unit SMARTApi;

interface

//**
// By Frédéric Hannes (http://www.scar-divi.com)
// License: http://creativecommons.org/licenses/by/3.0/
// -
// Interface to the SMART Remote API.
//**

uses
  WinApi.WinSock, SCARLib;

type
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
  SMART_RequestTarget: function(const InitChars: PAnsiChar): PTarget; stdcall;
  SMART_ReleaseTarget: procedure(const Target: PTarget); stdcall;
  SMART_GetTargetSize: procedure(const Target: PTarget; out Width, Height: Integer); stdcall;
  SMART_GetImageBuffer: function(const Target: PTarget): PSCARBmpDataArray; stdcall;
  SMART_GetMousePos: procedure(const Target: PTarget; out X, Y: Integer); stdcall;
  SMART_SetMousePos: procedure(const Target: PTarget; const X, Y: Integer); stdcall;
  SMART_MouseBtnDown: procedure(const Target: PTarget; const X, Y: Integer; const Btn: Integer); stdcall;
  SMART_MouseBtnUp: procedure(const Target: PTarget; const X, Y: Integer; const Btn: Integer); stdcall;
  SMART_GetMouseBtnState: function(const Target: PTarget; const Btn: Integer): Boolean; stdcall;
  SMART_TypeText: procedure(const Target: PTarget; const Str: PAnsiChar; const KeyWait, KeyModWait: Integer); stdcall;
  SMART_VKeyDown: procedure(const Target: PTarget; const Key: Byte); stdcall;
  SMART_VKeyUp: procedure(const Target: PTarget; const Key: Byte); stdcall;
  SMART_GetKeyState: function(const Target: PTarget; const Key: Byte): Boolean; stdcall;

  SMART_Exp_ClientID: function(const Idx: Integer): Integer; cdecl;
  SMART_Exp_GetClients: function(const OnlyUnpaired: Boolean): Integer; cdecl;
  SMART_Exp_SpawnClient: function(const RemotePath, Root, Params: PAnsiChar; const Width, Height: Integer;
    InitSeq, UserAgent, JVMPath: PAnsiChar; const MaxMem: Integer): Integer; cdecl;
  SMART_Exp_PairClient: function(const PID: Integer): Boolean; cdecl;
  SMART_Exp_KillClient: function(const PID: Integer): Boolean; cdecl;
  SMART_Exp_CurrentClient: function: Integer; cdecl;
  SMART_Exp_GetRefresh: function: Integer; cdecl;
  SMART_Exp_SetRefresh: procedure(const X: Integer); cdecl;
  SMART_Exp_SetTransparentColor: procedure(const Color: Integer); cdecl;
  SMART_Exp_SetDebug: procedure(const Enabled: Boolean); cdecl;
  SMART_Exp_SetGraphics: procedure(const Enabled: Boolean); cdecl;
  SMART_Exp_SetEnabled: procedure(const Enabled: Boolean); cdecl;
  SMART_Exp_Active: function: Boolean; cdecl;
  SMART_Exp_Enabled: function: Boolean; cdecl;

implementation

end.
