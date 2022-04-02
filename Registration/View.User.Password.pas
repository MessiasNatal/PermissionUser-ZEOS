unit View.User.Password;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TOperation = (toNew, toUpdate);
  TViewUserPassword = class(TForm)
    lblPassword1: TLabel;
    btnOk: TBitBtn;
    edtPassword1: TEdit;
    lblPassword2: TLabel;
    edtPassword2: TEdit;
    lblPassword3: TLabel;
    edtPassword3: TEdit;
    btnCancel: TBitBtn;
    procedure btnCancelClick(Sender: TObject);
  public
    class function GetPassword(Operation: TOperation; PasswordCurrent: string = ''): string;
  end;

implementation

{$R *.dfm}

{ TViewUserPassword }

procedure TViewUserPassword.btnCancelClick(Sender: TObject);
begin
  ModalResult := MrCancel;
end;

class function TViewUserPassword.GetPassword(Operation: TOperation; PasswordCurrent: string): string;
var
  Answer: Boolean;
begin
  with Self.Create(nil) do
    try
      case Operation of
        toNew:
        begin
          lblPassword1.Caption := 'Digite a Senha';
          lblPassword2.Caption := 'Confirme a Senha Digitada';
          lblPassword3.Visible := False;
          edtPassword3.Visible := False;
          Height := 179;
          btnOk.Top := 107;
          btnCancel.Top := 107;
        end;
        toUpdate:
        begin
          lblPassword1.Caption := 'Digite a Senha Atual';
          lblPassword2.Caption := 'Nova Senha';
          lblPassword3.Caption := 'Confirme a Nova Senha Digitada';
          Height := 227;
        end;
      end;
      Answer := False;
      repeat
        ShowModal;
        case Operation of
          toNew:
          begin
            Result := edtPassword1.Text;
            Answer := (edtPassword1.Text = edtPassword2.Text) and (edtPassword1.Text <> '') and (edtPassword2.Text <> '');
            if not Answer then
              MessageDlg('Senha de Confirmação não Confere.',mtWarning,[mbok],0);
          end;
          toUpdate:
          begin
            Result := edtPassword2.Text;
            Answer := (edtPassword1.Text = PasswordCurrent) and (edtPassword2.Text = edtPassword3.Text) and (edtPassword1.Text <> '') and (edtPassword2.Text <> '') and (edtPassword3.Text <> '');
            if (not Answer and (ModalResult = mrOk)) then
              MessageDlg('Senha Alterada não Confere.',mtWarning,[mbok],0);
          end;
        end;
      until (Answer or (ModalResult = mrCancel));
    finally
      Free;
    end;
end;

end.
