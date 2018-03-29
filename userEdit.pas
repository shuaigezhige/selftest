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
{�༭״̬��������}

procedure TuserEditFrame.GoEditState();
begin
  // ���,�޸�,ɾ����ť���ɼ�
  delUserButton.Visible := False;
  editUserButton.Visible := False;
  addUserButton.Visible := False;
  // �û���,����,�����޸�
  userIdEdit.Enabled := True;
  userPassEdit.Enabled := True;
  userGrpCmbBox.Enabled := True;
  // �ύ,������ť�ɼ�
  submitButton.Visible := True;
  abortSubmitButton.Visible := True;
end;

{��Ӱ�ť}

procedure TuserEditFrame.addUserButtonClick(Sender: TObject);
begin
  // ����û�
  GoEditState();
  userIdEdit.Clear;
  userPassEdit.Clear;
  // Ĭ�Ͻ������û���
  userIdEdit.SetFocus;
  // Ĭ��ֵ: "Ա��"
  userGrpCmbBox.ItemIndex := 1;
  mentionLabel.Caption := ' ���ܣ�������ϸȷ�����������ӣ�';
  mentionLabel.Visible := True;
  sqlModel.Caption := 'insert';
end;

{�޸İ�ť}

procedure TuserEditFrame.editUserButtonClick(Sender: TObject);
begin
  GoEditState();
  // �û������ɱ༭
  userIdEdit.Enabled := False;
  // Ĭ�Ͻ���������
  userPassEdit.SetFocus;
  mentionLabel.Caption := ' ���ܣ�������ϸȷ����������޸ģ�';
  mentionLabel.Visible := True;
  sqlModel.Caption := 'update';
end;

{�����ʼˢ��}

procedure TuserEditFrame.refresh(keyValue: string);
begin
  // ���¼�������
  userEditADOQuery.Close;
  userEditADOQuery.SQL.Clear;
  userEditADOQuery.SQL.Add(' select * from users ');
  userEditADOQuery.Open;
  userEditADOQuery.Locate('user_id', keyValue, []);
  ShowScrollBar(userListDBGrid.Handle, SB_HORZ, True);
  ShowScrollBar(userListDBGrid.Handle, SB_HORZ, False);
  userListDBGrid.SelectedRows.CurrentRowSelected := true;
  userListDBGrid.SetFocus;
  // �û���,����,���༭�����ó�DBGridѡ���ж�Ӧ��ֵ
  userIdEdit.Text := userEditADOQuery.FieldByName('user_id').AsString;
  userPassEdit.Text :=
    userEditADOQuery.fieldByName('user_pass').AsString;
  userGrpCmbBox.ItemIndex :=
    userGrpCmbBox.Items.IndexOf(userEditADOQuery.fieldByname('user_grp').AsString);
  // �û���,����,��𲻿��޸�
  userIdEdit.Enabled := False;
  userPassEdit.Enabled := False;
  userGrpCmbBox.Enabled := False;
  // ���,�޸�,ɾ����ť�ɼ�
  addUserButton.Visible := True;
  editUserButton.Visible := True;
  delUserButton.Visible := True;
  // �ύ,������ť���ɼ�
  submitButton.Visible := False;
  abortSubmitButton.Visible := False;
  // ��ʾ���ֲ��ɼ�
  mentionLabel.Visible := False;
end;

{ɾ����ť}

procedure TuserEditFrame.delUserButtonClick(Sender: TObject);
var
  userId: string;
  delADOQuery: TADOQuery;
begin
  if userIdEdit.Text = login.UserName then
    begin
      messagebox(handle, '�Լ�����ɾ���Լ���', 'ɾ������', mb_iconwarning
        +
        mb_ok);
      exit;
    end
  else
    if messagebox(handle, pchar('ɾ�����û����ܱ��ָ����Ƿ�ɾ���û� "' +
      userIdEdit.Text + '" ��'), 'ȷ��ɾ��',
      mb_iconquestion + mb_yesno) = IDyes then
      begin
        // ָ����һ��
        userEditADOQuery.Prior;
        // ������һ�е� Key
        userId := userEditADOQuery.FieldByName('user_id').AsString;
        userEditADOQuery.Refresh;
        // ������ʱADO,����ɾ��
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
        // �ͷ���ʱADO����
        delADOQuery.Close;
        delADOQuery.Free;
        // ˢ�²���λ����һ����¼
        refresh(userId);
      end
    else
      // ���ȡ����,ˢ�¶�λ��ԭ�ȵļ�¼
      refresh(userIdEdit.Text);
end;

{�ύ��ť}

procedure TuserEditFrame.submitButtonClick(Sender: TObject);
var
  userId: string;
  updADOQuery: TADOQuery;
  idCount: integer;
begin
  // �ύ����
  userId := userIdEdit.Text;
  if (trim(userIdEdit.Text) = '') then
    begin
      messagebox(handle, '��������û���Ϊ��ֵ�����������롣',
        '�������',
        mb_ok);
      userIdEdit.SetFocus;
      exit;
    end
  else
    if (trim(userPassEdit.Text) = '') then
      begin
        messagebox(handle, '�����������Ϊ��ֵ�����������롣',
          '�������',
          mb_ok);
        userPassEdit.SetFocus;
        exit;
      end
    else
      if (trim(userGrpCmbBox.Text) = '') then
        begin
          messagebox(handle, '��������û���Ϊ��ֵ�����������롣',
            '�������',
            mb_ok);
          userGrpCmbBox.SetFocus;
          exit;
        end;

  // ������ʱADO����,���ڸ���
  updADOQuery := TADOQuery.Create(self);
  updADOQuery.Connection := DBConnection;
  // �ж��Ƿ�������û�
  if sqlModel.Caption = 'insert' then
    // �����ӵ��û��Ƿ��Ѿ�����
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
      // ������ڣ�������������
      if idCount <> 0 then
        begin
          refresh(userId);
          messagebox(handle, '����ӵ��û����Ѵ��ڣ������������û�����',
            '�����ظ�',
            mb_ok);
          addUserButtonClick(self);
          userIdEdit.SetFocus;
          exit;
        end
          // ��������ڣ���ӵ�user����
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
      // ����û�����
    end
      // ������޸��û�
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
  // �ͷ���ʱADO����
  updADOQuery.Close;
  updADOQuery.Free;
end;

{�����ύ}

procedure TuserEditFrame.abortSubmitButtonClick(Sender: TObject);
begin
  // ���½��л�������
  refresh(userIdEdit.Text);
end;

{DBgrid Cell ����¼�, ͬ���趨ֵ���༭��}

procedure TuserEditFrame.userListDBGridCellClick(Column: TColumn);
begin
  userIdEdit.Text := userEditADOQuery.FieldByName('user_id').AsString;
  userPassEdit.Text := userEditADOQuery.fieldByName('user_pass').AsString;
  userGrpCmbBox.ItemIndex :=
    userGrpCmbBox.Items.IndexOf(userEditADOQuery.fieldByname('user_grp').AsString);
end;

{DBgrid ������, �������¼�}

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

{DBGridѡ���б�ɫ}

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
