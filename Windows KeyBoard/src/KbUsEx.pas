unit KbUsEx;

interface

uses Windows;

//
// Key names
//
const
  KB_LSHIFT     =  0;
  KB_RSHIFT     =  1;
  KB_CAPLOCK    =  2;
  KB_SPACE      =  3;
  KB_LCTR       =  4;
  KB_RCTR       =  5;
  KB_LALT       =  6;
  KB_RALT       =  7;
  KB_NUMLOCK    =  8;
  KB_PSC        =  9;
  NO_NAME       =  10;
  ICON          =  11;
  KB_SCROLL     =  12;
  BITMAP        =  13;

//
// Key types
//
const
  KNORMAL_TYPE        =  1;
  KMODIFIER_TYPE      =  2;
  KDEAD_TYPE          =  3;
  NUMLOCK_TYPE        =  4;
  SCROLLOCK_TYPE      =  5;
  CAPSLOCK_TYPE       =  6;

//
// 单个按键
//
type
  TKbKeyRec = record
    TextL: PChar;      // text in key lower
    TextC: PChar;      // text in key capital
    SkLow: PChar;      // What has to be printed low letter
    SkCap: PChar;      // What has to be printed cap letter
    Name: Integer;     // BITMAP, LSHIFT, RSHIF...
    PosY: Short;       // See explanation above
    PosX: Short;       // same as above
    kSizeY: Short;     // key size in conventional units
    kSizeX: Short;     // same as above
    kType: Integer;    // 1 - normal, 2 - modifier, 3 - dead
    Print: Integer;    // 1 - print use ToAscii(), 2 - print the text provided by the header file
    ScanCode: array[0..3] of UInt; // key scan-code
  end;

//
// 美式键盘
//
var
  KbKeyList: array[0..103] of TKbKeyRec =
  (
    (TextL: 'esc';         TextC: 'esc';         SkLow: '{esc}';       SkCap: '{esc}';       Name: NO_NAME;    PosY: 1;  PosX: 1;   kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($01, $00, $00, $00)),
    (TextL: 'F1';          TextC: 'F1';          SkLow: '{f1}';        SkCap: '{f1}';        Name: NO_NAME;    PosY: 1;  PosX: 19;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($3B, $00, $00, $00)),
    (TextL: 'F2';          TextC: 'F2';          SkLow: '{f2}';        SkCap: '{f2}';        Name: NO_NAME;    PosY: 1;  PosX: 28;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($3C, $00, $00, $00)),
    (TextL: 'F3';          TextC: 'F3';          SkLow: '{f3}';        SkCap: '{f3}';        Name: NO_NAME;    PosY: 1;  PosX: 37;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($3D, $00, $00, $00)),
    (TextL: 'F4';          TextC: 'F4';          SkLow: '{f4}';        SkCap: '{f4}';        Name: NO_NAME;    PosY: 1;  PosX: 46;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($3E, $00, $00, $00)),
    (TextL: 'F5';          TextC: 'F5';          SkLow: '{f5}';        SkCap: '{f5}';        Name: NO_NAME;    PosY: 1;  PosX: 60;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($3F, $00, $00, $00)),
    (TextL: 'F6';          TextC: 'F6';          SkLow: '{f6}';        SkCap: '{f6}';        Name: NO_NAME;    PosY: 1;  PosX: 69;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($40, $00, $00, $00)),
    (TextL: 'F7';          TextC: 'F7';          SkLow: '{f7}';        SkCap: '{f7}';        Name: NO_NAME;    PosY: 1;  PosX: 78;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($41, $00, $00, $00)),
    (TextL: 'F8';          TextC: 'F8';          SkLow: '{f8}';        SkCap: '{f8}';        Name: NO_NAME;    PosY: 1;  PosX: 87;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($42, $00, $00, $00)),
    (TextL: 'F9';          TextC: 'F9';          SkLow: '{f9}';        SkCap: '{f9}';        Name: NO_NAME;    PosY: 1;  PosX: 101; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($43, $00, $00, $00)),
    (TextL: 'F10';         TextC: 'F10';         SkLow: '{f10}';       SkCap: '{f10}';       Name: NO_NAME;    PosY: 1;  PosX: 110; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($44, $00, $00, $00)),
    (TextL: 'F11';         TextC: 'F11';         SkLow: '{f11}';       SkCap: '{f11}';       Name: NO_NAME;    PosY: 1;  PosX: 119; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($57, $00, $00, $00)),
    (TextL: 'F12';         TextC: 'F12';         SkLow: '{f12}';       SkCap: '{f12}';       Name: NO_NAME;    PosY: 1;  PosX: 128; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($58, $00, $00, $00)),
    (TextL: 'psc';         TextC: 'psc';         SkLow: '{PRTSC}';     SkCap: '{PRTSC}';     Name: KB_PSC;     PosY: 1;  PosX: 138; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($E0, $2A, $E0, $37)),
    (TextL: 'slk';         TextC: 'slk';         SkLow: '{SCROLLOCK}'; SkCap: '{SCROLLOCK}'; Name: KB_SCROLL;  PosY: 1;  PosX: 147; kSizeY: 8;  kSizeX: 8;  kType: SCROLLOCK_TYPE; Print: 2; ScanCode: ($46, $00, $00, $00)),
    (TextL: 'brk';         TextC: 'pau';         SkLow: '{BREAK}';     SkCap: '{^s}';        Name: NO_NAME;    PosY: 1;  PosX: 156; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($E1, $1D, $45, $00)),
    (TextL: '`';           TextC: '~';           SkLow: '`';           SkCap: '{~}';         Name: NO_NAME;    PosY: 12; PosX: 1;   kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($29, $00, $00, $00)),
    (TextL: '1';           TextC: '!';           SkLow: '1';           SkCap: '!';           Name: NO_NAME;    PosY: 12; PosX: 10;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($02, $00, $00, $00)),
    (TextL: '2';           TextC: '@';           SkLow: '2';           SkCap: '@';           Name: NO_NAME;    PosY: 12; PosX: 19;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($03, $00, $00, $00)),
    (TextL: '3';           TextC: '#';           SkLow: '3';           SkCap: '#';           Name: NO_NAME;    PosY: 12; PosX: 28;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($04, $00, $00, $00)),
    (TextL: '4';           TextC: '$';           SkLow: '4';           SkCap: '$';           Name: NO_NAME;    PosY: 12; PosX: 37;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($05, $00, $00, $00)),
    (TextL: '5';           TextC: '%';           SkLow: '5';           SkCap: '{%}';         Name: NO_NAME;    PosY: 12; PosX: 46;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($06, $00, $00, $00)),
    (TextL: '6';           TextC: '^';           SkLow: '6';           SkCap: '{^}';         Name: NO_NAME;    PosY: 12; PosX: 55;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($07, $00, $00, $00)),
    (TextL: '7';           TextC: '&';           SkLow: '7';           SkCap: '&';           Name: NO_NAME;    PosY: 12; PosX: 64;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($08, $00, $00, $00)),
    (TextL: '8';           TextC: '*';           SkLow: '8';           SkCap: '*';           Name: NO_NAME;    PosY: 12; PosX: 73;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($09, $00, $00, $00)),
    (TextL: '9';           TextC: '(';           SkLow: '9';           SkCap: '(';           Name: NO_NAME;    PosY: 12; PosX: 82;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($0A, $00, $00, $00)),
    (TextL: '0';           TextC: ')';           SkLow: '0';           SkCap: ')';           Name: NO_NAME;    PosY: 12; PosX: 91;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($0B, $00, $00, $00)),
    (TextL: '-';           TextC: '_';           SkLow: '-';           SkCap: '_';           Name: NO_NAME;    PosY: 12; PosX: 100; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($0C, $00, $00, $00)),
    (TextL: '=';           TextC: '+';           SkLow: '=';           SkCap: '{+}';         Name: NO_NAME;    PosY: 12; PosX: 109; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($0D, $00, $00, $00)),
    (TextL: 'bksp';        TextC: 'bksp';        SkLow: '{BS}';        SkCap: '{BS}';        Name: NO_NAME;    PosY: 12; PosX: 118; kSizeY: 8;  kSizeX: 18; kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($0E, $00, $00, $00)),
    (TextL: 'ins';         TextC: 'ins';         SkLow: '{INSERT}';    SkCap: '{INSERT}';    Name: NO_NAME;    PosY: 12; PosX: 138; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($E0, $52, $00, $00)),
    (TextL: 'hm';          TextC: 'hm';          SkLow: '{HOME}';      SkCap: '{HOME}';      Name: NO_NAME;    PosY: 12; PosX: 147; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($E0, $47, $00, $00)),
    (TextL: 'pup';         TextC: 'pup';         SkLow: '{PGUP}';      SkCap: '{PGUP}';      Name: NO_NAME;    PosY: 12; PosX: 156; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($E0, $49, $00, $00)),
    (TextL: 'nlk';         TextC: 'nlk';         SkLow: '{NUMLOCK}';   SkCap: '{NUMLOCK}';   Name: KB_NUMLOCK; PosY: 12; PosX: 166; kSizeY: 8;  kSizeX: 8;  kType: NUMLOCK_TYPE;   Print: 2; ScanCode: ($45, $00, $00, $00)),
    (TextL: '/';           TextC: '/';           SkLow: '/';           SkCap: '/';           Name: NO_NAME;    PosY: 12; PosX: 175; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($E0, $35, $00, $00)),
    (TextL: '*';           TextC: '*';           SkLow: '*';           SkCap: '*';           Name: NO_NAME;    PosY: 12; PosX: 184; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($E0, $37, $00, $00)),
    (TextL: '-';           TextC: '-';           SkLow: '-';           SkCap: '-';           Name: NO_NAME;    PosY: 12; PosX: 193; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($4A, $00, $00, $00)),
    (TextL: 'tab';         TextC: 'tab';         SkLow: '{TAB}';       SkCap: '{TAB}';       Name: NO_NAME;    PosY: 21; PosX: 1;   kSizeY: 8;  kSizeX: 13; kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($0F, $00, $00, $00)),
    (TextL: 'q';           TextC: 'Q';           SkLow: 'q';           SkCap: '+q';          Name: NO_NAME;    PosY: 21; PosX: 15;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($10, $00, $00, $00)),
    (TextL: 'w';           TextC: 'W';           SkLow: 'w';           SkCap: '+w';          Name: NO_NAME;    PosY: 21; PosX: 24;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($11, $00, $00, $00)),
    (TextL: 'e';           TextC: 'E';           SkLow: 'e';           SkCap: '+e';          Name: NO_NAME;    PosY: 21; PosX: 33;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($12, $00, $00, $00)),
    (TextL: 'r';           TextC: 'R';           SkLow: 'r';           SkCap: '+r';          Name: NO_NAME;    PosY: 21; PosX: 42;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($13, $00, $00, $00)),
    (TextL: 't';           TextC: 'T';           SkLow: 't';           SkCap: '+t';          Name: NO_NAME;    PosY: 21; PosX: 51;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($14, $00, $00, $00)),
    (TextL: 'y';           TextC: 'Y';           SkLow: 'y';           SkCap: '+y';          Name: NO_NAME;    PosY: 21; PosX: 60;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($15, $00, $00, $00)),
    (TextL: 'u';           TextC: 'U';           SkLow: 'u';           SkCap: '+u';          Name: NO_NAME;    PosY: 21; PosX: 69;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($16, $00, $00, $00)),
    (TextL: 'i';           TextC: 'I';           SkLow: 'i';           SkCap: '+i';          Name: NO_NAME;    PosY: 21; PosX: 78;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($17, $00, $00, $00)),
    (TextL: 'o';           TextC: 'O';           SkLow: 'o';           SkCap: '+o';          Name: NO_NAME;    PosY: 21; PosX: 87;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($18, $00, $00, $00)),
    (TextL: 'p';           TextC: 'P';           SkLow: 'p';           SkCap: '+p';          Name: NO_NAME;    PosY: 21; PosX: 96;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($19, $00, $00, $00)),
    (TextL: '[';           TextC: '{';           SkLow: '[';           SkCap: '{{}';         Name: NO_NAME;    PosY: 21; PosX: 105; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($1A, $00, $00, $00)),
    (TextL: ']';           TextC: '}';           SkLow: ']';           SkCap: '{}}';         Name: NO_NAME;    PosY: 21; PosX: 114; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($1B, $00, $00, $00)),
    (TextL: '\';           TextC: '|';           SkLow: '\';           SkCap: '|';           Name: NO_NAME;    PosY: 21; PosX: 123; kSizeY: 8;  kSizeX: 13; kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($2B, $00, $00, $00)),
    (TextL: 'del';         TextC: 'del';         SkLow: '{DEL}';       SkCap: '{DEL}';       Name: NO_NAME;    PosY: 21; PosX: 138; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($E0, $53, $00, $00)),
    (TextL: 'end';         TextC: 'end';         SkLow: '{END}';       SkCap: '{END}';       Name: NO_NAME;    PosY: 21; PosX: 147; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($E0, $4F, $00, $00)),
    (TextL: 'pdn';         TextC: 'pdn';         SkLow: '{PGDN}';      SkCap: '{PGDN}';      Name: NO_NAME;    PosY: 21; PosX: 156; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($E0, $51, $00, $00)),
    (TextL: '7';           TextC: '7';           SkLow: 'hm';          SkCap: '7';           Name: NO_NAME;    PosY: 21; PosX: 166; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 3; ScanCode: ($47, $00, $00, $00)),
    (TextL: '8';           TextC: '8';           SkLow: '↑';          SkCap: '8';           Name: NO_NAME;    PosY: 21; PosX: 175; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 3; ScanCode: ($48, $00, $00, $00)),
    (TextL: '9';           TextC: '9';           SkLow: 'pup';         SkCap: '9';           Name: NO_NAME;    PosY: 21; PosX: 184; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 3; ScanCode: ($49, $00, $00, $00)),
    (TextL: '+';           TextC: '+';           SkLow: '{+}';         SkCap: '{+}';         Name: NO_NAME;    PosY: 21; PosX: 193; kSizeY: 17; kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($4E, $00, $00, $00)),
    (TextL: 'lock';        TextC: 'lock';        SkLow: '{caplock}';   SkCap: '{caplock}';   Name: KB_CAPLOCK; PosY: 30; PosX: 1;   kSizeY: 8;  kSizeX: 17; kType: CAPSLOCK_TYPE;  Print: 2; ScanCode: ($3A, $00, $00, $00)),
    (TextL: 'a';           TextC: 'A';           SkLow: 'a';           SkCap: '+a';          Name: NO_NAME;    PosY: 30; PosX: 19;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($1E, $00, $00, $00)),
    (TextL: 's';           TextC: 'S';           SkLow: 's';           SkCap: '+s';          Name: NO_NAME;    PosY: 30; PosX: 28;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($1F, $00, $00, $00)),
    (TextL: 'd';           TextC: 'D';           SkLow: 'd';           SkCap: '+d';          Name: NO_NAME;    PosY: 30; PosX: 37;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($20, $00, $00, $00)),
    (TextL: 'f';           TextC: 'F';           SkLow: 'f';           SkCap: '+f';          Name: NO_NAME;    PosY: 30; PosX: 46;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($21, $00, $00, $00)),
    (TextL: 'g';           TextC: 'G';           SkLow: 'g';           SkCap: '+g';          Name: NO_NAME;    PosY: 30; PosX: 55;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($22, $00, $00, $00)),
    (TextL: 'h';           TextC: 'H';           SkLow: 'h';           SkCap: '+h';          Name: NO_NAME;    PosY: 30; PosX: 64;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($23, $00, $00, $00)),
    (TextL: 'j';           TextC: 'J';           SkLow: 'j';           SkCap: '+j';          Name: NO_NAME;    PosY: 30; PosX: 73;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($24, $00, $00, $00)),
    (TextL: 'k';           TextC: 'K';           SkLow: 'k';           SkCap: '+k';          Name: NO_NAME;    PosY: 30; PosX: 82;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($25, $00, $00, $00)),
    (TextL: 'l';           TextC: 'L';           SkLow: 'l';           SkCap: '+l';          Name: NO_NAME;    PosY: 30; PosX: 91;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($26, $00, $00, $00)),
    (TextL: ';';           TextC: ':';           SkLow: ';';           SkCap: '+;';          Name: NO_NAME;    PosY: 30; PosX: 100; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($27, $00, $00, $00)),
    (TextL: #39;           TextC: #39#39;        SkLow: #39;           SkCap: #39#39;        Name: NO_NAME;    PosY: 30; PosX: 109; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($28, $00, $00, $00)),
    (TextL: 'ent';         TextC: 'ent';         SkLow: '{enter}';     SkCap: '{enter}';     Name: NO_NAME;    PosY: 30; PosX: 118; kSizeY: 8;  kSizeX: 18; kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($1C, $00, $00, $00)),
    (TextL: '4';           TextC: '4';           SkLow: '←';          SkCap: '4';           Name: NO_NAME;    PosY: 30; PosX: 166; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 3; ScanCode: ($4B, $00, $00, $00)),
    (TextL: '5';           TextC: '5';           SkLow: '';            SkCap: '5';           Name: NO_NAME;    PosY: 30; PosX: 175; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 3; ScanCode: ($4C, $00, $00, $00)),
    (TextL: '6';           TextC: '6';           SkLow: '→';          SkCap: '6';           Name: NO_NAME;    PosY: 30; PosX: 184; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 3; ScanCode: ($4D, $00, $00, $00)),
    (TextL: 'shft';        TextC: 'shft';        SkLow: '';            SkCap: '';            Name: KB_LSHIFT;  PosY: 39; PosX: 1;   kSizeY: 8;  kSizeX: 21; kType: KMODIFIER_TYPE; Print: 2; ScanCode: ($2A, $00, $00, $00)),
    (TextL: 'z';           TextC: 'Z';           SkLow: 'z';           SkCap: '+z';          Name: NO_NAME;    PosY: 39; PosX: 23;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($2C, $00, $00, $00)),
    (TextL: 'x';           TextC: 'X';           SkLow: 'x';           SkCap: '+x';          Name: NO_NAME;    PosY: 39; PosX: 32;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($2D, $00, $00, $00)),
    (TextL: 'c';           TextC: 'C';           SkLow: 'c';           SkCap: '+c';          Name: NO_NAME;    PosY: 39; PosX: 41;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($2E, $00, $00, $00)),
    (TextL: 'v';           TextC: 'V';           SkLow: 'v';           SkCap: '+v';          Name: NO_NAME;    PosY: 39; PosX: 50;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($2F, $00, $00, $00)),
    (TextL: 'b';           TextC: 'B';           SkLow: 'b';           SkCap: '+b';          Name: NO_NAME;    PosY: 39; PosX: 59;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($30, $00, $00, $00)),
    (TextL: 'n';           TextC: 'N';           SkLow: 'n';           SkCap: '+n';          Name: NO_NAME;    PosY: 39; PosX: 68;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($31, $00, $00, $00)),
    (TextL: 'm';           TextC: 'M';           SkLow: 'm';           SkCap: '+m';          Name: NO_NAME;    PosY: 39; PosX: 77;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($32, $00, $00, $00)),
    (TextL: ',';           TextC: '<';           SkLow: ',';           SkCap: '+<';          Name: NO_NAME;    PosY: 39; PosX: 86;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($33, $00, $00, $00)),
    (TextL: '.';           TextC: '>';           SkLow: '.';           SkCap: '+>';          Name: NO_NAME;    PosY: 39; PosX: 95;  kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($34, $00, $00, $00)),
    (TextL: '/';           TextC: '?';           SkLow: '/';           SkCap: '+/';          Name: NO_NAME;    PosY: 39; PosX: 104; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($35, $00, $00, $00)),
    (TextL: 'shft';        TextC: 'shft';        SkLow: '';            SkCap: '';            Name: KB_RSHIFT;  PosY: 39; PosX: 113; kSizeY: 8;  kSizeX: 23; kType: KMODIFIER_TYPE; Print: 2; ScanCode: ($36, $00, $00, $00)),
    (TextL: 'IDB_UPUPARW'; TextC: 'IDB_UPDNARW'; SkLow: 'IDB_UP';      SkCap: '{UP}';        Name: BITMAP;     PosY: 39; PosX: 147; kSizeY: 8;  kSizeX: 8;  kType: KMODIFIER_TYPE; Print: 1; ScanCode: ($E0, $48, $00, $00)),
    (TextL: '1';           TextC: '1';           SkLow: 'end';         SkCap: '1';           Name: NO_NAME;    PosY: 39; PosX: 166; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 3; ScanCode: ($4F, $00, $00, $00)),
    (TextL: '2';           TextC: '2';           SkLow: '↓';          SkCap: '2';           Name: NO_NAME;    PosY: 39; PosX: 175; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 3; ScanCode: ($50, $00, $00, $00)),
    (TextL: '3';           TextC: '3';           SkLow: 'pdn';         SkCap: '3';           Name: NO_NAME;    PosY: 39; PosX: 184; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 3; ScanCode: ($51, $00, $00, $00)),
    (TextL: 'ent';         TextC: 'ent';         SkLow: 'ent';         SkCap: 'ent';         Name: NO_NAME;    PosY: 39; PosX: 193; kSizeY: 17; kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 2; ScanCode: ($E0, $1C, $00, $00)),
    (TextL: 'ctrl';        TextC: 'ctrl';        SkLow: '';            SkCap: '';            Name: KB_LCTR;    PosY: 48; PosX: 1;   kSizeY: 8;  kSizeX: 13; kType: KMODIFIER_TYPE; Print: 2; ScanCode: ($1D, $00, $00, $00)),
    (TextL: 'winlogoUp';   TextC: 'winlogoDn';   SkLow: 'I_winlogo';   SkCap: 'lwin';        Name: ICON;       PosY: 48; PosX: 15;  kSizeY: 8;  kSizeX: 8;  kType: KMODIFIER_TYPE),
    (TextL: 'alt';         TextC: 'alt';         SkLow: '';            SkCap: '';            Name: KB_LALT;    PosY: 48; PosX: 24;  kSizeY: 8;  kSizeX: 13; kType: KMODIFIER_TYPE; Print: 2; ScanCode: ($38, $00, $00, $00)),
    (TextL: '';            TextC: '';            SkLow: ' ';           SkCap: ' ';           Name: KB_SPACE;   PosY: 48; PosX: 38;  kSizeY: 8;  kSizeX: 52; kType: KNORMAL_TYPE;   Print: 1; ScanCode: ($39, $00, $00, $00)),
    (TextL: 'alt';         TextC: 'alt';         SkLow: '';            SkCap: '';            Name: KB_RALT;    PosY: 48; PosX: 91;  kSizeY: 8;  kSizeX: 13; kType: KMODIFIER_TYPE; Print: 2; ScanCode: ($E0, $38, $00, $00)),
    (TextL: 'winlogoUp';   TextC: 'winlogoDn';   SkLow: 'I_winlogo';   SkCap: 'rwin';        Name: ICON;       PosY: 48; PosX: 105; kSizeY: 8;  kSizeX: 8;  kType: KMODIFIER_TYPE),
    (TextL: 'MenuKeyUp';   TextC: 'MenuKeyDn';   SkLow: 'I_MenuKey';   SkCap: 'App';         Name: ICON;       PosY: 48; PosX: 114; kSizeY: 8;  kSizeX: 8;  kType: KMODIFIER_TYPE),
    (TextL: 'ctrl';        TextC: 'ctrl';        SkLow: '';            SkCap: '';            Name: KB_RCTR;    PosY: 48; PosX: 123; kSizeY: 8;  kSizeX: 13; kType: KMODIFIER_TYPE; Print: 2; ScanCode: ($E0, $10, $00, $00)),
    (TextL: 'IDB_LFUPARW'; TextC: 'IDB_LFDNARW'; SkLow: 'IDB_LEFT';    SkCap: '{LEFT}';      Name: BITMAP;     PosY: 48; PosX: 138; kSizeY: 8;  kSizeX: 8;  kType: KMODIFIER_TYPE; Print: 1; ScanCode: ($E0, $4B, $00, $00)),
    (TextL: 'IDB_DNUPARW'; TextC: 'IDB_DNDNARW'; SkLow: 'IDB_DOWN';    SkCap: '{DOWN}';      Name: BITMAP;     PosY: 48; PosX: 147; kSizeY: 8;  kSizeX: 8;  kType: KMODIFIER_TYPE; Print: 1; ScanCode: ($E0, $50, $00, $00)),
    (TextL: 'IDB_RHUPARW'; TextC: 'IDB_RHDNARW'; SkLow: 'IDB_RIGHT';   SkCap: '{RIGHT}';     Name: BITMAP;     PosY: 48; PosX: 156; kSizeY: 8;  kSizeX: 8;  kType: KMODIFIER_TYPE; Print: 1; ScanCode: ($E0, $4D, $00, $00)),
    (TextL: '0';           TextC: '0';           SkLow: 'ins';         SkCap: '0';           Name: NO_NAME;    PosY: 48; PosX: 166; kSizeY: 8;  kSizeX: 17; kType: KNORMAL_TYPE;   Print: 3; ScanCode: ($52, $00, $00, $00)),
    (TextL: '.';           TextC: '.';           SkLow: 'del';         SkCap: '.';           Name: NO_NAME;    PosY: 48; PosX: 184; kSizeY: 8;  kSizeX: 8;  kType: KNORMAL_TYPE;   Print: 3; ScanCode: ($53, $00, $00, $00))
  );

implementation

end.
