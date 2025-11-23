object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'SIGIEP - Inicio de Sesi'#243'n'
  ClientHeight = 400
  ClientWidth = 350
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
    Width = 350
    Height = 400
    Align = alClient
    Color = clWhite
    ParentBackground = False
    TabOrder = 0

    object imgLogo: TImage
      Left = 125
      Top = 20
      Width = 100
      Height = 100
      Center = True
      Proportional = True
      Stretch = True
    end

    object lblTitulo: TLabel
      Left = 0
      Top = 130
      Width = 350
      Height = 32
      Alignment = taCenter
      AutoSize = False
      Caption = 'SIGIEP'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end

    object lblSubtitulo: TLabel
      Left = 0
      Top = 162
      Width = 350
      Height = 20
      Alignment = taCenter
      AutoSize = False
      Caption = 'Sistema de Gesti'#243'n Integral de Catastro'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end

    object lblUsuario: TLabel
      Left = 40
      Top = 200
      Width = 45
      Height = 13
      Caption = 'Usuario:'
    end

    object edtUsuario: TEdit
      Left = 40
      Top = 218
      Width = 270
      Height = 25
      Font.Height = -13
      ParentFont = False
      TabOrder = 0
      OnKeyPress = edtUsuarioKeyPress
    end

    object lblPassword: TLabel
      Left = 40
      Top = 252
      Width = 63
      Height = 13
      Caption = 'Contrase'#241'a:'
    end

    object edtPassword: TEdit
      Left = 40
      Top = 270
      Width = 270
      Height = 25
      Font.Height = -13
      ParentFont = False
      PasswordChar = '*'
      TabOrder = 1
      OnKeyPress = edtPasswordKeyPress
    end

    object chkRecordarUsuario: TCheckBox
      Left = 40
      Top = 304
      Width = 150
      Height = 17
      Caption = 'Recordar usuario'
      TabOrder = 2
    end

    object btnLogin: TBitBtn
      Left = 40
      Top = 335
      Width = 130
      Height = 35
      Caption = 'Ingresar'
      Default = True
      Font.Height = -13
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = btnLoginClick
    end

    object btnCancelar: TBitBtn
      Left = 180
      Top = 335
      Width = 130
      Height = 35
      Cancel = True
      Caption = 'Cancelar'
      Font.Height = -13
      ParentFont = False
      TabOrder = 4
      OnClick = btnCancelarClick
    end

    object lblMensaje: TLabel
      Left = 40
      Top = 378
      Width = 270
      Height = 13
      AutoSize = False
      Font.Color = clRed
      ParentFont = False
      Visible = False
      WordWrap = True
    end

    object lblVersion: TLabel
      Left = 280
      Top = 380
      Width = 60
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'v1.0.0'
      Font.Color = clGray
      Font.Size = 7
      ParentFont = False
    end
  end
end
