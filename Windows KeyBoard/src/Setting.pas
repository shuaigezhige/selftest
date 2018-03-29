unit Setting;

interface

uses Windows;

//
// Data structure for Setting
//
type
  PKbInfo = ^TKbInfo;
  TKbInfo = record
    UseSound: Bool;        // Use click sound
    AlwaysOntop: Bool;     // windows always on top control
    ShowWarning: Bool;     // Show the initial warning dialog again
    DefaultFont: TLogFont; // default font
    KbRect: TRect;         // size and position of KB
  end;

var
  KbInfo: TKbInfo =
  (
    UseSound: True;
    AlwaysOntop: True;
    ShowWarning: True;
    DefaultFont:
    (
      lfHeight: -11;
      lfWidth: 0;
      lfEscapement: 0;
      lfOrientation: 0;
      lfWeight: 700;
      lfItalic: 0;
      lfUnderline: 0;
      lfStrikeOut: 0;
      lfCharSet: 0;
      lfOutPrecision: 3;
      lfClipPrecision: 2;
      lfQuality: 1;
      lfPitchAndFamily: 34;
      lfFaceName: 'MS Shell Dlg';
    );
    KbRect:
    (
      Left: 225;
      Top: 543;
      Right: 837;
      Bottom: 738;
    );
  );

implementation

end.