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

{��ѯ��ť}

procedure TdailyQueryFrame.queryButtonClick(Sender: TObject);
var
  inputStr: string;
  typeStr_1: string;
  typeStr_2: string;
  typeStr_3: string;
  CurenAmountADOQuery: TADOQuery;
  CurenAmount: Currency;
begin
  typeStr_1 := '��������';
  typeStr_2 := '�ɼӸ���';
  typeStr_3 := '�����̾�';
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
          // ����Ƿ�Ϊ�Ϸ�����
          inputStr := queryIdEdit.Text;
          if not canToInt(inputStr) then
            begin
              // ���ǺϷ������򱨴�
              messagebox(handle, '������ĺ��벻�����������������롣',
                '�������',
                mb_ok);
              queryIdEdit.SetFocus;
              exit;
            end;
          // �����ѯ�ƺ�
          if (trim(typeCmbBox.Text) = '�ƺ�') then
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
                    // û�м���������,Grid����ʾ,ɾ�������ɵ��
                    searchDBGrid.Visible := False;
                    delButton.Enabled := False;
                    RepButton.Enabled := False;
                    messagebox(handle, 'û�в�ѯ��������صļ�¼��',
                      '�޼�¼',
                      mb_ok);
                    exit;
                  end
                else
                  begin
                    // ����������,DBGridĬ��ָ���һ��
                    searchADOQuery.First;
                    searchDBGrid.Visible := True;
                    // ɾ��,����ť�ɵ��
                    delButton.Enabled := True;
                    RepButton.Enabled := True;
                    ShowScrollBar(searchDBGrid.Handle, SB_HORZ, True);
                    ShowScrollBar(searchDBGrid.Handle, SB_HORZ, False);
                    searchDBGrid.SelectedRows.CurrentRowSelected := true;
                    searchDBGrid.SetFocus;
                    // ����ͳ���������
                    with groupADOQuery do
                      begin
                        {�������������Ʒ���ͳ��
                         typeStr_1 := '��������';
                         typeStr_2 := '�ɼӸ���';
                         typeStr_3 := '�����̾�';}
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
            // �����ѯ������ϸ��
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
                // ��������Ķ����ŵ�ֵ, ����ˢ�º�λ
                //queryIdValue := strToInt(queryIdEdit.Text);
                if IsEmpty then
                  begin
                    // û�м���������,Grid����ʾ,ɾ�������ɵ��
                    searchDBGrid.Visible := False;
                    delButton.Enabled := False;
                    RepButton.Enabled := False;
                    messagebox(handle, 'û�в�ѯ��������صļ�¼��',
                      '�޼�¼',
                      mb_ok);
                    exit;
                  end
                else
                  begin
                    // ����������,DBGridĬ��ָ���һ��
                    searchADOQuery.First;
                    searchDBGrid.Visible := True;
                    // ɾ��,����ť�ɵ��
                    delButton.Enabled := True;
                    RepButton.Enabled := True;
                    ShowScrollBar(searchDBGrid.Handle, SB_HORZ, True);
                    ShowScrollBar(searchDBGrid.Handle, SB_HORZ, False);
                    searchDBGrid.SelectedRows.CurrentRowSelected := true;
                    searchDBGrid.SetFocus;
                    // ����ͳ���������
                    with groupADOQuery do
                      begin
                        {�������������Ʒ���ͳ��
                         typeStr_1 := '��������';
                         typeStr_2 := '�ɼӸ���';
                         typeStr_3 := '�����̾�';}
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
      // ��������Ϊ��, ����ȫ����
      searchADOQuery.SQL.Clear;
      searchADOQuery.SQL.Add(' select IIf((order_no mod 100) = 0, 100, (order_no mod 100)) as order_no, uniq_key, prod_nm, prod_price, sale_cnt, format(sale_date, "yyyy-mm-dd hh:nn:ss") as s_date, prod_type from sales where 1 = 1 ');
      searchADOQuery.SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) order by sale_date, order_no, uniq_key asc ');
      searchADOQuery.Open;
      if searchADOQuery.IsEmpty then
        begin
          // û�м���������,Grid����ʾ,ɾ�������ɵ��
          searchDBGrid.Visible := False;
          delButton.Enabled := False;
          RepButton.Enabled := False;
          messagebox(handle, 'û�в�ѯ��������صļ�¼��',
            '�޼�¼',
            mb_ok);
          exit;
        end
      else
        begin
          // ����������,DBGridĬ��ָ���һ��
          searchADOQuery.First;
          searchDBGrid.Visible := True;
          // ɾ��,����ť�ɵ��
          delButton.Enabled := True;
          RepButton.Enabled := True;
          ShowScrollBar(searchDBGrid.Handle, SB_HORZ, True);
          ShowScrollBar(searchDBGrid.Handle, SB_HORZ, False);
          searchDBGrid.SelectedRows.CurrentRowSelected := true;
          searchDBGrid.SetFocus;
          // ����ͳ���������
          with groupADOQuery do
            begin
              {�������������Ʒ���ͳ��
              typeStr_1 := '��������';
              typeStr_2 := '�ɼӸ���';
              typeStr_3 := '�����̾�';}
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

  // ��ʾĿǰΪֹ���������ܺ�
  // ������ʱADOQuery�ؼ�
  CurenAmountADOQuery := TADOQuery.Create(self);
  // ����ADOQuery�������ݿ��ִ�
  CurenAmountADOQuery.Connection := DBConnection;
  // �����������۵����м�¼�Ľ���ܺ�
  CurenAmountADOQuery.Close;
  CurenAmountADOQuery.SQL.Clear;
  CurenAmountADOQuery.SQL.Add(' select sum(prod_price) as curAmout from sales where 1 = 1 ');
  CurenAmountADOQuery.SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) ');
  CurenAmountADOQuery.Open;
  if not CurenAmountADOQuery.IsEmpty then
    begin
      CurenAmount := CurenAmountADOQuery.FieldByName('curAmout').AsCurrency;
      helpLabel1.Caption := '��ǰ�ۼ����۶�: ' + CurrToStr(CurenAmount) + 'Ԫ';
      helpLabel1.Font.Color := clBlue;
      helpLabel1.Visible := True;
    end;
  // �ͷ�ADOQuery����
  CurenAmountADOQuery.Close;
  CurenAmountADOQuery.Free;

  if (login.UserType = 'Ա��') then
    begin
      // �����Ա��,������ɾ�������ɱ���
      delButton.Enabled := False;
      // RepButton.Enabled := False;
    end;
end;

{����ˢ��}

procedure TdailyQueryFrame.refresh(keyValue: integer);
begin
  // DBGrid���ɼ�
  searchDBGrid.Visible := False;
  {//helpLabel1.Visible := True;
  //helpLabel2.Visible := True;}
  // ���¼���
  queryButtonClick(self);
  searchADOQuery.Locate('uniq_key', keyValue, []);
end;

{�ж�һ���ַ����Ƿ�Ϊ����}

function TdailyQueryFrame.isNum(S: string): Boolean;
//����SΪҪ�жϵ��ַ���,����true����ȷ
var
  i: integer;
begin
  Result := True;
  for i := 1 to length(s) do
    begin
      if not (s[i] in ['0'..'9', '-']) then
        //�ж��ַ���ÿ���ַ���s[i],�Ƿ�Ϊ"0"��'9"����"-"
        begin
          Result := False;
          break;
        end;
    end;
end;

{�ַ���ͷ��ȥ��}

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

{�ж�һ���ַ����Ƿ���ת�ͳ�����}

function TdailyQueryFrame.canToInt(s: string): boolean;
begin
  result := true;
  try
    strtoint(s);
  except result := false;
  end;
end;

{DBgrid Cell ����¼�, ͬ���趨ֵ���༭��}

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

{ɾ����ť}

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
      messagebox(handle, '����ѡ��Ҫɾ���ļ�¼��',
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
              SQL.Add(' delete from sales where uniq_key = :key ');
              Parameters.ParamByName('key').Value := strToInt(delKey);
              ExecSQL;
            end;
          // �ͷ���ʱADO����
          delADOQuery.Close;
          delADOQuery.Free;
          // ˢ�º�λ����һ��
          refresh(strToInt(delKeyPrior));
        end;
    end;
end;

{ѡ���б�ɫ}

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

{�������ɰ�ť}

procedure TdailyQueryFrame.RepButtonClick(Sender: TObject);
var
  fileInfo: string;
begin
  //queryButtonClick(self);
  fileInfo := '��Ŀ_' + FormatDateTime('yyyy-mm-dd', now()) + '.xls';
  exclToRep_func.ExportToExcel(searchDBGrid, groupADOQuery, fileInfo);
end;

end.
