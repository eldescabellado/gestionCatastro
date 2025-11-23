unit uFrmGeolocalizacion;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.StrUtils, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.OleCtrls, SHDocVw;

type
  TfrmGeolocalizacion = class(TForm)
    pnlTop: TPanel;
    lblTitulo: TLabel;

    pnlCoordenadas: TPanel;
    lblLatitud: TLabel;
    edtLatitud: TEdit;
    lblLongitud: TLabel;
    edtLongitud: TEdit;
    btnBuscar: TBitBtn;
    btnLimpiar: TBitBtn;

    pnlMapa: TPanel;
    WebBrowser: TWebBrowser;

    pnlBotones: TPanel;
    btnAceptar: TBitBtn;
    btnCancelar: TBitBtn;

    lblDireccion: TLabel;
    edtDireccion: TEdit;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnLimpiarClick(Sender: TObject);
    procedure btnAceptarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure WebBrowserDocumentComplete(ASender: TObject; const pDisp: IDispatch; const URL: OleVariant);
    procedure edtLatitudKeyPress(Sender: TObject; var Key: Char);

  private
    FLatitud: Double;
    FLongitud: Double;
    FDireccion: string;
    FMapaCargado: Boolean;
    FHTMLPath: string;

    procedure CargarMapa;
    procedure ActualizarMarcador(Lat, Lon: Double);
    procedure CentrarMapa(Lat, Lon: Double; Zoom: Integer = 15);
    procedure ProcesarClickMapa;
    function GenerarHTMLMapa: string;

  public
    property Latitud: Double read FLatitud write FLatitud;
    property Longitud: Double read FLongitud write FLongitud;
    property Direccion: string read FDireccion write FDireccion;

    class function Ejecutar(var ALat, ALon: Double; var ADireccion: string): Boolean;
  end;

var
  frmGeolocalizacion: TfrmGeolocalizacion;

implementation

{$R *.dfm}

uses
  System.IOUtils, ActiveX, MSHTML;

{ TfrmGeolocalizacion }

procedure TfrmGeolocalizacion.FormCreate(Sender: TObject);
begin
  FLatitud := 0;
  FLongitud := 0;
  FDireccion := '';
  FMapaCargado := False;

  // Ruta temporal para el HTML del mapa
  FHTMLPath := TPath.Combine(TPath.GetTempPath, 'sigiep_mapa.html');

  // Valores por defecto (Venezuela - centro aproximado)
  edtLatitud.Text := '8.0000';
  edtLongitud.Text := '-66.0000';
end;

procedure TfrmGeolocalizacion.FormShow(Sender: TObject);
begin
  // Si hay coordenadas previas, usarlas
  if (FLatitud <> 0) or (FLongitud <> 0) then
  begin
    edtLatitud.Text := FormatFloat('0.000000', FLatitud);
    edtLongitud.Text := FormatFloat('0.000000', FLongitud);
  end;

  if FDireccion <> '' then
    edtDireccion.Text := FDireccion;

  CargarMapa;
end;

function TfrmGeolocalizacion.GenerarHTMLMapa: string;
var
  Lat, Lon: string;
begin
  // Usar punto como separador decimal para JavaScript
  Lat := StringReplace(edtLatitud.Text, ',', '.', [rfReplaceAll]);
  Lon := StringReplace(edtLongitud.Text, ',', '.', [rfReplaceAll]);

  Result :=
    '<!DOCTYPE html>' + sLineBreak +
    '<html>' + sLineBreak +
    '<head>' + sLineBreak +
    '    <meta charset="utf-8" />' + sLineBreak +
    '    <meta name="viewport" content="width=device-width, initial-scale=1.0">' + sLineBreak +
    '    <title>Mapa SIGIEP</title>' + sLineBreak +
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
    '        // Función para actualizar el marcador' + sLineBreak +
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
    '        // Función para centrar el mapa' + sLineBreak +
    '        function centerMap(lat, lon, zoom) {' + sLineBreak +
    '            map.setView([lat, lon], zoom || 15);' + sLineBreak +
    '            updateMarker(lat, lon);' + sLineBreak +
    '        }' + sLineBreak +
    '        ' + sLineBreak +
    '        // Actualizar caja de información' + sLineBreak +
    '        function updateInfoBox(lat, lon) {' + sLineBreak +
    '            document.getElementById(''infoBox'').innerHTML = ' + sLineBreak +
    '                ''<strong>Lat:</strong> '' + lat.toFixed(6) + ''<br>'' +' + sLineBreak +
    '                ''<strong>Lon:</strong> '' + lon.toFixed(6);' + sLineBreak +
    '        }' + sLineBreak +
    '        ' + sLineBreak +
    '        // Obtener coordenadas seleccionadas' + sLineBreak +
    '        function getCoords() {' + sLineBreak +
    '            return selectedLat.toFixed(6) + '','' + selectedLon.toFixed(6);' + sLineBreak +
    '        }' + sLineBreak +
    '        ' + sLineBreak +
    '        // Evento de clic en el mapa' + sLineBreak +
    '        map.on(''click'', function(e) {' + sLineBreak +
    '            updateMarker(e.latlng.lat, e.latlng.lng);' + sLineBreak +
    '            // Comunicar a Delphi mediante cambio de título' + sLineBreak +
    '            document.title = ''COORDS:'' + e.latlng.lat.toFixed(6) + '','' + e.latlng.lng.toFixed(6);' + sLineBreak +
    '        });' + sLineBreak +
    '    </script>' + sLineBreak +
    '</body>' + sLineBreak +
    '</html>';
end;

procedure TfrmGeolocalizacion.CargarMapa;
var
  HTML: string;
begin
  HTML := GenerarHTMLMapa;

  // Guardar HTML temporal
  TFile.WriteAllText(FHTMLPath, HTML, TEncoding.UTF8);

  // Cargar en el navegador
  WebBrowser.Navigate('file:///' + StringReplace(FHTMLPath, '\', '/', [rfReplaceAll]));
end;

procedure TfrmGeolocalizacion.WebBrowserDocumentComplete(ASender: TObject;
  const pDisp: IDispatch; const URL: OleVariant);
begin
  FMapaCargado := True;

  // Si hay coordenadas iniciales, centrar el mapa
  if (FLatitud <> 0) or (FLongitud <> 0) then
    CentrarMapa(FLatitud, FLongitud, 15);
end;

procedure TfrmGeolocalizacion.ActualizarMarcador(Lat, Lon: Double);
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
        Script := Format('updateMarker(%s, %s)',
          [StringReplace(FormatFloat('0.000000', Lat), ',', '.', [rfReplaceAll]),
           StringReplace(FormatFloat('0.000000', Lon), ',', '.', [rfReplaceAll])]);
        Win.execScript(Script, 'JavaScript');
      end;
    end;
  except
    // Ignorar errores de script
  end;
end;

procedure TfrmGeolocalizacion.CentrarMapa(Lat, Lon: Double; Zoom: Integer);
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

procedure TfrmGeolocalizacion.ProcesarClickMapa;
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

      // Verificar si el título contiene coordenadas
      if StartsText('COORDS:', Title) then
      begin
        // Extraer coordenadas del título
        Title := Copy(Title, 8, MaxInt); // Quitar 'COORDS:'
        Parts := Title.Split([',']);

        if Length(Parts) = 2 then
        begin
          // Actualizar campos de texto
          edtLatitud.Text := Trim(Parts[0]);
          edtLongitud.Text := Trim(Parts[1]);

          // Actualizar variables internas
          FLatitud := StrToFloatDef(StringReplace(Parts[0], '.', FormatSettings.DecimalSeparator, []), 0);
          FLongitud := StrToFloatDef(StringReplace(Parts[1], '.', FormatSettings.DecimalSeparator, []), 0);
        end;
      end;
    end;
  except
    // Ignorar errores
  end;
end;

procedure TfrmGeolocalizacion.btnBuscarClick(Sender: TObject);
var
  Lat, Lon: Double;
  LatStr, LonStr: string;
begin
  // Convertir texto a números
  LatStr := StringReplace(Trim(edtLatitud.Text), '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  LonStr := StringReplace(Trim(edtLongitud.Text), '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);

  if not TryStrToFloat(LatStr, Lat) then
  begin
    MessageDlg('Latitud inválida. Use formato decimal (ej: 8.123456)', mtError, [mbOK], 0);
    edtLatitud.SetFocus;
    Exit;
  end;

  if not TryStrToFloat(LonStr, Lon) then
  begin
    MessageDlg('Longitud inválida. Use formato decimal (ej: -66.123456)', mtError, [mbOK], 0);
    edtLongitud.SetFocus;
    Exit;
  end;

  // Validar rangos
  if (Lat < -90) or (Lat > 90) then
  begin
    MessageDlg('Latitud debe estar entre -90 y 90', mtError, [mbOK], 0);
    edtLatitud.SetFocus;
    Exit;
  end;

  if (Lon < -180) or (Lon > 180) then
  begin
    MessageDlg('Longitud debe estar entre -180 y 180', mtError, [mbOK], 0);
    edtLongitud.SetFocus;
    Exit;
  end;

  FLatitud := Lat;
  FLongitud := Lon;

  // Centrar mapa en las coordenadas
  CentrarMapa(Lat, Lon, 15);
end;

procedure TfrmGeolocalizacion.btnLimpiarClick(Sender: TObject);
begin
  edtLatitud.Text := '8.0000';
  edtLongitud.Text := '-66.0000';
  edtDireccion.Text := '';
  FLatitud := 0;
  FLongitud := 0;
  FDireccion := '';

  // Recargar mapa
  CargarMapa;
end;

procedure TfrmGeolocalizacion.edtLatitudKeyPress(Sender: TObject; var Key: Char);
begin
  // Permitir solo números, punto, coma y signo negativo
  if not CharInSet(Key, ['0'..'9', '.', ',', '-', #8]) then
    Key := #0;
end;

procedure TfrmGeolocalizacion.btnAceptarClick(Sender: TObject);
begin
  // Procesar últimas coordenadas del mapa
  ProcesarClickMapa;

  // Validar que hay coordenadas
  if (FLatitud = 0) and (FLongitud = 0) then
  begin
    // Intentar obtener de los campos de texto
    btnBuscarClick(nil);
  end;

  FDireccion := Trim(edtDireccion.Text);

  // Limpiar archivo temporal
  if TFile.Exists(FHTMLPath) then
    TFile.Delete(FHTMLPath);

  ModalResult := mrOk;
end;

procedure TfrmGeolocalizacion.btnCancelarClick(Sender: TObject);
begin
  // Limpiar archivo temporal
  if TFile.Exists(FHTMLPath) then
    TFile.Delete(FHTMLPath);

  ModalResult := mrCancel;
end;

class function TfrmGeolocalizacion.Ejecutar(var ALat, ALon: Double;
  var ADireccion: string): Boolean;
var
  Frm: TfrmGeolocalizacion;
begin
  Result := False;
  Frm := TfrmGeolocalizacion.Create(nil);
  try
    Frm.Latitud := ALat;
    Frm.Longitud := ALon;
    Frm.Direccion := ADireccion;

    if Frm.ShowModal = mrOk then
    begin
      ALat := Frm.Latitud;
      ALon := Frm.Longitud;
      ADireccion := Frm.Direccion;
      Result := True;
    end;
  finally
    Frm.Free;
  end;
end;

end.
