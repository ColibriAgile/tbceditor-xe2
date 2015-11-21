unit BCEditor.Editor.CompletionProposal.Columns;

interface

uses
  System.Classes, Vcl.Graphics, System.SysUtils;

type
  TBCEditorProposalColumn = class(TCollectionItem)
  strict private
    FAutoWidth: Boolean;
    FItemList: TStrings;
    FWidth: Integer;
    procedure SetItemList(const Value: TStrings);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property AutoWidth: Boolean read FAutoWidth write FAutoWidth default True;
    property ItemList: TStrings read FItemList write SetItemList;
    property Width: Integer read FWidth write FWidth default 0;
  end;

  XTBCEditorProposalColumnsException = class(Exception);
  TBCEditorProposalColumns = class(TCollection)
  strict private
    FOwner: TPersistent;
    function GetItem(Index: Integer): TBCEditorProposalColumn;
    procedure SetItem(Index: Integer; Value: TBCEditorProposalColumn);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);
    function Add: TBCEditorProposalColumn;
    procedure AddItemToColumns(items: array of string);
    procedure ClearAll;
    function FindItemID(ID: Integer): TBCEditorProposalColumn;
    function Insert(Index: Integer): TBCEditorProposalColumn;
    property Items[index: Integer]: TBCEditorProposalColumn read GetItem write SetItem; default;
  end;

implementation

{ TBCEditorProposalColumn }

constructor TBCEditorProposalColumn.Create(Collection: TCollection);
begin
  inherited;
  FItemList := TStringList.Create;
  FAutoWidth := True;
  FWidth := 0;
end;

destructor TBCEditorProposalColumn.Destroy;
begin
  FItemList.Free;

  inherited;
end;

procedure TBCEditorProposalColumn.Assign(Source: TPersistent);
begin
  if Source is TBCEditorProposalColumn then
  with Source as TBCEditorProposalColumn do
    Self.FItemList.Assign(FItemList)
  else
    inherited Assign(Source);
end;

procedure TBCEditorProposalColumn.SetItemList(const Value: TStrings);
begin
  FItemList.Assign(Value);
end;

{ TBCEditorProposalColumns }

constructor TBCEditorProposalColumns.Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);
begin
  inherited Create(ItemClass);
  FOwner := AOwner;
end;

function TBCEditorProposalColumns.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TBCEditorProposalColumns.AddItemToColumns(items: array of string);
var
  i: Integer;
begin
  if Length(items) <> Self.Count then
    raise XTBCEditorProposalColumnsException.Create('Items does not matches columns.');

  for i := Low(items) to High(items) do
    Self[i].ItemList.Add(items[i]);
end;

procedure TBCEditorProposalColumns.ClearAll;
var
  i: Integer;
begin
  for i := 0 to Self.Count - 1 do
    Self[i].ItemList.Clear;
end;

function TBCEditorProposalColumns.GetItem(Index: Integer): TBCEditorProposalColumn;
begin
  Result := inherited GetItem(Index) as TBCEditorProposalColumn;
end;

procedure TBCEditorProposalColumns.SetItem(Index: Integer; Value: TBCEditorProposalColumn);
begin
  inherited SetItem(Index, Value);
end;

function TBCEditorProposalColumns.Add: TBCEditorProposalColumn;
begin
  Result := inherited Add as TBCEditorProposalColumn;
end;

function TBCEditorProposalColumns.FindItemID(ID: Integer): TBCEditorProposalColumn;
begin
  Result := inherited FindItemID(ID) as TBCEditorProposalColumn;
end;

function TBCEditorProposalColumns.Insert(Index: Integer): TBCEditorProposalColumn;
begin
  Result := inherited Insert(Index) as TBCEditorProposalColumn;
end;

end.
