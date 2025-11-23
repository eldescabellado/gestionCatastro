object dmMain: TdmMain
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 480
  Width = 640
  object FDConnectionPG: TFDConnection
    Params.Strings = (
      'DriverID=PG')
    LoginPrompt = False
    Left = 56
    Top = 24
  end
  object FDConnectionSQLite: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'Database=:memory:')
    LoginPrompt = False
    Left = 168
    Top = 24
  end
  object FDPhysPgDriverLink: TFDPhysPgDriverLink
    Left = 56
    Top = 88
  end
  object FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink
    Left = 168
    Top = 88
  end
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 280
    Top = 88
  end
  object qryGeneral: TFDQuery
    Connection = FDConnectionPG
    Left = 56
    Top = 160
  end
  object qryAuditoria: TFDQuery
    Connection = FDConnectionPG
    Left = 168
    Top = 160
  end
  object qryUsuarios: TFDQuery
    Connection = FDConnectionPG
    Left = 280
    Top = 160
  end
  object qryPermisos: TFDQuery
    Connection = FDConnectionPG
    Left = 392
    Top = 160
  end
  object FDTransactionPG: TFDTransaction
    Connection = FDConnectionPG
    Left = 280
    Top = 24
  end
end
