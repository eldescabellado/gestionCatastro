unit uFrmLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.Imaging.pngimage;

type
  TfrmLogin = class(TForm)
    pnlMain: TPanel;
    imgLogo: TImage;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    lblUsuario: TLabel;
    edtUsuario: TEdit;
    lblPassword: TLabel;
    edtPassword: TEdit;
    btnLogin: TBitBtn;
    btnCancelar: TBitBtn;
    lblMensaje: TLabel;
    chkRecordarUsuario: TCheckBox;
    lblVersion: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure edtPasswordKeyPress(Sender: TObject; var Key: Char);
    procedure edtUsuarioKeyPress(Sender: TObject; var Key: Char);

  private
    FIntentosLogin: Integer;
    procedure CargarConfiguracion;
    procedure GuardarConfiguracion;
    procedure IntentarLogin;
    procedure MostrarError(const Mensaje: string);
    procedure LimpiarError;

  public
    property IntentosLogin: Integer read FIntentosLogin;
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

uses
  System.IniFiles, uDmMain;

{ TfrmLogin }

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  FIntentosLogin := 0;

  // Configurar apariencia
  lblTitulo.Caption := 'SIGIEP';
  lblSubtitulo.Caption := 'Sistema de Gestión Integral de Catastro';
  lblVersion.Caption := 'Versión 1.0.0';

  lblMensaje.Caption := '';
  lblMensaje.Font.Color := clRed;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  CargarConfiguracion;
  LimpiarError;

  if edtUsuario.Text <> '' then
    edtPassword.SetFocus
  else
    edtUsuario.SetFocus;
end;

procedure TfrmLogin.CargarConfiguracion;
var
  IniFile: TIniFile;
  ConfigPath: string;
begin
  ConfigPath := ExtractFilePath(Application.ExeName) + 'Config\settings.ini';

  if FileExists(ConfigPath) then
  begin
    IniFile := TIniFile.Create(ConfigPath);
    try
      if IniFile.ReadBool('Login', 'RecordarUsuario', False) then
      begin
        edtUsuario.Text := IniFile.ReadString('Login', 'UltimoUsuario', '');
        chkRecordarUsuario.Checked := True;
      end;
    finally
      IniFile.Free;
    end;
  end;
end;

procedure TfrmLogin.GuardarConfiguracion;
var
  IniFile: TIniFile;
  ConfigPath: string;
begin
  ConfigPath := ExtractFilePath(Application.ExeName) + 'Config\';
  ForceDirectories(ConfigPath);

  IniFile := TIniFile.Create(ConfigPath + 'settings.ini');
  try
    IniFile.WriteBool('Login', 'RecordarUsuario', chkRecordarUsuario.Checked);
    if chkRecordarUsuario.Checked then
      IniFile.WriteString('Login', 'UltimoUsuario', edtUsuario.Text)
    else
      IniFile.WriteString('Login', 'UltimoUsuario', '');
  finally
    IniFile.Free;
  end;
end;

procedure TfrmLogin.MostrarError(const Mensaje: string);
begin
  lblMensaje.Caption := Mensaje;
  lblMensaje.Visible := True;
end;

procedure TfrmLogin.LimpiarError;
begin
  lblMensaje.Caption := '';
  lblMensaje.Visible := False;
end;

procedure TfrmLogin.IntentarLogin;
var
  MensajeError: string;
begin
  LimpiarError;

  // Validar campos
  if Trim(edtUsuario.Text) = '' then
  begin
    MostrarError('Ingrese el nombre de usuario');
    edtUsuario.SetFocus;
    Exit;
  end;

  if Trim(edtPassword.Text) = '' then
  begin
    MostrarError('Ingrese la contraseña');
    edtPassword.SetFocus;
    Exit;
  end;

  Screen.Cursor := crHourGlass;
  btnLogin.Enabled := False;
  try
    // Verificar conexión
    if not dmMain.EstaConectado then
    begin
      try
        dmMain.ConectarPostgreSQL;
        dmMain.ConectarSQLiteMemoria;
      except
        on E: Exception do
        begin
          MostrarError('Error de conexión: ' + E.Message);
          Exit;
        end;
      end;
    end;

    // Intentar login
    if dmMain.Login(edtUsuario.Text, edtPassword.Text, MensajeError) then
    begin
      // Login exitoso
      GuardarConfiguracion;
      ModalResult := mrOk;
    end
    else
    begin
      // Login fallido
      Inc(FIntentosLogin);
      MostrarError(MensajeError);
      edtPassword.Clear;
      edtPassword.SetFocus;

      // Verificar intentos máximos
      if FIntentosLogin >= 5 then
      begin
        MostrarError('Demasiados intentos fallidos. La aplicación se cerrará.');
        Sleep(2000);
        Application.Terminate;
      end;
    end;

  finally
    Screen.Cursor := crDefault;
    btnLogin.Enabled := True;
  end;
end;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
begin
  IntentarLogin;
end;

procedure TfrmLogin.btnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmLogin.edtUsuarioKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    edtPassword.SetFocus;
  end;
end;

procedure TfrmLogin.edtPasswordKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    IntentarLogin;
  end;
end;

end.
