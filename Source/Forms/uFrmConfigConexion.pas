unit uFrmConfigConexion;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, System.NetEncoding, System.Hash,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.ComCtrls,
  FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Phys.PG;

type
  TfrmConfigConexion = class(TForm)
    pnlMain: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;

    gbConexion: TGroupBox;
    lblServidor: TLabel;
    edtServidor: TEdit;
    lblPuerto: TLabel;
    edtPuerto: TEdit;
    lblBaseDatos: TLabel;
    edtBaseDatos: TEdit;
    lblUsuario: TLabel;
    edtUsuario: TEdit;
    lblPassword: TLabel;
    edtPassword: TEdit;

    chkGuardarPassword: TCheckBox;
    chkMostrarPassword: TCheckBox;

    pnlBotones: TPanel;
    btnProbar: TBitBtn;
    btnGuardar: TBitBtn;
    btnCancelar: TBitBtn;

    lblEstado: TLabel;
    ProgressBar: TProgressBar;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnProbarClick(Sender: TObject);
    procedure btnGuardarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure chkMostrarPasswordClick(Sender: TObject);
    procedure edtServidorChange(Sender: TObject);

  private
    FConexionExitosa: Boolean;
    FConfigPath: string;
    FClaveEncriptacion: string;

    function Encriptar(const Texto: string): string;
    function Desencriptar(const TextoEncriptado: string): string;
    function ProbarConexion: Boolean;
    procedure CargarConfiguracion;
    procedure GuardarConfiguracion;
    procedure MostrarEstado(const Mensaje: string; EsError: Boolean = False);
    procedure LimpiarEstado;
    procedure ActualizarBotones;

  public
    class function ConfiguracionExiste: Boolean;
    class function ObtenerRutaConfig: string;
  end;

var
  frmConfigConexion: TfrmConfigConexion;

implementation

{$R *.dfm}

uses
  System.IniFiles;

const
  // Clave para encriptación simple (en producción usar algo más robusto)
  CLAVE_BASE = 'S1G13P_C4T4STR0_2025';

{ TfrmConfigConexion }

procedure TfrmConfigConexion.FormCreate(Sender: TObject);
begin
  FConexionExitosa := False;
  FConfigPath := ExtractFilePath(Application.ExeName) + 'Config\';

  // Generar clave de encriptación basada en el nombre del equipo
  FClaveEncriptacion := CLAVE_BASE + GetEnvironmentVariable('COMPUTERNAME');

  // Valores por defecto
  edtServidor.Text := 'localhost';
  edtPuerto.Text := '5432';
  edtBaseDatos.Text := 'sigiep_catastro';
  edtUsuario.Text := 'postgres';
  edtPassword.Text := '';

  chkGuardarPassword.Checked := True;
end;

procedure TfrmConfigConexion.FormShow(Sender: TObject);
begin
  CargarConfiguracion;
  LimpiarEstado;
  ActualizarBotones;

  if edtServidor.Text <> '' then
    edtPassword.SetFocus
  else
    edtServidor.SetFocus;
end;

class function TfrmConfigConexion.ObtenerRutaConfig: string;
begin
  Result := ExtractFilePath(Application.ExeName) + 'Config\database.ini';
end;

class function TfrmConfigConexion.ConfiguracionExiste: Boolean;
var
  IniFile: TIniFile;
  Servidor, BaseDatos: string;
begin
  Result := False;

  if not FileExists(ObtenerRutaConfig) then
    Exit;

  IniFile := TIniFile.Create(ObtenerRutaConfig);
  try
    Servidor := IniFile.ReadString('PostgreSQL', 'Server', '');
    BaseDatos := IniFile.ReadString('PostgreSQL', 'Database', '');
    Result := (Servidor <> '') and (BaseDatos <> '');
  finally
    IniFile.Free;
  end;
end;

function TfrmConfigConexion.Encriptar(const Texto: string): string;
var
  I: Integer;
  Bytes: TBytes;
  ClaveBytes: TBytes;
begin
  if Texto = '' then
  begin
    Result := '';
    Exit;
  end;

  // Convertir a bytes
  Bytes := TEncoding.UTF8.GetBytes(Texto);
  ClaveBytes := TEncoding.UTF8.GetBytes(FClaveEncriptacion);

  // XOR con la clave (encriptación simple pero efectiva para este propósito)
  for I := 0 to High(Bytes) do
    Bytes[I] := Bytes[I] xor ClaveBytes[I mod Length(ClaveBytes)];

  // Convertir a Base64 para almacenar
  Result := TNetEncoding.Base64.EncodeBytesToString(Bytes);
end;

function TfrmConfigConexion.Desencriptar(const TextoEncriptado: string): string;
var
  I: Integer;
  Bytes: TBytes;
  ClaveBytes: TBytes;
begin
  if TextoEncriptado = '' then
  begin
    Result := '';
    Exit;
  end;

  try
    // Decodificar de Base64
    Bytes := TNetEncoding.Base64.DecodeStringToBytes(TextoEncriptado);
    ClaveBytes := TEncoding.UTF8.GetBytes(FClaveEncriptacion);

    // XOR inverso (misma operación)
    for I := 0 to High(Bytes) do
      Bytes[I] := Bytes[I] xor ClaveBytes[I mod Length(ClaveBytes)];

    // Convertir a string
    Result := TEncoding.UTF8.GetString(Bytes);
  except
    Result := '';
  end;
end;

procedure TfrmConfigConexion.CargarConfiguracion;
var
  IniFile: TIniFile;
  PasswordEncriptado: string;
begin
  if not FileExists(FConfigPath + 'database.ini') then
    Exit;

  IniFile := TIniFile.Create(FConfigPath + 'database.ini');
  try
    edtServidor.Text := IniFile.ReadString('PostgreSQL', 'Server', 'localhost');
    edtPuerto.Text := IniFile.ReadString('PostgreSQL', 'Port', '5432');
    edtBaseDatos.Text := IniFile.ReadString('PostgreSQL', 'Database', 'sigiep_catastro');
    edtUsuario.Text := IniFile.ReadString('PostgreSQL', 'Username', 'postgres');

    // Leer password encriptado
    PasswordEncriptado := IniFile.ReadString('PostgreSQL', 'Password', '');
    if PasswordEncriptado <> '' then
    begin
      // Verificar si está encriptado (empieza con marca especial)
      if Copy(PasswordEncriptado, 1, 4) = 'ENC:' then
        edtPassword.Text := Desencriptar(Copy(PasswordEncriptado, 5, MaxInt))
      else
        edtPassword.Text := PasswordEncriptado; // Password en texto plano (legacy)
    end;

    chkGuardarPassword.Checked := IniFile.ReadBool('PostgreSQL', 'SavePassword', True);
  finally
    IniFile.Free;
  end;
end;

procedure TfrmConfigConexion.GuardarConfiguracion;
var
  IniFile: TIniFile;
  PasswordGuardar: string;
begin
  // Crear directorio si no existe
  ForceDirectories(FConfigPath);

  IniFile := TIniFile.Create(FConfigPath + 'database.ini');
  try
    IniFile.WriteString('PostgreSQL', 'Server', edtServidor.Text);
    IniFile.WriteString('PostgreSQL', 'Port', edtPuerto.Text);
    IniFile.WriteString('PostgreSQL', 'Database', edtBaseDatos.Text);
    IniFile.WriteString('PostgreSQL', 'Username', edtUsuario.Text);

    // Guardar password encriptado si está marcada la opción
    if chkGuardarPassword.Checked and (edtPassword.Text <> '') then
    begin
      PasswordGuardar := 'ENC:' + Encriptar(edtPassword.Text);
      IniFile.WriteString('PostgreSQL', 'Password', PasswordGuardar);
    end
    else
      IniFile.WriteString('PostgreSQL', 'Password', '');

    IniFile.WriteBool('PostgreSQL', 'SavePassword', chkGuardarPassword.Checked);

    // Información adicional
    IniFile.WriteString('Info', 'LastModified', DateTimeToStr(Now));
    IniFile.WriteString('Info', 'ModifiedBy', GetEnvironmentVariable('USERNAME'));
  finally
    IniFile.Free;
  end;
end;

function TfrmConfigConexion.ProbarConexion: Boolean;
var
  Connection: TFDConnection;
begin
  Result := False;

  Connection := TFDConnection.Create(nil);
  try
    Connection.DriverName := 'PG';
    Connection.Params.Clear;
    Connection.Params.Values['Server'] := edtServidor.Text;
    Connection.Params.Values['Port'] := edtPuerto.Text;
    Connection.Params.Values['Database'] := edtBaseDatos.Text;
    Connection.Params.Values['User_Name'] := edtUsuario.Text;
    Connection.Params.Values['Password'] := edtPassword.Text;
    Connection.Params.Values['CharacterSet'] := 'UTF8';
    Connection.LoginPrompt := False;

    try
      Connection.Connected := True;
      Result := Connection.Connected;
      Connection.Connected := False;
    except
      on E: Exception do
      begin
        MostrarEstado('Error: ' + E.Message, True);
        Result := False;
      end;
    end;
  finally
    Connection.Free;
  end;
end;

procedure TfrmConfigConexion.MostrarEstado(const Mensaje: string; EsError: Boolean);
begin
  lblEstado.Caption := Mensaje;
  lblEstado.Visible := True;

  if EsError then
    lblEstado.Font.Color := clRed
  else
    lblEstado.Font.Color := clGreen;
end;

procedure TfrmConfigConexion.LimpiarEstado;
begin
  lblEstado.Caption := '';
  lblEstado.Visible := False;
end;

procedure TfrmConfigConexion.ActualizarBotones;
var
  DatosCompletos: Boolean;
begin
  DatosCompletos := (Trim(edtServidor.Text) <> '') and
                    (Trim(edtPuerto.Text) <> '') and
                    (Trim(edtBaseDatos.Text) <> '') and
                    (Trim(edtUsuario.Text) <> '');

  btnProbar.Enabled := DatosCompletos;
  btnGuardar.Enabled := DatosCompletos and FConexionExitosa;
end;

procedure TfrmConfigConexion.edtServidorChange(Sender: TObject);
begin
  FConexionExitosa := False;
  LimpiarEstado;
  ActualizarBotones;
end;

procedure TfrmConfigConexion.chkMostrarPasswordClick(Sender: TObject);
begin
  if chkMostrarPassword.Checked then
    edtPassword.PasswordChar := #0
  else
    edtPassword.PasswordChar := '*';
end;

procedure TfrmConfigConexion.btnProbarClick(Sender: TObject);
begin
  LimpiarEstado;
  Screen.Cursor := crHourGlass;
  btnProbar.Enabled := False;
  ProgressBar.Visible := True;
  ProgressBar.Style := pbstMarquee;
  Application.ProcessMessages;

  try
    MostrarEstado('Probando conexión...', False);
    Application.ProcessMessages;

    FConexionExitosa := ProbarConexion;

    if FConexionExitosa then
      MostrarEstado('Conexión exitosa', False)
    else if lblEstado.Caption = 'Probando conexión...' then
      MostrarEstado('No se pudo conectar', True);

  finally
    Screen.Cursor := crDefault;
    ProgressBar.Visible := False;
    ActualizarBotones;
  end;
end;

procedure TfrmConfigConexion.btnGuardarClick(Sender: TObject);
begin
  if not FConexionExitosa then
  begin
    if MessageDlg('No se ha probado la conexión. ¿Desea probarla ahora?',
                  mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      btnProbarClick(nil);
      if not FConexionExitosa then
        Exit;
    end
    else
      Exit;
  end;

  try
    GuardarConfiguracion;
    MostrarEstado('Configuración guardada correctamente', False);
    Sleep(500);
    ModalResult := mrOk;
  except
    on E: Exception do
      MostrarEstado('Error al guardar: ' + E.Message, True);
  end;
end;

procedure TfrmConfigConexion.btnCancelarClick(Sender: TObject);
begin
  if (edtServidor.Text <> '') or (edtPassword.Text <> '') then
  begin
    if MessageDlg('¿Está seguro que desea cancelar? Los cambios no se guardarán.',
                  mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      Exit;
  end;

  ModalResult := mrCancel;
end;

end.
