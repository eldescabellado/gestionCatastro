object frmFicha: TfrmFicha
  Left = 0
  Top = 0
  Caption = 'Ficha Catastral'
  ClientHeight = 650
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow

  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 900
    Height = 600
    ActivePage = tabPredio
    Align = alClient
    TabOrder = 0

    object tabPredio: TTabSheet
      Caption = 'Datos del Predio'

      object gbIdentificacion: TGroupBox
        Left = 8
        Top = 8
        Width = 425
        Height = 80
        Caption = 'Identificaci'#243'n'
        TabOrder = 0
        object lblCodigoCatastral: TLabel
          Left = 16
          Top = 24
          Width = 95
          Height = 13
          Caption = 'C'#243'digo Catastral:'
        end
        object edtCodigoCatastral: TEdit
          Left = 120
          Top = 21
          Width = 150
          Height = 21
          TabOrder = 0
        end
        object lblContribuyente: TLabel
          Left = 16
          Top = 52
          Width = 75
          Height = 13
          Caption = 'Contribuyente:'
        end
        object cmbContribuyente: TComboBox
          Left = 120
          Top = 49
          Width = 250
          Height = 21
          TabOrder = 1
        end
        object btnBuscarContrib: TBitBtn
          Left = 376
          Top = 47
          Width = 40
          Height = 25
          Caption = '...'
          TabOrder = 2
          OnClick = btnBuscarContribClick
        end
      end

      object gbUbicacion: TGroupBox
        Left = 8
        Top = 96
        Width = 860
        Height = 200
        Caption = 'Ubicaci'#243'n'
        TabOrder = 1
        object lblEstado: TLabel
          Left = 16
          Top = 24
          Width = 40
          Height = 13
          Caption = 'Estado:'
        end
        object cmbEstado: TComboBox
          Left = 80
          Top = 21
          Width = 150
          Height = 21
          TabOrder = 0
        end
        object lblMunicipio: TLabel
          Left = 250
          Top = 24
          Width = 55
          Height = 13
          Caption = 'Municipio:'
        end
        object cmbMunicipio: TComboBox
          Left = 320
          Top = 21
          Width = 150
          Height = 21
          TabOrder = 1
        end
        object lblParroquia: TLabel
          Left = 490
          Top = 24
          Width = 55
          Height = 13
          Caption = 'Parroquia:'
        end
        object cmbParroquia: TComboBox
          Left = 560
          Top = 21
          Width = 150
          Height = 21
          TabOrder = 2
        end
        object lblSector: TLabel
          Left = 16
          Top = 56
          Width = 36
          Height = 13
          Caption = 'Sector:'
        end
        object edtSector: TEdit
          Left = 80
          Top = 53
          Width = 150
          Height = 21
          TabOrder = 3
        end
        object lblUrbanizacion: TLabel
          Left = 250
          Top = 56
          Width = 70
          Height = 13
          Caption = 'Urbanizaci'#243'n:'
        end
        object edtUrbanizacion: TEdit
          Left = 320
          Top = 53
          Width = 150
          Height = 21
          TabOrder = 4
        end
        object lblCalle: TLabel
          Left = 16
          Top = 88
          Width = 30
          Height = 13
          Caption = 'Calle:'
        end
        object edtCalle: TEdit
          Left = 80
          Top = 85
          Width = 200
          Height = 21
          TabOrder = 5
        end
        object lblNumeroCasa: TLabel
          Left = 300
          Top = 88
          Width = 25
          Height = 13
          Caption = 'N'#186':'
        end
        object edtNumeroCasa: TEdit
          Left = 330
          Top = 85
          Width = 60
          Height = 21
          TabOrder = 6
        end
        object lblManzana: TLabel
          Left = 410
          Top = 88
          Width = 50
          Height = 13
          Caption = 'Manzana:'
        end
        object edtManzana: TEdit
          Left = 470
          Top = 85
          Width = 60
          Height = 21
          TabOrder = 7
        end
        object lblParcela: TLabel
          Left = 550
          Top = 88
          Width = 40
          Height = 13
          Caption = 'Parcela:'
        end
        object edtParcela: TEdit
          Left = 600
          Top = 85
          Width = 60
          Height = 21
          TabOrder = 8
        end
      end

      object gbLinderos: TGroupBox
        Left = 8
        Top = 304
        Width = 860
        Height = 100
        Caption = 'Linderos'
        TabOrder = 2
        object lblLinderoNorte: TLabel
          Left = 16
          Top = 24
          Width = 35
          Height = 13
          Caption = 'Norte:'
        end
        object edtLinderoNorte: TEdit
          Left = 60
          Top = 21
          Width = 350
          Height = 21
          TabOrder = 0
        end
        object lblLinderoSur: TLabel
          Left = 430
          Top = 24
          Width = 20
          Height = 13
          Caption = 'Sur:'
        end
        object edtLinderoSur: TEdit
          Left = 460
          Top = 21
          Width = 350
          Height = 21
          TabOrder = 1
        end
        object lblLinderoEste: TLabel
          Left = 16
          Top = 56
          Width = 25
          Height = 13
          Caption = 'Este:'
        end
        object edtLinderoEste: TEdit
          Left = 60
          Top = 53
          Width = 350
          Height = 21
          TabOrder = 2
        end
        object lblLinderoOeste: TLabel
          Left = 430
          Top = 56
          Width = 35
          Height = 13
          Caption = 'Oeste:'
        end
        object edtLinderoOeste: TEdit
          Left = 460
          Top = 53
          Width = 350
          Height = 21
          TabOrder = 3
        end
      end
    end

    object tabTerreno: TTabSheet
      Caption = 'Terreno'
      ImageIndex = 1

      object gbDimensiones: TGroupBox
        Left = 8
        Top = 8
        Width = 300
        Height = 120
        Caption = 'Dimensiones'
        TabOrder = 0
        object lblAreaTerreno: TLabel
          Left = 16
          Top = 28
          Width = 70
          Height = 13
          Caption = #193'rea Terreno:'
        end
        object edtAreaTerreno: TEdit
          Left = 100
          Top = 25
          Width = 100
          Height = 21
          TabOrder = 0
          OnExit = edtAreaTerrenoExit
        end
        object lblFachada: TLabel
          Left = 16
          Top = 60
          Width = 45
          Height = 13
          Caption = 'Fachada:'
        end
        object edtFachada: TEdit
          Left = 100
          Top = 57
          Width = 80
          Height = 21
          TabOrder = 1
        end
        object lblFondo: TLabel
          Left = 16
          Top = 92
          Width = 35
          Height = 13
          Caption = 'Fondo:'
        end
        object edtFondo: TEdit
          Left = 100
          Top = 89
          Width = 80
          Height = 21
          TabOrder = 2
        end
      end

      object gbClasificacion: TGroupBox
        Left = 320
        Top = 8
        Width = 300
        Height = 150
        Caption = 'Clasificaci'#243'n'
        TabOrder = 1
        object lblUsoTerreno: TLabel
          Left = 16
          Top = 28
          Width = 25
          Height = 13
          Caption = 'Uso:'
        end
        object cmbUsoTerreno: TComboBox
          Left = 100
          Top = 25
          Width = 180
          Height = 21
          TabOrder = 0
        end
        object lblClasificacionZona: TLabel
          Left = 16
          Top = 60
          Width = 30
          Height = 13
          Caption = 'Zona:'
        end
        object cmbClasificacionZona: TComboBox
          Left = 100
          Top = 57
          Width = 180
          Height = 21
          TabOrder = 1
        end
        object lblTopografia: TLabel
          Left = 16
          Top = 92
          Width = 60
          Height = 13
          Caption = 'Topograf'#237'a:'
        end
        object cmbTopografia: TComboBox
          Left = 100
          Top = 89
          Width = 180
          Height = 21
          TabOrder = 2
        end
        object lblFormaTerreno: TLabel
          Left = 16
          Top = 124
          Width = 38
          Height = 13
          Caption = 'Forma:'
        end
        object cmbFormaTerreno: TComboBox
          Left = 100
          Top = 121
          Width = 180
          Height = 21
          TabOrder = 3
        end
      end

      object gbServicios: TGroupBox
        Left = 8
        Top = 170
        Width = 612
        Height = 120
        Caption = 'Servicios P'#250'blicos'
        TabOrder = 2
        object chkAgua: TCheckBox
          Left = 16
          Top = 24
          Width = 80
          Height = 17
          Caption = 'Agua'
          TabOrder = 0
        end
        object chkElectricidad: TCheckBox
          Left = 16
          Top = 48
          Width = 100
          Height = 17
          Caption = 'Electricidad'
          TabOrder = 1
        end
        object chkCloacas: TCheckBox
          Left = 16
          Top = 72
          Width = 80
          Height = 17
          Caption = 'Cloacas'
          TabOrder = 2
        end
        object chkAseo: TCheckBox
          Left = 130
          Top = 24
          Width = 80
          Height = 17
          Caption = 'Aseo'
          TabOrder = 3
        end
        object chkGas: TCheckBox
          Left = 130
          Top = 48
          Width = 80
          Height = 17
          Caption = 'Gas'
          TabOrder = 4
        end
        object chkTelefono: TCheckBox
          Left = 130
          Top = 72
          Width = 80
          Height = 17
          Caption = 'Tel'#233'fono'
          TabOrder = 5
        end
        object chkInternet: TCheckBox
          Left = 244
          Top = 24
          Width = 80
          Height = 17
          Caption = 'Internet'
          TabOrder = 6
        end
        object chkAceras: TCheckBox
          Left = 244
          Top = 48
          Width = 80
          Height = 17
          Caption = 'Aceras'
          TabOrder = 7
        end
        object chkAlumbrado: TCheckBox
          Left = 244
          Top = 72
          Width = 100
          Height = 17
          Caption = 'Alumbrado'
          TabOrder = 8
        end
        object chkAsfalto: TCheckBox
          Left = 358
          Top = 24
          Width = 80
          Height = 17
          Caption = 'Asfalto'
          TabOrder = 9
        end
      end
    end

    object tabConstruccion: TTabSheet
      Caption = 'Construcci'#243'n'
      ImageIndex = 2

      object gbCaracteristicas: TGroupBox
        Left = 8
        Top = 8
        Width = 420
        Height = 280
        Caption = 'Caracter'#237'sticas'
        TabOrder = 0
        object lblAreaConstruccion: TLabel
          Left = 16
          Top = 28
          Width = 90
          Height = 13
          Caption = #193'rea Construcci'#243'n:'
        end
        object edtAreaConstruccion: TEdit
          Left = 130
          Top = 25
          Width = 100
          Height = 21
          TabOrder = 0
          OnExit = edtAreaConstruccionExit
        end
        object lblTipoConstruccion: TLabel
          Left = 16
          Top = 60
          Width = 30
          Height = 13
          Caption = 'Tipo:'
        end
        object cmbTipoConstruccion: TComboBox
          Left = 130
          Top = 57
          Width = 150
          Height = 21
          TabOrder = 1
        end
        object lblEstadoConstruccion: TLabel
          Left = 16
          Top = 92
          Width = 40
          Height = 13
          Caption = 'Estado:'
        end
        object cmbEstadoConstruccion: TComboBox
          Left = 130
          Top = 89
          Width = 150
          Height = 21
          TabOrder = 2
        end
        object lblAnioConstruccion: TLabel
          Left = 16
          Top = 124
          Width = 95
          Height = 13
          Caption = 'A'#241'o Construcci'#243'n:'
        end
        object edtAnioConstruccion: TEdit
          Left = 130
          Top = 121
          Width = 80
          Height = 21
          TabOrder = 3
        end
        object lblNumeroPlantas: TLabel
          Left = 16
          Top = 156
          Width = 40
          Height = 13
          Caption = 'Plantas:'
        end
        object edtNumeroPlantas: TEdit
          Left = 130
          Top = 153
          Width = 60
          Height = 21
          TabOrder = 4
        end
        object lblNumeroHabitaciones: TLabel
          Left = 16
          Top = 188
          Width = 70
          Height = 13
          Caption = 'Habitaciones:'
        end
        object edtNumeroHabitaciones: TEdit
          Left = 130
          Top = 185
          Width = 60
          Height = 21
          TabOrder = 5
        end
        object lblNumeroBanos: TLabel
          Left = 210
          Top = 188
          Width = 35
          Height = 13
          Caption = 'Ba'#241'os:'
        end
        object edtNumeroBanos: TEdit
          Left = 260
          Top = 185
          Width = 60
          Height = 21
          TabOrder = 6
        end
        object lblNumeroEstacionamientos: TLabel
          Left = 16
          Top = 220
          Width = 90
          Height = 13
          Caption = 'Estacionamientos:'
        end
        object edtNumeroEstacionamientos: TEdit
          Left = 130
          Top = 217
          Width = 60
          Height = 21
          TabOrder = 7
        end
      end

      object gbMateriales: TGroupBox
        Left = 440
        Top = 8
        Width = 420
        Height = 200
        Caption = 'Materiales'
        TabOrder = 1
        object lblMaterialEstructura: TLabel
          Left = 16
          Top = 28
          Width = 60
          Height = 13
          Caption = 'Estructura:'
        end
        object cmbMaterialEstructura: TComboBox
          Left = 130
          Top = 25
          Width = 180
          Height = 21
          TabOrder = 0
        end
        object lblMaterialParedes: TLabel
          Left = 16
          Top = 60
          Width = 45
          Height = 13
          Caption = 'Paredes:'
        end
        object cmbMaterialParedes: TComboBox
          Left = 130
          Top = 57
          Width = 180
          Height = 21
          TabOrder = 1
        end
        object lblMaterialTecho: TLabel
          Left = 16
          Top = 92
          Width = 35
          Height = 13
          Caption = 'Techo:'
        end
        object cmbMaterialTecho: TComboBox
          Left = 130
          Top = 89
          Width = 180
          Height = 21
          TabOrder = 2
        end
        object lblMaterialPiso: TLabel
          Left = 16
          Top = 124
          Width = 25
          Height = 13
          Caption = 'Piso:'
        end
        object cmbMaterialPiso: TComboBox
          Left = 130
          Top = 121
          Width = 180
          Height = 21
          TabOrder = 3
        end
        object lblCalidadAcabados: TLabel
          Left = 16
          Top = 156
          Width = 95
          Height = 13
          Caption = 'Calidad Acabados:'
        end
        object cmbCalidadAcabados: TComboBox
          Left = 130
          Top = 153
          Width = 180
          Height = 21
          TabOrder = 4
        end
      end
    end

    object tabLegal: TTabSheet
      Caption = 'Datos Legales'
      ImageIndex = 3

      object gbDocumentos: TGroupBox
        Left = 8
        Top = 8
        Width = 600
        Height = 200
        Caption = 'Documento de Propiedad'
        TabOrder = 0
        object lblNumeroDocumento: TLabel
          Left = 16
          Top = 28
          Width = 55
          Height = 13
          Caption = 'N'#250'mero:'
        end
        object edtNumeroDocumento: TEdit
          Left = 100
          Top = 25
          Width = 150
          Height = 21
          TabOrder = 0
        end
        object lblFechaDocumento: TLabel
          Left = 270
          Top = 28
          Width = 35
          Height = 13
          Caption = 'Fecha:'
        end
        object dtpFechaDocumento: TDateTimePicker
          Left = 320
          Top = 25
          Width = 120
          Height = 21
          Date = 45658.000000000000000000
          Time = 0.500000000000000000
          TabOrder = 1
        end
        object lblNotaria: TLabel
          Left = 16
          Top = 60
          Width = 45
          Height = 13
          Caption = 'Notar'#237'a:'
        end
        object edtNotaria: TEdit
          Left = 100
          Top = 57
          Width = 300
          Height = 21
          TabOrder = 2
        end
        object lblTomo: TLabel
          Left = 16
          Top = 92
          Width = 30
          Height = 13
          Caption = 'Tomo:'
        end
        object edtTomo: TEdit
          Left = 100
          Top = 89
          Width = 80
          Height = 21
          TabOrder = 3
        end
        object lblFolio: TLabel
          Left = 200
          Top = 92
          Width = 30
          Height = 13
          Caption = 'Folio:'
        end
        object edtFolio: TEdit
          Left = 240
          Top = 89
          Width = 80
          Height = 21
          TabOrder = 4
        end
        object lblProtocolo: TLabel
          Left = 340
          Top = 92
          Width = 55
          Height = 13
          Caption = 'Protocolo:'
        end
        object edtProtocolo: TEdit
          Left = 410
          Top = 89
          Width = 80
          Height = 21
          TabOrder = 5
        end
      end
    end

    object tabAvaluo: TTabSheet
      Caption = 'Aval'#250'o'
      ImageIndex = 4

      object gbCalculoAvaluo: TGroupBox
        Left = 8
        Top = 8
        Width = 450
        Height = 350
        Caption = 'C'#225'lculo de Aval'#250'o'
        TabOrder = 0
        object btnCalcular: TBitBtn
          Left = 16
          Top = 24
          Width = 120
          Height = 30
          Caption = 'Calcular Aval'#250'o'
          TabOrder = 0
          OnClick = btnCalcularClick
        end
        object lblValorTerrenoBase: TLabel
          Left = 16
          Top = 70
          Width = 100
          Height = 13
          Caption = 'Valor Terreno Base:'
        end
        object edtValorTerrenoBase: TEdit
          Left = 150
          Top = 67
          Width = 120
          Height = 21
          ReadOnly = True
          TabOrder = 1
        end
        object lblValorConstruccionBase: TLabel
          Left = 16
          Top = 98
          Width = 120
          Height = 13
          Caption = 'Valor Construcci'#243'n Base:'
        end
        object edtValorConstruccionBase: TEdit
          Left = 150
          Top = 95
          Width = 120
          Height = 21
          ReadOnly = True
          TabOrder = 2
        end
        object lblCoefZona: TLabel
          Left = 16
          Top = 126
          Width = 60
          Height = 13
          Caption = 'Coef. Zona:'
        end
        object edtCoefZona: TEdit
          Left = 150
          Top = 123
          Width = 80
          Height = 21
          ReadOnly = True
          TabOrder = 3
        end
        object lblCoefUso: TLabel
          Left = 250
          Top = 126
          Width = 55
          Height = 13
          Caption = 'Coef. Uso:'
        end
        object edtCoefUso: TEdit
          Left = 320
          Top = 123
          Width = 80
          Height = 21
          ReadOnly = True
          TabOrder = 4
        end
        object lblCoefEstado: TLabel
          Left = 16
          Top = 154
          Width = 70
          Height = 13
          Caption = 'Coef. Estado:'
        end
        object edtCoefEstado: TEdit
          Left = 150
          Top = 151
          Width = 80
          Height = 21
          ReadOnly = True
          TabOrder = 5
        end
        object lblCoefServicios: TLabel
          Left = 250
          Top = 154
          Width = 75
          Height = 13
          Caption = 'Coef. Servicios:'
        end
        object edtCoefServicios: TEdit
          Left = 320
          Top = 151
          Width = 80
          Height = 21
          ReadOnly = True
          TabOrder = 6
        end
        object lblCoefDepreciacion: TLabel
          Left = 16
          Top = 182
          Width = 95
          Height = 13
          Caption = 'Coef. Depreciaci'#243'n:'
        end
        object edtCoefDepreciacion: TEdit
          Left = 150
          Top = 179
          Width = 80
          Height = 21
          ReadOnly = True
          TabOrder = 7
        end
        object lblValorTerreno: TLabel
          Left = 16
          Top = 220
          Width = 75
          Height = 13
          Caption = 'Valor Terreno:'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtValorTerreno: TEdit
          Left = 150
          Top = 217
          Width = 120
          Height = 21
          ReadOnly = True
          TabOrder = 8
        end
        object lblValorConstruccion: TLabel
          Left = 16
          Top = 248
          Width = 100
          Height = 13
          Caption = 'Valor Construcci'#243'n:'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtValorConstruccion: TEdit
          Left = 150
          Top = 245
          Width = 120
          Height = 21
          ReadOnly = True
          TabOrder = 9
        end
        object lblValorTotal: TLabel
          Left = 16
          Top = 284
          Width = 70
          Height = 13
          Caption = 'VALOR TOTAL:'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtValorTotal: TEdit
          Left = 150
          Top = 281
          Width = 150
          Height = 25
          Font.Size = 12
          Font.Style = [fsBold]
          ParentFont = False
          ReadOnly = True
          TabOrder = 10
        end
      end

      object gbImpuesto: TGroupBox
        Left = 470
        Top = 8
        Width = 400
        Height = 130
        Caption = 'Impuesto'
        TabOrder = 1
        object lblBaseImponible: TLabel
          Left = 16
          Top = 28
          Width = 80
          Height = 13
          Caption = 'Base Imponible:'
        end
        object edtBaseImponible: TEdit
          Left = 120
          Top = 25
          Width = 120
          Height = 21
          ReadOnly = True
          TabOrder = 0
        end
        object lblAlicuota: TLabel
          Left = 16
          Top = 56
          Width = 50
          Height = 13
          Caption = 'Al'#237'cuota %:'
        end
        object edtAlicuota: TEdit
          Left = 120
          Top = 53
          Width = 80
          Height = 21
          ReadOnly = True
          TabOrder = 1
        end
        object lblMontoImpuesto: TLabel
          Left = 16
          Top = 88
          Width = 95
          Height = 13
          Caption = 'Impuesto Anual:'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtMontoImpuesto: TEdit
          Left = 120
          Top = 85
          Width = 150
          Height = 25
          Font.Size = 12
          Font.Style = [fsBold]
          ParentFont = False
          ReadOnly = True
          TabOrder = 2
        end
      end

      object gbExoneracion: TGroupBox
        Left = 470
        Top = 148
        Width = 400
        Height = 130
        Caption = 'Exoneraci'#243'n'
        TabOrder = 2
        object chkExoneracion: TCheckBox
          Left = 16
          Top = 24
          Width = 120
          Height = 17
          Caption = 'Tiene Exoneraci'#243'n'
          TabOrder = 0
          OnClick = chkExoneracionClick
        end
        object lblTipoExoneracion: TLabel
          Left = 16
          Top = 52
          Width = 25
          Height = 13
          Caption = 'Tipo:'
        end
        object cmbTipoExoneracion: TComboBox
          Left = 120
          Top = 49
          Width = 180
          Height = 21
          Enabled = False
          TabOrder = 1
        end
        object lblPorcentajeExon: TLabel
          Left = 16
          Top = 80
          Width = 65
          Height = 13
          Caption = 'Porcentaje %:'
        end
        object edtPorcentajeExon: TEdit
          Left = 120
          Top = 77
          Width = 60
          Height = 21
          Enabled = False
          TabOrder = 2
        end
        object lblMontoConExon: TLabel
          Left = 200
          Top = 80
          Width = 110
          Height = 13
          Caption = 'Monto con Exon.:'
        end
        object edtMontoConExon: TEdit
          Left = 200
          Top = 100
          Width = 100
          Height = 21
          ReadOnly = True
          TabOrder = 3
        end
      end

      object memoDetalle: TMemo
        Left = 8
        Top = 366
        Width = 862
        Height = 190
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 3
      end
    end

    object tabFotos: TTabSheet
      Caption = 'Fotograf'#237'as'
      ImageIndex = 5

      object gbFotos: TGroupBox
        Left = 8
        Top = 8
        Width = 860
        Height = 500
        Caption = 'Fotograf'#237'as del Inmueble'
        TabOrder = 0
        object lblFotoPrincipal: TLabel
          Left = 16
          Top = 24
          Width = 80
          Height = 13
          Caption = 'Foto Principal'
        end
        object imgPrincipal: TImage
          Left = 16
          Top = 44
          Width = 250
          Height = 200
          Proportional = True
          Stretch = True
        end
        object btnCargarFotoPrincipal: TBitBtn
          Left = 16
          Top = 252
          Width = 100
          Height = 25
          Caption = 'Cargar...'
          TabOrder = 0
          OnClick = btnCargarFotoPrincipalClick
        end
        object lblFotoFachada: TLabel
          Left = 290
          Top = 24
          Width = 75
          Height = 13
          Caption = 'Foto Fachada'
        end
        object imgFachada: TImage
          Left = 290
          Top = 44
          Width = 250
          Height = 200
          Proportional = True
          Stretch = True
        end
        object btnCargarFotoFachada: TBitBtn
          Left = 290
          Top = 252
          Width = 100
          Height = 25
          Caption = 'Cargar...'
          TabOrder = 1
          OnClick = btnCargarFotoFachadaClick
        end
        object lblFotoInterior: TLabel
          Left = 564
          Top = 24
          Width = 70
          Height = 13
          Caption = 'Foto Interior'
        end
        object imgInterior: TImage
          Left = 564
          Top = 44
          Width = 250
          Height = 200
          Proportional = True
          Stretch = True
        end
        object btnCargarFotoInterior: TBitBtn
          Left = 564
          Top = 252
          Width = 100
          Height = 25
          Caption = 'Cargar...'
          TabOrder = 2
          OnClick = btnCargarFotoInteriorClick
        end
      end
    end
  end

  object pnlBotones: TPanel
    Left = 0
    Top = 600
    Width = 900
    Height = 50
    Align = alBottom
    TabOrder = 1
    object btnGuardar: TBitBtn
      Left = 680
      Top = 10
      Width = 100
      Height = 30
      Caption = 'Guardar'
      TabOrder = 0
      OnClick = btnGuardarClick
    end
    object btnCancelar: TBitBtn
      Left = 788
      Top = 10
      Width = 100
      Height = 30
      Caption = 'Cancelar'
      TabOrder = 1
      OnClick = btnCancelarClick
    end
    object btnImprimir: TBitBtn
      Left = 16
      Top = 10
      Width = 100
      Height = 30
      Caption = 'Imprimir'
      TabOrder = 2
    end
  end

  object OpenPictureDialog: TOpenPictureDialog
    Filter = 'Imagenes (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp'
    Left = 400
    Top = 8
  end
end
