object prodAddFrame: TprodAddFrame
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
  object prodIdLabel: TLabel
    Left = 50
    Top = 416
    Width = 65
    Height = 21
    AutoSize = False
    Caption = #32534' '#21495':'
  end
  object prodNmLabel: TLabel
    Left = 225
    Top = 416
    Width = 57
    Height = 24
    AutoSize = False
    Caption = #21517' '#31216':'
  end
  object prodPriceLabel: TLabel
    Left = 398
    Top = 416
    Width = 97
    Height = 24
    AutoSize = False
    Caption = #20215#26684'/'#20803
  end
  object prodTypeLabel: TLabel
    Left = 528
    Top = 416
    Width = 65
    Height = 24
    AutoSize = False
    Caption = #31867' '#21035':'
  end
  object sqlModel: TLabel
    Left = 480
    Top = 488
    Width = 9
    Height = 16
  end
  object mentionLabel: TLabel
    Left = 192
    Top = 376
    Width = 337
    Height = 25
    AutoSize = False
  end
  object prodDBGrid: TDBGrid
    Left = 6
    Top = 8
    Width = 640
    Height = 350
    DataSource = prodDataSource
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = ANSI_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -16
    TitleFont.Name = #23435#20307
    TitleFont.Style = [fsBold]
    OnCellClick = prodDBGridCellClick
    OnDrawColumnCell = prodDBGridDrawColumnCell
    Columns = <
      item
        Expanded = False
        FieldName = 'prod_id'
        Title.Caption = #21697#31181#32534#21495
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'prod_nm'
        Title.Caption = #21697#31181#21517#31216
        Width = 290
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'prod_price'
        Title.Caption = #20215#26684'/'#20803
        Width = 110
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'prod_type'
        Title.Caption = #21697#31181#31867#21035
        Width = 100
        Visible = True
      end>
  end
  object submitButton: TButton
    Left = 200
    Top = 488
    Width = 81
    Height = 25
    Caption = #25552#20132
    TabOrder = 8
    Visible = False
    OnClick = submitButtonClick
  end
  object abortSubButton: TButton
    Left = 360
    Top = 488
    Width = 81
    Height = 25
    Caption = #25918#24323
    TabOrder = 9
    Visible = False
    OnClick = abortSubButtonClick
  end
  object addButton: TButton
    Left = 120
    Top = 376
    Width = 81
    Height = 25
    Caption = #28155#21152
    TabOrder = 1
    OnClick = addButtonClick
  end
  object editButton: TButton
    Left = 280
    Top = 376
    Width = 81
    Height = 25
    Caption = #20462#25913
    TabOrder = 2
    OnClick = editButtonClick
  end
  object delButton: TButton
    Left = 448
    Top = 376
    Width = 81
    Height = 25
    Caption = #21024#38500
    TabOrder = 3
    OnClick = delButtonClick
  end
  object prodIdEdit: TEdit
    Left = 32
    Top = 440
    Width = 89
    Height = 24
    AutoSize = False
    MaxLength = 9
    TabOrder = 4
    OnKeyPress = prodIdEditKeyPress
  end
  object prodNmEdit: TEdit
    Left = 144
    Top = 440
    Width = 217
    Height = 24
    AutoSize = False
    MaxLength = 30
    TabOrder = 5
  end
  object prodPriceEdit: TEdit
    Left = 384
    Top = 440
    Width = 89
    Height = 24
    AutoSize = False
    MaxLength = 8
    TabOrder = 6
    OnKeyPress = prodPriceEditKeyPress
  end
  object prodTypeCmbBox: TComboBox
    Left = 496
    Top = 440
    Width = 113
    Height = 24
    Style = csDropDownList
    ItemHeight = 16
    TabOrder = 7
    Items.Strings = (
      #20027#31867#38754#26465
      #21487#21152#21103#26009
      #39278#26009#28895#37202
      #38754#22791#27880
      #36771#22791#27880)
  end
  object prodADOQuery: TADOQuery
    AutoCalcFields = False
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from products')
    Left = 72
    Top = 224
  end
  object prodDataSource: TDataSource
    AutoEdit = False
    DataSet = prodADOQuery
    Left = 128
    Top = 224
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 48
    Top = 376
  end
end
