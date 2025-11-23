unit uNotificaciones;

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient,
  System.Net.HttpClientComponent, System.JSON, System.NetEncoding;

type
  // Resultado del envío de notificación
  TResultadoNotificacion = record
    Exitoso: Boolean;
    Codigo: Integer;
    Mensaje: string;
    IDMensaje: string;
    FechaEnvio: TDateTime;
  end;

  // Interfaz genérica de notificador
  INotificador = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function Enviar(const Destinatario, Asunto, Mensaje: string): TResultadoNotificacion;
    function ValidarDestinatario(const Destinatario: string): Boolean;
    function EstaConfigurado: Boolean;
  end;

  // Clase base abstracta
  TNotificadorBase = class abstract(TInterfacedObject, INotificador)
  protected
    FActivo: Boolean;
    FUltimoError: string;
  public
    function Enviar(const Destinatario, Asunto, Mensaje: string): TResultadoNotificacion; virtual; abstract;
    function ValidarDestinatario(const Destinatario: string): Boolean; virtual; abstract;
    function EstaConfigurado: Boolean; virtual; abstract;
    property Activo: Boolean read FActivo write FActivo;
    property UltimoError: string read FUltimoError;
  end;

  // Notificador por Email (SMTP)
  TNotificadorEmail = class(TNotificadorBase)
  private
    FServidorSMTP: string;
    FPuerto: Integer;
    FUsuario: string;
    FPassword: string;
    FRemitente: string;
    FUsarSSL: Boolean;

  public
    constructor Create;

    procedure Configurar(const Servidor: string; Puerto: Integer;
      const Usuario, Password, Remitente: string; UsarSSL: Boolean = True);

    function Enviar(const Destinatario, Asunto, Mensaje: string): TResultadoNotificacion; override;
    function ValidarDestinatario(const Destinatario: string): Boolean; override;
    function EstaConfigurado: Boolean; override;

    // Envío con adjuntos
    function EnviarConAdjunto(const Destinatario, Asunto, Mensaje: string;
      const RutaAdjunto: string): TResultadoNotificacion;

    // Propiedades
    property ServidorSMTP: string read FServidorSMTP write FServidorSMTP;
    property Puerto: Integer read FPuerto write FPuerto;
    property Usuario: string read FUsuario write FUsuario;
    property Password: string read FPassword write FPassword;
    property Remitente: string read FRemitente write FRemitente;
    property UsarSSL: Boolean read FUsarSSL write FUsarSSL;
  end;

  // Notificador por SMS (API REST)
  TNotificadorSMS = class(TNotificadorBase)
  private
    FAPIUrl: string;
    FAPIKey: string;
    FAPISecret: string;
    FRemitente: string;
    FHttpClient: TNetHTTPClient;
    FTimeoutSegundos: Integer;

    function ConstruirPayload(const Destinatario, Mensaje: string): string;
    function ProcesarRespuesta(const Response: IHTTPResponse): TResultadoNotificacion;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Configurar(const APIUrl, APIKey, APISecret, Remitente: string);

    function Enviar(const Destinatario, Asunto, Mensaje: string): TResultadoNotificacion; override;
    function ValidarDestinatario(const Destinatario: string): Boolean; override;
    function EstaConfigurado: Boolean; override;

    // Métodos específicos de SMS
    function EnviarSMS(const NumeroTelefono, Mensaje: string): TResultadoNotificacion;
    function ConsultarSaldo: Double;
    function ConsultarEstadoMensaje(const IDMensaje: string): string;

    // Propiedades
    property APIUrl: string read FAPIUrl write FAPIUrl;
    property APIKey: string read FAPIKey write FAPIKey;
    property APISecret: string read FAPISecret write FAPISecret;
    property Remitente: string read FRemitente write FRemitente;
    property TimeoutSegundos: Integer read FTimeoutSegundos write FTimeoutSegundos;
  end;

  // Gestor de Notificaciones (Fachada)
  TGestorNotificaciones = class
  private
    FNotificadorEmail: TNotificadorEmail;
    FNotificadorSMS: TNotificadorSMS;

  public
    constructor Create;
    destructor Destroy; override;

    procedure ConfigurarEmail(const Servidor: string; Puerto: Integer;
      const Usuario, Password, Remitente: string; UsarSSL: Boolean = True);
    procedure ConfigurarSMS(const APIUrl, APIKey, APISecret, Remitente: string);

    function EnviarEmail(const Destinatario, Asunto, Mensaje: string): TResultadoNotificacion;
    function EnviarSMS(const Telefono, Mensaje: string): TResultadoNotificacion;

    // Envío masivo
    function EnviarEmailMasivo(const Destinatarios: TArray<string>;
      const Asunto, Mensaje: string): TArray<TResultadoNotificacion>;
    function EnviarSMSMasivo(const Telefonos: TArray<string>;
      const Mensaje: string): TArray<TResultadoNotificacion>;

    // Verificar configuración
    function EmailConfigurado: Boolean;
    function SMSConfigurado: Boolean;

    // Propiedades
    property NotificadorEmail: TNotificadorEmail read FNotificadorEmail;
    property NotificadorSMS: TNotificadorSMS read FNotificadorSMS;
  end;

implementation

uses
  System.RegularExpressions, IdSMTP, IdMessage, IdSSLOpenSSL, IdText,
  IdAttachmentFile, IdExplicitTLSClientServerBase;

{ TNotificadorEmail }

constructor TNotificadorEmail.Create;
begin
  inherited Create;
  FPuerto := 587;
  FUsarSSL := True;
  FActivo := False;
end;

procedure TNotificadorEmail.Configurar(const Servidor: string; Puerto: Integer;
  const Usuario, Password, Remitente: string; UsarSSL: Boolean);
begin
  FServidorSMTP := Servidor;
  FPuerto := Puerto;
  FUsuario := Usuario;
  FPassword := Password;
  FRemitente := Remitente;
  FUsarSSL := UsarSSL;
  FActivo := True;
end;

function TNotificadorEmail.EstaConfigurado: Boolean;
begin
  Result := FActivo and (FServidorSMTP <> '') and (FRemitente <> '');
end;

function TNotificadorEmail.ValidarDestinatario(const Destinatario: string): Boolean;
var
  EmailRegex: TRegEx;
begin
  // Validar formato de email
  EmailRegex := TRegEx.Create('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  Result := EmailRegex.IsMatch(Destinatario);
end;

function TNotificadorEmail.Enviar(const Destinatario, Asunto, Mensaje: string): TResultadoNotificacion;
var
  SMTP: TIdSMTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Email: TIdMessage;
  TextPart: TIdText;
begin
  Result.Exitoso := False;
  Result.FechaEnvio := Now;

  if not EstaConfigurado then
  begin
    Result.Mensaje := 'Notificador de Email no configurado';
    Exit;
  end;

  if not ValidarDestinatario(Destinatario) then
  begin
    Result.Mensaje := 'Dirección de email inválida: ' + Destinatario;
    Exit;
  end;

  SMTP := TIdSMTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  Email := TIdMessage.Create(nil);
  try
    try
      // Configurar SSL
      if FUsarSSL then
      begin
        SSLHandler.SSLOptions.Method := sslvTLSv1_2;
        SSLHandler.SSLOptions.Mode := sslmClient;
        SMTP.IOHandler := SSLHandler;
        SMTP.UseTLS := utUseExplicitTLS;
      end;

      // Configurar SMTP
      SMTP.Host := FServidorSMTP;
      SMTP.Port := FPuerto;
      SMTP.Username := FUsuario;
      SMTP.Password := FPassword;
      SMTP.AuthType := satDefault;

      // Configurar mensaje
      Email.From.Address := FRemitente;
      Email.Recipients.EMailAddresses := Destinatario;
      Email.Subject := Asunto;
      Email.ContentType := 'text/html';

      // Cuerpo del mensaje
      TextPart := TIdText.Create(Email.MessageParts, nil);
      TextPart.Body.Text := Mensaje;
      TextPart.ContentType := 'text/html; charset=UTF-8';

      // Enviar
      SMTP.Connect;
      try
        SMTP.Send(Email);
        Result.Exitoso := True;
        Result.Mensaje := 'Email enviado correctamente';
        Result.IDMensaje := Email.MsgId;
        Result.Codigo := 200;
      finally
        SMTP.Disconnect;
      end;

    except
      on E: Exception do
      begin
        Result.Exitoso := False;
        Result.Mensaje := 'Error al enviar email: ' + E.Message;
        Result.Codigo := -1;
        FUltimoError := E.Message;
      end;
    end;
  finally
    Email.Free;
    SSLHandler.Free;
    SMTP.Free;
  end;
end;

function TNotificadorEmail.EnviarConAdjunto(const Destinatario, Asunto, Mensaje: string;
  const RutaAdjunto: string): TResultadoNotificacion;
var
  SMTP: TIdSMTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Email: TIdMessage;
  TextPart: TIdText;
begin
  Result.Exitoso := False;
  Result.FechaEnvio := Now;

  if not FileExists(RutaAdjunto) then
  begin
    Result.Mensaje := 'Archivo adjunto no encontrado: ' + RutaAdjunto;
    Exit;
  end;

  SMTP := TIdSMTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  Email := TIdMessage.Create(nil);
  try
    try
      // Configurar SSL
      if FUsarSSL then
      begin
        SSLHandler.SSLOptions.Method := sslvTLSv1_2;
        SMTP.IOHandler := SSLHandler;
        SMTP.UseTLS := utUseExplicitTLS;
      end;

      // Configurar SMTP
      SMTP.Host := FServidorSMTP;
      SMTP.Port := FPuerto;
      SMTP.Username := FUsuario;
      SMTP.Password := FPassword;

      // Configurar mensaje
      Email.From.Address := FRemitente;
      Email.Recipients.EMailAddresses := Destinatario;
      Email.Subject := Asunto;

      // Cuerpo
      TextPart := TIdText.Create(Email.MessageParts, nil);
      TextPart.Body.Text := Mensaje;
      TextPart.ContentType := 'text/html; charset=UTF-8';

      // Adjunto
      TIdAttachmentFile.Create(Email.MessageParts, RutaAdjunto);

      // Enviar
      SMTP.Connect;
      try
        SMTP.Send(Email);
        Result.Exitoso := True;
        Result.Mensaje := 'Email con adjunto enviado correctamente';
        Result.Codigo := 200;
      finally
        SMTP.Disconnect;
      end;

    except
      on E: Exception do
      begin
        Result.Mensaje := 'Error al enviar email: ' + E.Message;
        Result.Codigo := -1;
      end;
    end;
  finally
    Email.Free;
    SSLHandler.Free;
    SMTP.Free;
  end;
end;

{ TNotificadorSMS }

constructor TNotificadorSMS.Create;
begin
  inherited Create;
  FHttpClient := TNetHTTPClient.Create(nil);
  FTimeoutSegundos := 30;
  FActivo := False;
end;

destructor TNotificadorSMS.Destroy;
begin
  FHttpClient.Free;
  inherited;
end;

procedure TNotificadorSMS.Configurar(const APIUrl, APIKey, APISecret, Remitente: string);
begin
  FAPIUrl := APIUrl;
  FAPIKey := APIKey;
  FAPISecret := APISecret;
  FRemitente := Remitente;
  FActivo := True;

  // Configurar cliente HTTP
  FHttpClient.ConnectionTimeout := FTimeoutSegundos * 1000;
  FHttpClient.ResponseTimeout := FTimeoutSegundos * 1000;
end;

function TNotificadorSMS.EstaConfigurado: Boolean;
begin
  Result := FActivo and (FAPIUrl <> '') and (FAPIKey <> '');
end;

function TNotificadorSMS.ValidarDestinatario(const Destinatario: string): Boolean;
var
  PhoneRegex: TRegEx;
  Numero: string;
begin
  // Limpiar número
  Numero := Destinatario;
  Numero := StringReplace(Numero, ' ', '', [rfReplaceAll]);
  Numero := StringReplace(Numero, '-', '', [rfReplaceAll]);
  Numero := StringReplace(Numero, '(', '', [rfReplaceAll]);
  Numero := StringReplace(Numero, ')', '', [rfReplaceAll]);

  // Validar formato (Venezuela: +58, mínimo 10 dígitos)
  PhoneRegex := TRegEx.Create('^\+?[0-9]{10,15}$');
  Result := PhoneRegex.IsMatch(Numero);
end;

function TNotificadorSMS.ConstruirPayload(const Destinatario, Mensaje: string): string;
var
  JSONObj: TJSONObject;
begin
  // Construir JSON para API SMS
  // Formato típico de API SMS (ajustar según proveedor específico)
  JSONObj := TJSONObject.Create;
  try
    JSONObj.AddPair('api_key', FAPIKey);
    JSONObj.AddPair('api_secret', FAPISecret);
    JSONObj.AddPair('from', FRemitente);
    JSONObj.AddPair('to', Destinatario);
    JSONObj.AddPair('text', Mensaje);
    JSONObj.AddPair('type', 'unicode');

    Result := JSONObj.ToString;
  finally
    JSONObj.Free;
  end;
end;

function TNotificadorSMS.ProcesarRespuesta(const Response: IHTTPResponse): TResultadoNotificacion;
var
  JSONResponse: TJSONObject;
  StatusCode: Integer;
begin
  Result.Exitoso := False;
  Result.FechaEnvio := Now;
  Result.Codigo := Response.StatusCode;

  try
    if Response.StatusCode = 200 then
    begin
      JSONResponse := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
      try
        if JSONResponse <> nil then
        begin
          // Parsear respuesta según formato del proveedor
          if JSONResponse.TryGetValue<Integer>('status', StatusCode) then
          begin
            Result.Exitoso := StatusCode = 0;
            JSONResponse.TryGetValue<string>('message_id', Result.IDMensaje);

            if Result.Exitoso then
              Result.Mensaje := 'SMS enviado correctamente'
            else
              JSONResponse.TryGetValue<string>('error_text', Result.Mensaje);
          end
          else
          begin
            // Asumir éxito si no hay campo status
            Result.Exitoso := True;
            Result.Mensaje := 'SMS enviado';
          end;
        end;
      finally
        JSONResponse.Free;
      end;
    end
    else
    begin
      Result.Mensaje := Format('Error HTTP %d: %s', [Response.StatusCode, Response.StatusText]);
    end;
  except
    on E: Exception do
    begin
      Result.Mensaje := 'Error procesando respuesta: ' + E.Message;
    end;
  end;
end;

function TNotificadorSMS.Enviar(const Destinatario, Asunto, Mensaje: string): TResultadoNotificacion;
begin
  // Para SMS, el Asunto se ignora
  Result := EnviarSMS(Destinatario, Mensaje);
end;

function TNotificadorSMS.EnviarSMS(const NumeroTelefono, Mensaje: string): TResultadoNotificacion;
var
  Response: IHTTPResponse;
  Payload: TStringStream;
  Headers: TNetHeaders;
begin
  Result.Exitoso := False;
  Result.FechaEnvio := Now;

  if not EstaConfigurado then
  begin
    Result.Mensaje := 'Notificador SMS no configurado';
    Exit;
  end;

  if not ValidarDestinatario(NumeroTelefono) then
  begin
    Result.Mensaje := 'Número de teléfono inválido: ' + NumeroTelefono;
    Exit;
  end;

  // Validar longitud del mensaje
  if Length(Mensaje) > 160 then
  begin
    // Advertencia: mensaje largo se dividirá
  end;

  Payload := TStringStream.Create(ConstruirPayload(NumeroTelefono, Mensaje), TEncoding.UTF8);
  try
    try
      // Configurar headers
      SetLength(Headers, 2);
      Headers[0] := TNetHeader.Create('Content-Type', 'application/json');
      Headers[1] := TNetHeader.Create('Accept', 'application/json');

      // Enviar POST
      Response := FHttpClient.Post(FAPIUrl, Payload, nil, Headers);

      Result := ProcesarRespuesta(Response);

    except
      on E: Exception do
      begin
        Result.Exitoso := False;
        Result.Mensaje := 'Error de conexión: ' + E.Message;
        Result.Codigo := -1;
        FUltimoError := E.Message;
      end;
    end;
  finally
    Payload.Free;
  end;
end;

function TNotificadorSMS.ConsultarSaldo: Double;
var
  Response: IHTTPResponse;
  JSONResponse: TJSONObject;
  URL: string;
begin
  Result := 0;

  if not EstaConfigurado then
    Exit;

  try
    // URL de consulta de saldo (ajustar según proveedor)
    URL := FAPIUrl + '/balance?api_key=' + TNetEncoding.URL.Encode(FAPIKey) +
           '&api_secret=' + TNetEncoding.URL.Encode(FAPISecret);

    Response := FHttpClient.Get(URL);

    if Response.StatusCode = 200 then
    begin
      JSONResponse := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
      try
        if JSONResponse <> nil then
          JSONResponse.TryGetValue<Double>('balance', Result);
      finally
        JSONResponse.Free;
      end;
    end;
  except
    Result := -1;
  end;
end;

function TNotificadorSMS.ConsultarEstadoMensaje(const IDMensaje: string): string;
var
  Response: IHTTPResponse;
  JSONResponse: TJSONObject;
  URL: string;
begin
  Result := 'DESCONOCIDO';

  if not EstaConfigurado or (IDMensaje = '') then
    Exit;

  try
    // URL de consulta de estado (ajustar según proveedor)
    URL := FAPIUrl + '/status?api_key=' + TNetEncoding.URL.Encode(FAPIKey) +
           '&api_secret=' + TNetEncoding.URL.Encode(FAPISecret) +
           '&message_id=' + TNetEncoding.URL.Encode(IDMensaje);

    Response := FHttpClient.Get(URL);

    if Response.StatusCode = 200 then
    begin
      JSONResponse := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
      try
        if JSONResponse <> nil then
          JSONResponse.TryGetValue<string>('status', Result);
      finally
        JSONResponse.Free;
      end;
    end;
  except
    Result := 'ERROR';
  end;
end;

{ TGestorNotificaciones }

constructor TGestorNotificaciones.Create;
begin
  inherited Create;
  FNotificadorEmail := TNotificadorEmail.Create;
  FNotificadorSMS := TNotificadorSMS.Create;
end;

destructor TGestorNotificaciones.Destroy;
begin
  FNotificadorEmail.Free;
  FNotificadorSMS.Free;
  inherited;
end;

procedure TGestorNotificaciones.ConfigurarEmail(const Servidor: string; Puerto: Integer;
  const Usuario, Password, Remitente: string; UsarSSL: Boolean);
begin
  FNotificadorEmail.Configurar(Servidor, Puerto, Usuario, Password, Remitente, UsarSSL);
end;

procedure TGestorNotificaciones.ConfigurarSMS(const APIUrl, APIKey, APISecret, Remitente: string);
begin
  FNotificadorSMS.Configurar(APIUrl, APIKey, APISecret, Remitente);
end;

function TGestorNotificaciones.EnviarEmail(const Destinatario, Asunto, Mensaje: string): TResultadoNotificacion;
begin
  Result := FNotificadorEmail.Enviar(Destinatario, Asunto, Mensaje);
end;

function TGestorNotificaciones.EnviarSMS(const Telefono, Mensaje: string): TResultadoNotificacion;
begin
  Result := FNotificadorSMS.EnviarSMS(Telefono, Mensaje);
end;

function TGestorNotificaciones.EnviarEmailMasivo(const Destinatarios: TArray<string>;
  const Asunto, Mensaje: string): TArray<TResultadoNotificacion>;
var
  I: Integer;
begin
  SetLength(Result, Length(Destinatarios));
  for I := 0 to High(Destinatarios) do
    Result[I] := FNotificadorEmail.Enviar(Destinatarios[I], Asunto, Mensaje);
end;

function TGestorNotificaciones.EnviarSMSMasivo(const Telefonos: TArray<string>;
  const Mensaje: string): TArray<TResultadoNotificacion>;
var
  I: Integer;
begin
  SetLength(Result, Length(Telefonos));
  for I := 0 to High(Telefonos) do
    Result[I] := FNotificadorSMS.EnviarSMS(Telefonos[I], Mensaje);
end;

function TGestorNotificaciones.EmailConfigurado: Boolean;
begin
  Result := FNotificadorEmail.EstaConfigurado;
end;

function TGestorNotificaciones.SMSConfigurado: Boolean;
begin
  Result := FNotificadorSMS.EstaConfigurado;
end;

end.
