unit DM.User.Registration;

interface

uses
  System.SysUtils, System.Classes, ZAbstractRODataset, ZAbstractDataset , ZDataset, Data.DB, ZConnection;

type
  TDMUserRegistration = class(TDataModule)
    qyListGroup: TZQuery;
    qyUserRegistration: TZQuery;
  public
    function LoadListGroup(Connection: TComponent; SqlGroup: string): TDataSet;
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TDMUserRegistration }

function TDMUserRegistration.LoadListGroup(Connection: TComponent; SqlGroup: string): TDataSet;
begin
  qyListGroup.Connection := Connection as TZConnection;
  qyListGroup.SQL.Text := SqlGroup;
  qyListGroup.Open;
  Result := qyListGroup;
end;

end.
