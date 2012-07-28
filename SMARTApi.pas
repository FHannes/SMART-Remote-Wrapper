unit SMARTApi;

interface

//**
// By Frédéric Hannes (http://www.scar-divi.com)
// License: http://creativecommons.org/licenses/by/3.0/
// -
// Interface to the SMART Remote API.
//**

uses
  SCARLib;

type
  TSocket = IntPtr; // Replace with WinApi.WinSock namespace for socket access

  PShmData = ^TShmData;
  TShmData = packed record
    Id: Integer;
    Paired: Integer;
    Port: Integer;
    Width, Height: Integer;
    Time: Integer;
    Die: Integer;
    ImgOff: Integer;
    DbgOff: Integer;
    Args: array[0..4095] of AnsiChar;
  end;

  PSMARTClient = ^TSMARTClient;
  TSMARTClient = packed record
    Width, Height: Integer;
    RefCount: Integer;
    Sock: TSocket;
    MapFile: THandle;
    MemMap: THandle;
    Data: PShmData;
  end;

  PTarget = PSMARTClient;

var
  SMART_RequestTarget: function(const InitChars: PAnsiChar): PTarget; cdecl;
  SMART_ReleaseTarget: procedure(const Target: PTarget); cdecl;
  SMART_GetMousePos: procedure(const Target: PTarget; out X, Y: Integer); cdecl;
  SMART_SetMousePos: procedure(const Target: PTarget; const X, Y: Integer); cdecl;
  SMART_MouseBtnDown: procedure(const Target: PTarget; const X, Y: Integer; const Btn: Integer); cdecl;
  SMART_MouseBtnUp: procedure(const Target: PTarget; const X, Y: Integer; const Btn: Integer); cdecl;
  SMART_GetMouseBtnState: function(const Target: PTarget; const Btn: Integer): Boolean; cdecl;
  SMART_TypeText: procedure(const Target: PTarget; const Str: PAnsiChar; const KeyWait, KeyModWait: Integer); cdecl;
  SMART_VKeyDown: procedure(const Target: PTarget; const Key: Integer); cdecl;
  SMART_VKeyUp: procedure(const Target: PTarget; const Key: Integer); cdecl;
  SMART_GetKeyState: function(const Target: PTarget; const Key: Byte): Boolean; cdecl;
  SMART_ClientID: function(const Idx: Integer): Integer; cdecl;
  SMART_GetClients: function(const OnlyUnpaired: Boolean): Integer; cdecl;
  SMART_SpawnClient: function(const RemotePath, Root, Params: PAnsiChar; const Width, Height: Integer;
    InitSeq, UserAgent, JVMPath: PAnsiChar; const MaxMem: Integer): Integer; cdecl;
  SMART_PairClient: function(const PID: Integer): Boolean; cdecl;
  SMART_KillClient: function(const PID: Integer): Boolean; cdecl;
  SMART_GetRefresh: function(const Target: PTarget): Integer; cdecl;
  SMART_SetRefresh: procedure(const Target: PTarget; const X: Integer); cdecl;
  SMART_SetTransparentColor: procedure(const Target: PTarget; const Color: Integer); cdecl;
  SMART_SetDebug: procedure(const Target: PTarget; const Enabled: Boolean); cdecl;
  SMART_SetGraphics: procedure(const Target: PTarget; const Enabled: Boolean); cdecl;
  SMART_SetEnabled: procedure(const Target: PTarget; const Enabled: Boolean); cdecl;
  SMART_Active: function(const Target: PTarget): Boolean; cdecl;
  SMART_Enabled: function(const Target: PTarget): Boolean; cdecl;

procedure SMART_GetTargetSize(const Target: PTarget; out Width, Height: Integer);
function SMART_GetImageBuffer(const Target: PTarget): PSCARBmpDataArray;
function SMART_GetDebugBuffer(const Target: PTarget): PSCARBmpDataArray;

implementation

procedure SMART_GetTargetSize(const Target: PTarget; out Width, Height: Integer);
begin
  if Target <> nil then
  begin
    Width := Target^.Data^.Width;
    Height := Target^.Data^.Height;
  end;
end;

function SMART_GetImageBuffer(const Target: PTarget): PSCARBmpDataArray;
begin
  Result := @Target^.Data^;
  Inc(Result, Target^.Data^.ImgOff div 4);
end;

function SMART_GetDebugBuffer(const Target: PTarget): PSCARBmpDataArray;
begin
  Result := @Target^.Data^;
  Inc(Result, Target^.Data^.DbgOff div 4);
end;

end.
