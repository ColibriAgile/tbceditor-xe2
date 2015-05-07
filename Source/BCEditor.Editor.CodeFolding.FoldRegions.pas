unit BCEditor.Editor.CodeFolding.FoldRegions;

interface

uses
  Classes, SysUtils, BCEditor.Editor.SkipRegions;

type
  TBCEditorCodeFoldingRegions = class;

  TBCEditorFoldRegionItem = class(TCollectionItem)
  strict private
    FBeginningOfLine: Boolean;
    FBreakIfNotFoundBeforeNextRegion: string;
    FCloseAtNextToken: Boolean;
    FCloseToken: string;
    FCloseTokenLength: Integer;
    FNoSubs: Boolean;
    FOpenIsClose: Boolean;
    FOpenToken: string;
    FOpenTokenLength: Integer;
    FParentRegion: TBCEditorFoldRegionItem;
    FSharedClose: Boolean;
    FSkipIfFoundAfterOpenToken: string;
  public
    property BeginningOfLine: Boolean read FBeginningOfLine write FBeginningOfLine default False;
    property BreakIfNotFoundBeforeNextRegion: string read FBreakIfNotFoundBeforeNextRegion write FBreakIfNotFoundBeforeNextRegion;
    property CloseAtNextToken: Boolean read FCloseAtNextToken write FCloseAtNextToken;
    property CloseToken: string read FCloseToken write FCloseToken;
    property CloseTokenLength: Integer read FCloseTokenLength write FCloseTokenLength;
    property NoSubs: Boolean read FNoSubs write FNoSubs default False;
    property OpenIsClose: Boolean read FOpenIsClose write FOpenIsClose default False;
    property OpenToken: string read FOpenToken write FOpenToken;
    property OpenTokenLength: Integer read FOpenTokenLength write FOpenTokenLength;
    property ParentRegion: TBCEditorFoldRegionItem read FParentRegion write FParentRegion;
    property SharedClose: Boolean read FSharedClose write FSharedClose default False;
    property SkipIfFoundAfterOpenToken: string read FSkipIfFoundAfterOpenToken write FSkipIfFoundAfterOpenToken;
  end;

  TBCEditorCodeFoldingRegions = class(TCollection)
  strict private
    FReverseRegions: TBCEditorCodeFoldingRegions;
    FSkipRegions: TBCEditorSkipRegions;
    FStringEscapeChar: Char;
    function GetItem(Index: Integer): TBCEditorFoldRegionItem;
  public
    constructor Create(ItemClass: TCollectionItemClass);
    destructor Destroy; override;
    function Add(AOpenToken: string; ACloseToken: string): TBCEditorFoldRegionItem;
    property Items[index: Integer]: TBCEditorFoldRegionItem read GetItem; default;
    property ReverseRegions: TBCEditorCodeFoldingRegions read FReverseRegions write FReverseRegions;
    property SkipRegions: TBCEditorSkipRegions read FSkipRegions;
    property StringEscapeChar: Char read FStringEscapeChar write FStringEscapeChar default #0;
  end;

implementation

{ TBCEditorCodeFoldingRegions }

function TBCEditorCodeFoldingRegions.Add(AOpenToken: string; ACloseToken: string): TBCEditorFoldRegionItem;
begin
  Result := TBCEditorFoldRegionItem(inherited Add);
  with Result do
  begin
    OpenToken := AOpenToken;
    OpenTokenLength := Length(AOpenToken);
    CloseToken := ACloseToken;
    CloseTokenLength := Length(ACloseToken);
    BeginningOfLine := False;
    SharedClose := False;
    OpenIsClose := False;
    NoSubs := False;
    SkipIfFoundAfterOpenToken := '';
    BreakIfNotFoundBeforeNextRegion := '';
  end;
end;

constructor TBCEditorCodeFoldingRegions.Create(ItemClass: TCollectionItemClass);
begin
  inherited Create(ItemClass);
  FSkipRegions := TBCEditorSkipRegions.Create(TBCEditorSkipRegionItem);
  FStringEscapeChar := #0;
end;

destructor TBCEditorCodeFoldingRegions.Destroy;
begin
  FSkipRegions.Free;
  if Assigned(FReverseRegions) then
    FReverseRegions.Free;
  inherited;
end;

function TBCEditorCodeFoldingRegions.GetItem(Index: Integer): TBCEditorFoldRegionItem;
begin
  Result := TBCEditorFoldRegionItem(inherited Items[index]);
end;

end.
