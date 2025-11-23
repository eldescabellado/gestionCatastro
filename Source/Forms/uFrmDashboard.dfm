object frmDashboard: TfrmDashboard
  Left = 0
  Top = 0
  Caption = 'SIGIEP - Dashboard'
  ClientHeight = 700
  ClientWidth = 1200
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow

  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 1200
    Height = 50
    Align = alTop
    Color = clNavy
    ParentBackground = False
    TabOrder = 0
    object lblUsuario: TLabel
      Left = 16
      Top = 8
      Width = 50
      Height = 13
      Caption = 'Usuario:'
      Font.Color = clWhite
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblRol: TLabel
      Left = 16
      Top = 28
      Width = 20
      Height = 13
      Caption = 'Rol:'
      Font.Color = clWhite
      ParentFont = False
    end
    object lblFechaHora: TLabel
      Left = 900
      Top = 16
      Width = 100
      Height = 13
      Caption = '00/00/0000 00:00:00'
      Font.Color = clWhite
      ParentFont = False
    end
    object btnLogout: TBitBtn
      Left = 1100
      Top = 10
      Width = 85
      Height = 30
      Caption = 'Salir'
      TabOrder = 0
      OnClick = btnLogoutClick
    end
  end

  object pnlMenu: TPanel
    Left = 0
    Top = 50
    Width = 180
    Height = 630
    Align = alLeft
    Color = clGray
    ParentBackground = False
    TabOrder = 1
    object btnContribuyentes: TBitBtn
      Left = 8
      Top = 16
      Width = 160
      Height = 40
      Caption = 'Contribuyentes'
      TabOrder = 0
      OnClick = btnContribuyentesClick
    end
    object btnSolicitudes: TBitBtn
      Left = 8
      Top = 64
      Width = 160
      Height = 40
      Caption = 'Solicitudes'
      TabOrder = 1
      OnClick = btnSolicitudesClick
    end
    object btnFichas: TBitBtn
      Left = 8
      Top = 112
      Width = 160
      Height = 40
      Caption = 'Fichas Catastrales'
      TabOrder = 2
      OnClick = btnFichasClick
    end
    object btnVariables: TBitBtn
      Left = 8
      Top = 160
      Width = 160
      Height = 40
      Caption = 'Variables'
      TabOrder = 3
      OnClick = btnVariablesClick
    end
    object btnReportes: TBitBtn
      Left = 8
      Top = 208
      Width = 160
      Height = 40
      Caption = 'Reportes'
      TabOrder = 4
      OnClick = btnReportesClick
    end
    object btnUsuarios: TBitBtn
      Left = 8
      Top = 280
      Width = 160
      Height = 40
      Caption = 'Usuarios'
      TabOrder = 5
      OnClick = btnUsuariosClick
    end
    object btnConfiguracion: TBitBtn
      Left = 8
      Top = 328
      Width = 160
      Height = 40
      Caption = 'Configuraci'#243'n'
      TabOrder = 6
      OnClick = btnConfiguracionClick
    end
  end

  object pnlMain: TPanel
    Left = 180
    Top = 50
    Width = 1020
    Height = 630
    Align = alClient
    TabOrder = 2

    object pnlContadores: TPanel
      Left = 8
      Top = 8
      Width = 1000
      Height = 80
      TabOrder = 0

      object pnlContSolicitudes: TPanel
        Left = 8
        Top = 8
        Width = 200
        Height = 64
        Color = clSkyBlue
        ParentBackground = False
        TabOrder = 0
        object lblContSolicitudes: TLabel
          Left = 8
          Top = 8
          Width = 20
          Height = 32
          Caption = '0'
          Font.Size = 24
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblTituloSolicitudes: TLabel
          Left = 8
          Top = 44
          Width = 100
          Height = 13
          Caption = 'Solicitudes Pend.'
        end
      end

      object pnlContFichas: TPanel
        Left = 216
        Top = 8
        Width = 200
        Height = 64
        Color = clMoneyGreen
        ParentBackground = False
        TabOrder = 1
        object lblContFichas: TLabel
          Left = 8
          Top = 8
          Width = 20
          Height = 32
          Caption = '0'
          Font.Size = 24
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblTituloFichas: TLabel
          Left = 8
          Top = 44
          Width = 80
          Height = 13
          Caption = 'Fichas Activas'
        end
      end

      object pnlContContribuyentes: TPanel
        Left = 424
        Top = 8
        Width = 200
        Height = 64
        Color = clCream
        ParentBackground = False
        TabOrder = 2
        object lblContContribuyentes: TLabel
          Left = 8
          Top = 8
          Width = 20
          Height = 32
          Caption = '0'
          Font.Size = 24
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblTituloContribuyentes: TLabel
          Left = 8
          Top = 44
          Width = 90
          Height = 13
          Caption = 'Contribuyentes'
        end
      end

      object pnlContRecaudacion: TPanel
        Left = 632
        Top = 8
        Width = 250
        Height = 64
        Color = clInfoBk
        ParentBackground = False
        TabOrder = 3
        object lblContRecaudacion: TLabel
          Left = 8
          Top = 8
          Width = 20
          Height = 32
          Caption = '0'
          Font.Size = 24
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblTituloRecaudacion: TLabel
          Left = 8
          Top = 44
          Width = 120
          Height = 13
          Caption = 'Recaudaci'#243'n Est. (Bs)'
        end
      end
    end

    object pnlGraficoSolicitudes: TPanel
      Left = 8
      Top = 96
      Width = 400
      Height = 250
      TabOrder = 1
      object chartSolicitudes: TChart
        Left = 1
        Top = 1
        Width = 398
        Height = 248
        Align = alClient
        TabOrder = 0
        object serieSolicitudes: TPieSeries
          Marks.Visible = True
          XValues.DateTime = False
          YValues.DateTime = False
        end
      end
    end

    object pnlGraficoRecaudacion: TPanel
      Left = 416
      Top = 96
      Width = 590
      Height = 250
      TabOrder = 2
      object chartRecaudacion: TChart
        Left = 1
        Top = 1
        Width = 588
        Height = 248
        Align = alClient
        TabOrder = 0
        object serieRecaudacion: TBarSeries
          Marks.Visible = False
          XValues.DateTime = False
          YValues.DateTime = False
        end
      end
    end

    object pnlActividad: TPanel
      Left = 8
      Top = 354
      Width = 490
      Height = 260
      TabOrder = 3
      object lblTituloActividad: TLabel
        Left = 8
        Top = 8
        Width = 100
        Height = 13
        Caption = 'Actividad Reciente'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object gridActividad: TDBGrid
        Left = 8
        Top = 28
        Width = 474
        Height = 220
        DataSource = dsBitacora
        ReadOnly = True
        TabOrder = 0
      end
    end

    object pnlSolicitudesPendientes: TPanel
      Left = 506
      Top = 354
      Width = 500
      Height = 260
      TabOrder = 4
      object lblTituloSolPendientes: TLabel
        Left = 8
        Top = 8
        Width = 120
        Height = 13
        Caption = 'Solicitudes Pendientes'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object gridSolicitudesPend: TDBGrid
        Left = 8
        Top = 28
        Width = 484
        Height = 220
        DataSource = dsSolicitudesPend
        ReadOnly = True
        TabOrder = 0
      end
    end
  end

  object StatusBar: TStatusBar
    Left = 0
    Top = 680
    Width = 1200
    Height = 20
    Panels = <
      item
        Width = 200
      end
      item
        Width = 150
      end
      item
        Width = 100
      end>
  end

  object timerActualizacion: TTimer
    Enabled = False
    Interval = 30000
    OnTimer = timerActualizacionTimer
    Left = 400
    Top = 16
  end

  object dsBitacora: TDataSource
    Left = 440
    Top = 16
  end

  object dsSolicitudesPend: TDataSource
    Left = 480
    Top = 16
  end
end
