unit BCEditor.Editor.SkipRegions;

interface

uses
  Classes, SysUtils;

type
  TBCEditorSkipRegionItemType = (ritUnspecified, ritString, ritMultiLineComment, ritSingleLineComment);

  TBCEditorSkipRegionItem = class(TCollectionItem)
  strict private
    FCloseToken: string;
    FOpenToken: string;
    FRegionType: TBCEditorSkipRegionItemType;
    FSkipEmptyChars: Boolean;
  public
    property OpenToken: string read FOpenToken write FOpenToken;
    property CloseToken: string read FCloseToken write FCloseToken;
    property RegionType: TBCEditorSkipRegionItemType read FRegionType write FRegionType;
    property SkipEmptyChars: Boolean read FSkipEmptyChars write FSkipEmptyChars;
  end;

  TBCEditorSkipRegions = class(TCollection)
  strict private
    function GetSkipRegionItem(Index: Integer): TBCEditorSkipRegionItem;
  public
    function Add(const AOpenToken, ACloseToken: string): TBCEditorSkipRegionItem;
    property SkipRegions[index: Integer]: TBCEditorSkipRegionItem read GetSkipRegionItem; default;
  end;

implementation

uses
  Windows;

{ TBCEditorSkipRegions }

function TBCEditorSkipRegions.Add(const AOpenToken, ACloseToken: string): TBCEditorSkipRegionItem;
begin
  Result := TBCEditorSkipRegionItem(inherited Add);
  with Result do
  begin
    OpenToken := AOpenToken;
    CloseToken := ACloseToken;
  end;
end;

function TBCEditorSkipRegions.GetSkipRegionItem(Index: Integer): TBCEditorSkipRegionItem;
begin
  Result := TBCEditorSkipRegionItem(inherited Items[index]);
end;

end.
