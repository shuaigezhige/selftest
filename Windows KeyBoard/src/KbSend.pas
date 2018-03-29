unit KbSend;

interface

uses Windows;

var
  nDownShift: Integer = -1; // 之前按下的Shift
  nDownMenu: Integer = -1;  // 之前按下的Menu
  nDownCtrl: Integer = -1;  // 之前按下的Ctrl

procedure SendKey(nIndex: Integer; PtTip: PPoint);

implementation

uses Messages, MainWindow, KeyWindow, TipWindow, KbFunc, KbUsEx, Setting, ResDef;

//
// ** 前置声明 **
//
procedure SendKey_Extra(nIndex: Integer); forward;
procedure SendKey_NumPad(ScanCode: UInt); forward;
procedure SendKey_Extend(VirtualKey, ScanCode: UInt); forward;
procedure SendKey_Normal(VirtualKey, ScanCode: Word); forward;
procedure SendDown_Normal(VirtualKey, ScanCode: Word); forward;
procedure SendUp_Normal(VirtualKey, ScanCode: Word); forward;

//
// Send out the keystroke using SendInput
//
procedure SendKey(nIndex: Integer; PtTip: PPoint);
const {$J+}
  fTipShow: Bool = False; {$J-} // Tip显示中..
var
  fExtend: Bool;
  VirtualKey: UInt;
begin
  // 主窗口激活状态
  if (GetForegroundWindow() = g_hKbMainWnd) and (PtTip <> nil) then
  begin
    fTipShow := True;
    MoveTip(PtTip.x + 10, PtTip.y + 10);     // Tip位置
    ShowTip(1);                              // 显示Tip
    SetTimer(g_hKbMainWnd, 1014, 3000, nil); // 显示3秒
  end else
    if (fTipShow) then
    begin
      fTipShow := False;
      ShowTip(0);                            // 隐藏Tip
    end;

  // Make sure we are in the range(# of keys)
  if (nIndex < Low(KbKeyList)) or (nIndex > High(KbKeyList)) then Exit;

  // Extra Keys (Window Keys, App Key)
  if (lStrCmp(KbKeyList[nIndex].TextL, 'winlogoUp') = 0) or
     (lStrCmp(KbKeyList[nIndex].TextL, 'MenuKeyUp') = 0) then
  begin
    SendKey_Extra(nIndex);
    Exit;
  end;

  // extended key
  if (KbKeyList[nIndex].ScanCode[0] = $E0) then
  begin
    if (KbKeyList[nIndex].ScanCode[1] >= $47) and
       (KbKeyList[nIndex].ScanCode[1] <= $53) then
    begin
      // Incase of Arrow keys/ Home/ End keys do special procesing.
      case (KbKeyList[nIndex].ScanCode[1]) of
        $47: VirtualKey := VK_HOME;   // Home
        $48: VirtualKey := VK_UP;     // UP
        $49: VirtualKey := VK_PRIOR;  // PGUP
        $4B: VirtualKey := VK_LEFT;   // LEFT
        $4D: VirtualKey := VK_RIGHT;  // RIGHT
        $4F: VirtualKey := VK_END;    // END
        $50: VirtualKey := VK_DOWN;   // DOWN
        $51: VirtualKey := VK_NEXT;   // PGDOWN
        $52: VirtualKey := VK_INSERT; // INS
        $53: VirtualKey := VK_DELETE; // DEL
        else Exit;
      end;

      // Do the processing here itself
      SendKey_Extend(VirtualKey, KbKeyList[nIndex].ScanCode[1]);
      Exit;
    end;

    VirtualKey := MapVirtualKey(KbkeyList[nIndex].ScanCode[1], 1);
    fExtend := True;
  end else
    if (KbKeyList[nIndex].ScanCode[0] >= $47) and (KbKeyList[nIndex].ScanCode[0] <= $53) then // NumPad
    begin
      SendKey_NumPad(KbKeyList[nIndex].ScanCode[0]);
      Exit;
    end else // other keys
    begin
      VirtualKey := MapVirtualKey(KbKeyList[nIndex].ScanCode[0], 1);
      fExtend := False;
    end;

  case (KbKeyList[nIndex].Name) of
    KB_PSC:
    begin
      SendKey_Normal(VK_SNAPSHOT, 0);
    end;

    KB_LCTR, KB_RCTR:
    begin
      if (nDownCtrl = -1) then  // 按下
      begin
        SendDown_Normal(VK_CONTROL, KbKeyList[nIndex].ScanCode[0]);

        SetKeyLong(nIndex, 2);
        nDownCtrl := nIndex;
      end else                  // 抬起
      begin
        SendUp_Normal(VK_CONTROL, KbKeyList[nIndex].ScanCode[0]);

        SetKeyLong(nDownCtrl, 0);
        nDownCtrl := -1;
      end;
    end;

    KB_LSHIFT, KB_RSHIFT:
    begin
      if (nDownShift = -1) then // 按下
      begin
        SendDown_Normal(VK_SHIFT, KbKeyList[nIndex].ScanCode[0]);

        SetKeyLong(nIndex, 2);
        nDownShift := nIndex;
      end else                  // 抬起
      begin
        SendUp_Normal(VK_SHIFT, KbKeyList[nIndex].ScanCode[0]);

        SetKeyLong(nDownShift, 0);
        nDownShift := -1;
      end;
      RedrawKeys();
    end;

    KB_LALT, KB_RALT:
    begin
      if (nDownMenu = -1) then // 按下
      begin
        SendDown_Normal(VK_MENU, $38);

        SetKeyLong(nIndex, 2);
        nDownMenu := nIndex;
      end else
      begin                    // 抬起
        SendUp_Normal(VK_MENU, $38);

        SetKeyLong(nDownMenu, 0);
        nDownMenu := -1;
      end;
      RedrawKeys();
    end;

    KB_CAPLOCK:
    begin
      if (GetKeyState(VK_CAPITAL) and $0001 = 0) then SetKeyLong(nIndex, 2) else SetKeyLong(nIndex, 0);
      SendKey_Normal(VirtualKey, KbKeyList[nIndex].ScanCode[0]);
      RedrawKeys();
    end;

    KB_NUMLOCK:
    begin
      if (GetKeyState(VK_NUMLOCK) and $0001 = 0) then SetKeyLong(nIndex, 2) else SetKeyLong(nIndex, 0);
      SendKey_Normal(VK_NUMLOCK, $45);
      RedrawKeys();
    end;

    KB_SCROLL:
    begin
      if (GetKeyState(VK_SCROLL) and $0001 = 0) then SetKeyLong(nIndex, 2) else SetKeyLong(nIndex, 0);
      SendKey_Normal(VK_SCROLL, $46);
    end;

    else begin
      if (fExtend) then
        SendKey_Extend(VirtualKey, KbKeyList[nIndex].ScanCode[1])
      else
        // MapVirtualKey returns 0 for 'Break' key. Special case for 'Break'.
        if (VirtualKey = 0) and (KbKeyList[nIndex].ScanCode[0] = $E1) then
          if (GetAsyncKeyState(VK_CONTROL) and $8000 <> 0) then
            SendKey_Normal(03, KBkeyList[nIndex].ScanCode[2])
          else
            SendKey_Normal(19, KBkeyList[nIndex].ScanCode[0])
        else
          SendKey_Normal(VirtualKey, KbkeyList[nIndex].ScanCode[0]);
    end;
  end; // case (KbKey[nIndex].Name) of ..
end;

//
// Win键 & 菜单键
//
procedure SendKey_Extra(nIndex: Integer);
var
  ScanCode, VirtualKey: UInt;
begin
  if (lStrCmp(KbKeyList[nIndex].SkCap, 'App') = 0) then // App Key
  begin
    ScanCode := MapVirtualKey(VK_APPS, 0);
    VirtualKey := VK_APPS;
  end else
    if (lStrCmp(KbKeyList[nIndex].skCap, 'lwin') = 0) then // Left Window Key Down
    begin
      ScanCode := MapVirtualKey(VK_LWIN, 0);
      VirtualKey := VK_LWIN;
    end else
      if (lStrCmp(KbKeyList[nIndex].skCap, 'rwin') = 0) then // Right Window Key Down
      begin
        ScanCode := MapVirtualKey(VK_RWIN, 0);
        VirtualKey := VK_RWIN;
      end else
        Exit;

  SendKey_Extend(VirtualKey, ScanCode);
end;

//
// NumPad key down & up (数字小键盘)
//
procedure SendKey_NumPad(ScanCode: UInt);
var
  NumLock: Bool;
begin
  NumLock := (GetKeyState(VK_NUMLOCK) and $0001 = 1);

  case (ScanCode) of
    $47: if NumLock then SendKey_Normal(VK_NUMPAD7, ScanCode) else SendKey_Normal(VK_HOME, ScanCode);
    $48: if NumLock then SendKey_Normal(VK_NUMPAD8, ScanCode) else SendKey_Normal(VK_UP, ScanCode);
    $49: if NumLock then SendKey_Normal(VK_NUMPAD9, ScanCode) else SendKey_Normal(VK_PRIOR, ScanCode);
    $4A: SendKey_Normal(VK_SUBTRACT, ScanCode);
    $4B: if NumLock then SendKey_Normal(VK_NUMPAD4, ScanCode) else SendKey_Normal(VK_LEFT, ScanCode);
    $4C: if NumLock then SendKey_Normal(VK_NUMPAD5, ScanCode);
    $4D: if NumLock then SendKey_Normal(VK_NUMPAD6, ScanCode) else SendKey_Normal(VK_RIGHT, ScanCode);
    $4E: SendKey_Normal(VK_ADD, ScanCode);
    $4F: if NumLock then SendKey_Normal(VK_NUMPAD1, ScanCode) else SendKey_Normal(VK_END, ScanCode);
    $50: if NumLock then SendKey_Normal(VK_NUMPAD2, ScanCode) else SendKey_Normal(VK_DOWN, ScanCode);
    $51: if NumLock then SendKey_Normal(VK_NUMPAD3, ScanCode) else SendKey_Normal(VK_NEXT, ScanCode);
    $52: if NumLock then SendKey_Normal(VK_NUMPAD0, ScanCode) else SendKey_Normal(VK_INSERT, ScanCode);
    $53: if NumLock then SendKey_Normal(VK_DECIMAL, ScanCode) else SendKey_Normal(VK_DELETE, ScanCode);
  end;
end;

//
// Extend key down & up
//
procedure SendKey_Extend(VirtualKey, ScanCode: UInt);
var
  rgInput: array[0..1] of TInput;
begin
  // extend key down
  rgInput[0].iType := INPUT_KEYBOARD;
  rgInput[0].ki.time := 0;
  rgInput[0].ki.dwFlags := KEYEVENTF_EXTENDEDKEY;
  rgInput[0].ki.dwExtraInfo := 66;
  rgInput[0].ki.wVk := VirtualKey;
  rgInput[0].ki.wScan := ScanCode;

  // extend key up
  rgInput[1].iType := INPUT_KEYBOARD;
  rgInput[1].ki.time := 0;
  rgInput[1].ki.dwFlags := KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP;
  rgInput[1].ki.dwExtraInfo := 66;
  rgInput[1].ki.wVk := VirtualKey;
  rgInput[1].ki.wScan := ScanCode;

  SendInput(2, rgInput[0], SizeOf(TInput));
end;

//
// Normal key down & up
//
procedure SendKey_Normal(VirtualKey, ScanCode: Word);
var
  rgInput: array[0..1] of TInput;
begin
  // Normal key down
  rgInput[0].iType := INPUT_KEYBOARD;
  rgInput[0].ki.time := 0;
  rgInput[0].ki.dwFlags := 0;
  rgInput[0].ki.dwExtraInfo := 66;
  rgInput[0].ki.wVk := VirtualKey;
  rgInput[0].ki.wScan := ScanCode;

  // Normal key up
  rgInput[1].iType := INPUT_KEYBOARD;
  rgInput[1].ki.time := 0;
  rgInput[1].ki.dwFlags := KEYEVENTF_KEYUP;
  rgInput[1].ki.dwExtraInfo := 66;
  rgInput[1].ki.wVk := VirtualKey;
  rgInput[1].ki.wScan := ScanCode;

  SendInput(2, rgInput[0], SizeOf(TInput));
end;

//
// Normal key down
//
procedure SendDown_Normal(VirtualKey, ScanCode: Word);
var
  rgInput: TInput;
begin
  rgInput.iType := INPUT_KEYBOARD;
  rgInput.ki.time := 0;
  rgInput.ki.dwFlags := 0;
  rgInput.ki.dwExtraInfo := 66;
  rgInput.ki.wVk := VirtualKey;
  rgInput.ki.wScan := ScanCode;

  SendInput(1, rgInput, SizeOf(TInput));
end;

//
// Normal key down
//
procedure SendUp_Normal(VirtualKey, ScanCode: Word);
var
  rgInput: TInput;
begin
  rgInput.iType := INPUT_KEYBOARD;
  rgInput.ki.time := 0;
  rgInput.ki.dwFlags := KEYEVENTF_KEYUP;
  rgInput.ki.dwExtraInfo := 66;
  rgInput.ki.wVk := VirtualKey;
  rgInput.ki.wScan := ScanCode;

  SendInput(1, rgInput, SizeOf(TInput));
end;

end.
