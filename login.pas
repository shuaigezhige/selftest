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

{画面初始化}

procedure TuserLogin.FormCreate(Sender: TObject);
var
  ExeRoot: string;
begin
  // 检查是否注册
  CheckRegist();
  //ChDir(ExtractFilePath(Application.ExeName));
  //ExeRoot := GetCurrentDir;
  // 找到数据库文件所在路径
  DataFile := GetCurrentDir + '\Database\Database.mdb';
  // 初始化数据库连接字符串
  DBConnStr := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + DataFile +
    ';Persist Security Info=False;Jet OLEDB:Database Password=shuaigezhige';
  // 获得软键盘路径的字符串
  ExeRoot := GetCurrentDir + '\Windows KeyBoard\src\Osk_Mz.exe';
  //ExeRoot2 := GetCurrentDir + '\display.exe';
  // 调用软键盘程序
  ShellExecute(handle, 'open', Pchar(ExeRoot), nil, nil, SW_SHOWNORMAL);
  LogTimes := 0;
  //ShellExecute(handle, 'open', Pchar(ExeRoot2), nil, nil, SW_SHOWNORMAL);
  // 初始化数据库连接对象
  DBConnection := TADOConnection.Create(self);
  // 取消连接对话框
  DBConnection.LoginPrompt := False;
  DBConnection.Connected := False;
  DBConnection.ConnectionString := DBConnStr;
  DBConnection.KeepConnection := True;
  DBConnection.Connected := True;

  // 找到数据库文件所在路径
  disDataFile := GetCurrentDir + '\Database\DisplayData.mdb';
  //Label1.Caption := GetCurrentDir;
  // 初始化数据库连接字符串
  disDBConnStr := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + disDataFile +
    ';Persist Security Info=False;Jet OLEDB:Database Password=shuaigezhige';
  // 初始化数据库连接对象
  disDBConnection := TADOConnection.Create(self);
  // 取消连接对话框
  disDBConnection.LoginPrompt := False;
  disDBConnection.Connected := False;
  disDBConnection.ConnectionString := disDBConnStr;
  disDBConnection.KeepConnection := True;
  disDBConnection.Connected := True;
  //读取配置文件，设置打印开关
  IniFileStr := GetCurrentDir + '\ini\My_config.ini';
end;

{登录按钮}

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
  // 判断用户和密码是否均为空
  if (trim(userEdit.Text) <> '') and (trim(passEdit.Text) <> '') then
    begin
      // 创建临时ADOQuery控件
      LoginADOQuery := TADOQuery.Create(self);
      // 定义ADOQuery连接数据库字串
      LoginADOQuery.Connection := DBConnection;
      // 检索用户表的所有信息
      LoginADOQuery.Close;
      LoginADOQuery.SQL.Clear;
      LoginADOQuery.SQL.Add('select * from users where user_id="' +
        userEdit.Text + '" and user_pass="' + passEdit.Text + '" ');
      LoginADOQuery.Open;
      // 如果没有找到对应的记录
      if loginADOQuery.IsEmpty then
        begin
          LogTimes := LogTimes + 1;
          if messagebox(handle,
            '您填写的用户或密码有错误！是否重新输入？',
            '出错提示', mb_iconinformation + mb_okcancel) = IDcancel then
            application.Terminate;
          // 3此错误输入，程序自动退出
          if LogTimes >= 3 then
            begin
              messagebox(handle,
                '对不起，登录次数超过3次，程序自动关闭！',
                '非法登录', MB_ICONWARNING + mb_ok);
              application.Terminate;
            end;
        end
      else
        begin
          // 用户和密码正确，登录成功
          UserType := LoginADOQuery.FieldByName('user_grp').AsString;
          UserName := LoginADOQuery.FieldByName('user_id').AsString;
          LogTimes := 0;
          // 关闭并释放临时ADO控件
          LoginADOQuery.Close;
          LoginADOQuery.Free;
          // 隐藏登录窗口
          userLogin.Hide;

          // 创建主窗口对象
          mainForm := TmainForm.Create(self);
          // 最大牌号默认为0
          mainForm.MaxNumber := 0;
          // 最大主键Key默认为0
          mainForm.MaxKey := 0;
          // 获取当前时间
          nowtime := now();
          // 计算这个月前3个月的第一天的日期
          oldtime := monthAgoDec(nowtime, 3);

          // 创建临时ADO空间,用于转移3个月前的历史数据
          OptiDataADOQuery := TADOQuery.Create(self);
          // 定义ADOQuery连接数据库字串
          OptiDataADOQuery.Connection := DBConnection;
          OptiDataADOQuery.Close;
          OptiDataADOQuery.SQL.Clear;
          // 检索近期销售表中是否有3个月前的数据
          OptiDataADOQuery.SQL.Add('select count(*) as cnt from sales where sale_date < :oldtime');
          OptiDataADOQuery.Parameters.ParamByName('oldtime').Value := oldtime;
          OptiDataADOQuery.Open;
          tempCnt := OptiDataADOQuery.FieldByName('cnt').AsInteger;
          // 如果有3个月前的数据,把旧的数据登录到历史表中,并删除近期销售表中的旧数据
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
          // 关闭并释放数据库操作对象
          OptiDataADOQuery.Close;
          OptiDataADOQuery.Free;
          {
          // 创建数据库操作对象
          CountADOQuery := TADOQuery.Create(self);
          // 定义ADOQuery连接数据库字串
          CountADOQuery.Connection := DBConnection;
          CountADOQuery.Close;
          CountADOQuery.SQL.Clear;
          // 检索当前最大的牌号和唯一主键号
          CountADOQuery.SQL.Add('select max(order_no) as mo, max(uniq_key) as mk, max(sale_date) as maxdate from sales ');
          CountADOQuery.Open;
          // 如果不为空说明有历史数据,对今天准备发番的号码进行处理
          if not CountADOQuery.IsEmpty then
            begin
              maxDate := CountADOQuery.FieldByName('maxdate').AsDateTime;
              //如果当前日期大于目前DB的最大日期,并且最大的号码不整除100
              if (int(strtodate(FormatdateTime('yyyy-mm-dd', now)))
                >
                int(strtodate(FormatdateTime('yyyy-mm-dd', maxDate)))) and
                (CountADOQuery.FieldByName('mo').AsInteger mod 100 <> 0) then
                // 则认为是新一天的开始,把上一次的号码补满到100,准备从1开始发号
                mainForm.MaxNumber := ((CountADOQuery.FieldByName('mo').AsInteger
                  div 100) + 1) * 100
              else
                // 如果当前日期小于等于目前DB的最大日期,则认为是当天,取的目前最大号
                mainForm.MaxNumber := CountADOQuery.FieldByName('mo').AsInteger;
              // 主键则一直使用目前最大的Key值
              mainForm.MaxKey := CountADOQuery.FieldByName('mk').AsInteger;
            end;
          // 释放临时ADO对象
          CountADOQuery.Close;
          CountADOQuery.Free;
          }
          // 删除3个月前的厨房数据
          // 创建临时ADO空间,用于删除3个月前的厨房数据
          disDelADOQuery := TADOQuery.Create(self);
          // 定义ADOQuery连接数据库字串
          disDelADOQuery.Connection := disDBConnection;
          disDelADOQuery.Close;
          disDelADOQuery.SQL.Clear;
          // 检索近期销售表中是否有3个月前的数据
          disDelADOQuery.SQL.Add('select count(*) as cnt from dissales where sale_date < :oldtime');
          disDelADOQuery.Parameters.ParamByName('oldtime').Value := oldtime;
          disDelADOQuery.Open;
          tempCnt := disDelADOQuery.FieldByName('cnt').AsInteger;
          // 如果有3个月前的数据,把旧的数据登录到历史表中,并删除近期销售表中的旧数据
          if tempCnt > 0 then
            begin
              disDelADOQuery.Close;
              disDelADOQuery.SQL.Clear;
              disDelADOQuery.SQL.Add('delete from dissales where sale_date < :oldtime');
              disDelADOQuery.Parameters.ParamByName('oldtime').Value :=
                oldtime;
              disDelADOQuery.ExecSQL;
            end;
          // 关闭并释放数据库操作对象
          disDelADOQuery.Close;
          disDelADOQuery.Free;
          // 如果登录者是员工
          if (UserType = '员工') then
            with mainForm do
              begin
                // 只能只用点餐和当日查询功能
                orderButton.Visible := True;
                dailyQueryButton.Visible := True;
                exitButton.Visible := True;
                othSaleButton.Visible := False;
                prodDefButton.Visible := False;
                hisQueryButton.Visible := False;
                datManageButton.Visible := False;
                userManageButton.Visible := False;
              end;
          //显示主窗口
          ExeRoot2 := GetCurrentDir + '\display.exe';
          ShellExecute(handle, 'open', Pchar(ExeRoot2), nil, nil, SW_SHOWNORMAL);
          mainForm.ShowModal;
          // 密码框清空
          passEdit.Clear;
        end;
    end
  else
    // 用户和密码是否均为空
    messagebox(handle, '您没有正确填写用户或密码！', '提示', mb_iconinformation
      + mb_ok);
end;

{回车点击事件}

procedure TuserLogin.userEditKeyPress(Sender: TObject; var Key: Char);
begin
  // 输入后如果按下回车，默认进行登录
  if key = #13 then
    loginButtonClick(self);
end;

{回车点击事件}

procedure TuserLogin.passEditKeyPress(Sender: TObject; var Key: Char);
begin
  // 输入后如果按下回车，默认进行登录
  if key = #13 then
    loginButtonClick(self);
end;

{退出按钮}

procedure TuserLogin.exitButtonClick(Sender: TObject);
var
  hWndClose: HWnd;
  str: string;
begin
  // 软键盘窗口名
  str := 'On-Screen Keyboard';
  hWndClose := FindWindow(nil, PChar(str));
  if hWndClose <> 0 then
    //找到相应的程序名
    begin
      //关闭该运行程序
      SendMessage(hWndClose, WM_CLOSE, 0, 0);
    end;
  // 程序退出
  application.Terminate;
end;

{计算给定日期的1年内前3个月的1号的日期}

function TuserLogin.monthAgoDec(startdate: TDateTime; DecCnt: integer):
  TDateTime;
var
  paraDate: string;
  Syear, Smonth: integer;
  tempCnt: integer;
  tempRes: string;
begin
  // 参数时间格式化
  paraDate := formatdatetime('yyyy-mm-dd', startdate);
  // 获得年份字符串
  Syear := strtoint(copy(paraDate, 1, 4));
  // 获得月份字符串
  Smonth := strtoint(copy(paraDate, 6, 2));
  // 获得计算得出的之前的月份
  tempCnt := smonth - DecCnt + 1;
  // 如果计算的月份是个位数且大于0,格式补0
  if (tempCnt > 0) and (tempCnt < 10) then
    tempRes := IntToStr(Syear) + '-0' + IntToStr(tempCnt) + '-01' + ' 00:00:00'
  else
    // 如果计算的月份大于等于10,格式不补0
    if tempCnt >= 10 then
      tempRes := IntToStr(Syear) + '-' + IntToStr(tempCnt) + '-01' + ' 00:00:00'
    else
      // 如果计算的月份等于0,认为是去年的12月,年份减1
      if tempCnt = 0 then
        tempRes := IntToStr(Syear - 1) + '-12-01' + ' 00:00:00'
      else
        //如果计算的月份是负数,年份减1,且月份加12
        tempRes := IntToStr(Syear - 1) + '-' + IntToStr(12 + tempCnt) + '-01' +
          ' 00:00:00';
  // 返回结果
  result := strtodatetime(tempRes);
end;

{关闭按钮}

procedure TuserLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  exitButtonClick(self);
end;

{注册检查}

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
  //软件是否到注册期及是否允许继续使用的标志,当值为false是为允许使用
  dy := false;
  CPUID:= GetCPUID;
  //准备使用注册表
  registerTemp := TRegistry.Create();
  with registerTemp do
    begin
      //存放在此根下
      rootkey := HKEY_LOCAL_MACHINE;
      if OpenKey('software\microsoft\windows\Currentversion\AutoNood', true)
        then
        //新建一个目录,存放标志值.当然也可以存放在已存在的目录下
        begin
          //用gc_id的值作为标志,首先判断其存在否
          if valueexists('gc_id') then
            begin
              //读出标值
              re_id := readinteger('gc_id');
              //若标志值为0时,则说明已经注册.若不为0且值不到100,说明虽未注册
              //if (re_id <> 0) and (re_id <> 100) then
              if (re_id <> (CPUID[3] + CPUID[4]) mod 413) then
                //begin
                  {
                  //数未到,还可以使用.
                  //允许的标志值最大为100,每次加5,最多可以用20次
                  re_id := re_id + 5;
                  //将更新后的标志值写入注册表中
                  Writeinteger('gc_id', re_id);
                  leftCnt := 20 - (re_id div 5);
                  messagebox(handle, pchar('注册之前还可以使用' +
                    IntToStr(leftCnt) + '次。'), '未注册软件！', mb_ok);
                  }
                dy := true;
              //end;

            {if re_id = 100 then
              //如果到了100,则应注册
              dy := true;
            }
            end
          else
            begin
              //建立标志,并置初始标志值为5,可以任意值
              Writeinteger('gc_id', 5);
              messagebox(handle, pchar('未注册的版本，只能免费体验1次哦！'),
                '未注册软件！', mb_ok);
            end;
        end;
      if dy then
        begin
          //若dy的值为true,则应提示用户输入注册码,进行注册
          clickedok := inputquery('未注册软件！请输入注册码：', '',
            inputstr);
          if clickedok then
            begin
              get_id := GetCPUIDStr;
              //注册码为Terence_Zhang,当然也可以加入更复杂的算法
              if get_id = inputstr then
                begin
                  //若输入的注册码正确,则将标志值置为0,即已注册
                  writeinteger('gc_id', (CPUID[3] + CPUID[4]) mod 413);
                  closekey;
                  free;
                end
              else
                begin
                  //若输入的注册码错误,应作出提示并拒绝让其继续使用
                  application.MessageBox('注册码错误！请与作者联系！', '警告',
                    mb_ok);
                  closekey;
                  free;
                  //中止程序运行,拒绝让其继续使用
                  application.Terminate;
                  Halt;
                end;
            end
          else
            begin
              //若用户不输入注册码，也应作出提示并拒绝让其继续使用。
              application.MessageBox('请与作者联系，及时注册！', '警告',
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

{读取Ini文件}
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

{写入Ini文件}
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

