program SIGIEP_Catastro;

uses
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,
  System.UITypes,
  uDmMain in 'DataModules\uDmMain.pas' {dmMain: TDataModule},
  uFrmLogin in 'Forms\uFrmLogin.pas' {frmLogin},
  uFrmDashboard in 'Forms\uFrmDashboard.pas' {frmDashboard},
  uFrmFicha in 'Forms\uFrmFicha.pas' {frmFicha},
  uFrmConfigConexion in 'Forms\uFrmConfigConexion.pas' {frmConfigConexion},
  uFrmGeolocalizacion in 'Forms\uFrmGeolocalizacion.pas' {frmGeolocalizacion},
  uAuthManager in 'Units\uAuthManager.pas',
  uCalculoCatastral in 'Units\uCalculoCatastral.pas',
  uNotificaciones in 'Units\uNotificaciones.pas';

{$R *.res}

var
  ConfigurarConexion: Boolean;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'SIGIEP - Sistema de Gestión Integral de Catastro';

  // Crear el DataModule principal
  Application.CreateForm(TdmMain, dmMain);

  // Verificar si existe configuración de conexión
  ConfigurarConexion := not TfrmConfigConexion.ConfiguracionExiste;

  // Si no existe configuración, mostrar formulario de configuración
  if ConfigurarConexion then
  begin
    frmConfigConexion := TfrmConfigConexion.Create(Application);
    try
      if frmConfigConexion.ShowModal <> mrOk then
      begin
        // Usuario canceló la configuración
        ShowMessage('Debe configurar la conexión a la base de datos para continuar.');
        Exit;
      end;
    finally
      frmConfigConexion.Free;
    end;
  end;

  // Intentar conectar a la base de datos
  try
    if not dmMain.ConectarPostgreSQL then
    begin
      // Si falla la conexión, ofrecer reconfigurar
      if MessageDlg('No se pudo conectar a la base de datos PostgreSQL.' + #13#10 +
                    '¿Desea configurar los parámetros de conexión?',
                    mtError, [mbYes, mbNo], 0) = mrYes then
      begin
        frmConfigConexion := TfrmConfigConexion.Create(Application);
        try
          if frmConfigConexion.ShowModal = mrOk then
          begin
            // Reintentar conexión
            if not dmMain.ConectarPostgreSQL then
            begin
              ShowMessage('No se pudo conectar con la nueva configuración.');
              Exit;
            end;
          end
          else
            Exit;
        finally
          frmConfigConexion.Free;
        end;
      end
      else
        Exit;
    end;

    if not dmMain.ConectarSQLiteMemoria then
    begin
      ShowMessage('No se pudo inicializar SQLite en memoria.');
      Exit;
    end;
  except
    on E: Exception do
    begin
      if MessageDlg('Error de conexión: ' + E.Message + #13#10#13#10 +
                    '¿Desea configurar los parámetros de conexión?',
                    mtError, [mbYes, mbNo], 0) = mrYes then
      begin
        frmConfigConexion := TfrmConfigConexion.Create(Application);
        try
          frmConfigConexion.ShowModal;
        finally
          frmConfigConexion.Free;
        end;
      end;
      Exit;
    end;
  end;

  // Mostrar formulario de Login
  frmLogin := TfrmLogin.Create(Application);
  try
    if frmLogin.ShowModal = mrOk then
    begin
      // Login exitoso, crear y mostrar Dashboard
      Application.CreateForm(TfrmDashboard, frmDashboard);
      Application.Run;
    end;
  finally
    frmLogin.Free;
  end;
end.
