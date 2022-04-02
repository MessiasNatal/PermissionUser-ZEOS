unit View.User.GroupPermission;

interface

uses
  PermissionUser, Query, DM.User.Group, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.ImageList, System.UITypes, Data.DB, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, Vcl.ImgList, Vcl.ComCtrls, Vcl.Mask,
  Vcl.DBCtrls;

type
  TViewUserGroupPermission = class(TForm)
    pnl1: TPanel;
    lblGroup: TLabel;
    pnlDefault: TPanel;
    pnlOperation: TPanel;
    btnSave: TBitBtn;
    btnCancel: TBitBtn;
    pnlGrid: TPanel;
    pgcDefault: TPageControl;
    tshGrid: TTabSheet;
    tshRecords: TTabSheet;
    DBGrid1: TDBGrid;
    dsRecords: TDataSource;
    pnlOperacoes: TPanel;
    btnInsert: TBitBtn;
    btnDelete: TBitBtn;
    btnEdit: TBitBtn;
    btnClose: TBitBtn;
    ImgList: TImageList;
    grpPermissions: TGroupBox;
    pgcPermissions: TPageControl;
    tshPermissionsViews: TTabSheet;
    tshPermissionsMain: TTabSheet;
    scrList: TScrollBox;
    pnlOperationCheck: TPanel;
    btnNotAllViews: TSpeedButton;
    bntAllViews: TSpeedButton;
    pnlOptionsdMain: TPanel;
    btnNotAllMain: TSpeedButton;
    bntAllMain: TSpeedButton;
    edtNameGroup: TDBEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bntAllViewsClick(Sender: TObject);
    procedure btnNotAllViewsClick(Sender: TObject);
    procedure btnNotAllMainClick(Sender: TObject);
    procedure bntAllMainClick(Sender: TObject);
  private
    FDataGroup: TDMUserGroup;
    FDataSetGroup: TDataSet;
    FDataSetComponents: TDataSet;
    FPermissionUser: TPermissionUser;
    procedure OnDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure OnDblClick(Sender: TObject);
    procedure FreeObjectGrid;
    procedure DeleteGroup(IdGroup: Integer);
    procedure OpenGroup;
    procedure CheckGroupsView(Selected: string; IdItemGroup: Integer = 0);
    procedure CheckGroupsMain(Selected: string; IdItemGroup: Integer = 0);
    procedure OnClickOperation(Sender: TObject);
  public
    property PermissionUser: TPermissionUser read FPermissionUser write FPermissionUser;
  end;

implementation

{$R *.dfm}

procedure TViewUserGroupPermission.FormCreate(Sender: TObject);
begin
  FDataGroup := TDMUserGroup.Create(Self);

  pgcDefault.ActivePageIndex := 0;
  pgcPermissions.ActivePageIndex := 0;
  tshRecords.TabVisible := False;

  btnInsert.OnClick := OnClickOperation;
  btnEdit.OnClick := OnClickOperation;
  btnDelete.OnClick := OnClickOperation;
  btnClose.OnClick := OnClickOperation;
  btnSave.OnClick := OnClickOperation;
  btnCancel.OnClick := OnClickOperation;
end;

procedure TViewUserGroupPermission.FormShow(Sender: TObject);
begin
  OpenGroup;
  Self.Height := Screen.Height - 100;
end;

procedure TViewUserGroupPermission.CheckGroupsView(Selected: string; IdItemGroup: Integer = 0);
var
  i,y: Integer;
begin
  for i := 0 to Pred(scrList.ControlCount) do
    if (scrList.Controls[i] is TPanel) then
      for y := 0 to Pred(TPanel(scrList.Controls[i]).ControlCount) do
        if TPanel(scrList.Controls[i]).Controls[y] is TDBGrid then
          with TDBGrid(TPanel(scrList.Controls[i]).Controls[y]).DataSource do
            try
              DataSet.DisableControls;
              DataSet.First;
              while not DataSet.Eof do
              begin
                if IdItemGroup = 0 then
                begin
                  DataSet.Edit;
                  DataSet.FieldByName('selectedField').AsString := Selected;
                  DataSet.Post;
                end
                else
                begin
                  if IdItemGroup = DataSet.FieldByName(FPermissionUser.PermissionUserTableGroupUser.UserFieldId).AsInteger then
                  begin
                    DataSet.Edit;
                    DataSet.FieldByName('selectedField').AsString := Selected;
                    DataSet.Post;
                  end;
                end;
                DataSet.Next;
              end;
            finally
              DataSet.EnableControls;
            end;
end;

procedure TViewUserGroupPermission.CheckGroupsMain(Selected: string; IdItemGroup: Integer = 0);
var
  i,y: Integer;
begin
  for i := 0 to Pred(tshPermissionsMain.ControlCount) do
    if (tshPermissionsMain.Controls[i] is TPanel) then
      for y := 0 to Pred(TPanel(tshPermissionsMain.Controls[i]).ControlCount) do
        if TPanel(tshPermissionsMain.Controls[i]).Controls[y] is TDBGrid then
          with TDBGrid(TPanel(tshPermissionsMain.Controls[i]).Controls[y]).DataSource do
            try
              DataSet.DisableControls;
              DataSet.First;
              while not DataSet.Eof do
              begin
                if IdItemGroup = 0 then
                begin
                  DataSet.Edit;
                  DataSet.FieldByName('selectedField').AsString := Selected;
                  DataSet.Post;
                end
                else
                begin
                  if IdItemGroup = DataSet.FieldByName(FPermissionUser.PermissionUserTableGroupUser.UserFieldId).AsInteger then
                  begin
                    DataSet.Edit;
                    DataSet.FieldByName('selectedField').AsString := Selected;
                    DataSet.Post;
                  end;
                end;
                DataSet.Next;
              end;
            finally
              DataSet.EnableControls;
            end;
end;

procedure TViewUserGroupPermission.DeleteGroup(IdGroup: Integer);
const
  SqlDelete = 'delete from %s '+
              'where '+
              '  %s = :%s';
begin
  with TQuery.Create(FPermissionUser.PermissionUserConnection.Connection,Format(SqlDelete,[FPermissionUser.PermissionUserTableGroupUser.UserTableName,FPermissionUser.PermissionUserTableGroupUser.UserFieldIdUser,FPermissionUser.PermissionUserTableGroupUser.UserFieldIdUser])) do
    try
      qy.Connection.StartTransaction;
      qy.ParamByName(FPermissionUser.PermissionUserTableGroupUser.UserFieldIdUser).AsInteger := IdGroup;
      qy.ExecSQL;
      qy.Connection.Commit;
    finally
      Free;
    end;
end;

procedure TViewUserGroupPermission.FreeObjectGrid;
var
  i: Integer;
begin
  try
    scrList.Visible := False;
    for i := scrList.ControlCount - 1 downto 0 do
      scrList.Controls[i].Destroy;
    for i := tshPermissionsMain.ControlCount - 1 downto 0 do
      tshPermissionsMain.Controls[i].Destroy;
  finally
    scrList.Visible := True;
  end;
end;

procedure TViewUserGroupPermission.OnClickOperation(Sender: TObject);

  function GetSQLComponents: string;
  const
    SqlGroup = 'select '+
               '  * '+
               'from '+
               '  %s '+
               'order by '+
               '  4';
  begin
    case FPermissionUser.PermissionUserConnection.DataBase of
      Mysql: Result := Format(SqlGroup,[FPermissionUser.PermissionUserTableGroupComponents.UserTableName]);
    end;
  end;

  function GetSQLGroup: string;
  const
    SqlGroup = 'select '+
               '  * '+
               'from '+
               '  %s '+
               'group by '+
               '  %s '+
               'order by '+
               '  4';
  begin
    case FPermissionUser.PermissionUserConnection.DataBase of
      Mysql: Result := Format(SqlGroup,[FPermissionUser.PermissionUserTableGroupComponents.UserTableName,
                                        FPermissionUser.PermissionUserTableGroupComponents.UserFieldGroup]);
    end;
  end;

  procedure CreateGridComponents(Group: string; Main: Boolean);
  var
    grdComponents: TDBGrid;
    dsComponents: TDataSource;
    Bookmark: TBookmark;
    PnlParent, PnlTitle : TPanel;
    AOwner: TComponent;
  begin
    if Main then
      AOwner := tshPermissionsMain
    else
      AOwner := scrList;

    //PANEL TITLE GROUP
    PnlTitle := TPanel.Create(AOwner);
    PnlTitle.Caption := Group+':';
    PnlTitle.Font.Size := 10;
    PnlTitle.Font.Name := 'Segoe UI';
    PnlTitle.Font.Style := [fsBold];
    PnlTitle.Height := 20;
    PnlTitle.Alignment := taLeftJustify;
    PnlTitle.Align := alTop;
    PnlTitle.BevelOuter := bvNone;

    //GRID
    grdComponents := TDBGrid.Create(AOwner);
    dsComponents := TDataSource.Create(AOwner);
    dsComponents.DataSet := FDataGroup.GetNewDataset(grdComponents,FPermissionUser.PermissionUserTableGroupComponents.UserFieldId,FPermissionUser.PermissionUserTableGroupComponents.UserFieldDescription);
    grdComponents.DataSource := dsComponents;
    grdComponents.OnDrawColumnCell := Self.OnDrawColumnCell;
    grdComponents.OnDblClick := Self.OnDblClick;
    grdComponents.Align := alClient;
    grdComponents.Columns[0].Width := 25;
    grdComponents.Columns[2].Width := scrList.Width - 60;
    grdComponents.Columns[1].Visible := False;
    grdComponents.Columns[3].Visible := False;
    grdComponents.BorderStyle := bsNone;
    grdComponents.Tag := 1;
    grdComponents.Options := [dgRowSelect];

    Bookmark := FDataSetComponents.GetBookmark;
    try
      FDataSetComponents.Filter := Format('%s = %s',[FPermissionUser.PermissionUserTableGroupComponents.UserFieldGroup,QuotedStr(Group)]);
      FDataSetComponents.Filtered := True;
      FDataSetComponents.First;
      while not FDataSetComponents.Eof do
      begin
        dsComponents.DataSet.Append;
        dsComponents.DataSet.FieldByName(FPermissionUser.PermissionUserTableGroupComponents.UserFieldDescription).AsString := FDataSetComponents.FieldByName(FPermissionUser.PermissionUserTableGroupComponents.UserFieldDescription).AsString;
        dsComponents.DataSet.FieldByName(FPermissionUser.PermissionUserTableGroupComponents.UserFieldId).AsInteger := FDataSetComponents.FieldByName(FPermissionUser.PermissionUserTableGroupComponents.UserFieldId).AsInteger;
        dsComponents.DataSet.FieldByName('selectedField').AsString := 'N';
        dsComponents.DataSet.Post;
        FDataSetComponents.Next;
      end;
      dsComponents.DataSet.First;
      if not Main then
        grdComponents.Height := (grdComponents.DataSource.DataSet.RecordCount * 18) + 5;
    finally
      FDataSetComponents.Filtered := False;
      FDataSetComponents.GotoBookmark(Bookmark);
      FDataSetComponents.FreeBookmark(Bookmark);
    end;

    //PANEL PARENT
    PnlParent := TPanel.Create(AOwner);
    PnlParent.Height := PnlTitle.Height + grdComponents.Height;
    PnlParent.Width := 260;
    PnlParent.Align := alTop;
    PnlParent.BevelOuter := bvNone;

    if Main then
    begin
      PnlParent.Parent := tshPermissionsMain;
      PnlParent.Align := alClient;
    end
    else
      PnlParent.Parent := scrList;

    PnlTitle.Parent := PnlParent;
    grdComponents.Parent := PnlParent;
  end;

  procedure CreateGroupListPanel;
  begin
    try
      FDataSetGroup.First;
      FDataSetGroup.DisableControls;
      while not FDataSetGroup.Eof do
      begin
        CreateGridComponents(FDataSetGroup.FieldByName(FPermissionUser.PermissionUserTableGroupComponents.UserFieldGroup).AsString,FDataSetGroup.FieldByName(FPermissionUser.PermissionUserTableGroupComponents.UserFieldMain).AsBoolean);
        FDataSetGroup.Next;
      end;
    finally
      FDataSetGroup.EnableControls;
    end;
  end;

  procedure SelectedEdit(IdGroup: Integer);
  const
    SqlEdit = 'select '+
              '  * '+
              'from '+
              '  %s '+
              'where '+
              '  %s = :%s ';
  begin
    with TQuery.Create(FPermissionUser.PermissionUserConnection.Connection,Format(SqlEdit,[FPermissionUser.PermissionUserTableGroupUser.UserTableName,FPermissionUser.PermissionUserTableGroupUser.UserFieldIdUser,FPermissionUser.PermissionUserTableGroupUser.UserFieldIdUser])) do
      try
        qy.ParamByName(FPermissionUser.PermissionUserTableGroupUser.UserFieldIdUser).AsInteger := IdGroup;
        qy.Open;
        qy.First;
        while not qy.Eof do
        begin
          CheckGroupsView('S',qy.FieldByName(FPermissionUser.PermissionUserTableGroupUser.UserFieldIdGroup).AsInteger);
          CheckGroupsMain('S',qy.FieldByName(FPermissionUser.PermissionUserTableGroupUser.UserFieldIdGroup).AsInteger);
          qy.Next;
        end;
      finally
        Free;
      end;
  end;

  procedure SaveComponentsGroup(IdGroup: Integer);
  const
    SqlInsertGroupComponents = 'insert into %s '+
                               ' (%s, '+
                               '  %s) '+
                               'values '+
                               ' (:%s, '+
                               '  :%s) ';
  var
    i,y: Integer;
  begin
    for i := 0 to Pred(scrList.ControlCount) do
      if (scrList.Controls[i] is TPanel) then
        for y := 0 to Pred(TPanel(scrList.Controls[i]).ControlCount) do
          if TPanel(scrList.Controls[i]).Controls[y] is TDBGrid then
            with TDBGrid(TPanel(scrList.Controls[i]).Controls[y]).DataSource do
              try
                DataSet.DisableControls;
                DataSet.First;
                while not DataSet.Eof do
                begin
                  if DataSet.FieldByName('selectedField').AsString = 'S' then
                    with TQuery.Create(FPermissionUser.PermissionUserConnection.Connection,Format(SqlInsertGroupComponents,[FPermissionUser.PermissionUserTableGroupUser.UserTableName,FPermissionUser.PermissionUserTableGroupUser.UserFieldIdGroup,FPermissionUser.PermissionUserTableGroupUser.UserFieldIdUser,FPermissionUser.PermissionUserTableGroupUser.UserFieldIdGroup,FPermissionUser.PermissionUserTableGroupUser.UserFieldIdUser])) do
                      try
                        qy.ParamByName(FPermissionUser.PermissionUserTableGroupUser.UserFieldIdGroup).AsInteger := DataSet.FieldByName(FPermissionUser.PermissionUserTableGroupComponents.UserFieldId).AsInteger;
                        qy.ParamByName(FPermissionUser.PermissionUserTableGroupUser.UserFieldIdUser).AsInteger := IdGroup;
                        qy.ExecSQL;
                      finally
                        Free;
                      end;
                  DataSet.Next;
                end;
              finally
                DataSet.EnableControls;
              end;
    for i := 0 to Pred(tshPermissionsMain.ControlCount) do
      if (tshPermissionsMain.Controls[i] is TPanel) then
        for y := 0 to Pred(TPanel(tshPermissionsMain.Controls[i]).ControlCount) do
          if TPanel(tshPermissionsMain.Controls[i]).Controls[y] is TDBGrid then
            with TDBGrid(TPanel(tshPermissionsMain.Controls[i]).Controls[y]).DataSource do
              try
                DataSet.DisableControls;
                DataSet.First;
                while not DataSet.Eof do
                begin
                  if DataSet.FieldByName('selectedField').AsString = 'S' then
                    with TQuery.Create(FPermissionUser.PermissionUserConnection.Connection,Format(SqlInsertGroupComponents,[FPermissionUser.PermissionUserTableGroupUser.UserTableName,FPermissionUser.PermissionUserTableGroupUser.UserFieldIdGroup,FPermissionUser.PermissionUserTableGroupUser.UserFieldIdUser,FPermissionUser.PermissionUserTableGroupUser.UserFieldIdGroup,FPermissionUser.PermissionUserTableGroupUser.UserFieldIdUser])) do
                      try
                        qy.ParamByName(FPermissionUser.PermissionUserTableGroupUser.UserFieldIdGroup).AsInteger := DataSet.FieldByName(FPermissionUser.PermissionUserTableGroupComponents.UserFieldId).AsInteger;
                        qy.ParamByName(FPermissionUser.PermissionUserTableGroupUser.UserFieldIdUser).AsInteger := IdGroup;
                        qy.ExecSQL;
                      finally
                        Free;
                      end;
                  DataSet.Next;
                end;
              finally
                DataSet.EnableControls;
              end;
  end;

  procedure SaveGroup;
  begin
    DeleteGroup(dsRecords.DataSet.Fields[0].AsInteger);
    SaveComponentsGroup(dsRecords.DataSet.Fields[0].AsInteger);
  end;

  procedure Loads;
  begin
    FDataGroup.LoadGroup(FPermissionUser.PermissionUserConnection.Connection,GetSQLGroup,FDataSetGroup);
    FDataGroup.LoadComponents(FPermissionUser.PermissionUserConnection.Connection,GetSQLComponents,FDataSetComponents);
    CreateGroupListPanel;
  end;

begin
  if Sender = btnInsert then
    try
      dsRecords.DataSet.Append;
      Loads;
    finally
      tshGrid.TabVisible := False;
      tshRecords.TabVisible := True;
    end
  else
  if Sender = btnEdit then
    try
      if dsRecords.DataSet.IsEmpty then
        Exit;
      dsRecords.DataSet.Edit;
      Loads;
      SelectedEdit(dsRecords.DataSet.Fields[0].AsInteger);
    finally
      tshGrid.TabVisible := False;
      tshRecords.TabVisible := True;
    end
  else
  if Sender = btnSave then
    try
      if edtNameGroup.Text = '' then
        edtNameGroup.Text := 'GRUPO SEM DEFINIÇÃO';
      pnlOperation.Enabled := False;
      TQuery.Operation(toSave,dsRecords.DataSet);
      SaveGroup;
      OpenGroup;
      FreeObjectGrid;
    finally
      tshRecords.TabVisible := False;
      tshGrid.TabVisible := True;
      pnlOperation.Enabled := True;
    end
  else
  if Sender = btnDelete then
  begin
    if (dsRecords.DataSet.IsEmpty) or (MessageBox(0,'Confirma exclusão do registro ?'+'','Informação',mb_iconquestion+mb_taskmodal+mb_yesno)=id_no) then
      Exit;
    DeleteGroup(dsRecords.DataSet.Fields[0].AsInteger);
    TQuery.Operation(toDelete,dsRecords.DataSet);
  end
  else
  if Sender = btnCancel then
    try
      FreeObjectGrid;
      dsRecords.DataSet.Cancel;
    finally
      tshRecords.TabVisible := False;
      tshGrid.TabVisible := True;
    end
  else
  if Sender = btnClose then
    Close;
end;

procedure TViewUserGroupPermission.OnDblClick(Sender: TObject);
begin
  if TDBGrid(Sender).DataSource.DataSet.FieldByName('selectedField').AsString = 'S' then
  begin
    TDBGrid(Sender).DataSource.DataSet.Edit;
    TDBGrid(Sender).DataSource.DataSet.FieldByName('selectedField').AsString := 'N';
    TDBGrid(Sender).DataSource.DataSet.Post;
  end
  else
  begin
    TDBGrid(Sender).DataSource.DataSet.Edit;
    TDBGrid(Sender).DataSource.DataSet.FieldByName('selectedField').AsString := 'S';
    TDBGrid(Sender).DataSource.DataSet.Post;
  end;
end;

procedure TViewUserGroupPermission.OnDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if Column.Field = TDBGrid(Sender).DataSource.DataSet.FieldByName('selectedImage') then
  begin
    TDBGrid(Sender).Canvas.FillRect(Rect);
    if TDBGrid(Sender).DataSource.DataSet.FieldByName('selectedField').AsString = 'N' then
      ImgList.Draw(TDBGrid(Sender).Canvas,Rect.Left+5,Rect.Top+1,0)
    else
      ImgList.Draw(TDBGrid(Sender).Canvas,Rect.Left+5,Rect.Top+1,1);
  end;
end;

procedure TViewUserGroupPermission.OpenGroup;
const
  SqlSelect = 'select '+
              '  * '+
              'from '+
              '  %s '+
              'where '+
              '  %s is null and '+
              '  %s = ''false''';
begin
  dsRecords.DataSet := FDataGroup.LoadListGroup(FPermissionUser.PermissionUserConnection.Connection,Format(SqlSelect,[FPermissionUser.PermissionUserTable.UserTableName,
                                                                                                                      FPermissionUser.PermissionUserTable.UserFieldIdGroup,
                                                                                                                      FPermissionUser.PermissionUserTable.UserFieldUserSystem]));
  edtNameGroup.DataField := dsRecords.DataSet.Fields[2].FieldName;
end;

procedure TViewUserGroupPermission.btnNotAllMainClick(Sender: TObject);
begin
  CheckGroupsMain('S');
end;

procedure TViewUserGroupPermission.bntAllMainClick(Sender: TObject);
begin
  CheckGroupsMain('N');
end;

procedure TViewUserGroupPermission.bntAllViewsClick(Sender: TObject);
begin
  CheckGroupsView('N');
end;

procedure TViewUserGroupPermission.btnNotAllViewsClick(Sender: TObject);
begin
  CheckGroupsView('S');
end;

end.
