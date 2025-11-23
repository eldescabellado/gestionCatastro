unit uDmMain;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles, System.Hash,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, Data.DB;

type
  // Información del usuario logueado
  TUsuarioSesion = record
    UsuarioID: Integer;
    Username: string;
    NombreCompleto: string;
    Email: string;
    RolID: Integer;
    RolNombre: string;
    EsSuperUsuario: Boolean;
    IPCliente: string;
    MACCliente: string;
    NombreEquipo: string;
    FechaLogin: TDateTime;
  end;

  TdmMain = class(TDataModule)
    // Conexiones
    FDConnectionPG: TFDConnection;
    FDConnectionSQLite: TFDConnection;

    // Drivers y GUI
    FDPhysPgDriverLink: TFDPhysPgDriverLink;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;

    // Queries de uso general
    qryGeneral: TFDQuery;
    qryAuditoria: TFDQuery;
    qryUsuarios: TFDQuery;
    qryPermisos: TFDQuery;

    // Transacciones
    FDTransactionPG: TFDTransaction;

    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);

  private
    FUsuarioActual: TUsuarioSesion;
    FConfigPath: string;
    FConectado: Boolean;

    function GetIPLocal: string;
    function GetMACAddress: string;
    function GetNombreEquipo: string;
    function HashPassword(const Password, Salt: string): string;
    function GenerarSalt: string;

  public
    // Conexión
    function ConectarPostgreSQL: Boolean;
    function ConectarSQLiteMemoria: Boolean;
    procedure Desconectar;
    function EstaConectado: Boolean;

    // Autenticación
    function Login(const Username, Password: string; out MensajeError: string): Boolean;
    procedure Logout;
    function CambiarPassword(const PasswordActual, PasswordNuevo: string): Boolean;
    function VerificarPermiso(const CodigoPermiso: string): Boolean;
    function RequiereAutorizacionRemota(const CodigoPermiso: string): Boolean;

    // Auditoría
    procedure RegistrarBitacora(const Accion, Modulo, Tabla: string;
      RegistroID: Integer; const DatosAnteriores, DatosNuevos: string;
      const Resultado: string = 'EXITO'; const MensajeError: string = '');

    // Configuración
    function ObtenerConfiguracion(const Clave: string; const ValorDefecto: string = ''): string;
    procedure GuardarConfiguracion(const Clave, Valor: string);

    // Propiedades
    property UsuarioActual: TUsuarioSesion read FUsuarioActual;
    property Conectado: Boolean read FConectado;
    property ConnectionPG: TFDConnection read FDConnectionPG;
    property ConnectionSQLite: TFDConnection read FDConnectionSQLite;
  end;

var
  dmMain: TdmMain;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  Winapi.Windows, Winapi.Winsock, Vcl.Forms, System.NetEncoding;

{ TdmMain }

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  FConectado := False;
  FConfigPath := ExtractFilePath(Application.ExeName) + 'Config\';

  // Inicializar conexión PostgreSQL
  FDConnectionPG.Params.Clear;
  FDConnectionPG.DriverName := 'PG';
  FDConnectionPG.LoginPrompt := False;

  // Inicializar conexión SQLite en memoria
  FDConnectionSQLite.Params.Clear;
  FDConnectionSQLite.DriverName := 'SQLite';
  FDConnectionSQLite.Params.Add('Database=:memory:');
  FDConnectionSQLite.LoginPrompt := False;

  // Configurar transacción
  FDTransactionPG.Connection := FDConnectionPG;
  FDTransactionPG.Options.Isolation := xiReadCommitted;
  FDTransactionPG.Options.AutoCommit := False;
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
  Desconectar;
end;

function TdmMain.ConectarPostgreSQL: Boolean;
var
  IniFile: TIniFile;
  ConfigFile: string;
begin
  Result := False;

  try
    ConfigFile := FConfigPath + 'database.ini';

    if not FileExists(ConfigFile) then
    begin
      // Crear archivo de configuración por defecto
      ForceDirectories(FConfigPath);
      IniFile := TIniFile.Create(ConfigFile);
      try
        IniFile.WriteString('PostgreSQL', 'Server', 'localhost');
        IniFile.WriteString('PostgreSQL', 'Port', '5432');
        IniFile.WriteString('PostgreSQL', 'Database', 'sigiep_catastro');
        IniFile.WriteString('PostgreSQL', 'Username', 'postgres');
        IniFile.WriteString('PostgreSQL', 'Password', '');
      finally
        IniFile.Free;
      end;
    end;

    // Leer configuración
    IniFile := TIniFile.Create(ConfigFile);
    try
      FDConnectionPG.Params.Values['Server'] := IniFile.ReadString('PostgreSQL', 'Server', 'localhost');
      FDConnectionPG.Params.Values['Port'] := IniFile.ReadString('PostgreSQL', 'Port', '5432');
      FDConnectionPG.Params.Values['Database'] := IniFile.ReadString('PostgreSQL', 'Database', 'sigiep_catastro');
      FDConnectionPG.Params.Values['User_Name'] := IniFile.ReadString('PostgreSQL', 'Username', 'postgres');
      FDConnectionPG.Params.Values['Password'] := IniFile.ReadString('PostgreSQL', 'Password', '');
      FDConnectionPG.Params.Values['CharacterSet'] := 'UTF8';
    finally
      IniFile.Free;
    end;

    FDConnectionPG.Connected := True;
    FConectado := True;
    Result := True;

  except
    on E: Exception do
    begin
      FConectado := False;
      raise Exception.Create('Error al conectar a PostgreSQL: ' + E.Message);
    end;
  end;
end;

function TdmMain.ConectarSQLiteMemoria: Boolean;
begin
  Result := False;
  try
    FDConnectionSQLite.Connected := True;
    Result := True;
  except
    on E: Exception do
      raise Exception.Create('Error al inicializar SQLite en memoria: ' + E.Message);
  end;
end;

procedure TdmMain.Desconectar;
begin
  if FDConnectionPG.Connected then
  begin
    // Registrar cierre de sesión
    if FUsuarioActual.UsuarioID > 0 then
      RegistrarBitacora('LOGOUT', 'SEGURIDAD', 'Usuarios', FUsuarioActual.UsuarioID, '', '', 'EXITO');

    FDConnectionPG.Connected := False;
  end;

  if FDConnectionSQLite.Connected then
    FDConnectionSQLite.Connected := False;

  FConectado := False;
  FillChar(FUsuarioActual, SizeOf(FUsuarioActual), 0);
end;

function TdmMain.EstaConectado: Boolean;
begin
  Result := FConectado and FDConnectionPG.Connected;
end;

function TdmMain.GetIPLocal: string;
var
  WSAData: TWSAData;
  HostEnt: PHostEnt;
  HostName: array[0..255] of AnsiChar;
  InAddr: TInAddr;
begin
  Result := '0.0.0.0';
  try
    if WSAStartup($0101, WSAData) = 0 then
    begin
      if gethostname(HostName, SizeOf(HostName)) = 0 then
      begin
        HostEnt := gethostbyname(HostName);
        if HostEnt <> nil then
        begin
          InAddr := PInAddr(HostEnt^.h_addr_list^)^;
          Result := string(inet_ntoa(InAddr));
        end;
      end;
      WSACleanup;
    end;
  except
    Result := '0.0.0.0';
  end;
end;

function TdmMain.GetMACAddress: string;
begin
  // Implementación simplificada - en producción usar GetAdaptersInfo
  Result := '00:00:00:00:00:00';
end;

function TdmMain.GetNombreEquipo: string;
var
  Buffer: array[0..MAX_COMPUTERNAME_LENGTH] of Char;
  Size: DWORD;
begin
  Size := SizeOf(Buffer);
  if GetComputerName(Buffer, Size) then
    Result := Buffer
  else
    Result := 'DESCONOCIDO';
end;

function TdmMain.HashPassword(const Password, Salt: string): string;
begin
  // Usar SHA256 para hash de contraseña
  Result := THashSHA2.GetHashString(Salt + Password + Salt, SHA256);
end;

function TdmMain.GenerarSalt: string;
var
  I: Integer;
  Bytes: TBytes;
begin
  SetLength(Bytes, 32);
  for I := 0 to 31 do
    Bytes[I] := Random(256);
  Result := TNetEncoding.Base64.EncodeBytesToString(Bytes);
end;

function TdmMain.Login(const Username, Password: string; out MensajeError: string): Boolean;
var
  Salt, HashCalculado, HashAlmacenado: string;
  IntentosMax, Intentos: Integer;
begin
  Result := False;
  MensajeError := '';

  if not EstaConectado then
  begin
    MensajeError := 'No hay conexión a la base de datos';
    Exit;
  end;

  qryUsuarios.Close;
  qryUsuarios.SQL.Text :=
    'SELECT u.UsuarioID, u.Username, u.PasswordHash, u.Salt, u.Nombre, u.Apellido, ' +
    '       u.Email, u.RolID, u.EsInmutable, u.Activo, u.Bloqueado, u.IntentosLogin, ' +
    '       r.Nombre AS RolNombre, r.EsSuperUsuario ' +
    'FROM Usuarios u ' +
    'INNER JOIN Roles r ON u.RolID = r.RolID ' +
    'WHERE LOWER(u.Username) = LOWER(:Username)';
  qryUsuarios.ParamByName('Username').AsString := Username;
  qryUsuarios.Open;

  if qryUsuarios.IsEmpty then
  begin
    MensajeError := 'Usuario no encontrado';
    RegistrarBitacora('LOGIN_FALLIDO', 'SEGURIDAD', 'Usuarios', 0, '', '', 'DENEGADO', 'Usuario no existe: ' + Username);
    Exit;
  end;

  // Verificar si está activo
  if not qryUsuarios.FieldByName('Activo').AsBoolean then
  begin
    MensajeError := 'Usuario inactivo. Contacte al administrador.';
    RegistrarBitacora('LOGIN_FALLIDO', 'SEGURIDAD', 'Usuarios',
      qryUsuarios.FieldByName('UsuarioID').AsInteger, '', '', 'DENEGADO', 'Usuario inactivo');
    Exit;
  end;

  // Verificar si está bloqueado
  if qryUsuarios.FieldByName('Bloqueado').AsBoolean then
  begin
    MensajeError := 'Usuario bloqueado por múltiples intentos fallidos. Contacte al administrador.';
    Exit;
  end;

  // Verificar contraseña
  Salt := qryUsuarios.FieldByName('Salt').AsString;
  HashCalculado := HashPassword(Password, Salt);
  HashAlmacenado := qryUsuarios.FieldByName('PasswordHash').AsString;

  if HashCalculado <> HashAlmacenado then
  begin
    // Incrementar intentos fallidos
    Intentos := qryUsuarios.FieldByName('IntentosLogin').AsInteger + 1;
    IntentosMax := StrToIntDef(ObtenerConfiguracion('INTENTOS_LOGIN_MAX', '3'), 3);

    qryGeneral.SQL.Text :=
      'UPDATE Usuarios SET IntentosLogin = :Intentos, ' +
      'Bloqueado = CASE WHEN :Intentos >= :Max THEN TRUE ELSE FALSE END, ' +
      'FechaBloqueo = CASE WHEN :Intentos >= :Max THEN CURRENT_TIMESTAMP ELSE NULL END ' +
      'WHERE UsuarioID = :ID';
    qryGeneral.ParamByName('Intentos').AsInteger := Intentos;
    qryGeneral.ParamByName('Max').AsInteger := IntentosMax;
    qryGeneral.ParamByName('ID').AsInteger := qryUsuarios.FieldByName('UsuarioID').AsInteger;
    qryGeneral.ExecSQL;

    if Intentos >= IntentosMax then
      MensajeError := 'Usuario bloqueado por múltiples intentos fallidos.'
    else
      MensajeError := Format('Contraseña incorrecta. Intentos restantes: %d', [IntentosMax - Intentos]);

    RegistrarBitacora('LOGIN_FALLIDO', 'SEGURIDAD', 'Usuarios',
      qryUsuarios.FieldByName('UsuarioID').AsInteger, '', '', 'DENEGADO', 'Contraseña incorrecta');
    Exit;
  end;

  // Login exitoso - Cargar datos del usuario
  FUsuarioActual.UsuarioID := qryUsuarios.FieldByName('UsuarioID').AsInteger;
  FUsuarioActual.Username := qryUsuarios.FieldByName('Username').AsString;
  FUsuarioActual.NombreCompleto := qryUsuarios.FieldByName('Nombre').AsString + ' ' +
                                   qryUsuarios.FieldByName('Apellido').AsString;
  FUsuarioActual.Email := qryUsuarios.FieldByName('Email').AsString;
  FUsuarioActual.RolID := qryUsuarios.FieldByName('RolID').AsInteger;
  FUsuarioActual.RolNombre := qryUsuarios.FieldByName('RolNombre').AsString;
  FUsuarioActual.EsSuperUsuario := qryUsuarios.FieldByName('EsSuperUsuario').AsBoolean;
  FUsuarioActual.IPCliente := GetIPLocal;
  FUsuarioActual.MACCliente := GetMACAddress;
  FUsuarioActual.NombreEquipo := GetNombreEquipo;
  FUsuarioActual.FechaLogin := Now;

  // Resetear intentos y actualizar último acceso
  qryGeneral.SQL.Text :=
    'UPDATE Usuarios SET IntentosLogin = 0, UltimoAcceso = CURRENT_TIMESTAMP WHERE UsuarioID = :ID';
  qryGeneral.ParamByName('ID').AsInteger := FUsuarioActual.UsuarioID;
  qryGeneral.ExecSQL;

  // Registrar login exitoso
  RegistrarBitacora('LOGIN', 'SEGURIDAD', 'Usuarios', FUsuarioActual.UsuarioID, '', '', 'EXITO');

  Result := True;
end;

procedure TdmMain.Logout;
begin
  if FUsuarioActual.UsuarioID > 0 then
  begin
    RegistrarBitacora('LOGOUT', 'SEGURIDAD', 'Usuarios', FUsuarioActual.UsuarioID, '', '', 'EXITO');
    FillChar(FUsuarioActual, SizeOf(FUsuarioActual), 0);
  end;
end;

function TdmMain.CambiarPassword(const PasswordActual, PasswordNuevo: string): Boolean;
var
  SaltActual, HashActual, NuevoSalt, NuevoHash: string;
begin
  Result := False;

  // Verificar contraseña actual
  qryGeneral.SQL.Text := 'SELECT Salt, PasswordHash FROM Usuarios WHERE UsuarioID = :ID';
  qryGeneral.ParamByName('ID').AsInteger := FUsuarioActual.UsuarioID;
  qryGeneral.Open;

  if qryGeneral.IsEmpty then Exit;

  SaltActual := qryGeneral.FieldByName('Salt').AsString;
  HashActual := HashPassword(PasswordActual, SaltActual);

  if HashActual <> qryGeneral.FieldByName('PasswordHash').AsString then
    Exit;

  // Generar nuevo hash
  NuevoSalt := GenerarSalt;
  NuevoHash := HashPassword(PasswordNuevo, NuevoSalt);

  // Actualizar
  qryGeneral.SQL.Text :=
    'UPDATE Usuarios SET PasswordHash = :Hash, Salt = :Salt, FechaModificacion = CURRENT_TIMESTAMP ' +
    'WHERE UsuarioID = :ID';
  qryGeneral.ParamByName('Hash').AsString := NuevoHash;
  qryGeneral.ParamByName('Salt').AsString := NuevoSalt;
  qryGeneral.ParamByName('ID').AsInteger := FUsuarioActual.UsuarioID;
  qryGeneral.ExecSQL;

  RegistrarBitacora('CAMBIO_PASSWORD', 'SEGURIDAD', 'Usuarios', FUsuarioActual.UsuarioID, '', '', 'EXITO');

  Result := True;
end;

function TdmMain.VerificarPermiso(const CodigoPermiso: string): Boolean;
begin
  // Super usuario tiene todos los permisos
  if FUsuarioActual.EsSuperUsuario then
  begin
    Result := True;
    Exit;
  end;

  qryPermisos.SQL.Text :=
    'SELECT 1 FROM RolesPermisos rp ' +
    'INNER JOIN Permisos p ON rp.PermisoID = p.PermisoID ' +
    'WHERE rp.RolID = :RolID AND p.Codigo = :Codigo AND p.Activo = TRUE';
  qryPermisos.ParamByName('RolID').AsInteger := FUsuarioActual.RolID;
  qryPermisos.ParamByName('Codigo').AsString := CodigoPermiso;
  qryPermisos.Open;

  Result := not qryPermisos.IsEmpty;
end;

function TdmMain.RequiereAutorizacionRemota(const CodigoPermiso: string): Boolean;
begin
  qryPermisos.SQL.Text :=
    'SELECT RequiereAutorizacionRemota FROM Permisos WHERE Codigo = :Codigo AND Activo = TRUE';
  qryPermisos.ParamByName('Codigo').AsString := CodigoPermiso;
  qryPermisos.Open;

  if qryPermisos.IsEmpty then
    Result := False
  else
    Result := qryPermisos.FieldByName('RequiereAutorizacionRemota').AsBoolean;
end;

procedure TdmMain.RegistrarBitacora(const Accion, Modulo, Tabla: string;
  RegistroID: Integer; const DatosAnteriores, DatosNuevos: string;
  const Resultado: string; const MensajeError: string);
begin
  try
    qryAuditoria.SQL.Text :=
      'INSERT INTO BitacoraGlobal (UsuarioID, Username, Accion, Modulo, Tabla, RegistroID, ' +
      'DatosAnteriores, DatosNuevos, IPCliente, MACCliente, NombreEquipo, Resultado, MensajeError) ' +
      'VALUES (:UsuarioID, :Username, :Accion, :Modulo, :Tabla, :RegistroID, ' +
      ':DatosAnt::jsonb, :DatosNuev::jsonb, :IP, :MAC, :Equipo, :Resultado, :Error)';

    qryAuditoria.ParamByName('UsuarioID').AsInteger := FUsuarioActual.UsuarioID;
    qryAuditoria.ParamByName('Username').AsString := FUsuarioActual.Username;
    qryAuditoria.ParamByName('Accion').AsString := Accion;
    qryAuditoria.ParamByName('Modulo').AsString := Modulo;
    qryAuditoria.ParamByName('Tabla').AsString := Tabla;
    qryAuditoria.ParamByName('RegistroID').AsInteger := RegistroID;

    if DatosAnteriores <> '' then
      qryAuditoria.ParamByName('DatosAnt').AsString := DatosAnteriores
    else
      qryAuditoria.ParamByName('DatosAnt').Clear;

    if DatosNuevos <> '' then
      qryAuditoria.ParamByName('DatosNuev').AsString := DatosNuevos
    else
      qryAuditoria.ParamByName('DatosNuev').Clear;

    qryAuditoria.ParamByName('IP').AsString := FUsuarioActual.IPCliente;
    qryAuditoria.ParamByName('MAC').AsString := FUsuarioActual.MACCliente;
    qryAuditoria.ParamByName('Equipo').AsString := FUsuarioActual.NombreEquipo;
    qryAuditoria.ParamByName('Resultado').AsString := Resultado;
    qryAuditoria.ParamByName('Error').AsString := MensajeError;

    qryAuditoria.ExecSQL;
  except
    // No lanzar excepción por fallo en auditoría
  end;
end;

function TdmMain.ObtenerConfiguracion(const Clave: string; const ValorDefecto: string): string;
begin
  qryGeneral.SQL.Text := 'SELECT Valor FROM ConfiguracionSistema WHERE Clave = :Clave';
  qryGeneral.ParamByName('Clave').AsString := Clave;
  qryGeneral.Open;

  if qryGeneral.IsEmpty then
    Result := ValorDefecto
  else
    Result := qryGeneral.FieldByName('Valor').AsString;
end;

procedure TdmMain.GuardarConfiguracion(const Clave, Valor: string);
begin
  qryGeneral.SQL.Text :=
    'INSERT INTO ConfiguracionSistema (Clave, Valor, FechaModificacion) ' +
    'VALUES (:Clave, :Valor, CURRENT_TIMESTAMP) ' +
    'ON CONFLICT (Clave) DO UPDATE SET Valor = :Valor, FechaModificacion = CURRENT_TIMESTAMP';
  qryGeneral.ParamByName('Clave').AsString := Clave;
  qryGeneral.ParamByName('Valor').AsString := Valor;
  qryGeneral.ExecSQL;
end;

end.
