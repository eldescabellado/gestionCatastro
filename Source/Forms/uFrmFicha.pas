unit uFrmFicha;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.StrUtils, System.IOUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Buttons, Vcl.Mask, Vcl.ExtDlgs, Vcl.OleCtrls, SHDocVw,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  uCalculoCatastral;

type
  TModoFormulario = (mfNuevo, mfEditar, mfConsultar);

  TfrmFicha = class(TForm)
    // PageControl principal
    PageControl: TPageControl;

    // ===== Pestaña: Datos del Predio =====
    tabPredio: TTabSheet;

    // Grupo: Identificación
    gbIdentificacion: TGroupBox;
    lblCodigoCatastral: TLabel;
    edtCodigoCatastral: TEdit;
    lblContribuyente: TLabel;
    cmbContribuyente: TComboBox;
    btnBuscarContrib: TBitBtn;

    // Grupo: Ubicación
    gbUbicacion: TGroupBox;
    lblEstado: TLabel;
    cmbEstado: TComboBox;
    lblMunicipio: TLabel;
    cmbMunicipio: TComboBox;
    lblParroquia: TLabel;
    cmbParroquia: TComboBox;
    lblSector: TLabel;
    edtSector: TEdit;
    lblUrbanizacion: TLabel;
    edtUrbanizacion: TEdit;
    lblCalle: TLabel;
    edtCalle: TEdit;
    lblNumeroCasa: TLabel;
    edtNumeroCasa: TEdit;
    lblManzana: TLabel;
    edtManzana: TEdit;
    lblParcela: TLabel;
    edtParcela: TEdit;

    // Grupo: Geolocalización
    gbGeolocalizacion: TGroupBox;
    lblLatitud: TLabel;
    edtLatitud: TEdit;
    lblLongitud: TLabel;
    edtLongitud: TEdit;
    btnGeolocalizacion: TBitBtn;
    edtDireccionGeo: TEdit;
    lblDireccionGeo: TLabel;

    // Grupo: Linderos
    gbLinderos: TGroupBox;
    lblLinderoNorte: TLabel;
    edtLinderoNorte: TEdit;
    lblLinderoSur: TLabel;
    edtLinderoSur: TEdit;
    lblLinderoEste: TLabel;
    edtLinderoEste: TEdit;
    lblLinderoOeste: TLabel;
    edtLinderoOeste: TEdit;

    // ===== Pestaña: Terreno =====
    tabTerreno: TTabSheet;

    // Grupo: Dimensiones
    gbDimensiones: TGroupBox;
    lblAreaTerreno: TLabel;
    edtAreaTerreno: TEdit;
    lblFachada: TLabel;
    edtFachada: TEdit;
    lblFondo: TLabel;
    edtFondo: TEdit;

    // Grupo: Clasificación
    gbClasificacion: TGroupBox;
    lblUsoTerreno: TLabel;
    cmbUsoTerreno: TComboBox;
    lblClasificacionZona: TLabel;
    cmbClasificacionZona: TComboBox;
    lblTopografia: TLabel;
    cmbTopografia: TComboBox;
    lblFormaTerreno: TLabel;
    cmbFormaTerreno: TComboBox;

    // Grupo: Servicios
    gbServicios: TGroupBox;
    chkAgua: TCheckBox;
    chkElectricidad: TCheckBox;
    chkCloacas: TCheckBox;
    chkAseo: TCheckBox;
    chkGas: TCheckBox;
    chkTelefono: TCheckBox;
    chkInternet: TCheckBox;
    chkAceras: TCheckBox;
    chkAlumbrado: TCheckBox;
    chkAsfalto: TCheckBox;

    // ===== Pestaña: Construcción =====
    tabConstruccion: TTabSheet;

    // Grupo: Características
    gbCaracteristicas: TGroupBox;
    lblAreaConstruccion: TLabel;
    edtAreaConstruccion: TEdit;
    lblTipoConstruccion: TLabel;
    cmbTipoConstruccion: TComboBox;
    lblEstadoConstruccion: TLabel;
    cmbEstadoConstruccion: TComboBox;
    lblAnioConstruccion: TLabel;
    edtAnioConstruccion: TEdit;
    lblNumeroPlantas: TLabel;
    edtNumeroPlantas: TEdit;
    lblNumeroHabitaciones: TLabel;
    edtNumeroHabitaciones: TEdit;
    lblNumeroBanos: TLabel;
    edtNumeroBanos: TEdit;
    lblNumeroEstacionamientos: TLabel;
    edtNumeroEstacionamientos: TEdit;

    // Grupo: Materiales
    gbMateriales: TGroupBox;
    lblMaterialEstructura: TLabel;
    cmbMaterialEstructura: TComboBox;
    lblMaterialParedes: TLabel;
    cmbMaterialParedes: TComboBox;
    lblMaterialTecho: TLabel;
    cmbMaterialTecho: TComboBox;
    lblMaterialPiso: TLabel;
    cmbMaterialPiso: TComboBox;
    lblCalidadAcabados: TLabel;
    cmbCalidadAcabados: TComboBox;

    // ===== Pestaña: Datos Legales =====
    tabLegal: TTabSheet;
    gbDocumentos: TGroupBox;
    lblNumeroDocumento: TLabel;
    edtNumeroDocumento: TEdit;
    lblFechaDocumento: TLabel;
    dtpFechaDocumento: TDateTimePicker;
    lblNotaria: TLabel;
    edtNotaria: TEdit;
    lblTomo: TLabel;
    edtTomo: TEdit;
    lblFolio: TLabel;
    edtFolio: TEdit;
    lblProtocolo: TLabel;
    edtProtocolo: TEdit;

    // ===== Pestaña: Avalúo =====
    tabAvaluo: TTabSheet;

    // Grupo: Cálculo
    gbCalculoAvaluo: TGroupBox;
    btnCalcular: TBitBtn;
    lblValorTerrenoBase: TLabel;
    edtValorTerrenoBase: TEdit;
    lblValorConstruccionBase: TLabel;
    edtValorConstruccionBase: TEdit;
    lblCoefZona: TLabel;
    edtCoefZona: TEdit;
    lblCoefUso: TLabel;
    edtCoefUso: TEdit;
    lblCoefEstado: TLabel;
    edtCoefEstado: TEdit;
    lblCoefServicios: TLabel;
    edtCoefServicios: TEdit;
    lblCoefDepreciacion: TLabel;
    edtCoefDepreciacion: TEdit;
    lblValorTerreno: TLabel;
    edtValorTerreno: TEdit;
    lblValorConstruccion: TLabel;
    edtValorConstruccion: TEdit;
    lblValorTotal: TLabel;
    edtValorTotal: TEdit;

    // Grupo: Impuesto
    gbImpuesto: TGroupBox;
    lblBaseImponible: TLabel;
    edtBaseImponible: TEdit;
    lblAlicuota: TLabel;
    edtAlicuota: TEdit;
    lblMontoImpuesto: TLabel;
    edtMontoImpuesto: TEdit;

    // Grupo: Exoneración
    gbExoneracion: TGroupBox;
    chkExoneracion: TCheckBox;
    lblTipoExoneracion: TLabel;
    cmbTipoExoneracion: TComboBox;
    lblPorcentajeExon: TLabel;
    edtPorcentajeExon: TEdit;
    lblMontoConExon: TLabel;
    edtMontoConExon: TEdit;

    // Detalle de Cálculo
    memoDetalle: TMemo;

    // ===== Pestaña: Fotografías =====
    tabFotos: TTabSheet;
    gbFotos: TGroupBox;
    imgPrincipal: TImage;
    imgFachada: TImage;
    imgInterior: TImage;
    btnCargarFotoPrincipal: TBitBtn;
    btnCargarFotoFachada: TBitBtn;
    btnCargarFotoInterior: TBitBtn;
    lblFotoPrincipal: TLabel;
    lblFotoFachada: TLabel;
    lblFotoInterior: TLabel;

    // ===== Pestaña: Geolocalización =====
    tabGeolocalizacion: TTabSheet;
    pnlMapaControles: TPanel;
    lblMapaLatitud: TLabel;
    edtMapaLatitud: TEdit;
    lblMapaLongitud: TLabel;
    edtMapaLongitud: TEdit;
    btnIrAPunto: TBitBtn;
    btnLimpiarMapa: TBitBtn;
    lblMapaDireccion: TLabel;
    edtMapaDireccion: TEdit;
    pnlMapa: TPanel;
    WebBrowser: TWebBrowser;

    // Panel de botones
    pnlBotones: TPanel;
    btnGuardar: TBitBtn;
    btnCancelar: TBitBtn;
    btnImprimir: TBitBtn;

    // Diálogo de imágenes
    OpenPictureDialog: TOpenPictureDialog;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCalcularClick(Sender: TObject);
    procedure btnGuardarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnCargarFotoPrincipalClick(Sender: TObject);
    procedure btnCargarFotoFachadaClick(Sender: TObject);
    procedure btnCargarFotoInteriorClick(Sender: TObject);
    procedure chkExoneracionClick(Sender: TObject);
    procedure btnBuscarContribClick(Sender: TObject);
    procedure edtAreaTerrenoExit(Sender: TObject);
    procedure edtAreaConstruccionExit(Sender: TObject);
    procedure btnGeolocalizacionClick(Sender: TObject);
    procedure btnIrAPuntoClick(Sender: TObject);
    procedure btnLimpiarMapaClick(Sender: TObject);
    procedure WebBrowserDocumentComplete(ASender: TObject; const pDisp: IDispatch; const URL: OleVariant);
    procedure edtMapaLatitudKeyPress(Sender: TObject; var Key: Char);

  private
    FModo: TModoFormulario;
    FFichaID: Integer;
    FContribuyenteID: Integer;
    FCalculador: TCalculoCatastral;
    FQuery: TFDQuery;

    FRutaFotoPrincipal: string;
    FRutaFotoFachada: string;
    FRutaFotoInterior: string;

    FLatitud: Double;
    FLongitud: Double;
    FMapaCargado: Boolean;
    FHTMLPath: string;

    procedure InicializarCombos;
    procedure CargarMapa;
    procedure CentrarMapa(Lat, Lon: Double; Zoom: Integer = 15);
    procedure ProcesarClickMapa;
    function GenerarHTMLMapa: string;
    procedure LimpiarFormulario;
    procedure CargarFicha(FichaID: Integer);
    function ValidarDatos: Boolean;
    function GuardarFicha: Boolean;
    procedure CalcularAvaluo;
    function ObtenerDatosFicha: TDatosFicha;
    procedure MostrarResultadoAvaluo(const Resultado: TResultadoAvaluo);
    procedure CargarFoto(const Ruta: string; Imagen: TImage);
    procedure HabilitarEdicion(Habilitar: Boolean);

  public
    procedure NuevaFicha(ContribuyenteID: Integer = 0);
    procedure EditarFicha(FichaID: Integer);
    procedure ConsultarFicha(FichaID: Integer);
    property FichaID: Integer read FFichaID;
  end;

var
  frmFicha: TfrmFicha;

implementation

{$R *.dfm}

uses
  uDmMain, uAuthManager, ActiveX, MSHTML;

{ TfrmFicha }

procedure TfrmFicha.FormCreate(Sender: TObject);
begin
  FQuery := TFDQuery.Create(Self);
  FQuery.Connection := dmMain.ConnectionPG;

  FCalculador := TCalculoCatastral.Create(dmMain.ConnectionPG, dmMain.ConnectionSQLite);

  FFichaID := 0;
  FContribuyenteID := 0;
  FMapaCargado := False;
  FHTMLPath := TPath.Combine(TPath.GetTempPath, 'sigiep_mapa_ficha.html');

  // Valores por defecto para coordenadas (Venezuela - centro)
  edtMapaLatitud.Text := '8.0000';
  edtMapaLongitud.Text := '-66.0000';

  InicializarCombos;
end;

procedure TfrmFicha.FormDestroy(Sender: TObject);
begin
  // Limpiar archivo temporal del mapa
  if TFile.Exists(FHTMLPath) then
    TFile.Delete(FHTMLPath);

  FCalculador.Free;
  FQuery.Free;
end;

procedure TfrmFicha.FormShow(Sender: TObject);
begin
  PageControl.ActivePageIndex := 0;

  // Cargar variables de cálculo si no están cargadas
  if not FCalculador.VariablesCargadas then
    FCalculador.CargarVariables;

  // Cargar el mapa de geolocalización
  CargarMapa;
end;

procedure TfrmFicha.InicializarCombos;
begin
  // Uso del Terreno
  cmbUsoTerreno.Items.Clear;
  cmbUsoTerreno.Items.Add('RESIDENCIAL');
  cmbUsoTerreno.Items.Add('COMERCIAL');
  cmbUsoTerreno.Items.Add('INDUSTRIAL');
  cmbUsoTerreno.Items.Add('AGRICOLA');
  cmbUsoTerreno.Items.Add('MIXTO');
  cmbUsoTerreno.Items.Add('BALDIO');
  cmbUsoTerreno.Items.Add('INSTITUCIONAL');

  // Topografía
  cmbTopografia.Items.Clear;
  cmbTopografia.Items.Add('PLANO');
  cmbTopografia.Items.Add('PENDIENTE_SUAVE');
  cmbTopografia.Items.Add('PENDIENTE_MEDIA');
  cmbTopografia.Items.Add('PENDIENTE_FUERTE');
  cmbTopografia.Items.Add('IRREGULAR');

  // Forma del Terreno
  cmbFormaTerreno.Items.Clear;
  cmbFormaTerreno.Items.Add('REGULAR');
  cmbFormaTerreno.Items.Add('IRREGULAR');
  cmbFormaTerreno.Items.Add('ESQUINERO');

  // Tipo de Construcción
  cmbTipoConstruccion.Items.Clear;
  cmbTipoConstruccion.Items.Add('CASA');
  cmbTipoConstruccion.Items.Add('APARTAMENTO');
  cmbTipoConstruccion.Items.Add('TOWNHOUSE');
  cmbTipoConstruccion.Items.Add('LOCAL_COMERCIAL');
  cmbTipoConstruccion.Items.Add('GALPON');
  cmbTipoConstruccion.Items.Add('EDIFICIO');
  cmbTipoConstruccion.Items.Add('OTRO');
  cmbTipoConstruccion.Items.Add('SIN_CONSTRUCCION');

  // Estado de Construcción
  cmbEstadoConstruccion.Items.Clear;
  cmbEstadoConstruccion.Items.Add('NUEVA');
  cmbEstadoConstruccion.Items.Add('BUENA');
  cmbEstadoConstruccion.Items.Add('REGULAR');
  cmbEstadoConstruccion.Items.Add('MALA');
  cmbEstadoConstruccion.Items.Add('EN_CONSTRUCCION');
  cmbEstadoConstruccion.Items.Add('RUINAS');

  // Materiales de Estructura
  cmbMaterialEstructura.Items.Clear;
  cmbMaterialEstructura.Items.Add('Concreto Armado');
  cmbMaterialEstructura.Items.Add('Acero');
  cmbMaterialEstructura.Items.Add('Madera');
  cmbMaterialEstructura.Items.Add('Mixto');

  // Materiales de Paredes
  cmbMaterialParedes.Items.Clear;
  cmbMaterialParedes.Items.Add('Bloque');
  cmbMaterialParedes.Items.Add('Ladrillo');
  cmbMaterialParedes.Items.Add('Adobe');
  cmbMaterialParedes.Items.Add('Bahareque');
  cmbMaterialParedes.Items.Add('Drywall');

  // Materiales de Techo
  cmbMaterialTecho.Items.Clear;
  cmbMaterialTecho.Items.Add('Platabanda');
  cmbMaterialTecho.Items.Add('Tejas');
  cmbMaterialTecho.Items.Add('Zinc');
  cmbMaterialTecho.Items.Add('Acerolit');
  cmbMaterialTecho.Items.Add('Machimbre');

  // Materiales de Piso
  cmbMaterialPiso.Items.Clear;
  cmbMaterialPiso.Items.Add('Cerámica');
  cmbMaterialPiso.Items.Add('Granito');
  cmbMaterialPiso.Items.Add('Porcelanato');
  cmbMaterialPiso.Items.Add('Mármol');
  cmbMaterialPiso.Items.Add('Cemento');
  cmbMaterialPiso.Items.Add('Tierra');

  // Calidad de Acabados
  cmbCalidadAcabados.Items.Clear;
  cmbCalidadAcabados.Items.Add('1 - Económico');
  cmbCalidadAcabados.Items.Add('2 - Tercera');
  cmbCalidadAcabados.Items.Add('3 - Segunda');
  cmbCalidadAcabados.Items.Add('4 - Primera');
  cmbCalidadAcabados.Items.Add('5 - Lujo');

  // Tipo de Exoneración
  cmbTipoExoneracion.Items.Clear;
  cmbTipoExoneracion.Items.Add('Vivienda Principal');
  cmbTipoExoneracion.Items.Add('Tercera Edad');
  cmbTipoExoneracion.Items.Add('Discapacidad');
  cmbTipoExoneracion.Items.Add('Institución Sin Fines de Lucro');
  cmbTipoExoneracion.Items.Add('Gobierno');
end;

procedure TfrmFicha.LimpiarFormulario;
var
  I: Integer;
  Comp: TComponent;
begin
  // Limpiar todos los edits
  for I := 0 to ComponentCount - 1 do
  begin
    Comp := Components[I];
    if Comp is TEdit then
      TEdit(Comp).Clear
    else if Comp is TComboBox then
      TComboBox(Comp).ItemIndex := -1
    else if Comp is TCheckBox then
      TCheckBox(Comp).Checked := False
    else if Comp is TMemo then
      TMemo(Comp).Clear;
  end;

  // Limpiar imágenes
  imgPrincipal.Picture.Assign(nil);
  imgFachada.Picture.Assign(nil);
  imgInterior.Picture.Assign(nil);

  FRutaFotoPrincipal := '';
  FRutaFotoFachada := '';
  FRutaFotoInterior := '';

  FLatitud := 0;
  FLongitud := 0;

  FFichaID := 0;
  FContribuyenteID := 0;
end;

procedure TfrmFicha.NuevaFicha(ContribuyenteID: Integer);
begin
  FModo := mfNuevo;
  FFichaID := 0;
  FContribuyenteID := ContribuyenteID;

  LimpiarFormulario;
  HabilitarEdicion(True);

  Caption := 'Nueva Ficha Catastral';
  btnGuardar.Caption := 'Guardar';
end;

procedure TfrmFicha.EditarFicha(FichaID: Integer);
begin
  FModo := mfEditar;
  FFichaID := FichaID;

  CargarFicha(FichaID);
  HabilitarEdicion(True);

  Caption := 'Editar Ficha Catastral - ' + edtCodigoCatastral.Text;
  btnGuardar.Caption := 'Actualizar';
end;

procedure TfrmFicha.ConsultarFicha(FichaID: Integer);
begin
  FModo := mfConsultar;
  FFichaID := FichaID;

  CargarFicha(FichaID);
  HabilitarEdicion(False);

  Caption := 'Consultar Ficha Catastral - ' + edtCodigoCatastral.Text;
  btnGuardar.Visible := False;
end;

procedure TfrmFicha.HabilitarEdicion(Habilitar: Boolean);
var
  I: Integer;
  Comp: TComponent;
begin
  for I := 0 to ComponentCount - 1 do
  begin
    Comp := Components[I];
    if Comp is TEdit then
      TEdit(Comp).ReadOnly := not Habilitar
    else if Comp is TComboBox then
      TComboBox(Comp).Enabled := Habilitar
    else if Comp is TCheckBox then
      TCheckBox(Comp).Enabled := Habilitar
    else if Comp is TBitBtn then
    begin
      if (Comp <> btnCancelar) and (Comp <> btnImprimir) then
        TBitBtn(Comp).Enabled := Habilitar;
    end;
  end;

  btnGuardar.Visible := Habilitar;
end;

procedure TfrmFicha.CargarFicha(FichaID: Integer);
begin
  FQuery.SQL.Text := 'SELECT * FROM FichaCatastral WHERE FichaID = :ID';
  FQuery.ParamByName('ID').AsInteger := FichaID;
  FQuery.Open;

  if FQuery.IsEmpty then
  begin
    ShowMessage('Ficha no encontrada');
    Exit;
  end;

  // Cargar datos del predio
  edtCodigoCatastral.Text := FQuery.FieldByName('CodigoCatastral').AsString;
  FContribuyenteID := FQuery.FieldByName('ContribuyenteID').AsInteger;
  cmbEstado.Text := FQuery.FieldByName('Estado').AsString;
  cmbMunicipio.Text := FQuery.FieldByName('Municipio').AsString;
  cmbParroquia.Text := FQuery.FieldByName('Parroquia').AsString;
  edtSector.Text := FQuery.FieldByName('Sector').AsString;
  edtUrbanizacion.Text := FQuery.FieldByName('Urbanizacion').AsString;
  edtCalle.Text := FQuery.FieldByName('Calle').AsString;
  edtNumeroCasa.Text := FQuery.FieldByName('NumeroCasa').AsString;
  edtManzana.Text := FQuery.FieldByName('Manzana').AsString;
  edtParcela.Text := FQuery.FieldByName('Parcela').AsString;

  // Linderos
  edtLinderoNorte.Text := FQuery.FieldByName('LinderoNorte').AsString;
  edtLinderoSur.Text := FQuery.FieldByName('LinderoSur').AsString;
  edtLinderoEste.Text := FQuery.FieldByName('LinderoEste').AsString;
  edtLinderoOeste.Text := FQuery.FieldByName('LinderoOeste').AsString;

  // Terreno
  edtAreaTerreno.Text := FormatFloat('0.00', FQuery.FieldByName('AreaTerreno').AsFloat);
  edtFachada.Text := FormatFloat('0.00', FQuery.FieldByName('Fachada').AsFloat);
  edtFondo.Text := FormatFloat('0.00', FQuery.FieldByName('Fondo').AsFloat);
  cmbUsoTerreno.Text := FQuery.FieldByName('UsoTerreno').AsString;
  cmbClasificacionZona.Text := FQuery.FieldByName('ClasificacionZona').AsString;
  cmbTopografia.Text := FQuery.FieldByName('TopografiaTerreno').AsString;
  cmbFormaTerreno.Text := FQuery.FieldByName('FormaTerreno').AsString;

  // Servicios
  chkAgua.Checked := FQuery.FieldByName('TieneAgua').AsBoolean;
  chkElectricidad.Checked := FQuery.FieldByName('TieneElectricidad').AsBoolean;
  chkCloacas.Checked := FQuery.FieldByName('TieneCloacas').AsBoolean;
  chkAseo.Checked := FQuery.FieldByName('TieneAseo').AsBoolean;
  chkGas.Checked := FQuery.FieldByName('TieneGas').AsBoolean;
  chkAceras.Checked := FQuery.FieldByName('TieneAceras').AsBoolean;
  chkAlumbrado.Checked := FQuery.FieldByName('TieneAlumbrado').AsBoolean;
  chkAsfalto.Checked := FQuery.FieldByName('TieneAsfalto').AsBoolean;

  // Construcción
  edtAreaConstruccion.Text := FormatFloat('0.00', FQuery.FieldByName('AreaConstruccion').AsFloat);
  cmbTipoConstruccion.Text := FQuery.FieldByName('TipoConstruccion').AsString;
  cmbEstadoConstruccion.Text := FQuery.FieldByName('EstadoConstruccion').AsString;
  edtAnioConstruccion.Text := FQuery.FieldByName('AnioConstruccion').AsString;
  edtNumeroPlantas.Text := FQuery.FieldByName('NumeroPlantas').AsString;
  edtNumeroHabitaciones.Text := FQuery.FieldByName('NumeroHabitaciones').AsString;
  edtNumeroBanos.Text := FQuery.FieldByName('NumeroBanos').AsString;
  edtNumeroEstacionamientos.Text := FQuery.FieldByName('NumeroEstacionamientos').AsString;

  // Materiales
  cmbMaterialEstructura.Text := FQuery.FieldByName('MaterialEstructura').AsString;
  cmbMaterialParedes.Text := FQuery.FieldByName('MaterialParedes').AsString;
  cmbMaterialTecho.Text := FQuery.FieldByName('MaterialTecho').AsString;
  cmbMaterialPiso.Text := FQuery.FieldByName('MaterialPiso').AsString;
  cmbCalidadAcabados.ItemIndex := FQuery.FieldByName('CalidadAcabados').AsInteger - 1;

  // Valores
  edtValorTerrenoBase.Text := FormatFloat('#,##0.00', FQuery.FieldByName('ValorTerrenoBase').AsFloat);
  edtValorConstruccionBase.Text := FormatFloat('#,##0.00', FQuery.FieldByName('ValorConstruccionBase').AsFloat);
  edtCoefZona.Text := FormatFloat('0.0000', FQuery.FieldByName('CoeficienteZona').AsFloat);
  edtCoefUso.Text := FormatFloat('0.0000', FQuery.FieldByName('CoeficienteUso').AsFloat);
  edtCoefEstado.Text := FormatFloat('0.0000', FQuery.FieldByName('CoeficienteEstado').AsFloat);
  edtCoefServicios.Text := FormatFloat('0.0000', FQuery.FieldByName('CoeficienteServicios').AsFloat);
  edtCoefDepreciacion.Text := FormatFloat('0.0000', FQuery.FieldByName('CoeficienteDepreciacion').AsFloat);
  edtValorTerreno.Text := FormatFloat('#,##0.00', FQuery.FieldByName('ValorTerreno').AsFloat);
  edtValorConstruccion.Text := FormatFloat('#,##0.00', FQuery.FieldByName('ValorConstruccion').AsFloat);
  edtValorTotal.Text := FormatFloat('#,##0.00', FQuery.FieldByName('ValorTotal').AsFloat);
  edtBaseImponible.Text := FormatFloat('#,##0.00', FQuery.FieldByName('BaseImponible').AsFloat);
  edtAlicuota.Text := FormatFloat('0.0000', FQuery.FieldByName('Alicuota').AsFloat);
  edtMontoImpuesto.Text := FormatFloat('#,##0.00', FQuery.FieldByName('MontoImpuestoAnual').AsFloat);

  // Exoneración
  chkExoneracion.Checked := FQuery.FieldByName('TieneExoneracion').AsBoolean;
  cmbTipoExoneracion.Text := FQuery.FieldByName('TipoExoneracion').AsString;
  edtPorcentajeExon.Text := FormatFloat('0.00', FQuery.FieldByName('PorcentajeExoneracion').AsFloat);

  // Fotos
  FRutaFotoPrincipal := FQuery.FieldByName('RutaFotoPrincipal').AsString;
  FRutaFotoFachada := FQuery.FieldByName('RutaFotoFachada').AsString;
  FRutaFotoInterior := FQuery.FieldByName('RutaFotoInterior').AsString;

  CargarFoto(FRutaFotoPrincipal, imgPrincipal);
  CargarFoto(FRutaFotoFachada, imgFachada);
  CargarFoto(FRutaFotoInterior, imgInterior);

  FQuery.Close;
end;

function TfrmFicha.ValidarDatos: Boolean;
begin
  Result := False;

  if Trim(edtCodigoCatastral.Text) = '' then
  begin
    ShowMessage('El código catastral es requerido');
    edtCodigoCatastral.SetFocus;
    Exit;
  end;

  if FContribuyenteID = 0 then
  begin
    ShowMessage('Debe seleccionar un contribuyente');
    Exit;
  end;

  if Trim(edtAreaTerreno.Text) = '' then
  begin
    ShowMessage('El área del terreno es requerida');
    edtAreaTerreno.SetFocus;
    Exit;
  end;

  if cmbUsoTerreno.ItemIndex < 0 then
  begin
    ShowMessage('Debe seleccionar el uso del terreno');
    cmbUsoTerreno.SetFocus;
    Exit;
  end;

  Result := True;
end;

function TfrmFicha.ObtenerDatosFicha: TDatosFicha;
begin
  FillChar(Result, SizeOf(Result), 0);

  Result.FichaID := FFichaID;
  Result.CodigoCatastral := edtCodigoCatastral.Text;
  Result.AreaTerreno := StrToFloatDef(edtAreaTerreno.Text, 0);
  Result.UsoTerreno := cmbUsoTerreno.Text;
  Result.ClasificacionZona := cmbClasificacionZona.Text;
  Result.TopografiaTerreno := cmbTopografia.Text;
  Result.FormaTerreno := cmbFormaTerreno.Text;

  Result.AreaConstruccion := StrToFloatDef(edtAreaConstruccion.Text, 0);
  Result.TipoConstruccion := cmbTipoConstruccion.Text;
  Result.EstadoConstruccion := cmbEstadoConstruccion.Text;
  Result.AnioConstruccion := StrToIntDef(edtAnioConstruccion.Text, 0);
  Result.CalidadAcabados := cmbCalidadAcabados.ItemIndex + 1;

  Result.TieneAgua := chkAgua.Checked;
  Result.TieneElectricidad := chkElectricidad.Checked;
  Result.TieneCloacas := chkCloacas.Checked;
  Result.TieneAseo := chkAseo.Checked;
  Result.TieneGas := chkGas.Checked;
  Result.TieneAceras := chkAceras.Checked;
  Result.TieneAlumbrado := chkAlumbrado.Checked;
  Result.TieneAsfalto := chkAsfalto.Checked;

  Result.TieneExoneracion := chkExoneracion.Checked;
  Result.PorcentajeExoneracion := StrToFloatDef(edtPorcentajeExon.Text, 0);
end;

procedure TfrmFicha.CalcularAvaluo;
var
  Datos: TDatosFicha;
  Resultado: TResultadoAvaluo;
begin
  Datos := ObtenerDatosFicha;
  Resultado := FCalculador.CalcularAvaluo(Datos);
  MostrarResultadoAvaluo(Resultado);
end;

procedure TfrmFicha.MostrarResultadoAvaluo(const Resultado: TResultadoAvaluo);
begin
  edtValorTerrenoBase.Text := FormatFloat('#,##0.00', Resultado.ValorTerrenoBase);
  edtValorConstruccionBase.Text := FormatFloat('#,##0.00', Resultado.ValorConstruccionBase);
  edtCoefZona.Text := FormatFloat('0.0000', Resultado.CoeficienteZona);
  edtCoefUso.Text := FormatFloat('0.0000', Resultado.CoeficienteUso);
  edtCoefEstado.Text := FormatFloat('0.0000', Resultado.CoeficienteEstado);
  edtCoefServicios.Text := FormatFloat('0.0000', Resultado.CoeficienteServicios);
  edtCoefDepreciacion.Text := FormatFloat('0.0000', Resultado.CoeficienteDepreciacion);
  edtValorTerreno.Text := FormatFloat('#,##0.00', Resultado.ValorTerreno);
  edtValorConstruccion.Text := FormatFloat('#,##0.00', Resultado.ValorConstruccion);
  edtValorTotal.Text := FormatFloat('#,##0.00', Resultado.ValorTotal);
  edtBaseImponible.Text := FormatFloat('#,##0.00', Resultado.BaseImponible);
  edtAlicuota.Text := FormatFloat('0.0000', Resultado.Alicuota);
  edtMontoImpuesto.Text := FormatFloat('#,##0.00', Resultado.MontoImpuestoAnual);
  edtMontoConExon.Text := FormatFloat('#,##0.00', Resultado.MontoConExoneracion);

  memoDetalle.Text := Resultado.DetalleCalculo;
end;

procedure TfrmFicha.btnCalcularClick(Sender: TObject);
begin
  CalcularAvaluo;
end;

function TfrmFicha.GuardarFicha: Boolean;
begin
  Result := False;

  if not ValidarDatos then
    Exit;

  try
    dmMain.ConnectionPG.StartTransaction;
    try
      if FModo = mfNuevo then
      begin
        // INSERT
        FQuery.SQL.Text :=
          'INSERT INTO FichaCatastral (CodigoCatastral, ContribuyenteID, Estado, Municipio, ' +
          'Parroquia, Sector, Urbanizacion, Calle, NumeroCasa, Manzana, Parcela, ' +
          'LinderoNorte, LinderoSur, LinderoEste, LinderoOeste, ' +
          'AreaTerreno, Fachada, Fondo, UsoTerreno, ClasificacionZona, TopografiaTerreno, FormaTerreno, ' +
          'TieneAgua, TieneElectricidad, TieneCloacas, TieneAseo, TieneGas, TieneAceras, TieneAlumbrado, TieneAsfalto, ' +
          'AreaConstruccion, TipoConstruccion, EstadoConstruccion, AnioConstruccion, NumeroPlantas, ' +
          'NumeroHabitaciones, NumeroBanos, NumeroEstacionamientos, ' +
          'MaterialEstructura, MaterialParedes, MaterialTecho, MaterialPiso, CalidadAcabados, ' +
          'ValorTerrenoBase, ValorConstruccionBase, CoeficienteZona, CoeficienteUso, CoeficienteEstado, ' +
          'CoeficienteServicios, CoeficienteDepreciacion, ValorTerreno, ValorConstruccion, ValorTotal, ' +
          'BaseImponible, Alicuota, MontoImpuestoAnual, ' +
          'TieneExoneracion, TipoExoneracion, PorcentajeExoneracion, ' +
          'RutaFotoPrincipal, RutaFotoFachada, RutaFotoInterior, ' +
          'UsuarioCreacion, FechaUltimoAvaluo, UsuarioUltimoAvaluo) ' +
          'VALUES (:CodigoCatastral, :ContribuyenteID, :Estado, :Municipio, ' +
          ':Parroquia, :Sector, :Urbanizacion, :Calle, :NumeroCasa, :Manzana, :Parcela, ' +
          ':LinderoNorte, :LinderoSur, :LinderoEste, :LinderoOeste, ' +
          ':AreaTerreno, :Fachada, :Fondo, :UsoTerreno, :ClasificacionZona, :TopografiaTerreno, :FormaTerreno, ' +
          ':TieneAgua, :TieneElectricidad, :TieneCloacas, :TieneAseo, :TieneGas, :TieneAceras, :TieneAlumbrado, :TieneAsfalto, ' +
          ':AreaConstruccion, :TipoConstruccion, :EstadoConstruccion, :AnioConstruccion, :NumeroPlantas, ' +
          ':NumeroHabitaciones, :NumeroBanos, :NumeroEstacionamientos, ' +
          ':MaterialEstructura, :MaterialParedes, :MaterialTecho, :MaterialPiso, :CalidadAcabados, ' +
          ':ValorTerrenoBase, :ValorConstruccionBase, :CoeficienteZona, :CoeficienteUso, :CoeficienteEstado, ' +
          ':CoeficienteServicios, :CoeficienteDepreciacion, :ValorTerreno, :ValorConstruccion, :ValorTotal, ' +
          ':BaseImponible, :Alicuota, :MontoImpuestoAnual, ' +
          ':TieneExoneracion, :TipoExoneracion, :PorcentajeExoneracion, ' +
          ':RutaFotoPrincipal, :RutaFotoFachada, :RutaFotoInterior, ' +
          ':UsuarioCreacion, CURRENT_TIMESTAMP, :UsuarioUltimoAvaluo) ' +
          'RETURNING FichaID';
      end
      else
      begin
        // UPDATE
        FQuery.SQL.Text :=
          'UPDATE FichaCatastral SET ' +
          'CodigoCatastral = :CodigoCatastral, ContribuyenteID = :ContribuyenteID, ' +
          'Estado = :Estado, Municipio = :Municipio, Parroquia = :Parroquia, ' +
          'Sector = :Sector, Urbanizacion = :Urbanizacion, Calle = :Calle, ' +
          'NumeroCasa = :NumeroCasa, Manzana = :Manzana, Parcela = :Parcela, ' +
          'LinderoNorte = :LinderoNorte, LinderoSur = :LinderoSur, ' +
          'LinderoEste = :LinderoEste, LinderoOeste = :LinderoOeste, ' +
          'AreaTerreno = :AreaTerreno, Fachada = :Fachada, Fondo = :Fondo, ' +
          'UsoTerreno = :UsoTerreno, ClasificacionZona = :ClasificacionZona, ' +
          'TopografiaTerreno = :TopografiaTerreno, FormaTerreno = :FormaTerreno, ' +
          'TieneAgua = :TieneAgua, TieneElectricidad = :TieneElectricidad, ' +
          'TieneCloacas = :TieneCloacas, TieneAseo = :TieneAseo, TieneGas = :TieneGas, ' +
          'TieneAceras = :TieneAceras, TieneAlumbrado = :TieneAlumbrado, TieneAsfalto = :TieneAsfalto, ' +
          'AreaConstruccion = :AreaConstruccion, TipoConstruccion = :TipoConstruccion, ' +
          'EstadoConstruccion = :EstadoConstruccion, AnioConstruccion = :AnioConstruccion, ' +
          'NumeroPlantas = :NumeroPlantas, NumeroHabitaciones = :NumeroHabitaciones, ' +
          'NumeroBanos = :NumeroBanos, NumeroEstacionamientos = :NumeroEstacionamientos, ' +
          'MaterialEstructura = :MaterialEstructura, MaterialParedes = :MaterialParedes, ' +
          'MaterialTecho = :MaterialTecho, MaterialPiso = :MaterialPiso, ' +
          'CalidadAcabados = :CalidadAcabados, ' +
          'ValorTerrenoBase = :ValorTerrenoBase, ValorConstruccionBase = :ValorConstruccionBase, ' +
          'CoeficienteZona = :CoeficienteZona, CoeficienteUso = :CoeficienteUso, ' +
          'CoeficienteEstado = :CoeficienteEstado, CoeficienteServicios = :CoeficienteServicios, ' +
          'CoeficienteDepreciacion = :CoeficienteDepreciacion, ' +
          'ValorTerreno = :ValorTerreno, ValorConstruccion = :ValorConstruccion, ' +
          'ValorTotal = :ValorTotal, BaseImponible = :BaseImponible, ' +
          'Alicuota = :Alicuota, MontoImpuestoAnual = :MontoImpuestoAnual, ' +
          'TieneExoneracion = :TieneExoneracion, TipoExoneracion = :TipoExoneracion, ' +
          'PorcentajeExoneracion = :PorcentajeExoneracion, ' +
          'RutaFotoPrincipal = :RutaFotoPrincipal, RutaFotoFachada = :RutaFotoFachada, ' +
          'RutaFotoInterior = :RutaFotoInterior, ' +
          'UsuarioModificacion = :UsuarioModificacion, FechaUltimoAvaluo = CURRENT_TIMESTAMP, ' +
          'UsuarioUltimoAvaluo = :UsuarioUltimoAvaluo ' +
          'WHERE FichaID = :FichaID';
        FQuery.ParamByName('FichaID').AsInteger := FFichaID;
        FQuery.ParamByName('UsuarioModificacion').AsInteger := dmMain.UsuarioActual.UsuarioID;
      end;

      // Asignar parámetros comunes
      FQuery.ParamByName('CodigoCatastral').AsString := edtCodigoCatastral.Text;
      FQuery.ParamByName('ContribuyenteID').AsInteger := FContribuyenteID;
      FQuery.ParamByName('Estado').AsString := cmbEstado.Text;
      FQuery.ParamByName('Municipio').AsString := cmbMunicipio.Text;
      FQuery.ParamByName('Parroquia').AsString := cmbParroquia.Text;
      FQuery.ParamByName('Sector').AsString := edtSector.Text;
      FQuery.ParamByName('Urbanizacion').AsString := edtUrbanizacion.Text;
      FQuery.ParamByName('Calle').AsString := edtCalle.Text;
      FQuery.ParamByName('NumeroCasa').AsString := edtNumeroCasa.Text;
      FQuery.ParamByName('Manzana').AsString := edtManzana.Text;
      FQuery.ParamByName('Parcela').AsString := edtParcela.Text;
      FQuery.ParamByName('LinderoNorte').AsString := edtLinderoNorte.Text;
      FQuery.ParamByName('LinderoSur').AsString := edtLinderoSur.Text;
      FQuery.ParamByName('LinderoEste').AsString := edtLinderoEste.Text;
      FQuery.ParamByName('LinderoOeste').AsString := edtLinderoOeste.Text;
      FQuery.ParamByName('AreaTerreno').AsFloat := StrToFloatDef(edtAreaTerreno.Text, 0);
      FQuery.ParamByName('Fachada').AsFloat := StrToFloatDef(edtFachada.Text, 0);
      FQuery.ParamByName('Fondo').AsFloat := StrToFloatDef(edtFondo.Text, 0);
      FQuery.ParamByName('UsoTerreno').AsString := cmbUsoTerreno.Text;
      FQuery.ParamByName('ClasificacionZona').AsString := cmbClasificacionZona.Text;
      FQuery.ParamByName('TopografiaTerreno').AsString := cmbTopografia.Text;
      FQuery.ParamByName('FormaTerreno').AsString := cmbFormaTerreno.Text;
      FQuery.ParamByName('TieneAgua').AsBoolean := chkAgua.Checked;
      FQuery.ParamByName('TieneElectricidad').AsBoolean := chkElectricidad.Checked;
      FQuery.ParamByName('TieneCloacas').AsBoolean := chkCloacas.Checked;
      FQuery.ParamByName('TieneAseo').AsBoolean := chkAseo.Checked;
      FQuery.ParamByName('TieneGas').AsBoolean := chkGas.Checked;
      FQuery.ParamByName('TieneAceras').AsBoolean := chkAceras.Checked;
      FQuery.ParamByName('TieneAlumbrado').AsBoolean := chkAlumbrado.Checked;
      FQuery.ParamByName('TieneAsfalto').AsBoolean := chkAsfalto.Checked;
      FQuery.ParamByName('AreaConstruccion').AsFloat := StrToFloatDef(edtAreaConstruccion.Text, 0);
      FQuery.ParamByName('TipoConstruccion').AsString := cmbTipoConstruccion.Text;
      FQuery.ParamByName('EstadoConstruccion').AsString := cmbEstadoConstruccion.Text;
      FQuery.ParamByName('AnioConstruccion').AsInteger := StrToIntDef(edtAnioConstruccion.Text, 0);
      FQuery.ParamByName('NumeroPlantas').AsInteger := StrToIntDef(edtNumeroPlantas.Text, 1);
      FQuery.ParamByName('NumeroHabitaciones').AsInteger := StrToIntDef(edtNumeroHabitaciones.Text, 0);
      FQuery.ParamByName('NumeroBanos').AsInteger := StrToIntDef(edtNumeroBanos.Text, 0);
      FQuery.ParamByName('NumeroEstacionamientos').AsInteger := StrToIntDef(edtNumeroEstacionamientos.Text, 0);
      FQuery.ParamByName('MaterialEstructura').AsString := cmbMaterialEstructura.Text;
      FQuery.ParamByName('MaterialParedes').AsString := cmbMaterialParedes.Text;
      FQuery.ParamByName('MaterialTecho').AsString := cmbMaterialTecho.Text;
      FQuery.ParamByName('MaterialPiso').AsString := cmbMaterialPiso.Text;
      FQuery.ParamByName('CalidadAcabados').AsInteger := cmbCalidadAcabados.ItemIndex + 1;

      // Valores calculados
      FQuery.ParamByName('ValorTerrenoBase').AsFloat := StrToFloatDef(StringReplace(edtValorTerrenoBase.Text, ',', '', [rfReplaceAll]), 0);
      FQuery.ParamByName('ValorConstruccionBase').AsFloat := StrToFloatDef(StringReplace(edtValorConstruccionBase.Text, ',', '', [rfReplaceAll]), 0);
      FQuery.ParamByName('CoeficienteZona').AsFloat := StrToFloatDef(edtCoefZona.Text, 1);
      FQuery.ParamByName('CoeficienteUso').AsFloat := StrToFloatDef(edtCoefUso.Text, 1);
      FQuery.ParamByName('CoeficienteEstado').AsFloat := StrToFloatDef(edtCoefEstado.Text, 1);
      FQuery.ParamByName('CoeficienteServicios').AsFloat := StrToFloatDef(edtCoefServicios.Text, 1);
      FQuery.ParamByName('CoeficienteDepreciacion').AsFloat := StrToFloatDef(edtCoefDepreciacion.Text, 1);
      FQuery.ParamByName('ValorTerreno').AsFloat := StrToFloatDef(StringReplace(edtValorTerreno.Text, ',', '', [rfReplaceAll]), 0);
      FQuery.ParamByName('ValorConstruccion').AsFloat := StrToFloatDef(StringReplace(edtValorConstruccion.Text, ',', '', [rfReplaceAll]), 0);
      FQuery.ParamByName('ValorTotal').AsFloat := StrToFloatDef(StringReplace(edtValorTotal.Text, ',', '', [rfReplaceAll]), 0);
      FQuery.ParamByName('BaseImponible').AsFloat := StrToFloatDef(StringReplace(edtBaseImponible.Text, ',', '', [rfReplaceAll]), 0);
      FQuery.ParamByName('Alicuota').AsFloat := StrToFloatDef(edtAlicuota.Text, 0);
      FQuery.ParamByName('MontoImpuestoAnual').AsFloat := StrToFloatDef(StringReplace(edtMontoImpuesto.Text, ',', '', [rfReplaceAll]), 0);

      // Exoneración
      FQuery.ParamByName('TieneExoneracion').AsBoolean := chkExoneracion.Checked;
      FQuery.ParamByName('TipoExoneracion').AsString := cmbTipoExoneracion.Text;
      FQuery.ParamByName('PorcentajeExoneracion').AsFloat := StrToFloatDef(edtPorcentajeExon.Text, 0);

      // Fotos
      FQuery.ParamByName('RutaFotoPrincipal').AsString := FRutaFotoPrincipal;
      FQuery.ParamByName('RutaFotoFachada').AsString := FRutaFotoFachada;
      FQuery.ParamByName('RutaFotoInterior').AsString := FRutaFotoInterior;

      // Usuario
      if FModo = mfNuevo then
        FQuery.ParamByName('UsuarioCreacion').AsInteger := dmMain.UsuarioActual.UsuarioID;
      FQuery.ParamByName('UsuarioUltimoAvaluo').AsInteger := dmMain.UsuarioActual.UsuarioID;

      if FModo = mfNuevo then
      begin
        FQuery.Open;
        FFichaID := FQuery.FieldByName('FichaID').AsInteger;
        FQuery.Close;
      end
      else
        FQuery.ExecSQL;

      dmMain.ConnectionPG.Commit;

      // Registrar en bitácora
      if FModo = mfNuevo then
        dmMain.RegistrarBitacora('CREAR', 'CATASTRO', 'FichaCatastral', FFichaID, '', '', 'EXITO')
      else
        dmMain.RegistrarBitacora('ACTUALIZAR', 'CATASTRO', 'FichaCatastral', FFichaID, '', '', 'EXITO');

      Result := True;

    except
      on E: Exception do
      begin
        dmMain.ConnectionPG.Rollback;
        ShowMessage('Error al guardar: ' + E.Message);
        dmMain.RegistrarBitacora('GUARDAR', 'CATASTRO', 'FichaCatastral', FFichaID, '', '', 'ERROR', E.Message);
      end;
    end;
  except
    on E: Exception do
      ShowMessage('Error de transacción: ' + E.Message);
  end;
end;

procedure TfrmFicha.btnGuardarClick(Sender: TObject);
begin
  if GuardarFicha then
  begin
    ShowMessage('Ficha guardada correctamente');
    ModalResult := mrOk;
  end;
end;

procedure TfrmFicha.btnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmFicha.CargarFoto(const Ruta: string; Imagen: TImage);
begin
  if (Ruta <> '') and FileExists(Ruta) then
  begin
    try
      Imagen.Picture.LoadFromFile(Ruta);
    except
      Imagen.Picture.Assign(nil);
    end;
  end
  else
    Imagen.Picture.Assign(nil);
end;

procedure TfrmFicha.btnCargarFotoPrincipalClick(Sender: TObject);
begin
  if OpenPictureDialog.Execute then
  begin
    FRutaFotoPrincipal := OpenPictureDialog.FileName;
    CargarFoto(FRutaFotoPrincipal, imgPrincipal);
  end;
end;

procedure TfrmFicha.btnCargarFotoFachadaClick(Sender: TObject);
begin
  if OpenPictureDialog.Execute then
  begin
    FRutaFotoFachada := OpenPictureDialog.FileName;
    CargarFoto(FRutaFotoFachada, imgFachada);
  end;
end;

procedure TfrmFicha.btnCargarFotoInteriorClick(Sender: TObject);
begin
  if OpenPictureDialog.Execute then
  begin
    FRutaFotoInterior := OpenPictureDialog.FileName;
    CargarFoto(FRutaFotoInterior, imgInterior);
  end;
end;

procedure TfrmFicha.chkExoneracionClick(Sender: TObject);
begin
  cmbTipoExoneracion.Enabled := chkExoneracion.Checked;
  edtPorcentajeExon.Enabled := chkExoneracion.Checked;

  if not chkExoneracion.Checked then
  begin
    cmbTipoExoneracion.ItemIndex := -1;
    edtPorcentajeExon.Text := '0';
  end;
end;

procedure TfrmFicha.btnBuscarContribClick(Sender: TObject);
begin
  // Abrir formulario de búsqueda de contribuyentes
  ShowMessage('Búsqueda de Contribuyentes - Por implementar');
end;

procedure TfrmFicha.edtAreaTerrenoExit(Sender: TObject);
begin
  // Recalcular automáticamente si hay datos suficientes
  if (Trim(edtAreaTerreno.Text) <> '') and (cmbUsoTerreno.ItemIndex >= 0) then
    CalcularAvaluo;
end;

procedure TfrmFicha.edtAreaConstruccionExit(Sender: TObject);
begin
  if Trim(edtAreaConstruccion.Text) <> '' then
    CalcularAvaluo;
end;

procedure TfrmFicha.btnGeolocalizacionClick(Sender: TObject);
begin
  // Ir a la pestaña de geolocalización
  PageControl.ActivePage := tabGeolocalizacion;

  // Si hay coordenadas, centrar el mapa
  if (FLatitud <> 0) or (FLongitud <> 0) then
  begin
    edtMapaLatitud.Text := FormatFloat('0.000000', FLatitud);
    edtMapaLongitud.Text := FormatFloat('0.000000', FLongitud);
    CentrarMapa(FLatitud, FLongitud);
  end;
end;

function TfrmFicha.GenerarHTMLMapa: string;
var
  Lat, Lon: string;
begin
  // Usar punto como separador decimal para JavaScript
  Lat := StringReplace(edtMapaLatitud.Text, ',', '.', [rfReplaceAll]);
  Lon := StringReplace(edtMapaLongitud.Text, ',', '.', [rfReplaceAll]);

  Result :=
    '<!DOCTYPE html>' + sLineBreak +
    '<html>' + sLineBreak +
    '<head>' + sLineBreak +
    '    <meta charset="utf-8" />' + sLineBreak +
    '    <meta name="viewport" content="width=device-width, initial-scale=1.0">' + sLineBreak +
    '    <title>SIGIEP Catastro - Mapa</title>' + sLineBreak +
    '    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />' + sLineBreak +
    '    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>' + sLineBreak +
    '    <style>' + sLineBreak +
    '        body { margin: 0; padding: 0; }' + sLineBreak +
    '        #map { position: absolute; top: 0; bottom: 0; width: 100%; }' + sLineBreak +
    '        .info-box {' + sLineBreak +
    '            position: absolute; bottom: 10px; left: 10px;' + sLineBreak +
    '            background: white; padding: 8px 12px;' + sLineBreak +
    '            border-radius: 4px; box-shadow: 0 2px 6px rgba(0,0,0,0.3);' + sLineBreak +
    '            font-family: Arial, sans-serif; font-size: 12px;' + sLineBreak +
    '            z-index: 1000;' + sLineBreak +
    '        }' + sLineBreak +
    '    </style>' + sLineBreak +
    '</head>' + sLineBreak +
    '<body>' + sLineBreak +
    '    <div id="map"></div>' + sLineBreak +
    '    <div class="info-box" id="infoBox">Haga clic en el mapa para seleccionar ubicación</div>' + sLineBreak +
    '    <script>' + sLineBreak +
    '        var map = L.map(''map'').setView([' + Lat + ', ' + Lon + '], 8);' + sLineBreak +
    '        ' + sLineBreak +
    '        L.tileLayer(''https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'', {' + sLineBreak +
    '            attribution: ''&copy; OpenStreetMap contributors'',' + sLineBreak +
    '            maxZoom: 19' + sLineBreak +
    '        }).addTo(map);' + sLineBreak +
    '        ' + sLineBreak +
    '        var marker = null;' + sLineBreak +
    '        var selectedLat = ' + Lat + ';' + sLineBreak +
    '        var selectedLon = ' + Lon + ';' + sLineBreak +
    '        ' + sLineBreak +
    '        function updateMarker(lat, lon) {' + sLineBreak +
    '            selectedLat = lat;' + sLineBreak +
    '            selectedLon = lon;' + sLineBreak +
    '            if (marker) {' + sLineBreak +
    '                marker.setLatLng([lat, lon]);' + sLineBreak +
    '            } else {' + sLineBreak +
    '                marker = L.marker([lat, lon], {draggable: true}).addTo(map);' + sLineBreak +
    '                marker.on(''dragend'', function(e) {' + sLineBreak +
    '                    var pos = marker.getLatLng();' + sLineBreak +
    '                    selectedLat = pos.lat;' + sLineBreak +
    '                    selectedLon = pos.lng;' + sLineBreak +
    '                    updateInfoBox(pos.lat, pos.lng);' + sLineBreak +
    '                    document.title = ''COORDS:'' + pos.lat.toFixed(6) + '','' + pos.lng.toFixed(6);' + sLineBreak +
    '                });' + sLineBreak +
    '            }' + sLineBreak +
    '            updateInfoBox(lat, lon);' + sLineBreak +
    '        }' + sLineBreak +
    '        ' + sLineBreak +
    '        function centerMap(lat, lon, zoom) {' + sLineBreak +
    '            map.setView([lat, lon], zoom || 15);' + sLineBreak +
    '            updateMarker(lat, lon);' + sLineBreak +
    '        }' + sLineBreak +
    '        ' + sLineBreak +
    '        function updateInfoBox(lat, lon) {' + sLineBreak +
    '            document.getElementById(''infoBox'').innerHTML = ' + sLineBreak +
    '                ''<strong>Lat:</strong> '' + lat.toFixed(6) + ''<br>'' +' + sLineBreak +
    '                ''<strong>Lon:</strong> '' + lon.toFixed(6);' + sLineBreak +
    '        }' + sLineBreak +
    '        ' + sLineBreak +
    '        function getCoords() {' + sLineBreak +
    '            return selectedLat.toFixed(6) + '','' + selectedLon.toFixed(6);' + sLineBreak +
    '        }' + sLineBreak +
    '        ' + sLineBreak +
    '        map.on(''click'', function(e) {' + sLineBreak +
    '            updateMarker(e.latlng.lat, e.latlng.lng);' + sLineBreak +
    '            document.title = ''COORDS:'' + e.latlng.lat.toFixed(6) + '','' + e.latlng.lng.toFixed(6);' + sLineBreak +
    '        });' + sLineBreak +
    '    </script>' + sLineBreak +
    '</body>' + sLineBreak +
    '</html>';
end;

procedure TfrmFicha.CargarMapa;
var
  HTML: string;
begin
  HTML := GenerarHTMLMapa;
  TFile.WriteAllText(FHTMLPath, HTML, TEncoding.UTF8);
  WebBrowser.Navigate('file:///' + StringReplace(FHTMLPath, '\', '/', [rfReplaceAll]));
end;

procedure TfrmFicha.WebBrowserDocumentComplete(ASender: TObject;
  const pDisp: IDispatch; const URL: OleVariant);
begin
  FMapaCargado := True;

  // Si hay coordenadas previas, centrar el mapa
  if (FLatitud <> 0) or (FLongitud <> 0) then
    CentrarMapa(FLatitud, FLongitud, 15);
end;

procedure TfrmFicha.CentrarMapa(Lat, Lon: Double; Zoom: Integer);
var
  Doc: IHTMLDocument2;
  Win: IHTMLWindow2;
  Script: string;
begin
  if not FMapaCargado then Exit;

  try
    Doc := WebBrowser.Document as IHTMLDocument2;
    if Assigned(Doc) then
    begin
      Win := Doc.parentWindow;
      if Assigned(Win) then
      begin
        Script := Format('centerMap(%s, %s, %d)',
          [StringReplace(FormatFloat('0.000000', Lat), ',', '.', [rfReplaceAll]),
           StringReplace(FormatFloat('0.000000', Lon), ',', '.', [rfReplaceAll]),
           Zoom]);
        Win.execScript(Script, 'JavaScript');
      end;
    end;
  except
    // Ignorar errores de script
  end;
end;

procedure TfrmFicha.ProcesarClickMapa;
var
  Doc: IHTMLDocument2;
  Title: string;
  Parts: TArray<string>;
begin
  try
    Doc := WebBrowser.Document as IHTMLDocument2;
    if Assigned(Doc) then
    begin
      Title := Doc.title;

      if StartsText('COORDS:', Title) then
      begin
        Title := Copy(Title, 8, MaxInt);
        Parts := Title.Split([',']);

        if Length(Parts) = 2 then
        begin
          edtMapaLatitud.Text := Trim(Parts[0]);
          edtMapaLongitud.Text := Trim(Parts[1]);

          FLatitud := StrToFloatDef(StringReplace(Parts[0], '.', FormatSettings.DecimalSeparator, []), 0);
          FLongitud := StrToFloatDef(StringReplace(Parts[1], '.', FormatSettings.DecimalSeparator, []), 0);

          // Actualizar campos en el grupo de ubicación
          edtLatitud.Text := Trim(Parts[0]);
          edtLongitud.Text := Trim(Parts[1]);
        end;
      end;
    end;
  except
    // Ignorar errores
  end;
end;

procedure TfrmFicha.btnIrAPuntoClick(Sender: TObject);
var
  Lat, Lon: Double;
  LatStr, LonStr: string;
begin
  LatStr := StringReplace(Trim(edtMapaLatitud.Text), '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  LonStr := StringReplace(Trim(edtMapaLongitud.Text), '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);

  if not TryStrToFloat(LatStr, Lat) then
  begin
    ShowMessage('Latitud inválida. Use formato decimal (ej: 8.123456)');
    edtMapaLatitud.SetFocus;
    Exit;
  end;

  if not TryStrToFloat(LonStr, Lon) then
  begin
    ShowMessage('Longitud inválida. Use formato decimal (ej: -66.123456)');
    edtMapaLongitud.SetFocus;
    Exit;
  end;

  if (Lat < -90) or (Lat > 90) then
  begin
    ShowMessage('Latitud debe estar entre -90 y 90');
    edtMapaLatitud.SetFocus;
    Exit;
  end;

  if (Lon < -180) or (Lon > 180) then
  begin
    ShowMessage('Longitud debe estar entre -180 y 180');
    edtMapaLongitud.SetFocus;
    Exit;
  end;

  FLatitud := Lat;
  FLongitud := Lon;

  // Actualizar campos en el grupo de ubicación
  edtLatitud.Text := FormatFloat('0.000000', Lat);
  edtLongitud.Text := FormatFloat('0.000000', Lon);

  CentrarMapa(Lat, Lon, 15);
end;

procedure TfrmFicha.btnLimpiarMapaClick(Sender: TObject);
begin
  edtMapaLatitud.Text := '8.0000';
  edtMapaLongitud.Text := '-66.0000';
  edtMapaDireccion.Text := '';
  edtLatitud.Text := '';
  edtLongitud.Text := '';
  edtDireccionGeo.Text := '';
  FLatitud := 0;
  FLongitud := 0;

  CargarMapa;
end;

procedure TfrmFicha.edtMapaLatitudKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', '.', ',', '-', #8]) then
    Key := #0;
end;

end.
