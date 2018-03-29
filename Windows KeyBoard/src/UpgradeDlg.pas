unit UpgradeDlg;

interface

function UpgradeDlgFunc(): Integer;

implementation

uses Windows, ShellApi, Messages, KbFunc, ResDef;

//
// ** ǰ������ **
//
function UpgradeDlgProc(hDlg: HWnd; uMsg: UInt; wParam: WParam; lParam: LParam): Bool; stdcall; forward;

//
// �򿪸��¶Ի���
//
function UpgradeDlgFunc(): Integer;
begin
  Result := DialogBox(HInstance, MakeIntResource(IDD_UPGRADE), 0, @UpgradeDlgProc);
  if (Result = -1) then SendErrorMessage(IDS_CANNOT_CREATE_DLG);
end;

//
// ���¶Ի���ص�
//
function UpgradeDlgProc(hDlg: HWnd; uMsg: UInt; wParam: WParam; lParam: LParam): Bool; stdcall;
var
  Str: array[0..MAX_PATH] of Char;
  hWndDc, hMemDc: HDc;
  hNewBmp, hOldBmp: HBitmap;
  Rc: TRect;
  PS: TPaintStruct;
begin
  Result := True; // Did process the message

  case (uMsg) of
    WM_INITDIALOG:
    begin
      RelocateDialog(hDlg); // �����Ի���λ��
    end;

    WM_PAINT:
    begin
      hWndDc := BeginPaint(hDlg, PS);

      GetWindowRect(GetDlgItem(hDlg, IDC_LOGO1), Rc); // ͼƬλ��
      ScreenToClient(hDlg, PPoint(@Rc)^); // Top & Left

      hMemDc := CreateCompatibleDC(hWndDc);
      hNewBmp := LoadImage(HInstance, MakeIntResource(IDB_BITMAP), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS);
      hOldBmp := SelectObject(hMemDc, hNewBmp);

      BitBlt(hWndDc, Rc.Left, Rc.Top, 112, 32, hMemDc, 0,0, SRCCOPY);

      SelectObject(hMemDc, hOldBmp);
      DeleteObject(hNewBmp);
      DeleteDC(hMemDc);

      EndPaint(hDlg, PS);
    end;

    WM_COMMAND:
    begin
      case (wParam) of
        IDOK:
          EndDialog(hDlg, IDOK);

        IDCANCEL:
          EndDialog(hDlg, IDCANCEL);

        BUT_WEBSITE: // ����
        begin
          LoadString(HInstance, IDS_WEDSITE, Str, MAX_PATH);
          ShellExecute(0, 'open', Str, nil, nil, SW_SHOWNORMAL);

          EndDialog(hDlg, IDOK);
        end;

        BUT_MAIL:    // ȥ��
        begin
          LoadString(HInstance, IDS_MAIL, Str, MAX_PATH);
          ShellExecute(0, 'open', Str, nil, nil, SW_SHOWNORMAL);

          EndDialog(hDlg, IDOK);
        end;

        else
          Result := False;
      end;
    end; // WM_COMMAND ..

    else
      Result := False;
  end;
end;

end.
