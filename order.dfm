object OrderFrame: TOrderFrame
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
  object Label2: TLabel
    Left = 219
    Top = 8
    Width = 68
    Height = 16
    Caption = #21487#21152#21103#26009
  end
  object Label3: TLabel
    Left = 338
    Top = 136
    Width = 43
    Height = 16
    Caption = #29366#24577':'
  end
  object Label4: TLabel
    Left = 338
    Top = 328
    Width = 34
    Height = 16
    Caption = #35746#21333
  end
  object Label1: TLabel
    Left = 54
    Top = 8
    Width = 68
    Height = 16
    Caption = #20027#31867#38754#26465
  end
  object Label5: TLabel
    Left = 536
    Top = 136
    Width = 43
    Height = 16
    Caption = #23567#35745':'
  end
  object SinglePriceLabel: TLabel
    Left = 584
    Top = 136
    Width = 9
    Height = 16
  end
  object Label6: TLabel
    Left = 536
    Top = 328
    Width = 43
    Height = 16
    Caption = #21512#35745':'
  end
  object TotalAmountLbl: TLabel
    Left = 584
    Top = 328
    Width = 9
    Height = 16
  end
  object Label7: TLabel
    Left = 388
    Top = 8
    Width = 51
    Height = 16
    Caption = #38754#20221#37327
  end
  object Label8: TLabel
    Left = 355
    Top = 102
    Width = 53
    Height = 16
    Caption = #21495'(+):'
  end
  object Label9: TLabel
    Left = 545
    Top = 8
    Width = 34
    Height = 16
    Caption = #36771#26898
  end
  object Label10: TLabel
    Left = 388
    Top = 136
    Width = 27
    Height = 16
    Caption = '   '
  end
  object HelpLabel1: TLabel
    Left = 8
    Top = 498
    Width = 302
    Height = 14
    Caption = #27880': '#23545#20110#24050#32463#25104#21151#25171#21360#36807#30340#35746#21333','#22914#22806#21152#21103#26009','
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -14
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    ParentFont = False
  end
  object HelpLabel2: TLabel
    Left = 38
    Top = 518
    Width = 274
    Height = 14
    Caption = #35831#36755#20837#24050#21457#30340'"'#29260#21495'",'#21542#21017#40664#35748#20026'"-1'#21495'".'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -14
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    ParentFont = False
  end
  object PrintBtn: TButton
    Left = 451
    Top = 500
    Width = 80
    Height = 30
    Caption = #30830#35748
    TabOrder = 10
    OnClick = PrintBtnClick
  end
  object MainFoodLB: TListBox
    Left = 6
    Top = 32
    Width = 165
    Height = 457
    ItemHeight = 16
    TabOrder = 0
    OnClick = MainFoodLBClick
  end
  object OptionFoodLB: TListBox
    Left = 183
    Top = 32
    Width = 140
    Height = 457
    ItemHeight = 16
    TabOrder = 1
    OnClick = OptionFoodLBClick
  end
  object SingleOrderLB: TListBox
    Left = 336
    Top = 160
    Width = 308
    Height = 113
    ItemHeight = 16
    TabOrder = 5
    OnDblClick = SingleOrderLBDblClick
  end
  object OrderLB: TListBox
    Left = 336
    Top = 352
    Width = 308
    Height = 137
    ItemHeight = 16
    TabOrder = 9
    OnClick = OrderLBClick
    OnDblClick = OrderLBDblClick
  end
  object AddBtn: TButton
    Left = 354
    Top = 288
    Width = 73
    Height = 25
    Caption = #28155#21152
    TabOrder = 6
    OnClick = AddBtnClick
  end
  object OrderNumberEdit: TEdit
    Left = 410
    Top = 98
    Width = 60
    Height = 24
    MaxLength = 3
    TabOrder = 4
    OnKeyPress = OrderNumberEditKeyPress
  end
  object ClearSingleBtn: TButton
    Left = 554
    Top = 288
    Width = 73
    Height = 25
    Caption = #28165#31354
    TabOrder = 8
    OnClick = ClearSingleBtnClick
  end
  object noodWeightLB: TListBox
    Left = 358
    Top = 32
    Width = 112
    Height = 49
    ItemHeight = 16
    TabOrder = 2
    OnClick = noodWeightLBClick
  end
  object pepperLB: TListBox
    Left = 505
    Top = 32
    Width = 115
    Height = 90
    ItemHeight = 16
    TabOrder = 3
    OnClick = pepperLBClick
  end
  object editButton: TButton
    Left = 454
    Top = 288
    Width = 73
    Height = 25
    Caption = #20462#25913
    Enabled = False
    TabOrder = 7
    OnClick = editButtonClick
  end
  object printeCheckBox: TCheckBox
    Left = 336
    Top = 508
    Width = 97
    Height = 17
    Caption = #25171#21360
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 11
    OnClick = printeCheckBoxClick
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 616
    Top = 496
  end
end
