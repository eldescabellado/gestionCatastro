object frmGeolocalizacion: TfrmGeolocalizacion
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Geolocalizaci'#243'n - SIGIEP Catastro'
  ClientHeight = 550
  ClientWidth = 750
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow

  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 750
    Height = 50
    Align = alTop
    Color = clNavy
    ParentBackground = False
    TabOrder = 0

    object lblTitulo: TLabel
      Left = 0
      Top = 0
      Width = 750
      Height = 50
      Align = alClient
      Alignment = taCenter
      Caption = 'Seleccionar Ubicaci'#243'n Geogr'#225'fica'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
  end

  object pnlCoordenadas: TPanel
    Left = 0
    Top = 50
    Width = 750
    Height = 70
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1

    object lblLatitud: TLabel
      Left = 16
      Top = 16
      Width = 42
      Height = 13
      Caption = 'Latitud:'
    end
    object edtLatitud: TEdit
      Left = 70
      Top = 13
      Width = 100
      Height = 21
      TabOrder = 0
      Text = '8.0000'
      OnKeyPress = edtLatitudKeyPress
    end

    object lblLongitud: TLabel
      Left = 185
      Top = 16
      Width = 50
      Height = 13
      Caption = 'Longitud:'
    end
    object edtLongitud: TEdit
      Left = 245
      Top = 13
      Width = 100
      Height = 21
      TabOrder = 1
      Text = '-66.0000'
      OnKeyPress = edtLatitudKeyPress
    end

    object btnBuscar: TBitBtn
      Left = 360
      Top = 10
      Width = 90
      Height = 28
      Caption = 'Ir a Punto'
      TabOrder = 2
      OnClick = btnBuscarClick
    end

    object btnLimpiar: TBitBtn
      Left = 460
      Top = 10
      Width = 75
      Height = 28
      Caption = 'Limpiar'
      TabOrder = 3
      OnClick = btnLimpiarClick
    end

    object lblDireccion: TLabel
      Left = 16
      Top = 44
      Width = 52
      Height = 13
      Caption = 'Direcci'#243'n:'
    end
    object edtDireccion: TEdit
      Left = 70
      Top = 41
      Width = 465
      Height = 21
      TabOrder = 4
    end
  end

  object pnlMapa: TPanel
    Left = 0
    Top = 120
    Width = 750
    Height = 380
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2

    object WebBrowser: TWebBrowser
      Left = 0
      Top = 0
      Width = 750
      Height = 380
      Align = alClient
      TabOrder = 0
      OnDocumentComplete = WebBrowserDocumentComplete
      ControlData = {
        4C000000A7380000942C00000000000000000000000000000000000000000000
        000000004C000000000000000000000001000000E0D057007335CF11AE690800
        2B2E126208000000000000004C0000000114020000000000C000000000000046
        8000000000000000000000000000000000000000000000000000000000000000
        00000000000000000100000000000000000000000000000000000000}
    end
  end

  object pnlBotones: TPanel
    Left = 0
    Top = 500
    Width = 750
    Height = 50
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 3

    object btnAceptar: TBitBtn
      Left = 520
      Top = 10
      Width = 100
      Height = 30
      Caption = 'Aceptar'
      Default = True
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnAceptarClick
    end

    object btnCancelar: TBitBtn
      Left = 630
      Top = 10
      Width = 100
      Height = 30
      Cancel = True
      Caption = 'Cancelar'
      TabOrder = 1
      OnClick = btnCancelarClick
    end
  end
end
