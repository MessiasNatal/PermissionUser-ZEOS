unit DM.User.Group;

interface

uses
  System.SysUtils, System.Classes, Data.DB, ZAbstractRODataset, ZAbstractDataset, ZDataset, ZConnection, Datasnap.DBClient;

type
  TDMUserGroup = class(TDataModule)
    qyComponents: TZQuery;
    qyGroup: TZQuery;
    qyListGroup: TZQuery;
    qyGroupComponentsUserLogged: TZQuery;
  public
    procedure LoadGroup(Connection: TComponent; SqlGroup: string; out DataSetGroup: TDataSet);
    function LoadListGroup(Connection: TComponent; SqlGroup: string): TDataSet;
    procedure LoadComponents(Connection: TComponent; SqlComponents: string; out DataSetComponents: TDataSet);
    function GetNewDataset(AOwner: TComponent; FieldId,FieldDescritpion: string): TDataSet;
    function LoadGroupComponentsUserLogged(Connection: TComponent; SqlGroupComponentsUserLogged: string): TDataSet;
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TDMUserGroup }

function TDMUserGroup.GetNewDataset(AOwner: TComponent; FieldId,FieldDescritpion: string): TDataSet;
var
  DataComponentsFilter: TClientDataSet;
begin
  DataComponentsFilter := TClientDataSet.Create(AOwner);
  DataComponentsFilter.FieldDefs.Add('selectedImage',ftString,1,False);
  DataComponentsFilter.FieldDefs.Add('selectedField',ftString,1,False);
  DataComponentsFilter.FieldDefs.Add(FieldDescritpion,ftString,50,True);
  DataComponentsFilter.FieldDefs.Add(FieldId,ftInteger);
  DataComponentsFilter.CreateDataSet;
  DataComponentsFilter.IndexFieldNames := DataComponentsFilter.Fields[2].FieldName;
  Result := DataComponentsFilter;
end;

procedure TDMUserGroup.LoadComponents(Connection: TComponent; SqlComponents: string; out DataSetComponents: TDataSet);
begin
  qyComponents.Connection := Connection as TZConnection;
  qyComponents.SQL.Text := SqlComponents;
  qyComponents.Open;
  DataSetComponents := qyComponents;
end;

procedure TDMUserGroup.LoadGroup(Connection: TComponent; SqlGroup: string; out DataSetGroup: TDataSet);
begin
  qyGroup.Connection := Connection as TZConnection;
  qyGroup.SQL.Text := SqlGroup;
  qyGroup.Open;
  DataSetGroup := qyGroup;
end;

function TDMUserGroup.LoadListGroup(Connection: TComponent; SqlGroup: string): TDataSet;
begin
  qyListGroup.Connection := Connection as TZConnection;
  qyListGroup.SQL.Text := SqlGroup;
  qyListGroup.Open;
  Result := qyListGroup;
end;

function TDMUserGroup.LoadGroupComponentsUserLogged(Connection: TComponent; SqlGroupComponentsUserLogged: string): TDataSet;
begin
  qyGroupComponentsUserLogged.Connection := Connection as TZConnection;
  qyGroupComponentsUserLogged.SQL.Text := SqlGroupComponentsUserLogged;
  qyGroupComponentsUserLogged.Open;
  Result := qyGroupComponentsUserLogged;
end;

end.
