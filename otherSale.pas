unit otherSale;

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
  main;

type
  TadditionFrame = class(TFrame)
    drinksLB: TListBox;
    Label1: TLabel;
    SingleOrderLB: TListBox;
    Label3: TLabel;
    SinglePriceLabel: TLabel;
    OKBtn: TButton;
    ClearBtn: TButton;
    Label2: TLabel;
    procedure drinksLBClick(Sender: TObject);
    procedure SingleOrderLBDblClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure ClearBtnClick(Sender: TObject);
    procedure addFoodToSingleLB(Food: TFood);
    function GetMaxSeq(MainForm: TmainForm): integer;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
uses login;
{$R *.dfm}

procedure TadditionFrame.drinksLBClick(Sender: TObject);
var
  i: Integer;
begin
  // 遍历ListBox中条目
  for i := 0 to drinksLB.Count - 1 do
    begin
      // 如果当前条目选中
      if drinksLB.Selected[i] then
        begin
          // 将选中的条目加到单点状态栏中
          addFoodToSingleLB(drinksLB.Items.Objects[i] as TFood);
          break;
        end;
    end;
end;

procedure TadditionFrame.SingleOrderLBDblClick(Sender: TObject);
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

procedure TadditionFrame.OKBtnClick(Sender: TObject);
var
  i: integer;
  //j: integer;
  Food: TFood;
  orderADOQuery: TADOQuery;
  MyForm: TmainForm;
begin
  if SingleOrderLB.Items.Count = 0 then
    begin
      messagebox(handle, '目前没有任何订单记录,至少生成一份订单才能确认！',
        '无订单',
        mb_ok);
      exit;
    end;
  MyForm := Owner as TmainForm;
  orderADOQuery := TADOQuery.Create(self);
  orderADOQuery.Connection := DBConnection;
  // 遍历订单状态栏中的所有条目
  for i := 0 to SingleOrderLB.Count - 1 do
    begin
      Food := SingleOrderLB.Items.Objects[i] as TFood;
      if (Food.tp = '饮料烟酒') then
        begin
          Food.seq := GetMaxSeq(MyForm);
          with orderADOQuery do
            begin
              SQL.Clear;
              SQL.Add('insert into sales (prod_id, prod_nm, prod_price, prod_type, sale_date, sale_cnt, order_no, uniq_key) values (:pi, :pn, :pp, :pt, :time, 1, :on, :uk) ');
              Parameters.ParamByName('pi').Value := Food.id;
              Parameters.ParamByName('pn').Value := Food.name;
              Parameters.ParamByName('pp').Value := Food.price;
              Parameters.ParamByName('pt').Value := Food.tp;
              Parameters.ParamByName('time').Value := now();
              Parameters.ParamByName('on').Value := -2;
              Parameters.ParamByName('uk').Value := Food.seq;
              ExecSQL;
            end;
        end;
    end;
  //OrderLB.Clear;
  //TotalAmountLbl.Caption := '0元';
  ClearBtnClick(self);
  orderADOQuery.Close;
  orderADOQuery.Free;
  //editButton.Enabled := false;
  //AddBtn.Enabled := True;
  //Label10.Caption := '添加';
  //Label10.Font.Color := clBlue;
  // DoPrint;
end;

procedure TadditionFrame.ClearBtnClick(Sender: TObject);
begin
  SingleOrderLB.Clear;
  SinglePriceLabel.Caption := '0元';
end;

function TadditionFrame.GetMaxSeq(MainForm: TmainForm): integer;
begin
  inc(MainForm.MaxKey);
  GetMaxSeq := MainForm.MaxKey;
end;

{单点状态栏添加项目}

procedure TadditionFrame.addFoodToSingleLB(Food: TFood);
var
  i: Integer;
  TempFood: TFood;
  //MainFood: TFood;
  OptionFoodArr: array of TFood;
  TotalPrice: Currency;
  NFood: TFood;
  //mianComment: TFood;
  //pepperComment: TFood;
begin
  //MainFood := nil;
  //mianComment := nil;
  //pepperComment := nil;
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
      // 暂存数组容量加1
      SetLength(OptionFoodArr, length(OptionFoodArr) + 1);
      // 将当前的品种添加到数组的末尾
      OptionFoodArr[length(OptionFoodArr) - 1] := NFood;
      {
      // 如果当前遍历的对象是主类面条的实例
      if (TempFood.tp = '主类面条') then
        begin
          // 主类面赋值为当前对象
          MainFood := NFood;
        end

      // 否则是可加副料的实例
      else
        if (TempFood.tp <> '面备注') and (TempFood.tp <> '辣备注') then
          begin
            // 可加副料数组容量加1
            SetLength(OptionFoodArr, length(OptionFoodArr) + 1);
            // 将当前的副料加到副料数组的末尾
            OptionFoodArr[length(OptionFoodArr) - 1] := NFood;
          end
        else
          if (TempFood.tp = '面备注') then
            begin
              mianComment := TFood.Create();
              mianComment.id := TempFood.id;
              mianComment.name := TempFood.name;
              mianComment.price := TempFood.price;
              mianComment.tp := TempFood.tp;
            end
          else
            begin
              pepperComment := TFood.Create();
              pepperComment.id := TempFood.id;
              pepperComment.name := TempFood.name;
              pepperComment.price := TempFood.price;
              pepperComment.tp := TempFood.tp;
            end;
            }
    end;
  // 单点状态栏清空其内容,并将总价设为0
  SingleOrderLB.Clear;
  TotalPrice := 0;
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
  {
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
        //TotalPrice := TotalPrice + Food.price;
      end
    else
      // 如果传递的参数是可加副料
      if (Food.tp = '可加副料') then
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
        end
      else
        // 如果传递的参数是面备注
        if (Food.tp = '面备注') then
          begin
            // 如果当前记录中有主类面
            if MainFood <> nil then
              begin
                SingleOrderLB.AddItem(MainFood.name + ' -- ' +
                  CurrToStr(MainFood.price) + '元', MainFood);
                // 把主类面的价格也加上
                TotalPrice := TotalPrice + MainFood.price;
                for i := 0 to Length(OptionFoodArr) - 1 do
                  begin
                    SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
                      CurrToStr(OptionFoodArr[i].price) + '元',
                      OptionFoodArr[i]);
                    TotalPrice := TotalPrice + OptionFoodArr[i].price;
                  end;
                // 添加面备注
                mianComment := nil;
                mianComment := TFood.Create();
                mianComment.id := Food.id;
                mianComment.name := Food.name;
                mianComment.price := Food.price;
                mianComment.tp := Food.tp;
                SingleOrderLB.AddItem(mianComment.name, mianComment);
                // 如果有辣备注,显示辣备注
                if pepperComment <> nil then
                  SingleOrderLB.AddItem(pepperComment.name, pepperComment);
              end
            else
              // 如果当前记录中没有主类面,不添加面备注,重新显示之前的副料
              for i := 0 to Length(OptionFoodArr) - 1 do
                begin
                  SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
                    CurrToStr(OptionFoodArr[i].price) + '元',
                    OptionFoodArr[i]);
                  TotalPrice := TotalPrice + OptionFoodArr[i].price;
                end;
          end
        else
          // 如果传递的参数是辣备注
          if (Food.tp = '辣备注') then
            begin
              // 如果当前记录中有主类面
              if MainFood <> nil then
                begin
                  SingleOrderLB.AddItem(MainFood.name + ' -- ' +
                    CurrToStr(MainFood.price) + '元', MainFood);
                  // 把主类面的价格也加上
                  TotalPrice := TotalPrice + MainFood.price;
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
                  pepperComment := nil;
                  pepperComment := TFood.Create();
                  pepperComment.id := Food.id;
                  pepperComment.name := Food.name;
                  pepperComment.price := Food.price;
                  pepperComment.tp := Food.tp;
                  SingleOrderLB.AddItem(pepperComment.name, pepperComment);
                end
              else
                // 如果没有主类面,不添加辣备注,重新显示之前的副料
                for i := 0 to Length(OptionFoodArr) - 1 do
                  begin
                    SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
                      CurrToStr(OptionFoodArr[i].price) + '元',
                      OptionFoodArr[i]);
                    TotalPrice := TotalPrice + OptionFoodArr[i].price;
                  end;
            end;
            }
  SinglePriceLabel.Caption := CurrToStr(TotalPrice) + '元';
end;
end.
