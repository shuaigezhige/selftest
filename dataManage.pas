unit dataManage;

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
  ADODB;

type
  TdataDelMan = class(TFrame)
    DelRencBtn: TButton;
    DelPastBtn: TButton;
    NoteLable: TLabel;
    procedure DelRencBtnClick(Sender: TObject);
    procedure DelPastBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
uses login;
{$R *.dfm}

{��ս��ڱ�}

procedure TdataDelMan.DelRencBtnClick(Sender: TObject);
var
  delADOQuery: TADOQuery;
begin
  if messagebox(handle,
    pchar('ɾ�������ݲ��ܱ��ָ����Ƿ�ɾ�����������ڵ�������ʷ������'),
    'ȷ��ɾ��',
    mb_iconquestion + mb_yesno) = IDyes then
    begin
      // ������ʱADO����,���ڸ���
      delADOQuery := TADOQuery.Create(self);
      delADOQuery.Connection := DBConnection;
      with delADOQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add(' delete from sales where 1=1 ');
          ExecSQL;
        end;
      // �ͷ�ADO���ݿ����
      delADOQuery.Close;
      delADOQuery.Free;
      messagebox(handle, '�����ѱ���գ�', '���', mb_iconwarning + mb_ok);
      exit;
    end;
end;

{�����ʷ��}

procedure TdataDelMan.DelPastBtnClick(Sender: TObject);
var
  delADOQuery: TADOQuery;
begin
  if messagebox(handle,
    pchar('ɾ�������ݲ��ܱ��ָ����Ƿ�ɾ�����������ڵ�������ʷ������'),
    'ȷ��ɾ��',
    mb_iconquestion + mb_yesno) = IDyes then
    begin
      // ������ʱADO����,���ڸ���
      delADOQuery := TADOQuery.Create(self);
      delADOQuery.Connection := DBConnection;
      with delADOQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add(' delete from his_sales where 1=1 ');
          ExecSQL;
        end;
      // �ͷ�ADO���ݿ����
      delADOQuery.Close;
      delADOQuery.Free;
      messagebox(handle, '�����ѱ���գ�', '���', mb_iconwarning + mb_ok);
      exit;
    end;
end;

end.
