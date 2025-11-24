object frmContribuyentes: TfrmContribuyentes
  Left = 0
  Top = 0
  Caption = 'SIGIEP - Gesti'#243'n de Contribuyentes'
  ClientHeight = 600
  ClientWidth = 950
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

  object pnlBusqueda: TPanel
    Left = 0
    Top = 0
    Width = 950
    Height = 50
    Align = alTop
    Color = clWhite
    ParentBackground = False
    TabOrder = 0

    object lblBuscar: TLabel
      Left = 16
      Top = 17
      Width = 40
      Height = 13
      Caption = 'Buscar:'
    end
    object edtBuscar: TEdit
      Left = 65
      Top = 14
      Width = 250
      Height = 21
      TabOrder = 0
      OnKeyPress = edtBuscarKeyPress
    end
    object cmbFiltroBusqueda: TComboBox
      Left = 325
      Top = 14
      Width = 150
      Height = 21
      TabOrder = 1
      Text = 'Todos los campos'
    end
    object btnBuscar: TBitBtn
      Left = 490
      Top = 11
      Width = 80
      Height = 28
      Caption = 'Buscar'
      TabOrder = 2
      OnClick = btnBuscarClick
    end
    object btnNuevo: TBitBtn
      Left = 850
      Top = 11
      Width = 85
      Height = 28
      Caption = 'Nuevo'
      TabOrder = 3
      OnClick = btnNuevoClick
    end
  end

  object pnlPrincipal: TPanel
    Left = 0
    Top = 50
    Width = 950
    Height = 500
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1

    object pnlListado: TPanel
      Left = 0
      Top = 0
      Width = 950
      Height = 500
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0

      object gridContribuyentes: TDBGrid
        Left = 0
        Top = 0
        Width = 950
        Height = 500
        Align = alClient
        DataSource = dsContribuyentes
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = [fsBold]
        OnDblClick = gridContribuyentesDblClick
      end
    end

    object pnlDetalle: TPanel
      Left = 0
      Top = 0
      Width = 950
      Height = 500
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      Visible = False

      object gbIdentificacion: TGroupBox
        Left = 8
        Top = 8
        Width = 450
        Height = 90
        Caption = 'Identificaci'#243'n'
        TabOrder = 0

        object lblTipoPersona: TLabel
          Left = 16
          Top = 28
          Width = 75
          Height = 13
          Caption = 'Tipo Persona:'
        end
        object cmbTipoPersona: TComboBox
          Left = 100
          Top = 25
          Width = 120
          Height = 21
          TabOrder = 0
          OnChange = cmbTipoPersonaChange
        end
        object lblRIF: TLabel
          Left = 240
          Top = 28
          Width = 20
          Height = 13
          Caption = 'RIF:'
        end
        object edtRIF: TEdit
          Left = 270
          Top = 25
          Width = 150
          Height = 21
          CharCase = ecUpperCase
          TabOrder = 1
          OnExit = edtRIFExit
        end
        object lblCedula: TLabel
          Left = 16
          Top = 60
          Width = 41
          Height = 13
          Caption = 'C'#233'dula:'
        end
        object edtCedula: TEdit
          Left = 100
          Top = 57
          Width = 120
          Height = 21
          TabOrder = 2
        end
      end

      object gbDatosPersonales: TGroupBox
        Left = 470
        Top = 8
        Width = 470
        Height = 90
        Caption = 'Datos Personales'
        TabOrder = 1

        object lblNombre: TLabel
          Left = 16
          Top = 28
          Width = 46
          Height = 13
          Caption = 'Nombre:'
        end
        object edtNombre: TEdit
          Left = 80
          Top = 25
          Width = 150
          Height = 21
          TabOrder = 0
        end
        object lblApellido: TLabel
          Left = 250
          Top = 28
          Width = 45
          Height = 13
          Caption = 'Apellido:'
        end
        object edtApellido: TEdit
          Left = 310
          Top = 25
          Width = 150
          Height = 21
          TabOrder = 1
        end
        object lblRazonSocial: TLabel
          Left = 16
          Top = 60
          Width = 68
          Height = 13
          Caption = 'Raz'#243'n Social:'
        end
        object edtRazonSocial: TEdit
          Left = 100
          Top = 57
          Width = 360
          Height = 21
          TabOrder = 2
        end
      end

      object gbContacto: TGroupBox
        Left = 8
        Top = 108
        Width = 450
        Height = 90
        Caption = 'Contacto'
        TabOrder = 2

        object lblTelefono: TLabel
          Left = 16
          Top = 28
          Width = 48
          Height = 13
          Caption = 'Tel'#233'fono:'
        end
        object edtTelefono: TEdit
          Left = 80
          Top = 25
          Width = 130
          Height = 21
          TabOrder = 0
        end
        object lblCelular: TLabel
          Left = 230
          Top = 28
          Width = 38
          Height = 13
          Caption = 'Celular:'
        end
        object edtCelular: TEdit
          Left = 280
          Top = 25
          Width = 130
          Height = 21
          TabOrder = 1
        end
        object lblEmail: TLabel
          Left = 16
          Top = 60
          Width = 30
          Height = 13
          Caption = 'Email:'
        end
        object edtEmail: TEdit
          Left = 80
          Top = 57
          Width = 330
          Height = 21
          TabOrder = 2
        end
      end

      object gbDomicilio: TGroupBox
        Left = 8
        Top = 208
        Width = 932
        Height = 180
        Caption = 'Domicilio'
        TabOrder = 3

        object lblDireccion: TLabel
          Left = 16
          Top = 28
          Width = 52
          Height = 13
          Caption = 'Direcci'#243'n:'
        end
        object memDireccion: TMemo
          Left = 80
          Top = 25
          Width = 840
          Height = 60
          TabOrder = 0
        end
        object lblEstado: TLabel
          Left = 16
          Top = 100
          Width = 40
          Height = 13
          Caption = 'Estado:'
        end
        object cmbEstado: TComboBox
          Left = 80
          Top = 97
          Width = 180
          Height = 21
          TabOrder = 1
          OnChange = cmbEstadoChange
        end
        object lblMunicipio: TLabel
          Left = 280
          Top = 100
          Width = 55
          Height = 13
          Caption = 'Municipio:'
        end
        object cmbMunicipio: TComboBox
          Left = 350
          Top = 97
          Width = 180
          Height = 21
          TabOrder = 2
          OnChange = cmbMunicipioChange
        end
        object lblParroquia: TLabel
          Left = 550
          Top = 100
          Width = 55
          Height = 13
          Caption = 'Parroquia:'
        end
        object cmbParroquia: TComboBox
          Left = 620
          Top = 97
          Width = 180
          Height = 21
          TabOrder = 3
          OnChange = cmbParroquiaChange
        end
        object lblCiudad: TLabel
          Left = 16
          Top = 140
          Width = 40
          Height = 13
          Caption = 'Ciudad:'
        end
        object cmbCiudad: TComboBox
          Left = 80
          Top = 137
          Width = 180
          Height = 21
          TabOrder = 4
          OnChange = cmbCiudadChange
        end
        object lblSector: TLabel
          Left = 280
          Top = 140
          Width = 35
          Height = 13
          Caption = 'Sector:'
        end
        object cmbSector: TComboBox
          Left = 350
          Top = 137
          Width = 180
          Height = 21
          TabOrder = 5
        end
        object lblCodigoPostal: TLabel
          Left = 550
          Top = 140
          Width = 45
          Height = 13
          Caption = 'C'#243'd.Post:'
        end
        object edtCodigoPostal: TEdit
          Left = 620
          Top = 137
          Width = 80
          Height = 21
          TabOrder = 6
        end
      end

      object gbEstado: TGroupBox
        Left = 470
        Top = 108
        Width = 470
        Height = 90
        Caption = 'Estado'
        TabOrder = 4

        object chkActivo: TCheckBox
          Left = 16
          Top = 28
          Width = 97
          Height = 17
          Caption = 'Activo'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object lblFechaRegistro: TLabel
          Left = 16
          Top = 60
          Width = 80
          Height = 13
          Caption = 'Fecha Registro:'
        end
        object edtFechaRegistro: TEdit
          Left = 110
          Top = 57
          Width = 100
          Height = 21
          ReadOnly = True
          TabOrder = 1
        end
      end

      object pnlBotonesDetalle: TPanel
        Left = 0
        Top = 400
        Width = 950
        Height = 50
        BevelOuter = bvNone
        TabOrder = 5

        object btnGuardar: TBitBtn
          Left = 700
          Top = 10
          Width = 100
          Height = 30
          Caption = 'Guardar'
          TabOrder = 0
          OnClick = btnGuardarClick
        end
        object btnCancelar: TBitBtn
          Left = 810
          Top = 10
          Width = 100
          Height = 30
          Caption = 'Cancelar'
          TabOrder = 1
          OnClick = btnCancelarClick
        end
        object btnEditar: TBitBtn
          Left = 480
          Top = 10
          Width = 100
          Height = 30
          Caption = 'Editar'
          TabOrder = 2
          OnClick = btnEditarClick
        end
        object btnEliminar: TBitBtn
          Left = 590
          Top = 10
          Width = 100
          Height = 30
          Caption = 'Eliminar'
          TabOrder = 3
          OnClick = btnEliminarClick
        end
      end
    end
  end

  object pnlBotonesListado: TPanel
    Left = 0
    Top = 550
    Width = 950
    Height = 50
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2

    object btnVerFichas: TBitBtn
      Left = 16
      Top = 10
      Width = 120
      Height = 30
      Caption = 'Ver Fichas'
      TabOrder = 0
      OnClick = btnVerFichasClick
    end
    object btnVerSolicitudes: TBitBtn
      Left = 150
      Top = 10
      Width = 120
      Height = 30
      Caption = 'Ver Solicitudes'
      TabOrder = 1
      OnClick = btnVerSolicitudesClick
    end
    object btnCerrar: TBitBtn
      Left = 830
      Top = 10
      Width = 100
      Height = 30
      Caption = 'Cerrar'
      TabOrder = 2
      OnClick = btnCerrarClick
    end
  end

  object dsContribuyentes: TDataSource
    Left = 400
    Top = 300
  end
end
