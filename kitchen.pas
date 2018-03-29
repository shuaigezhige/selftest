unit kitchen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AppEvnts, DB, ADODB, Grids, DBGrids, StdCtrls, ExtCtrls, Inifiles;
type
  TdisplayForm = class(TForm)
    searchDBGrid: TDBGrid;
    searchADOQuery: TADOQuery;
    searchDataSource: TDataSource;
    ApplicationEvents1: TApplicationEvents;
    TimerCounter: TTimer;
    setButton: TButton;
    timeSet: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    freshCheckBox: TCheckBox;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure queryRefresh(Sender: TObject);
    procedure TimerCounterTimer(Sender: TObject);
    procedure searchDBGridDrawColumnCell(Sender: TObject;
      const Rect: TRect; DataCol: Integer; Column: TColumn;
      State: TGridDrawState);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure setButtonClick(Sender: TObject);
    procedure queryData(Sender: TObject);
    procedure queryForRefresh(Sender: TObject);
    function canToInt(s: string): boolean;
    function isNum(S: string): Boolean;
    function ReadIniFile(filePathStr: string; sectionStr: string; valueStr:
      string): string;
    function WriteIniFile(filePathStr: string; sectionStr: string; valueStr:
      string; setToStr: string): boolean;
    procedure freshCheckBoxClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  protected
    procedure hotykey(var msg: TMessage); message WM_HOTKEY;
    procedure WndProc(var Message: TMessage); override;
    procedure Delay(MSecs: Extended);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  displayForm: TdisplayForm;
  DBConnection: TADOConnection;
  IniFileStr: string;
  MyIni: TIniFile;
  id1, id2{, id3}: Integer;
implementation

{$R *.dfm}

procedure TdisplayForm.FormCreate(Sender: TObject);
var
  Refretime: string;
  DBConnStr: string;
  DataFile: string;
begin
  // ���ȫ���ȼ�С���̵�'+'
  id1 := GlobalAddAtom('hotkey1');
  RegisterHotKey(handle, id1, 0, 107);
  // ���ȫ���ȼ�С���̵�'-'
  id2 := GlobalAddAtom('hotkey2');
  RegisterHotKey(handle, id2, 0, 109);
  // ���ȫ���ȼ�С���̵�'-'
  //id3 := GlobalAddAtom('hotkey3');
  //RegisterHotKey(handle, id3, 0, 96);

  //�������ļ�����ˢ��ʱ����
  IniFileStr := GetCurrentDir + '\ini\My_config.ini';
  Refretime := ReadIniFile(IniFileStr, 'refreshtime', 'value');
  timeSet.Text := Refretime;

  // �ҵ����ݿ��ļ�����·��
  DataFile := GetCurrentDir + '\Database\DisplayData.mdb';
  //Label1.Caption := GetCurrentDir;
  // ��ʼ�����ݿ������ַ���
  DBConnStr := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + DataFile +
    ';Persist Security Info=False;Jet OLEDB:Database Password=shuaigezhige';
  // ��ʼ�����ݿ����Ӷ���
  DBConnection := TADOConnection.Create(self);
  // ȡ�����ӶԻ���
  DBConnection.LoginPrompt := False;
  DBConnection.Connected := False;
  DBConnection.ConnectionString := DBConnStr;
  DBConnection.KeepConnection := True;
  DBConnection.Connected := True;

  searchADOQuery.Connection := DBConnection;
  queryData(self);
  searchADOQuery.First;

  TimerCounter.Enabled := False;
  TimerCounter.Interval := strToInt(Refretime) * 1000;
  TimerCounter.Enabled := True;
end;

procedure TdisplayForm.queryForRefresh(Sender: TObject);
var
  pushADOQuery: TADOQuery;
begin
  pushADOQuery := TADOQuery.Create(self);
  pushADOQuery.Connection := DBConnection;
  with pushADOQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add(' select order_no as old_ordid from dissales where order_no > 0 ');
    SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) order by sale_date, order_no asc ');
    Open;
  end;
  // �ͷ�ADO���ݿ����
  pushADOQuery.Close;
  pushADOQuery.Free;
end;

{��ѯ����}

procedure TdisplayForm.queryData(Sender: TObject);
begin
  searchADOQuery.Close;
  searchADOQuery.SQL.Clear;
  searchADOQuery.SQL.Add(' select IIf((order_no mod 100) = 0, 100, (order_no mod 100)) as order_no, order_no as old_ordid, prod_nm, format(sale_date, "hh:nn") as s_date from dissales where order_no > 0 ');
  searchADOQuery.SQL.Append(' and year(sale_date) = year(now()) and month(sale_date) = month(now()) and day(sale_date) = day(now()) order by sale_date, order_no asc ');
  searchADOQuery.Open;
  searchDataSource.DataSet := searchADOQuery;
  searchDBGrid.DataSource := searchDataSource;
  //searchDBGrid.Visible := False;
  //searchDBGrid.Refresh;
  //searchDBGrid.Repaint;
  searchDBGrid.Visible := True;
end;

{DBGRIDˢ��}

procedure TdisplayForm.queryRefresh(Sender: TObject);
var
  curKey: integer;
  curKey2: String;
  curKey3: String;
begin
  curKey := searchADOQuery.FieldByName('old_ordid').AsInteger;
  curKey2 := searchADOQuery.FieldByName('prod_nm').AsString;
  curKey3 := searchADOQuery.FieldByName('s_date').AsString;
  queryData(self);
  searchADOQuery.Locate('old_ordid;prod_nm;s_date', VarArrayOf([curKey,curKey2,curKey3]), []);
end;

{��ʱ��}

procedure TdisplayForm.TimerCounterTimer(Sender: TObject);
begin
  SendMessage(searchDBGrid.Handle, WM_KEYDOWN, VK_DOWN, 0);
  searchDBGrid.SelectedRows.CurrentRowSelected := true;
  searchDBGrid.SetFocus;
  queryRefresh(self);
end;

{DBGRID��ͼ}

procedure TdisplayForm.searchDBGridDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  if gdSelected in State then
    with searchDBGrid do
    begin
      Canvas.Brush.Color := clYellow;
      Canvas.FillRect(Rect);
      Canvas.Font.Color := clRed;
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

{DBGRID������¹���}

procedure TdisplayForm.ApplicationEvents1Message(var Msg: tagMSG;
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

{��ȡIni�ļ�}

function TdisplayForm.ReadIniFile(filePathStr: string; sectionStr: string;
  valueStr: string): string;
var
  keyValue: string;
begin
  try
    MyIni := TiniFile.Create(filePathStr);
    keyValue := MyIni.ReadString(sectionStr, valueStr, '');
    MyIni.Free;
  except
    MyIni.Free;
    result := 'Error!';
    exit;
  end;
  result := keyValue;
end;

{д��Ini�ļ�}

function TdisplayForm.WriteIniFile(filePathStr: string; sectionStr: string;
  valueStr: string; setToStr: string): boolean;
begin
  try
    MyIni := TiniFile.Create(filePathStr);
    MyIni.WriteString(sectionStr, valueStr, setToStr);
    MyIni.Free;
  except
    MyIni.Free;
    result := False;
    exit;
  end;
  result := True;
end;

procedure TdisplayForm.setButtonClick(Sender: TObject);
var
  setStr: string;
begin
  setStr := timeSet.Text;
  // ������������Ϊ��
  if (trim(setStr) <> '') then
  begin
    // �ж�����������ǲ�������
    if not isNum(setStr) then
    begin
      // ���Ǵ���������򱨴�
      messagebox(handle, '������Ĳ������������������롣',
        '����',
        mb_ok);
      timeSet.SetFocus;
      exit;
    end
    else
    begin
      // ����Ƿ�Ϊ�Ϸ�����
      if not canToInt(setStr) then
      begin
        messagebox(handle, '������Ĳ������������������롣',
          '����',
          mb_ok);
        timeSet.SetFocus;
        exit;
      end;
    end;
    TimerCounter.Interval := strToInt(timeSet.Text) * 1000;
    WriteIniFile(IniFileStr, 'refreshtime', 'value', setStr);
    timeSet.Text := ReadIniFile(IniFileStr, 'refreshtime', 'value');
    if freshCheckBox.Checked then
    begin
      TimerCounter.Enabled := False;
      TimerCounter.Enabled := True;
    end;
    messagebox(handle, 'ˢ��Ƶ���Ѹ��£�', '���', mb_ok);
    searchDBGrid.SetFocus;
  end
  else
  begin
    messagebox(handle, '������Ĳ������������������롣',
      '����',
      mb_ok);
    exit;
  end;
end;

{�ж�һ���ַ����Ƿ�Ϊ����}

function TdisplayForm.isNum(S: string): Boolean;
//����SΪҪ�жϵ��ַ���,����true����ȷ
var
  i: integer;
begin
  Result := True;
  for i := 1 to length(s) do
  begin
    if not (s[i] in ['0'..'9']) then
      //�ж��ַ���ÿ���ַ���s[i],�Ƿ�Ϊ"0"��'9"
    begin
      Result := False;
      break;
    end;
  end;
end;

{�ж�һ���ַ����Ƿ���ת�ͳ�����}

function TdisplayForm.canToInt(s: string): boolean;
begin
  result := true;
  try
    strtoint(s);
  except result := false;
  end;
end;

{ˢ�¿���checkbox����¼�}

procedure TdisplayForm.freshCheckBoxClick(Sender: TObject);
begin
  if freshCheckBox.Checked then
  begin
    TimerCounter.Enabled := True;
    Label4.Caption := '������';
  end
  else
  begin
    TimerCounter.Enabled := False;
    Label4.Caption := '��ֹͣ';
  end
end;

{ȫ�ֿ�ݼ���'+'(107)���¹���һ�У�'-'(109)���Ϲ���һ��}

procedure TdisplayForm.hotykey(var msg: TMessage);
begin
  TimerCounter.Enabled := False;
  if (msg.LParamLo = 0) and (msg.LParamHi = 107) then
  begin
    SendMessage(searchDBGrid.Handle, WM_KEYDOWN, VK_DOWN, 0);
    searchDBGrid.SelectedRows.CurrentRowSelected := true;
    searchDBGrid.SetFocus;
  end;
  if (msg.LParamLo = 0) and (msg.LParamHi = 109) then
  begin
    SendMessage(searchDBGrid.Handle, WM_KEYDOWN, VK_UP, 0);
    searchDBGrid.SelectedRows.CurrentRowSelected := true;
    searchDBGrid.SetFocus;
  end;
  if (msg.LParamLo = 0) and (msg.LParamHi = 96) then
  begin
    if freshCheckBox.Checked then
    begin
      freshCheckBox.Checked := False;
      freshCheckBoxClick(self);
    end
    else
    begin
      freshCheckBox.Checked := True;
      freshCheckBoxClick(self);
    end
  end;
  Delay(2000);
  if freshCheckBox.Checked then
  begin
    TimerCounter.Enabled := True;
  end;
end;

{���ڹرգ�ע��ȫ���ȼ�}

procedure TdisplayForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  UnregisterHotKey(Handle, id1);
  //GlobalDeleteAtom(id1);
  UnregisterHotKey(Handle, id2);
  //GlobalDeleteAtom(id2);
  //UnregisterHotKey(Handle, id3);
end;

{��ʱ������MSecs��λΪ����(ǧ��֮1��)}

procedure TdisplayForm.Delay(MSecs: Extended);
var
  FirstTickCount, Now: Extended;
begin
  FirstTickCount := GetTickCount();
  repeat
    Application.ProcessMessages;
    Now := GetTickCount();
  until (Now - FirstTickCount >= MSecs) or (Now < FirstTickCount);
end;

{��Ϣ���պ���}

procedure TdisplayForm.WndProc(var Message: TMessage);
var
  Msg: Cardinal;
begin
  Msg := RegisterWindowMessage('wm_mymessage');
  if Message.Msg = Msg then
  begin
    //TimerCounter.Enabled := False;
    //Delay(500);
    //queryForRefresh(self);
    Delay(6000);
    queryRefresh(self);
    //Delay(1000);
    //queryRefresh(self);
    //Delay(1000);
    //queryRefresh(self);
    if freshCheckBox.Checked then
      begin
        TimerCounter.Enabled := True;
      end;
  end
  else
  begin
    inherited;
  end;
end;

end.

