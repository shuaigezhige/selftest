object dailyQueryFrame: TdailyQueryFrame
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
  object helpLabel1: TLabel
    Left = 32
    Top = 475
    Width = 420
    Height = 16
    AutoSize = False
    Caption = #24110#21161#35828#26126': '#26446#24635','#35201#24819#26597#35810#19968#20010#32452#21512','#31867#21035#35831#36873#25321'"'#29260#21495'".'
    Visible = False
  end
  object helpLabel2: TLabel
    Left = 64
    Top = 500
    Width = 405
    Height = 16
    AutoSize = False
    Caption = '      '#27492#22806','#35201#24819#26597#35810#19968#20010#21333#28857','#31867#21035#35831#36873#25321'"'#26126#32454#21495'".'
    Visible = False
  end
  object queryTypeLabel: TLabel
    Left = 32
    Top = 435
    Width = 89
    Height = 25
    AutoSize = False
    Caption = #26597#35810#31867#21035':'
  end
  object queryIdLabel: TLabel
    Left = 265
    Top = 435
    Width = 51
    Height = 25
    AutoSize = False
    Caption = #21495#30721':'
  end
  object searchDBGrid: TDBGrid
    Left = 6
    Top = 8
    Width = 640
    Height = 401
    DataSource = searchDataSource
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = ANSI_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -16
    TitleFont.Name = #23435#20307
    TitleFont.Style = [fsBold]
    OnDrawColumnCell = searchDBGridDrawColumnCell
    Columns = <
      item
        Expanded = False
        FieldName = 'order_no'
        Title.Caption = #29260#21495
        Width = 50
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'uniq_key'
        Title.Caption = #26126#32454#21495
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'prod_nm'
        Title.Caption = #21697#31181#21517#31216
        Width = 160
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'prod_price'
        Title.Caption = #20215#26684
        Width = 50
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'sale_cnt'
        Title.Caption = #25968#37327
        Width = 50
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'prod_type'
        Title.Caption = #21697#31181#31867#21035
        Width = 105
        Visible = True
      end
      item
        Expanded = False
        FieldName = 's_date'
        Title.Caption = #38144#21806#26085#26399
        Width = 185
        Visible = True
      end>
  end
  object delButton: TButton
    Left = 504
    Top = 472
    Width = 81
    Height = 25
    Caption = #21024#38500
    TabOrder = 4
    OnClick = delButtonClick
  end
  object queryButton: TButton
    Left = 504
    Top = 432
    Width = 81
    Height = 25
    Caption = #26597#35810
    TabOrder = 3
    OnClick = queryButtonClick
  end
  object queryIdEdit: TEdit
    Left = 312
    Top = 432
    Width = 146
    Height = 24
    AutoSize = False
    MaxLength = 10
    TabOrder = 2
  end
  object typeCmbBox: TComboBox
    Left = 112
    Top = 432
    Width = 115
    Height = 24
    ItemHeight = 16
    TabOrder = 1
    Items.Strings = (
      #29260#21495
      #26126#32454#21495)
  end
  object RepButton: TButton
    Left = 504
    Top = 512
    Width = 81
    Height = 25
    Caption = #25253#34920#29983#25104
    TabOrder = 5
    OnClick = RepButtonClick
  end
  object searchDataSource: TDataSource
    DataSet = searchADOQuery
    Left = 592
    Top = 264
  end
  object searchADOQuery: TADOQuery
    CacheSize = 1000
    CursorType = ctStatic
    Parameters = <>
    Left = 560
    Top = 264
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 592
    Top = 304
  end
  object groupADOQuery: TADOQuery
    CursorType = ctStatic
    Parameters = <>
    Left = 560
    Top = 304
  end
end
