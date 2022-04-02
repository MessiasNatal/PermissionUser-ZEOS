unit Query;

interface

uses
  System.Classes, System.SysUtils, System.UITypes, Data.DB, Vcl.Dialogs, ZConnection, ZAbstractRODataset,
  ZAbstractDataset, ZDataset;

type
  TOperation = (toSave, toDelete, toCancel);

  TQuery = class
  private
    FQuery: TZQuery;
  public
    constructor Create(Conexao: TComponent; Sql: string = '');
    destructor Destroy; override;
    property qy: TZQuery read FQuery write FQuery;
    class function GetConn(Connection: TComponent): TZConnection;
    class procedure Operation(Operation: TOperation; DataSet: TDataSet);
    class function ValidadeFields(DataSet: TDataSet): Boolean;
  end;

implementation

{ TQUERY }

class procedure TQuery.Operation(Operation: TOperation; DataSet: TDataSet);
begin
  try
    case Operation of
      toSave:
      begin
        TZQuery(DataSet).Post;
        TZQuery(DataSet).ApplyUpdates;
        TZQuery(DataSet).CommitUpdates;
      end;
      toDelete:
      begin
        TZQuery(DataSet).Delete;
        TZQuery(DataSet).ApplyUpdates;
        TZQuery(DataSet).CommitUpdates;
      end;
      toCancel:
      begin
        TZQuery(DataSet).Cancel;
        TZQuery(DataSet).CancelUpdates;
      end;
    end;
  except
    on e: Exception do
    begin
      TZQuery(DataSet).Cancel;
      TZQuery(DataSet).CancelUpdates;
      if Pos('duplicate',LowerCase(E.Message)) > 0 then
        MessageDlg('Registro já Existe.',TMsgDlgType.mtWarning,[mbok],0)
      else
      if Pos('foreign',LowerCase(E.Message)) > 0 then
        MessageDlg('Registro Possui Movimentações!',TMsgDlgType.mtWarning,[mbok],0)
      else
        raise Exception.Create(e.Message);
    end;
  end;
end;

constructor TQuery.Create(Conexao: TComponent; Sql: string = '');
begin
  FQuery := TZQuery.Create(nil);
  FQuery.Connection := TZConnection(Conexao);
  FQuery.CachedUpdates := True;
  FQuery.SQL.Clear;
  if Sql <> '' then
    FQuery.SQL.Add(Sql);
end;

destructor TQuery.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

class function TQuery.GetConn(Connection: TComponent): TZConnection;
begin
  Result := TZConnection(Connection);
end;

class function TQuery.ValidadeFields(DataSet: TDataSet): Boolean;
var
  cont: integer;
  Fields : string;
begin
  Result := True;
  Fields := '';
  for cont := 0 to DataSet.FieldCount - 1 do
  begin
    if DataSet.Fields[cont].Required then
    begin
      if DataSet.Fields[cont].DataType=ftWideString then
      begin
        if (DataSet.Fields[cont].IsNull) or (trim(DataSet.fields[cont].asstring)='') then
        begin
          Fields := Fields + ' - '+  DataSet.Fields[cont].DisplayLabel + #13;
          DataSet.Fields[cont].FocusControl;
          Result:=False;
        end;
      end
      else if DataSet.Fields[cont].DataType=ftWideString then
      begin
        if (DataSet.Fields[cont].IsNull) or (trim(DataSet.fields[cont].asstring)='') then
        begin
          Fields := Fields + ' - '+  DataSet.Fields[cont].DisplayLabel + #13;
          DataSet.Fields[cont].FocusControl;
          Result:=False;
        end;
      end
      else if (DataSet.Fields[cont].DataType=ftinteger) then
      begin
        if (DataSet.Fields[cont].IsNull) or (DataSet.fields[cont].asinteger=0) then
        begin
          Fields := Fields + ' - '+  DataSet.Fields[cont].DisplayLabel + #13;
          DataSet.Fields[cont].FocusControl;
          Result:=False;
        end;
      end
      else if (DataSet.fields[cont].datatype=ftcurrency) then
      begin
        if (DataSet.Fields[cont].IsNull) or (DataSet.fields[cont].ascurrency=0) then
        begin
          Fields := Fields + ' - '+  DataSet.Fields[cont].DisplayLabel + #13;
          DataSet.Fields[cont].FocusControl;
          Result:=False;
        end;
      end
      else if (DataSet.fields[cont].datatype=ftfloat) then
      begin
        if (DataSet.Fields[cont].IsNull) or (DataSet.fields[cont].asfloat=0) then
        begin
          Fields := Fields + ' - '+  DataSet.Fields[cont].DisplayLabel + #13;
          DataSet.Fields[cont].FocusControl;
          Result:=False;
        end;
      end
      else if DataSet.Fields[cont].DataType=ftFMTBcd then
      begin
        if (DataSet.Fields[cont].IsNull) or (DataSet.fields[cont].AsFloat=0) then
        begin
          Fields := Fields + ' - '+  DataSet.Fields[cont].DisplayLabel + #13;
          DataSet.Fields[cont].FocusControl;
          Result:=False;
        end;
      end
      else
      begin
        if (DataSet.Fields[cont].IsNull) or (trim(DataSet.fields[cont].asstring)='') then
        begin
          Fields := Fields + ' - '+  DataSet.Fields[cont].DisplayLabel + #13;
          DataSet.Fields[cont].FocusControl;
          Result:=False;
        end;
      end;
    end;
  end;
  if not Result then
    MessageDlg('Favor preencher o(s) seguinte(s) campo(s) obrigatório(s) ' + #13 + Fields,mtInformation,[mbOK],0);
end;

end.
