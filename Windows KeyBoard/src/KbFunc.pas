unit KbFunc;

interface

uses Windows;

//
// Sound Types
//
const
  SND_UP   =  1;
  SND_DOWN =  2;

function WhatPlatform(): DWord;
function SendErrorMessage(IDS_String: UInt): Bool;
function RelocateDialog(hDialog: HWnd): Bool;
function ChooseNewFont(): Bool;
function MakeClick(What: Integer): Bool;

function HtmlHelp(hWndCaller: HWnd; pszFile: PChar; uCommand: UInt; dwData: DWord): HWnd; stdcall; external 'hhctrl.ocx' name 'HtmlHelpA';
function RegisterLink(): Bool; stdcall; external 'shell32.dll' Index 258;

implementation

uses CommDlg, MMSystem, Setting, ResDef, KbSend, KbUsEx, TipWindow, KeyWindow, MainWindow, RegUtil, WarningDlg;

//
// OS Platform
//
function WhatPlatform(): DWord;
var
  OSVerInfo: TOSVersionInfo;
begin
  OSVerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(OSVerInfo);

  Result := OSVerInfo.dwPlatformId;
end;

//
// error msg
//
function SendErrorMessage(IDS_String: UInt): Bool;
var
  ErrStr, Title: array[0..MAX_PATH] of Char;
begin
  Result := False;

	if (LoadString(HInstance, IDS_String, ErrStr, MAX_PATH) = 0) then Exit;
	if (LoadString(HInstance, IDS_TITLE, Title, MAX_PATH) = 0) then Exit;

	MessageBox(g_hKbMainWnd, ErrStr, Title, MB_ICONHAND or MB_OK);

  Result := True;
end;

//
// Moves the dialog outside of the OSK screen area, (调整对话框位置)
// Either on top if space permits or on the bottom edge of OSK
//
function RelocateDialog(hDialog: HWnd): Bool;
var
  KbMainRect, DialogRect, DesktopRect: TRect;
  Left, Top, Width, Height: Integer;
begin
  Result := False;

  GetWindowRect(g_hKbMainWnd, KbMainRect);
  GetWindowRect(hDialog, DialogRect);
  GetWindowRect(GetDesktopWindow(), DesktopRect);

  Width := DialogRect.Right - DialogRect.Left;
  Height := DialogRect.Bottom - DialogRect.Top;

  if (KbMainRect.Top - Height > DesktopRect.Top) then
  begin
    // There is enough space over OSK window, place the dialog on the top of the osk window
    Top := KbMainRect.Top - Height;
    Left := KbMainRect.Left + (KbMainRect.Right - KbMainRect.Left) div 2 - Width div 2;
  end else
    if (KbMainRect.Bottom + Height < DesktopRect.Bottom) then
    begin
      // There is enough space under OSK window, place the dialog on the bottom of the osk window
      Top := KbMainRect.Bottom;
      Left := KbMainRect.Left + (KbMainRect.Right - KbMainRect.Left) div 2 - Width div 2;
    end else
    begin
      // It is not possible to see the entire dialog, don't move it.
      Exit;
    end;

  Result := MoveWindow(hDialog, Left, Top, Width, Height, True);
end;

//
// 选择字体
//
function ChooseNewFont(): Bool;
var
  Chf: TChooseFont;
  Fnt: TLogFont;
begin
  Result := False;

  Fnt := KbInfo.DefaultFont;
  Chf.hDC := 0;
  Chf.lStructSize := SizeOf(TChooseFont);
  Chf.hwndOwner := 0;
  Chf.lpLogFont := @Fnt;
  Chf.Flags := CF_SCREENFONTS or CF_FORCEFONTEXIST or CF_INITTOLOGFONTSTRUCT;
  Chf.rgbColors := $000000;
  Chf.lCustData := 0;
  Chf.hInstance := HInstance;
  Chf.lpszStyle := nil;
  Chf.nFontType := SCREEN_FONTTYPE;
  Chf.nSizeMin := 0;
  Chf.nSizeMax := 14;
  Chf.lpfnHook := nil;
  Chf.lpTemplateName := nil;
  if (ChooseFont(Chf) = False) then Exit;

  KbInfo.DefaultFont := Fnt;
  Result := True;
end;

//
// 点击声响
//
function MakeClick(What: Integer): Bool;
begin
  case (What) of
    SND_UP:
      Result := PlaySound(MakeIntResource(WAV_CLICKUP), HInstance, SND_SYNC or SND_RESOURCE);

    SND_DOWN:
      Result := PlaySound(MakeIntResource(WAV_CLICKDN), HInstance, SND_SYNC or SND_RESOURCE);

    else
      Result := False;
  end;
end;

end.
