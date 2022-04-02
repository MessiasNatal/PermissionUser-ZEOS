unit Registro;

interface

procedure register;

implementation

uses
  System.Classes, PermissionUser;

procedure register;
begin
  RegisterComponents('Permission User ZEOS',[TPermissionUser, TPermissionUserConection, TPermissionUserComponentsConfiguration]);
end;

end.
