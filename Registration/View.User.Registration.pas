unit View.User.Registration;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Data.DB, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.Buttons, DM.User.Registration, Query, View.User.InsertEdit, ZConnection;

type
  TViewUserRegistration = class(TForm)
    pnlDefault: TPanel;
    pnlPesquisa: TPanel;
    btnInsert: TBitBtn;
    btnEdit: TBitBtn;
    btnDelete: TBitBtn;
    grdRecords: TDBGrid;
    dsRegistration: TDataSource;
    btnFechar: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FDMUserRegistration: TDMUserRegistration;
    FPermissionUser: TComponent;
    FSQLUserRegistration: string;
    procedure OpenViewInsertEdit(Operation: TDataSetState);
    procedure Operation(Sender: TObject);
  public
    property PermissionUser: TComponent read FPermissionUser write FPermissionUser;
    property SQLUserRegistration: string read FSQLUserRegistration write FSQLUserRegistration;
  end;

implementation

{$R *.dfm}

uses
  PermissionUser;

{ TViewUserRegistration }

procedure TViewUserRegistration.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TViewUserRegistration.FormCreate(Sender: TObject);
begin
  FDMUserRegistration := TDMUserRegistration.Create(Self);
  dsRegistration.DataSet := FDMUserRegistration.qyUserRegistration;

  btnInsert.OnClick := Operation;
  btnEdit.OnClick := Operation;
  btnDelete.OnClick := Operation;
end;

procedure TViewUserRegistration.FormShow(Sender: TObject);
begin
  try
    FDMUserRegistration.qyUserRegistration.SQL.Text := SQLUserRegistration;
    FDMUserRegistration.qyUserRegistration.Connection := TQuery.GetConn(TPermissionUser(FPermissionUser).PermissionUserConnection.Connection) as TZConnection;
    FDMUserRegistration.qyUserRegistration.Open;
    FDMUserRegistration.qyUserRegistration.FieldByName(TPermissionUser(FPermissionUser).PermissionUserTable.UserFieldId).Required:=False;

    FDMUserRegistration.qyUserRegistration.Fields[0].DisplayLabel := 'Código';
    FDMUserRegistration.qyUserRegistration.Fields[1].DisplayLabel := 'Permissão';
    FDMUserRegistration.qyUserRegistration.Fields[2].DisplayLabel := 'Nome Completo';
    FDMUserRegistration.qyUserRegistration.Fields[3].DisplayLabel := 'E-Mail';
    FDMUserRegistration.qyUserRegistration.Fields[4].DisplayLabel := 'Login';

    FDMUserRegistration.qyUserRegistration.Fields[1].Required := True;
    FDMUserRegistration.qyUserRegistration.Fields[2].Required := True;
    FDMUserRegistration.qyUserRegistration.Fields[3].Required := True;
    FDMUserRegistration.qyUserRegistration.Fields[4].Required := True;
  except
    on e: Exception do
      raise Exception.Create(e.Message);
  end;
end;

procedure TViewUserRegistration.OpenViewInsertEdit(Operation: TDataSetState);
begin
  with TViewUserInsertEdit.Create(Self) do
    try
      dsRegistrationInsertEdit.DataSet := dsRegistration.DataSet;
      case Operation of
        dsInsert: dsRegistrationInsertEdit.DataSet.Insert;
        dsEdit: dsRegistrationInsertEdit.DataSet.Edit;
      end;
      PermissionUser := Self.FPermissionUser as TPermissionUser;
      DMUserRegistration := Self.FDMUserRegistration;
      ShowModal;
    finally
      Free;
    end;
end;

procedure TViewUserRegistration.Operation(Sender: TObject);
begin
  if Sender = btnInsert then
    OpenViewInsertEdit(dsInsert)
  else
  if (Sender = btnEdit) and (not dsRegistration.DataSet.IsEmpty) then
    OpenViewInsertEdit(dsEdit)
  else
  if (Sender = btnDelete) and (not dsRegistration.DataSet.IsEmpty) and (MessageBox(0,'Confirma Exclusão ?','Informação',MB_ICONQUESTION+MB_TASKMODAL+MB_YESNO) = ID_YES) then
    TQuery.Operation(toDelete,dsRegistration.DataSet);
end;

end.
