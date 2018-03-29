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
{�����������������ListBox}

procedure TOrderFrame.MainFoodLBClick(Sender: TObject);
var
  i: Integer;
begin
  // ����ListBox����Ŀ
  for i := 0 to MainFoodLB.Count - 1 do
  begin
    // �����ǰ��Ŀѡ��
    if MainFoodLB.Selected[i] then
    begin
      // ��ѡ�е���Ŀ�ӵ�����״̬����
      addFoodToSingleLB(MainFoodLB.Items.Objects[i] as TFood);
      break;
    end;
  end;
end;

{����״̬�������Ŀ}

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
  // ��������״̬��,�鿴��ǰ�Ѵ��ڵ�Ʒ�����Ͳ�������
  for i := 0 to SingleOrderLB.Count - 1 do
  begin
    // ������ʱFood����,��Ϊ�������
    TempFood := SingleOrderLB.Items.Objects[i] as TFood;
    // ����NFood����,������ʱFood���������ֵ
    NFood := TFood.Create();
    NFood.id := TempFood.id;
    NFood.name := TempFood.name;
    NFood.price := TempFood.price;
    NFood.tp := TempFood.tp;
    // �����ǰ�����Ķ���������������ʵ��
    if (TempFood.tp = '��������') then
    begin
      // �����渳ֵΪ��ǰ����
      MainFood := NFood;
    end
      // �����ǿɼӸ��ϵ�ʵ��
    else if (TempFood.tp <> '�汸ע') and (TempFood.tp <> '����ע') and
      (TempFood.tp <> '�����̾�') then
    begin
      // �ɼӸ�������������1
      SetLength(OptionFoodArr, length(OptionFoodArr) + 1);
      // ����ǰ�ĸ��ϼӵ����������ĩβ
      OptionFoodArr[length(OptionFoodArr) - 1] := NFood;
    end
    else if (TempFood.tp = '�����̾�') then
    begin
      // �����̾�����������1
      SetLength(DrinkArr, length(DrinkArr) + 1);
      // ����ǰ�������̾Ƽӵ������̾������ĩβ
      DrinkArr[length(DrinkArr) - 1] := NFood;
    end
    else if (TempFood.tp = '�汸ע') then
    begin
      mianComment := TFood.Create();
      mianComment.id := NFood.id;
      mianComment.name := NFood.name;
      mianComment.price := NFood.price;
      mianComment.tp := NFood.tp;
    end
    else if (TempFood.tp = '����ע') then
    begin
      pepperComment := TFood.Create();
      pepperComment.id := NFood.id;
      pepperComment.name := NFood.name;
      pepperComment.price := NFood.price;
      pepperComment.tp := NFood.tp;
    end;

  end;
  // ����״̬�����������,�����ܼ���Ϊ0
  SingleOrderLB.Clear;
  TotalPrice := 0;
  // ������ݵĲ�������������
  if (Food.tp = '��������') then
  begin
    // ����״̬�������Ӹ���Ŀ
    SingleOrderLB.AddItem(Food.name + ' -- ' + CurrToStr(Food.price) + 'Ԫ',
      Food);
    // �ܼ۸���
    TotalPrice := TotalPrice + Food.price;
    // �ٰ�֮ǰ����ĸ��ϵ�����ļ۸�ӵ��ܼ���,����ʾ
    for i := 0 to Length(OptionFoodArr) - 1 do
    begin
      SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
        CurrToStr(OptionFoodArr[i].price) + 'Ԫ', OptionFoodArr[i]);
      TotalPrice := TotalPrice + OptionFoodArr[i].price;
    end;

    // ������汸ע,��ʾ�汸ע
    if mianComment <> nil then
      SingleOrderLB.AddItem(mianComment.name, mianComment);
    // ���������ע,��ʾ�汸ע
    if pepperComment <> nil then
      SingleOrderLB.AddItem(pepperComment.name, pepperComment);

    // ��֮ǰ����������̾Ƶ�����ļ۸�ӵ��ܼ���,����ʾ
    for i := 0 to Length(DrinkArr) - 1 do
    begin
      SingleOrderLB.AddItem(DrinkArr[i].name + ' -- ' +
        CurrToStr(DrinkArr[i].price) + 'Ԫ', DrinkArr[i]);
      TotalPrice := TotalPrice + DrinkArr[i].price;
    end;
  end
  else if (Food.tp = '�ɼӸ���') then
  begin
    // �����ǰ��¼����������
    if MainFood <> nil then
    begin
      SingleOrderLB.AddItem(MainFood.name + ' -- ' +
        CurrToStr(MainFood.price) + 'Ԫ', MainFood);
      // ��������ļ۸�Ҳ����
      TotalPrice := TotalPrice + MainFood.price;
    end;
    // ��֮ǰ����ĸ��ϵ�����ļ۸�ӵ��ܼ���,����ʾ
    for i := 0 to Length(OptionFoodArr) - 1 do
    begin
      SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
        CurrToStr(OptionFoodArr[i].price) + 'Ԫ', OptionFoodArr[i]);
      TotalPrice := TotalPrice + OptionFoodArr[i].price;
    end;

    // �ٰѼӽ����ĸ��Ϻͼ۸����
    SingleOrderLB.AddItem(Food.name + ' -- ' + CurrToStr(Food.price) +
      'Ԫ',
      Food);
    TotalPrice := TotalPrice + Food.price;

    // ������汸ע,��ʾ�汸ע
    if mianComment <> nil then
      SingleOrderLB.AddItem(mianComment.name, mianComment);
    // ���������ע,��ʾ�汸ע
    if pepperComment <> nil then
      SingleOrderLB.AddItem(pepperComment.name, pepperComment);

    // ��֮ǰ����������̾Ƶ�����ļ۸�ӵ��ܼ���,����ʾ
    for i := 0 to Length(DrinkArr) - 1 do
    begin
      SingleOrderLB.AddItem(DrinkArr[i].name + ' -- ' +
        CurrToStr(DrinkArr[i].price) + 'Ԫ', DrinkArr[i]);
      TotalPrice := TotalPrice + DrinkArr[i].price;
    end;

  end
  else if (Food.tp = '�����̾�') then
  begin
    // �����ǰ��¼����������
    if MainFood <> nil then
    begin
      SingleOrderLB.AddItem(MainFood.name + ' -- ' +
        CurrToStr(MainFood.price) + 'Ԫ', MainFood);
      // ��������ļ۸�Ҳ����
      TotalPrice := TotalPrice + MainFood.price;
    end;
    // ��֮ǰ����ĸ��ϵ�����ļ۸�ӵ��ܼ���,����ʾ
    for i := 0 to Length(OptionFoodArr) - 1 do
    begin
      SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
        CurrToStr(OptionFoodArr[i].price) + 'Ԫ', OptionFoodArr[i]);
      TotalPrice := TotalPrice + OptionFoodArr[i].price;
    end;

    // ������汸ע,��ʾ�汸ע
    if mianComment <> nil then
      SingleOrderLB.AddItem(mianComment.name, mianComment);
    // ���������ע,��ʾ�汸ע
    if pepperComment <> nil then
      SingleOrderLB.AddItem(pepperComment.name, pepperComment);

    // ��֮ǰ����������̾Ƶ�����ļ۸�ӵ��ܼ���,����ʾ
    for i := 0 to Length(DrinkArr) - 1 do
    begin
      SingleOrderLB.AddItem(DrinkArr[i].name + ' -- ' +
        CurrToStr(DrinkArr[i].price) + 'Ԫ', DrinkArr[i]);
      TotalPrice := TotalPrice + DrinkArr[i].price;
    end;

    // �ٰѼӽ����������̾ƺͼ۸����
    SingleOrderLB.AddItem(Food.name + ' -- ' + CurrToStr(Food.price) +
      'Ԫ',
      Food);
    TotalPrice := TotalPrice + Food.price;
  end
  else if (Food.tp = '�汸ע') then
  begin
    // �����ǰ��¼����������
    if MainFood <> nil then
    begin
      SingleOrderLB.AddItem(MainFood.name + ' -- ' +
        CurrToStr(MainFood.price) + 'Ԫ', MainFood);
      // ��������ļ۸�Ҳ����
      TotalPrice := TotalPrice + MainFood.price;
      // ��֮ǰ�ĿɼӸ��ϼ���
      for i := 0 to Length(OptionFoodArr) - 1 do
      begin
        SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
          CurrToStr(OptionFoodArr[i].price) + 'Ԫ',
          OptionFoodArr[i]);
        TotalPrice := TotalPrice + OptionFoodArr[i].price;
      end;

      // ����汸ע
      mianComment := TFood.Create();
      mianComment.id := Food.id;
      mianComment.name := Food.name;
      mianComment.price := Food.price;
      mianComment.tp := Food.tp;
      SingleOrderLB.AddItem(mianComment.name, mianComment);
      // ���������ע,��ʾ����ע
      if pepperComment <> nil then
        SingleOrderLB.AddItem(pepperComment.name, pepperComment);

      // ��֮ǰ����������̾Ƶ�����ļ۸�ӵ��ܼ���,����ʾ
      for i := 0 to Length(DrinkArr) - 1 do
      begin
        SingleOrderLB.AddItem(DrinkArr[i].name + ' -- ' +
          CurrToStr(DrinkArr[i].price) + 'Ԫ', DrinkArr[i]);
        TotalPrice := TotalPrice + DrinkArr[i].price;
      end;
    end
    else
    begin
      // �����ǰ��¼��û��������,������汸ע,������ʾ֮ǰ�ĸ���
      for i := 0 to Length(OptionFoodArr) - 1 do
      begin
        SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
          CurrToStr(OptionFoodArr[i].price) + 'Ԫ',
          OptionFoodArr[i]);
        TotalPrice := TotalPrice + OptionFoodArr[i].price;
      end;

      // ��֮ǰ����������̾Ƶ�����ļ۸�ӵ��ܼ���,����ʾ
      for i := 0 to Length(DrinkArr) - 1 do
      begin
        SingleOrderLB.AddItem(DrinkArr[i].name + ' -- ' +
          CurrToStr(DrinkArr[i].price) + 'Ԫ', DrinkArr[i]);
        TotalPrice := TotalPrice + DrinkArr[i].price;
      end;
    end;
  end
  else if (Food.tp = '����ע') then
  begin
    // �����ǰ��¼����������
    if MainFood <> nil then
    begin
      SingleOrderLB.AddItem(MainFood.name + ' -- ' +
        CurrToStr(MainFood.price) + 'Ԫ', MainFood);
      // ��������ļ۸�Ҳ����
      TotalPrice := TotalPrice + MainFood.price;
      // ��֮ǰ�ĿɼӸ��ϼ���
      for i := 0 to Length(OptionFoodArr) - 1 do
      begin
        SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
          CurrToStr(OptionFoodArr[i].price) + 'Ԫ',
          OptionFoodArr[i]);
        TotalPrice := TotalPrice + OptionFoodArr[i].price;
      end;
      // ������汸ע,��ʾ�汸ע
      if mianComment <> nil then
        SingleOrderLB.AddItem(mianComment.name, mianComment);
      // �������ע
      pepperComment := TFood.Create();
      pepperComment.id := Food.id;
      pepperComment.name := Food.name;
      pepperComment.price := Food.price;
      pepperComment.tp := Food.tp;
      SingleOrderLB.AddItem(pepperComment.name, pepperComment);

      // ��֮ǰ����������̾Ƶ�����ļ۸�ӵ��ܼ���,����ʾ
      for i := 0 to Length(DrinkArr) - 1 do
      begin
        SingleOrderLB.AddItem(DrinkArr[i].name + ' -- ' +
          CurrToStr(DrinkArr[i].price) + 'Ԫ', DrinkArr[i]);
        TotalPrice := TotalPrice + DrinkArr[i].price;
      end;
    end
    else
    begin
      // ���û��������,���������ע,������ʾ֮ǰ�ĸ���
      for i := 0 to Length(OptionFoodArr) - 1 do
      begin
        SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
          CurrToStr(OptionFoodArr[i].price) + 'Ԫ',
          OptionFoodArr[i]);
        TotalPrice := TotalPrice + OptionFoodArr[i].price;
      end;
      // ��֮ǰ����������̾Ƶ�����ļ۸�ӵ��ܼ���,����ʾ
      for i := 0 to Length(DrinkArr) - 1 do
      begin
        SingleOrderLB.AddItem(DrinkArr[i].name + ' -- ' +
          CurrToStr(DrinkArr[i].price) + 'Ԫ', DrinkArr[i]);
        TotalPrice := TotalPrice + DrinkArr[i].price;
      end;
    end;
  end;
  SinglePriceLabel.Caption := CurrToStr(TotalPrice) + 'Ԫ';
end;
{����������ɼӸ�����Ŀ}

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
{����״̬��������˫���¼�}

procedure TOrderFrame.SingleOrderLBDblClick(Sender: TObject);
var
  i: integer;
  TotalPrice: Currency;
begin
  // ɾ��ѡ�е���Ŀ
  SingleOrderLB.DeleteSelected;
  // ���°��ܼ���Ϊ0
  TotalPrice := 0;
  // ���¼����ܼ�
  for i := 0 to SingleOrderLB.Count - 1 do
  begin
    TotalPrice := TotalPrice + (SingleOrderLB.Items.Objects[i] as
      TFood).price;
  end;
  // ��ʾ�ܼ�
  SinglePriceLabel.Caption := CurrToStr(TotalPrice) + 'Ԫ';
end;

{����״̬��˫���¼�}

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
  // �������������м�¼
  for i := 0 to OrderLB.Count - 1 do
  begin
    decFlg := false;
    // ������ҵ�ѡ�еļ�¼,��ֹͣ
    if stopFlg then
      break;
    if OrderLB.Selected[i] then
    begin
      // ���ɾ���������һ����¼
      if i = OrderLB.Count - 1 then
      begin
        // ��ǰѡ�е����һ����¼
        FoodRec := OrderLB.Items.Objects[i] as TFoodRecord;
        // ������ǰ��¼��ÿһ��Ʒ��
        for j := 0 to Length(FoodRec.Foods) - 1 do
        begin
          // ��ǰѡ�еļ�¼�ĸ�Ʒ��
          DelFood := FoodRec.Foods[j] as TFood;
          // �����ǰѡ�еļ�¼�ĸ�Ʒ������������
          if DelFood.tp = '��������' then
          begin
            dec(tempForm.MaxNumber);
            stopFlg := true;
            break;
          end;
        end;
      end
      else
      begin
        // ��ǰѡ�еļ�¼
        FoodRec := OrderLB.Items.Objects[i] as TFoodRecord;
        // ������ǰѡ�м�¼��ÿһ��Ʒ��
        for j := 0 to Length(FoodRec.Foods) - 1 do
        begin
          // ��ǰѡ�еļ�¼�ĸ�Ʒ��
          DelFood := FoodRec.Foods[j] as TFood;
          // �����ǰѡ�еļ�¼�ĸ�Ʒ������������
          if DelFood.tp = '��������' then
          begin
            // �ӵ�ǰѡ�еļ�¼����һ����ʼ
            for k := i + 1 to OrderLB.Count - 1 do
            begin
              // decFlg := false;
              // ������ǰѡ�еļ�¼����һ����ÿ��Ʒ��
              nextFoodRecord := OrderLB.Items.Objects[k] as
                TFoodRecord;
              for m := 0 to Length(nextFoodRecord.Foods) - 1 do
              begin
                nextFood := nextFoodRecord.Foods[m] as TFood;
                if nextFood.tp = '��������' then
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
        // ��ǰԤ�����ƺż�1
        if decFlg then
          dec(tempForm.MaxNumber);
        stopFlg := true;
      end;
    end;
  end;
  // ɾ��ѡ�е���Ŀ
  OrderLB.DeleteSelected;
  // ����ɾ��֮����嵥list
  for i := 0 to OrderLB.Count - 1 do
  begin
    FoodRec := OrderLB.Items.Objects[i] as TFoodRecord;
    SetLength(saveFoodList, length(saveFoodList) + 1);
    saveFoodList[length(saveFoodList) - 1] := FoodRec;
  end;
  // ��ն���״̬��
  OrderLB.Clear;
  // ��֮ǰsaveFoodList�е���Ŀ���ո��¹����ƺ�������ʾ
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
    // ��ʾ���¹�����ƺ�,��Ҫ��ɾ���������µ����ݼ�1����ƺ�
    orderStr := IntToStr(GetPrintNo(FoodRec.OrderNumber)) + ':' +
      orderStr;
    OrderLB.AddItem(orderStr + ' -- ' + CurrToStr(FoodRec.amount) + 'Ԫ',
      FoodRec);
    totalAmount := totalAmount + FoodRec.amount;
  end;
  // ��ʾ�������ܼ�
  TotalAmountLbl.Caption := CurrToStr(totalAmount) + 'Ԫ';
  // ������������Ŀ����
  ClearSingleBtnClick(self);
end;

{����ƺ�}

function TOrderFrame.GetMaxNumber(MainForm: TmainForm): integer;
begin
  inc(MainForm.MaxNumber);
  GetMaxNumber := MainForm.MaxNumber;
end;

{�������ֵ}

function TOrderFrame.GetMaxSeq(MainForm: TmainForm): integer;
begin
  inc(MainForm.MaxKey);
  GetMaxSeq := MainForm.MaxKey;
end;

{���ȡģ�������ƺ�}

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

{������Ӱ�ť}

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
    messagebox(handle, 'Ŀǰû���κε�ͼ�¼�����ȵ�ͣ�',
      'δ���',
      mb_ok);
    exit;
  end;

  HasMainFood := false;
  MyForm := Owner as TmainForm;
  FoodRec := TFoodRecord.Create;
  totalAmount := 0;
  // �ѵ���״̬���е�ÿһ����¼�ӵ�FoodRec�����Foods������
  for i := 0 to SingleOrderLB.Count - 1 do
  begin
    TempFood := SingleOrderLB.Items.Objects[i] as TFood;
    if TempFood.tp = '��������' then
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
    // ��ִ�е�����״̬���еĵ�2����ʱ��,���� "+"
    if i <> 0 then
    begin
      if (TempFood.tp = '�汸ע') or (TempFood.tp = '����ע') then
      begin
        if not HasMainFood then
        begin
          messagebox(handle,
            '���б�ע���ݵĶ�������Ҫ����������������ȷ��ӣ�',
            '��Ӳ���',
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

  // �����û���������Ҳû����������,�������-1
  Number := -1;

  if not (length(trim(OrderNumberEdit.Text)) = 0) then
  begin
    if (strtoint(OrderNumberEdit.Text) <= 0) or (strtoint(OrderNumberEdit.Text)
      > 100) then
    begin
      messagebox(handle,
        '��ӵ��ƺŷ�Χֻ����1 ~ 100֮�䣬�����������ƺţ�',
        '������',
        mb_ok);
      OrderNumberEdit.SetFocus;
      exit;
    end;
    Number := StrToInt(trim(OrderNumberEdit.Text)) mod 100;
    // �����ֵ���ڵ�ǰ����, ����Ϊ�ǶԸ����ȥ�ŵ�׷��, ��ǰ��100����
    if Number > (MyForm.MaxNumber mod 100) then
    begin
      // ��ǰ���ų���100,�Ž��г�������
      if MyForm.MaxNumber >= 100 then
        Number := ((MyForm.MaxNumber div 100) - 1) * 100 + Number
      else
        Number := StrToInt(OrderNumberEdit.Text);
    end
    else
      // �����ֵС�ڵ�ǰ����,����Ϊ�ǶԽ���δ��100�����е�׷��
    begin
      // ��ǰ���ų���100,�Ž��г�������
      if MyForm.MaxNumber >= 100 then
        Number := (MyForm.MaxNumber div 100) * 100 + Number
      else
        Number := StrToInt(OrderNumberEdit.Text);
    end;
  end;
  // �����������,����
  if HasMainFood then
  begin
    Number := GetMaxNumber(MyForm);
  end;
  FoodRec.OrderNumber := Number;
  orderStr := IntToStr(GetPrintNo(Number)) + ':' + orderStr;
  FoodRec.insertTime := now();
  OrderLB.AddItem(orderStr + ' -- ' + CurrToStr(FoodRec.amount) + 'Ԫ',
    FoodRec);
  // ��������״̬���е����м�¼
  for i := 0 to OrderLB.Count - 1 do
  begin
    FoodRec := OrderLB.Items.Objects[i] as TFoodRecord;
    totalAmount := totalAmount + FoodRec.amount;
  end;
  // ����Ŀǰ���м�¼���ܼ�
  TotalAmountLbl.Caption := CurrToStr(totalAmount) + 'Ԫ';
  // ������������Ŀ����
  ClearSingleBtnClick(self);
end;

{ȷ�ϴ�ӡ��ť}

procedure TOrderFrame.PrintBtnClick(Sender: TObject);
var
  i: integer;
  j: integer;
  // Ԥ���ƺ�
  NextNumber: integer;
  FoodRecord: TFoodRecord;
  Food: TFood;
  orderADOQuery: TADOQuery;
  MyForm: TmainForm;
  // ����Ϣ
  //ds: TCopyDataStruct;
  hd: THandle;
begin
  if OrderLB.Items.Count = 0 then
  begin
    messagebox(handle, 'û���κζ�����¼����������һ�ݶ������ܴ�ӡ��',
      '�޶���',
      mb_ok);
    exit;
  end;
  MyForm := Owner as TmainForm;
  orderADOQuery := TADOQuery.Create(self);
  orderADOQuery.Connection := DBConnection;
  DBConnection.BeginTrans;
  // ��������״̬���е�������Ŀ
  for i := 0 to OrderLB.Count - 1 do
  begin
    FoodRecord := OrderLB.Items.Objects[i] as TFoodRecord;
    // ÿ�����ÿ��Ʒ�ֵ�¼�����ݿ�
    for j := 0 to length(FoodRecord.Foods) - 1 do
    begin
      Food := FoodRecord.Foods[j] as TFood;
      if (Food.tp = '��������') or (Food.tp = '�ɼӸ���') or (Food.tp =
        '�����̾�') then
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
  // ��ӡ
  if printeCheckBox.Checked then
    DoPrint;

  TotalAmountLbl.Caption := '0Ԫ';
  // ������������Ŀ����
  ClearSingleBtnClick(self);
  // �ͷ�ADO���ݿ����
  DBConnection.CommitTrans;
  orderADOQuery.Close;
  orderADOQuery.Free;
  // ��ʾԤ���ƺ�
  NextNumber := MyForm.MaxNumber + 1;
  Label4.Caption := '����(Ԥ��' + IntToStr(GetPrintNo(NextNumber)) + '��)';
  // ��������¼��
  displayorders(self);
  // ��ն�����
  OrderLB.Clear;
  // �����������δ�������򾯸�
  {Hd := FindWindow (nil, 'kitchendisplay'); // ��ý��ܴ��ڵľ��
  if Hd <= 0 then
    ShowMessage ('������ʾ����δ�򿪣�');
  }
  Hd := FindWindow(nil, 'kitchendisplay'); // ��ý��ܴ��ڵľ��
  if Hd > 0 then
  begin
    //������Ϣ
    sendMms(self);
  end
  else
    ShowMessage('������ʾ����δ�򿪣�');
end;

{������ʾ����}

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
  // ��������״̬���е�������Ŀ
  for i := 0 to OrderLB.Count - 1 do
  begin
    disString := '';
    disFoodRecord := OrderLB.Items.Objects[i] as TFoodRecord;
    // ����ÿ�����ÿ��Ʒ��
    //disOrderNumber := disFoodRecord.OrderNumber;
    for j := 0 to length(disFoodRecord.Foods) - 1 do
    begin
      disFood := disFoodRecord.Foods[j] as TFood;
      if (disFood.tp <> '�����̾�') then
      begin
        if j <> 0 then
        begin
          if (disFood.tp = '�汸ע') or (disFood.tp = '����ע') then
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
  // �ͷ�ADO���ݿ����
  disorderADOQuery.Close;
  disorderADOQuery.Free;
end;

{��ӡ����}

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
    Messagedlg('û�м�⵽��ӡ�������������Ѿ���д�뵽�������Ŀ�У����ʵ��',
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
      if (Food.tp <> '�����̾�') then
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
    // ��ӡ����ʼ��
    Write(Ptext, chr(27) + chr(64));
    // ���ú���ģʽ
    //Write(Ptext, chr(28) + chr(38));
    for i := 0 to OrderLB.Count - 1 do
    begin
      hasMainFoodFlg := false;
      hasOptFoodFlg := false;
      FoodRecord := OrderLB.Items.Objects[i] as TFoodRecord;
      for j := 0 to length(FoodRecord.Foods) - 1 do
      begin
        Food := FoodRecord.Foods[j] as TFood;
        if (Food.tp = '��������') then
        begin
          hasMainFoodFlg := true;
          break;
        end;
      end;
      if hasMainFoodFlg then
      begin
        // ���ñ��߱����ӡ��ʽ
        Write(Ptext, chr(27) + chr(33) + chr(48));
        // ��ӡ�ƺ�
        write(Ptext, IntToStr(GetPrintNo(FoodRecord.OrderNumber)));
        // ȡ�����߱����ӡ��ʽ
        Write(Ptext, chr(27) + chr(33) + chr(0));
        // ��ӡʱ��
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
          if (Food.tp <> '�����̾�') then
          begin
            if (j <> 0) then
            begin
              if (Food.tp = '�汸ע') or (Food.tp = '����ע') then
                FoodStr := FoodStr + ' '
              else
                FoodStr := FoodStr + '+';
            end;
            FoodStr := FoodStr + Food.name;
          end;
        end;
        // ���ñ��߱����ӡ��ʽ
        Write(Ptext, chr(27) + chr(33) + chr(48));
        // ��ӡ����
        writeln(Ptext, FoodStr);
        // ȡ�����߱����ӡ��ʽ
        Write(Ptext, chr(27) + chr(33) + chr(0));
        writeln(Ptext, '--------------------------------');
      end
      else
      begin
        for j := 0 to length(FoodRecord.Foods) - 1 do
        begin
          Food := FoodRecord.Foods[j] as TFood;
          if (Food.tp <> '�����̾�') then
          begin
            hasOptFoodFlg := true;
            break;
          end;
        end;
        if hasOptFoodFlg then
        begin
          // ���ñ��߱����ӡ��ʽ
          Write(Ptext, chr(27) + chr(33) + chr(48));
          // ��ӡ�ƺ�
          write(Ptext, IntToStr(GetPrintNo(FoodRecord.OrderNumber)));
          // ȡ�����߱����ӡ��ʽ
          Write(Ptext, chr(27) + chr(33) + chr(0));
          // ��ӡʱ��
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
          FoodStr := '���:';
          for j := 0 to length(FoodRecord.Foods) - 1 do
          begin
            Food := FoodRecord.Foods[j] as TFood;
            if (Food.tp <> '�����̾�') then
            begin
              if (j <> 0) then
                FoodStr := FoodStr + '+';
              FoodStr := FoodStr + Food.name;
            end;
          end;
          // ���ñ��߱����ӡ��ʽ
          Write(Ptext, chr(27) + chr(33) + chr(48));
          writeln(Ptext, FoodStr);
          // ȡ�����߱����ӡ��ʽ
          Write(Ptext, chr(27) + chr(33) + chr(0));
          writeln(Ptext, '--------------------------------');
        end;
      end;
    end;
    // ��ǰ��ֽ
    Write(Ptext, chr(27) + chr(74) + chr(120));
    CloseFile(Ptext); //ֹͣ��ӡ
  end;
end;

{�ƺű༭�������޶�}

procedure TOrderFrame.OrderNumberEditKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #13, #8]) then
    Key := #0;
end;

{����״̬��������Ŀ����}

procedure TOrderFrame.ClearSingleBtnClick(Sender: TObject);
begin
  // ��յ���״̬��
  SingleOrderLB.Clear;
  // �۸����
  SinglePriceLabel.Caption := '0Ԫ';
  // ���ñ༭��ť
  editButton.Enabled := false;
  // �����Ӱ�ť
  AddBtn.Enabled := true;
  // ״̬��������
  Label10.Caption := '���';
  Label10.Font.Color := clBlue;
  // ����ƺ������
  OrderNumberEdit.Clear;
  // ����Ӧ���������
  SetWidth(self.OrderLB);
end;

{��������״̬���е�һ����¼,���Ե�����״̬��,׼���޸�}

procedure TOrderFrame.OrderLBClick(Sender: TObject);
var
  i, j: integer;
  modifyFoodRecord: TFoodRecord;
  tmpFood: TFood;
begin
  // �������״̬��Ϊ��
  if OrderLB.Count = 0 then
  begin
    editButton.Enabled := false;
    exit;
  end;
  // ���ñ༭��Ŀ������Ʒ��Flg
  modifyHasMainFlg := false;
  // ��λ����ǰѡ�еļ�¼
  for i := 0 to OrderLB.Count - 1 do
  begin
    if OrderLB.Selected[i] then
      // ���Ե�����״̬����
    begin
      modifyFoodRecord := OrderLB.Items.Objects[i] as TFoodRecord;
      modifyFoodDateTime := modifyFoodRecord.insertTime;
      SingleOrderLB.Clear;
      for j := 0 to length(modifyFoodRecord.Foods) - 1 do
      begin
        tmpFood := modifyFoodRecord.Foods[j] as TFood;
        if (tmpFood.tp = '��������') then
          modifyHasMainFlg := true;
        if (tmpFood.tp <> '�汸ע') and (tmpFood.tp <> '����ע') then
        begin
          SingleOrderLB.AddItem(modifyFoodRecord.Foods[j].name + ' -- '
            +
            CurrToStr(modifyFoodRecord.Foods[j].price) + 'Ԫ',
            modifyFoodRecord.Foods[j]);
        end
        else
        begin
          SingleOrderLB.AddItem(modifyFoodRecord.Foods[j].name,
            modifyFoodRecord.Foods[j]);
        end;
      end;
      // ��ʾ����״̬���е��ܼ�
      SinglePriceLabel.Caption := CurrToStr(modifyFoodRecord.amount) +
        'Ԫ';
      ModifiedFoodOrderNum := modifyFoodRecord.OrderNumber;
      ModifiedFoodRowNum := i;
      if modifyFoodRecord.OrderNumber mod 100 = 0 then
        Label10.Caption := '�޸�100��'
      else
        Label10.Caption := '�޸�' + IntToStr(modifyFoodRecord.OrderNumber
          mod
          100) + '��';
      Label10.Font.Color := clRed;
      break;
    end;
  end;
  // ����༭��ť
  editButton.Enabled := true;
  // ������Ӱ�ť
  AddBtn.Enabled := false;
end;

{�޸İ�ť}

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
    messagebox(handle, '�޸ĵĵ�ͼ�¼����Ϊ�գ�����ȷ�޸ģ�',
      '�޸Ĳ���',
      mb_ok);
    exit;
  end;
  HasMainFlg := false;
  if not modifyHasMainFlg then
    for i := 0 to SingleOrderLB.Count - 1 do
    begin
      TmpFood := SingleOrderLB.Items.Objects[i] as TFood;
      if (TmpFood.tp = '��������') then
      begin
        messagebox(handle,
          '�޸���Ӹ��ϵĶ���ʱ��������׷����������������ȷ�޸ģ�',
          '�޸Ĳ���',
          mb_ok);
        exit;
      end;
    end
  else
  begin
    for i := 0 to SingleOrderLB.Count - 1 do
    begin
      TmpFood := SingleOrderLB.Items.Objects[i] as TFood;
      if TmpFood.tp = '��������' then
      begin
        HasMainFlg := true;
        break;
      end;
    end;
    if not HasMainFlg then
    begin
      messagebox(handle,
        '�޸ĺ������������Ķ���ʱ������Ҫ����һ����������������ȷ�޸ģ�',
        '�޸Ĳ���',
        mb_ok);
      exit;
    end;
  end;
  FoodRecord := TFoodRecord.Create();
  totalAmount := 0;
  // �ѵ���״̬���е�ÿһ����¼�ӵ�FoodRec�����Foods������
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
    // ��ִ�е�����״̬���еĵ�2����ʱ��,���� "+"
    if i <> 0 then
    begin
      if (TmpFood.tp = '�汸ע') or (TmpFood.tp = '����ע') then
      begin
        if not HasMainFlg then
        begin
          messagebox(handle,
            '�޸���Ӹ��ϵĶ���ʱ��������׷�ӱ�ע���ݣ�����ȷ�޸ģ�',
            '�޸Ĳ���',
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
    CurrToStr(FoodRecord.amount) + 'Ԫ', FoodRecord);
  // ��������״̬���е����м�¼
  for i := 0 to OrderLB.Count - 1 do
  begin
    FoodRecord := OrderLB.Items.Objects[i] as TFoodRecord;
    totalAmount := totalAmount + FoodRecord.amount;
  end;
  // ����Ŀǰ���м�¼���ܼ�
  TotalAmountLbl.Caption := CurrToStr(totalAmount) + 'Ԫ';
  // ���ñ༭��Ŀ������Ʒ��Flg
  modifyHasMainFlg := false;
  // ����״̬��������Ŀ����
  ClearSingleBtnClick(self);
end;

{�������������¼�}

procedure TOrderFrame.noodWeightLBClick(Sender: TObject);
var
  i: integer;
begin
  // ����ListBox����Ŀ
  for i := 0 to noodWeightLB.Count - 1 do
  begin
    // �����ǰ��Ŀѡ��
    if noodWeightLB.Selected[i] then
    begin
      // ��ѡ�е���Ŀ�ӵ�����״̬����
      addFoodToSingleLB(noodWeightLB.Items.Objects[i] as TFood);
      break;
    end;
  end;
end;

{��������ע��Ŀ}

procedure TOrderFrame.pepperLBClick(Sender: TObject);
var
  i: integer;
begin
  // ����ListBox����Ŀ
  for i := 0 to pepperLB.Count - 1 do
  begin
    // �����ǰ��Ŀѡ��
    if pepperLB.Selected[i] then
    begin
      // ��ѡ�е���Ŀ�ӵ�����״̬����
      addFoodToSingleLB(pepperLB.Items.Objects[i] as TFood);
      break;
    end;
  end;

end;

{����ListBoxˮƽ������}

procedure TOrderFrame.SetWidth(Sender: TListBox);
var
  i, w: Integer;
begin
  w := 0;
  with Sender do
  begin
    Canvas.Font.Name := '����';
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

{����Ҽ���Ϣ��׽}

procedure TOrderFrame.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  //����Ҽ����,�������Ӱ�ť����
  //if ((Msg.Message = WM_RBUTTONDOWN) or (Msg.Message=WM_RBUTTONUP)) then
  if (Msg.Message = WM_RBUTTONDOWN) then
  begin
    if Label10.Caption = '���' then
      AddBtnClick(self)
    else
      editButtonClick(self);
    Handled := True;
  end;
end;

{��ӡ���ؿ���}

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
  GetMem (ds.lpData, ds.cbData ); //Ϊ���ݵ������������ڴ�
  StrCopy (ds.lpData, PChar ('inputOk'));

  Hd := FindWindow (nil, 'kitchendisplay'); // ��ý��ܴ��ڵľ��
  if Hd > 0 then
    SendMessage (Hd, WM_COPYDATA, Handle,
                 Cardinal(@ds)) // ����WM_COPYDATA��Ϣ
  else
    ShowMessage ('��������δ�򿪣�');
    FreeMem (ds.lpData); //�ͷ���Դ
end;
}
end.

