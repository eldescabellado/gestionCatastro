unit uAuthManager;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.Hash,
  System.NetEncoding, System.JSON, Vcl.Graphics, Vcl.Imaging.pngimage,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  // Estado del Token de Autorización
  TEstadoToken = (etPendiente, etAprobado, etRechazado, etExpirado, etUsado);

  // Información del Token
  TInfoToken = record
    TokenID: Integer;
    Token: string;
    UsuarioSolicitante: Integer;
    UsuarioAutorizador: Integer;
    AccionCodigo: string;
    Descripcion: string;
    Estado: TEstadoToken;
    FechaSolicitud: TDateTime;
    FechaExpiracion: TDateTime;
    FechaRespuesta: TDateTime;
    DatosContexto: string;
  end;

  // Callback para eventos de autorización
  TOnAutorizacionCallback = procedure(const Token: string; Autorizado: Boolean) of object;

  // Clase principal de gestión de autorizaciones
  TAuthManager = class
  private
    FConnection: TFDConnection;
    FQuery: TFDQuery;
    FOnAutorizacion: TOnAutorizacionCallback;
    FIntervaloVerificacion: Integer; // Milisegundos

    function GenerarTokenCriptografico: string;
    function EstadoToString(Estado: TEstadoToken): string;
    function StringToEstado(const Estado: string): TEstadoToken;
    procedure ActualizarEstadoToken(const Token: string; NuevoEstado: TEstadoToken;
      UsuarioAutorizador: Integer = 0; const Observaciones: string = '');

  public
    constructor Create(AConnection: TFDConnection);
    destructor Destroy; override;

    // Solicitud de autorización
    function SolicitarAutorizacion(const AccionCodigo: string;
      const Descripcion: string = ''; const DatosContexto: string = ''): string;

    // Verificación de token (simula respuesta de app móvil)
    function VerificarToken(const Token: string): Boolean;

    // Aprobar/Rechazar token (usado por supervisor)
    function AprobarToken(const Token: string; UsuarioAutorizador: Integer;
      const Observaciones: string = ''): Boolean;
    function RechazarToken(const Token: string; UsuarioAutorizador: Integer;
      const MotivoRechazo: string): Boolean;

    // Esperar autorización con timeout
    function EsperarAutorizacion(const Token: string; TimeoutSegundos: Integer): Boolean;

    // Obtener información del token
    function ObtenerInfoToken(const Token: string): TInfoToken;

    // Verificar si token está pendiente
    function TokenPendiente(const Token: string): Boolean;

    // Cancelar solicitud
    procedure CancelarSolicitud(const Token: string);

    // Generar código QR para el token (retorna imagen PNG en stream)
    function GenerarQRCode(const Token: string): TMemoryStream;

    // Obtener tiempo de expiración de política
    function ObtenerTiempoExpiracion(const AccionCodigo: string): Integer;

    // Limpiar tokens expirados
    procedure LimpiarTokensExpirados;

    // Simular autorización externa (para pruebas)
    procedure SimularAutorizacionExterna(const Token: string; Aprobar: Boolean);

    // Propiedades
    property OnAutorizacion: TOnAutorizacionCallback read FOnAutorizacion write FOnAutorizacion;
    property IntervaloVerificacion: Integer read FIntervaloVerificacion write FIntervaloVerificacion;
  end;

implementation

uses
  uDmMain;

{ TAuthManager }

constructor TAuthManager.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection;
  FIntervaloVerificacion := 1000; // 1 segundo por defecto
end;

destructor TAuthManager.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TAuthManager.GenerarTokenCriptografico: string;
var
  Bytes: TBytes;
  I: Integer;
  GUID: TGUID;
begin
  // Generar bytes aleatorios usando GUID + random
  CreateGUID(GUID);
  SetLength(Bytes, 32);

  // Mezclar GUID con random para mayor entropía
  Move(GUID, Bytes[0], 16);
  for I := 16 to 31 do
    Bytes[I] := Random(256);

  // Convertir a hash SHA256 y tomar los primeros 16 caracteres hex
  Result := Copy(THashSHA2.GetHashString(TNetEncoding.Base64.EncodeBytesToString(Bytes), SHA256), 1, 16);

  // Convertir a mayúsculas para legibilidad
  Result := UpperCase(Result);
end;

function TAuthManager.EstadoToString(Estado: TEstadoToken): string;
begin
  case Estado of
    etPendiente: Result := 'PENDIENTE';
    etAprobado: Result := 'APROBADO';
    etRechazado: Result := 'RECHAZADO';
    etExpirado: Result := 'EXPIRADO';
    etUsado: Result := 'USADO';
  else
    Result := 'PENDIENTE';
  end;
end;

function TAuthManager.StringToEstado(const Estado: string): TEstadoToken;
begin
  if Estado = 'APROBADO' then
    Result := etAprobado
  else if Estado = 'RECHAZADO' then
    Result := etRechazado
  else if Estado = 'EXPIRADO' then
    Result := etExpirado
  else if Estado = 'USADO' then
    Result := etUsado
  else
    Result := etPendiente;
end;

function TAuthManager.ObtenerTiempoExpiracion(const AccionCodigo: string): Integer;
begin
  // Buscar tiempo de expiración en políticas
  FQuery.SQL.Text :=
    'SELECT TiempoExpiracionToken FROM PoliticasSeguridad ' +
    'WHERE Codigo = :Codigo AND Activo = TRUE';
  FQuery.ParamByName('Codigo').AsString := 'POL_' + AccionCodigo;
  FQuery.Open;

  if FQuery.IsEmpty then
    Result := 300 // 5 minutos por defecto
  else
    Result := FQuery.FieldByName('TiempoExpiracionToken').AsInteger;
end;

function TAuthManager.SolicitarAutorizacion(const AccionCodigo: string;
  const Descripcion: string; const DatosContexto: string): string;
var
  Token: string;
  TiempoExpiracion: Integer;
begin
  Token := GenerarTokenCriptografico;
  TiempoExpiracion := ObtenerTiempoExpiracion(AccionCodigo);

  FQuery.SQL.Text :=
    'INSERT INTO TokensAutorizacion ' +
    '(Token, UsuarioSolicitante, AccionCodigo, Descripcion, Estado, ' +
    ' DatosContexto, FechaSolicitud, FechaExpiracion, IPSolicitante, MacSolicitante) ' +
    'VALUES ' +
    '(:Token, :Usuario, :Accion, :Descripcion, ''PENDIENTE'', ' +
    ' :Contexto::jsonb, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + :Expiracion * INTERVAL ''1 second'', ' +
    ' :IP, :MAC) ' +
    'RETURNING TokenID';

  FQuery.ParamByName('Token').AsString := Token;
  FQuery.ParamByName('Usuario').AsInteger := dmMain.UsuarioActual.UsuarioID;
  FQuery.ParamByName('Accion').AsString := AccionCodigo;
  FQuery.ParamByName('Descripcion').AsString := Descripcion;

  if DatosContexto <> '' then
    FQuery.ParamByName('Contexto').AsString := DatosContexto
  else
    FQuery.ParamByName('Contexto').AsString := '{}';

  FQuery.ParamByName('Expiracion').AsInteger := TiempoExpiracion;
  FQuery.ParamByName('IP').AsString := dmMain.UsuarioActual.IPCliente;
  FQuery.ParamByName('MAC').AsString := dmMain.UsuarioActual.MACCliente;

  FQuery.Open;

  // Registrar en bitácora
  dmMain.RegistrarBitacora('SOLICITUD_AUTORIZACION', 'SEGURIDAD', 'TokensAutorizacion',
    FQuery.FieldByName('TokenID').AsInteger,
    '', Format('{"token":"%s","accion":"%s"}', [Token, AccionCodigo]), 'EXITO');

  Result := Token;
end;

function TAuthManager.VerificarToken(const Token: string): Boolean;
var
  Estado: string;
begin
  Result := False;

  FQuery.SQL.Text :=
    'SELECT Estado, FechaExpiracion FROM TokensAutorizacion WHERE Token = :Token';
  FQuery.ParamByName('Token').AsString := Token;
  FQuery.Open;

  if FQuery.IsEmpty then
    Exit;

  // Verificar si expiró
  if FQuery.FieldByName('FechaExpiracion').AsDateTime < Now then
  begin
    ActualizarEstadoToken(Token, etExpirado);
    Exit;
  end;

  Estado := FQuery.FieldByName('Estado').AsString;
  Result := Estado = 'APROBADO';

  // Si fue aprobado, marcarlo como usado
  if Result then
    ActualizarEstadoToken(Token, etUsado);
end;

procedure TAuthManager.ActualizarEstadoToken(const Token: string;
  NuevoEstado: TEstadoToken; UsuarioAutorizador: Integer; const Observaciones: string);
begin
  FQuery.SQL.Text :=
    'UPDATE TokensAutorizacion SET ' +
    'Estado = :Estado, ' +
    'UsuarioAutorizador = COALESCE(:Autorizador, UsuarioAutorizador), ' +
    'FechaRespuesta = CASE WHEN :Estado IN (''APROBADO'', ''RECHAZADO'') THEN CURRENT_TIMESTAMP ELSE FechaRespuesta END, ' +
    'Observaciones = COALESCE(:Obs, Observaciones) ' +
    'WHERE Token = :Token';

  FQuery.ParamByName('Estado').AsString := EstadoToString(NuevoEstado);

  if UsuarioAutorizador > 0 then
    FQuery.ParamByName('Autorizador').AsInteger := UsuarioAutorizador
  else
    FQuery.ParamByName('Autorizador').Clear;

  if Observaciones <> '' then
    FQuery.ParamByName('Obs').AsString := Observaciones
  else
    FQuery.ParamByName('Obs').Clear;

  FQuery.ParamByName('Token').AsString := Token;
  FQuery.ExecSQL;
end;

function TAuthManager.AprobarToken(const Token: string; UsuarioAutorizador: Integer;
  const Observaciones: string): Boolean;
var
  Info: TInfoToken;
begin
  Result := False;
  Info := ObtenerInfoToken(Token);

  if Info.TokenID = 0 then
    Exit;

  if Info.Estado <> etPendiente then
    Exit;

  if Info.FechaExpiracion < Now then
  begin
    ActualizarEstadoToken(Token, etExpirado);
    Exit;
  end;

  ActualizarEstadoToken(Token, etAprobado, UsuarioAutorizador, Observaciones);

  // Registrar en bitácora
  dmMain.RegistrarBitacora('AUTORIZACION_APROBADA', 'SEGURIDAD', 'TokensAutorizacion',
    Info.TokenID, '', Format('{"token":"%s","autorizador":%d}', [Token, UsuarioAutorizador]), 'EXITO');

  Result := True;

  // Callback
  if Assigned(FOnAutorizacion) then
    FOnAutorizacion(Token, True);
end;

function TAuthManager.RechazarToken(const Token: string; UsuarioAutorizador: Integer;
  const MotivoRechazo: string): Boolean;
var
  Info: TInfoToken;
begin
  Result := False;
  Info := ObtenerInfoToken(Token);

  if Info.TokenID = 0 then
    Exit;

  if Info.Estado <> etPendiente then
    Exit;

  ActualizarEstadoToken(Token, etRechazado, UsuarioAutorizador, MotivoRechazo);

  // Registrar en bitácora
  dmMain.RegistrarBitacora('AUTORIZACION_RECHAZADA', 'SEGURIDAD', 'TokensAutorizacion',
    Info.TokenID, '', Format('{"token":"%s","motivo":"%s"}', [Token, MotivoRechazo]), 'EXITO');

  Result := True;

  // Callback
  if Assigned(FOnAutorizacion) then
    FOnAutorizacion(Token, False);
end;

function TAuthManager.EsperarAutorizacion(const Token: string; TimeoutSegundos: Integer): Boolean;
var
  FechaLimite: TDateTime;
  Estado: TEstadoToken;
begin
  Result := False;
  FechaLimite := IncSecond(Now, TimeoutSegundos);

  while Now < FechaLimite do
  begin
    // Verificar estado actual
    FQuery.SQL.Text := 'SELECT Estado FROM TokensAutorizacion WHERE Token = :Token';
    FQuery.ParamByName('Token').AsString := Token;
    FQuery.Open;

    if FQuery.IsEmpty then
      Exit;

    Estado := StringToEstado(FQuery.FieldByName('Estado').AsString);

    case Estado of
      etAprobado:
        begin
          ActualizarEstadoToken(Token, etUsado);
          Result := True;
          Exit;
        end;
      etRechazado, etExpirado:
        Exit;
    end;

    // Esperar antes de siguiente verificación
    Sleep(FIntervaloVerificacion);
  end;

  // Timeout - marcar como expirado
  ActualizarEstadoToken(Token, etExpirado);
end;

function TAuthManager.ObtenerInfoToken(const Token: string): TInfoToken;
begin
  FillChar(Result, SizeOf(Result), 0);

  FQuery.SQL.Text :=
    'SELECT TokenID, Token, UsuarioSolicitante, UsuarioAutorizador, AccionCodigo, ' +
    '       Descripcion, Estado, FechaSolicitud, FechaExpiracion, FechaRespuesta, ' +
    '       DatosContexto::text ' +
    'FROM TokensAutorizacion WHERE Token = :Token';
  FQuery.ParamByName('Token').AsString := Token;
  FQuery.Open;

  if not FQuery.IsEmpty then
  begin
    Result.TokenID := FQuery.FieldByName('TokenID').AsInteger;
    Result.Token := FQuery.FieldByName('Token').AsString;
    Result.UsuarioSolicitante := FQuery.FieldByName('UsuarioSolicitante').AsInteger;
    Result.UsuarioAutorizador := FQuery.FieldByName('UsuarioAutorizador').AsInteger;
    Result.AccionCodigo := FQuery.FieldByName('AccionCodigo').AsString;
    Result.Descripcion := FQuery.FieldByName('Descripcion').AsString;
    Result.Estado := StringToEstado(FQuery.FieldByName('Estado').AsString);
    Result.FechaSolicitud := FQuery.FieldByName('FechaSolicitud').AsDateTime;
    Result.FechaExpiracion := FQuery.FieldByName('FechaExpiracion').AsDateTime;
    Result.FechaRespuesta := FQuery.FieldByName('FechaRespuesta').AsDateTime;
    Result.DatosContexto := FQuery.FieldByName('DatosContexto').AsString;
  end;
end;

function TAuthManager.TokenPendiente(const Token: string): Boolean;
var
  Info: TInfoToken;
begin
  Info := ObtenerInfoToken(Token);
  Result := (Info.TokenID > 0) and (Info.Estado = etPendiente) and (Info.FechaExpiracion > Now);
end;

procedure TAuthManager.CancelarSolicitud(const Token: string);
begin
  FQuery.SQL.Text :=
    'DELETE FROM TokensAutorizacion WHERE Token = :Token AND Estado = ''PENDIENTE''';
  FQuery.ParamByName('Token').AsString := Token;
  FQuery.ExecSQL;
end;

function TAuthManager.GenerarQRCode(const Token: string): TMemoryStream;
var
  QRContent: string;
  Bitmap: TBitmap;
  PNG: TPngImage;
begin
  // Contenido del QR: URL o datos para la app móvil
  QRContent := Format('sigiep://autorizar?token=%s&usuario=%d',
    [Token, dmMain.UsuarioActual.UsuarioID]);

  // Crear stream de memoria
  Result := TMemoryStream.Create;

  // Nota: Aquí se implementaría la generación real del QR usando
  // una librería como DelphiZXingQRCode o similar
  // Por ahora, creamos una imagen placeholder

  Bitmap := TBitmap.Create;
  try
    Bitmap.Width := 200;
    Bitmap.Height := 200;
    Bitmap.Canvas.Brush.Color := clWhite;
    Bitmap.Canvas.FillRect(Rect(0, 0, 200, 200));
    Bitmap.Canvas.Font.Size := 10;
    Bitmap.Canvas.TextOut(10, 80, 'Token: ' + Token);
    Bitmap.Canvas.TextOut(10, 100, 'QR Code');

    // Convertir a PNG
    PNG := TPngImage.Create;
    try
      PNG.Assign(Bitmap);
      PNG.SaveToStream(Result);
      Result.Position := 0;
    finally
      PNG.Free;
    end;
  finally
    Bitmap.Free;
  end;
end;

procedure TAuthManager.LimpiarTokensExpirados;
begin
  FQuery.SQL.Text :=
    'UPDATE TokensAutorizacion SET Estado = ''EXPIRADO'' ' +
    'WHERE Estado = ''PENDIENTE'' AND FechaExpiracion < CURRENT_TIMESTAMP';
  FQuery.ExecSQL;
end;

procedure TAuthManager.SimularAutorizacionExterna(const Token: string; Aprobar: Boolean);
begin
  // Método para simular que un dispositivo externo (app móvil) autorizó
  // En producción, esto vendría de la API REST

  if Aprobar then
    AprobarToken(Token, dmMain.UsuarioActual.UsuarioID, 'Aprobación simulada')
  else
    RechazarToken(Token, dmMain.UsuarioActual.UsuarioID, 'Rechazo simulado');
end;

end.
