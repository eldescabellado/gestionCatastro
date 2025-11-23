unit uFrmDashboard;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.Menus, Vcl.Buttons,
  VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart, VCLTee.DBChart,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  TfrmDashboard = class(TForm)
    // Panel Superior - Información del Usuario
    pnlHeader: TPanel;
    lblUsuario: TLabel;
    lblFechaHora: TLabel;
    lblRol: TLabel;
    btnLogout: TBitBtn;

    // Panel Lateral - Menú
    pnlMenu: TPanel;
    btnContribuyentes: TBitBtn;
    btnSolicitudes: TBitBtn;
    btnFichas: TBitBtn;
    btnVariables: TBitBtn;
    btnReportes: TBitBtn;
    btnUsuarios: TBitBtn;
    btnConfiguracion: TBitBtn;

    // Panel Principal - Dashboard
    pnlMain: TPanel;

    // Contadores
    pnlContadores: TPanel;
    pnlContSolicitudes: TPanel;
    lblContSolicitudes: TLabel;
    lblTituloSolicitudes: TLabel;
    pnlContFichas: TPanel;
    lblContFichas: TLabel;
    lblTituloFichas: TLabel;
    pnlContContribuyentes: TPanel;
    lblContContribuyentes: TLabel;
    lblTituloContribuyentes: TLabel;
    pnlContRecaudacion: TPanel;
    lblContRecaudacion: TLabel;
    lblTituloRecaudacion: TLabel;

    // Gráfico de Solicitudes por Estado
    pnlGraficoSolicitudes: TPanel;
    chartSolicitudes: TChart;
    serieSolicitudes: TPieSeries;

    // Gráfico de Recaudación
    pnlGraficoRecaudacion: TPanel;
    chartRecaudacion: TChart;
    serieRecaudacion: TBarSeries;

    // Grid de Actividad Reciente
    pnlActividad: TPanel;
    lblTituloActividad: TLabel;
    gridActividad: TDBGrid;

    // Grid de Solicitudes Pendientes
    pnlSolicitudesPendientes: TPanel;
    lblTituloSolPendientes: TLabel;
    gridSolicitudesPend: TDBGrid;

    // Timer para actualización
    timerActualizacion: TTimer;

    // Barra de estado
    StatusBar: TStatusBar;

    // DataSources
    dsBitacora: TDataSource;
    dsSolicitudesPend: TDataSource;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnLogoutClick(Sender: TObject);
    procedure timerActualizacionTimer(Sender: TObject);
    procedure btnContribuyentesClick(Sender: TObject);
    procedure btnSolicitudesClick(Sender: TObject);
    procedure btnFichasClick(Sender: TObject);
    procedure btnVariablesClick(Sender: TObject);
    procedure btnReportesClick(Sender: TObject);
    procedure btnUsuariosClick(Sender: TObject);
    procedure btnConfiguracionClick(Sender: TObject);

  private
    FqryContadores: TFDQuery;
    FqryBitacora: TFDQuery;
    FqrySolicitudes: TFDQuery;
    FqryGraficos: TFDQuery;

    procedure InicializarComponentes;
    procedure CargarDatosUsuario;
    procedure CargarContadores;
    procedure CargarGraficoSolicitudes;
    procedure CargarGraficoRecaudacion;
    procedure CargarActividadReciente;
    procedure CargarSolicitudesPendientes;
    procedure ActualizarDashboard;
    procedure VerificarPermisos;
    procedure ConfigurarGrids;

  public
    procedure RefrescarDatos;
  end;

var
  frmDashboard: TfrmDashboard;

implementation

{$R *.dfm}

uses
  uDmMain, uFrmFicha, uFrmContribuyentes;

{ TfrmDashboard }

procedure TfrmDashboard.FormCreate(Sender: TObject);
begin
  // Crear queries internos
  FqryContadores := TFDQuery.Create(Self);
  FqryContadores.Connection := dmMain.ConnectionPG;

  FqryBitacora := TFDQuery.Create(Self);
  FqryBitacora.Connection := dmMain.ConnectionPG;

  FqrySolicitudes := TFDQuery.Create(Self);
  FqrySolicitudes.Connection := dmMain.ConnectionPG;

  FqryGraficos := TFDQuery.Create(Self);
  FqryGraficos.Connection := dmMain.ConnectionPG;

  // Asignar DataSources
  dsBitacora.DataSet := FqryBitacora;
  dsSolicitudesPend.DataSet := FqrySolicitudes;

  InicializarComponentes;
end;

procedure TfrmDashboard.FormShow(Sender: TObject);
begin
  CargarDatosUsuario;
  VerificarPermisos;
  ConfigurarGrids;
  ActualizarDashboard;
  timerActualizacion.Enabled := True;
end;

procedure TfrmDashboard.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  timerActualizacion.Enabled := False;
end;

procedure TfrmDashboard.InicializarComponentes;
begin
  // Configurar formulario
  Caption := 'SIGIEP - Sistema de Gestión Integral de Catastro';
  WindowState := wsMaximized;

  // Configurar timer (actualizar cada 30 segundos)
  timerActualizacion.Interval := 30000;
  timerActualizacion.Enabled := False;

  // Configurar gráficos
  chartSolicitudes.Title.Text.Text := 'Solicitudes por Estado';
  chartSolicitudes.Legend.Visible := True;

  chartRecaudacion.Title.Text.Text := 'Recaudación Estimada por Mes';
  chartRecaudacion.Legend.Visible := False;
end;

procedure TfrmDashboard.CargarDatosUsuario;
begin
  lblUsuario.Caption := 'Usuario: ' + dmMain.UsuarioActual.NombreCompleto;
  lblRol.Caption := 'Rol: ' + dmMain.UsuarioActual.RolNombre;
  lblFechaHora.Caption := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);

  StatusBar.Panels[0].Text := 'Usuario: ' + dmMain.UsuarioActual.Username;
  StatusBar.Panels[1].Text := 'IP: ' + dmMain.UsuarioActual.IPCliente;
  StatusBar.Panels[2].Text := FormatDateTime('dd/mm/yyyy', Date);
end;

procedure TfrmDashboard.VerificarPermisos;
begin
  // Verificar permisos y habilitar/deshabilitar botones
  btnContribuyentes.Enabled := dmMain.VerificarPermiso('CONTRIB_VER');
  btnSolicitudes.Enabled := dmMain.VerificarPermiso('SOLIC_VER');
  btnFichas.Enabled := dmMain.VerificarPermiso('FICHA_VER');
  btnVariables.Enabled := dmMain.VerificarPermiso('VARIABLES_VER');
  btnReportes.Enabled := dmMain.VerificarPermiso('REPORTES_VER');
  btnUsuarios.Enabled := dmMain.VerificarPermiso('USUARIOS_VER');
  btnConfiguracion.Enabled := dmMain.UsuarioActual.EsSuperUsuario;
end;

procedure TfrmDashboard.ConfigurarGrids;
begin
  // Configurar grid de actividad
  gridActividad.Columns.Clear;
  with gridActividad.Columns.Add do
  begin
    FieldName := 'FechaHora';
    Title.Caption := 'Fecha/Hora';
    Width := 130;
  end;
  with gridActividad.Columns.Add do
  begin
    FieldName := 'Username';
    Title.Caption := 'Usuario';
    Width := 100;
  end;
  with gridActividad.Columns.Add do
  begin
    FieldName := 'Accion';
    Title.Caption := 'Acción';
    Width := 120;
  end;
  with gridActividad.Columns.Add do
  begin
    FieldName := 'Modulo';
    Title.Caption := 'Módulo';
    Width := 100;
  end;
  with gridActividad.Columns.Add do
  begin
    FieldName := 'Resultado';
    Title.Caption := 'Resultado';
    Width := 80;
  end;

  // Configurar grid de solicitudes pendientes
  gridSolicitudesPend.Columns.Clear;
  with gridSolicitudesPend.Columns.Add do
  begin
    FieldName := 'NumeroExpediente';
    Title.Caption := 'Expediente';
    Width := 100;
  end;
  with gridSolicitudesPend.Columns.Add do
  begin
    FieldName := 'TipoSolicitud';
    Title.Caption := 'Tipo';
    Width := 120;
  end;
  with gridSolicitudesPend.Columns.Add do
  begin
    FieldName := 'Contribuyente';
    Title.Caption := 'Contribuyente';
    Width := 150;
  end;
  with gridSolicitudesPend.Columns.Add do
  begin
    FieldName := 'Estado';
    Title.Caption := 'Estado';
    Width := 100;
  end;
  with gridSolicitudesPend.Columns.Add do
  begin
    FieldName := 'FechaSolicitud';
    Title.Caption := 'Fecha';
    Width := 90;
  end;
  with gridSolicitudesPend.Columns.Add do
  begin
    FieldName := 'Prioridad';
    Title.Caption := 'Prior.';
    Width := 50;
  end;
end;

procedure TfrmDashboard.CargarContadores;
begin
  // Contar solicitudes pendientes
  FqryContadores.SQL.Text :=
    'SELECT COUNT(*) AS Total FROM Solicitudes ' +
    'WHERE Estado NOT IN (''APROBADO'', ''RECHAZADO'', ''ANULADO'')';
  FqryContadores.Open;
  lblContSolicitudes.Caption := FqryContadores.FieldByName('Total').AsString;
  FqryContadores.Close;

  // Contar fichas activas
  FqryContadores.SQL.Text :=
    'SELECT COUNT(*) AS Total FROM FichaCatastral WHERE EstadoFicha = ''ACTIVA''';
  FqryContadores.Open;
  lblContFichas.Caption := FqryContadores.FieldByName('Total').AsString;
  FqryContadores.Close;

  // Contar contribuyentes
  FqryContadores.SQL.Text :=
    'SELECT COUNT(*) AS Total FROM Contribuyentes WHERE Activo = TRUE';
  FqryContadores.Open;
  lblContContribuyentes.Caption := FqryContadores.FieldByName('Total').AsString;
  FqryContadores.Close;

  // Calcular recaudación estimada
  FqryContadores.SQL.Text :=
    'SELECT COALESCE(SUM(MontoImpuestoAnual), 0) AS Total FROM FichaCatastral ' +
    'WHERE EstadoFicha = ''ACTIVA''';
  FqryContadores.Open;
  lblContRecaudacion.Caption := FormatFloat('#,##0.00', FqryContadores.FieldByName('Total').AsFloat);
  FqryContadores.Close;
end;

procedure TfrmDashboard.CargarGraficoSolicitudes;
begin
  serieSolicitudes.Clear;

  FqryGraficos.SQL.Text :=
    'SELECT Estado, COUNT(*) AS Cantidad ' +
    'FROM Solicitudes ' +
    'GROUP BY Estado ' +
    'ORDER BY Cantidad DESC';
  FqryGraficos.Open;

  while not FqryGraficos.Eof do
  begin
    serieSolicitudes.Add(
      FqryGraficos.FieldByName('Cantidad').AsFloat,
      FqryGraficos.FieldByName('Estado').AsString,
      clTeeColor
    );
    FqryGraficos.Next;
  end;

  FqryGraficos.Close;
end;

procedure TfrmDashboard.CargarGraficoRecaudacion;
begin
  serieRecaudacion.Clear;

  FqryGraficos.SQL.Text :=
    'SELECT ' +
    '  TO_CHAR(FechaCreacion, ''Mon'') AS Mes, ' +
    '  EXTRACT(MONTH FROM FechaCreacion) AS NumMes, ' +
    '  SUM(MontoImpuestoAnual) AS Total ' +
    'FROM FichaCatastral ' +
    'WHERE EXTRACT(YEAR FROM FechaCreacion) = EXTRACT(YEAR FROM CURRENT_DATE) ' +
    'GROUP BY TO_CHAR(FechaCreacion, ''Mon''), EXTRACT(MONTH FROM FechaCreacion) ' +
    'ORDER BY NumMes';
  FqryGraficos.Open;

  while not FqryGraficos.Eof do
  begin
    serieRecaudacion.Add(
      FqryGraficos.FieldByName('Total').AsFloat,
      FqryGraficos.FieldByName('Mes').AsString,
      clTeeColor
    );
    FqryGraficos.Next;
  end;

  FqryGraficos.Close;
end;

procedure TfrmDashboard.CargarActividadReciente;
begin
  FqryBitacora.Close;
  FqryBitacora.SQL.Text :=
    'SELECT FechaHora, Username, Accion, Modulo, Tabla, Resultado ' +
    'FROM BitacoraGlobal ' +
    'ORDER BY FechaHora DESC ' +
    'LIMIT 50';
  FqryBitacora.Open;
end;

procedure TfrmDashboard.CargarSolicitudesPendientes;
begin
  FqrySolicitudes.Close;
  FqrySolicitudes.SQL.Text :=
    'SELECT ' +
    '  s.NumeroExpediente, ' +
    '  ts.Nombre AS TipoSolicitud, ' +
    '  COALESCE(c.RazonSocial, c.Nombre || '' '' || c.Apellido) AS Contribuyente, ' +
    '  s.Estado, ' +
    '  s.FechaSolicitud::date, ' +
    '  s.Prioridad ' +
    'FROM Solicitudes s ' +
    'INNER JOIN TiposSolicitud ts ON s.TipoSolicitudID = ts.TipoSolicitudID ' +
    'INNER JOIN Contribuyentes c ON s.ContribuyenteID = c.ContribuyenteID ' +
    'WHERE s.Estado NOT IN (''APROBADO'', ''RECHAZADO'', ''ANULADO'') ' +
    'ORDER BY s.Prioridad ASC, s.FechaSolicitud ASC ' +
    'LIMIT 20';
  FqrySolicitudes.Open;
end;

procedure TfrmDashboard.ActualizarDashboard;
begin
  Screen.Cursor := crHourGlass;
  try
    lblFechaHora.Caption := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);
    CargarContadores;
    CargarGraficoSolicitudes;
    CargarGraficoRecaudacion;
    CargarActividadReciente;
    CargarSolicitudesPendientes;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmDashboard.RefrescarDatos;
begin
  ActualizarDashboard;
end;

procedure TfrmDashboard.timerActualizacionTimer(Sender: TObject);
begin
  ActualizarDashboard;
end;

procedure TfrmDashboard.btnLogoutClick(Sender: TObject);
begin
  if MessageDlg('¿Está seguro que desea cerrar sesión?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    timerActualizacion.Enabled := False;
    dmMain.Logout;
    Close;
  end;
end;

procedure TfrmDashboard.btnContribuyentesClick(Sender: TObject);
var
  Frm: TfrmContribuyentes;
begin
  // Abrir formulario de Contribuyentes
  Frm := TfrmContribuyentes.Create(Application);
  try
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
  ActualizarDashboard;
end;

procedure TfrmDashboard.btnSolicitudesClick(Sender: TObject);
begin
  // Abrir formulario de Solicitudes
  ShowMessage('Módulo de Solicitudes - Por implementar');
end;

procedure TfrmDashboard.btnFichasClick(Sender: TObject);
var
  Frm: TfrmFicha;
begin
  // Abrir formulario de Fichas Catastrales
  Frm := TfrmFicha.Create(Application);
  try
    Frm.NuevaFicha(0);
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
  ActualizarDashboard;
end;

procedure TfrmDashboard.btnVariablesClick(Sender: TObject);
begin
  // Abrir formulario de Variables de Cálculo
  ShowMessage('Módulo de Variables - Por implementar');
end;

procedure TfrmDashboard.btnReportesClick(Sender: TObject);
begin
  // Abrir formulario de Reportes
  ShowMessage('Módulo de Reportes - Por implementar');
end;

procedure TfrmDashboard.btnUsuariosClick(Sender: TObject);
begin
  // Abrir formulario de Usuarios
  ShowMessage('Módulo de Usuarios - Por implementar');
end;

procedure TfrmDashboard.btnConfiguracionClick(Sender: TObject);
begin
  // Abrir formulario de Configuración
  ShowMessage('Módulo de Configuración - Por implementar');
end;

end.
