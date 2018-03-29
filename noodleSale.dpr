program noodleSale;

uses
  Windows,
  Forms,
  login in 'login.pas' {userLogin},
  main in 'main.pas' {mainForm},
  userEdit in 'userEdit.pas' {userEditFrame: TFrame},
  prodAdd in 'prodAdd.pas' {prodAddFrame: TFrame},
  order in 'order.pas' {OrderFrame: TFrame},
  dailyQuery in 'dailyQuery.pas' {dailyQueryFrame: TFrame},
  hisQuery in 'hisQuery.pas' {hisQueryFrame: TFrame},
  exclToRep_func in 'exclToRep_func.pas',
  otherSale in 'otherSale.pas' {additionFrame: TFrame},
  dataManage in 'dataManage.pas' {dataDelMan: TFrame};

{$R *.res}
var
  hMutex: hWnd;
begin
  Application.Initialize;
  Application.Title := 'Noodle';
  hMutex := CreateMutex(nil, false, 'Noodle');
  if GetLastError <> Error_Already_Exists then
    begin
      Application.CreateForm(TuserLogin, userLogin);
      Application.Run;
    end
  else
    begin
      Application.MessageBox('只允许同时运行一个本程序', '非法');
      ReleaseMutex(hMutex);
    end;

end.

