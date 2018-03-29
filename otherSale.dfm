object additionFrame: TadditionFrame
  Left = 0
  Top = 0
  Width = 650
  Height = 540
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = #23435#20307
  Font.Style = [fsBold]
  ParentFont = False
  TabOrder = 0
  object Label1: TLabel
    Left = 64
    Top = 8
    Width = 34
    Height = 16
    Caption = #39278#26009
  end
  object Label3: TLabel
    Left = 192
    Top = 264
    Width = 43
    Height = 16
    Caption = #23567#35745':'
  end
  object SinglePriceLabel: TLabel
    Left = 240
    Top = 264
    Width = 9
    Height = 16
  end
  object Label2: TLabel
    Left = 266
    Top = 8
    Width = 34
    Height = 16
    Caption = #35746#21333
  end
  object drinksLB: TListBox
    Left = 6
    Top = 32
    Width = 150
    Height = 457
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #23435#20307
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    TabOrder = 0
    OnClick = drinksLBClick
  end
  object SingleOrderLB: TListBox
    Left = 192
    Top = 32
    Width = 181
    Height = 220
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #23435#20307
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    TabOrder = 1
    OnDblClick = SingleOrderLBDblClick
  end
  object OKBtn: TButton
    Left = 196
    Top = 304
    Width = 73
    Height = 25
    Caption = #30830#35748
    TabOrder = 2
    OnClick = OKBtnClick
  end
  object ClearBtn: TButton
    Left = 296
    Top = 304
    Width = 73
    Height = 25
    Caption = #28165#31354
    TabOrder = 3
    OnClick = ClearBtnClick
  end
end
