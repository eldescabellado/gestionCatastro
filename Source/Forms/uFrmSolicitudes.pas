unit uFrmSolicitudes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, Vcl.Mask,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  TModoSolicitud = (msListado, msNueva, msEditar, msConsultar);

  TfrmSolicitudes = class(TForm)
    // Panel Superior - Búsqueda y Filtros
    pnlBusqueda: TPanel;
    lblBuscar: TLabel;
    edtBuscar: TEdit;
    btnBuscar: TBitBtn;
    btnNueva: TBitBtn;
    lblFiltroEstado: TLabel;
    cmbFiltroEstado: TComboBox;

    // Panel Principal
    pnlPrincipal: TPanel;

    // Panel Listado
    pnlListado: TPanel;
    gridSolicitudes: TDBGrid;
    dsSolicitudes: TDataSource;

    // Panel Detalle
    pnlDetalle: TPanel;
    pcDetalle: TPageControl;

    // Tab: Datos Generales
    tabGeneral: TTabSheet;
    gbSolicitud: TGroupBox;
    lblNumExpediente: TLabel;
    edtNumExpediente: TEdit;
    lblTipoSolicitud: TLabel;
    cmbTipoSolicitud: TComboBox;
    lblFechaSolicitud: TLabel;
    edtFechaSolicitud: TEdit;
    lblEstado: TLabel;
    edtEstado: TEdit;
    lblPrioridad: TLabel;
    cmbPrioridad: TComboBox;

    gbContribuyente: TGroupBox;
    lblContribuyente: TLabel;
    edtContribuyente: TEdit;
    btnSeleccionarContribuyente: TBitBtn;
    btnNuevoContribuyente: TBitBtn;
    lblRIF: TLabel;
    edtRIF: TEdit;
    lblCedula: TLabel;
    edtCedula: TEdit;
    lblTelefono: TLabel;
    edtTelefono: TEdit;

    gbObservaciones: TGroupBox;
    memObservaciones: TMemo;

    // Tab: Workflow
    tabWorkflow: TTabSheet;
    gbAsignaciones: TGroupBox;
    lblReceptor: TLabel;
    cmbReceptor: TComboBox;
    lblRevisor: TLabel;
    cmbRevisor: TComboBox;
    lblInspector: TLabel;
    cmbInspector: TComboBox;
    lblAprobador: TLabel;
    cmbAprobador: TComboBox;

    gbFechas: TGroupBox;
    lblFechaRecepcion: TLabel;
    edtFechaRecepcion: TEdit;
    lblFechaAsignacion: TLabel;
    edtFechaAsignacion: TEdit;
    lblFechaInspeccion: TLabel;
    edtFechaInspeccion: TEdit;
    lblFechaResolucion: TLabel;
    edtFechaResolucion: TEdit;

    gbAcciones: TGroupBox;
    btnRecibir: TBitBtn;
    btnAsignar: TBitBtn;
    btnInspeccionar: TBitBtn;
    btnAprobar: TBitBtn;
    btnRechazar: TBitBtn;

    // Tab: Ficha Catastral
    tabFicha: TTabSheet;
    gbFicha: TGroupBox;
    lblFichaAsociada: TLabel;
    edtFichaAsociada: TEdit;
    btnCrearFicha: TBitBtn;
    btnVerFicha: TBitBtn;
    btnImprimirFicha: TBitBtn;

    // Tab: Historial
    tabHistorial: TTabSheet;
    gridHistorial: TDBGrid;
    dsHistorial: TDataSource;

    // Panel Botones Detalle
    pnlBotonesDetalle: TPanel;
    btnGuardar: TBitBtn;
    btnCancelar: TBitBtn;
    btnEditar: TBitBtn;
    btnAnular: TBitBtn;

    // Panel Inferior
    pnlBotonesListado: TPanel;
    btnCerrar: TBitBtn;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnNuevaClick(Sender: TObject);
    procedure btnGuardarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnAnularClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure gridSolicitudesDblClick(Sender: TObject);
    procedure btnSeleccionarContribuyenteClick(Sender: TObject);
    procedure btnNuevoContribuyenteClick(Sender: TObject);
    procedure btnRecibirClick(Sender: TObject);
    procedure btnAsignarClick(Sender: TObject);
    procedure btnInspeccionarClick(Sender: TObject);
    procedure btnAprobarClick(Sender: TObject);
    procedure btnRechazarClick(Sender: TObject);
    procedure btnCrearFichaClick(Sender: TObject);
    procedure btnVerFichaClick(Sender: TObject);
    procedure btnImprimirFichaClick(Sender: TObject);
    procedure edtBuscarKeyPress(Sender: TObject; var Key: Char);
    procedure cmbFiltroEstadoChange(Sender: TObject);

  private
    FModo: TModoSolicitud;
    FSolicitudID: Integer;
    FContribuyenteID: Integer;
    FFichaID: Integer;
    FqrySolicitudes: TFDQuery;
    FqryDetalle: TFDQuery;
    FqryHistorial: TFDQuery;
    FqryAux: TFDQuery;

    procedure CargarListado;
    procedure CargarSolicitud(ID: Integer);
    procedure CargarHistorial;
    procedure CargarTiposSolicitud;
    procedure CargarUsuarios;
    procedure LimpiarFormulario;
    procedure MostrarDetalle(Mostrar: Boolean);
    procedure HabilitarEdicion(Habilitar: Boolean);
    procedure ActualizarBotonesWorkflow;
    function ValidarDatos: Boolean;
    function GuardarSolicitud: Boolean;
    procedure ConfigurarGrid;
    function CambiarEstado(NuevoEstado: string; Observacion: string = ''): Boolean;
    function PuedeAutorizar: Boolean;

  public
    procedure NuevaSolicitudParaContribuyente(ContribuyenteID: Integer);
  end;

var
  frmSolicitudes: TfrmSolicitudes;

implementation

{$R *.dfm}

uses
  uDmMain, uFrmContribuyentes, uFrmFicha;

{ TfrmSolicitudes }

procedure TfrmSolicitudes.FormCreate(Sender: TObject);
begin
  FqrySolicitudes := TFDQuery.Create(Self);
  FqrySolicitudes.Connection := dmMain.ConnectionPG;

  FqryDetalle := TFDQuery.Create(Self);
  FqryDetalle.Connection := dmMain.ConnectionPG;

  FqryHistorial := TFDQuery.Create(Self);
  FqryHistorial.Connection := dmMain.ConnectionPG;

  FqryAux := TFDQuery.Create(Self);
  FqryAux.Connection := dmMain.ConnectionPG;

  dsSolicitudes.DataSet := FqrySolicitudes;
  dsHistorial.DataSet := FqryHistorial;

  FSolicitudID := 0;
  FContribuyenteID := 0;
  FFichaID := 0;
  FModo := msListado;

  // Configurar filtro de estados
  cmbFiltroEstado.Items.Clear;
  cmbFiltroEstado.Items.Add('Todos');
  cmbFiltroEstado.Items.Add('PENDIENTE');
  cmbFiltroEstado.Items.Add('EN_REVISION');
  cmbFiltroEstado.Items.Add('INSPECCION');
  cmbFiltroEstado.Items.Add('PENDIENTE_APROBACION');
  cmbFiltroEstado.Items.Add('APROBADO');
  cmbFiltroEstado.Items.Add('RECHAZADO');
  cmbFiltroEstado.ItemIndex := 0;

  // Configurar prioridades
  cmbPrioridad.Items.Clear;
  cmbPrioridad.Items.Add('1 - Urgente');
  cmbPrioridad.Items.Add('2 - Alta');
  cmbPrioridad.Items.Add('3 - Normal');
  cmbPrioridad.Items.Add('4 - Baja');
  cmbPrioridad.Items.Add('5 - Mínima');
  cmbPrioridad.ItemIndex := 2;

  CargarTiposSolicitud;
  CargarUsuarios;
  ConfigurarGrid;
end;

procedure TfrmSolicitudes.FormDestroy(Sender: TObject);
begin
  FqrySolicitudes.Free;
  FqryDetalle.Free;
  FqryHistorial.Free;
  FqryAux.Free;
end;

procedure TfrmSolicitudes.FormShow(Sender: TObject);
begin
  MostrarDetalle(False);
  CargarListado;
  edtBuscar.SetFocus;
end;

procedure TfrmSolicitudes.ConfigurarGrid;
begin
  gridSolicitudes.Columns.Clear;

  with gridSolicitudes.Columns.Add do
  begin
    FieldName := 'NumeroExpediente';
    Title.Caption := 'Expediente';
    Width := 100;
  end;
  with gridSolicitudes.Columns.Add do
  begin
    FieldName := 'TipoSolicitud';
    Title.Caption := 'Tipo';
    Width := 120;
  end;
  with gridSolicitudes.Columns.Add do
  begin
    FieldName := 'Contribuyente';
    Title.Caption := 'Contribuyente';
    Width := 200;
  end;
  with gridSolicitudes.Columns.Add do
  begin
    FieldName := 'Estado';
    Title.Caption := 'Estado';
    Width := 120;
  end;
  with gridSolicitudes.Columns.Add do
  begin
    FieldName := 'Prioridad';
    Title.Caption := 'Prior.';
    Width := 50;
  end;
  with gridSolicitudes.Columns.Add do
  begin
    FieldName := 'FechaSolicitud';
    Title.Caption := 'Fecha';
    Width := 80;
  end;
end;

procedure TfrmSolicitudes.CargarTiposSolicitud;
begin
  cmbTipoSolicitud.Items.Clear;
  FqryAux.Close;
  FqryAux.SQL.Text := 'SELECT TipoSolicitudID, Nombre FROM TiposSolicitud WHERE Activo = TRUE ORDER BY Nombre';
  FqryAux.Open;
  while not FqryAux.Eof do
  begin
    cmbTipoSolicitud.Items.AddObject(
      FqryAux.FieldByName('Nombre').AsString,
      TObject(FqryAux.FieldByName('TipoSolicitudID').AsInteger)
    );
    FqryAux.Next;
  end;
  FqryAux.Close;
  if cmbTipoSolicitud.Items.Count > 0 then
    cmbTipoSolicitud.ItemIndex := 0;
end;

procedure TfrmSolicitudes.CargarUsuarios;
begin
  // Cargar usuarios para asignaciones
  FqryAux.Close;
  FqryAux.SQL.Text := 'SELECT UsuarioID, Nombre || '' '' || Apellido AS NombreCompleto FROM Usuarios WHERE Activo = TRUE ORDER BY Nombre';
  FqryAux.Open;

  cmbReceptor.Items.Clear;
  cmbRevisor.Items.Clear;
  cmbInspector.Items.Clear;
  cmbAprobador.Items.Clear;

  cmbReceptor.Items.AddObject('(Sin asignar)', TObject(0));
  cmbRevisor.Items.AddObject('(Sin asignar)', TObject(0));
  cmbInspector.Items.AddObject('(Sin asignar)', TObject(0));
  cmbAprobador.Items.AddObject('(Sin asignar)', TObject(0));

  while not FqryAux.Eof do
  begin
    cmbReceptor.Items.AddObject(
      FqryAux.FieldByName('NombreCompleto').AsString,
      TObject(FqryAux.FieldByName('UsuarioID').AsInteger)
    );
    cmbRevisor.Items.AddObject(
      FqryAux.FieldByName('NombreCompleto').AsString,
      TObject(FqryAux.FieldByName('UsuarioID').AsInteger)
    );
    cmbInspector.Items.AddObject(
      FqryAux.FieldByName('NombreCompleto').AsString,
      TObject(FqryAux.FieldByName('UsuarioID').AsInteger)
    );
    cmbAprobador.Items.AddObject(
      FqryAux.FieldByName('NombreCompleto').AsString,
      TObject(FqryAux.FieldByName('UsuarioID').AsInteger)
    );
    FqryAux.Next;
  end;
  FqryAux.Close;

  cmbReceptor.ItemIndex := 0;
  cmbRevisor.ItemIndex := 0;
  cmbInspector.ItemIndex := 0;
  cmbAprobador.ItemIndex := 0;
end;

procedure TfrmSolicitudes.CargarListado;
var
  Filtro, FiltroEstado: string;
begin
  Filtro := Trim(edtBuscar.Text);
  FiltroEstado := cmbFiltroEstado.Text;

  FqrySolicitudes.Close;

  FqrySolicitudes.SQL.Text :=
    'SELECT s.SolicitudID, s.NumeroExpediente, ts.Nombre AS TipoSolicitud, ' +
    '  COALESCE(c.RazonSocial, c.Nombre || '' '' || c.Apellido) AS Contribuyente, ' +
    '  s.Estado, s.Prioridad, s.FechaSolicitud::DATE ' +
    'FROM Solicitudes s ' +
    'INNER JOIN TiposSolicitud ts ON s.TipoSolicitudID = ts.TipoSolicitudID ' +
    'INNER JOIN Contribuyentes c ON s.ContribuyenteID = c.ContribuyenteID ' +
    'WHERE 1=1 ';

  if Filtro <> '' then
    FqrySolicitudes.SQL.Text := FqrySolicitudes.SQL.Text +
      'AND (s.NumeroExpediente ILIKE ''%' + Filtro + '%'' ' +
      'OR c.RIF ILIKE ''%' + Filtro + '%'' ' +
      'OR c.Nombre ILIKE ''%' + Filtro + '%'' ' +
      'OR c.RazonSocial ILIKE ''%' + Filtro + '%'') ';

  if (FiltroEstado <> '') and (FiltroEstado <> 'Todos') then
    FqrySolicitudes.SQL.Text := FqrySolicitudes.SQL.Text +
      'AND s.Estado = ''' + FiltroEstado + ''' ';

  FqrySolicitudes.SQL.Text := FqrySolicitudes.SQL.Text +
    'ORDER BY s.Prioridad ASC, s.FechaSolicitud DESC LIMIT 500';

  FqrySolicitudes.Open;
end;

procedure TfrmSolicitudes.CargarSolicitud(ID: Integer);
var
  I: Integer;
begin
  FqryDetalle.Close;
  FqryDetalle.SQL.Text :=
    'SELECT s.*, ts.Nombre AS TipoSolicitudNombre, ' +
    '  c.RIF, c.Cedula, c.Telefono, c.Celular, ' +
    '  COALESCE(c.RazonSocial, c.Nombre || '' '' || c.Apellido) AS NombreContribuyente ' +
    'FROM Solicitudes s ' +
    'INNER JOIN TiposSolicitud ts ON s.TipoSolicitudID = ts.TipoSolicitudID ' +
    'INNER JOIN Contribuyentes c ON s.ContribuyenteID = c.ContribuyenteID ' +
    'WHERE s.SolicitudID = :ID';
  FqryDetalle.ParamByName('ID').AsInteger := ID;
  FqryDetalle.Open;

  if FqryDetalle.IsEmpty then
  begin
    ShowMessage('Solicitud no encontrada');
    Exit;
  end;

  FSolicitudID := ID;
  FContribuyenteID := FqryDetalle.FieldByName('ContribuyenteID').AsInteger;
  FFichaID := FqryDetalle.FieldByName('FichaCatastralID').AsInteger;

  // Datos generales
  edtNumExpediente.Text := FqryDetalle.FieldByName('NumeroExpediente').AsString;
  edtFechaSolicitud.Text := FormatDateTime('dd/mm/yyyy', FqryDetalle.FieldByName('FechaSolicitud').AsDateTime);
  edtEstado.Text := FqryDetalle.FieldByName('Estado').AsString;

  // Tipo de solicitud
  for I := 0 to cmbTipoSolicitud.Items.Count - 1 do
  begin
    if Integer(cmbTipoSolicitud.Items.Objects[I]) = FqryDetalle.FieldByName('TipoSolicitudID').AsInteger then
    begin
      cmbTipoSolicitud.ItemIndex := I;
      Break;
    end;
  end;

  // Prioridad
  cmbPrioridad.ItemIndex := FqryDetalle.FieldByName('Prioridad').AsInteger - 1;

  // Contribuyente
  edtContribuyente.Text := FqryDetalle.FieldByName('NombreContribuyente').AsString;
  edtRIF.Text := FqryDetalle.FieldByName('RIF').AsString;
  edtCedula.Text := FqryDetalle.FieldByName('Cedula').AsString;
  edtTelefono.Text := FqryDetalle.FieldByName('Telefono').AsString;

  // Observaciones
  memObservaciones.Text := FqryDetalle.FieldByName('Observaciones').AsString;

  // Workflow - Fechas
  if not FqryDetalle.FieldByName('FechaRecepcion').IsNull then
    edtFechaRecepcion.Text := FormatDateTime('dd/mm/yyyy HH:nn', FqryDetalle.FieldByName('FechaRecepcion').AsDateTime)
  else
    edtFechaRecepcion.Clear;

  if not FqryDetalle.FieldByName('FechaAsignacion').IsNull then
    edtFechaAsignacion.Text := FormatDateTime('dd/mm/yyyy HH:nn', FqryDetalle.FieldByName('FechaAsignacion').AsDateTime)
  else
    edtFechaAsignacion.Clear;

  if not FqryDetalle.FieldByName('FechaInspeccion').IsNull then
    edtFechaInspeccion.Text := FormatDateTime('dd/mm/yyyy HH:nn', FqryDetalle.FieldByName('FechaInspeccion').AsDateTime)
  else
    edtFechaInspeccion.Clear;

  if not FqryDetalle.FieldByName('FechaResolucion').IsNull then
    edtFechaResolucion.Text := FormatDateTime('dd/mm/yyyy HH:nn', FqryDetalle.FieldByName('FechaResolucion').AsDateTime)
  else
    edtFechaResolucion.Clear;

  // Ficha asociada
  if FFichaID > 0 then
  begin
    FqryAux.Close;
    FqryAux.SQL.Text := 'SELECT CodigoCatastral FROM FichaCatastral WHERE FichaID = :ID';
    FqryAux.ParamByName('ID').AsInteger := FFichaID;
    FqryAux.Open;
    edtFichaAsociada.Text := FqryAux.FieldByName('CodigoCatastral').AsString;
    FqryAux.Close;
  end
  else
    edtFichaAsociada.Text := '(Sin ficha asociada)';

  CargarHistorial;
  ActualizarBotonesWorkflow;
  FqryDetalle.Close;
end;

procedure TfrmSolicitudes.CargarHistorial;
begin
  FqryHistorial.Close;
  FqryHistorial.SQL.Text :=
    'SELECT h.FechaCambio, h.EstadoAnterior, h.EstadoNuevo, ' +
    '  u.Nombre || '' '' || u.Apellido AS Usuario, h.Observaciones ' +
    'FROM SolicitudesHistorial h ' +
    'LEFT JOIN Usuarios u ON h.UsuarioID = u.UsuarioID ' +
    'WHERE h.SolicitudID = :ID ' +
    'ORDER BY h.FechaCambio DESC';
  FqryHistorial.ParamByName('ID').AsInteger := FSolicitudID;
  FqryHistorial.Open;
end;

procedure TfrmSolicitudes.LimpiarFormulario;
begin
  edtNumExpediente.Text := '(Se generará automáticamente)';
  edtFechaSolicitud.Text := FormatDateTime('dd/mm/yyyy', Now);
  edtEstado.Text := 'PENDIENTE';
  cmbTipoSolicitud.ItemIndex := 0;
  cmbPrioridad.ItemIndex := 2;

  edtContribuyente.Clear;
  edtRIF.Clear;
  edtCedula.Clear;
  edtTelefono.Clear;
  memObservaciones.Clear;

  edtFechaRecepcion.Clear;
  edtFechaAsignacion.Clear;
  edtFechaInspeccion.Clear;
  edtFechaResolucion.Clear;

  cmbReceptor.ItemIndex := 0;
  cmbRevisor.ItemIndex := 0;
  cmbInspector.ItemIndex := 0;
  cmbAprobador.ItemIndex := 0;

  edtFichaAsociada.Text := '(Sin ficha asociada)';

  FSolicitudID := 0;
  FContribuyenteID := 0;
  FFichaID := 0;

  ActualizarBotonesWorkflow;
end;

procedure TfrmSolicitudes.MostrarDetalle(Mostrar: Boolean);
begin
  pnlListado.Visible := not Mostrar;
  pnlDetalle.Visible := Mostrar;
  pnlBotonesListado.Visible := not Mostrar;
  pnlBotonesDetalle.Visible := Mostrar;

  if Mostrar then
  begin
    pcDetalle.ActivePageIndex := 0;
    cmbTipoSolicitud.SetFocus;
  end
  else
    edtBuscar.SetFocus;
end;

procedure TfrmSolicitudes.HabilitarEdicion(Habilitar: Boolean);
begin
  cmbTipoSolicitud.Enabled := Habilitar and (FModo = msNueva);
  cmbPrioridad.Enabled := Habilitar;
  btnSeleccionarContribuyente.Enabled := Habilitar and (FModo = msNueva);
  btnNuevoContribuyente.Enabled := Habilitar and (FModo = msNueva);
  memObservaciones.ReadOnly := not Habilitar;

  btnGuardar.Visible := Habilitar;
  btnEditar.Visible := not Habilitar and (FModo = msConsultar);
  btnAnular.Visible := not Habilitar and (FModo = msConsultar);
end;

procedure TfrmSolicitudes.ActualizarBotonesWorkflow;
var
  Estado: string;
begin
  Estado := edtEstado.Text;

  // Desactivar todos por defecto
  btnRecibir.Enabled := False;
  btnAsignar.Enabled := False;
  btnInspeccionar.Enabled := False;
  btnAprobar.Enabled := False;
  btnRechazar.Enabled := False;
  btnCrearFicha.Enabled := False;
  btnVerFicha.Enabled := False;
  btnImprimirFicha.Enabled := False;

  if FModo <> msConsultar then Exit;

  // Habilitar según estado actual
  if Estado = 'PENDIENTE' then
    btnRecibir.Enabled := True
  else if Estado = 'EN_REVISION' then
  begin
    btnAsignar.Enabled := True;
    btnRechazar.Enabled := True;
  end
  else if Estado = 'INSPECCION' then
  begin
    btnInspeccionar.Enabled := True;
    btnRechazar.Enabled := True;
  end
  else if Estado = 'PENDIENTE_APROBACION' then
  begin
    btnAprobar.Enabled := PuedeAutorizar;
    btnRechazar.Enabled := True;
    btnCrearFicha.Enabled := FFichaID = 0;
  end
  else if Estado = 'APROBADO' then
  begin
    btnVerFicha.Enabled := FFichaID > 0;
    btnImprimirFicha.Enabled := FFichaID > 0;
    btnCrearFicha.Enabled := FFichaID = 0;
  end;
end;

function TfrmSolicitudes.PuedeAutorizar: Boolean;
begin
  // Verificar si el usuario actual tiene permiso de autorización
  Result := False;
  FqryAux.Close;
  FqryAux.SQL.Text :=
    'SELECT 1 FROM Usuarios u ' +
    'INNER JOIN Roles r ON u.RolID = r.RolID ' +
    'LEFT JOIN RolesPermisos rp ON r.RolID = rp.RolID ' +
    'LEFT JOIN Permisos p ON rp.PermisoID = p.PermisoID ' +
    'WHERE u.UsuarioID = :UsuarioID ' +
    'AND (r.EsSuperUsuario = TRUE OR p.Codigo IN (''AUTORIZA_CARTA_CATASTRAL'', ''SOLIC_APROBAR''))';
  FqryAux.ParamByName('UsuarioID').AsInteger := dmMain.UsuarioActual.UsuarioID;
  FqryAux.Open;
  Result := not FqryAux.IsEmpty;
  FqryAux.Close;
end;

function TfrmSolicitudes.ValidarDatos: Boolean;
begin
  Result := False;

  if FContribuyenteID = 0 then
  begin
    ShowMessage('Debe seleccionar un contribuyente');
    btnSeleccionarContribuyente.SetFocus;
    Exit;
  end;

  if cmbTipoSolicitud.ItemIndex < 0 then
  begin
    ShowMessage('Debe seleccionar el tipo de solicitud');
    cmbTipoSolicitud.SetFocus;
    Exit;
  end;

  Result := True;
end;

function TfrmSolicitudes.GuardarSolicitud: Boolean;
var
  TipoSolicitudID: Integer;
begin
  Result := False;

  if not ValidarDatos then
    Exit;

  TipoSolicitudID := Integer(cmbTipoSolicitud.Items.Objects[cmbTipoSolicitud.ItemIndex]);

  try
    dmMain.ConnectionPG.StartTransaction;
    try
      if FModo = msNueva then
      begin
        FqryDetalle.SQL.Text :=
          'INSERT INTO Solicitudes (TipoSolicitudID, ContribuyenteID, Prioridad, Observaciones) ' +
          'VALUES (:TipoSolicitudID, :ContribuyenteID, :Prioridad, :Observaciones) ' +
          'RETURNING SolicitudID';
        FqryDetalle.ParamByName('TipoSolicitudID').AsInteger := TipoSolicitudID;
        FqryDetalle.ParamByName('ContribuyenteID').AsInteger := FContribuyenteID;
      end
      else
      begin
        FqryDetalle.SQL.Text :=
          'UPDATE Solicitudes SET ' +
          'Prioridad = :Prioridad, Observaciones = :Observaciones ' +
          'WHERE SolicitudID = :SolicitudID';
        FqryDetalle.ParamByName('SolicitudID').AsInteger := FSolicitudID;
      end;

      FqryDetalle.ParamByName('Prioridad').AsInteger := cmbPrioridad.ItemIndex + 1;
      FqryDetalle.ParamByName('Observaciones').AsString := Trim(memObservaciones.Text);

      if FModo = msNueva then
      begin
        FqryDetalle.Open;
        FSolicitudID := FqryDetalle.FieldByName('SolicitudID').AsInteger;
        FqryDetalle.Close;
      end
      else
        FqryDetalle.ExecSQL;

      dmMain.ConnectionPG.Commit;

      if FModo = msNueva then
        dmMain.RegistrarBitacora('CREAR', 'SOLICITUDES', 'Solicitudes', FSolicitudID, '', '', 'EXITO')
      else
        dmMain.RegistrarBitacora('ACTUALIZAR', 'SOLICITUDES', 'Solicitudes', FSolicitudID, '', '', 'EXITO');

      Result := True;
    except
      on E: Exception do
      begin
        dmMain.ConnectionPG.Rollback;
        ShowMessage('Error al guardar: ' + E.Message);
      end;
    end;
  except
    on E: Exception do
      ShowMessage('Error de transacción: ' + E.Message);
  end;
end;

function TfrmSolicitudes.CambiarEstado(NuevoEstado: string; Observacion: string): Boolean;
begin
  Result := False;
  try
    dmMain.ConnectionPG.StartTransaction;
    try
      FqryDetalle.SQL.Text :=
        'UPDATE Solicitudes SET Estado = :Estado WHERE SolicitudID = :ID';
      FqryDetalle.ParamByName('Estado').AsString := NuevoEstado;
      FqryDetalle.ParamByName('ID').AsInteger := FSolicitudID;
      FqryDetalle.ExecSQL;

      // Actualizar fechas según el estado
      case AnsiIndexStr(NuevoEstado, ['EN_REVISION', 'INSPECCION', 'PENDIENTE_APROBACION', 'APROBADO', 'RECHAZADO']) of
        0: // EN_REVISION
        begin
          FqryDetalle.SQL.Text := 'UPDATE Solicitudes SET FechaRecepcion = CURRENT_TIMESTAMP, ' +
            'UsuarioReceptor = :UsuarioID WHERE SolicitudID = :ID';
          FqryDetalle.ParamByName('UsuarioID').AsInteger := dmMain.UsuarioActual.UsuarioID;
          FqryDetalle.ParamByName('ID').AsInteger := FSolicitudID;
          FqryDetalle.ExecSQL;
        end;
        1: // INSPECCION
        begin
          FqryDetalle.SQL.Text := 'UPDATE Solicitudes SET FechaAsignacion = CURRENT_TIMESTAMP, ' +
            'UsuarioRevisor = :UsuarioID WHERE SolicitudID = :ID';
          FqryDetalle.ParamByName('UsuarioID').AsInteger := dmMain.UsuarioActual.UsuarioID;
          FqryDetalle.ParamByName('ID').AsInteger := FSolicitudID;
          FqryDetalle.ExecSQL;
        end;
        2: // PENDIENTE_APROBACION
        begin
          FqryDetalle.SQL.Text := 'UPDATE Solicitudes SET FechaInspeccion = CURRENT_TIMESTAMP, ' +
            'UsuarioInspector = :UsuarioID WHERE SolicitudID = :ID';
          FqryDetalle.ParamByName('UsuarioID').AsInteger := dmMain.UsuarioActual.UsuarioID;
          FqryDetalle.ParamByName('ID').AsInteger := FSolicitudID;
          FqryDetalle.ExecSQL;
        end;
        3, 4: // APROBADO, RECHAZADO
        begin
          FqryDetalle.SQL.Text := 'UPDATE Solicitudes SET FechaResolucion = CURRENT_TIMESTAMP, ' +
            'UsuarioAprobador = :UsuarioID WHERE SolicitudID = :ID';
          FqryDetalle.ParamByName('UsuarioID').AsInteger := dmMain.UsuarioActual.UsuarioID;
          FqryDetalle.ParamByName('ID').AsInteger := FSolicitudID;
          FqryDetalle.ExecSQL;
        end;
      end;

      dmMain.ConnectionPG.Commit;
      dmMain.RegistrarBitacora('CAMBIAR_ESTADO', 'SOLICITUDES', 'Solicitudes', FSolicitudID, '', NuevoEstado, 'EXITO');
      Result := True;
    except
      on E: Exception do
      begin
        dmMain.ConnectionPG.Rollback;
        ShowMessage('Error al cambiar estado: ' + E.Message);
      end;
    end;
  except
    on E: Exception do
      ShowMessage('Error de transacción: ' + E.Message);
  end;
end;

procedure TfrmSolicitudes.btnBuscarClick(Sender: TObject);
begin
  CargarListado;
end;

procedure TfrmSolicitudes.edtBuscarKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnBuscarClick(nil);
  end;
end;

procedure TfrmSolicitudes.cmbFiltroEstadoChange(Sender: TObject);
begin
  CargarListado;
end;

procedure TfrmSolicitudes.btnNuevaClick(Sender: TObject);
begin
  FModo := msNueva;
  LimpiarFormulario;
  MostrarDetalle(True);
  HabilitarEdicion(True);
end;

procedure TfrmSolicitudes.gridSolicitudesDblClick(Sender: TObject);
begin
  if not FqrySolicitudes.IsEmpty then
  begin
    FModo := msConsultar;
    CargarSolicitud(FqrySolicitudes.FieldByName('SolicitudID').AsInteger);
    MostrarDetalle(True);
    HabilitarEdicion(False);
  end;
end;

procedure TfrmSolicitudes.btnEditarClick(Sender: TObject);
begin
  FModo := msEditar;
  HabilitarEdicion(True);
end;

procedure TfrmSolicitudes.btnGuardarClick(Sender: TObject);
begin
  if GuardarSolicitud then
  begin
    ShowMessage('Solicitud guardada correctamente');
    MostrarDetalle(False);
    CargarListado;
  end;
end;

procedure TfrmSolicitudes.btnCancelarClick(Sender: TObject);
begin
  MostrarDetalle(False);
end;

procedure TfrmSolicitudes.btnAnularClick(Sender: TObject);
begin
  if MessageDlg('¿Está seguro que desea anular esta solicitud?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    if CambiarEstado('ANULADO', 'Anulación manual') then
    begin
      ShowMessage('Solicitud anulada');
      MostrarDetalle(False);
      CargarListado;
    end;
  end;
end;

procedure TfrmSolicitudes.btnSeleccionarContribuyenteClick(Sender: TObject);
var
  Frm: TfrmContribuyentes;
begin
  Frm := TfrmContribuyentes.Create(Application);
  try
    FContribuyenteID := Frm.SeleccionarContribuyente;
    if FContribuyenteID > 0 then
    begin
      // Cargar datos del contribuyente
      FqryAux.Close;
      FqryAux.SQL.Text :=
        'SELECT RIF, Cedula, Telefono, ' +
        '  COALESCE(RazonSocial, Nombre || '' '' || Apellido) AS NombreCompleto ' +
        'FROM Contribuyentes WHERE ContribuyenteID = :ID';
      FqryAux.ParamByName('ID').AsInteger := FContribuyenteID;
      FqryAux.Open;
      edtContribuyente.Text := FqryAux.FieldByName('NombreCompleto').AsString;
      edtRIF.Text := FqryAux.FieldByName('RIF').AsString;
      edtCedula.Text := FqryAux.FieldByName('Cedula').AsString;
      edtTelefono.Text := FqryAux.FieldByName('Telefono').AsString;
      FqryAux.Close;
    end;
  finally
    Frm.Free;
  end;
end;

procedure TfrmSolicitudes.btnNuevoContribuyenteClick(Sender: TObject);
var
  Frm: TfrmContribuyentes;
begin
  Frm := TfrmContribuyentes.Create(Application);
  try
    Frm.ShowModal;
    // Después de crear, podemos seleccionar el nuevo contribuyente
  finally
    Frm.Free;
  end;
end;

procedure TfrmSolicitudes.btnRecibirClick(Sender: TObject);
begin
  if CambiarEstado('EN_REVISION', 'Solicitud recibida') then
  begin
    ShowMessage('Solicitud recibida correctamente');
    CargarSolicitud(FSolicitudID);
  end;
end;

procedure TfrmSolicitudes.btnAsignarClick(Sender: TObject);
begin
  if CambiarEstado('INSPECCION', 'Solicitud asignada para inspección') then
  begin
    ShowMessage('Solicitud asignada para inspección');
    CargarSolicitud(FSolicitudID);
  end;
end;

procedure TfrmSolicitudes.btnInspeccionarClick(Sender: TObject);
begin
  if CambiarEstado('PENDIENTE_APROBACION', 'Inspección completada') then
  begin
    ShowMessage('Inspección registrada, pendiente de aprobación');
    CargarSolicitud(FSolicitudID);
  end;
end;

procedure TfrmSolicitudes.btnAprobarClick(Sender: TObject);
begin
  if not PuedeAutorizar then
  begin
    ShowMessage('No tiene permisos para aprobar solicitudes.' + #13#10 +
      'Contacte a un supervisor o gerente con permiso de autorización.');
    Exit;
  end;

  if MessageDlg('¿Está seguro que desea APROBAR esta solicitud?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    if CambiarEstado('APROBADO', 'Solicitud aprobada') then
    begin
      ShowMessage('Solicitud APROBADA correctamente');
      CargarSolicitud(FSolicitudID);
    end;
  end;
end;

procedure TfrmSolicitudes.btnRechazarClick(Sender: TObject);
var
  Motivo: string;
begin
  if InputQuery('Rechazar Solicitud', 'Ingrese el motivo del rechazo:', Motivo) then
  begin
    if Trim(Motivo) = '' then
    begin
      ShowMessage('Debe ingresar un motivo para el rechazo');
      Exit;
    end;

    if CambiarEstado('RECHAZADO', Motivo) then
    begin
      // Guardar motivo de rechazo
      FqryDetalle.SQL.Text := 'UPDATE Solicitudes SET MotivoRechazo = :Motivo WHERE SolicitudID = :ID';
      FqryDetalle.ParamByName('Motivo').AsString := Motivo;
      FqryDetalle.ParamByName('ID').AsInteger := FSolicitudID;
      FqryDetalle.ExecSQL;

      ShowMessage('Solicitud RECHAZADA');
      CargarSolicitud(FSolicitudID);
    end;
  end;
end;

procedure TfrmSolicitudes.btnCrearFichaClick(Sender: TObject);
var
  Frm: TfrmFicha;
begin
  Frm := TfrmFicha.Create(Application);
  try
    Frm.NuevaFicha(FContribuyenteID);
    if Frm.ShowModal = mrOk then
    begin
      // Asociar ficha a la solicitud
      FFichaID := Frm.FichaID;
      if FFichaID > 0 then
      begin
        FqryDetalle.SQL.Text := 'UPDATE Solicitudes SET FichaCatastralID = :FichaID WHERE SolicitudID = :ID';
        FqryDetalle.ParamByName('FichaID').AsInteger := FFichaID;
        FqryDetalle.ParamByName('ID').AsInteger := FSolicitudID;
        FqryDetalle.ExecSQL;
        ShowMessage('Ficha catastral creada y asociada a la solicitud');
        CargarSolicitud(FSolicitudID);
      end;
    end;
  finally
    Frm.Free;
  end;
end;

procedure TfrmSolicitudes.btnVerFichaClick(Sender: TObject);
var
  Frm: TfrmFicha;
begin
  if FFichaID > 0 then
  begin
    Frm := TfrmFicha.Create(Application);
    try
      Frm.CargarFicha(FFichaID);
      Frm.ShowModal;
    finally
      Frm.Free;
    end;
  end
  else
    ShowMessage('No hay ficha catastral asociada');
end;

procedure TfrmSolicitudes.btnImprimirFichaClick(Sender: TObject);
begin
  if FFichaID = 0 then
  begin
    ShowMessage('No hay ficha catastral asociada');
    Exit;
  end;

  if edtEstado.Text <> 'APROBADO' then
  begin
    ShowMessage('Solo se pueden imprimir fichas de solicitudes APROBADAS');
    Exit;
  end;

  // Aquí se implementará la generación con FastReport
  ShowMessage('Generando ficha catastral para impresión...' + #13#10 +
    'Ficha: ' + edtFichaAsociada.Text + #13#10 +
    '(FastReport - Por implementar)');

  dmMain.RegistrarBitacora('IMPRIMIR', 'CATASTRO', 'FichaCatastral', FFichaID, '', '', 'EXITO');
end;

procedure TfrmSolicitudes.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSolicitudes.NuevaSolicitudParaContribuyente(ContribuyenteID: Integer);
begin
  FModo := msNueva;
  LimpiarFormulario;
  FContribuyenteID := ContribuyenteID;

  // Cargar datos del contribuyente
  FqryAux.Close;
  FqryAux.SQL.Text :=
    'SELECT RIF, Cedula, Telefono, ' +
    '  COALESCE(RazonSocial, Nombre || '' '' || Apellido) AS NombreCompleto ' +
    'FROM Contribuyentes WHERE ContribuyenteID = :ID';
  FqryAux.ParamByName('ID').AsInteger := FContribuyenteID;
  FqryAux.Open;
  edtContribuyente.Text := FqryAux.FieldByName('NombreCompleto').AsString;
  edtRIF.Text := FqryAux.FieldByName('RIF').AsString;
  edtCedula.Text := FqryAux.FieldByName('Cedula').AsString;
  edtTelefono.Text := FqryAux.FieldByName('Telefono').AsString;
  FqryAux.Close;

  MostrarDetalle(True);
  HabilitarEdicion(True);
end;

end.
