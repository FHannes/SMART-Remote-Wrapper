library SmartRemote;

//**
// By Frédéric Hannes (http://www.scar-divi.com)
// License: http://creativecommons.org/licenses/by/3.0/
//**

uses
  FastShareMem in 'FastShareMem.pas',
  SCARLib in 'SCARLib.pas',
  SMARTApi in 'SMARTApi.pas',
  System.SysUtils,
  System.Classes,
  System.Win.Registry,
  System.StrUtils,
  WinApi.Windows,
  Vcl.Controls,
  Vcl.Graphics;

var
  SMARTLib: THandle = 0;

type
  PClientData = ^TClientData;
  TClientData = packed record
    Target: PTarget;
    LastX, LastY: Integer; // Last coordinates the cursor was known to be at
  end;

function SMART_Dir: string;
begin
  Result := GetCurrentDir;
  if Exp <> nil then
  begin
    Result := Exp^.WorkspacePath + 'SMART' + PathDelim;
    ForceDirectories(Result);
  end;
end;

function InitSmartLib(const LibPath: string): Boolean; stdcall;
begin
  if SMARTLib = 0 then
    SMARTLib := LoadLibrary(PChar(LibPath));
  Result := SMARTLib <> 0;
  if Result then
  begin
    SMART_RequestTarget := GetProcAddress(SMARTLib, 'EIOS_RequestTarget');
    SMART_ReleaseTarget := GetProcAddress(SMARTLib, 'EIOS_ReleaseTarget');
    SMART_GetTargetSize := GetProcAddress(SMARTLib, 'EIOS_GetTargetDimensions');
    SMART_GetImageBuffer := GetProcAddress(SMARTLib, 'EIOS_GetImageBuffer');
    SMART_GetMousePos := GetProcAddress(SMARTLib, 'EIOS_GetMousePosition');
    SMART_SetMousePos := GetProcAddress(SMARTLib, 'EIOS_MoveMouse');
    SMART_MouseBtnDown := GetProcAddress(SMARTLib, 'EIOS_HoldMouse');
    SMART_MouseBtnUp := GetProcAddress(SMARTLib, 'EIOS_ReleaseMouse');
    SMART_GetMouseBtnState := GetProcAddress(SMARTLib, 'EIOS_IsMouseHeld');
    SMART_TypeText := GetProcAddress(SMARTLib, 'EIOS_SendString');
    SMART_VKeyDown := GetProcAddress(SMARTLib, 'EIOS_HoldKey');
    SMART_VKeyUp := GetProcAddress(SMARTLib, 'EIOS_ReleaseKey');
    SMART_GetKeyState := GetProcAddress(SMARTLib, 'EIOS_IsKeyHeld');

    SMART_Exp_ClientID := GetProcAddress(SMARTLib, 'exp_clientID');
    SMART_Exp_GetClients := GetProcAddress(SMARTLib, 'exp_getClients');
    SMART_Exp_SpawnClient := GetProcAddress(SMARTLib, 'exp_spawnClient');
    SMART_Exp_PairClient := GetProcAddress(SMARTLib, 'exp_pairClient');
    SMART_Exp_KillClient := GetProcAddress(SMARTLib, 'exp_killClient');
    SMART_Exp_CurrentClient := GetProcAddress(SMARTLib, 'exp_getCurrent');
    SMART_Exp_ImageArray := GetProcAddress(SMARTLib, 'exp_getImageArray');
    SMART_Exp_DebugArray := GetProcAddress(SMARTLib, 'exp_getDebugArray');
    SMART_Exp_GetRefresh := GetProcAddress(SMARTLib, 'exp_getRefresh');
    SMART_Exp_SetRefresh := GetProcAddress(SMARTLib, 'exp_setRefresh');
    SMART_Exp_SetTransparentColor := GetProcAddress(SMARTLib, 'exp_setTransparentColor');
    SMART_Exp_SetDebug := GetProcAddress(SMARTLib, 'exp_setDebug');
    SMART_Exp_SetGraphics := GetProcAddress(SMARTLib, 'exp_setGraphics');
    SMART_Exp_SetEnabled := GetProcAddress(SMARTLib, 'exp_setEnabled');
    SMART_Exp_Active := GetProcAddress(SMARTLib, 'exp_isActive');
    SMART_Exp_Enabled := GetProcAddress(SMARTLib, 'exp_isBlocking');
    SMART_Exp_GetMousePos := GetProcAddress(SMARTLib, 'exp_getMousePos');
    SMART_Exp_HoldMouse := GetProcAddress(SMARTLib, 'exp_holdMouse');
    SMART_Exp_ReleaseMouse := GetProcAddress(SMARTLib, 'exp_releaseMouse');
    SMART_Exp_HoldMousePlus := GetProcAddress(SMARTLib, 'exp_holdMousePlus');
    SMART_Exp_ReleaseMousePlus := GetProcAddress(SMARTLib, 'exp_releaseMousePlus');
    SMART_Exp_MoveMouse := GetProcAddress(SMARTLib, 'exp_moveMouse');
    SMART_Exp_WindMouse := GetProcAddress(SMARTLib, 'exp_windMouse');
    SMART_Exp_ClickMouse := GetProcAddress(SMARTLib, 'exp_clickMouse');
    SMART_Exp_ClickMousePlus := GetProcAddress(SMARTLib, 'exp_clickMousePlus');
    SMART_Exp_IsMouseButtonHeld := GetProcAddress(SMARTLib, 'exp_isMouseButtonHeld');
    SMART_Exp_SendKeys := GetProcAddress(SMARTLib, 'exp_sendKeys');
    SMART_Exp_HoldKey := GetProcAddress(SMARTLib, 'exp_holdKey');
    SMART_Exp_ReleaseKey := GetProcAddress(SMARTLib, 'exp_releaseKey');
    SMART_Exp_IsKeyDown := GetProcAddress(SMARTLib, 'exp_isKeyDown');
    SMART_Exp_GetColor := GetProcAddress(SMARTLib, 'exp_getColor');
    SMART_Exp_FindColor := GetProcAddress(SMARTLib, 'exp_findColor');
    SMART_Exp_FindColorTol := GetProcAddress(SMARTLib, 'exp_findColorTol');
    SMART_Exp_FindColorSpiral := GetProcAddress(SMARTLib, 'exp_findColorSpiral');
    SMART_Exp_FindColorSpiralTol := GetProcAddress(SMARTLib, 'exp_findColorSpiralTol');
  end;
end;

function GetJVMPath: string; stdcall;
begin
  Result := '';
  with TRegistry.Create do
  try
    Access := KEY_READ;
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKey('Software\JavaSoft\Java Runtime Environment', False) then
      if ValueExists('CurrentVersion') then
        if OpenKey(ReadString('CurrentVersion'), False) then
          Result := ReadString('RuntimeLib');
  finally
    Free;
  end;
end;

procedure _SetCursorPos(const Client: Pointer; const X, Y: Integer); stdcall;
var
  Data: PClientData;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    SMART_SetMousePos(Data^.Target, X, Y);
    Data^.LastX := X;
    Data^.LastY := Y;
  end;
end;

procedure _GetCursorPos(const Client: Pointer; out X, Y: Integer); stdcall;
var
  Data: PClientData;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    SMART_GetMousePos(Data^.Target, X, Y);
    Data^.LastX := X;
    Data^.LastY := Y;
  end;
end;

procedure _MouseBtnDown(const Client: Pointer; const Button: TMouseButton); stdcall;
var
  Data: PClientData;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    case Button of
      mbLeft: SMART_MouseBtnDown(Data^.Target, Data^.LastX, Data^.LastY, 1);
      mbRight: SMART_MouseBtnDown(Data^.Target, Data^.LastX, Data^.LastY, 0);
      mbMiddle: SMART_MouseBtnDown(Data^.Target, Data^.LastX, Data^.LastY, 2);
    end;
  end;
end;

procedure _MouseBtnUp(const Client: Pointer; const Button: TMouseButton); stdcall;
var
  Data: PClientData;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    case Button of
      mbLeft: SMART_MouseBtnUp(Data^.Target, Data^.LastX, Data^.LastY, 1);
      mbRight: SMART_MouseBtnUp(Data^.Target, Data^.LastX, Data^.LastY, 0);
      mbMiddle: SMART_MouseBtnUp(Data^.Target, Data^.LastX, Data^.LastY, 2);
    end;
  end;
end;

function _GetMouseBtnState(const Client: Pointer; const Button: TMouseButton): Boolean; stdcall;
var
  Data: PClientData;
begin
  Result := False;
  if (Client <> nil) and (Exp <> nil) then
  begin
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    case Button of
      mbLeft: Result := SMART_GetMouseBtnState(Data^.Target, 1);
      mbRight: Result := SMART_GetMouseBtnState(Data^.Target, 0);
      mbMiddle: Result := SMART_GetMouseBtnState(Data^.Target, 2);
    end;
  end;
end;

procedure _VKeyDown(const Client: Pointer; const VKey: Byte); stdcall;
var
  Data: PClientData;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    if VKey <> VK_RETURN then
      SMART_VKeyDown(Data^.Target, VKey)
    else
      SMART_VKeyDown(Data^.Target, 10);
  end;
end;

procedure _VKeyUp(const Client: Pointer; const VKey: Byte); stdcall;
var
  Data: PClientData;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    if VKey <> VK_RETURN then
      SMART_VKeyUp(Data^.Target, VKey)
    else
      SMART_VKeyUp(Data^.Target, 10);
  end;
end;

procedure _KeyDown(const Client: Pointer; const Key: WideChar); stdcall;
begin
  _VKeyDown(Client, Ord(AnsiChar(Key)));
end;

procedure _KeyUp(const Client: Pointer; const Key: WideChar); stdcall;
begin
  _VKeyUp(Client, Ord(AnsiChar(Key)));
end;

function _GetKeyState(const Client: Pointer; const VKey: Byte): Boolean; stdcall;
var
  Data: PClientData;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    if VKey <> VK_RETURN then
      Result := SMART_GetKeyState(Data^.Target, VKey)
    else
      Result := SMART_GetKeyState(Data^.Target, 10);
  end else
    Result := False;
end;

procedure _Capture(const Client: Pointer; const DC: HDC; const XS, YS, XE, YE, DestX, DestY: Integer); stdcall;
var
  Data: PClientData;
  Box: TBox;
  Info: TBitmapInfo;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    Box := Exp^.TSCARClient_GetImageArea(Client);
    FillChar(Info, SizeOf(TBitmapInfo), 0);
    with Info.bmiHeader do
    begin
      biSize := SizeOf(TBitmapInfoHeader);
      biWidth := Box.Width;
      biHeight := -Box.Height;
      biPlanes := 1;
      biBitCount := 32;
      biCompression := BI_RGB;
    end;
    SetDIBitsToDevice(DC, 0, 0, XE - XS + 1, YE - YS + 1, XS, YS, 0, Box.Height, SMART_GetImageBuffer(Data^.Target),
      Info, DIB_RGB_COLORS);
  end;
end;

function _GetPixel(const Client: Pointer; const X, Y: Integer): Integer; stdcall;
var
  Data: PClientData;
  Box: TBox;
  W: Integer;
  Col: TSCARBmpData;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    Box := Exp^.TSCARClient_GetImageArea(Client);
    W := Box.X2 - Box.X1 + 1;
    Col := SMART_GetImageBuffer(Data^.Target)^[W * Y + X];
    Result := Col.R or Col.G shl 8 or Col.B shl 16;
  end else
    Result := -1;
end;

procedure _Activate(const Client: Pointer); stdcall;
begin
end;

procedure _Destroy(const Client: Pointer); stdcall;
var
  Data: PClientData;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    SMART_ReleaseTarget(Data^.Target);
    Dispose(Data);
  end;
end;

procedure _Clone(const Client: Pointer; const Callbacks: PLibClientCallbacks); stdcall;
begin
  raise Exception.Create('Can''t clone this!');
end;

function CreateSmartClient(const TargetId: Integer): TSCARClient; stdcall;
var
  Data: PClientData;
  Box: TBox;
  Callbacks: PLibClientCallbacks;
  Width, Height: Integer;
  InitStr: AnsiString;
  CurDir: string;
begin
  if Exp <> nil then
  begin
    New(Data);
    Result := Exp^.TSCARLibraryClient_Create;
    InitStr := AnsiString(IntToStr(TargetId));
    CurDir := GetCurrentDir;
    SetCurrentDirectory(PChar(SMART_Dir));
    Data^.Target := SMART_RequestTarget(PAnsiChar(InitStr));
    SetCurrentDirectory(PChar(CurDir));
    SMART_GetTargetSize(Data^.Target, Width, Height);
    Exp^.TSCARLibraryClient_SetData(Result, Data);
    Box := TBox.Create(0, 0, Width - 1, Height - 1);
    Exp^.TSCARClient_SetInputArea(Result, Box);
    Exp^.TSCARClient_SetImageArea(Result, Box);
    Callbacks := Exp^.TSCARLibraryClient_GetCallbacks(Result);
    with Callbacks^ do
    begin
      SetCursorPos := @_SetCursorPos;
      GetCursorPos := @_GetCursorPos;
      MouseBtnDown := @_MouseBtnDown;
      MouseBtnUp := @_MouseBtnUp;
      VKeyDown := @_VKeyDown;
      VKeyUp := @_VKeyUp;
      KeyDown := @_KeyDown;
      KeyUp := @_KeyUp;
      GetKeyState := @_GetKeyState;
      GetCurrentKeyState := @_GetKeyState;
      GetToggleKeyState := @_GetKeyState;
      Capture := @_Capture;
      GetPixel := @_GetPixel;
      Activate := @_Activate;
      Clone := @_Clone;
      Destroy := @_Destroy;
    end;
  end else
    Result := nil;
end;

function SmartClientID(const Idx: Integer): Integer; stdcall;
begin
  Result := SMART_Exp_ClientID(Idx);
end;

function SmartGetClients(const OnlyUnpaired: Boolean): Integer; stdcall;
begin
  Result := SMART_Exp_GetClients(OnlyUnpaired);
end;

function SmartSpawnClient(const RemotePath, Root, Params: AnsiString; const Width, Height: Integer;
  const InitSeq, UserAgent, JVMPath: AnsiString; const MaxMem: Integer): Integer; stdcall;
var
  CurDir: string;
  RemotePathFixed: AnsiString;
  I, L: Integer;
begin
  RemotePathFixed := RemotePath;
  if PathDelim <> '/' then
  begin
    L := Length(RemotePathFixed);
    for I := 1 to L do
      if RemotePathFixed[I] = PathDelim then
        RemotePathFixed[I] := '/';
  end;
  CurDir := GetCurrentDir;
  SetCurrentDirectory(PChar(SMART_Dir));
  Result := SMART_Exp_SpawnClient(PAnsiChar(RemotePathFixed), PAnsiChar(Root), PAnsiChar(Params), Width, Height,
    PAnsiChar(InitSeq), PAnsiChar(UserAgent), PAnsiChar(JVMPath), MaxMem);
  SetCurrentDirectory(PChar(CurDir));
end;

function SmartPairClient(const PID: Integer): Boolean; stdcall;
var
  CurDir: string;
begin
  CurDir := GetCurrentDir;
  SetCurrentDirectory(PChar(SMART_Dir));
  Result := SMART_Exp_PairClient(PID);
  SetCurrentDirectory(PChar(CurDir));
end;

function SmartKillClient(const PID: Integer): Boolean; stdcall;
var
  CurDir: string;
begin
  CurDir := GetCurrentDir;
  SetCurrentDirectory(PChar(SMART_Dir));
  Result := SMART_Exp_KillClient(PID);
  SetCurrentDirectory(PChar(CurDir));
end;

function SmartCurrentClient: Integer; stdcall;
begin
  Result := SMART_Exp_CurrentClient;
end;

function SmartImageArray: Integer; stdcall;
begin
  Result := SMART_Exp_ImageArray;
end;

function SmartDebugArray: Integer; stdcall;
begin
  Result := SMART_Exp_DebugArray;
end;

function SmartGetRefresh: Integer; stdcall;
begin
  Result := SMART_Exp_GetRefresh;
end;

procedure SmartSetRefresh(const X: Integer); stdcall;
begin
  SMART_Exp_SetRefresh(X);
end;

procedure SmartSetTransparentColor(const Color: Integer); stdcall;
begin
  SMART_Exp_SetTransparentColor(Color);
end;

procedure SmartSetDebug(const Enabled: Boolean); stdcall;
begin
  SMART_Exp_SetDebug(Enabled);
end;

procedure SmartSetGraphics(const Enabled: Boolean); stdcall;
begin
  SMART_Exp_SetGraphics(Enabled);
end;

procedure SmartSetEnabled(const Enabled: Boolean); stdcall;
begin
  SMART_Exp_SetEnabled(Enabled);
end;

function SmartActive: Boolean; stdcall;
begin
  Result := SMART_Exp_Active;
end;

function SmartEnabled: Boolean; stdcall;
begin
  Result := SMART_Exp_Enabled;
end;

procedure SmartGetMousePos(out X, Y: Integer); stdcall;
begin
  SMART_Exp_GetMousePos(X, Y);
end;

procedure SmartHoldMouse(const X, Y: Integer; const Left: Boolean); stdcall;
begin
  SMART_Exp_HoldMouse(X, Y, Left);
end;

procedure SmartReleaseMouse(const X, Y: Integer; const Left: Boolean); stdcall;
begin
  SMART_Exp_ReleaseMouse(X, Y, Left);
end;

procedure SmartHoldMousePlus(const X, Y, Button: Integer); stdcall;
begin
  SMART_Exp_HoldMousePlus(X, Y, Button);
end;

procedure SmartReleaseMousePlus(const X, Y, Button: Integer); stdcall;
begin
  SMART_Exp_ReleaseMousePlus(X, Y, Button);
end;

procedure SmartMoveMouse(const X, Y: Integer); stdcall;
begin
  SMART_Exp_MoveMouse(X, Y);
end;

procedure SmartWindMouse(const X, Y: Integer); stdcall;
begin
  SMART_Exp_WindMouse(X, Y);
end;

procedure SmartClickMouse(const X, Y: Integer; const Left: Boolean); stdcall;
begin
  SMART_Exp_ClickMouse(X, Y, Left);
end;

procedure SmartClickMousePlus(const X, Y, Button: Integer); stdcall;
begin
  SMART_Exp_ClickMousePlus(X, Y, Button);
end;

function SmartIsMouseButtonHeld(const Button: Integer): Boolean; stdcall;
begin
  Result := SMART_Exp_IsMouseButtonHeld(Button);
end;

procedure SmartSendKeys(const Text: AnsiString; const KeyWait, KeyModWait: Integer); stdcall;
begin
  SMART_Exp_SendKeys(PAnsiChar(Text), KeyWait, KeyModWait);
end;

procedure SmartHoldKey(const Code: Integer); stdcall;
begin
  SMART_Exp_HoldKey(Code);
end;

procedure SmartReleaseKey(const Code: Integer); stdcall;
begin
  SMART_Exp_ReleaseKey(Code);
end;

function SmartIsKeyDown(const Code: Integer): Boolean; stdcall;
begin
  Result := SMART_Exp_IsKeyDown(Code);
end;

function SmartGetColor(const X, Y: Integer): Integer; stdcall;
begin
  Result := SMART_Exp_GetColor(X, Y);
end;

function SmartFindColor(out X, Y: Integer; const Color, XS, YS, XE, YE: Integer): Boolean; stdcall;
begin
  Result := SMART_Exp_FindColor(X, Y, Color, XS, YS, XE, YE);
end;

function SmartFindColorTol(out X, Y: Integer; const Color, XS, YS, XE, YE, Tol: Integer): Boolean; stdcall;
begin
  Result := SMART_Exp_FindColorTol(X, Y, Color, XS, YS, XE, YE, Tol);
end;

function SmartFindColorSpiral(out X, Y: Integer; const Color, XS, YS, XE, YE: Integer): Boolean; stdcall;
begin
  Result := SMART_Exp_FindColorSpiral(X, Y, Color, XS, YS, XE, YE);
end;

function SmartFindColorSpiralTol(out X, Y: Integer; const Color, XS, YS, XE, YE, Tol: Integer): Boolean; stdcall;
begin
  Result := SMART_Exp_FindColorSpiralTol(X, Y, Color, XS, YS, XE, YE, Tol);
end;

procedure OnLoadLib(const SCARExports: PExports); stdcall;
begin
  Exp := SCARExports;
end;

procedure OnUnloadLib; stdcall;
begin
  if SMARTLib <> 0 then
    FreeLibrary(SMARTLib);
end;

function OnGetFuncCount: Integer; stdcall;
begin
  Result := 37;
end;

function OnGetFuncInfo(const Idx: Integer; out ProcAddr: Pointer; out ProcDef: PAnsiChar;
  out CallConv: TCallConv): Integer; stdcall;
begin
  Result := Idx;
  case Idx of
    0: begin
      ProcAddr := @GetJVMPath;
      ProcDef := 'function GetJVMPath: string;';
      CallConv := ccStdCall;
    end;
    1: begin
      ProcAddr := @InitSmartLib;
      ProcDef := 'function InitSmartLib(const LibPath: string): Boolean;';
      CallConv := ccStdCall;
    end;
    2: begin
      ProcAddr := @CreateSmartClient;
      ProcDef := 'function CreateSmartClient(const TargetId: Integer): TSCARClient;';
      CallConv := ccStdCall;
    end;
    3: begin
      ProcAddr := @SmartGetClients;
      ProcDef := 'function SmartGetClients(const OnlyUnpaired: Boolean): Integer;';
      CallConv := ccStdCall;
    end;
    4: begin
      ProcAddr := @SmartClientID;
      ProcDef := 'function SmartClientID(const Idx: Integer): Integer;';
      CallConv := ccStdCall;
    end;
    5: begin
      ProcAddr := @SmartSpawnClient;
      ProcDef := 'function SmartSpawnClient(const RemotePath, Root, Params: AnsiString; const Width, Height: Integer; const InitSeq, UserAgent, JVMPath: AnsiString; const MaxMem: Integer): Integer;';
      CallConv := ccStdCall;
    end;
    6: begin
      ProcAddr := @SmartPairClient;
      ProcDef := 'function SmartPairClient(const PID: Integer): Boolean;';
      CallConv := ccStdCall;
    end;
    7: begin
      ProcAddr := @SmartCurrentClient;
      ProcDef := 'function SmartCurrentClient: Integer;';
      CallConv := ccStdCall;
    end;
    8: begin
      ProcAddr := @SmartImageArray;
      ProcDef := 'function SmartImageArray: Integer;';
      CallConv := ccStdCall;
    end;
    9: begin
      ProcAddr := @SmartDebugArray;
      ProcDef := 'function SmartDebugArray: Integer;';
      CallConv := ccStdCall;
    end;
    10: begin
      ProcAddr := @SmartGetRefresh;
      ProcDef := 'function SmartGetRefresh: Integer;';
      CallConv := ccStdCall;
    end;
    11: begin
      ProcAddr := @SmartSetRefresh;
      ProcDef := 'procedure SmartSetRefresh(const X: Integer);';
      CallConv := ccStdCall;
    end;
    12: begin
      ProcAddr := @SmartSetTransparentColor;
      ProcDef := 'procedure SmartSetTransparentColor(const Color: Integer);';
      CallConv := ccStdCall;
    end;
    13: begin
      ProcAddr := @SmartSetDebug;
      ProcDef := 'procedure SmartSetDebug(const Enabled: Boolean);';
      CallConv := ccStdCall;
    end;
    14: begin
      ProcAddr := @SmartSetGraphics;
      ProcDef := 'procedure SmartSetGraphics(const Enabled: Boolean);';
      CallConv := ccStdCall;
    end;
    15: begin
      ProcAddr := @SmartSetEnabled;
      ProcDef := 'procedure SmartSetEnabled(const Enabled: Boolean);';
      CallConv := ccStdCall;
    end;
    16: begin
      ProcAddr := @SmartActive;
      ProcDef := 'function SmartActive: Boolean;';
      CallConv := ccStdCall;
    end;
    17: begin
      ProcAddr := @SmartEnabled;
      ProcDef := 'function SmartEnabled: Boolean;';
      CallConv := ccStdCall;
    end;
    18: begin
      ProcAddr := @SmartGetMousePos;
      ProcDef := 'procedure SmartGetMousePos(out X, Y: Integer);';
      CallConv := ccStdCall;
    end;
    19: begin
      ProcAddr := @SmartHoldMouse;
      ProcDef := 'procedure SmartHoldMouse(const X, Y: Integer; const Left: Boolean); ';
      CallConv := ccStdCall;
    end;
    20: begin
      ProcAddr := @SmartReleaseMouse;
      ProcDef := 'procedure SmartReleaseMouse(const X, Y: Integer; const Left: Boolean);';
      CallConv := ccStdCall;
    end;
    21: begin
      ProcAddr := @SmartHoldMousePlus;
      ProcDef := 'procedure SmartHoldMousePlus(const X, Y, Button: Integer);';
      CallConv := ccStdCall;
    end;
    22: begin
      ProcAddr := @SmartReleaseMousePlus;
      ProcDef := 'procedure SmartReleaseMousePlus(const X, Y, Button: Integer);';
      CallConv := ccStdCall;
    end;
    23: begin
      ProcAddr := @SmartMoveMouse;
      ProcDef := 'procedure SmartMoveMouse(const X, Y: Integer);';
      CallConv := ccStdCall;
    end;
    24: begin
      ProcAddr := @SmartWindMouse;
      ProcDef := 'procedure SmartWindMouse(const X, Y: Integer);';
      CallConv := ccStdCall;
    end;
    25: begin
      ProcAddr := @SmartClickMouse;
      ProcDef := 'procedure SmartClickMouse(const X, Y: Integer; const Left: Boolean);';
      CallConv := ccStdCall;
    end;
    26: begin
      ProcAddr := @SmartClickMousePlus;
      ProcDef := 'procedure SmartClickMousePlus(const X, Y, Button: Integer);';
      CallConv := ccStdCall;
    end;
    27: begin
      ProcAddr := @SmartIsMouseButtonHeld;
      ProcDef := 'function SmartIsMouseButtonHeld(const Button: Integer): Boolean;';
      CallConv := ccStdCall;
    end;
    28: begin
      ProcAddr := @SmartSendKeys;
      ProcDef := 'procedure SmartSendKeys(const Text: AnsiString; const KeyWait, KeyModWait: Integer);';
      CallConv := ccStdCall;
    end;
    29: begin
      ProcAddr := @SmartHoldKey;
      ProcDef := 'procedure SmartHoldKey(const Code: Integer);';
      CallConv := ccStdCall;
    end;
    30: begin
      ProcAddr := @SmartReleaseKey;
      ProcDef := 'procedure SmartReleaseKey(const Code: Integer);';
      CallConv := ccStdCall;
    end;
    31: begin
      ProcAddr := @SmartIsKeyDown;
      ProcDef := 'function SmartIsKeyDown(const Code: Integer): Boolean;';
      CallConv := ccStdCall;
    end;
    32: begin
      ProcAddr := @SmartGetColor;
      ProcDef := 'function SmartGetColor(const X, Y: Integer): Integer;';
      CallConv := ccStdCall;
    end;
    33: begin
      ProcAddr := @SmartFindColor;
      ProcDef := 'function SmartFindColor(out X, Y: Integer; const Color, XS, YS, XE, YE: Integer): Boolean;';
      CallConv := ccStdCall;
    end;
    34: begin
      ProcAddr := @SmartFindColorTol;
      ProcDef := 'function SmartFindColorTol(out X, Y: Integer; const Color, XS, YS, XE, YE, Tol: Integer): Boolean;';
      CallConv := ccStdCall;
    end;
    35: begin
      ProcAddr := @SmartFindColorSpiral;
      ProcDef := 'function SmartFindColorSpiral(out X, Y: Integer; const Color, XS, YS, XE, YE: Integer): Boolean;';
      CallConv := ccStdCall;
    end;
    36: begin
      ProcAddr := @SmartFindColorSpiralTol;
      ProcDef := 'function SmartFindColorSpiralTol(out X, Y: Integer; const Color, XS, YS, XE, YE, Tol: Integer): Boolean;';
      CallConv := ccStdCall;
    end;
    else Result := -1;
  end;
end;

function LibArch: Integer; stdcall;
begin
  Result := 2;
end;

exports OnLoadLib;
exports OnUnloadLib;
exports OnGetFuncCount;
exports OnGetFuncInfo;
exports LibArch;

end.
