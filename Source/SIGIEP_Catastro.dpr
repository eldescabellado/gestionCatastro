program SIGIEP_Catastro;

uses
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,
  uDmMain in 'DataModules\uDmMain.pas' {dmMain: TDataModule},
  uFrmLogin in 'Forms\uFrmLogin.pas' {frmLogin},
  uFrmDashboard in 'Forms\uFrmDashboard.pas' {frmDashboard},
  uFrmFicha in 'Forms\uFrmFicha.pas' {frmFicha},
  uAuthManager in 'Units\uAuthManager.pas',
  uCalculoCatastral in 'Units\uCalculoCatastral.pas',
  uNotificaciones in 'Units\uNotificaciones.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'SIGIEP - Sistema de Gestión Integral de Catastro';

  // Crear el DataModule principal
  Application.CreateForm(TdmMain, dmMain);

  // Mostrar formulario de Login
  frmLogin := TfrmLogin.Create(Application);
  try
    // Intentar conectar a la base de datos
    try
      if not dmMain.ConectarPostgreSQL then
      begin
        ShowMessage('No se pudo conectar a la base de datos PostgreSQL.');
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
        ShowMessage('Error de conexión: ' + E.Message + #13#10 +
                    'Verifique la configuración en Config\database.ini');
        Exit;
      end;
    end;

    // Mostrar login
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
