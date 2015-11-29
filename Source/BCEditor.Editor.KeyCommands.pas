unit BCEditor.Editor.KeyCommands;

interface

uses
  Classes, SysUtils, Menus;

const
  bceNone = 0;
  bceEditCommandFirst = 501;
  bceEditCommandLast = 1000;
  { Caret moving }
  bceLeft = 1;
  bceRight = 2;
  bceUp = 3;
  bceDown = 4;
  bceWordLeft = 5;
  bceWordRight = 6;
  bceLineStart = 7;
  bceLineEnd = 8;
  bcePageUp = 9;
  bcePageDown = 10;
  bcePageLeft = 11;
  bcePageRight = 12;
  bcePageTop = 13;
  bcePageBottom = 14;
  bceEditorTop = 15;
  bceEditorBottom = 16;
  bceGotoXY = 17;
  { Selection }
  bceSelection = 100;
  bceSelectionLeft = bceLeft + bceSelection;
  bceSelectionRight = bceRight + bceSelection;
  bceSelectionUp = bceUp + bceSelection;
  bceSelectionDown = bceDown + bceSelection;
  bceSelectionWordLeft = bceWordLeft + bceSelection;
  bceSelectionWordRight = bceWordRight + bceSelection;
  bceSelectionLineStart = bceLineStart + bceSelection;
  bceSelectionLineEnd = bceLineEnd + bceSelection;
  bceSelectionPageUp = bcePageUp + bceSelection;
  bceSelectionPageDown = bcePageDown + bceSelection;
  bceSelectionPageLeft = bcePageLeft + bceSelection;
  bceSelectionPageRight = bcePageRight + bceSelection;
  bceSelectionPageTop = bcePageTop + bceSelection;
  bceSelectionPageBottom = bcePageBottom + bceSelection;
  bceSelectionEditorTop = bceEditorTop + bceSelection;
  bceSelectionEditorBottom = bceEditorBottom + bceSelection;
  bceSelectionGotoXY = bceGotoXY + bceSelection;
  bceSelectionScope = bceSelection + 21;
  bceSelectionWord = bceSelection + 22;
  bceSelectAll = bceSelection + 23;
  { Scrolling }
  bceScrollUp = 211;
  bceScrollDown = 212;
  bceScrollLeft = 213;
  bceScrollRight = 214;
  { Mode }
  bceInsertMode = 221;
  bceOverwriteMode = 222;
  bceToggleMode = 223;
  { Selection modes }
  bceNormalSelect = 231;
  bceColumnSelect = 232;
  bceLineSelect = 233;
  { Bookmark }
  bceGotoBookmark1 = 302;
  bceGotoBookmark2 = 303;
  bceGotoBookmark3 = 304;
  bceGotoBookmark4 = 305;
  bceGotoBookmark5 = 306;
  bceGotoBookmark6 = 307;
  bceGotoBookmark7 = 308;
  bceGotoBookmark8 = 309;
  bceGotoBookmark9 = 310;
  bceSetBookmark1 = 352;
  bceSetBookmark2 = 353;
  bceSetBookmark3 = 354;
  bceSetBookmark4 = 355;
  bceSetBookmark5 = 356;
  bceSetBookmark6 = 357;
  bceSetBookmark7 = 358;
  bceSetBookmark8 = 359;
  bceSetBookmark9 = 360;
  { Focus }
  bceGotFocus = 480;
  bceLostFocus = 481;
  { Help }
  bceContextHelp = 490;
  { Deletion }
  bceBackspace = 501;
  bceDeleteChar = 502;
  bceDeleteWord = 503;
  bceDeleteLastWord = 504;
  bceDeleteBeginningOfLine = 505;
  bceDeleteEndOfLine = 506;
  bceDeleteLine = 507;
  bceClear = 508;
  { Insert }
  bceLineBreak = 509;
  bceInsertLine = 510;
  bceChar = 511;
  bceString = 512;
  bceImeStr = 550;
  { Clipboard }
  bceUndo = 601;
  bceRedo = 602;
  bceCopy = 603;
  bceCut = 604;
  bcePaste = 605;
  { Indent }
  bceBlockIndent = 610;
  bceBlockUnindent = 611;
  bceTab = 612;
  bceShiftTab = 613;
  { Case }
  bceUpperCase = 620;
  bceLowerCase = 621;
  bceAlternatingCase = 622;
  bceSentenceCase = 623;
  bceTitleCase = 624;
  bceUpperCaseBlock = 625;
  bceLowerCaseBlock = 626;
  bceAlternatingCaseBlock = 627;
  { Move }
  bceMoveLineUp      = 701;
  bceMoveLineDown    = 702;
  bceMoveCharLeft    = 703;
  bceMoveCharRight   = 704;
  { Search }
  bceSearchNext = 800;
  bceSearchPrevious = 801;

  bceUserFirst = 1001;
  { code folding }
  bceCollapse = bceUserFirst + 100;
  bceUncollapse = bceUserFirst + 101;
  bceCollapseLevel = bceUserFirst + 102;
  bceUncollapseLevel = bceUserFirst + 103;
  bceCollapseAll = bceUserFirst + 104;
  bceUncollapseAll = bceUserFirst + 105;
  bceCollapseCurrent = bceUserFirst + 109;

type
  TBCEditorCommand = type Word;

  TBCEditorHookedCommandEvent = procedure(Sender: TObject; AfterProcessing: Boolean; var AHandled: Boolean; var ACommand: TBCEditorCommand; var AChar: Char; Data: Pointer; AHandlerData: Pointer) of object;
  TBCEditorProcessCommandEvent = procedure(Sender: TObject; var ACommand: TBCEditorCommand; var AChar: Char; AData: Pointer) of object;
  TBCEditorHookedCommandHandler = class(TObject)
  strict private
    FEvent: TBCEditorHookedCommandEvent;
    FData: Pointer;
  public
    constructor Create(AEvent: TBCEditorHookedCommandEvent; AData: pointer);
    function Equals(AEvent: TBCEditorHookedCommandEvent): Boolean; reintroduce;
    property Data: Pointer read FData write FData;
    property Event: TBCEditorHookedCommandEvent read FEvent write FEvent;
  end;

  TBCEditorKeyCommand = class(TCollectionItem)
  strict private
    FKey: Word;
    FSecondaryKey: Word;
    FShiftState: TShiftState;
    FSecondaryShiftState: TShiftState;
    FCommand: TBCEditorCommand;
    function GetShortCut: TShortCut;
    function GetSecondaryShortCut: TShortCut;
    procedure SetCommand(const AValue: TBCEditorCommand);
    procedure SetKey(const AValue: Word);
    procedure SetSecondaryKey(const AValue: Word);
    procedure SetShiftState(const AValue: TShiftState);
    procedure SetSecondaryShiftState(const AValue: TShiftState);
    procedure SetShortCut(const AValue: TShortCut);
    procedure SetSecondaryShortCut(const AValue: TShortCut);
  protected
    function GetDisplayName: string; override;
  public
    procedure Assign(ASource: TPersistent); override;
    property Key: Word read FKey write SetKey;
    property SecondaryKey: Word read FSecondaryKey write SetSecondaryKey;
    property ShiftState: TShiftState read FShiftState write SetShiftState;
    property SecondaryShiftState: TShiftState read FSecondaryShiftState write SetSecondaryShiftState;
  published
    property Command: TBCEditorCommand read FCommand write SetCommand;
    property ShortCut: TShortCut read GetShortCut write SetShortCut default 0;
    property SecondaryShortCut: TShortCut read GetSecondaryShortCut write SetSecondaryShortCut default 0;
  end;

  TBCEditorKeyCommands = class(TCollection)
  strict private
    FOwner: TPersistent;
    function GetItem(AIndex: Integer): TBCEditorKeyCommand;
    procedure SetItem(AIndex: Integer; AValue: TBCEditorKeyCommand);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent);
    function FindCommand(ACommand: TBCEditorCommand): Integer;
    function FindKeyCode(AKeyCode: Word; AShift: TShiftState): Integer;
    function FindKeyCodes(AKeyCode: Word; AShift: TShiftState; ASecondaryKeycode: Word; ASecondaryShift: TShiftState): Integer;
    function FindShortcut(AShortCut: TShortCut): Integer;
    function FindShortcuts(AShortCut, ASecondaryShortCut: TShortCut): Integer;
    function NewItem: TBCEditorKeyCommand;
    procedure Add(const ACommand: TBCEditorCommand; const AShift: TShiftState; const AKey: Word);
    procedure Assign(ASource: TPersistent); override;
    procedure ResetDefaults;
  public
    property Items[AIndex: Integer]: TBCEditorKeyCommand read GetItem write SetItem; default;
  end;

function IdentToEditorCommand(const AIdent: string; var ACommand: LongInt): Boolean;
function EditorCommandToIdent(ACommand: LongInt; var AIdent: string): Boolean;

implementation

uses
  Windows, BCEditor.Language;

type
  TBCEditorCommandString = record
    Value: TBCEditorCommand;
    Name: string;
  end;

const
  EditorCommandStrings: array [0 .. 109] of TBCEditorCommandString = (
    (Value: bceNone; Name: 'ecNone'),
    (Value: bceLeft; Name: 'ecLeft'),
    (Value: bceRight; Name: 'ecRight'),
    (Value: bceUp; Name: 'ecUp'),
    (Value: bceDown; Name: 'ecDown'),
    (Value: bceWordLeft; Name: 'ecWordLeft'),
    (Value: bceWordRight; Name: 'ecWordRight'),
    (Value: bceLineStart; Name: 'ecLineStart'),
    (Value: bceLineEnd; Name: 'ecLineEnd'),
    (Value: bcePageUp; Name: 'ecPageUp'),
    (Value: bcePageDown; Name: 'ecPageDown'),
    (Value: bcePageLeft; Name: 'ecPageLeft'),
    (Value: bcePageRight; Name: 'ecPageRight'),
    (Value: bcePageTop; Name: 'ecPageTop'),
    (Value: bcePageBottom; Name: 'ecPageBottom'),
    (Value: bceEditorTop; Name: 'ecEditorTop'),
    (Value: bceEditorBottom; Name: 'ecEditorBottom'),
    (Value: bceGotoXY; Name: 'ecGotoXY'),
    (Value: bceSelectionLeft; Name: 'ecSelectionLeft'),
    (Value: bceSelectionRight; Name: 'ecSelectionRight'),
    (Value: bceSelectionUp; Name: 'ecSelectionUp'),
    (Value: bceSelectionDown; Name: 'ecSelectionDown'),
    (Value: bceSelectionWordLeft; Name: 'ecSelectionWordLeft'),
    (Value: bceSelectionWordRight; Name: 'ecSelectionWordRight'),
    (Value: bceSelectionLineStart; Name: 'ecSelectionLineStart'),
    (Value: bceSelectionLineEnd; Name: 'ecSelectionLineEnd'),
    (Value: bceSelectionPageUp; Name: 'ecSelectionPageUp'),
    (Value: bceSelectionPageDown; Name: 'ecSelectionPageDown'),
    (Value: bceSelectionPageLeft; Name: 'ecSelectionPageLeft'),
    (Value: bceSelectionPageRight; Name: 'ecSelectionPageRight'),
    (Value: bceSelectionPageTop; Name: 'ecSelectionPageTop'),
    (Value: bceSelectionPageBottom; Name: 'ecSelectionPageBottom'),
    (Value: bceSelectionEditorTop; Name: 'ecSelectionEditorTop'),
    (Value: bceSelectionEditorBottom; Name: 'ecSelectionEditorBottom'),
    (Value: bceSelectionGotoXY; Name: 'ecSelectionGotoXY'),
    (Value: bceSelectionWord; Name: 'ecSelectionWord'),
    (Value: bceSelectAll; Name: 'ecSelectAll'),
    (Value: bceScrollUp; Name: 'ecScrollUp'),
    (Value: bceScrollDown; Name: 'ecScrollDown'),
    (Value: bceScrollLeft; Name: 'ecScrollLeft'),
    (Value: bceScrollRight; Name: 'ecScrollRight'),
    (Value: bceBackspace; Name: 'ecBackspace'),
    (Value: bceDeleteChar; Name: 'ecDeleteChar'),
    (Value: bceDeleteWord; Name: 'ecDeleteWord'),
    (Value: bceDeleteLastWord; Name: 'ecDeleteLastWord'),
    (Value: bceDeleteBeginningOfLine; Name: 'ecDeleteBeginningOfLine'),
    (Value: bceDeleteEndOfLine; Name: 'ecDeleteEndOfLine'),
    (Value: bceDeleteLine; Name: 'ecDeleteLine'),
    (Value: bceClear; Name: 'ecClear'),
    (Value: bceLineBreak; Name: 'ecLineBreak'),
    (Value: bceInsertLine; Name: 'ecInsertLine'),
    (Value: bceChar; Name: 'ecChar'),
    (Value: bceImeStr; Name: 'ecImeStr'),
    (Value: bceUndo; Name: 'ecUndo'),
    (Value: bceRedo; Name: 'ecRedo'),
    (Value: bceCut; Name: 'ecCut'),
    (Value: bceCopy; Name: 'ecCopy'),
    (Value: bcePaste; Name: 'ecPaste'),
    (Value: bceInsertMode; Name: 'ecInsertMode'),
    (Value: bceOverwriteMode; Name: 'ecOverwriteMode'),
    (Value: bceToggleMode; Name: 'ecToggleMode'),
    (Value: bceBlockIndent; Name: 'ecBlockIndent'),
    (Value: bceBlockUnindent; Name: 'ecBlockUnindent'),
    (Value: bceTab; Name: 'ecTab'),
    (Value: bceShiftTab; Name: 'ecShiftTab'),
    (Value: bceNormalSelect; Name: 'ecNormalSelect'),
    (Value: bceColumnSelect; Name: 'ecColumnSelect'),
    (Value: bceLineSelect; Name: 'ecLineSelect'),
    (Value: bceUserFirst; Name: 'ecUserFirst'),
    (Value: bceContextHelp; Name: 'ecContextHelp'),
    (Value: bceGotoBookmark1; Name: 'ecGotoBookmark1'),
    (Value: bceGotoBookmark2; Name: 'ecGotoBookmark2'),
    (Value: bceGotoBookmark3; Name: 'ecGotoBookmark3'),
    (Value: bceGotoBookmark4; Name: 'ecGotoBookmark4'),
    (Value: bceGotoBookmark5; Name: 'ecGotoBookmark5'),
    (Value: bceGotoBookmark6; Name: 'ecGotoBookmark6'),
    (Value: bceGotoBookmark7; Name: 'ecGotoBookmark7'),
    (Value: bceGotoBookmark8; Name: 'ecGotoBookmark8'),
    (Value: bceGotoBookmark9; Name: 'ecGotoBookmark9'),
    (Value: bceSetBookmark1; Name: 'ecSetBookmark1'),
    (Value: bceSetBookmark2; Name: 'ecSetBookmark2'),
    (Value: bceSetBookmark3; Name: 'ecSetBookmark3'),
    (Value: bceSetBookmark4; Name: 'ecSetBookmark4'),
    (Value: bceSetBookmark5; Name: 'ecSetBookmark5'),
    (Value: bceSetBookmark6; Name: 'ecSetBookmark6'),
    (Value: bceSetBookmark7; Name: 'ecSetBookmark7'),
    (Value: bceSetBookmark8; Name: 'ecSetBookmark8'),
    (Value: bceSetBookmark9; Name: 'ecSetBookmark9'),
    (Value: bceString; Name: 'ecString'),
    (Value: bceMoveLineUp; Name: 'ecMoveLineUp'),
    (Value: bceMoveLineDown; Name: 'ecMoveLineDown'),
    (Value: bceMoveCharLeft; Name: 'ecMoveCharLeft'),
    (Value: bceMoveCharRight; Name: 'ecMoveCharRight'),
    (Value: bceUpperCase; Name: 'ecUpperCase'),
    (Value: bceLowerCase; Name: 'ecLowerCase'),
    (Value: bceAlternatingCase; Name: 'ecAlternatingCase'),
    (Value: bceSentenceCase; Name: 'ecSentenceCase'),
    (Value: bceTitleCase; Name: 'ecTitleCase'),
    (Value: bceUpperCaseBlock; Name: 'ecUpperCaseBlock'),
    (Value: bceLowerCaseBlock; Name: 'ecLowerCaseBlock'),
    (Value: bceAlternatingCaseBlock; Name: 'ecAlternatingCaseBlock'),
    (Value: bceCollapse; Name: 'ecCollapse'),
    (Value: bceUncollapse; Name: 'ecUncollapse'),
    (Value: bceCollapseLevel; Name: 'ecCollapseLevel'),
    (Value: bceUncollapseLevel; Name: 'ecUncollapseLevel'),
    (Value: bceCollapseAll; Name: 'ecCollapseAll'),
    (Value: bceUncollapseAll; Name: 'ecUncollapseAll'),
    (Value: bceCollapseCurrent; Name: 'ecCollapseCurrent'),
    (Value: bceSearchNext; Name: 'ecSearchNext'),
    (Value: bceSearchPrevious; Name: 'ecSearchPrevious')
  );

function IdentToEditorCommand(const AIdent: string; var ACommand: LongInt): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := Low(EditorCommandStrings) to High(EditorCommandStrings) do
    if CompareText(EditorCommandStrings[i].Name, AIdent) = 0 then
    begin
      ACommand := EditorCommandStrings[i].Value;
      Exit;
    end;
  Result := False;
end;

function EditorCommandToIdent(ACommand: LongInt; var AIdent: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := Low(EditorCommandStrings) to High(EditorCommandStrings) do
    if EditorCommandStrings[i].Value = ACommand then
    begin
      AIdent := EditorCommandStrings[i].Name;
      Exit;
    end;
  Result := False;
end;

function EditorCommandToCodeString(ACommand: TBCEditorCommand): string;
begin
  if not EditorCommandToIdent(ACommand, Result) then
    Result := IntToStr(ACommand);
end;

{ TBCEditorHookedCommandHandler }

constructor TBCEditorHookedCommandHandler.Create(AEvent: TBCEditorHookedCommandEvent; AData: pointer);
begin
  inherited Create;
  FEvent := AEvent;
  FData := AData;
end;

function TBCEditorHookedCommandHandler.Equals(AEvent: TBCEditorHookedCommandEvent): Boolean;
begin
  Result := (TMethod(FEvent).Code = TMethod(AEvent).Code) and (TMethod(FEvent).Data = TMethod(AEvent).Data);
end;

{ TBCEditorKeyCommand }

procedure TBCEditorKeyCommand.Assign(ASource: TPersistent);
begin
  if Assigned(ASource) and (ASource is TBCEditorKeyCommand) then
  with ASource as TBCEditorKeyCommand do
  begin
    Self.FCommand := FCommand;
    Self.FKey := FKey;
    Self.FSecondaryKey := FSecondaryKey;
    Self.FShiftState := FShiftState;
    Self.FSecondaryShiftState := FSecondaryShiftState;
  end
  else
    inherited Assign(ASource);
end;

function TBCEditorKeyCommand.GetDisplayName: string;
begin
  Result := EditorCommandToCodeString(Command) + ' - ' + ShortCutToText(ShortCut);
  if SecondaryShortCut <> 0 then
    Result := Result + ' ' + ShortCutToText(SecondaryShortCut);
  if Result = '' then
    Result := inherited GetDisplayName;
end;

function TBCEditorKeyCommand.GetShortCut: TShortCut;
begin
  Result := Menus.ShortCut(Key, ShiftState);
end;

procedure TBCEditorKeyCommand.SetCommand(const AValue: TBCEditorCommand);
begin
  if FCommand <> AValue then
    FCommand := AValue;
end;

procedure TBCEditorKeyCommand.SetKey(const AValue: Word);
begin
  if FKey <> AValue then
    FKey := AValue;
end;

procedure TBCEditorKeyCommand.SetShiftState(const AValue: TShiftState);
begin
  if FShiftState <> AValue then
    FShiftState := AValue;
end;

procedure TBCEditorKeyCommand.SetShortCut(const AValue: TShortCut);
var
  LNewKey: Word;
  LNewShiftState: TShiftState;
  LDuplicate: Integer;
begin
  if AValue <> 0 then
  begin
    LDuplicate := TBCEditorKeyCommands(Collection).FindShortcuts(AValue, SecondaryShortCut);
    if (LDuplicate <> -1) and (LDuplicate <> Self.Index) then
      raise Exception.Create(SBCEditorDuplicateShortcut);
  end;

  Menus.ShortCutToKey(AValue, LNewKey, LNewShiftState);

  if (LNewKey <> Key) or (LNewShiftState <> ShiftState) then
  begin
    Key := LNewKey;
    ShiftState := LNewShiftState;
  end;
end;

procedure TBCEditorKeyCommand.SetSecondaryKey(const AValue: Word);
begin
  if FSecondaryKey <> AValue then
    FSecondaryKey := AValue;
end;

procedure TBCEditorKeyCommand.SetSecondaryShiftState(const AValue: TShiftState);
begin
  if FSecondaryShiftState <> AValue then
    FSecondaryShiftState := AValue;
end;

procedure TBCEditorKeyCommand.SetSecondaryShortCut(const AValue: TShortCut);
var
  LNewKey: Word;
  LNewShiftState: TShiftState;
  LDuplicate: Integer;
begin
  if AValue <> 0 then
  begin
    LDuplicate := TBCEditorKeyCommands(Collection).FindShortcuts(ShortCut, AValue);
    if (LDuplicate <> -1) and (LDuplicate <> Self.Index) then
      raise Exception.Create(SBCEditOrduplicateShortcut);
  end;

  Menus.ShortCutToKey(AValue, LNewKey, LNewShiftState);
  if (LNewKey <> SecondaryKey) or (LNewShiftState <> SecondaryShiftState) then
  begin
    SecondaryKey := LNewKey;
    SecondaryShiftState := LNewShiftState;
  end;
end;

function TBCEditorKeyCommand.GetSecondaryShortCut: TShortCut;
begin
  Result := Menus.ShortCut(SecondaryKey, SecondaryShiftState);
end;

{ TBCEditorKeyCommands }

function TBCEditorKeyCommands.NewItem: TBCEditorKeyCommand;
begin
  Result := TBCEditorKeyCommand(inherited Add);
end;

procedure TBCEditorKeyCommands.Add(const ACommand: TBCEditorCommand; const AShift: TShiftState; const AKey: Word);
var
  LNewKeystroke: TBCEditorKeyCommand;
begin
  LNewKeystroke := NewItem;
  LNewKeystroke.Key := AKey;
  LNewKeystroke.ShiftState := AShift;
  LNewKeystroke.Command := ACommand;
end;

procedure TBCEditorKeyCommands.Assign(ASource: TPersistent);
var
  i: Integer;
begin
  if Assigned(ASource) and (ASource is TBCEditorKeyCommands) then
  with ASource as TBCEditorKeyCommands do
  begin
    Self.Clear;
    for i := 0 to Count - 1 do
      with NewItem do
        Assign((ASource as TBCEditorKeyCommands)[i]);
  end
  else
    inherited Assign(ASource);
end;

constructor TBCEditorKeyCommands.Create(AOwner: TPersistent);
begin
  inherited Create(TBCEditorKeyCommand);

  FOwner := AOwner;
end;

function TBCEditorKeyCommands.FindCommand(ACommand: TBCEditorCommand): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if Items[i].Command = ACommand then
    begin
      Result := i;
      Break;
    end;
end;

function TBCEditorKeyCommands.FindKeyCode(AKeycode: Word; AShift: TShiftState): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if (Items[i].Key = AKeyCode) and (Items[i].ShiftState = AShift) and (Items[i].SecondaryKey = 0) then
    begin
      Result := i;
      Break;
    end;
end;

function TBCEditorKeyCommands.FindKeyCodes(AKeyCode: Word; AShift: TShiftState; ASecondaryKeyCode: Word; ASecondaryShift: TShiftState): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if (Items[i].Key = AKeyCode) and (Items[i].ShiftState = AShift) and (Items[i].SecondaryKey = ASecondaryKeyCode) and
      (Items[i].SecondaryShiftState = ASecondaryShift) then
    begin
      Result := i;
      Break;
    end;
end;

function TBCEditorKeyCommands.FindShortcut(AShortCut: TShortCut): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if Items[i].ShortCut = AShortCut then
    begin
      Result := i;
      Break;
    end;
end;

function TBCEditorKeyCommands.FindShortcuts(AShortCut, ASecondaryShortCut: TShortCut): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if (Items[i].ShortCut = AShortCut) and (Items[i].SecondaryShortCut = ASecondaryShortCut) then
    begin
      Result := i;
      break;
    end;
end;

function TBCEditorKeyCommands.GetItem(AIndex: Integer): TBCEditorKeyCommand;
begin
  Result := TBCEditorKeyCommand(inherited GetItem(AIndex));
end;

function TBCEditorKeyCommands.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TBCEditorKeyCommands.ResetDefaults;
begin
  Clear;

  { Scrolling, caret moving and selection }
  Add(bceUp, [], VK_UP);
  Add(bceSelectionUp, [ssShift], VK_UP);
  Add(bceScrollUp, [ssCtrl], VK_UP);
  Add(bceDown, [], VK_DOWN);
  Add(bceSelectionDown, [ssShift], VK_DOWN);
  Add(bceScrollDown, [ssCtrl], VK_DOWN);
  Add(bceLeft, [], VK_LEFT);
  Add(bceSelectionLeft, [ssShift], VK_LEFT);
  Add(bceWordLeft, [ssCtrl], VK_LEFT);
  Add(bceSelectionWordLeft, [ssShift, ssCtrl], VK_LEFT);
  Add(bceRight, [], VK_RIGHT);
  Add(bceSelectionRight, [ssShift], VK_RIGHT);
  Add(bceWordRight, [ssCtrl], VK_RIGHT);
  Add(bceSelectionWordRight, [ssShift, ssCtrl], VK_RIGHT);
  Add(bcePageDown, [], VK_NEXT);
  Add(bceSelectionPageDown, [ssShift], VK_NEXT);
  Add(bcePageBottom, [ssCtrl], VK_NEXT);
  Add(bceSelectionPageBottom, [ssShift, ssCtrl], VK_NEXT);
  Add(bcePageUp, [], VK_PRIOR);
  Add(bceSelectionPageUp, [ssShift], VK_PRIOR);
  Add(bcePageTop, [ssCtrl], VK_PRIOR);
  Add(bceSelectionPageTop, [ssShift, ssCtrl], VK_PRIOR);
  Add(bceLineStart, [], VK_HOME);
  Add(bceSelectionLineStart, [ssShift], VK_HOME);
  Add(bceEditorTop, [ssCtrl], VK_HOME);
  Add(bceSelectionEditorTop, [ssShift, ssCtrl], VK_HOME);
  Add(bceLineEnd, [], VK_END);
  Add(bceSelectionLineEnd, [ssShift], VK_END);
  Add(bceEditorBottom, [ssCtrl], VK_END);
  Add(bceSelectionEditorBottom, [ssShift, ssCtrl], VK_END);
  { Insert key alone }
  Add(bceToggleMode, [], VK_INSERT);
  { Clipboard }
  Add(bceUndo, [ssAlt], VK_BACK);
  Add(bceRedo, [ssAlt, ssShift], VK_BACK);
  Add(bceCopy, [ssCtrl], VK_INSERT);
  Add(bceCut, [ssShift], VK_DELETE);
  Add(bcePaste, [ssShift], VK_INSERT);
  { Deletion }
  Add(bceDeleteChar, [], VK_DELETE);
  Add(bceBackspace, [], VK_BACK);
  Add(bceBackspace, [ssShift], VK_BACK);
  Add(bceDeleteLastWord, [ssCtrl], VK_BACK);
  { Search }
  Add(bceSearchNext, [], VK_F3);
  Add(bceSearchPrevious, [ssShift], VK_F3);
  { Enter (return) & Tab }
  Add(bceLineBreak, [], VK_RETURN);
  Add(bceLineBreak, [ssShift], VK_RETURN);
  Add(bceTab, [], VK_TAB);
  Add(bceShiftTab, [ssShift], VK_TAB);
  { Help }
  Add(bceContextHelp, [], VK_F1);
  { Standard edit commands }
  Add(bceUndo, [ssCtrl], Ord('Z'));
  Add(bceRedo, [ssCtrl, ssShift], Ord('Z'));
  Add(bceCut, [ssCtrl], Ord('X'));
  Add(bceCopy, [ssCtrl], Ord('C'));
  Add(bcePaste, [ssCtrl], Ord('V'));
  Add(bceSelectAll, [ssCtrl], Ord('A'));
  { Block commands }
  Add(bceBlockIndent, [ssCtrl, ssShift], Ord('I'));
  Add(bceBlockUnindent, [ssCtrl, ssShift], Ord('U'));
  { Fragment deletion }
  Add(bceDeleteWord, [ssCtrl], Ord('T'));
  { Line operations }
  Add(bceInsertLine, [ssCtrl], Ord('M'));
  Add(bceMoveLineUp, [ssCtrl, ssAlt], VK_UP);
  Add(bceMoveLineDown, [ssCtrl, ssAlt], VK_DOWN);
  Add(bceDeleteLine, [ssCtrl], Ord('Y'));
  Add(bceDeleteEndOfLine, [ssCtrl, ssShift], Ord('Y'));
  Add(bceMoveCharLeft, [ssAlt, ssCtrl], VK_LEFT);
  Add(bceMoveCharRight, [ssAlt, ssCtrl], VK_RIGHT);
  { Bookmarks }
  Add(bceGotoBookmark1, [ssCtrl], Ord('1'));
  Add(bceGotoBookmark2, [ssCtrl], Ord('2'));
  Add(bceGotoBookmark3, [ssCtrl], Ord('3'));
  Add(bceGotoBookmark4, [ssCtrl], Ord('4'));
  Add(bceGotoBookmark5, [ssCtrl], Ord('5'));
  Add(bceGotoBookmark6, [ssCtrl], Ord('6'));
  Add(bceGotoBookmark7, [ssCtrl], Ord('7'));
  Add(bceGotoBookmark8, [ssCtrl], Ord('8'));
  Add(bceGotoBookmark9, [ssCtrl], Ord('9'));
  Add(bceSetBookmark1, [ssCtrl, ssShift], Ord('1'));
  Add(bceSetBookmark2, [ssCtrl, ssShift], Ord('2'));
  Add(bceSetBookmark3, [ssCtrl, ssShift], Ord('3'));
  Add(bceSetBookmark4, [ssCtrl, ssShift], Ord('4'));
  Add(bceSetBookmark5, [ssCtrl, ssShift], Ord('5'));
  Add(bceSetBookmark6, [ssCtrl, ssShift], Ord('6'));
  Add(bceSetBookmark7, [ssCtrl, ssShift], Ord('7'));
  Add(bceSetBookmark8, [ssCtrl, ssShift], Ord('8'));
  Add(bceSetBookmark9, [ssCtrl, ssShift], Ord('9'));
  { Selection modes }
  Add(bceNormalSelect, [ssCtrl, ssAlt], Ord('N'));
  Add(bceColumnSelect, [ssCtrl, ssAlt], Ord('C'));
  Add(bceLineSelect, [ssCtrl, ssAlt], Ord('L'));
end;

procedure TBCEditorKeyCommands.SetItem(AIndex: Integer; AValue: TBCEditorKeyCommand);
begin
  inherited SetItem(AIndex, AValue);
end;

initialization
  RegisterIntegerConsts(TypeInfo(TBCEditorCommand), IdentToEditorCommand, EditorCommandToIdent);

//finalization
//  Causes a memory leak in the RTL..............
//  UnregisterIntegerConsts(TypeInfo(TBCEditorCommand), IdentToEditorCommand, EditorCommandToIdent);

end.
