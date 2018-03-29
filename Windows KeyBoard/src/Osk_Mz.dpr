
//-----------------------------------------
//
// 屏幕键盘, 译自windows_2000_source_code\win2k\private\windows\shell\accessib\osk, 仅供参考..
//
// 特别感谢 阿虎、燕子、雪阳、阿紫、东兰、双木 等网友帮忙测试, :)
//
//
//                                 麻子, 2006-03
//
//-----------------------------------------

program Osk_Mz;

{$R '..\res\Osk_Mz.res' '..\res\Osk_Mz.rc'}

uses
  Windows,
  AboutDlg   in 'AboutDlg.pas',   // 关于对话框
  WarningDlg in 'WarningDlg.pas', // 提示对话框
  UpgradeDlg in 'UpgradeDlg.pas', // 更新对话框
  TipWindow  in 'TipWindow.pas',  // 气泡窗口
  KeyWindow  in 'KeyWindow.pas',  // 按键窗口
  MainWindow in 'MainWindow.pas', // 框架窗口
  MouseHook  in 'MouseHook.pas',  // 鼠标钩子
  LLKeyHook  in 'LLKeyHook.pas',  // 日志钩子
  KbUsEx in 'KbUsEx.pas', // 美式键盘
  KbFunc in 'KbFunc.pas', // 通用函数
  KbSend in 'KbSend.pas', // 发送按键
  ResDef in 'ResDef.pas', // Resource ID
  Setting in 'Setting.pas', // Data structure for Setting
  RegUtil in 'RegUtil.pas'; // 注册表读写

const
  SM_REMOTESESSION = $1000; { WinUser.h, Line 5559 }
var
  hMutexOSKRunning: THandle; // 互斥对象
  Msg: TMsg;  
begin
  // Allow only ONE instance of the program running.
  SetLastError(0);
  hMutexOSKRunning := CreateMutex(nil, True, 'OSKRunning_Mz');
  if (hMutexOSKRunning = 0) or (GetLastError() = ERROR_ALREADY_EXISTS) then Exit;

  // on Terminal server
  if (GetSystemMetrics(SM_REMOTESESSION) <> 0) then
  begin
    SendErrorMessage(IDS_TSERROR);
    Exit;
  end;

  // No mouse install
  if (GetSystemMetrics(SM_MOUSEPRESENT) = 0) then
  begin
    SendErrorMessage(IDS_NO_MOUSE);
    Exit;
  end;

  // use the setting read from Registry
  OpenUserSetting();

  // 注册窗口类
  if (RegisterLink() = False) or
     (RegisterMain() = False) or
     (RegisterKeys() = False) then
  begin
    SendErrorMessage(IDS_CANNOT_REGISTER_WIN);
    Exit;
  end;

  // 建立主窗口
  if (CreateMain() = False) then
  begin
    SendErrorMessage(IDS_CANNOT_CREATE_KB);
    Exit;
  end else
  begin
    SetMainTop();
    ShowWindow(g_hKbMainWnd, SW_SHOW);
    UpdateWindow(g_hKbMainWnd);
  end;

  // 安装钩子
  if (MouseHookOn() = False) then Exit;
  if (LLKeyHookOn() = False) then Exit;

  // check if there is necessary to show the initial warning msg
  if (KbInfo.ShowWarning) then WarningMsgDlgFunc();

  // 消息循环
  while (GetMessage(Msg, 0, 0, 0)) do
  begin
    TranslateMessage(Msg); // Translates character keys
    DispatchMessage(Msg); // Dispatches message to window
  end;

  // 卸载钩子
  MouseHookOff();
  LLKeyHookOff();

  // 收尾工作
  ReleaseMutex(hMutexOSKRunning);
  SaveUserSetting();
end.
