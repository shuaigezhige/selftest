unit main;

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
  ExtCtrls,
  jpeg,
  ADODB, AppEvnts;
// 单项品种类型
type
  TFood = class
    id: string;
      name: string;
    price: Currency;
    tp: string;
    seq: integer;
  end;
  // 品种组合类型
type
  TFoodRecord = class
    Foods: array of TFood;
    amount: Currency;
    OrderNumber: integer;
    insertTime: TDateTime;
  end;

type
  TmainForm = class(TForm)
    MenuGroupBox: TGroupBox;
    orderButton: TButton;
    prodDefButton: TButton;
    othSaleButton: TButton;
    dailyQueryButton: TButton;
    hisQueryButton: TButton;
    workGroupBox: TGroupBox;
    datManageButton: TButton;
    exitButton: TButton;
    userManageButton: TButton;
    logoImage: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure userManageButtonClick(Sender: TObject);
    procedure exitButtonClick(Sender: TObject);
    procedure prodDefButtonClick(Sender: TObject);
    procedure orderButtonClick(Sender: TObject);
    procedure dailyQueryButtonClick(Sender: TObject);
    procedure hisQueryButtonClick(Sender: TObject);
    procedure othSaleButtonClick(Sender: TObject);
    procedure datManageButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    MaxNumber: integer;
    MaxKey: integer;
  end;

implementation

uses login,
  userEdit,
  order,
  otherSale,
  prodAdd,
  dailyQuery,
  hisQuery,
  dataManage;

{$R *.dfm}

{右上角关闭按钮}

procedure TmainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // 关闭窗口
  self.Close;
  // 退回到登陆画面
  userLogin.show;
  // 本窗口释放
  self.Release;
end;

{用户管理按钮}

procedure TmainForm.userManageButtonClick(Sender: TObject);
var
  i: integer;
begin
  // 清除所有的Frame
  logoImage.Visible := False;
  for i := 0 to self.ComponentCount - 1 do
    if (self.Components[i] is Tframe) then
      (self.Components[i] as Tframe).Free;

  // 建立相应的用户管理Frame
  with TuserEditFrame.Create(self) do
    begin
      Parent := self;
      // Frame显示位置
      Left := 131;
      Top := 16;
      // 定义Frame中ADOQuery的连接字串
      userEditADOQuery.Connection := DBConnection;
      // 刷新Frame并且记录定位到当前用户那一条
      refresh(login.UserName);
      // 用户组属性只可选不可编辑
      userGrpCmbBox.Style := csDropDownList;
      // 数据库插入更新判断用
      sqlModel.Visible := False;
      // 显示Frame
      Show;
    end;
end;

{退出按钮}

procedure TmainForm.exitButtonClick(Sender: TObject);
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

{品种管理按钮}

procedure TmainForm.prodDefButtonClick(Sender: TObject);
var
  i: integer;
begin
  // 清除所有的Frame
  logoImage.Visible := False;
  for i := 0 to self.ComponentCount - 1 do
    if (self.Components[i] is Tframe) then
      (self.Components[i] as Tframe).Free;

  // 建立相应的品种管理Frame
  with TprodAddFrame.Create(self) do
    begin
      // 显示位置
      Parent := self;
      Left := 131;
      Top := 16;
      prodADOQuery.Connection := DBConnection;
      // 初期化打开定位到第一行
      refresh('-1');
      // 品种类别属性只可选不可编辑
      prodTypeCmbBox.Style := csDropDownList;
      // 数据库插入更新判断用
      sqlModel.Visible := False;
      // 显示Frame
      Show;
    end;
end;

{当天查询}

procedure TmainForm.dailyQueryButtonClick(Sender: TObject);
var
  i: integer;
begin
  // 清除所有的Frame
  logoImage.Visible := False;
  for i := 0 to self.ComponentCount - 1 do
    if (self.Components[i] is Tframe) then
      (self.Components[i] as Tframe).Free;

  // 建立相应的品种管理Frame
  with TdailyQueryFrame.Create(self) do
    begin
      // 显示位置
      Parent := self;
      Left := 131;
      Top := 16;
      searchADOQuery.Connection := DBConnection;
      groupADOQuery.Connection := DBConnection;
      // 初期化打开定位到第一行
      refresh(-1);
      // 查询类别属性不可选不可编辑
      typeCmbBox.Style := csDropDownList;
      typeCmbBox.ItemIndex := 0;
      typeCmbBox.Enabled := false;
      // 显示Frame
      Show;
    end;
end;

{历史查询}

procedure TmainForm.hisQueryButtonClick(Sender: TObject);
var
  i: integer;
begin
  // 清除所有的Frame
  logoImage.Visible := False;
  for i := 0 to self.ComponentCount - 1 do
    if (self.Components[i] is Tframe) then
      (self.Components[i] as Tframe).Free;

  // 建立相应的品种管理Frame
  with ThisQueryFrame.Create(self) do
    begin
      // 显示位置
      Parent := self;
      Left := 131;
      Top := 16;
      searchADOQuery.Connection := DBConnection;
      groupADOQuery.Connection := DBConnection;
      // 设定开始结束2个时间控件的时间值
      startDateTime.Date := StrToDate(FormatdateTime('yyyy-mm-dd', now));
      startDateTime.Time := StrToTime('00:00:00');
      endDateTime.Date := StrToDate(FormatdateTime('yyyy-mm-dd', now));
      endDateTime.Time := StrToTime('23:59:59');
      // 初期化打开定位到第一行
      refresh(-1);
      // CheckBox默认选中"近3个月"
      recentRadBtn.Checked := true;
      hisMonthsRadBtn.Checked := False;
      // 查询类别属性不可选不可编辑
      typeCmbBox.Style := csDropDownList;
      typeCmbBox.ItemIndex := 0;
      typeCmbBox.Enabled := false;
      // 显示Frame
      Show;
    end;
end;

{顾客点餐}

procedure TmainForm.orderButtonClick(Sender: TObject);
var
  i: integer;
  OrderADOQuery: TADOQuery;
  PridId: string;
  ProdNm: string;
  ProdPrice: Currency;
  ProdType: string;
  TempFood: TFood;
  newOrderFrame: TOrderFrame;
  maxDate: TDateTime;
  CountADOQuery: TADOQuery;
  // 预发牌号
  NextNumber: integer;
  printerSwitch: string;
begin
  // 清除所有的Frame
  logoImage.Visible := False;
  for i := 0 to self.ComponentCount - 1 do
    if (self.Components[i] is Tframe) then
      (self.Components[i] as Tframe).Free;

  // 创建新的顾客点餐Frame
  newOrderFrame := TOrderFrame.Create(self);

  // 创建数据库操作对象
  CountADOQuery := TADOQuery.Create(self);
  // 定义ADOQuery连接数据库字串
  CountADOQuery.Connection := DBConnection;
  CountADOQuery.Close;
  CountADOQuery.SQL.Clear;
  // 检索当前最大的牌号和唯一主键号
  CountADOQuery.SQL.Add('select max(order_no) as mo, max(sale_date) as maxdate from sales where order_no <> -1');
  CountADOQuery.Open;
  // 如果不为空说明有历史数据,对今天准备发番的号码进行处理
  if not CountADOQuery.IsEmpty then
    begin
      maxDate := CountADOQuery.FieldByName('maxdate').AsDateTime;
      //如果当前日期不等于目前DB的最大日期,并且最大的号码不整除100
      if (int(strtodate(FormatdateTime('yyyy-mm-dd', now))) >
        int(strtodate(FormatdateTime('yyyy-mm-dd', maxDate)))) and
        (CountADOQuery.FieldByName('mo').AsInteger mod 100 <> 0) then
        // 则认为是新一天的开始,把上一次的号码补满到100,准备从1开始发号
        self.MaxNumber := ((CountADOQuery.FieldByName('mo').AsInteger
          div 100) + 1) * 100
      else
        // 如果当前日期等于或大于目前DB的最大日期,或者最大号能整除100，则取的目前最大号
        self.MaxNumber := CountADOQuery.FieldByName('mo').AsInteger;
      // 主键则一直使用目前最大的Key值,检索当前最大的唯一主键号
      CountADOQuery.SQL.Clear;
      CountADOQuery.SQL.Add('select max(uniq_key) as mk from sales');
      CountADOQuery.Open;
      self.MaxKey := CountADOQuery.FieldByName('mk').AsInteger;
    end;
  // 释放临时ADO对象
  CountADOQuery.Close;
  CountADOQuery.Free;

  // 顾客点餐Frame设置
  with newOrderFrame do
    begin
      //显示位置
      Parent := self;
      Left := 131;
      Top := 16;
      // 主类面条ListBox清空
      MainFoodLB.Clear;
      // 副料ListBox清空
      OptionFoodLB.Clear;
      // 单点状态框ListBox清空
      SingleOrderLB.Clear;
      // 订单状态框ListBox清空
      OrderLB.Clear;

      // 生成临时ADO控件,用于添加品种类型
      OrderADOQuery := TADOQuery.Create(self);
      OrderADOQuery.Connection := DBConnection;
      OrderADOQuery.Close;
      OrderADOQuery.SQL.Clear;
      // 检索品种Master表
      OrderADOQuery.SQL.Add(' SELECT PROD_ID,PROD_NM,PROD_PRICE, PROD_TYPE FROM PRODUCTS ORDER BY PROD_ID');
      OrderADOQuery.Open;

      while not OrderADOQuery.Eof do
        begin
          // 品种ID
          PridId := OrderADOQuery.FieldByName('PROD_ID').AsString;
          // 品种名称
          ProdNm := OrderADOQuery.FieldByName('PROD_NM').AsString;
          // 品种价格
          prodPrice := OrderADOQuery.FieldByName('PROD_PRICE').AsCurrency;
          // 品种类别
          prodType := OrderADOQuery.FieldByName('PROD_TYPE').AsString;
          // 创建销售对象保存每种品种的属性
          TempFood := TFood.Create();
          TempFood.id := PridId;
          TempFood.name := ProdNm;
          TempFood.price := prodPrice;
          TempFood.tp := ProdType;

          if (ProdType = '主类面条') then
            begin
              // 主类面条加到主类面条ListBox
              MainFoodLB.AddItem(TempFood.name + ' -- '
                + CurrToStr(TempFood.price) + '元', TempFood);
            end
          else
            if (ProdType = '可加副料') then
              begin
                // 可加副料加到可加副料ListBox
                OptionFoodLB.AddItem(TempFood.name + ' -- '
                  + CurrToStr(TempFood.price) + '元', TempFood);
              end
            else
              if (ProdType = '饮料烟酒') then
                begin
                  // 饮料烟酒加到可加副料ListBox
                  OptionFoodLB.AddItem(TempFood.name + ' -- '
                    + CurrToStr(TempFood.price) + '元', TempFood);
                end
              else
                if (ProdType = '面备注') then
                  begin
                    // 面备注加到面备注ListBox
                    noodWeightLB.AddItem(TempFood.name, TempFood);
                  end
                else
                  if (ProdType = '辣备注') then
                    begin
                      // 辣备注加到辣备注ListBox
                      pepperLB.AddItem(TempFood.name, TempFood);
                    end;
          // 循环处理下一条记录
          OrderADOQuery.Next;
        end;
      // 释放临时ADO对象
      OrderADOQuery.Close;
      OrderADOQuery.Free;
      Label10.Caption := '添加';
      Label10.Font.Color := clBlue;
      // 显示预发牌号
      NextNumber := self.MaxNumber + 1;
      Label4.Caption := '订单(预发' + IntToStr(GetPrintNo(NextNumber)) + '号)';
      SetWidth(MainFoodLB);
      SetWidth(OptionFoodLB);
      SetWidth(noodWeightLB);
      SetWidth(pepperLB);
      SetWidth(SingleOrderLB);
      printerswitch := userLogin.ReadIniFile(IniFileStr, 'printer','switch');
      if printerSwitch = 'on' then
         printeCheckBox.Checked := True
         else
         printeCheckBox.Checked := False;
      Show;
    end;
end;

{顺便卖卖,预留窗口,目前不使用}

procedure TmainForm.othSaleButtonClick(Sender: TObject);
var
  i: integer;
  OrderADOQuery: TADOQuery;
  PridId: string;
  ProdNm: string;
  ProdPrice: Currency;
  ProdType: string;
  TempFood: TFood;
begin
  // 清除所有的Frame
  logoImage.Visible := False;
  for i := 0 to self.ComponentCount - 1 do
    if (self.Components[i] is Tframe) then
      (self.Components[i] as Tframe).Free;
  // 建立相应的Frame
  with TadditionFrame.Create(self) do
    begin
      Parent := self;
      Left := 131;
      Top := 16;
      OrderADOQuery := TADOQuery.Create(self);
      OrderADOQuery.Connection := DBConnection;
      OrderADOQuery.Close;
      OrderADOQuery.SQL.Clear;
      // 检索Master表
      OrderADOQuery.SQL.Add(' SELECT PROD_ID,PROD_NM,PROD_PRICE, PROD_TYPE FROM PRODUCTS ORDER BY PROD_ID');
      OrderADOQuery.Open;
      // 饮料烟酒ListBox清空
      drinksLB.Clear;
      // 单点状态框ListBox清空
      SingleOrderLB.Clear;
      while not OrderADOQuery.Eof do
        begin
          // 品种ID
          PridId := OrderADOQuery.FieldByName('PROD_ID').AsString;
          // 品种名称
          ProdNm := OrderADOQuery.FieldByName('PROD_NM').AsString;
          // 品种价格
          prodPrice := OrderADOQuery.FieldByName('PROD_PRICE').AsCurrency;
          // 品种类别
          prodType := OrderADOQuery.FieldByName('PROD_TYPE').AsString;
          // 创建销售对象保存每种品种的属性
          TempFood := TFood.Create();
          TempFood.id := PridId;
          TempFood.name := ProdNm;
          TempFood.price := prodPrice;
          TempFood.tp := ProdType;

          if (ProdType = '饮料烟酒') then
            begin
              // 饮料烟酒加到饮料烟酒ListBox
              drinksLB.AddItem(TempFood.name + ' -- '
                + CurrToStr(TempFood.price) + '元', TempFood);
            end;
          // 循环处理下一条记录
          OrderADOQuery.Next;
        end;
      // 释放临时ADO对象
      OrderADOQuery.Close;
      OrderADOQuery.Free;
      Show;
    end;
end;

{数据管理按钮}

procedure TmainForm.datManageButtonClick(Sender: TObject);
var
  i: integer;
begin
  // 清除所有的Frame
  logoImage.Visible := False;
  for i := 0 to self.ComponentCount - 1 do
    if (self.Components[i] is Tframe) then
      (self.Components[i] as Tframe).Free;

  // 建立相应的数据管理Frame
  with TdataDelMan.Create(self) do
    begin
      // 显示位置
      Parent := self;
      Left := 131;
      Top := 16;
      // 显示Frame
      Show;
    end;
end;

end.
