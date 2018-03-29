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
  // ����ListBox����Ŀ
  for i := 0 to drinksLB.Count - 1 do
    begin
      // �����ǰ��Ŀѡ��
      if drinksLB.Selected[i] then
        begin
          // ��ѡ�е���Ŀ�ӵ�����״̬����
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
      messagebox(handle, 'Ŀǰû���κζ�����¼,��������һ�ݶ�������ȷ�ϣ�',
        '�޶���',
        mb_ok);
      exit;
    end;
  MyForm := Owner as TmainForm;
  orderADOQuery := TADOQuery.Create(self);
  orderADOQuery.Connection := DBConnection;
  // ��������״̬���е�������Ŀ
  for i := 0 to SingleOrderLB.Count - 1 do
    begin
      Food := SingleOrderLB.Items.Objects[i] as TFood;
      if (Food.tp = '�����̾�') then
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
  //TotalAmountLbl.Caption := '0Ԫ';
  ClearBtnClick(self);
  orderADOQuery.Close;
  orderADOQuery.Free;
  //editButton.Enabled := false;
  //AddBtn.Enabled := True;
  //Label10.Caption := '���';
  //Label10.Font.Color := clBlue;
  // DoPrint;
end;

procedure TadditionFrame.ClearBtnClick(Sender: TObject);
begin
  SingleOrderLB.Clear;
  SinglePriceLabel.Caption := '0Ԫ';
end;

function TadditionFrame.GetMaxSeq(MainForm: TmainForm): integer;
begin
  inc(MainForm.MaxKey);
  GetMaxSeq := MainForm.MaxKey;
end;

{����״̬�������Ŀ}

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
      // �ݴ�����������1
      SetLength(OptionFoodArr, length(OptionFoodArr) + 1);
      // ����ǰ��Ʒ����ӵ������ĩβ
      OptionFoodArr[length(OptionFoodArr) - 1] := NFood;
      {
      // �����ǰ�����Ķ���������������ʵ��
      if (TempFood.tp = '��������') then
        begin
          // �����渳ֵΪ��ǰ����
          MainFood := NFood;
        end

      // �����ǿɼӸ��ϵ�ʵ��
      else
        if (TempFood.tp <> '�汸ע') and (TempFood.tp <> '����ע') then
          begin
            // �ɼӸ�������������1
            SetLength(OptionFoodArr, length(OptionFoodArr) + 1);
            // ����ǰ�ĸ��ϼӵ����������ĩβ
            OptionFoodArr[length(OptionFoodArr) - 1] := NFood;
          end
        else
          if (TempFood.tp = '�汸ע') then
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
  // ����״̬�����������,�����ܼ���Ϊ0
  SingleOrderLB.Clear;
  TotalPrice := 0;
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
  {
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
        //TotalPrice := TotalPrice + Food.price;
      end
    else
      // ������ݵĲ����ǿɼӸ���
      if (Food.tp = '�ɼӸ���') then
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
        end
      else
        // ������ݵĲ������汸ע
        if (Food.tp = '�汸ע') then
          begin
            // �����ǰ��¼����������
            if MainFood <> nil then
              begin
                SingleOrderLB.AddItem(MainFood.name + ' -- ' +
                  CurrToStr(MainFood.price) + 'Ԫ', MainFood);
                // ��������ļ۸�Ҳ����
                TotalPrice := TotalPrice + MainFood.price;
                for i := 0 to Length(OptionFoodArr) - 1 do
                  begin
                    SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
                      CurrToStr(OptionFoodArr[i].price) + 'Ԫ',
                      OptionFoodArr[i]);
                    TotalPrice := TotalPrice + OptionFoodArr[i].price;
                  end;
                // ����汸ע
                mianComment := nil;
                mianComment := TFood.Create();
                mianComment.id := Food.id;
                mianComment.name := Food.name;
                mianComment.price := Food.price;
                mianComment.tp := Food.tp;
                SingleOrderLB.AddItem(mianComment.name, mianComment);
                // ���������ע,��ʾ����ע
                if pepperComment <> nil then
                  SingleOrderLB.AddItem(pepperComment.name, pepperComment);
              end
            else
              // �����ǰ��¼��û��������,������汸ע,������ʾ֮ǰ�ĸ���
              for i := 0 to Length(OptionFoodArr) - 1 do
                begin
                  SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
                    CurrToStr(OptionFoodArr[i].price) + 'Ԫ',
                    OptionFoodArr[i]);
                  TotalPrice := TotalPrice + OptionFoodArr[i].price;
                end;
          end
        else
          // ������ݵĲ���������ע
          if (Food.tp = '����ע') then
            begin
              // �����ǰ��¼����������
              if MainFood <> nil then
                begin
                  SingleOrderLB.AddItem(MainFood.name + ' -- ' +
                    CurrToStr(MainFood.price) + 'Ԫ', MainFood);
                  // ��������ļ۸�Ҳ����
                  TotalPrice := TotalPrice + MainFood.price;
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
                  pepperComment := nil;
                  pepperComment := TFood.Create();
                  pepperComment.id := Food.id;
                  pepperComment.name := Food.name;
                  pepperComment.price := Food.price;
                  pepperComment.tp := Food.tp;
                  SingleOrderLB.AddItem(pepperComment.name, pepperComment);
                end
              else
                // ���û��������,���������ע,������ʾ֮ǰ�ĸ���
                for i := 0 to Length(OptionFoodArr) - 1 do
                  begin
                    SingleOrderLB.AddItem(OptionFoodArr[i].name + ' -- ' +
                      CurrToStr(OptionFoodArr[i].price) + 'Ԫ',
                      OptionFoodArr[i]);
                    TotalPrice := TotalPrice + OptionFoodArr[i].price;
                  end;
            end;
            }
  SinglePriceLabel.Caption := CurrToStr(TotalPrice) + 'Ԫ';
end;
end.
