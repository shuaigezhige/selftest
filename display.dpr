program display;

uses
  Windows,
  Forms,
  kitchen in 'kitchen.pas' {displayForm};

{$R *.res}
var
  hMutex: hWnd;
begin
  Application.Initialize;
  Application.Title := 'kitchendisplay';
  hMutex := CreateMutex(nil, false, 'kitchendisplay');
  if GetLastError <> Error_Already_Exists then
     begin
       Application.CreateForm(TdisplayForm, displayForm);
       Application.Run;
     end
  else
    begin
      Application.MessageBox('只允许同时运行一个本程序', '非法');
      ReleaseMutex(hMutex);
    end;
end.
