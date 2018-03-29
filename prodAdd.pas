unit prodAdd;

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
  Grids,
  DBGrids,
  StdCtrls,
  DBCtrls,
  Mask,
  DB,
  ADODB,
  AppEvnts;

type
  TprodAddFrame = class(TFrame)
    prodDBGrid: TDBGrid;
    prodADOQuery: TADOQuery;
    prodDataSource: TDataSource;
    prodIdLabel: TLabel;
    prodNmLabel: TLabel;
    prodPriceLabel: TLabel;
    prodTypeLabel: TLabel;
    submitButton: TButton;
    abortSubButton: TButton;
    addButton: TButton;
    editButton: TButton;
    delButton: TButton;
    ApplicationEvents1: TApplicationEvents;
    prodNmEdit: TEdit;
    prodPriceEdit: TEdit;
    prodTypeCmbBox: TComboBox;
    prodIdEdit: TEdit;
    sqlModel: TLabel;
    mentionLabel: TLabel;
    procedure addButtonClick(Sender: TObject);
    procedure abortSubButtonClick(Sender: TObject);
    procedure delButtonClick(Sender: TObject);
    procedure submitButtonClick(Sender: TObject);
    procedure editButtonClick(Sender: TObject);
    procedure GoEditState();
    function IsDigit(S: string): Boolean;
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure refresh(keyValue: string);
    procedure prodDBGridCellClick(Column: TColumn);
    procedure prodDBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure prodPriceEditKeyPress(Sender: TObject; var Key: Char);
    procedure prodIdEditKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
uses login;
{$R *.dfm}

{�ж�һ���ַ����Ƿ�Ϊ����}

function TprodAddFrame.IsDigit(S: string): Boolean;
//����SΪҪ�жϵ��ַ���,����true����ȷ
var
  i, j: integer;
begin
  Result := True;
  if (trim(S) = '') then
    Result := False
  else
    begin
      j := 0;
      for i := 1 to length(s) do
        begin
          if not (s[i] in ['0'..'9', '.']) then
            //�ж��ַ���ÿ���ַ���s[i],�Ƿ�Ϊ"0"��'9"���ּ�".'
            Result := False;
          if s[i] = '.' then //ͳ���ַ�����"."�ĸ���
            j := j + 1;
        end;

      if j > 1 then //�ַ�����"."�ĸ�������1
        Result := False;

      if (s[1] = '.') or (s[length(s)] = '.') then
        //�ַ�����"."������ǰ��������
        Result := False;
      //����, �ַ�����"."��λ��֮ǰ������"0"�ж�
      s := copy(s, 1, pos('.', S) - 1); //ȡ�ַ�����"."��λ��֮ǰ�ַ�
      j := 0;
      for i := 1 to length(s) do
        begin
          if s[i] = '0' then
            j := j + 1;
        end;
      if j > 1 then //�ַ�����"."��λ��֮ǰ������"0"
        Result := False;
    end;
end;

{��Ӱ�ť}

procedure TprodAddFrame.addButtonClick(Sender: TObject);
begin
  {���Ʒ��}
  GoEditState();
  // �༭�����
  prodIdEdit.Clear;
  prodNmEdit.Clear;
  prodPriceEdit.Clear;
  // Ĭ�Ͻ�����ID�༭��
  prodIdEdit.SetFocus;
  // Ʒ�����Ĭ��ֵ "����"
  prodTypeCmbBox.ItemIndex := 0;
  mentionLabel.Caption := '���ܣ�������ϸȷ�����������ӣ�';
  mentionLabel.Visible := True;
  // �������,�ж���,����
  sqlModel.Caption := 'insert';
end;

{�޸İ�ť}

procedure TprodAddFrame.editButtonClick(Sender: TObject);
begin
  {�޸�Ʒ��}
  GoEditState();
  // �޸�ʱID���ɱ༭
  prodIdEdit.Enabled := False;
  // Ĭ�Ͻ��������Ʊ༭��
  prodNmEdit.SetFocus;
  mentionLabel.Caption := '���ܣ�������ϸȷ����������޸ģ�';
  mentionLabel.Visible := True;
  // �������,�ж���,����
  sqlModel.Caption := 'update';
end;

{ɾ����ť}

procedure TprodAddFrame.delButtonClick(Sender: TObject);
var
  priorId: string;
  delADOQuery: TADOQuery;
begin
  if messagebox(handle, pchar('ɾ����Ʒ�ֲ��ܱ��ָ����Ƿ�ɾ��Ʒ�� "' +
    prodNmEdit.Text + '" ��'), 'ȷ��ɾ��',
    mb_iconquestion + mb_yesno) = IDyes then
    begin
      // ��ָ����һ��
      prodADOQuery.Prior;
      // ������һ�е� Key
      priorId := prodADOQuery.FieldByName('prod_id').AsString;
      // ������ʱADO,����ɾ��
      delADOQuery := TADOQuery.Create(self);
      delADOQuery.Connection := DBConnection;
      with delADOQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add('delete from products where prod_id = :id');
          Parameters.ParamByName('id').Value := prodIdEdit.Text;
          ExecSQL;
        end;
      // �ͷ���ʱADO����
      delADOQuery.Close;
      delADOQuery.Free;
      // ˢ�²���λ����һ����¼
      refresh(priorId);
    end
  else
    // ���ȡ����,ˢ�¶�λ��ԭ�ȵļ�¼
    refresh(prodIdEdit.Text);
end;

{�����ύ��ť}

procedure TprodAddFrame.abortSubButtonClick(Sender: TObject);
begin
  // ����ˢ�»���
  refresh(prodIdEdit.Text);
end;

{�༭״̬��������}

procedure TprodAddFrame.GoEditState();
begin
  // ������Ŀ����
  // ���,�༭,ɾ����ť����
  delButton.Visible := False;
  editButton.Visible := False;
  addButton.Visible := False;
  // ���ݸ��༭��ɱ༭
  prodIdEdit.Enabled := True;
  prodNmEdit.Enabled := True;
  prodPriceEdit.Enabled := True;
  prodTypeCmbBox.Enabled := True;
  // �ύ,������ť�ɼ�
  submitButton.Visible := True;
  abortSubButton.Visible := True;
  prodIdEdit.SetFocus;
end;

{�ύ��ť}

procedure TprodAddFrame.submitButtonClick(Sender: TObject);
var
  prodId: string;
  tempNm_Id: string;
  idCount: integer;
  nmCount: integer;
  tempProdNm: string;
  updADOQuery: TADOQuery;
begin
  // ���浱ǰ��¼�� Key
  prodId := prodIdEdit.Text;
  tempProdNm := trim(prodNmEdit.Text);
  if (trim(prodIdEdit.Text) = '') then
    begin
      messagebox(handle, '������ı�Ų���Ϊ�գ����������롣',
        '�������',
        mb_ok);
      prodIdEdit.SetFocus;
      exit;
    end
  else
    if (trim(prodNmEdit.Text) = '') then
      begin
        messagebox(handle, '����������Ʋ���Ϊ�գ����������롣',
          '�������', mb_ok);
        prodNmEdit.SetFocus;
        exit;
      end
    else
      if (trim(prodTypeCmbBox.Text) = '') then
        begin
          messagebox(handle,
            '������������Ϊ�գ����������롣',
            '�������', mb_ok);
          prodTypeCmbBox.SetFocus;
          exit;
        end
      else
        if not IsDigit(prodPriceEdit.Text) then
          begin
            messagebox(handle,
              '������ļ۸������֣����������롣',
              '�������', mb_ok);
            prodPriceEdit.SetFocus;
            exit;
          end
        else
          if (StrToCurr(prodPriceEdit.Text) < 0) or
            (StrToCurr(prodPriceEdit.Text) >
            99.9) then
            begin
              messagebox(handle,
                '������ļ۸������ 0 ~ 99.9 ֮�䣬���������롣',
                '�������', mb_ok);
              prodPriceEdit.SetFocus;
              exit;
            end;
  // ������ʱADO����,���ڸ���
  updADOQuery := TADOQuery.Create(self);
  updADOQuery.Connection := DBConnection;
  // ����ǲ�������
  if sqlModel.Caption = 'insert' then
    begin
      with updADOQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add(' select count(*) as Cnt from products where prod_id = :id ');
          Parameters.ParamByName('id').Value := prodIdEdit.Text;
          Open;
          idCount := FieldByName('Cnt').AsInteger;
          Close;
          SQL.Clear;
          SQL.Add(' select prod_id, count(*) as Cnt from products where prod_nm = :nm group by prod_id ');
          Parameters.ParamByName('nm').Value := tempProdNm;
          Open;
          nmCount := FieldByName('Cnt').AsInteger;
          tempNm_Id := FieldByName('prod_id').AsString;
        end;
      if idCount <> 0 then
        begin
          refresh(prodId);
          messagebox(handle, pchar('����ӵ�Ʒ�ֱ��: "' + prodId +
            '" �Ѵ��ڣ������������š�'),
            '����Ѵ���',
            mb_ok);
          addButtonClick(self);
          exit;
        end
      else
        if nmCount <> 0 then
          begin
            refresh(tempNm_Id);
            messagebox(handle, pchar('����ӵ�����: "' +
              tempProdNm + '" �Ѵ��ڣ��������������ơ�'),
              '�����Ѵ���',
              mb_ok);
            addButtonClick(self);
            exit;
          end
        else
          begin
            with updADOQuery do
              begin
                Close;
                SQL.Clear;
                SQL.Add('insert into products(prod_id, prod_nm, prod_price, prod_type) values (:id, :nm, :price, :type)');
                Parameters.ParamByName('id').Value := prodIdEdit.Text;
                Parameters.ParamByName('nm').Value := prodNmEdit.Text;
                Parameters.ParamByName('price').Value :=
                  prodPriceEdit.Text;
                Parameters.ParamByName('type').Value :=
                  prodTypeCmbBox.Text;
                ExecSQL;
              end;
            refresh(prodId);
          end;
    end
      // ����ǽ����޸Ĳ���
  else
    if sqlModel.Caption = 'update' then
      begin
        with updADOQuery do
          begin
            Close;
            SQL.Clear;
            SQL.Add(' select prod_id, count(*) as Cnt from products where prod_nm = :nm and prod_id <> :prod_id group by prod_id ');
            Parameters.ParamByName('nm').Value := tempProdNm;
            Parameters.ParamByName('prod_id').Value := prodId;
            Open;
            nmCount := FieldByName('Cnt').AsInteger;
            tempNm_Id := FieldByName('prod_id').AsString;
          end;
        if nmCount <> 0 then
          begin
            refresh(tempNm_Id);
            messagebox(handle, pchar('���޸ĵ�����: "' +
              tempProdNm + '" �Ѵ��ڣ��������޸����ơ�'),
              '�����Ѵ���',
              mb_ok);
            addButtonClick(self);
            exit;
          end
        else
          begin
            with updADOQuery do
              begin
                Close;
                SQL.Clear;
                SQL.Add('update products set prod_nm = :nm, prod_price = :price, prod_type = :type where prod_id = :id');
                Parameters.ParamByName('id').Value := prodIdEdit.Text;
                Parameters.ParamByName('nm').Value := prodNmEdit.Text;
                Parameters.ParamByName('price').Value :=
                  prodPriceEdit.Text;
                Parameters.ParamByName('type').Value :=
                  prodTypeCmbBox.Text;
                ExecSQL;
              end;
            refresh(prodId);
          end;
      end;
  // �ͷ���ʱADO����
  updADOQuery.Close;
  updADOQuery.Free;
end;

{DBgrid ������, �������¼�}

procedure TprodAddFrame.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if (prodDBGrid.Focused) and (Msg.message = WM_MOUSEWHEEL) then
    begin
      if Msg.wParam > 0 then
        begin
          SendMessage(prodDBGrid.Handle, WM_KEYDOWN, VK_UP, 0);
          prodDBGrid.SelectedRows.CurrentRowSelected := true;
          prodDBGrid.SetFocus;
          prodIdEdit.Text := prodADOQuery.FieldByName('prod_id').AsString;
          prodNmEdit.Text :=
            prodADOQuery.fieldByName('prod_nm').AsString;
          prodPriceEdit.Text :=
            prodADOQuery.fieldByName('prod_price').AsString;
          prodTypeCmbBox.ItemIndex :=
            prodTypeCmbBox.Items.IndexOf(prodADOQuery.fieldByname('prod_type').AsString);
        end
      else
        begin
          SendMessage(prodDBGrid.Handle, WM_KEYDOWN, VK_DOWN, 0);
          prodDBGrid.SelectedRows.CurrentRowSelected := true;
          prodDBGrid.SetFocus;
          prodIdEdit.Text := prodADOQuery.FieldByName('prod_id').AsString;
          prodNmEdit.Text :=
            prodADOQuery.fieldByName('prod_nm').AsString;
          prodPriceEdit.Text :=
            prodADOQuery.fieldByName('prod_price').AsString;
          prodTypeCmbBox.ItemIndex :=
            prodTypeCmbBox.Items.IndexOf(prodADOQuery.fieldByname('prod_type').AsString);
        end;
      Handled := True;
    end;
end;

{����ˢ��}

procedure TprodAddFrame.refresh(keyValue: string);
begin
  // ���¼���
  prodADOQuery.Close;
  prodADOQuery.SQL.Clear;
  prodADOQuery.SQL.Add(' select * from products order by prod_id ');
  prodADOQuery.Open;
  prodADOQuery.Locate('prod_id', keyValue, []);
  ShowScrollBar(prodDBGrid.Handle, SB_HORZ, True);
  ShowScrollBar(prodDBGrid.Handle, SB_HORZ, False);
  prodDBGrid.SelectedRows.CurrentRowSelected := true;
  prodDBGrid.SetFocus;
  // ���༭�����ó�DBGridѡ���ж�Ӧ��ֵ
  prodIdEdit.Text := prodADOQuery.FieldByName('prod_id').AsString;
  prodNmEdit.Text :=
    prodADOQuery.fieldByName('prod_nm').AsString;
  prodPriceEdit.Text :=
    prodADOQuery.fieldByName('prod_price').AsString;
  prodTypeCmbBox.ItemIndex :=
    prodTypeCmbBox.Items.IndexOf(prodADOQuery.fieldByname('prod_type').AsString);
  // ���,�޸�,ɾ����ť�ɼ�
  addButton.Visible := True;
  editButton.Visible := True;
  delButton.Visible := True;
  // ���༭�򲻿ɱ༭
  prodIdEdit.Enabled := False;
  prodNmEdit.Enabled := False;
  prodPriceEdit.Enabled := False;
  prodTypeCmbBox.Enabled := False;
  // �ύ,������ť���ɼ�
  submitButton.Visible := False;
  abortSubButton.Visible := False;
  // ��ʾ���ֲ��ɼ�
  mentionLabel.Visible := False;
end;

{DBgrid Cell ����¼�, ͬ���趨ֵ���༭��}

procedure TprodAddFrame.prodDBGridCellClick(Column: TColumn);
begin
  prodIdEdit.Text := prodADOQuery.FieldByName('prod_id').AsString;
  prodNmEdit.Text :=
    prodADOQuery.fieldByName('prod_nm').AsString;
  prodPriceEdit.Text :=
    prodADOQuery.fieldByName('prod_price').AsString;
  prodTypeCmbBox.ItemIndex :=
    prodTypeCmbBox.Items.IndexOf(prodADOQuery.fieldByname('prod_type').AsString);
end;

{DBGridѡ���б�ɫ}

procedure TprodAddFrame.prodDBGridDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  if gdSelected in State then
    with prodDBGrid do
      begin
        Canvas.Brush.Color := clMoneyGreen;
        Canvas.FillRect(Rect);
        Canvas.Font.Color := clBlack;
        Canvas.TextOut(Rect.Left, Rect.Top, Column.Field.AsString);
      end
  else
    with prodDBGrid do
      begin
        Canvas.Brush.Color := clWindow;
        Canvas.FillRect(Rect);
        Canvas.Font.Color := clBlack;
        Canvas.TextOut(Rect.Left, Rect.Top, Column.Field.AsString);
      end;
  prodDBGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

{�۸�༭��������Χ}

procedure TprodAddFrame.prodPriceEditKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', '.', #13, #8]) then
    Key := #0;
end;

{��ű༭��������Χ}

procedure TprodAddFrame.prodIdEditKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #13, #8]) then
    Key := #0;
end;

end.
