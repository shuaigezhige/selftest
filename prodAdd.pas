unit prodAdd;

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
  Grids,
  DBGrids,
  StdCtrls,
  DBCtrls,
  Mask,
  DB,
  ADODB,
  AppEvnts;

type
  TprodAddFrame = class(TFrame)
    prodDBGrid: TDBGrid;
    prodADOQuery: TADOQuery;
    prodDataSource: TDataSource;
    prodIdLabel: TLabel;
    prodNmLabel: TLabel;
    prodPriceLabel: TLabel;
    prodTypeLabel: TLabel;
    submitButton: TButton;
    abortSubButton: TButton;
    addButton: TButton;
    editButton: TButton;
    delButton: TButton;
    ApplicationEvents1: TApplicationEvents;
    prodNmEdit: TEdit;
    prodPriceEdit: TEdit;
    prodTypeCmbBox: TComboBox;
    prodIdEdit: TEdit;
    sqlModel: TLabel;
    mentionLabel: TLabel;
    procedure addButtonClick(Sender: TObject);
    procedure abortSubButtonClick(Sender: TObject);
    procedure delButtonClick(Sender: TObject);
    procedure submitButtonClick(Sender: TObject);
    procedure editButtonClick(Sender: TObject);
    procedure GoEditState();
    function IsDigit(S: string): Boolean;
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure refresh(keyValue: string);
    procedure prodDBGridCellClick(Column: TColumn);
    procedure prodDBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure prodPriceEditKeyPress(Sender: TObject; var Key: Char);
    procedure prodIdEditKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
uses login;
{$R *.dfm}

{判断一个字符串是否为数字}

function TprodAddFrame.IsDigit(S: string): Boolean;
//变量S为要判断的字符串,返回true则正确
var
  i, j: integer;
begin
  Result := True;
  if (trim(S) = '') then
    Result := False
  else
    begin
      j := 0;
      for i := 1 to length(s) do
        begin
          if not (s[i] in ['0'..'9', '.']) then
            //判断字符串每个字符即s[i],是否为"0"到'9"数字及".'
            Result := False;
          if s[i] = '.' then //统计字符串中"."的个数
            j := j + 1;
        end;

      if j > 1 then //字符串中"."的个数大于1
        Result := False;

      if (s[1] = '.') or (s[length(s)] = '.') then
        //字符串中"."的在最前面和最后面
        Result := False;
      //增加, 字符串中"."的位置之前有两个"0"判断
      s := copy(s, 1, pos('.', S) - 1); //取字符串中"."的位置之前字符
      j := 0;
      for i := 1 to length(s) do
        begin
          if s[i] = '0' then
            j := j + 1;
        end;
      if j > 1 then //字符串中"."的位置之前有两个"0"
        Result := False;
    end;
end;

{添加按钮}

procedure TprodAddFrame.addButtonClick(Sender: TObject);
begin
  {添加品种}
  GoEditState();
  // 编辑框清空
  prodIdEdit.Clear;
  prodNmEdit.Clear;
  prodPriceEdit.Clear;
  // 默认焦点在ID编辑框
  prodIdEdit.SetFocus;
  // 品种类别默认值 "主类"
  prodTypeCmbBox.ItemIndex := 0;
  mentionLabel.Caption := '李总，请你仔细确认无误后再添加！';
  mentionLabel.Visible := True;
  // 操作类别,判断用,隐藏
  sqlModel.Caption := 'insert';
end;

{修改按钮}

procedure TprodAddFrame.editButtonClick(Sender: TObject);
begin
  {修改品种}
  GoEditState();
  // 修改时ID不可编辑
  prodIdEdit.Enabled := False;
  // 默认焦点在名称编辑框
  prodNmEdit.SetFocus;
  mentionLabel.Caption := '李总，请你仔细确认无误后再修改！';
  mentionLabel.Visible := True;
  // 操作类别,判断用,隐藏
  sqlModel.Caption := 'update';
end;

{删除按钮}

procedure TprodAddFrame.delButtonClick(Sender: TObject);
var
  priorId: string;
  delADOQuery: TADOQuery;
begin
  if messagebox(handle, pchar('删除的品种不能被恢复，是否删除品种 "' +
    prodNmEdit.Text + '" ？'), '确认删除',
    mb_iconquestion + mb_yesno) = IDyes then
    begin
      // 先指向上一行
      prodADOQuery.Prior;
      // 保存上一行的 Key
      priorId := prodADOQuery.FieldByName('prod_id').AsString;
      // 生成临时ADO,用于删除
      delADOQuery := TADOQuery.Create(self);
      delADOQuery.Connection := DBConnection;
      with delADOQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add('delete from products where prod_id = :id');
          Parameters.ParamByName('id').Value := prodIdEdit.Text;
          ExecSQL;
        end;
      // 释放临时ADO对象
      delADOQuery.Close;
      delADOQuery.Free;
      // 刷新并定位到上一条记录
      refresh(priorId);
    end
  else
    // 如果取消了,刷新定位到原先的记录
    refresh(prodIdEdit.Text);
end;

{放弃提交按钮}

procedure TprodAddFrame.abortSubButtonClick(Sender: TObject);
begin
  // 重新刷新画面
  refresh(prodIdEdit.Text);
end;

{编辑状态画面设置}

procedure TprodAddFrame.GoEditState();
begin
  // 画面项目设置
  // 添加,编辑,删除按钮隐藏
  delButton.Visible := False;
  editButton.Visible := False;
  addButton.Visible := False;
  // 数据各编辑框可编辑
  prodIdEdit.Enabled := True;
  prodNmEdit.Enabled := True;
  prodPriceEdit.Enabled := True;
  prodTypeCmbBox.Enabled := True;
  // 提交,放弃按钮可见
  submitButton.Visible := True;
  abortSubButton.Visible := True;
  prodIdEdit.SetFocus;
end;

{提交按钮}

procedure TprodAddFrame.submitButtonClick(Sender: TObject);
var
  prodId: string;
  tempNm_Id: string;
  idCount: integer;
  nmCount: integer;
  tempProdNm: string;
  updADOQuery: TADOQuery;
begin
  // 保存当前记录的 Key
  prodId := prodIdEdit.Text;
  tempProdNm := trim(prodNmEdit.Text);
  if (trim(prodIdEdit.Text) = '') then
    begin
      messagebox(handle, '您输入的编号不能为空，请重新输入。',
        '检查输入',
        mb_ok);
      prodIdEdit.SetFocus;
      exit;
    end
  else
    if (trim(prodNmEdit.Text) = '') then
      begin
        messagebox(handle, '您输入的名称不能为空，请重新输入。',
          '检查输入', mb_ok);
        prodNmEdit.SetFocus;
        exit;
      end
    else
      if (trim(prodTypeCmbBox.Text) = '') then
        begin
          messagebox(handle,
            '您输入的类别不能为空，请重新输入。',
            '检查输入', mb_ok);
          prodTypeCmbBox.SetFocus;
          exit;
        end
      else
        if not IsDigit(prodPriceEdit.Text) then
          begin
            messagebox(handle,
              '您输入的价格不是数字，请重新输入。',
              '检查输入', mb_ok);
            prodPriceEdit.SetFocus;
            exit;
          end
        else
          if (StrToCurr(prodPriceEdit.Text) < 0) or
            (StrToCurr(prodPriceEdit.Text) >
            99.9) then
            begin
              messagebox(handle,
                '您输入的价格必须在 0 ~ 99.9 之间，请重新输入。',
                '检查输入', mb_ok);
              prodPriceEdit.SetFocus;
              exit;
            end;
  // 创建临时ADO对象,用于更新
  updADOQuery := TADOQuery.Create(self);
  updADOQuery.Connection := DBConnection;
  // 如果是插入数据
  if sqlModel.Caption = 'insert' then
    begin
      with updADOQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add(' select count(*) as Cnt from products where prod_id = :id ');
          Parameters.ParamByName('id').Value := prodIdEdit.Text;
          Open;
          idCount := FieldByName('Cnt').AsInteger;
          Close;
          SQL.Clear;
          SQL.Add(' select prod_id, count(*) as Cnt from products where prod_nm = :nm group by prod_id ');
          Parameters.ParamByName('nm').Value := tempProdNm;
          Open;
          nmCount := FieldByName('Cnt').AsInteger;
          tempNm_Id := FieldByName('prod_id').AsString;
        end;
      if idCount <> 0 then
        begin
          refresh(prodId);
          messagebox(handle, pchar('您添加的品种编号: "' + prodId +
            '" 已存在，请重新输入编号。'),
            '编号已存在',
            mb_ok);
          addButtonClick(self);
          exit;
        end
      else
        if nmCount <> 0 then
          begin
            refresh(tempNm_Id);
            messagebox(handle, pchar('您添加的名称: "' +
              tempProdNm + '" 已存在，请重新输入名称。'),
              '名称已存在',
              mb_ok);
            addButtonClick(self);
            exit;
          end
        else
          begin
            with updADOQuery do
              begin
                Close;
                SQL.Clear;
                SQL.Add('insert into products(prod_id, prod_nm, prod_price, prod_type) values (:id, :nm, :price, :type)');
                Parameters.ParamByName('id').Value := prodIdEdit.Text;
                Parameters.ParamByName('nm').Value := prodNmEdit.Text;
                Parameters.ParamByName('price').Value :=
                  prodPriceEdit.Text;
                Parameters.ParamByName('type').Value :=
                  prodTypeCmbBox.Text;
                ExecSQL;
              end;
            refresh(prodId);
          end;
    end
      // 如果是进行修改操作
  else
    if sqlModel.Caption = 'update' then
      begin
        with updADOQuery do
          begin
            Close;
            SQL.Clear;
            SQL.Add(' select prod_id, count(*) as Cnt from products where prod_nm = :nm and prod_id <> :prod_id group by prod_id ');
            Parameters.ParamByName('nm').Value := tempProdNm;
            Parameters.ParamByName('prod_id').Value := prodId;
            Open;
            nmCount := FieldByName('Cnt').AsInteger;
            tempNm_Id := FieldByName('prod_id').AsString;
          end;
        if nmCount <> 0 then
          begin
            refresh(tempNm_Id);
            messagebox(handle, pchar('您修改的名称: "' +
              tempProdNm + '" 已存在，请重新修改名称。'),
              '名称已存在',
              mb_ok);
            addButtonClick(self);
            exit;
          end
        else
          begin
            with updADOQuery do
              begin
                Close;
                SQL.Clear;
                SQL.Add('update products set prod_nm = :nm, prod_price = :price, prod_type = :type where prod_id = :id');
                Parameters.ParamByName('id').Value := prodIdEdit.Text;
                Parameters.ParamByName('nm').Value := prodNmEdit.Text;
                Parameters.ParamByName('price').Value :=
                  prodPriceEdit.Text;
                Parameters.ParamByName('type').Value :=
                  prodTypeCmbBox.Text;
                ExecSQL;
              end;
            refresh(prodId);
          end;
      end;
  // 释放临时ADO对象
  updADOQuery.Close;
  updADOQuery.Free;
end;

{DBgrid 滚动条, 鼠标滚轮事件}

procedure TprodAddFrame.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if (prodDBGrid.Focused) and (Msg.message = WM_MOUSEWHEEL) then
    begin
      if Msg.wParam > 0 then
        begin
          SendMessage(prodDBGrid.Handle, WM_KEYDOWN, VK_UP, 0);
          prodDBGrid.SelectedRows.CurrentRowSelected := true;
          prodDBGrid.SetFocus;
          prodIdEdit.Text := prodADOQuery.FieldByName('prod_id').AsString;
          prodNmEdit.Text :=
            prodADOQuery.fieldByName('prod_nm').AsString;
          prodPriceEdit.Text :=
            prodADOQuery.fieldByName('prod_price').AsString;
          prodTypeCmbBox.ItemIndex :=
            prodTypeCmbBox.Items.IndexOf(prodADOQuery.fieldByname('prod_type').AsString);
        end
      else
        begin
          SendMessage(prodDBGrid.Handle, WM_KEYDOWN, VK_DOWN, 0);
          prodDBGrid.SelectedRows.CurrentRowSelected := true;
          prodDBGrid.SetFocus;
          prodIdEdit.Text := prodADOQuery.FieldByName('prod_id').AsString;
          prodNmEdit.Text :=
            prodADOQuery.fieldByName('prod_nm').AsString;
          prodPriceEdit.Text :=
            prodADOQuery.fieldByName('prod_price').AsString;
          prodTypeCmbBox.ItemIndex :=
            prodTypeCmbBox.Items.IndexOf(prodADOQuery.fieldByname('prod_type').AsString);
        end;
      Handled := True;
    end;
end;

{画面刷新}

procedure TprodAddFrame.refresh(keyValue: string);
begin
  // 重新检索
  prodADOQuery.Close;
  prodADOQuery.SQL.Clear;
  prodADOQuery.SQL.Add(' select * from products order by prod_id ');
  prodADOQuery.Open;
  prodADOQuery.Locate('prod_id', keyValue, []);
  ShowScrollBar(prodDBGrid.Handle, SB_HORZ, True);
  ShowScrollBar(prodDBGrid.Handle, SB_HORZ, False);
  prodDBGrid.SelectedRows.CurrentRowSelected := true;
  prodDBGrid.SetFocus;
  // 各编辑框设置成DBGrid选中行对应的值
  prodIdEdit.Text := prodADOQuery.FieldByName('prod_id').AsString;
  prodNmEdit.Text :=
    prodADOQuery.fieldByName('prod_nm').AsString;
  prodPriceEdit.Text :=
    prodADOQuery.fieldByName('prod_price').AsString;
  prodTypeCmbBox.ItemIndex :=
    prodTypeCmbBox.Items.IndexOf(prodADOQuery.fieldByname('prod_type').AsString);
  // 添加,修改,删除按钮可见
  addButton.Visible := True;
  editButton.Visible := True;
  delButton.Visible := True;
  // 各编辑框不可编辑
  prodIdEdit.Enabled := False;
  prodNmEdit.Enabled := False;
  prodPriceEdit.Enabled := False;
  prodTypeCmbBox.Enabled := False;
  // 提交,放弃按钮不可见
  submitButton.Visible := False;
  abortSubButton.Visible := False;
  // 提示文字不可见
  mentionLabel.Visible := False;
end;

{DBgrid Cell 点击事件, 同步设定值到编辑框}

procedure TprodAddFrame.prodDBGridCellClick(Column: TColumn);
begin
  prodIdEdit.Text := prodADOQuery.FieldByName('prod_id').AsString;
  prodNmEdit.Text :=
    prodADOQuery.fieldByName('prod_nm').AsString;
  prodPriceEdit.Text :=
    prodADOQuery.fieldByName('prod_price').AsString;
  prodTypeCmbBox.ItemIndex :=
    prodTypeCmbBox.Items.IndexOf(prodADOQuery.fieldByname('prod_type').AsString);
end;

{DBGrid选中行变色}

procedure TprodAddFrame.prodDBGridDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  if gdSelected in State then
    with prodDBGrid do
      begin
        Canvas.Brush.Color := clMoneyGreen;
        Canvas.FillRect(Rect);
        Canvas.Font.Color := clBlack;
        Canvas.TextOut(Rect.Left, Rect.Top, Column.Field.AsString);
      end
  else
    with prodDBGrid do
      begin
        Canvas.Brush.Color := clWindow;
        Canvas.FillRect(Rect);
        Canvas.Font.Color := clBlack;
        Canvas.TextOut(Rect.Left, Rect.Top, Column.Field.AsString);
      end;
  prodDBGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

{价格编辑框入力范围}

procedure TprodAddFrame.prodPriceEditKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', '.', #13, #8]) then
    Key := #0;
end;

{编号编辑框入力范围}

procedure TprodAddFrame.prodIdEditKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #13, #8]) then
    Key := #0;
end;

end.
