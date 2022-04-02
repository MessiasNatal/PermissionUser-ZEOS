unit PermissionUser;

interface

uses
  Query, System.Classes, System.SysUtils, System.UITypes, Data.DB, Vcl.Forms, Vcl.Controls, Vcl.Dialogs, Vcl.Buttons;

type
  TPermissionUser = class;
  TPermissionUserRegistration = class;

  TDataBase = (Mysql, Firebird {Implement your base});
  TMiddleware = (ZEOS {Implement your middleware});
  TNotAuthorized = (naDisabled, naInvisible);
  TLoginOperation = (loAuthorized, loNotAuthorized, loCancel);

  TEventAfterLogin = procedure (Sender: TPermissionUserRegistration) of object;
  TEventBeforeLogin = procedure (var Login,Pass: string) of object;

{***********************************************************************************************************************
*******************************************************CRYPTO*******************************************************
************************************************************************************************************************}

  TCrypto = class
  strict private
    function InternalEncrypt(const S: ansistring; Key: Word): ansistring;
    function PostProcess(const S: ansistring): ansistring;
    function InternalDecrypt(const S: ansistring; Key: Word): ansistring;
    function PreProcess(const S: ansistring): ansistring;
    function Encode(const S: ansistring): ansistring;
    function Decode(const S: ansistring): ansistring;
  public
    function Encrypt(const S: ansistring; Key: Word = 0): ansistring;
    function Decrypt(const S: ansistring; Key: Word = 0): ansistring;
  const
    Codes64 = '0A1B2C3D4E5F6G7H89IjKlMnOPqRsTuVWXyZabcdefghijkLmNopQrStUvwxYz+/';
    C1 = 52845;
    C2 = 22719;
  end;

{***********************************************************************************************************************
*******************************************************CONNECTION*******************************************************
************************************************************************************************************************}

  TPermissionUserConection = class(TComponent)
  strict private
    FConnection: TComponent;
    FDataBase: TDataBase;
    FMiddleware: TMiddleware;
  published
    property Connection: TComponent read FConnection write FConnection;
    property DataBase: TDataBase read FDataBase write FDataBase default Mysql;
    property Middleware: TMiddleware read FMiddleware write FMiddleware default ZEOS;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{***********************************************************************************************************************
*********************************************************TABLES*********************************************************
************************************************************************************************************************}

  TPermissionUserTable = class(TPersistent)
  strict private
    FPermissionUser: TPermissionUser;
    FUserTableName: string;
    FUserFieldId: string;
    FUserFieldName: string;
    FUserFieldEmail: string;
    FUserFieldAdmin: string;
    FUserFieldLogin: string;
    FUserFieldPassword: string;
    FUserFieldActive: string;
    FUserFieldUserSystem: string;
    FUserFieldIdGroup: string;
    procedure CreateTable;
  published
    property UserTableName: string read FUserTableName write FUserTableName;
    property UserFieldId: string read FUserFieldId write FUserFieldId;
    property UserFieldName: string read FUserFieldName write FUserFieldName;
    property UserFieldEmail: string read FUserFieldEmail write FUserFieldEmail;
    property UserFieldAdmin: string read FUserFieldAdmin write FUserFieldAdmin;
    property UserFieldLogin: string read FUserFieldLogin write FUserFieldLogin;
    property UserFieldPassword: string read FUserFieldPassword write FUserFieldPassword;
    property UserFieldActive: string read FUserFieldActive write FUserFieldActive;
    property UserFieldUserSystem: string read FUserFieldUserSystem write FUserFieldUserSystem;
    property UserFieldIdGroup: string read FUserFieldIdGroup write FUserFieldIdGroup;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Load;
  end;

  TPermissionUserTableGroupComponents = class(TPersistent)
  strict private
    FPermissionUser: TPermissionUser;
    FUserTableName: string;
    FUserFieldId: string;
    FUserFieldComponent: string;
    FUserFieldGroup: string;
    FUserFieldForm: string;
    FUserFieldDescription: string;
    FUserFieldMain: string;
    procedure CreateTable;
    procedure InsertComponents;
  published
    property UserTableName: string read FUserTableName write FUserTableName;
    property UserFieldId: string read FUserFieldId write FUserFieldId;
    property UserFieldComponent: string read FUserFieldComponent write FUserFieldComponent;
    property UserFieldGroup: string read FUserFieldGroup write FUserFieldGroup;
    property UserFieldForm: string read FUserFieldForm write FUserFieldForm;
    property UserFieldDescription: string read FUserFieldDescription write FUserFieldDescription;
    property UserFieldMain: string read FUserFieldMain write FUserFieldMain;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Load;
    procedure OpenViewGroup;
  end;

  TPermissionUserTableGroupUser = class(TPersistent)
  strict private
    FPermissionUser: TPermissionUser;
    FUserTableName: string;
    FUserFieldId: string;
    FUserFieldIdGroup: string;
    FUserFieldIdUser: string;
    procedure CreateTable;
  published
    property UserTableName: string read FUserTableName write FUserTableName;
    property UserFieldId: string read FUserFieldId write FUserFieldId;
    property UserFieldIdGroup: string read FUserFieldIdGroup write FUserFieldIdGroup;
    property UserFieldIdUser: string read FUserFieldIdUser write FUserFieldIdUser;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Load;
  end;

{***********************************************************************************************************************
****************************************************GROUP COMPONENTS****************************************************
************************************************************************************************************************}

  //COMPONENTS VIEW

  TPermissionUserComponentsItems = class(TCollectionItem)
  strict private
    FComponent: TControl;
    FDescription: string;
  private
    procedure SetComponent(const Value: TControl);
  published
    property Component: TControl read FComponent write SetComponent;
    property Description: string read FDescription write FDescription;
  protected
    function GetDisplayName: String; override;
  public
    procedure Assign(Source: TPersistent); override;
  end;

  TPermissionUserComponents = class(TCollection)
  strict private
    function GetItem(Index: Integer): TPermissionUserComponentsItems;
    procedure SetItem(Index: Integer; Value: TPermissionUserComponentsItems);
  public
    constructor Create;
    function Add: TPermissionUserComponentsItems;
    property Items[Index: Integer]: TPermissionUserComponentsItems read GetItem write SetItem; default;
  end;

  TPermissionUserComponentsConfiguration = class(TComponent)
  strict private
    FPermissionUser: TPermissionUser;
    FView: TForm;
    FGroup: string;
    FNotAuthorized: TNotAuthorized;
    FPermissionUserComponents: TPermissionUserComponents;
    FActive: Boolean;
    FMain: Boolean;
  published
    property PermissionUser: TPermissionUser read FPermissionUser write FPermissionUser;
    property View: TForm read FView write FView;
    property Group: string read FGroup write FGroup;
    property NotAuthorized: TNotAuthorized read FNotAuthorized write FNotAuthorized;
    property PermissionUserComponents: TPermissionUserComponents read FPermissionUserComponents write FPermissionUserComponents;
    property Active: Boolean read FActive write FActive;
    property Main: Boolean read FMain write FMain;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Load;
  end;

  //COMPONENTS ALL

  TPermissionUserComponentsItemsAll = class(TCollectionItem)
  strict private
    FPermissionUser: TPermissionUser;
    FComponent: string;
    FDescription: string;
    FGroup: string;
    FView: string;
    FMain: string;
  published
    property Component: string read FComponent write FComponent;
    property Description: string read FDescription write FDescription;
    property Group: string read FGroup write FGroup;
    property View: string read FView write FView;
    property Main: string read FMain write FMain;
  protected
    function GetDisplayName: String; override;
  public
    procedure Assign(Source: TPersistent); override;
    property PermissionUser: TPermissionUser read FPermissionUser write FPermissionUser;
  end;

  TPermissionUserComponentsAll = class(TCollection)
  strict private
    function GetItem(Index: Integer): TPermissionUserComponentsItemsAll;
    procedure SetItem(Index: Integer; Value: TPermissionUserComponentsItemsAll);
  public
    constructor Create;
    function Add: TPermissionUserComponentsItemsAll;
    property Items[Index: Integer]: TPermissionUserComponentsItemsAll read GetItem write SetItem; default;
  end;

{***********************************************************************************************************************
******************************************************REGISTRATION******************************************************
************************************************************************************************************************}

  TPermissionUserRegistration = class
  strict private
    FPermissionUser: TPermissionUser;
    FId: Integer;
    FName: string;
    FEmail: string;
    FLogin: string;
    FPassword: string;
    FActive: Boolean;
    FAdmin: Boolean;
    FUserSystem: Boolean;
    FIdGroup: Integer;
    FComponents: TDataSet;
  private
    function LoginUser(LoginDefault, PassDefault: AnsiString): TLoginOperation;
    procedure OpenViewRegistration;
  public
    property PermissionUser: TPermissionUser read FPermissionUser write FPermissionUser;
    property Id: Integer read FId write FId;
    property Login: string read FLogin write FLogin;
    property Name: string read FName write FName;
    property Email: string read FEmail write FEmail;
    property Admin: Boolean read FAdmin write FAdmin;
    property Password: string read FPassword write FPassword;
    property Active: Boolean read FActive write FActive;
    property UserSystem: Boolean read FUserSystem write FUserSystem;
    property IdGroup: Integer read FIdGroup write FIdGroup;
    property Components: TDataSet read FComponents write FComponents;
  public
    constructor Create(PermissionUser: TPermissionUser);
    destructor Destroy; override;
    procedure ModifyPassword;
  end;

{***********************************************************************************************************************
*******************************************************CLASS MAIN*******************************************************
************************************************************************************************************************}

  TPermissionUser = class(TComponent)
  strict private
    FUserDefaultName: string;
    FUserDefaultLogin: string;
    FUserDefaultPassword: string;
    FUserDefaultEmail: string;
    FPermissionUserTable: TPermissionUserTable;
    FPermissionUserConection: TPermissionUserConection;
    FPermissionUserTableGroupComponents: TPermissionUserTableGroupComponents;
    FPermissionUserTableGroupUser: TPermissionUserTableGroupUser;
    FUserLogged: TPermissionUserRegistration;
    FMessageLoginNotAuthorized: string;
    FBtnUserRegistration: TSpeedButton;
    FBtnGroup: TSpeedButton;
    FBtnModifyPassword: TSpeedButton;
    FPermissionUserComponentsAll: TPermissionUserComponentsAll;
    FOnAfterLogin: TEventAfterLogin;
    FOnBeforeLogin: TEventBeforeLogin;
    FCrypto: TCrypto;
  published
    property UserDefaultName: string read FUserDefaultName write FUserDefaultName;
    property UserDefaultLogin: string read FUserDefaultLogin write FUserDefaultLogin;
    property UserDefaultPassword: string read FUserDefaultPassword write FUserDefaultPassword;
    property UserDefaultEmail: string read FUserDefaultEmail write FUserDefaultEmail;
    property MessageLoginNotAuthorized: string read FMessageLoginNotAuthorized write FMessageLoginNotAuthorized;
    property PermissionUserTable: TPermissionUserTable read FPermissionUserTable write FPermissionUserTable;
    property PermissionUserConnection: TPermissionUserConection read FPermissionUserConection write FPermissionUserConection;
    property PermissionUserTableGroupComponents: TPermissionUserTableGroupComponents read FPermissionUserTableGroupComponents write FPermissionUserTableGroupComponents;
    property PermissionUserTableGroupUser: TPermissionUserTableGroupUser read FPermissionUserTableGroupUser write FPermissionUserTableGroupUser;
    property BtnUserRegistration: TSpeedButton read FBtnUserRegistration write FBtnUserRegistration;
    property BtnGroup: TSpeedButton read FBtnGroup write FBtnGroup;
    property BtnModifyPassword: TSpeedButton read FBtnModifyPassword write FBtnModifyPassword;
    property PermissionUserComponentsAll: TPermissionUserComponentsAll read FPermissionUserComponentsAll write FPermissionUserComponentsAll;
    property OnAfterLogin: TEventAfterLogin read FOnAfterLogin write FOnAfterLogin;
    property OnBeforeLogin: TEventBeforeLogin read FOnBeforeLogin write FOnBeforeLogin;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OnClickUserRegistration(Sender: TObject);
    procedure OnClickGroup(Sender: TObject);
    procedure OnClickModifyPassword(Sender: TObject);
    property UserLogged: TPermissionUserRegistration read FUserLogged;
    procedure Load;
    procedure Login;
    procedure LoadGroupPermission;
    function GetKey(Table: string; Key: string): Integer;
    property Crypto: TCrypto read FCrypto;
  end;

implementation

uses
  DM.User.Group, View.PermissionUser.Login, View.User.Registration, View.User.GroupPermission, View.User.Password;

{ TPermissionUser }

constructor TPermissionUser.Create(AOwner: TComponent);

  procedure LoginDefault;
  begin
    FUserDefaultLogin := 'admin';
    FUserDefaultName := 'admin admin';
    FUserDefaultPassword := '123';
    FUserDefaultEmail := 'admin@admin.com';
  end;

begin
  inherited Create(AOwner);
  LoginDefault;
  FMessageLoginNotAuthorized := 'User or Password Incorret';
  FUserLogged := TPermissionUserRegistration.Create(Self);
  FPermissionUserTable := TPermissionUserTable.Create(Self);
  FPermissionUserTableGroupComponents := TPermissionUserTableGroupComponents.Create(Self);
  FPermissionUserTableGroupUser := TPermissionUserTableGroupUser.Create(Self);
  FPermissionUserComponentsAll := TPermissionUserComponentsAll.Create;
  FCrypto := TCrypto.Create;
end;

destructor TPermissionUser.Destroy;
begin
  FreeAndNil(FPermissionUserComponentsAll);
  FreeAndNil(FPermissionUserTableGroupUser);
  FreeAndNil(FPermissionUserTableGroupComponents);
  FreeAndNil(FPermissionUserTable);
  FreeAndNil(FUserLogged);
  FreeAndNil(FCrypto);
  inherited;
end;

function TPermissionUser.GetKey(Table: string; Key: string): Integer;
const
  SqlGetKey = 'select '+
              '  coalesce(max(%s),1)+1 as ''key'' '+
              'from '+
              '  %s  ';
begin
  with TQuery.Create(FPermissionUserConection.Connection,Format(SqlGetKey,[Key,Table])) do
    try
      qy.Open;
      Result := qy.FieldByName('key').AsInteger;
    finally
      Free;
    end;
end;

procedure TPermissionUser.Load;
begin
  FPermissionUserTable.Load;
  FPermissionUserTableGroupComponents.Load;
  FPermissionUserTableGroupUser.Load;

  FBtnUserRegistration.OnClick := Self.OnClickUserRegistration;
  FBtnGroup.OnClick := Self.OnClickGroup;
  FBtnModifyPassword.OnClick := Self.OnClickModifyPassword;
end;

procedure TPermissionUser.LoadGroupPermission;

  function LoadGroupPermission: TDataSet;
  const
    SqlGroup = 'select '+
               '  %s.* '+
               'from '+
               '  %s '+
               '  left join %s on %s.id = %s.%s '+
               'where '+
               '  %s.%s = %d ';
  var
    FDataGroupPermission: TDMUserGroup;
  begin
    FDataGroupPermission := TDMUserGroup.Create(Self);
    Result := FDataGroupPermission.LoadGroupComponentsUserLogged(PermissionUserConnection.Connection,Format(SqlGroup,[PermissionUserTableGroupComponents.UserTableName,
                                                                                                                      PermissionUserTableGroupUser.UserTableName,
                                                                                                                      PermissionUserTableGroupComponents.UserTableName,
                                                                                                                      PermissionUserTableGroupComponents.UserTableName,
                                                                                                                      PermissionUserTableGroupUser.UserTableName,
                                                                                                                      PermissionUserTableGroupUser.UserFieldIdGroup,
                                                                                                                      PermissionUserTableGroupUser.UserTableName,
                                                                                                                      PermissionUserTableGroupUser.UserFieldIdUser,
                                                                                                                      UserLogged.IdGroup]));
  end;

begin
  UserLogged.Components := nil;
  UserLogged.Components := LoadGroupPermission;
end;

procedure TPermissionUser.Login;
var
  Login,Pass: string;
  Operation : TLoginOperation;
begin
  Login := '';
  Pass := '';

  if Assigned(FOnBeforeLogin) then
    FOnBeforeLogin(Login,Pass);

  Load;
  Operation := UserLogged.LoginUser(Login,Pass);
  LoadGroupPermission;
  FBtnUserRegistration.Visible := UserLogged.Admin;
  FBtnGroup.Visible := UserLogged.Admin;

  if Operation = loAuthorized then
    if Assigned(FOnAfterLogin) then
      FOnAfterLogin(Self.UserLogged);
end;

procedure TPermissionUser.OnClickGroup(Sender: TObject);
begin
  FPermissionUserTableGroupComponents.OpenViewGroup
end;

procedure TPermissionUser.OnClickModifyPassword(Sender: TObject);
begin
  FUserLogged.ModifyPassword;
end;

procedure TPermissionUser.OnClickUserRegistration(Sender: TObject);
begin
  FUserLogged.OpenViewRegistration;
end;

{ TPermissionUserConection }

constructor TPermissionUserConection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TPermissionUserConection.Destroy;
begin
  FConnection := nil;
  inherited;
end;

{ TPermissionUserComponents }

constructor TPermissionUserComponentsConfiguration.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPermissionUserComponents := TPermissionUserComponents.Create;
  if not (AOwner is TForm) then
    raise Exception.Create('AOwner is not TForm');
  FView := AOwner as TForm;
end;

destructor TPermissionUserComponentsConfiguration.Destroy;
begin
  PermissionUserComponents.Free;
  inherited;
end;

procedure TPermissionUserComponentsConfiguration.Load;
var
  i: Integer;
  Permission: Boolean;
begin
  if not FActive then
    Exit;
  for i := 0 to Pred(FPermissionUserComponents.Count) do
  begin
    try
      FPermissionUser.UserLogged.Components.Filtered := False;
      FPermissionUser.UserLogged.Components.Filter := Format('%s = %s and %s = %s and %s = %s',[FPermissionUser.PermissionUserTableGroupComponents.UserFieldComponent,
                                                                                                QuotedStr(TControl(FPermissionUserComponents.Items[i].Component).Name),
                                                                                                FPermissionUser.PermissionUserTableGroupComponents.UserFieldForm,
                                                                                                QuotedStr(Self.FView.Name),
                                                                                                FPermissionUser.PermissionUserTableGroupComponents.UserFieldGroup,
                                                                                                QuotedStr(Self.FGroup)]);
      FPermissionUser.UserLogged.Components.Filtered := True;
      Permission := not FPermissionUser.UserLogged.Components.IsEmpty;
      if FPermissionUser.UserLogged.UserSystem then
        Permission := True;
      case Self.FNotAuthorized of
        naDisabled: TControl(FPermissionUserComponents.Items[i].Component).Enabled := Permission;
        naInvisible: TControl(FPermissionUserComponents.Items[i].Component).Visible := Permission;
      end;
    finally
      FPermissionUser.UserLogged.Components.Filtered := False;
    end;
  end;
  FPermissionUser.BtnUserRegistration.Visible := FPermissionUser.UserLogged.Admin;
  FPermissionUser.BtnGroup.Visible := FPermissionUser.UserLogged.Admin;
end;

{ TPermissionUserTable }

constructor TPermissionUserTable.Create(AOwner: TComponent);

  procedure TableDefault;
  begin
    FUserTableName := 'permissionuser';
    FUserFieldId := 'id';
    FUserFieldName := 'name';
    FUserFieldEmail := 'email';
    FUserFieldAdmin := 'useradmin';
    FUserFieldLogin := 'login';
    FUserFieldPassword := 'password';
    FUserFieldActive := 'active';
    FUserFieldUserSystem := 'user_system';
    FUserFieldIdGroup := 'id_group';
  end;

begin
  FPermissionUser := AOwner as TPermissionUser;
  TableDefault;
end;

procedure TPermissionUserTable.CreateTable;

  procedure ValidadeUserDefaultExists;
  const
    SqlExistsUserDefault = 'select * from %s '+
                           'where '+
                           '  %s = %s and '+
                           '  %s = %s and '+
                           '  %s = %s ';

    function GetSQLInsertLoginDefault: string;
    const
      SqlInsertUserDefault = 'insert into %s ('+
                             '  %s, '+
                             '  %s, '+
                             '	%s, '+
                             '	%s, '+
                             '	%s, '+
                             '	%s, '+
                             '	%s, '+
                             '	%s) '+
                             'values ('+
                             '  %d, '+
                             '  %s, '+
                             '	%s, '+
                             '	%s, '+
                             '	%s, '+
                             '	%s, '+
                             '	%s, '+
                             '	%s); ';
    begin
      Result := Format(SqlInsertUserDefault,[FUserTableName,
                                             FUserFieldId,
                                             FUserFieldName,
                                             FUserFieldEmail,
                                             FUserFieldLogin,
                                             FUserFieldPassword,
                                             FUserFieldActive,
                                             FUserFieldAdmin,
                                             FUserFieldUserSystem,
                                             FPermissionUser.GetKey(FUserTableName,FUserFieldId),
                                             QuotedStr(FPermissionUser.UserDefaultName),
                                             QuotedStr(FPermissionUser.UserDefaultEmail),
                                             QuotedStr(FPermissionUser.UserDefaultLogin),
                                             QuotedStr(FPermissionUser.Crypto.Encrypt(FPermissionUser.UserDefaultPassword)),
                                             QuotedStr('true'),
                                             QuotedStr('true'),
                                             QuotedStr('true')]);
    end;

  begin
    with TQuery.Create(FPermissionUser.PermissionUserConnection.Connection,Format(SqlExistsUserDefault,[FUserTableName,FUserFieldName,QuotedStr(FPermissionUser.UserDefaultName),FUserFieldLogin,QuotedStr(FUserFieldLogin),FUserFieldUserSystem,QuotedStr('true')])) do
      try
        qy.Open;
        if qy.IsEmpty then
          try
            with TQuery.Create(FPermissionUser.PermissionUserConnection.Connection,GetSQLInsertLoginDefault) do
              try
                qy.ExecSQL;
              finally
                Free;
              end;
          except
            Exit;
          end;
      finally
        Free;
      end;
  end;

  function GetSQLTable: string;
  const
    SqlCreateTablleMYSQL = 'create table %s ( '+
                           '  %s int(11) not null auto_increment, '+
                           '  %s int(11), '+
                           '  %s varchar(50) not null, '+
                           '  %s varchar(50) null, '+
                           '  %s varchar(50) null, '+
                           '  %s varchar(50) null, '+
                           '  %s varchar(5) null default ''true'', '+
                           '  %s varchar(5) null default ''false'', '+
                           '  %s varchar(5) null default ''false'', '+
                           '  primary key (%s) '+
                           ');';
    SqlCreateTablleFIREBIRD = 'create table %s ( '+
                              '  %s integer not null, '+
                              '  %s integer, '+
                              '  %s varchar(50) not null, '+
                              '  %s varchar(50), '+
                              '  %s varchar(50), '+
                              '  %s varchar(50), '+
                              '  %s varchar(5) not null, '+
                              '  %s varchar(5) not null, '+
                              '  %s varchar(5) not null '+
                              '); ';
  begin
    case FPermissionUser.PermissionUserConnection.DataBase of
      Mysql: Result := Format(SqlCreateTablleMYSQL,[FUserTableName,
                                                    FUserFieldId,
                                                    FUserFieldIdGroup,
                                                    FUserFieldName,
                                                    FUserFieldEmail,
                                                    FUserFieldLogin,
                                                    FUserFieldPassword,
                                                    FUserFieldActive,
                                                    FUserFieldAdmin,
                                                    FUserFieldUserSystem,
                                                    FUserFieldId]);
      Firebird: Result := Format(SqlCreateTablleFIREBIRD,[FUserTableName,
                                                          FUserFieldId,
                                                          FUserFieldIdGroup,
                                                          FUserFieldName,
                                                          FUserFieldEmail,
                                                          FUserFieldLogin,
                                                          FUserFieldPassword,
                                                          FUserFieldActive,
                                                          FUserFieldAdmin,
                                                          FUserFieldUserSystem]);
    end;
  end;

  procedure ValidadeTableExists;
  begin
    with TQuery.Create(FPermissionUser.PermissionUserConnection.Connection,GetSQLTable) do
      try
        try
          qy.ExecSQL;
        except
          Exit; //Ajustar para utilizar se existir função do ZEOS que obtem a lista de tabela para verificar a existencia
        end;
      finally
        Free;
      end;
  end;

begin
  ValidadeTableExists;
  ValidadeUserDefaultExists;
end;

destructor TPermissionUserTable.Destroy;
begin
  inherited;
end;

procedure TPermissionUserTable.Load;
begin
  CreateTable;
end;

{ TPermissionUserRegistration }

constructor TPermissionUserRegistration.Create(PermissionUser: TPermissionUser);
begin
  FPermissionUser := PermissionUser;
end;

destructor TPermissionUserRegistration.Destroy;
begin
  inherited;
end;

function TPermissionUserRegistration.LoginUser(LoginDefault, PassDefault: AnsiString): TLoginOperation;
const
  SqlLogin = 'select '+
             '  * '+
             'from '+
             '  %s  '+
             'where '+
             '  %s = :%s and  '+
             '  %s = :%s ';

  function ValidadeLogin(User, Password: string): TLoginOperation;
  begin
    Result := loNotAuthorized;
    with TQuery.Create(FPermissionUser.PermissionUserConnection.Connection,Format(SqlLogin,[FPermissionUser.PermissionUserTable.UserTableName,FPermissionUser.PermissionUserTable.UserFieldLogin,FPermissionUser.PermissionUserTable.UserFieldLogin,FPermissionUser.PermissionUserTable.UserFieldPassword,FPermissionUser.PermissionUserTable.UserFieldPassword])) do
      try
        qy.Close;
        qy.ParamByName(FPermissionUser.PermissionUserTable.UserFieldLogin).AsString := User;
        qy.ParamByName(FPermissionUser.PermissionUserTable.UserFieldPassword).AsString := PermissionUser.Crypto.Encrypt(Password);
        qy.Open;

        if (not qy.IsEmpty) and qy.FieldByName(FPermissionUser.PermissionUserTable.UserFieldActive).AsBoolean then
          Result := loAuthorized;

        if Result = loNotAuthorized then
        begin
          MessageDlg(FPermissionUser.MessageLoginNotAuthorized,mtWarning,[mbok],0);
          Exit;
        end;

        FId := qy.FieldByName(FPermissionUser.PermissionUserTable.UserFieldId).AsInteger;
        FIdGroup := qy.FieldByName(FPermissionUser.PermissionUserTable.UserFieldIdGroup).AsInteger;
        FLogin := qy.FieldByName(FPermissionUser.PermissionUserTable.UserFieldLogin).AsString;
        FName := qy.FieldByName(FPermissionUser.PermissionUserTable.UserFieldName).AsString;
        FEmail := qy.FieldByName(FPermissionUser.PermissionUserTable.UserFieldEmail).AsString;
        FAdmin := qy.FieldByName(FPermissionUser.PermissionUserTable.UserFieldAdmin).AsBoolean;
        FPassword := Password;
        FActive := qy.FieldByName(FPermissionUser.PermissionUserTable.UserFieldActive).AsBoolean;
        FUserSystem := qy.FieldByName(FPermissionUser.PermissionUserTable.UserFieldUserSystem).AsBoolean;

      finally
        Free;
      end;
  end;

  function GetLogin: TLoginOperation;
  begin
    with TViewPermissionUserLogin.Create(FPermissionUser) do
      try
        if LoginDefault <> '' then
          edtUser.Text := LoginDefault;
        if (LoginDefault <> '') and (PassDefault <> '') then
          Result := ValidadeLogin(LoginDefault,PermissionUser.Crypto.Decrypt(PassDefault))
        else
        begin
          ShowModal;
          Result := loCancel;
          if ModalResult = mrOk then
            Result := ValidadeLogin(edtUser.Text,edtPassword.Text);
        end;
      finally
        Free;
      end;
  end;

var
  RepeatLogin: Integer;
begin
  RepeatLogin := 0;
  repeat
    Result := GetLogin;
    Inc(RepeatLogin)
  until ((Result = loAuthorized) or (Result = loCancel) or (RepeatLogin = 3));
  if (Result = loNotAuthorized) or (Result = loCancel) then
    Application.Terminate;
end;

procedure TPermissionUserRegistration.ModifyPassword;
const
  SqlModify = 'update %s set '+
              '  %s = :%s '+
              'where '+
              '  %s = :%s ';

  procedure Modify(Password: string);
  begin
    with TQuery.Create(FPermissionUser.PermissionUserConnection.Connection,Format(SqlModify,[FPermissionUser.PermissionUserTable.UserTableName,FPermissionUser.PermissionUserTable.UserFieldPassword,FPermissionUser.PermissionUserTable.UserFieldPassword,FPermissionUser.PermissionUserTable.UserFieldId,FPermissionUser.PermissionUserTable.UserFieldId])) do
      try
        qy.ParamByName(FPermissionUser.PermissionUserTable.UserFieldPassword).AsString := PermissionUser.Crypto.Encrypt(Password);
        qy.ParamByName(FPermissionUser.PermissionUserTable.UserFieldId).AsInteger := FPermissionUser.UserLogged.FId;
        qy.ExecSQL;
      finally
        Free;
      end;
  end;

var
  PasswordModify: string;
begin
  with TViewUserPassword.Create(FPermissionUser) do
    try
      PasswordModify := GetPassword(toUpdate,FPassword);
      if PasswordModify = '' then
        Exit;
    finally
      Free;
    end;
  Modify(PasswordModify);
end;

procedure TPermissionUserRegistration.OpenViewRegistration;

  function GetSQLUserRegistration: string;
  const
    SQLUserRegistration = 'select '+
                          '  * '+
                          'from '+
                          '  %s  '+
                          'where '+
                          '  %s is not null';
  begin
    Result := Format(SQLUserRegistration,[FPermissionUser.PermissionUserTable.UserTableName,
                                          FPermissionUser.PermissionUserTable.UserFieldIdGroup])
  end;

begin
  if not FPermissionUser.UserLogged.FAdmin then
    Exit;
  with TViewUserRegistration.Create(FPermissionUser) do
    try
      PermissionUser := Self.FPermissionUser;
      SQLUserRegistration := GetSQLUserRegistration;
      ShowModal;
    finally
      Free;
    end;
end;

{ TPermissionUserComponentsItens }

function TPermissionUserComponents.Add: TPermissionUserComponentsItems;
begin
  Result := TPermissionUserComponentsItems(inherited Add);
end;

constructor TPermissionUserComponents.Create;
begin
  inherited Create(TPermissionUserComponentsItems);
end;

function TPermissionUserComponents.GetItem(Index: Integer): TPermissionUserComponentsItems;
begin
  Result := TPermissionUserComponentsItems(inherited GetItem(Index));
end;

procedure TPermissionUserComponents.SetItem(Index: Integer; Value: TPermissionUserComponentsItems);
begin
  inherited SetItem(Index, Value);
end;

{ TPermissionUserComponentsItems }

procedure TPermissionUserComponentsItems.Assign(Source: TPersistent);
begin
  inherited;
end;

function TPermissionUserComponentsItems.GetDisplayName: String;
begin
  if FComponent <> nil then
    Result := FComponent.Name;
  if Result = '' then
    Result := inherited GetDisplayName;
end;

procedure TPermissionUserComponentsItems.SetComponent(const Value: TControl);
var
  DescriptionParam: string;
begin
  FComponent := Value;
  if Value is TBitBtn then
    DescriptionParam := TBitBtn(Value).Caption
  else if Value is TSpeedButton then
    DescriptionParam := TSpeedButton(Value).Caption;
  if FDescription = '' then
    InputQuery('TPermissionUserComponentsItems','Description',DescriptionParam);
  FDescription := DescriptionParam;
end;

{ TPermissionUserTableGroupComponents }

constructor TPermissionUserTableGroupComponents.Create(AOwner: TComponent);

  procedure TableDefault;
  begin
    FUserTableName := 'permissionuser_group_components';
    FUserFieldId := 'id';
    FUserFieldComponent := 'component';
    FUserFieldGroup := 'group_component';
    FUserFieldForm := 'form';
    FUserFieldDescription := 'description';
    FUserFieldMain := 'main';
  end;

begin
  FPermissionUser := AOwner as TPermissionUser;
  TableDefault;
end;

procedure TPermissionUserTableGroupComponents.CreateTable;

  function GetSQLTable: string;
  const
    SqlCreateTablleMYSQL = 'create table %s ( '+
                           '  %s int(11) not null auto_increment, '+
                           '  %s varchar(50) not null, '+
                           '  %s varchar(50) not null, '+
                           '  %s varchar(50) not null, '+
                           '  %s varchar(50) not null, '+
                           '  %s varchar(50) not null '+
                           '  primary key (%s) '+
                           ');';
  begin
    case FPermissionUser.PermissionUserConnection.DataBase of
      Mysql: Result := Format(SqlCreateTablleMYSQL,[FUserTableName,
                                                    FUserFieldId,
                                                    FUserFieldComponent,
                                                    FUserFieldDescription,
                                                    FUserFieldGroup,
                                                    FUserFieldForm,
                                                    FUserFieldMain,
                                                    FUserFieldId]);
    end;
  end;

  procedure ValidadeTableExists;
  begin
    with TQuery.Create(FPermissionUser.PermissionUserConnection.Connection,GetSQLTable) do
      try
        try
          qy.ExecSQL;
        except
          Exit; //Ajustar para utilizar se existir função do ZEOS que obtem a lista de tabela para verificar a existencia
        end;
      finally
        Free;
      end;
  end;

begin
  ValidadeTableExists;
end;

destructor TPermissionUserTableGroupComponents.Destroy;
begin
  inherited;
end;

procedure TPermissionUserTableGroupComponents.InsertComponents;

  function GetSQLSelectComponent: string;
  const
    SqlSelectComponent = 'select * from %s '+
                         'where '+
                         '  %s = :%s and '+
                         '  %s = :%s  ';
  begin
    case FPermissionUser.PermissionUserConnection.DataBase of
      Mysql, Firebird: Result := Format(SqlSelectComponent,[FUserTableName,
                                                            FUserFieldComponent,
                                                            FUserFieldComponent,
                                                            FUserFieldForm,
                                                            FUserFieldForm]);
    end;
  end;

  function ValidadeComponentsExists(Component,Form: string): Boolean;
  begin
    Result := False;
    with TQuery.Create(FPermissionUser.PermissionUserConnection.Connection,GetSQLSelectComponent) do
      try
        try
          qy.Close;
          qy.ParamByName(FUserFieldComponent).AsString := Component;
          qy.ParamByName(FUserFieldForm).AsString := Form;
          qy.Open;
          Result := qy.IsEmpty;
        except
          Exit;
        end;
      finally
        Free;
      end;
  end;

  function GetSQLRemoveComponent: string;
  const
    sqlRemove = 'delete from %s '+
                'where '+
                '  %s = :%s and '+
                '  %s = :%s and '+
                '  %s = :%s ';
  begin
    case FPermissionUser.PermissionUserConnection.DataBase of
      Mysql, Firebird: Result := Format(sqlRemove,[FUserTableName,
                                                   FUserFieldComponent,
                                                   FUserFieldComponent,
                                                   FUserFieldForm,
                                                   FUserFieldForm,
                                                   FUserFieldGroup,
                                                   FUserFieldGroup]);
    end;
  end;

  procedure RemoveComponent(Form,Group,Component: string);
  begin
    with TQuery.Create(FPermissionUser.PermissionUserConnection.Connection,GetSQLRemoveComponent) do
      try
        try
          qy.Close;
          qy.ParamByName(FUserFieldComponent).AsString := Component;
          qy.ParamByName(FUserFieldForm).AsString := Form;
          qy.ParamByName(FUserFieldGroup).AsString := Group;
          qy.ExecSQL;
        except
          on e: exception do
            raise Exception.Create(e.Message);
        end;
      finally
        Free;
      end;
  end;

  function GetSQLInsertComponent: string;
  const
    SqlInsertComponent = 'insert into %s '+
                         ' (%s, '+
                         '  %s, '+
                         '  %s, '+
                         '  %s, '+
                         '  %s, '+
                         '  %s) '+
                         'values '+
                         ' (:%s, '+
                         '  :%s, '+
                         '  :%s, '+
                         '  :%s, '+
                         '  :%s, '+
                         '  :%s)';
  begin
    case FPermissionUser.PermissionUserConnection.DataBase of
      Mysql, Firebird: Result := Format(SqlInsertComponent,[FUserTableName,
                                                            FUserFieldId,
                                                            FUserFieldComponent,
                                                            FUserFieldForm,
                                                            FUserFieldGroup,
                                                            FUserFieldDescription,
                                                            FUserFieldMain,
                                                            FUserFieldId,
                                                            FUserFieldComponent,
                                                            FUserFieldForm,
                                                            FUserFieldGroup,
                                                            FUserFieldDescription,
                                                            FUserFieldMain
                                                            ]);
    end;
  end;

  procedure InsertComponent(Component,Description,Form,Group,Main: string);
  begin
    with TQuery.Create(FPermissionUser.PermissionUserConnection.Connection,GetSQLInsertComponent) do
      try
        try
          qy.Close;
          qy.ParamByName(FUserFieldId).AsInteger := FPermissionUser.GetKey(FUserTableName,FUserFieldId);
          qy.ParamByName(FUserFieldComponent).AsString := Component;
          qy.ParamByName(FUserFieldDescription).AsString := Description;
          qy.ParamByName(FUserFieldForm).AsString := Form;
          qy.ParamByName(FUserFieldGroup).AsString := Group;
          qy.ParamByName(FUserFieldMain).AsString := Main;
          qy.ExecSQL;
        except
          on e: exception do
            raise Exception.Create(e.Message);
        end;
      finally
        Free;
      end;
  end;

var
  i: Integer;
begin
  for i := 0 to Pred(FPermissionUser.PermissionUserComponentsAll.Count) do
    if ValidadeComponentsExists(FPermissionUser.PermissionUserComponentsAll.Items[i].Component,FPermissionUser.PermissionUserComponentsAll.Items[i].View) then
      InsertComponent(FPermissionUser.PermissionUserComponentsAll.Items[i].Component,
                      FPermissionUser.PermissionUserComponentsAll.Items[i].Description,
                      FPermissionUser.PermissionUserComponentsAll.Items[i].View,
                      FPermissionUser.PermissionUserComponentsAll.Items[i].Group,
                      FPermissionUser.PermissionUserComponentsAll.Items[i].Main);
end;

procedure TPermissionUserTableGroupComponents.Load;
begin
  CreateTable;
  InsertComponents;
end;

procedure TPermissionUserTableGroupComponents.OpenViewGroup;
begin
  with TViewUserGroupPermission.Create(FPermissionUser) do
    try
      PermissionUser := Self.FPermissionUser;
      ShowModal;
    finally
      Free;
    end;
  FPermissionUser.LoadGroupPermission;
end;

{ TPermissionUserTableGroupUser }

constructor TPermissionUserTableGroupUser.Create(AOwner: TComponent);

  procedure TableDefault;
  begin
    FUserTableName := 'group_components_user';
    FUserFieldId := 'id';
    FUserFieldIdGroup := 'id_group';
    FUserFieldIdUser := 'id_user';
  end;

begin
  FPermissionUser := AOwner as TPermissionUser;
  TableDefault;
end;

procedure TPermissionUserTableGroupUser.CreateTable;

  function GetSQLTable: string;
  const
    SqlCreateTableMYSQL = 'create table %s ( '+
                          '	%s int(11) not null auto_increment, '+
                          '	%s int(11) null not null, '+
                          '	%s int(11) null not null, '+
                          '	primary key (%s) '+
                          '); ';
   SqlCreateTableFIREBIRD = 'create table %s ( '+
                            ' %s integer not null, '+
                            ' %s integer not null, '+
                            ' %s integer not null '+
                            '); ';
  begin
    case FPermissionUser.PermissionUserConnection.DataBase of
      Mysql: Result := Format(SqlCreateTableMYSQL,[FUserTableName,
                                                   FUserFieldId,
                                                   FUserFieldIdGroup,
                                                   FUserFieldIdUser,
                                                   FUserFieldId]);
      Firebird: Result := Format(SqlCreateTableFIREBIRD,[FUserTableName,
                                                         FUserFieldId,
                                                         FUserFieldIdGroup,
                                                         FUserFieldIdUser,
                                                         FUserFieldId]);
    end;
  end;

  procedure ValidadeTableExists;
  begin
    with TQuery.Create(FPermissionUser.PermissionUserConnection.Connection,GetSQLTable) do
      try
        try
          qy.ExecSQL;
        except
          Exit; //Ajustar para utilizar se existir função do ZEOS que obtem a lista de tabela para verificar a existencia
        end;
      finally
        Free;
      end;
  end;

begin
  ValidadeTableExists;
end;

destructor TPermissionUserTableGroupUser.Destroy;
begin
  inherited;
end;

procedure TPermissionUserTableGroupUser.Load;
begin
  CreateTable;
end;

{ TPermissionUserComponentsItemsAll }

procedure TPermissionUserComponentsItemsAll.Assign(Source: TPersistent);
begin
  inherited;
end;

function TPermissionUserComponentsItemsAll.GetDisplayName: String;
begin
  if FComponent <> '' then
    Result := FView+'.'+FComponent;
  if Result = '' then
    Result := inherited GetDisplayName;
end;

{ TPermissionUserComponentsAll }

function TPermissionUserComponentsAll.Add: TPermissionUserComponentsItemsAll;
begin
  Result := TPermissionUserComponentsItemsAll(inherited Add);
end;

constructor TPermissionUserComponentsAll.Create;
begin
  inherited Create(TPermissionUserComponentsItemsAll);
end;

function TPermissionUserComponentsAll.GetItem(Index: Integer): TPermissionUserComponentsItemsAll;
begin
  Result := TPermissionUserComponentsItemsAll(inherited GetItem(Index));
end;

procedure TPermissionUserComponentsAll.SetItem(Index: Integer; Value: TPermissionUserComponentsItemsAll);
begin
  inherited SetItem(Index, Value);
end;

{ TCypto }

function TCrypto.Decode(const S: ansistring): ansistring;
const
  Map: array [Ansichar] of byte = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 62, 0, 0, 0, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 0, 0, 0,
    0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
    18, 19, 20, 21, 22, 23, 24, 25, 0, 0, 0, 0, 0, 0, 26, 27, 28, 29, 30, 31,
    32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
    51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0);
var
  I: longint;
begin
  case Length(S) of
    2:
      begin
        I := Map[S[1]] + (Map[S[2]] shl 6);
        SetLength(Result, 1);
        Move(I, Result[1], Length(Result));
      end;
    3:
      begin
        I := Map[S[1]] + (Map[S[2]] shl 6) + (Map[S[3]] shl 12);
        SetLength(Result, 2);
        Move(I, Result[1], Length(Result));
      end;
    4:
      begin
        I := Map[S[1]] + (Map[S[2]] shl 6) + (Map[S[3]] shl 12) +
          (Map[S[4]] shl 18);
        SetLength(Result, 3);
        Move(I, Result[1], Length(Result));
      end
  end;
end;

function TCrypto.Decrypt(const S: ansistring; Key: Word): ansistring;
begin
  Result := InternalDecrypt(PreProcess(S), Key);
end;

function TCrypto.Encode(const S: ansistring): ansistring;
const
  Map: array [0 .. 63]
    of char = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
var
  I: longint;
begin
  I := 0;
  Move(S[1], I, Length(S));
  case Length(S) of
    1:
      Result := Map[I mod 64] + Map[(I shr 6) mod 64];
    2:
      Result := Map[I mod 64] + Map[(I shr 6) mod 64] + Map[(I shr 12) mod 64];
    3:
      Result := Map[I mod 64] + Map[(I shr 6) mod 64] + Map[(I shr 12) mod 64] +
        Map[(I shr 18) mod 64];
  end;
end;

function TCrypto.Encrypt(const S: ansistring; Key: Word): ansistring;
begin
  Result := PostProcess(InternalEncrypt(S, Key));
end;

function TCrypto.InternalDecrypt(const S: ansistring; Key: Word): ansistring;
var
  I: Word;
  Seed: int64;
begin
  Result := S;
  Seed := Key;
  for I := 1 to Length(Result) do
  begin
    Result[I] := Ansichar(byte(Result[I]) xor (Seed shr 8));
    Seed := (byte(S[I]) + Seed) * Word(C1) + Word(C2);
  end;
end;

function TCrypto.InternalEncrypt(const S: ansistring; Key: Word): ansistring;
var
  I: Word;
  Seed: int64;
begin
  Result := S;
  Seed := Key;
  for I := 1 to Length(Result) do
  begin
    Result[I] := Ansichar(byte(Result[I]) xor (Seed shr 8));
    Seed := (byte(Result[I]) + Seed) * Word(C1) + Word(C2);
  end;
end;

function TCrypto.PostProcess(const S: ansistring): ansistring;
var
  SS: ansistring;
begin
  SS := S;
  Result := '';
  while SS <> '' do
  begin
    Result := Result + Encode(Copy(SS, 1, 3));
    Delete(SS, 1, 3);
  end;
end;

function TCrypto.PreProcess(const S: ansistring): ansistring;
var
  SS: ansistring;
begin
  SS := S;
  Result := '';
  while SS <> '' do
  begin
    Result := Result + Decode(Copy(SS, 1, 4));
    Delete(SS, 1, 4);
  end;
end;

end.


