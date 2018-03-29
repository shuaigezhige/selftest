object hisQueryFrame: ThisQueryFrame
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
  object queryTypeLabel: TLabel
    Left = 32
    Top = 498
    Width = 89
    Height = 25
    AutoSize = False
    Caption = #26597#35810#31867#21035':'
  end
  object queryIdLabel: TLabel
    Left = 265
    Top = 498
    Width = 51
    Height = 25
    AutoSize = False
    Caption = #21495#30721':'
  end
  object startDateLabel: TLabel
    Left = 32
    Top = 459
    Width = 89
    Height = 25
    AutoSize = False
    Caption = #24320#22987#26085#26399':'
  end
  object endDateLabel: TLabel
    Left = 264
    Top = 459
    Width = 89
    Height = 25
    AutoSize = False
    Caption = #32467#26463#26085#26399':'
  end
  object searchDBGrid: TDBGrid
    Left = 6
    Top = 7
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
  object queryButton: TButton
    Left = 503
    Top = 432
    Width = 81
    Height = 25
    Caption = #26597#35810
    TabOrder = 7
    OnClick = queryButtonClick
  end
  object delButton: TButton
    Left = 503
    Top = 472
    Width = 81
    Height = 25
    Caption = #21024#38500
    TabOrder = 8
    OnClick = delButtonClick
  end
  object typeCmbBox: TComboBox
    Left = 112
    Top = 495
    Width = 115
    Height = 24
    ItemHeight = 16
    TabOrder = 5
    Items.Strings = (
      #29260#21495
      #26126#32454#21495)
  end
  object queryIdEdit: TEdit
    Left = 312
    Top = 495
    Width = 146
    Height = 24
    AutoSize = False
    MaxLength = 10
    TabOrder = 6
  end
  object startDateTime: TDateTimePicker
    Left = 112
    Top = 456
    Width = 115
    Height = 24
    Date = 40128.000000000000000000
    Time = 40128.000000000000000000
    TabOrder = 3
  end
  object endDateTime: TDateTimePicker
    Left = 344
    Top = 456
    Width = 115
    Height = 24
    Date = 40128.999988425930000000
    Time = 40128.999988425930000000
    TabOrder = 4
  end
  object recentRadBtn: TRadioButton
    Left = 112
    Top = 424
    Width = 130
    Height = 20
    Caption = #26597#35810#36817'3'#20010#26376
    Checked = True
    TabOrder = 1
    TabStop = True
    OnClick = recentRadBtnClick
  end
  object hisMonthsRadBtn: TRadioButton
    Left = 312
    Top = 424
    Width = 130
    Height = 20
    Caption = #26597#35810'3'#20010#26376#21069
    TabOrder = 2
    OnClick = hisMonthsRadBtnClick
  end
  object RepButton: TButton
    Left = 504
    Top = 512
    Width = 81
    Height = 25
    Caption = #25253#34920#29983#25104
    TabOrder = 9
    OnClick = RepButtonClick
  end
  object searchADOQuery: TADOQuery
    CacheSize = 1000
    CursorType = ctStatic
    Parameters = <>
    Left = 560
    Top = 264
  end
  object searchDataSource: TDataSource
    DataSet = searchADOQuery
    Left = 592
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
