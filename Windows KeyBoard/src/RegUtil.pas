unit RegUtil;

interface

uses Windows;

function OpenUserSetting(): Bool;
function SaveUserSetting(): Bool;

implementation

uses KbFunc, Setting, ResDef;

const
  CURRENT_STEPPING = 3;
  REG_PATH = 'Software\Microsoft\Osk_Mz';

//
// 从注册表读取用户设置
//
function OpenUserSetting(): Bool;
var
  hkPerUser: HKey;
  dwType, cbData, dwStepping, dwDisposition: DWord;
  Return: LongInt;
begin
  Result := False;

  // Now we'll attempt to create the key
  Return := RegCreateKeyEx(HKEY_CURRENT_USER, REG_PATH, 0, 'Application Per-User Data',
    REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, nil, hkPerUser, @dwDisposition);
  if (Return <> ERROR_SUCCESS) then
  begin
    SendErrorMessage(IDS_REGISTRY_ACCESS_ERROR);
    Exit;
  end;

  // Usually the disposition value will indicate that we've created a
  // new key. Sometimes it may instead state that we've opened an existing
  // key. This can happen when installation is incomplete and interrupted,
  // say by loss of electrical power.
  if (dwDisposition <> REG_CREATED_NEW_KEY) and (dwDisposition <> REG_OPENED_EXISTING_KEY) then
  begin
    SendErrorMessage(IDS_REGISTRY_ACCESS_ERROR);
    Exit;
  end;

  // Stepping
  dwType := REG_DWORD;
  cbData := SizeOf(DWord);
  Return := RegQueryValueEx(hkPerUser, 'Stepping', nil, @dwType, @dwStepping, @cbData);
  if (Return <> ERROR_SUCCESS) then dwStepping := 0;

  // Setting
  dwType := REG_BINARY;
  cbData := SizeOf(TKbInfo);
  Return := RegQueryValueEx(hkPerUser, 'Setting', nil, @dwType, @KbInfo, @cbData);

  // 首次运行
  if (Return <> ERROR_SUCCESS) or (dwStepping < CURRENT_STEPPING) then
  begin
    // if it is not there then create the default Settings value
    RegSetValueEx(hkPerUser, 'Setting', 0, REG_BINARY, @KbInfo, SizeOf(TKbInfo));

    // 重新读出
    dwType := REG_BINARY;
    cbData := SizeOf(TKbInfo);
    Return := RegQueryValueEx(hkPerUser, 'Setting', nil, @dwType, @KbInfo, @cbData);

    // 读取失败
    if (Return <> ERROR_SUCCESS) then
    begin
      SendErrorMessage(IDS_REGISTRY_ACCESS_ERROR);
      RegCloseKey(hkPerUser);
      Exit;
    end;

    // update the stepping
    dwStepping := CURRENT_STEPPING;
    RegSetValueEx(hkPerUser, 'Stepping', 0, REG_DWORD, @dwStepping, SizeOf(DWord));
  end;

  RegCloseKey(hkPerUser);
  Result := True;
end;

//
// 保存用户设置到注册表
//
function SaveUserSetting(): Bool;
var
  Return: LongInt;
  hkPerUser: HKey;
  dwDisposition: DWord;
begin
  Result := False;

  // Now we'll attempt to create the key ..
  Return := RegCreateKeyEx(HKEY_CURRENT_USER, REG_PATH, 0, 'Application Per-User Data',
    REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, nil, hkPerUser, @dwDisposition);
  if (Return <> ERROR_SUCCESS) then
  begin
    SendErrorMessage(IDS_REGISTRY_ACCESS_ERROR);
    Exit;
  end;

  // Usually the disposition value will indicate that we've created a
  // new key. Sometimes it may instead state that we've opened an existing
  // key. This can happen when installation is incomplete and interrupted,
  // say by loss of electrical power.
  if (dwDisposition <> REG_CREATED_NEW_KEY) and (dwDisposition <> REG_OPENED_EXISTING_KEY) then
  begin
    SendErrorMessage(IDS_REGISTRY_ACCESS_ERROR);
    Exit;
  end;

  // Save the whole setting
  Return := RegSetValueEx(hkPerUser, 'Setting', 0, REG_BINARY, @KbInfo, SizeOf(TKbInfo));
  if (Return <> ERROR_SUCCESS) then
  begin
    SendErrorMessage(IDS_REGISTRY_ACCESS_ERROR);
    RegCloseKey(hkPerUser);
    Exit;
  end;

  RegCloseKey(hkPerUser);
  Result := True;
end;

end.
