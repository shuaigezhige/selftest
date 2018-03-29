
//-----------------------------------------
//
// ��Ļ����, ����windows_2000_source_code\win2k\private\windows\shell\accessib\osk, �����ο�..
//
// �ر��л ���������ӡ�ѩ�������ϡ�������˫ľ �����Ѱ�æ����, :)
//
//
//                                 ����, 2006-03
//
//-----------------------------------------

program Osk_Mz;

{$R '..\res\Osk_Mz.res' '..\res\Osk_Mz.rc'}

uses
  Windows,
  AboutDlg   in 'AboutDlg.pas',   // ���ڶԻ���
  WarningDlg in 'WarningDlg.pas', // ��ʾ�Ի���
  UpgradeDlg in 'UpgradeDlg.pas', // ���¶Ի���
  TipWindow  in 'TipWindow.pas',  // ���ݴ���
  KeyWindow  in 'KeyWindow.pas',  // ��������
  MainWindow in 'MainWindow.pas', // ��ܴ���
  MouseHook  in 'MouseHook.pas',  // ��깳��
  LLKeyHook  in 'LLKeyHook.pas',  // ��־����
  KbUsEx in 'KbUsEx.pas', // ��ʽ����
  KbFunc in 'KbFunc.pas', // ͨ�ú���
  KbSend in 'KbSend.pas', // ���Ͱ���
  ResDef in 'ResDef.pas', // Resource ID
  Setting in 'Setting.pas', // Data structure for Setting
  RegUtil in 'RegUtil.pas'; // ע����д

const
  SM_REMOTESESSION = $1000; { WinUser.h, Line 5559 }
var
  hMutexOSKRunning: THandle; // �������
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

  // ע�ᴰ����
  if (RegisterLink() = False) or
     (RegisterMain() = False) or
     (RegisterKeys() = False) then
  begin
    SendErrorMessage(IDS_CANNOT_REGISTER_WIN);
    Exit;
  end;

  // ����������
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

  // ��װ����
  if (MouseHookOn() = False) then Exit;
  if (LLKeyHookOn() = False) then Exit;

  // check if there is necessary to show the initial warning msg
  if (KbInfo.ShowWarning) then WarningMsgDlgFunc();

  // ��Ϣѭ��
  while (GetMessage(Msg, 0, 0, 0)) do
  begin
    TranslateMessage(Msg); // Translates character keys
    DispatchMessage(Msg); // Dispatches message to window
  end;

  // ж�ع���
  MouseHookOff();
  LLKeyHookOff();

  // ��β����
  ReleaseMutex(hMutexOSKRunning);
  SaveUserSetting();
end.
