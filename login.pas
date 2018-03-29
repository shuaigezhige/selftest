unit login;

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
  ADODB,
  SHELLAPI,
  DB,
  Registry,
  Inifiles;
type
  TuserLogin = class(TForm)
    userEdit: TEdit;
    passEdit: TEdit;
    loginButton: TButton;
    exitButton: TButton;
    userLabel: TLabel;
    passLabel: TLabel;
    procedure loginButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure userEditKeyPress(Sender: TObject; var Key: Char);
    procedure passEditKeyPress(Sender: TObject; var Key: Char);
    procedure exitButtonClick(Sender: TObject);
    function monthAgoDec(startdate: TDateTime; DecCnt: integer): TDateTime;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function ReadIniFile(filePathStr: string; sectionStr: string; valueStr: string):string;
    function WriteIniFile(filePathStr: string; sectionStr: string; valueStr: string; setToStr: string):boolean;
  private
    { Private declarations }
    procedure CheckRegist();
    function GetCPUIDStr:String;
  public
    { Public declarations }
  end;

var
  userLogin: TuserLogin;
  LogTimes: Integer;
  UserType: string;
  DataFile: string;
  UserName: string;
  DBConnStr: string;
  DBConnection: TADOConnection;
  disDBConnection: TADOConnection;
  disDBConnStr: string;
  disDataFile: string;
  IniFileStr: string;
  MyIni: TIniFile;
implementation

uses main;

{$R *.dfm}
type
  TCPUID = array[1..4] of Longint;

function GetCPUID:TCPUID; assembler; register;
asm
  PUSH    EBX         {Save affected register}
  PUSH    EDI
  MOV     EDI,EAX     {@Resukt}
  MOV     EAX,1
  DW      $A20F       {CPUID Command}
  STOSD               {CPUID[1]}
  MOV     EAX,EBX
  STOSD               {CPUID[2]}
  MOV     EAX,ECX
  STOSD               {CPUID[3]}
  MOV     EAX,EDX
  STOSD               {CPUID[4]}
  POP     EDI         {Restore registers}
  POP     EBX
end;

{�����ʼ��}

procedure TuserLogin.FormCreate(Sender: TObject);
var
  ExeRoot: string;
begin
  // ����Ƿ�ע��
  CheckRegist();
  //ChDir(ExtractFilePath(Application.ExeName));
  //ExeRoot := GetCurrentDir;
  // �ҵ����ݿ��ļ�����·��
  DataFile := GetCurrentDir + '\Database\Database.mdb';
  // ��ʼ�����ݿ������ַ���
  DBConnStr := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + DataFile +
    ';Persist Security Info=False;Jet OLEDB:Database Password=shuaigezhige';
  // ��������·�����ַ���
  ExeRoot := GetCurrentDir + '\Windows KeyBoard\src\Osk_Mz.exe';
  //ExeRoot2 := GetCurrentDir + '\display.exe';
  // ��������̳���
  ShellExecute(handle, 'open', Pchar(ExeRoot), nil, nil, SW_SHOWNORMAL);
  LogTimes := 0;
  //ShellExecute(handle, 'open', Pchar(ExeRoot2), nil, nil, SW_SHOWNORMAL);
  // ��ʼ�����ݿ����Ӷ���
  DBConnection := TADOConnection.Create(self);
  // ȡ�����ӶԻ���
  DBConnection.LoginPrompt := False;
  DBConnection.Connected := False;
  DBConnection.ConnectionString := DBConnStr;
  DBConnection.KeepConnection := True;
  DBConnection.Connected := True;

  // �ҵ����ݿ��ļ�����·��
  disDataFile := GetCurrentDir + '\Database\DisplayData.mdb';
  //Label1.Caption := GetCurrentDir;
  // ��ʼ�����ݿ������ַ���
  disDBConnStr := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + disDataFile +
    ';Persist Security Info=False;Jet OLEDB:Database Password=shuaigezhige';
  // ��ʼ�����ݿ����Ӷ���
  disDBConnection := TADOConnection.Create(self);
  // ȡ�����ӶԻ���
  disDBConnection.LoginPrompt := False;
  disDBConnection.Connected := False;
  disDBConnection.ConnectionString := disDBConnStr;
  disDBConnection.KeepConnection := True;
  disDBConnection.Connected := True;
  //��ȡ�����ļ������ô�ӡ����
  IniFileStr := GetCurrentDir + '\ini\My_config.ini';
end;

{��¼��ť}

procedure TuserLogin.loginButtonClick(Sender: TObject);
var
  LoginADOQuery: TADOQuery;
  //CountADOQuery: TADOQuery;
  OptiDataADOQuery: TADOQuery;
  disDelADOQuery: TADOQuery;
  tempCnt: Integer;
  mainForm: TmainForm;
  //maxDate: TDateTime;
  nowtime: TDateTime;
  oldtime: TDateTime;
  ExeRoot2: string;
begin
  // �ж��û��������Ƿ��Ϊ��
  if (trim(userEdit.Text) <> '') and (trim(passEdit.Text) <> '') then
    begin
      // ������ʱADOQuery�ؼ�
      LoginADOQuery := TADOQuery.Create(self);
      // ����ADOQuery�������ݿ��ִ�
      LoginADOQuery.Connection := DBConnection;
      // �����û����������Ϣ
      LoginADOQuery.Close;
      LoginADOQuery.SQL.Clear;
      LoginADOQuery.SQL.Add('select * from users where user_id="' +
        userEdit.Text + '" and user_pass="' + passEdit.Text + '" ');
      LoginADOQuery.Open;
      // ���û���ҵ���Ӧ�ļ�¼
      if loginADOQuery.IsEmpty then
        begin
          LogTimes := LogTimes + 1;
          if messagebox(handle,
            '����д���û��������д����Ƿ��������룿',
            '������ʾ', mb_iconinformation + mb_okcancel) = IDcancel then
            application.Terminate;
          // 3�˴������룬�����Զ��˳�
          if LogTimes >= 3 then
            begin
              messagebox(handle,
                '�Բ��𣬵�¼��������3�Σ������Զ��رգ�',
                '�Ƿ���¼', MB_ICONWARNING + mb_ok);
              application.Terminate;
            end;
        end
      else
        begin
          // �û���������ȷ����¼�ɹ�
          UserType := LoginADOQuery.FieldByName('user_grp').AsString;
          UserName := LoginADOQuery.FieldByName('user_id').AsString;
          LogTimes := 0;
          // �رղ��ͷ���ʱADO�ؼ�
          LoginADOQuery.Close;
          LoginADOQuery.Free;
          // ���ص�¼����
          userLogin.Hide;

          // ���������ڶ���
          mainForm := TmainForm.Create(self);
          // ����ƺ�Ĭ��Ϊ0
          mainForm.MaxNumber := 0;
          // �������KeyĬ��Ϊ0
          mainForm.MaxKey := 0;
          // ��ȡ��ǰʱ��
          nowtime := now();
          // ���������ǰ3���µĵ�һ�������
          oldtime := monthAgoDec(nowtime, 3);

          // ������ʱADO�ռ�,����ת��3����ǰ����ʷ����
          OptiDataADOQuery := TADOQuery.Create(self);
          // ����ADOQuery�������ݿ��ִ�
          OptiDataADOQuery.Connection := DBConnection;
          OptiDataADOQuery.Close;
          OptiDataADOQuery.SQL.Clear;
          // �����������۱����Ƿ���3����ǰ������
          OptiDataADOQuery.SQL.Add('select count(*) as cnt from sales where sale_date < :oldtime');
          OptiDataADOQuery.Parameters.ParamByName('oldtime').Value := oldtime;
          OptiDataADOQuery.Open;
          tempCnt := OptiDataADOQuery.FieldByName('cnt').AsInteger;
          // �����3����ǰ������,�Ѿɵ����ݵ�¼����ʷ����,��ɾ���������۱��еľ�����
          if tempCnt > 0 then
            begin
              OptiDataADOQuery.Close;
              OptiDataADOQuery.SQL.Clear;
              OptiDataADOQuery.SQL.Add('insert into his_sales select * from sales where sale_date < :oldtime');
              OptiDataADOQuery.Parameters.ParamByName('oldtime').Value :=
                oldtime;
              OptiDataADOQuery.ExecSQL;
              OptiDataADOQuery.Close;
              OptiDataADOQuery.SQL.Clear;
              OptiDataADOQuery.SQL.Add('delete from sales where sale_date < :oldtime');
              OptiDataADOQuery.Parameters.ParamByName('oldtime').Value :=
                oldtime;
              OptiDataADOQuery.ExecSQL;
            end;
          // �رղ��ͷ����ݿ��������
          OptiDataADOQuery.Close;
          OptiDataADOQuery.Free;
          {
          // �������ݿ��������
          CountADOQuery := TADOQuery.Create(self);
          // ����ADOQuery�������ݿ��ִ�
          CountADOQuery.Connection := DBConnection;
          CountADOQuery.Close;
          CountADOQuery.SQL.Clear;
          // ������ǰ�����ƺź�Ψһ������
          CountADOQuery.SQL.Add('select max(order_no) as mo, max(uniq_key) as mk, max(sale_date) as maxdate from sales ');
          CountADOQuery.Open;
          // �����Ϊ��˵������ʷ����,�Խ���׼�������ĺ�����д���
          if not CountADOQuery.IsEmpty then
            begin
              maxDate := CountADOQuery.FieldByName('maxdate').AsDateTime;
              //�����ǰ���ڴ���ĿǰDB���������,�������ĺ��벻����100
              if (int(strtodate(FormatdateTime('yyyy-mm-dd', now)))
                >
                int(strtodate(FormatdateTime('yyyy-mm-dd', maxDate)))) and
                (CountADOQuery.FieldByName('mo').AsInteger mod 100 <> 0) then
                // ����Ϊ����һ��Ŀ�ʼ,����һ�εĺ��벹����100,׼����1��ʼ����
                mainForm.MaxNumber := ((CountADOQuery.FieldByName('mo').AsInteger
                  div 100) + 1) * 100
              else
                // �����ǰ����С�ڵ���ĿǰDB���������,����Ϊ�ǵ���,ȡ��Ŀǰ����
                mainForm.MaxNumber := CountADOQuery.FieldByName('mo').AsInteger;
              // ������һֱʹ��Ŀǰ����Keyֵ
              mainForm.MaxKey := CountADOQuery.FieldByName('mk').AsInteger;
            end;
          // �ͷ���ʱADO����
          CountADOQuery.Close;
          CountADOQuery.Free;
          }
          // ɾ��3����ǰ�ĳ�������
          // ������ʱADO�ռ�,����ɾ��3����ǰ�ĳ�������
          disDelADOQuery := TADOQuery.Create(self);
          // ����ADOQuery�������ݿ��ִ�
          disDelADOQuery.Connection := disDBConnection;
          disDelADOQuery.Close;
          disDelADOQuery.SQL.Clear;
          // �����������۱����Ƿ���3����ǰ������
          disDelADOQuery.SQL.Add('select count(*) as cnt from dissales where sale_date < :oldtime');
          disDelADOQuery.Parameters.ParamByName('oldtime').Value := oldtime;
          disDelADOQuery.Open;
          tempCnt := disDelADOQuery.FieldByName('cnt').AsInteger;
          // �����3����ǰ������,�Ѿɵ����ݵ�¼����ʷ����,��ɾ���������۱��еľ�����
          if tempCnt > 0 then
            begin
              disDelADOQuery.Close;
              disDelADOQuery.SQL.Clear;
              disDelADOQuery.SQL.Add('delete from dissales where sale_date < :oldtime');
              disDelADOQuery.Parameters.ParamByName('oldtime').Value :=
                oldtime;
              disDelADOQuery.ExecSQL;
            end;
          // �رղ��ͷ����ݿ��������
          disDelADOQuery.Close;
          disDelADOQuery.Free;
          // �����¼����Ա��
          if (UserType = 'Ա��') then
            with mainForm do
              begin
                // ֻ��ֻ�õ�ͺ͵��ղ�ѯ����
                orderButton.Visible := True;
                dailyQueryButton.Visible := True;
                exitButton.Visible := True;
                othSaleButton.Visible := False;
                prodDefButton.Visible := False;
                hisQueryButton.Visible := False;
                datManageButton.Visible := False;
                userManageButton.Visible := False;
              end;
          //��ʾ������
          ExeRoot2 := GetCurrentDir + '\display.exe';
          ShellExecute(handle, 'open', Pchar(ExeRoot2), nil, nil, SW_SHOWNORMAL);
          mainForm.ShowModal;
          // ��������
          passEdit.Clear;
        end;
    end
  else
    // �û��������Ƿ��Ϊ��
    messagebox(handle, '��û����ȷ��д�û������룡', '��ʾ', mb_iconinformation
      + mb_ok);
end;

{�س�����¼�}

procedure TuserLogin.userEditKeyPress(Sender: TObject; var Key: Char);
begin
  // �����������»س���Ĭ�Ͻ��е�¼
  if key = #13 then
    loginButtonClick(self);
end;

{�س�����¼�}

procedure TuserLogin.passEditKeyPress(Sender: TObject; var Key: Char);
begin
  // �����������»س���Ĭ�Ͻ��е�¼
  if key = #13 then
    loginButtonClick(self);
end;

{�˳���ť}

procedure TuserLogin.exitButtonClick(Sender: TObject);
var
  hWndClose: HWnd;
  str: string;
begin
  // ����̴�����
  str := 'On-Screen Keyboard';
  hWndClose := FindWindow(nil, PChar(str));
  if hWndClose <> 0 then
    //�ҵ���Ӧ�ĳ�����
    begin
      //�رո����г���
      SendMessage(hWndClose, WM_CLOSE, 0, 0);
    end;
  // �����˳�
  application.Terminate;
end;

{����������ڵ�1����ǰ3���µ�1�ŵ�����}

function TuserLogin.monthAgoDec(startdate: TDateTime; DecCnt: integer):
  TDateTime;
var
  paraDate: string;
  Syear, Smonth: integer;
  tempCnt: integer;
  tempRes: string;
begin
  // ����ʱ���ʽ��
  paraDate := formatdatetime('yyyy-mm-dd', startdate);
  // �������ַ���
  Syear := strtoint(copy(paraDate, 1, 4));
  // ����·��ַ���
  Smonth := strtoint(copy(paraDate, 6, 2));
  // ��ü���ó���֮ǰ���·�
  tempCnt := smonth - DecCnt + 1;
  // ���������·��Ǹ�λ���Ҵ���0,��ʽ��0
  if (tempCnt > 0) and (tempCnt < 10) then
    tempRes := IntToStr(Syear) + '-0' + IntToStr(tempCnt) + '-01' + ' 00:00:00'
  else
    // ���������·ݴ��ڵ���10,��ʽ����0
    if tempCnt >= 10 then
      tempRes := IntToStr(Syear) + '-' + IntToStr(tempCnt) + '-01' + ' 00:00:00'
    else
      // ���������·ݵ���0,��Ϊ��ȥ���12��,��ݼ�1
      if tempCnt = 0 then
        tempRes := IntToStr(Syear - 1) + '-12-01' + ' 00:00:00'
      else
        //���������·��Ǹ���,��ݼ�1,���·ݼ�12
        tempRes := IntToStr(Syear - 1) + '-' + IntToStr(12 + tempCnt) + '-01' +
          ' 00:00:00';
  // ���ؽ��
  result := strtodatetime(tempRes);
end;

{�رհ�ť}

procedure TuserLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  exitButtonClick(self);
end;

{ע����}

procedure TuserLogin.CheckRegist();
var
  re_id: integer;
  registerTemp: Tregistry;
  inputstr: string;
  get_id: string;
  dy, clickedok: boolean;
  //leftCnt: integer;
  CPUID:TCPUID;
begin
  //����Ƿ�ע���ڼ��Ƿ��������ʹ�õı�־,��ֵΪfalse��Ϊ����ʹ��
  dy := false;
  CPUID:= GetCPUID;
  //׼��ʹ��ע���
  registerTemp := TRegistry.Create();
  with registerTemp do
    begin
      //����ڴ˸���
      rootkey := HKEY_LOCAL_MACHINE;
      if OpenKey('software\microsoft\windows\Currentversion\AutoNood', true)
        then
        //�½�һ��Ŀ¼,��ű�־ֵ.��ȻҲ���Դ�����Ѵ��ڵ�Ŀ¼��
        begin
          //��gc_id��ֵ��Ϊ��־,�����ж�����ڷ�
          if valueexists('gc_id') then
            begin
              //������ֵ
              re_id := readinteger('gc_id');
              //����־ֵΪ0ʱ,��˵���Ѿ�ע��.����Ϊ0��ֵ����100,˵����δע��
              //if (re_id <> 0) and (re_id <> 100) then
              if (re_id <> (CPUID[3] + CPUID[4]) mod 413) then
                //begin
                  {
                  //��δ��,������ʹ��.
                  //����ı�־ֵ���Ϊ100,ÿ�μ�5,��������20��
                  re_id := re_id + 5;
                  //�����º�ı�־ֵд��ע�����
                  Writeinteger('gc_id', re_id);
                  leftCnt := 20 - (re_id div 5);
                  messagebox(handle, pchar('ע��֮ǰ������ʹ��' +
                    IntToStr(leftCnt) + '�Ρ�'), 'δע�������', mb_ok);
                  }
                dy := true;
              //end;

            {if re_id = 100 then
              //�������100,��Ӧע��
              dy := true;
            }
            end
          else
            begin
              //������־,���ó�ʼ��־ֵΪ5,��������ֵ
              Writeinteger('gc_id', 5);
              messagebox(handle, pchar('δע��İ汾��ֻ���������1��Ŷ��'),
                'δע�������', mb_ok);
            end;
        end;
      if dy then
        begin
          //��dy��ֵΪtrue,��Ӧ��ʾ�û�����ע����,����ע��
          clickedok := inputquery('δע�������������ע���룺', '',
            inputstr);
          if clickedok then
            begin
              get_id := GetCPUIDStr;
              //ע����ΪTerence_Zhang,��ȻҲ���Լ�������ӵ��㷨
              if get_id = inputstr then
                begin
                  //�������ע������ȷ,�򽫱�־ֵ��Ϊ0,����ע��
                  writeinteger('gc_id', (CPUID[3] + CPUID[4]) mod 413);
                  closekey;
                  free;
                end
              else
                begin
                  //�������ע�������,Ӧ������ʾ���ܾ��������ʹ��
                  application.MessageBox('ע�����������������ϵ��', '����',
                    mb_ok);
                  closekey;
                  free;
                  //��ֹ��������,�ܾ��������ʹ��
                  application.Terminate;
                  Halt;
                end;
            end
          else
            begin
              //���û�������ע���룬ҲӦ������ʾ���ܾ��������ʹ�á�
              application.MessageBox('����������ϵ����ʱע�ᣡ', '����',
                mb_ok);
              closekey;
              free;
              application.Terminate;
              Halt;
            end;
        end;
    end;
end;

function TuserLogin.GetCPUIDStr:String;
var
  CPUID:TCPUID;
begin
  CPUID:= GetCPUID;
  Result:= 'Terence_Zhang_' + IntToHex(CPUID[3],8) + IntToHex(CPUID[4],8);
end;

{��ȡIni�ļ�}
function TuserLogin.ReadIniFile(filePathStr: string; sectionStr: string; valueStr:string):string;
var
keyValue: string;
begin
  try
    MyIni := TiniFile.Create(filePathStr);
    keyValue := MyIni.ReadString(sectionStr ,valueStr,'');
    MyIni.Free;
  except
    MyIni.Free;
    result := '';
    exit;
  end;
    result := keyValue;
end;

{д��Ini�ļ�}
function TuserLogin.WriteIniFile(filePathStr: string; sectionStr: string; valueStr: string; setToStr: string):boolean;
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

end.

