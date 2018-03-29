unit AboutDlg;

interface

function AboutDlgFunc(): Integer;

implementation

uses Windows, ShellApi, Messages, CommCtrl, UpgradeDlg, KbFunc, ResDef;

//
// ** ǰ������ **
//
function AboutDlgProc(hDlg: HWnd; uMsg: UInt; wParam: WParam; lParam: LParam): Bool; stdcall; forward;

//
// �򿪹��ڶԻ���
//
function AboutDlgFunc(): Integer;
begin
  Result := DialogBox(HInstance, MakeIntResource(IDD_ABOUT), 0, @AboutDlgProc);
  if (Result = -1) then SendErrorMessage(IDS_CANNOT_CREATE_DLG);
end;

//
// ���ڶԻ���ص�
//
function AboutDlgProc(hDlg: HWnd; uMsg: UInt; wParam: WParam; lParam: LParam): Bool; stdcall;
var
  hWndDc, hMemDc: HDc;
  hNewBmp, hOldBmp: HBitmap;
  Rc: TRect;
  PS: TPaintStruct;
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

    WM_PAINT:
    begin
      hWndDc := BeginPaint(hDlg, PS);

      GetWindowRect(GetDlgItem(hDlg, IDC_LOGO), Rc); // ͼƬλ��
      ScreenToClient(hDlg, PPoint(@Rc)^);

      hMemDc := CreateCompatibleDC(hWndDc);
      hNewBmp := LoadImage(HInstance, MakeIntResource(IDB_BITMAP), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS);
      hOldBmp := SelectObject(hMemDc, hNewBmp);

      BitBlt(hWndDc, Rc.Left, Rc.Top, 112, 32, hMemDc, 0,0, SRCCOPY);

      SelectObject(hMemDc, hOldBmp);
      DeleteObject(hNewBmp);
      DeleteDC(hMemDc);

      EndPaint(hDlg, PS);
    end;

    WM_NOTIFY: // Web address linked: Anil
    begin
      ID_Ctl := wParam;
      PNmh := PNMHdr(lParam);

      case (PNmh.Code) of
        NM_RETURN, // �س�
        NM_CLICK:  // ���
          if (ID_Ctl = IDC_ENABLEWEB2) then
          begin
            LoadString(HInstance, IDS_ENABLEWEB, WebAddr, MAX_PATH);
            ShellExecute(hDlg, 'open', 'iexplore.exe', WebAddr, nil, SW_SHOW);
          end;
      end; // case (PNmh.code) of ..
    end;

    WM_COMMAND:
    begin
      case (wParam) of
        IDOK:
          EndDialog(hDlg, IDOK);

        IDCANCEL:
          EndDialog(hDlg, IDCANCEL);

        BUT_UPGRADE: // v-mjgran: The upgrade button has been removed
        begin
          EndDialog(hDlg, IDCANCEL);
          UpgradeDlgFunc(); // ��ʾ�����Ի���
        end;

        else
          Result := False;
      end; // case (wParam) of ..
    end;

    else
      Result := False;
  end; // case (uMsg) of ..
end;

end.
