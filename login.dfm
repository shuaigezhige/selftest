object userLogin: TuserLogin
  Left = 581
  Top = 312
  BorderStyle = bsDialog
  Caption = #26446#35760#20061#40092#38754'-'#30331#24405
  ClientHeight = 190
  ClientWidth = 267
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = #23435#20307
  Font.Style = [fsBold]
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object userLabel: TLabel
    Left = 32
    Top = 38
    Width = 60
    Height = 16
    AutoSize = False
    Caption = #29992#25143#21517':'
  end
  object passLabel: TLabel
    Left = 49
    Top = 70
    Width = 60
    Height = 16
    AutoSize = False
    Caption = #23494#30721':'
  end
  object userEdit: TEdit
    Left = 96
    Top = 32
    Width = 125
    Height = 24
    AutoSize = False
    MaxLength = 12
    TabOrder = 0
    OnKeyPress = userEditKeyPress
  end
  object passEdit: TEdit
    Left = 96
    Top = 64
    Width = 125
    Height = 24
    AutoSize = False
    MaxLength = 12
    PasswordChar = '#'
    TabOrder = 1
    OnKeyPress = passEditKeyPress
  end
  object loginButton: TButton
    Left = 42
    Top = 120
    Width = 75
    Height = 25
    Caption = #30331#24405
    TabOrder = 2
    OnClick = loginButtonClick
  end
  object exitButton: TButton
    Left = 144
    Top = 120
    Width = 75
    Height = 25
    Caption = #36864#20986
    TabOrder = 3
    OnClick = exitButtonClick
  end
end
