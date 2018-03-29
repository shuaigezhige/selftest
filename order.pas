unit order;

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
  CheckLst,
  Grids,
  ADODB,
  main,
  Printers,
  AppEvnts;
type
  TOrderFrame = class(TFrame)
    Label2: TLabel;
    Label3: TLabel;
    PrintBtn: TButton;
    Label4: TLabel;
    Label1: TLabel;
    MainFoodLB: TListBox;
    OptionFoodLB: TListBox;
    SingleOrderLB: TListBox;
    OrderLB: TListBox;
    AddBtn: TButton;
    Label5: TLabel;
    SinglePriceLabel: TLabel;
    Label6: TLabel;
    TotalAmountLbl: TLabel;
    OrderNumberEdit: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    ClearSingleBtn: TButton;
    noodWeightLB: TListBox;
    pepperLB: TListBox;
    Label9: TLabel;
    editButton: TButton;
    Label10: TLabel;
    HelpLabel1: TLabel;
    HelpLabel2: TLabel;
    ApplicationEvents1: TApplicationEvents;
    printeCheckBox: TCheckBox;
    procedure MainFoodLBClick(Sender: TObject);
    procedure addFoodToSingleLB(Food: TFood);
    procedure OptionFoodLBClick(Sender: TObject);
    procedure SingleOrderLBDblClick(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure OrderLBDblClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure displayorders(Sender: TObject);
    procedure OrderNumberEditKeyPress(Sender: TObject; var Key: Char);
    procedure ClearSingleBtnClick(Sender: TObject);
    procedure OrderLBClick(Sender: TObject);
    procedure editButtonClick(Sender: TObject);
    procedure noodWeightLBClick(Sender: TObject);
    procedure pepperLBClick(Sender: TObject);
    procedure SetWidth(Sender: TListBox);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure printeCheckBoxClick(Sender: TObject);
    procedure sendMms(Sender: TObject);
  private
    { Private declarations }
    function GetMaxNumber(MainForm: TmainForm): integer;
    function GetMaxSeq(MainForm: TmainForm): integer;
    procedure DoPrint();
  public
    { Public declarations }
    ModifiedFoodOrderNum: integer;
    ModifiedFoodRowNum: integer;
    modifyFoodDateTime: TDateTime;
    modifyHasMainFlg: boolean;
    function GetPrintNo(OldNumber: integer): integer;
  end;

implementation
uses login;
{$R *.dfm}
{鼠标左键点击主类面条ListBox}

procedure TOrderFrame.MainFoodLBClick(Sender: TObject);
var
  i: Integer;
begin
  // 遍历ListBox中条目
  for i := 0 to MainFoodLB.Count - 1 do
  begin
    // 如果当前条目选中
    if MainFoodLB.Selected[i] then
    begin
      // 将选中的条目加到单点状态栏中
      addFoodToSingleLB(MainFoodLB.Items.Objects[i] as TFood);
      break;
    end;
  end;
end;

{单点状态栏添加项目}

procedure TOrderFrame.addFoodToSingleLB(Food: TFood);
var
  i: Integer;
  TempFood: TFood;
  MainFood: TFood;
  OptionFoodArr: array of TFood;
  DrinkArr: array of TFood;
  TotalPrice: Currency;
  NFood: TFood;
  mianComment: TFood;
  pepperComment: TFood;
begin
  MainFood := nil;
  mianComment := nil;
  pepperComment := nil;
  // 遍历单点状态栏,查看当前已存在的品种类型并整理保存
  for i := 0 to SingleOrderLB.Count - 1 do
  begin
    // 创建临时Food对象,作为处理对象
    TempFood := SingleOrderLB.Items.Objects[i] as TFood;
    // 创建NFood对象,保存临时Food对象的属性值
    NFood := TFood.Create();
    NFood.id := TempFood.id;
    NFood.name := TempFood.name;
    NFood.price := TempFood.price;
    NFood.tp := TempFood.tp;
    // 如果当前遍历的对象是主类面条的实例
    if (TempFood.tp = '主类面条') then
    begin
      // 主类面赋值为当前对象
      MainFood := NFood;
    end
      // 否则是可加副料的实例
    else if (TempFood.tp <> '面备注') and (TempFood.tp <> '辣备注') and
      (TempFood.tp <> '饮料烟酒') then
    begin
      // 可加副料数组容量加1
      SetLength(OptionFoodArr, length(OptionFoodArr) + 1);
      // 将当前的副料加到副料数组的末尾
      OptionFoodArr[length(OptionFoodArr) - 1] := NFood;
    end
    else if (TempFood.tp = '饮料烟酒') then
    begin
      // 饮料烟酒数组容量加1
      SetLength(DrinkArr, length(DrinkArr) + 1);
      // 将当前的饮料烟酒加到饮料烟酒数组的末尾
      DrinkArr[length(DrinkArr) - 1] := NFood;
    end
    else if (TempFood.tp = '面备注') then
    begin
      mianComment := TFood.Create();
      mianComment.id := NFood.id;
      mianComment.name := NFood.name;
      mianComment.price := NFood.price;
      mianComment.tp := NFood.tp;
    end
    else if (TempFood.tp = '辣备注') then
    begin
      pepperComment := TFood.Create();
      pepperComment.id := NFood.id;
      pepperComment.name := NFood.name;
      pepperComment.price := NFood.price;
      pepperComment.tp := NFood.tp;
    end;

  end;
  // 单点状态栏清空其内容,并将总价设为0
  SingleOrderLB.Clear;
  TotalPrice := 0;
  // 如果传递的参数是主类面条
  if (Food.tp = '主类面条') then
  begin
    // 单点状态栏中增加该项目
    SingleOrderLB.AddItem(Food.name + ' -- ' + CurrToStr(Food.price) + '元',
      Food);
    // 总价更新
    TotalPrice := TotalPrice + Food.price;
    // 再把之前保存的副料的数组的价格加到总价中,并显示
    for i := 0 to Length(OptionFoodArr) - 1 do
    begin
      SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
        CurrToStr(OptionFoodArr[i].price) + '元', OptionFoodArr[i]);
      TotalPrice := TotalPrice + OptionFoodArr[i].price;
    end;

    // 如果有面备注,显示面备注
    if mianComment <> nil then
      SingleOrderLB.AddItem(mianComment.name, mianComment);
    // 如果有辣备注,显示面备注
    if pepperComment <> nil then
      SingleOrderLB.AddItem(pepperComment.name, pepperComment);

    // 把之前保存的饮料烟酒的数组的价格加到总价中,并显示
    for i := 0 to Length(DrinkArr) - 1 do
    begin
      SingleOrderLB.AddItem(DrinkArr[i].name + ' -- ' +
        CurrToStr(DrinkArr[i].price) + '元', DrinkArr[i]);
      TotalPrice := TotalPrice + DrinkArr[i].price;
    end;
  end
  else if (Food.tp = '可加副料') then
  begin
    // 如果当前记录中有主类面
    if MainFood <> nil then
    begin
      SingleOrderLB.AddItem(MainFood.name + ' -- ' +
        CurrToStr(MainFood.price) + '元', MainFood);
      // 把主类面的价格也加上
      TotalPrice := TotalPrice + MainFood.price;
    end;
    // 把之前保存的副料的数组的价格加到总价中,并显示
    for i := 0 to Length(OptionFoodArr) - 1 do
    begin
      SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
        CurrToStr(OptionFoodArr[i].price) + '元', OptionFoodArr[i]);
      TotalPrice := TotalPrice + OptionFoodArr[i].price;
    end;

    // 再把加进来的副料和价格加上
    SingleOrderLB.AddItem(Food.name + ' -- ' + CurrToStr(Food.price) +
      '元',
      Food);
    TotalPrice := TotalPrice + Food.price;

    // 如果有面备注,显示面备注
    if mianComment <> nil then
      SingleOrderLB.AddItem(mianComment.name, mianComment);
    // 如果有辣备注,显示面备注
    if pepperComment <> nil then
      SingleOrderLB.AddItem(pepperComment.name, pepperComment);

    // 把之前保存的饮料烟酒的数组的价格加到总价中,并显示
    for i := 0 to Length(DrinkArr) - 1 do
    begin
      SingleOrderLB.AddItem(DrinkArr[i].name + ' -- ' +
        CurrToStr(DrinkArr[i].price) + '元', DrinkArr[i]);
      TotalPrice := TotalPrice + DrinkArr[i].price;
    end;

  end
  else if (Food.tp = '饮料烟酒') then
  begin
    // 如果当前记录中有主类面
    if MainFood <> nil then
    begin
      SingleOrderLB.AddItem(MainFood.name + ' -- ' +
        CurrToStr(MainFood.price) + '元', MainFood);
      // 把主类面的价格也加上
      TotalPrice := TotalPrice + MainFood.price;
    end;
    // 把之前保存的副料的数组的价格加到总价中,并显示
    for i := 0 to Length(OptionFoodArr) - 1 do
    begin
      SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
        CurrToStr(OptionFoodArr[i].price) + '元', OptionFoodArr[i]);
      TotalPrice := TotalPrice + OptionFoodArr[i].price;
    end;

    // 如果有面备注,显示面备注
    if mianComment <> nil then
      SingleOrderLB.AddItem(mianComment.name, mianComment);
    // 如果有辣备注,显示面备注
    if pepperComment <> nil then
      SingleOrderLB.AddItem(pepperComment.name, pepperComment);

    // 把之前保存的饮料烟酒的数组的价格加到总价中,并显示
    for i := 0 to Length(DrinkArr) - 1 do
    begin
      SingleOrderLB.AddItem(DrinkArr[i].name + ' -- ' +
        CurrToStr(DrinkArr[i].price) + '元', DrinkArr[i]);
      TotalPrice := TotalPrice + DrinkArr[i].price;
    end;

    // 再把加进来的饮料烟酒和价格加上
    SingleOrderLB.AddItem(Food.name + ' -- ' + CurrToStr(Food.price) +
      '元',
      Food);
    TotalPrice := TotalPrice + Food.price;
  end
  else if (Food.tp = '面备注') then
  begin
    // 如果当前记录中有主类面
    if MainFood <> nil then
    begin
      SingleOrderLB.AddItem(MainFood.name + ' -- ' +
        CurrToStr(MainFood.price) + '元', MainFood);
      // 把主类面的价格也加上
      TotalPrice := TotalPrice + MainFood.price;
      // 把之前的可加副料加上
      for i := 0 to Length(OptionFoodArr) - 1 do
      begin
        SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
          CurrToStr(OptionFoodArr[i].price) + '元',
          OptionFoodArr[i]);
        TotalPrice := TotalPrice + OptionFoodArr[i].price;
      end;

      // 添加面备注
      mianComment := TFood.Create();
      mianComment.id := Food.id;
      mianComment.name := Food.name;
      mianComment.price := Food.price;
      mianComment.tp := Food.tp;
      SingleOrderLB.AddItem(mianComment.name, mianComment);
      // 如果有辣备注,显示辣备注
      if pepperComment <> nil then
        SingleOrderLB.AddItem(pepperComment.name, pepperComment);

      // 把之前保存的饮料烟酒的数组的价格加到总价中,并显示
      for i := 0 to Length(DrinkArr) - 1 do
      begin
        SingleOrderLB.AddItem(DrinkArr[i].name + ' -- ' +
          CurrToStr(DrinkArr[i].price) + '元', DrinkArr[i]);
        TotalPrice := TotalPrice + DrinkArr[i].price;
      end;
    end
    else
    begin
      // 如果当前记录中没有主类面,不添加面备注,重新显示之前的副料
      for i := 0 to Length(OptionFoodArr) - 1 do
      begin
        SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
          CurrToStr(OptionFoodArr[i].price) + '元',
          OptionFoodArr[i]);
        TotalPrice := TotalPrice + OptionFoodArr[i].price;
      end;

      // 把之前保存的饮料烟酒的数组的价格加到总价中,并显示
      for i := 0 to Length(DrinkArr) - 1 do
      begin
        SingleOrderLB.AddItem(DrinkArr[i].name + ' -- ' +
          CurrToStr(DrinkArr[i].price) + '元', DrinkArr[i]);
        TotalPrice := TotalPrice + DrinkArr[i].price;
      end;
    end;
  end
  else if (Food.tp = '辣备注') then
  begin
    // 如果当前记录中有主类面
    if MainFood <> nil then
    begin
      SingleOrderLB.AddItem(MainFood.name + ' -- ' +
        CurrToStr(MainFood.price) + '元', MainFood);
      // 把主类面的价格也加上
      TotalPrice := TotalPrice + MainFood.price;
      // 把之前的可加副料加上
      for i := 0 to Length(OptionFoodArr) - 1 do
      begin
        SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
          CurrToStr(OptionFoodArr[i].price) + '元',
          OptionFoodArr[i]);
        TotalPrice := TotalPrice + OptionFoodArr[i].price;
      end;
      // 如果有面备注,显示面备注
      if mianComment <> nil then
        SingleOrderLB.AddItem(mianComment.name, mianComment);
      // 添加辣备注
      pepperComment := TFood.Create();
      pepperComment.id := Food.id;
      pepperComment.name := Food.name;
      pepperComment.price := Food.price;
      pepperComment.tp := Food.tp;
      SingleOrderLB.AddItem(pepperComment.name, pepperComment);

      // 把之前保存的饮料烟酒的数组的价格加到总价中,并显示
      for i := 0 to Length(DrinkArr) - 1 do
      begin
        SingleOrderLB.AddItem(DrinkArr[i].name + ' -- ' +
          CurrToStr(DrinkArr[i].price) + '元', DrinkArr[i]);
        TotalPrice := TotalPrice + DrinkArr[i].price;
      end;
    end
    else
    begin
      // 如果没有主类面,不添加辣备注,重新显示之前的副料
      for i := 0 to Length(OptionFoodArr) - 1 do
      begin
        SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
          CurrToStr(OptionFoodArr[i].price) + '元',
          OptionFoodArr[i]);
        TotalPrice := TotalPrice + OptionFoodArr[i].price;
      end;
      // 把之前保存的饮料烟酒的数组的价格加到总价中,并显示
      for i := 0 to Length(DrinkArr) - 1 do
      begin
        SingleOrderLB.AddItem(DrinkArr[i].name + ' -- ' +
          CurrToStr(DrinkArr[i].price) + '元', DrinkArr[i]);
        TotalPrice := TotalPrice + DrinkArr[i].price;
      end;
    end;
  end;
  SinglePriceLabel.Caption := CurrToStr(TotalPrice) + '元';
end;
{鼠标左键点击可加副料项目}

procedure TOrderFrame.OptionFoodLBClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to OptionFoodLB.Count - 1 do
  begin
    if OptionFoodLB.Selected[i] then
    begin
      addFoodToSingleLB(OptionFoodLB.Items.Objects[i] as TFood);
      break;
    end;
  end;
end;
{单点状态栏鼠标左键双击事件}

procedure TOrderFrame.SingleOrderLBDblClick(Sender: TObject);
var
  i: integer;
  TotalPrice: Currency;
begin
  // 删除选中的项目
  SingleOrderLB.DeleteSelected;
  // 重新把总价设为0
  TotalPrice := 0;
  // 重新计算总价
  for i := 0 to SingleOrderLB.Count - 1 do
  begin
    TotalPrice := TotalPrice + (SingleOrderLB.Items.Objects[i] as
      TFood).price;
  end;
  // 显示总价
  SinglePriceLabel.Caption := CurrToStr(TotalPrice) + '元';
end;

{订单状态栏双击事件}

procedure TOrderFrame.OrderLBDblClick(Sender: TObject);
var
  i, j, k, m: integer;
  nextFoodRecord: TFoodRecord;
  totalAmount: Currency;
  FoodRec: TFoodRecord;
  decFlg: boolean;
  stopFlg: boolean;
  saveFoodList: array of TFoodRecord;
  tempForm: TmainForm;
  DelFood: TFood;
  nextFood: TFood;
  TempFood: TFood;
  orderStr: string;
begin
  totalAmount := 0;
  stopFlg := false;
  tempForm := Owner as TmainForm;
  // 遍历订单栏所有记录
  for i := 0 to OrderLB.Count - 1 do
  begin
    decFlg := false;
    // 如果已找到选中的记录,就停止
    if stopFlg then
      break;
    if OrderLB.Selected[i] then
    begin
      // 如果删除的是最后一条记录
      if i = OrderLB.Count - 1 then
      begin
        // 当前选中的最后一条记录
        FoodRec := OrderLB.Items.Objects[i] as TFoodRecord;
        // 遍历当前记录的每一个品种
        for j := 0 to Length(FoodRec.Foods) - 1 do
        begin
          // 当前选中的记录的该品种
          DelFood := FoodRec.Foods[j] as TFood;
          // 如果当前选中的记录的该品种是主类面条
          if DelFood.tp = '主类面条' then
          begin
            dec(tempForm.MaxNumber);
            stopFlg := true;
            break;
          end;
        end;
      end
      else
      begin
        // 当前选中的记录
        FoodRec := OrderLB.Items.Objects[i] as TFoodRecord;
        // 遍历当前选中记录的每一个品种
        for j := 0 to Length(FoodRec.Foods) - 1 do
        begin
          // 当前选中的记录的该品种
          DelFood := FoodRec.Foods[j] as TFood;
          // 如果当前选中的记录的该品种是主类面条
          if DelFood.tp = '主类面条' then
          begin
            // 从当前选中的记录的下一条开始
            for k := i + 1 to OrderLB.Count - 1 do
            begin
              // decFlg := false;
              // 遍历当前选中的记录的下一条的每个品种
              nextFoodRecord := OrderLB.Items.Objects[k] as
                TFoodRecord;
              for m := 0 to Length(nextFoodRecord.Foods) - 1 do
              begin
                nextFood := nextFoodRecord.Foods[m] as TFood;
                if nextFood.tp = '主类面条' then
                  // begin
                  dec(nextFoodRecord.OrderNumber);
                // decFlg := true;
              // end;
              end;
            end;
            decFlg := true;
            break;
          end;
        end;
        // 当前预发的牌号减1
        if decFlg then
          dec(tempForm.MaxNumber);
        stopFlg := true;
      end;
    end;
  end;
  // 删除选中的项目
  OrderLB.DeleteSelected;
  // 保存删除之后的清单list
  for i := 0 to OrderLB.Count - 1 do
  begin
    FoodRec := OrderLB.Items.Objects[i] as TFoodRecord;
    SetLength(saveFoodList, length(saveFoodList) + 1);
    saveFoodList[length(saveFoodList) - 1] := FoodRec;
  end;
  // 清空订单状态栏
  OrderLB.Clear;
  // 把之前saveFoodList中的项目按照更新过的牌号重新显示
  for i := 0 to Length(saveFoodList) - 1 do
  begin
    orderStr := '';
    FoodRec := saveFoodList[i] as TFoodRecord;
    for j := 0 to Length(FoodRec.Foods) - 1 do
    begin
      TempFood := FoodRec.Foods[j] as TFood;
      if j <> 0 then
        orderStr := orderStr + '+';
      orderStr := orderStr + TempFood.name;
    end;
    // 显示更新过后的牌号,主要是删除那条以下的数据减1后的牌号
    orderStr := IntToStr(GetPrintNo(FoodRec.OrderNumber)) + ':' +
      orderStr;
    OrderLB.AddItem(orderStr + ' -- ' + CurrToStr(FoodRec.amount) + '元',
      FoodRec);
    totalAmount := totalAmount + FoodRec.amount;
  end;
  // 显示计算后的总价
  TotalAmountLbl.Caption := CurrToStr(totalAmount) + '元';
  // 订单栏以上项目重置
  ClearSingleBtnClick(self);
end;

{获得牌号}

function TOrderFrame.GetMaxNumber(MainForm: TmainForm): integer;
begin
  inc(MainForm.MaxNumber);
  GetMaxNumber := MainForm.MaxNumber;
end;

{获得主键值}

function TOrderFrame.GetMaxSeq(MainForm: TmainForm): integer;
begin
  inc(MainForm.MaxKey);
  GetMaxSeq := MainForm.MaxKey;
end;

{获得取模整理后的牌号}

function TOrderFrame.GetPrintNo(OldNumber: integer): integer;
var
  Temp: integer;
begin
  Temp := OldNumber mod 100;
  if Temp = 0 then
  begin
    Temp := 100;
  end;
  GetPrintNo := Temp;
end;

{单点添加按钮}

procedure TOrderFrame.AddBtnClick(Sender: TObject);
var
  FoodRec: TFoodRecord;
  TempFood: TFood;
  orderStr: string;
  FoodForRec: TFood;
  HasMainFood: boolean;
  Number: integer;
  i: integer;
  totalAmount: Currency;
  MyForm: TmainForm;
begin
  if SingleOrderLB.Items.Count = 0 then
  begin
    messagebox(handle, '目前没有任何点餐记录，请先点餐！',
      '未点餐',
      mb_ok);
    exit;
  end;

  HasMainFood := false;
  MyForm := Owner as TmainForm;
  FoodRec := TFoodRecord.Create;
  totalAmount := 0;
  // 把单点状态栏中的每一条记录加到FoodRec对象的Foods数组中
  for i := 0 to SingleOrderLB.Count - 1 do
  begin
    TempFood := SingleOrderLB.Items.Objects[i] as TFood;
    if TempFood.tp = '主类面条' then
    begin
      HasMainFood := true;
    end;
    FoodForRec := TFood.Create();
    FoodForRec.id := TempFood.id;
    FoodForRec.name := TempFood.name;
    FoodForRec.price := TempFood.price;
    FoodForRec.tp := TempFood.tp;
    SetLength(FoodRec.Foods, length(FoodRec.Foods) + 1);
    FoodRec.Foods[length(FoodRec.Foods) - 1] := FoodForRec;
    FoodRec.amount := FoodRec.amount + FoodForRec.price;
    // 当执行到单点状态栏中的第2条的时候,加上 "+"
    if i <> 0 then
    begin
      if (TempFood.tp = '面备注') or (TempFood.tp = '辣备注') then
      begin
        if not HasMainFood then
        begin
          messagebox(handle,
            '含有备注内容的订单必须要有主类面条，请正确添加！',
            '添加不正',
            mb_ok);
          exit;
        end
        else
          orderStr := orderStr + ' ';
      end
      else
        orderStr := orderStr + '+';
    end;
    orderStr := orderStr + TempFood.name;
  end;

  // 如果既没有输入号码也没有主类面条,则给号码-1
  Number := -1;

  if not (length(trim(OrderNumberEdit.Text)) = 0) then
  begin
    if (strtoint(OrderNumberEdit.Text) <= 0) or (strtoint(OrderNumberEdit.Text)
      > 100) then
    begin
      messagebox(handle,
        '外加的牌号范围只能在1 ~ 100之间，请重新输入牌号！',
        '输入检查',
        mb_ok);
      OrderNumberEdit.SetFocus;
      exit;
    end;
    Number := StrToInt(trim(OrderNumberEdit.Text)) mod 100;
    // 输入的值大于当前最大号, 则认为是对更早过去号的追加, 向前退100个号
    if Number > (MyForm.MaxNumber mod 100) then
    begin
      // 当前最大号超过100,才进行除法运算
      if MyForm.MaxNumber >= 100 then
        Number := ((MyForm.MaxNumber div 100) - 1) * 100 + Number
      else
        Number := StrToInt(OrderNumberEdit.Text);
    end
    else
      // 输入的值小于当前最大号,则认为是对近期未满100个号中的追加
    begin
      // 当前最大号超过100,才进行除法运算
      if MyForm.MaxNumber >= 100 then
        Number := (MyForm.MaxNumber div 100) * 100 + Number
      else
        Number := StrToInt(OrderNumberEdit.Text);
    end;
  end;
  // 如果有主类面,发号
  if HasMainFood then
  begin
    Number := GetMaxNumber(MyForm);
  end;
  FoodRec.OrderNumber := Number;
  orderStr := IntToStr(GetPrintNo(Number)) + ':' + orderStr;
  FoodRec.insertTime := now();
  OrderLB.AddItem(orderStr + ' -- ' + CurrToStr(FoodRec.amount) + '元',
    FoodRec);
  // 遍历订单状态栏中的所有记录
  for i := 0 to OrderLB.Count - 1 do
  begin
    FoodRec := OrderLB.Items.Objects[i] as TFoodRecord;
    totalAmount := totalAmount + FoodRec.amount;
  end;
  // 计算目前所有记录的总价
  TotalAmountLbl.Caption := CurrToStr(totalAmount) + '元';
  // 订单栏以上项目重置
  ClearSingleBtnClick(self);
end;

{确认打印按钮}

procedure TOrderFrame.PrintBtnClick(Sender: TObject);
var
  i: integer;
  j: integer;
  // 预发牌号
  NextNumber: integer;
  FoodRecord: TFoodRecord;
  Food: TFood;
  orderADOQuery: TADOQuery;
  MyForm: TmainForm;
  // 发消息
  //ds: TCopyDataStruct;
  hd: THandle;
begin
  if OrderLB.Items.Count = 0 then
  begin
    messagebox(handle, '没有任何订单记录，至少生成一份订单才能打印！',
      '无订单',
      mb_ok);
    exit;
  end;
  MyForm := Owner as TmainForm;
  orderADOQuery := TADOQuery.Create(self);
  orderADOQuery.Connection := DBConnection;
  DBConnection.BeginTrans;
  // 遍历订单状态栏中的所有条目
  for i := 0 to OrderLB.Count - 1 do
  begin
    FoodRecord := OrderLB.Items.Objects[i] as TFoodRecord;
    // 每份面的每个品种登录到数据库
    for j := 0 to length(FoodRecord.Foods) - 1 do
    begin
      Food := FoodRecord.Foods[j] as TFood;
      if (Food.tp = '主类面条') or (Food.tp = '可加副料') or (Food.tp =
        '饮料烟酒') then
      begin
        Food.seq := GetMaxSeq(MyForm);
        with orderADOQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add('insert into sales (prod_id, prod_nm, prod_price, prod_type, sale_date, sale_cnt, order_no, uniq_key) values (:pi, :pn, :pp, :pt, :time, 1, :on, :uk) ');
          Parameters.ParamByName('pi').Value := Food.id;
          Parameters.ParamByName('pn').Value := Food.name;
          Parameters.ParamByName('pp').Value := Food.price;
          Parameters.ParamByName('pt').Value := Food.tp;
          Parameters.ParamByName('time').Value := now();
          //FoodRecord.insertTime;
          Parameters.ParamByName('on').Value := FoodRecord.OrderNumber;
          Parameters.ParamByName('uk').Value := Food.seq;
          ExecSQL;
        end;
      end;
    end;
  end;
  // 打印
  if printeCheckBox.Checked then
    DoPrint;

  TotalAmountLbl.Caption := '0元';
  // 订单栏以上项目重置
  ClearSingleBtnClick(self);
  // 释放ADO数据库对象
  DBConnection.CommitTrans;
  orderADOQuery.Close;
  orderADOQuery.Free;
  // 显示预发牌号
  NextNumber := MyForm.MaxNumber + 1;
  Label4.Caption := '订单(预发' + IntToStr(GetPrintNo(NextNumber)) + '号)';
  // 厨房数据录入
  displayorders(self);
  // 清空订单栏
  OrderLB.Clear;
  // 如果厨房窗口未启动，则警告
  {Hd := FindWindow (nil, 'kitchendisplay'); // 获得接受窗口的句柄
  if Hd <= 0 then
    ShowMessage ('厨房显示窗口未打开！');
  }
  Hd := FindWindow(nil, 'kitchendisplay'); // 获得接受窗口的句柄
  if Hd > 0 then
  begin
    //发送消息
    sendMms(self);
  end
  else
    ShowMessage('厨房显示窗口未打开！');
end;

{厨房显示函数}

procedure TOrderFrame.displayorders(Sender: TObject);
var
  i: integer;
  j: integer;
  disFoodRecord: TFoodRecord;
  disFood: TFood;
  disorderADOQuery: TADOQuery;
  disString: string;
begin
  disorderADOQuery := TADOQuery.Create(self);
  disorderADOQuery.Connection := disDBConnection;
  disDBConnection.BeginTrans;
  // 遍历订单状态栏中的所有条目
  for i := 0 to OrderLB.Count - 1 do
  begin
    disString := '';
    disFoodRecord := OrderLB.Items.Objects[i] as TFoodRecord;
    // 遍历每份面的每个品种
    //disOrderNumber := disFoodRecord.OrderNumber;
    for j := 0 to length(disFoodRecord.Foods) - 1 do
    begin
      disFood := disFoodRecord.Foods[j] as TFood;
      if (disFood.tp <> '饮料烟酒') then
      begin
        if j <> 0 then
        begin
          if (disFood.tp = '面备注') or (disFood.tp = '辣备注') then
          begin
            disString := disString + ' ';
          end
          else
          begin
            disString := disString + '+';
          end;
        end;
        disString := disString + disFood.name;
      end;
    end;

    with disorderADOQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('insert into dissales (order_no, prod_nm, sale_date) values (:on, :pn, :time) ');
      Parameters.ParamByName('on').Value := disFoodRecord.OrderNumber;
      Parameters.ParamByName('pn').Value := disString;
      Parameters.ParamByName('time').Value := now();
      ExecSQL;
    end;
  end;
  disDBConnection.CommitTrans;
  // 释放ADO数据库对象
  disorderADOQuery.Close;
  disorderADOQuery.Free;
end;

{打印函数}

procedure TOrderFrame.DoPrint();
var
  PText: TextFile;
  FoodRecord: TFoodRecord;
  Food: TFood;
  FoodStr: string;
  i: integer;
  j: integer;
  needPrnFlg: boolean;
  hasOptFoodFlg: boolean;
  hasMainFoodFlg: boolean;
begin
  if Printer.Printers.Count <= 0 then
  begin
    Messagedlg('没有检测到打印机！订单数据已经被写入到今天的账目中，请查实！',
      mterror, [mbok],
      0);
    exit;
  end;
  needPrnFlg := false;
  for i := 0 to OrderLB.Count - 1 do
  begin
    FoodRecord := OrderLB.Items.Objects[i] as TFoodRecord;
    for j := 0 to length(FoodRecord.Foods) - 1 do
    begin
      Food := FoodRecord.Foods[j] as TFood;
      if (Food.tp <> '饮料烟酒') then
      begin
        needPrnFlg := true;
        break;
      end;
    end;
  end;
  if needPrnFlg then
  begin
    //Printer.Canvas.Font.Charset := GB2312_CHARSET;
    AssignFile(PText, 'LPT1');
    //AssignPRN(PText);
    Rewrite(PText);
    // 打印机初始化
    Write(Ptext, chr(27) + chr(64));
    // 设置汉字模式
    //Write(Ptext, chr(28) + chr(38));
    for i := 0 to OrderLB.Count - 1 do
    begin
      hasMainFoodFlg := false;
      hasOptFoodFlg := false;
      FoodRecord := OrderLB.Items.Objects[i] as TFoodRecord;
      for j := 0 to length(FoodRecord.Foods) - 1 do
      begin
        Food := FoodRecord.Foods[j] as TFood;
        if (Food.tp = '主类面条') then
        begin
          hasMainFoodFlg := true;
          break;
        end;
      end;
      if hasMainFoodFlg then
      begin
        // 设置倍高倍宽打印方式
        Write(Ptext, chr(27) + chr(33) + chr(48));
        // 打印牌号
        write(Ptext, IntToStr(GetPrintNo(FoodRecord.OrderNumber)));
        // 取消倍高倍宽打印方式
        Write(Ptext, chr(27) + chr(33) + chr(0));
        // 打印时间
        if (length(IntToStr(GetPrintNo(FoodRecord.OrderNumber))) = 1) then
          writeln(Ptext, '                ' +
            FormatDateTime('yy-mm-dd hh:mm',
            now));
        if (length(IntToStr(GetPrintNo(FoodRecord.OrderNumber))) = 2) then
          writeln(Ptext, '              ' +
            FormatDateTime('yy-mm-dd hh:mm',
            now));
        if (length(IntToStr(GetPrintNo(FoodRecord.OrderNumber))) = 3) then
          writeln(Ptext, '            ' + FormatDateTime('yy-mm-dd hh:mm',
            now));
        FoodStr := '';
        for j := 0 to length(FoodRecord.Foods) - 1 do
        begin
          Food := FoodRecord.Foods[j] as TFood;
          if (Food.tp <> '饮料烟酒') then
          begin
            if (j <> 0) then
            begin
              if (Food.tp = '面备注') or (Food.tp = '辣备注') then
                FoodStr := FoodStr + ' '
              else
                FoodStr := FoodStr + '+';
            end;
            FoodStr := FoodStr + Food.name;
          end;
        end;
        // 设置倍高倍宽打印方式
        Write(Ptext, chr(27) + chr(33) + chr(48));
        // 打印内容
        writeln(Ptext, FoodStr);
        // 取消倍高倍宽打印方式
        Write(Ptext, chr(27) + chr(33) + chr(0));
        writeln(Ptext, '--------------------------------');
      end
      else
      begin
        for j := 0 to length(FoodRecord.Foods) - 1 do
        begin
          Food := FoodRecord.Foods[j] as TFood;
          if (Food.tp <> '饮料烟酒') then
          begin
            hasOptFoodFlg := true;
            break;
          end;
        end;
        if hasOptFoodFlg then
        begin
          // 设置倍高倍宽打印方式
          Write(Ptext, chr(27) + chr(33) + chr(48));
          // 打印牌号
          write(Ptext, IntToStr(GetPrintNo(FoodRecord.OrderNumber)));
          // 取消倍高倍宽打印方式
          Write(Ptext, chr(27) + chr(33) + chr(0));
          // 打印时间
          if (length(IntToStr(GetPrintNo(FoodRecord.OrderNumber))) = 1) then
            writeln(Ptext, '                ' +
              FormatDateTime('yy-mm-dd hh:mm',
              now));
          if (length(IntToStr(GetPrintNo(FoodRecord.OrderNumber))) = 2) then
            writeln(Ptext, '              ' +
              FormatDateTime('yy-mm-dd hh:mm',
              now));
          if (length(IntToStr(GetPrintNo(FoodRecord.OrderNumber))) = 3) then
            writeln(Ptext, '            ' +
              FormatDateTime('yy-mm-dd hh:mm',
              now));
          FoodStr := '外加:';
          for j := 0 to length(FoodRecord.Foods) - 1 do
          begin
            Food := FoodRecord.Foods[j] as TFood;
            if (Food.tp <> '饮料烟酒') then
            begin
              if (j <> 0) then
                FoodStr := FoodStr + '+';
              FoodStr := FoodStr + Food.name;
            end;
          end;
          // 设置倍高倍宽打印方式
          Write(Ptext, chr(27) + chr(33) + chr(48));
          writeln(Ptext, FoodStr);
          // 取消倍高倍宽打印方式
          Write(Ptext, chr(27) + chr(33) + chr(0));
          writeln(Ptext, '--------------------------------');
        end;
      end;
    end;
    // 向前走纸
    Write(Ptext, chr(27) + chr(74) + chr(120));
    CloseFile(Ptext); //停止打印
  end;
end;

{牌号编辑框输入限定}

procedure TOrderFrame.OrderNumberEditKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #13, #8]) then
    Key := #0;
end;

{单点状态栏以上项目重置}

procedure TOrderFrame.ClearSingleBtnClick(Sender: TObject);
begin
  // 清空单点状态栏
  SingleOrderLB.Clear;
  // 价格归零
  SinglePriceLabel.Caption := '0元';
  // 禁用编辑按钮
  editButton.Enabled := false;
  // 解禁添加按钮
  AddBtn.Enabled := true;
  // 状态文字重置
  Label10.Caption := '添加';
  Label10.Font.Color := clBlue;
  // 清空牌号输入框
  OrderNumberEdit.Clear;
  // 自适应订单栏宽度
  SetWidth(self.OrderLB);
end;

{单击订单状态栏中的一条记录,回显到单点状态栏,准备修改}

procedure TOrderFrame.OrderLBClick(Sender: TObject);
var
  i, j: integer;
  modifyFoodRecord: TFoodRecord;
  tmpFood: TFood;
begin
  // 如果订单状态栏为空
  if OrderLB.Count = 0 then
  begin
    editButton.Enabled := false;
    exit;
  end;
  // 重置编辑条目的主类品种Flg
  modifyHasMainFlg := false;
  // 定位到当前选中的记录
  for i := 0 to OrderLB.Count - 1 do
  begin
    if OrderLB.Selected[i] then
      // 回显到单点状态栏中
    begin
      modifyFoodRecord := OrderLB.Items.Objects[i] as TFoodRecord;
      modifyFoodDateTime := modifyFoodRecord.insertTime;
      SingleOrderLB.Clear;
      for j := 0 to length(modifyFoodRecord.Foods) - 1 do
      begin
        tmpFood := modifyFoodRecord.Foods[j] as TFood;
        if (tmpFood.tp = '主类面条') then
          modifyHasMainFlg := true;
        if (tmpFood.tp <> '面备注') and (tmpFood.tp <> '辣备注') then
        begin
          SingleOrderLB.AddItem(modifyFoodRecord.Foods[j].name + ' -- '
            +
            CurrToStr(modifyFoodRecord.Foods[j].price) + '元',
            modifyFoodRecord.Foods[j]);
        end
        else
        begin
          SingleOrderLB.AddItem(modifyFoodRecord.Foods[j].name,
            modifyFoodRecord.Foods[j]);
        end;
      end;
      // 显示单点状态栏中的总价
      SinglePriceLabel.Caption := CurrToStr(modifyFoodRecord.amount) +
        '元';
      ModifiedFoodOrderNum := modifyFoodRecord.OrderNumber;
      ModifiedFoodRowNum := i;
      if modifyFoodRecord.OrderNumber mod 100 = 0 then
        Label10.Caption := '修改100号'
      else
        Label10.Caption := '修改' + IntToStr(modifyFoodRecord.OrderNumber
          mod
          100) + '号';
      Label10.Font.Color := clRed;
      break;
    end;
  end;
  // 解禁编辑按钮
  editButton.Enabled := true;
  // 禁用添加按钮
  AddBtn.Enabled := false;
end;

{修改按钮}

procedure TOrderFrame.editButtonClick(Sender: TObject);
var
  FoodRecord: TFoodRecord;
  TmpFood: TFood;
  ordStr: string;
  i: integer;
  totalAmount: Currency;
  FoodForRec: TFood;
  HasMainFlg: boolean;
begin
  if SingleOrderLB.Items.Count = 0 then
  begin
    messagebox(handle, '修改的点餐记录不能为空，请正确修改！',
      '修改不正',
      mb_ok);
    exit;
  end;
  HasMainFlg := false;
  if not modifyHasMainFlg then
    for i := 0 to SingleOrderLB.Count - 1 do
    begin
      TmpFood := SingleOrderLB.Items.Objects[i] as TFood;
      if (TmpFood.tp = '主类面条') then
      begin
        messagebox(handle,
          '修改外加副料的订单时，不允许追加主类面条，请正确修改！',
          '修改不正',
          mb_ok);
        exit;
      end;
    end
  else
  begin
    for i := 0 to SingleOrderLB.Count - 1 do
    begin
      TmpFood := SingleOrderLB.Items.Objects[i] as TFood;
      if TmpFood.tp = '主类面条' then
      begin
        HasMainFlg := true;
        break;
      end;
    end;
    if not HasMainFlg then
    begin
      messagebox(handle,
        '修改含有主类面条的订单时，至少要包含一个主类面条，请正确修改！',
        '修改不正',
        mb_ok);
      exit;
    end;
  end;
  FoodRecord := TFoodRecord.Create();
  totalAmount := 0;
  // 把单点状态栏中的每一条记录加到FoodRec对象的Foods数组中
  for i := 0 to SingleOrderLB.Count - 1 do
  begin
    FoodForRec := TFood.Create();
    TmpFood := SingleOrderLB.Items.Objects[i] as TFood;
    FoodForRec.id := TmpFood.id;
    FoodForRec.name := TmpFood.name;
    FoodForRec.price := TmpFood.price;
    FoodForRec.tp := TmpFood.tp;
    SetLength(FoodRecord.Foods, length(FoodRecord.Foods) + 1);
    FoodRecord.Foods[length(FoodRecord.Foods) - 1] := FoodForRec;
    FoodRecord.amount := FoodRecord.amount + FoodForRec.price;
    // 当执行到单点状态栏中的第2条的时候,加上 "+"
    if i <> 0 then
    begin
      if (TmpFood.tp = '面备注') or (TmpFood.tp = '辣备注') then
      begin
        if not HasMainFlg then
        begin
          messagebox(handle,
            '修改外加副料的订单时，不允许追加备注内容，请正确修改！',
            '修改不正',
            mb_ok);
          exit;
        end
        else
          ordStr := ordStr + ' ';
      end
      else
        ordStr := ordStr + '+';
    end;
    ordStr := ordStr + TmpFood.name;
  end;
  FoodRecord.OrderNumber := ModifiedFoodOrderNum;
  ordStr := IntToStr(GetPrintNo(ModifiedFoodOrderNum)) + ':' + ordStr;
  OrderLB.Items.Delete(ModifiedFoodRowNum);
  FoodRecord.insertTime := modifyFoodDateTime;
  OrderLB.Items.InsertObject(ModifiedFoodRowNum, ordStr + ' -- ' +
    CurrToStr(FoodRecord.amount) + '元', FoodRecord);
  // 遍历订单状态栏中的所有记录
  for i := 0 to OrderLB.Count - 1 do
  begin
    FoodRecord := OrderLB.Items.Objects[i] as TFoodRecord;
    totalAmount := totalAmount + FoodRecord.amount;
  end;
  // 计算目前所有记录的总价
  TotalAmountLbl.Caption := CurrToStr(totalAmount) + '元';
  // 重置编辑条目的主类品种Flg
  modifyHasMainFlg := false;
  // 单点状态栏以上项目重置
  ClearSingleBtnClick(self);
end;

{面份量单击添加事件}

procedure TOrderFrame.noodWeightLBClick(Sender: TObject);
var
  i: integer;
begin
  // 遍历ListBox中条目
  for i := 0 to noodWeightLB.Count - 1 do
  begin
    // 如果当前条目选中
    if noodWeightLB.Selected[i] then
    begin
      // 将选中的条目加到单点状态栏中
      addFoodToSingleLB(noodWeightLB.Items.Objects[i] as TFood);
      break;
    end;
  end;
end;

{单点辣备注项目}

procedure TOrderFrame.pepperLBClick(Sender: TObject);
var
  i: integer;
begin
  // 遍历ListBox中条目
  for i := 0 to pepperLB.Count - 1 do
  begin
    // 如果当前条目选中
    if pepperLB.Selected[i] then
    begin
      // 将选中的条目加到单点状态栏中
      addFoodToSingleLB(pepperLB.Items.Objects[i] as TFood);
      break;
    end;
  end;

end;

{重设ListBox水平滚动条}

procedure TOrderFrame.SetWidth(Sender: TListBox);
var
  i, w: Integer;
begin
  w := 0;
  with Sender do
  begin
    Canvas.Font.Name := '宋体';
    Canvas.Font.Size := 12;
    Canvas.Font.Style := [fsBold];
    for i := 0 to Items.Count - 1 do
    begin
      if Canvas.TextWidth(Items.Strings[i]) > w then
        w := Canvas.TextWidth(Items.Strings[i]);
    end;
    SendMessage(Handle, LB_SETHORIZONTALEXTENT, w + 5, 0);
  end;
end;

{鼠标右键消息捕捉}

procedure TOrderFrame.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  //如果右键点击,则调用添加按钮过程
  //if ((Msg.Message = WM_RBUTTONDOWN) or (Msg.Message=WM_RBUTTONUP)) then
  if (Msg.Message = WM_RBUTTONDOWN) then
  begin
    if Label10.Caption = '添加' then
      AddBtnClick(self)
    else
      editButtonClick(self);
    Handled := True;
  end;
end;

{打印开关控制}

procedure TOrderFrame.printeCheckBoxClick(Sender: TObject);
begin
  if printeCheckBox.Checked then
  begin
    userLogin.WriteIniFile(IniFileStr, 'printer', 'switch', 'on');
  end
  else
  begin
    userLogin.WriteIniFile(IniFileStr, 'printer', 'switch', 'off');
  end
end;

procedure TOrderFrame.sendMms(Sender: TObject);
var
  Msg: Cardinal;
  B: DWord;
  M: TMessage;
begin
  Msg := RegisterWindowMessage('wm_mymessage');
  M.Msg := Msg;
  B := BSM_ALLCOMPONENTS;
  BroadcastSystemMessage(BSF_POSTMESSAGE, @B, M.Msg, M.WParam, M.LParam);
end;
{
var
  ds: TCopyDataStruct;
  hd: THandle;
begin
  ds.cbData := Length ('inputOk') + 1;
  GetMem (ds.lpData, ds.cbData ); //为传递的数据区分配内存
  StrCopy (ds.lpData, PChar ('inputOk'));

  Hd := FindWindow (nil, 'kitchendisplay'); // 获得接受窗口的句柄
  if Hd > 0 then
    SendMessage (Hd, WM_COPYDATA, Handle,
                 Cardinal(@ds)) // 发送WM_COPYDATA消息
  else
    ShowMessage ('厨房窗口未打开！');
    FreeMem (ds.lpData); //释放资源
end;
}
end.

