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

//生成一个显示进度条的窗体

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

//将DBGRID中的内容导入到EXCEL中

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
  typeStr_1 := '主类面条';
  typeStr_2 := '可加副料';
  typeStr_3 := '饮料烟酒';
  noodleAmout := 0;
  totalAmout := 0;
  optiAmout := 0;
  drinkAmout := 0;
  // result := false;
  filename := '';
  if dbgrid.DataSource.DataSet.RecordCount > 65000 then
    begin
      if
        application.messagebox('需要导出的数据过大，一次最大导出65000行,是否还要继续？', '询问', mb_yesno + mb_iconquestion) = idno then
        exit;
    end;
  screen.Cursor := crHourGlass;
  try
    excel := CreateOleObject('Excel.Application');
    excel.workbooks.add;
  except
    screen.cursor := crDefault;
    showmessage('无法调用Excel！');
    exit;
  end;
  savedialog := tsavedialog.Create(nil);
  // 获得程序所在路径
  // ChDir(ExtractFilePath(Application.ExeName));
  // 获得当前路径的字符串
  ExeRoot := GetCurrentDir;
  savedialog.InitialDir := GetCurrentDir + '\Reports';
  savedialog.FileName := info;
  savedialog.Filter := 'Excel文件(*.xls)|*.xls';
  if savedialog.Execute then
    begin
      if FileExists(savedialog.FileName) then
        try
          if application.messagebox('该文件已经存在，要覆盖吗？', '询问',
            mb_yesno + mb_iconquestion) = idyes then
            // 删除已存在的文件
            DeleteFile(PChar(savedialog.FileName))
          else
            begin
              // 否则退出
              Excel.Quit;
              savedialog.free;
              screen.cursor := crDefault;
              Exit;
            end;
        except
          // 异常情况退出
          Excel.Quit;
          savedialog.free;
          screen.cursor := crDefault;
          Exit;
        end;
      // 保存文件名
      filename := savedialog.FileName;
    end;
  // 释放保存对话框
  savedialog.free;
  // application.ProcessMessages;
  // 如果文件名为空, 退出
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
      // 如果DBGrid的当前列可见
      if dbgrid.Columns.Items[i].Visible then
        begin
          //Excel.Columns[k+1].ColumnWidth:=dbgrid.Columns.Items[i].Title.Column.Width;
          // 设定EXCEL文件CELL的值为DBGrid的列标题
          excel.cells[1, k + 1] := dbgrid.Columns.Items[i].Title.Caption;
          inc(k);
        end;
    end;
  Excel.ActiveSheet.Rows[1].Font.Bold := True;
  Excel.ActiveSheet.Rows[1].Font.Color := clBlue;
  Excel.ActiveSheet.Rows[1].Font.Size := 12;
  // 锁定DBGrid控件
  dbgrid.DataSource.DataSet.DisableControls;
  // 保存当前DBGrid所在行的标记
  saveplace := dbgrid.DataSource.DataSet.GetBookmark;
  // DBGrid的DataSource指向第一条记录
  dbgrid.DataSource.dataset.First;
  i := 2;
  // i指到下一行(第2行)
  // 如果行数超出65000行
  if dbgrid.DataSource.DataSet.recordcount > 65000 then
    // 进度条最大进度数量为65000
    ProgressBar1 := ProgressBarform(65000)
  else
    // 行数没有超出65000行,进度条最大进度数量为DataSource的数据行数
    ProgressBar1 := ProgressBarform(dbgrid.DataSource.DataSet.recordcount);
  // 当DBGrid的DataSource不为空时
  while not dbgrid.DataSource.dataset.Eof do
    // 循环处理DataSource中每一行每一个CELL的值
    begin
      k := 0;
      // 计算面条类总价
      if dbgrid.DataSource.dataset.fieldbyname('prod_type').AsString = typeStr_1
        then
        noodleAmout := noodleAmout +
          dbgrid.DataSource.dataset.fieldbyname('prod_price').AsCurrency
          // 计算可加副料总价
      else
        if dbgrid.DataSource.dataset.fieldbyname('prod_type').AsString =
          typeStr_2 then
          optiAmout := optiAmout +
            dbgrid.DataSource.dataset.fieldbyname('prod_price').AsCurrency
            // 计算饮料烟酒总价
        else
          if dbgrid.DataSource.dataset.fieldbyname('prod_type').AsString =
            typeStr_3 then
            drinkAmout := drinkAmout +
              dbgrid.DataSource.dataset.fieldbyname('prod_price').AsCurrency;
      // 计算所有售出品种的总价
      totalAmout := totalAmout +
        dbgrid.DataSource.dataset.fieldbyname('prod_price').AsCurrency;
      for j := 0 to dbgrid.Columns.count - 1 do
        begin
          // 如果DBGrid的当前列可见
          if dbgrid.Columns.Items[j].Visible then
            begin
              // 第i行,第k+1个CELL的格式
              //excel.cells[i, k + 1].NumberFormat := '@';
              if not
                // 如果该列不为空
              dbgrid.DataSource.dataset.fieldbyname(dbgrid.Columns.Items[j].FieldName).isnull then
                begin
                  // 把EXCEL中对应的CELL值设为DBGrid中该CELL的值
                  str :=
                    dbgrid.DataSource.dataset.fieldbyname(dbgrid.Columns.Items[j].FieldName).value;
                  Excel.Cells[i, k + 1] := Str;
                end;
              // 下一列
              inc(k);
            end
          else
            // 如果DBGrid的当前列不可见,跳过进行下一列的处理
            continue;
        end;
      // 行数到达65000时中断循环
      if i = 65000 then
        break;
      // 换行
      inc(i);
      // 一行结束,进度条前移一个位
      ProgressBar1.StepBy(1);
      // DataSource指向下一行
      dbgrid.DataSource.dataset.next;
    end;

  inc(i);
  inc(i);
  Excel.Cells[i, 1] := '分类统计';
  Excel.ActiveSheet.Rows[i].Font.Bold := True;
  Excel.ActiveSheet.Rows[i].Font.Color := clRed;
  Excel.ActiveSheet.Rows[i].Font.Size := 12;
  inc(i);
  inc(i);
  Excel.Cells[i, 1] := '主类面条:';
  Excel.Cells[i, 2] := CurrToStr(noodleAmout) + '元';
  Excel.ActiveSheet.Rows[i].Font.Bold := True;
  Excel.ActiveSheet.Rows[i].Font.Color := clBlue;
  Excel.ActiveSheet.Rows[i].Font.Size := 12;
  inc(i);
  inc(i);
  Excel.Cells[i, 2] := '面条名称';
  Excel.Cells[i, 3] := '销售数量';
  Excel.Cells[i, 4] := '销售金额';
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
  Excel.Cells[i, 1] := '可加副料:';
  Excel.Cells[i, 2] := CurrToStr(optiAmout) + '元';
  Excel.ActiveSheet.Rows[i].Font.Bold := True;
  Excel.ActiveSheet.Rows[i].Font.Color := clBlue;
  Excel.ActiveSheet.Rows[i].Font.Size := 12;
  inc(i);
  inc(i);
  Excel.Cells[i, 2] := '副料名称';
  Excel.Cells[i, 3] := '销售数量';
  Excel.Cells[i, 4] := '销售金额';
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
  Excel.Cells[i, 1] := '饮料烟酒:';
  Excel.Cells[i, 2] := CurrToStr(drinkAmout) + '元';
  Excel.ActiveSheet.Rows[i].Font.Bold := True;
  Excel.ActiveSheet.Rows[i].Font.Color := clBlue;
  Excel.ActiveSheet.Rows[i].Font.Size := 12;
  inc(i);
  inc(i);
  Excel.Cells[i, 2] := '品种名称';
  Excel.Cells[i, 3] := '销售数量';
  Excel.Cells[i, 4] := '销售金额';
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
  Excel.Cells[i, 1] := '总计:';
  Excel.Cells[i, 2] := CurrToStr(totalAmout) + '元';
  Excel.ActiveSheet.Rows[i].Font.Bold := True;
  Excel.ActiveSheet.Rows[i].Font.Color := clRed;
  Excel.ActiveSheet.Rows[i].Font.Size := 12;
  // 循环结束,进度条所属的内存管理对象释放
  progressbar1.Owner.Free;
  // application.ProcessMessages;
  // DataSource指向原先保存的标志位
  dbgrid.DataSource.dataset.GotoBookmark(SavePlace);
  // DataSource解锁
  dbgrid.DataSource.dataset.EnableControls;
  try
    // 如果文件后缀名不是xls
    if copy(FileName, length(FileName) - 3, 4) <> '.xls' then
      // 自动补齐
      FileName := FileName + '.xls';
    // EXCEL文件的CELL自适应宽度
    Excel.workbooks[1].worksheets[1].Columns.AutoFit;
    Excel.workbooks[1].worksheets[1].name := info;
    // 禁止EXCEL文件的修改
    Excel.ActiveSheet.Protect(Password:='1912',
                              Contents:=True);
    Excel.ActiveWorkbook.Protect(Password:='1912',
                                 Structure:=True,
                                 Windows:=True
                                 );
    Excel.ActiveWorkbook.SaveAs(FileName, xlNormal, '', '', False, False);
  except
    // 异常退出EXCEL
    Excel.Quit;
    screen.cursor := crDefault;
    exit;
  end;
  //Excel.Visible := true;
  // 正常退出EXCEL
  Excel.Quit;
  screen.cursor := crDefault;
  // 打印报表分类统计金额
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
      Messagedlg('没有检测到打印机！请查实！',
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
  // 打印机初始化
  Write(Ptext, chr(27) + chr(64));
  // 设置汉字模式
  //Write(Ptext, chr(28) + chr(38));
  // 设置倍高倍宽打印方式
  Write(Ptext, chr(27) + chr(33) + chr(48));
  // 打印时间
  writeln(Ptext, prtInfo);
  writeln(Ptext, '----------------');
  writeln(Ptext, '主类面条:' + noodleAmt);
  writeln(Ptext, '可加副料:' + optiAmt);
  writeln(Ptext, '饮料烟酒:' + drinkAmt);
  writeln(Ptext, '总计:' + totalAmt + '元');
  writeln(Ptext, ' ');
  writeln(Ptext, ' ');
  writeln(Ptext, ' ');
  writeln(Ptext, '----------------');
  // 取消倍高倍宽打印方式
  Write(Ptext, chr(27) + chr(33) + chr(0));
  // 打印时间
  writeln(Ptext, '打印时间:' + FormatDateTime('yyyy-mm-dd hh:mm', now));
  // 向前走纸
  Write(Ptext, chr(27) + chr(74) + chr(120));
  CloseFile(Ptext); //停止打印
end;

{
//将ADOQUERY的数据集导入到EXCEL中

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
        application.messagebox('需要导出的数据过大，Excel最大只能容纳65536行,是否还要继续？', '询问', mb_yesno + mb_iconquestion) = idno then
        exit;
    end;
  screen.Cursor := crHourGlass;
  try
    excel := CreateOleObject('Excel.Application');
    excel.workbooks.add;
  except
    screen.cursor := crDefault;
    showmessage('无法调用Excel！');
    exit;
  end;
  savedialog := tsavedialog.Create(nil);
  savedialog.Filter := 'Excel文件(*.xls)|*.xls';
  if savedialog.Execute then
    begin
      if FileExists(savedialog.FileName) then
        try
          if application.messagebox('该文件已经存在，要覆盖吗？', '询问',
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
  // 自适应宽度
  Excel.workbooks[1].worksheets[1].Columns.AutoFit;
  Excel.Quit;
  screen.cursor := crDefault;
  Result := true;
end;
}
end.
