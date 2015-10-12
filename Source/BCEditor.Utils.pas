unit BCEditor.Utils;

interface

uses
  Windows, Math, Classes, Graphics, Dialogs, BCEditor.Consts, BCEditor.Types;

  function CeilOfIntDiv(ADividend: Cardinal; ADivisor: Word): Word;
  function DeleteWhiteSpace(const AStr: string): string;
  function GetTabConvertProc(TabWidth: Integer): TBCEditorTabConvertProc;
  function GetTextSize(AHandle: HDC; AText: PChar; ACount: Integer): TSize;
  function MessageDialog(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer;
  function MinMax(Value, MinValue, MaxValue: Integer): Integer;
  function RoundCorrect(Value: Real): LongInt;
  function TextExtent(ACanvas: TCanvas; const Text: string): TSize;
  function TextWidth(ACanvas: TCanvas; const Text: string): Integer;
  function TextHeight(ACanvas: TCanvas; const Text: string): Integer;
  procedure ClearList(var List: TList);
  procedure FreeList(var List: TList);
  procedure TextOut(ACanvas: TCanvas; X, Y: Integer; const Text: string);

implementation

uses
  Forms, SysUtils, Clipbrd, Character;

procedure FreeList(var List: TList);
begin
  ClearList(List);
  if Assigned(List) then
  begin
    List.Free;
    List := nil;
  end;
end;

function CeilOfIntDiv(ADividend: Cardinal; ADivisor: Word): Word;
var
  LRemainder: Word;
begin
  DivMod(ADividend, ADivisor, Result, LRemainder);
  if LRemainder > 0 then
    Inc(Result);
end;

procedure ClearList(var List: TList);
var
  i: Integer;
begin
  if not Assigned(List) then
    Exit;
  for i := 0 to List.Count - 1 do
  if Assigned(List[i]) then
  begin
    TObject(List[i]).Free;
    List[i] := nil;
  end;
  List.Clear;
end;

function DeleteWhiteSpace(const AStr: string): string;
var
  i, j: Integer;
begin
  SetLength(Result, Length(AStr));
  j := 0;
  for i := 1 to Length(AStr) do
    if not TCharacter.IsWhiteSpace(AStr[i]) then
    begin
      inc(j);
      Result[j] := AStr[i];
    end;
  SetLength(Result, j);
end;

function MessageDialog(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer;
begin
  with CreateMessageDialog(Msg, DlgType, Buttons) do
  try
    HelpContext := 0;
    HelpFile := '';
    Position := poMainFormCenter;
    Result := ShowModal;
  finally
    Free;
  end;
end;

function MinMax(Value, MinValue, MaxValue: Integer): Integer;
begin
  Value := Min(Value, MaxValue);
  Result := Max(Value, MinValue);
end;

function GetHasTabs(Line: PChar; var CharsBefore: Integer): Boolean;
begin
  Result := False;
  CharsBefore := 0;
  if Assigned(Line) then
  begin
    while Line^ <> BCEDITOR_NONE_CHAR do
    begin
      if Line^ = BCEDITOR_TAB_CHAR then
        Exit(True);
      Inc(CharsBefore);
      Inc(Line);
    end;
  end
end;

function ConvertTabs(const Line: string; TabWidth: Integer; var HasTabs: Boolean): string;
var
  PSource: PChar;
begin
  HasTabs := False;
  Result := '';
  PSource := PChar(Line);
  while PSource^ <> BCEDITOR_NONE_CHAR do
  begin
    if PSource^ = BCEDITOR_TAB_CHAR then
    begin
      HasTabs := True;
      Result := Result + StringOfChar(BCEDITOR_SPACE_CHAR, TabWidth);
    end
    else
      Result := Result + PSource^;
    Inc(PSource);
  end;
end;

function GetTabConvertProc(TabWidth: Integer): TBCEditorTabConvertProc;
begin
  Result := TBCEditorTabConvertProc(@ConvertTabs);
end;

function GetTextSize(AHandle: HDC; AText: PChar; ACount: Integer): TSize;
begin
  Result.cx := 0;
  Result.cy := 0;
  GetTextExtentPoint32W(AHandle, AText, ACount, Result);
end;

type
  TAccessCanvas = class(TCanvas)
  end;

function TextExtent(ACanvas: TCanvas; const Text: string): TSize;
begin
  with TAccessCanvas(ACanvas) do
  begin
    RequiredState([csHandleValid, csFontValid]);
    Result := GetTextSize(Handle, PChar(Text), Length(Text));
  end;
end;

function TextWidth(ACanvas: TCanvas; const Text: string): Integer;
begin
  Result := TextExtent(ACanvas, Text).cx;
end;

function TextHeight(ACanvas: TCanvas; const Text: string): Integer;
begin
  Result := TextExtent(ACanvas, Text).cy;
end;

procedure TextOut(ACanvas: TCanvas; x, Y: Integer; const Text: string);
begin
  with TAccessCanvas(ACanvas) do
  begin
    Changing;
    RequiredState([csHandleValid, csFontValid, csBrushValid]);
    if CanvasOrientation = coRightToLeft then
      Inc(x, BCEditor.Utils.TextWidth(ACanvas, Text) + 1);
    Windows.ExtTextOut(Handle, x, Y, TextFlags, nil, PChar(Text), Length(Text), nil);
    MoveTo(x + BCEditor.Utils.TextWidth(ACanvas, Text), Y);
    Changed;
  end;
end;

{procedure TextRect(ACanvas: TCanvas; Rect: TRect; X, Y: Integer; const Text: string);
var
  Options: Longint;
begin
  with TAccessCanvas(ACanvas) do
  begin
    Changing;
    RequiredState([csHandleValid, csFontValid, csBrushValid]);
    Options := ETO_CLIPPED or TextFlags;
    if Brush.Style <> bsClear then
      Options := Options or ETO_OPAQUE;
    if ((TextFlags and ETO_RTLREADING) <> 0) and (CanvasOrientation = coRightToLeft) then
      Inc(X, BCEditor.Utils.TextWidth(ACanvas, Text) + 1);
<<<<<<< HEAD
    Windows.ExtTextOutW(Handle, X, Y, Options, @Rect, PChar(Text), Length(Text), nil);
=======
    Winapi.Windows.ExtTextOut(Handle, X, Y, Options, @Rect, PChar(Text), Length(Text), nil);
>>>>>>> 7a33033832e2660ba9c96be127ace5fe54c94a16
    Changed;
  end;
end;  }

function RoundCorrect(Value: Real): LongInt;
begin
  Result:= Trunc(Value);
  if Frac(Value) >= 0.5 then
    Result := Result + 1;
end;

end.
