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

{��ѯ��ť}

procedure ThisQueryFrame.queryButtonClick(Sender: TObject);
//������  startDate  endDate
var
  startDate, endDate: string;
  inputStr: string;
  typeStr_1: string;
  typeStr_2: string;
  typeStr_3: string;
begin
  typeStr_1 := '��������';
  typeStr_2 := '�ɼӸ���';
  typeStr_3 := '�����̾�';
  //�����ʼ���ڴ��ڽ�������
  if int(strtodate(FormatdateTime('yyyy-mm-dd', startDateTime.Date))) >
    int(endDateTime.Date) then
    begin
      messagebox(handle, '��ʼ���ڲ��ܴ��ڽ������ڣ����������롣',
        '�������',
        mb_ok);
      startDateTime.SetFocus;
      exit;
    end;
  // ������������Ϊ��
  if (trim(queryIdEdit.Text) <> '') then
    begin
      // �ж�����������ǲ�������
      if not isNum(queryIdEdit.Text) then
        begin
          // ���Ǵ���������򱨴�
          messagebox(handle, '������ĺ��벻�����֣����������롣',
            '�������',
            mb_ok);
          queryIdEdit.SetFocus;
          exit;
        end
      else
        begin
          // ����Ƿ��ǺϷ�����
          inputStr := queryIdEdit.Text;
          if not canToInt(inputStr) then
            begin
              // ���ǺϷ������򱨴�
              messagebox(handle, '������ĺ��벻�Ϸ������������롣',
                '�������',
                mb_ok);
              queryIdEdit.SetFocus;
              exit;
            end;
          //inputStr := inputFormat(queryIdEdit.Text);
          //queryIdEdit.Text := inputStr;
          // �����ѯ��Ϻ�
          if (trim(typeCmbBox.Text) = '�ƺ�') then
            with searchADOQuery do
              begin
                //������  startDate  endDate
                startDate := FormatDateTime('yyyy-mm-dd hh24:mm:ss',
                  startDateTime.DateTime);
                endDate := FormatDateTime('yyyy-mm-dd hh24:mm:ss',
                  endDateTime.DateTime);
                Close;
                SQL.Clear;
                // �����ѯ��������ǰ��
                if hisMonthsRadBtn.Checked = true then
                  begin
                    SQL.Add(' select IIf((order_no mod 100) = 0, 100, (order_no mod 100)) as order_no, uniq_key, prod_nm, prod_price, sale_cnt, format(sale_date, "yyyy-mm-dd hh:nn:ss") as s_date, prod_type from his_sales where 1 = 1 ');
                    searchType := 'old';
                  end
                    // �����ѯ���������ڵ�
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
                // ����������ֵ, ����ˢ�º�λ
                //queryIdValue := strToInt(queryIdEdit.Text);
                if IsEmpty then
                  begin
                    searchDBGrid.Visible := False;
                    delButton.Enabled := False;
                    RepButton.Enabled := False;
                    messagebox(handle, 'û�в�ѯ����صļ�¼��',
                      '�޼�¼',
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
                    // ����ͳ���������
                    with groupADOQuery do
                      begin
                        {�������������Ʒ���ͳ��
                           typeStr_1 := '��������';
                           typeStr_2 := '�ɼӸ���';
                           typeStr_3 := '�����̾�';}
                        Close;
                        SQL.Clear;
                        // �������������Ʒ���ͳ��
                        // �����ѯ��������ǰ��
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
                            // �����ѯ���������ڵ�
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
            // �����ѯ������ϸ��
            with searchADOQuery do
              begin
                //������  startDate  endDate
                startDate := FormatDateTime('yyyy-mm-dd hh24:mm:ss',
                  startDateTime.DateTime);
                endDate := FormatDateTime('yyyy-mm-dd hh24:mm:ss',
                  endDateTime.DateTime);
                Close;
                SQL.Clear;
                // �����ѯ��������ǰ��
                if hisMonthsRadBtn.Checked = true then
                  begin
                    SQL.Add(' select IIf((order_no mod 100) = 0, 100, (order_no mod 100)) as order_no, uniq_key, prod_nm, prod_price, sale_cnt, format(sale_date, "yyyy-mm-dd hh:nn:ss") as s_date, prod_type from his_sales where 1 = 1 ');
                    searchType := 'old';
                  end
                    // �����ѯ���������ڵ�
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
                // ��������Ķ����ŵ�ֵ, ����ˢ�º�λ
                //queryIdValue := strToInt(queryIdEdit.Text);
                if IsEmpty then
                  begin
                    searchDBGrid.Visible := False;
                    delButton.Enabled := False;
                    RepButton.Enabled := False;
                    messagebox(handle, 'û�в�ѯ����صļ�¼��',
                      '�޼�¼',
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
                    // ����ͳ���������
                    with groupADOQuery do
                      begin
                        Close;
                        SQL.Clear;
                        // �������������Ʒ���ͳ��
                        // �����ѯ��������ǰ��
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
                            // �����ѯ���������ڵ�
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
    // ��������Ϊ��, ����ȫ����
    begin
      searchADOQuery.Close;
      searchADOQuery.SQL.Clear;
      // �����ѯ��������ǰ��
      if hisMonthsRadBtn.Checked = true then
        begin
          searchADOQuery.SQL.Add(' select IIf((order_no mod 100) = 0, 100, (order_no mod 100)) as order_no, uniq_key, prod_nm, prod_price, sale_cnt, format(sale_date, "yyyy-mm-dd hh:nn:ss") as s_date, prod_type from his_sales where 1 = 1 ');
          searchType := 'old';
        end
          // �����ѯ���������ڵ�
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
          messagebox(handle, 'û�в�ѯ����صļ�¼��',
            '�޼�¼',
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
          // ����ͳ���������
          with groupADOQuery do
            begin
              Close;
              SQL.Clear;
              // �������������Ʒ���ͳ��
              // �����ѯ��������ǰ��
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
                  // �����ѯ���������ڵ�
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

{����ˢ��}

procedure ThisQueryFrame.refresh(keyValue: integer);
//������  startDate  endDate
var
  startDate, endDate: string;
begin
  searchDBGrid.Visible := False;
  //������  startDate  endDate
  startDate := datetostr(startDateTime.DateTime);
  endDate := datetostr(endDateTime.DateTime);
  startDate := FormatDateTime('yyyy-mm-dd hh24:mm:ss',
    startDateTime.DateTime);
  endDate := FormatDateTime('yyyy-mm-dd hh24:mm:ss',
    endDateTime.DateTime);
  queryButtonClick(self);
  searchADOQuery.Locate('uniq_key', keyValue, []);
end;

{�ж�һ���ַ����Ƿ�Ϊ����}

function ThisQueryFrame.isNum(S: string): Boolean;
//����SΪҪ�жϵ��ַ���,����true����ȷ
var
  i: integer;
begin
  Result := True;
  for i := 1 to length(s) do
    begin
      if not (s[i] in ['0'..'9', '-']) then
        //�ж��ַ���ÿ���ַ���s[i],�Ƿ�Ϊ"0"��'9"����
        begin
          Result := False;
          break;
        end;
    end;
end;

{�ַ���ͷ��ȥ��}

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

{�ж�һ���ַ����Ƿ���ת�ͳ�����}

function ThisQueryFrame.canToInt(s: string): boolean;
begin
  result := true;
  try
    strtoint(s);
  except result := false;
  end;
end;

{DBgrid Cell ����¼�, ͬ���趨ֵ���༭��}

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

{ɾ����ť}

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
      messagebox(handle, '��ѡ��Ҫɾ���ļ�¼�ȣ�',
        '��¼δѡ��',
        mb_ok);
      exit;
    end
  else
    begin
      delKey := searchADOQuery.FieldByName('uniq_key').AsString;
      delSalDate := searchADOQuery.FieldByName('s_date').AsString;
      delProdNm := searchADOQuery.FieldByName('prod_nm').AsString;
      delProdPrice := searchADOQuery.FieldByName('prod_price').AsString;
      if messagebox(handle, pchar('�Ƿ�ɾ���� "' + delSalDate + '" ���۵�: "' +
        delProdNm + '(�۸�:' + delProdPrice +
        'Ԫ)" �ļ�¼ ��(ɾ�����ܱ��ָ�)'), 'ȷ��ɾ��',
        mb_iconquestion + mb_yesno) = IDyes then
        begin
          // ָ����һ��
          searchADOQuery.Prior;
          // ������һ�е� Key
          delKeyPrior := searchADOQuery.FieldByName('uniq_key').AsString;
          // ������ʱADO,����ɾ��
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
          // �ͷ���ʱADO����
          delADOQuery.Close;
          delADOQuery.Free;
          // ˢ�º�λ����һ��
          refresh(strToInt(delKeyPrior));
        end
    end;
end;

{ѡ���б�ɫ}

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

{��ѯ�������°�ť���}

procedure ThisQueryFrame.recentRadBtnClick(Sender: TObject);
begin
  if hisMonthsRadBtn.Checked = true then
    hisMonthsRadBtn.Checked := False;
  recentRadBtn.Checked := true;
end;

{��ѯ������ǰ��ť���}

procedure ThisQueryFrame.hisMonthsRadBtnClick(Sender: TObject);
begin
  if recentRadBtn.Checked = true then
    recentRadBtn.Checked := False;
  hisMonthsRadBtn.Checked := true;
end;

{�������ɰ�ť}

procedure ThisQueryFrame.RepButtonClick(Sender: TObject);
var
  fileInfo: string;
begin
  //queryButtonClick(self);
  fileInfo := '��Ŀ_' + startDateRep + '~' + endDateRep + '.xls';
  exclToRep_func.ExportToExcel(searchDBGrid, groupADOQuery, fileInfo);
end;

end.
