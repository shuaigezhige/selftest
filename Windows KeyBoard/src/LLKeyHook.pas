unit LLKeyHook;

interface

uses Windows;

function LLKeyHookOn(): Bool;
function LLKeyHookOff(): Bool;

implementation

uses Messages, MainWindow, KeyWindow, KbFunc, KbSend, ResDef;

//
// HHOOK to the low-level keyboard
//
var hLLKeyHook: HHook = 0;

//
// ** 前置声明 **
//
function LowLevelKeyboardProc(nCode: Integer; wParam: WParam; lParam: LParam): LResult; stdcall; forward;
procedure LLKeyDown(VirtualKey: UInt); forward;
procedure LLKeyUp(VirtualKey: UInt); forward;

//
// 安装键盘钩子
//
function LLKeyHookOn(): Bool;
const
  WH_KEYBOARD_LL = 13; { WinUser.h, Line 649 }
begin
  Result := False;

  hLLKeyHook := SetWindowsHookEx(WH_KEYBOARD_LL, @LowLevelKeyboardProc, HInstance, 0);
  if (hLLKeyHook = 0) then
  begin
    SendErrorMessage(IDS_LLKEY_HOOK);
    Exit;
  end;

  Result := True;
end;

//
// 卸载键盘钩子
//
function LLKeyHookOff(): Bool;
begin
  Result := UnhookWindowsHookEx(hLLKeyHook);
  if (Result = False) then SendErrorMessage(IDS_LLKEY_UNHOOK);
end;

//
// 键盘钩子回调
//
function LowLevelKeyboardProc(nCode: Integer; wParam: WParam; lParam: LParam): LResult; stdcall;
type
  PLLKeyHookStruct = ^TLLKeyHookStruct;
  TLLKeyHookStruct = record { WinUser.h, Line 926 }
    vkCode: DWord;
    scanCode: DWord;
    flags: DWord;
    time: DWord;
    dwExtraInfo: ULong;
  end;
begin
  Result := CallNextHookEx(hLLKeyHook, nCode, wParam, lParam);
  if (nCode <> HC_ACTION) or (PLLKeyHookStruct(lParam).dwExtraInfo = 66) then Exit;

  case (wParam) of
    WM_KEYDOWN:
      LLKeyDown(PLLKeyHookStruct(lParam).vkCode);

    WM_KEYUP:
      LLKeyUp(PLLKeyHookStruct(lParam).vkCode);
  end;
end;

//
// 按键按下处理
//
procedure LLKeyDown(VirtualKey: UInt);
begin
  case (VirtualKey) of
    VK_F11:
      if IsIconic(g_hKbMainWnd) then ShowWindow(g_hKbMainWnd, SW_RESTORE) else ShowWindow(g_hKbMainWnd, SW_SHOWMINIMIZED);

    VK_LSHIFT:
      if (nDownShift = -1) then SendKey(74, nil);

    VK_RSHIFT:
      if (nDownShift = -1) then SendKey(85, nil);
  end;
end;

//
// 按键抬起处理
//
procedure LLKeyUp(VirtualKey: UInt);
begin
  case (VirtualKey) of
    VK_LSHIFT,
    VK_RSHIFT:
      if (nDownShift <> -1) then SendKey(nDownShift, nil);

    VK_LMENU,
    VK_RMENU:
      if (nDownMenu <> -1) then SendKey(nDownMenu, nil);

    VK_LCONTROL,
    VK_RCONTROL:
      if (nDownCtrl <> -1) then SendKey(nDownCtrl, nil);

    VK_CAPITAL:
    begin
      RedrawCapsLock();
      RedrawKeys();
    end;

    VK_NUMLOCK:
    begin
      RedrawNumLock();
      RedrawKeys();
    end;

    VK_SCROLL:
      RedrawScrollLock();
  end;
end;

end.
