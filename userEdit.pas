unit userEdit;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  DB,
  ADODB,
  DBCtrls,
  Mask,
  Grids,
  DBGrids,
  AppEvnts;

type
  TuserEditFrame = class(TFrame)
    addUserButton: TButton;
    userListDBGrid: TDBGrid;
    userIdLabel: TLabel;
    passLable: TLabel;
    grpLabel: TLabel;
    submitButton: TButton;
    abortSubmitButton: TButton;
    delUserButton: TButton;
    editUserButton: TButton;
    tempLabel2: TLabel;
    userEditADOQuery: TADOQuery;
    userEditDataSource: TDataSource;
    tempLabel1: TLabel;
    userIdEdit: TEdit;
    userPassEdit: TEdit;
    userGrpCmbBox: TComboBox;
    sqlModel: TLabel;
    ApplicationEvents1: TApplicationEvents;
    mentionLabel: TLabel;
    procedure editUserButtonClick(Sender: TObject);
    procedure submitButtonClick(Sender: TObject);
    procedure delUserButtonClick(Sender: TObject);
    procedure abortSubmitButtonClick(Sender: TObject);
    procedure addUserButtonClick(Sender: TObject);
    procedure GoEditState();
    procedure userListDBGridCellClick(Column: TColumn);
    procedure refresh(keyValue: string);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure userListDBGridDrawColumnCell(Sender: TObject;
      const Rect: TRect; DataCol: Integer; Column: TColumn;
      State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses login,
  main;

{$R *.dfm}
{编辑状态画面设置}

procedure TuserEditFrame.GoEditState();
begin
  // 添加,修改,删除按钮不可见
  delUserButton.Visible := False;
  editUserButton.Visible := False;
  addUserButton.Visible := False;
  // 用户名,密码,组别可修改
  userIdEdit.Enabled := True;
  userPassEdit.Enabled := True;
  userGrpCmbBox.Enabled := True;
  // 提交,放弃按钮可见
  submitButton.Visible := True;
  abortSubmitButton.Visible := True;
end;

{添加按钮}

procedure TuserEditFrame.addUserButtonClick(Sender: TObject);
begin
  // 添加用户
  GoEditState();
  userIdEdit.Clear;
  userPassEdit.Clear;
  // 默认焦点在用户名
  userIdEdit.SetFocus;
  // 默认值: "员工"
  userGrpCmbBox.ItemIndex := 1;
  mentionLabel.Caption := ' 李总，请你仔细确认无误后再添加！';
  mentionLabel.Visible := True;
  sqlModel.Caption := 'insert';
end;

{修改按钮}

procedure TuserEditFrame.editUserButtonClick(Sender: TObject);
begin
  GoEditState();
  // 用户名不可编辑
  userIdEdit.Enabled := False;
  // 默认焦点在密码
  userPassEdit.SetFocus;
  mentionLabel.Caption := ' 李总，请你仔细确认无误后再修改！';
  mentionLabel.Visible := True;
  sqlModel.Caption := 'update';
end;

{画面初始刷新}

procedure TuserEditFrame.refresh(keyValue: string);
begin
  // 重新检索数据
  userEditADOQuery.Close;
  userEditADOQuery.SQL.Clear;
  userEditADOQuery.SQL.Add(' select * from users ');
  userEditADOQuery.Open;
  userEditADOQuery.Locate('user_id', keyValue, []);
  ShowScrollBar(userListDBGrid.Handle, SB_HORZ, True);
  ShowScrollBar(userListDBGrid.Handle, SB_HORZ, False);
  userListDBGrid.SelectedRows.CurrentRowSelected := true;
  userListDBGrid.SetFocus;
  // 用户名,密码,组别编辑框设置成DBGrid选中行对应的值
  userIdEdit.Text := userEditADOQuery.FieldByName('user_id').AsString;
  userPassEdit.Text :=
    userEditADOQuery.fieldByName('user_pass').AsString;
  userGrpCmbBox.ItemIndex :=
    userGrpCmbBox.Items.IndexOf(userEditADOQuery.fieldByname('user_grp').AsString);
  // 用户名,密码,组别不可修改
  userIdEdit.Enabled := False;
  userPassEdit.Enabled := False;
  userGrpCmbBox.Enabled := False;
  // 添加,修改,删除按钮可见
  addUserButton.Visible := True;
  editUserButton.Visible := True;
  delUserButton.Visible := True;
  // 提交,放弃按钮不可见
  submitButton.Visible := False;
  abortSubmitButton.Visible := False;
  // 提示文字不可见
  mentionLabel.Visible := False;
end;

{删除按钮}

procedure TuserEditFrame.delUserButtonClick(Sender: TObject);
var
  userId: string;
  delADOQuery: TADOQuery;
begin
  if userIdEdit.Text = login.UserName then
    begin
      messagebox(handle, '自己不能删除自己！', '删除错误', mb_iconwarning
        +
        mb_ok);
      exit;
    end
  else
    if messagebox(handle, pchar('删除的用户不能被恢复，是否删除用户 "' +
      userIdEdit.Text + '" ？'), '确认删除',
      mb_iconquestion + mb_yesno) = IDyes then
      begin
        // 指向上一行
        userEditADOQuery.Prior;
        // 保存上一行的 Key
        userId := userEditADOQuery.FieldByName('user_id').AsString;
        userEditADOQuery.Refresh;
        // 生成临时ADO,用于删除
        delADOQuery := TADOQuery.Create(self);
        delADOQuery.Connection := DBConnection;
        with delADOQuery do
          begin
            Close;
            SQL.Clear;
            SQL.Add('delete from users where user_id = :id');
            Parameters.ParamByName('id').Value := userIdEdit.Text;
            ExecSQL;
          end;
        // 释放临时ADO对象
        delADOQuery.Close;
        delADOQuery.Free;
        // 刷新并定位到上一条记录
        refresh(userId);
      end
    else
      // 如果取消了,刷新定位到原先的记录
      refresh(userIdEdit.Text);
end;

{提交按钮}

procedure TuserEditFrame.submitButtonClick(Sender: TObject);
var
  userId: string;
  updADOQuery: TADOQuery;
  idCount: integer;
begin
  // 提交数据
  userId := userIdEdit.Text;
  if (trim(userIdEdit.Text) = '') then
    begin
      messagebox(handle, '您输入的用户名为空值，请重新输入。',
        '检查输入',
        mb_ok);
      userIdEdit.SetFocus;
      exit;
    end
  else
    if (trim(userPassEdit.Text) = '') then
      begin
        messagebox(handle, '您输入的密码为空值，请重新输入。',
          '检查输入',
          mb_ok);
        userPassEdit.SetFocus;
        exit;
      end
    else
      if (trim(userGrpCmbBox.Text) = '') then
        begin
          messagebox(handle, '您输入的用户组为空值，请重新输入。',
            '检查输入',
            mb_ok);
          userGrpCmbBox.SetFocus;
          exit;
        end;

  // 创建临时ADO对象,用于更新
  updADOQuery := TADOQuery.Create(self);
  updADOQuery.Connection := DBConnection;
  // 判断是否是添加用户
  if sqlModel.Caption = 'insert' then
    // 检查添加的用户是否已经存在
    begin
      with updADOQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add('select count(*) as userCnt from users where user_id= :id ');
          Parameters.ParamByName('id').Value := userIdEdit.Text;
          Open;
          idCount := FieldByName('userCnt').AsInteger;
        end;
      // 如果存在，报错，重新输入
      if idCount <> 0 then
        begin
          refresh(userId);
          messagebox(handle, '您添加的用户名已存在，请重新输入用户名。',
            '数据重复',
            mb_ok);
          addUserButtonClick(self);
          userIdEdit.SetFocus;
          exit;
        end
          // 如果不存在，添加到user表中
      else
        begin
          with updADOQuery do
            begin
              Close;
              SQL.Clear;
              SQL.Add('insert into users(user_id, user_pass, user_grp) values (:id, :pass, :grp)');
              Parameters.ParamByName('id').Value := userIdEdit.Text;
              Parameters.ParamByName('pass').Value := userPassEdit.Text;
              Parameters.ParamByName('grp').Value := userGrpCmbBox.Text;
              ExecSQL;
            end;
          refresh(userId);
        end;
      // 添加用户结束
    end
      // 如果是修改用户
  else
    if sqlModel.Caption = 'update' then
      begin
        with updADOQuery do
          begin
            Close;
            SQL.Clear;
            SQL.Add('update users set user_pass = :pass, user_grp = :grp where user_id = :id');
            Parameters.ParamByName('id').Value := userIdEdit.Text;
            Parameters.ParamByName('pass').Value := userPassEdit.Text;
            Parameters.ParamByName('grp').Value := userGrpCmbBox.Text;
            ExecSQL;
          end;
        refresh(userId);
      end;
  // 释放临时ADO对象
  updADOQuery.Close;
  updADOQuery.Free;
end;

{放弃提交}

procedure TuserEditFrame.abortSubmitButtonClick(Sender: TObject);
begin
  // 重新进行画面设置
  refresh(userIdEdit.Text);
end;

{DBgrid Cell 点击事件, 同步设定值到编辑框}

procedure TuserEditFrame.userListDBGridCellClick(Column: TColumn);
begin
  userIdEdit.Text := userEditADOQuery.FieldByName('user_id').AsString;
  userPassEdit.Text := userEditADOQuery.fieldByName('user_pass').AsString;
  userGrpCmbBox.ItemIndex :=
    userGrpCmbBox.Items.IndexOf(userEditADOQuery.fieldByname('user_grp').AsString);
end;

{DBgrid 滚动条, 鼠标滚轮事件}

procedure TuserEditFrame.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if (userListDBGrid.Focused) and (Msg.message = WM_MOUSEWHEEL) then
    begin
      if Msg.wParam > 0 then
        begin
          SendMessage(userListDBGrid.Handle, WM_KEYDOWN, VK_UP, 0);
          userListDBGrid.SelectedRows.CurrentRowSelected := true;
          userListDBGrid.SetFocus;
          userIdEdit.Text := userEditADOQuery.FieldByName('user_id').AsString;
          userPassEdit.Text :=
            userEditADOQuery.fieldByName('user_pass').AsString;
          userGrpCmbBox.ItemIndex :=
            userGrpCmbBox.Items.IndexOf(userEditADOQuery.fieldByname('user_grp').AsString);
        end
      else
        begin
          SendMessage(userListDBGrid.Handle, WM_KEYDOWN, VK_DOWN, 0);
          userListDBGrid.SelectedRows.CurrentRowSelected := true;
          userListDBGrid.SetFocus;
          userIdEdit.Text := userEditADOQuery.FieldByName('user_id').AsString;
          userPassEdit.Text :=
            userEditADOQuery.fieldByName('user_pass').AsString;
          userGrpCmbBox.ItemIndex :=
            userGrpCmbBox.Items.IndexOf(userEditADOQuery.fieldByname('user_grp').AsString);
        end;
      Handled := True;
    end;
end;

{DBGrid选中行变色}

procedure TuserEditFrame.userListDBGridDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  if gdSelected in State then
    with userListDBGrid do
      begin
        Canvas.Brush.Color := clMoneyGreen;
        Canvas.FillRect(Rect);
        Canvas.Font.Color := clBlack;
        Canvas.TextOut(Rect.Left, Rect.Top, Column.Field.AsString);
      end
  else
    with userListDBGrid do
      begin
        Canvas.Brush.Color := clWindow;
        Canvas.FillRect(Rect);
        Canvas.Font.Color := clBlack;
        Canvas.TextOut(Rect.Left, Rect.Top, Column.Field.AsString);
      end;
  userListDBGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

end.
