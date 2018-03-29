unit MouseHook;

interface

uses Windows;

function MouseHookOn(): Bool;
function MouseHookOff(): Bool;

implementation

uses Messages, MainWindow, KeyWindow, KbFunc, KbSend, Setting, ResDef;

//
// handle to mouse hook
//
var hMouseHook: HHook = 0;

//
// ** 前置声明 **
//
function MouseProc(nCode: Integer; wParam: WParam; lParam: LParam): LResult; stdcall; forward;

//
// 安装鼠标钩子
//
function MouseHookOn(): Bool;
begin
  Result := False;

  hMouseHook := SetWindowsHookEx(WH_MOUSE, @MouseProc, 0, GetCurrentThreadId());
  if (hMouseHook = 0) then
  begin
    SendErrorMessage(IDS_MOUSE_HOOK);
    Exit;
  end;

  Result := True;
end;

//
// 卸载鼠标钩子
//
function MouseHookOff(): Bool;
begin
  Result := UnhookWindowsHookEx(hMouseHook);
  if (Result = False) then SendErrorMessage(IDS_MOUSE_UNHOOK);
end;

//
// Filter function for the WH_MOUSE
//
function MouseProc(nCode: Integer; wParam: WParam; lParam: LParam): LResult; stdcall;
const {$J+}
  LastDown: Bool = False; // 鼠标未抬起
  OldKeyPt: TPoint = ();
  OldIndex: Integer = -1; {$J-}
var
  NewIndex: Integer;
begin
  NewIndex := LocateKey(PMouseHookStruct(lParam).hWnd);

  case (wParam) of
    WM_MOUSEMOVE:
      if (LastDown = False) then
        if (NewIndex <> OldIndex) then
        begin
          if (GetKeyLong(OldIndex) < 2) then SetKeyLong(OldIndex, 0);
          if (GetKeyLong(NewIndex) < 2) then SetKeyLong(NewIndex, 1);
          OldIndex := NewIndex;
        end;

    WM_LBUTTONDOWN:
      if (NewIndex > -1) then
      begin
        LastDown := True;
        OldKeyPt := PMouseHookStruct(lParam).Pt;
        if (KbInfo.UseSound) then MakeClick(SND_DOWN);
        SetCapture(g_hKbMainWnd);
      end;

    WM_LBUTTONUP:
      if (LastDown = True) then
      begin
        LastDown := False;
        if (KbInfo.UseSound) then MakeClick(SND_UP);
        ReleaseCapture();
        SendKey(OldIndex, @OldKeyPt);

        if (NewIndex <> OldIndex) then
        begin
          if (GetKeyLong(OldIndex) < 2) then SetKeyLong(OldIndex, 0);
          if (GetKeyLong(NewIndex) < 2) then SetKeyLong(NewIndex, 1);
          OldIndex := NewIndex;
        end;
      end;
  end;
                                       
  Result := CallNextHookEx(hMouseHook, nCode, wParam, lParam);
end;

end.
