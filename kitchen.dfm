object displayForm: TdisplayForm
  Left = 1234
  Top = 15
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #21416#25151
  ClientHeight = 955
  ClientWidth = 1272
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 84
    Top = 82
    Width = 40
    Height = 26
    AutoSize = False
    Caption = #31186
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 81
    Width = 41
    Height = 20
    AutoSize = False
    Caption = #39057#29575
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 8
    Top = 40
    Width = 80
    Height = 20
    AutoSize = False
    Caption = #24050#21551#21160
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    ParentFont = False
  end
  object searchDBGrid: TDBGrid
    Left = 104
    Top = 0
    Width = 1168
    Height = 955
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -47
    Font.Name = #23435#20307
    Font.Style = []
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = ANSI_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -27
    TitleFont.Name = #23435#20307
    TitleFont.Style = [fsBold]
    Visible = False
    OnDrawColumnCell = searchDBGridDrawColumnCell
    Columns = <
      item
        Expanded = False
        FieldName = 'order_no'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -40
        Font.Name = #23435#20307
        Font.Style = []
        Title.Caption = #29260#21495
        Width = 65
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'prod_nm'
        Title.Caption = #21697#31181#21517#31216
        Width = 1005
        Visible = True
      end
      item
        Expanded = False
        FieldName = 's_date'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -21
        Font.Name = #23435#20307
        Font.Style = []
        Title.Caption = #26102#38388
        Width = 60
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'old_ordid'
        Visible = False
      end>
  end
  object setButton: TButton
    Left = 16
    Top = 111
    Width = 75
    Height = 20
    Caption = #35774#32622
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = setButtonClick
  end
  object timeSet: TEdit
    Left = 42
    Top = 79
    Width = 40
    Height = 20
    AutoSize = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    Text = '10'
  end
  object freshCheckBox: TCheckBox
    Left = 8
    Top = 16
    Width = 92
    Height = 17
    Caption = #21047#26032#24320#20851
    Checked = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    ParentFont = False
    State = cbChecked
    TabOrder = 3
    OnClick = freshCheckBoxClick
  end
  object searchADOQuery: TADOQuery
    CacheSize = 1000
    CursorType = ctStatic
    Parameters = <>
    Left = 64
    Top = 200
  end
  object searchDataSource: TDataSource
    DataSet = searchADOQuery
    Left = 64
    Top = 144
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 64
    Top = 256
  end
  object TimerCounter: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = TimerCounterTimer
    Left = 16
    Top = 144
  end
end
