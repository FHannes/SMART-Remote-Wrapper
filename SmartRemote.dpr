library SmartRemote;

//**
// By Frédéric Hannes (http://www.scar-divi.com)
// License: http://creativecommons.org/licenses/by/3.0/
//**

{$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  FastShareMem in 'FastShareMem.pas',
  SCARLib in 'SCARLib.pas',
  SMARTApi in 'SMARTApi.pas',
  Vcl_Rtl in 'Vcl_Rtl.pas',
  WinApi.Windows;

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
  GetDir(0, Result);
  if Exp <> nil then
  begin
    Result := Exp^.WorkspacePath + 'SMART' + PathDelim;
    CreateDirectory(PChar(Result), nil);
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
    SMART_Exp_GetRefresh := GetProcAddress(SMARTLib, 'exp_getRefresh');
    SMART_Exp_SetRefresh := GetProcAddress(SMARTLib, 'exp_setRefresh');
    SMART_Exp_SetTransparentColor := GetProcAddress(SMARTLib, 'exp_setTransparentColor');
    SMART_Exp_SetDebug := GetProcAddress(SMARTLib, 'exp_setDebug');
    SMART_Exp_SetGraphics := GetProcAddress(SMARTLib, 'exp_setGraphics');
    SMART_Exp_SetEnabled := GetProcAddress(SMARTLib, 'exp_setEnabled');
    SMART_Exp_Active := GetProcAddress(SMARTLib, 'exp_isActive');
    SMART_Exp_Enabled := GetProcAddress(SMARTLib, 'exp_isBlocking');
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
      mbRight: SMART_MouseBtnDown(Data^.Target, Data^.LastX, Data^.LastY, 3);
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
      mbRight: SMART_MouseBtnUp(Data^.Target, Data^.LastX, Data^.LastY, 3);
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
      mbRight: Result := SMART_GetMouseBtnState(Data^.Target, 3);
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
  W, H: Integer;
  Col: TSCARBmpData;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    try
      Data := Exp^.TSCARLibraryClient_GetData(Client);
      SMART_GetTargetSize(Data^.Target, W, H);
      Col := SMART_GetImageBuffer(Data^.Target)^[W * Y + X];
      Result := Col.R or Col.G shl 8 or Col.B shl 16;
    except
      Result := -1;
    end;
  end else
    Result := -1;
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

procedure _TypeText(const Client: Pointer; const Text: string; const PressIval, PressIvalRnd, ModIval, ModIvalRnd,
  CharIval, CharIvalRnd: Integer; const UseNumpad: Boolean); stdcall;
var
  Data: PClientData;
  Str: AnsiString;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    Str := AnsiString(Text);
    SMART_TypeText(Data^.Target, PAnsiChar(Str), (PressIval + PressIvalRnd) div 2, (ModIval + ModIvalRnd) div 2);
  end;
end;

function _Exists(const Client: Pointer): Boolean; stdcall;
var
  Data: PClientData;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    Result := (Data <> nil) and (Data^.Target <> nil);
  end;
end;

function _Update(const Client: Pointer): Boolean; stdcall;
var
  Data: PClientData;
  W, H: Integer;
  Box: TBox;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    if (Data <> nil) and (Data^.Target <> nil) then
    begin
      SMART_GetTargetSize(Data^.Target, W, H);
      Box := TBox.Create(W, H);
      Exp^.TSCARClient_SetImageArea(Client, Box);
      Exp^.TSCARClient_SetInputArea(Client, Box);
    end;
  end;
end;

function _Clone(const Client: Pointer): Pointer; stdcall;
var
  Callbacks: PLibClientCallbacks;
  Data, NewData: PClientData;
begin
  if (Client <> nil) and (Exp <> nil) then
  begin
    Result := Exp^.TSCARLibraryClient_Create;
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
      Clone := @_Clone;
      Destroy := @_Destroy;
      TypeText := @_TypeText;
      Exists := @_Exists;
      Update := @_Update;
    end;
    Exp^.TSCARClient_SetInputArea(Result, Exp^.TSCARClient_GetInputArea(Client));
    Exp^.TSCARClient_SetImageArea(Result, Exp^.TSCARClient_GetImageArea(Client));
    Data := Exp^.TSCARLibraryClient_GetData(Client);
    New(NewData);
    NewData^.Target := Data^.Target;
    NewData^.LastX := Data^.LastX;
    NewData^.LastY := Data^.LastY;
    Exp^.TSCARLibraryClient_SetData(Result, NewData);
  end else
    Result := nil;
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
    Str(TargetId, InitStr);
    GetDir(0, CurDir);
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
      Clone := @_Clone;
      Destroy := @_Destroy;
      TypeText := @_TypeText;
      Exists := @_Exists;
      Update := @_Update;
    end;
  end else
    Result := nil;
end;

function SmartClientID(const Idx: Integer): Integer; stdcall;
begin
  Result := SMART_Exp_ClientID(Idx);
end;

function SmartGetClients(const OnlyUnpaired: Boolean): Integer; stdcall;
var
  CurDir: string;
begin
  GetDir(0, CurDir);
  SetCurrentDirectory(PChar(SMART_Dir));
  Result := SMART_Exp_GetClients(OnlyUnpaired);
  SetCurrentDirectory(PChar(CurDir));
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
  GetDir(0, CurDir);
  SetCurrentDirectory(PChar(SMART_Dir));
  Result := SMART_Exp_SpawnClient(PAnsiChar(RemotePathFixed), PAnsiChar(Root), PAnsiChar(Params), Width, Height,
    PAnsiChar(InitSeq), PAnsiChar(UserAgent), PAnsiChar(JVMPath), MaxMem);
  SetCurrentDirectory(PChar(CurDir));
end;

function SmartPairClient(const PID: Integer): Boolean; stdcall;
var
  CurDir: string;
begin
  GetDir(0, CurDir);
  SetCurrentDirectory(PChar(SMART_Dir));
  Result := SMART_Exp_PairClient(PID);
  SetCurrentDirectory(PChar(CurDir));
end;

function SmartKillClient(const PID: Integer): Boolean; stdcall;
var
  CurDir: string;
begin
  GetDir(0, CurDir);
  SetCurrentDirectory(PChar(SMART_Dir));
  Result := SMART_Exp_KillClient(PID);
  SetCurrentDirectory(PChar(CurDir));
end;

function SmartCurrentClient: Integer; stdcall;
begin
  Result := SMART_Exp_CurrentClient;
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
  Result := 15;
end;

function OnGetFuncInfo(const Idx: Integer; out ProcAddr: Pointer; out ProcDef: PAnsiChar;
  out CallConv: TCallConv): Integer; stdcall;
begin
  Result := Idx;
  case Idx of
    0: begin
      ProcAddr := @InitSmartLib;
      ProcDef := 'function InitSmartLib(const LibPath: string): Boolean;';
      CallConv := ccStdCall;
    end;
    1: begin
      ProcAddr := @CreateSmartClient;
      ProcDef := 'function CreateSmartClient(const TargetId: Integer): TSCARClient;';
      CallConv := ccStdCall;
    end;
    2: begin
      ProcAddr := @SmartGetClients;
      ProcDef := 'function SmartGetClients(const OnlyUnpaired: Boolean): Integer;';
      CallConv := ccStdCall;
    end;
    3: begin
      ProcAddr := @SmartClientID;
      ProcDef := 'function SmartClientID(const Idx: Integer): Integer;';
      CallConv := ccStdCall;
    end;
    4: begin
      ProcAddr := @SmartSpawnClient;
      ProcDef := 'function SmartSpawnClient(const RemotePath, Root, Params: AnsiString; const Width, Height: Integer; const InitSeq, UserAgent, JVMPath: AnsiString; const MaxMem: Integer): Integer;';
      CallConv := ccStdCall;
    end;
    5: begin
      ProcAddr := @SmartPairClient;
      ProcDef := 'function SmartPairClient(const PID: Integer): Boolean;';
      CallConv := ccStdCall;
    end;
    6: begin
      ProcAddr := @SmartCurrentClient;
      ProcDef := 'function SmartCurrentClient: Integer;';
      CallConv := ccStdCall;
    end;
    7: begin
      ProcAddr := @SmartGetRefresh;
      ProcDef := 'function SmartGetRefresh: Integer;';
      CallConv := ccStdCall;
    end;
    8: begin
      ProcAddr := @SmartSetRefresh;
      ProcDef := 'procedure SmartSetRefresh(const X: Integer);';
      CallConv := ccStdCall;
    end;
    9: begin
      ProcAddr := @SmartSetTransparentColor;
      ProcDef := 'procedure SmartSetTransparentColor(const Color: Integer);';
      CallConv := ccStdCall;
    end;
    10: begin
      ProcAddr := @SmartSetDebug;
      ProcDef := 'procedure SmartSetDebug(const Enabled: Boolean);';
      CallConv := ccStdCall;
    end;
    11: begin
      ProcAddr := @SmartSetGraphics;
      ProcDef := 'procedure SmartSetGraphics(const Enabled: Boolean);';
      CallConv := ccStdCall;
    end;
    12: begin
      ProcAddr := @SmartSetEnabled;
      ProcDef := 'procedure SmartSetEnabled(const Enabled: Boolean);';
      CallConv := ccStdCall;
    end;
    13: begin
      ProcAddr := @SmartActive;
      ProcDef := 'function SmartActive: Boolean;';
      CallConv := ccStdCall;
    end;
    14: begin
      ProcAddr := @SmartEnabled;
      ProcDef := 'function SmartEnabled: Boolean;';
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

