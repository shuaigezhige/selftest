unit MainWindow;

interface

uses Windows;

//
// 主窗口句柄
//
var g_hKbMainWnd: HWnd;

function RegisterMain(): Bool;
function CreateMain(): Bool;
function SetMainTop(): Bool;

implementation

uses Messages, KeyWindow, TipWindow, AboutDlg, KbUsEx, KbFunc, Setting, ResDef;

//
// 前置声明 **
//
function MainWndProc(hMainWnd: HWnd; uMsg: UInt; wParam: WParam; lParam: LParam): LResult; stdcall; forward;

//
// 主窗口类名
//
const
  szKbMainClass = 'MainKb_Mz';

//
// 注册主窗口
//
function RegisterMain(): Bool;
var
  WndClass: TWndClass;
begin
  // Keyboard frame class
  WndClass.style       := CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS;
  WndClass.lpfnWndProc := @MainWndProc;
  WndClass.cbClsExtra  := 0;
  WndClass.cbWndExtra  := 0;
  WndClass.hInstance   := HInstance;
  WndClass.hIcon       := LoadIcon(HInstance, 'APP_OSK');
  WndClass.hCursor     := LoadCursor(0, IDC_ARROW);
  WndClass.hbrBackground := COLOR_INACTIVECAPTION + 1;
  WndClass.lpszMenuName  := 'IDR_MENU';
  WndClass.lpszClassName := szKbMainClass;

  Result := RegisterClass(WndClass) <> 0;
end;

//
// Create the main window (Keyboard)
//
function CreateMain(): Bool;
var
  szTitle: array[0..256] of Char;
  ScrRect: TRect;
  OffsetX, OffsetY: Integer;
begin
  Result := False;

  // 屏幕范围
  if (SystemParametersInfo(SPI_GETWORKAREA, 0, @ScrRect, 0) = False) then Exit;

  // Left & Right
  if (KbInfo.KbRect.Left < ScrRect.Left) then
    OffsetX := ScrRect.Left - KbInfo.KbRect.Left
  else
    if (KbInfo.KbRect.Right > ScrRect.Right) then
      OffsetX := ScrRect.Right - KbInfo.KbRect.Right
    else
      OffsetX := 0;

  // Top & Bottom
  if (KbInfo.KbRect.Top < ScrRect.Top) then
    OffsetY := ScrRect.Top - KbInfo.KbRect.Top
  else
    if (KbInfo.KbRect.Bottom > ScrRect.Bottom) then
      OffsetY := ScrRect.Bottom - KbInfo.KbRect.Bottom
    else
      OffsetY := 0;

  // 修正位置
  if (OffsetRect(KbInfo.KbRect, OffsetX, OffsetY) = False) then Exit;

  // 窗口标题
  if (LoadString(HInstance, IDS_TITLE, szTitle, 256) = 0) then Exit;

  // 建立窗口
  g_hKbMainWnd := CreateWindowEx(WS_EX_NOACTIVATE or WS_EX_APPWINDOW, szKbMainClass, szTitle,
    WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX, KbInfo.KbRect.Left, KbInfo.KbRect.Top,
    KbInfo.KbRect.Right - KbInfo.KbRect.Left, KbInfo.KbRect.Bottom - KbInfo.KbRect.Top, 0, 0, HInstance, nil);
  if (g_hKbMainWnd = 0) then Exit;

  Result := True;
end;

//
// Place the main window always on top / non top most
//
function SetMainTop(): Bool;
begin
  if (KbInfo.AlwaysOnTop) then
    Result := SetWindowPos(g_hKbMainWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE)
  else
    Result := SetWindowPos(g_hKbMainWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
end;

//
// 主窗口回调
//
function MainWndProc(hMainWnd: HWnd; uMsg: UInt; wParam: WParam; lParam: LParam): LResult; stdcall;
const
  KB_LARGERMARGIN = 202; // smallest width
  KB_CHARBMARGIN  = 57;  // smallest height
{$J+}
  OldWidth: Integer = 0;
  OldHeight: Integer = 0;
  hPreWindow: HWnd = 0;
{$J-}
var
  ClientRect: TRect;
  ChmPathBuf: array[0..MAX_PATH] of Char;
  X: Integer;  
begin
  case (uMsg) of
    WM_CREATE:
    begin
      Result := -1;

      // 建立按键窗口
      if (CreateKeys(hMainWnd) = False) then
      begin
        SendErrorMessage(IDS_CANNOT_CREATE_KEY);
        Exit;
      end;

      // 建立Tip窗口
      if (CreateTip(hMainWnd) = False) then
      begin
        SendErrorMessage(IDS_CANNOT_CREATE_TIP);
        Exit;
      end;

      SetForegroundWindow(hMainWnd);

      Result := 0;
    end;

    WM_SHOWWINDOW:
    begin
      RedrawNumLock();
      RedrawCapsLock();
      RedrawScrollLock();

      Result := 0;
    end;

    WM_SIZE:
    begin
      Result := 0;

      // 窗口处于最小化状态
      if IsIconic(hMainWnd) then Exit;

      // 窗口尺寸(宽/高)未变
      GetClientRect(hMainWnd, ClientRect);
      if (OldWidth = ClientRect.Right) and (OldHeight = ClientRect.Bottom) then
        Exit
      else begin
        OldWidth := ClientRect.Right;
        OldHeight := ClientRect.Bottom;
      end;

      // 调整各按键(位置&大小)
      ReSizeKeys(OldWidth / KB_LARGERMARGIN, OldHeight / KB_CHARBMARGIN);

      // Save the KB position
      GetWindowRect(hMainWnd, KbInfo.KbRect);
    end;

    WM_MOVE:
    begin
      if (IsIconic(hMainWnd) = False) then GetWindowRect(hMainWnd, KbInfo.KbRect);
      Result := 0;
    end;

    WM_EXITSIZEMOVE:
    begin
      SetForegroundWindow(hPreWindow);
      Result := 0;
    end;

{   WM_MOUSEMOVE:
    begin
      SetForegroundWindow(hPreWindow);
      Result := 0;
    end; }

    WM_MOUSEACTIVATE:
    begin
      X := LoWord(lParam);
      if (X = HTCAPTION) or (X = HTSIZE) or (X = HTREDUCE) or
         (X = HTSYSMENU) or (X = HTLEFT) or (X = HTTOP) or
         (X = HTRIGHT) or (X = HTBOTTOM) or (X = HTZOOM) or
         (X = HTTOPLEFT) or (X = HTTOPRIGHT) or (X = HTBOTTOMLEFT) or
         (X = HTBOTTOMRIGHT) or (X = HTMENU) or (X = HTCLOSE) then
      begin
        hPreWindow := GetForegroundWindow(); // save the current window handle
        SetForegroundWindow(hMainWnd);
      end;

      Result := MA_NOACTIVATE; // not activate and discard the mouse message
    end;

    WM_INITMENUPOPUP:
    begin
      // 前端显示
      if (KbInfo.AlwaysOntop) then
        CheckMenuItem(wParam, IDM_ALWAYS_ON_TOP, MF_CHECKED)
      else
        CheckMenuItem(wParam, IDM_ALWAYS_ON_TOP, MF_UNCHECKED);

      // 单击声响
      if (KbInfo.UseSound) then
        CheckMenuItem(wParam, IDM_CLICK_SOUND, MF_CHECKED)
      else
        CheckMenuItem(wParam, IDM_CLICK_SOUND, MF_UNCHECKED);

      Result := 0;
    end;

    WM_COMMAND:
    begin
      case LoWord(wParam) of
        IDM_EXIT:
          SendMessage(hMainWnd, WM_CLOSE, 0, 0);

        IDM_ALWAYS_ON_TOP:
        begin
          KbInfo.AlwaysOnTop := not KbInfo.AlwaysOnTop;
          SetMainTop();
        end;

        IDM_CLICK_SOUND:
          KbInfo.UseSound := not KbInfo.UseSound;

        IDM_SET_FONT:
          if ChooseNewFont() then RedrawKeys();

        IDM_HELPTOPICS:
        begin
          GetWindowsDirectory(ChmPathBuf, MAX_PATH);
          lStrCat(ChmPathBuf, '\HELP\OSK.CHM');
          HtmlHelp(0, ChmPathBuf, 0, 0);
        end;

        IDM_HELPABOUT:
          AboutDlgFunc();
      end;

      Result := 0;
    end;

    WM_TIMER:
    begin
      // 关闭定时器
      KillTimer(hMainWnd, 1014);

      // 隐藏ToolTip
      ShowTip(0);

      Result := 0;
    end;

    WM_DESTROY:
    begin
      PostQuitMessage(0);
      Result := 0;
    end;

    else
      Result := DefWindowProc(hMainWnd, uMsg, wParam, lParam);
  end;
end;

end.