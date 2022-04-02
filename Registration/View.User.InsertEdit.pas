unit View.User.InsertEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.UITypes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.DBCtrls, Vcl.Mask, Data.DB, Vcl.Buttons, Query,
  View.User.Password, PermissionUser, DM.User.Registration;

type
  TViewUserInsertEdit = class(TForm)
    pnlDefault: TPanel;
    lblNameComplete: TLabel;
    lblEmail: TLabel;
    lblLogin: TLabel;
    ckActive: TDBCheckBox;
    ckAdmin: TDBCheckBox;
    dsRegistrationInsertEdit: TDataSource;
    edtNameComplete: TDBEdit;
    edtEmail: TDBEdit;
    edtLogin: TDBEdit;
    pnlOperation: TPanel;
    btnSave: TBitBtn;
    btnCancel: TBitBtn;
    lblGroupPermission: TLabel;
    cbGroupPermission: TDBLookupComboBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FPermissionUser: TPermissionUser;
    FDMUserRegistration: TDMUserRegistration;
    procedure LoadGroup;
    function ValidadeEmail(Email: string): Boolean;
  public
    property PermissionUser: TPermissionUser read FPermissionUser write FPermissionUser;
    property DMUserRegistration: TDMUserRegistration read FDMUserRegistration write FDMUserRegistration;
  end;

implementation

{$R *.dfm}

procedure TViewUserInsertEdit.btnCancelClick(Sender: TObject);
begin
  if (dsRegistrationInsertEdit.DataSet.State = dsInsert) or (dsRegistrationInsertEdit.DataSet.State = dsEdit) then
    TQuery.Operation(toCancel,dsRegistrationInsertEdit.DataSet);
  Close;
end;

procedure TViewUserInsertEdit.btnSaveClick(Sender: TObject);

  procedure SetPassword;
  begin
    case dsRegistrationInsertEdit.DataSet.State of
      dsInsert: dsRegistrationInsertEdit.DataSet.FieldByName(FPermissionUser.PermissionUserTable.UserFieldPassword).AsString := PermissionUser.Crypto.Encrypt(TViewUserPassword.GetPassword(toNew));
      dsEdit: dsRegistrationInsertEdit.DataSet.FieldByName(FPermissionUser.PermissionUserTable.UserFieldPassword).AsString := PermissionUser.Crypto.Encrypt(TViewUserPassword.GetPassword(toUpdate,dsRegistrationInsertEdit.DataSet.FieldByName(FPermissionUser.PermissionUserTable.UserFieldPassword).AsString));
    end;
  end;

begin

  if (not TQuery.ValidadeFields(dsRegistrationInsertEdit.DataSet)) or (not ValidadeEmail(edtEmail.Text)) then
    Exit;
  if dsRegistrationInsertEdit.DataSet.State = dsInsert then
    SetPassword;
  TQuery.Operation(toSave,dsRegistrationInsertEdit.DataSet);
  Close;
end;

procedure TViewUserInsertEdit.FormShow(Sender: TObject);
begin
  LoadGroup;
end;

procedure TViewUserInsertEdit.LoadGroup;
const
  SqlSelect = 'select '+
              '  * '+
              'from '+
              '  %s '+
              'where '+
              '  %s is null and '+
              '  %s = ''false''';
var
  Source: TDataSource;
begin
  Source := TDataSource.Create(Self);
  Source.DataSet := FDMUserRegistration.LoadListGroup(FPermissionUser.PermissionUserConnection.Connection,Format(SqlSelect,[FPermissionUser.PermissionUserTable.UserTableName,
                                                                                                                            FPermissionUser.PermissionUserTable.UserFieldIdGroup,
                                                                                                                            FPermissionUser.PermissionUserTable.UserFieldUserSystem]));
  cbGroupPermission.ListSource := Source;
  cbGroupPermission.ListField := FPermissionUser.PermissionUserTable.UserFieldName;
  cbGroupPermission.KeyField := FPermissionUser.PermissionUserTable.UserFieldId;
end;

function TViewUserInsertEdit.ValidadeEmail(Email: string): Boolean;
begin
  Email := Trim(UpperCase(Email));
  if Pos('@', Email) > 1 then
  begin
    Delete(Email, 1, pos('@', Email));
    Result := (Length(Email) > 0) and (Pos('.', Email) > 2);
  end
  else
    Result := False;
  if not Result then
    MessageDlg('E-Mail Inválido.',mtWarning,[mbOK],0);
end;

end.
