unit uCalculoCatastral;

interface

uses
  System.SysUtils, System.Classes, System.Math, System.Generics.Collections,
  FireDAC.Comp.Client, FireDAC.Stan.Param, Data.DB;

type
  // Estructura de datos de la Ficha para cálculo
  TDatosFicha = record
    FichaID: Integer;
    CodigoCatastral: string;

    // Terreno
    AreaTerreno: Double;
    UsoTerreno: string;
    ClasificacionZona: string;
    TopografiaTerreno: string;
    FormaTerreno: string;

    // Construcción
    AreaConstruccion: Double;
    TipoConstruccion: string;
    EstadoConstruccion: string;
    AnioConstruccion: Integer;
    CalidadAcabados: Integer;

    // Servicios
    TieneAgua: Boolean;
    TieneElectricidad: Boolean;
    TieneCloacas: Boolean;
    TieneAseo: Boolean;
    TieneGas: Boolean;
    TieneAceras: Boolean;
    TieneAlumbrado: Boolean;
    TieneAsfalto: Boolean;

    // Exoneración
    TieneExoneracion: Boolean;
    PorcentajeExoneracion: Double;
  end;

  // Resultado del cálculo
  TResultadoAvaluo = record
    // Valores base
    ValorTerrenoBase: Double;
    ValorConstruccionBase: Double;

    // Coeficientes aplicados
    CoeficienteZona: Double;
    CoeficienteUso: Double;
    CoeficienteEstado: Double;
    CoeficienteServicios: Double;
    CoeficienteDepreciacion: Double;

    // Valores finales
    ValorTerreno: Double;
    ValorConstruccion: Double;
    ValorTotal: Double;

    // Impuesto
    BaseImponible: Double;
    Alicuota: Double;
    MontoImpuestoAnual: Double;
    MontoConExoneracion: Double;

    // Desglose para reporte
    DetalleCalculo: string;
  end;

  // Diccionario de variables
  TVariableCalculo = record
    Codigo: string;
    Nombre: string;
    ValorNumerico: Double;
    ValorPorcentaje: Double;
    UnidadMedida: string;
  end;

  // Clase principal de cálculo catastral
  TCalculoCatastral = class
  private
    FConnectionPG: TFDConnection;
    FConnectionSQLite: TFDConnection;
    FVariables: TDictionary<string, TVariableCalculo>;
    FAnioFiscal: Integer;
    FVariablesCargadas: Boolean;

    // Queries
    FQueryPG: TFDQuery;
    FQuerySQLite: TFDQuery;

    procedure CrearTablasEnMemoria;
    procedure CargarVariablesDesdePostgreSQL;

    function ObtenerVariable(const Codigo: string): Double;
    function CalcularCoeficienteZona(const ClasificacionZona: string): Double;
    function CalcularCoeficienteUso(const UsoTerreno: string): Double;
    function CalcularCoeficienteEstado(const EstadoConstruccion: string): Double;
    function CalcularCoeficienteServicios(const Ficha: TDatosFicha): Double;
    function CalcularCoeficienteDepreciacion(AnioConstruccion: Integer): Double;
    function ObtenerAlicuota(const UsoTerreno: string): Double;
    function DeterminarTipoTerrenoVariable(const UsoTerreno: string): string;
    function DeterminarTipoConstruccionVariable(CalidadAcabados: Integer): string;

  public
    constructor Create(AConnectionPG, AConnectionSQLite: TFDConnection);
    destructor Destroy; override;

    // Cargar variables (debe llamarse al iniciar sesión)
    procedure CargarVariables;
    procedure RecargarVariables;

    // Cálculo principal
    function CalcularAvaluo(const Ficha: TDatosFicha): TResultadoAvaluo;

    // Cálculos individuales (para UI en tiempo real)
    function CalcularValorTerreno(AreaTerreno: Double; const UsoTerreno, ClasificacionZona: string): Double;
    function CalcularValorConstruccion(AreaConstruccion: Double; CalidadAcabados: Integer;
      const EstadoConstruccion: string; AnioConstruccion: Integer): Double;

    // Utilidades
    function ObtenerVariablesCategoria(const Categoria: string): TArray<TVariableCalculo>;
    function VariableExiste(const Codigo: string): Boolean;

    // Propiedades
    property AnioFiscal: Integer read FAnioFiscal write FAnioFiscal;
    property VariablesCargadas: Boolean read FVariablesCargadas;
  end;

implementation

uses
  System.DateUtils;

{ TCalculoCatastral }

constructor TCalculoCatastral.Create(AConnectionPG, AConnectionSQLite: TFDConnection);
begin
  inherited Create;
  FConnectionPG := AConnectionPG;
  FConnectionSQLite := AConnectionSQLite;
  FVariables := TDictionary<string, TVariableCalculo>.Create;
  FAnioFiscal := YearOf(Now);
  FVariablesCargadas := False;

  FQueryPG := TFDQuery.Create(nil);
  FQueryPG.Connection := FConnectionPG;

  FQuerySQLite := TFDQuery.Create(nil);
  FQuerySQLite.Connection := FConnectionSQLite;
end;

destructor TCalculoCatastral.Destroy;
begin
  FVariables.Free;
  FQueryPG.Free;
  FQuerySQLite.Free;
  inherited;
end;

procedure TCalculoCatastral.CrearTablasEnMemoria;
begin
  // Crear tabla de variables en SQLite memoria
  FQuerySQLite.SQL.Text :=
    'CREATE TABLE IF NOT EXISTS VariablesCalculo (' +
    '  VariableID INTEGER PRIMARY KEY, ' +
    '  Codigo TEXT NOT NULL UNIQUE, ' +
    '  Nombre TEXT, ' +
    '  ValorNumerico REAL, ' +
    '  ValorPorcentaje REAL, ' +
    '  UnidadMedida TEXT, ' +
    '  Categoria TEXT ' +
    ')';
  FQuerySQLite.ExecSQL;

  // Crear índice
  FQuerySQLite.SQL.Text :=
    'CREATE INDEX IF NOT EXISTS idx_var_codigo ON VariablesCalculo(Codigo)';
  FQuerySQLite.ExecSQL;

  // Crear tabla para cálculos temporales
  FQuerySQLite.SQL.Text :=
    'CREATE TABLE IF NOT EXISTS CalculosTemp (' +
    '  CalculoID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
    '  FichaID INTEGER, ' +
    '  FechaCalculo TEXT, ' +
    '  ValorTerreno REAL, ' +
    '  ValorConstruccion REAL, ' +
    '  ValorTotal REAL, ' +
    '  DetalleJSON TEXT ' +
    ')';
  FQuerySQLite.ExecSQL;
end;

procedure TCalculoCatastral.CargarVariablesDesdePostgreSQL;
var
  Variable: TVariableCalculo;
begin
  // Limpiar variables anteriores
  FVariables.Clear;

  // Limpiar tabla SQLite
  FQuerySQLite.SQL.Text := 'DELETE FROM VariablesCalculo';
  FQuerySQLite.ExecSQL;

  // Cargar desde PostgreSQL
  FQueryPG.SQL.Text :=
    'SELECT v.VariableID, v.Codigo, v.Nombre, v.ValorNumerico, v.ValorPorcentaje, ' +
    '       v.UnidadMedida, c.Codigo AS Categoria ' +
    'FROM VariablesCalculo v ' +
    'LEFT JOIN CategoriasVariable c ON v.CategoriaID = c.CategoriaID ' +
    'WHERE v.Activo = TRUE ' +
    '  AND v.AnioFiscal = :AnioFiscal ' +
    '  AND (v.FechaFinVigencia IS NULL OR v.FechaFinVigencia >= CURRENT_DATE)';
  FQueryPG.ParamByName('AnioFiscal').AsInteger := FAnioFiscal;
  FQueryPG.Open;

  // Insertar en SQLite y diccionario
  while not FQueryPG.Eof do
  begin
    Variable.Codigo := FQueryPG.FieldByName('Codigo').AsString;
    Variable.Nombre := FQueryPG.FieldByName('Nombre').AsString;
    Variable.ValorNumerico := FQueryPG.FieldByName('ValorNumerico').AsFloat;
    Variable.ValorPorcentaje := FQueryPG.FieldByName('ValorPorcentaje').AsFloat;
    Variable.UnidadMedida := FQueryPG.FieldByName('UnidadMedida').AsString;

    // Agregar al diccionario
    FVariables.AddOrSetValue(Variable.Codigo, Variable);

    // Insertar en SQLite
    FQuerySQLite.SQL.Text :=
      'INSERT INTO VariablesCalculo (VariableID, Codigo, Nombre, ValorNumerico, ValorPorcentaje, UnidadMedida, Categoria) ' +
      'VALUES (:ID, :Codigo, :Nombre, :ValorNum, :ValorPorc, :Unidad, :Cat)';
    FQuerySQLite.ParamByName('ID').AsInteger := FQueryPG.FieldByName('VariableID').AsInteger;
    FQuerySQLite.ParamByName('Codigo').AsString := Variable.Codigo;
    FQuerySQLite.ParamByName('Nombre').AsString := Variable.Nombre;
    FQuerySQLite.ParamByName('ValorNum').AsFloat := Variable.ValorNumerico;
    FQuerySQLite.ParamByName('ValorPorc').AsFloat := Variable.ValorPorcentaje;
    FQuerySQLite.ParamByName('Unidad').AsString := Variable.UnidadMedida;
    FQuerySQLite.ParamByName('Cat').AsString := FQueryPG.FieldByName('Categoria').AsString;
    FQuerySQLite.ExecSQL;

    FQueryPG.Next;
  end;

  FVariablesCargadas := True;
end;

procedure TCalculoCatastral.CargarVariables;
begin
  CrearTablasEnMemoria;
  CargarVariablesDesdePostgreSQL;
end;

procedure TCalculoCatastral.RecargarVariables;
begin
  CargarVariablesDesdePostgreSQL;
end;

function TCalculoCatastral.ObtenerVariable(const Codigo: string): Double;
var
  Variable: TVariableCalculo;
begin
  if FVariables.TryGetValue(Codigo, Variable) then
    Result := Variable.ValorNumerico
  else
    Result := 0;
end;

function TCalculoCatastral.VariableExiste(const Codigo: string): Boolean;
begin
  Result := FVariables.ContainsKey(Codigo);
end;

function TCalculoCatastral.DeterminarTipoTerrenoVariable(const UsoTerreno: string): string;
begin
  if UsoTerreno = 'RESIDENCIAL' then
    Result := 'TERRENO_RESIDENCIAL'
  else if UsoTerreno = 'COMERCIAL' then
    Result := 'TERRENO_COMERCIAL'
  else if UsoTerreno = 'INDUSTRIAL' then
    Result := 'TERRENO_INDUSTRIAL'
  else if UsoTerreno = 'AGRICOLA' then
    Result := 'TERRENO_AGRICOLA'
  else
    Result := 'TERRENO_RESIDENCIAL';
end;

function TCalculoCatastral.DeterminarTipoConstruccionVariable(CalidadAcabados: Integer): string;
begin
  case CalidadAcabados of
    5: Result := 'CONST_LUJO';
    4: Result := 'CONST_PRIMERA';
    3: Result := 'CONST_SEGUNDA';
    2: Result := 'CONST_TERCERA';
  else
    Result := 'CONST_ECONOMICA';
  end;
end;

function TCalculoCatastral.CalcularCoeficienteZona(const ClasificacionZona: string): Double;
var
  CodigoVar: string;
begin
  // Mapear clasificación de zona a código de variable
  if Pos('PREMIUM', UpperCase(ClasificacionZona)) > 0 then
    CodigoVar := 'ZONA_URBANA_PREMIUM'
  else if Pos('ZR1', UpperCase(ClasificacionZona)) > 0 then
    CodigoVar := 'ZONA_URBANA_A'
  else if Pos('ZR2', UpperCase(ClasificacionZona)) > 0 then
    CodigoVar := 'ZONA_URBANA_B'
  else if Pos('ZC', UpperCase(ClasificacionZona)) > 0 then
    CodigoVar := 'ZONA_URBANA_A'
  else if Pos('RURAL', UpperCase(ClasificacionZona)) > 0 then
    CodigoVar := 'ZONA_RURAL'
  else
    CodigoVar := 'ZONA_URBANA_C';

  Result := ObtenerVariable(CodigoVar);
  if Result = 0 then
    Result := 1.0;
end;

function TCalculoCatastral.CalcularCoeficienteUso(const UsoTerreno: string): Double;
var
  CodigoVar: string;
begin
  CodigoVar := 'USO_' + UsoTerreno;
  Result := ObtenerVariable(CodigoVar);
  if Result = 0 then
    Result := 1.0;
end;

function TCalculoCatastral.CalcularCoeficienteEstado(const EstadoConstruccion: string): Double;
var
  CodigoVar: string;
begin
  CodigoVar := 'ESTADO_' + EstadoConstruccion;
  Result := ObtenerVariable(CodigoVar);
  if Result = 0 then
    Result := 1.0;
end;

function TCalculoCatastral.CalcularCoeficienteServicios(const Ficha: TDatosFicha): Double;
var
  Servicios: Integer;
begin
  // Contar servicios disponibles
  Servicios := 0;
  if Ficha.TieneAgua then Inc(Servicios);
  if Ficha.TieneElectricidad then Inc(Servicios);
  if Ficha.TieneCloacas then Inc(Servicios);
  if Ficha.TieneAseo then Inc(Servicios);
  if Ficha.TieneGas then Inc(Servicios);
  if Ficha.TieneAceras then Inc(Servicios);
  if Ficha.TieneAlumbrado then Inc(Servicios);
  if Ficha.TieneAsfalto then Inc(Servicios);

  // Determinar coeficiente según cantidad de servicios
  if Servicios >= 7 then
    Result := ObtenerVariable('SERV_COMPLETOS')
  else if Servicios >= 5 then
    Result := ObtenerVariable('SERV_BASICOS')
  else if Servicios >= 3 then
    Result := ObtenerVariable('SERV_PARCIALES')
  else
    Result := ObtenerVariable('SERV_MINIMOS');

  if Result = 0 then
    Result := 1.0;
end;

function TCalculoCatastral.CalcularCoeficienteDepreciacion(AnioConstruccion: Integer): Double;
var
  Antiguedad: Integer;
  CodigoVar: string;
begin
  if AnioConstruccion <= 0 then
  begin
    Result := 1.0;
    Exit;
  end;

  Antiguedad := YearOf(Now) - AnioConstruccion;

  if Antiguedad <= 5 then
    CodigoVar := 'DEPREC_0_5'
  else if Antiguedad <= 10 then
    CodigoVar := 'DEPREC_6_10'
  else if Antiguedad <= 20 then
    CodigoVar := 'DEPREC_11_20'
  else if Antiguedad <= 30 then
    CodigoVar := 'DEPREC_21_30'
  else
    CodigoVar := 'DEPREC_31_MAS';

  Result := ObtenerVariable(CodigoVar);
  if Result = 0 then
    Result := 1.0;
end;

function TCalculoCatastral.ObtenerAlicuota(const UsoTerreno: string): Double;
var
  CodigoVar: string;
begin
  if UsoTerreno = 'COMERCIAL' then
    CodigoVar := 'ALICUOTA_COMERCIAL'
  else if UsoTerreno = 'INDUSTRIAL' then
    CodigoVar := 'ALICUOTA_INDUSTRIAL'
  else
    CodigoVar := 'ALICUOTA_RESIDENCIAL';

  Result := ObtenerVariable(CodigoVar);
  if Result = 0 then
    Result := 0.5; // 0.5% por defecto
end;

function TCalculoCatastral.CalcularValorTerreno(AreaTerreno: Double;
  const UsoTerreno, ClasificacionZona: string): Double;
var
  ValorBase, CoefZona, CoefUso: Double;
begin
  ValorBase := ObtenerVariable(DeterminarTipoTerrenoVariable(UsoTerreno));
  CoefZona := CalcularCoeficienteZona(ClasificacionZona);
  CoefUso := CalcularCoeficienteUso(UsoTerreno);

  Result := AreaTerreno * ValorBase * CoefZona * CoefUso;
end;

function TCalculoCatastral.CalcularValorConstruccion(AreaConstruccion: Double;
  CalidadAcabados: Integer; const EstadoConstruccion: string;
  AnioConstruccion: Integer): Double;
var
  ValorBase, CoefEstado, CoefDepreciacion: Double;
begin
  if AreaConstruccion <= 0 then
  begin
    Result := 0;
    Exit;
  end;

  ValorBase := ObtenerVariable(DeterminarTipoConstruccionVariable(CalidadAcabados));
  CoefEstado := CalcularCoeficienteEstado(EstadoConstruccion);
  CoefDepreciacion := CalcularCoeficienteDepreciacion(AnioConstruccion);

  Result := AreaConstruccion * ValorBase * CoefEstado * CoefDepreciacion;
end;

function TCalculoCatastral.CalcularAvaluo(const Ficha: TDatosFicha): TResultadoAvaluo;
var
  ValorTerrenoBase, ValorConstruccionBase: Double;
  CoefServicios: Double;
  DetalleBuilder: TStringBuilder;
begin
  if not FVariablesCargadas then
    CargarVariables;

  DetalleBuilder := TStringBuilder.Create;
  try
    // ===== CÁLCULO DE TERRENO =====
    ValorTerrenoBase := ObtenerVariable(DeterminarTipoTerrenoVariable(Ficha.UsoTerreno));
    Result.ValorTerrenoBase := Ficha.AreaTerreno * ValorTerrenoBase;

    Result.CoeficienteZona := CalcularCoeficienteZona(Ficha.ClasificacionZona);
    Result.CoeficienteUso := CalcularCoeficienteUso(Ficha.UsoTerreno);
    Result.CoeficienteServicios := CalcularCoeficienteServicios(Ficha);

    Result.ValorTerreno := Result.ValorTerrenoBase *
                          Result.CoeficienteZona *
                          Result.CoeficienteUso *
                          Result.CoeficienteServicios;

    DetalleBuilder.AppendLine('=== CÁLCULO DE TERRENO ===');
    DetalleBuilder.AppendFormat('Área: %.2f m²', [Ficha.AreaTerreno]);
    DetalleBuilder.AppendLine;
    DetalleBuilder.AppendFormat('Valor Base: %.2f Bs/m²', [ValorTerrenoBase]);
    DetalleBuilder.AppendLine;
    DetalleBuilder.AppendFormat('Valor Base Total: %.2f Bs', [Result.ValorTerrenoBase]);
    DetalleBuilder.AppendLine;
    DetalleBuilder.AppendFormat('Coef. Zona: %.4f', [Result.CoeficienteZona]);
    DetalleBuilder.AppendLine;
    DetalleBuilder.AppendFormat('Coef. Uso: %.4f', [Result.CoeficienteUso]);
    DetalleBuilder.AppendLine;
    DetalleBuilder.AppendFormat('Coef. Servicios: %.4f', [Result.CoeficienteServicios]);
    DetalleBuilder.AppendLine;
    DetalleBuilder.AppendFormat('VALOR TERRENO: %.2f Bs', [Result.ValorTerreno]);
    DetalleBuilder.AppendLine;
    DetalleBuilder.AppendLine;

    // ===== CÁLCULO DE CONSTRUCCIÓN =====
    if Ficha.AreaConstruccion > 0 then
    begin
      ValorConstruccionBase := ObtenerVariable(DeterminarTipoConstruccionVariable(Ficha.CalidadAcabados));
      Result.ValorConstruccionBase := Ficha.AreaConstruccion * ValorConstruccionBase;

      Result.CoeficienteEstado := CalcularCoeficienteEstado(Ficha.EstadoConstruccion);
      Result.CoeficienteDepreciacion := CalcularCoeficienteDepreciacion(Ficha.AnioConstruccion);

      Result.ValorConstruccion := Result.ValorConstruccionBase *
                                  Result.CoeficienteEstado *
                                  Result.CoeficienteDepreciacion;

      DetalleBuilder.AppendLine('=== CÁLCULO DE CONSTRUCCIÓN ===');
      DetalleBuilder.AppendFormat('Área: %.2f m²', [Ficha.AreaConstruccion]);
      DetalleBuilder.AppendLine;
      DetalleBuilder.AppendFormat('Valor Base: %.2f Bs/m²', [ValorConstruccionBase]);
      DetalleBuilder.AppendLine;
      DetalleBuilder.AppendFormat('Valor Base Total: %.2f Bs', [Result.ValorConstruccionBase]);
      DetalleBuilder.AppendLine;
      DetalleBuilder.AppendFormat('Coef. Estado: %.4f', [Result.CoeficienteEstado]);
      DetalleBuilder.AppendLine;
      DetalleBuilder.AppendFormat('Coef. Depreciación: %.4f', [Result.CoeficienteDepreciacion]);
      DetalleBuilder.AppendLine;
      DetalleBuilder.AppendFormat('VALOR CONSTRUCCIÓN: %.2f Bs', [Result.ValorConstruccion]);
      DetalleBuilder.AppendLine;
      DetalleBuilder.AppendLine;
    end
    else
    begin
      Result.ValorConstruccionBase := 0;
      Result.CoeficienteEstado := 1;
      Result.CoeficienteDepreciacion := 1;
      Result.ValorConstruccion := 0;
    end;

    // ===== VALOR TOTAL =====
    Result.ValorTotal := Result.ValorTerreno + Result.ValorConstruccion;

    DetalleBuilder.AppendLine('=== VALOR TOTAL ===');
    DetalleBuilder.AppendFormat('Terreno: %.2f Bs', [Result.ValorTerreno]);
    DetalleBuilder.AppendLine;
    DetalleBuilder.AppendFormat('Construcción: %.2f Bs', [Result.ValorConstruccion]);
    DetalleBuilder.AppendLine;
    DetalleBuilder.AppendFormat('VALOR TOTAL: %.2f Bs', [Result.ValorTotal]);
    DetalleBuilder.AppendLine;
    DetalleBuilder.AppendLine;

    // ===== CÁLCULO DE IMPUESTO =====
    Result.BaseImponible := Result.ValorTotal;
    Result.Alicuota := ObtenerAlicuota(Ficha.UsoTerreno);
    Result.MontoImpuestoAnual := Result.BaseImponible * (Result.Alicuota / 100);

    // Aplicar exoneración si corresponde
    if Ficha.TieneExoneracion and (Ficha.PorcentajeExoneracion > 0) then
      Result.MontoConExoneracion := Result.MontoImpuestoAnual * (1 - Ficha.PorcentajeExoneracion / 100)
    else
      Result.MontoConExoneracion := Result.MontoImpuestoAnual;

    DetalleBuilder.AppendLine('=== CÁLCULO DE IMPUESTO ===');
    DetalleBuilder.AppendFormat('Base Imponible: %.2f Bs', [Result.BaseImponible]);
    DetalleBuilder.AppendLine;
    DetalleBuilder.AppendFormat('Alícuota: %.4f%%', [Result.Alicuota]);
    DetalleBuilder.AppendLine;
    DetalleBuilder.AppendFormat('Impuesto Anual: %.2f Bs', [Result.MontoImpuestoAnual]);
    DetalleBuilder.AppendLine;

    if Ficha.TieneExoneracion then
    begin
      DetalleBuilder.AppendFormat('Exoneración: %.2f%%', [Ficha.PorcentajeExoneracion]);
      DetalleBuilder.AppendLine;
      DetalleBuilder.AppendFormat('Monto con Exoneración: %.2f Bs', [Result.MontoConExoneracion]);
      DetalleBuilder.AppendLine;
    end;

    Result.DetalleCalculo := DetalleBuilder.ToString;

  finally
    DetalleBuilder.Free;
  end;
end;

function TCalculoCatastral.ObtenerVariablesCategoria(const Categoria: string): TArray<TVariableCalculo>;
var
  Lista: TList<TVariableCalculo>;
  Pair: TPair<string, TVariableCalculo>;
begin
  Lista := TList<TVariableCalculo>.Create;
  try
    // Buscar en SQLite por categoría
    FQuerySQLite.SQL.Text :=
      'SELECT Codigo, Nombre, ValorNumerico, ValorPorcentaje, UnidadMedida ' +
      'FROM VariablesCalculo WHERE Categoria = :Cat ORDER BY Nombre';
    FQuerySQLite.ParamByName('Cat').AsString := Categoria;
    FQuerySQLite.Open;

    while not FQuerySQLite.Eof do
    begin
      if FVariables.TryGetValue(FQuerySQLite.FieldByName('Codigo').AsString, Pair.Value) then
        Lista.Add(Pair.Value);
      FQuerySQLite.Next;
    end;

    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

end.
