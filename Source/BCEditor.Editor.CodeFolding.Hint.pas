unit BCEditor.Editor.CodeFolding.Hint;

interface

uses
  Classes, Graphics, Controls, BCEditor.Editor.CodeFolding.Hint.Colors;

type
  TBCEditorCodeFoldingHint = class(TPersistent)
  strict private
    FColors: TBCEditorCodeFoldingHintColors;
    FCursor: TCursor;
    FFont: TFont;
    FVisible: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Colors: TBCEditorCodeFoldingHintColors read FColors write FColors;
    property Cursor: TCursor read FCursor write FCursor default crHelp;
    property Font: TFont read FFont write FFont;
    property Visible: Boolean read FVisible write FVisible default True;
  end;

implementation

constructor TBCEditorCodeFoldingHint.Create;
begin
  inherited;

  FColors := TBCEditorCodeFoldingHintColors.Create;
  FCursor := crHelp;
  FVisible := True;
  FFont := TFont.Create;
  FFont.Name := 'Courier New';
  FFont.Size := 8;
end;

destructor TBCEditorCodeFoldingHint.Destroy;
begin
  FColors.Free;
  FFont.Free;

  inherited;
end;

procedure TBCEditorCodeFoldingHint.Assign(Source: TPersistent);
begin
  if Source is TBCEditorCodeFoldingHint then
  with Source as TBCEditorCodeFoldingHint do
  begin
    Self.FColors.Assign(FColors);
    Self.FCursor := FCursor;
    Self.FFont.Assign(FFont);
  end
  else
    inherited;
end;

end.
