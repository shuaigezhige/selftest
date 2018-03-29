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

{清空近期表}

procedure TdataDelMan.DelRencBtnClick(Sender: TObject);
var
  delADOQuery: TADOQuery;
begin
  if messagebox(handle,
    pchar('删除的数据不能被恢复，是否删除近三个月内的所有历史订单？'),
    '确认删除',
    mb_iconquestion + mb_yesno) = IDyes then
    begin
      // 创建临时ADO对象,用于更新
      delADOQuery := TADOQuery.Create(self);
      delADOQuery.Connection := DBConnection;
      with delADOQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add(' delete from sales where 1=1 ');
          ExecSQL;
        end;
      // 释放ADO数据库对象
      delADOQuery.Close;
      delADOQuery.Free;
      messagebox(handle, '数据已被清空！', '完成', mb_iconwarning + mb_ok);
      exit;
    end;
end;

{清空历史表}

procedure TdataDelMan.DelPastBtnClick(Sender: TObject);
var
  delADOQuery: TADOQuery;
begin
  if messagebox(handle,
    pchar('删除的数据不能被恢复，是否删除近三个月内的所有历史订单？'),
    '确认删除',
    mb_iconquestion + mb_yesno) = IDyes then
    begin
      // 创建临时ADO对象,用于更新
      delADOQuery := TADOQuery.Create(self);
      delADOQuery.Connection := DBConnection;
      with delADOQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add(' delete from his_sales where 1=1 ');
          ExecSQL;
        end;
      // 释放ADO数据库对象
      delADOQuery.Close;
      delADOQuery.Free;
      messagebox(handle, '数据已被清空！', '完成', mb_iconwarning + mb_ok);
      exit;
    end;
end;

end.
