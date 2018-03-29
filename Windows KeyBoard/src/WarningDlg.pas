unit WarningDlg;

interface

function WarningMsgDlgFunc(): Integer;

implementation

uses Windows, ShellApi, Messages, CommCtrl, KbFunc, Setting, ResDef;

//
// ** ǰ������ **
//
function WarningMsgDlgProc(hDlg: HWnd; uMsg: UInt; wParam: WParam; lParam: LParam): Bool; stdcall; forward;

//
// ����ʾ�Ի���
//
function WarningMsgDlgFunc(): Integer;
begin
  Result := DialogBox(HInstance, MakeIntResource(IDD_WARNING_MSG), 0, @WarningMsgDlgProc);
  if (Result = -1) then SendErrorMessage(IDS_CANNOT_CREATE_DLG);
end;

//
// ��ʾ�Ի���ص�
//
function WarningMsgDlgProc(hDlg: HWnd; uMsg: UInt; wParam: WParam; lParam: LParam): Bool; stdcall;
var
  ID_Ctl: Integer;
  PNmh: PNMHdr;
  WebAddr: array[0..MAX_PATH] of Char;
begin
  Result := True; // Did process the message

  case (uMsg) of
    WM_INITDIALOG:
    begin
      RelocateDialog(hDlg); // �����Ի���λ��
    end;

    WM_NOTIFY:
    begin
      ID_Ctl := wParam;
      PNmh := PNMHdr(lParam);

      case (PNmh.code) of
        NM_RETURN, // �س�
        NM_CLICK:  // ���
          if (ID_Ctl = IDC_ENABLEWEB) then
          begin
            LoadString(HInstance, IDS_ENABLEWEB, WebAddr, MAX_PATH);
            ShellExecute(hDlg, 'open', 'iexplore.exe', WebAddr, nil, SW_SHOW);
          end;
      end;
    end; // WM_NOTIFY ..

    WM_CLOSE:
    begin
      EndDialog(hDlg, IDOK);
    end;

    WM_COMMAND:
    begin
      case (wParam) of
        IDOK:
        begin                        
          KbInfo.ShowWarning := IsDlgButtonChecked(hDlg, IDC_SHOW_AGAIN) <> BST_CHECKED;
          EndDialog(hDlg, IDOK);
        end;

        IDCANCEL:
          EndDialog(hDlg, IDCANCEL);
      end;
    end; // WM_COMMAND ..

    else
      Result := False;
  end;
end;

end.
