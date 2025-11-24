unit uFrmContribuyentes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, Vcl.Mask,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  TModoContribuyente = (mcListado, mcNuevo, mcEditar, mcConsultar);

  TfrmContribuyentes = class(TForm)
    // Panel Superior - Búsqueda
    pnlBusqueda: TPanel;
    lblBuscar: TLabel;
    edtBuscar: TEdit;
    btnBuscar: TBitBtn;
    btnNuevo: TBitBtn;
    cmbFiltroBusqueda: TComboBox;

    // Panel Principal
    pnlPrincipal: TPanel;

    // Panel Listado
    pnlListado: TPanel;
    gridContribuyentes: TDBGrid;
    dsContribuyentes: TDataSource;

    // Panel Detalle (para edición/creación)
    pnlDetalle: TPanel;

    // Grupo: Identificación
    gbIdentificacion: TGroupBox;
    lblTipoPersona: TLabel;
    cmbTipoPersona: TComboBox;
    lblRIF: TLabel;
    edtRIF: TEdit;
    lblCedula: TLabel;
    edtCedula: TEdit;

    // Grupo: Datos Personales
    gbDatosPersonales: TGroupBox;
    lblNombre: TLabel;
    edtNombre: TEdit;
    lblApellido: TLabel;
    edtApellido: TEdit;
    lblRazonSocial: TLabel;
    edtRazonSocial: TEdit;

    // Grupo: Contacto
    gbContacto: TGroupBox;
    lblTelefono: TLabel;
    edtTelefono: TEdit;
    lblCelular: TLabel;
    edtCelular: TEdit;
    lblEmail: TLabel;
    edtEmail: TEdit;

    // Grupo: Domicilio
    gbDomicilio: TGroupBox;
    lblDireccion: TLabel;
    memDireccion: TMemo;
    lblEstado: TLabel;
    cmbEstado: TComboBox;
    lblMunicipio: TLabel;
    cmbMunicipio: TComboBox;
    lblParroquia: TLabel;
    cmbParroquia: TComboBox;
    lblCiudad: TLabel;
    cmbCiudad: TComboBox;
    lblSector: TLabel;
    cmbSector: TComboBox;
    lblCodigoPostal: TLabel;
    edtCodigoPostal: TEdit;

    // Grupo: Estado
    gbEstado: TGroupBox;
    chkActivo: TCheckBox;
    lblFechaRegistro: TLabel;
    edtFechaRegistro: TEdit;

    // Panel Botones Detalle
    pnlBotonesDetalle: TPanel;
    btnGuardar: TBitBtn;
    btnCancelar: TBitBtn;
    btnEditar: TBitBtn;
    btnEliminar: TBitBtn;

    // Panel Inferior - Botones Listado
    pnlBotonesListado: TPanel;
    btnVerFichas: TBitBtn;
    btnVerSolicitudes: TBitBtn;
    btnCerrar: TBitBtn;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnNuevoClick(Sender: TObject);
    procedure btnGuardarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnEliminarClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure btnVerFichasClick(Sender: TObject);
    procedure btnVerSolicitudesClick(Sender: TObject);
    procedure gridContribuyentesDblClick(Sender: TObject);
    procedure cmbTipoPersonaChange(Sender: TObject);
    procedure cmbEstadoChange(Sender: TObject);
    procedure cmbMunicipioChange(Sender: TObject);
    procedure cmbParroquiaChange(Sender: TObject);
    procedure cmbCiudadChange(Sender: TObject);
    procedure edtBuscarKeyPress(Sender: TObject; var Key: Char);

  private
    FModo: TModoContribuyente;
    FContribuyenteID: Integer;
    FqryContribuyentes: TFDQuery;
    FqryDetalle: TFDQuery;

    procedure CargarListado;
    procedure CargarContribuyente(ID: Integer);
    procedure LimpiarFormulario;
    procedure MostrarDetalle(Mostrar: Boolean);
    procedure HabilitarEdicion(Habilitar: Boolean);
    function ValidarDatos: Boolean;
    function GuardarContribuyente: Boolean;
    procedure ConfigurarGrid;
    procedure AjustarCamposPorTipoPersona;
    procedure CargarEstados;
    procedure CargarMunicipios(EstadoID: Integer);
    procedure CargarParroquias(MunicipioID: Integer);
    procedure CargarCiudades(ParroquiaID: Integer);
    procedure CargarSectores(CiudadID: Integer);
    procedure CargarConfiguracionUbicacion;

  public
    function SeleccionarContribuyente: Integer;
  end;

var
  frmContribuyentes: TfrmContribuyentes;

implementation

{$R *.dfm}

uses
  uDmMain, uFrmSolicitudes;

{ TfrmContribuyentes }

procedure TfrmContribuyentes.FormCreate(Sender: TObject);
begin
  FqryContribuyentes := TFDQuery.Create(Self);
  FqryContribuyentes.Connection := dmMain.ConnectionPG;

  FqryDetalle := TFDQuery.Create(Self);
  FqryDetalle.Connection := dmMain.ConnectionPG;

  dsContribuyentes.DataSet := FqryContribuyentes;

  FContribuyenteID := 0;
  FModo := mcListado;

  // Configurar combo de filtro
  cmbFiltroBusqueda.Items.Clear;
  cmbFiltroBusqueda.Items.Add('Todos los campos');
  cmbFiltroBusqueda.Items.Add('RIF');
  cmbFiltroBusqueda.Items.Add('Cédula');
  cmbFiltroBusqueda.Items.Add('Nombre/Razón Social');
  cmbFiltroBusqueda.ItemIndex := 0;

  // Configurar tipo de persona
  cmbTipoPersona.Items.Clear;
  cmbTipoPersona.Items.Add('NATURAL');
  cmbTipoPersona.Items.Add('JURIDICA');
  cmbTipoPersona.ItemIndex := 0;

  // Cargar Estados de Venezuela
  CargarEstados;

  // Aplicar configuración de ubicación fija
  CargarConfiguracionUbicacion;

  ConfigurarGrid;
end;

procedure TfrmContribuyentes.CargarEstados;
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmMain.ConnectionPG;
    qry.SQL.Text := 'SELECT EstadoID, Nombre FROM Estados WHERE Activo = TRUE ORDER BY Nombre';
    qry.Open;

    cmbEstado.Items.Clear;
    cmbEstado.Items.AddObject('(Seleccione)', TObject(0));

    while not qry.Eof do
    begin
      cmbEstado.Items.AddObject(
        qry.FieldByName('Nombre').AsString,
        TObject(qry.FieldByName('EstadoID').AsInteger)
      );
      qry.Next;
    end;

    cmbEstado.ItemIndex := 0;
    qry.Close;
  finally
    qry.Free;
  end;
end;

procedure TfrmContribuyentes.CargarMunicipios(EstadoID: Integer);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmMain.ConnectionPG;
    qry.SQL.Text := 'SELECT MunicipioID, Nombre FROM Municipios WHERE EstadoID = :EstadoID AND Activo = TRUE ORDER BY Nombre';
    qry.ParamByName('EstadoID').AsInteger := EstadoID;
    qry.Open;

    cmbMunicipio.Items.Clear;
    cmbMunicipio.Items.AddObject('(Seleccione)', TObject(0));

    while not qry.Eof do
    begin
      cmbMunicipio.Items.AddObject(
        qry.FieldByName('Nombre').AsString,
        TObject(qry.FieldByName('MunicipioID').AsInteger)
      );
      qry.Next;
    end;

    cmbMunicipio.ItemIndex := 0;
    qry.Close;
  finally
    qry.Free;
  end;

  // Limpiar niveles inferiores
  cmbParroquia.Items.Clear;
  cmbParroquia.Items.AddObject('(Seleccione)', TObject(0));
  cmbParroquia.ItemIndex := 0;
end;

procedure TfrmContribuyentes.CargarParroquias(MunicipioID: Integer);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmMain.ConnectionPG;
    qry.SQL.Text := 'SELECT ParroquiaID, Nombre FROM Parroquias WHERE MunicipioID = :MunicipioID AND Activo = TRUE ORDER BY Nombre';
    qry.ParamByName('MunicipioID').AsInteger := MunicipioID;
    qry.Open;

    cmbParroquia.Items.Clear;
    cmbParroquia.Items.AddObject('(Seleccione)', TObject(0));

    while not qry.Eof do
    begin
      cmbParroquia.Items.AddObject(
        qry.FieldByName('Nombre').AsString,
        TObject(qry.FieldByName('ParroquiaID').AsInteger)
      );
      qry.Next;
    end;

    cmbParroquia.ItemIndex := 0;
    qry.Close;
  finally
    qry.Free;
  end;
end;

procedure TfrmContribuyentes.CargarCiudades(ParroquiaID: Integer);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmMain.ConnectionPG;
    qry.SQL.Text := 'SELECT CiudadID, Nombre FROM Ciudades WHERE ParroquiaID = :ParroquiaID AND Activo = TRUE ORDER BY Nombre';
    qry.ParamByName('ParroquiaID').AsInteger := ParroquiaID;
    qry.Open;

    cmbCiudad.Items.Clear;
    cmbCiudad.Items.AddObject('(Seleccione)', TObject(0));

    while not qry.Eof do
    begin
      cmbCiudad.Items.AddObject(
        qry.FieldByName('Nombre').AsString,
        TObject(qry.FieldByName('CiudadID').AsInteger)
      );
      qry.Next;
    end;

    cmbCiudad.ItemIndex := 0;
    qry.Close;
  finally
    qry.Free;
  end;

  // Limpiar sectores
  cmbSector.Items.Clear;
  cmbSector.Items.AddObject('(Seleccione)', TObject(0));
  cmbSector.ItemIndex := 0;
end;

procedure TfrmContribuyentes.CargarSectores(CiudadID: Integer);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmMain.ConnectionPG;
    qry.SQL.Text := 'SELECT SectorID, Nombre FROM Sectores WHERE CiudadID = :CiudadID AND Activo = TRUE ORDER BY Nombre';
    qry.ParamByName('CiudadID').AsInteger := CiudadID;
    qry.Open;

    cmbSector.Items.Clear;
    cmbSector.Items.AddObject('(Seleccione)', TObject(0));

    while not qry.Eof do
    begin
      cmbSector.Items.AddObject(
        qry.FieldByName('Nombre').AsString,
        TObject(qry.FieldByName('SectorID').AsInteger)
      );
      qry.Next;
    end;

    cmbSector.ItemIndex := 0;
    qry.Close;
  finally
    qry.Free;
  end;
end;

procedure TfrmContribuyentes.CargarConfiguracionUbicacion;
var
  qry: TFDQuery;
  EstadoFijo, MunicipioFijo: Integer;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmMain.ConnectionPG;

    // Obtener Estado fijo
    qry.SQL.Text := 'SELECT COALESCE(Valor, ''0'')::INTEGER AS Val FROM Configuracion WHERE Clave = ''ESTADO_FIJO''';
    qry.Open;
    EstadoFijo := qry.FieldByName('Val').AsInteger;
    qry.Close;

    // Obtener Municipio fijo
    qry.SQL.Text := 'SELECT COALESCE(Valor, ''0'')::INTEGER AS Val FROM Configuracion WHERE Clave = ''MUNICIPIO_FIJO''';
    qry.Open;
    MunicipioFijo := qry.FieldByName('Val').AsInteger;
    qry.Close;

    // Si hay Estado fijo, seleccionarlo y deshabilitar
    if EstadoFijo > 0 then
    begin
      // Buscar el índice del estado
      for var i := 0 to cmbEstado.Items.Count - 1 do
      begin
        if Integer(cmbEstado.Items.Objects[i]) = EstadoFijo then
        begin
          cmbEstado.ItemIndex := i;
          cmbEstado.Enabled := False;
          CargarMunicipios(EstadoFijo);
          Break;
        end;
      end;

      // Si hay Municipio fijo, seleccionarlo
      if MunicipioFijo > 0 then
      begin
        for var j := 0 to cmbMunicipio.Items.Count - 1 do
        begin
          if Integer(cmbMunicipio.Items.Objects[j]) = MunicipioFijo then
          begin
            cmbMunicipio.ItemIndex := j;
            cmbMunicipio.Enabled := False;
            CargarParroquias(MunicipioFijo);
            Break;
          end;
        end;
      end;
    end;
  finally
    qry.Free;
  end;
end;

procedure TfrmContribuyentes.FormDestroy(Sender: TObject);
begin
  // Cerrar queries antes de liberar para evitar hangs
  try
    if Assigned(FqryContribuyentes) then
    begin
      FqryContribuyentes.Close;
      FqryContribuyentes.Free;
    end;
    if Assigned(FqryDetalle) then
    begin
      FqryDetalle.Close;
      FqryDetalle.Free;
    end;
  except
    on E: Exception do
      // Log error silently
      OutputDebugString(PChar('Error en FormDestroy Contribuyentes: ' + E.Message));
  end;
end;

procedure TfrmContribuyentes.FormShow(Sender: TObject);
begin
  MostrarDetalle(False);
  CargarListado;
  edtBuscar.SetFocus;
end;

procedure TfrmContribuyentes.ConfigurarGrid;
begin
  gridContribuyentes.Columns.Clear;

  with gridContribuyentes.Columns.Add do
  begin
    FieldName := 'RIF';
    Title.Caption := 'RIF';
    Width := 100;
  end;
  with gridContribuyentes.Columns.Add do
  begin
    FieldName := 'Cedula';
    Title.Caption := 'Cédula';
    Width := 100;
  end;
  with gridContribuyentes.Columns.Add do
  begin
    FieldName := 'NombreCompleto';
    Title.Caption := 'Nombre / Razón Social';
    Width := 250;
  end;
  with gridContribuyentes.Columns.Add do
  begin
    FieldName := 'Celular';
    Title.Caption := 'Celular';
    Width := 100;
  end;
  with gridContribuyentes.Columns.Add do
  begin
    FieldName := 'Telefono';
    Title.Caption := 'Teléfono';
    Width := 100;
  end;
  with gridContribuyentes.Columns.Add do
  begin
    FieldName := 'Email';
    Title.Caption := 'Email';
    Width := 150;
  end;
  with gridContribuyentes.Columns.Add do
  begin
    FieldName := 'TipoPersona';
    Title.Caption := 'Tipo';
    Width := 80;
  end;
  with gridContribuyentes.Columns.Add do
  begin
    FieldName := 'Activo';
    Title.Caption := 'Activo';
    Width := 50;
  end;
end;

procedure TfrmContribuyentes.CargarListado;
var
  Filtro, Campo: string;
begin
  Filtro := Trim(edtBuscar.Text);

  FqryContribuyentes.Close;

  try
    if Filtro = '' then
    begin
      // Query compatible con esquema original y nuevas columnas
      FqryContribuyentes.SQL.Text :=
        'SELECT ContribuyenteID, RIF, ' +
        '  COALESCE(Cedula, NumeroDocumento) AS Cedula, ' +
        '  COALESCE(TipoPersona, CASE WHEN TipoDocumento = ''J'' THEN ''JURIDICA'' ELSE ''NATURAL'' END) AS TipoPersona, ' +
        '  CASE WHEN TipoDocumento = ''J'' OR COALESCE(TipoPersona, '''') = ''JURIDICA'' THEN RazonSocial ' +
        '       ELSE COALESCE(Nombre, '''') || '' '' || COALESCE(Apellido, '''') END AS NombreCompleto, ' +
        '  COALESCE(Celular, TelefonoMovil) AS Celular, ' +
        '  COALESCE(Telefono, TelefonoLocal) AS Telefono, ' +
        '  Email, Activo ' +
        'FROM Contribuyentes ' +
        'ORDER BY 5 ' +
        'LIMIT 500';
    end
    else
    begin
      case cmbFiltroBusqueda.ItemIndex of
        1: Campo := 'RIF ILIKE :Filtro';
        2: Campo := '(COALESCE(Cedula, NumeroDocumento) ILIKE :Filtro)';
        3: Campo := '(Nombre ILIKE :Filtro OR Apellido ILIKE :Filtro OR RazonSocial ILIKE :Filtro)';
      else
        Campo := '(RIF ILIKE :Filtro OR COALESCE(Cedula, NumeroDocumento) ILIKE :Filtro OR Nombre ILIKE :Filtro OR Apellido ILIKE :Filtro OR RazonSocial ILIKE :Filtro)';
      end;

      FqryContribuyentes.SQL.Text :=
        'SELECT ContribuyenteID, RIF, ' +
        '  COALESCE(Cedula, NumeroDocumento) AS Cedula, ' +
        '  COALESCE(TipoPersona, CASE WHEN TipoDocumento = ''J'' THEN ''JURIDICA'' ELSE ''NATURAL'' END) AS TipoPersona, ' +
        '  CASE WHEN TipoDocumento = ''J'' OR COALESCE(TipoPersona, '''') = ''JURIDICA'' THEN RazonSocial ' +
        '       ELSE COALESCE(Nombre, '''') || '' '' || COALESCE(Apellido, '''') END AS NombreCompleto, ' +
        '  COALESCE(Celular, TelefonoMovil) AS Celular, ' +
        '  COALESCE(Telefono, TelefonoLocal) AS Telefono, ' +
        '  Email, Activo ' +
        'FROM Contribuyentes ' +
        'WHERE ' + Campo + ' ' +
        'ORDER BY 5 ' +
        'LIMIT 500';
      FqryContribuyentes.ParamByName('Filtro').AsString := '%' + Filtro + '%';
    end;

    FqryContribuyentes.Open;
    OutputDebugString(PChar('CargarListado: ' + IntToStr(FqryContribuyentes.RecordCount) + ' registros'));
  except
    on E: Exception do
    begin
      OutputDebugString(PChar('Error en CargarListado: ' + E.Message));
      ShowMessage('Error al cargar contribuyentes: ' + E.Message);
    end;
  end;
end;

procedure TfrmContribuyentes.CargarContribuyente(ID: Integer);
begin
  FqryDetalle.Close;
  FqryDetalle.SQL.Text :=
    'SELECT * FROM Contribuyentes WHERE ContribuyenteID = :ID';
  FqryDetalle.ParamByName('ID').AsInteger := ID;
  FqryDetalle.Open;

  if FqryDetalle.IsEmpty then
  begin
    ShowMessage('Contribuyente no encontrado');
    Exit;
  end;

  FContribuyenteID := ID;

  // Cargar datos
  cmbTipoPersona.ItemIndex := cmbTipoPersona.Items.IndexOf(FqryDetalle.FieldByName('TipoPersona').AsString);
  edtRIF.Text := FqryDetalle.FieldByName('RIF').AsString;
  edtCedula.Text := FqryDetalle.FieldByName('Cedula').AsString;
  edtNombre.Text := FqryDetalle.FieldByName('Nombre').AsString;
  edtApellido.Text := FqryDetalle.FieldByName('Apellido').AsString;
  edtRazonSocial.Text := FqryDetalle.FieldByName('RazonSocial').AsString;
  edtTelefono.Text := FqryDetalle.FieldByName('Telefono').AsString;
  edtCelular.Text := FqryDetalle.FieldByName('Celular').AsString;
  edtEmail.Text := FqryDetalle.FieldByName('Email').AsString;
  memDireccion.Text := FqryDetalle.FieldByName('Direccion').AsString;
  cmbEstado.Text := FqryDetalle.FieldByName('Estado').AsString;
  cmbMunicipio.Text := FqryDetalle.FieldByName('Municipio').AsString;
  cmbParroquia.Text := FqryDetalle.FieldByName('Parroquia').AsString;
  edtCodigoPostal.Text := FqryDetalle.FieldByName('CodigoPostal').AsString;
  chkActivo.Checked := FqryDetalle.FieldByName('Activo').AsBoolean;
  edtFechaRegistro.Text := FormatDateTime('dd/mm/yyyy', FqryDetalle.FieldByName('FechaRegistro').AsDateTime);

  AjustarCamposPorTipoPersona;
  FqryDetalle.Close;
end;

procedure TfrmContribuyentes.LimpiarFormulario;
begin
  cmbTipoPersona.ItemIndex := 0;
  edtRIF.Clear;
  edtCedula.Clear;
  edtNombre.Clear;
  edtApellido.Clear;
  edtRazonSocial.Clear;
  edtTelefono.Clear;
  edtCelular.Clear;
  edtEmail.Clear;
  memDireccion.Clear;
  cmbEstado.ItemIndex := -1;
  cmbMunicipio.ItemIndex := -1;
  cmbParroquia.ItemIndex := -1;
  edtCodigoPostal.Clear;
  chkActivo.Checked := True;
  edtFechaRegistro.Text := FormatDateTime('dd/mm/yyyy', Now);
  FContribuyenteID := 0;

  AjustarCamposPorTipoPersona;
end;

procedure TfrmContribuyentes.MostrarDetalle(Mostrar: Boolean);
begin
  pnlListado.Visible := not Mostrar;
  pnlDetalle.Visible := Mostrar;
  pnlBotonesListado.Visible := not Mostrar;
  pnlBotonesDetalle.Visible := Mostrar;

  if Mostrar then
    edtRIF.SetFocus
  else
    edtBuscar.SetFocus;
end;

procedure TfrmContribuyentes.HabilitarEdicion(Habilitar: Boolean);
var
  I: Integer;
  Comp: TComponent;
begin
  for I := 0 to ComponentCount - 1 do
  begin
    Comp := Components[I];
    if (Comp is TEdit) and (Comp <> edtBuscar) and (Comp <> edtFechaRegistro) then
      TEdit(Comp).ReadOnly := not Habilitar
    else if (Comp is TComboBox) and (Comp <> cmbFiltroBusqueda) then
      TComboBox(Comp).Enabled := Habilitar
    else if (Comp is TMemo) then
      TMemo(Comp).ReadOnly := not Habilitar
    else if (Comp is TCheckBox) then
      TCheckBox(Comp).Enabled := Habilitar;
  end;

  btnGuardar.Visible := Habilitar;
  btnEditar.Visible := not Habilitar and (FModo = mcConsultar);
  btnEliminar.Visible := not Habilitar and (FModo = mcConsultar);
end;

procedure TfrmContribuyentes.AjustarCamposPorTipoPersona;
var
  EsJuridica: Boolean;
begin
  EsJuridica := (cmbTipoPersona.Text = 'JURIDICA');

  // Mostrar/ocultar campos según tipo
  lblNombre.Visible := not EsJuridica;
  edtNombre.Visible := not EsJuridica;
  lblApellido.Visible := not EsJuridica;
  edtApellido.Visible := not EsJuridica;
  lblCedula.Visible := not EsJuridica;
  edtCedula.Visible := not EsJuridica;

  lblRazonSocial.Visible := EsJuridica;
  edtRazonSocial.Visible := EsJuridica;
end;

function TfrmContribuyentes.ValidarDatos: Boolean;
begin
  Result := False;

  if Trim(edtRIF.Text) = '' then
  begin
    ShowMessage('El RIF es requerido');
    edtRIF.SetFocus;
    Exit;
  end;

  if cmbTipoPersona.Text = 'NATURAL' then
  begin
    if Trim(edtNombre.Text) = '' then
    begin
      ShowMessage('El nombre es requerido');
      edtNombre.SetFocus;
      Exit;
    end;
    if Trim(edtApellido.Text) = '' then
    begin
      ShowMessage('El apellido es requerido');
      edtApellido.SetFocus;
      Exit;
    end;
  end
  else
  begin
    if Trim(edtRazonSocial.Text) = '' then
    begin
      ShowMessage('La razón social es requerida');
      edtRazonSocial.SetFocus;
      Exit;
    end;
  end;

  Result := True;
end;

function TfrmContribuyentes.GuardarContribuyente: Boolean;
begin
  Result := False;

  if not ValidarDatos then
    Exit;

  try
    dmMain.ConnectionPG.StartTransaction;
    try
      if FModo = mcNuevo then
      begin
        FqryDetalle.SQL.Text :=
          'INSERT INTO Contribuyentes (RIF, Cedula, TipoPersona, Nombre, Apellido, RazonSocial, ' +
          'Telefono, Celular, Email, Direccion, Estado, Municipio, Parroquia, CodigoPostal, ' +
          'Activo, UsuarioCreacion) ' +
          'VALUES (:RIF, :Cedula, :TipoPersona, :Nombre, :Apellido, :RazonSocial, ' +
          ':Telefono, :Celular, :Email, :Direccion, :Estado, :Municipio, :Parroquia, :CodigoPostal, ' +
          ':Activo, :UsuarioCreacion) ' +
          'RETURNING ContribuyenteID';
      end
      else
      begin
        FqryDetalle.SQL.Text :=
          'UPDATE Contribuyentes SET ' +
          'RIF = :RIF, Cedula = :Cedula, TipoPersona = :TipoPersona, ' +
          'Nombre = :Nombre, Apellido = :Apellido, RazonSocial = :RazonSocial, ' +
          'Telefono = :Telefono, Celular = :Celular, Email = :Email, ' +
          'Direccion = :Direccion, Estado = :Estado, Municipio = :Municipio, ' +
          'Parroquia = :Parroquia, CodigoPostal = :CodigoPostal, ' +
          'Activo = :Activo, UsuarioModificacion = :UsuarioModificacion, ' +
          'FechaModificacion = CURRENT_TIMESTAMP ' +
          'WHERE ContribuyenteID = :ContribuyenteID';
        FqryDetalle.ParamByName('ContribuyenteID').AsInteger := FContribuyenteID;
        FqryDetalle.ParamByName('UsuarioModificacion').AsInteger := dmMain.UsuarioActual.UsuarioID;
      end;

      FqryDetalle.ParamByName('RIF').AsString := Trim(edtRIF.Text);
      FqryDetalle.ParamByName('Cedula').AsString := Trim(edtCedula.Text);
      FqryDetalle.ParamByName('TipoPersona').AsString := cmbTipoPersona.Text;
      FqryDetalle.ParamByName('Nombre').AsString := Trim(edtNombre.Text);
      FqryDetalle.ParamByName('Apellido').AsString := Trim(edtApellido.Text);
      FqryDetalle.ParamByName('RazonSocial').AsString := Trim(edtRazonSocial.Text);
      FqryDetalle.ParamByName('Telefono').AsString := Trim(edtTelefono.Text);
      FqryDetalle.ParamByName('Celular').AsString := Trim(edtCelular.Text);
      FqryDetalle.ParamByName('Email').AsString := Trim(edtEmail.Text);
      FqryDetalle.ParamByName('Direccion').AsString := Trim(memDireccion.Text);
      FqryDetalle.ParamByName('Estado').AsString := cmbEstado.Text;
      FqryDetalle.ParamByName('Municipio').AsString := cmbMunicipio.Text;
      FqryDetalle.ParamByName('Parroquia').AsString := cmbParroquia.Text;
      FqryDetalle.ParamByName('CodigoPostal').AsString := Trim(edtCodigoPostal.Text);
      FqryDetalle.ParamByName('Activo').AsBoolean := chkActivo.Checked;

      if FModo = mcNuevo then
      begin
        FqryDetalle.ParamByName('UsuarioCreacion').AsInteger := dmMain.UsuarioActual.UsuarioID;
        FqryDetalle.Open;
        FContribuyenteID := FqryDetalle.FieldByName('ContribuyenteID').AsInteger;
        FqryDetalle.Close;
      end
      else
        FqryDetalle.ExecSQL;

      dmMain.ConnectionPG.Commit;

      // Registrar en bitácora
      if FModo = mcNuevo then
        dmMain.RegistrarBitacora('CREAR', 'CATASTRO', 'Contribuyentes', FContribuyenteID, '', '', 'EXITO')
      else
        dmMain.RegistrarBitacora('ACTUALIZAR', 'CATASTRO', 'Contribuyentes', FContribuyenteID, '', '', 'EXITO');

      Result := True;
    except
      on E: Exception do
      begin
        dmMain.ConnectionPG.Rollback;
        ShowMessage('Error al guardar: ' + E.Message);
        dmMain.RegistrarBitacora('GUARDAR', 'CATASTRO', 'Contribuyentes', FContribuyenteID, '', '', 'ERROR', E.Message);
      end;
    end;
  except
    on E: Exception do
      ShowMessage('Error de transacción: ' + E.Message);
  end;
end;

procedure TfrmContribuyentes.btnBuscarClick(Sender: TObject);
begin
  CargarListado;
end;

procedure TfrmContribuyentes.edtBuscarKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnBuscarClick(nil);
  end;
end;

procedure TfrmContribuyentes.btnNuevoClick(Sender: TObject);
begin
  FModo := mcNuevo;
  LimpiarFormulario;
  MostrarDetalle(True);
  HabilitarEdicion(True);
end;

procedure TfrmContribuyentes.gridContribuyentesDblClick(Sender: TObject);
begin
  if not FqryContribuyentes.IsEmpty then
  begin
    FModo := mcConsultar;
    CargarContribuyente(FqryContribuyentes.FieldByName('ContribuyenteID').AsInteger);
    MostrarDetalle(True);
    HabilitarEdicion(False);
  end;
end;

procedure TfrmContribuyentes.btnEditarClick(Sender: TObject);
begin
  FModo := mcEditar;
  HabilitarEdicion(True);
end;

procedure TfrmContribuyentes.btnGuardarClick(Sender: TObject);
begin
  if GuardarContribuyente then
  begin
    ShowMessage('Contribuyente guardado correctamente');
    MostrarDetalle(False);
    CargarListado;
  end;
end;

procedure TfrmContribuyentes.btnCancelarClick(Sender: TObject);
begin
  MostrarDetalle(False);
end;

procedure TfrmContribuyentes.btnEliminarClick(Sender: TObject);
begin
  if MessageDlg('¿Está seguro que desea eliminar este contribuyente?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      FqryDetalle.SQL.Text := 'UPDATE Contribuyentes SET Activo = FALSE WHERE ContribuyenteID = :ID';
      FqryDetalle.ParamByName('ID').AsInteger := FContribuyenteID;
      FqryDetalle.ExecSQL;

      dmMain.RegistrarBitacora('ELIMINAR', 'CATASTRO', 'Contribuyentes', FContribuyenteID, '', '', 'EXITO');

      ShowMessage('Contribuyente desactivado');
      MostrarDetalle(False);
      CargarListado;
    except
      on E: Exception do
        ShowMessage('Error al eliminar: ' + E.Message);
    end;
  end;
end;

procedure TfrmContribuyentes.cmbTipoPersonaChange(Sender: TObject);
begin
  AjustarCamposPorTipoPersona;
end;

procedure TfrmContribuyentes.cmbEstadoChange(Sender: TObject);
var
  EstadoID: Integer;
begin
  // Cargar municipios del estado seleccionado
  if cmbEstado.ItemIndex > 0 then
  begin
    EstadoID := Integer(cmbEstado.Items.Objects[cmbEstado.ItemIndex]);
    CargarMunicipios(EstadoID);
  end
  else
  begin
    cmbMunicipio.Items.Clear;
    cmbMunicipio.Items.AddObject('(Seleccione)', TObject(0));
    cmbMunicipio.ItemIndex := 0;
    cmbParroquia.Items.Clear;
    cmbParroquia.Items.AddObject('(Seleccione)', TObject(0));
    cmbParroquia.ItemIndex := 0;
  end;
end;

procedure TfrmContribuyentes.cmbMunicipioChange(Sender: TObject);
var
  MunicipioID: Integer;
begin
  // Cargar parroquias del municipio seleccionado
  if cmbMunicipio.ItemIndex > 0 then
  begin
    MunicipioID := Integer(cmbMunicipio.Items.Objects[cmbMunicipio.ItemIndex]);
    CargarParroquias(MunicipioID);
  end
  else
  begin
    cmbParroquia.Items.Clear;
    cmbParroquia.Items.AddObject('(Seleccione)', TObject(0));
    cmbParroquia.ItemIndex := 0;
  end;
end;

procedure TfrmContribuyentes.cmbParroquiaChange(Sender: TObject);
var
  ParroquiaID: Integer;
begin
  // Cargar ciudades de la parroquia seleccionada
  if cmbParroquia.ItemIndex > 0 then
  begin
    ParroquiaID := Integer(cmbParroquia.Items.Objects[cmbParroquia.ItemIndex]);
    CargarCiudades(ParroquiaID);
  end
  else
  begin
    cmbCiudad.Items.Clear;
    cmbCiudad.Items.AddObject('(Seleccione)', TObject(0));
    cmbCiudad.ItemIndex := 0;
    cmbSector.Items.Clear;
    cmbSector.Items.AddObject('(Seleccione)', TObject(0));
    cmbSector.ItemIndex := 0;
  end;
end;

procedure TfrmContribuyentes.cmbCiudadChange(Sender: TObject);
var
  CiudadID: Integer;
begin
  // Cargar sectores de la ciudad seleccionada
  if cmbCiudad.ItemIndex > 0 then
  begin
    CiudadID := Integer(cmbCiudad.Items.Objects[cmbCiudad.ItemIndex]);
    CargarSectores(CiudadID);
  end
  else
  begin
    cmbSector.Items.Clear;
    cmbSector.Items.AddObject('(Seleccione)', TObject(0));
    cmbSector.ItemIndex := 0;
  end;
end;

procedure TfrmContribuyentes.btnVerFichasClick(Sender: TObject);
begin
  if not FqryContribuyentes.IsEmpty then
    ShowMessage('Ver fichas del contribuyente - Por implementar')
  else
    ShowMessage('Seleccione un contribuyente');
end;

procedure TfrmContribuyentes.btnVerSolicitudesClick(Sender: TObject);
var
  Frm: TfrmSolicitudes;
begin
  if not FqryContribuyentes.IsEmpty then
  begin
    Frm := TfrmSolicitudes.Create(Application);
    try
      Frm.NuevaSolicitudParaContribuyente(FqryContribuyentes.FieldByName('ContribuyenteID').AsInteger);
      Frm.ShowModal;
    finally
      Frm.Free;
    end;
  end
  else
    ShowMessage('Seleccione un contribuyente');
end;

procedure TfrmContribuyentes.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

function TfrmContribuyentes.SeleccionarContribuyente: Integer;
begin
  Result := 0;
  if ShowModal = mrOk then
  begin
    if not FqryContribuyentes.IsEmpty then
      Result := FqryContribuyentes.FieldByName('ContribuyenteID').AsInteger;
  end;
end;

end.
