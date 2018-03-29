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
// ����Ʒ������
type
  TFood = class
    id: string;
      name: string;
    price: Currency;
    tp: string;
    seq: integer;
  end;
  // Ʒ���������
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

{���Ͻǹرհ�ť}

procedure TmainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // �رմ���
  self.Close;
  // �˻ص���½����
  userLogin.show;
  // �������ͷ�
  self.Release;
end;

{�û�����ť}

procedure TmainForm.userManageButtonClick(Sender: TObject);
var
  i: integer;
begin
  // ������е�Frame
  logoImage.Visible := False;
  for i := 0 to self.ComponentCount - 1 do
    if (self.Components[i] is Tframe) then
      (self.Components[i] as Tframe).Free;

  // ������Ӧ���û�����Frame
  with TuserEditFrame.Create(self) do
    begin
      Parent := self;
      // Frame��ʾλ��
      Left := 131;
      Top := 16;
      // ����Frame��ADOQuery�������ִ�
      userEditADOQuery.Connection := DBConnection;
      // ˢ��Frame���Ҽ�¼��λ����ǰ�û���һ��
      refresh(login.UserName);
      // �û�������ֻ��ѡ���ɱ༭
      userGrpCmbBox.Style := csDropDownList;
      // ���ݿ��������ж���
      sqlModel.Visible := False;
      // ��ʾFrame
      Show;
    end;
end;

{�˳���ť}

procedure TmainForm.exitButtonClick(Sender: TObject);
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

{Ʒ�ֹ���ť}

procedure TmainForm.prodDefButtonClick(Sender: TObject);
var
  i: integer;
begin
  // ������е�Frame
  logoImage.Visible := False;
  for i := 0 to self.ComponentCount - 1 do
    if (self.Components[i] is Tframe) then
      (self.Components[i] as Tframe).Free;

  // ������Ӧ��Ʒ�ֹ���Frame
  with TprodAddFrame.Create(self) do
    begin
      // ��ʾλ��
      Parent := self;
      Left := 131;
      Top := 16;
      prodADOQuery.Connection := DBConnection;
      // ���ڻ��򿪶�λ����һ��
      refresh('-1');
      // Ʒ���������ֻ��ѡ���ɱ༭
      prodTypeCmbBox.Style := csDropDownList;
      // ���ݿ��������ж���
      sqlModel.Visible := False;
      // ��ʾFrame
      Show;
    end;
end;

{�����ѯ}

procedure TmainForm.dailyQueryButtonClick(Sender: TObject);
var
  i: integer;
begin
  // ������е�Frame
  logoImage.Visible := False;
  for i := 0 to self.ComponentCount - 1 do
    if (self.Components[i] is Tframe) then
      (self.Components[i] as Tframe).Free;

  // ������Ӧ��Ʒ�ֹ���Frame
  with TdailyQueryFrame.Create(self) do
    begin
      // ��ʾλ��
      Parent := self;
      Left := 131;
      Top := 16;
      searchADOQuery.Connection := DBConnection;
      groupADOQuery.Connection := DBConnection;
      // ���ڻ��򿪶�λ����һ��
      refresh(-1);
      // ��ѯ������Բ���ѡ���ɱ༭
      typeCmbBox.Style := csDropDownList;
      typeCmbBox.ItemIndex := 0;
      typeCmbBox.Enabled := false;
      // ��ʾFrame
      Show;
    end;
end;

{��ʷ��ѯ}

procedure TmainForm.hisQueryButtonClick(Sender: TObject);
var
  i: integer;
begin
  // ������е�Frame
  logoImage.Visible := False;
  for i := 0 to self.ComponentCount - 1 do
    if (self.Components[i] is Tframe) then
      (self.Components[i] as Tframe).Free;

  // ������Ӧ��Ʒ�ֹ���Frame
  with ThisQueryFrame.Create(self) do
    begin
      // ��ʾλ��
      Parent := self;
      Left := 131;
      Top := 16;
      searchADOQuery.Connection := DBConnection;
      groupADOQuery.Connection := DBConnection;
      // �趨��ʼ����2��ʱ��ؼ���ʱ��ֵ
      startDateTime.Date := StrToDate(FormatdateTime('yyyy-mm-dd', now));
      startDateTime.Time := StrToTime('00:00:00');
      endDateTime.Date := StrToDate(FormatdateTime('yyyy-mm-dd', now));
      endDateTime.Time := StrToTime('23:59:59');
      // ���ڻ��򿪶�λ����һ��
      refresh(-1);
      // CheckBoxĬ��ѡ��"��3����"
      recentRadBtn.Checked := true;
      hisMonthsRadBtn.Checked := False;
      // ��ѯ������Բ���ѡ���ɱ༭
      typeCmbBox.Style := csDropDownList;
      typeCmbBox.ItemIndex := 0;
      typeCmbBox.Enabled := false;
      // ��ʾFrame
      Show;
    end;
end;

{�˿͵��}

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
  // Ԥ���ƺ�
  NextNumber: integer;
  printerSwitch: string;
begin
  // ������е�Frame
  logoImage.Visible := False;
  for i := 0 to self.ComponentCount - 1 do
    if (self.Components[i] is Tframe) then
      (self.Components[i] as Tframe).Free;

  // �����µĹ˿͵��Frame
  newOrderFrame := TOrderFrame.Create(self);

  // �������ݿ��������
  CountADOQuery := TADOQuery.Create(self);
  // ����ADOQuery�������ݿ��ִ�
  CountADOQuery.Connection := DBConnection;
  CountADOQuery.Close;
  CountADOQuery.SQL.Clear;
  // ������ǰ�����ƺź�Ψһ������
  CountADOQuery.SQL.Add('select max(order_no) as mo, max(sale_date) as maxdate from sales where order_no <> -1');
  CountADOQuery.Open;
  // �����Ϊ��˵������ʷ����,�Խ���׼�������ĺ�����д���
  if not CountADOQuery.IsEmpty then
    begin
      maxDate := CountADOQuery.FieldByName('maxdate').AsDateTime;
      //�����ǰ���ڲ�����ĿǰDB���������,�������ĺ��벻����100
      if (int(strtodate(FormatdateTime('yyyy-mm-dd', now))) >
        int(strtodate(FormatdateTime('yyyy-mm-dd', maxDate)))) and
        (CountADOQuery.FieldByName('mo').AsInteger mod 100 <> 0) then
        // ����Ϊ����һ��Ŀ�ʼ,����һ�εĺ��벹����100,׼����1��ʼ����
        self.MaxNumber := ((CountADOQuery.FieldByName('mo').AsInteger
          div 100) + 1) * 100
      else
        // �����ǰ���ڵ��ڻ����ĿǰDB���������,��������������100����ȡ��Ŀǰ����
        self.MaxNumber := CountADOQuery.FieldByName('mo').AsInteger;
      // ������һֱʹ��Ŀǰ����Keyֵ,������ǰ����Ψһ������
      CountADOQuery.SQL.Clear;
      CountADOQuery.SQL.Add('select max(uniq_key) as mk from sales');
      CountADOQuery.Open;
      self.MaxKey := CountADOQuery.FieldByName('mk').AsInteger;
    end;
  // �ͷ���ʱADO����
  CountADOQuery.Close;
  CountADOQuery.Free;

  // �˿͵��Frame����
  with newOrderFrame do
    begin
      //��ʾλ��
      Parent := self;
      Left := 131;
      Top := 16;
      // ��������ListBox���
      MainFoodLB.Clear;
      // ����ListBox���
      OptionFoodLB.Clear;
      // ����״̬��ListBox���
      SingleOrderLB.Clear;
      // ����״̬��ListBox���
      OrderLB.Clear;

      // ������ʱADO�ؼ�,�������Ʒ������
      OrderADOQuery := TADOQuery.Create(self);
      OrderADOQuery.Connection := DBConnection;
      OrderADOQuery.Close;
      OrderADOQuery.SQL.Clear;
      // ����Ʒ��Master��
      OrderADOQuery.SQL.Add(' SELECT PROD_ID,PROD_NM,PROD_PRICE, PROD_TYPE FROM PRODUCTS ORDER BY PROD_ID');
      OrderADOQuery.Open;

      while not OrderADOQuery.Eof do
        begin
          // Ʒ��ID
          PridId := OrderADOQuery.FieldByName('PROD_ID').AsString;
          // Ʒ������
          ProdNm := OrderADOQuery.FieldByName('PROD_NM').AsString;
          // Ʒ�ּ۸�
          prodPrice := OrderADOQuery.FieldByName('PROD_PRICE').AsCurrency;
          // Ʒ�����
          prodType := OrderADOQuery.FieldByName('PROD_TYPE').AsString;
          // �������۶��󱣴�ÿ��Ʒ�ֵ�����
          TempFood := TFood.Create();
          TempFood.id := PridId;
          TempFood.name := ProdNm;
          TempFood.price := prodPrice;
          TempFood.tp := ProdType;

          if (ProdType = '��������') then
            begin
              // ���������ӵ���������ListBox
              MainFoodLB.AddItem(TempFood.name + ' -- '
                + CurrToStr(TempFood.price) + 'Ԫ', TempFood);
            end
          else
            if (ProdType = '�ɼӸ���') then
              begin
                // �ɼӸ��ϼӵ��ɼӸ���ListBox
                OptionFoodLB.AddItem(TempFood.name + ' -- '
                  + CurrToStr(TempFood.price) + 'Ԫ', TempFood);
              end
            else
              if (ProdType = '�����̾�') then
                begin
                  // �����̾Ƽӵ��ɼӸ���ListBox
                  OptionFoodLB.AddItem(TempFood.name + ' -- '
                    + CurrToStr(TempFood.price) + 'Ԫ', TempFood);
                end
              else
                if (ProdType = '�汸ע') then
                  begin
                    // �汸ע�ӵ��汸עListBox
                    noodWeightLB.AddItem(TempFood.name, TempFood);
                  end
                else
                  if (ProdType = '����ע') then
                    begin
                      // ����ע�ӵ�����עListBox
                      pepperLB.AddItem(TempFood.name, TempFood);
                    end;
          // ѭ��������һ����¼
          OrderADOQuery.Next;
        end;
      // �ͷ���ʱADO����
      OrderADOQuery.Close;
      OrderADOQuery.Free;
      Label10.Caption := '���';
      Label10.Font.Color := clBlue;
      // ��ʾԤ���ƺ�
      NextNumber := self.MaxNumber + 1;
      Label4.Caption := '����(Ԥ��' + IntToStr(GetPrintNo(NextNumber)) + '��)';
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

{˳������,Ԥ������,Ŀǰ��ʹ��}

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
  // ������е�Frame
  logoImage.Visible := False;
  for i := 0 to self.ComponentCount - 1 do
    if (self.Components[i] is Tframe) then
      (self.Components[i] as Tframe).Free;
  // ������Ӧ��Frame
  with TadditionFrame.Create(self) do
    begin
      Parent := self;
      Left := 131;
      Top := 16;
      OrderADOQuery := TADOQuery.Create(self);
      OrderADOQuery.Connection := DBConnection;
      OrderADOQuery.Close;
      OrderADOQuery.SQL.Clear;
      // ����Master��
      OrderADOQuery.SQL.Add(' SELECT PROD_ID,PROD_NM,PROD_PRICE, PROD_TYPE FROM PRODUCTS ORDER BY PROD_ID');
      OrderADOQuery.Open;
      // �����̾�ListBox���
      drinksLB.Clear;
      // ����״̬��ListBox���
      SingleOrderLB.Clear;
      while not OrderADOQuery.Eof do
        begin
          // Ʒ��ID
          PridId := OrderADOQuery.FieldByName('PROD_ID').AsString;
          // Ʒ������
          ProdNm := OrderADOQuery.FieldByName('PROD_NM').AsString;
          // Ʒ�ּ۸�
          prodPrice := OrderADOQuery.FieldByName('PROD_PRICE').AsCurrency;
          // Ʒ�����
          prodType := OrderADOQuery.FieldByName('PROD_TYPE').AsString;
          // �������۶��󱣴�ÿ��Ʒ�ֵ�����
          TempFood := TFood.Create();
          TempFood.id := PridId;
          TempFood.name := ProdNm;
          TempFood.price := prodPrice;
          TempFood.tp := ProdType;

          if (ProdType = '�����̾�') then
            begin
              // �����̾Ƽӵ������̾�ListBox
              drinksLB.AddItem(TempFood.name + ' -- '
                + CurrToStr(TempFood.price) + 'Ԫ', TempFood);
            end;
          // ѭ��������һ����¼
          OrderADOQuery.Next;
        end;
      // �ͷ���ʱADO����
      OrderADOQuery.Close;
      OrderADOQuery.Free;
      Show;
    end;
end;

{���ݹ���ť}

procedure TmainForm.datManageButtonClick(Sender: TObject);
var
  i: integer;
begin
  // ������е�Frame
  logoImage.Visible := False;
  for i := 0 to self.ComponentCount - 1 do
    if (self.Components[i] is Tframe) then
      (self.Components[i] as Tframe).Free;

  // ������Ӧ�����ݹ���Frame
  with TdataDelMan.Create(self) do
    begin
      // ��ʾλ��
      Parent := self;
      Left := 131;
      Top := 16;
      // ��ʾFrame
      Show;
    end;
end;

end.
