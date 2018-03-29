object userEditFrame: TuserEditFrame
  Left = 0
  Top = 0
  Width = 650
  Height = 540
  Ctl3D = True
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = #23435#20307
  Font.Style = [fsBold]
  ParentCtl3D = False
  ParentFont = False
  TabOrder = 0
  object userIdLabel: TLabel
    Left = 400
    Top = 165
    Width = 60
    Height = 16
    Caption = #29992#25143#21517':'
  end
  object passLable: TLabel
    Left = 416
    Top = 213
    Width = 43
    Height = 16
    Caption = #23494#30721':'
  end
  object grpLabel: TLabel
    Left = 400
    Top = 261
    Width = 60
    Height = 16
    Caption = #29992#25143#32452':'
  end
  object tempLabel2: TLabel
    Left = 352
    Top = 112
    Width = 294
    Height = 16
    AutoSize = False
    Caption = '-------------'#32534#36753#21306'--------------'
  end
  object tempLabel1: TLabel
    Left = 352
    Top = 16
    Width = 294
    Height = 16
    AutoSize = False
    Caption = '-------------'#21151#33021#21306'--------------'
  end
  object sqlModel: TLabel
    Left = 240
    Top = 8
    Width = 9
    Height = 16
  end
  object mentionLabel: TLabel
    Left = 360
    Top = 56
    Width = 281
    Height = 25
    AutoSize = False
  end
  object addUserButton: TButton
    Left = 360
    Top = 56
    Width = 81
    Height = 25
    BiDiMode = bdLeftToRight
    Caption = #28155#21152
    ParentBiDiMode = False
    TabOrder = 1
    OnClick = addUserButtonClick
  end
  object userListDBGrid: TDBGrid
    Left = 8
    Top = 8
    Width = 345
    Height = 345
    DataSource = userEditDataSource
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = ANSI_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -16
    TitleFont.Name = #23435#20307
    TitleFont.Style = [fsBold]
    OnCellClick = userListDBGridCellClick
    OnDrawColumnCell = userListDBGridDrawColumnCell
    Columns = <
      item
        Expanded = False
        FieldName = 'user_id'
        Title.Caption = #29992#25143#21517
        Width = 110
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'user_pass'
        Title.Caption = #23494#30721
        Width = 110
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'user_grp'
        Title.Caption = #29992#25143#32452
        Width = 90
        Visible = True
      end>
  end
  object submitButton: TButton
    Left = 390
    Top = 320
    Width = 81
    Height = 25
    BiDiMode = bdLeftToRight
    Caption = #25552#20132
    ParentBiDiMode = False
    TabOrder = 7
    Visible = False
    OnClick = submitButtonClick
  end
  object abortSubmitButton: TButton
    Left = 520
    Top = 320
    Width = 81
    Height = 25
    BiDiMode = bdLeftToRight
    Caption = #25918#24323
    ParentBiDiMode = False
    TabOrder = 8
    Visible = False
    OnClick = abortSubmitButtonClick
  end
  object delUserButton: TButton
    Left = 560
    Top = 56
    Width = 81
    Height = 25
    BiDiMode = bdLeftToRight
    Caption = #21024#38500
    ParentBiDiMode = False
    TabOrder = 3
    OnClick = delUserButtonClick
  end
  object editUserButton: TButton
    Left = 460
    Top = 56
    Width = 81
    Height = 25
    BiDiMode = bdLeftToRight
    Caption = #20462#25913
    ParentBiDiMode = False
    TabOrder = 2
    OnClick = editUserButtonClick
  end
  object userIdEdit: TEdit
    Left = 464
    Top = 160
    Width = 121
    Height = 24
    AutoSize = False
    MaxLength = 12
    TabOrder = 4
  end
  object userPassEdit: TEdit
    Left = 464
    Top = 208
    Width = 121
    Height = 24
    AutoSize = False
    MaxLength = 12
    TabOrder = 5
  end
  object userGrpCmbBox: TComboBox
    Left = 464
    Top = 256
    Width = 121
    Height = 24
    ItemHeight = 16
    TabOrder = 6
    Items.Strings = (
      #31649#29702#21592
      #21592#24037)
  end
  object userEditADOQuery: TADOQuery
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      '')
    Left = 32
    Top = 200
  end
  object userEditDataSource: TDataSource
    AutoEdit = False
    DataSet = userEditADOQuery
    Left = 88
    Top = 200
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 224
    Top = 200
  end
end
