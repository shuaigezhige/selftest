unit hisQuery;

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
  ComCtrls,
  Clipbrd,
  ComObj;

type
  ThisQueryFrame = class(TFrame)
    searchDataSource: TDataSource;
    searchDBGrid: TDBGrid;
    searchADOQuery: TADOQuery;
    groupADOQuery: TADOQuery;
    delButton: TButton;
    queryButton: TButton;
    queryIdEdit: TEdit;
    ApplicationEvents1: TApplicationEvents;
    typeCmbBox: TComboBox;
    queryTypeLabel: TLabel;
    queryIdLabel: TLabel;
    startDateTime: TDateTimePicker;
    endDateTime: TDateTimePicker;
    startDateLabel: TLabel;
    endDateLabel: TLabel;
    recentRadBtn: TRadioButton;
    hisMonthsRadBtn: TRadioButton;
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
    procedure recentRadBtnClick(Sender: TObject);
    procedure hisMonthsRadBtnClick(Sender: TObject);
    procedure RepButtonClick(Sender: TObject);
    function canToInt(s: string): boolean;
  private
    { Private declarations }
  public
    { Public declarations }
    searchType: string;
    startDateRep: string;
    endDateRep: string;
  end;

implementation
uses login,
  exclToRep_func;
{$R *.dfm}

{查询按钮}

procedure ThisQueryFrame.queryButtonClick(Sender: TObject);
//调试用  startDate  endDate
var
  startDate, endDate: string;
  inputStr: string;
  typeStr_1: string;
  typeStr_2: string;
  typeStr_3: string;
begin
  typeStr_1 := '主类面条';
  typeStr_2 := '可加副料';
  typeStr_3 := '饮料烟酒';
  //如果开始日期大于结束日期
  if int(strtodate(FormatdateTime('yyyy-mm-dd', startDateTime.Date))) >
    int(endDateTime.Date) then
    begin
      messagebox(handle, '开始日期不能大于结束日期，请重新输入。',
        '检查输入',
        mb_ok);
      startDateTime.SetFocus;
      exit;
    end;
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
          // 检查是否是合法整数
          inputStr := queryIdEdit.Text;
          if not canToInt(inputStr) then
            begin
              // 不是合法整数则报错
              messagebox(handle, '你输入的号码不合法，请重新输入。',
                '检查输入',
                mb_ok);
              queryIdEdit.SetFocus;
              exit;
            end;
          //inputStr := inputFormat(queryIdEdit.Text);
          //queryIdEdit.Text := inputStr;
          // 如果查询组合号
          if (trim(typeCmbBox.Text) = '牌号') then
            with searchADOQuery do
              begin
                //调试用  startDate  endDate
                startDate := FormatDateTime('yyyy-mm-dd hh24:mm:ss',
                  startDateTime.DateTime);
                endDate := FormatDateTime('yyyy-mm-dd hh24:mm:ss',
                  endDateTime.DateTime);
                Close;
                SQL.Clear;
                // 如果查询三个月以前的
                if hisMonthsRadBtn.Checked = true then
                  begin
                    SQL.Add(' select IIf((order_no mod 100) = 0, 100, (order_no mod 100)) as order_no, uniq_key, prod_nm, prod_price, sale_cnt, format(sale_date, "yyyy-mm-dd hh:nn:ss") as s_date, prod_type from his_sales where 1 = 1 ');
                    searchType := 'old';
                  end
                    // 如果查询三个月以内的
                else
                  begin
                    SQL.Add(' select IIf((order_no mod 100) = 0, 100, (order_no mod 100)) as order_no, uniq_key, prod_nm, prod_price, sale_cnt, format(sale_date, "yyyy-mm-dd hh:nn:ss") as s_date, prod_type from sales where 1 = 1 ');
                    searchType := 'recent';
                  end;
                SQL.Append(' and IIf((order_no mod 100) = 0, 100, (order_no mod 100)) = :ord_no ');
                SQL.Append(' and sale_date between :startDate and :endDate order by sale_date, order_no, uniq_key asc ');
                Parameters.ParamByName('ord_no').Value := strToInt(inputStr);
                Parameters.ParamByName('startDate').Value :=
                  startDateTime.DateTime;
                Parameters.ParamByName('endDate').Value :=
                  endDateTime.DateTime;
                Open;
                // 保存输入框的值, 用于刷新后定位
                //queryIdValue := strToInt(queryIdEdit.Text);
                if IsEmpty then
                  begin
                    searchDBGrid.Visible := False;
                    delButton.Enabled := False;
                    RepButton.Enabled := False;
                    messagebox(handle, '没有查询到相关的记录！',
                      '无记录',
                      mb_ok);
                    exit;
                  end
                else
                  begin
                    searchADOQuery.First;
                    searchDBGrid.Visible := True;
                    delButton.Enabled := True;
                    RepButton.Enabled := True;
                    ShowScrollBar(searchDBGrid.Handle, SB_HORZ, True);
                    ShowScrollBar(searchDBGrid.Handle, SB_HORZ, False);
                    searchDBGrid.SelectedRows.CurrentRowSelected := true;
                    searchDBGrid.SetFocus;
                    startDateRep := FormatDateTime('yyyy-mm-dd',
                      startDateTime.DateTime);
                    endDateRep := FormatDateTime('yyyy-mm-dd',
                      endDateTime.DateTime);
                    // 分组统计数量金额
                    with groupADOQuery do
                      begin
                        {按主类面条名称分组统计
                           typeStr_1 := '主类面条';
                           typeStr_2 := '可加副料';
                           typeStr_3 := '饮料烟酒';}
                        Close;
                        SQL.Clear;
                        // 按主类面条名称分组统计
                        // 如果查询三个月以前的
                        if hisMonthsRadBtn.Checked = true then
                          begin
                            SQL.Add(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''1'' as grpType from his_sales where 1 = 1 ');
                            SQL.Append(' and prod_type =:type_1 ');
                            SQL.Append(' and IIf((order_no mod 100) = 0, 100, (order_no mod 100)) = :ord_no_1 ');
                            SQL.Append(' and sale_date between :startDate_1 and :endDate_1 ');
                            SQL.Append(' group by prod_nm ) ');
                            SQL.Append(' UNION ');
                            SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''2'' as grpType from his_sales where 1 = 1 ');
                            SQL.Append(' and prod_type =:type_2 ');
                            SQL.Append(' and IIf((order_no mod 100) = 0, 100, (order_no mod 100)) = :ord_no_2 ');
                            SQL.Append(' and sale_date between :startDate_2 and :endDate_2 ');
                            SQL.Append(' group by prod_nm ) ');
                            SQL.Append(' UNION ');
                            SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''3'' as grpType from his_sales where 1 = 1 ');
                            SQL.Append(' and prod_type =:type_3 ');
                            SQL.Append(' and IIf((order_no mod 100) = 0, 100, (order_no mod 100)) = :ord_no_3 ');
                            SQL.Append(' and sale_date between :startDate_3 and :endDate_3 ');
                            SQL.Append(' group by prod_nm ) ');
                          end
                            // 如果查询三个月以内的
                        else
                          begin
                            SQL.Add(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''1'' as grpType from sales where 1 = 1 ');
                            SQL.Append(' and prod_type =:type_1 ');
                            SQL.Append(' and IIf((order_no mod 100) = 0, 100, (order_no mod 100)) = :ord_no_1 ');
                            SQL.Append(' and sale_date between :startDate_1 and :endDate_1 ');
                            SQL.Append(' group by prod_nm ) ');
                            SQL.Append(' UNION ');
                            SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''2'' as grpType from sales where 1 = 1 ');
                            SQL.Append(' and prod_type =:type_2 ');
                            SQL.Append(' and IIf((order_no mod 100) = 0, 100, (order_no mod 100)) = :ord_no_2 ');
                            SQL.Append(' and sale_date between :startDate_2 and :endDate_2 ');
                            SQL.Append(' group by prod_nm ) ');
                            SQL.Append(' UNION ');
                            SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''3'' as grpType from sales where 1 = 1 ');
                            SQL.Append(' and prod_type =:type_3 ');
                            SQL.Append(' and IIf((order_no mod 100) = 0, 100, (order_no mod 100)) = :ord_no_3 ');
                            SQL.Append(' and sale_date between :startDate_3 and :endDate_3 ');
                            SQL.Append(' group by prod_nm ) ');
                          end;
                        Parameters.ParamByName('type_1').Value := typeStr_1;
                        Parameters.ParamByName('type_2').Value := typeStr_2;
                        Parameters.ParamByName('type_3').Value := typeStr_3;
                        Parameters.ParamByName('ord_no_1').Value :=
                          strToInt(inputStr);
                        Parameters.ParamByName('ord_no_2').Value :=
                          strToInt(inputStr);
                        Parameters.ParamByName('ord_no_3').Value :=
                          strToInt(inputStr);
                        Parameters.ParamByName('startDate_1').Value :=
                          startDateTime.DateTime;
                        Parameters.ParamByName('endDate_1').Value :=
                          endDateTime.DateTime;
                        Parameters.ParamByName('startDate_2').Value :=
                          startDateTime.DateTime;
                        Parameters.ParamByName('endDate_2').Value :=
                          endDateTime.DateTime;
                        Parameters.ParamByName('startDate_3').Value :=
                          startDateTime.DateTime;
                        Parameters.ParamByName('endDate_3').Value :=
                          endDateTime.DateTime;
                        Open;
                      end;
                  end;
              end
          else
            // 否则查询的是明细号
            with searchADOQuery do
              begin
                //调试用  startDate  endDate
                startDate := FormatDateTime('yyyy-mm-dd hh24:mm:ss',
                  startDateTime.DateTime);
                endDate := FormatDateTime('yyyy-mm-dd hh24:mm:ss',
                  endDateTime.DateTime);
                Close;
                SQL.Clear;
                // 如果查询三个月以前的
                if hisMonthsRadBtn.Checked = true then
                  begin
                    SQL.Add(' select IIf((order_no mod 100) = 0, 100, (order_no mod 100)) as order_no, uniq_key, prod_nm, prod_price, sale_cnt, format(sale_date, "yyyy-mm-dd hh:nn:ss") as s_date, prod_type from his_sales where 1 = 1 ');
                    searchType := 'old';
                  end
                    // 如果查询三个月以内的
                else
                  begin
                    SQL.Add(' select IIf((order_no mod 100) = 0, 100, (order_no mod 100)) as order_no, uniq_key, prod_nm, prod_price, sale_cnt, format(sale_date, "yyyy-mm-dd hh:nn:ss") as s_date, prod_type from sales where 1 = 1 ');
                    searchType := 'recent';
                  end;
                SQL.Append(' and uniq_key = :uniq_key ');
                SQL.Append(' and sale_date between :startDate and :endDate order by sale_date, order_no, uniq_key asc ');
                Parameters.ParamByName('uniq_key').Value :=
                  strToInt(inputStr);
                Parameters.ParamByName('startDate').Value :=
                  startDateTime.DateTime;
                Parameters.ParamByName('endDate').Value :=
                  endDateTime.DateTime;
                Open;
                // 保存输入的订单号的值, 用于刷新后定位
                //queryIdValue := strToInt(queryIdEdit.Text);
                if IsEmpty then
                  begin
                    searchDBGrid.Visible := False;
                    delButton.Enabled := False;
                    RepButton.Enabled := False;
                    messagebox(handle, '没有查询到相关的记录！',
                      '无记录',
                      mb_ok);
                    exit;
                  end
                else
                  begin
                    searchADOQuery.First;
                    searchDBGrid.Visible := True;
                    delButton.Enabled := True;
                    RepButton.Enabled := True;
                    ShowScrollBar(searchDBGrid.Handle, SB_HORZ, True);
                    ShowScrollBar(searchDBGrid.Handle, SB_HORZ, False);
                    searchDBGrid.SelectedRows.CurrentRowSelected := true;
                    searchDBGrid.SetFocus;
                    startDateRep := FormatDateTime('yyyy-mm-dd',
                      startDateTime.DateTime);
                    endDateRep := FormatDateTime('yyyy-mm-dd',
                      endDateTime.DateTime);
                    // 分组统计数量金额
                    with groupADOQuery do
                      begin
                        Close;
                        SQL.Clear;
                        // 按主类面条名称分组统计
                        // 如果查询三个月以前的
                        if hisMonthsRadBtn.Checked = true then
                          begin
                            SQL.Add(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''1'' as grpType from his_sales where 1 = 1 ');
                            SQL.Append(' and prod_type =:type_1 ');
                            SQL.Append(' and uniq_key = :uniq_key_1 ');
                            SQL.Append(' and sale_date between :startDate_1 and :endDate_1 ');
                            SQL.Append(' group by prod_nm ) ');
                            SQL.Append(' UNION ');
                            SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''2'' as grpType from his_sales where 1 = 1 ');
                            SQL.Append(' and prod_type =:type_2 ');
                            SQL.Append(' and uniq_key = :uniq_key_2 ');
                            SQL.Append(' and sale_date between :startDate_2 and :endDate_2 ');
                            SQL.Append(' group by prod_nm ) ');
                            SQL.Append(' UNION ');
                            SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''3'' as grpType from his_sales where 1 = 1 ');
                            SQL.Append(' and prod_type =:type_3 ');
                            SQL.Append(' and uniq_key = :uniq_key_3 ');
                            SQL.Append(' and sale_date between :startDate_3 and :endDate_3 ');
                            SQL.Append(' group by prod_nm ) ');
                          end
                            // 如果查询三个月以内的
                        else
                          begin
                            SQL.Add(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''1'' as grpType from sales where 1 = 1 ');
                            SQL.Append(' and prod_type =:type_1 ');
                            SQL.Append(' and uniq_key = :uniq_key_1 ');
                            SQL.Append(' and sale_date between :startDate_1 and :endDate_1 ');
                            SQL.Append(' group by prod_nm ) ');
                            SQL.Append(' UNION ');
                            SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''2'' as grpType from sales where 1 = 1 ');
                            SQL.Append(' and prod_type =:type_2 ');
                            SQL.Append(' and uniq_key = :uniq_key_2 ');
                            SQL.Append(' and sale_date between :startDate_2 and :endDate_2 ');
                            SQL.Append(' group by prod_nm ) ');
                            SQL.Append(' UNION ');
                            SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''3'' as grpType from sales where 1 = 1 ');
                            SQL.Append(' and prod_type =:type_3 ');
                            SQL.Append(' and uniq_key = :uniq_key_3 ');
                            SQL.Append(' and sale_date between :startDate_3 and :endDate_3 ');
                            SQL.Append(' group by prod_nm ) ');
                          end;
                        Parameters.ParamByName('type_1').Value := typeStr_1;
                        Parameters.ParamByName('type_2').Value := typeStr_2;
                        Parameters.ParamByName('type_3').Value := typeStr_3;
                        Parameters.ParamByName('uniq_key_1').Value :=
                          strToInt(inputStr);
                        Parameters.ParamByName('uniq_key_2').Value :=
                          strToInt(inputStr);
                        Parameters.ParamByName('uniq_key_3').Value :=
                          strToInt(inputStr);
                        Parameters.ParamByName('startDate_1').Value :=
                          startDateTime.DateTime;
                        Parameters.ParamByName('endDate_1').Value :=
                          endDateTime.DateTime;
                        Parameters.ParamByName('startDate_2').Value :=
                          startDateTime.DateTime;
                        Parameters.ParamByName('endDate_2').Value :=
                          endDateTime.DateTime;
                        Parameters.ParamByName('startDate_3').Value :=
                          startDateTime.DateTime;
                        Parameters.ParamByName('endDate_3').Value :=
                          endDateTime.DateTime;
                        Open;
                      end;
                  end;
              end;
        end;
    end
  else
    // 如果输入框为空, 进行全检索
    begin
      searchADOQuery.Close;
      searchADOQuery.SQL.Clear;
      // 如果查询三个月以前的
      if hisMonthsRadBtn.Checked = true then
        begin
          searchADOQuery.SQL.Add(' select IIf((order_no mod 100) = 0, 100, (order_no mod 100)) as order_no, uniq_key, prod_nm, prod_price, sale_cnt, format(sale_date, "yyyy-mm-dd hh:nn:ss") as s_date, prod_type from his_sales where 1 = 1 ');
          searchType := 'old';
        end
          // 如果查询三个月以内的
      else
        begin
          searchADOQuery.SQL.Add(' select IIf((order_no mod 100) = 0, 100, (order_no mod 100)) as order_no, uniq_key, prod_nm, prod_price, sale_cnt, format(sale_date, "yyyy-mm-dd hh:nn:ss") as s_date, prod_type from sales where 1 = 1 ');
          searchType := 'recent';
        end;
      searchADOQuery.SQL.Append(' and sale_date between :startDate and :endDate order by sale_date, order_no, uniq_key asc ');
      searchADOQuery.Parameters.ParamByName('startDate').Value :=
        startDateTime.DateTime;
      searchADOQuery.Parameters.ParamByName('endDate').Value :=
        endDateTime.DateTime;
      searchADOQuery.Open;
      if searchADOQuery.IsEmpty then
        begin
          searchDBGrid.Visible := False;
          delButton.Enabled := False;
          RepButton.Enabled := False;
          messagebox(handle, '没有查询到相关的记录！',
            '无记录',
            mb_ok);
          exit;
        end
      else
        begin
          searchADOQuery.First;
          searchDBGrid.Visible := True;
          delButton.Enabled := True;
          RepButton.Enabled := True;
          ShowScrollBar(searchDBGrid.Handle, SB_HORZ, True);
          ShowScrollBar(searchDBGrid.Handle, SB_HORZ, False);
          searchDBGrid.SelectedRows.CurrentRowSelected := true;
          searchDBGrid.SetFocus;
          startDateRep := FormatDateTime('yyyy-mm-dd',
            startDateTime.DateTime);
          endDateRep := FormatDateTime('yyyy-mm-dd',
            endDateTime.DateTime);
          // 分组统计数量金额
          with groupADOQuery do
            begin
              Close;
              SQL.Clear;
              // 按主类面条名称分组统计
              // 如果查询三个月以前的
              if hisMonthsRadBtn.Checked = true then
                begin
                  SQL.Add(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''1'' as grpType from his_sales where 1 = 1 ');
                  SQL.Append(' and prod_type =:type_1 ');
                  SQL.Append(' and sale_date between :startDate_1 and :endDate_1 ');
                  SQL.Append(' group by prod_nm ) ');
                  SQL.Append(' UNION ');
                  SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''2'' as grpType from his_sales where 1 = 1 ');
                  SQL.Append(' and prod_type =:type_2 ');
                  SQL.Append(' and sale_date between :startDate_2 and :endDate_2 ');
                  SQL.Append(' group by prod_nm ) ');
                  SQL.Append(' UNION ');
                  SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''3'' as grpType from his_sales where 1 = 1 ');
                  SQL.Append(' and prod_type =:type_3 ');
                  SQL.Append(' and sale_date between :startDate_3 and :endDate_3 ');
                  SQL.Append(' group by prod_nm ) ');
                end
                  // 如果查询三个月以内的
              else
                begin
                  SQL.Add(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''1'' as grpType from sales where 1 = 1 ');
                  SQL.Append(' and prod_type =:type_1 ');
                  SQL.Append(' and sale_date between :startDate_1 and :endDate_1 ');
                  SQL.Append(' group by prod_nm ) ');
                  SQL.Append(' UNION ');
                  SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''2'' as grpType from sales where 1 = 1 ');
                  SQL.Append(' and prod_type =:type_2 ');
                  SQL.Append(' and sale_date between :startDate_2 and :endDate_2 ');
                  SQL.Append(' group by prod_nm ) ');
                  SQL.Append(' UNION ');
                  SQL.Append(' ( select prod_nm, sum(sale_cnt) as group_cnt, sum(prod_price) as group_price, ''3'' as grpType from sales where 1 = 1 ');
                  SQL.Append(' and prod_type =:type_3 ');
                  SQL.Append(' and sale_date between :startDate_3 and :endDate_3 ');
                  SQL.Append(' group by prod_nm ) ');
                end;
              Parameters.ParamByName('type_1').Value := typeStr_1;
              Parameters.ParamByName('type_2').Value := typeStr_2;
              Parameters.ParamByName('type_3').Value := typeStr_3;
              Parameters.ParamByName('startDate_1').Value :=
                startDateTime.DateTime;
              Parameters.ParamByName('endDate_1').Value :=
                endDateTime.DateTime;
              Parameters.ParamByName('startDate_2').Value :=
                startDateTime.DateTime;
              Parameters.ParamByName('endDate_2').Value :=
                endDateTime.DateTime;
              Parameters.ParamByName('startDate_3').Value :=
                startDateTime.DateTime;
              Parameters.ParamByName('endDate_3').Value :=
                endDateTime.DateTime;
              Open;
            end;
        end;
    end;
  //refresh(-1);
end;

{画面刷新}

procedure ThisQueryFrame.refresh(keyValue: integer);
//调试用  startDate  endDate
var
  startDate, endDate: string;
begin
  searchDBGrid.Visible := False;
  //调试用  startDate  endDate
  startDate := datetostr(startDateTime.DateTime);
  endDate := datetostr(endDateTime.DateTime);
  startDate := FormatDateTime('yyyy-mm-dd hh24:mm:ss',
    startDateTime.DateTime);
  endDate := FormatDateTime('yyyy-mm-dd hh24:mm:ss',
    endDateTime.DateTime);
  queryButtonClick(self);
  searchADOQuery.Locate('uniq_key', keyValue, []);
end;

{判断一个字符串是否为数字}

function ThisQueryFrame.isNum(S: string): Boolean;
//变量S为要判断的字符串,返回true则正确
var
  i: integer;
begin
  Result := True;
  for i := 1 to length(s) do
    begin
      if not (s[i] in ['0'..'9', '-']) then
        //判断字符串每个字符即s[i],是否为"0"到'9"数字
        begin
          Result := False;
          break;
        end;
    end;
end;

{字符串头部去零}

function ThisQueryFrame.inputFormat(s: string): string;
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

function ThisQueryFrame.canToInt(s: string): boolean;
begin
  result := true;
  try
    strtoint(s);
  except result := false;
  end;
end;

{DBgrid Cell 点击事件, 同步设定值到编辑框}

procedure ThisQueryFrame.ApplicationEvents1Message(var Msg: tagMSG;
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

procedure ThisQueryFrame.delButtonClick(Sender: TObject);
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
      messagebox(handle, '请选中要删除的记录先！',
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
              if searchType = 'old' then
                SQL.Add(' delete from his_sales where uniq_key = :key ')
              else
                SQL.Add(' delete from sales where uniq_key = :key ');
              Parameters.ParamByName('key').Value := strToInt(delKey);
              ExecSQL;
            end;
          // 释放临时ADO对象
          delADOQuery.Close;
          delADOQuery.Free;
          // 刷新后定位到上一行
          refresh(strToInt(delKeyPrior));
        end
    end;
end;

{选中行变色}

procedure ThisQueryFrame.searchDBGridDrawColumnCell(Sender: TObject;
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

{查询近三个月按钮点击}

procedure ThisQueryFrame.recentRadBtnClick(Sender: TObject);
begin
  if hisMonthsRadBtn.Checked = true then
    hisMonthsRadBtn.Checked := False;
  recentRadBtn.Checked := true;
end;

{查询三个月前按钮点击}

procedure ThisQueryFrame.hisMonthsRadBtnClick(Sender: TObject);
begin
  if recentRadBtn.Checked = true then
    recentRadBtn.Checked := False;
  hisMonthsRadBtn.Checked := true;
end;

{报表生成按钮}

procedure ThisQueryFrame.RepButtonClick(Sender: TObject);
var
  fileInfo: string;
begin
  //queryButtonClick(self);
  fileInfo := '账目_' + startDateRep + '~' + endDateRep + '.xls';
  exclToRep_func.ExportToExcel(searchDBGrid, groupADOQuery, fileInfo);
end;

end.
