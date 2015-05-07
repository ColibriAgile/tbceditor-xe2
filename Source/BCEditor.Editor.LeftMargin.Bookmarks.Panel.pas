unit BCEditor.Editor.LeftMargin.Bookmarks.Panel;

interface

uses
  Classes, Graphics, BCEditor.Consts;

type
  TBCEditorLeftMarginBookMarkPanel = class(TPersistent)
  strict private
    FColor: TColor;
    FLeftMargin: Integer;
    FOnChange: TNotifyEvent;
    FOtherMarkXOffset: Integer;
    FVisible: Boolean;
    FWidth: Integer;
    procedure SetColor(const Value: TColor);
    procedure SetLeftMargin(Value: Integer);
    procedure SetOtherMarkXOffset(Value: Integer);
    procedure SetVisible(const Value: Boolean);
    procedure SetWidth(Value: Integer);
    procedure DoChange;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property Color: TColor read FColor write SetColor default clLeftMarginBookmarkBackground;
    property LeftMargin: Integer read FLeftMargin write SetLeftMargin default 2;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OtherMarkXOffset: Integer read FOtherMarkXOffset write SetOtherMarkXOffset default 12;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Width: Integer read FWidth write SetWidth default 20;
  end;

implementation

uses
  Math;

constructor TBCEditorLeftMarginBookMarkPanel.Create;
begin
  inherited;

  FColor := clLeftMarginBookmarkbackground;
  FWidth := 20;
  FLeftMargin := 2;
  FVisible := True;
  FOtherMarkXOffset := 12;
end;

procedure TBCEditorLeftMarginBookMarkPanel.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TBCEditorLeftMarginBookMarkPanel) then
  with Source as TBCEditorLeftMarginBookMarkPanel do
  begin
    Self.FColor := FColor;
    Self.FLeftMargin := FLeftMargin;
    Self.FOtherMarkXOffset := FOtherMarkXOffset;
    Self.FVisible := FVisible;
    Self.FWidth := FWidth;

    if Assigned(Self.FOnChange) then
      Self.FOnChange(Self);
  end
  else
    inherited;
end;

procedure TBCEditorLeftMarginBookMarkPanel.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TBCEditorLeftMarginBookMarkPanel.SetColor(const Value: TColor);
begin
  if Value <> FColor then
  begin
    FColor := Value;
    DoChange
  end;
end;

procedure TBCEditorLeftMarginBookMarkPanel.SetWidth(Value: Integer);
begin
  Value := Max(0, Value);
  if FWidth <> Value then
  begin
    FWidth := Value;
    DoChange
  end;
end;

procedure TBCEditorLeftMarginBookMarkPanel.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    DoChange
  end;
end;

procedure TBCEditorLeftMarginBookMarkPanel.SetLeftMargin(Value: Integer);
begin
  if FLeftMargin <> Value then
  begin
    FLeftMargin := Value;
    DoChange;
  end;
end;

procedure TBCEditorLeftMarginBookMarkPanel.SetOtherMarkXOffset(Value: Integer);
begin
  if FOtherMarkXOffset <> Value then
  begin
    FOtherMarkXOffset := Value;
    DoChange;
  end;
end;

end.
