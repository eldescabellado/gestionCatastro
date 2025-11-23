object frmConfigConexion: TfrmConfigConexion
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Configuraci'#243'n de Conexi'#243'n'
  ClientHeight = 450
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow

  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 420
    Height = 450
    Align = alClient
    Color = clWhite
    ParentBackground = False
    TabOrder = 0

    object lblTitulo: TLabel
      Left = 0
      Top = 16
      Width = 420
      Height = 24
      Alignment = taCenter
      AutoSize = False
      Caption = 'Configuraci'#243'n de Base de Datos'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end

    object lblSubtitulo: TLabel
      Left = 0
      Top = 42
      Width = 420
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'Configure los par'#225'metros de conexi'#243'n a PostgreSQL'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end

    object gbConexion: TGroupBox
      Left = 16
      Top = 70
      Width = 388
      Height = 280
      Caption = 'Par'#225'metros de Conexi'#243'n'
      TabOrder = 0

      object lblServidor: TLabel
        Left = 16
        Top = 28
        Width = 50
        Height = 13
        Caption = 'Servidor:'
      end
      object edtServidor: TEdit
        Left = 100
        Top = 25
        Width = 200
        Height = 21
        TabOrder = 0
        OnChange = edtServidorChange
      end

      object lblPuerto: TLabel
        Left = 16
        Top = 60
        Width = 40
        Height = 13
        Caption = 'Puerto:'
      end
      object edtPuerto: TEdit
        Left = 100
        Top = 57
        Width = 80
        Height = 21
        TabOrder = 1
        OnChange = edtServidorChange
      end

      object lblBaseDatos: TLabel
        Left = 16
        Top = 92
        Width = 75
        Height = 13
        Caption = 'Base de Datos:'
      end
      object edtBaseDatos: TEdit
        Left = 100
        Top = 89
        Width = 200
        Height = 21
        TabOrder = 2
        OnChange = edtServidorChange
      end

      object lblUsuario: TLabel
        Left = 16
        Top = 124
        Width = 45
        Height = 13
        Caption = 'Usuario:'
      end
      object edtUsuario: TEdit
        Left = 100
        Top = 121
        Width = 200
        Height = 21
        TabOrder = 3
        OnChange = edtServidorChange
      end

      object lblPassword: TLabel
        Left = 16
        Top = 156
        Width = 63
        Height = 13
        Caption = 'Contrase'#241'a:'
      end
      object edtPassword: TEdit
        Left = 100
        Top = 153
        Width = 200
        Height = 21
        PasswordChar = '*'
        TabOrder = 4
        OnChange = edtServidorChange
      end

      object chkMostrarPassword: TCheckBox
        Left = 100
        Top = 180
        Width = 140
        Height = 17
        Caption = 'Mostrar contrase'#241'a'
        TabOrder = 5
        OnClick = chkMostrarPasswordClick
      end

      object chkGuardarPassword: TCheckBox
        Left = 100
        Top = 203
        Width = 200
        Height = 17
        Caption = 'Guardar contrase'#241'a (encriptada)'
        Checked = True
        State = cbChecked
        TabOrder = 6
      end

      object ProgressBar: TProgressBar
        Left = 16
        Top = 240
        Width = 356
        Height = 17
        Style = pbstMarquee
        TabOrder = 7
        Visible = False
      end
    end

    object lblEstado: TLabel
      Left = 16
      Top = 358
      Width = 388
      Height = 30
      AutoSize = False
      Font.Color = clGreen
      ParentFont = False
      Visible = False
      WordWrap = True
    end

    object pnlBotones: TPanel
      Left = 0
      Top = 395
      Width = 420
      Height = 55
      Align = alBottom
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1

      object btnProbar: TBitBtn
        Left = 16
        Top = 10
        Width = 120
        Height = 35
        Caption = 'Probar Conexi'#243'n'
        TabOrder = 0
        OnClick = btnProbarClick
      end

      object btnGuardar: TBitBtn
        Left = 168
        Top = 10
        Width = 110
        Height = 35
        Caption = 'Guardar'
        Enabled = False
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnClick = btnGuardarClick
      end

      object btnCancelar: TBitBtn
        Left = 284
        Top = 10
        Width = 110
        Height = 35
        Cancel = True
        Caption = 'Cancelar'
        TabOrder = 2
        OnClick = btnCancelarClick
      end
    end
  end
end
