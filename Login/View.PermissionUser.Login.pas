unit View.PermissionUser.Login;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TViewPermissionUserLogin = class(TForm)
    lbUser: TLabel;
    lbPassword: TLabel;
    btnCancel: TBitBtn;
    btnOK: TBitBtn;
    lnlLogin: TLabel;
    pnlUser: TPanel;
    edtUser: TEdit;
    pnlPassword: TPanel;
    edtPassword: TEdit;
    imgLogin: TImage;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure edtPasswordKeyPress(Sender: TObject; var Key: Char);
    procedure edtUserKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
  end;

implementation

{$R *.dfm}

procedure TViewPermissionUserLogin.btnCancelClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TViewPermissionUserLogin.btnOKClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TViewPermissionUserLogin.edtPasswordKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    btnOK.SetFocus;
end;

procedure TViewPermissionUserLogin.edtUserKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    edtPassword.SetFocus;
end;

procedure TViewPermissionUserLogin.FormShow(Sender: TObject);
begin
  SetWindowPos(Self.handle, HWND_TOPMOST, Self.Left, Self.Top,Self.Width, Self.Height, 0);
  edtUser.SetFocus;
end;

end.
