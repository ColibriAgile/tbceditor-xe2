unit BCEditor.Editor.Minimap;

interface

uses
  Classes, Graphics, BCEditor.Types, BCEditor.Editor.Minimap.Colors;

type
  TBCEditorMinimap = class(TPersistent)
  strict private
    FCharHeight: Integer;
    FCharWidth: Integer;
    FClicked: Boolean;
    FColors: TBCEditorMinimapColors;
    FDragging: Boolean;
    FFont: TFont;
    FOnChange: TNotifyEvent;
    FOptions: TBCEditorMinimapOptions;
    FTopLine: Integer;
    FVisible: Boolean;
    FVisibleLines: Integer;
    FWidth: Integer;
    procedure DoChange;
    procedure SetColors(const Value: TBCEditorMinimapColors);
    procedure SetFont(Value: TFont);
    procedure SetOnChange(Value: TNotifyEvent);
    procedure SetVisible(Value: Boolean);
    procedure SetWidth(Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    function GetWidth: Integer;
    procedure Assign(Source: TPersistent); override;
    property CharWidth: Integer read FCharWidth write FCharWidth;
    property CharHeight: Integer read FCharHeight write FCharHeight;
    property Clicked: Boolean read FClicked write FClicked;
    property Dragging: Boolean read FDragging write FDragging;
    property TopLine: Integer read FTopLine write FTopLine default 1;
    property VisibleLines: Integer read FVisibleLines write FVisibleLines;
  published
    property Colors: TBCEditorMinimapColors read FColors write SetColors;
    property Font: TFont read FFont write SetFont;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
    property Options: TBCEditorMinimapOptions read FOptions write FOptions default [];
    property Visible: Boolean read FVisible write SetVisible default False;
    property Width: Integer read FWidth write SetWidth default 100;
  end;

implementation

uses
  Math;

{ TBCEditorMinimap }

constructor TBCEditorMinimap.Create;
begin
  inherited;

  FFont := TFont.Create;
  FFont.Name := 'Courier New';
  FFont.Size := 1;
  FFont.Style := [];

  FVisible := False;
  FWidth := 140;
  FDragging := False;
  FOptions := [];

  FClicked := False;

  FTopLine := 1;

  FColors := TBCEditorMinimapColors.Create;
end;

destructor TBCEditorMinimap.Destroy;
begin
  FFont.Free;
  FColors.Free;
  inherited Destroy;
end;

procedure TBCEditorMinimap.Assign(Source: TPersistent);
begin
  if Source is TBCEditorMinimap then
  with Source as TBCEditorMinimap do
  begin
    Self.FColors.Assign(FColors);
    Self.FFont.Assign(FFont);
    Self.FOptions := FOptions;
    Self.FVisible := FVisible;
    Self.FWidth := FWidth;
  end
  else
    inherited;
end;

procedure TBCEditorMinimap.SetOnChange(Value: TNotifyEvent);
begin
  FOnChange := Value;
  FFont.OnChange := Value;
  FColors.OnChange := Value;
end;

procedure TBCEditorMinimap.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TBCEditorMinimap.SetColors(const Value: TBCEditorMinimapColors);
begin
  FColors.Assign(Value);
end;

procedure TBCEditorMinimap.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TBCEditorMinimap.SetWidth(Value: Integer);
begin
  Value := Max(0, Value);
  if FWidth <> Value then
  begin
    FWidth := Value;
    DoChange;
  end;
end;

function TBCEditorMinimap.GetWidth: Integer;
begin
  if FVisible then
    Result := FWidth
  else
    Result := 0;
end;

procedure TBCEditorMinimap.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    DoChange;
  end;
end;

end.
