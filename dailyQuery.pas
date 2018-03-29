unit dailyQuery;

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
  Grids,
  DBGrids,
  AppEvnts,
  Clipbrd,
  ComObj;

type
  TdailyQueryFrame = class(TFrame)
    searchDataSource: TDataSource;
    searchDBGrid: TDBGrid;
    searchADOQuery: TADOQuery;
    groupADOQuery: TADOQuery;
    delButton: TButton;
    queryButton: TButton;
    queryIdEdit: TEdit;
    helpLabel1: TLabel;
    helpLabel2: TLabel;
    ApplicationEvents1: TApplicationEvents;
    typeCmbBox: TComboBox;
    queryTypeLabel: TLabel;
    queryIdLabel: TLabel;
    RepButton: TButton;

    procedure queryButtonClick(Sender: TObject);
    procedure refresh(keyValue: integer);
    function isNum(S: string): Boolean;
    function inputFormat(s: string): string;
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure delButtonClick(Sender: TObject);
    procedure searchDBGridDrawColumnCell(Sender: TObject;
      const Rect: TRect; DataCol: Integer; Column: TColumn;
      State: TGridDrawState);
    procedure RepButtonClick(Sender: TObject);
    function canToInt(s: string): boolean;
    //function groupSum(): TADOQuery;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
uses login,
  exclToRep_func;
{$R *.dfm}

{查询按钮}

procedure TdailyQueryFrame.queryButtonClick(Sender: TObject);
var
  inputStr: string;
  typeStr_1: string;
  typeStr_2: string;
  typeStr_3: string;
  CurenAmountADOQuery: TADOQuery;
  CurenAmount: Currency;
begin
  typeStr_1 := '主类面条';
  typeStr_2 := '可加副料';
  typeStr_3 := '饮料烟酒';
  // 如果条件输入框不为空
  if (trim(queryIdEdit.Text) <> '') then
    begin
      // 判断条件输入框是不是数字
      if not isNum(queryIdEdit.Text) then
        begin
          // 不是纯数字组合则报错
          messagebox(handle, '你输入的号码不是数字，请重新输入。',
            '检查输入',
            mb_ok);
          queryIdEdit.SetFocus;
          exit;
        end
      else
        begin
          // 检查是否为合法整数
          inputStr := queryIdEdit.Text;
          if not canToInt(inputStr) then
            begin
              // 不是合法整数则报错
              messagebox(handle, '你输入的号码不是整数，请重新输入。',
                '检查输入',
                mb_ok);
              queryIdEdit.SetFocus;
              exit;
            end;
          // 如果查询牌号
          if (trim(typeCmbBox.Text) = '牌号') then
            with searchADOQuery do
              begin
                Close;
                SQL.Clear;
                SQL.Add(' select IIf((order_no mod 100) = 0, 100, (order_no mod 100)) as order_no, uniq_key, prod_nm, prod_price, sale_cnt, format(sale_date, "yyyy-mm-dd hh:nn:ss") as s_date, prod_type from sales where 1 = 1 ');
                SQL.Append(' and IIf((order_no mod 100) = 0, 100, (order_no mod 100)) = :ord_no ');
                SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) order by sale_date, order_no, uniq_key asc ');
                Parameters.ParamByName('ord_no').Value := strToInt(inputStr);
                Open;
                if IsEmpty then
                  begin
                    // 没有检索到数据,Grid不显示,删除报表不可点击
                    searchDBGrid.Visible := False;
                    delButton.Enabled := False;
                    RepButton.Enabled := False;
                    messagebox(handle, '没有查询到今天相关的记录！',
                      '无记录',
                      mb_ok);
                    exit;
                  end
                else
                  begin
                    // 检索到数据,DBGrid默认指向第一行
                    searchADOQuery.First;
                    searchDBGrid.Visible := True;
                    // 删除,报表按钮可点击
                    delButton.Enabled := True;
                    RepButton.Enabled := True;
                    ShowScrollBar(searchDBGrid.Handle, SB_HORZ, True);
                    ShowScrollBar(searchDBGrid.Handle, SB_HORZ, False);
                    searchDBGrid.SelectedRows.CurrentRowSelected := true;
                    searchDBGrid.SetFocus;
                    // 分组统计数量金额
                    with groupADOQuery do
                      begin
                        {按主类面条名称分组统计
                         typeStr_1 := '主类面条';
                         typeStr_2 := '可加副料';
                         typeStr_3 := '饮料烟酒';}
                        Close;
                        SQL.Clear;
                        SQL.Add(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''1'' as grpType from sales where 1 = 1 ');
                        SQL.Append(' and prod_type =:type_1 ');
                        SQL.Append(' and IIf((order_no mod 100) = 0, 100, (order_no mod 100)) = :ord_no_1 ');
                        SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) ');
                        SQL.Append(' group by prod_nm ) ');
                        SQL.Append(' UNION ');
                        SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''2'' as grpType from sales where 1 = 1 ');
                        SQL.Append(' and prod_type =:type_2 ');
                        SQL.Append(' and IIf((order_no mod 100) = 0, 100, (order_no mod 100)) = :ord_no_2 ');
                        SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) ');
                        SQL.Append(' group by prod_nm ) ');
                        SQL.Append(' UNION ');
                        SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''3'' as grpType from sales where 1 = 1 ');
                        SQL.Append(' and prod_type =:type_3 ');
                        SQL.Append(' and IIf((order_no mod 100) = 0, 100, (order_no mod 100)) = :ord_no_3 ');
                        SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) ');
                        SQL.Append(' group by prod_nm ) ');
                        Parameters.ParamByName('type_1').Value := typeStr_1;
                        Parameters.ParamByName('type_2').Value := typeStr_2;
                        Parameters.ParamByName('type_3').Value := typeStr_3;
                        Parameters.ParamByName('ord_no_1').Value :=
                          strToInt(inputStr);
                        Parameters.ParamByName('ord_no_2').Value :=
                          strToInt(inputStr);
                        Parameters.ParamByName('ord_no_3').Value :=
                          strToInt(inputStr);
                        Open;
                      end;
                  end;
              end
          else
            // 否则查询的是明细号
            with searchADOQuery do
              begin
                Close;
                SQL.Clear;
                SQL.Add(' select IIf((order_no mod 100) = 0, 100, (order_no mod 100)) as order_no, uniq_key, prod_nm, prod_price, sale_cnt, format(sale_date, "yyyy-mm-dd hh:nn:ss") as s_date, prod_type from sales where 1 = 1 ');
                SQL.Append(' and uniq_key = :uniq_key ');
                SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) order by sale_date, order_no, uniq_key asc ');
                Parameters.ParamByName('uniq_key').Value :=
                  strToInt(inputStr);
                Open;
                // 保存输入的订单号的值, 用于刷新后定位
                //queryIdValue := strToInt(queryIdEdit.Text);
                if IsEmpty then
                  begin
                    // 没有检索到数据,Grid不显示,删除报表不可点击
                    searchDBGrid.Visible := False;
                    delButton.Enabled := False;
                    RepButton.Enabled := False;
                    messagebox(handle, '没有查询到今天相关的记录！',
                      '无记录',
                      mb_ok);
                    exit;
                  end
                else
                  begin
                    // 检索到数据,DBGrid默认指向第一行
                    searchADOQuery.First;
                    searchDBGrid.Visible := True;
                    // 删除,报表按钮可点击
                    delButton.Enabled := True;
                    RepButton.Enabled := True;
                    ShowScrollBar(searchDBGrid.Handle, SB_HORZ, True);
                    ShowScrollBar(searchDBGrid.Handle, SB_HORZ, False);
                    searchDBGrid.SelectedRows.CurrentRowSelected := true;
                    searchDBGrid.SetFocus;
                    // 分组统计数量金额
                    with groupADOQuery do
                      begin
                        {按主类面条名称分组统计
                         typeStr_1 := '主类面条';
                         typeStr_2 := '可加副料';
                         typeStr_3 := '饮料烟酒';}
                        Close;
                        SQL.Clear;
                        SQL.Add(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''1'' as grpType from sales where 1 = 1 ');
                        SQL.Append(' and prod_type =:type_1 ');
                        SQL.Append(' and uniq_key = :uniq_key_1 ');
                        SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) ');
                        SQL.Append(' group by prod_nm ) ');
                        SQL.Append(' UNION ');
                        SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''2'' as grpType from sales where 1 = 1 ');
                        SQL.Append(' and prod_type =:type_2 ');
                        SQL.Append(' and uniq_key = :uniq_key_2 ');
                        SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) ');
                        SQL.Append(' group by prod_nm ) ');
                        SQL.Append(' UNION ');
                        SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''3'' as grpType from sales where 1 = 1 ');
                        SQL.Append(' and prod_type =:type_3 ');
                        SQL.Append(' and uniq_key = :uniq_key_3 ');
                        SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) ');
                        SQL.Append(' group by prod_nm ) ');
                        Parameters.ParamByName('type_1').Value := typeStr_1;
                        Parameters.ParamByName('type_2').Value := typeStr_2;
                        Parameters.ParamByName('type_3').Value := typeStr_3;
                        Parameters.ParamByName('uniq_key_1').Value :=
                          strToInt(inputStr);
                        Parameters.ParamByName('uniq_key_2').Value :=
                          strToInt(inputStr);
                        Parameters.ParamByName('uniq_key_3').Value :=
                          strToInt(inputStr);
                        Open;
                      end;
                  end;
              end;
        end;
    end
  else
    begin
      // 如果输入框为空, 进行全检索
      searchADOQuery.SQL.Clear;
      searchADOQuery.SQL.Add(' select IIf((order_no mod 100) = 0, 100, (order_no mod 100)) as order_no, uniq_key, prod_nm, prod_price, sale_cnt, format(sale_date, "yyyy-mm-dd hh:nn:ss") as s_date, prod_type from sales where 1 = 1 ');
      searchADOQuery.SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) order by sale_date, order_no, uniq_key asc ');
      searchADOQuery.Open;
      if searchADOQuery.IsEmpty then
        begin
          // 没有检索到数据,Grid不显示,删除报表不可点击
          searchDBGrid.Visible := False;
          delButton.Enabled := False;
          RepButton.Enabled := False;
          messagebox(handle, '没有查询到今天相关的记录！',
            '无记录',
            mb_ok);
          exit;
        end
      else
        begin
          // 检索到数据,DBGrid默认指向第一行
          searchADOQuery.First;
          searchDBGrid.Visible := True;
          // 删除,报表按钮可点击
          delButton.Enabled := True;
          RepButton.Enabled := True;
          ShowScrollBar(searchDBGrid.Handle, SB_HORZ, True);
          ShowScrollBar(searchDBGrid.Handle, SB_HORZ, False);
          searchDBGrid.SelectedRows.CurrentRowSelected := true;
          searchDBGrid.SetFocus;
          // 分组统计数量金额
          with groupADOQuery do
            begin
              {按主类面条名称分组统计
              typeStr_1 := '主类面条';
              typeStr_2 := '可加副料';
              typeStr_3 := '饮料烟酒';}
              Close;
              SQL.Clear;
              SQL.Add(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''1'' as grpType from sales where 1 = 1 ');
              SQL.Append(' and prod_type =:type_1 ');
              SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) ');
              SQL.Append(' group by prod_nm ) ');
              SQL.Append(' UNION ');
              SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''2'' as grpType from sales where 1 = 1 ');
              SQL.Append(' and prod_type =:type_2 ');
              SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) ');
              SQL.Append(' group by prod_nm ) ');
              SQL.Append(' UNION ');
              SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''3'' as grpType from sales where 1 = 1 ');
              SQL.Append(' and prod_type =:type_3 ');
              SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) ');
              SQL.Append(' group by prod_nm ) ');
              Parameters.ParamByName('type_1').Value := typeStr_1;
              Parameters.ParamByName('type_2').Value := typeStr_2;
              Parameters.ParamByName('type_3').Value := typeStr_3;
              Open;
            end;
        end;
    end;

  // 显示目前为止当天销售总和
  // 创建临时ADOQuery控件
  CurenAmountADOQuery := TADOQuery.Create(self);
  // 定义ADOQuery连接数据库字串
  CurenAmountADOQuery.Connection := DBConnection;
  // 检索当天销售的所有记录的金额总和
  CurenAmountADOQuery.Close;
  CurenAmountADOQuery.SQL.Clear;
  CurenAmountADOQuery.SQL.Add(' select sum(prod_price) as curAmout from sales where 1 = 1 ');
  CurenAmountADOQuery.SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) ');
  CurenAmountADOQuery.Open;
  if not CurenAmountADOQuery.IsEmpty then
    begin
      CurenAmount := CurenAmountADOQuery.FieldByName('curAmout').AsCurrency;
      helpLabel1.Caption := '当前累计销售额: ' + CurrToStr(CurenAmount) + '元';
      helpLabel1.Font.Color := clBlue;
      helpLabel1.Visible := True;
    end;
  // 释放ADOQuery对象
  CurenAmountADOQuery.Close;
  CurenAmountADOQuery.Free;

  if (login.UserType = '员工') then
    begin
      // 如果是员工,不可以删除和生成报表
      delButton.Enabled := False;
      // RepButton.Enabled := False;
    end;
end;

{画面刷新}

procedure TdailyQueryFrame.refresh(keyValue: integer);
begin
  // DBGrid不可见
  searchDBGrid.Visible := False;
  {//helpLabel1.Visible := True;
  //helpLabel2.Visible := True;}
  // 重新检索
  queryButtonClick(self);
  searchADOQuery.Locate('uniq_key', keyValue, []);
end;

{判断一个字符串是否为数字}

function TdailyQueryFrame.isNum(S: string): Boolean;
//变量S为要判断的字符串,返回true则正确
var
  i: integer;
begin
  Result := True;
  for i := 1 to length(s) do
    begin
      if not (s[i] in ['0'..'9', '-']) then
        //判断字符串每个字符即s[i],是否为"0"到'9"或者"-"
        begin
          Result := False;
          break;
        end;
    end;
end;

{字符串头部去零}

function TdailyQueryFrame.inputFormat(S: string): string;
var
  i, j: integer;
begin
  j := 1;
  if length(s) > 1 then
    begin
      for i := 1 to length(s) do
        begin
          if s[i] = '0' then
            j := j + 1
          else
            continue;
        end;
      if j > 1 then
        result := copy(s, j, length(s))
      else
        result := s;
    end
  else
    result := s;

end;

{判断一个字符串是否能转型成整数}

function TdailyQueryFrame.canToInt(s: string): boolean;
begin
  result := true;
  try
    strtoint(s);
  except result := false;
  end;
end;

{DBgrid Cell 点击事件, 同步设定值到编辑框}

procedure TdailyQueryFrame.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if (searchDBGrid.Focused) and (Msg.message = WM_MOUSEWHEEL) then
    begin
      if Msg.wParam > 0 then
        begin
          SendMessage(searchDBGrid.Handle, WM_KEYDOWN, VK_UP, 0);
          searchDBGrid.SelectedRows.CurrentRowSelected := true;
          searchDBGrid.SetFocus;
        end
      else
        begin
          SendMessage(searchDBGrid.Handle, WM_KEYDOWN, VK_DOWN, 0);
          searchDBGrid.SelectedRows.CurrentRowSelected := true;
          searchDBGrid.SetFocus;
        end;
      Handled := True;
    end;
end;

{删除按钮}

procedure TdailyQueryFrame.delButtonClick(Sender: TObject);
var
  delKey: string;
  delKeyPrior: string;
  delSalDate: string;
  delProdNm: string;
  delProdPrice: string;
  delADOQuery: TADOQuery;
begin
  if searchDBGrid.SelectedRows.Count = 0 then
    begin
      messagebox(handle, '请先选中要删除的记录！',
        '记录未选中',
        mb_ok);
      exit;
    end
  else
    begin
      delKey := searchADOQuery.FieldByName('uniq_key').AsString;
      delSalDate := searchADOQuery.FieldByName('s_date').AsString;
      delProdNm := searchADOQuery.FieldByName('prod_nm').AsString;
      delProdPrice := searchADOQuery.FieldByName('prod_price').AsString;
      if messagebox(handle, pchar('是否删除在 "' + delSalDate + '" 销售的: "' +
        delProdNm + '(价格:' + delProdPrice +
        '元)" 的记录 ？(删除后不能被恢复)'), '确认删除',
        mb_iconquestion + mb_yesno) = IDyes then
        begin
          // 指向上一行
          searchADOQuery.Prior;
          // 保存上一行的 Key
          delKeyPrior := searchADOQuery.FieldByName('uniq_key').AsString;
          // 生成临时ADO,用于删除
          delADOQuery := TADOQuery.Create(self);
          delADOQuery.Connection := DBConnection;
          with delADOQuery do
            begin
              Close;
              SQL.Clear;
              SQL.Add(' delete from sales where uniq_key = :key ');
              Parameters.ParamByName('key').Value := strToInt(delKey);
              ExecSQL;
            end;
          // 释放临时ADO对象
          delADOQuery.Close;
          delADOQuery.Free;
          // 刷新后定位到上一行
          refresh(strToInt(delKeyPrior));
        end;
    end;
end;

{选中行变色}

procedure TdailyQueryFrame.searchDBGridDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  if gdSelected in State then
    with searchDBGrid do
      begin
        Canvas.Brush.Color := clMoneyGreen;
        Canvas.FillRect(Rect);
        Canvas.Font.Color := clBlack;
        Canvas.TextOut(Rect.Left, Rect.Top, Column.Field.AsString);
      end
  else
    with searchDBGrid do
      begin
        Canvas.Brush.Color := clWindow;
        Canvas.FillRect(Rect);
        Canvas.Font.Color := clBlack;
        Canvas.TextOut(Rect.Left, Rect.Top, Column.Field.AsString);
      end;
  searchDBGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

{报表生成按钮}

procedure TdailyQueryFrame.RepButtonClick(Sender: TObject);
var
  fileInfo: string;
begin
  //queryButtonClick(self);
  fileInfo := '账目_' + FormatDateTime('yyyy-mm-dd', now()) + '.xls';
  exclToRep_func.ExportToExcel(searchDBGrid, groupADOQuery, fileInfo);
end;

end.
