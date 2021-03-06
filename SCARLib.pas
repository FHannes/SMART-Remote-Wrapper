unit SCARLib;

//**
// By Fr�d�ric Hannes (http://www.scar-divi.com)
// License: http://creativecommons.org/licenses/by/3.0/
// -
// SCAR Divi 3.35 function exports unit. DO NOT MODIFY THIS UNIT!
// When a new verison of SCAR Divi is available, you can aquire
// an updated with additional functionality in the samples svn:
// http://svn.scar-divi.com/samples/libraries/main/
//**

interface

// DO NOT MODIFY THIS UNIT!

uses
  Vcl_Rtl,
  WinApi.Windows;

type
  TCallConv = (ccRegister, ccPascal, ccCdecl, ccStdCall, ccSafeCall);

  TSCARClient = Pointer;
  TSCARBitmap = Pointer;

  PSCARBmpData = ^TSCARBmpData;
  TSCARBmpData = packed record
    case Integer of
      0: (B, G, R, A: Byte);
      1: (Color: Cardinal);
  end;

  PSCARBmpDataArray = ^TSCARBmpDataArray;
  TSCARBmpDataArray = array[0..0] of TSCARBmpData;

  PLibClientCallbacks = ^TLibClientCallbacks;
  TLibClientCallbacks = record
    SetCursorPos: procedure(const Client: TSCARClient; const X, Y: Integer); stdcall;
    GetCursorPos: procedure(const Client: TSCARClient; out X, Y: Integer); stdcall;
    MouseBtnDown: procedure(const Client: TSCARClient; const Button: TMouseButton); stdcall;
    MouseBtnUp: procedure(const Client: TSCARClient; const Button: TMouseButton); stdcall;
    GetMouseBtnState: function(const Client: TSCARClient; const Btn: TMouseButton): Boolean; stdcall;
    VKeyDown: procedure(const Client: TSCARClient; const VKey: Byte); stdcall;
    VKeyUp: procedure(const Client: TSCARClient; const VKey: Byte); stdcall;
    KeyDown: procedure(const Client: TSCARClient; const Key: WideChar); stdcall;
    KeyUp: procedure(const Client: TSCARClient; const Key: WideChar); stdcall;
    GetKeyState: function(const Client: TSCARClient; const VKey: Byte): Boolean; stdcall;
    GetCurrentKeyState: function(const Client: TSCARClient; const VKey: Byte): Boolean; stdcall;
    GetToggleKeyState: function(const Client: TSCARClient; const VKey: Byte): Boolean; stdcall;
    Capture: procedure(const Client: TSCARClient; const DC: HDC; const XS, YS, XE, YE, DestX, DestY: Integer); stdcall;
    GetPixel: function(const Client: TSCARClient; const X, Y: Integer): Integer; stdcall;
    Activate: procedure(const Client: TSCARClient); stdcall;
    Clone: function(const Client: TSCARClient): TSCARClient; stdcall;
    Destroy: procedure(const Client: TSCARClient); stdcall;
    TypeText: procedure(const Client: TSCARClient; const Text: string; const PressIval, PressIvalRnd, ModIval, ModIvalRnd,
      CharIval, CharIvalRnd: Integer; const UseNumpad: Boolean); stdcall;
    Exists: function(const Client: TSCARClient): Boolean; stdcall;
    Update: function(const Client: TSCARClient): Boolean; stdcall;
  end;

  PBox = ^TBox;
  TBox = record
    X1, Y1, X2, Y2: Integer;
  private
    function GetWidth: Integer;
    function GetHeight: Integer;
  public
    constructor Create(const X1, Y1, X2, Y2: Integer); overload;
    constructor Create(const Width, Height: Integer); overload;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
  end;

  PExports = ^TExports;
  TExports = record
    Version: function: Integer; stdcall;
    DebugLn: procedure(const Str: PWideChar); stdcall;
    DebugLnA: procedure(const Str: PAnsiChar); stdcall;
    GetClient: function: Pointer; stdcall;
    SetClient: function(const Client: Pointer): Pointer; stdcall;
    AppPath: function: string; stdcall;
    AppPathA: function: AnsiString; stdcall;
    ScriptPath: function: string; stdcall;
    ScriptPathA: function: AnsiString; stdcall;
    ScriptFileName: function: string; stdcall;
    ScriptFileNameA: function: AnsiString; stdcall;
    IncludesPath: function: string; stdcall;
    IncludesPathA: function: AnsiString; stdcall;
    FontsPath: function: string; stdcall;
    FontsPathA: function: AnsiString; stdcall;
    LogsPath: function: string; stdcall;
    LogsPathA: function: AnsiString; stdcall;
    WorkspacePath: function: string; stdcall;
    WorkspacePathA: function: AnsiString; stdcall;
    ScreenPath: function: string; stdcall;
    ScreenPathA: function: AnsiString; stdcall;
    TSCARBitmap_Create: function: TSCARBitmap; stdcall;
    TSCARBitmap_Free: procedure(const Bmp: TSCARBitmap); stdcall;
    TSCARBitmap_SetSize: procedure(const Bmp: TSCARBitmap; const NewWidth, NewHeight: Integer); stdcall;
    TSCARBitmap_Resize: procedure(const Bmp: TSCARBitmap; const NewWidth, NewHeight: Integer); stdcall;
    TSCARBitmap_Clone: function(const Bmp: TSCARBitmap): TSCARBitmap; stdcall;
    TSCARBitmap_Assign: procedure(const Bmp: TSCARBitmap; const Obj: TObject); stdcall;
    TSCARBitmap_AssignTo: procedure(const Bmp: TSCARBitmap; const Obj: TObject); stdcall;
    TSCARBitmap_Clear: procedure(const Bmp: TSCARBitmap; const Color: Integer); stdcall;
    TSCARBitmap_LoadFromBmp: function(const Bmp: TSCARBitmap; const Path: PWideChar): Boolean; stdcall;
    TSCARBitmap_LoadFromBmpA: function(const Bmp: TSCARBitmap; const Path: PAnsiChar): Boolean; stdcall;
    TSCARBitmap_SaveToBmp: function(const Bmp: TSCARBitmap; const Path: PWideChar): Boolean; stdcall;
    TSCARBitmap_SaveToBmpA: function(const Bmp: TSCARBitmap; const Path: PAnsiChar): Boolean; stdcall;
    TSCARBitmap_LoadFromPng: function(const Bmp: TSCARBitmap; const Path: PWideChar): Boolean; stdcall;
    TSCARBitmap_LoadFromPngA: function(const Bmp: TSCARBitmap; const Path: PAnsiChar): Boolean; stdcall;
    TSCARBitmap_SaveToPng: function(const Bmp: TSCARBitmap; const Path: PWideChar): Boolean; stdcall;
    TSCARBitmap_SaveToPngA: function(const Bmp: TSCARBitmap; const Path: PAnsiChar): Boolean; stdcall;
    TSCARBitmap_LoadFromJpeg: function(const Bmp: TSCARBitmap; const Path: PWideChar): Boolean; stdcall;
    TSCARBitmap_LoadFromJpegA: function(const Bmp: TSCARBitmap; const Path: PAnsiChar): Boolean; stdcall;
    TSCARBitmap_SaveToJpeg: function(const Bmp: TSCARBitmap; const Path: PWideChar; const Quality: Integer): Boolean; stdcall;
    TSCARBitmap_SaveToJpegA: function(const Bmp: TSCARBitmap; const Path: PAnsiChar; const Quality: Integer): Boolean; stdcall;
    TSCARBitmap_LoadFromStr: procedure(const Bmp: TSCARBitmap; const DataStr: PAnsiChar); stdcall;
    TSCARBitmap_SaveToStr: procedure(const Bmp: TSCARBitmap; out DataStr: PAnsiChar); stdcall;
    TSCARBitmap_Flip: procedure(const Bmp: TSCARBitmap; const Horizontal: Boolean); stdcall;
    TSCARBitmap_Rotate: procedure(const Bmp: TSCARBitmap; const Angle: Extended); stdcall;
    TSCARBitmap_SetAlphaMask: procedure(const Bmp, Mask: TSCARBitmap); stdcall;
    TSCARBitmap_GetAlphaMask: function(const Bmp: TSCARBitmap): TSCARBitmap; stdcall;
    TSCARBitmap_DrawTo: procedure(const Bmp, Target: TSCARBitmap; const X, Y: Integer); stdcall;
    TSCARBitmap_DrawToEx: procedure(const Bmp, Target: TSCARBitmap; const X1, Y1, X2, Y2: Integer); stdcall;
    TSCARBitmap_GetCanvas: function(const Bmp: TSCARBitmap): TCanvas; stdcall;
    TSCARBitmap_GetDC: function(const Bmp: TSCARBitmap): HDC; stdcall;
    TSCARBitmap_GetWidth: function(const Bmp: TSCARBitmap): Integer; stdcall;
    TSCARBitmap_SetWidth: procedure(const Bmp: TSCARBitmap; const NewWidth: Integer); stdcall;
    TSCARBitmap_GetHeight: function(const Bmp: TSCARBitmap): Integer; stdcall;
    TSCARBitmap_SetHeight: procedure(const Bmp: TSCARBitmap; const NewHeight: Integer); stdcall;
    TSCARBitmap_GetBits: function(const Bmp: TSCARBitmap): PSCARBmpDataArray; stdcall;
    TSCARBitmap_GetTranspColor: function(const Bmp: TSCARBitmap): Integer; stdcall;
    TSCARBitmap_SetTranspColor: procedure(const Bmp: TSCARBitmap; const TranspColor: Integer); stdcall;
    TSCARBitmap_GetPixels: function(const Bmp: TSCARBitmap; const X, Y: Integer): Integer; stdcall;
    TSCARBitmap_SetPixels: procedure(const Bmp: TSCARBitmap; const X, Y, Color: Integer); stdcall;
    TSCARBitmap_GetAlphaBlend: function(const Bmp: TSCARBitmap): Boolean; stdcall;
    TSCARBitmap_SetAlphaBlend: procedure(const Bmp: TSCARBitmap; const AlphaBlend: Boolean); stdcall;
    TSCARLibraryClient_Create: function: TSCARClient; stdcall;
    TSCARLibraryClient_GetCallbacks: function(const Client: TSCARClient): PLibClientCallbacks; stdcall;
    TSCARLibraryClient_GetData: function(const Client: TSCARClient): Pointer; stdcall;
    TSCARLibraryClient_SetData: procedure(const Client: TSCARClient; const Data: Pointer); stdcall;
    TSCARClient_GetInputArea: function(const Client: TSCARClient): TBox; stdcall;
    TSCARClient_SetInputArea: procedure(const Client: TSCARClient; const Box: TBox); stdcall;
    TSCARClient_GetImageArea: function(const Client: TSCARClient): TBox; stdcall;
    TSCARClient_SetImageArea: procedure(const Client: TSCARClient; const Box: TBox); stdcall;
    TSCARClient_Activate: procedure(const Client: TSCARClient); stdcall;
    TSCARClient_Clone: function(const Client: TSCARClient): Pointer; stdcall;
    TSCARClient_Capture: function(const Client: TSCARClient): TSCARBitmap; stdcall;
    TSCARClient_CaptureEx: function(const Client: TSCARClient; const XS, YS, XE, YE: Integer): TSCARBitmap; stdcall;
    TSCARClient_Free: procedure(const Client: TSCARClient); stdcall;
  end;

var
  Exp: PExports = nil;

implementation

{ TBox }

constructor TBox.Create(const X1, Y1, X2, Y2: Integer);
begin
  Self.X1 := X1;
  Self.Y1 := Y1;
  Self.X2 := X2;
  Self.Y2 := Y2;
end;

constructor TBox.Create(const Width, Height: Integer);
begin
  Self.X1 := 0;
  Self.Y1 := 0;
  Self.X2 := Width - 1;
  Self.Y2 := Height - 1;
end;

function TBox.GetHeight: Integer;
begin
  Result := Y2 - Y1 + 1;
end;

function TBox.GetWidth: Integer;
begin
  Result := X2 - X1 + 1;
end;

end.
