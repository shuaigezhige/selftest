unit TipWindow;

interface

uses Windows;

function CreateTip(hMainWnd: HWnd): Bool;
function ShowTip(nShow: Integer): Bool;
function MoveTip(xPos, yPos: Word): Bool;

implementation

uses Messages, CommCtrl, ResDef;

var
  hToolTip: HWnd;
  ToolInfo: TToolInfo;

//
// 建立ToolTip
//
function CreateTip(hMainWnd: HWnd): Bool;
const
  TTS_BALLOON = $40; { CommCtrl.h, line 2034 }
  MAX_TOOLTIP_SIZE = 256;
var
  szToolTipText: array[0..MAX_TOOLTIP_SIZE] of Char;
begin
  Result := False;

  if (LoadString(HInstance, IDS_TOOLTIP, szToolTipText, MAX_TOOLTIP_SIZE) = 0) then Exit;

  hToolTip := CreateWindowEx(WS_EX_TOPMOST, TOOLTIPS_CLASS, nil,
    WS_POPUP or TTS_NOPREFIX or TTS_BALLOON, 0, 0, 0, 0, 0, 0, HInstance, nil);
  if (hToolTip = 0) then Exit;

  ToolInfo.cbSize := SizeOf(ToolInfo);
  ToolInfo.uFlags := TTF_TRANSPARENT or TTF_CENTERTIP or TTF_TRACK;
  ToolInfo.hwnd   := hMainWnd;
  ToolInfo.uId    := 0;
  ToolInfo.hInst  := HInstance;
  ToolInfo.lpszText := @szToolTipText;
  if (SendMessage(hToolTip, TTM_ADDTOOL, 0, Integer(@ToolInfo)) = 0) then Exit;

  Result := True;
end;

//
// 显示隐藏ToolTip
//
function ShowTip(nShow: Integer): Bool;
begin
  Result := False;
  if (hToolTip = 0) then Exit else SendMessage(hToolTip, TTM_TRACKACTIVATE, nShow, Integer(@ToolInfo));
  Result := True;
end;

//
// 设置ToolTip位置
//
function MoveTip(xPos, yPos: Word): Bool;
begin
  Result := False;
  if (hToolTip = 0) then Exit else SendMessage(hToolTip, TTM_TRACKPOSITION, 0, MakeLParam(xPos, yPos));
  Result := True;
end;

initialization
  InitCommonControls();

end.
