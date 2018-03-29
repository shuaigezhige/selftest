unit exclToRep_func;

interface
uses forms,
  SysUtils,
  ComCtrls,
  DBGrids,
  DB,
  Dialogs,
  Messages,
  Windows,
  ComObj,
  Controls,
  ADODB,
  StdCtrls,
  Printers,
  Graphics;

function ProgressBarform(max: integer): tProgressBar;
procedure ExportToExcel(dbgrid: tdbgrid; SumADOQuery: TADOQuery; info: string);
procedure PrintAmout(noodleAmout: Currency; optiAmout: Currency; drinkAmout: Currency; totalAmout: Currency; info: string);
//function queryExportToExcel(queryexport: tadoquery): boolean;

implementation

//����һ����ʾ�������Ĵ���

function ProgressBarform(max: integer): tProgressBar;
var
  ProgressBar1: TProgressBar;
  form: tform;
begin
  application.CreateForm(tform, form);
  form.Position := poScreenCenter;
  form.BorderStyle := bsnone;
  form.Height := 30;
  form.Width := 260;
  ProgressBar1 := TProgressBar.Create(form);
  ProgressBar1.Visible := true;
  ProgressBar1.Smooth := true;
  ProgressBar1.Max := max;
  ProgressBar1.ParentWindow := form.Handle;
  ProgressBar1.Height := 20;
  ProgressBar1.Width := 250;
  ProgressBar1.Left := form.Left + 5;
  ProgressBar1.Top := form.Top + 5;
  ProgressBar1.Step := 1;
  form.show;
  result := ProgressBar1;
end;

//��DBGRID�е����ݵ��뵽EXCEL��

procedure ExportToExcel(dbgrid: tdbgrid; SumADOQuery: TADOQuery; info: string);
const
  xlNormal = -4143;
var
  i, j, k: integer;
  str, filename: string;
  excel: OleVariant;
  SavePlace: TBookmark;
  savedialog: tsavedialog;
  ProgressBar1: TProgressBar;
  ExeRoot: string;
  noodleAmout: Currency;
  optiAmout: Currency;
  drinkAmout: Currency;
  totalAmout: Currency;
  typeStr_1: string;
  typeStr_2: string;
  typeStr_3: string;
begin
  typeStr_1 := '��������';
  typeStr_2 := '�ɼӸ���';
  typeStr_3 := '�����̾�';
  noodleAmout := 0;
  totalAmout := 0;
  optiAmout := 0;
  drinkAmout := 0;
  // result := false;
  filename := '';
  if dbgrid.DataSource.DataSet.RecordCount > 65000 then
    begin
      if
        application.messagebox('��Ҫ���������ݹ���һ����󵼳�65000��,�Ƿ�Ҫ������', 'ѯ��', mb_yesno + mb_iconquestion) = idno then
        exit;
    end;
  screen.Cursor := crHourGlass;
  try
    excel := CreateOleObject('Excel.Application');
    excel.workbooks.add;
  except
    screen.cursor := crDefault;
    showmessage('�޷�����Excel��');
    exit;
  end;
  savedialog := tsavedialog.Create(nil);
  // ��ó�������·��
  // ChDir(ExtractFilePath(Application.ExeName));
  // ��õ�ǰ·�����ַ���
  ExeRoot := GetCurrentDir;
  savedialog.InitialDir := GetCurrentDir + '\Reports';
  savedialog.FileName := info;
  savedialog.Filter := 'Excel�ļ�(*.xls)|*.xls';
  if savedialog.Execute then
    begin
      if FileExists(savedialog.FileName) then
        try
          if application.messagebox('���ļ��Ѿ����ڣ�Ҫ������', 'ѯ��',
            mb_yesno + mb_iconquestion) = idyes then
            // ɾ���Ѵ��ڵ��ļ�
            DeleteFile(PChar(savedialog.FileName))
          else
            begin
              // �����˳�
              Excel.Quit;
              savedialog.free;
              screen.cursor := crDefault;
              Exit;
            end;
        except
          // �쳣����˳�
          Excel.Quit;
          savedialog.free;
          screen.cursor := crDefault;
          Exit;
        end;
      // �����ļ���
      filename := savedialog.FileName;
    end;
  // �ͷű���Ի���
  savedialog.free;
  // application.ProcessMessages;
  // ����ļ���Ϊ��, �˳�
  if filename = '' then
    begin
      // result := false;
      Excel.Quit;
      screen.cursor := crDefault;
      exit;
    end;
  k := 0;
  for i := 0 to dbgrid.Columns.count - 1 do
    begin
      // ���DBGrid�ĵ�ǰ�пɼ�
      if dbgrid.Columns.Items[i].Visible then
        begin
          //Excel.Columns[k+1].ColumnWidth:=dbgrid.Columns.Items[i].Title.Column.Width;
          // �趨EXCEL�ļ�CELL��ֵΪDBGrid���б���
          excel.cells[1, k + 1] := dbgrid.Columns.Items[i].Title.Caption;
          inc(k);
        end;
    end;
  Excel.ActiveSheet.Rows[1].Font.Bold := True;
  Excel.ActiveSheet.Rows[1].Font.Color := clBlue;
  Excel.ActiveSheet.Rows[1].Font.Size := 12;
  // ����DBGrid�ؼ�
  dbgrid.DataSource.DataSet.DisableControls;
  // ���浱ǰDBGrid�����еı��
  saveplace := dbgrid.DataSource.DataSet.GetBookmark;
  // DBGrid��DataSourceָ���һ����¼
  dbgrid.DataSource.dataset.First;
  i := 2;
  // iָ����һ��(��2��)
  // �����������65000��
  if dbgrid.DataSource.DataSet.recordcount > 65000 then
    // ����������������Ϊ65000
    ProgressBar1 := ProgressBarform(65000)
  else
    // ����û�г���65000��,����������������ΪDataSource����������
    ProgressBar1 := ProgressBarform(dbgrid.DataSource.DataSet.recordcount);
  // ��DBGrid��DataSource��Ϊ��ʱ
  while not dbgrid.DataSource.dataset.Eof do
    // ѭ������DataSource��ÿһ��ÿһ��CELL��ֵ
    begin
      k := 0;
      // �����������ܼ�
      if dbgrid.DataSource.dataset.fieldbyname('prod_type').AsString = typeStr_1
        then
        noodleAmout := noodleAmout +
          dbgrid.DataSource.dataset.fieldbyname('prod_price').AsCurrency
          // ����ɼӸ����ܼ�
      else
        if dbgrid.DataSource.dataset.fieldbyname('prod_type').AsString =
          typeStr_2 then
          optiAmout := optiAmout +
            dbgrid.DataSource.dataset.fieldbyname('prod_price').AsCurrency
            // ���������̾��ܼ�
        else
          if dbgrid.DataSource.dataset.fieldbyname('prod_type').AsString =
            typeStr_3 then
            drinkAmout := drinkAmout +
              dbgrid.DataSource.dataset.fieldbyname('prod_price').AsCurrency;
      // ���������۳�Ʒ�ֵ��ܼ�
      totalAmout := totalAmout +
        dbgrid.DataSource.dataset.fieldbyname('prod_price').AsCurrency;
      for j := 0 to dbgrid.Columns.count - 1 do
        begin
          // ���DBGrid�ĵ�ǰ�пɼ�
          if dbgrid.Columns.Items[j].Visible then
            begin
              // ��i��,��k+1��CELL�ĸ�ʽ
              //excel.cells[i, k + 1].NumberFormat := '@';
              if not
                // ������в�Ϊ��
              dbgrid.DataSource.dataset.fieldbyname(dbgrid.Columns.Items[j].FieldName).isnull then
                begin
                  // ��EXCEL�ж�Ӧ��CELLֵ��ΪDBGrid�и�CELL��ֵ
                  str :=
                    dbgrid.DataSource.dataset.fieldbyname(dbgrid.Columns.Items[j].FieldName).value;
                  Excel.Cells[i, k + 1] := Str;
                end;
              // ��һ��
              inc(k);
            end
          else
            // ���DBGrid�ĵ�ǰ�в��ɼ�,����������һ�еĴ���
            continue;
        end;
      // ��������65000ʱ�ж�ѭ��
      if i = 65000 then
        break;
      // ����
      inc(i);
      // һ�н���,������ǰ��һ��λ
      ProgressBar1.StepBy(1);
      // DataSourceָ����һ��
      dbgrid.DataSource.dataset.next;
    end;

  inc(i);
  inc(i);
  Excel.Cells[i, 1] := '����ͳ��';
  Excel.ActiveSheet.Rows[i].Font.Bold := True;
  Excel.ActiveSheet.Rows[i].Font.Color := clRed;
  Excel.ActiveSheet.Rows[i].Font.Size := 12;
  inc(i);
  inc(i);
  Excel.Cells[i, 1] := '��������:';
  Excel.Cells[i, 2] := CurrToStr(noodleAmout) + 'Ԫ';
  Excel.ActiveSheet.Rows[i].Font.Bold := True;
  Excel.ActiveSheet.Rows[i].Font.Color := clBlue;
  Excel.ActiveSheet.Rows[i].Font.Size := 12;
  inc(i);
  inc(i);
  Excel.Cells[i, 2] := '��������';
  Excel.Cells[i, 3] := '��������';
  Excel.Cells[i, 4] := '���۽��';
  Excel.ActiveSheet.Rows[i].Font.Bold := True;
  Excel.ActiveSheet.Rows[i].Font.Color := clBlue;
  Excel.ActiveSheet.Rows[i].Font.Size := 12;
  inc(i);
  SumADOQuery.First;
  while not SumADOQuery.Eof do
    begin
      if (SumADOQuery.fieldbyname('grpType').AsString = '1') then
        begin
          k := 0;
          for j := 0 to SumADOQuery.FieldCount - 2 do
            begin
              //excel.cells[i, k + 2].NumberFormat := '@';
              if not
                SumADOQuery.fieldbyname(SumADOQuery.Fields[j].FieldName).isnull
                then
                begin
                  str :=
                    SumADOQuery.fieldbyname(SumADOQuery.Fields[j].FieldName).AsString;
                  Excel.Cells[i, k + 2] := Str;
                end;
              inc(k);
            end;
          if i = 65300 then
            break;
          inc(i);
        end;
      //ProgressBar1.StepBy(1);
      SumADOQuery.next;
    end;
  inc(i);
  Excel.Cells[i, 1] := '�ɼӸ���:';
  Excel.Cells[i, 2] := CurrToStr(optiAmout) + 'Ԫ';
  Excel.ActiveSheet.Rows[i].Font.Bold := True;
  Excel.ActiveSheet.Rows[i].Font.Color := clBlue;
  Excel.ActiveSheet.Rows[i].Font.Size := 12;
  inc(i);
  inc(i);
  Excel.Cells[i, 2] := '��������';
  Excel.Cells[i, 3] := '��������';
  Excel.Cells[i, 4] := '���۽��';
  Excel.ActiveSheet.Rows[i].Font.Bold := True;
  Excel.ActiveSheet.Rows[i].Font.Color := clBlue;
  Excel.ActiveSheet.Rows[i].Font.Size := 12;
  inc(i);
  SumADOQuery.First;
  while not SumADOQuery.Eof do
    begin
      if (SumADOQuery.fieldbyname('grpType').AsString = '2') then
        begin
          k := 0;
          for j := 0 to SumADOQuery.FieldCount - 2 do
            begin
              //excel.cells[i, k + 2].NumberFormat := '@';
              if not
                SumADOQuery.fieldbyname(SumADOQuery.Fields[j].FieldName).isnull
                then
                begin
                  str :=
                    SumADOQuery.fieldbyname(SumADOQuery.Fields[j].FieldName).AsString;
                  Excel.Cells[i, k + 2] := Str;
                end;
              inc(k);
            end;

          if i = 65400 then
            break;
          inc(i);
        end;
      //ProgressBar1.StepBy(1);
      SumADOQuery.next;
    end;
  inc(i);
  Excel.Cells[i, 1] := '�����̾�:';
  Excel.Cells[i, 2] := CurrToStr(drinkAmout) + 'Ԫ';
  Excel.ActiveSheet.Rows[i].Font.Bold := True;
  Excel.ActiveSheet.Rows[i].Font.Color := clBlue;
  Excel.ActiveSheet.Rows[i].Font.Size := 12;
  inc(i);
  inc(i);
  Excel.Cells[i, 2] := 'Ʒ������';
  Excel.Cells[i, 3] := '��������';
  Excel.Cells[i, 4] := '���۽��';
  Excel.ActiveSheet.Rows[i].Font.Bold := True;
  Excel.ActiveSheet.Rows[i].Font.Color := clBlue;
  Excel.ActiveSheet.Rows[i].Font.Size := 12;
  inc(i);
  SumADOQuery.First;
  while not SumADOQuery.Eof do
    begin
      if (SumADOQuery.fieldbyname('grpType').AsString = '3') then
        begin
          k := 0;
          for j := 0 to SumADOQuery.FieldCount - 2 do
            begin
              //excel.cells[i, k + 2].NumberFormat := '@';
              if not
                SumADOQuery.fieldbyname(SumADOQuery.Fields[j].FieldName).isnull
                then
                begin
                  str :=
                    SumADOQuery.fieldbyname(SumADOQuery.Fields[j].FieldName).AsString;
                  Excel.Cells[i, k + 2] := Str;
                end;
              inc(k);
            end;

          if i = 65500 then
            break;
          inc(i);
        end;
      //ProgressBar1.StepBy(1);
      SumADOQuery.next;
    end;
  inc(i);
  Excel.Cells[i, 1] := '�ܼ�:';
  Excel.Cells[i, 2] := CurrToStr(totalAmout) + 'Ԫ';
  Excel.ActiveSheet.Rows[i].Font.Bold := True;
  Excel.ActiveSheet.Rows[i].Font.Color := clRed;
  Excel.ActiveSheet.Rows[i].Font.Size := 12;
  // ѭ������,�������������ڴ��������ͷ�
  progressbar1.Owner.Free;
  // application.ProcessMessages;
  // DataSourceָ��ԭ�ȱ���ı�־λ
  dbgrid.DataSource.dataset.GotoBookmark(SavePlace);
  // DataSource����
  dbgrid.DataSource.dataset.EnableControls;
  try
    // ����ļ���׺������xls
    if copy(FileName, length(FileName) - 3, 4) <> '.xls' then
      // �Զ�����
      FileName := FileName + '.xls';
    // EXCEL�ļ���CELL����Ӧ���
    Excel.workbooks[1].worksheets[1].Columns.AutoFit;
    Excel.workbooks[1].worksheets[1].name := info;
    // ��ֹEXCEL�ļ����޸�
    Excel.ActiveSheet.Protect(Password:='1912',
                              Contents:=True);
    Excel.ActiveWorkbook.Protect(Password:='1912',
                                 Structure:=True,
                                 Windows:=True
                                 );
    Excel.ActiveWorkbook.SaveAs(FileName, xlNormal, '', '', False, False);
  except
    // �쳣�˳�EXCEL
    Excel.Quit;
    screen.cursor := crDefault;
    exit;
  end;
  //Excel.Visible := true;
  // �����˳�EXCEL
  Excel.Quit;
  screen.cursor := crDefault;
  // ��ӡ�������ͳ�ƽ��
  exclToRep_func.PrintAmout(noodleAmout,optiAmout,drinkAmout,totalAmout,info);
  // Result := true;
end;

procedure PrintAmout(noodleAmout: Currency; optiAmout: Currency; drinkAmout: Currency; totalAmout: Currency; info: string);
var
  PText: TextFile;
  noodleAmt: string;
  optiAmt: string;
  drinkAmt: string;
  totalAmt: string;
  prtInfo: string;
begin
  if Printer.Printers.Count <= 0 then
    begin
      Messagedlg('û�м�⵽��ӡ�������ʵ��',
        mterror, [mbok],
        0);
      exit;
    end;
  noodleAmt := CurrToStr(noodleAmout);
  optiAmt := CurrToStr(optiAmout);
  drinkAmt := CurrToStr(drinkAmout);
  totalAmt := CurrToStr(totalAmout);
  prtInfo := info;
  prtInfo := copy(prtInfo, 0, length(prtInfo) - 4);
  //Printer.Canvas.Font.Charset := GB2312_CHARSET;
  AssignFile(PText, 'LPT1');
  //AssignPRN(PText);
  Rewrite(PText);
  // ��ӡ����ʼ��
  Write(Ptext, chr(27) + chr(64));
  // ���ú���ģʽ
  //Write(Ptext, chr(28) + chr(38));
  // ���ñ��߱����ӡ��ʽ
  Write(Ptext, chr(27) + chr(33) + chr(48));
  // ��ӡʱ��
  writeln(Ptext, prtInfo);
  writeln(Ptext, '----------------');
  writeln(Ptext, '��������:' + noodleAmt);
  writeln(Ptext, '�ɼӸ���:' + optiAmt);
  writeln(Ptext, '�����̾�:' + drinkAmt);
  writeln(Ptext, '�ܼ�:' + totalAmt + 'Ԫ');
  writeln(Ptext, ' ');
  writeln(Ptext, ' ');
  writeln(Ptext, ' ');
  writeln(Ptext, '----------------');
  // ȡ�����߱����ӡ��ʽ
  Write(Ptext, chr(27) + chr(33) + chr(0));
  // ��ӡʱ��
  writeln(Ptext, '��ӡʱ��:' + FormatDateTime('yyyy-mm-dd hh:mm', now));
  // ��ǰ��ֽ
  Write(Ptext, chr(27) + chr(74) + chr(120));
  CloseFile(Ptext); //ֹͣ��ӡ
end;

{
//��ADOQUERY�����ݼ����뵽EXCEL��

function queryExportToExcel(queryexport: tadoquery): boolean;
const
  xlNormal = -4143;
var
  i, j, k: integer;
  str, filename: string;
  excel: OleVariant;
  savedialog: tsavedialog;
  ProgressBar1: TProgressBar;
begin
  result := false;
  filename := '';
  if queryexport.RecordCount > 65536 then
    begin
      if
        application.messagebox('��Ҫ���������ݹ���Excel���ֻ������65536��,�Ƿ�Ҫ������', 'ѯ��', mb_yesno + mb_iconquestion) = idno then
        exit;
    end;
  screen.Cursor := crHourGlass;
  try
    excel := CreateOleObject('Excel.Application');
    excel.workbooks.add;
  except
    screen.cursor := crDefault;
    showmessage('�޷�����Excel��');
    exit;
  end;
  savedialog := tsavedialog.Create(nil);
  savedialog.Filter := 'Excel�ļ�(*.xls)|*.xls';
  if savedialog.Execute then
    begin
      if FileExists(savedialog.FileName) then
        try
          if application.messagebox('���ļ��Ѿ����ڣ�Ҫ������', 'ѯ��',
            mb_yesno + mb_iconquestion) = idyes then
            DeleteFile(PChar(savedialog.FileName))
          else
            begin
              Excel.Quit;
              savedialog.free;
              screen.cursor := crDefault;
              Exit;
            end;
        except
          Excel.Quit;
          savedialog.free;
          screen.cursor := crDefault;
          Exit;
        end;
      filename := savedialog.FileName;
    end;
  savedialog.free;
  application.ProcessMessages;
  if filename = '' then
    begin
      result := false;
      Excel.Quit;
      screen.cursor := crDefault;
      exit;
    end;
  k := 0;
  for i := 0 to queryexport.FieldCount - 1 do
    begin
      excel.cells[1, k + 1] := queryexport.Fields[i].FieldName;
      inc(k);
    end;
  queryexport.First;
  i := 2;
  if queryexport.recordcount > 65536 then
    ProgressBar1 := ProgressBarform(65536)
  else
    ProgressBar1 := ProgressBarform(queryexport.recordcount);
  while not queryexport.Eof do
    begin
      k := 0;
      for j := 0 to queryexport.FieldCount - 1 do
        begin
          excel.cells[i, k + 1].NumberFormat := '@';
          if not queryexport.fieldbyname(queryexport.Fields[j].FieldName).isnull
            then
            begin
              str :=
                queryexport.fieldbyname(queryexport.Fields[j].FieldName).AsString;
              Excel.Cells[i, k + 1] := Str;
            end;
          inc(k);
        end;
      if i = 65536 then
        break;
      inc(i);
      ProgressBar1.StepBy(1);
      queryexport.next;
    end;
  progressbar1.Owner.Free;
  application.ProcessMessages;
  try
    if copy(FileName, length(FileName) - 3, 4) <> '.xls' then
      FileName := FileName + '.xls';
    Excel.ActiveWorkbook.SaveAs(FileName, xlNormal, '', '', False, False);
  except
    Excel.Quit;
    screen.cursor := crDefault;
    exit;
  end;
  //Excel.Visible    :=    true;
  // ����Ӧ���
  Excel.workbooks[1].worksheets[1].Columns.AutoFit;
  Excel.Quit;
  screen.cursor := crDefault;
  Result := true;
end;
}
end.
