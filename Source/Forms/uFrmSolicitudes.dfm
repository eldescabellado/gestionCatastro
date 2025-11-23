object frmSolicitudes: TfrmSolicitudes
  Left = 0
  Top = 0
  Caption = 'SIGIEP - Gesti'#243'n de Solicitudes'
  ClientHeight = 600
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 13
  object pnlBusqueda: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 49
    Align = alTop
    TabOrder = 0
    object lblBuscar: TLabel
      Left = 16
      Top = 16
      Width = 36
      Height = 13
      Caption = 'Buscar:'
    end
    object lblFiltroEstado: TLabel
      Left = 400
      Top = 16
      Width = 36
      Height = 13
      Caption = 'Estado:'
    end
    object edtBuscar: TEdit
      Left = 58
      Top = 13
      Width = 200
      Height = 21
      TabOrder = 0
      OnKeyPress = edtBuscarKeyPress
    end
    object btnBuscar: TBitBtn
      Left = 264
      Top = 11
      Width = 75
      Height = 25
      Caption = 'Buscar'
      TabOrder = 1
      OnClick = btnBuscarClick
    end
    object btnNueva: TBitBtn
      Left = 808
      Top = 11
      Width = 75
      Height = 25
      Caption = 'Nueva'
      TabOrder = 2
      OnClick = btnNuevaClick
    end
    object cmbFiltroEstado: TComboBox
      Left = 442
      Top = 13
      Width = 145
      Height = 21
      Style = csDropDownList
      TabOrder = 3
      OnChange = cmbFiltroEstadoChange
    end
  end
  object pnlPrincipal: TPanel
    Left = 0
    Top = 49
    Width = 900
    Height = 510
    Align = alClient
    TabOrder = 1
    object pnlListado: TPanel
      Left = 1
      Top = 1
      Width = 898
      Height = 508
      Align = alClient
      TabOrder = 0
      object gridSolicitudes: TDBGrid
        Left = 1
        Top = 1
        Width = 896
        Height = 506
        Align = alClient
        DataSource = dsSolicitudes
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        OnDblClick = gridSolicitudesDblClick
      end
    end
    object pnlDetalle: TPanel
      Left = 1
      Top = 1
      Width = 898
      Height = 508
      Align = alClient
      TabOrder = 1
      Visible = False
      object pcDetalle: TPageControl
        Left = 1
        Top = 1
        Width = 896
        Height = 506
        ActivePage = tabGeneral
        Align = alClient
        TabOrder = 0
        object tabGeneral: TTabSheet
          Caption = 'Datos Generales'
          object gbSolicitud: TGroupBox
            Left = 3
            Top = 3
            Width = 433
            Height = 145
            Caption = ' Solicitud '
            TabOrder = 0
            object lblNumExpediente: TLabel
              Left = 16
              Top = 24
              Width = 57
              Height = 13
              Caption = 'Expediente:'
            end
            object lblTipoSolicitud: TLabel
              Left = 16
              Top = 56
              Width = 26
              Height = 13
              Caption = 'Tipo:'
            end
            object lblFechaSolicitud: TLabel
              Left = 240
              Top = 24
              Width = 33
              Height = 13
              Caption = 'Fecha:'
            end
            object lblEstado: TLabel
              Left = 240
              Top = 56
              Width = 36
              Height = 13
              Caption = 'Estado:'
            end
            object lblPrioridad: TLabel
              Left = 16
              Top = 88
              Width = 47
              Height = 13
              Caption = 'Prioridad:'
            end
            object edtNumExpediente: TEdit
              Left = 88
              Top = 21
              Width = 130
              Height = 21
              ReadOnly = True
              TabOrder = 0
            end
            object cmbTipoSolicitud: TComboBox
              Left = 88
              Top = 53
              Width = 130
              Height = 21
              Style = csDropDownList
              TabOrder = 1
            end
            object edtFechaSolicitud: TEdit
              Left = 296
              Top = 21
              Width = 121
              Height = 21
              ReadOnly = True
              TabOrder = 2
            end
            object edtEstado: TEdit
              Left = 296
              Top = 53
              Width = 121
              Height = 21
              ReadOnly = True
              TabOrder = 3
            end
            object cmbPrioridad: TComboBox
              Left = 88
              Top = 85
              Width = 130
              Height = 21
              Style = csDropDownList
              TabOrder = 4
            end
          end
          object gbContribuyente: TGroupBox
            Left = 3
            Top = 154
            Width = 433
            Height = 145
            Caption = ' Contribuyente '
            TabOrder = 1
            object lblContribuyente: TLabel
              Left = 16
              Top = 24
              Width = 39
              Height = 13
              Caption = 'Nombre:'
            end
            object lblRIF: TLabel
              Left = 16
              Top = 56
              Width = 18
              Height = 13
              Caption = 'RIF:'
            end
            object lblCedula: TLabel
              Left = 160
              Top = 56
              Width = 39
              Height = 13
              Caption = 'C'#233'dula:'
            end
            object lblTelefono: TLabel
              Left = 16
              Top = 88
              Width = 45
              Height = 13
              Caption = 'Tel'#233'fono:'
            end
            object edtContribuyente: TEdit
              Left = 88
              Top = 21
              Width = 233
              Height = 21
              ReadOnly = True
              TabOrder = 0
            end
            object btnSeleccionarContribuyente: TBitBtn
              Left = 327
              Top = 19
              Width = 41
              Height = 25
              Caption = '...'
              TabOrder = 1
              OnClick = btnSeleccionarContribuyenteClick
            end
            object btnNuevoContribuyente: TBitBtn
              Left = 374
              Top = 19
              Width = 41
              Height = 25
              Caption = '+'
              TabOrder = 2
              OnClick = btnNuevoContribuyenteClick
            end
            object edtRIF: TEdit
              Left = 40
              Top = 53
              Width = 105
              Height = 21
              ReadOnly = True
              TabOrder = 3
            end
            object edtCedula: TEdit
              Left = 205
              Top = 53
              Width = 105
              Height = 21
              ReadOnly = True
              TabOrder = 4
            end
            object edtTelefono: TEdit
              Left = 88
              Top = 85
              Width = 130
              Height = 21
              ReadOnly = True
              TabOrder = 5
            end
          end
          object gbObservaciones: TGroupBox
            Left = 442
            Top = 3
            Width = 433
            Height = 296
            Caption = ' Observaciones '
            TabOrder = 2
            object memObservaciones: TMemo
              Left = 16
              Top = 24
              Width = 401
              Height = 257
              TabOrder = 0
            end
          end
        end
        object tabWorkflow: TTabSheet
          Caption = 'Workflow'
          ImageIndex = 1
          object gbAsignaciones: TGroupBox
            Left = 3
            Top = 3
            Width = 433
            Height = 177
            Caption = ' Asignaciones '
            TabOrder = 0
            object lblReceptor: TLabel
              Left = 16
              Top = 32
              Width = 48
              Height = 13
              Caption = 'Receptor:'
            end
            object lblRevisor: TLabel
              Left = 16
              Top = 64
              Width = 39
              Height = 13
              Caption = 'Revisor:'
            end
            object lblInspector: TLabel
              Left = 16
              Top = 96
              Width = 48
              Height = 13
              Caption = 'Inspector:'
            end
            object lblAprobador: TLabel
              Left = 16
              Top = 128
              Width = 53
              Height = 13
              Caption = 'Aprobador:'
            end
            object cmbReceptor: TComboBox
              Left = 88
              Top = 29
              Width = 329
              Height = 21
              Style = csDropDownList
              Enabled = False
              TabOrder = 0
            end
            object cmbRevisor: TComboBox
              Left = 88
              Top = 61
              Width = 329
              Height = 21
              Style = csDropDownList
              Enabled = False
              TabOrder = 1
            end
            object cmbInspector: TComboBox
              Left = 88
              Top = 93
              Width = 329
              Height = 21
              Style = csDropDownList
              Enabled = False
              TabOrder = 2
            end
            object cmbAprobador: TComboBox
              Left = 88
              Top = 125
              Width = 329
              Height = 21
              Style = csDropDownList
              Enabled = False
              TabOrder = 3
            end
          end
          object gbFechas: TGroupBox
            Left = 442
            Top = 3
            Width = 433
            Height = 177
            Caption = ' Fechas del Proceso '
            TabOrder = 1
            object lblFechaRecepcion: TLabel
              Left = 16
              Top = 32
              Width = 53
              Height = 13
              Caption = 'Recepci'#243'n:'
            end
            object lblFechaAsignacion: TLabel
              Left = 16
              Top = 64
              Width = 55
              Height = 13
              Caption = 'Asignaci'#243'n:'
            end
            object lblFechaInspeccion: TLabel
              Left = 16
              Top = 96
              Width = 55
              Height = 13
              Caption = 'Inspecci'#243'n:'
            end
            object lblFechaResolucion: TLabel
              Left = 16
              Top = 128
              Width = 54
              Height = 13
              Caption = 'Resoluci'#243'n:'
            end
            object edtFechaRecepcion: TEdit
              Left = 88
              Top = 29
              Width = 150
              Height = 21
              ReadOnly = True
              TabOrder = 0
            end
            object edtFechaAsignacion: TEdit
              Left = 88
              Top = 61
              Width = 150
              Height = 21
              ReadOnly = True
              TabOrder = 1
            end
            object edtFechaInspeccion: TEdit
              Left = 88
              Top = 93
              Width = 150
              Height = 21
              ReadOnly = True
              TabOrder = 2
            end
            object edtFechaResolucion: TEdit
              Left = 88
              Top = 125
              Width = 150
              Height = 21
              ReadOnly = True
              TabOrder = 3
            end
          end
          object gbAcciones: TGroupBox
            Left = 3
            Top = 186
            Width = 872
            Height = 73
            Caption = ' Acciones de Workflow '
            TabOrder = 2
            object btnRecibir: TBitBtn
              Left = 16
              Top = 28
              Width = 100
              Height = 33
              Caption = 'Recibir'
              TabOrder = 0
              OnClick = btnRecibirClick
            end
            object btnAsignar: TBitBtn
              Left = 132
              Top = 28
              Width = 100
              Height = 33
              Caption = 'Asignar'
              TabOrder = 1
              OnClick = btnAsignarClick
            end
            object btnInspeccionar: TBitBtn
              Left = 248
              Top = 28
              Width = 100
              Height = 33
              Caption = 'Inspeccionar'
              TabOrder = 2
              OnClick = btnInspeccionarClick
            end
            object btnAprobar: TBitBtn
              Left = 364
              Top = 28
              Width = 100
              Height = 33
              Caption = 'Aprobar'
              TabOrder = 3
              OnClick = btnAprobarClick
            end
            object btnRechazar: TBitBtn
              Left = 480
              Top = 28
              Width = 100
              Height = 33
              Caption = 'Rechazar'
              TabOrder = 4
              OnClick = btnRechazarClick
            end
          end
        end
        object tabFicha: TTabSheet
          Caption = 'Ficha Catastral'
          ImageIndex = 2
          object gbFicha: TGroupBox
            Left = 3
            Top = 3
            Width = 433
            Height = 145
            Caption = ' Ficha Catastral Asociada '
            TabOrder = 0
            object lblFichaAsociada: TLabel
              Left = 16
              Top = 32
              Width = 35
              Height = 13
              Caption = 'C'#243'digo:'
            end
            object edtFichaAsociada: TEdit
              Left = 88
              Top = 29
              Width = 200
              Height = 21
              ReadOnly = True
              TabOrder = 0
            end
            object btnCrearFicha: TBitBtn
              Left = 16
              Top = 72
              Width = 120
              Height = 33
              Caption = 'Crear Ficha'
              TabOrder = 1
              OnClick = btnCrearFichaClick
            end
            object btnVerFicha: TBitBtn
              Left = 152
              Top = 72
              Width = 120
              Height = 33
              Caption = 'Ver Ficha'
              TabOrder = 2
              OnClick = btnVerFichaClick
            end
            object btnImprimirFicha: TBitBtn
              Left = 288
              Top = 72
              Width = 120
              Height = 33
              Caption = 'Imprimir Ficha'
              TabOrder = 3
              OnClick = btnImprimirFichaClick
            end
          end
        end
        object tabHistorial: TTabSheet
          Caption = 'Historial'
          ImageIndex = 3
          object gridHistorial: TDBGrid
            Left = 0
            Top = 0
            Width = 878
            Height = 470
            Align = alClient
            DataSource = dsHistorial
            Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
            ReadOnly = True
            TabOrder = 0
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
          end
        end
      end
    end
  end
  object pnlBotonesDetalle: TPanel
    Left = 0
    Top = 559
    Width = 900
    Height = 41
    Align = alBottom
    TabOrder = 2
    Visible = False
    object btnGuardar: TBitBtn
      Left = 616
      Top = 8
      Width = 85
      Height = 25
      Caption = 'Guardar'
      TabOrder = 0
      OnClick = btnGuardarClick
    end
    object btnCancelar: TBitBtn
      Left = 707
      Top = 8
      Width = 85
      Height = 25
      Caption = 'Cancelar'
      TabOrder = 1
      OnClick = btnCancelarClick
    end
    object btnEditar: TBitBtn
      Left = 428
      Top = 8
      Width = 85
      Height = 25
      Caption = 'Editar'
      TabOrder = 2
      OnClick = btnEditarClick
    end
    object btnAnular: TBitBtn
      Left = 519
      Top = 8
      Width = 85
      Height = 25
      Caption = 'Anular'
      TabOrder = 3
      OnClick = btnAnularClick
    end
  end
  object pnlBotonesListado: TPanel
    Left = 0
    Top = 559
    Width = 900
    Height = 41
    Align = alBottom
    TabOrder = 3
    object btnCerrar: TBitBtn
      Left = 808
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Cerrar'
      TabOrder = 0
      OnClick = btnCerrarClick
    end
  end
  object dsSolicitudes: TDataSource
    Left = 40
    Top = 528
  end
  object dsHistorial: TDataSource
    Left = 112
    Top = 528
  end
end
