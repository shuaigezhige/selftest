unit KeyWindow;

interface

uses Windows;

function RegisterKeys(): Bool;
function CreateKeys(hMainWnd: HWnd): Bool;
function ReSizeKeys(ColMargin, RowMargin: Single): Bool;
function LocateKey(hKeyWnd: HWnd): Integer;
function GetKeyLong(nIndex: Integer): Integer;
function SetKeyLong(nIndex, nState: Integer): Bool;
function RedrawKeys(): Bool;
function RedrawNumLock(): Bool;
function RedrawCapsLock(): Bool;
function RedrawScrollLock(): Bool;

implementation

uses Messages, KbFunc, KbUsEx, KbSend, Setting, ResDef;

//
// 按键窗口句柄
//
var KeyWndList: array[0..103] of HWnd;

//
// ** 前置声明 **
//
function SetKeyRegion(hKeyWnd: HWnd; Width, Height: Integer): Bool; forward;
function KeyWndProc(hKeyWnd: HWnd; uMsg: UInt; wParam: WParam; lParam: LParam): LResult; stdcall; forward;
function DrawKeyRed(hKeyDc: HDC; Rect: TRect): Bool; forward;
function DrawKeyIcon(hKeyDc: HDC; pIconName: PChar; Rect: TRect): Bool; forward;
function DrawKeyBmp(hKeyDc: HDC; pBmpName: PChar; Rect: TRect): Bool; forward;
function DrawKeyText(hKeyDc: HDC; Rect: TRect; nIndex, nState: Integer): Bool; forward;
function DrawKeyLight(hKeyDc: HDC; Rect: TRect): Bool; forward;

//
// 注册按键窗口
//
function RegisterKeys(): Bool;
var
  WndClass: TWndClass;
  StrClass: array[0..20] of Char;
  J: Integer;
begin
  Result := False;

  WndClass.style         := CS_HREDRAW or CS_VREDRAW;
  WndClass.lpfnWndProc   := @KeyWndProc;
  WndClass.cbClsExtra    := 0;
  WndClass.cbWndExtra    := SizeOf(DWord); // 按键状态 ( 0 = 正常, 1 = 显亮, 2 = 按下 )
  WndClass.hInstance     := HInstance;
  WndClass.hIcon         := 0;
  WndClass.hCursor       := LoadCursor(HInstance, MakeIntResource(IDC_CURHAND));
  WndClass.hbrBackground := 0;
  WndClass.lpszMenuName  := nil;
  WndClass.lpszClassName := @StrClass;

  // All keys class
  for J := Low(KbKeyList) to High(KbKeyList) do
  begin
    case (KbKeyList[J].kType) of
      KNORMAL_TYPE:
      begin
        wvsprintf(StrClass, 'N%d_Mz', @J);
        WndClass.hbrBackground := COLOR_WINDOW + 1;
      end;

      KMODIFIER_TYPE:
      begin
        wvsprintf(StrClass, 'M%d_Mz', @J);
        WndClass.hbrBackground := COLOR_MENU + 1;
      end;

      KDEAD_TYPE:
      begin
        wvsprintf(StrClass, 'D%d_Mz', @J);
        WndClass.hbrBackground := COLOR_MENU + 1;
      end;

      NUMLOCK_TYPE:
      begin
        wvsprintf(StrClass, 'NL%d_Mz', @J);
        WndClass.hbrBackground := COLOR_MENU + 1;
      end;

      SCROLLOCK_TYPE:
      begin
        wvsprintf(StrClass, 'SL%d_Mz', @J);
        WndClass.hbrBackground := COLOR_MENU + 1;
      end;

      CAPSLOCK_TYPE:
      begin
        wvsprintf(StrClass, 'CL%d_Mz', @J);
        WndClass.hbrBackground := COLOR_MENU + 1;
      end;

      else Exit; // **
    end;

    if (RegisterClass(WndClass) = 0) then Exit;
  end;

  Result := True;
end;

//
// 建立按键窗口
//
function CreateKeys(hMainWnd: HWnd): Bool;
var
  StrClass: array[0..20] of Char;
  J: Integer;
begin
  Result := False;

  for J := Low(KbKeyList) to High(KbKeyList) do
  begin
    case (KbKeyList[J].kType) of
      KNORMAL_TYPE:
        wvsprintf(StrClass, 'N%d_Mz', @J);

      KMODIFIER_TYPE:
        wvsprintf(StrClass, 'M%d_Mz', @J);

      KDEAD_TYPE:
        wvsprintf(StrClass, 'D%d_Mz', @J);

      NUMLOCK_TYPE:
        wvsprintf(StrClass, 'NL%d_Mz', @J);

      SCROLLOCK_TYPE:
        wvsprintf(StrClass, 'SL%d_Mz', @J);

      CAPSLOCK_TYPE:
        wvsprintf(StrClass, 'CL%d_Mz', @J);

      else Exit;
    end;
                                                            
    KeyWndList[J] := CreateWindow(StrClass, KbKeyList[J].TextC, WS_VISIBLE or WS_CHILD or WS_BORDER, 0, 0, 0, 0, hMainWnd, J, HInstance, nil);
    if (KeyWndList[J] = 0) then Exit;
  end;

  Result := True;
end;

//
// 调整按键大小
//
function ReSizeKeys(ColMargin, RowMargin: Single): Bool;
const
  KB_DELTAKEYSIZE = 2; // increment in key size
var
  J, Width, Height: Integer; // Width and height of each window key
begin
  // for each key
  for J := Low(KbKeyList) to High(KbKeyList) do
  begin
    // Width & Height
    Width := Trunc(KbKeyList[J].kSizeX * ColMargin) + KB_DELTAKEYSIZE;
    Height := Trunc(KbKeyList[J].kSizeY * RowMargin) + KB_DELTAKEYSIZE;

    // move Keys
    MoveWindow(KeyWndList[J],
      Trunc(KbKeyList[J].PosX * ColMargin),
      Trunc(KbKeyList[J].PosY * RowMargin),
      Width, Height, True);

    // set the region we want for each key
    SetKeyRegion(KeyWndList[J], Width, Height);
  end;

  Result := True;
end;

//
// 返回按键编号
//
function LocateKey(hKeyWnd: HWnd): Integer;
begin
  for Result := Low(KeyWndList) to High(KeyWndList) do if (KeyWndList[Result] = hKeyWnd) then Exit;
  Result := -1;
end;

//
// 读取按键状态
//
function GetKeyLong(nIndex: Integer): Integer;
begin
  Result := 3;

  if (nIndex < Low(KbKeyList)) or (nIndex > High(KbKeyList)) then Exit;
  if (IsWindow(KeyWndList[nIndex]) = False) then Exit;

  Result := GetWindowLong(KeyWndList[nIndex], 0);
end;

//
// 设置按键状态
//
function SetKeyLong(nIndex, nState: Integer): Bool;
var
  hBackground: HBrush;
begin
  Result := False;

  // 超出范围
  if (nIndex < Low(KbKeyList)) or (nIndex > High(KbKeyList)) then Exit;

  // 背景画刷
  if (nState <> 0) then
    hBackground := COLOR_WINDOWTEXT + 1 // Hilite
  else
    case (KbKeyList[nIndex].kType) of
      KNORMAL_TYPE:
        hBackground := COLOR_WINDOW + 1;

      KMODIFIER_TYPE, KDEAD_TYPE, NUMLOCK_TYPE, SCROLLOCK_TYPE, CAPSLOCK_TYPE:
        hBackground := COLOR_MENU + 1;

      else Exit;
    end;
  SetClassLong(KeyWndList[nIndex], GCL_HBRBACKGROUND, hBackground);

  // 保存状态
  SetWindowLong(KeyWndList[nIndex], 0, nState);

  // 重绘按键
  InvalidateRect(KeyWndList[nIndex], nil, True);

  Result := True;
end;

//
// Round the coner of each key
//
function SetKeyRegion(hKeyWnd: HWnd; Width, Height: Integer): Bool;
var
  hKeyRgn: HRgn;
begin
  Result := False;

  hKeyRgn := CreateRoundRectRgn(1, 1, Width, Height, 5, 2);
  if (hKeyRgn = 0) then Exit;

  if (SetWindowRgn(hKeyWnd, hKeyRgn, True) = 0) then Exit;

  Result := False;
end;

//
// Redraw the keys
//
function RedrawKeys(): Bool;
var
  J: Integer;
begin
  for J := Low(KbKeyList) to High(KbKeyList) do InvalidateRect(KeyWndList[J], nil, True);
  Result := True;
end;

//
// Redraw the num lock key.
//
function RedrawNumLock(): Bool;
var
  J: Integer;
begin
  Result := True;

  for J := Low(KbKeyList) to High(KbKeyList) do
    if (KbKeyList[J].kType = NUMLOCK_TYPE) then
    begin
      if (GetKeyState(VK_NUMLOCK) and $0001 = 0) then SetKeyLong(J, 0) else SetKeyLong(J, 2);
      Exit;
    end;

  Result := False;
end;

//
// Redraw the scroll lock key.
//
function RedrawScrollLock(): Bool;
var
  J: Integer;
begin
  Result := True;

  for J := Low(KbKeyList) to High(KbKeyList) do
    if (KbKeyList[J].kType = SCROLLOCK_TYPE) then
    begin
      if (GetKeyState(VK_SCROLL) and $0001 = 0) then SetKeyLong(J, 0) else SetKeyLong(J, 2);
      Exit;
    end;

  Result := False;
end;

//
// Redraw the num caps key.
//
function RedrawCapsLock(): Bool;
var
  J: Integer;
begin
  Result := True;

  for J := Low(KbKeyList) to High(KbKeyList) do
    if (KbKeyList[J].kType = CAPSLOCK_TYPE) then
    begin
      if (GetKeyState(VK_CAPITAL) and $0001 = 0) then SetKeyLong(J, 0) else SetKeyLong(J, 2);
      Exit;
    end;

  Result := False;
end;

//
// 按键窗口回调
//
function KeyWndProc(hKeyWnd: HWnd; uMsg: UInt; wParam: WParam; lParam: LParam): LResult; stdcall;
var
  hKeyDc: HDC;
  PaintStruct: TPaintStruct;
  KeyRect: TRect;
  nIndex, nState: Integer;
begin
  case (uMsg) of
    WM_PAINT:
    begin
      nIndex := GetWindowLong(hKeyWnd, GWL_ID);
      nState := GetWindowLong(hKeyWnd, 0);
      GetClientRect(hKeyWnd, KeyRect);

      hKeyDc := BeginPaint(hKeyWnd, PaintStruct);

      case (nState) of
        0: // 普通状态
        begin
          case (KbKeyList[nIndex].Name) of
            BITMAP:
              DrawKeyBmp(hKeyDc, KbKeyList[nIndex].TextL, KeyRect);

            ICON:
              DrawKeyIcon(hKeyDc, KbKeyList[nIndex].TextL, KeyRect);

            else
              DrawKeyText(hKeyDc, KeyRect, nIndex, nState);
          end;
        end;

        1: // 路过状态
        begin
          case (KbkeyList[nIndex].Name) of
            BITMAP:
              DrawKeyBmp(hKeyDc, KbKeyList[nIndex].SkLow, KeyRect);

            ICON:
              DrawKeyIcon(hKeyDc, KbKeyList[nIndex].SkLow, KeyRect);

            else
              DrawKeyText(hKeyDc, KeyRect, nIndex, nState);
          end;

          DrawKeyRed(hKeyDc, KeyRect);
        end;

        2: // 按下状态
        begin
          case (KbkeyList[nIndex].Name) of
            BITMAP:
              DrawKeyBmp(hKeyDc, KbKeyList[nIndex].SkLow, KeyRect);

            ICON:
              DrawKeyIcon(hKeyDc, KbKeyList[nIndex].SkLow, KeyRect);

            KB_CAPLOCK,
            KB_NUMLOCK,
            KB_SCROLL:
            begin
              DrawKeyText(hKeyDc, KeyRect, nIndex, nState);
              DrawKeyLight(hKeyDc, KeyRect);
            end;

            else
              DrawKeyText(hKeyDc, KeyRect, nIndex, nState);
          end;

          DrawKeyRed(hKeyDc, KeyRect);
        end;
      end; // case (nState) of ..

      EndPaint(hKeyWnd, PaintStruct);
      Result := 0;
    end;

    WM_MOUSEACTIVATE:
    begin
      Result := MA_NOACTIVATEANDEAT; // 不激活窗体, 并删除鼠标消息..
    end;

    else
      Result := DefWindowProc(hKeyWnd, uMsg, wParam, lParam);
  end; // case (uMsg) of ..
end;

//
// 红色边框
//
function DrawKeyRed(hKeyDc: HDC; Rect: TRect): Bool;
const
  lpRed: TLogPen = (lopnStyle: PS_SOLID; lopnWidth: (x: 2; y: 2); lopnColor: $0000FF);
var
  Points: array[0..2] of TPoint;
  hOldPen, hNewPen: HPen;
begin
  Result := False;

  hNewPen := CreatePenIndirect(lpRed);
  if (hNewPen = 0) then Exit else hOldPen := SelectObject(hKeyDc, hNewPen);

  Points[0].x := Rect.Right - 1;
  Points[0].y := 2;
  Points[1].x := Rect.Right - 1;
  Points[1].y := Rect.Bottom - 1;
  Points[2].x := 0;
  Points[2].y := Rect.Bottom - 1;
  Result := Polyline(hKeyDc, Points, 3);

  Points[0].x := 1;
  Points[0].y := Rect.Bottom;
  Points[1].x := 0;
  Points[1].y := 0;
  Points[2].x := Rect.Right;
  Points[2].y := 1;
  Result := Polyline(hKeyDc, Points, 3) and Result;

  SelectObject(hKeyDc, hOldPen);
  DeleteObject(hNewPen);
end;

//
// 绘制图标
//
function DrawKeyIcon(hKeyDc: HDC; pIconName: PChar; Rect: TRect): Bool;
var
  hKeyIcon: HIcon;
  xLeft, yTop: Integer;
begin
  Result := False;

  hKeyIcon := LoadImage(HInstance, pIconName, IMAGE_ICON, 0, 0, LR_DEFAULTSIZE or LR_SHARED);
  if (hKeyIcon = 0) then
  begin
    SendErrorMessage(IDS_CANNOT_LOAD_ICON);
    Exit;
  end;

  // Find out where is the top left corner to place the icon
  xLeft := (Rect.Right - Rect.Left) div 2 - 16;
  yTop := (Rect.Bottom - Rect.Top) div 2 - 16;

  // Draw the icon (Draw in center)
  SetMapMode(hKeyDc, MM_TEXT);
  Result := DrawIconEx(hKeyDc, xLeft, yTop, hKeyIcon, 0, 0, 0, 0, DI_NORMAL);
end;

//
// 绘制位图
//
function DrawKeyBmp(hKeyDc: HDC; pBmpName: PChar; Rect: TRect): Bool;
var
  hKeyBmp: HBitMap;
  hMemDc: HDC;
  Width, Height: Integer;
begin
  Result := False;

  hKeyBmp := LoadImage(HInstance, pBmpName, IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE or LR_SHARED);
  if (hKeyBmp = 0) then
  begin
    SendErrorMessage(IDS_CANNOT_LOAD_ICON); // **
    Exit;
  end;

  Width := Rect.Right - Rect.Left - 2;
  Height := Rect.Bottom - Rect.Top - 2;

  SetMapMode(hKeyDc, MM_TEXT);
  hMemDc := CreateCompatibleDC(hKeyDc);
  SelectObject(hMemDc, hKeyBmp);

  // Leave 1 pixels for drawing border
  Result := StretchBlt(hKeyDc, 1, 1, Width, Height, hMemDc, 0, 0, Width, Height, SRCCOPY);
  DeleteDC(hMemDc);
end;

//
// print out str in the center of Rect (绘制文字)
//
function DrawKeyText(hKeyDc: HDC; Rect: TRect; nIndex, nState: Integer): Bool;
var
  KeyState: TKeyboardState;
  VirtualKey: UInt;
  cBuffer: array[0..30] of Char;
  OutText: PChar;
  OutSize: TSize;
  OutLength, OutPosX, OutPosY: Integer;
  OldBkMode: Integer;
  hNewFont, hOldFont: HFont;
begin
  Result := False;

  // 文本
  case (KbKeyList[nIndex].Print) of
    1: begin
      GetKeyboardState(KeyState);
      KeyState[VK_CONTROL]  := 0; // **
      KeyState[VK_LCONTROL] := 0;
      KeyState[VK_RCONTROL] := 0;
      VirtualKey := MapVirtualKey(KbKeyList[nIndex].ScanCode[0], 1);
      cBuffer[0] := #0;
      ToAscii(VirtualKey, KbKeyList[nIndex].ScanCode[0], KeyState, cBuffer, 0);
      cBuffer[1] := #0;      
      OutText := @cBuffer;
    end;

    2: begin
      if (GetKeyState(VK_SHIFT) and $1000 = 0) then
        OutText := KbKeyList[nIndex].TextL  // Print lower
      else
        OutText := KbKeyList[nIndex].TextC; // Print Cap
    end;

    3: begin
      if (GetKeyState(VK_NUMLOCK) and $0001 = 0) then
        OutText := KbKeyList[nIndex].SkLow
      else
        OutText := KbKeyList[nIndex].SkCap;
    end;

    else Exit;
  end;

  // 字体
  hNewFont := CreateFontIndirect(KbInfo.DefaultFont);
  if (hNewFont <> 0) then hOldFont := SelectObject(hKeyDc, hNewFont) else hOldFont := 0;

  // 背景
  OldBkMode := SetBkMode(hKeyDc, TRANSPARENT);

  // 颜色
  if (nState <> 0) then
    SetTextColor(hKeyDc, GetSysColor(COLOR_HIGHLIGHTTEXT)) // Hilite
  else
    if (KbKeyList[nIndex].kType = KMODIFIER_TYPE) or
       (KbKeyList[nIndex].kType = NUMLOCK_TYPE) or
       (KbKeyList[nIndex].kType = SCROLLOCK_TYPE) or
       (KbKeyList[nIndex].kType = CAPSLOCK_TYPE)
    then
      SetTextColor(hKeyDc, GetSysColor(COLOR_INACTIVECAPTION)) // Modifier
    else
      SetTextColor(hKeyDc, GetSysColor(COLOR_BTNTEXT)); // Normal

  // 位置
  OutLength := lStrLen(OutText);
  GetTextExtentPoint32(hKeyDc, OutText, OutLength, OutSize);
  OutPosX := ((Rect.Right - Rect.Left) - OutSize.cx) div 2;
  OutPosY := ((Rect.Bottom - Rect.Top) - OutSize.cy) div 2;

  // 绘制
  Result := TextOut(hKeyDc, OutPosX, OutPosY, OutText, OutLength);

  // 清除
  SetBkMode(hKeyDc, OldBkMode);
  SelectObject(hKeyDc, hOldFont);
  DeleteObject(hNewFont);
end;

//
// Draw the keys LED light ( Lock灯 )
//
function DrawKeyLight(hKeyDc: HDC; Rect: TRect): Bool;
const
  sIconName = 'LED_LIGHT';
var
  hKeyIcon: HIcon;
begin
  Result := False;

  hKeyIcon := LoadImage(HInstance, sIconName, IMAGE_ICON, Rect.Right, Rect.Bottom, LR_SHARED);
  if (hKeyIcon = 0) then
  begin
    SendErrorMessage(IDS_CANNOT_LOAD_ICON);
    Exit;
  end;

  SetMapMode(hKeyDc, MM_TEXT);
  Result := DrawIconEx(hKeyDc, 2, 2, hKeyIcon, Rect.Right, Rect.Bottom, 0, 0, DI_NORMAL);
end;

end.
