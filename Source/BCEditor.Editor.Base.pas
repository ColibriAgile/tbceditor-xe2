﻿unit BCEditor.Editor.Base;

interface

uses
  Windows, Messages, Classes, SysUtils, Contnrs,
  Forms, Controls, Graphics, StdCtrls, ExtCtrls, Dialogs,
  BCEditor.Consts, BCEditor.Editor.ActiveLine, BCEditor.Editor.Bookmarks, BCEditor.Editor.Caret,
  BCEditor.Editor.CodeFolding, BCEditor.Editor.CodeFolding.FoldRegions, BCEditor.Editor.CodeFolding.Ranges,
  BCEditor.Editor.CodeFolding.Types, BCEditor.Editor.CompletionProposal, BCEditor.Editor.CompletionProposal.Form,
  BCEditor.Editor.Glyph, BCEditor.Editor.InternalImage, BCEditor.Editor.KeyCommands, BCEditor.Editor.LeftMargin,
  BCEditor.Editor.LineSpacing, BCEditor.Editor.MatchingPair, BCEditor.Editor.Minimap, BCEditor.Editor.Replace,
  BCEditor.Editor.RightMargin, BCEditor.Editor.Scroll, BCEditor.Editor.Search, BCEditor.Editor.Directories,
  BCEditor.Editor.Selection, BCEditor.Editor.SkipRegions, BCEditor.Editor.SpecialChars, BCEditor.Editor.Tabs,
  BCEditor.Editor.Undo, BCEditor.Editor.Undo.List, BCEditor.Editor.WordWrap, BCEditor.Editor.WordWrap.Helper,
  BCEditor.Highlighter, BCEditor.Highlighter.Attributes, BCEditor.KeyboardHandler, BCEditor.Lines, BCEditor.Search,
  BCEditor.Search.RegularExpressions, BCEditor.Search.WildCard, BCEditor.TextDrawer,
  BCEditor.Types, BCEditor.Utils{$IFDEF USE_ALPHASKINS}, sCommonData, acSBUtils{$ENDIF};

type
  TBCBaseEditor = class(TCustomControl)
  strict private
    FActiveLine: TBCEditorActiveLine;
    FAfterBookmarkPanelPaint: TBCEditorBookmarkPanelPaintEvent;
    FOnAfterLinePaint: TBCEditorLinePaintEvent;
    FAllCodeFoldingRanges: TBCEditorAllCodeFoldingRanges;
    FAltEnabled: Boolean;
    FAlwaysShowCaret: Boolean;
    FBackgroundColor: TColor;
    FBeforeBookmarkPanelPaint: TBCEditorBookmarkPanelPaintEvent;
    FBookmarkPanelLinePaint: TBCEditorBookmarkPanelLinePaintEvent;
    FBookMarks: array [0 .. 8] of TBCEditorBookmark;
    FBorderStyle: TBorderStyle;
    FBreakWhitespace: Boolean;
    FBufferBmp: Graphics.TBitmap;
    FCaret: TBCEditorCaret;
    FCaretAtEndOfLine: Boolean;
    FCaretOffset: TPoint;
    FCaretX: Integer;
    FCaretY: Integer;
    FChainedEditor: TBCBaseEditor;
    FChainLinesChanged: TNotifyEvent;
    FChainLinesChanging: TNotifyEvent;
    FChainListCleared: TNotifyEvent;
    FChainListDeleted: TStringListChangeEvent;
    FChainListInserted: TStringListChangeEvent;
    FChainListPutted: TStringListChangeEvent;
    FChainRedoAdded: TNotifyEvent;
    FChainUndoAdded: TNotifyEvent;
    FCharsInWindow: Integer;
    FCharWidth: Integer;
    FCodeFolding: TBCEditorCodeFolding;
    FCodeFoldingHintForm: TBCEditorCompletionProposalForm;
    FCodeFoldingRangeForLine: array of TBCEditorCodeFoldingRange;
    FCollapsedLinesDifferenceCache: array of Integer;
    FColumnWidths: PIntegerArray;
    FCommandDrop: Boolean;
    {$IFDEF USE_ALPHASKINS}
    FCommonData: TsScrollWndData;
    {$ENDIF}
    FCompletionProposal: TBCEditorCompletionProposal;
    FCompletionProposalTimer: TTimer;
    FCurrentMatchingPair: TBCEditorMatchingTokenResult;
    FCurrentMatchingPairMatch: TBCEditorMatchingPairMatch;
    FDirectories: TBCEditorDirectories;
    FDoubleClickTime: Cardinal;
    FEncoding: TEncoding;
    FFocusList: TList;
    FFontDummy: TFont;
    FHighlightedFoldRange: TBCEditorCodeFoldingRange;
    FHighlighter: TBCEditorHighlighter;
    FHookedCommandHandlers: TObjectList;
    FInsertMode: Boolean;
    FInternalBookmarkImage: TBCEditorInternalImage;
    FInvalidateRect: TRect;
    FIsScrolling: Boolean;
    FKeyboardHandler: TBCEditorKeyboardHandler;
    FKeyCommands: TBCEditorKeyCommands;
    FLastDblClick: Cardinal;
    FLastDisplayLineCount: Integer;
    FLastDisplayY: Integer;
    FLastKey: Word;
    FLastRow: Integer;
    FLastShiftState: TShiftState;
    FLastSortOrder: TBCEditorSortOrder;
    FLastTopLine: Integer;
    FLeftChar: Integer;
    FLeftMargin: TBCEditorLeftMargin;
    FLeftMarginCharWidth: Integer;
    FLines: TBCEditorLines;
    FLinespacing: TBCEditorLineSpacing;
    FMarkList: TBCEditorBookmarkList;
    FMatchingPair: TBCEditorMatchingPair;
    FMatchingPairMatchStack: array of TBCEditorMatchingPairTokenMatch;
    FMatchingPairOpenDuplicate, FMatchingPairCloseDuplicate: array of Integer;
    FMinimap: TBCEditorMinimap;
    FMinimapBufferBmp: Graphics.TBitmap;
    FMinimapClickOffsetY: Integer;
    FModified: Boolean;
    FMouseDownX: Integer;
    FMouseDownY: Integer;
    FMouseOverURI: Boolean;
    FMouseWheelAccumulator: Integer;
    FNeedToRescanCodeFolding: Boolean;
    FOldMouseMovePoint: TPoint;
    FOnAfterBookmarkPlaced: TNotifyEvent;
    FOnAfterClearBookmark: TNotifyEvent;
    FOnBeforeBookmarkPlaced: TBCEditorBookmarkEvent;
    FOnBeforeClearBookmark: TBCEditorBookmarkEvent;
    FOnCaretChanged: TBCEditorCaretChangedEvent;
    FOnChange: TNotifyEvent;
    FOnCommandProcessed: TBCEditorProcessCommandEvent;
    FOnContextHelp: TBCEditorContextHelpEvent;
    FOnCustomLineColors: TBCEditorCustomLineColorsEvent;
    FOnDropFiles: TBCEditorDropFilesEvent;
    FOnKeyPressW: TBCEditorKeyPressWEvent;
    FOnLeftMarginClick: TLeftMarginClickEvent;
    FOnLinesDeleted: TStringListChangeEvent;
    FOnLinesInserted: TStringListChangeEvent;
    FOnLinesPutted: TStringListChangeEvent;
    FOnPaint: TBCEditorPaintEvent;
    FOnProcessCommand: TBCEditorProcessCommandEvent;
    FOnProcessUserCommand: TBCEditorProcessCommandEvent;
    FOnReplaceText: TBCEditorReplaceTextEvent;
    FOnRightMarginMouseUp: TNotifyEvent;
    FOnScroll: TBCEditorScrollEvent;
    FOnSelectionChanged: TNotifyEvent;
    FOptions: TBCEditorOptions;
    FOriginalLines: TBCEditorLines;
    FOriginalRedoList: TBCEditorUndoList;
    FOriginalUndoList: TBCEditorUndoList;
    FPaintLock: Integer;
    FPlugins: TList;
    FProcessingMinimap: Integer;
    FReadOnly: Boolean;
    FRedoList: TBCEditorUndoList;
    FReplace: TBCEditorReplace;
    FRightMargin: TBCEditorRightMargin;
    FRightMarginMovePosition: Integer;
    FSaveSelectionMode: TBCEditorSelectionMode;
    FScroll: TBCEditorScroll;
    FScrollDeltaX: Integer;
    FScrollDeltaY: Integer;
    FScrollTimer: TTimer;
    {$IFDEF USE_ALPHASKINS}
    FScrollWnd: TacScrollWnd;
    {$ENDIF}
    FSearch: TBCEditorSearch;
    FSearchEngine: TBCEditorSearchCustom;
    FSearchHighlighterBitmap: TBitmap;
    FSearchHighlighterBlendFunction: TBlendFunction;
    FSearchLines: TList;
    FSelectedCaseCycle: TBCEditorCase;
    FSelectedCaseText: string;
    FSelection: TBCEditorSelection;
    FSelectionBeginPosition: TBCEditorTextPosition;
    FSelectionEndPosition: TBCEditorTextPosition;
    FSpecialChars: TBCEditorSpecialChars;
    FStateFlags: TBCEditorStateFlags;
    FTabs: TBCEditorTabs;
    FTextDrawer: TBCEditorTextDrawer;
    FTextHeight: Integer;
    FTextOffset: Integer;
    FTopLine: Integer;
    FUndo: TBCEditorUndo;
    FUndoList: TBCEditorUndoList;
    FUndoRedo: Boolean;
    FURIOpener: Boolean;
    FWantReturns: Boolean;
    FWindowProducedMessage: Boolean;
    FVisibleLines: Integer;
    FWordWrap: TBCEditorWordWrap;
    FWordWrapHelper: TBCEditorWordWrapHelper;
    function CodeFoldingCollapsableFoldRangeForLine(ALine: Integer): TBCEditorCodeFoldingRange;
    function CodeFoldingFoldRangeForLineTo(ALine: Integer): TBCEditorCodeFoldingRange;
    function CodeFoldingLineInsideRange(ALine: Integer): TBCEditorCodeFoldingRange;
    function CodeFoldingRangeForLine(ALine: Integer): TBCEditorCodeFoldingRange;
    function CodeFoldingTreeEndForLine(ALine: Integer): Boolean;
    function CodeFoldingTreeLineForLine(ALine: Integer): Boolean;
    function DoOnCustomLineColors(ALine: Integer; var AForeground: TColor; var ABackground: TColor): Boolean;
    function DoOnCodeFoldingHintClick(X, Y: Integer): Boolean;
    function DoTrimTrailingSpaces(ALine: Integer): Integer; overload;
    function ExtraLineSpacing: Integer;
    function FindHookedCommandEvent(AHookedCommandEvent: TBCEditorHookedCommandEvent): Integer;
    function GetCanPaste: Boolean;
    function GetCanRedo: Boolean;
    function GetCanUndo: Boolean;
    function GetCaretPosition: TBCEditorTextPosition;
    function GetClipboardText: string;
    function GetCollapsedLineNumber(ALine: Integer): Integer;
    function GetDisplayLineCount: Integer;
    function GetDisplayPosition: TBCEditorDisplayPosition; overload;
    function GetDisplayPosition(AColumn, ARow: Integer): TBCEditorDisplayPosition; overload;
    function GetDisplayX: Integer;
    function GetDisplayY: Integer;
    function GetEndOfLine(ALine: PChar): PChar;
    function GetExpandedLength(const ALine: string; ATabWidth: Integer): Integer;
    function GetHighlighterAttributeAtRowColumn(const ATextPosition: TBCEditorTextPosition; var AToken: string;
      var ATokenType, AStart: Integer; var AHighlighterAttribute: TBCEditorHighlighterAttribute): Boolean;
    function GetHookedCommandHandlersCount: Integer;
    function GetLeadingWhite(const ALine: string): string;
    function GetLeftSpacing(ACharCount: Integer; AWantTabs: Boolean): string;
    function GetLineHeight: Integer;
    function GetLineIndentChars(AStrings: TStrings; ALine: Integer): Integer;
    function GetLineText: string;
    function GetMatchingToken(APoint: TBCEditorTextPosition; var AMatch: TBCEditorMatchingPairMatch): TBCEditorMatchingTokenResult;
    function GetSelectionAvailable: Boolean;
    function GetSelectedText: string;
    function GetSearchResultCount: Integer;
    function GetSelectionBeginPosition: TBCEditorTextPosition;
    function GetSelectionEndPosition: TBCEditorTextPosition;
    function GetText: string;
    function GetUncollapsedLineNumber(ALine: Integer): Integer;
    function GetUncollapsedLineNumberDifference(ALine: Integer): Integer;
    function GetWordAtCursor: string;
    function GetWordAtMouse: string;
    function GetWordAtRowColumn(ATextPosition: TBCEditorTextPosition): string;
    function GetWordWrap: Boolean;
    function GetWrapAtColumn: Integer;
    function IsLineInsideCollapsedCodeFolding(ALine: Integer): Boolean;
    function IsKeywordAtCursorPosition(AOpenKeyWord: PBoolean = nil; AIncludeAfterToken: Boolean = True): Boolean;
    function IsKeywordAtLine(ALine: Integer): Boolean;
    function IsStringAllWhite(const ALine: string): Boolean;
    function LeftSpaceCount(const ALine: string; WantTabs: Boolean = False): Integer;
    function MinPoint(const APoint1, APoint2: TPoint): TPoint;
    function NextWordPosition: TBCEditorTextPosition; overload;
    function NextWordPosition(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition; overload;
    function PreviousWordPosition: TBCEditorTextPosition; overload;
    function PreviousWordPosition(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition; overload;
    function RescanHighlighterRangesFrom(Index: Integer): Integer;
    function RowColumnToCharIndex(ATextPosition: TBCEditorTextPosition): Integer;
    function RowToLine(ARow: Integer): Integer;
    function SearchText(const ASearchText: string): Integer;
    function StringReverseScan(const ALine: string; AStart: Integer; ACharMethod: TBCEditorCharMethod): Integer;
    function StringScan(const ALine: string; AStart: Integer; ACharMethod: TBCEditorCharMethod): Integer;
    function TrimTrailingSpaces(const ALine: string): string;
    procedure ActiveLineChanged(Sender: TObject);
    procedure AssignSearchEngine;
    procedure CaretChanged(Sender: TObject);
    procedure CheckIfAtMatchingKeywords;
    procedure ClearSearchLines;
    procedure CodeFoldingCollapse(AFoldRange: TBCEditorCodeFoldingRange; AAddToUndoList: Boolean = True);
    procedure CodeFoldingExpandCollapsedLine(const ALine: Integer);
    //procedure CodeFoldingExpandCollapsedLines(const AFirst, ALast: Integer);
    procedure CodeFoldingLinesDeleted(AFirstLine: Integer; ACount: Integer);
    procedure CodeFoldingPrepareRangeForLine;
    procedure CodeFoldingOnChange(AEvent: TBCEditorCodeFoldingChanges);
    procedure CodeFoldingUncollapse(AFoldRange: TBCEditorCodeFoldingRange; AAddToUndoList: Boolean = True);
    procedure CompletionProposalTimerHandler(Sender: TObject);
    procedure ComputeCaret(X, Y: Integer);
    procedure ComputeScroll(X, Y: Integer);
    procedure DeflateMinimapRect(var ARect: TRect);
    procedure DoCutToClipboard;
    procedure DoEndKey(ASelection: Boolean);
    procedure DoHomeKey(ASelection: Boolean);
    procedure DoInternalUndo;
    procedure DoInternalRedo;
    procedure DoLinesDeleted(AFirstLine, ACount: Integer; AddToUndoList: Boolean);
    procedure DoLinesInserted(AFirstLine, ACount: Integer);
    procedure DoPasteFromClipboard;
    procedure DoShiftTabKey;
    procedure DoTabKey;
    procedure DoToggleSelectedCase(const ACommand: TBCEditorCommand);
    procedure DrawCursor(ACanvas: TCanvas);
    procedure FindAll(ASearchText: string = '');
    procedure FontChanged(Sender: TObject);
    procedure LinesChanging(Sender: TObject);
    procedure MinimapChanged(Sender: TObject);
    procedure MoveCaretAndSelection(const BeforeTextPosition, AfterTextPosition: TBCEditorTextPosition; SelectionCommand: Boolean);
    procedure MoveCaretHorizontally(const X: Integer; SelectionCommand: Boolean);
    procedure MoveCaretVertically(const Y: Integer; SelectionCommand: Boolean);
    procedure MoveCodeFoldingRangesAfter(AFoldRange: TBCEditorCodeFoldingRange; ALineCount: Integer);
    procedure OpenLink(AURI: string; ALinkType: Integer);
    procedure ProperSetLine(ALine: Integer; const ALineText: string);
    procedure RightMarginChanged(Sender: TObject);
    procedure ScrollChanged(Sender: TObject);
    procedure ScrollTimerHandler(Sender: TObject);
    procedure SearchChanged(AEvent: TBCEditorSearchChanges);
    procedure SelectionChanged(Sender: TObject);
    procedure SetActiveLine(const Value: TBCEditorActiveLine);
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetCaretX(Value: Integer);
    procedure SetCaretY(Value: Integer);
    procedure SetClipboardText(const AText: string);
    procedure SetCodeFolding(Value: TBCEditorCodeFolding);
    procedure SetDefaultKeyCommands;
    procedure SetInsertMode(const Value: Boolean);
    procedure SetInternalCaretX(Value: Integer);
    procedure SetInternalCaretY(Value: Integer);
    procedure SetInternalDisplayPosition(const ADisplayPosition: TBCEditorDisplayPosition);
    procedure SetKeyCommands(const Value: TBCEditorKeyCommands);
    procedure SetLeftChar(Value: Integer);
    procedure SetLeftMargin(const Value: TBCEditorLeftMargin);
    procedure SetLeftMarginWidth(Value: Integer);
    procedure SetLines(Value: TBCEditorLines);
    procedure SetLineText(Value: string);
    procedure SetModified(Value: Boolean);
    procedure SetOptions(Value: TBCEditorOptions);
    procedure SetRightMargin(const Value: TBCEditorRightMargin);
    procedure SetScroll(const Value: TBCEditorScroll);
    procedure SetSearch(const Value: TBCEditorSearch);
    procedure SetSelectedText(const Value: string);
    procedure SetSelectedWord;
    procedure SetSelection(const Value: TBCEditorSelection);
    procedure SetSelectionBeginPosition(Value: TBCEditorTextPosition);
    procedure SetSelectionEndPosition(Value: TBCEditorTextPosition);
    procedure SetSpecialChars(const Value: TBCEditorSpecialChars);
    procedure SetTabs(const Value: TBCEditorTabs);
    procedure SetText(const Value: string);
    procedure SetTopLine(Value: Integer);
    procedure SetUndo(const Value: TBCEditorUndo);
    procedure SetWordBlock(ATextPosition: TBCEditorTextPosition);
    procedure SetWordWrap(const Value: TBCEditorWordWrap);
    procedure SizeOrFontChanged(const FontChanged: Boolean);
    procedure SpecialCharsChanged(Sender: TObject);
    procedure SwapInt(var ALeft, ARight: Integer);
    procedure TabsChanged(Sender: TObject);
    procedure UndoChanged(Sender: TObject);
    procedure UndoRedoAdded(Sender: TObject);
    procedure UpdateFoldRanges(ACurrentLine, ALineCount: Integer); overload;
    procedure UpdateFoldRanges(AFoldRanges: TBCEditorCodeFoldingRanges; ALineCount: Integer); overload;
    procedure UpdateWordWrapHiddenOffsets;
    procedure UpdateModifiedStatus;
    procedure UpdateScrollBars;
    procedure UpdateWordWrap(const Value: Boolean);
    procedure WMCaptureChanged(var Msg: TMessage); message WM_CAPTURECHANGED;
    procedure WMChar(var Msg: TWMChar); message WM_CHAR;
    procedure WMClear(var Msg: TMessage); message WM_CLEAR;
    procedure WMCopy(var Message: TMessage); message WM_COPY;
    procedure WMCut(var Message: TMessage); message WM_CUT;
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
    procedure WMEraseBkgnd(var Msg: TMessage); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMGetText(var Msg: TWMGetText); message WM_GETTEXT;
    procedure WMGetTextLength(var Msg: TWMGetTextLength); message WM_GETTEXTLENGTH;
    procedure WMHScroll(var Msg: TWMScroll); message WM_HSCROLL;
    procedure WMIMEChar(var Msg: TMessage); message WM_IME_CHAR;
    procedure WMIMEComposition(var Msg: TMessage); message WM_IME_COMPOSITION;
    procedure WMIMENotify(var Msg: TMessage); message WM_IME_NOTIFY;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    {$IFDEF USE_VCL_STYLES}
    procedure WMNCPaint(var Message: TMessage); message WM_NCPAINT;
    {$ENDIF}
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSetText(var Msg: TWMSetText); message WM_SETTEXT;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMUndo(var Msg: TMessage); message WM_UNDO;
    procedure WMVScroll(var Msg: TWMScroll); message WM_VSCROLL;
    procedure WordWrapChanged(Sender: TObject);
  protected
    function DoMouseWheel(AShift: TShiftState; AWheelDelta: Integer; AMousePos: TPoint): Boolean; override;
    function DoOnReplaceText(const ASearch, AReplace: string; ALine, AColumn: Integer; DeleteLine: Boolean): TBCEditorReplaceAction;
    function DoSearchMatchNotFoundWraparoundDialog: Boolean; virtual;
    function GetReadOnly: Boolean; virtual;
    function GetSelectedLength: Integer;
    function PixelsToNearestRowColumn(X, Y: Integer): TBCEditorDisplayPosition;
    function PixelsToRowColumn(X, Y: Integer): TBCEditorDisplayPosition;
    function RowColumnToPixels(const ADisplayPosition: TBCEditorDisplayPosition): TPoint;
    procedure ChainLinesChanged(Sender: TObject);
    procedure ChainLinesChanging(Sender: TObject);
    procedure ChainListCleared(Sender: TObject);
    procedure ChainListDeleted(Sender: TObject; AIndex: Integer; ACount: Integer);
    procedure ChainListInserted(Sender: TObject; AIndex: Integer; ACount: Integer);
    procedure ChainListPutted(Sender: TObject; AIndex: Integer; ACount: Integer);
    procedure ChainUndoRedoAdded(Sender: TObject);
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DblClick; override;
    procedure DecPaintLock;
    procedure DestroyWnd; override;
    procedure DoBlockIndent;
    procedure DoBlockUnindent;
    procedure DoChange; virtual;
    procedure DoCopyToClipboard(const AText: string);
    procedure DoExecuteCompletionProposal;
    procedure DoKeyPressW(var Message: TWMKey);
    procedure DoOnAfterBookmarkPlaced;
    procedure DoOnAfterClearBookmark;
    procedure DoOnBeforeBookmarkPlaced(var ABookmark: TBCEditorBookmark);
    procedure DoOnBeforeClearBookmark(var ABookmark: TBCEditorBookmark);
    procedure DoOnCommandProcessed(ACommand: TBCEditorCommand; AChar: Char; AData: pointer);
    procedure DoOnLeftMarginClick(Button: TMouseButton; X, Y: Integer);
    procedure DoOnMinimapClick(Button: TMouseButton; X, Y: Integer);
    procedure DoOnPaint;
    procedure DoOnProcessCommand(var ACommand: TBCEditorCommand; var AChar: Char; AData: pointer); virtual;
    procedure DoSearchStringNotFoundDialog; virtual;
    procedure DoTripleClick;
    procedure DragCanceled; override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure FreeHintForm(var AForm: TBCEditorCompletionProposalForm);
    procedure HideCaret;
    procedure IncPaintLock;
    procedure InvalidateRect(const ARect: TRect; AErase: Boolean = False);
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPressW(var Key: Char);
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure LinesChanged(Sender: TObject);
    procedure LinesHookChanged;
    procedure ListBeforeDeleted(Sender: TObject; AIndex: Integer; ACount: Integer);
    procedure ListBeforeInserted(Sender: TObject; Index: Integer; ACount: Integer);
    procedure ListBeforePutted(Sender: TObject; Index: Integer; ACount: Integer);
    procedure ListCleared(Sender: TObject);
    procedure ListDeleted(Sender: TObject; AIndex: Integer; ACount: Integer);
    procedure ListInserted(Sender: TObject; Index: Integer; ACount: Integer);
    procedure ListPutted(Sender: TObject; Index: Integer; ACount: Integer);
    procedure Loaded; override;
    procedure MarkListChange(Sender: TObject);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure NotifyHookedCommandHandlers(AfterProcessing: Boolean; var ACommand: TBCEditorCommand; var AChar: Char; AData: pointer);
    procedure Paint; override;
    procedure PaintCodeFolding(AClipRect: TRect; ALineCount: Integer);
    procedure PaintCodeFoldingLine(AClipRect: TRect; ALine: Integer);
    procedure PaintCodeFoldingCollapsedLine(AFoldRange: TBCEditorCodeFoldingRange; ALineRect: TRect);
    procedure PaintCodeFoldingCollapseMark(AFoldRange: TBCEditorCodeFoldingRange; ATokenPosition, ATokenLength, ALine, AScrolledXBy: Integer; ALineRect: TRect);
    procedure PaintGuides(ALine, AScrolledXBy: Integer; ALineRect: TRect; AMinimap: Boolean);
    procedure PaintLeftMargin(const AClipRect: TRect; AFirstRow, ALastTextRow, ALastRow: Integer);
    procedure PaintRightMarginMove;
    procedure PaintSearchMap(AClipRect: TRect);
    procedure PaintSpecialChars(ALine, AScrolledXBy: Integer; ALineRect: TRect);
    procedure PaintTextLines(AClipRect: TRect; AFirstRow, ALastRow, AFirstColumn, ALastColumn: Integer; AMinimap: Boolean);
    procedure RecalculateCharExtent;
    procedure RedoItem;
    procedure RepaintGuides;
    procedure ResetCaret(DoUpdate: Boolean = True);
    procedure ScanCodeFoldingRanges(var ATopFoldRanges: TBCEditorAllCodeFoldingRanges; AStrings: TStrings); virtual;
    procedure ScanMatchingPair;
    procedure SetAlwaysShowCaret(const Value: Boolean);
    procedure SetBreakWhitespace(Value: Boolean);
    procedure SetCaretPosition(const Value: TBCEditorTextPosition); overload;
    procedure SetCaretPosition(CallEnsureCursorPositionVisible: Boolean; Value: TBCEditorTextPosition); overload;
    procedure SetInternalCaretPosition(const Value: TBCEditorTextPosition);
    procedure SetName(const Value: TComponentName); override;
    procedure SetReadOnly(Value: Boolean); virtual;
    procedure SetSelectedTextEmpty(const AChangeString: string = '');
    procedure SetSelectedTextPrimitive(const Value: string); overload;
    procedure SetSelectedTextPrimitive(APasteMode: TBCEditorSelectionMode; AValue: PChar; AAddToUndoList: Boolean); overload;
    procedure SetWantReturns(Value: Boolean);
    procedure ShowCaret;
    procedure UndoItem;
    procedure UpdateMouseCursor;
    property InternalCaretPosition: TBCEditorTextPosition write SetInternalCaretPosition;
    property InternalCaretX: Integer write SetInternalCaretX;
    property InternalCaretY: Integer write SetInternalCaretY;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CaretInView: Boolean;
    function CreateFileStream(AFileName: string): TStream; virtual;
    function CreateUncollapsedLines: TStringList;
    function DisplayToTextPosition(const ADisplayPosition: TBCEditorDisplayPosition): TBCEditorTextPosition;
    function GetColorsFileName(AFileName: string): string;
    function GetHighlighterFileName(AFileName: string): string;
    function FindPrevious: Boolean;
    function FindNext: Boolean;
    function GetBookmark(ABookmark: Integer; var X, Y: Integer): Boolean;
    function GetPositionOfMouse(out ATextPosition: TBCEditorTextPosition): Boolean;
    function GetWordAtPixels(X, Y: Integer): string;
    function IsBookmark(ABookmark: Integer): Boolean;
    function IsPointInSelection(const ATextPosition: TBCEditorTextPosition): Boolean;
    function IsWordBreakChar(AChar: Char): Boolean;
    function IsWordChar(AChar: Char): Boolean;
    function LineToRow(ALine: Integer): Integer;
    function ReplaceText(const ASearchText: string; const AReplaceText: string): Integer;
    function SplitTextIntoWords(AStringList: TStrings; ACaseSensitive: Boolean): string;
    function TextToDisplayPosition(const ATextPosition: TBCEditorTextPosition; ACollapsedLineNumber: Boolean = True;
      ARealWidth: Boolean = True): TBCEditorDisplayPosition;
    function TranslateKeyCode(ACode: Word; AShift: TShiftState; var AData: pointer): TBCEditorCommand;
    function WordEnd: TBCEditorTextPosition; overload;
    function WordEnd(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition; overload;
    function WordStart: TBCEditorTextPosition; overload;
    function WordStart(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition; overload;
    procedure AddFocusControl(AControl: TWinControl);
    procedure AddKeyCommand(ACommand: TBCEditorCommand; AKey1: Word; AShift1: TShiftState; AKey2: Word = 0; AShift2: TShiftState = []);
    procedure AddKeyDownHandler(AHandler: TKeyEvent);
    procedure AddKeyPressHandler(AHandler: TBCEditorKeyPressWEvent);
    procedure AddKeyUpHandler(AHandler: TKeyEvent);
    procedure AddMouseCursorHandler(AHandler: TBCEditorMouseCursorEvent);
    procedure AddMouseDownHandler(AHandler: TMouseEvent);
    procedure AddMouseUpHandler(AHandler: TMouseEvent);
    procedure BeginUndoBlock;
    procedure BeginUpdate;
    procedure CaretZero;
    procedure ChainEditor(AEditor: TBCBaseEditor);
    procedure Clear;
    procedure ClearBookmark(ABookmark: Integer);
    procedure ClearBookmarks;
    procedure ClearCodeFolding;
    procedure ClearMatchingPair;
    procedure ClearSelection;
    procedure ClearUndo;
    procedure CodeFoldingCollapseAll;
    procedure CodeFoldingCollapseLevel(ALevel: Integer);
    procedure CodeFoldingUncollapseAll;
    procedure CodeFoldingUncollapseLevel(ALevel: Integer; ANeedInvalidate: Boolean = True);
    procedure CommandProcessor(ACommand: TBCEditorCommand; AChar: Char; AData: pointer);
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure DeleteWhitespace;
    procedure DoUndo;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure EndUndoBlock;
    procedure EndUpdate;
    procedure EnsureCursorPositionVisible; overload;
    procedure EnsureCursorPositionVisible(AForceToMiddle: Boolean; AEvenIfVisible: Boolean = False); overload;
    procedure ExecuteCommand(ACommand: TBCEditorCommand; AChar: Char; AData: pointer); virtual;
    procedure GotoBookmark(ABookmark: Integer);
    procedure GotoLineAndCenter(ALine: Integer);
    procedure HookEditorLines(ABuffer: TBCEditorLines; AUndo, ARedo: TBCEditorUndoList);
    procedure InitCodeFolding;
    procedure InsertBlock(const ABlockBeginPosition, ABlockEndPosition: TBCEditorTextPosition; AChangeStr: PChar; AAddToUndoList: Boolean);
    procedure InvalidateLeftMargin;
    procedure InvalidateLeftMarginLine(ALine: Integer);
    procedure InvalidateLeftMarginLines(AFirstLine, ALastLine: Integer);
    procedure InvalidateLine(ALine: Integer);
    procedure InvalidateLines(AFirstLine, ALastLine: Integer);
    procedure InvalidateMinimap;
    procedure InvalidateSelection;
    procedure LeftMarginChanged(Sender: TObject);
    procedure LoadFromFile(const AFileName: String);
    procedure LockUndo;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure PasteFromClipboard;
    procedure DoRedo;
    procedure RegisterCommandHandler(const AHookedCommandEvent: TBCEditorHookedCommandEvent; AHandlerData: Pointer);
    procedure RemoveChainedEditor;
    procedure RemoveFocusControl(AControl: TWinControl);
    procedure RemoveKeyDownHandler(AHandler: TKeyEvent);
    procedure RemoveKeyPressHandler(AHandler: TBCEditorKeyPressWEvent);
    procedure RemoveKeyUpHandler(AHandler: TKeyEvent);
    procedure RemoveMouseCursorHandler(AHandler: TBCEditorMouseCursorEvent);
    procedure RemoveMouseDownHandler(AHandler: TMouseEvent);
    procedure RemoveMouseUpHandler(AHandler: TMouseEvent);
    procedure RescanCodeFoldingRanges;
    procedure SaveToFile(const AFileName: String);
    procedure SelectAll;
    procedure SetBookmark(AIndex: Integer; X: Integer; Y: Integer);
    procedure SetCaretAndSelection(const CaretPosition, BlockBeginPosition, BlockEndPosition: TBCEditorTextPosition; ACaret: Integer = -1);
    procedure SetFocus; override;
    procedure SetLineColor(ALine: Integer; AForegroundColor, ABackgroundColor: TColor);
    procedure SetLineColorToDefault(ALine: Integer);
    procedure Sort(ASortOrder: TBCEditorSortOrder = soToggle);
    procedure ToggleBookmark(AIndex: Integer = -1);
    procedure ToggleSelectedCase(ACase: TBCEditorCase = cNone);
    procedure UnhookEditorLines;
    procedure UnlockUndo;
    procedure UnregisterCommandHandler(AHookedCommandEvent: TBCEditorHookedCommandEvent);
    procedure UpdateCaret;
    procedure WndProc(var Message: TMessage); override;
    property ActiveLine: TBCEditorActiveLine read FActiveLine write SetActiveLine;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clWindow;
    property AllCodeFoldingRanges: TBCEditorAllCodeFoldingRanges read FAllCodeFoldingRanges;
    property AlwaysShowCaret: Boolean read FAlwaysShowCaret write SetAlwaysShowCaret;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property BreakWhitespace: Boolean read FBreakWhitespace write SetBreakWhitespace;
    property CanPaste: Boolean read GetCanPaste;
    property CanRedo: Boolean read GetCanRedo;
    property CanUndo: Boolean read GetCanUndo;
    property Canvas;
    property Caret: TBCEditorCaret read FCaret write FCaret;
    property CaretX: Integer read FCaretX write SetCaretX;
    property CaretPosition: TBCEditorTextPosition read GetCaretPosition write SetCaretPosition;
    property CaretY: Integer read FCaretY write SetCaretY;
    property CharsInWindow: Integer read FCharsInWindow;
    property CharWidth: Integer read FCharWidth;
    property CodeFolding: TBCEditorCodeFolding read FCodeFolding write SetCodeFolding;
    property CompletionProposal: TBCEditorCompletionProposal read FCompletionProposal write FCompletionProposal;
    property Cursor default crIBeam;
    property Directories: TBCEditorDirectories read FDirectories write FDirectories;
    property DisplayLineCount: Integer read GetDisplayLineCount;
    property DisplayX: Integer read GetDisplayX;
    property DisplayPosition: TBCEditorDisplayPosition read GetDisplayPosition;
    property DisplayY: Integer read GetDisplayY;
    property Encoding: TEncoding read FEncoding write FEncoding;
    property Font;
    property Highlighter: TBCEditorHighlighter read FHighlighter;
    property InsertMode: Boolean read FInsertMode write SetInsertMode default True;
    property IsScrolling: Boolean read FIsScrolling;
    property KeyCommands: TBCEditorKeyCommands read FKeyCommands write SetKeyCommands stored False;
    property LeftChar: Integer read FLeftChar write SetLeftChar;
    property LeftMargin: TBCEditorLeftMargin read FLeftMargin write SetLeftMargin;
    property LineHeight: Integer read GetLineHeight;
    property Lines: TBCEditorLines read FLines write SetLines;
    property LineSpacing: TBCEditorLineSpacing read FLinespacing write FLinespacing;
    property LineText: string read GetLineText write SetLineText;
    property Marks: TBCEditorBookmarkList read FMarkList;
    property MatchingPair: TBCEditorMatchingPair read FMatchingPair write FMatchingPair;
    property Minimap: TBCEditorMinimap read FMinimap write FMinimap;
    property Modified: Boolean read FModified write SetModified;
    property OnAfterBookmarkPanelPaint: TBCEditorBookmarkPanelPaintEvent read FAfterBookmarkPanelPaint write FAfterBookmarkPanelPaint;
    property OnAfterBookmarkPlaced: TNotifyEvent read FOnAfterBookmarkPlaced write FOnAfterBookmarkPlaced;
    property OnAfterClearBookmark: TNotifyEvent read FOnAfterClearBookmark write FOnAfterClearBookmark;
    property OnAfterLinePaint: TBCEditorLinePaintEvent read FOnAfterLinePaint write FOnAfterLinePaint;
    property OnBeforeBookmarkPlaced: TBCEditorBookmarkEvent read FOnBeforeBookmarkPlaced write FOnBeforeBookmarkPlaced;
    property OnBeforeClearBookmark: TBCEditorBookmarkEvent read FOnBeforeClearBookmark write FOnBeforeClearBookmark;
    property OnBeforeBookmarkPanelPaint: TBCEditorBookmarkPanelPaintEvent read FBeforeBookmarkPanelPaint write FBeforeBookmarkPanelPaint;
    property OnBookmarkPanelLinePaint: TBCEditorBookmarkPanelLinePaintEvent read FBookmarkPanelLinePaint write FBookmarkPanelLinePaint;
    property OnCaretChanged: TBCEditorCaretChangedEvent read FOnCaretChanged write FOnCaretChanged;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnCommandProcessed: TBCEditorProcessCommandEvent read FOnCommandProcessed write FOnCommandProcessed;
    property OnContextHelp: TBCEditorContextHelpEvent read FOnContextHelp write FOnContextHelp;
    property OnCustomLineColors: TBCEditorCustomLineColorsEvent read FOnCustomLineColors write FOnCustomLineColors;
    property OnDropFiles: TBCEditorDropFilesEvent read FOnDropFiles write FOnDropFiles;
    property OnKeyPress: TBCEditorKeyPressWEvent read FOnKeyPressW write FOnKeyPressW;
    property OnLeftMarginClick: TLeftMarginClickEvent read FOnLeftMarginClick write FOnLeftMarginClick;
    property OnLinesDeleted: TStringListChangeEvent read FOnLinesDeleted write FOnLinesDeleted;
    property OnLinesInserted: TStringListChangeEvent read FOnLinesInserted write FOnLinesInserted;
    property OnLinesPutted: TStringListChangeEvent read FOnLinesPutted write FOnLinesPutted;
    property OnPaint: TBCEditorPaintEvent read FOnPaint write FOnPaint;
    property OnProcessCommand: TBCEditorProcessCommandEvent read FOnProcessCommand write FOnProcessCommand;
    property OnProcessUserCommand: TBCEditorProcessCommandEvent read FOnProcessUserCommand write FOnProcessUserCommand;
    property OnReplaceText: TBCEditorReplaceTextEvent read FOnReplaceText write FOnReplaceText;
    property OnRightMarginMouseUp: TNotifyEvent read FOnRightMarginMouseUp write FOnRightMarginMouseUp;
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write FOnSelectionChanged;
    property OnScroll: TBCEditorScrollEvent read FOnScroll write FOnScroll;
    property Options: TBCEditorOptions read FOptions write SetOptions default BCEDITOR_DEFAULT_OPTIONS;
    property PaintLock: Integer read FPaintLock;
    property ParentColor default False;
    property ParentFont default False;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property RedoList: TBCEditorUndoList read FRedoList;
    property Replace: TBCEditorReplace read FReplace write FReplace;
    property RightMargin: TBCEditorRightMargin read FRightMargin write SetRightMargin;
    property Scroll: TBCEditorScroll read FScroll write SetScroll;
    property Search: TBCEditorSearch read FSearch write SetSearch;
    property SearchResultCount: Integer read GetSearchResultCount;
    property Selection: TBCEditorSelection read FSelection write SetSelection;
    property SelectionAvailable: Boolean read GetSelectionAvailable;
    property SelectionBeginPosition: TBCEditorTextPosition read GetSelectionBeginPosition write SetSelectionBeginPosition;
    property SelectionEndPosition: TBCEditorTextPosition read GetSelectionEndPosition write SetSelectionEndPosition;
    property SelectedText: string read GetSelectedText write SetSelectedText;
    {$IFDEF USE_ALPHASKINS}
    property SkinData: TsScrollWndData read FCommonData write FCommonData;
    {$ENDIF}
    property SpecialChars: TBCEditorSpecialChars read FSpecialChars write SetSpecialChars;
    property Tabs: TBCEditorTabs read FTabs write SetTabs;
    property TabStop default True;
    property Text: string read GetText write SetText;
    property TopLine: Integer read FTopLine write SetTopLine;
    property Undo: TBCEditorUndo read FUndo write SetUndo;
    property UndoList: TBCEditorUndoList read FUndoList;
    property URIOpener: Boolean read FURIOpener write FURIOpener;
    property VisibleLines: Integer read FVisibleLines;
    property WantReturns: Boolean read FWantReturns write SetWantReturns default True;
    property WordAtCursor: string read GetWordAtCursor;
    property WordAtMouse: string read GetWordAtMouse;
    property WordWrap: TBCEditorWordWrap read FWordWrap write SetWordWrap;
  end;

implementation

{$R BCEditor.res}

uses
  ShellAPI, Imm, WideStrUtils, Math, Types, Clipbrd, Character,
  Menus, BCEditor.Editor.LeftMargin.Border, BCEditor.Editor.LeftMargin.LineNumbers, BCEditor.Editor.Scroll.Hint,
  BCEditor.Editor.Search.Map, BCEditor.Editor.Undo.Item, BCEditor.Editor.Utils, BCEditor.Encoding, BCEditor.Language,
  {$IFDEF USE_VCL_STYLES}Vcl.Themes, BCEditor.StyleHooks,{$ENDIF} BCEditor.Highlighter.Rules
  {$IFDEF USE_ALPHASKINS}, sVCLUtils, sMessages, sConst, sSkinProps{$ENDIF};

var
  ScrollHintWindow, RightMarginHintWindow: THintWindow;
  ClipboardFormatBCEditor: Cardinal;
  ClipboardFormatBorland: Cardinal;
  ClipboardFormatMSDev: Cardinal;

function GetScrollHint: THintWindow;
begin
  if not Assigned(ScrollHintWindow) then
  begin
    ScrollHintWindow := THintWindow.Create(Application);
    ScrollHintWindow.DoubleBuffered := True;
  end;
  Result := ScrollHintWindow;
end;

function GetRightMarginHint: THintWindow;
begin
  if not Assigned(RightMarginHintWindow) then
  begin
    RightMarginHintWindow := THintWindow.Create(Application);
    RightMarginHintWindow.DoubleBuffered := True;
  end;
  Result := RightMarginHintWindow;
end;

{ TBCBaseEditor }

constructor TBCBaseEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  {$IFDEF USE_ALPHASKINS}
  FCommonData := TsScrollWndData.Create(Self);
  FCommonData.COC := COC_TsMemo;
  if FCommonData.SkinSection = '' then
    FCommonData.SkinSection := s_Edit;
  {$ENDIF}

  FProcessingMinimap := 0;

  FBackgroundColor := clWindow;
  Height := 150;
  Width := 200;
  Cursor := crIBeam;
  Color := clWindow;
  DoubleBuffered := False;
  ControlStyle := ControlStyle + [csOpaque, csSetCaption, csNeedsBorderPaint];
  FBorderStyle := bsSingle;
  FURIOpener := False;
  FDoubleClickTime := GetDoubleClickTime;
  FBreakWhitespace := True;
  FSelectedCaseText := '';
  FLastSortOrder := soDesc;
  { Code folding }
  FAllCodeFoldingRanges := TBCEditorAllCodeFoldingRanges.Create;
  FPlugins := TList.Create;
  FCodeFolding := TBCEditorCodeFolding.Create;
  FCodeFolding.OnChange := CodeFoldingOnChange;
  { Directory }
  FDirectories := TBCEditorDirectories.Create;
  { Matching pair }
  FMatchingPair := TBCEditorMatchingPair.Create;
  { Line spacing }
  FLinespacing := TBCEditorLineSpacing.Create;
  FLinespacing.OnChange := FontChanged;
  { Special chars }
  FSpecialChars := TBCEditorSpecialChars.Create;
  FSpecialChars.OnChange := SpecialCharsChanged;
  { Caret }
  FCaret := TBCEditorCaret.Create;
  FCaret.OnChange := CaretChanged;
  { Text buffer }
  FLines := TBCEditorLines.Create(Self);
  FOriginalLines := FLines;
  with FLines do
  begin
    OnChange := LinesChanged;
    OnChanging := LinesChanging;
    OnCleared := ListCleared;
    OnDeleted := ListDeleted;
    OnInserted := ListInserted;
    OnPutted := ListPutted;
    OnBeforePutted := ListBeforePutted;
  end;
  { Font }
  FFontDummy := TFont.Create;
  with FFontDummy do
  begin
    Name := 'Courier New';
    Size := 10;
  end;
  { Undo & Redo }
  FUndoRedo := False;
  FUndo := TBCEditorUndo.Create;
  FUndo.OnChange := UndoChanged;
  FUndoList := TBCEditorUndoList.Create;
  FUndoList.OnAddedUndo := UndoRedoAdded;
  FOriginalUndoList := FUndoList;
  FRedoList := TBCEditorUndoList.Create;
  FRedoList.OnAddedUndo := UndoRedoAdded;
  FOriginalRedoList := FRedoList;
  FCommandDrop := False;
  { Active line, selection }
  FSelection := TBCEditorSelection.Create;
  FSelection.OnChange := SelectionChanged;
  { Bookmarks }
  FMarkList := TBCEditorBookmarkList.Create(Self);
  FMarkList.OnChange := MarkListChange;
  { Painting }
  FBufferBmp := Graphics.TBitmap.Create;
  FMinimapBufferBmp := Graphics.TBitmap.Create;
  FTextDrawer := TBCEditorTextDrawer.Create([fsBold], FFontDummy);
  Font.Assign(FFontDummy);
  Font.OnChange := FontChanged;
  ParentFont := False;
  ParentColor := False;
  { LeftMargin mast be initialized strongly after FTextDrawer initialization }
  FLeftMargin := TBCEditorLeftMargin.Create(Self);
  FLeftMargin.OnChange := LeftMarginChanged;
  { Right edge }
  FRightMargin := TBCEditorRightMargin.Create;
  FRightMargin.OnChange := RightMarginChanged;
  { Text }
  TabStop := True;
  FInsertMode := True;
  FFocusList := TList.Create;
  FKeyboardHandler := TBCEditorKeyboardHandler.Create;
  FKeyCommands := TBCEditorKeyCommands.Create(Self);
  SetDefaultKeyCommands;
  FWantReturns := True;
  FTabs := TBCEditorTabs.Create;
  FTabs.OnChange := TabsChanged;
  FLeftChar := 1;
  FTopLine := 1;
  FCaretX := 1;
  FCaretY := 1;
  FSelectionBeginPosition.Char := 1;
  FSelectionBeginPosition.Line := 1;
  FSelectionEndPosition := FSelectionBeginPosition;
  FOptions := BCEDITOR_DEFAULT_OPTIONS;
  { Scroll }
  FScrollTimer := TTimer.Create(Self);
  FScrollTimer.Enabled := False;
  FScrollTimer.Interval := 100;
  FScrollTimer.OnTimer := ScrollTimerHandler;
  { Completion proposal }
  FCompletionProposal := TBCEditorCompletionProposal.Create;
  FCompletionProposalTimer := TTimer.Create(Self);
  FCompletionProposalTimer.Enabled := False;
  FCompletionProposalTimer.OnTimer := CompletionProposalTimerHandler;
  { Search }
  FSearchHighlighterBlendFunction.BlendOp := AC_SRC_OVER;
  FSearchHighlighterBitmap := TBitmap.Create;
  FSearchLines := TList.Create;
  FSearch := TBCEditorSearch.Create;
  FSearch.OnChange := SearchChanged;
  AssignSearchEngine;
  FReplace := TBCEditorReplace.Create;
  { Scroll }
  FScroll := TBCEditorScroll.Create;
  FScroll.OnChange := ScrollChanged;
  { Mini map }
  FMinimap := TBCEditorMinimap.Create;
  FMinimap.OnChange := MinimapChanged;
  { Active line }
  FActiveLine := TBCEditorActiveLine.Create;
  FActiveLine.OnChange := ActiveLineChanged;
  { Word wrap }
  FWordWrap := TBCEditorWordWrap.Create;
  FWordWrap.OnChange := WordWrapChanged;
  { Do update character constraints }
  FontChanged(nil);
  TabsChanged(nil);
  { Text }
  FTextOffset := FLeftMargin.GetWidth + FCodeFolding.GetWidth + 2;
  { Highlighter }
  FHighlighter := TBCEditorHighlighter.Create(Self);
end;

destructor TBCBaseEditor.Destroy;
begin
  {$IFDEF USE_ALPHASKINS}
  if FScrollWnd <> nil then
    FreeAndNil(FScrollWnd);
  if Assigned(FCommonData) then
    FreeAndNil(FCommonData);
  {$ENDIF}
  ClearCodeFolding;
  FCodeFolding.Free;
  FDirectories.Free;
  FAllCodeFoldingRanges.Free;
  FHighlighter.Free;
  FHighlighter := nil;
  if Assigned(FChainedEditor) or (FLines <> FOriginalLines) then
    RemoveChainedEditor;

  { do not use FreeAndNil, it first nils and then freey causing problems with code accessing FHookedCommandHandlers
    while destruction }
  FHookedCommandHandlers.Free;
  FHookedCommandHandlers := nil;
  FPlugins.Free;
  FPlugins := nil;
  FMarkList.Free;
  FKeyCommands.Free;
  FKeyCommands := nil;
  FKeyboardHandler.Free;
  FFocusList.Free;
  FSelection.Free;
  FOriginalUndoList.Free;
  FOriginalRedoList.Free;
  FLeftMargin.Free;
  FLeftMargin := nil; { notification has a check }
  FMinimap.Free;
  FWordWrap.Free;
  FTextDrawer.Free;
  FInternalBookmarkImage.Free;
  FFontDummy.Free;
  FOriginalLines.Free;
  FBufferBmp.Free;
  FMinimapBufferBmp.Free;
  FActiveLine.Free;
  FRightMargin.Free;
  FScroll.Free;
  ClearSearchLines;
  FSearchLines.Free;
  FSearch.Free;
  FSearchHighlighterBitmap.Free;
  FReplace.Free;
  FTabs.Free;
  FUndo.Free;
  FLinespacing.Free;
  FSpecialChars.Free;
  FCaret.Free;
  FMatchingPair.Free;
  FCompletionProposal.Free;
  if Assigned(FColumnWidths) then
  begin
    FreeMem(FColumnWidths);
    FColumnWidths := nil;
  end;
  if Assigned(FWordWrapHelper) then
  begin
    FWordWrapHelper.Free;
    FWordWrapHelper := nil;
  end;
  if Assigned(FSearchEngine) then
  begin
    FSearchEngine.Free;
    FSearchEngine := nil;
  end;

  inherited Destroy;
end;

{ Private declarations }

function TBCBaseEditor.CodeFoldingCollapsableFoldRangeForLine(ALine: Integer): TBCEditorCodeFoldingRange;
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  Result := nil;

  for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if Assigned(LCodeFoldingRange) then
      if (LCodeFoldingRange.FromLine = ALine) and not LCodeFoldingRange.ParentCollapsed and LCodeFoldingRange.Collapsable then
      begin
        Result := LCodeFoldingRange;
        Break;
      end
  end;
end;

function TBCBaseEditor.CodeFoldingFoldRangeForLineTo(ALine: Integer): TBCEditorCodeFoldingRange;
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  Result := nil;
  for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if (LCodeFoldingRange.ToLine = ALine) and not LCodeFoldingRange.ParentCollapsed then
    begin
      Result := LCodeFoldingRange;
      Break;
    end;
  end;
end;

function TBCBaseEditor.CodeFoldingLineInsideRange(ALine: Integer): TBCEditorCodeFoldingRange;
var
  LLength: Integer;
begin
  Result := nil;
  LLength := Length(FCodeFoldingRangeForLine) - 1;
  if ALine > LLength then
    ALine := LLength;
  while (ALine > 0) and not Assigned(FCodeFoldingRangeForLine[ALine]) do
    Dec(ALine);
  if (ALine > 0) and Assigned(FCodeFoldingRangeForLine[ALine]) then
    Result := FCodeFoldingRangeForLine[ALine]
end;

function TBCBaseEditor.CodeFoldingRangeForLine(ALine: Integer): TBCEditorCodeFoldingRange;
begin
  Result := nil;
  if ALine < Length(FCodeFoldingRangeForLine) then
    Result := FCodeFoldingRangeForLine[ALine]
end;

function TBCBaseEditor.CodeFoldingTreeEndForLine(ALine: Integer): Boolean;
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  Result := False;

  for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if Assigned(LCodeFoldingRange) then
      if (LCodeFoldingRange.ToLine = ALine) and LCodeFoldingRange.Collapsable and
        not LCodeFoldingRange.ParentCollapsed and not LCodeFoldingRange.Collapsed then
        Exit(True);
  end;
end;

function TBCBaseEditor.CodeFoldingTreeLineForLine(ALine: Integer): Boolean;
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  Result := False;

  for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if Assigned(LCodeFoldingRange) then
      if (LCodeFoldingRange.FromLine < ALine) and (LCodeFoldingRange.ToLine > ALine) and
        not LCodeFoldingRange.ParentCollapsed and not LCodeFoldingRange.Collapsed and LCodeFoldingRange.Collapsable then
        Exit(True);
  end;
end;

function TBCBaseEditor.DoOnCustomLineColors(ALine: Integer; var AForeground: TColor; var ABackground: TColor): Boolean;
begin
  Result := False;
  AForeground := clNone;
  ABackground := clNone;
  ALine := RowToLine(ALine);
  if FCodeFolding.Visible then
    ALine := GetUncollapsedLineNumber(ALine);
  if Assigned(FOnCustomLineColors) then
    FOnCustomLineColors(Self, ALine, Result, AForeground, ABackground);
end;

function TBCBaseEditor.DoOnCodeFoldingHintClick(X, Y: Integer): Boolean;
var
  LFoldRange: TBCEditorCodeFoldingRange;
  LDisplayPosition: TBCEditorDisplayPosition;
  LPoint: TPoint;
  LScrolledXBy: Integer;
  LCollapseMarkRect: TRect;
begin
  Result := True;
  LDisplayPosition := PixelsToNearestRowColumn(X, Y);
  LFoldRange := CodeFoldingCollapsableFoldRangeForLine(RowToLine(LDisplayPosition.Row));

  if Assigned(LFoldRange) and LFoldRange.Collapsed then
  begin
    LScrolledXBy := (LeftChar - 1) * CharWidth;
    LPoint := Point(X, Y);
    LCollapseMarkRect := LFoldRange.CollapseMarkRect;

    if LCollapseMarkRect.Right - LScrolledXBy > 0 then
    begin
      OffsetRect(LCollapseMarkRect, -LScrolledXBy, 0);

      if PtInRect(LCollapseMarkRect, LPoint) then
      begin
        FreeHintForm(FCodeFoldingHintForm);
        CodeFoldingUncollapse(LFoldRange);
        Exit;
      end;
    end;
  end;
  Result := False;
end;

function TBCBaseEditor.DoTrimTrailingSpaces(ALine: Integer): Integer;
var
  LLineText: string;
  i, LLength: Integer;
begin
  Result := 0;
  if not (eoTrimTrailingSpaces in FOptions) then
    Exit;
  LLineText := FLines[ALine - 1];
  LLength := Length(LLineText);
  i := 0;
  while (LLength > 0) and (LLineText[LLength] < BCEDITOR_EXCLAMATION_MARK) do
  begin
    Dec(LLength);
    Inc(i);
  end;
  if i = 0 then
    Exit;

  FLines[ALine - 1] := Copy(FLines[ALine - 1], 1, LLength);
  Result := i;
end;

function TBCBaseEditor.ExtraLineSpacing: Integer;
begin
  Result := 0;
  case FLinespacing.Rule of
    lsSingle:
      Result := 2;
    lsOneAndHalf:
      Result := RoundCorrect(FTextHeight * 0.5) + 2;
    lsDouble:
      Result := FTextHeight + 2;
    lsSpecified:
      Result := FLinespacing.Spacing;
  end;
end;

function TBCBaseEditor.FindHookedCommandEvent(AHookedCommandEvent: TBCEditorHookedCommandEvent): Integer;
var
  LHookedCommandHandler: TBCEditorHookedCommandHandler;
begin
  Result := GetHookedCommandHandlersCount - 1;
  while Result >= 0 do
  begin
    LHookedCommandHandler := TBCEditorHookedCommandHandler(FHookedCommandHandlers[Result]);
    if LHookedCommandHandler.Equals(AHookedCommandEvent) then
      Break;
    Dec(Result);
  end;
end;

function TBCBaseEditor.GetCanPaste;
begin
  Result := not ReadOnly and (IsClipboardFormatAvailable(CF_TEXT) or IsClipboardFormatAvailable(CF_UNICODETEXT));
end;

function TBCBaseEditor.GetCanRedo: Boolean;
begin
  Result := not ReadOnly and FRedoList.CanUndo;
end;

function TBCBaseEditor.GetCanUndo: Boolean;
begin
  Result := not ReadOnly and FUndoList.CanUndo;
end;

function TBCBaseEditor.GetCaretPosition: TBCEditorTextPosition;
begin
  Result.Char := CaretX;
  Result.Line := CaretY;
end;

function TBCBaseEditor.GetClipboardText: string;
var
  LGlobalMem: HGLOBAL;
  LLocaleID: LCID;
  LBytePointer: PByte;

  function StringToString(const S: AnsiString; CodePage: Word): string;
  var
    InputLength, OutputLength: Integer;
  begin
    InputLength := Length(S);
    OutputLength := MultiByteToWideChar(CodePage, 0, PAnsiChar(S), InputLength, nil, 0);
    SetLength(Result, OutputLength);
    MultiByteToWideChar(CodePage, 0, PAnsiChar(S), InputLength, PChar(Result), OutputLength);
  end;

  function CodePageFromLocale(Language: LCID): Integer;
  var
    Buf: array [0 .. 6] of Char;
  begin
    GetLocaleInfo(Language, LOCALE_IDefaultAnsiCodePage, Buf, 6);
    Result := StrToIntDef(Buf, GetACP);
  end;

begin
  Result := '';
  Clipboard.open;
  try
    if Clipboard.HasFormat(CF_UNICODETEXT) then
    begin
      LGLobalMem := Clipboard.GetAsHandle(CF_UNICODETEXT);
      try
        if LGlobalMem <> 0 then
          Result := PChar(GlobalLock(LGlobalMem));
      finally
        if LGlobalMem <> 0 then
          GlobalUnlock(LGlobalMem);
      end;
    end
    else
    begin
      LLocaleID := 0;
      LGlobalMem := Clipboard.GetAsHandle(CF_LOCALE);
      try
        if LGlobalMem <> 0 then
          LLocaleID := PInteger(GlobalLock(LGlobalMem))^;
      finally
        if LGlobalMem <> 0 then
          GlobalUnlock(LGlobalMem);
      end;

      LGlobalMem := Clipboard.GetAsHandle(CF_TEXT);
      try
        if LGlobalMem <> 0 then
        begin
          LBytePointer := GlobalLock(LGlobalMem);
          Result := StringToString(PAnsiChar(LBytePointer), CodePageFromLocale(LLocaleID));
        end
      finally
        if LGlobalMem <> 0 then
          GlobalUnlock(LGlobalMem);
      end;
    end;
  finally
    Clipboard.Close;
  end;
end;

function TBCBaseEditor.CreateUncollapsedLines: TStringList;
var
  i, j, k: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  Result := TStringList.Create;
  Result.Text := FLines.Text;
  j := Length(FCodeFoldingRangeForLine) - 1;
  for i := 1 to j do
  begin
    LCodeFoldingRange := CodeFoldingRangeForLine(i);
    if Assigned(LCodeFoldingRange) and LCodeFoldingRange.Collapsed then
    begin
      Result.Delete(i - 1); { Collapsed line }
      for k := LCodeFoldingRange.CollapsedLines.Count - 1 downto 0 do
        Result.Insert(i - 1, LCodeFoldingRange.CollapsedLines.Strings[k]);
    end;
  end;
end;

function TBCBaseEditor.GetCollapsedLineNumber(ALine: Integer): Integer;
var
  LDifference, i: Integer;
  LCodeFoldingRangeForLine: TBCEditorCodeFoldingRange;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  LDifference := 0;
  LCodeFoldingRangeForLine := CodeFoldingRangeForLine(ALine);
  Result := ALine;

  for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if Assigned(LCodeFoldingRange) then
      if LCodeFoldingRange.ToLine < ALine then
      begin
        if (LCodeFoldingRange <> LCodeFoldingRangeForLine) and not LCodeFoldingRange.ParentCollapsed then
          Inc(LDifference, Max(LCodeFoldingRange.CollapsedLines.Count - 1, 0))
      end
      else
        Break;
  end;

  Dec(Result, LDifference);
end;

function TBCBaseEditor.GetDisplayLineCount: Integer;
begin
  if not Assigned(FWordWrapHelper) then
    Result := FLines.Count
  else
    Result := FWordWrapHelper.GetRowCount;
end;

function TBCBaseEditor.GetDisplayPosition: TBCEditorDisplayPosition;
begin
  Result := TextToDisplayPosition(CaretPosition, False);
  if GetWordWrap and FCaretAtEndOfLine then
  begin
    if Result.Column = 1 then
    begin
      if Result.Row > 0 then
        Dec(Result.Row);
      Result.Column := FWordWrapHelper.GetRowLength(Result.Row) + 1;
    end
    else
      FCaretAtEndOfLine := False;
  end;
end;

function TBCBaseEditor.GetDisplayPosition(AColumn, ARow: Integer): TBCEditorDisplayPosition;
begin
  Result.Column := AColumn;
  Result.Row := ARow;
end;

function TBCBaseEditor.GetDisplayX: Integer;
begin
  Result := DisplayPosition.Column;
end;

function TBCBaseEditor.GetDisplayY: Integer;
begin
  if not GetWordWrap then
    Result := GetCollapsedLineNumber(CaretY)
  else
    Result := DisplayPosition.Row;
end;

function TBCBaseEditor.GetEndOfLine(ALine: PChar): PChar;
begin
  Result := ALine;
  if Assigned(Result) then
    while (Result^ <> BCEDITOR_NONE_CHAR) and (Result^ <> BCEDITOR_LINEFEED) and (Result^ <> BCEDITOR_CARRIAGE_RETURN) do
      Inc(Result);
end;

function TBCBaseEditor.GetExpandedLength(const ALine: string; ATabWidth: Integer): Integer;
var
  LPLine: PChar;
begin
  Result := 0;
  LPLine := PChar(ALine);
  while LPLine^ <> BCEDITOR_NONE_CHAR do
  begin
    if LPLine^ = BCEDITOR_TAB_CHAR then
      Inc(Result, ATabWidth - (Result mod ATabWidth))
    else
      Inc(Result);
    Inc(LPLine);
  end;
end;

function TBCBaseEditor.GetHighlighterAttributeAtRowColumn(const ATextPosition: TBCEditorTextPosition; var AToken: string;
  var ATokenType, AStart: Integer; var AHighlighterAttribute: TBCEditorHighlighterAttribute): Boolean;
var
  LPositionX, LPositionY: Integer;
  LLine: string;
begin
  LPositionY := ATextPosition.Line - 1;
  if Assigned(Highlighter) and (LPositionY >= 0) and (LPositionY < FLines.Count) then
  begin
    LLine := FLines[LPositionY];
    if LPositionY = 0 then
      Highlighter.ResetCurrentRange
    else
      Highlighter.SetCurrentRange(FLines.Ranges[LPositionY - 1]);
    Highlighter.SetCurrentLine(LLine);
    LPositionX := ATextPosition.Char;
    if (LPositionX > 0) and (LPositionX <= Length(LLine)) then
    while not Highlighter.GetEndOfLine do
    begin
      AStart := Highlighter.GetTokenPosition + 1;
      AToken := Highlighter.GetToken;
      if (LPositionX >= AStart) and (LPositionX < AStart + Length(AToken)) then
      begin
        AHighlighterAttribute := Highlighter.GetTokenAttribute;
        ATokenType := Highlighter.GetTokenKind;
        Exit(True);
      end;
      Highlighter.Next;
    end;
  end;
  AToken := '';
  AHighlighterAttribute := nil;
  Result := False;
end;

function TBCBaseEditor.GetHookedCommandHandlersCount: Integer;
begin
  if Assigned(FHookedCommandHandlers) then
    Result := FHookedCommandHandlers.Count
  else
    Result := 0;
end;

function TBCBaseEditor.GetLeadingWhite(const ALine: string): string;
var
  i: Integer;
begin
  Result := '';

  i := 1;
  while (i <= Length(ALine)) and (ALine[i] < BCEDITOR_EXCLAMATION_MARK) do
  begin
    Result := Result + ALine[i];
    Inc(i);
  end;
end;

function TBCBaseEditor.GetLeftSpacing(ACharCount: Integer; AWantTabs: Boolean): string;
begin
  if AWantTabs and not (toTabsToSpaces in FTabs.Options) and (ACharCount >= FTabs.Width) then
    Result := StringOfChar(BCEDITOR_TAB_CHAR, ACharCount div FTabs.Width) +
      StringOfChar(BCEDITOR_SPACE_CHAR, ACharCount mod FTabs.Width)
  else
    Result := StringOfChar(BCEDITOR_SPACE_CHAR, ACharCount);
end;

function TBCBaseEditor.GetLineHeight: Integer;
begin
  Result := FTextHeight + ExtraLineSpacing;
end;

function TBCBaseEditor.GetLineIndentChars(AStrings: TStrings; ALine: Integer): Integer;
var
  LPLine: PChar;
begin
  Result := 0;
  if ALine >= AStrings.Count then
    Exit;
  LPLine := PChar(AStrings[ALine]);
  repeat
    if LPLine^ = BCEDITOR_TAB_CHAR then
      while (LPLine^ <> BCEDITOR_NONE_CHAR) and (LPLine^ = BCEDITOR_TAB_CHAR) do
      begin
        Inc(LPLine);
        Inc(Result, FTabs.Width);
      end
    else
    if LPLine^ = BCEDITOR_SPACE_CHAR then
      while (LPLine^ <> BCEDITOR_NONE_CHAR) and (LPLine^ = BCEDITOR_SPACE_CHAR) do
      begin
        Inc(LPLine);
        Inc(Result);
      end
  until (LPLine^ <> BCEDITOR_TAB_CHAR) and (LPLine^ <> BCEDITOR_SPACE_CHAR);
end;

function TBCBaseEditor.GetLineText: string;
begin
  if (CaretY >= 1) and (CaretY <= FLines.Count) then
    Result := FLines[CaretY - 1]
  else
    Result := '';
end;

function TBCBaseEditor.GetMatchingToken(APoint: TBCEditorTextPosition; var AMatch: TBCEditorMatchingPairMatch): TBCEditorMatchingTokenResult;
var
  i, j: Integer;
  LPLine: PChar;
  LTokenMatch: PBCEditorMatchingPairToken;
  LToken, OriginalToken: string;
  LLevel, LDeltaLevel: Integer;
  LMatchStackID: Integer;
  LOpenDuplicateLength, LCloseDuplicateLength: Integer;

  function IsOpenToken: Boolean;
  var
    i: Integer;
  begin
    Result := True;
    for i := 0 to LOpenDuplicateLength - 1 do
    if LToken = PBCEditorMatchingPairToken(FHighlighter.MatchingPairs[FMatchingPairOpenDuplicate[i]])^.OpenToken then
      Exit;
    Result := False
  end;

  function IsCloseToken: Boolean;
  var
    i: Integer;
  begin
    Result := True;
    for i := 0 to LCloseDuplicateLength - 1 do
    if LToken = PBCEditorMatchingPairToken(FHighlighter.MatchingPairs[FMatchingPairCloseDuplicate[i]])^.CloseToken then
      Exit;
    Result := False
  end;

  function CheckToken: Boolean;
  begin
    with FHighlighter do
    begin
      LToken := LowerCase(GetToken);
      if IsCloseToken then
        Dec(LLevel)
      else
      if IsOpenToken then
        Inc(LLevel);
      if LLevel = 0 then
      begin
        GetMatchingToken := trOpenAndCloseTokenFound;
        AMatch.CloseToken := GetToken;
        AMatch.CloseTokenPos.Line := APoint.Line + 1;
        AMatch.CloseTokenPos.Char := GetTokenPosition + 1;
        Result := True;
      end
      else
      begin
        Next;
        Result := False;
      end;
    end;
  end;

  procedure CheckTokenBack;
  begin
    with FHighlighter do
    begin
      LToken := LowerCase(GetToken);
      if IsCloseToken then
      begin
        Dec(LLevel);
        if LMatchStackID >= 0 then
          Dec(LMatchStackID);
      end
      else
      if IsOpenToken then
      begin
        Inc(LLevel);
        Inc(LMatchStackID);
        if LMatchStackID >= Length(FMatchingPairMatchStack) then
          SetLength(FMatchingPairMatchStack, Length(FMatchingPairMatchStack) + 32);
        FMatchingPairMatchStack[LMatchStackID].Token := GetToken;
        FMatchingPairMatchStack[LMatchStackID].Position.Line := APoint.Line + 1;
        FMatchingPairMatchStack[LMatchStackID].Position.Char := GetTokenPosition + 1;
      end;
      Next;
    end;
  end;

begin
  Result := trNotFound;
  if FHighlighter = nil then
    Exit;
  Dec(APoint.Line);
  Dec(APoint.Char);
  with FHighlighter do
  begin
    if APoint.Line = 0 then
      ResetCurrentRange
    else
      SetCurrentRange(FLines.Ranges[APoint.Line]);
    SetCurrentLine(FLines[APoint.Line]);

    while not GetEndOfLine and (APoint.Char >= GetTokenPosition + Length(GetToken)) do
      Next;

    if GetEndOfLine then
      Exit;

    if FHighlighter.GetCurrentRangeAttribute.Element = BCEDITOR_ATTRIBUTE_ELEMENT_COMMENT then
      Exit;

    I := 0;
    J := FHighlighter.MatchingPairs.Count;
    OriginalToken := GetToken;
    LToken := Trim(LowerCase(OriginalToken));
    if LToken = '' then
      Exit;
    while I < J do
    begin
      if LToken = PBCEditorMatchingPairToken(FHighlighter.MatchingPairs[I])^.OpenToken then
      begin
        Result := trOpenTokenFound;
        AMatch.OpenToken := OriginalToken;
        AMatch.OpenTokenPos.Line := APoint.Line + 1;
        AMatch.OpenTokenPos.Char := GetTokenPosition + 1;

        LPLine := PChar(FLines[APoint.Line]);
        Inc(LPLine, AMatch.OpenTokenPos.Char - 1);
        if (Length(OriginalToken) > 2) and ((LPLine^ <> #0) or (LPLine^ <> BCEDITOR_SPACE_CHAR) or (LPLine^ <> BCEDITOR_TAB_CHAR)) then
          Result := trNotFound;
        Break;
      end
      else
      if LToken = PBCEditorMatchingPairToken(FHighlighter.MatchingPairs[I])^.CloseToken then
      begin
        Result := trCloseTokenFound;
        AMatch.CloseToken := OriginalToken;
        AMatch.CloseTokenPos.Line := APoint.Line + 1;
        AMatch.CloseTokenPos.Char := GetTokenPosition + 1;
        Break;
      end;
      Inc(I);
    end;
    if Result = trNotFound then
      Exit;
    LTokenMatch := FHighlighter.MatchingPairs.Items[I];
    AMatch.TokenAttribute := GetTokenAttribute;
    if J > Length(FMatchingPairOpenDuplicate) then
    begin
      SetLength(FMatchingPairOpenDuplicate, J);
      SetLength(FMatchingPairCloseDuplicate, J);
    end;
    LOpenDuplicateLength := 0;
    LCloseDuplicateLength := 0;
    for I := 0 to J - 1 do
    begin
      if LTokenMatch^.OpenToken = PBCEditorMatchingPairToken(FHighlighter.MatchingPairs[I])^.OpenToken then
      begin
        FMatchingPairCloseDuplicate[LCloseDuplicateLength] := I;
        Inc(LCloseDuplicateLength);
      end;
      if (LTokenMatch^.CloseToken = PBCEditorMatchingPairToken(FHighlighter.MatchingPairs[I])^.CloseToken) then
      begin
        FMatchingPairOpenDuplicate[LOpenDuplicateLength] := I;
        Inc(LOpenDuplicateLength);
      end;
    end;
    if Result = trOpenTokenFound then
    begin
      LLevel := 1;
      Next;
      while True do
      begin
        while not GetEndOfLine do
          if CheckToken then
            Exit;
        Inc(APoint.Line);
        if APoint.Line >= FLines.Count then
          Break;
        SetCurrentLine(FLines[APoint.Line]);
      end;
    end
    else
    begin
      if Length(FMatchingPairMatchStack) < 32 then
        SetLength(FMatchingPairMatchStack, 32);
      LMatchStackID := -1;
      LLevel := -1;
      if APoint.Line = 0 then
        ResetCurrentRange
      else
        SetCurrentRange(FLines.Ranges[APoint.Line - 1]);
      SetCurrentLine(FLines[APoint.Line]);
      while not GetEndOfLine and (GetTokenPosition < AMatch.CloseTokenPos.Char -1) do
        CheckTokenBack;
      if LMatchStackID > -1 then
      begin
        Result := trCloseAndOpenTokenFound;
        AMatch.OpenToken := FMatchingPairMatchStack[LMatchStackID].Token;
        AMatch.OpenTokenPos := FMatchingPairMatchStack[LMatchStackID].Position;
      end
      else
      while APoint.Line > 0 do
      begin
        LDeltaLevel := -LLevel - 1;
        Dec(APoint.Line);
        if APoint.Line = 0 then
          ResetCurrentRange
        else
          SetCurrentRange(FLines.Ranges[APoint.Line - 1]);
        SetCurrentLine(FLines[APoint.Line]);
        LMatchStackID := -1;
        while not GetEndOfLine do
          CheckTokenBack;
        if LDeltaLevel <= LMatchStackID then
        begin
          Result := trCloseAndOpenTokenFound;
          AMatch.OpenToken := FMatchingPairMatchStack[LMatchStackID - LDeltaLevel].Token;
          AMatch.OpenTokenPos := FMatchingPairMatchStack[LMatchStackID - LDeltaLevel].Position;
          Exit;
        end;
      end;
    end;
  end;
end;

function TBCBaseEditor.GetSelectionAvailable: Boolean;
begin
  Result := (FSelectionBeginPosition.Char <> FSelectionEndPosition.Char) or
    ((FSelectionBeginPosition.Line <> FSelectionEndPosition.Line) and (FSelection.ActiveMode <> smColumn));
end;

function TBCBaseEditor.GetSelectedText: string;

  function CopyPadded(const S: string; Index, Count: Integer): string;
  var
    i: Integer;
    LSourceLength, LDestinationLength: Integer;
    LPResult: PChar;
  begin
    LSourceLength := Length(S);
    LDestinationLength := Index + Count;
    if LSourceLength >= LDestinationLength then
      Result := Copy(S, Index, Count)
    else
    begin
      SetLength(Result, LDestinationLength);
      LPResult := PChar(Result);
      StrCopy(LPResult, PChar(Copy(S, Index, Count)));
      Inc(LPResult, Length(S));
      for i := 0 to LDestinationLength - LSourceLength - 1 do
        LPResult[i] := BCEDITOR_SPACE_CHAR;
    end;
  end;

  procedure CopyAndForward(const S: string; Index, Count: Integer; var PResult: PChar);
  var
    LPSource: PChar;
    LSourceLength: Integer;
    LDestinationLength: Integer;
  begin
    LSourceLength := Length(S);
    if (Index <= LSourceLength) and (Count > 0) then
    begin
      Dec(Index);
      LPSource := PChar(S) + Index;
      LDestinationLength := Min(LSourceLength - Index, Count);
      Move(LPSource^, PResult^, LDestinationLength * SizeOf(Char));
      Inc(PResult, LDestinationLength);
      PResult^ := BCEDITOR_NONE_CHAR;
    end;
  end;

  function CopyPaddedAndForward(const S: string; Index, Count: Integer; var PResult: PChar): Integer;
  var
    LPOld: PChar;
    LLength, i: Integer;
  begin
    Result := 0;
    LPOld := PResult;
    CopyAndForward(S, Index, Count, PResult);
    LLength := Count - (PResult - LPOld);
    { Was anything copied at all or Index was behind line length? }
    if not (eoTrimTrailingSpaces in Options) and (PResult - LPOld > 0) then
    begin
      for i := 0 to LLength - 1 do
        PResult[i] := BCEDITOR_SPACE_CHAR;
      Inc(PResult, LLength);
    end
    else
      Result := LLength;
  end;

  function IsWrappedRow(ALine, ARow: Integer): Boolean;
  begin
    if GetWordWrap then
      Result := FWordWrapHelper.LineToRealRow(ALine) <> ARow
    else
      Result := False;
  end;

  function DoGetSelectedText: string;
  var
    LFirst, LLast, LTotalLength: Integer;
    LColumnFrom, LColumnTo: Integer;
    i, L, R: Integer;
    S: string;
    P: PChar;
    LRow: Integer;
    LTextPosition: TBCEditorTextPosition;
    LDisplayPosition: TBCEditorDisplayPosition;
    LTrimCount: Integer;
    LUncollapsedLines: TStringList;
    LCodeFoldingRange: TBCEditorCodeFoldingRange;
  begin
    LColumnFrom := SelectionBeginPosition.Char;
    LFirst := SelectionBeginPosition.Line;
    LColumnTo := SelectionEndPosition.Char;
    LLast := SelectionEndPosition.Line;
    LTotalLength := 0;
    case FSelection.ActiveMode of
      smNormal:
        begin
          LFirst := GetUncollapsedLineNumber(LFirst);
          LLast := GetUncollapsedLineNumber(LLast);
          LCodeFoldingRange := CodeFoldingRangeForLine(LLast);
          if Assigned(LCodeFoldingRange) and LCodeFoldingRange.Collapsed then
            LLast := LCodeFoldingRange.ToLine;

          LUncollapsedLines := CreateUncollapsedLines;
          try
            if LFirst = LLast then
              Result := Copy(LUncollapsedLines[LFirst - 1], LColumnFrom, LColumnTo - LColumnFrom)
            else
            begin
              // step1: calculate total length of result string
              LTotalLength := Max(0, Length(LUncollapsedLines[LFirst - 1]) - LColumnFrom + 1);
              Inc(LTotalLength, Length(SLineBreak));
              for i := LFirst to LLast - 2 do
              begin
                Inc(LTotalLength, Length(LUncollapsedLines[i]));
                Inc(LTotalLength, Length(SLineBreak));
              end;
              Inc(LTotalLength, LColumnTo - 1);
              //Inc(LTotalLength, Length(SLineBreak) * (LLast - LFirst));
              // step2: build up result string
              SetLength(Result, LTotalLength);
              P := PChar(Result);
              CopyAndForward(LUncollapsedLines[LFirst - 1], LColumnFrom, MaxInt, P);
              CopyAndForward(SLineBreak, 1, MaxInt, P);
              for i := LFirst to LLast - 2 do
              begin
                CopyAndForward(LUncollapsedLines[i], 1, MaxInt, P);
                CopyAndForward(SLineBreak, 1, MaxInt, P);
              end;
              CopyAndForward(LUncollapsedLines[LLast - 1], 1, LColumnTo - 1, P);
            end;
          finally
            LUncollapsedLines.Free;
          end;
        end;
      smColumn:
        begin
          with TextToDisplayPosition(SelectionBeginPosition, False) do
          begin
            LFirst := Row;
            LColumnFrom := Column;
          end;
          with TextToDisplayPosition(SelectionEndPosition, False) do
          begin
            LLast := Row;
            LColumnTo := Column;
          end;
          if LColumnFrom > LColumnTo then
            SwapInt(LColumnFrom, LColumnTo);

          { pre-allocate string large enough for worst case }
          LTotalLength := ((LColumnTo - LColumnFrom) + Length(sLineBreak)) * (LLast - LFirst + 1);
          SetLength(Result, LTotalLength);
          P := PChar(Result);

          { copy chunks to the pre-allocated string }
          LTotalLength := 0;
          for LRow := LFirst to LLast do
          begin
            LDisplayPosition.Row := LRow;
            LDisplayPosition.Column := LColumnFrom;
            LTextPosition := DisplayToTextPosition(LDisplayPosition);
            if IsWrappedRow(LTextPosition.Line, LRow) then
              Continue;
            L := LTextPosition.Char;
            S := FLines[LTextPosition.Line - 1];
            LDisplayPosition.Column := LColumnTo;
            R := DisplayToTextPosition(LDisplayPosition).Char;
            LTrimCount := CopyPaddedAndForward(S, L, R - L, P);
            LTotalLength := LTotalLength + (R - L) - LTrimCount + Length(sLineBreak);
            CopyAndForward(sLineBreak, 1, MaxInt, P);
          end;
          SetLength(Result, Max(LTotalLength - Length(sLineBreak), 0));
        end;
      smLine:
        begin
          LUncollapsedLines := CreateUncollapsedLines;
          for i := GetUncollapsedLineNumber(LFirst) - 1 to GetUncollapsedLineNumber(LLast + 1) - 2 do
          begin
            Inc(LTotalLength, Length(TrimRight(LUncollapsedLines[i])) + Length(sLineBreak));
          end;
          if LLast - 1 = FLines.Count then
            Dec(LTotalLength, Length(sLineBreak));

          SetLength(Result, LTotalLength);
          P := PChar(Result);
          for i := GetUncollapsedLineNumber(LFirst) - 1 to GetUncollapsedLineNumber(LLast + 1) - 2 do
          begin
            CopyAndForward(TrimRight(LUncollapsedLines[i]), 1, MaxInt, P);
            CopyAndForward(sLineBreak, 1, MaxInt, P);
          end;
          LUncollapsedLines.Free;
        end;
    end;
  end;

begin
  if not SelectionAvailable then
    Result := ''
  else
    Result := DoGetSelectedText;
end;

function TBCBaseEditor.GetSearchResultCount: Integer;
begin
  Result := FSearchLines.Count;
end;

function TBCBaseEditor.GetSelectionBeginPosition: TBCEditorTextPosition;
var
  LChar: Char;
begin
  if (FSelectionEndPosition.Line < FSelectionBeginPosition.Line) or
    ((FSelectionEndPosition.Line = FSelectionBeginPosition.Line) and (FSelectionEndPosition.Char < FSelectionBeginPosition.Char)) then
    Result := FSelectionEndPosition
  else
    Result := FSelectionBeginPosition;

  if Result.Char <= Length(FLines[Result.Line - 1]) then
  begin
    LChar := FLines[Result.Line - 1][Result.Char];
    if TCharacter.IsLowSurrogate(LChar) then
    begin
      Dec(Result.Char);
      InternalCaretX := FCaretX - 1;
    end;
  end;
end;

function TBCBaseEditor.GetSelectionEndPosition: TBCEditorTextPosition;
var
  LChar: Char;
begin
  if (FSelectionEndPosition.Line < FSelectionBeginPosition.Line) or
    ((FSelectionEndPosition.Line = FSelectionBeginPosition.Line) and (FSelectionEndPosition.Char < FSelectionBeginPosition.Char)) then
    Result := FSelectionBeginPosition
  else
    Result := FSelectionEndPosition;

  if Result.Char <= Length(FLines[Result.Line - 1]) then
  begin
    LChar := FLines[Result.Line - 1][Result.Char];
    if TCharacter.IsLowSurrogate(LChar) then
    begin
      Inc(Result.Char);
      InternalCaretX := FCaretX + 1;
    end;
  end;
end;

function TBCBaseEditor.GetText: string;
begin
  Result := FLines.Text;
end;

function TBCBaseEditor.GetUncollapsedLineNumber(ALine: Integer): Integer;
begin
  Result := ALine;
  Inc(Result, GetUncollapsedLineNumberDifference(ALine));
end;

function TBCBaseEditor.GetUncollapsedLineNumberDifference(ALine: Integer): Integer;
var
  i: Integer;
  LCodeFoldingRangeForLine: TBCEditorCodeFoldingRange;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  LCodeFoldingRangeForLine := CodeFoldingRangeForLine(ALine);

  if ALine > High(FCollapsedLinesDifferenceCache) then
    SetLength(FCollapsedLinesDifferenceCache, ALine + 1);

  Result := FCollapsedLinesDifferenceCache[ALine];
  if Result > 0 then
    Exit(Result - 1);

  for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if Assigned(LCodeFoldingRange) then
    begin
      if LCodeFoldingRange.FromLine < ALine then
      begin
        if (LCodeFoldingRange <> LCodeFoldingRangeForLine) and LCodeFoldingRange.Collapsed and
          not LCodeFoldingRange.ParentCollapsed then
          Inc(Result, Max(LCodeFoldingRange.CollapsedLines.Count - 1, 0))
      end
      else
        Break;
    end;
  end;

  FCollapsedLinesDifferenceCache[ALine] := Result+1;
end;

function TBCBaseEditor.GetWordAtCursor: string;
begin
  Result := GetWordAtRowColumn(GetTextPosition(CaretX, CaretY));
end;

function TBCBaseEditor.GetWordAtMouse: string;
var
  LTextPosition: TBCEditorTextPosition;
begin
  if GetPositionOfMouse(LTextPosition) then
    Result := GetWordAtRowColumn(LTextPosition);
end;

function TBCBaseEditor.GetWordAtRowColumn(ATextPosition: TBCEditorTextPosition): string;
var
  LTextLine: string;
  LLength, LStop: Integer;
begin
  Result := '';
  if (ATextPosition.Line >= 1) and (ATextPosition.Line <= FLines.Count) then
  begin
    LTextLine := FLines[ATextPosition.Line - 1];
    LLength := Length(LTextLine);
    if LLength = 0 then
      Exit;
    if (ATextPosition.Char >= 1) and (ATextPosition.Char <= LLength + 1) and not IsWordBreakChar(LTextLine[ATextPosition.Char]) then
    begin
      LStop := ATextPosition.Char;
      while (LStop <= LLength) and not IsWordBreakChar(LTextLine[LStop]) do
        Inc(LStop);
      while (ATextPosition.Char > 1) and not IsWordBreakChar(LTextLine[ATextPosition.Char - 1]) do
        Dec(ATextPosition.Char);
      if LStop > ATextPosition.Char then
        Result := Copy(LTextLine, ATextPosition.Char, LStop - ATextPosition.Char);
    end;
  end;
end;

function TBCBaseEditor.GetWordWrap: Boolean;
begin
  Result := Assigned(FWordWrapHelper);
end;

function TBCBaseEditor.GetWrapAtColumn: Integer;
begin
  Result := 0;
  case FWordWrap.Style of
    wwsClientWidth:
      Result := CharsInWindow;
    wwsRightMargin:
      Result := FRightMargin.Position;
    wwsSpecified:
      Result := FWordWrap.Position;
  end
end;

function TBCBaseEditor.IsLineInsideCollapsedCodeFolding(ALine: Integer): Boolean;
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  Result := False;
  for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if LCodeFoldingRange.FromLine > ALine then
      Break
    else
    if (LCodeFoldingRange.FromLine <= ALine) and (ALine <= LCodeFoldingRange.ToLine) then
      if LCodeFoldingRange.Collapsed or LCodeFoldingRange.ParentCollapsed then
        Exit(True);
  end;
end;

function TBCBaseEditor.IsKeywordAtCursorPosition(AOpenKeyWord: PBoolean = nil; AIncludeAfterToken: Boolean = True): Boolean;

  function IsKeywordAtCursorPosForFoldRegions(AOpenKeyWord: PBoolean): Boolean;
  var
    P, i: Integer;
    LKeyword: PChar;
    LLine: String;
    LFoldRegions: TBCEditorCodeFoldingRegions;
    LOffset: Byte;
  begin
    Result := False;

    LFoldRegions := FHighlighter.CodeFoldingRegions;

    LOffset := 0;
    if not AIncludeAfterToken then
      LOffset := 1;

    for i := 0 to LFoldRegions.Count - 1 do
    begin
      LLine := UpperCase(LineText);
      LKeyword := PChar(LFoldRegions[i].OpenToken);

      repeat
        P := Pos(LKeyword, LLine);
        if P > 0 then
        begin
          if (CaretX >= P) and (CaretX <= P + Integer(StrLen(LKeyword)) - LOffset) then
          begin
            Result := True;

            if Assigned(AOpenKeyWord) then
              AOpenKeyWord^ := True;

            Exit;
          end
          else
            Delete(LLine, 1, P + Integer(StrLen(LKeyword)));
        end;
      until P = 0;

      LLine := UpperCase(LineText);
      LKeyword := PChar(LFoldRegions[i].CloseToken);

      repeat
        P := Pos(LKeyword, LLine);

        if P > 0 then
        begin
          if (CaretX >= P) and (CaretX <= P + Integer(StrLen(LKeyword)) - LOffset) then
          begin
            Result := True;

            if Assigned(AOpenKeyWord) then
              AOpenKeyWord^ := False;

            Exit;
          end
          else
            Delete(LLine, 1, P + Integer(StrLen(LKeyword)));
        end;
      until P = 0;
    end;
  end;

begin
  Result := False;

  if not FCodeFolding.Visible then
    Exit;

  if Assigned(FHighlighter) and (FHighlighter.CodeFoldingRegions.Count = 0) then
    Exit;

  if Assigned(FHighlighter) then
    Result := IsKeywordAtCursorPosForFoldRegions(AOpenKeyWord);
end;

function TBCBaseEditor.IsKeywordAtLine(ALine: Integer): Boolean;
var
  i: Integer;
  LLineText: string;
  LFoldRegions: TBCEditorCodeFoldingRegions;
  LKeyWordPtr, LBookmarkTextPtr, LTextPtr: PChar;

  procedure SkipEmptySpace;
  begin
    while (LTextPtr^ = BCEDITOR_SPACE_CHAR) or (LTextPtr^ = BCEDITOR_TAB_CHAR) do
      Inc(LTextPtr);
  end;

  function IsValidChar(Character: PChar): Boolean;
  begin
    Result := CharInSet(Character^, BCEDITOR_STRING_UPPER_CHARACTERS + BCEDITOR_NUMBERS{ + BCEDITOR_SPECIAL_CHARACTERS});
  end;

  function IsWholeWord(FirstChar, LastChar: PChar): Boolean;
  begin
    Result := not IsValidChar(FirstChar) and not IsValidChar(LastChar);
  end;

  function GetLineText(ALine: Integer): string;
  begin
    if (ALine >= 1) and (ALine <= FLines.Count) then
      Result := FLines[ALine - 1]
    else
      Result := '';
  end;

begin
  Result := False;

  if not FCodeFolding.Visible then
    Exit;

  if Assigned(FHighlighter) and (FHighlighter.CodeFoldingRegions.Count = 0) then
    Exit;

  LLineText := GetLineText(ALine);

  if Trim(LLineText) = '' then
    Exit;

  if Assigned(FHighlighter) then
  begin
    LFoldRegions := FHighlighter.CodeFoldingRegions;

    for i := 0 to LFoldRegions.Count - 1 do
    begin
      LTextPtr := PChar(LLineText);
      while LTextPtr^ <> BCEDITOR_NONE_CHAR do
      begin
        SkipEmptySpace;

        LBookmarkTextPtr := LTextPtr;
        { check if the open keyword found }
        LKeyWordPtr := PChar(LFoldRegions[i].OpenToken);
        while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
        begin
          Inc(LTextPtr);
          Inc(LKeyWordPtr);
        end;
        if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then { if found, pop skip region from the stack }
        begin
          if IsWholeWord(LBookmarkTextPtr - 1, LTextPtr) then { not interested in partial hits }
            Exit(True)
          else
            LTextPtr := LBookmarkTextPtr; { skip region close not found, return pointer back }
        end
        else
          LTextPtr := LBookmarkTextPtr; { skip region close not found, return pointer back }

        { check if the close keyword found }
        LKeyWordPtr := PChar(LFoldRegions[i].CloseToken);

        while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
        begin
          Inc(LTextPtr);
          Inc(LKeyWordPtr);
        end;
        if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then { if found, pop skip region from the stack }
        begin
          if IsWholeWord(LBookmarkTextPtr - 1, LTextPtr) then { not interested in partial hits }
            Exit(True)
          else
            LTextPtr := LBookmarkTextPtr; { skip region close not found, return pointer back }
        end
        else
          LTextPtr := LBookmarkTextPtr; { skip region close not found, return pointer back }

        Inc(LTextPtr);
        { skip until next word }
        while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and IsValidChar(LTextPtr - 1) do
          Inc(LTextPtr);
      end;
    end;
  end;
end;

function TBCBaseEditor.IsStringAllWhite(const ALine: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := 1 to Length(ALine) do
  if ALine[i] > BCEDITOR_SPACE_CHAR then
  begin
    Result := False;
    Break;
  end;
end;

function TBCBaseEditor.LeftSpaceCount(const ALine: string; WantTabs: Boolean = False): Integer;
var
  LPLine: PChar;
begin
  LPLine := PChar(ALine);
  if Assigned(LPLine) and (eoAutoIndent in FOptions) then
  begin
    Result := 0;
    while (LPLine^ >= #1) and (LPLine^ <= BCEDITOR_SPACE_CHAR) do
    begin
      if (LPLine^ = BCEDITOR_TAB_CHAR) and WantTabs then
        Inc(Result, FTabs.Width)
      else
        Inc(Result);
      Inc(LPLine);
    end;
  end
  else
    Result := 0;
end;

function TBCBaseEditor.MinPoint(const APoint1, APoint2: TPoint): TPoint;
begin
  if (APoint2.Y < APoint1.Y) or ((APoint2.Y = APoint1.Y) and (APoint2.X < APoint1.X)) then
    Result := APoint2
  else
    Result := APoint1;
end;

function TBCBaseEditor.NextWordPosition: TBCEditorTextPosition;
begin
  Result := NextWordPosition(CaretPosition);
end;

function TBCBaseEditor.NextWordPosition(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition;
var
  X, Y, LLength: Integer;
  LLine: string;
begin
  X := ATextPosition.Char;
  Y := ATextPosition.Line;

  if (Y >= 1) and (Y <= FLines.Count) then
  begin
    LLine := FLines[Y - 1];

    LLength := Length(LLine);
    if X >= LLength then
    begin
      if Y < FLines.Count then
      begin
        LLine := FLines[Y];
        Inc(Y);
        X := StringScan(LLine, 1, IsWordBreakChar);
        if X = 0 then
          Inc(X);
      end;
    end
    else
    begin
      if not IsWordBreakChar(LLine[X]) then
        X := StringScan(LLine, X, IsWordBreakChar);
      if X > 0 then
        X := StringScan(LLine, X, IsWordChar);
      if X = 0 then
        X := LLength + 1;
    end;
  end;
  Result.Char := X;
  Result.Line := Y;
end;

function TBCBaseEditor.PixelsToNearestRowColumn(X, Y: Integer): TBCEditorDisplayPosition;
var
  LLinesY: Integer;
begin
  LLinesY := FVisibleLines * LineHeight;
  { don't return a partially visible last line }
  if Y >= LLinesY then
    Y := Max(LLinesY - 1, 0);
  Result := PixelsToRowColumn(X + 6, Y); { +6 because X is not in the middle of the cursor }
end;

function TBCBaseEditor.PixelsToRowColumn(X, Y: Integer): TBCEditorDisplayPosition;
begin
  Result.Column := Max(1, FLeftChar + ((X - FLeftMargin.GetWidth - FCodeFolding.GetWidth - 2) div FCharWidth));
  Result.Row := Max(1, TopLine + (Y div LineHeight));
end;

function TBCBaseEditor.PreviousWordPosition: TBCEditorTextPosition;
begin
  Result := PreviousWordPosition(CaretPosition);
end;

function TBCBaseEditor.PreviousWordPosition(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition;
var
  X, Y: Integer;
  LLine: string;
begin
  X := ATextPosition.Char;
  Y := ATextPosition.Line;
  if (Y >= 1) and (Y <= FLines.Count) then
  begin
    LLine := FLines[Y - 1];
    X := Min(X, Length(LLine) + 1);

    if X <= 1 then
    begin
      if Y > 1 then
      begin
        Dec(Y);
        LLine := FLines[Y - 1];
        X := Length(LLine) + 1;
      end;
    end
    else
    begin
      if X > 0 then
        X := StringReverseScan(LLine, X - 1, IsWordBreakChar) + 1;
      if X = 0 then
      begin
        if Y > 1 then
        begin
          Dec(Y);
          LLine := FLines[Y - 1];
          X := Length(LLine) + 1;
        end
        else
          X := 1;

        { if previous char is a word-break-char search for the last IdentChar }
        if IsWordBreakChar(LLine[X - 1]) then
          X := StringReverseScan(LLine, X - 1, IsWordChar);
        if X > 0 then
          X := StringReverseScan(LLine, X - 1, IsWordBreakChar) + 1;
        if X = 0 then
        begin
          if Y > 1 then
          begin
            Dec(Y);
            LLine := FLines[Y - 1];
            X := Length(LLine) + 1;
          end
          else
            X := 1;
        end;
      end;

      // if previous char is a word-break-char search for the last IdentChar
      if IsWordBreakChar(LLine[X - 1]) then
        X := StringReverseScan(LLine, X - 1, IsWordChar);
      if X > 0 then
        X := StringReverseScan(LLine, X - 1, IsWordBreakChar) + 1;
      if X = 0 then
      begin
        if Y > 1 then
        begin
          Dec(Y);
          LLine := Lines[Y - 1];
          X := Length(LLine) + 1;
        end
        else
          X := 1;
      end;

    end;
  end;
  Result.Char := X;
  Result.Line := Y;
end;

function TBCBaseEditor.RescanHighlighterRangesFrom(Index: Integer): Integer;
var
  LCurrentRange: TBCEditorLinesRange;
begin
  Result := Index;
  if Result >= FLines.Count then
    Exit;

  if Result = 0 then
    FHighlighter.ResetCurrentRange
  else
    FHighlighter.SetCurrentRange(FLines.Ranges[Result - 1]);

  repeat
    FHighlighter.SetCurrentLine(FLines[Result]);
    FHighlighter.NextToEndOfLine;
    LCurrentRange := FHighlighter.GetCurrentRange;
    if FLines.Ranges[Result] = LCurrentRange then
      Exit;
    FLines.Ranges[Result] := LCurrentRange;
    Inc(Result);
  until Result = FLines.Count;
  Dec(Result);
end;

function TBCBaseEditor.RowColumnToCharIndex(ATextPosition: TBCEditorTextPosition): Integer;
var
  i: Integer;
begin
  Result := 0;
  ATextPosition.Line := Min(FLines.Count, ATextPosition.Line) - 1;
  for i := 0 to ATextPosition.Line - 1 do
    Result := Result + Length(FLines[i]) + 2;
  Result := Result + ATextPosition.Char - 1;
end;

function TBCBaseEditor.RowColumnToPixels(const ADisplayPosition: TBCEditorDisplayPosition): TPoint;
begin
  Result.X := (ADisplayPosition.Column - 1) * FCharWidth + FTextOffset;
  Result.Y := (ADisplayPosition.Row - FTopLine) * LineHeight;
end;

function TBCBaseEditor.RowToLine(ARow: Integer): Integer;
var
  LDisplayPosition: TBCEditorDisplayPosition;
begin
  if not GetWordWrap then
    Result := ARow
  else
  begin
    LDisplayPosition.Column := 1;
    LDisplayPosition.Row := ARow;
    Result := DisplayToTextPosition(LDisplayPosition).Line;
  end;
end;

function TBCBaseEditor.SearchText(const ASearchText: string): Integer;
var
  LStartTextPosition, LEndTextPosition: TBCEditorTextPosition;
  LCurrentTextPosition: TBCEditorTextPosition;
  LSearchLength, LSearchIndex, LFound: Integer;
  LCurrentLine: Integer;
  LIsBackward, LIsFromCursor: Boolean;
  LIsEndUndoBlock: Boolean;
  LResultOffset: Integer;

  function InValidSearchRange(AFirst, ALast: Integer): Boolean;
  begin
    Result := True;
    if (FSelection.ActiveMode = smNormal) or not (soSelectedOnly in FSearch.Options) then
    begin
      if ((LCurrentTextPosition.Line = LStartTextPosition.Line) and (AFirst < LStartTextPosition.Char)) or
        ((LCurrentTextPosition.Line = LEndTextPosition.Line) and (ALast > LEndTextPosition.Char)) then
        Result := False;
    end
    else
    if (FSelection.ActiveMode = smColumn) then
      Result := (AFirst >= LStartTextPosition.Char) and (ALast <= LEndTextPosition.Char) or
        (LEndTextPosition.Char - LStartTextPosition.Char < 1);
  end;

begin
  if not Assigned(FSearchEngine) then
    raise Exception.Create('Search engine has not been assigned');

  Result := 0;
  if Length(ASearchText) = 0 then
    Exit;

  LIsBackward := soBackwards in FSearch.Options;
  LIsFromCursor := not (soEntireScope in FSearch.Options);
  if not SelectionAvailable then
    FSearch.Options := FSearch.Options - [soSelectedOnly];
  if soSelectedOnly in FSearch.Options then
  begin
    LStartTextPosition := SelectionBeginPosition;
    LEndTextPosition := SelectionEndPosition;
    if FSelection.ActiveMode = smLine then
    begin
      LStartTextPosition.Char := 1;
      LEndTextPosition.Char := Length(FLines[LEndTextPosition.Line - 1]) + 1;
    end
    else
    if FSelection.ActiveMode = smColumn then
      if LStartTextPosition.Char > LEndTextPosition.Char then
        SwapInt(LStartTextPosition.Char, LEndTextPosition.Char);
    if LIsBackward then
      LCurrentTextPosition := LEndTextPosition
    else
      LCurrentTextPosition := LStartTextPosition;
  end
  else
  begin
    LStartTextPosition.Char := 1;
    LStartTextPosition.Line := 1;
    LEndTextPosition.Line := FLines.Count;
    LEndTextPosition.Char := Length(FLines[LEndTextPosition.Line - 1]) + 1;
    if LIsFromCursor then
      if LIsBackward then
        LEndTextPosition := CaretPosition
      else
        LStartTextPosition := CaretPosition;
    if LIsBackward then
      LCurrentTextPosition := LEndTextPosition
    else
      LCurrentTextPosition := LStartTextPosition;
  end;
  FSearchEngine.Pattern := ASearchText;
  case FSearch.Engine of
    seNormal:
    begin
      TBCEditorNormalSearch(FSearchEngine).CaseSensitive := soCaseSensitive in FSearch.Options;
      TBCEditorNormalSearch(FSearchEngine).WholeWordsOnly := soWholeWordsOnly in FSearch.Options;
    end;
  end;
  LIsEndUndoBlock := False;
  try
    while (LCurrentTextPosition.Line >= LStartTextPosition.Line) and (LCurrentTextPosition.Line <= LEndTextPosition.Line) do
    begin
      LCurrentLine := FSearchEngine.FindAll(FLines[LCurrentTextPosition.Line - 1]);
      LResultOffset := 0;
      if LIsBackward then
        LSearchIndex := Pred(FSearchEngine.ResultCount)
      else
        LSearchIndex := 0;
      while LCurrentLine > 0 do
      begin
        LFound := FSearchEngine.Results[LSearchIndex] + LResultOffset;
        LSearchLength := FSearchEngine.Lengths[LSearchIndex];
        if LIsBackward then
          Dec(LSearchIndex)
        else
          Inc(LSearchIndex);
        Dec(LCurrentLine);
        if not InValidSearchRange(LFound, LFound + LSearchLength) then
          Continue;
        Inc(Result);
        LCurrentTextPosition.Char := LFound;

        SelectionBeginPosition := LCurrentTextPosition;
        SetCaretPosition(False, GetTextPosition(1, LCurrentTextPosition.Line));
        EnsureCursorPositionVisible(True);
        Inc(LCurrentTextPosition.Char, LSearchLength);
        SelectionEndPosition := LCurrentTextPosition;

        if LIsBackward then
          InternalCaretPosition := SelectionBeginPosition
        else
          InternalCaretPosition := LCurrentTextPosition;
        Exit;
      end;
      if LIsBackward then
        Dec(LCurrentTextPosition.Line)
      else
        Inc(LCurrentTextPosition.Line);
    end;
  finally
    if LIsEndUndoBlock then
      EndUndoBlock;
  end;
end;

function TBCBaseEditor.StringReverseScan(const ALine: string; AStart: Integer; ACharMethod: TBCEditorCharMethod): Integer;
var
  i: Integer;
begin
  Result := 0;
  if (AStart > 0) and (AStart <= Length(ALine)) then
    for i := AStart downto 1 do
      if ACharMethod(ALine[i]) then
        Exit(i);
end;

function TBCBaseEditor.StringScan(const ALine: string; AStart: Integer; ACharMethod: TBCEditorCharMethod): Integer;
var
  LCharPointer: PChar;
begin
  if (AStart > 0) and (AStart <= Length(ALine)) then
  begin
    LCharPointer := PChar(@ALine[AStart]);
    repeat
      if ACharMethod(LCharPointer^) then
        Exit(AStart);
      Inc(LCharPointer);
      Inc(AStart);
    until LCharPointer^ = BCEDITOR_NONE_CHAR;
  end;
  Result := 0;
end;

function TBCBaseEditor.TrimTrailingSpaces(const ALine: string): string;
var
  i: Integer;
begin
  i := Length(ALine);
  while (i > 0) and CharInSet(ALine[i], [BCEDITOR_SPACE_CHAR, BCEDITOR_TAB_CHAR]) do
    Dec(i);
  Result := Copy(ALine, 1, i);
end;

procedure TBCBaseEditor.ActiveLineChanged(Sender: TObject);
begin
  if not (csLoading in ComponentState) then
  begin
    if Sender is TBCEditorActiveLine then
      InvalidateLine(CaretY);
    if Sender is TBCEditorGlyph then
      InvalidateLeftMargin;
  end;
end;

procedure TBCBaseEditor.AssignSearchEngine;
begin
  if Assigned(FSearchEngine) then
  begin
    FSearchEngine.Free;
    FSearchEngine := nil;
  end;
  case FSearch.Engine of
    seNormal:
      FSearchEngine := TBCEditorNormalSearch.Create;
    seRegularExpression:
      FSearchEngine := TBCEditorRegexSearch.Create;
    seWildCard:
      FSearchEngine := TBCEditorWildCardSearch.Create;
  end;
end;

procedure TBCBaseEditor.CaretChanged(Sender: TObject);
begin
  ResetCaret;
  RecalculateCharExtent;
end;

procedure TBCBaseEditor.CheckIfAtMatchingKeywords;
var
  LNewFoldRange: TBCEditorCodeFoldingRange;
  LIsKeyWord, LOpenKeyWord: Boolean;

  function HighlightIndentGuide: Boolean;
  begin
    Result := False;

    if LIsKeyWord and LOpenKeyWord then
      FHighlightedFoldRange := CodeFoldingRangeForLine(CaretY)
    else
    if LIsKeyWord and not LOpenKeyWord then
      FHighlightedFoldRange := CodeFoldingFoldRangeForLineTo(CaretY);

    if Assigned(FHighlightedFoldRange) then
      Exit(True);
  end;

begin
  LIsKeyWord := IsKeywordAtCursorPosition(@LOpenKeyWord, mpoHighlightAfterToken in FMatchingPair.Options);

  if not Assigned(FHighlightedFoldRange) then
  begin
    if HighlightIndentGuide then
      with FHighlightedFoldRange do
        InvalidateLines(FromLine, ToLine);
  end
  else
  begin
    LNewFoldRange := nil;

    if LIsKeyWord and LOpenKeyWord then
      LNewFoldRange := CodeFoldingRangeForLine(CaretY)
    else
    if LIsKeyWord and not LOpenKeyWord then
      LNewFoldRange := CodeFoldingFoldRangeForLineTo(CaretY);

    if LNewFoldRange <> FHighlightedFoldRange then
    begin
      if Assigned(FHighlightedFoldRange) then
      with FHighlightedFoldRange do
        InvalidateLines(FromLine, ToLine);

      FHighlightedFoldRange := nil;
      HighlightIndentGuide;

      if Assigned(FHighlightedFoldRange) then
        with FHighlightedFoldRange do
          InvalidateLines(FromLine, ToLine);
    end;
  end;
end;

procedure TBCBaseEditor.CodeFoldingCollapse(AFoldRange: TBCEditorCodeFoldingRange; AAddToUndoList: Boolean = True);
var
  i: Integer;
  LLineState: TBCEditorLineState;
  LTextLine: string;
begin
  ClearMatchingPair;
  SetLength(FCollapsedLinesDifferenceCache, 0);
  FLines.BeginUpdate;
  with AFoldRange do
  begin
    LTextLine := FLines[ToLine - 1];

    for i := FromLine - 1 to ToLine - 1 do
      CollapsedLines.AddObject(FLines[i], TObject(PInteger(FLines.Attributes[i].LineState)));

    FLines.DeleteLines(FromLine, CollapsedLines.Count - 1);

    LLineState := FLines.Attributes[FromLine - 1].LineState;
    if RegionItem.OpenTokenEnd <> '' then
      FLines[FromLine - 1] := Copy(FLines[FromLine - 1], 1, Pos(RegionItem.OpenTokenEnd,
         UpperCase(FLines[FromLine - 1])))
    else
      FLines[FromLine - 1] := Copy(FLines[FromLine - 1], 1,
        Length(AFoldRange.RegionItem.OpenToken) + Pos(AFoldRange.RegionItem.OpenToken,
        UpperCase(FLines[FromLine - 1])) - 1);
    FLines[FromLine - 1] := FLines[FromLine - 1] + '..' + Trim(LTextLine);
    FLines.Attributes[FromLine - 1].LineState := LLineState;
    Collapsed := True;
    SetParentCollapsedOfSubCodeFoldingRanges(True, FoldRangeLevel);
    MoveCodeFoldingRangesAfter(AFoldRange, -CollapsedLines.Count + 1);
  end;
  if AAddToUndoList then
  begin
    AFoldRange.UndoListed := True;
    FUndoList.AddChange(crCollapseFold, CaretPosition, CaretPosition, '', FSelection.ActiveMode, AFoldRange);
  end;
  CheckIfAtMatchingKeywords;
  FLines.EndUpdate;

  UpdateScrollbars;
end;

procedure TBCBaseEditor.CodeFoldingExpandCollapsedLine(const ALine: Integer);
var
  LFoldRange: TBCEditorCodeFoldingRange;
begin
  LFoldRange := CodeFoldingRangeForLine(ALine);
  if LFoldRange = nil then
    LFoldRange := CodeFoldingFoldRangeForLineTo(ALine);
  if Assigned(LFoldRange) then
  with FAllCodeFoldingRanges do
  begin
    Delete(LFoldRange);
    UpdateFoldRanges;
    UpdateWordWrapHiddenOffsets;
  end;
end;

procedure TBCBaseEditor.CodeFoldingLinesDeleted(AFirstLine: Integer; ACount: Integer);
var
  i: Integer;
  LStartTextPosition, LEndTextPosition: TBCEditorTextPosition;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  if ACount > 0 then
  begin
    for i := AFirstLine + ACount - 1 downto AFirstLine do
    begin
      LCodeFoldingRange := CodeFoldingRangeForLine(i);
      if Assigned(LCodeFoldingRange) then
      begin
        LStartTextPosition.Line := LCodeFoldingRange.FromLine;
        LStartTextPosition.Char := 1;
        LEndTextPosition.Line := LCodeFoldingRange.FromLine;
        LEndTextPosition.Char := Length(FLines[LCodeFoldingRange.FromLine - 1]);
        FAllCodeFoldingRanges.Delete(LCodeFoldingRange);
      end;
    end;
    UpdateFoldRanges(AFirstLine, -ACount);
    LeftMarginChanged(Self);
  end;
end;

procedure TBCBaseEditor.CodeFoldingPrepareRangeForLine;
var
  i: Integer;
  LMaxFromLine: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  LMaxFromLine := 0;

  SetLength(FCodeFoldingRangeForLine, 0); { empty }
  SetLength(FCodeFoldingRangeForLine, FLines.Count + 1); { max }
  for i := FAllCodeFoldingRanges.AllCount - 1 downto 0 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if Assigned(LCodeFoldingRange) then
      if not LCodeFoldingRange.ParentCollapsed then
      begin
        if LCodeFoldingRange.FromLine >= LMaxFromLine then
          LMaxFromLine := LCodeFoldingRange.FromLine;
        FCodeFoldingRangeForLine[LCodeFoldingRange.FromLine] := LCodeFoldingRange;
      end;
  end;

  if FAllCodeFoldingRanges.AllCount > 0 then
    SetLength(FCodeFoldingRangeForLine, LMaxFromLine + 1); { actual size }
end;

procedure TBCBaseEditor.CodeFoldingOnChange(AEvent: TBCEditorCodeFoldingChanges);
begin
  if AEvent = fcEnabled then
  begin
    if not FCodeFolding.Visible then
      CodeFoldingUncollapseAll
    else
      InitCodeFolding;
  end
  else
  if AEvent = fcRescan then
    InitCodeFolding;

  Invalidate;
end;

procedure TBCBaseEditor.CodeFoldingUncollapse(AFoldRange: TBCEditorCodeFoldingRange; AAddToUndoList: Boolean = True);
var
  i: Integer;
begin
  ClearMatchingPair;
  SetLength(FCollapsedLinesDifferenceCache, 0);
  FLines.BeginUpdate;
  with AFoldRange do
  begin
    FLines.Delete(FromLine - 1); { open..close [...] }
    FLines.InsertStrings(FromLine - 1, CollapsedLines);
    for i := 0 to CollapsedLines.Count - 1 do
      FLines.Attributes[FromLine - 1 + i].LineState := TBCEditorLineState(PInteger(CollapsedLines.Objects[i]));
    Collapsed := False;
    MoveCodeFoldingRangesAfter(AFoldRange, CollapsedLines.Count - 1);
    SetParentCollapsedOfSubCodeFoldingRanges(False, FoldRangeLevel);
    CollapsedLines.Clear;
  end;
  if AAddToUndoList then
  begin
    AFoldRange.UndoListed := True;
    FUndoList.AddChange(crUncollapseFold, CaretPosition, CaretPosition, '', FSelection.ActiveMode, AFoldRange);
  end;
  CheckIfAtMatchingKeywords;
  FLines.EndUpdate;

  UpdateScrollbars;
end;

procedure TBCBaseEditor.CompletionProposalTimerHandler(Sender: TObject);
begin
  FCompletionProposalTimer.Enabled := False;
  DoExecuteCompletionProposal;
end;

procedure TBCBaseEditor.ComputeCaret(X, Y: Integer);
var
  LCaretNearestPosition: TBCEditorDisplayPosition;
begin
  LCaretNearestPosition := PixelsToNearestRowColumn(X, Y);
  LCaretNearestPosition.Row := MinMax(LCaretNearestPosition.Row, 1, DisplayLineCount);
  SetInternalDisplayPosition(LCaretNearestPosition);
end;

procedure TBCBaseEditor.ComputeScroll(X, Y: Integer);
var
  LScrollBounds: TRect;
begin
  if not MouseCapture and not Dragging then
  begin
    FScrollTimer.Enabled := False;
    Exit;
  end;
  LScrollBounds := Bounds(FLeftMargin.GetWidth + FCodeFolding.GetWidth, 0,
    FCharsInWindow * FCharWidth + FLeftMargin.GetWidth + FCodeFolding.GetWidth + 4,
    FVisibleLines * LineHeight);

  DeflateMinimapRect(LScrollBounds);

  if BorderStyle = bsNone then
    InflateRect(LScrollBounds, -2, -2);

  if X < LScrollBounds.Left then
    FScrollDeltaX := (X - LScrollBounds.Left) div FCharWidth - 1
  else
  if X >= LScrollBounds.Right then
    FScrollDeltaX := (X - LScrollBounds.Right) div FCharWidth + 1
  else
    FScrollDeltaX := 0;

  if Y < LScrollBounds.Top then
    FScrollDeltaY := (Y - LScrollBounds.Top) div LineHeight - 1
  else
  if Y >= LScrollBounds.Bottom then
    FScrollDeltaY := (Y - LScrollBounds.Bottom) div LineHeight + 1
  else
    FScrollDeltaY := 0;

  FScrollTimer.Enabled := (FScrollDeltaX <> 0) or (FScrollDeltaY <> 0);
end;

procedure TBCBaseEditor.DeflateMinimapRect(var ARect: TRect);
begin
  ARect.Right := (ClientRect.Right-ClientRect.Left) - FMinimap.GetWidth - FSearch.Map.GetWidth;
end;

procedure TBCBaseEditor.DoToggleSelectedCase(const ACommand: TBCEditorCommand);

  function ToggleCase(const Value: string): string;
  var
    i: Integer;
    S: string;
  begin
    Result := UpperCase(Value);
    S := LowerCase(Value);
    for i := 1 to Length(Value) do
    begin
      if Result[i] = Value[i] then
        Result[i] := S[i];
    end;
  end;

  function TitleCase(const AString: string): string;
  var
    i, LLength: Integer;
    s: string;
  begin
    i := 1;
    LLength := Length(AString);
    while i <= LLength do
    begin
      s := AString[i];
      if i > 1 then
      begin
        if AString[i - 1] = ' ' then
          s := UpperCase(s)
        else
          s := LowerCase(s);
      end
      else
        s := UpperCase(s);
      Result := Result + s;
      Inc(i);
    end;
  end;

var
  LSelectedText: string;
  LOldCaretPosition, LOldBlockBeginPosition, LOldBlockEndPosition: TBCEditorTextPosition;
  LWasSelectionAvailable: Boolean;
begin
  Assert((ACommand >= ecUpperCase) and (ACommand <= ecAlternatingCaseBlock));
  if SelectionAvailable then
  begin
    LWasSelectionAvailable := True;
    LOldBlockBeginPosition := SelectionBeginPosition;
    LOldBlockEndPosition := SelectionEndPosition;
  end
  else
    LWasSelectionAvailable := False;
  LOldCaretPosition := CaretPosition;
  try
    LSelectedText := SelectedText;
    if LSelectedText <> '' then
    begin
      case ACommand of
        ecUpperCase, ecUpperCaseBlock:
          LSelectedText := UpperCase(LSelectedText);
        ecLowerCase, ecLowerCaseBlock:
          LSelectedText := LowerCase(LSelectedText);
        ecAlternatingCase, ecAlternatingCaseBlock:
          LSelectedText := ToggleCase(LSelectedText);
        ecSentenceCase:
          LSelectedText := UpperCase(LSelectedText[1]) + LowerCase(Copy(LSelectedText, 2, Length(LSelectedText)));
        ecTitleCase:
          LSelectedText := TitleCase(LSelectedText);
      end;
      BeginUndoBlock;
      try
        if LWasSelectionAvailable then
          FUndoList.AddChange(crSelection, LOldBlockBeginPosition, LOldBlockEndPosition, '', FSelection.ActiveMode)
        else
          FUndoList.AddChange(crSelection, LOldCaretPosition, LOldCaretPosition, '', FSelection.ActiveMode);
        FUndoList.AddChange(crCaret, LOldCaretPosition, LOldCaretPosition, '', FSelection.ActiveMode);
        SelectedText := LSelectedText;
      finally
        EndUndoBlock;
      end;
    end;
  finally
    if LWasSelectionAvailable and (ACommand >= ecUpperCaseBlock) then
    begin
      SelectionBeginPosition := LOldBlockBeginPosition;
      SelectionEndPosition := LOldBlockEndPosition;
    end;
    if LWasSelectionAvailable or (ACommand < ecUpperCaseBlock) then
      CaretPosition := LOldCaretPosition;
  end;
end;

procedure TBCBaseEditor.DoEndKey(ASelection: Boolean);

  function CaretInLastRow: Boolean;
  var
    LLastRow: Integer;
  begin
    if not GetWordWrap then
      Result := True
    else
    begin
      LLastRow := LineToRow(CaretY + 1) - 1;
      while (LLastRow > 1) and (FWordWrapHelper.GetRowLength(LLastRow) = 0) and (RowToLine(LLastRow) = CaretY) do
        Dec(LLastRow);
      Result := DisplayY = LLastRow;
    end;
  end;

  function FirstCharInRow: Integer;
  var
    LDisplayPosition: TBCEditorDisplayPosition;
  begin
    LDisplayPosition.Row := DisplayY;
    LDisplayPosition.Column := 1;
    Result := DisplayToTextPosition(LDisplayPosition).Char;
  end;

var
  LNewCaretPosition: TBCEditorDisplayPosition;
begin
  if GetWordWrap then
  begin
    LNewCaretPosition.Row := DisplayY;
    LNewCaretPosition.Column := FWordWrapHelper.GetRowLength(LNewCaretPosition.Row) + 1;
    LNewCaretPosition.Column := Min(CharsInWindow + 1, LNewCaretPosition.Column);
    MoveCaretAndSelection(CaretPosition, DisplayToTextPosition(LNewCaretPosition), ASelection);
    SetInternalDisplayPosition(LNewCaretPosition);
  end
  else
    MoveCaretAndSelection(CaretPosition, GetTextPosition(Length(LineText) + 1, CaretY), ASelection);
end;

procedure TBCBaseEditor.DoHomeKey(ASelection: Boolean);
var
  LNewPosition: TBCEditorDisplayPosition;
begin
  if GetWordWrap then
  begin
    LNewPosition.Row := DisplayY;
    LNewPosition.Column := TextToDisplayPosition(GetTextPosition(1, CaretY)).Column;
    MoveCaretAndSelection(CaretPosition, DisplayToTextPosition(LNewPosition), ASelection);
  end
  else
    MoveCaretAndSelection(CaretPosition, GetTextPosition(1, CaretY), ASelection);
end;

procedure TBCBaseEditor.DoLinesDeleted(AFirstLine, ACount: Integer; AddToUndoList: Boolean);
var
  i: Integer;
begin
  for i := 0 to Marks.Count - 1 do
    if Marks[i].Line >= AFirstLine + ACount then
      Marks[i].Line := Marks[i].Line - ACount
    else
    if Marks[i].Line > AFirstLine then
      Marks[i].Line := AFirstLine;

  if FCodeFolding.Visible then
    CodeFoldingLinesDeleted(AFirstLine + 1, ACount);

  if Assigned(FOnLinesDeleted) then
    FOnLinesDeleted(Self, AFirstLine, ACount);
end;

procedure TBCBaseEditor.DoLinesInserted(AFirstLine, ACount: Integer);
var
  i: Integer;
begin
  for i := 0 to Marks.Count - 1 do
    if Marks[i].Line >= AFirstLine then
      Marks[i].Line := Marks[i].Line + ACount;

  if FCodeFolding.Visible then
    UpdateFoldRanges(AFirstLine, ACount);
end;

procedure TBCBaseEditor.DoShiftTabKey;
var
  LNewX: Integer;
  LLine: string;
  LLength: Integer;
  LDestinationX: Integer;
  LMaxLength, LLineNumber: Integer;
  LPreviousLine: string;
  LOldSelectedText: string;
  P: PChar;
  LOldCaretPosition: TBCEditorTextPosition;
  LChangeScroll: Boolean;
begin
  if (toSelectedBlockIndent in FTabs.Options) and SelectionAvailable then
  begin
    DoBlockUnindent;
    Exit;
  end;

  LNewX := CaretX;

  if LNewX <> 1 then
  begin
    LLineNumber := CaretY - 1;
    if (LLineNumber > 0) and (LLineNumber < FLines.Count) then
    begin
      Dec(LLineNumber);
      LMaxLength := CaretX - 1;
      repeat
        LPreviousLine := FLines[LLineNumber];
        if Length(LPreviousLine) >= LMaxLength then
        begin
          P := @LPreviousLine[LMaxLength];
          repeat
            if P^ <> BCEDITOR_SPACE_CHAR then
              Break;
            Dec(LNewX);
            Dec(P);
          until LNewX = 1;
          if LNewX <> 1 then
            repeat
              if P^ = BCEDITOR_SPACE_CHAR then
                Break;
              Dec(LNewX);
              Dec(P);
            until LNewX = 1;
          Break;
        end;
        Dec(LLineNumber);
      until LLineNumber < 0;
    end;
  end;

  if LNewX = CaretX then
  begin
    LLine := LineText;
    LLength := Length(LLine);
    LDestinationX := ((CaretX - 2) div FTabs.Width) * FTabs.Width + 1;
    if LNewX > LLength then
      LNewX := LDestinationX
    else
    if (LNewX > LDestinationX) and (LLine[LNewX - 1] = BCEDITOR_TAB_CHAR) then
      Dec(LNewX)
    else
    while (LNewX > LDestinationX) and ((LNewX - 1 > LLength) or (LLine[LNewX - 1] = BCEDITOR_SPACE_CHAR)) do
      Dec(LNewX);
  end;

  if LNewX <> CaretX then
  begin
    SetSelectionBeginPosition(GetTextPosition(LNewX, CaretY));
    SetSelectionEndPosition(CaretPosition);
    LOldCaretPosition := CaretPosition;

    LOldSelectedText := SelectedText;
    SetSelectedTextPrimitive('');

    FUndoList.AddChange(crSilentDelete, GetTextPosition(LNewX, CaretY), LOldCaretPosition, LOldSelectedText, smNormal);

    LChangeScroll := not (soPastEndOfLine in FScroll.Options);
    try
      FScroll.Options := FScroll.Options + [soPastEndOfLine];
      InternalCaretX := LNewX;
    finally
      if LChangeScroll then
        FScroll.Options := FScroll.Options - [soPastEndOfLine];
    end;
  end;
end;

procedure TBCBaseEditor.DoTabKey;
var
  i: Integer;
  LBlockStartPosition: TBCEditorTextPosition;
  LSpaces : string;
  LNewCaretX: Integer;
  LChangeScroll: Boolean;
  LDisplayPosition, LDistanceToTab: Integer;
begin
  if (toSelectedBlockIndent in FTabs.Options) and SelectionAvailable then
  begin
    DoBlockIndent;
    Exit;
  end;

  FUndoList.BeginBlock;
  try
    if SelectionAvailable then
    begin
      FUndoList.AddChange(crDelete, FSelectionBeginPosition, FSelectionEndPosition, GetSelectedText, FSelection.ActiveMode);
      SetSelectedTextPrimitive('');
    end;
    LBlockStartPosition := CaretPosition;

    if toTabsToSpaces in FTabs.Options then
    begin
      i := FTabs.Width - (LBlockStartPosition.Char - 1) mod FTabs.Width;
      if i = 0 then
        i :=  FTabs.Width;
    end
    else
      i :=  FTabs.Width;

    if toTabsToSpaces in FTabs.Options then
    begin
      LSpaces := StringOfChar(BCEDITOR_SPACE_CHAR, i);
      LNewCaretX := LBlockStartPosition.Char + i;
    end
    else
    if (eoTrimTrailingSpaces in Options) and (LBlockStartPosition.Char > Length(LineText)) then
    begin
      LDisplayPosition := TextToDisplayPosition(CaretPosition).Column;
      LDistanceToTab :=  FTabs.Width - ((LDisplayPosition - 1) mod FTabs.Width);
      LNewCaretX := LBlockStartPosition.Char + LDistanceToTab;
    end
    else
    begin
      LSpaces := BCEDITOR_TAB_CHAR;
      if (eoTrimTrailingSpaces in Options) and (Length(TrimTrailingSpaces(LineText)) = 0) then
        LNewCaretX := LBlockStartPosition.Char + GetExpandedLength(LSpaces, FTabs.Width)
      else
        LNewCaretX := LBlockStartPosition.Char + Length(LSpaces);
    end;

    SetSelectedTextPrimitive(LSpaces);
    if FSelection.ActiveMode <> smColumn then
      FUndoList.AddChange(crInsert, LBlockStartPosition, CaretPosition, GetSelectedText,
        FSelection.ActiveMode );
  finally
    FUndoList.EndBlock;
  end;

  LChangeScroll := not (soPastEndOfLine in FScroll.Options);
  try
    FScroll.Options := FScroll.Options + [soPastEndOfLine];
    InternalCaretX := LNewCaretX;
  finally
    if LChangeScroll then
      FScroll.Options := FScroll.Options - [soPastEndOfLine];
  end;

  EnsureCursorPositionVisible;
end;

procedure TBCBaseEditor.DrawCursor(ACanvas: TCanvas);
var
  LDisplayPosition: TBCEditorDisplayPosition;
  LPoint: TPoint;
  LCaretStyle: TBCEditorCaretStyle;
  LCaretWidth, LCaretHeight, Y: Integer;
  LTempBitmap: Graphics.TBitmap;
begin
  if GetSelectedLength > 0 then
    Exit;

  LDisplayPosition := GetDisplayPosition;
  LPoint := RowColumnToPixels(DisplayPosition);
  Y := 0;
  LCaretHeight := 1;
  LCaretWidth := 1;
  if InsertMode then
    LCaretStyle := FCaret.Styles.Insert
  else
    LCaretStyle := FCaret.Styles.Overwrite;
  case LCaretStyle of
    csHorizontalLine, csThinHorizontalLine:
      begin
        LCaretWidth := FCharWidth;
        if LCaretStyle = csHorizontalLine then
          LCaretHeight := 2;
        Y := LineHeight;
        LPoint.Y := LPoint.Y + Y;
      end;
    csHalfBlock:
      begin
        LCaretWidth := FCharWidth;
        LCaretHeight := LineHeight div 2;
        Y := LineHeight div 2;
        LPoint.Y := LPoint.Y + Y;
      end;
    csBlock:
      begin
        LCaretWidth := FCharWidth;
        LCaretHeight := LineHeight;
      end;
    csVerticalLine, csThinVerticalLine:
    begin
      if LCaretStyle = csVerticalLine then
        LCaretWidth := 2;
      LCaretHeight := LineHeight;
    end;
  end;

  LTempBitmap := Graphics.TBitmap.Create;
  try
    LTempBitmap.Width := FCharWidth;
    LTempBitmap.Height := LineHeight;
    { Background }
    LTempBitmap.Canvas.Pen.Color := FCaret.NonBlinking.Colors.Background;
    LTempBitmap.Canvas.Brush.Color := FCaret.NonBlinking.Colors.Background;
    LTempBitmap.Canvas.Rectangle(0, 0, LTempBitmap.Width, LTempBitmap.Height);
    { Character }
    LTempBitmap.Canvas.Brush.Style := bsClear;
    LTempBitmap.Canvas.Font.Name := Font.Name;
    LTempBitmap.Canvas.Font.Color := FCaret.NonBlinking.Colors.Foreground;
    LTempBitmap.Canvas.Font.Style := Font.Style;
    LTempBitmap.Canvas.Font.Height := Font.Height;
    LTempBitmap.Canvas.Font.Size := Font.Size;
    LTempBitmap.Canvas.TextOut(0, 0, Copy(LineText, CaretX, 1));
    { Copy rect }
    ACanvas.CopyRect(Rect(LPoint.X + FCaret.Offsets.X, LPoint.Y + FCaret.Offsets.Y, LPoint.X + FCaret.Offsets.X + LCaretWidth,
      LPoint.Y + FCaret.Offsets.Y + LCaretHeight), LTempBitmap.Canvas, Rect(0, Y, LCaretWidth, Y + LCaretHeight));
  finally
    LTempBitmap.Free
  end;
end;

procedure TBCBaseEditor.ClearSearchLines;
var
  i: Integer;
begin
  for i := FSearchLines.Count - 1 downto 0 do
    Dispose(PBCEditorTextPosition(FSearchLines.Items[i]));
  FSearchLines.Clear;
end;

procedure TBCBaseEditor.FindAll(ASearchText: string = '');
var
  i: Integer;
  LLine, LKeyword: string;
  LTextPtr, LKeyWordPtr, LBookmarkTextPtr: PChar;
  LPTextPosition: PBCEditorTextPosition;
begin
  ClearSearchLines;
  if ASearchText = '' then
    LKeyword := FSearch.SearchText
  else
    LKeyword := ASearchText;
  if LKeyword = '' then
    Exit;
  if not (soCaseSensitive in FSearch.Options) then
    LKeyword := UpperCase(LKeyword);
  for i := 0 to FLines.Count - 1 do
  begin
    LLine := FLines[i-1];
    if not (soCaseSensitive in FSearch.Options) then
      LLine := UpperCase(LLine);
    LTextPtr := PChar(LLine);
    while LTextPtr^ <> BCEDITOR_NONE_CHAR do
    begin
      if LTextPtr^ = PChar(LKeyword)^ then { if the first character is a match }
      begin
        LKeyWordPtr := PChar(LKeyword);
        LBookmarkTextPtr := LTextPtr;
        { check if the keyword found }
        while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (LTextPtr^ = LKeyWordPtr^) do
        begin
          Inc(LTextPtr);
          Inc(LKeyWordPtr);
        end;
        if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then
        begin
          New(LPTextPosition);
          LPTextPosition^.Char := Integer(LBookmarkTextPtr);
          LPTextPosition^.Line := i;
          FSearchLines.Add(LPTextPosition)
        end
        else
          LTextPtr := LBookmarkTextPtr; { not found, return pointer back }
      end;
      Inc(LTextPtr);
    end;
  end;
end;

procedure TBCBaseEditor.FontChanged(Sender: TObject);
begin
  RecalculateCharExtent;
  SizeOrFontChanged(True);
end;

procedure TBCBaseEditor.LinesChanging(Sender: TObject);
begin
  Include(FStateFlags, sfLinesChanging);
end;

procedure TBCBaseEditor.MinimapChanged(Sender: TObject);
begin
  FMinimapBufferBmp.Height := 0;
  SizeOrFontChanged(True);
  Invalidate;
  if not (csLoading in ComponentState) then
    InvalidateMinimap;
end;

procedure TBCBaseEditor.MoveCaretAndSelection(const BeforeTextPosition, AfterTextPosition: TBCEditorTextPosition; SelectionCommand: Boolean);
begin
  if (uoGroupUndo in FUndo.Options) and UndoList.CanUndo then
    FUndoList.AddGroupBreak;

  IncPaintLock;
  if SelectionCommand then
  begin
    if not SelectionAvailable then
      SetSelectionBeginPosition(BeforeTextPosition);
    SetSelectionEndPosition(AfterTextPosition);
  end
  else
    SetSelectionBeginPosition(AfterTextPosition);
  InternalCaretPosition := AfterTextPosition;
  if GetWrapAtColumn > FCharsInWindow then
    EnsureCursorPositionVisible;
  DecPaintLock;
end;

procedure TBCBaseEditor.MoveCaretHorizontally(const X: Integer; SelectionCommand: Boolean);
var
  LZeroPosition, LDestinationPosition: TBCEditorTextPosition;
  LCurrentLineLength, LBorder: Integer;
  LChangeY: Boolean;
  LCaretRowColumn: TBCEditorDisplayPosition;
begin
  if GetWordWrap then
    if X > 0 then
    begin
      if FCaretAtEndOfLine then
      begin
        FCaretAtEndOfLine := False;
        IncPaintLock;
        Include(FStateFlags, sfCaretChanged);
        DecPaintLock;
        Exit;
      end;
    end
    else
    begin
      if (not FCaretAtEndOfLine) and (CaretX > 1) and (DisplayX = 1) then
      begin
        FCaretAtEndOfLine := True;
        if FWordWrap.Style = wwsRightMargin then
          LBorder := FRightMargin.Position
        else
          LBorder := FCharsInWindow - 1;
        if DisplayX > LBorder + 1 then
          SetInternalDisplayPosition(GetDisplayPosition(LBorder + 1, DisplayY))
        else
        begin
          IncPaintLock;
          Include(FStateFlags, sfCaretChanged);
          DecPaintLock;
        end;
        Exit;
      end;
    end;

  if not SelectionAvailable and SelectionCommand then
    FSelectionBeginPosition := CaretPosition;

  LZeroPosition := CaretPosition;
  LDestinationPosition := LZeroPosition;

  LCurrentLineLength := FLines.AccessStringLength(FCaretY - 1);
  LChangeY := not (soPastEndOfLine in FScroll.Options);

  if LChangeY and (X = -1) and (LZeroPosition.Char = 1) and (LZeroPosition.Line > 1) then
  with LDestinationPosition do
  begin
    Line := RowToLine(LineToRow(Line) - 1);
    Char := FLines.AccessStringLength(Line - 1) + 1;
  end
  else
  if LChangeY and (X = 1) and (LZeroPosition.Char > LCurrentLineLength) and (LZeroPosition.Line < FLines.Count) then
    with LDestinationPosition do
    begin
      Line := RowToLine(LineToRow(LDestinationPosition.Line) + 1);
      Char := 1;
    end
  else
  begin
    LDestinationPosition.Char := Max(1, LDestinationPosition.Char + X);

    if (X > 0) and LChangeY then
      LDestinationPosition.Char := Min(LDestinationPosition.Char, LCurrentLineLength + 1);
  end;

  if not SelectionCommand and (LDestinationPosition.Line <> LZeroPosition.Line) then
  begin
    DoTrimTrailingSpaces(LZeroPosition.Line);
    DoTrimTrailingSpaces(LDestinationPosition.Line);
  end;

  MoveCaretAndSelection(FSelectionBeginPosition, LDestinationPosition, SelectionCommand);

  if GetWordWrap and (X > 0) and (CaretX < Length(LineText)) then
  begin
    LCaretRowColumn := DisplayPosition;
    if (LCaretRowColumn.Column = 1) and (LineToRow(CaretY) <> LCaretRowColumn.Row) then
      FCaretAtEndOfLine := True
    else
    if LCaretRowColumn.Column > CharsInWindow + 1 then
    begin
      Inc(LCaretRowColumn.Row);
      LCaretRowColumn.Column := 1;
      InternalCaretPosition := DisplayToTextPosition(LCaretRowColumn);
    end;
  end;
end;

procedure TBCBaseEditor.MoveCaretVertically(const Y: Integer; SelectionCommand: Boolean);
var
  LDestinationPosition, LEndOfLinePosition: TBCEditorDisplayPosition;
  LDestinationLineChar: TBCEditorTextPosition;
begin
  LDestinationPosition := DisplayPosition;

  Inc(LDestinationPosition.Row, Y);
  if Y >= 0 then
  begin
    if RowToLine(LDestinationPosition.Row) > FLines.Count then
      LDestinationPosition.Row := Max(1, DisplayLineCount);
  end
  else
  begin
    if LDestinationPosition.Row < 1 then
      LDestinationPosition.Row := 1;
  end;

  LDestinationLineChar := DisplayToTextPosition(LDestinationPosition);

  if not SelectionCommand and (LDestinationLineChar.Line <> FSelectionBeginPosition.Line) then
  begin
    DoTrimTrailingSpaces(FSelectionBeginPosition.Line);
    DoTrimTrailingSpaces(LDestinationLineChar.Line);
  end;

  if not SelectionAvailable and SelectionCommand then
    FSelectionBeginPosition := CaretPosition;

  { Set caret and block begin / end }
  IncPaintLock;
  MoveCaretAndSelection(FSelectionBeginPosition, LDestinationLineChar, SelectionCommand);
  if GetWordWrap then
  begin
    LEndOfLinePosition := TextToDisplayPosition(LDestinationLineChar);
    FCaretAtEndOfLine := (LEndOfLinePosition.Column = 1) and (LEndOfLinePosition.Row <> LDestinationPosition.Row);
  end;
  DecPaintLock;
end;

procedure TBCBaseEditor.MoveCodeFoldingRangesAfter(AFoldRange: TBCEditorCodeFoldingRange; ALineCount: Integer);
var
  i, j: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  i := 0;
  while i < FAllCodeFoldingRanges.AllCount - 1 do
  begin
    if FAllCodeFoldingRanges[i] = AFoldRange then
      Break;
    Inc(i);
  end;
  for j := 0 to i - 1 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[j];
    if (not LCodeFoldingRange.Collapsed) and (LCodeFoldingRange.ToLine > AFoldRange.FromLine) or
      (not LCodeFoldingRange.Collapsed) and LCodeFoldingRange.RegionItem.SharedClose and
      (AFoldRange.RegionItem.CloseToken = LCodeFoldingRange.RegionItem.CloseToken) then
      LCodeFoldingRange.ToLine := LCodeFoldingRange.ToLine + ALineCount;
  end;
  for j := i + 1 to FAllCodeFoldingRanges.AllCount - 1 do
    FAllCodeFoldingRanges[j].MoveBy(ALineCount);
end;

procedure TBCBaseEditor.OpenLink(AURI: string; ALinkType: Integer);
begin
  case TBCEditorRangeType(ALinkType) of
    ttMailtoLink:
      if (Pos('mailto:', AURI) <> 1) then
        AURI := 'mailto:' + AURI;
    ttWebLink:
      AURI := 'http://' + AURI;
  end;

  ShellExecute(0, nil, PChar(AURI), nil, nil, SW_SHOWNORMAL);
end;

procedure TBCBaseEditor.ProperSetLine(ALine: Integer; const ALineText: string);
begin
  if eoTrimTrailingSpaces in Options then
    FLines[ALine] := TrimRight(ALineText)
  else
    FLines[ALine] := ALineText;
end;

procedure TBCBaseEditor.RightMarginChanged(Sender: TObject);
begin
  if FWordWrap.Style = wwsRightMargin then
    FWordWrapHelper.DisplayChanged;
  if GetWordWrap then
    if FWordWrap.Style = wwsRightMargin then
      FWordWrapHelper.Reset;

  if not (csLoading in ComponentState) then
    Invalidate;
end;

procedure TBCBaseEditor.ScanCodeFoldingRanges(var ATopFoldRanges: TBCEditorAllCodeFoldingRanges; AStrings: TStrings);
const
  CODE_FOLDING_VALID_CHARACTERS = ['\', '@'] + BCEDITOR_UNDERSCORE + BCEDITOR_STRING_UPPER_CHARACTERS + BCEDITOR_NUMBERS;
var
  LLine, LFold, LFoldCount, LCount: Integer;
  LTextPtr: PChar;
  LBeginningOfLine, LIsOneCharFolds: Boolean;
  LKeyWordPtr, LBookmarkTextPtr, LBookmarkTextPtr2: PChar;
  LFoldRange: TBCEditorCodeFoldingRange;
  LOpenTokenSkipFoldRangeList: TList;
  LOpenTokenFoldRangeList: TList;
  LFoldRanges: TBCEditorCodeFoldingRanges;

  function IsValidChar(Character: PChar): Boolean;
  begin
    Result := CharInSet(UpCase(Character^), CODE_FOLDING_VALID_CHARACTERS);
  end;

  function IsWholeWord(FirstChar, LastChar: PChar): Boolean;
  begin
    Result := not IsValidChar(FirstChar) and not IsValidChar(LastChar);
  end;

  procedure SkipEmptySpace;
  begin
    while (LTextPtr^ = BCEDITOR_SPACE_CHAR) or (LTextPtr^ = BCEDITOR_TAB_CHAR) do
      Inc(LTextPtr);
  end;

  function CountCharsBefore(TextPtr: PChar; Character: Char): Integer;
  var
    TempPtr: PChar;
  begin
    Result := 0;
    TempPtr := TextPtr - 1;
    while TempPtr^ = Character do
    begin
      Inc(Result);
      Dec(TempPtr);
    end;
  end;

  function OddCountOfStringEscapeChars(ATextPtr: PChar): Boolean;
  begin
    Result := False;
    if Highlighter.CodeFoldingRegions.StringEscapeChar <> #0 then
      Result := Odd(CountCharsBefore(ATextPtr, Highlighter.CodeFoldingRegions.StringEscapeChar));
  end;

  function IsNextSkipChar(ATextPtr: PChar; ASkipRegionItem: TBCEditorSkipRegionItem): Boolean;
  begin
    Result := False;
    if ASkipRegionItem.SkipIfNextCharIsNot <> #0 then
      Result := (ATextPtr + 1)^ = ASkipRegionItem.SkipIfNextCharIsNot;
  end;

  function IsPreviousCharStringEscape(ATextPtr: PChar): Boolean;
  begin
    Result := False;
    if Highlighter.CodeFoldingRegions.StringEscapeChar <> #0 then
      Result := (ATextPtr - 1)^ = Highlighter.CodeFoldingRegions.StringEscapeChar;
  end;

  function IsNextCharStringEscape(ATextPtr: PChar): Boolean;
  begin
    Result := False;
    if Highlighter.CodeFoldingRegions.StringEscapeChar <> #0 then
      Result := (ATextPtr + 1)^ = Highlighter.CodeFoldingRegions.StringEscapeChar;
  end;

  function SkipRegionsClose: Boolean;
  var
    LSkipRegionItem: TBCEditorSkipRegionItem;
  begin
    Result := False;
    { Note! Check Close before Open because close and open keys might be same. }
    if (LOpenTokenSkipFoldRangeList.Count > 0) and
      CharInSet(LTextPtr^, FHighlighter.SkipCloseKeyChars) and not OddCountOfStringEscapeChars(LTextPtr) then
    begin
      LSkipRegionItem := LOpenTokenSkipFoldRangeList.Last;
      LKeyWordPtr := PChar(LSkipRegionItem.CloseToken);
      LBookmarkTextPtr := LTextPtr;
      { check if the close keyword found }
      while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and ((LTextPtr^ = LKeyWordPtr^) or
        (LSkipRegionItem.SkipEmptyChars and ((LTextPtr^ = BCEDITOR_SPACE_CHAR) or (LTextPtr^ = BCEDITOR_TAB_CHAR)) )) do
      begin
        if (LTextPtr^ <> BCEDITOR_SPACE_CHAR) and (LTextPtr^ <> BCEDITOR_TAB_CHAR) then
          Inc(LKeyWordPtr);
        Inc(LTextPtr);
      end;
      if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then { if found, pop skip region from the stack }
      begin
        LOpenTokenSkipFoldRangeList.Delete(LOpenTokenSkipFoldRangeList.Count - 1);
        Result := True;
      end
      else
        LTextPtr := LBookmarkTextPtr; { skip region close not found, return pointer back }
    end;
  end;

  function SkipRegionsOpen: Boolean;
  var
    i, j: Integer;
    LSkipRegionItem: TBCEditorSkipRegionItem;
  begin
    Result := False;
    if CharInSet(LTextPtr^, FHighlighter.SkipOpenKeyChars) then
      if LOpenTokenSkipFoldRangeList.Count = 0 then
      begin
        j := Highlighter.CodeFoldingRegions.SkipRegions.Count - 1;
        for i := 0 to j do
        begin
          LSkipRegionItem := Highlighter.CodeFoldingRegions.SkipRegions[i];
          if (LTextPtr^ = PChar(LSkipRegionItem.OpenToken)^) and not OddCountOfStringEscapeChars(LTextPtr) and
            not IsNextSkipChar(LTextPtr, LSkipRegionItem) then
          begin
            LKeyWordPtr := PChar(LSkipRegionItem.OpenToken);
            LBookmarkTextPtr := LTextPtr;
            { check if the open keyword found }
            while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and ((LTextPtr^ = LKeyWordPtr^) or
               (LSkipRegionItem.SkipEmptyChars and ((LTextPtr^ = BCEDITOR_SPACE_CHAR) or (LTextPtr^ = BCEDITOR_TAB_CHAR)) )) do
            begin
              if not LSkipRegionItem.SkipEmptyChars or
                (LSkipRegionItem.SkipEmptyChars and (LTextPtr^ <> BCEDITOR_SPACE_CHAR) and (LTextPtr^ <> BCEDITOR_TAB_CHAR)) then
                Inc(LKeyWordPtr);
              Inc(LTextPtr);
            end;
            if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then { if found, skip single line comment or push skip region into stack }
            begin
              if LSkipRegionItem.RegionType = ritSingleLineComment then
              { single line comment skip until next line }
                Exit(True)
              else
                LOpenTokenSkipFoldRangeList.Add(LSkipRegionItem);
              Dec(LTextPtr); { the end of the while loop will increase }
              Break;
            end
            else
              LTextPtr := LBookmarkTextPtr; { skip region open not found, return pointer back }
          end;
        end;
      end;
  end;

  function RegionItemsClose: Boolean;
  var
    i, j: Integer;
    LCodeFoldingRange: TBCEditorCodeFoldingRange;
    LRegionItem: TBCEditorCodeFoldingRegionItem;
  begin
    Result := False;
    if LOpenTokenFoldRangeList.Count > 0 then
      if (not IsValidChar(LTextPtr - 1) or LIsOneCharFolds {and not IsPreviousCharStringEscape(LTextPtr)} ) and CharInSet(UpCase(LTextPtr^), FHighlighter.FoldCloseKeyChars) then
      begin
        LCodeFoldingRange := TBCEditorCodeFoldingRange(LOpenTokenFoldRangeList.Last);
        if LCodeFoldingRange.RegionItem.CloseTokenBeginningOfLine and not LBeginningOfLine then
          Exit;
        LKeyWordPtr := PChar(LCodeFoldingRange.RegionItem.CloseToken);
        LBookmarkTextPtr := LTextPtr;
        { check if the close keyword found }
        while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
        begin
          Inc(LTextPtr);
          Inc(LKeyWordPtr);
        end;
        if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then { if found, pop skip region from the stack }
        begin
          if (TBCEditorCodeFoldingRange(LOpenTokenFoldRangeList.Last).RegionItem.CloseTokenLength = 1) or IsWholeWord(LBookmarkTextPtr - 1, LTextPtr) then { not interested in partial hits }
          begin
            LFoldRange := LOpenTokenFoldRangeList.Last;
            LOpenTokenFoldRangeList.Remove(LFoldRange);
            Dec(LFoldCount);

            if LFoldRange.RegionItem.BreakIfNotFoundBeforeNextRegion <> '' then
              if not LFoldRange.IsExtraTokenFound then
              begin
                LTextPtr := LBookmarkTextPtr;
                Exit(True);
              end;
            if LFoldRange.RegionItem.TokenEndIsPreviousLine then
              LFoldRange.ToLine := LLine
            else
              LFoldRange.ToLine := LLine + 1; { +1 for not 0-based }
            { Check if any shared close }
            if LOpenTokenFoldRangeList.Count > 0 then
            begin
              LCodeFoldingRange := LOpenTokenFoldRangeList.Last;
              if Assigned(LCodeFoldingRange.RegionItem) then
                if LCodeFoldingRange.RegionItem.SharedClose and
                  (LFoldRange.RegionItem.OpenToken <> LCodeFoldingRange.RegionItem.OpenToken) and
                  (LFoldRange.RegionItem.CloseToken = LCodeFoldingRange.RegionItem.CloseToken)then
                begin
                  if LFoldRange.RegionItem.TokenEndIsPreviousLine then
                    LCodeFoldingRange.ToLine := LLine
                  else
                    LCodeFoldingRange.ToLine := LLine + 1; { +1 for not 0-based }
                  LOpenTokenFoldRangeList.Remove(LCodeFoldingRange);
                  Dec(LFoldCount);
                end;
            end;
            { Check if the close token is one of the open tokens }
            LBookmarkTextPtr2 := LBookmarkTextPtr; { save Bookmark }
            LBookmarkTextPtr := LTextPtr; { set the Bookmark into current position }
            LTextPtr := LBookmarkTextPtr2; { go back to saved Bookmark }
            j := Highlighter.CodeFoldingRegions.Count - 1;
            for i := 0 to j do
            begin
              LRegionItem := Highlighter.CodeFoldingRegions[i];
              if LRegionItem.OpenIsClose then { optimizing... }
              begin
                if UpCase(LTextPtr^) = PChar(LRegionItem.OpenToken)^ then { if first character match }
                begin
                  LKeyWordPtr := PChar(LRegionItem.OpenToken);
                  { check if open keyword found }
                  while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
                  begin
                    Inc(LTextPtr);
                    Inc(LKeyWordPtr);
                  end;

                  if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then
                  begin
                    if (LRegionItem.OpenTokenLength = 1) or IsWholeWord(LBookmarkTextPtr2 - 1, LTextPtr) then { not interested in partial hits }
                    begin
                      if LOpenTokenFoldRangeList.Count > 0 then
                        LFoldRanges := TBCEditorCodeFoldingRange(LOpenTokenFoldRangeList.Last).SubCodeFoldingRanges
                      else
                        LFoldRanges := ATopFoldRanges;

                      LFoldRange := LFoldRanges.Add(ATopFoldRanges, LLine + 1, GetLineIndentChars(AStrings, LLine{ + 1}), LFoldCount,
                        LRegionItem, LLine + 1);
                      { open keyword found }
                      LOpenTokenFoldRangeList.Add(LFoldRange);
                      Inc(LFoldCount);
                      Break;
                    end
                    else
                      LTextPtr := LBookmarkTextPtr2; { skip region close not found, return pointer back }
                  end
                  else
                    LTextPtr := LBookmarkTextPtr2; { skip region close not found, return pointer back }
                end;
                LTextPtr := LBookmarkTextPtr; { go back where we were }
              end;
            end;
            LTextPtr := LBookmarkTextPtr; { go back where we were }
            Result := True;
          end
          else
            LTextPtr := LBookmarkTextPtr; { region close not found, return pointer back }
        end
        else
          LTextPtr := LBookmarkTextPtr; { region close not found, return pointer back }
      end;
  end;

  procedure RegionItemsOpen;
  var
    i, j: Integer;
    LSkipIfFoundAfterOpenToken: Boolean;
    LRegionItem: TBCEditorCodeFoldingRegionItem;
  begin
    if LOpenTokenSkipFoldRangeList.Count = 0 then
      if (not IsValidChar(LTextPtr - 1) or LIsOneCharFolds) and CharInSet(UpCase(LTextPtr^), FHighlighter.FoldOpenKeyChars) then
      begin
        LFoldRange := nil;
        if LOpenTokenFoldRangeList.Count > 0 then
          LFoldRange := LOpenTokenFoldRangeList.Last;
        if Assigned(LFoldRange) and LFoldRange.RegionItem.NoSubs then
          Exit;

        j := FHighlighter.CodeFoldingRegions.Count - 1;
        for i := 0 to j do
        begin
          LRegionItem := Highlighter.CodeFoldingRegions[i];
          if (LRegionItem.OpenTokenBeginningOfLine and LBeginningOfLine) or (not LRegionItem.OpenTokenBeginningOfLine) then
          begin
            { check if extra token found }
            if Assigned(LFoldRange) then
            begin
              if LFoldRange.RegionItem.BreakIfNotFoundBeforeNextRegion <> '' then
                if LTextPtr^ = PChar(LFoldRange.RegionItem.BreakIfNotFoundBeforeNextRegion)^ then { if first character match }
                begin
                  LKeyWordPtr := PChar(LFoldRange.RegionItem.BreakIfNotFoundBeforeNextRegion);
                  LBookmarkTextPtr := LTextPtr;
                  { check if open keyword found }
                  while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and
                    ((UpCase(LTextPtr^) = LKeyWordPtr^) or (LTextPtr^ = BCEDITOR_SPACE_CHAR) or (LTextPtr^ = BCEDITOR_TAB_CHAR)) do
                  begin
                    if ((LKeyWordPtr^ = BCEDITOR_SPACE_CHAR) or (LKeyWordPtr^ = BCEDITOR_TAB_CHAR)) or
                      (LTextPtr^ <> BCEDITOR_SPACE_CHAR) and (LTextPtr^ <> BCEDITOR_TAB_CHAR) then
                      Inc(LKeyWordPtr);
                    Inc(LTextPtr);
                  end;
                  if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then
                  begin
                    LFoldRange.IsExtraTokenFound := True;
                    Continue;
                  end
                  else
                    LTextPtr := LBookmarkTextPtr; { region not found, return pointer back }
                end;
            end;
            { First word after newline }
            if UpCase(LTextPtr^) = PChar(LRegionItem.OpenToken)^ then { if first character match }
            begin
              LKeyWordPtr := PChar(LRegionItem.OpenToken);
              LBookmarkTextPtr := LTextPtr;
              { check if open keyword found }
              while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
              begin
                Inc(LTextPtr);
                Inc(LKeyWordPtr);
              end;

              if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then
              begin
                if (LRegionItem.OpenTokenLength = 1) or IsWholeWord(LBookmarkTextPtr - 1, LTextPtr) then { not interested in partial hits }
                begin
                  { check if special rule found }
                  LSkipIfFoundAfterOpenToken := False;
                  if LRegionItem.SkipIfFoundAfterOpenToken <> '' then
                  begin
                    while LTextPtr^ <> BCEDITOR_NONE_CHAR do
                    begin
                      LKeyWordPtr := PChar(LRegionItem.SkipIfFoundAfterOpenToken);
                      LBookmarkTextPtr2 := LTextPtr;
                      if UpCase(LTextPtr^) = LKeyWordPtr^ then { if first character match }
                      begin
                        while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
                        begin
                          Inc(LTextPtr);
                          Inc(LKeyWordPtr);
                        end;
                        if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then
                        begin
                          LSkipIfFoundAfterOpenToken := True;
                          Break;
                        end
                        else
                          LTextPtr := LBookmarkTextPtr2; { region not found, return pointer back }
                      end;
                      Inc(LTextPtr);
                    end;
                  end;
                  if LSkipIfFoundAfterOpenToken then
                  begin
                    LTextPtr := LBookmarkTextPtr; { skip found, return pointer back }
                    Continue;
                  end;

                  if Assigned(LFoldRange) and (LFoldRange.RegionItem.BreakIfNotFoundBeforeNextRegion <> '') and not LFoldRange.IsExtraTokenFound then
                    LOpenTokenFoldRangeList.Remove(LOpenTokenFoldRangeList.Last);

                  if LOpenTokenFoldRangeList.Count > 0 then
                    LFoldRanges := TBCEditorCodeFoldingRange(LOpenTokenFoldRangeList.Last).SubCodeFoldingRanges
                  else
                    LFoldRanges := ATopFoldRanges;

                  LFoldRange := LFoldRanges.Add(ATopFoldRanges, LLine + 1, GetLineIndentChars(AStrings, LLine{ + 1}), LFoldCount,
                    LRegionItem, LLine + 1);
                  { open keyword found }
                  LOpenTokenFoldRangeList.Add(LFoldRange);
                  Inc(LFoldCount);
                  Dec(LTextPtr); { the end of the while loop will increase }
                  Break;
                end
                else
                  LTextPtr := LBookmarkTextPtr; { region not found, return pointer back }
              end
              else
                LTextPtr := LBookmarkTextPtr; { region not found, return pointer back }
            end;
          end;
        end;
      end;
  end;

var
  LRegionItem: TBCEditorCodeFoldingRegionItem;
begin
  LFoldCount := 0;
  LOpenTokenSkipFoldRangeList := TList.Create;
  LOpenTokenFoldRangeList := TList.Create;
  try
    LIsOneCharFolds := False;
    { Check if one char folds }
    LCount := Highlighter.CodeFoldingRegions.Count - 1;
    for LFold := 0 to LCount do
    begin
      LRegionItem := Highlighter.CodeFoldingRegions[LFold];
      if (LRegionItem.OpenTokenLength = 1) and (LRegionItem.CloseTokenLength = 1) then
      begin
        LIsOneCharFolds := True;
        Break;
      end;
    end;
    { Go through the text character by character }
    LCount := AStrings.Count - 1;
    for LLine := 0 to LCount do
    begin
      LTextPtr := PChar(AStrings[LLine]);
      LBeginningOfLine := True;
      while LTextPtr^ <> BCEDITOR_NONE_CHAR do
      begin
        SkipEmptySpace;
        if SkipRegionsClose then
          Continue; { while TextPtr^ <> BCEDITOR_NONE_CHAR do }
        if SkipRegionsOpen then
          Break; { line comment breaks }
        SkipEmptySpace;

        if LOpenTokenSkipFoldRangeList.Count = 0 then
        begin
          if RegionItemsClose then
            Continue; { while TextPtr^ <> BCEDITOR_NONE_CHAR do }
          RegionItemsOpen;
        end;

        if LTextPtr^ <> BCEDITOR_NONE_CHAR then
          Inc(LTextPtr);
        LBeginningOfLine := False; { not in the beginning of the line anymore }
      end;
    end;
    { Check the last not empty line }
    LLine := AStrings.Count - 1;
    while (LLine >= 0) and (Trim(AStrings[LLine]) = '') do
      Dec(LLine);
    if LLine >= 0 then
    begin
      LTextPtr := PChar(AStrings[LLine]);
      while LOpenTokenFoldRangeList.Count > 0 do
      begin
        LFoldRange := LOpenTokenFoldRangeList.Last;
        if Assigned(LFoldRange) then
        begin
          LFoldRange.ToLine := LLine + 1;
          LOpenTokenFoldRangeList.Remove(LFoldRange);
          Dec(LFoldCount);
          RegionItemsClose;
        end;
      end;
    end;
  finally
    LOpenTokenSkipFoldRangeList.Free;
    LOpenTokenFoldRangeList.Free;
  end;
end;

procedure TBCBaseEditor.ScrollChanged(Sender: TObject);
begin
  UpdateScrollBars;
  Invalidate;
end;

procedure TBCBaseEditor.ScrollTimerHandler(Sender: TObject);
var
  X, Y: Integer;
  LCursorPoint: TPoint;
  LDisplayPosition: TBCEditorDisplayPosition;
  LTextPosition: TBCEditorTextPosition;
begin
  Windows.GetCursorPos(LCursorPoint);
  LCursorPoint := ScreenToClient(LCursorPoint);
  LDisplayPosition := PixelsToRowColumn(LCursorPoint.X, LCursorPoint.Y);
  LDisplayPosition.Row := MinMax(LDisplayPosition.Row, 1, DisplayLineCount);
  if FScrollDeltaX <> 0 then
  begin
    LeftChar := LeftChar + FScrollDeltaX;
    X := LeftChar;
    LDisplayPosition.Column := X;
  end;
  if FScrollDeltaY <> 0 then
  begin
    if GetKeyState(VK_SHIFT) < 0 then
      TopLine := TopLine + FScrollDeltaY * VisibleLines
    else
      TopLine := TopLine + FScrollDeltaY;
    Y := TopLine;
    if FScrollDeltaY > 0 then
      Inc(Y, VisibleLines - 1);
    LDisplayPosition.Row := MinMax(Y, 1, DisplayLineCount);
  end;
  LTextPosition := DisplayToTextPosition(LDisplayPosition);
  if (CaretX <> LTextPosition.Char) or (CaretY <> LTextPosition.Line) then
  begin
    IncPaintLock;
    try
      InternalCaretPosition := LTextPosition;
      if MouseCapture then
        SetSelectionEndPosition(CaretPosition);
    finally
      DecPaintLock;
    end;
  end;
  ComputeScroll(LCursorPoint.X, LCursorPoint.Y);
end;

procedure TBCBaseEditor.SearchChanged(AEvent: TBCEditorSearchChanges);
begin
  if AEvent = scEngineUpdate then
    CaretZero;
  if AEvent = scSearch then
    if SelectionAvailable then
      CaretPosition := SelectionBeginPosition;

  case AEvent of
    scEngineUpdate:
      AssignSearchEngine;
    scSearch:
    begin
      FindAll; { for search map and search count }
      if Assigned(FSearchEngine) and FSearch.Enabled then
        FindNext;
    end;
  end;
  Invalidate;
end;

procedure TBCBaseEditor.SelectionChanged(Sender: TObject);
begin
  InvalidateSelection;
end;

procedure TBCBaseEditor.SetActiveLine(const Value: TBCEditorActiveLine);
begin
  FActiveLine.Assign(Value);
end;

procedure TBCBaseEditor.SetBackgroundColor(const Value: TColor);
begin
  if FBackgroundColor <> Value then
  begin
    FBackgroundColor := Value;
    Color := Value;
    Invalidate;
  end;
end;

procedure TBCBaseEditor.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TBCBaseEditor.SetCaretX(Value: Integer);
var
  LTextPosition: TBCEditorTextPosition;
begin
  LTextPosition.Char := Value;
  LTextPosition.Line := CaretY;
  SetCaretPosition(LTextPosition);
end;

procedure TBCBaseEditor.SetCaretY(Value: Integer);
var
  LTextPosition: TBCEditorTextPosition;
begin
  LTextPosition.Char := CaretX;
  LTextPosition.Line := Value;
  SetCaretPosition(LTextPosition);
end;

procedure TBCBaseEditor.SetClipboardText(const AText: string);
var
  LGlobalMem: HGLOBAL;
  LPGlobalLock: PByte;
  LLength: Integer;
begin
  if AText = '' then
    Exit;
  LLength := Length(AText);
  Clipboard.open;
  try
    Clipboard.Clear;

    { set ANSI text only on Win9X, WinNT automatically creates ANSI from Unicode }
    if Win32Platform <> VER_PLATFORM_WIN32_NT then
    begin
      LGlobalMem := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, LLength + 1);
      if LGlobalMem <> 0 then
      begin
        LPGlobalLock := GlobalLock(LGlobalMem);
        try
          if Assigned(LPGlobalLock) then
          begin
            Move(PAnsiChar(AnsiString(AText))^, LPGlobalLock^, LLength + 1);
            Clipboard.SetAsHandle(CF_TEXT, LGlobalMem);
          end;
        finally
          GlobalUnlock(LGlobalMem);
        end;
      end;
    end;
    { Set unicode text, this also works on Win9X, even if the clipboard-viewer
      can't show it, Word 2000+ can paste it including the unicode only characters }
    LGlobalMem := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, (LLength + 1) * SizeOf(Char));
    if LGlobalMem <> 0 then
    begin
      LPGlobalLock := GlobalLock(LGlobalMem);
      try
        if Assigned(LPGlobalLock) then
        begin
          Move(PChar(AText)^, LPGlobalLock^, (LLength + 1) * SizeOf(Char));
          Clipboard.SetAsHandle(CF_UNICODETEXT, LGlobalMem);
        end;
      finally
        GlobalUnlock(LGlobalMem);
      end;
    end;
    { Don't free Mem! It belongs to the clipboard now, and it will free it
      when it is done with it. }
  finally
    Clipboard.Close;
  end;
end;

procedure TBCBaseEditor.SetCodeFolding(Value: TBCEditorCodeFolding);
begin
  FCodeFolding.Assign(Value);
  if Value.Visible then
    InitCodeFolding;
end;

procedure TBCBaseEditor.SetDefaultKeyCommands;
begin
  FKeyCommands.ResetDefaults;
end;

procedure TBCBaseEditor.SetInsertMode(const Value: Boolean);
begin
  if FInsertMode <> Value then
  begin
    FInsertMode := Value;
    if not (csDesigning in ComponentState) then
      ResetCaret;
  end;
end;

procedure TBCBaseEditor.SetInternalCaretX(Value: Integer);
var
  LTextPosition: TBCEditorTextPosition;
begin
  LTextPosition.Char := Value;
  LTextPosition.Line := CaretY;
  SetInternalCaretPosition(LTextPosition);
end;

procedure TBCBaseEditor.SetInternalCaretY(Value: Integer);
var
  LTextPosition: TBCEditorTextPosition;
begin
  LTextPosition.Char := CaretX;
  LTextPosition.Line := Value;
  SetInternalCaretPosition(LTextPosition);
end;

procedure TBCBaseEditor.SetInternalDisplayPosition(const ADisplayPosition: TBCEditorDisplayPosition);
begin
  IncPaintLock;
  InternalCaretPosition := DisplayToTextPosition(ADisplayPosition);
  FCaretAtEndOfLine := GetWordWrap and (ADisplayPosition.Row <= FWordWrapHelper.GetRowCount) and
    (ADisplayPosition.Column > FWordWrapHelper.GetRowLength(ADisplayPosition.Row)) and (DisplayY <> ADisplayPosition.Row);
  DecPaintLock;
end;

procedure TBCBaseEditor.SetKeyCommands(const Value: TBCEditorKeyCommands);
begin
  if not Assigned(Value) then
    FKeyCommands.Clear
  else
    FKeyCommands.Assign(Value);
end;

procedure TBCBaseEditor.SetLeftChar(Value: Integer);
var
  LMaxLineWidth: Integer;
  LDelta: Integer;
  LTextAreaRect: TRect;
begin
  if GetWordWrap and (GetWrapAtColumn <= CharsInWindow) then
    Value := 1;

  if soPastEndOfLine in FScroll.Options then
  begin
    if soAutoSizeMaxWidth in FScroll.Options then
      LMaxLineWidth := MaxInt - CharsInWindow
    else
      LMaxLineWidth := FScroll.MaxWidth - CharsInWindow + 1
  end
  else
  begin
    if GetWordWrap then
      LMaxLineWidth := GetWrapAtColumn
    else
      LMaxLineWidth := FLines.GetLengthOfLongestLine{(RowToLine(FTopLine), RowToLine(FTopLine + FVisibleLines))};
    if LMaxLineWidth > CharsInWindow then
      LMaxLineWidth := LMaxLineWidth - CharsInWindow + 1
    else
      LMaxLineWidth := 1;
  end;
  Value := MinMax(Value, 1, LMaxLineWidth);
  if Value <> FLeftChar then
  begin
    LDelta := FLeftChar - Value;
    FLeftChar := Value;
    FTextOffset := FLeftMargin.GetWidth + FCodeFolding.GetWidth + 2 - (LeftChar - 1) * FCharWidth;
    if Abs(LDelta) < CharsInWindow then
    begin
      LTextAreaRect := ClientRect;
      if FLeftMargin.Visible then
        LTextAreaRect.Left := LTextAreaRect.Left + FLeftMargin.GetWidth + FCodeFolding.GetWidth;
      DeflateMinimapRect(LTextAreaRect);
      ScrollWindow(Handle, LDelta * CharWidth, 0, @LTextAreaRect, @LTextAreaRect);
    end
    else
      InvalidateLines(-1, -1);
    if ((soAutosizeMaxWidth in FScroll.Options) or (soPastEndOfLine in FScroll.Options)) and (FScroll.MaxWidth < LeftChar + CharsInWindow) then
      FScroll.MaxWidth := LeftChar + CharsInWindow - 1
    else
      UpdateScrollBars;
    InvalidateLines(DisplayY, DisplayY);
  end;
end;

procedure TBCBaseEditor.SetLeftMargin(const Value: TBCEditorLeftMargin);
begin
  FLeftMargin.Assign(Value);
end;

procedure TBCBaseEditor.SetLeftMarginWidth(Value: Integer);
begin
  Value := Max(Value, 0);
  if FLeftMargin.Width <> Value then
  begin
    FLeftMargin.Width := Value;
    FTextOffset := FLeftMargin.GetWidth + FCodeFolding.GetWidth + 2 - (LeftChar - 1) * FCharWidth;
    if HandleAllocated then
    begin
      FCharsInWindow := Max(ClientWidth - FLeftMargin.GetWidth - FCodeFolding.GetWidth - 2, 0) div FCharWidth;
      if GetWordWrap and (FWordWrap.Style = wwsclientWidth) then
        FWordWrapHelper.DisplayChanged;
      UpdateScrollBars;
      Invalidate;
    end;
  end;
end;

procedure TBCBaseEditor.SetLines(Value: TBCEditorLines);
begin
  ClearBookmarks;
  FLines.Assign(Value);
  SizeOrFontChanged(True);
end;

procedure TBCBaseEditor.SetLineText(Value: string);
begin
  if (CaretY >= 1) and (CaretY <= Max(1, FLines.Count)) then
    FLines[CaretY - 1] := Value;
end;

procedure TBCBaseEditor.SetModified(Value: Boolean);
var
  i: Integer;
begin
  if Value <> FModified then
  begin
    FModified := Value;
    if (uoGroupUndo in FUndo.Options) and (not Value) and UndoList.CanUndo then
      UndoList.AddGroupBreak;
    UndoList.InitialState := not Value;
    if not FModified then
    begin
      for i := 0 to FLines.Count - 1 do
        if FLines.Attributes[i].LineState = lsModified then
          FLines.Attributes[i].LineState := lsNormal;
      InvalidateLeftMargin;
    end;
  end;
end;

procedure TBCBaseEditor.SetOptions(Value: TBCEditorOptions);
begin
  if Value <> FOptions then
  begin
    FOptions := Value;

    if (eoDropFiles in FOptions) <> (eoDropFiles in Value) and not (csDesigning in ComponentState) and HandleAllocated then
      DragAcceptFiles(Handle, eoDropFiles in FOptions);

    Invalidate;
  end;
end;

procedure TBCBaseEditor.SetRightMargin(const Value: TBCEditorRightMargin);
begin
  FRightMargin.Assign(Value);
end;

procedure TBCBaseEditor.SetScroll(const Value: TBCEditorScroll);
begin
  FScroll.Assign(Value);
end;

procedure TBCBaseEditor.SetSearch(const Value: TBCEditorSearch);
begin
  FSearch.Assign(Value);
end;

procedure TBCBaseEditor.SetSelectedText(const Value: string);
var
  LBlockStartPosition, LBlockEndPosition: TBCEditorTextPosition;
begin
  BeginUndoBlock;
  try
    if SelectionAvailable then
      FUndoList.AddChange(crDelete, FSelectionBeginPosition, FSelectionEndPosition, GetSelectedText, FSelection.ActiveMode)
    else
      FSelection.ActiveMode := FSelection.Mode;

    LBlockStartPosition := SelectionBeginPosition;
    LBlockEndPosition := SelectionEndPosition;
    FSelectionBeginPosition := LBlockStartPosition;
    FSelectionEndPosition := LBlockEndPosition;
    SetSelectedTextPrimitive(Value);

    if (Value <> '') and (FSelection.ActiveMode <> smColumn) then
      FUndoList.AddChange(crInsert, LBlockStartPosition, SelectionEndPosition, '', FSelection.ActiveMode);
  finally
    EndUndoBlock;
  end;
end;

procedure TBCBaseEditor.SetSelectedWord;
begin
  SetWordBlock(CaretPosition);
end;

procedure TBCBaseEditor.SetSelection(const Value: TBCEditorSelection);
begin
  FSelection.Assign(Value);
end;

procedure TBCBaseEditor.SetSelectionBeginPosition(Value: TBCEditorTextPosition);
var
  LFirstLine, LLastLine: Integer;
begin
  FSelection.ActiveMode := Selection.Mode;
  if (soPastEndOfLine in FScroll.Options) and not GetWordWrap then
    Value.Char := MinMax(Value.Char, 1, FScroll.MaxWidth + 1)
  else
    Value.Char := Max(Value.Char, 1);
  Value.Line := MinMax(Value.Line, 1, FLines.Count);
  if FSelection.ActiveMode = smNormal then
    if (Value.Line >= 1) and (Value.Line <= FLines.Count) then
      Value.Char := Min(Value.Char, Length(Lines[Value.Line - 1]) + 1)
    else
      Value.Char := 1;

  if SelectionAvailable then
  begin
    if FSelectionBeginPosition.Line < FSelectionEndPosition.Line then
    begin
      LFirstLine := Min(Value.Line, FSelectionBeginPosition.Line);
      LLastLine := Max(Value.Line, FSelectionEndPosition.Line);
    end
    else
    begin
      LFirstLine := Min(Value.Line, FSelectionEndPosition.Line);
      LLastLine := Max(Value.Line, FSelectionBeginPosition.Line);
    end;
    FSelectionBeginPosition := Value;
    FSelectionEndPosition := Value;
    InvalidateLines(LFirstLine, LLastLine);
    if FMinimap.Visible then
      InvalidateMinimap;
  end
  else
  begin
    FSelectionBeginPosition := Value;
    FSelectionEndPosition := Value;
  end;
end;

procedure TBCBaseEditor.SetSelectionEndPosition(Value: TBCEditorTextPosition);
var
  LCurrentLine: Integer;
begin
  FSelection.ActiveMode := Selection.Mode;
  if FSelection.Visible then
  begin
    if (soPastEndOfLine in FScroll.Options) and not GetWordWrap then
      Value.Char := MinMax(Value.Char, 1, FScroll.MaxWidth + 1)
    else
      Value.Char := Max(Value.Char, 1);
    Value.Line := MinMax(Value.Line, 1, FLines.Count);
    if FSelection.ActiveMode = smNormal then
    begin
      if (Value.Line >= 1) and (Value.Line <= FLines.Count) then
        Value.Char := Min(Value.Char, Length(Lines[Value.Line - 1]) + 1)
      else
        Value.Char := 1;
    end;
    if (Value.Char <> FSelectionEndPosition.Char) or (Value.Line <> FSelectionEndPosition.Line) then
    begin
      if (FSelection.ActiveMode = smColumn) and (Value.Char <> FSelectionEndPosition.Char) then
      begin
        InvalidateLines(Min(FSelectionBeginPosition.Line, Min(FSelectionEndPosition.Line, Value.Line)),
          Max(FSelectionBeginPosition.Line, Max(FSelectionEndPosition.Line, Value.Line)));
        FSelectionEndPosition := Value;
      end
      else
      begin
        LCurrentLine := FSelectionEndPosition.Line;
        FSelectionEndPosition := Value;
        if (FSelection.ActiveMode <> smColumn) or (FSelectionBeginPosition.Char <> FSelectionEndPosition.Char) then
          InvalidateLines(LCurrentLine, FSelectionEndPosition.Line);
      end;
    end;
    if Assigned(FOnSelectionChanged) then
      FOnSelectionChanged(Self);
  end;
end;

procedure TBCBaseEditor.SetSpecialChars(const Value: TBCEditorSpecialChars);
begin
  FSpecialChars.Assign(Value);
end;

procedure TBCBaseEditor.SetTabs(const Value: TBCEditorTabs);
begin
  FTabs.Assign(Value);
end;

procedure TBCBaseEditor.SetText(const Value: string);
begin
  IncPaintLock;
  BeginUndoBlock;
  SelectAll;
  SelectedText := Value;
  EndUndoBlock;
  DecPaintLock;
end;

procedure TBCBaseEditor.SetTopLine(Value: Integer);
var
  LDelta: Integer;
  LClientRect: TRect;
  LDisplayLineCount: Integer;
begin
  LDisplayLineCount := GetDisplayLineCount;
  if LDisplayLineCount = 0 then
    LDisplayLineCount := 1;

  if (soPastEndOfFileMarker in FScroll.Options) and
    (not (sfInSelection in FStateFlags) or (sfInSelection in FStateFlags) and (Value = FTopLine)) then
    Value := Min(Value, LDisplayLineCount)
  else
    Value := Min(Value, LDisplayLineCount - FVisibleLines + 1);

  Value := Max(Value, 1);
  if Value <> TopLine then
  begin
    LDelta := TopLine - Value;
    FTopLine := Value;
    if FMinimap.Visible and not FMinimap.Dragging then
      FMinimap.TopLine := Max(FTopLine - Abs(Trunc((FMinimap.VisibleLines - FVisibleLines) * (FTopLine / LDisplayLineCount))), 1);
    LClientRect := ClientRect;
    DeflateMinimapRect(LClientRect);
    if Abs(LDelta) < FVisibleLines then
      ScrollWindow(Handle, 0, LineHeight * LDelta, @LClientRect, @LClientRect)
    else
      Invalidate;
    UpdateScrollBars;
  end;
end;

procedure TBCBaseEditor.SetUndo(const Value: TBCEditorUndo);
begin
  FUndo.Assign(Value);
end;

procedure TBCBaseEditor.SetWordBlock(ATextPosition: TBCEditorTextPosition);
var
  LBlockBeginPosition: TBCEditorTextPosition;
  LBlockEndPosition: TBCEditorTextPosition;
  LTempString: string;

  procedure CharScan;
  var
    i: Integer;
  begin
    LBlockEndPosition.Char := Length(LTempString);
    for i := ATextPosition.Char to Length(LTempString) do
      if IsWordBreakChar(LTempString[i]) then
      begin
        LBlockEndPosition.Char := i;
        Break;
      end;
    LBlockBeginPosition.Char := 1;
    for i := ATextPosition.Char - 1 downto 1 do
      if IsWordBreakChar(LTempString[i]) then
      begin
        LBlockBeginPosition.Char := i + 1;
        Break;
      end;
  end;

begin
  if (soPastEndOfLine in FScroll.Options) and not GetWordWrap then
    ATextPosition.Char := MinMax(ATextPosition.Char, 1, FScroll.MaxWidth + 1)
  else
    ATextPosition.Char := Max(ATextPosition.Char, 1);
  ATextPosition.Line := MinMax(ATextPosition.Line, 1, FLines.Count);
  LTempString := FLines[ATextPosition.Line - 1] + BCEDITOR_NONE_CHAR;

  if ATextPosition.Char > Length(LTempString) then
  begin
    InternalCaretPosition := GetTextPosition(Length(LTempString), ATextPosition.Line);
    Exit;
  end;

  CharScan;

  LBlockBeginPosition.Line := ATextPosition.Line;
  LBlockEndPosition.Line := ATextPosition.Line;
  SetCaretAndSelection(LBlockEndPosition, LBlockBeginPosition, LBlockEndPosition);
  InvalidateLine(ATextPosition.Line);
end;

procedure TBCBaseEditor.SetWordWrap(const Value: TBCEditorWordWrap);
begin
  FWordWrap.Assign(Value);
end;

procedure TBCBaseEditor.SizeOrFontChanged(const FontChanged: Boolean);
begin
  if HandleAllocated and (FCharWidth <> 0) then
  begin
    FCharsInWindow := Max(ClientWidth - FLeftMargin.GetWidth - FCodeFolding.GetWidth - 2 - FMinimap.GetWidth -
      FSearch.Map.GetWidth, 0) div FCharWidth;
    FVisibleLines := ClientHeight div LineHeight;

    if GetWordWrap then
    begin
      FWordWrapHelper.DisplayChanged;
      Invalidate;
    end;
    if FontChanged then
    begin
      if LeftMargin.LineNumbers.Visible then
        LeftMarginChanged(Self)
      else
        UpdateScrollBars;
      ResetCaret;
      Exclude(FStateFlags, sfCaretChanged);
      Invalidate;
    end
    else
      UpdateScrollBars;

    Exclude(FStateFlags, sfScrollbarChanged);
    if not (soPastEndOfLine in FScroll.Options) then
      LeftChar := LeftChar;
    if not (soPastEndOfFileMarker in FScroll.Options) then
      TopLine := TopLine;
  end;
end;

procedure TBCBaseEditor.SpecialCharsChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TBCBaseEditor.SwapInt(var ALeft, ARight: Integer);
var
  LTemp: Integer;
begin
  LTemp := ARight;
  ARight := ALeft;
  ALeft := LTemp;
end;

procedure TBCBaseEditor.TabsChanged(Sender: TObject);
begin
  FLines.TabWidth := FTabs.Width;
  Invalidate;
  if GetWordWrap then
  begin
    FWordWrapHelper.Reset;
    InvalidateLeftMargin;
  end;
end;

procedure TBCBaseEditor.UndoChanged(Sender: TObject);
begin
  FUndoList.MaxUndoActions := FUndo.MaxActions;
  FRedoList.MaxUndoActions := FUndo.MaxActions;
end;

procedure TBCBaseEditor.UndoRedoAdded(Sender: TObject);
var
 LUndoItem: TBCEditorUndoItem;
begin
  LUndoItem := nil;
  if Sender = FUndoList then
    LUndoItem := FUndoList.PeekItem;

  UpdateModifiedStatus;

  if not FUndoList.InsideRedo and Assigned(LUndoItem) and (LUndoItem.ChangeReason <> crGroupBreak) then
    FRedoList.Clear;

  if TBCEditorUndoList(Sender).BlockCount = 0 then
    DoChange;
end;

procedure TBCBaseEditor.UpdateFoldRanges(ACurrentLine, ALineCount: Integer);
var
  i, LPosition: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if not LCodeFoldingRange.ParentCollapsed then
    begin
      if LCodeFoldingRange.FromLine > ACurrentLine then
      begin
        LCodeFoldingRange.MoveBy(ALineCount);

        if LCodeFoldingRange.Collapsed then
          UpdateFoldRanges(LCodeFoldingRange.SubCodeFoldingRanges, ALineCount);

        Continue;
      end
      else
      if LCodeFoldingRange.FromLine = ACurrentLine then
      begin
        LPosition := Pos(LCodeFoldingRange.RegionItem.OpenToken, UpperCase(Lines[LCodeFoldingRange.FromLine]));

        if LPosition > 0 then
        begin
          LCodeFoldingRange.MoveBy(ALineCount);
          Continue;
        end;
      end;

      if not LCodeFoldingRange.Collapsed then
      begin
        if LCodeFoldingRange.ToLine > ACurrentLine then
          LCodeFoldingRange.Widen(ALineCount)
        else
        if LCodeFoldingRange.ToLine = ACurrentLine then
        begin
          LPosition := Pos(LCodeFoldingRange.RegionItem.CloseToken, UpperCase(Lines[LCodeFoldingRange.ToLine]));

          if LPosition > 0 then
            LCodeFoldingRange.Widen(ALineCount);
        end;
      end;
    end;
  end;
end;

procedure TBCBaseEditor.UpdateFoldRanges(AFoldRanges: TBCEditorCodeFoldingRanges; ALineCount: Integer);
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  if Assigned(AFoldRanges) then
  for i := 0 to AFoldRanges.Count - 1 do
  begin
    LCodeFoldingRange := AFoldRanges[i];
    UpdateFoldRanges(LCodeFoldingRange.SubCodeFoldingRanges, ALineCount);
    LCodeFoldingRange.MoveBy(ALineCount);
  end;
end;

procedure TBCBaseEditor.UpdateWordWrapHiddenOffsets;
begin
  if GetWordWrap then
    FWordWrapHelper.LinesFolded(-1, -1);
end;

procedure TBCBaseEditor.UpdateModifiedStatus;
begin
  Modified := not UndoList.InitialState;
end;

procedure TBCBaseEditor.UpdateScrollBars;
var
  LMaxScroll: Integer;
  LScrollInfo: TScrollInfo;
  LRightChar: Integer;

  procedure UpdateVerticalScrollBar;
  begin
    if FScroll.Bars in [ssBoth, ssVertical] then
    begin
      LMaxScroll := DisplayLineCount;

      if soPastEndOfFileMarker in FScroll.Options then
        Inc(LMaxScroll, VisibleLines - 1);

      if LMaxScroll <= BCEDITOR_MAX_SCROLL_RANGE then
      begin
        LScrollInfo.nMin := 1;
        LScrollInfo.nMax := Max(1, LMaxScroll);
        LScrollInfo.nPage := VisibleLines;
        LScrollInfo.nPos := TopLine;
      end
      else
      begin
        LScrollInfo.nMin := 1;
        LScrollInfo.nMax := BCEDITOR_MAX_SCROLL_RANGE;
        LScrollInfo.nPage := MulDiv(BCEDITOR_MAX_SCROLL_RANGE, VisibleLines, LMaxScroll);
        LScrollInfo.nPos := MulDiv(BCEDITOR_MAX_SCROLL_RANGE, TopLine, LMaxScroll);
      end;

      ShowScrollBar(Handle, SB_VERT, (LScrollInfo.nMin = 0) or (LScrollInfo.nMax > VisibleLines));
      SetScrollInfo(Handle, SB_VERT, LScrollInfo, True);

      if LMaxScroll <= VisibleLines then
      begin
        if (TopLine <= 1) and (LMaxScroll <= VisibleLines) then
          EnableScrollBar(Handle, SB_VERT, ESB_DISABLE_BOTH)
        else
        begin
          EnableScrollBar(Handle, SB_VERT, ESB_ENABLE_BOTH);
          if TopLine <= 1 then
            EnableScrollBar(Handle, SB_VERT, ESB_DISABLE_UP)
          else
          if DisplayLineCount - TopLine - VisibleLines + 1 = 0 then
            EnableScrollBar(Handle, SB_VERT, ESB_DISABLE_DOWN);
        end;
      end
      else
        EnableScrollBar(Handle, SB_VERT, ESB_ENABLE_BOTH);

      if Visible then
        SendMessage(Handle, WM_SETREDRAW, -1, 0);
      if FPaintLock = 0 then
        Invalidate;
    end
    else
      ShowScrollBar(Handle, SB_VERT, False);
  end;

  procedure UpdateHorizontalScrollBar;
  begin
    if (FScroll.Bars in [ssBoth, ssHorizontal]) and
      (not GetWordWrap or (GetWordWrap and (GetWrapAtColumn > CharsInWindow))) then
    begin
      if soPastEndOfLine in FScroll.Options then
        LMaxScroll := FScroll.MaxWidth
      else
      if GetWordWrap then
        LMaxScroll := GetWrapAtColumn
      else
        LMaxScroll := Max(FLines.GetLengthOfLongestLine{(RowToLine(FTopLine), RowToLine(FTopLine + FVisibleLines))}, 1);
      if LMaxScroll <= BCEDITOR_MAX_SCROLL_RANGE then
      begin
        LScrollInfo.nMin := 1;
        LScrollInfo.nMax := LMaxScroll;
        LScrollInfo.nPage := CharsInWindow;
        LScrollInfo.nPos := LeftChar;
      end
      else
      begin
        LScrollInfo.nMin := 0;
        LScrollInfo.nMax := BCEDITOR_MAX_SCROLL_RANGE;
        LScrollInfo.nPage := MulDiv(BCEDITOR_MAX_SCROLL_RANGE, CharsInWindow, LMaxScroll);
        LScrollInfo.nPos := MulDiv(BCEDITOR_MAX_SCROLL_RANGE, LeftChar, LMaxScroll);
      end;

      ShowScrollBar(Handle, SB_HORZ, (LScrollInfo.nMin = 0) or (LScrollInfo.nMax > CharsInWindow));
      SetScrollInfo(Handle, SB_HORZ, LScrollInfo, True);

      if LMaxScroll <= CharsInWindow then
      begin
        LRightChar := LeftChar + CharsInWindow - 1;
        if (LeftChar <= 1) and (LRightChar >= LMaxScroll) then
          EnableScrollBar(Handle, SB_HORZ, ESB_DISABLE_BOTH)
        else
        begin
          EnableScrollBar(Handle, SB_HORZ, ESB_ENABLE_BOTH);
          if (LeftChar <= 1) then
            EnableScrollBar(Handle, SB_HORZ, ESB_DISABLE_LEFT)
          else
          if LRightChar >= LMaxScroll then
            EnableScrollBar(Handle, SB_HORZ, ESB_DISABLE_RIGHT)
        end;
      end
      else
        EnableScrollBar(Handle, SB_HORZ, ESB_ENABLE_BOTH);
    end
    else
      ShowScrollBar(Handle, SB_HORZ, False);
  end;

begin
  if not HandleAllocated or (PaintLock <> 0) then
    Include(FStateFlags, sfScrollbarChanged)
  else
  begin
    Exclude(FStateFlags, sfScrollbarChanged);
    if FScroll.Bars <> ssNone then
    begin
      LScrollInfo.cbSize := SizeOf(ScrollInfo);
      LScrollInfo.fMask := SIF_ALL;
      LScrollInfo.fMask := LScrollInfo.fMask or SIF_DISABLENOSCROLL;

      if Visible then
        SendMessage(Handle, WM_SETREDRAW, 0, 0);

      UpdateHorizontalScrollBar;
      UpdateVerticalScrollBar;
    end
    else
      ShowScrollBar(Handle, SB_BOTH, False);
    {$IFDEF USE_VCL_STYLES}
    Perform(CM_UPDATE_VCLSTYLE_SCROLLBARS, 0, 0);
    {$ENDIF}
  end;
end;

procedure TBCBaseEditor.UpdateWordWrap(const Value: Boolean);
var
  LOldTopLine: Integer;
  LShowCaret: Boolean;
begin
  if GetWordWrap <> Value then
  begin
    Invalidate;
    LShowCaret := CaretInView;
    LOldTopLine := RowToLine(TopLine);
    if Value then
    begin
      FWordWrapHelper := TBCEditorWordWrapHelper.Create(Self);
      LeftChar := 1;
      if FWordWrap.Style = wwsRightMargin then
        FRightMargin.Visible := True;
    end
    else
    begin
      FWordWrapHelper.Free;
      FWordWrapHelper := nil;
    end;
    TopLine := LineToRow(LOldTopLine);
    UpdateScrollBars;

    if soPastEndOfLine in FScroll.Options then
    begin
      InternalCaretPosition := CaretPosition;
      SetSelectionBeginPosition(SelectionBeginPosition);
      SetSelectionEndPosition(SelectionEndPosition);
    end;
    if LShowCaret then
      EnsureCursorPositionVisible;
  end;
end;

procedure TBCBaseEditor.WMCaptureChanged(var Msg: TMessage);
begin
  FScrollTimer.Enabled := False;
  inherited;
end;

procedure TBCBaseEditor.WMChar(var Msg: TWMChar);
begin
  DoKeyPressW(Msg);
end;

procedure TBCBaseEditor.WMClear(var Msg: TMessage);
begin
  if not ReadOnly then
    SelectedText := '';
end;

procedure TBCBaseEditor.WMCopy(var Message: TMessage);
begin
  CopyToClipboard;
  message.Result := Ord(True);
end;

procedure TBCBaseEditor.WMCut(var Message: TMessage);
begin
  if not ReadOnly then
    CutToClipboard;
  message.Result := Ord(True);
end;

procedure TBCBaseEditor.WMDropFiles(var Msg: TMessage);
var
  i, LNumberDropped: Integer;
  LFileName: array [0 .. MAX_PATH - 1] of Char;
  LPoint: TPoint;
  LFilesList: TStringList;
begin
  try
    if Assigned(FOnDropFiles) then
    begin
      LFilesList := TStringList.Create;
      try
        LNumberDropped := DragQueryFile(THandle(Msg.wParam), Cardinal(-1), nil, 0);
        DragQueryPoint(THandle(Msg.wParam), LPoint);
        for i := 0 to LNumberDropped - 1 do
        begin
          DragQueryFileW(THandle(Msg.wParam), i, LFileName, SizeOf(LFileName) div 2);
          LFilesList.Add(LFileName)
        end;
        FOnDropFiles(Self, LPoint.X, LPoint.Y, LFilesList);
      finally
        LFilesList.Free;
      end;
    end;
  finally
    Msg.Result := 0;
    DragFinish(THandle(Msg.wParam));
  end;
end;

procedure TBCBaseEditor.WMEraseBkgnd(var Msg: TMessage);
begin
  Msg.Result := -1;
end;

procedure TBCBaseEditor.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  inherited;
  Msg.Result := Msg.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
  if FTabs.WantTabs then
    Msg.Result := Msg.Result or DLGC_WANTTAB;
  if FWantReturns then
    Msg.Result := Msg.Result or DLGC_WANTALLKEYS;
end;

procedure TBCBaseEditor.WMGetText(var Msg: TWMGetText);
begin
  StrLCopy(PChar(Msg.Text), PChar(Text), Msg.TextMax - 1);
  Msg.Result := StrLen(PChar(Msg.Text));
end;

procedure TBCBaseEditor.WMGetTextLength(var Msg: TWMGetTextLength);
begin
  if csDocking in ControlState then
    Msg.Result := 0
  else
    Msg.Result := Length(Text);
end;

procedure TBCBaseEditor.WMHScroll(var Msg: TWMScroll);
var
  LMaxWidth: Integer;
begin
  Msg.Result := 0;

  inherited;

  case Msg.ScrollCode of
    { Scrolls to start / end of the line }
    SB_LEFT:
      LeftChar := 1;
    SB_RIGHT:
      begin
        if soPastEndOfLine in FScroll.Options then
          LeftChar := FScroll.MaxWidth - CharsInWindow + 1
        else
          { Simply set LeftChar property to the LengthOfLongestLine,
            it would do the range checking and constrain the value if necessary }
          LeftChar := FLines.GetLengthOfLongestLine{(RowToLine(FTopLine), RowToLine(FTopLine + FVisibleLines))};
      end;
    { Scrolls one char left / right }
    SB_LINERIGHT:
      LeftChar := LeftChar + 1;
    SB_LINELEFT:
      LeftChar := LeftChar - 1;
    { Scrolls one page of chars left / right }
    SB_PAGERIGHT:
      LeftChar := LeftChar + FCharsInWindow;
    SB_PAGELEFT:
      LeftChar := LeftChar - FCharsInWindow;
    { Scrolls to the current scroll bar position }
    SB_THUMBPOSITION, SB_THUMBTRACK:
      begin
        FIsScrolling := True;
        if soPastEndOfLine in FScroll.Options then
          LMaxWidth := FScroll.MaxWidth
        else
          LMaxWidth := Max(FLines.GetLengthOfLongestLine{(RowToLine(FTopLine), RowToLine(TopLine + VisibleLines))}, 1);
        if LMaxWidth > BCEDITOR_MAX_SCROLL_RANGE then
          LeftChar := MulDiv(LMaxWidth, Msg.Pos, BCEDITOR_MAX_SCROLL_RANGE)
        else
          LeftChar := Msg.Pos;
      end;
    SB_ENDSCROLL:
      FIsScrolling := False;
  end;
  Update;
  if Assigned(OnScroll) then
    OnScroll(Self, sbHorizontal);
end;

procedure TBCBaseEditor.WMIMEChar(var Msg: TMessage);
begin
  { Do nothing here, the IME string is retrieved in WMIMEComposition
    Handling the WM_IME_CHAR message stops Windows from sending WM_CHAR messages while using the IME }
end;

function IsWindows98orLater: Boolean;
begin
  Result := (Win32MajorVersion > 4) or (Win32MajorVersion = 4) and (Win32MinorVersion > 0);
end;

procedure TBCBaseEditor.WMIMEComposition(var Msg: TMessage);
var
  LImc: HIMC;
  LPBuffer: PChar;
  LPAnsiBuffer: PAnsiChar;
  LPBufferLength: Integer;
  LImeCount: Integer;
begin
  if (Msg.LParam and GCS_RESULTSTR) <> 0 then
  begin
    LImc := ImmGetContext(Handle);
    try
      if IsWindows98orLater then
      begin
        LImeCount := ImmGetCompositionStringW(LImc, GCS_RESULTSTR, nil, 0);
        { ImeCount is always the size in bytes, also for Unicode }
        GetMem(LPBuffer, LImeCount + SizeOf(Char));
        try
          ImmGetCompositionStringW(LImc, GCS_RESULTSTR, LPBuffer, LImeCount);
          LPBuffer[LImeCount div SizeOf(Char)] := BCEDITOR_NONE_CHAR;
          CommandProcessor(ecImeStr, BCEDITOR_NONE_CHAR, LPBuffer);
        finally
          FreeMem(LPBuffer);
        end;
      end
      else
      begin
        LImeCount := ImmGetCompositionStringA(LImc, GCS_RESULTSTR, nil, 0);
        { ImeCount is always the size in bytes, also for Unicode }
        GetMem(LPAnsiBuffer, LImeCount + SizeOf(AnsiChar));
        try
          ImmGetCompositionStringA(LImc, GCS_RESULTSTR, LPAnsiBuffer, LImeCount);
          LPAnsiBuffer[LImeCount] := BCEDITOR_NONE_CHAR;

          LPBufferLength := MultiByteToWideChar(DefaultSystemCodePage, 0, LPAnsiBuffer, LImeCount, nil, 0);
          GetMem(LPBuffer, (LPBufferLength + 1) * SizeOf(Char));
          try
            MultiByteToWideChar(DefaultSystemCodePage, 0, LPAnsiBuffer, LImeCount, LPBuffer, LPBufferLength);
            CommandProcessor(ecImeStr, BCEDITOR_NONE_CHAR, LPBuffer);
          finally
            FreeMem(LPBuffer);
          end;
        finally
          FreeMem(LPAnsiBuffer);
        end;
      end;
    finally
      ImmReleaseContext(Handle, LImc);
    end;
  end;
  inherited;
end;

procedure TBCBaseEditor.WMIMENotify(var Msg: TMessage);
var
  LImc: HIMC;
  LLogFontW: TLogFontW;
  LLogFontA: TLogFontA;
begin
  with Msg do
  begin
    case wParam of
      IMN_SETOPENSTATUS:
        begin
          LImc := ImmGetContext(Handle);
          if LImc <> 0 then
          begin
            if IsWindows98orLater then
            begin
              GetObjectW(Font.Handle, SizeOf(TLogFontW), @LLogFontW);
              ImmSetCompositionFontW(LImc, @LLogFontW);
            end
            else
            begin
              GetObjectA(Font.Handle, SizeOf(TLogFontA), @LLogFontA);
              ImmSetCompositionFontA(LImc, @LLogFontA);
            end;
            ImmReleaseContext(Handle, LImc);
          end;
        end;
    end;
  end;
  inherited;
end;

procedure TBCBaseEditor.WMKillFocus(var Msg: TWMKillFocus);
begin
  inherited;
  CommandProcessor(ecLostFocus, BCEDITOR_NONE_CHAR, nil);
  if Focused or FAlwaysShowCaret then
    Exit;
  HideCaret;
  Windows.DestroyCaret;
  if not Selection.Visible and SelectionAvailable then
    InvalidateSelection;
end;

{$IFDEF USE_VCL_STYLES}
procedure TBCBaseEditor.WMNCPaint(var Message: TMessage);
var
  LRect: TRect;
  LExStyle: Integer;
  LTempRgn: HRGN;
  LBorderWidth, LBorderHeight: Integer;
begin
  if StyleServices.Enabled then
  begin
    LExStyle := GetWindowLong(Handle, GWL_EXSTYLE);
    if (LExStyle and WS_EX_CLIENTEDGE) <> 0 then
    begin
      GetWindowRect(Handle, LRect);
      LBorderWidth := GetSystemMetrics(SM_CXEDGE);
      LBorderHeight := GetSystemMetrics(SM_CYEDGE);
      InflateRect(LRect, -LBorderWidth, -LBorderHeight);
      LTempRgn := CreateRectRgnIndirect(LRect);
      DefWindowProc(Handle, Message.Msg, wParam(LTempRgn), 0);
      DeleteObject(LTempRgn);
    end
    else
      DefaultHandler(Message);
  end
  else
    DefaultHandler(Message);

  if StyleServices.Enabled then
    StyleServices.PaintBorder(Self, False);
end;
{$ENDIF}

procedure TBCBaseEditor.WMPaste(var Message: TMessage);
begin
  if not ReadOnly then
    PasteFromClipboard;
  message.Result := Ord(True);
end;

procedure TBCBaseEditor.WMSetCursor(var Msg: TWMSetCursor);
begin
  if (Msg.HitTest = HTCLIENT) and (Msg.CursorWnd = Handle) and not (csDesigning in ComponentState) then
    UpdateMouseCursor
  else
    inherited;
end;

procedure TBCBaseEditor.WMSetFocus(var Msg: TWMSetFocus);
begin
  CommandProcessor(ecGotFocus, BCEDITOR_NONE_CHAR, nil);

  ResetCaret;
  if not Selection.Visible and SelectionAvailable then
    InvalidateSelection;
end;

procedure TBCBaseEditor.WMSetText(var Msg: TWMSetText);
begin
  Msg.Result := 1;
  try
    if HandleAllocated and IsWindowUnicode(Handle) then
      Text := PChar(Msg.Text)
    else
      Text := string(PAnsiChar(Msg.Text));
  except
    Msg.Result := 0;
    raise
  end
end;

procedure TBCBaseEditor.WMSize(var Msg: TWMSize);
begin
  inherited;
  SizeOrFontChanged(False);
end;

procedure TBCBaseEditor.WMUndo(var Msg: TMessage);
begin
  DoUndo;
end;

procedure TBCBaseEditor.WMVScroll(var Msg: TWMScroll);
var
  LScrollHint: string;
  LScrollHintRect: TRect;
  LScrollHintPoint: TPoint;
  LScrollHintWindow: THintWindow;
  LScrollButtonHeight: Integer;
  LScrollInfo: TScrollInfo;
begin
  Invalidate;
  Msg.Result := 0;

  case Msg.ScrollCode of
    { Scrolls to start / end of the text }
    SB_TOP:
      TopLine := 1;
    SB_BOTTOM:
      TopLine := DisplayLineCount;
    { Scrolls one line up / down }
    SB_LINEDOWN:
      TopLine := TopLine + 1;
    SB_LINEUP:
      TopLine := TopLine - 1;
    { Scrolls one page of lines up / down }
    SB_PAGEDOWN:
      TopLine := TopLine + FVisibleLines;
    SB_PAGEUP:
      TopLine := TopLine - FVisibleLines;
    { Scrolls to the current scroll bar position }
    SB_THUMBPOSITION, SB_THUMBTRACK:
      begin
        FIsScrolling := True;
        if DisplayLineCount > BCEDITOR_MAX_SCROLL_RANGE then
          TopLine := MulDiv(VisibleLines + DisplayLineCount - 1, Msg.Pos, BCEDITOR_MAX_SCROLL_RANGE)
        else
          TopLine := Msg.Pos;

        if soShowHint in FScroll.Options then
        begin
          LScrollHintWindow := GetScrollHint;
          if FScroll.Hint.Format = shFTopLineOnly then
            LScrollHint := Format(SBCEditorScrollInfoTopLine, [RowToLine(TopLine)])
          else
            LScrollHint := Format(SBCEditorScrollInfo, [RowToLine(TopLine), RowToLine(TopLine + Min(VisibleLines, DisplayLineCount - TopLine))]);

          LScrollHintRect := ScrollHintWindow.CalcHintRect(200, LScrollHint, nil);

          if soHintFollows in FScroll.Options then
          begin
            LScrollButtonHeight := GetSystemMetrics(SM_CYVSCROLL);

            FillChar(LScrollInfo, SizeOf(LScrollInfo), 0);
            LScrollInfo.cbSize := SizeOf(LScrollInfo);
            LScrollInfo.fMask := SIF_ALL;
            GetScrollInfo(Handle, SB_VERT, LScrollInfo);

            LScrollHintPoint := ClientToScreen(Point(ClientWidth - LScrollHintRect.Right - 4, ((LScrollHintRect.Bottom - LScrollHintRect.Top) shr 1) +
              RoundCorrect((LScrollInfo.nTrackPos / LScrollInfo.nMax) * (ClientHeight - (LScrollButtonHeight * 2 ))) - 2));
          end
          else
            LScrollHintPoint := ClientToScreen(Point(ClientWidth - LScrollHintRect.Right - 4, 4));

          OffsetRect(LScrollHintRect, LScrollHintPoint.X, LScrollHintPoint.Y);
          LScrollHintWindow.ActivateHint(LScrollHintRect, LScrollHint);
          LScrollHintWindow.Invalidate;
          LScrollHintWindow.Update;
        end;
      end;
    SB_ENDSCROLL:
      begin
        FIsScrolling := False;
        if soShowHint in FScroll.Options then
          ShowWindow(GetScrollHint.Handle, SW_HIDE);
      end;
  end;
  Update;
  if Assigned(OnScroll) then
    OnScroll(Self, sbVertical);
end;

procedure TBCBaseEditor.WordWrapChanged(Sender: TObject);
begin
  if GetWordWrap <> FWordWrap.Enabled then
    UpdateWordWrap(FWordWrap.Enabled);
  if GetWordWrap then
    FWordWrapHelper.DisplayChanged;
  if not (csLoading in ComponentState) then
    Invalidate;
end;

{ Protected declarations }

function TBCBaseEditor.DoMouseWheel(AShift: TShiftState; AWheelDelta: Integer; AMousePos: TPoint): Boolean;
var
  LWheelClicks: Integer;
  LLinesToScroll: Integer;
begin
  Result := inherited DoMouseWheel(AShift, AWheelDelta, AMousePos);
  if Result then
    Exit;

  if GetKeyState(VK_CONTROL) < 0 then
    LLinesToScroll := VisibleLines shr Ord(soHalfPage in FScroll.Options)
  else
    LLinesToScroll := 3;
  Inc(FMouseWheelAccumulator, AWheelDelta);
  LWheelClicks := FMouseWheelAccumulator div BCEDITOR_WHEEL_DIVISOR;
  FMouseWheelAccumulator := FMouseWheelAccumulator mod BCEDITOR_WHEEL_DIVISOR;
  TopLine := TopLine - LWheelClicks * LLinesToScroll;
  Update;
  if Assigned(OnScroll) then
    OnScroll(Self, sbVertical);
  Result := True;
end;

function TBCBaseEditor.DoOnReplaceText(const ASearch, AReplace: string; ALine, AColumn: Integer; DeleteLine: Boolean): TBCEditorReplaceAction;
begin
  Result := raCancel;
  if Assigned(FOnReplaceText) then
    FOnReplaceText(Self, ASearch, AReplace, ALine, AColumn, DeleteLine, Result);
end;

function TBCBaseEditor.DoSearchMatchNotFoundWraparoundDialog: Boolean;
begin
  Result := MessageDialog(SBCEditorSearchMatchNotFound, mtConfirmation, [mbYes, mbNo]) = MrYes;
end;

function TBCBaseEditor.GetReadOnly: Boolean;
begin
  Result := FReadOnly;
end;

function TBCBaseEditor.GetSelectedLength: Integer;
begin
  if SelectionAvailable then
    Result := RowColumnToCharIndex(SelectionEndPosition) - RowColumnToCharIndex(SelectionBeginPosition)
  else
    Result := 0;
end;

function TBCBaseEditor.TranslateKeyCode(ACode: Word; AShift: TShiftState; var AData: pointer): TBCEditorCommand;
var
  i: Integer;
begin
  i := KeyCommands.FindKeycode2(FLastKey, FLastShiftState, ACode, AShift);
  if i >= 0 then
    Result := KeyCommands[i].Command
  else
  begin
    i := KeyCommands.FindKeycode(ACode, AShift);
    if i >= 0 then
      Result := KeyCommands[i].Command
    else
      Result := ecNone;
  end;
  if (Result = ecNone) and (ACode >= VK_ACCEPT) and (ACode <= VK_SCROLL) then
  begin
    FLastKey := ACode;
    FLastShiftState := AShift;
  end
  else
  begin
    FLastKey := 0;
    FLastShiftState := [];
  end;
end;

procedure TBCBaseEditor.ChainLinesChanged(Sender: TObject);
begin
  if Assigned(FChainLinesChanged) then
    FChainLinesChanged(Sender);
  FOriginalLines.OnChange(Sender);
end;

procedure TBCBaseEditor.ChainLinesChanging(Sender: TObject);
begin
  if Assigned(FChainLinesChanging) then
    FChainLinesChanging(Sender);
  FOriginalLines.OnChanging(Sender);
end;

procedure TBCBaseEditor.ChainListCleared(Sender: TObject);
begin
  if Assigned(FChainListCleared) then
    FChainListCleared(Sender);
  FOriginalLines.OnCleared(Sender);
end;

procedure TBCBaseEditor.ChainListDeleted(Sender: TObject; AIndex: Integer; ACount: Integer);
begin
  if Assigned(FChainListDeleted) then
    FChainListDeleted(Sender, AIndex, ACount);
  FOriginalLines.OnDeleted(Sender, AIndex, ACount);
end;

procedure TBCBaseEditor.ChainListInserted(Sender: TObject; AIndex: Integer; ACount: Integer);
begin
  if Assigned(FChainListInserted) then
    FChainListInserted(Sender, AIndex, ACount);
  FOriginalLines.OnInserted(Sender, AIndex, ACount);
end;

procedure TBCBaseEditor.ChainListPutted(Sender: TObject; AIndex: Integer; ACount: Integer);
begin
  if Assigned(FChainListPutted) then
    FChainListPutted(Sender, AIndex, ACount);
  FOriginalLines.OnPutted(Sender, AIndex, ACount);
end;

procedure TBCBaseEditor.ChainUndoRedoAdded(Sender: TObject);
var
  LUndoList: TBCEditorUndoList;
  LNotifyEvent: TNotifyEvent;
begin
  if Sender = FUndoList then
  begin
    LUndoList := FOriginalUndoList;
    LNotifyEvent := FChainUndoAdded;
  end
  else
  begin
    LUndoList := FOriginalRedoList;
    LNotifyEvent := FChainRedoAdded;
  end;
  if Assigned(LNotifyEvent) then
    LNotifyEvent(Sender);
  LUndoList.OnAddedUndo(Sender);
end;

procedure TBCBaseEditor.CreateParams(var AParams: TCreateParams);
const
  LBorderStyles: array [TBorderStyle] of DWORD = (0, WS_BORDER);
  LClassStylesOff = CS_VREDRAW or CS_HREDRAW;
begin
  StrDispose(WindowText);
  WindowText := nil;

  inherited CreateParams(AParams);

  with AParams do
  begin
    WindowClass.Style := WindowClass.Style and not LClassStylesOff;
    Style := Style or LBorderStyles[FBorderStyle] or WS_CLIPCHILDREN;

    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

procedure TBCBaseEditor.CreateWnd;
begin
  inherited;

  if (eoDropFiles in FOptions) and not (csDesigning in ComponentState) then
    DragAcceptFiles(Handle, True);

  UpdateScrollBars;
end;

procedure TBCBaseEditor.DblClick;
var
  LCursorPoint: TPoint;
begin
  Windows.GetCursorPos(LCursorPoint);
  LCursorPoint := ScreenToClient(LCursorPoint);

  if LCursorPoint.X >= FLeftMargin.GetWidth + FCodeFolding.GetWidth + 2 then
  begin
    if FSelection.Visible then
      SetWordBlock(CaretPosition);
    inherited;
    Include(FStateFlags, sfDblClicked);
    MouseCapture := False;
  end
  else
    inherited;
end;

procedure TBCBaseEditor.DecPaintLock;
begin
  Assert(FPaintLock > 0);
  Dec(FPaintLock);
  if (FPaintLock = 0) and HandleAllocated then
  begin
    if sfScrollbarChanged in FStateFlags then
      UpdateScrollBars;

    if sfCaretChanged in FStateFlags then
      UpdateCaret;
  end;
end;

procedure TBCBaseEditor.DestroyWnd;
begin
  if (eoDropFiles in FOptions) and not (csDesigning in ComponentState) then
    DragAcceptFiles(Handle, False);

  inherited;
end;

procedure TBCBaseEditor.DoBlockIndent;
var
  LOldCaretPosition: TBCEditorTextPosition;
  LBlockBeginPosition, LBlockEndPosition: TBCEditorTextPosition;
  LStringToInsert: string;
  LEndOfLine, LCaretPositionX, i: Integer;
  LSpaces: string;
  LOrgSelectionMode: TBCEditorSelectionMode;
  LInsertionPosition: TBCEditorTextPosition;
begin
  LOrgSelectionMode := FSelection.ActiveMode;
  LOldCaretPosition := CaretPosition;

  LStringToInsert := '';
  if SelectionAvailable then
  try
    LBlockBeginPosition := SelectionBeginPosition;
    LBlockEndPosition := SelectionEndPosition;

    if LBlockEndPosition.Char = 1 then
    begin
      LEndOfLine := LBlockEndPosition.Line - 1;
      LCaretPositionX := 1;
    end
    else
    begin
      LEndOfLine := LBlockEndPosition.Line;
      if toTabsToSpaces in FTabs.Options then
        LCaretPositionX := CaretX + FTabs.Width
      else
        LCaretPositionX := CaretX + 1;
    end;
    if toTabsToSpaces in FTabs.Options then
      LSpaces := StringOfChar(BCEDITOR_SPACE_CHAR, FTabs.Width)
    else
      LSpaces := BCEDITOR_TAB_CHAR;
    for I := LBlockBeginPosition.Line to LEndOfLine - 1 do
      LStringToInsert := LStringToInsert + LSpaces + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
    LStringToInsert := LStringToInsert + LSpaces;

    FUndoList.BeginBlock;
    try
      LInsertionPosition.Line := LBlockBeginPosition.Line;
      if FSelection.ActiveMode = smColumn then
        LInsertionPosition.Char := Min(LBlockBeginPosition.Char, LBlockEndPosition.Char)
      else
        LInsertionPosition.Char := 1;
      InsertBlock(LInsertionPosition, LInsertionPosition, PChar(LStringToInsert), True);
      FUndoList.AddChange(crIndent, LBlockBeginPosition, LBlockEndPosition, '', smColumn);
      FUndoList.AddChange(crIndent, GetTextPosition(LBlockBeginPosition.Char + Length(LSpaces), LBlockBeginPosition.Line),
        GetTextPosition(LBlockEndPosition.Char + Length(LSpaces), LBlockEndPosition.Line), '', smColumn);
    finally
      FUndoList.EndBlock;
    end;
    LOldCaretPosition.Char := LCaretPositionX;
  finally
    if LBlockEndPosition.Char > 1 then
      Inc(LBlockEndPosition.Char, Length(LSpaces));
    SetCaretAndSelection(LOldCaretPosition, GetTextPosition(LBlockBeginPosition.Char + Length(LSpaces),
      LBlockBeginPosition.Line), LBlockEndPosition);
    FSelection.ActiveMode := LOrgSelectionMode;
  end;
end;

procedure TBCBaseEditor.DoBlockUnindent;
var
  LOldCaretPosition: TBCEditorTextPosition;
  LBlockBeginPosition, LBlockEndPosition: TBCEditorTextPosition;
  LLine: PChar;
  LFullStringToDelete: string;
  LStringToDelete: array of string;
  LLength, LCaretPositionX, LDeleteIndex, i, j, LDeletionLength, LFirstIndent, LLastIndent, LLastLine: Integer;
  LLineText: string;
  LOldSelectionMode: TBCEditorSelectionMode;
  LSomethingToDelete: Boolean;

  function GetDeletionLength: Integer;
  var
    Run: PChar;
  begin
    Result := 0;
    Run := LLine;
    if Run[0] = BCEDITOR_TAB_CHAR then
    begin
      Result := 1;
      LSomethingToDelete := True;
      Exit;
    end;
    while (Run[0] = BCEDITOR_SPACE_CHAR) and (Result < FTabs.Width) do
    begin
      Inc(Result);
      Inc(Run);
      LSomethingToDelete := True;
    end;
    if (Run[0] = BCEDITOR_TAB_CHAR) and (Result < FTabs.Width) then
      Inc(Result);
  end;

begin
  LOldSelectionMode := FSelection.ActiveMode;
  LLength := 0;
  LLastIndent := 0;
  if SelectionAvailable then
  begin
    LBlockBeginPosition := SelectionBeginPosition;
    LBlockEndPosition := SelectionEndPosition;

    LOldCaretPosition := CaretPosition;
    LCaretPositionX := FCaretX;

    if SelectionEndPosition.Char = 1 then
      LLastLine := LBlockEndPosition.Line - 1
    else
      LLastLine := LBlockEndPosition.Line;

    LSomethingToDelete := False;
    j := 0;
    SetLength(LStringToDelete, LLastLine -  LBlockBeginPosition.Line + 1);
    for I := LBlockBeginPosition.Line to LLastLine do
    begin
      LLine := PChar(Lines[I - 1]);
      if FSelection.ActiveMode = smColumn then
        Inc(LLine, MinIntValue([LBlockBeginPosition.Char - 1, LBlockEndPosition.Char - 1, Length(Lines[I - 1])]));
      LDeletionLength := GetDeletionLength;
      LStringToDelete[j] := Copy(LLine, 1, LDeletionLength);
      Inc(j);
      if (FCaretY = I) and (LCaretPositionX <> 1) then
        LCaretPositionX := LCaretPositionX - LDeletionLength;
    end;
    LFirstIndent := -1;
    LFullStringToDelete := '';
    if LSomethingToDelete then
    begin
      for i := 0 to Length(LStringToDelete) - 2 do
        LFullStringToDelete := LFullStringToDelete + LStringToDelete[i] + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
      LFullStringToDelete := LFullStringToDelete + LStringToDelete[Length(LStringToDelete) - 1];
      InternalCaretY := LBlockBeginPosition.Line;
      if FSelection.ActiveMode <> smColumn then
        LDeleteIndex := 1
      else
        LDeleteIndex := Min(LBlockBeginPosition.Char, LBlockEndPosition.Char);
      j := 0;
      for I := LBlockBeginPosition.Line to LLastLine do
      begin
        LLength := Length(LStringToDelete[j]);
        Inc(j);
        if LFirstIndent = -1 then
          LFirstIndent := LLength;
        LLineText := FLines[i - 1];
        Delete(LLineText, LDeleteIndex, LLength);
        FLines[i - 1] := LLineText;
      end;
      LLastIndent := LLength;
      FUndoList.AddChange(crUnindent, LBlockBeginPosition, LBlockEndPosition, LFullStringToDelete, FSelection.ActiveMode);
    end;
    if LFirstIndent = -1 then
      LFirstIndent := 0;
    if FSelection.ActiveMode = smColumn then
      SetCaretAndSelection(LOldCaretPosition, LBlockBeginPosition, LBlockEndPosition)
    else
    begin
      LOldCaretPosition.Char := LCaretPositionX;
      Dec(LBlockBeginPosition.Char, LFirstIndent);
      Dec(LBlockEndPosition.Char, LLastIndent);
      SetCaretAndSelection(LOldCaretPosition, LBlockBeginPosition, LBlockEndPosition);
    end;
    FSelection.ActiveMode := LOldSelectionMode;
  end;
end;

procedure TBCBaseEditor.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TBCBaseEditor.DoCopyToClipboard(const AText: string);
var
  LGlobalMem: HGLOBAL;
  LBytePointer: PByte;
  LTextLength: Integer;
  LSmType: Byte;
begin
  if AText = '' then
    Exit;
  SetClipboardText(AText);

  LTextLength := Length(AText);
  { Open and Close are the only TClipboard methods we use because TClipboard is very hard (impossible) to work with if
    you want to put more than one format on it at a time. }
  Clipboard.Open;
  try
    { Copy it in our custom format so we know what kind of block it is. That effects how it is pasted in. }
    LGlobalMem := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, SizeOf(TBCEditorSelectionMode) + LTextLength + 1);
    if LGlobalMem <> 0 then
    begin
      LBytePointer := GlobalLock(LGlobalMem);
      try
        if Assigned(LBytePointer) then
        begin
          PBCEditorSelectionMode(LBytePointer)^ := FSelection.ActiveMode;
          Inc(LBytePointer, SizeOf(TBCEditorSelectionMode));
          Move(PAnsiChar(AnsiString(AText))^, LBytePointer^, LTextLength + 1);
          SetClipboardData(ClipboardFormatBCEditor, LGlobalMem);
        end;
      finally
        GlobalUnlock(LGlobalMem);
      end;
    end;
    { Don't free Mem!  It belongs to the clipboard now, and it will free it when it is done with it. }
  finally
    Clipboard.Close;
  end;
  if FSelection.Mode = smColumn then
  begin
    { Borland-IDE }
    LSmType := $02;
    Clipboard.Open;
    try
      LGlobalMem := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, SizeOf(LSmType));
      if LGlobalMem <> 0 then
      begin
        LBytePointer := GlobalLock(LGlobalMem);
        try
          if Assigned(LBytePointer) then
          begin
            Move(LSmType, LBytePointer^, SizeOf(LSmType));
            SetClipboardData(ClipboardFormatBorland, LGlobalMem);
          end;
        finally
          GlobalUnlock(LGlobalMem);
        end;
      end;
    finally
      Clipboard.Close;
    end;

    { Microsoft VisualStudio }
    LSmType := $02;
    Clipboard.Open;
    try
      LGlobalMem := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, SizeOf(LSmType));
      if LGlobalMem <> 0 then
      begin
        LBytePointer := GlobalLock(LGlobalMem);
        try
          if Assigned(LBytePointer) then
          begin
            Move(LSmType, LBytePointer^, SizeOf(LSmType));
            SetClipboardData(ClipboardFormatMSDev, LGlobalMem);
          end;
        finally
          GlobalUnlock(LGlobalMem);
        end;
      end;
    finally
      Clipboard.Close;
    end;
  end;
end;

procedure TBCBaseEditor.DoExecuteCompletionProposal;
var
  LPoint: TPoint;
begin
  LPoint := ClientToScreen(RowColumnToPixels(DisplayPosition));
  Inc(LPoint.Y, LineHeight);
  with CompletionProposalHintForm(Self) do
  begin
    BackgroundColor := FCompletionProposal.Colors.Background;
    BorderColor := FCompletionProposal.Colors.Border;
    CaseSensitive := cpoCaseSensitive in FCompletionProposal.Options;
    CloseChars := FCompletionProposal.CloseChars;
    Columns.Assign(FCompletionProposal.Columns);
    Filtered := cpoFiltered in FCompletionProposal.Options;
    Font.Assign(FCompletionProposal.Font);
    FormWidth := FCompletionProposal.Width;
    Resizeable := cpoResizeable in FCompletionProposal.Options;
    SelectedBackgroundColor := FCompletionProposal.Colors.SelectedBackground;
    SelectedTextColor := FCompletionProposal.Colors.SelectedText;
    TriggerChars := FCompletionProposal.Trigger.Chars;
    VisibleLines := FCompletionProposal.VisibleLines;

    if cpoParseItemsFromText in FCompletionProposal.Options then
      SplitTextIntoWords(ItemList, False);

    Execute(GetCurrentInput, LPoint.X, LPoint.Y, ctCode);
  end;
end;

procedure TBCBaseEditor.DoUndo;
begin
  CommandProcessor(ecUndo, #0, nil);
end;

procedure TBCBaseEditor.DoInternalUndo;

  procedure RemoveGroupBreak;
  var
    LUndoItem: TBCEditorUndoItem;
    LOldBlockNumber: Integer;
  begin
    if FUndoList.LastChangeReason = crGroupBreak then
    begin
      LOldBlockNumber := RedoList.BlockChangeNumber;
      try
        LUndoItem := FUndoList.PopItem;
        RedoList.BlockChangeNumber := LUndoItem.ChangeNumber;
        LUndoItem.Free;
        FRedoList.AddGroupBreak;
      finally
        RedoList.BlockChangeNumber := LOldBlockNumber;
      end;
    end;
  end;

var
  LUndoItem: TBCEditorUndoItem;
  LOldChangeNumber: Integer;
  LSaveChangeNumber: Integer;
  LLastChangeReason: TBCEditorChangeReason;
  LLastChangeString: string;
  LIsAutoComplete: Boolean;
  LIsPasteAction: Boolean;
  LIsKeepGoing: Boolean;
  LIsCodeFoldingAction: Boolean;
begin
  if ReadOnly then
    Exit;

  RemoveGroupBreak;

  LLastChangeReason := FUndoList.LastChangeReason;
  LLastChangeString := FUndoList.LastChangeString;
  LIsAutoComplete := LLastChangeReason = crAutoCompleteEnd;
  LIsPasteAction := LLastChangeReason = crPaste;
  LIsCodeFoldingAction := FCodeFolding.Visible and (LLastChangeReason in [crCollapseFold, crUncollapseFold]);

  LUndoItem := FUndoList.PeekItem;
  if Assigned(LUndoItem) then
  begin
    LOldChangeNumber := LUndoItem.ChangeNumber;
    LSaveChangeNumber := FRedoList.BlockChangeNumber;
    FRedoList.BlockChangeNumber := LUndoItem.ChangeNumber;
    try
      repeat
        Self.UndoItem;
        LUndoItem := FUndoList.PeekItem;
        if not Assigned(LUndoItem) then
          LIsKeepGoing := False
        else
        begin
          if LIsAutoComplete then
            LIsKeepGoing := FUndoList.LastChangeReason <> crAutoCompleteBegin
          else
          if LIsPasteAction then
            LIsKeepGoing := (uoGroupUndo in FUndo.Options) and (FUndoList.LastChangeString = LLastChangeString)
          else
          if LIsCodeFoldingAction then
            LIsKeepGoing := False
          else
          if LUndoItem.ChangeNumber = LOldChangeNumber then
            LIsKeepGoing := True
          else
          //if FCodeFolding.Visible and (LUndoItem.ChangeReason = crDeleteCollapsedFold) then
          //  LIsKeepGoing := True
          //else
            LIsKeepGoing := (uoGroupUndo in FUndo.Options) and (LLastChangeReason = LUndoItem.ChangeReason) and
              not (LLastChangeReason in [crIndent, crUnindent]);
          LLastChangeReason := LUndoItem.ChangeReason;
        end;
      until not LIsKeepGoing;

      if LIsAutoComplete and (FUndoList.LastChangeReason = crAutoCompleteBegin) then
      begin
        Self.UndoItem;
        UpdateModifiedStatus;
      end;
    finally
      FRedoList.BlockChangeNumber := LSaveChangeNumber;
    end;
  end;
end;

type
  TBCEditorAccessWinControl = class(TWinControl);

procedure TBCBaseEditor.DoKeyPressW(var Message: TWMKey);
var
  LForm: TCustomForm;
  LKey: Char;
begin
  LKey := Char(message.CharCode);

  if FCompletionProposal.Enabled and FCompletionProposal.Trigger.Enabled then
  begin
    if Pos(LKey, FCompletionProposal.Trigger.Chars) > 0 then
    begin
      FCompletionProposalTimer.Interval := FCompletionProposal.Trigger.Interval;
      FCompletionProposalTimer.Enabled := True;
    end
    else
      FCompletionProposalTimer.Enabled := False;
  end;

  LForm := GetParentForm(Self);
  if Assigned(LForm) and (LForm <> TWinControl(Self)) and LForm.KeyPreview and (LKey <= High(AnsiChar)) and
    TBCEditorAccessWinControl(LForm).DoKeyPress(message) then
    Exit;

  if (csNoStdEvents in ControlStyle) then
    Exit;

  if Assigned(FOnKeyPressW) then
    FOnKeyPressW(Self, LKey);

  if LKey <> BCEDITOR_NONE_CHAR then
    KeyPressW(LKey);
end;

procedure TBCBaseEditor.DoOnAfterBookmarkPlaced;
begin
  if Assigned(FOnAfterBookmarkPlaced) then
    FOnAfterBookmarkPlaced(Self);
end;

procedure TBCBaseEditor.DoOnAfterClearBookmark;
begin
  if Assigned(FOnAfterClearBookmark) then
    FOnAfterClearBookmark(Self);
end;

procedure TBCBaseEditor.DoOnBeforeClearBookmark(var ABookmark: TBCEditorBookmark);
begin
  if Assigned(FOnBeforeClearBookmark) then
    FOnBeforeClearBookmark(Self, ABookmark);
end;

procedure TBCBaseEditor.DoOnCommandProcessed(ACommand: TBCEditorCommand; AChar: Char; AData: pointer);
begin
  if FCodeFolding.Visible then
  begin
    if FNeedToRescanCodeFolding or
      ((ACommand = ecChar) or (ACommand = ecDeleteLastChar) or (ACommand = ecDeleteChar)) and IsKeywordAtLine(FCaretY) or
      ((ACommand = ecLineBreak) and IsKeywordAtLine(FCaretY - 1)) or { the caret is already in the new line }
      (ACommand = ecPaste) or (ACommand = ecUndo) or (ACommand = ecRedo) then
      RescanCodeFoldingRanges
    else
    case ACommand of
      ecInsertLine, ecLineBreak, ecDeleteLine, ecDeleteLastChar, ecClear:
        CodeFoldingPrepareRangeForLine;
    end;
  end;

  if FMatchingPair.Enabled then
  case ACommand of
    ecPaste, ecUndo, ecRedo, ecDeleteLastChar, ecTab, ecLeft, ecRight, ecUp, ecDown, ecPageUp, ecPageDown, ecPageTop,
    ecPageBottom, ecEditorTop, ecEditorBottom, ecGotoXY, ecBlockIndent, ecBlockUnindent, ecShiftTab, ecInsertLine, ecChar,
    ecString, ecLineBreak, ecDeleteChar, ecDeleteWord, ecDeleteLastWord, ecDeleteBeginningOfLine, ecDeleteEndOfLine,
    ecDeleteLine, ecClear:
      ScanMatchingPair;
  end;

  if cfoShowIndentGuides in CodeFolding.Options then
  case ACommand of
    ecCut, ecPaste, ecUndo, ecRedo, ecDeleteLastChar, ecDeleteChar:
      CheckIfAtMatchingKeywords;
    ecUp, ecDown, ecPageUp, ecPageDown, ecPageTop, ecPageBottom, ecEditorTop, ecEditorBottom, ecGotoXY:
      RepaintGuides;
  end;
  if Assigned(FOnCommandProcessed) then
    FOnCommandProcessed(Self, ACommand, AChar, AData);
end;

procedure TBCBaseEditor.DoOnLeftMarginClick(Button: TMouseButton; X, Y: Integer);
var
  i: Integer;
  LOffset: Integer;
  LLine: Integer;
  LMarks: TBCEditorBookmarks;
  LMark: TBCEditorBookmark;
  LFoldRange: TBCEditorCodeFoldingRange;
  LCodeFoldingRegion: Boolean;
begin
  CaretY := DisplayToTextPosition(PixelsToRowColumn(X, Y)).Line;
  CaretX := 0;
  if (X < LeftMargin.Bookmarks.Panel.Width) and (Y div LineHeight <= CaretY - TopLine) and
     LeftMargin.Bookmarks.Visible and
    (bpoToggleBookmarkByClick in LeftMargin.Bookmarks.Panel.Options) then
    ToggleBookmark;

  LCodeFoldingRegion := (X >= FLeftMargin.GetWidth) and (X <= FLeftMargin.GetWidth + FCodeFolding.GetWidth);

  if FCodeFolding.Visible and LCodeFoldingRegion and (Lines.Count > 0) then
  begin
    LFoldRange := CodeFoldingCollapsableFoldRangeForLine(RowToLine(PixelsToRowColumn(X, Y).Row));

    if Assigned(LFoldRange) then
    begin
      if LFoldRange.Collapsed then
        CodeFoldingUncollapse(LFoldRange)
      else
        CodeFoldingCollapse(LFoldRange);
      Refresh;
      Exit;
    end;
  end;
  if Assigned(FOnLeftMarginClick) then
  begin
    LLine := DisplayToTextPosition(PixelsToRowColumn(X, Y)).Line;
    if LLine <= FLines.Count then
    begin
      Marks.GetMarksForLine(LLine, LMarks);
      LOffset := 0;
      LMark := nil;
      for i := 1 to BCEDITOR_MAX_BOOKMARKS do
      begin
        if Assigned(LMarks[i]) then
        begin
          Inc(LOffset, FLeftMargin.Bookmarks.Panel.OtherMarkXOffset);
          if X < LOffset then
          begin
            LMark := LMarks[i];
            Break;
          end;
        end;
      end;
      FOnLeftMarginClick(Self, Button, X, Y, LLine, LMark);
    end;
  end;
end;

procedure TBCBaseEditor.DoOnMinimapClick(Button: TMouseButton; X, Y: Integer);
var
  LNewLine, LPreviousLine, LStep: Integer;
begin
  FMinimap.Clicked := True;
  LPreviousLine := -1;
  LNewLine := Max(1, FMinimap.TopLine + Y div FMinimap.CharHeight);

  if (LNewLine >= TopLine) and (LNewLine <= TopLine + VisibleLines) then
    CaretY := LNewLine
  else
  begin
    LNewLine := LNewLine - VisibleLines div 2;
    LStep :=  Abs(LNewLine - TopLine) div 5;
    if LNewLine < TopLine then
    while LNewLine < TopLine - LStep do
    begin
      TopLine := TopLine - LStep;
      if TopLine <> LPreviousLine then
        LPreviousLine := TopLine
      else
        Break;
      Paint;
    end
    else
    while LNewLine > TopLine + LStep do
    begin
      TopLine := TopLine + LStep;
      if TopLine <> LPreviousLine then
        LPreviousLine := TopLine
      else
        Break;
      Paint;
    end;
    TopLine := LNewLine;
  end;
  FMinimapClickOffsetY := LNewLine - TopLine;
end;

procedure TBCBaseEditor.DoOnPaint;
begin
  if Assigned(FOnPaint) then
  begin
    Canvas.Font.Assign(Font);
    Canvas.Brush.Color := FBackgroundColor;
    FOnPaint(Self, Canvas);
  end;
end;

procedure TBCBaseEditor.DoOnBeforeBookmarkPlaced(var ABookmark: TBCEditorBookmark);
begin
  if Assigned(FOnBeforeBookmarkPlaced) then
    FOnBeforeBookmarkPlaced(Self, ABookmark);
end;

procedure TBCBaseEditor.DoOnProcessCommand(var ACommand: TBCEditorCommand; var AChar: Char; AData: pointer);
begin
  if ACommand < ecUserFirst then
  begin
    if Assigned(FOnProcessCommand) then
      FOnProcessCommand(Self, ACommand, AChar, AData);
  end
  else
  begin
    if Assigned(FOnProcessUserCommand) then
      FOnProcessUserCommand(Self, ACommand, AChar, AData);
  end;
end;

procedure TBCBaseEditor.DoSearchStringNotFoundDialog;
begin
  MessageDialog(Format(SBCEditorSearchStringNotFound, [FSearch.SearchText]), mtInformation, [mbOK]);
end;

procedure TBCBaseEditor.DoTripleClick;
begin
  SelectionBeginPosition := GetTextPosition(0, CaretY);
  SelectionEndPosition := GetTextPosition(0, CaretY + 1);
  FLastDblClick := 0;
end;

procedure TBCBaseEditor.DragCanceled;
begin
  FScrollTimer.Enabled := False;
  inherited;
end;

procedure TBCBaseEditor.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  LDisplayPosition: TBCEditorDisplayPosition;
begin
  inherited;
  if (Source is TBCBaseEditor) and not ReadOnly then
  begin
    Accept := True;
    if GetKeyState(VK_CONTROL) < 0 then
      DragCursor := crMultiDrag
    else
      DragCursor := crDrag;
    if Dragging then
    begin
      if State = dsDragLeave then
        ComputeCaret(FMouseDownX, FMouseDownY)
      else
      begin
        LDisplayPosition := PixelsToNearestRowColumn(X, Y);
        LDisplayPosition.Column := MinMax(LDisplayPosition.Column, LeftChar, LeftChar + CharsInWindow - 1);
        LDisplayPosition.Row := MinMax(LDisplayPosition.Row, TopLine, TopLine + VisibleLines - 1);
        InternalCaretPosition := DisplayToTextPosition(LDisplayPosition);
        ComputeScroll(X, Y);
      end;
    end
    else
      ComputeCaret(X, Y);
  end;
end;

procedure TBCBaseEditor.FreeHintForm(var AForm: TBCEditorCompletionProposalForm);
var
  LRect: TRect;
  LDisplayPosition: TBCEditorDisplayPosition;
  LFoldRange: TBCEditorCodeFoldingRange;
  LPoint: TPoint;
begin
  LDisplayPosition := PixelsToNearestRowColumn(Mouse.CursorPos.X, Mouse.CursorPos.Y);
  LFoldRange := CodeFoldingCollapsableFoldRangeForLine(RowToLine(LDisplayPosition.Row));

  if Assigned(LFoldRange) and LFoldRange.Collapsed then
  begin
    LPoint := Point(Mouse.CursorPos.X, Mouse.CursorPos.Y);
    LRect := LFoldRange.CollapseMarkRect;
  end;

  if Assigned(AForm) then
  begin
    AForm.Hide;
    AForm.ItemList.Clear;
    AForm.Free;
    AForm := nil;
  end;
  FCodeFolding.MouseOverHint := False;
  UpdateMouseCursor;
end;

procedure TBCBaseEditor.HideCaret;
begin
  if sfCaretVisible in FStateFlags then
    if Windows.HideCaret(Handle) then
      Exclude(FStateFlags, sfCaretVisible);
end;

procedure TBCBaseEditor.IncPaintLock;
begin
  Inc(FPaintLock);
end;

procedure TBCBaseEditor.InvalidateRect(const ARect: TRect; AErase: Boolean = False);
begin
  Windows.InvalidateRect(Handle, @ARect, AErase);
end;

procedure TBCBaseEditor.KeyDown(var Key: Word; Shift: TShiftState);
var
  LData: Pointer;
  LChar: Char;
  LEditorCommand: TBCEditorCommand;
  LTokenType, LStart: Integer;
  LToken: string;
  LHighlighterAttribute: TBCEditorHighlighterAttribute;
  LCursorPoint: TPoint;
  LTextPosition: TBCEditorTextPosition;
  LShortCutKey: Word;
  LShortCutShift: TShiftState;

begin
  inherited;

  if Key = 0 then
  begin
    Include(FStateFlags, sfIgnoreNextChar);
    Exit;
  end;

  ShortCutToKey(FCompletionProposal.ShortCut, LShortCutKey, LShortCutShift);
  if FCompletionProposal.Enabled and (Shift = LShortCutShift) and (Key = LShortCutKey) then
  begin
    Key := 0;
    DoExecuteCompletionProposal;
    Exit;
  end;

  FKeyboardHandler.ExecuteKeyDown(Self, Key, Shift);

  { URI mouse over }
  if (ssCtrl in Shift) and URIOpener then
  begin
    Windows.GetCursorPos(LCursorPoint);
    LCursorPoint := ScreenToClient(LCursorPoint);
    LTextPosition := DisplayToTextPosition(PixelsToRowColumn(LCursorPoint.X, LCursorPoint.Y));
    GetHighlighterAttributeAtRowColumn(LTextPosition, LToken, LTokenType, LStart, LHighlighterAttribute);
    FMouseOverURI := LTokenType in [Integer(ttWebLink), Integer(ttMailtoLink)];
  end;

  LData := nil;
  LChar := BCEDITOR_NONE_CHAR;
  try
    LEditorCommand := TranslateKeyCode(Key, Shift, LData);
    if (LEditorCommand <> ecNone) then
    begin
      Key := 0;
      Include(FStateFlags, sfIgnoreNextChar);
      CommandProcessor(LEditorCommand, LChar, LData);
    end
    else
      Exclude(FStateFlags, sfIgnoreNextChar);
  finally
    if Assigned(LData) then
      FreeMem(LData);
  end;
end;

procedure TBCBaseEditor.KeyPressW(var Key: Char);
begin
  if not (sfIgnoreNextChar in FStateFlags) then
  begin
    FKeyboardHandler.ExecuteKeyPress(Self, Key);
    CommandProcessor(ecChar, Key, nil);
  end
  else
    Exclude(FStateFlags, sfIgnoreNextChar);
end;

procedure TBCBaseEditor.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if FMouseOverURI then
    FMouseOverURI := False;

  if FCodeFolding.Visible then
    CheckIfAtMatchingKeywords;

  FKeyboardHandler.ExecuteKeyUp(Self, Key, Shift);
end;

procedure TBCBaseEditor.LinesChanged(Sender: TObject);
var
  LOldMode: TBCEditorSelectionMode;
begin
  Exclude(FStateFlags, sfLinesChanging);
  if HandleAllocated then
  begin
    UpdateScrollBars;
    LOldMode := FSelection.ActiveMode;
    SetSelectionBeginPosition(CaretPosition);
    FSelection.ActiveMode := LOldMode;
    InvalidateRect(FInvalidateRect);
    FillChar(FInvalidateRect, SizeOf(TRect), 0);
    if FLeftMargin.LineNumbers.Visible and FLeftMargin.Autosize then
      FLeftMargin.AutosizeDigitCount(Lines.Count);
    if not (soPastEndOfFileMarker in Scroll.Options) then
      TopLine := TopLine;
    if GetWordWrap then
      FWordWrapHelper.Reset;
    SetLength(FCollapsedLinesDifferenceCache, 0);
  end;
end;

procedure TBCBaseEditor.LinesHookChanged;
var
  LLongestLineLength: Integer;
begin
  Invalidate;
  if soAutosizeMaxWidth in FScroll.Options then
  begin
    LLongestLineLength := FLines.GetLengthOfLongestLine;
    if LLongestLineLength <> FScroll.MaxWidth then
      FScroll.MaxWidth := LLongestLineLength;
  end;
  UpdateScrollBars;
end;

procedure TBCBaseEditor.ListBeforeDeleted(Sender: TObject; AIndex: Integer; ACount: Integer);
begin
  { Do nothing }
end;

procedure TBCBaseEditor.ListBeforeInserted(Sender: TObject; Index: Integer; ACount: Integer);
begin
  { Do nothing }
end;

procedure TBCBaseEditor.ListBeforePutted(Sender: TObject; Index: Integer; ACount: Integer);
begin
  { Do nothing }
end;

procedure TBCBaseEditor.ListCleared(Sender: TObject);
begin
  if GetWordWrap then
    FWordWrapHelper.Reset;

  ClearUndo;
  FillChar(FInvalidateRect, SizeOf(TRect), 0);
  Invalidate;
  CaretPosition := GetTextPosition(1, 1);
  TopLine := 1;
  LeftChar := 1;
end;

procedure TBCBaseEditor.ListDeleted(Sender: TObject; AIndex: Integer; ACount: Integer);
var
  LNativeIndex, LRunner: Integer;
begin
  LNativeIndex := AIndex;
  if Assigned(FHighlighter) then
  begin
    AIndex := Max(AIndex, 1);
    if FLines.Count > 0 then
    begin
      LRunner := RescanHighlighterRangesFrom(Pred(AIndex));
      { This is necessary because a line can be deleted with ecDeleteChar
        command and above, what've done, is rescanned a line joined with deleted
        one. But if range on that line hadn't changed, it still could've been
        changed on lines below. In case if range on line with join had changed
        the above rescan already did the job }
      if LRunner = Pred(AIndex) then
        RescanHighlighterRangesFrom(AIndex);
    end;
  end;

  if GetWordWrap then
    FWordWrapHelper.LinesDeleted(LNativeIndex, ACount);

  InvalidateLines(LNativeIndex + 1, LNativeIndex + FVisibleLines + 1);
  InvalidateLeftMarginLines(LNativeIndex + 1, LNativeIndex + FVisibleLines + 1);
end;

procedure TBCBaseEditor.ListInserted(Sender: TObject; Index: Integer; ACount: Integer);
var
  LLength: Integer;
  LLastScan: Integer;
begin
  if Assigned(FHighlighter) and (FLines.Count > 0) then
  begin
    LLastScan := Index;
    repeat
      LLastScan := RescanHighlighterRangesFrom(LLastScan);
      Inc(LLastScan);
    until LLastScan >= Index + ACount;
  end;

  if GetWordWrap then
    FWordWrapHelper.LinesInserted(Index, ACount);

  if FLeftMargin.LineNumbers.Visible and FLeftMargin.Autosize then
    FLeftMargin.AutosizeDigitCount(Lines.Count);

  LLength := FLeftMargin.RealLeftMarginWidth(FLeftMarginCharWidth);
  if FLeftMargin.Autosize and (FLeftMargin.GetWidth <> LLength) then
   SetLeftMarginWidth(LLength);

  InvalidateLines(Index + 1, Index + FVisibleLines + 1);
  InvalidateLeftMarginLines(Index + 1, Index + FVisibleLines + 1);

  if soAutosizeMaxWidth in FScroll.Options then
  begin
    LLength := FLines.ExpandedStringLengths[Index];
    if LLength > FScroll.MaxWidth then
      FScroll.MaxWidth := LLength;
  end;
end;

procedure TBCBaseEditor.ListPutted(Sender: TObject; Index: Integer; ACount: Integer);
var
  LLength: Integer;
  LLineEnd: Integer;
begin
  LLineEnd := Min(Index + 1, FLines.Count);
  if Assigned(FHighlighter) then
  begin
    LLineEnd := Max(LLineEnd, RescanHighlighterRangesFrom(Index) + 1);
    if FLines <> FOriginalLines then
      LLineEnd := MaxInt;
  end;
  if GetWordWrap then
  begin
    if FWordWrapHelper.LinesPutted(Index, ACount) <> 0 then
      InvalidateLeftMarginLines(Index + 1, LLineEnd);
  end;
  InvalidateLines(Index + 1, LLineEnd);

  if Assigned(FOnLinesPutted) then
    FOnLinesPutted(Self, Index, ACount);

  if soAutosizeMaxWidth in FScroll.Options then
  begin
    LLength := FLines.ExpandedStringLengths[Index];
    if LLength > FScroll.MaxWidth then
      FScroll.MaxWidth := LLength;
  end;
end;

procedure TBCBaseEditor.Loaded;
begin
  inherited Loaded;
  {$IFDEF USE_ALPHASKINS}
  FCommonData.Loaded;
  RefreshEditScrolls(SkinData, FScrollWnd);
  {$ENDIF}
  LeftMarginChanged(Self);
  MinimapChanged(Self);
  UpdateScrollBars;
end;

procedure TBCBaseEditor.MarkListChange(Sender: TObject);
begin
  InvalidateLeftMargin;
end;

procedure TBCBaseEditor.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LWasSelected: Boolean;
  LStartDrag: Boolean;
  LBeginPosition, LEndPosition: TBCEditorTextPosition;
  LOldCaretY: Integer;
  LLeftMarginWidth: Integer;
begin
  LBeginPosition := FSelectionBeginPosition;
  LEndPosition := FSelectionEndPosition;
  LLeftMarginWidth := FLeftMargin.GetWidth + FCodeFolding.GetWidth;

  LWasSelected := False;
  LStartDrag := False;
  if Button = mbLeft then
  begin
    LWasSelected := SelectionAvailable;
    FMouseDownX := X;
    FMouseDownY := Y;
    if FMinimap.Visible then
      FMinimapBufferBmp.Height := 0;
  end;

  if not FMinimap.Dragging and FMinimap.Visible and (X > (ClientRect.Right-ClientRect.Left) - FMinimap.GetWidth - FSearch.Map.GetWidth) then
  begin
    DoOnMinimapClick(Button, X, Y);
    Exit;
  end;

  inherited MouseDown(Button, Shift, X, Y);

  { Can move right edge? }
  if (rmoMouseMove in FRightMargin.Options) and FRightMargin.Visible then
    if (Button = mbLeft) and (Abs(RowColumnToPixels(GetDisplayPosition(FRightMargin.Position + 1, 0)).X - X) < 3) then
    begin
      FRightMargin.Moving := True;
      FRightMarginMovePosition := RowColumnToPixels(GetDisplayPosition(FRightMargin.Position, 0)).X;
      Exit;
    end;

  if (Button = mbLeft) and FCodeFolding.Visible and (Lines.Count > 0) and (cfoShowCollapsedCodeHint in FCodeFolding.Options) and
    (cfoUncollapseByHintClick in FCodeFolding.Options) then
    if DoOnCodeFoldingHintClick(X, Y) then
    begin
      Include(FStateFlags, sfCodeFoldingInfoClicked);
      FCodeFolding.MouseOverHint := False;
      UpdateMouseCursor;
      Exit;
    end;

  { Chained handlers first }
  FKeyboardHandler.ExecuteMouseDown(Self, Button, Shift, X, Y);

  { double and triple clicks }
  if (Button = mbLeft) and (ssDouble in Shift) and (X > LLeftMarginWidth)
  then
  begin
    FLastDblClick := GetTickCount;
    FLastRow := PixelsToRowColumn(X, Y).Row;
    Exit;
  end
  else
  if (soTripleClickRowSelect in FSelection.Options) and (Shift = [ssLeft]) and (FLastDblClick > 0) then
  begin
    if ((GetTickCount - FLastDblClick) < FDoubleClickTime) and (FLastRow = PixelsToRowColumn(X, Y).Row) then
    begin
      DoTripleClick;
      Invalidate;
      Exit;
    end;
    FLastDblClick := 0;
  end;

  { Move caret }
  LOldCaretY := FCaretY;
  if (Button in [mbLeft, mbRight]) and (X > LLeftMarginWidth) then
  begin
    if Button = mbRight then
    begin
      if (coRightMouseClickMovesCaret in FCaret.Options) and
        (SelectionAvailable and not IsPointInSelection(DisplayToTextPosition(PixelsToRowColumn(X, Y))) or not SelectionAvailable) then
      begin
        InvalidateSelection;
        FSelectionEndPosition := FSelectionBeginPosition;
        ComputeCaret(X, Y);
      end
      else
        Exit;
    end
    else
      ComputeCaret(X, Y);
  end;

  if Button = mbLeft then
  begin
    { I couldn't track down why, but sometimes (and definately not all the time)
      the block positioning is lost.  This makes sure that the block is
      maintained in case they started a drag operation on the block }
    FSelectionBeginPosition := LBeginPosition;
    FSelectionEndPosition := LEndPosition;

    MouseCapture := True;
    { if mousedown occurred in selected block begin drag operation }
    Exclude(FStateFlags, sfWaitForDragging);
    if LWasSelected and (eoDragDropEditing in FOptions) and (X > LLeftMarginWidth) and
      (FSelection.Mode = smNormal) and IsPointInSelection(DisplayToTextPosition(PixelsToRowColumn(X, Y))) then
      LStartDrag := True
  end;

  if (Button = mbLeft) and LStartDrag then
    Include(FStateFlags, sfWaitForDragging)
  else
  begin
    if not (sfDblClicked in FStateFlags) then
    begin
      if ssShift in Shift then
        { BlockBegin and BlockEnd are restored to their original position in the
          code from above and SetBlockEnd will take care of proper invalidation }
        SetSelectionEndPosition(CaretPosition)
      else
      begin
        if soALTSetsColumnMode in FSelection.Options then
        begin
          if (ssAlt in Shift) and not FAltEnabled then
          begin
            FSaveSelectionMode := FSelection.Mode;
            FSelection.Mode := smColumn;
            FAltEnabled := True;
          end
          else
          if not (ssAlt in Shift) and FAltEnabled then
          begin
            FSelection.Mode := FSaveSelectionMode;
            FAltEnabled := False;
          end;
        end;
        { Selection mode must be set before calling SetBlockBegin }
        SetSelectionBeginPosition(CaretPosition);
      end;
    end;
  end;

  { Trim if not modifying selection }
  if not (ssShift in Shift) then
  begin
    DoTrimTrailingSpaces(LOldCaretY);
    if DoTrimTrailingSpaces(FCaretY) > 0 then
      if not (soPastEndOfLine in FScroll.Options) then
        CaretX := CaretX;
    { This is necessary because user could click on trimmed area and caret would appear behind
      line length when not in eoScrollPastEndOfLine mode }
  end;

  if X <= FLeftMargin.GetWidth + FCodeFolding.GetWidth then
    DoOnLeftMarginClick(Button, X, Y)
  else
    RepaintGuides;

  if FMatchingPair.Enabled then
    ScanMatchingPair;

  if CanFocus then
  begin
    SetFocus;
    Windows.SetFocus(Handle);
  end;
end;

procedure TBCBaseEditor.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LDisplayPosition: TBCEditorDisplayPosition;
  LFoldRange: TBCEditorCodeFoldingRange;
  LPoint: TPoint;
  i, j, LScrolledXBy: Integer;
  LRect: TRect;
  LHintWindow: THintWindow;
  S: string;
  LTopLine, LTemp, LTemp2: Integer;
begin
  if FMinimap.Visible and (X > (ClientRect.Right-ClientRect.Left) - FMinimap.GetWidth - FSearch.Map.GetWidth) then
    if FMinimap.Clicked then
    begin
      if FMinimap.Dragging then
      begin
        LTemp := GetDisplayLineCount - FMinimap.VisibleLines;
        LTemp2 := Y div FMinimap.CharHeight - FMinimapClickOffsetY;
        FMinimap.TopLine := Max(1, Trunc((LTemp / Max(FMinimap.VisibleLines - VisibleLines, 1)) * LTemp2));
        if (FMinimap.TopLine > LTemp) and (LTemp > 0) then
          FMinimap.TopLine := LTemp;

        LTopLine := Max(1, FMinimap.TopLine + LTemp2);
        if TopLine <> LTopLine then
        begin
          Inc(FProcessingMinimap);
          //OutputDebugString(PChar(Format('FProcessingMinimap = %d, Y=%d, TopLine = %d', [FProcessingMinimap, Y, LTopLine])));
          TopLine := LTopLine;
          Paint;
        end;
      end;
      if not FMinimap.Dragging then
        if (ssLeft in Shift) and MouseCapture and (Abs(FMouseDownY - Y) >= GetSystemMetrics(SM_CYDRAG)) then
          FMinimap.Dragging := True;
      Exit;
    end;

  if FMinimap.Clicked then
    Exit;

  inherited MouseMove(Shift, X, Y);

  if FMouseOverURI and not (ssCtrl in Shift) then
    FMouseOverURI := False;

  if (rmoMouseMove in FRightMargin.Options) and FRightMargin.Visible then
  begin
    FRightMargin.MouseOver := Abs(RowColumnToPixels(GetDisplayPosition(FRightMargin.Position + 1, 0)).X - X) < 3;

    if FRightMargin.Moving and (X > FLeftMargin.GetWidth + FCodeFolding.GetWidth + 2) then
    begin
      FRightMarginMovePosition := X;
      if rmoShowMovingHint in FRightMargin.Options then
      begin
        LHintWindow := GetRightMarginHint;

        S := Format(SBCEditorRightMarginPosition, [PixelsToRowColumn(FRightMarginMovePosition, Y).Column]);

        LRect := LHintWindow.CalcHintRect(200, S, nil);
        LPoint := ClientToScreen(Point(ClientWidth - LRect.Right - 4, 4));

        OffsetRect(LRect, LPoint.X, LPoint.Y);
        LHintWindow.ActivateHint(LRect, S);
        LHintWindow.Invalidate;
      end;
      Invalidate;
      Exit;
    end;
  end;

  if FCodeFolding.Visible and (cfoShowCollapsedCodeHint in CodeFolding.Options) and FCodeFolding.Hint.Visible then
  begin
    LDisplayPosition := PixelsToNearestRowColumn(X, Y);
    LFoldRange := CodeFoldingCollapsableFoldRangeForLine(RowToLine(LDisplayPosition.Row));

    if Assigned(LFoldRange) and LFoldRange.Collapsed then
    begin
      LScrolledXBy := (LeftChar - 1) * CharWidth;
      LPoint := Point(X, Y);
      LRect := LFoldRange.CollapseMarkRect;

      if LRect.Right - LScrolledXBy > 0 then
      begin
        OffsetRect(LRect, -LScrolledXBy, 0);
        FCodeFolding.MouseOverHint := False;
        if PtInRect(LRect, LPoint) then
        begin
          FCodeFolding.MouseOverHint := True;

          LPoint := RowColumnToPixels(GetDisplayPosition(0, LDisplayPosition.Row + 1));
          LPoint.X := Mouse.CursorPos.X - X + LPoint.X + 4 + LScrolledXBy;
          LPoint.Y := Mouse.CursorPos.Y - Y + LPoint.Y + 2;

          if not Assigned(FCodeFoldingHintForm) then
          begin
            FCodeFoldingHintForm := TBCEditorCompletionProposalForm.Create(Self);
            with FCodeFoldingHintForm do
            begin
              BackgroundColor := FCodeFolding.Hint.Colors.Background;
              BorderColor := FCodeFolding.Hint.Colors.Border;
              Font := FCodeFolding.Hint.Font;
              Resizeable := False;
            end;

            j := LFoldRange.CollapsedLines.Count - 1;
            if j > 40 then
              j := 40;
            for i := 0 to j do
              FCodeFoldingHintForm.ItemList.Add(StringReplace(LFoldRange.CollapsedLines[i], BCEDITOR_TAB_CHAR,
                StringOfChar(BCEDITOR_SPACE_CHAR, FTabs.Width), [rfReplaceAll]));
            if j = 40 then
              FCodeFoldingHintForm.ItemList.Add('...');

            FCodeFoldingHintForm.Execute('', LPoint.X, LPoint.Y, ctHint);
          end;
        end
        else
          FreeHintForm(FCodeFoldingHintForm);
      end
      else
        FreeHintForm(FCodeFoldingHintForm);
    end
    else
      FreeHintForm(FCodeFoldingHintForm);
  end;

  { Drag & Drop }
  if MouseCapture and (sfWaitForDragging in FStateFlags) then
  begin
    if (Abs(FMouseDownX - X) >= GetSystemMetrics(SM_CXDRAG)) or (Abs(FMouseDownY - Y) >= GetSystemMetrics(SM_CYDRAG)) then
    begin
      Exclude(FStateFlags, sfWaitForDragging);
      BeginDrag(False);
    end;
  end
  else
  if (ssLeft in Shift) and MouseCapture and ((X <> FOldMouseMovePoint.X) or (Y <> FOldMouseMovePoint.Y))  then
  begin
    FOldMouseMovePoint.X := X;
    FOldMouseMovePoint.Y := Y;
    ComputeScroll(X, Y);
    LDisplayPosition := PixelsToNearestRowColumn(X, Y);
    LDisplayPosition.Row := MinMax(LDisplayPosition.Row, 1, DisplayLineCount);
    if FScrollDeltaX <> 0 then
      LDisplayPosition.Column := DisplayX;
    if FScrollDeltaY <> 0 then
      LDisplayPosition.Row := DisplayY;
    if not (sfCodeFoldingInfoClicked in FStateFlags) then { no selection when info clicked }
    begin
      InternalCaretPosition := DisplayToTextPosition(LDisplayPosition);
      SelectionEndPosition := CaretPosition;
    end;
    FLastSortOrder := soDesc;
    Include(FStateFlags, sfInSelection);
    Exclude(FStateFlags, sfCodeFoldingInfoClicked);
  end;
end;

procedure TBCBaseEditor.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LTokenType, LStart: Integer;
  LToken: string;
  LHighlighterAttribute: TBCEditorHighlighterAttribute;
  LCursorPoint: TPoint;
  LTextPosition: TBCEditorTextPosition;
begin
  FMinimap.Clicked := False;
  FMinimap.Dragging := False;

  Exclude(FStateFlags, sfInSelection);

  inherited MouseUp(Button, Shift, X, Y);

  FKeyboardHandler.ExecuteMouseUp(Self, Button, Shift, X, Y);

  if FCodeFolding.Visible then
    CheckIfAtMatchingKeywords;

  if FMouseOverURI and (Button = mbLeft) and (X > FLeftMargin.GetWidth + FCodeFolding.GetWidth) then
  begin
    Windows.GetCursorPos(LCursorPoint);
    LCursorPoint := ScreenToClient(LCursorPoint);
    LTextPosition := DisplayToTextPosition(PixelsToRowColumn(LCursorPoint.X, LCursorPoint.Y));
    GetHighlighterAttributeAtRowColumn(LTextPosition, LToken, LTokenType, LStart, LHighlighterAttribute);
    OpenLink(LToken, LTokenType);
    Exit;
  end;

  if (rmoMouseMove in FRightMargin.Options) and FRightMargin.Visible then
    if FRightMargin.Moving then
    begin
      FRightMargin.Moving := False;
      if rmoShowMovingHint in FRightMargin.Options then
        ShowWindow(GetRightMarginHint.Handle, SW_HIDE);
      with PixelsToRowColumn(FRightMarginMovePosition, Y) do
        FRightMargin.Position := Column;
      if Assigned(FOnRightMarginMouseUp) then
        FOnRightMarginMouseUp(Self);
      Invalidate;
      Exit;
    end;

  FScrollTimer.Enabled := False;
  if (Button = mbRight) and (Shift = [ssRight]) and Assigned(PopupMenu) then
    Exit;
  MouseCapture := False;

  if FStateFlags * [sfDblClicked, sfWaitForDragging] = [sfWaitForDragging] then
  begin
    ComputeCaret(X, Y);

    if not (ssShift in Shift) then
      SetSelectionBeginPosition(CaretPosition);
    SetSelectionEndPosition(CaretPosition);

    Exclude(FStateFlags, sfWaitForDragging);
  end;
  Exclude(FStateFlags, sfDblClicked);
end;

procedure TBCBaseEditor.NotifyHookedCommandHandlers(AfterProcessing: Boolean; var ACommand: TBCEditorCommand;
  var AChar: Char; AData: pointer);
var
  LHandled: Boolean;
  i: Integer;
  LHookedCommandHandler: TBCEditorHookedCommandHandler;
begin
  LHandled := False;
  for i := 0 to GetHookedCommandHandlersCount - 1 do
  begin
    LHookedCommandHandler := TBCEditorHookedCommandHandler(FHookedCommandHandlers[i]);
    LHookedCommandHandler.Event(Self, AfterProcessing, LHandled, ACommand, AChar, AData, LHookedCommandHandler.Data);
  end;
  if LHandled then
    ACommand := ecNone;
end;

procedure TBCBaseEditor.Paint;
var
  LClipRect, DrawRect: TRect;
  LLine1, LLine2, LLine3, LColumn1, LColumn2, LTemp: Integer;
  LHandle: HDC;
  LSelectionAvailable: Boolean;
begin
  LClipRect := Canvas.ClipRect;

  LColumn1 := FLeftChar;
  LTemp := FLeftMargin.GetWidth - FCodeFolding.GetWidth - 2;
  if LClipRect.Left > FLeftMargin.GetWidth + FCodeFolding.GetWidth + 2 then
    Inc(LColumn1, (LClipRect.Left - LTemp) div FCharWidth);
  LColumn2 := FLeftChar + (LClipRect.Right - LTemp + FCharWidth - 1) div FCharWidth;

  LLine1 := FTopLine;
  LTemp := (LClipRect.Bottom + FTextHeight - 1) div LineHeight;
  LLine2 := MinMax(FTopLine + LTemp, 1, GetDisplayLineCount);
  LLine3 := FTopLine + LTemp;

  HideCaret;
  FBufferBmp.Width := Width;
  FBufferBmp.Height := Height;

  LHandle := Canvas.Handle;
  Canvas.Handle := FBufferBmp.Canvas.Handle;
  FBufferBmp.Canvas.Handle := LHandle;
  LHandle := Canvas.Handle; { important, don't remove }

  FTextDrawer.BeginDrawing(LHandle);
  try
    { Paint the text area if it was (partly) invalidated }
    if LClipRect.Right > FLeftMargin.GetWidth + FCodeFolding.GetWidth then
    begin
      DrawRect := LClipRect;
      DrawRect.Left := DrawRect.Left + FLeftMargin.GetWidth + FCodeFolding.GetWidth;
      DrawRect.Right := (ClientRect.Right-ClientRect.Left) - FMinimap.GetWidth - FSearch.Map.GetWidth;
      DeflateMinimapRect(DrawRect);
      FTextDrawer.SetBaseFont(Font);
      FTextDrawer.Style := Font.Style;
      PaintTextLines(DrawRect, LLine1, LLine2, LColumn1, LColumn2, False);
      FTextDrawer.SetBaseFont(Font);
      FTextDrawer.Style := Font.Style;
    end;

    if FCaret.NonBlinking.Enabled then
      DrawCursor(Canvas);

    DoOnPaint;

    if LClipRect.Left <= FLeftMargin.GetWidth then
    begin
      if FLeftMargin.Visible then
      begin
        DrawRect := LClipRect;
        DrawRect.Right := FLeftMargin.GetWidth + 2;
        PaintLeftMargin(DrawRect, LLine1, LLine2, LLine3);
      end;

      if FCodeFolding.Visible and (Lines.Count > 0) then
      begin
        DrawRect.Left := FLeftMargin.GetWidth + 1;
        DrawRect.Right := FLeftMargin.GetWidth + FCodeFolding.GetWidth;
        PaintCodeFolding(DrawRect, FTopLine + FVisibleLines);
      end;
    end;

    { Paint minimap text lines }
    if FMinimap.Visible then
      if (LClipRect.Right >= ClientRect.Right-ClientRect.Left - FMinimap.GetWidth - FSearch.Map.GetWidth) then
      begin
        DrawRect := LClipRect;
        DrawRect.Left := ClientRect.Right-ClientRect.Left - FMinimap.GetWidth - FSearch.Map.GetWidth;
        DrawRect.Right := ClientRect.Right-ClientRect.Left - FSearch.Map.GetWidth;

        FTextDrawer.SetBaseFont(FMinimap.Font);
        FTextDrawer.Style := FMinimap.Font.Style;
        FMinimap.CharWidth := FTextDrawer.CharWidth;
        FMinimap.CharHeight := FTextDrawer.CharHeight - 1;
        FMinimap.VisibleLines := ClientHeight div FMinimap.CharHeight;

        LSelectionAvailable := SelectionAvailable;

        if not FMinimap.Dragging and
          (DrawRect.Bottom-DrawRect.Top = FMinimapBufferBmp.Height) and (FLastTopLine = FTopLine) and
          (FLastDisplayLineCount = DisplayLineCount) and (not LSelectionAvailable or
          LSelectionAvailable and
          (FSelectionBeginPosition.Line >= FTopLine) and (FSelectionEndPosition.Line <= FTopLine + FVisibleLines)) then
        begin
          LLine1 := FTopLine;
          LLine2 := FTopLine + FVisibleLines;
          Canvas.CopyRect(DrawRect, FMinimapBufferBmp.Canvas, Rect(0, 0, DrawRect.Right-DrawRect.Left, DrawRect.Bottom-DrawRect.Top));
        end
        else
        begin
          LLine1 := Max(FMinimap.TopLine, 1);
          LLine2 := Min(GetDisplayLineCount, LLine1 + ((LClipRect.Bottom-LClipRect.Top) div FMinimap.CharHeight) - 1);
        end;

        LColumn1 := 1;
        LColumn2 := FMinimap.GetWidth div FTextDrawer.CharWidth;

        PaintTextLines(DrawRect, LLine1, LLine2, LColumn1, LColumn2, True);

        FMinimapBufferBmp.Width := DrawRect.Right-DrawRect.Left;
        FMinimapBufferBmp.Height := DrawRect.Bottom-DrawRect.Top;
        FMinimapBufferBmp.Canvas.CopyRect(Rect(0, 0, DrawRect.Right-DrawRect.Left, DrawRect.Bottom-DrawRect.Top), Canvas, DrawRect);

        FTextDrawer.SetBaseFont(Font);
        FTextDrawer.Style := Font.Style;
      end;

    { Paint search map }
    if FSearch.Map.Visible then
      if LClipRect.Right >= ClientRect.Right-ClientRect.Left - FSearch.Map.GetWidth then
      begin
        DrawRect := LClipRect;
        DrawRect.Left := ClientRect.Right-ClientRect.Left - FSearch.Map.GetWidth;
        PaintSearchMap(DrawRect);
      end;

    if FRightMargin.Moving then
      PaintRightMarginMove;
  finally
    FLastTopLine := FTopLine;
    FLastDisplayLineCount := DisplayLineCount;
    FTextDrawer.EndDrawing;
    FBufferBmp.Canvas.CopyRect(ClientRect, Canvas, ClientRect);
    FBufferBmp.Canvas.Handle := Canvas.Handle;
    Canvas.Handle := LHandle;
    UpdateCaret;
  end;
end;

procedure TBCBaseEditor.PaintCodeFolding(AClipRect: TRect; ALineCount: Integer);
var
  i: Integer;
  LFoldRange: TBCEditorCodeFoldingRange;
  LOldBrushColor, LOldPenColor: TColor;
begin
  LOldBrushColor := Canvas.Brush.Color;
  LOldPenColor := Canvas.Pen.Color;

  Canvas.Brush.Color := FCodeFolding.Colors.Background;
  Canvas.FillRect(AClipRect); { fill code folding rect }
  Canvas.Pen.Style := psSolid;
  Canvas.Brush.Color := FCodeFolding.Colors.FoldingLine;

  LFoldRange := nil;
  if cfoHighlightFoldingLine in FCodeFolding.Options then
    LFoldRange := CodeFoldingLineInsideRange(RowToLine(CaretY));

  for i := FTopLine to ALineCount do
  begin
    if Assigned(LFoldRange) and (i >= LFoldRange.FromLine) and (i <= LFoldRange.ToLine) then
    begin
      Canvas.Brush.Color := CodeFolding.Colors.FoldingLineHighlight;
      Canvas.Pen.Color := CodeFolding.Colors.FoldingLineHighlight;
    end
    else
    begin
      Canvas.Brush.Color := CodeFolding.Colors.FoldingLine;
      Canvas.Pen.Color := CodeFolding.Colors.FoldingLine;
    end;
    AClipRect.Top := (i - FTopLine) * LineHeight;
    AClipRect.Bottom := AClipRect.Top + LineHeight;
    PaintCodeFoldingLine(AClipRect, i);
  end;

  Canvas.Brush.Color := LOldBrushColor;
  Canvas.Pen.Color := LOldPenColor;
end;

procedure TBCBaseEditor.PaintCodeFoldingLine(AClipRect: TRect; ALine: Integer);
var
  X, LHeight: Integer;
  LFoldRange: TBCEditorCodeFoldingRange;
  FOldBrushColor: TColor;
begin
  if (LineToRow(CaretY) = ALine) and (FCodeFolding.Colors.ActiveLineBackground <> clNone) then
  begin
    FOldBrushColor := Canvas.Brush.Color;
    Canvas.Brush.Color := FCodeFolding.Colors.ActiveLineBackground;
    Canvas.FillRect(AClipRect);
    Canvas.Brush.Color := FOldBrushColor;
  end;

  if CodeFolding.Padding > 0 then
    InflateRect(AClipRect, -CodeFolding.Padding, 0);

  LFoldRange := CodeFoldingCollapsableFoldRangeForLine(RowToLine(ALine));

  if not Assigned(LFoldRange) then
  begin
    if CodeFoldingTreeLineForLine(RowToLine(ALine)) then
    begin
      X := AClipRect.Left + ((AClipRect.Right - AClipRect.Left) div 2);
      Canvas.MoveTo(X, AClipRect.Top);
      Canvas.LineTo(X, AClipRect.Bottom);
    end;
    if CodeFoldingTreeEndForLine(RowToLine(ALine)) then
    begin
      X := AClipRect.Left + ((AClipRect.Right - AClipRect.Left) div 2);
      Canvas.MoveTo(X, AClipRect.Top);
      Canvas.LineTo(X, AClipRect.Top + ((AClipRect.Bottom - AClipRect.Top) - 4));
      Canvas.LineTo(AClipRect.Right, AClipRect.Top + ((AClipRect.Bottom - AClipRect.Top) - 4));
    end
  end
  else
  begin
    if (ALine = 1) or (RowToLine(ALine) <> RowToLine(ALine - 1)) then
    begin
      if LFoldRange.Collapsable then
      begin
        LHeight := AClipRect.Right - AClipRect.Left;
        AClipRect.Top := AClipRect.Top + ((LineHeight - LHeight) div 2);
        AClipRect.Bottom := AClipRect.Top + LHeight;

        if CodeFolding.MarkStyle = msSquare then
          Canvas.FrameRect(AClipRect)
        else
        if CodeFolding.MarkStyle = msCircle then
        begin
          Canvas.Brush.Color := FCodeFolding.Colors.Background;
          Canvas.Ellipse(AClipRect);
        end;

        { minus }
        Canvas.MoveTo(AClipRect.Left + 2, AClipRect.Top + ((AClipRect.Bottom - AClipRect.Top) div 2));
        Canvas.LineTo(AClipRect.Right - 2, AClipRect.Top + ((AClipRect.Bottom - AClipRect.Top) div 2));

        if LFoldRange.Collapsed then
        begin
          { plus }
          Canvas.MoveTo(AClipRect.Left + ((AClipRect.Right - AClipRect.Left) div 2), AClipRect.Top + 2);
          Canvas.LineTo(AClipRect.Left + ((AClipRect.Right - AClipRect.Left) div 2), AClipRect.Bottom - 2);
        end;
      end;
    end;
  end;
end;

procedure TBCBaseEditor.PaintCodeFoldingCollapsedLine(AFoldRange: TBCEditorCodeFoldingRange; ALineRect: TRect);
var
  LOldPenColor: TColor;
begin
  if FCodeFolding.Visible and (cfoShowCollapsedLine in CodeFolding.Options) and Assigned(AFoldRange) and
    AFoldRange.Collapsed and not AFoldRange.ParentCollapsed then
  begin
    LOldPenColor := Canvas.Pen.Color;
    Canvas.Pen.Color := CodeFolding.Colors.CollapsedLine;
    Canvas.MoveTo(ALineRect.Left, ALineRect.Bottom - 1);
    Canvas.LineTo(Width, ALineRect.Bottom - 1);
    Canvas.Pen.Color := LOldPenColor;
  end;
end;

procedure TBCBaseEditor.PaintCodeFoldingCollapseMark(AFoldRange: TBCEditorCodeFoldingRange; ATokenPosition, ATokenLength, ALine,
  AScrolledXBy: Integer; ALineRect: TRect);
var
  LOldPenColor: TColor;
  LCollapseMarkRect: TRect;
  X, Y: Integer;
  LBrush: TBrush;
begin
  LOldPenColor := Canvas.Pen.Color;
  if FCodeFolding.Visible and (cfoShowCollapsedCodeHint in CodeFolding.Options) and Assigned(AFoldRange) and
    AFoldRange.Collapsed and not AFoldRange.ParentCollapsed then
  begin
    LCollapseMarkRect.Left := (ATokenPosition + ATokenLength + 1) * FCharWidth + FLeftMargin.GetWidth + FCodeFolding.GetWidth;
    LCollapseMarkRect.Top := ALineRect.Top + 2;
    LCollapseMarkRect.Bottom := ALineRect.Bottom - 2;
    LCollapseMarkRect.Right := LCollapseMarkRect.Left + CharWidth * 4 - 2;

    AFoldRange.CollapseMarkRect := LCollapseMarkRect;

    if LCollapseMarkRect.Right - AScrolledXBy > 0 then
    begin
      OffsetRect(LCollapseMarkRect, -AScrolledXBy, 0);
      LBrush := TBrush.Create;
      try
        LBrush.Color := FCodeFolding.Colors.FoldingLine;
        Windows.FrameRect(Canvas.Handle, LCollapseMarkRect, LBrush.Handle);
      finally
        LBrush.Free;
      end;
      Canvas.Pen.Color := FCodeFolding.Colors.FoldingLine;
      { paint [...] }
      Y := LCollapseMarkRect.Top + (LCollapseMarkRect.Bottom - LCollapseMarkRect.Top) div 2;
      X := LCollapseMarkRect.Left + FCharWidth - 1;
      Canvas.Rectangle(X, Y, X + 2, Y + 2);
      X := X + FCharWidth - 1;
      Canvas.Rectangle(X, Y, X + 2, Y + 2);
      X := X + FCharWidth - 1;
      Canvas.Rectangle(X, Y, X + 2, Y + 2);
    end;
  end;
  //Canvas.Brush.Color := LOldBrushColor;
  Canvas.Pen.Color := LOldPenColor;
end;

procedure TBCBaseEditor.PaintGuides(ALine, AScrolledXBy: Integer; ALineRect: TRect; AMinimap: Boolean);
var
  i, X, Y: Integer;
  LOldColor, LTempColor: TColor;
  LDeepestLevel: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  LOldColor := Canvas.Pen.Color;
  LDeepestLevel := 0;

  if FCodeFolding.Visible and (cfoShowIndentGuides in CodeFolding.Options) and
    ((not AMinimap) or AMinimap and (moShowIndentGuides in FMinimap.Options)) then
  begin
    for i := FAllCodeFoldingRanges.AllCount - 1 downto 0 do
    begin
      LCodeFoldingRange := FAllCodeFoldingRanges[i];
      if Assigned(LCodeFoldingRange) then
        if (LCodeFoldingRange.IndentLevel > LDeepestLevel) and (CaretY >= LCodeFoldingRange.FromLine) and
          (CaretY <= LCodeFoldingRange.ToLine) then
          LDeepestLevel := LCodeFoldingRange.IndentLevel;
    end;
    for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
    begin
      LCodeFoldingRange := FAllCodeFoldingRanges[i];
      if Assigned(LCodeFoldingRange) then
        if not LCodeFoldingRange.Collapsed and not LCodeFoldingRange.ParentCollapsed and
          (LCodeFoldingRange.FromLine < ALine) and (LCodeFoldingRange.ToLine > ALine) then
        begin
          if AMinimap then
            X := GetLineIndentChars(FLines, LCodeFoldingRange.ToLine - 1) * FMinimap.CharWidth
          else
            X := GetLineIndentChars(FLines, LCodeFoldingRange.ToLine - 1) * FTextDrawer.CharWidth;
          Canvas.Pen.Color := FCodeFolding.Colors.Indent;

          if (X - AScrolledXBy > 0) and not AMinimap or AMinimap and (X > 0 {Offset}) then
          begin
            if AMinimap then
              X := ClientRect.Right-ClientRect.Left - FMinimap.GetWidth - FSearch.Map.GetWidth + X
            else
              X := FLeftMargin.GetWidth + FCodeFolding.Width + X - AScrolledXBy;
            LTempColor := Canvas.Pen.Color;
            Canvas.Pen.Color := FBackgroundColor;
            if (LDeepestLevel = LCodeFoldingRange.IndentLevel) and
              (CaretY >= LCodeFoldingRange.FromLine) and (CaretY <= LCodeFoldingRange.ToLine) then
              if cfoHighlightIndentGuides in FCodeFolding.Options then
                Canvas.Pen.Color := FCodeFolding.Colors.IndentHighlight;
            Y := ALineRect.Top;
            Canvas.MoveTo(X, Y);
            Canvas.LineTo(X, ALineRect.Bottom);
            Canvas.Pen.Color := LTempColor;
            if LineHeight mod 2 = 0 then
            while Y < ALineRect.Bottom do
            begin
              Canvas.MoveTo(X, Y);
              Inc(Y);
              Canvas.LineTo(X, Y);
              Inc(Y);
            end
            else
            begin
              if ALine mod 2 = 1 then
                Inc(Y);
              while Y < ALineRect.Bottom do
              begin
                Canvas.MoveTo(X, Y);
                Inc(Y);
                Canvas.LineTo(X, Y);
                Inc(Y);
              end;
            end;
          end;
        end;
    end;
  end;
  Canvas.Pen.Color := LOldColor;
end;

procedure TBCBaseEditor.PaintLeftMargin(const AClipRect: TRect; AFirstRow, ALastTextRow, ALastRow: Integer);

  procedure DrawMark(ABookMark: TBCEditorBookmark; var ALeftMarginOffset: Integer; AMarkRow: Integer);
  var
    Y: Integer;
  begin
    if not ABookMark.InternalImage and Assigned(FLeftMargin.Bookmarks.Images) then
    begin
      if ABookMark.ImageIndex <= FLeftMargin.Bookmarks.Images.Count then
      begin
        ALeftMarginOffset := 0;

        if FTextHeight > FLeftMargin.Bookmarks.Images.Height then
          Y := FTextHeight shr 1 - FLeftMargin.Bookmarks.Images.Height shr 1
        else
          Y := 0;
        with FLeftMargin.Bookmarks do
          Images.Draw(Canvas, Panel.LeftMargin + ALeftMarginOffset, (AMarkRow - TopLine) * LineHeight + Y,
            ABookMark.ImageIndex);
        Inc(ALeftMarginOffset, FLeftMargin.Bookmarks.Panel.OtherMarkXOffset);
      end;
    end
    else
    begin
      if ABookMark.ImageIndex in [0 .. 8] then
      begin
        if not Assigned(FInternalBookmarkImage) then
          FInternalBookmarkImage := TBCEditorInternalImage.Create(HINSTANCE, 'BCEDITORBOOKMARKIMAGES', 9);
        if ALeftMarginOffset = 0 then
          FInternalBookmarkImage.DrawTransparent(Canvas, ABookMark.ImageIndex, FLeftMargin.Bookmarks.Panel.LeftMargin +
            ALeftMarginOffset, (aMarkRow - TopLine) * LineHeight, LineHeight, clFuchsia);
        Inc(ALeftMarginOffset, FLeftMargin.Bookmarks.Panel.OtherMarkXOffset);
      end;
    end;
  end;

var
  LLine: Integer;
  LUncollapsedLineNumber: Integer;
  i: Integer;
  LLineRect: TRect;
  LLeftMarginOffsets: PIntegerArray;
  LHasOtherMarks: Boolean;
  LLineNumber: string;
  LFirstLine: Integer;
  LLastLine: Integer;
  LLastTextLine: Integer;
  LMarkRow: Integer;
  LTextSize: TSize;
  LLeftMarginWidth: Integer;
  LOldColor: TColor;
  LLineStateRect: TRect;
  LPanelRect: TRect;
  LPanelActiveLineRect: TRect;
  LPEditorLineAttribute: PBCEditorLineAttribute;
  LBookmark: TBCEditorBookmark;
  LActiveLine: Integer;
begin
  LFirstLine := RowToLine(AFirstRow);
  LLastLine := RowToLine(ALastRow);
  LLastTextLine := RowToLine(ALastTextRow);
  LActiveLine := (LineToRow(CaretY) - TopLine) * LineHeight;

  Canvas.Brush.Color := FLeftMargin.Colors.Background;
  Canvas.FillRect(AClipRect); { fill left margin rect }

  { Line numbers }
  if FLeftMargin.LineNumbers.Visible then
  begin
    FTextDrawer.SetBaseFont(FLeftMargin.Font);
    try
      FTextDrawer.SetForegroundColor(FLeftMargin.Font.Color);

      LLineRect := AClipRect;

      if lnoAfterLastLine in FLeftMargin.LineNumbers.Options then
        LLastTextLine := LLastLine;

      for LLine := LFirstLine to LLastTextLine do
      begin
        if (LLine <> CaretY) or (FLeftMargin.Colors.ActiveLineBackground = clNone) then
          FTextDrawer.SetBackgroundColor(FLeftMargin.Colors.Background)
        else
          FTextDrawer.SetBackgroundColor(FLeftMargin.Colors.ActiveLineBackground);

        LLineRect.Top := (LineToRow(LLine) - TopLine) * LineHeight;
        LLineRect.Bottom := LLineRect.Top + LineHeight;

        LLineNumber := FLeftMargin.FormatLineNumber(LLine);

        LUncollapsedLineNumber := LLine;
        if FCodeFolding.Visible then
        begin
          LUncollapsedLineNumber := GetUncollapsedLineNumber(LLine);
          LLineNumber := FLeftMargin.FormatLineNumber(LUncollapsedLineNumber);
        end;

        if (lnoIntens in LeftMargin.LineNumbers.Options) and (LLine <> CaretY) and (LLineNumber[Length(LLineNumber)] <> '0') and
          (LLine <> LeftMargin.LineNumbers.StartFrom) then
        begin
          LLeftMarginWidth := FLeftMargin.GetWidth - FLeftMargin.LineState.Width - 1;
          LOldColor := Canvas.Pen.Color;
          Canvas.Pen.Color := LeftMargin.Colors.LineNumberLine;
          if (LUncollapsedLineNumber mod 5) = 0 then
          begin
            Canvas.MoveTo(LLeftMarginWidth - FLeftMarginCharWidth + ((FLeftMarginCharWidth - 9) div 2), 1 + LLineRect.Top + ((LineHeight - 1) div 2));
            Canvas.LineTo(LLeftMarginWidth - ((FLeftMarginCharWidth - 1) div 2), 1 + LLineRect.Top + ((LineHeight - 1) div 2));
          end
          else
          begin
            Canvas.MoveTo(LLeftMarginWidth - FLeftMarginCharWidth + ((FLeftMarginCharWidth - 2) div 2), 1 + LLineRect.Top + ((LineHeight - 1) div 2));
            Canvas.LineTo(LLeftMarginWidth - ((FLeftMarginCharWidth - 1) div 2), 1 + LLineRect.Top + ((LineHeight - 1) div 2));
          end;
          Canvas.Pen.Color := LOldColor;

          Continue;
        end;

        GetTextExtentPoint32(Canvas.Handle, PChar(LLineNumber), Length(LLineNumber), LTextSize);
        Windows.ExtTextOut(Canvas.Handle, (FLeftMargin.GetWidth - FLeftMargin.LineState.Width - 2) - LTextSize.cx,
          LLineRect.Top + ((LineHeight - Integer(LTextSize.cy)) div 2), ETO_OPAQUE, @LLineRect, PChar(LLineNumber),
          Length(LLineNumber), nil);
      end;
      FTextDrawer.SetBackgroundColor(FLeftMargin.Colors.Background);
      { erase the remaining area }
      if AClipRect.Bottom > LLineRect.Bottom then
      begin
        LLineRect.Top := LLineRect.Bottom;
        LLineRect.Bottom := AClipRect.Bottom;
        with LLineRect do
          FTextDrawer.ExtTextOut(Left, Top, [tooOpaque], LLineRect, '', 0);
      end;
    finally
      FTextDrawer.SetBaseFont(Self.Font);
    end;
  end;
  { Bookmark panel }
  if FLeftMargin.Bookmarks.Panel.Visible then
  begin
    LPanelRect := Types.Rect(0, 0, FLeftMargin.Bookmarks.Panel.Width, ClientHeight);
    if FLeftMargin.Colors.BookmarkPanelBackground <> clNone then
    begin
      Canvas.Brush.Color := FLeftMargin.Colors.BookmarkPanelBackground;
      Canvas.FillRect(LPanelRect); { fill bookmark panel rect }
    end;
    if FLeftMargin.Colors.ActiveLineBackground <> clNone then
    begin
      LPanelActiveLineRect := Types.Rect(0, LActiveLine, FLeftMargin.Bookmarks.Panel.Width, LActiveLine + LineHeight);
      Canvas.Brush.Color := FLeftMargin.Colors.ActiveLineBackground;
      Canvas.FillRect(LPanelActiveLineRect); { fill bookmark panel active line rect}
    end;
    if Assigned(FBeforeBookmarkPanelPaint) then
      FBeforeBookmarkPanelPaint(Self, Canvas, LPanelRect, LFirstLine, LLastLine);
  end;
  Canvas.Brush.Style := bsClear;
  { Word wrap }
  if GetWordWrap and FWordWrap.Indicator.Visible then
    for LLine := AFirstRow to ALastRow do
      if LineToRow(RowToLine(LLine)) <> LLine then
        FWordWrap.Indicator.Draw(Canvas, FWordWrap.Indicator.Left, (LLine - TopLine) * LineHeight, LineHeight);
  { Border }
  if (FLeftMargin.Border.Style <> mbsNone) and (AClipRect.Right >= FLeftMargin.GetWidth - 2) then
    with Canvas do
    begin
      Pen.Color := FLeftMargin.Colors.Border;
      Pen.Width := 1;
      with AClipRect do
      begin
        if FLeftMargin.Border.Style = mbsMiddle then
        begin
          MoveTo(FLeftMargin.GetWidth - 2, Top);
          LineTo(FLeftMargin.GetWidth - 2, Bottom);
          Pen.Color := FLeftMargin.Colors.Background;
        end;
        MoveTo(FLeftMargin.GetWidth - 1, Top);
        LineTo(FLeftMargin.GetWidth - 1, Bottom);
      end;
    end;
  { Bookmarks }
  if FLeftMargin.Bookmarks.Visible and FLeftMargin.Bookmarks.Visible and (Marks.Count > 0) and
    (LLastLine >= LFirstLine) then
  begin
    LLeftMarginOffsets := AllocMem((aLastRow - aFirstRow + 1) * SizeOf(Integer));
    try
      LHasOtherMarks := False;
      for i := 0 to Marks.Count - 1 do
      begin
        LBookmark := Marks[i];
        if LBookmark.Visible and (LBookmark.Line >= LFirstLine) and (LBookmark.Line <= LLastLine) then
        begin
          if not LBookmark.IsBookmark then
            LHasOtherMarks := True
          else
          begin
            LMarkRow := LineToRow(LBookmark.Line);
            if not FCodeFolding.Visible or FCodeFolding.Visible and not IsLineInsideCollapsedCodeFolding(LMarkRow) then
              if (LMarkRow - aFirstRow >= 0) and (LMarkRow - AFirstRow <= ALastRow - AFirstRow + 1) then
                DrawMark(Marks[i], LLeftMarginOffsets[LMarkRow - AFirstRow], LMarkRow);
          end
        end;
      end;
      if LHasOtherMarks then
      for i := 0 to Marks.Count - 1 do
      begin
        LBookmark := Marks[i];
        if LBookmark.Visible and not LBookmark.IsBookmark and (LBookmark.Line >= LFirstLine) and (LBookmark.Line <= LLastLine) then
        begin
          LMarkRow := LineToRow(LBookmark.Line);
          if not FCodeFolding.Visible or FCodeFolding.Visible and not IsLineInsideCollapsedCodeFolding(LMarkRow) then
            if (LMarkRow - aFirstRow >= 0) and (LMarkRow - AFirstRow <= ALastRow - AFirstRow + 1) then
              DrawMark(Marks[i], LLeftMarginOffsets[LMarkRow - AFirstRow], LMarkRow);
        end;
      end;
    finally
      FreeMem(LLeftMarginOffsets);
    end;
  end;
  { Active Line Indicator }
  if FActiveLine.Visible and FActiveLine.Indicator.Visible then
    FActiveLine.Indicator.Draw(Canvas, FActiveLine.Indicator.Left, LActiveLine, LineHeight);
  { Line state }
  if FLeftMargin.LineState.Enabled then
  begin
    LLineStateRect.Left := FLeftMargin.GetWidth - FLeftMargin.LineState.Width - 1;
    LLineStateRect.Right := LLineStateRect.Left + FLeftMargin.LineState.Width;
    for LLine := AFirstRow to ALastRow do
    begin
      i := RowToLine(LLine) - 1;
      LPEditorLineAttribute := FLines.Attributes[i];

      if (i < FLines.Count) and (LPEditorLineAttribute.LineState <> lsNone) then
      begin
        LLineStateRect.Top := (LLine - TopLine) * LineHeight;
        LLineStateRect.Bottom := LLineStateRect.Top + LineHeight;
        if LPEditorLineAttribute.LineState = lsNormal then
          Canvas.Brush.Color := FLeftMargin.Colors.LineStateNormal
        else
          Canvas.Brush.Color := FLeftMargin.Colors.LineStateModified;
        Canvas.FillRect(LLineStateRect); { fill line state rect }
      end;
    end;
  end;
  if FLeftMargin.Bookmarks.Panel.Visible then
  begin
    if Assigned(FBookmarkPanelLinePaint) then
    begin
      for LLine := AFirstRow to ALastRow do
      begin
        i := RowToLine(LLine);
        if FCodeFolding.Visible then
          i := GetUncollapsedLineNumber(i);
        LLineRect.Left := LPanelRect.Left;
        LLineRect.Right := LPanelRect.Right;
        LLineRect.Top := (LLine - TopLine) * LineHeight;
        LLineRect.Bottom := LLineRect.Top + LineHeight;
        FBookmarkPanelLinePaint(Self, Canvas, LLineRect, i);
      end;
    end;
    if Assigned(FAfterBookmarkPanelPaint) then
      FAfterBookmarkPanelPaint(Self, Canvas, LPanelRect, LFirstLine, LLastLine);
  end;
end;

procedure TBCBaseEditor.PaintRightMarginMove;
var
  LRightMarginPosition: Integer;
begin
  with Canvas do
  begin
    Pen.Width := 1;
    Pen.Style := psDot;
    Pen.Color := FRightMargin.Colors.MovingEdge;
    FTextDrawer.SetBackgroundColor(Self.Color);
    MoveTo(FRightMarginMovePosition, 0);
    LineTo(FRightMarginMovePosition, ClientHeight);
    LRightMarginPosition := RowColumnToPixels(GetDisplayPosition(FRightMargin.Position + 1, 0)).X;
    Pen.Style := psSolid;
    Pen.Color := FRightMargin.Colors.Edge;
    MoveTo(LRightMarginPosition, 0);
    LineTo(LRightMarginPosition, ClientHeight);
  end;
end;

procedure TBCBaseEditor.PaintSearchMap(AClipRect: TRect);
var
  i, j: Integer;
  LHeight: Double;
  {$IFDEF USE_VCL_STYLES}
  LStyles: TCustomStyleServices;
  {$ENDIF}
begin
  {$IFDEF USE_VCL_STYLES}
  LStyles := StyleServices;
  {$ENDIF}
  { Background }
  if FSearch.Map.Colors.Background <> clNone then
    Canvas.Brush.Color := FSearch.Map.Colors.Background
  else
  {$IFDEF USE_VCL_STYLES}
  if LStyles.Enabled then
    Canvas.Brush.Color := LStyles.GetStyleColor(scPanel)
  else
  {$ENDIF}
    Canvas.Brush.Color := FBackgroundColor;
  Canvas.FillRect(AClipRect); { fill search map rect }
  { Lines in window }
  LHeight := (ClientRect.Bottom-ClientRect.Top) / Max(Lines.Count, 1);
  AClipRect.Top := RoundCorrect((TopLine - 1) * LHeight);
  AClipRect.Bottom := RoundCorrect((TopLine - 1 + VisibleLines) * LHeight);
  Canvas.Brush.Color := FBackgroundColor;
  Canvas.FillRect(AClipRect); { fill lines in window rect }

  if not Assigned(FSearchLines) then
    Exit;
  if not Assigned(FSearchEngine) then
    Exit;
  if (FSearchEngine.ResultCount = 0) and not (soHighlightSimilarTerms in FSelection.Options) then
    Exit;
  { draw lines }
  if FSearch.Map.Colors.Foreground <> clNone then
    Canvas.Pen.Color := FSearch.Map.Colors.Foreground
  else
  {$IFDEF USE_VCL_STYLES}
  if LStyles.Enabled then
    Canvas.Pen.Color := LStyles.GetSystemColor(clHighlight)
  else
  {$ENDIF}
    Canvas.Pen.Color := clHighlight;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;
  for i := 0 to FSearchLines.Count - 1 do
  begin
    j := RoundCorrect((PBCEditorTextPosition(FSearchLines.Items[i])^.Line - 1) * LHeight);
    Canvas.MoveTo(AClipRect.Left, j);
    Canvas.LineTo(AClipRect.Right, j);
    Canvas.MoveTo(AClipRect.Left, j + 1);
    Canvas.LineTo(AClipRect.Right, j + 1);
  end;
  { draw active line }
  if moShowActiveLine in FSearch.Map.Options then
  begin
    if FSearch.Map.Colors.ActiveLine <> clNone then
      Canvas.Pen.Color := FSearch.Map.Colors.ActiveLine
    else
      Canvas.Pen.Color := FActiveLine.Color;
    j := RoundCorrect((CaretY - 1) * LHeight);
    Canvas.MoveTo(AClipRect.Left, j);
    Canvas.LineTo(AClipRect.Right, j);
    Canvas.MoveTo(AClipRect.Left, j + 1);
    Canvas.LineTo(AClipRect.Right, j + 1);
  end;
end;

procedure TBCBaseEditor.PaintSpecialChars(ALine, AScrolledXBy: Integer; ALineRect: TRect);
var
  i: Integer;
  LPLine: PChar;
  LCharWidth, LTextHeight: Integer;
  LCharPosition, X, Y: Integer;
  LCharRect: TRect;
begin
  if FSpecialChars.Visible then
  begin
    LPLine := PChar(FLines.Strings[ALine - 1]);

    if scoUseTextColor in FSpecialChars.Options then
      Canvas.Pen.Color := FHighlighter.MainRules.Attribute.Foreground
    else
      Canvas.Pen.Color := FSpecialChars.Color;

    LCharWidth := FCharWidth;
    LTextHeight := Max(FTextHeight - 8, 0) shr 4;
    with ALineRect do
      X := Top + (Bottom - Top) shr 1;

    LCharPosition := 1;
    while LPLine^ <> #0 do
    begin
      if LPLine^ = BCEDITOR_SPACE_CHAR then
      begin
        with LCharRect do
        begin
          Top := X - LTextHeight;
          Bottom := X + 2 + LTextHeight;
          Left := FLeftMargin.Width + FCodeFolding.Width - AScrolledXBy + LCharPosition * LCharWidth - LCharWidth div 2;
          Right := Left + 2;
        end;
        with Canvas, LCharRect do
          Rectangle(Left, Top, Right, Bottom);
      end;
      if LPLine^ = BCEDITOR_TAB_CHAR then
      begin
        with LCharRect do
        begin
          Top := ALineRect.Top;
          Bottom := ALineRect.Bottom;
          Left := FLeftMargin.Width + FCodeFolding.Width - AScrolledXBy + LCharPosition * LCharWidth - LCharWidth div 2;
          Right := Left + FTabs.Width * LCharWidth - 6;
        end;
        with Canvas do
        begin
          with ALineRect do
            Y := (Bottom - Top) shr 1;
          i := 0;
          if FSpecialChars.Style = scsDot then
          begin
            i := LCharRect.Left;
            while i < LCharRect.Right do
            begin
              MoveTo(i, LCharRect.Top + Y);
              LineTo(i + 1, LCharRect.Top + Y);
              Inc(i, 2);
            end;
          end;
          if FSpecialChars.Style = scsSolid then
          begin
            MoveTo(LCharRect.Left, LCharRect.Top + Y);
            LineTo(LCharRect.Right, LCharRect.Top + Y);
            i := LCharRect.Right;
          end;

          MoveTo(i, LCharRect.Top + Y);
          LineTo(i - (Y shr 1), LCharRect.Top + Y - (Y shr 1));
          MoveTo(i, LCharRect.Top + Y);
          LineTo(i - (Y shr 1), LCharRect.Top + Y + (Y shr 1));
        end;
        Inc(LCharPosition, FTabs.Width)
      end
      else
        Inc(LCharPosition, Length(LPLine^));
      Inc(LPLine);
    end;
    if FSpecialChars.EndOfLine.Visible then
    begin
      if scoUseTextColor in FSpecialChars.Options then
        Canvas.Pen.Color := FHighlighter.MainRules.Attribute.Foreground
      else
        Canvas.Pen.Color := FSpecialChars.EndOfLine.Color;
      with Canvas do
      begin
        with LCharRect do
        begin
          Top := ALineRect.Top;
          Bottom := ALineRect.Bottom - 3;
          Left := FLeftMargin.Width + FCodeFolding.Width - AScrolledXBy + LCharPosition * LCharWidth - LCharWidth div 2;
          Right := Left + FTabs.Width * LCharWidth - 3;
        end;
        if LCharRect.Left > FLeftMargin.GetWidth - FCodeFolding.GetWidth then
        begin
          if FSpecialChars.EndOfLine.Style = eolPilcrow then
          begin
            FTextDrawer.ForegroundColor := Canvas.Pen.Color;
            FTextDrawer.Style := [];
            FTextDrawer.TextOut(LCharRect.Left, LCharRect.Top, Char($00B6), 1);
          end
          else
          if FSpecialChars.EndOfLine.Style = eolArrow then
          begin
            Y := LCharRect.Top + 2;
            if FSpecialChars.Style = scsDot then
            begin
              while Y < LCharRect.Bottom do
              begin
                MoveTo(LCharRect.Left + 6, Y);
                LineTo(LCharRect.Left + 6, Y + 1);
                Inc(Y, 2);
              end;
            end;
            { Solid }
            if FSpecialChars.Style = scsSolid then
            begin
              MoveTo(LCharRect.Left + 6, Y);
              Y := LCharRect.Bottom;
              LineTo(LCharRect.Left + 6, Y + 1);
            end;
            MoveTo(LCharRect.Left + 6, Y);
            LineTo(LCharRect.Left + 3, Y - 3);
            MoveTo(LCharRect.Left + 6, Y);
            LineTo(LCharRect.Left + 9, Y - 3);
          end
          else
          begin
            Y := LCharRect.Top + GetLineHeight div 2;
            MoveTo(LCharRect.Left, Y);
            LineTo(LCharRect.Left + 11, Y);
            MoveTo(LCharRect.Left + 1, Y - 1);
            LineTo(LCharRect.Left + 1, Y + 2);
            MoveTo(LCharRect.Left + 2, Y - 2);
            LineTo(LCharRect.Left + 2, Y + 3);
            MoveTo(LCharRect.Left + 3, Y - 3);
            LineTo(LCharRect.Left + 3, Y + 4);
            MoveTo(LCharRect.Left + 10, Y - 3);
            LineTo(LCharRect.Left + 10, Y);
          end;
        end;
      end;
    end;
  end;
end;

procedure TBCBaseEditor.PaintTextLines(AClipRect: TRect; AFirstRow, ALastRow, AFirstColumn, ALastColumn: Integer;
  AMinimap: Boolean);
var
  LAnySelection: Boolean;
  LCurrentLine: Integer;
  LFirstLine: Integer;
  LForegroundColor, LBackgroundColor: TColor;
  LIsComplexLine: Boolean;
  LIsLineSelected, LIsCurrentLine: Boolean;
  LLastLine: Integer;
  LLineRect, LTokenRect: TRect;
  LLineSelectionStart, LLineSelectionEnd: Integer;
  LRightMarginPosition: Integer;
  LSelectionEndPosition: TBCEditorDisplayPosition;
  LSelectionStartPosition: TBCEditorDisplayPosition;
  LTokenHelper: TBCEditorTokenHelper;
  LCustomLineColors: Boolean;
  LCustomForegroundColor: TColor;
  LCustomBackgroundColor: TColor;
  LIsCustomBackgroundColor: Boolean;

  function GetBackgroundColor: TColor;
  var
    LHighlighterAttribute: TBCEditorHighlighterAttribute;
  begin
    if LIsCurrentLine and FActiveLine.Visible and (FActiveLine.Color <> clNone) then
      Result := FActiveLine.Color
    else
    begin
      Result := FBackgroundColor;
      if Assigned(FHighlighter) then
      begin
        LHighlighterAttribute := FHighlighter.GetCurrentRangeAttribute;
        if Assigned(LHighlighterAttribute) and (LHighlighterAttribute.Background <> clNone) then
          Result := LHighlighterAttribute.Background;
      end;
    end;
  end;

  procedure ComputeSelectionInfo;
  var
    LStartPosition: TBCEditorTextPosition;
    LEndPosition: TBCEditorTextPosition;
  begin
    LAnySelection := False;
    if FSelection.Visible or Focused then
    begin
      LAnySelection := SelectionAvailable;
      LStartPosition := GetSelectionBeginPosition;
      LEndPosition := GetSelectionEndPosition;
      if LAnySelection then
      begin
        LSelectionStartPosition := TextToDisplayPosition(LStartPosition, True, False);
        LSelectionEndPosition := TextToDisplayPosition(LEndPosition, False, False);
      end;
    end;
  end;

  procedure SetDrawingColors(ASelected: Boolean; AHighlight: Boolean = False);
  var
    LColor: TColor;
  begin
    with FTextDrawer do
    begin
      { Selection colors }
      if ASelected then
      begin
        if FSelection.Colors.Foreground <> clNone then
          SetForegroundColor(FSelection.Colors.Foreground)
        else
          SetForegroundColor(LForegroundColor);
        LColor := FSelection.Colors.Background;
      end
      { Normal colors }
      else
      begin
        SetForegroundColor(LForegroundColor);
        LColor := LBackgroundColor;
      end;
      SetBackgroundColor(LColor); { for the text... }
      Canvas.Brush.Color := LColor; { and for the rest of the line }
    end;
  end;

  function ColumnToWidth(AColumn: Integer; AMinimap: Boolean = False; ARealWidth: Boolean = True): Integer;
  var
    LCharWidth: Integer;
  begin
    if AMinimap then
      Result := ClientRect.Right-ClientRect.Left - FMinimap.GetWidth - FSearch.Map.GetWidth
    else
      Result := FTextOffset;

    if AMinimap then
      LCharWidth := FMinimap.CharWidth
    else
      LCharWidth := FTextDrawer.CharWidth;

    if ARealWidth then
      Result := Result + FColumnWidths[Pred(AColumn)]
    else
      Result := Result + LCharWidth * Pred(AColumn);
  end;

  procedure PaintToken(AToken: string; ATokenLength, ACharsBefore, AFirst, ALast: Integer);
  var
    LText: string;
    X: Integer;
    LCharsToPaint: Integer;
    OldPenColor: TColor;
  const
    ETOOptions = [tooOpaque, tooClipped];

    function ShrinkAtWideGlyphs(const Token: string; First: Integer; var CharCount: Integer): string;
    var
      i, j: Integer;
    begin
      Result := Token;
      i := First;
      j := 0;
      while i < First + CharCount do
      begin
        Inc(j);
        while Token[i] = BCEDITOR_FILLER_CHAR do
          Inc(i);
        if j <> i then
          Result[j] := Token[i];
        Inc(i);
      end;
      if Length(Result) <> j then
        SetLength(Result, j);
      CharCount := j;
    end;

  begin
    if (ALast >= AFirst) and (LTokenRect.Right > LTokenRect.Left) then
    begin
      X := ColumnToWidth(AFirst, AMinimap);

      Dec(AFirst, ACharsBefore);
      Dec(ALast, ACharsBefore);

      if AFirst > ATokenLength then
      begin
        LCharsToPaint := 0;
        LText := '';
      end
      else
      begin
        LCharsToPaint := Min(ALast - AFirst + 1, ATokenLength - AFirst + 1);

        if GetWordWrap then
        while X + FTextDrawer.CharWidth * LCharsToPaint > ClientWidth do
        begin
          Dec(LCharsToPaint);
          while (LCharsToPaint > 0) and (AToken[AFirst + LCharsToPaint - 1] = BCEDITOR_FILLER_CHAR) do
            Dec(LCharsToPaint);
        end;

        LText := ShrinkAtWideGlyphs(AToken, AFirst, LCharsToPaint);
      end;

      FTextDrawer.ExtTextOut(X, LTokenRect.Top, ETOOptions, LTokenRect, PChar(LText), LCharsToPaint);

      if LTokenHelper.MatchingPairUnderline then
      begin
        OldPenColor := Canvas.Pen.Color;
        Canvas.Pen.Color := FMatchingPair.Colors.Underline;
        Canvas.MoveTo(LTokenRect.Left, LTokenRect.Bottom - 1);
        Canvas.LineTo(LTokenRect.Right, LTokenRect.Bottom - 1);
        Canvas.Pen.Color := OldPenColor;
      end;

      LTokenRect.Left := LTokenRect.Right;
    end;
  end;

  procedure PaintHighlightToken(AFillToEndOfLine: Boolean);
  var
    LIsTokenSelected: Boolean;
    LFirstColumn, LLastColumn, LSelectionStart, LSelectionEnd: Integer;
    LFirstUnselectedPartOfToken, LSelected, LSecondUnselectedPartOfToken: Boolean;
    X1, X2: Integer;
  begin
    { Compute some helper variables. }
    LFirstColumn := Max(AFirstColumn, LTokenHelper.CharsBefore + 1);
    LLastColumn := Min(ALastColumn, LTokenHelper.CharsBefore + LTokenHelper.Length + 1);
    if LIsComplexLine then
    begin
      LFirstUnselectedPartOfToken := LFirstColumn < LLineSelectionStart;
      LSelected := (LFirstColumn < LLineSelectionEnd) and (LLastColumn >= LLineSelectionStart);
      LSecondUnselectedPartOfToken := LLastColumn >= LLineSelectionEnd;
      LIsTokenSelected := LSelected and (LFirstUnselectedPartOfToken or LSecondUnselectedPartOfToken);
    end
    else
    begin
      LFirstUnselectedPartOfToken := False;
      LSelected := LIsLineSelected;
      LSecondUnselectedPartOfToken := False;
      LIsTokenSelected := False;
    end;
    { Any token chars accumulated? }
    if LTokenHelper.Length > 0 then
    begin
      LBackgroundColor := LTokenHelper.Background;
      LForegroundColor := LTokenHelper.Foreground;

      FTextDrawer.SetStyle(LTokenHelper.FontStyle);

      if AMinimap then
        if (LCurrentLine >= RowToLine(TopLine)) and (LCurrentLine < RowToLine(TopLine + VisibleLines)) then
          LBackgroundColor := FMinimap.Colors.VisibleLines;

      if LCustomLineColors and (LCustomForegroundColor <> clNone) then
        LForegroundColor := LCustomForegroundColor;
      if LCustomLineColors and (LCustomBackgroundColor <> clNone) then
        LBackgroundColor := LCustomBackgroundColor;

      if LIsTokenSelected then
      begin
        if LFirstUnselectedPartOfToken then
        begin
          SetDrawingColors(False);
          LTokenRect.Right := ColumnToWidth(LLineSelectionStart, AMinimap);
          with LTokenHelper do
            PaintToken(Text, Length, CharsBefore, LFirstColumn, LLineSelectionStart);
        end;
        { selected part of the token }
        SetDrawingColors(True);
        LSelectionStart := Max(LLineSelectionStart, LFirstColumn);
        LSelectionEnd := Min(LLineSelectionEnd, LLastColumn);
        LTokenRect.Right := ColumnToWidth(LSelectionEnd, AMinimap);
        with LTokenHelper do
          PaintToken(Text, Length, CharsBefore, LSelectionStart, LSelectionEnd);
        { second unselected part of the token }
        if LSecondUnselectedPartOfToken then
        begin
          SetDrawingColors(False);
          LTokenRect.Right := ColumnToWidth(LLastColumn, AMinimap);
          with LTokenHelper do
            PaintToken(Text, Length, CharsBefore, LLineSelectionEnd, LLastColumn);
        end;
      end
      else
      begin
        SetDrawingColors(LSelected);
        LTokenRect.Right := ColumnToWidth(LLastColumn, AMinimap);
        with LTokenHelper do
          PaintToken(Text, Length, CharsBefore, LFirstColumn, LLastColumn);
      end;
    end;

    if AFillToEndOfLine and (LTokenRect.Left < LLineRect.Right) then
    begin
      LBackgroundColor := GetBackgroundColor;
      if AMinimap then
        if (LCurrentLine >= RowToLine(TopLine)) and (LCurrentLine < RowToLine(TopLine + VisibleLines)) then
          LBackgroundColor := FMinimap.Colors.VisibleLines;

      if LCustomLineColors and (LCustomForegroundColor <> clNone) then
        LForegroundColor := LCustomForegroundColor;
      if LCustomLineColors and (LCustomBackgroundColor <> clNone) then
        LBackgroundColor := LCustomBackgroundColor;

      if LIsComplexLine then
      begin
        X1 := ColumnToWidth(LLineSelectionStart, AMinimap, False);
        X2 := ColumnToWidth(LLineSelectionEnd, AMinimap, False);
        if LTokenRect.Left < X1 then
        begin
          SetDrawingColors(False);
          LTokenRect.Right := X1;
          Canvas.FillRect(LTokenRect); { fill end of line rect }
          LTokenRect.Left := X1;
        end;
        if LTokenRect.Left < X2 then
        begin
          SetDrawingColors(not (soToEndOfLine in FSelection.Options));
          LTokenRect.Right := X2;
          Canvas.FillRect(LTokenRect); { fill end of line rect }
          LTokenRect.Left := X2;
        end;
        if LTokenRect.Left < LLineRect.Right then
        begin
          SetDrawingColors(False);
          LTokenRect.Right := LLineRect.Right;
          Canvas.FillRect(LTokenRect); { fill end of line rect }
        end;
      end
      else
      begin
        SetDrawingColors(not (soToEndOfLine in FSelection.Options) and LIsLineSelected);
        LTokenRect.Right := LLineRect.Right;
        Canvas.FillRect(LTokenRect); { fill end of line rect }
      end;
    end;
  end;

  procedure PrepareTokenHelper(const AToken: string; ACharsBefore, ATokenLength: Integer; AForeground, ABackground: TColor;
    AFontStyle: TFontStyles; AMatchingPairUnderline: Boolean);
  var
    i: Integer;
    LCanAppend: Boolean;
    LDoSpacesTest, LIsSpaces: Boolean;

    function TokenIsSpaces: Boolean;
    var
      PToken: PChar;
    begin
      if not LDoSpacesTest then
      begin
        LDoSpacesTest := True;
        PToken := PChar(AToken);
        while PToken^ <> #0 do
        begin
          if PToken^ <> #32 then
            Break;
          Inc(PToken);
        end;
        LIsSpaces := PToken^ = #0;
      end;
      Result := LIsSpaces;
    end;

  begin
    if (ABackground = clNone) or ((FActiveLine.Color <> clNone) and LIsCurrentLine and not LIsCustomBackgroundColor) then
      ABackground := GetBackgroundColor;
    if AForeground = clNone then
      AForeground := Font.Color;
    LCanAppend := False;
    LDoSpacesTest := False;
    if LTokenHelper.Length > 0 then
    begin
      LCanAppend := ((LTokenHelper.FontStyle = AFontStyle) or
        (not (fsUnderline in AFontStyle) and not (fsUnderline in LTokenHelper.FontStyle) and TokenIsSpaces)) and
        (LTokenHelper.MatchingPairUnderline = AMatchingPairUnderline) and
        ((LTokenHelper.Background = ABackground) and ((LTokenHelper.Foreground = AForeground) or TokenIsSpaces));
      if not LCanAppend then
        PaintHighlightToken(False);
    end;
    if LCanAppend then
    begin
      if LTokenHelper.Length + ATokenLength > LTokenHelper.MaxLength then
      begin
        LTokenHelper.MaxLength := LTokenHelper.Length + ATokenLength + 32;
        SetLength(LTokenHelper.Text, LTokenHelper.MaxLength);
      end;
      for i := 1 to ATokenLength do
        LTokenHelper.Text[LTokenHelper.Length + i] := AToken[i];
      Inc(LTokenHelper.Length, ATokenLength);
    end
    else
    begin
      LTokenHelper.Length := ATokenLength;
      if LTokenHelper.Length > LTokenHelper.MaxLength then
      begin
        LTokenHelper.MaxLength := LTokenHelper.Length + 32;
        SetLength(LTokenHelper.Text, LTokenHelper.MaxLength);
      end;
      for i := 1 to ATokenLength do
        LTokenHelper.Text[i] := AToken[i];
      LTokenHelper.CharsBefore := ACharsBefore;
      LTokenHelper.Foreground := AForeground;
      LTokenHelper.Background := ABackground;
      LTokenHelper.FontStyle := AFontStyle;
      LTokenHelper.MatchingPairUnderline := AMatchingPairUnderline;
    end;
  end;

  procedure InitColumnWidths(AText: PChar; ACharWidth: Integer; ALength: Integer);
  var
    i, LWidthSum: Integer;
  begin
    LIsCurrentLine := False;
    ReallocMem(FColumnWidths, (ALength + 1) * SizeOf(Integer));
    LWidthSum := 0;
    for i := 0 to ALength do
    begin
      FColumnWidths[i] := LWidthSum;
      LWidthSum := LWidthSum + FTextDrawer.GetCharCount(@AText[i]) * ACharWidth;
    end;
  end;

  procedure PaintLines;
  var
    i: Integer;
    LCurrentLineText: string;
    LCurrentRow: Integer;
    LDisplayPosition: TBCEditorDisplayPosition;
    LEndRow: Integer;
    LFirstChar: Integer;
    LFoldRange: TBCEditorCodeFoldingRange;
    LHighlighterAttribute: TBCEditorHighlighterAttribute;
    LLastChar: Integer;
    LScrolledXBy: Integer;
    LStartRow: Integer;
    LTokenText: string;
    LTokenPosition, LTokenLength: Integer;
    LCurrentRange: TBCEditorRange;
    LStyle: TFontStyles;
    LKeyWord, LWord: string;
    LSelectionBeginChar, LSelectionEndChar: Integer;
    LTempTextPosition: TBCEditorTextPosition;
    LMatchingPairUnderline: Boolean;
  begin
    LLineRect := AClipRect;
    if AMinimap then
      LLineRect.Bottom := (AFirstRow - FMinimap.TopLine) * FMinimap.CharHeight
    else
      LLineRect.Bottom := (AFirstRow - FTopLine) * LineHeight;

    if Assigned(FHighlighter) then
    begin
      LTokenHelper.MaxLength := Max(128, fCharsInWindow);
      SetLength(LTokenHelper.Text, LTokenHelper.MaxLength);
    end;

    LScrolledXBy := (FLeftChar - 1) * FCharWidth;

    for i := LFirstLine to LLastLine do
    begin
      LCurrentLine := i;

      { Get line with tabs converted to spaces. Trust me, you don't want to mess around with tabs when painting. }
      LCurrentLineText := FLines.ExpandedStrings[LCurrentLine - 1];
      InitColumnWidths(PChar(LCurrentLineText), FTextDrawer.CharWidth, Length(LCurrentLineText));
      LIsCurrentLine := CaretY = LCurrentLine;
      LStartRow := Max(LineToRow(LCurrentLine), AFirstRow);
      LEndRow := Min(LineToRow(LCurrentLine + 1) - 1, ALastRow);
      LTokenPosition := 0;
      LTokenLength := 0;

      for LCurrentRow := LStartRow to LEndRow do
      begin
        LForegroundColor := Font.Color;
        LBackgroundColor := GetBackgroundColor;
        LCustomLineColors := DoOnCustomLineColors(LCurrentLine, LCustomForegroundColor, LCustomBackgroundColor);

        if GetWordWrap then
        begin
          LDisplayPosition.Row := LCurrentRow;
          if Assigned(FHighlighter) then
            LDisplayPosition.Column := AFirstColumn
          else
            LDisplayPosition.Column := 1;
          LFirstChar := FWordWrapHelper.DisplayToTextPosition(LDisplayPosition).Char;
          LDisplayPosition.Column := ALastColumn;
          LLastChar := FWordWrapHelper.DisplayToTextPosition(LDisplayPosition).Char;
        end
        else
        begin
          LFirstChar := AFirstColumn;
          LLastChar := ALastColumn;
        end;

        LIsComplexLine := False;
        LLineSelectionStart := 0;
        LLineSelectionEnd := 0;

        if LAnySelection and (LCurrentRow >= LSelectionStartPosition.Row) and (LCurrentRow <= LSelectionEndPosition.Row) then
        begin
          LLineSelectionStart := AFirstColumn;
          LLineSelectionEnd := ALastColumn + 1;
          if (FSelection.ActiveMode = smColumn) or
            ((FSelection.ActiveMode = smNormal) and (LCurrentRow = LSelectionStartPosition.Row)) then
          begin
            if LSelectionStartPosition.Column > ALastColumn then
            begin
              LLineSelectionStart := 0;
              LLineSelectionEnd := 0;
            end
            else
            if LSelectionStartPosition.Column > AFirstColumn then
            begin
              LLineSelectionStart := LSelectionStartPosition.Column;
              LIsComplexLine := True;
            end;
          end;
          if (FSelection.ActiveMode = smColumn) or
            ((FSelection.ActiveMode = smNormal) and (LCurrentRow = LSelectionEndPosition.Row)) then
          begin
            if LSelectionEndPosition.Column < AFirstColumn then
            begin
              LLineSelectionStart := 0;
              LLineSelectionEnd := 0;
            end
            else
            if LSelectionEndPosition.Column < ALastColumn then
            begin
              LLineSelectionEnd := LSelectionEndPosition.Column;
              LIsComplexLine := True;
            end;
          end;
        end;

        LLineRect.Top := LLineRect.Bottom;
        if AMinimap then
          Inc(LLineRect.Bottom, FMinimap.CharHeight)
        else
          Inc(LLineRect.Bottom, LineHeight);

        LIsLineSelected := not LIsComplexLine and (LLineSelectionStart > 0);
        LTokenRect := LLineRect;

        if LCurrentLine = 1 then
          FHighlighter.ResetCurrentRange
        else
          FHighlighter.SetCurrentRange(Lines.Ranges[LCurrentLine - 2]);
        FHighlighter.SetCurrentLine(LCurrentLineText);
        LTokenHelper.Length := 0;

        while not FHighlighter.GetEndOfLine do
        begin
          LTokenPosition := FHighlighter.GetTokenPosition;
          LTokenText := FHighlighter.GetToken;
          LTokenLength := Length(LTokenText);
          if LTokenPosition + LTokenLength >= LFirstChar then
          begin
            if LTokenPosition + LTokenLength > LLastChar then
            begin
              if LTokenPosition > LLastChar then
                Break;
              if GetWordWrap then
                LTokenLength := LLastChar - LTokenPosition - 1
              else
                LTokenLength := LLastChar - LTokenPosition;
            end;
            Dec(LTokenPosition, LFirstChar - AFirstColumn);
            LHighlighterAttribute := FHighlighter.GetTokenAttribute;
            if Assigned(LHighlighterAttribute) then
            begin
              LForegroundColor := LHighlighterAttribute.Foreground;
              LBackgroundColor := LHighlighterAttribute.Background;
              LStyle := LHighlighterAttribute.Style;

              { TODO: This is quite ugly and should not be here, think a better solution }
              if LHighlighterAttribute.UseParentElementForTokens then
              begin
                LCurrentRange := TBCEditorRange(FHighlighter.GetCurrentRange);
                if Assigned(LCurrentRange) then
                  if (LTokenText = LCurrentRange.OpenToken.Symbols[0]) or (LTokenText = LCurrentRange.CloseToken.Symbols[0]) or
                    (LCurrentRange.CloseToken.Symbols[0] = '') then
                  begin
                    LForegroundColor := LCurrentRange.Parent.Attribute.Foreground;
                    LBackgroundColor := LCurrentRange.Parent.Attribute.Background;
                    LStyle := LCurrentRange.Parent.Attribute.Style;
                  end;
              end;

              LIsCustomBackgroundColor := False;
              LMatchingPairUnderline := False;

              if FMatchingPair.Enabled then
                if FCurrentMatchingPair <> trNotFound then
                  if (LTokenText = FCurrentMatchingPairMatch.OpenToken) or (LTokenText = FCurrentMatchingPairMatch.CloseToken) then
                  begin
                    if (LTokenPosition = FCurrentMatchingPairMatch.OpenTokenPos.Char - 1) and
                       (LCurrentLine = FCurrentMatchingPairMatch.OpenTokenPos.Line) or
                       (LTokenPosition = FCurrentMatchingPairMatch.CloseTokenPos.Char - 1) and
                       (LCurrentLine = FCurrentMatchingPairMatch.CloseTokenPos.Line) then
                    begin
                      if (FCurrentMatchingPair = trOpenAndCloseTokenFound) or (FCurrentMatchingPair = trCloseAndOpenTokenFound) then
                      begin
                        if mpoUseMatchedColor in FMatchingPair.Options then
                        begin
                          LIsCustomBackgroundColor := True;
                          if LForegroundColor = FMatchingPair.Colors.Matched then
                            LForegroundColor := BackgroundColor;
                          LBackgroundColor := FMatchingPair.Colors.Matched;
                        end;
                        LMatchingPairUnderline := mpoUnderline in FMatchingPair.Options;
                      end
                      else
                      if mpoHighlightUnmatched in FMatchingPair.Options then
                      begin
                        if mpoUseMatchedColor in FMatchingPair.Options then
                        begin
                          LIsCustomBackgroundColor := True;
                          if LForegroundColor = FMatchingPair.Colors.Unmatched then
                            LForegroundColor := BackgroundColor;
                          LBackgroundColor := FMatchingPair.Colors.Unmatched;
                        end;
                        LMatchingPairUnderline := mpoUnderline in FMatchingPair.Options;
                      end;
                    end;
                  end;

              LKeyword := '';
              LWord := LTokenText;
              if FSearch.Enabled and (FSearch.SearchText <> '') and (soHighlightResults in FSearch.Options) then
              begin
                LKeyword := FSearch.SearchText;
                if not (soCaseSensitive in FSearch.Options) then
                begin
                  LKeyword := UpperCase(LKeyword);
                  LWord := UpperCase(LWord);
                end;
              end
              else
              if SelectionAvailable and (soHighlightSimilarTerms in FSelection.Options) then
              begin
                LTempTextPosition := FSelectionEndPosition;
                LSelectionBeginChar := FSelectionBeginPosition.Char;
                LSelectionEndChar := FSelectionEndPosition.Char;
                if LSelectionBeginChar > LSelectionEndChar then
                  SwapInt(LSelectionBeginChar, LSelectionEndChar);
                LTempTextPosition.Char := LSelectionEndChar - 1;
                if LTokenText = GetWordAtRowColumn(LTempTextPosition) then
                  LKeyWord := Copy(FLines[FSelectionBeginPosition.Line - 1], LSelectionBeginChar, LSelectionEndChar -
                    LSelectionBeginChar);
              end;
              if (LKeyword <> '') and (LKeyword = LWord) then
              begin
                LIsCustomBackgroundColor := True;
                if FSearch.Highlighter.Colors.Foreground <> clNone then
                  LForegroundColor := FSearch.Highlighter.Colors.Foreground;
                LBackgroundColor := FSearch.Highlighter.Colors.Background;
              end;

              PrepareTokenHelper(LTokenText, LTokenPosition, LTokenLength, LForegroundColor, LBackgroundColor, LStyle,
                LMatchingPairUnderline)
            end
            else
              PrepareTokenHelper(LTokenText, LTokenPosition, LTokenLength, LForegroundColor, LBackgroundColor, Font.Style,
                False);
          end;
          FHighlighter.Next;
        end;

        PaintHighlightToken(True);

        if not AMinimap then
        begin
          if FCodeFolding.Visible then
            LFoldRange := CodeFoldingCollapsableFoldRangeForLine(RowToLine(LCurrentLine))
          else
            LFoldRange := nil;
          PaintCodeFoldingCollapseMark(LFoldRange, LTokenPosition, LTokenLength, LCurrentLine, LScrolledXBy, LLineRect);
          PaintSpecialChars(LCurrentLine, LScrolledXBy, LLineRect);
          PaintCodeFoldingCollapsedLine(LFoldRange, LLineRect);
        end;

        PaintGuides(LCurrentLine, LScrolledXBy, LLineRect, AMinimap);

        if Assigned(FOnAfterLinePaint) then
          FOnAfterLinePaint(Self, Canvas, LLineRect, RowToLine(LCurrentLine), AMinimap);
      end;
    end;
    LIsCurrentLine := False;
  end;

begin
  { Retrieve lines associated with rows }
  LFirstLine := RowToLine(AFirstRow);
  LLastLine := RowToLine(ALastRow);

  { WordWrap always start from first column }
  if GetWordWrap then
    AFirstColumn := 1;

  FTextOffset := FLeftMargin.GetWidth + FCodeFolding.GetWidth + 2 - (LeftChar - 1) * FCharWidth;

  if LLastLine >= LFirstLine then
  begin
    SetDrawingColors(False);
    ComputeSelectionInfo;
    PaintLines;
  end;

  { If there is anything visible below the last line, then fill this as well }
  LTokenRect := AClipRect;

  if AMinimap then
  begin
    ALastRow := Min(GetDisplayLineCount, Max(FMinimap.TopLine, 1) + ((AClipRect.Bottom-AClipRect.Top) div FMinimap.CharHeight) - 1);
    LTokenRect.Top := (ALastRow - FMinimap.TopLine + 1) * FMinimap.CharHeight
  end
  else
    LTokenRect.Top := (ALastRow - TopLine + 1) * LineHeight;

  if LTokenRect.Top < LTokenRect.Bottom then
  begin
    LBackgroundColor := GetBackgroundColor;
    SetDrawingColors(False);
    Canvas.FillRect(LTokenRect);
  end;

  if not AMinimap then
    if FRightMargin.Visible then
    begin
      LRightMarginPosition := FTextOffset + FRightMargin.Position * FTextDrawer.CharWidth;
      if (LRightMarginPosition >= AClipRect.Left) and (LRightMarginPosition <= AClipRect.Right) then
      begin
        Canvas.Pen.Color := FRightMargin.Colors.Edge;
        Canvas.MoveTo(LRightMarginPosition, 0);
        Canvas.LineTo(LRightMarginPosition, Height);
      end;
    end;
end;

procedure TBCBaseEditor.RecalculateCharExtent;
const
  LFontStyles: array [0 .. 3] of TFontStyles = ([], [fsItalic], [fsBold], [fsItalic, fsBold]);
var
  LHasStyle: array [0 .. 3] of Boolean;
  i, j: Integer;
  LCurrentFontStyle: TFontStyles;
begin
  FillChar(LHasStyle, SizeOf(LHasStyle), 0);
  if Assigned(FHighlighter) and (FHighlighter.Attributes.Count > 0) then
  begin
    for i := 0 to FHighlighter.Attributes.Count - 1 do
    begin
      LCurrentFontStyle := FHighlighter.Attribute[i].Style * [fsItalic, fsBold];
      for j := 0 to 3 do
        if LCurrentFontStyle = LFontStyles[j] then
        begin
          LHasStyle[j] := True;
          Break;
        end;
    end;
  end
  else
  begin
    LCurrentFontStyle := Font.Style * [fsItalic, fsBold];
    for i := 0 to 3 do
      if LCurrentFontStyle = LFontStyles[i] then
      begin
        LHasStyle[i] := True;
        Break;
      end;
  end;

  FTextHeight := 0;
  FCharWidth := 0;
  FTextDrawer.BaseFont := Self.Font;
  for i := 0 to 3 do
    if LHasStyle[i] then
    begin
      FTextDrawer.BaseStyle := LFontStyles[i];
      FTextHeight := Max(FTextHeight, FTextDrawer.CharHeight);
      FCharWidth := Max(FCharWidth, FTextDrawer.CharWidth);
    end;
  Inc(FTextHeight, ExtraLineSpacing);
end;

procedure TBCBaseEditor.RedoItem;
var
  LUndoItem: TBCEditorUndoItem;
  LRun, LStrToDelete: PChar;
  LLength: Integer;
  LTempString: string;
  LTextPosition: TBCEditorTextPosition;
  LChangeScrollPastEndOfLine: Boolean;
  LBeginX: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  LChangeScrollPastEndOfLine := not (soPastEndOfLine in FScroll.Options);
  LUndoItem := FRedoList.PopItem;
  if Assigned(LUndoItem) then
  try
    FSelection.ActiveMode := LUndoItem.ChangeSelectionMode;
    IncPaintLock;
    FScroll.Options := FScroll.Options + [soPastEndOfLine];
    FUndoList.InsideRedo := True;
    case LUndoItem.ChangeReason of
      crCaret:
        begin
          FUndoList.AddChange(LUndoItem.ChangeReason, CaretPosition, CaretPosition, '', FSelection.ActiveMode);
          InternalCaretPosition := LUndoItem.ChangeStartPosition;
        end;
      crSelection:
        begin
          FUndoList.AddChange(LUndoItem.ChangeReason, SelectionBeginPosition, SelectionEndPosition, '', FSelection.ActiveMode);
          SetCaretAndSelection(CaretPosition, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition);
        end;
      crInsert, crPaste, crDragDropInsert:
        begin
          SetCaretAndSelection(LUndoItem.ChangeStartPosition, LUndoItem.ChangeStartPosition, LUndoItem.ChangeStartPosition);
          SetSelectedTextPrimitive(LUndoItem.ChangeSelectionMode, PChar(LUndoItem.ChangeString), False);
          InternalCaretPosition := LUndoItem.ChangeEndPosition;
          FUndoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition,
            SelectedText, LUndoItem.ChangeSelectionMode);
          if LUndoItem.ChangeReason = crDragDropInsert then
            SetCaretAndSelection(LUndoItem.ChangeStartPosition, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition);
        end;
      crDeleteAfterCursor, crSilentDeleteAfterCursor:
        begin
          SetCaretAndSelection(LUndoItem.ChangeStartPosition, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition);
          LTempString := SelectedText;
          SetSelectedTextPrimitive(LUndoItem.ChangeSelectionMode, PChar(LUndoItem.ChangeString), False);
          FUndoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition,
            LTempString, LUndoItem.ChangeSelectionMode);
          InternalCaretPosition := LUndoItem.ChangeEndPosition;
        end;
      crDelete, crSilentDelete:
        begin
          SetCaretAndSelection(LUndoItem.ChangeStartPosition, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition);
          FUndoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition,
            LTempString, LUndoItem.ChangeSelectionMode);
          InternalCaretPosition := LUndoItem.ChangeStartPosition;
        end;
      crLineBreak:
        begin
          LTextPosition := LUndoItem.ChangeStartPosition;
          SetCaretAndSelection(LTextPosition, LTextPosition, LTextPosition);
          CommandProcessor(ecLineBreak, BCEDITOR_CARRIAGE_RETURN, nil);
        end;
      crIndent:
        begin
          SetCaretAndSelection(LUndoItem.ChangeEndPosition, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition);
          FUndoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition,
            LUndoItem.ChangeString, LUndoItem.ChangeSelectionMode);
        end;
      crUnindent:
        begin
          LStrToDelete := PChar(LUndoItem.ChangeString);
          InternalCaretY := LUndoItem.ChangeStartPosition.Line;
          if LUndoItem.ChangeSelectionMode = smColumn then
            LBeginX := Min(LUndoItem.ChangeStartPosition.Char, LUndoItem.ChangeEndPosition.Char)
          else
            LBeginX := 1;
          repeat
            LRun := GetEndOfLine(LStrToDelete);
            if LRun <> LStrToDelete then
            begin
              LLength := LRun - LStrToDelete;
              if LLength > 0 then
              begin
                LTempString := FLines[CaretY - 1];
                Delete(LTempString, LBeginX, LLength);
                FLines[CaretY - 1] := LTempString;
              end;
            end
            else
              LLength := 0;
            if LRun^ = BCEDITOR_CARRIAGE_RETURN then
            begin
              Inc(LRun);
              if LRun^ = BCEDITOR_LINEFEED then
                Inc(LRun);
              Inc(FCaretY);
            end;
            LStrToDelete := LRun;
          until LRun^ = BCEDITOR_NONE_CHAR;
          if LUndoItem.ChangeSelectionMode = smColumn then
            SetCaretAndSelection(LUndoItem.ChangeStartPosition, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition)
          else
          begin
            LTextPosition.Char := LUndoItem.ChangeStartPosition.Char - FTabs.Width;
            LTextPosition.Line := LUndoItem.ChangeStartPosition.Line;
            SetCaretAndSelection(LTextPosition, LTextPosition, GetTextPosition(LUndoItem.ChangeEndPosition.Char -
              LLength, LUndoItem.ChangeEndPosition.Line));
          end;
          FUndoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition,
            LUndoItem.ChangeString, LUndoItem.ChangeSelectionMode);
        end;
      crCollapseFold:
        begin
          LCodeFoldingRange := nil;
          if Assigned(LUndoItem.ChangeData) then
            LCodeFoldingRange := TBCEditorCodeFoldingRange(LUndoItem.ChangeData);
          if Assigned(LCodeFoldingRange) and (LCodeFoldingRange.FromLine > 0) then
          begin
            CodeFoldingUncollapse(LCodeFoldingRange, False);
            FUndoList.AddChange(crUncollapseFold, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition, '',
              LUndoItem.ChangeSelectionMode, LCodeFoldingRange);
          end;
        end;
      crUncollapseFold:
        begin
          LCodeFoldingRange := nil;
          if Assigned(LUndoItem.ChangeData) then
            LCodeFoldingRange := TBCEditorCodeFoldingRange(LUndoItem.ChangeData);
          if Assigned(LCodeFoldingRange) and (LCodeFoldingRange.FromLine > 0) then
          begin
            CodeFoldingCollapse(LCodeFoldingRange, False);
            FUndoList.AddChange(crCollapseFold, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition, '',
              LUndoItem.ChangeSelectionMode, LCodeFoldingRange);
          end;
        end;
    end;
  finally
    FUndoList.InsideRedo := False;
    if LChangeScrollPastEndOfLine then
      FScroll.Options := FScroll.Options - [soPastEndOfLine];
    LUndoItem.Free;
    DecPaintLock;
  end;
end;

procedure TBCBaseEditor.RepaintGuides;
var
  LCurrentLine, LScrolledXBy: Integer;
  LLineRect: TRect;
begin
  if csDestroying in ComponentState then
    Exit;
  if not FCodeFolding.Visible then
    Exit;
  try
    HideCaret;
    LLineRect.Left := FLeftMargin.GetWidth + FCodeFolding.Width;
    LLineRect.Right := LLineRect.Left + CharsInWindow * CharWidth;
    LLineRect.Top := 0;
    LLineRect.Bottom := GetLineHeight;
    LScrolledXBy := (LeftChar - 1) * CharWidth;
    for LCurrentLine := RowToLine(TopLine) to RowToLine(TopLine) + VisibleLines do
    begin
      PaintGuides(LCurrentLine, LScrolledXBy, LLineRect, False);
      LLineRect.Top := LLineRect.Bottom;
      Inc(LLineRect.Bottom, GetLineHeight);
    end;
  finally
    UpdateCaret;
  end;
end;

procedure TBCBaseEditor.ResetCaret(DoUpdate: Boolean = True);
var
  LCaretStyle: TBCEditorCaretStyle;
  LWidth, LHeight: Integer;
begin
  { CreateCaret automatically destroys the previous one, so we don't have to
    worry about cleaning up the old one here with DestroyCaret.
    Ideally, we will have properties that control what these two carets look like. }
  if InsertMode then
    LCaretStyle := FCaret.Styles.Insert
  else
    LCaretStyle := FCaret.Styles.Overwrite;
  LHeight := 1;
  LWidth := 1;
  FCaretOffset := Point(FCaret.Offsets.X, FCaret.Offsets.Y);
  case LCaretStyle of
    csHorizontalLine, csThinHorizontalLine:
      begin
        LWidth := FCharWidth;
        if LCaretStyle = csHorizontalLine then
          LHeight := 2;
        FCaretOffset.Y := FCaretOffset.Y + LineHeight;
      end;
    csHalfBlock:
      begin
        LWidth := FCharWidth;
        LHeight := LineHeight div 2;
        FCaretOffset.Y := FCaretOffset.Y + LHeight;
      end;
    csBlock:
      begin
        LWidth := FCharWidth;
        LHeight := LineHeight;
      end;
    csVerticalLine, csThinVerticalLine:
    begin
      if LCaretStyle = csVerticalLine then
        LWidth := 2;
      LHeight := LineHeight;
    end;
  end;
  Exclude(FStateFlags, sfCaretVisible);

  if Focused or FAlwaysShowCaret then
  begin
    CreateCaret(Handle, 0, LWidth, LHeight);
    if DoUpdate then
      UpdateCaret;
  end;
end;

procedure TBCBaseEditor.ScanMatchingPair;
var
  LLine, LTempPosition: Integer;
  LTextPosition: TBCEditorTextPosition;
  LFoldRange: TBCEditorCodeFoldingRange;
begin
  LTextPosition := CaretPosition;
  FCurrentMatchingPair := GetMatchingToken(LTextPosition, FCurrentMatchingPairMatch);
  if mpoHighlightAfterToken in FMatchingPair.Options then
    if (FCurrentMatchingPair = trNotFound) and (LTextPosition.Char > 1) then
    begin
      Dec(LTextPosition.Char);
      FCurrentMatchingPair := GetMatchingToken(LTextPosition, FCurrentMatchingPairMatch);
    end;
  if cfoHighlightMatchingPair in FCodeFolding.Options then
  begin
    LFoldRange := CodeFoldingCollapsableFoldRangeForLine(RowToLine(CaretY));
    if Assigned(LFoldRange) then
    begin
      if IsKeywordAtCursorPosition(nil, mpoHighlightAfterToken in FMatchingPair.Options) then
      begin
        FCurrentMatchingPair := trOpenAndCloseTokenFound;
        LTempPosition := Pos(LFoldRange.RegionItem.OpenToken, UpperCase(FLines[LFoldRange.FromLine - 1]));
        FCurrentMatchingPairMatch.OpenToken := System.Copy(FLines[LFoldRange.FromLine - 1], LTempPosition, Length(LFoldRange.RegionItem.OpenToken));
        FCurrentMatchingPairMatch.OpenTokenPos := GetTextPosition(LTempPosition, LFoldRange.FromLine);
        if not LFoldRange.Collapsed then
          LLine := LFoldRange.ToLine
        else
          LLine := LFoldRange.FromLine;
        LTempPosition := Pos(LFoldRange.RegionItem.CloseToken, UpperCase(FLines[LLine - 1]));
        FCurrentMatchingPairMatch.CloseToken := System.Copy(FLines[LLine - 1], LTempPosition, Length(LFoldRange.RegionItem.CloseToken));
        FCurrentMatchingPairMatch.CloseTokenPos := GetTextPosition(LTempPosition, LLine);
      end;
    end;
  end;
end;

procedure TBCBaseEditor.SetAlwaysShowCaret(const Value: Boolean);
begin
  if FAlwaysShowCaret <> Value then
  begin
    FAlwaysShowCaret := Value;
    if not (csDestroying in ComponentState) and not Focused then
    begin
      if Value then
        ResetCaret
      else
      begin
        HideCaret;
        Windows.DestroyCaret;
      end;
    end;
  end;
end;

procedure TBCBaseEditor.SetBreakWhitespace(Value: Boolean);
begin
  if FBreakWhitespace <> Value then
  begin
    FBreakWhitespace := Value;
    if GetWordWrap then
    begin
      FWordWrapHelper.Reset;
      Invalidate;
    end;
  end;
end;

procedure TBCBaseEditor.SetCaretPosition(const Value: TBCEditorTextPosition);
begin
  IncPaintLock;
  try
    SetCaretPosition(True, Value);
    if SelectionAvailable then
      InvalidateSelection;
    FSelectionBeginPosition.Char := FCaretX;
    FSelectionBeginPosition.Line := FCaretY;
    FSelectionEndPosition := FSelectionBeginPosition;
  finally
    DecPaintLock;
  end;
end;

procedure TBCBaseEditor.SetCaretPosition(CallEnsureCursorPositionVisible: Boolean; Value: TBCEditorTextPosition);
var
  LMaxX: Integer;
begin
  FCaretAtEndOfLine := False;

  if GetWordWrap then
    LMaxX := MaxInt
  else
    LMaxX := FScroll.MaxWidth + 1;

  if Value.Line > FLines.Count then
    Value.Line := FLines.Count;
  if Value.Line < 1 then
  begin
    Value.Line := 1;
    if not (soPastEndOfLine in FScroll.Options) then
      LMaxX := 1;
  end
  else
  if not (soPastEndOfLine in FScroll.Options) then
    LMaxX := Length(Lines[Value.Line - 1]) + 1;

  if (Value.Char > LMaxX) and (not (soPastEndOfLine in FScroll.Options) or not (soAutosizeMaxWidth in FScroll.Options)) then
    Value.Char := LMaxX;

  if Value.Char < 1 then
    Value.Char := 1;

  if (Value.Char <> FCaretX) or (Value.Line <> FCaretY) then
  begin
    FLastDisplayY := DisplayY;
    IncPaintLock;
    try
      if FCaretX <> Value.Char then
        FCaretX := Value.Char;
      if FCaretY <> Value.Line then
      begin
        if ActiveLine.Color <> clNone then
        begin
          InvalidateLine(FCaretY);
          InvalidateLine(Value.Line);
        end;
        FCaretY := Value.Line;
      end;
      if CallEnsureCursorPositionVisible then
        EnsureCursorPositionVisible;
      Include(FStateFlags, sfCaretChanged);
      Include(FStateFlags, sfScrollbarChanged);
    finally
      DecPaintLock;
    end;
  end;
end;

procedure TBCBaseEditor.SetInternalCaretPosition(const Value: TBCEditorTextPosition);
begin
  SetCaretPosition(True, Value);
end;

procedure TBCBaseEditor.SetName(const Value: TComponentName);
var
  LTextToName: Boolean;
begin
  LTextToName := (ComponentState * [csDesigning, csLoading] = [csDesigning]) and (TrimRight(Text) = Name);
  inherited SetName(Value);
  if LTextToName then
    Text := Value;
end;

procedure TBCBaseEditor.SetReadOnly(Value: Boolean);
begin
  if FReadOnly <> Value then
    FReadOnly := Value;
end;

procedure TBCBaseEditor.SetSelectedTextEmpty(const AChangeString: string = '');
var
  LBlockStartPosition, LUndoBeginPosition, LUndoEndPosition: TBCEditorTextPosition;
begin
  LUndoBeginPosition := SelectionBeginPosition;
  LUndoEndPosition := SelectionEndPosition;
  if AChangeString <> '' then
  begin
    LBlockStartPosition := SelectionBeginPosition;
    if FSelection.ActiveMode = smLine then
      LBlockStartPosition.Char := 1;
    FUndoList.BeginBlock;
  end;
  FUndoList.AddChange(crDelete, LUndoBeginPosition, LUndoEndPosition, GetSelectedText, FSelection.ActiveMode);
  SetSelectedTextPrimitive(AChangeString);
  if AChangeString <> '' then
  begin
    FUndoList.AddChange(crInsert, LBlockStartPosition, SelectionEndPosition, '', smNormal);
    FUndoList.EndBlock;
  end;
end;

procedure TBCBaseEditor.SetSelectedTextPrimitive(const Value: string);
begin
  SetSelectedTextPrimitive(FSelection.ActiveMode, PChar(Value), True);
end;

procedure TBCBaseEditor.SetSelectedTextPrimitive(APasteMode: TBCEditorSelectionMode; AValue: PChar; AAddToUndoList: Boolean);
var
  LBeginTextPosition, LEndTextPosition: TBCEditorTextPosition;
  LTempString: string;

  function IsWrappedRow(aLine, ARow: Integer): Boolean;
  begin
    if GetWordWrap then
      Result := FWordWrapHelper.LineToRealRow(aLine) <> ARow
    else
      Result := False;
  end;

  procedure DeleteSelection;
  var
    i: Integer;
    LMarkOffset: Integer;
    LFirstLine, LLastLine, LCurrentLine: Integer;
    LDeletePosition, LDisplayDeletePosition, LDeletePositionEnd, LDisplayDeletePositionEnd: Integer;
    LUpdateMarks: Boolean;
  begin
    LUpdateMarks := False;
    LMarkOffset := 0;
    case FSelection.ActiveMode of
      smNormal:
        begin
          if FLines.Count > 0 then
          begin
            LTempString := Copy(Lines[LBeginTextPosition.Line - 1], 1, LBeginTextPosition.Char - 1) +
              Copy(Lines[LEndTextPosition.Line - 1], LEndTextPosition.Char, MaxInt);
            FLines.DeleteLines(LBeginTextPosition.Line, Min(LEndTextPosition.Line - LBeginTextPosition.Line, FLines.Count -
              LBeginTextPosition.Line));
            FLines[LBeginTextPosition.Line - 1] := LTempString;
          end;
          LUpdateMarks := True;
          InternalCaretPosition := LBeginTextPosition;
        end;
      smColumn:
        begin
          if LBeginTextPosition.Char > LEndTextPosition.Char then
            SwapInt(LBeginTextPosition.Char, LEndTextPosition.Char);

          with TextToDisplayPosition(LBeginTextPosition, False) do
          begin
            LFirstLine := Row;
            LDisplayDeletePosition := Column;
          end;
          with TextToDisplayPosition(LEndTextPosition, False) do
          begin
            LLastLine := Row;
            LDisplayDeletePositionEnd := Column;
          end;

          //CodeFoldingExpandCollapsedLines(LBeginTextPosition.Line, LEndTextPosition.Line);

          for i := LFirstLine to LLastLine do
          begin
            with DisplayToTextPosition(GetDisplayPosition(LDisplayDeletePosition, i)) do
            begin
              LDeletePosition := Char;
              LCurrentLine := Line;
            end;
            CodeFoldingExpandCollapsedLine(LCurrentLine);

            LDeletePositionEnd := DisplayToTextPosition(GetDisplayPosition(LDisplayDeletePositionEnd, i)).Char;
            LTempString := FLines.List[LCurrentLine - 1].fString;
            Delete(LTempString, LDeletePosition, LDeletePositionEnd - LDeletePosition);
            FLines[LCurrentLine - 1] := LTempString;
          end;
          InternalCaretPosition := GetTextPosition(LBeginTextPosition.Char, FSelectionEndPosition.Line);
        end;
      smLine:
        begin
          FLines.DeleteLines(Pred(LBeginTextPosition.Line), (LEndTextPosition.Line - LBeginTextPosition.Line) + 1);
          InternalCaretPosition := GetTextPosition(1, LBeginTextPosition.Line);
          LUpdateMarks := True;
          LMarkOffset := 0;
        end;
    end;

    if LUpdateMarks then
      DoLinesDeleted(LBeginTextPosition.Line, LEndTextPosition.Line - LBeginTextPosition.Line + LMarkOffset, True);
  end;

  procedure InsertText;

    function CountLines(P: PChar): Integer;
    begin
      Result := 0;
      while P^ <> BCEDITOR_NONE_CHAR do
      begin
        if P^ = BCEDITOR_CARRIAGE_RETURN then
          Inc(P);
        if P^ = BCEDITOR_LINEFEED then
          Inc(P);
        Inc(Result);
        P := GetEndOfLine(P);
      end;
    end;

    function InsertNormal: Integer;
    var
      LLeftSide: string;
      LRightSide: string;
      LStr, LWhite: string;
      LStart: PChar;
      P: PChar;
      LIndented: Boolean;
    begin
      Result := 0;
      LLeftSide := Copy(LineText, 1, CaretX - 1);
      if CaretX - 1 > Length(LLeftSide) then
        LLeftSide := LLeftSide + StringOfChar(BCEDITOR_SPACE_CHAR, CaretX - 1 - Length(LLeftSide));
      LRightSide := Copy(LineText, CaretX, Length(LineText) - (CaretX - 1));

      LIndented := False;
      if (FLines.Count > 0) and (eoAutoIndent in fOptions) then
        LWhite := GetLeadingWhite(FLines.List^[Pred(FCaretY)].fString)
      else
        LWhite := '';

      { insert the first line of Value into current line }
      LStart := PChar(AValue);
      P := GetEndOfLine(LStart);
      if P^ <> BCEDITOR_NONE_CHAR then
      begin
        LStr := LLeftSide + Copy(AValue, 1, P - LStart);
        FLines[FCaretY - 1] := LStr;
        FLines.InsertLines(FCaretY, CountLines(P));
      end
      else
      begin
        LStr := LLeftSide + AValue + LRightSide;
        FLines[FCaretY - 1] := LStr;
      end;

      { insert left lines of Value }
      while P^ <> BCEDITOR_NONE_CHAR do
      begin
        if P^ = BCEDITOR_CARRIAGE_RETURN then
          Inc(P);
        if P^ = BCEDITOR_LINEFEED then
          Inc(P);
        Inc(FCaretY);
        LStart := P;
        P := GetEndOfLine(LStart);
        if P = LStart then
        begin
          if P^ <> BCEDITOR_NONE_CHAR then
            LStr := ''
          else
            LStr := LRightSide;
        end
        else
        begin
          SetString(LStr, LStart, P - LStart);
          if P^ = BCEDITOR_NONE_CHAR then
            LStr := LStr + LRightSide
        end;

        if (not IsStringAllWhite(LStr) and (GetLeadingExpandedLength(LStr, FTabs.Width) < GetLeadingExpandedLength(LWhite,
          FTabs.Width))) or LIndented then
        begin
          FLines[FCaretY - 1] := LWhite + LStr;
          LIndented := True;
        end
        else
          FLines[FCaretY - 1] := LStr;

        Inc(Result);
      end;
      FCaretX := 1 + Length(FLines[CaretY - 1]) - Length(LRightSide);
    end;

    function InsertColumn: Integer;
    var
      LStr: string;
      LStart: PChar;
      P: PChar;
      LLength: Integer;
      LFirstLine: Integer;
      LCurrentLine: Integer;
      LInsertPosition: Integer;
      LDisplayInsertPosition: Integer;
      LLineBreakPosition: TBCEditorTextPosition;
    begin
      Result := 0;

      with TextToDisplayPosition(CaretPosition, False) do
      begin
        LFirstLine := Row;
        LDisplayInsertPosition := Column;
      end;

      LStart := PChar(AValue);
      P := nil;
      repeat
        with DisplayToTextPosition(GetDisplayPosition(LDisplayInsertPosition, LFirstLine)) do
        begin
          LInsertPosition := Char;
          LCurrentLine := FCaretY;
        end;
        if IsWrappedRow(LCurrentLine, LFirstLine) then
        begin
          Inc(LFirstLine);
          Continue;
        end;

        P := GetEndOfLine(LStart);
        if P <> LStart then
        begin
          SetLength(LStr, P - LStart);
          Move(LStart^, LStr[1], (P - LStart) * SizeOf(Char));

          if LCurrentLine > FLines.Count then
          begin
            Inc(Result);

            if P - LStart > 0 then
            begin
              LLength := LInsertPosition - 1;
              if toTabsToSpaces in FTabs.Options then
                LTempString := StringOfChar(BCEDITOR_SPACE_CHAR, LLength)
              else
                LTempString := StringOfChar(BCEDITOR_TAB_CHAR, LLength div FTabs.Width) + StringOfChar(BCEDITOR_SPACE_CHAR,
                  LLength mod FTabs.Width);
              LTempString := LTempString + LStr;
            end
            else
              LTempString := '';

            FLines.Add('');

            { Reflect our changes in undo list }
            if AAddToUndoList then
            begin
              with LLineBreakPosition do
              begin
                Line := LCurrentLine - 1;
                Char := Length(Lines[LCurrentLine - 2]) + 1;
              end;
              FUndoList.AddChange(crLineBreak, LLineBreakPosition, LLineBreakPosition, '', smNormal);
            end;
          end
          else
          begin
            LTempString := FLines[LCurrentLine - 1];
            LLength := Length(LTempString);
            if (LLength < LInsertPosition) and (P - LStart > 0) then
              LTempString := LTempString + StringOfChar(BCEDITOR_SPACE_CHAR, LInsertPosition - LLength - 1) + LStr
            else
              Insert(LStr, LTempString, LInsertPosition);
          end;
          FLines[LCurrentLine - 1] := LTempString;

          if AAddToUndoList then
            FUndoList.AddChange(crPaste, GetTextPosition(CaretX, CaretY), GetTextPosition(CaretX + (P - LStart), CaretY),
              '', FSelection.ActiveMode);
        end;

        if P^ = BCEDITOR_CARRIAGE_RETURN then
        begin
          Inc(P);
          if P^ = BCEDITOR_LINEFEED then
            Inc(P);
          Inc(LFirstLine);
          Inc(FCaretY);
        end;
        LStart := P;
      until P^ = BCEDITOR_NONE_CHAR;
      Inc(FCaretX, Length(LStr));
    end;

    function InsertLine: Integer;
    var
      LStart: PChar;
      P: PChar;
      S: string;
      LIsAfterLine, LDoReplace, LDoCaretFix: Boolean;
    begin
      Result := 0;

      if FLines.Count = 0 then
        FLines.Add('');

      if FCaretX = 1 then
        LIsAfterLine := False
      else
        LIsAfterLine := FCaretX > FLines.AccessStringLength(FCaretY - 1);
      LDoReplace := FLines.AccessStringLength(FCaretY - 1) = 0;
      LDoCaretFix := False;

      { Insert strings }
      FCaretX := 1;
      LStart := PChar(AValue);
      repeat
        P := GetEndOfLine(LStart);
        if P <> LStart then
        begin
          SetLength(S, P - LStart);
          Move(LStart^, S[1], (P - LStart) * SizeOf(Char));
        end
        else
          S := '';

        if LDoReplace then
        begin
          LDoReplace := False;
          FLines[FCaretY - 1] := S;
          LDoCaretFix := True;
        end
        else
        begin
          FLines.Insert(FCaretY - 1 + Ord(LIsAfterLine), S);
          Inc(Result);
        end;

        Inc(FCaretY);

        if P^ = BCEDITOR_CARRIAGE_RETURN then
          Inc(P);
        if P^ = BCEDITOR_LINEFEED then
          Inc(P);
        LStart := P;
      until P^ = BCEDITOR_NONE_CHAR;

      if LDoCaretFix then
        FCaretX := Length(S) + 1;
    end;

  var
    I, LStartLine: Integer;
    LStartColumn: Integer;
    LInsertedLines: Integer;
  begin
    if Length(AValue) = 0 then
      Exit;

    LStartLine := CaretY;
    LStartColumn := CaretX;
    case APasteMode of
      smNormal:
        LInsertedLines := InsertNormal;
      smColumn:
        LInsertedLines := InsertColumn;
      smLine:
        LInsertedLines := InsertLine;
    else
      LInsertedLines := 0;
    end;

    { We delete selected based on the current selection mode, but paste
      what's on the clipboard according to what it was when copied.
      Update marks }
    if LInsertedLines > 0 then
    begin
      if ((APasteMode = smNormal) and (LStartColumn > 1)) or ((APasteMode = smLine) and (LStartColumn > 1)) then
        Inc(LStartLine);

      { Trim trailing spaces }
      if eoTrimTrailingSpaces in Options then
        for I := LStartLine to LStartLine + LInsertedLines do
          DoTrimTrailingSpaces(I);

      DoLinesInserted(LStartLine, LInsertedLines);
    end;

    { Force caret reset }
    InternalCaretPosition := CaretPosition;
    SelectionBeginPosition := CaretPosition;
    SelectionEndPosition := CaretPosition;
  end;

begin
  IncPaintLock;
  FLines.BeginUpdate;
  try
    LBeginTextPosition := SelectionBeginPosition;
    LEndTextPosition := SelectionEndPosition;
    if (LBeginTextPosition.Char <> LEndTextPosition.Char) or (LBeginTextPosition.Line <> LEndTextPosition.Line) then
    begin
      DeleteSelection;
      InternalCaretPosition := LBeginTextPosition;
      SelectionBeginPosition := LBeginTextPosition;
      SelectionEndPosition := LBeginTextPosition;
    end;
    if Assigned(AValue) and (AValue[0] <> BCEDITOR_NONE_CHAR) then
      InsertText;
    if CaretY < 1 then
      InternalCaretY := 1;
  finally
    FLines.EndUpdate;
    if (LBeginTextPosition.Char <> LEndTextPosition.Char) or (LBeginTextPosition.Line <> LEndTextPosition.Line) then
    begin
      SelectionBeginPosition := LBeginTextPosition;
      SelectionEndPosition := CaretPosition;
    end;
    DecPaintLock;
  end;
end;

procedure TBCBaseEditor.SetWantReturns(Value: Boolean);
begin
  FWantReturns := Value;
end;

procedure TBCBaseEditor.ShowCaret;
begin
  if FCaret.Visible and not FCaret.NonBlinking.Enabled and not (sfCaretVisible in FStateFlags) then
    if Windows.ShowCaret(Handle) then
      Include(FStateFlags, sfCaretVisible);
end;

procedure TBCBaseEditor.UndoItem;
var
  LUndoItem: TBCEditorUndoItem;
  LTempPosition: TBCEditorTextPosition;
  LTempText: string;
  LChangeScrollPastEndOfLine: Boolean;
  LBeginX: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  LChangeScrollPastEndOfLine := not (soPastEndOfLine in FScroll.Options);
  LUndoItem := FUndoList.PopItem;
  if Assigned(LUndoItem) then
  try
    FSelection.ActiveMode := LUndoItem.ChangeSelectionMode;
    IncPaintLock;
    FScroll.Options := FScroll.Options + [soPastEndOfLine];

    case LUndoItem.ChangeReason of
      crCaret:
        begin
          FRedoList.AddChange(LUndoItem.ChangeReason, CaretPosition, CaretPosition, '', FSelection.ActiveMode);
          InternalCaretPosition := LUndoItem.ChangeStartPosition;
        end;
      crSelection:
        begin
          FRedoList.AddChange(LUndoItem.ChangeReason, SelectionBeginPosition, SelectionEndPosition, '', FSelection.ActiveMode);
          SetCaretAndSelection(CaretPosition, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition);
        end;
      crInsert, crPaste, crDragDropInsert:
        begin
          SetCaretAndSelection(LUndoItem.ChangeStartPosition, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition);
          LTempText := SelectedText;
          SetSelectedTextPrimitive(LUndoItem.ChangeSelectionMode, PChar(LUndoItem.ChangeString), False);
          FRedoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition, LTempText,
            LUndoItem.ChangeSelectionMode);
          InternalCaretPosition := LUndoItem.ChangeStartPosition;
        end;
      crDeleteAfterCursor, crDelete, crSilentDelete, crSilentDeleteAfterCursor, crDeleteAll:
        begin
          if LUndoItem.ChangeSelectionMode = smColumn then
            LTempPosition := GetTextPosition(Min(LUndoItem.ChangeStartPosition.Char, LUndoItem.ChangeEndPosition.Char),
              Min(LUndoItem.ChangeStartPosition.Line, LUndoItem.ChangeEndPosition.Line))
          else
            LTempPosition := TBCEditorTextPosition(MinPoint(TPoint(LUndoItem.ChangeStartPosition),
              TPoint(LUndoItem.ChangeEndPosition)));
          if (LUndoItem.ChangeReason in [crDeleteAfterCursor, crSilentDeleteAfterCursor]) and
            (LTempPosition.Line > FLines.Count) then
          begin
            InternalCaretPosition := GetTextPosition(1, FLines.Count);
            FLines.Add('');
          end;
          CaretPosition := LTempPosition;
          SetSelectedTextPrimitive(LUndoItem.ChangeSelectionMode, PChar(LUndoItem.ChangeString), False);
          if LUndoItem.ChangeReason in [crDeleteAfterCursor, crSilentDeleteAfterCursor] then
            LTempPosition := LUndoItem.ChangeStartPosition
          else
            LTempPosition := LUndoItem.ChangeEndPosition;
          if LUndoItem.ChangeReason in [crSilentDelete, crSilentDeleteAfterCursor] then
            InternalCaretPosition := LTempPosition
          else
            SetCaretAndSelection(LTempPosition, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition);
          FRedoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition, '',
            LUndoItem.ChangeSelectionMode);
          if LUndoItem.ChangeReason = crDeleteAll then
          begin
            InternalCaretPosition := GetTextPosition(1, 1);
            FSelectionEndPosition := GetTextPosition(1, 1);
          end;
          EnsureCursorPositionVisible;
        end;
      crLineBreak:
        begin
          InternalCaretPosition := LUndoItem.ChangeStartPosition;
          if CaretY > 0 then
          begin
            LTempText := FLines.Strings[CaretY - 1];
            if (Length(LTempText) < CaretX - 1) and (LeftSpaceCount(LUndoItem.ChangeString) = 0) then
              LTempText := LTempText + StringOfChar(BCEDITOR_SPACE_CHAR, CaretX - 1 - Length(LTempText));
            ProperSetLine(CaretY - 1, LTempText + LUndoItem.ChangeString);
            FLines.Delete(LUndoItem.ChangeEndPosition.Line);
          end
          else
            ProperSetLine(CaretY - 1, LUndoItem.ChangeString);
          DoLinesDeleted(CaretY + 1, 1, True);
          FRedoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition, '',
            LUndoItem.ChangeSelectionMode);
        end;
      crIndent:
        begin
          SetCaretAndSelection(LUndoItem.ChangeEndPosition, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition);
          FRedoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition,
            LUndoItem.ChangeString, LUndoItem.ChangeSelectionMode);
        end;
      crUnindent:
        begin
          if LUndoItem.ChangeSelectionMode <> smColumn then
            InsertBlock(GetTextPosition(1, LUndoItem.ChangeStartPosition.Line),
              GetTextPosition(1, LUndoItem.ChangeEndPosition.Line), PChar(LUndoItem.ChangeString), False)
          else
          begin
            LBeginX := Min(LUndoItem.ChangeStartPosition.Char, LUndoItem.ChangeEndPosition.Char);
            InsertBlock(GetTextPosition(LBeginX, LUndoItem.ChangeStartPosition.Line),
              GetTextPosition(LBeginX, LUndoItem.ChangeEndPosition.Line), PChar(LUndoItem.ChangeString), False);
          end;
          SetCaretAndSelection(LUndoItem.ChangeStartPosition, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition);
          FRedoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition,
            LUndoItem.ChangeString, LUndoItem.ChangeSelectionMode);
        end;
      crCollapseFold:
        begin
          LCodeFoldingRange := nil;
          if Assigned(LUndoItem.ChangeData) then
            LCodeFoldingRange := TBCEditorCodeFoldingRange(LUndoItem.ChangeData);
          if Assigned(LCodeFoldingRange) and (LCodeFoldingRange.FromLine > 0) then
          begin
            CodeFoldingUncollapse(LCodeFoldingRange, False);
            FRedoList.AddChange(crUncollapseFold, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition, '',
              LUndoItem.ChangeSelectionMode, LCodeFoldingRange);
          end;
        end;
      crUncollapseFold:
        begin
          LCodeFoldingRange := nil;
          if Assigned(LUndoItem.ChangeData) then
            LCodeFoldingRange := TBCEditorCodeFoldingRange(LUndoItem.ChangeData);
          if Assigned(LCodeFoldingRange) and (LCodeFoldingRange.FromLine > 0) then
          begin
            CodeFoldingCollapse(LCodeFoldingRange, False);
            FRedoList.AddChange(crCollapseFold, LUndoItem.ChangeStartPosition, LUndoItem.ChangeEndPosition, '',
              LUndoItem.ChangeSelectionMode, LCodeFoldingRange);
          end;
        end;
    end;
  finally
    if LChangeScrollPastEndOfLine then
      FScroll.Options := FScroll.Options - [soPastEndOfLine];
    LUndoItem.Free;
    DecPaintLock;
  end;
end;

procedure TBCBaseEditor.UpdateMouseCursor;
var
  LCursorPoint: TPoint;
  LTextPosition: TBCEditorTextPosition;
  LNewCursor: TCursor;
begin
  Windows.GetCursorPos(LCursorPoint);
  LCursorPoint := ScreenToClient(LCursorPoint);
  if LCursorPoint.X < FLeftMargin.GetWidth + FCodeFolding.GetWidth then
    SetCursor(Screen.Cursors[FLeftMargin.Cursor])
  else
  if FMinimap.Visible and (LCursorPoint.X > ClientRect.Right-ClientRect.Left - FMinimap.GetWidth - FSearch.Map.GetWidth) then
    SetCursor(Screen.Cursors[crArrow])  // TODO: Option?
  else
  begin
    LTextPosition := DisplayToTextPosition(PixelsToRowColumn(LCursorPoint.X, LCursorPoint.Y));
    if (eoDragDropEditing in FOptions) and not MouseCapture and IsPointInSelection(LTextPosition) then
      LNewCursor := crArrow
    else
    if FRightMargin.Moving or FRightMargin.MouseOver then
      LNewCursor := crHSplit
    else
    if FMouseOverURI then
      LNewCursor := crHandPoint
    else
    if FCodeFolding.MouseOverHint then
      LNewCursor := FCodeFolding.Hint.Cursor
    else
      LNewCursor := Cursor;
    FKeyboardHandler.ExecuteMouseCursor(Self, LTextPosition, LNewCursor);
    SetCursor(Screen.Cursors[LNewCursor]);
  end;
end;

{ Public declarations }

function TBCBaseEditor.CaretInView: Boolean;
var
  LDisplayPosition: TBCEditorDisplayPosition;
begin
  LDisplayPosition := DisplayPosition;
  Result := (LDisplayPosition.Column >= LeftChar) and (LDisplayPosition.Column <= LeftChar + CharsInWindow) and
    (LDisplayPosition.Row >= TopLine) and (LDisplayPosition.Row <= TopLine + VisibleLines);
end;

function TBCBaseEditor.CreateFileStream(AFileName: string): TStream;
begin
  Result := TFileStream.Create(GetHighlighterFileName(AFileName), fmOpenRead);
end;

function TBCBaseEditor.DisplayToTextPosition(const ADisplayPosition: TBCEditorDisplayPosition): TBCEditorTextPosition;
var
  s: string;
  i, L, X: Integer;
begin
  if GetWordWrap then
    Result := FWordWrapHelper.DisplayToTextPosition(ADisplayPosition)
  else
    Result := TBCEditorTextPosition(ADisplayPosition);

  if Result.Line <= FLines.Count then
  begin
    s := FLines[Result.Line - 1];
    l := Length(s);
    X := 0;
    i := 0;

    while X < Result.Char  do
    begin
      Inc(i);
      if (i <= l) and (s[i] = #9) then
        Inc(X, FTabs.Width)
      else
      if i <= l then
        Inc(X, FTextDrawer.GetCharCount(@s[i]))
      else
        Inc(X);
    end;
    Result.Char := i;
  end;
end;

function TBCBaseEditor.GetColorsFileName(AFileName: string): string;
begin
  Result := Trim(ExtractFilePath(AFileName));
  if Result = '' then
    Result := FDirectories.Colors;
  if Trim(ExtractFilePath(Result)) = '' then
  {$WARN SYMBOL_PLATFORM OFF}
    Result := Format('%s%s', [IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)), Result]);
  Result := Format('%s%s', [IncludeTrailingBackslash(Result), ExtractFileName(AFileName)]);
  {$WARN SYMBOL_PLATFORM ON}
end;

function TBCBaseEditor.GetHighlighterFileName(AFileName: string): string;
begin
  Result := Trim(ExtractFilePath(AFileName));
  if Result = '' then
    Result := FDirectories.Highlighters;
  if Trim(ExtractFilePath(Result)) = '' then
  {$WARN SYMBOL_PLATFORM OFF}
    Result := Format('%s%s', [IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)), Result]);
  Result := Format('%s%s', [IncludeTrailingBackslash(Result), ExtractFileName(AFileName)]);
  {$WARN SYMBOL_PLATFORM ON}
end;

function TBCBaseEditor.FindPrevious: Boolean;
begin
  Result := False;
  if Trim(FSearch.SearchText) = '' then
    Exit;
  FSearch.Options := FSearch.Options + [soBackwards];
  if SearchText(FSearch.SearchText) = 0 then
  begin
    if soBeepIfStringNotFound in FSearch.Options then
      Beep;
    SelectionEndPosition := SelectionBeginPosition;
    CaretPosition := SelectionBeginPosition;
  end
  else
    Result := True;
end;

function TBCBaseEditor.FindNext: Boolean;
begin
  Result := False;
  if Trim(FSearch.SearchText) = '' then
    Exit;
  FSearch.Options := FSearch.Options - [soBackwards];
  if SearchText(FSearch.SearchText) = 0 then
  begin
    if soBeepIfStringNotFound in FSearch.Options then
      Beep;
    SelectionBeginPosition := SelectionEndPosition;
    CaretPosition := SelectionBeginPosition;
    if (CaretX = 1) and (CaretY = 1) then
    begin
      if soShowStringNotFound in FSearch.Options then
        DoSearchStringNotFoundDialog;
    end
    else
    if soShowSearchMatchNotFound in FSearch.Options then
      if DoSearchMatchNotFoundWraparoundDialog then
      begin
        CaretZero;
        Result := FindNext;
      end;
  end
  else
    Result := True;
end;

function TBCBaseEditor.GetBookmark(ABookmark: Integer; var X, Y: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  if Assigned(Marks) then
    for i := 0 to Marks.Count - 1 do
      if Marks[i].IsBookmark and (Marks[i].Index = ABookmark) then
      begin
        X := Marks[i].Char;
        Y := Marks[i].Line;
        Result := True;
        Exit;
      end;
end;

function TBCBaseEditor.GetPositionOfMouse(out ATextPosition: TBCEditorTextPosition): Boolean;
var
  LCursorPoint: TPoint;
begin
  Windows.GetCursorPos(LCursorPoint);
  LCursorPoint := ScreenToClient(LCursorPoint);
  if (LCursorPoint.X < 0) or (LCursorPoint.Y < 0) or (LCursorPoint.X > Self.Width) or (LCursorPoint.Y > Self.Height) then
  begin
    Result := False;
    Exit;
  end;
  ATextPosition := DisplayToTextPosition(PixelsToRowColumn(LCursorPoint.X, LCursorPoint.Y));
  Result := True;
end;

function TBCBaseEditor.GetWordAtPixels(X, Y: Integer): string;
begin
  Result := GetWordAtRowColumn(DisplayToTextPosition(PixelsToRowColumn(X, Y)));
end;

function TBCBaseEditor.IsBookmark(ABookmark: Integer): Boolean;
var
  X, Y: Integer;
begin
  Result := GetBookmark(ABookmark, X, Y);
end;

function TBCBaseEditor.IsPointInSelection(const ATextPosition: TBCEditorTextPosition): Boolean;
var
  LBeginTextPosition, LEndTextPosition: TBCEditorTextPosition;
begin
  LBeginTextPosition := SelectionBeginPosition;
  LEndTextPosition := SelectionEndPosition;
  if (ATextPosition.Line >= LBeginTextPosition.Line) and (ATextPosition.Line <= LEndTextPosition.Line) and
    ((LBeginTextPosition.Line <> LEndTextPosition.Line) or (LBeginTextPosition.Char <> LEndTextPosition.Char)) then
  begin
    if FSelection.ActiveMode = smLine then
      Result := True
    else
    if (FSelection.ActiveMode = smColumn) then
    begin
      if (LBeginTextPosition.Char > LEndTextPosition.Char) then
        Result := (ATextPosition.Char >= LEndTextPosition.Char) and (ATextPosition.Char < LBeginTextPosition.Char)
      else
      if (LBeginTextPosition.Char < LEndTextPosition.Char) then
        Result := (ATextPosition.Char >= LBeginTextPosition.Char) and (ATextPosition.Char < LEndTextPosition.Char)
      else
        Result := False;
    end
    else
      Result := ((ATextPosition.Line > LBeginTextPosition.Line) or (ATextPosition.Char >= LBeginTextPosition.Char)) and
        ((ATextPosition.Line < LEndTextPosition.Line) or (ATextPosition.Char < LEndTextPosition.Char));
  end
  else
    Result := False;
end;

function TBCBaseEditor.IsWordBreakChar(AChar: Char): Boolean;
begin
  Result := CharInSet(AChar, [BCEDITOR_NONE_CHAR .. BCEDITOR_SPACE_CHAR, '.', ',', ';', ':', '"', '''', '´', '`', '°',
    '^', '!', '?', '&', '$', '@', '§', '%', '#', '~', '[', ']', '(', ')', '{', '}', '<', '>', '-', '=', '+', '*', '/',
    '\', '|']);
end;

function TBCBaseEditor.IsWordChar(AChar: Char): Boolean;
begin
  Result := not IsWordBreakChar(AChar);
end;

function TBCBaseEditor.LineToRow(ALine: Integer): Integer;
begin
  if not GetWordWrap then
    Result := ALine
  else
    Result := FWordWrapHelper.LineToRow(ALine);
end;

function TBCBaseEditor.ReplaceText(const ASearchText: string; const AReplaceText: string): Integer;
var
  LStartTextPosition, LEndTextPosition: TBCEditorTextPosition;
  LCurrentTextPosition: TBCEditorTextPosition;
  LSearchLength, LReplaceLength, LSearchIndex, LFound: Integer;
  LCurrentLine: Integer;
  LIsBackward, LIsFromCursor: Boolean;
  LIsPrompt: Boolean;
  LIsReplaceAll, LIsDeleteLine: Boolean;
  LIsEndUndoBlock: Boolean;
  LActionReplace: TBCEditorReplaceAction;
  LResultOffset: Integer;

  function InValidSearchRange(First, Last: Integer): Boolean;
  begin
    Result := True;
    if (FSelection.ActiveMode = smNormal) or not (soSelectedOnly in FSearch.Options) then
    begin
      if ((LCurrentTextPosition.Line = LStartTextPosition.Line) and (First < LStartTextPosition.Char)) or
        ((LCurrentTextPosition.Line = LEndTextPosition.Line) and (Last > LEndTextPosition.Char)) then
        Result := False;
    end
    else
    if (FSelection.ActiveMode = smColumn) then
      Result := (First >= LStartTextPosition.Char) and (Last <= LEndTextPosition.Char) or
        (LEndTextPosition.Char - LStartTextPosition.Char < 1);
  end;

begin
  if not Assigned(FSearchEngine) then
    raise Exception.Create('Search engine has not been assigned');

  Result := 0;
  if Length(ASearchText) = 0 then
    Exit;
  LIsBackward := roBackwards in FReplace.Options;
  LIsPrompt := roPrompt in FReplace.Options;
  LIsReplaceAll := roReplaceAll in FReplace.Options;
  LIsDeleteLine := eraDeleteLine = FReplace.Action;
  LIsFromCursor := not (roEntireScope in FReplace.Options);
  if not SelectionAvailable then
    FReplace.Options := FReplace.Options - [roSelectedOnly];
  if roSelectedOnly in FReplace.Options then
  begin
    LStartTextPosition := SelectionBeginPosition;
    LEndTextPosition := SelectionEndPosition;
    if FSelection.ActiveMode = smLine then
    begin
      LStartTextPosition.Char := 1;
      LEndTextPosition.Char := Length(Lines[LEndTextPosition.Line - 1]) + 1;
    end
    else
    if FSelection.ActiveMode = smColumn then
      if LStartTextPosition.Char > LEndTextPosition.Char then
        SwapInt(LStartTextPosition.Char, LEndTextPosition.Char);
    if LIsBackward then
      LCurrentTextPosition := LEndTextPosition
    else
      LCurrentTextPosition := LStartTextPosition;
  end
  else
  begin
    LStartTextPosition.Char := 1;
    LStartTextPosition.Line := 1;
    LEndTextPosition.Line := FLines.Count;
    LEndTextPosition.Char := Length(Lines[LEndTextPosition.Line - 1]) + 1;
    if LIsFromCursor then
      if LIsBackward then
        LEndTextPosition := CaretPosition
      else
        LStartTextPosition := CaretPosition;
    if LIsBackward then
      LCurrentTextPosition := LEndTextPosition
    else
      LCurrentTextPosition := LStartTextPosition;
  end;
  FSearchEngine.Pattern := ASearchText;
  case FReplace.Engine of
    seNormal:
    begin
      TBCEditorNormalSearch(FSearchEngine).CaseSensitive := roCaseSensitive in FReplace.Options;
      TBCEditorNormalSearch(FSearchEngine).WholeWordsOnly := roWholeWordsOnly in FReplace.Options;
    end;
  end;
  LReplaceLength := 0;
  if LIsReplaceAll and not LIsPrompt then
  begin
    IncPaintLock;
    BeginUndoBlock;
    LIsEndUndoBlock := True;
  end
  else
    LIsEndUndoBlock := False;
  try
    while (LCurrentTextPosition.Line >= LStartTextPosition.Line) and (LCurrentTextPosition.Line <= LEndTextPosition.Line) do
    begin
      LCurrentLine := FSearchEngine.FindAll(Lines[LCurrentTextPosition.Line - 1]);
      LResultOffset := 0;
      if LIsBackward then
        LSearchIndex := Pred(FSearchEngine.ResultCount)
      else
        LSearchIndex := 0;
      while LCurrentLine > 0 do
      begin
        LFound := FSearchEngine.Results[LSearchIndex] + LResultOffset;
        LSearchLength := FSearchEngine.Lengths[LSearchIndex];
        if LIsBackward then
          Dec(LSearchIndex)
        else
          Inc(LSearchIndex);
        Dec(LCurrentLine);
        if not InValidSearchRange(LFound, LFound + LSearchLength) then
          Continue;
        Inc(Result);
        LCurrentTextPosition.Char := LFound;

        SelectionBeginPosition := LCurrentTextPosition;
        SetCaretPosition(False, GetTextPosition(1, LCurrentTextPosition.Line));
        EnsureCursorPositionVisible(True);
        Inc(LCurrentTextPosition.Char, LSearchLength);
        SelectionEndPosition := LCurrentTextPosition;

        if LIsBackward then
          InternalCaretPosition := SelectionBeginPosition
        else
          InternalCaretPosition := LCurrentTextPosition;

        if LIsPrompt and Assigned(FOnReplaceText) then
        begin
          LActionReplace := DoOnReplaceText(ASearchText, AReplaceText, LCurrentTextPosition.Line, LFound, LIsDeleteLine);
          if LActionReplace = raCancel then
            Exit;
        end
        else
          LActionReplace := raReplace;
        if LActionReplace = raSkip then
          Dec(Result)
        else
        begin
          if LActionReplace = raReplaceAll then
          begin
            if not LIsReplaceAll or LIsPrompt then
            begin
              LIsReplaceAll := True;
              IncPaintLock;
            end;
            LIsPrompt := False;
            if not LIsEndUndoBlock then
              BeginUndoBlock;
            LIsEndUndoBlock := True;
          end;
          if LIsDeleteLine then
          begin
            ExecuteCommand(ecDeleteLine, 'Y', nil);
            Dec(LCurrentTextPosition.Line);
          end
          else
          begin
            SelectedText := FSearchEngine.Replace(SelectedText, AReplaceText);
            LReplaceLength := CaretX - LFound;
          end
        end;
        if not LIsBackward then
        begin
          InternalCaretX := LFound + LReplaceLength;
          if (LSearchLength <> LReplaceLength) and (LActionReplace <> raSkip) then
          begin
            Inc(LResultOffset, LReplaceLength - LSearchLength);
            if (FSelection.ActiveMode <> smColumn) and (CaretY = LEndTextPosition.Line) then
            begin
              Inc(LEndTextPosition.Char, LReplaceLength - LSearchLength);
              SelectionEndPosition := LEndTextPosition;
            end;
          end;
        end;
        if not LIsReplaceAll then
          Exit;
      end;
      if LIsBackward then
        Dec(LCurrentTextPosition.Line)
      else
        Inc(LCurrentTextPosition.Line);
    end;
  finally
    if LIsReplaceAll and not LIsPrompt then
      DecPaintLock;
    if LIsEndUndoBlock then
      EndUndoBlock;
    if CanFocus then
      SetFocus;
  end;
end;

function TBCBaseEditor.SplitTextIntoWords(AStringList: TStrings; ACaseSensitive: Boolean): string;
var
  i, Line: Integer;
  LWord, LWordList: string;
  LStringList: TStringList;
  LKeywordStringList: TStringList;
  LTextPtr, LKeyWordPtr, LBookmarkTextPtr: PChar;
  LOpenTokenSkipFoldRangeList: TList;
  LSkipOpenKeyChars, LSkipCloseKeyChars: TBCEditorCharSet;

  procedure AddKeyChars;
  var
    i: Integer;

    procedure Add(var KeyChars: TBCEditorCharSet; KeyPtr: PChar);
    begin
      while KeyPtr^ <> BCEDITOR_NONE_CHAR do
      begin
        KeyChars := KeyChars + [KeyPtr^];
        Inc(KeyPtr);
      end;
    end;

  begin
    LSkipOpenKeyChars := [];
    LSkipCloseKeyChars := [];

    for i := 0 to FHighlighter.CompletionProposalSkipRegions.Count - 1 do
    begin
      Add(LSkipOpenKeyChars, PChar(FHighlighter.CompletionProposalSkipRegions[i].OpenToken));
      Add(LSkipCloseKeyChars, PChar(FHighlighter.CompletionProposalSkipRegions[i].CloseToken));
    end;
  end;

begin
  Result := '';
  AddKeyChars;
  AStringList.Clear;
  LKeywordStringList := TStringList.Create;
  LStringList := TStringList.Create;
  LOpenTokenSkipFoldRangeList := TList.Create;
  try
    for Line := 0 to FLines.Count - 1 do
    begin
      { add document words }
      LTextPtr := PChar(FLines[Line]);
      LWord := '';
      while LTextPtr^ <> BCEDITOR_NONE_CHAR do
      begin
        { Skip regions - Close }
        if (LOpenTokenSkipFoldRangeList.Count > 0) and CharInSet(LTextPtr^, LSkipCloseKeyChars) then
        begin
          LKeyWordPtr := PChar(TBCEditorSkipRegionItem(LOpenTokenSkipFoldRangeList.Last).CloseToken);
          LBookmarkTextPtr := LTextPtr;
          { check if the close keyword found }
          while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (LTextPtr^ = LKeyWordPtr^) do
          begin
            Inc(LTextPtr);
            Inc(LKeyWordPtr);
          end;
          if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then { if found, pop skip region from the list }
          begin
            LOpenTokenSkipFoldRangeList.Delete(LOpenTokenSkipFoldRangeList.Count - 1);
            Continue; { while TextPtr^ <> BCEDITOR_NONE_CHAR do }
          end
          else
            LTextPtr := LBookmarkTextPtr; { skip region close not found, return pointer back }
        end;

        { Skip regions - Open }
        if CharInSet(LTextPtr^, LSkipOpenKeyChars) then
        begin
          for i := 0 to FHighlighter.CompletionProposalSkipRegions.Count - 1 do
            if LTextPtr^ = PChar(FHighlighter.CompletionProposalSkipRegions[i].OpenToken)^ then { if the first character is a match }
            begin
              LKeyWordPtr := PChar(FHighlighter.CompletionProposalSkipRegions[i].OpenToken);
              LBookmarkTextPtr := LTextPtr;
              { check if the open keyword found }
              while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (LTextPtr^ = LKeyWordPtr^) do
              begin
                Inc(LTextPtr);
                Inc(LKeyWordPtr);
              end;
              if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then { if found, skip single line comment or push skip region into stack }
              begin
                if FHighlighter.CompletionProposalSkipRegions[i].RegionType = ritSingleLineComment then
                begin
                  { single line comment skip until next line }
                  while LTextPtr^ <> BCEDITOR_NONE_CHAR do
                    Inc(LTextPtr);
                end
                else
                  LOpenTokenSkipFoldRangeList.Add(FHighlighter.CompletionProposalSkipRegions[i]);
                Dec(LTextPtr); { the end of the while loop will increase }
                Break; { for i := 0 to BCEditor.Highlighter.CompletionProposalSkipRegions... }
              end
              else
                LTextPtr := LBookmarkTextPtr; { skip region open not found, return pointer back }
            end;
        end;

        if LOpenTokenSkipFoldRangeList.Count = 0 then
        begin
          if (LWord = '') and CharInSet(LTextPtr^, BCEDITOR_VALID_STRING_CHARACTERS) or
            (LWord <> '') and CharInSet(LTextPtr^, BCEDITOR_VALID_STRING_CHARACTERS + BCEDITOR_NUMBERS) then
            LWord := LWord + LTextPtr^
          else
          begin
            if (LWord <> '') and (Length(LWord) > 1) then
              if Pos(LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED, LWordList) = 0 then { no duplicates }
                LWordList := LWordList + LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
            LWord := ''
          end;
        end;
        if LTextPtr^ <> BCEDITOR_NONE_CHAR then
          Inc(LTextPtr);
      end;
      if (LWord <> '') and (Length(LWord) > 1) then
        if Pos(LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED, LWordList) = 0 then { no duplicates }
          LWordList := LWordList + LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
    end;
    { add highlighter keywords }
    FHighlighter.AddKeywords(LKeywordStringList);
    for i := 0 to LKeywordStringList.Count - 1 do
    begin
      LWord := LKeywordStringList.Strings[i];
      if (Length(LWord) > 1) and CharInSet(LWord[1], BCEDITOR_VALID_STRING_CHARACTERS) then
        if Pos(LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED, LWordList) = 0 then { no duplicates }
          LWordList := LWordList + LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
    end;
    LStringList.Text := LWordList;
    LStringList.Sort;
    AStringList.Assign(LStringList);
  finally
    LStringList.Free;
    LOpenTokenSkipFoldRangeList.Free;
    LKeywordStringList.Free;
  end;
end;

function TBCBaseEditor.TextToDisplayPosition(const ATextPosition: TBCEditorTextPosition; ACollapsedLineNumber: Boolean = True;
  ARealWidth: Boolean = True): TBCEditorDisplayPosition;
var
  i: Integer;
  s: string;
  L, X: Integer;
begin
  Result := TBCEditorDisplayPosition(ATextPosition);

  if not GetWordWrap then
  begin
    if ACollapsedLineNumber then
      Result.Row := GetCollapsedLineNumber(Result.Row)
    else
      Result.Row := ATextPosition.Line
  end;

  if ATextPosition.Line - 1 < FLines.Count then
  begin
    s := FLines[ATextPosition.Line - 1];
    l := Length(s);
    X := 0;
    for i := 1 to ATextPosition.Char - 1 do
    begin
      if (i <= l) and (s[i] = BCEDITOR_TAB_CHAR) then
        Inc(X, FTabs.Width)
      else
      if ARealWidth and (i <= l) and (s[i] <> BCEDITOR_SPACE_CHAR) and (s[i] <> '') then
        Inc(X, FTextDrawer.GetCharCount(@s[i]))
      else
        Inc(X);
    end;
    Result.Column := X + 1;
  end;

  if GetWordWrap then
    Result := FWordWrapHelper.TextToDisplayPosition(TBCEditorTextPosition(Result));
end;

function TBCBaseEditor.WordEnd: TBCEditorTextPosition;
begin
  Result := WordEnd(CaretPosition);
end;

function TBCBaseEditor.WordEnd(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition;
var
  X, Y: Integer;
  LLine: string;
begin
  X := ATextPosition.Char;
  Y := ATextPosition.Line;
  if (X >= 1) and (Y <= FLines.Count) then
  begin
    LLine := FLines[Y - 1];
    X := StringScan(LLine, X, IsWordBreakChar);
    if X = 0 then
      X := Length(LLine) + 1;
  end;
  Result.Char := X;
  Result.Line := Y;
end;

function TBCBaseEditor.WordStart: TBCEditorTextPosition;
begin
  Result := WordStart(CaretPosition);
end;

function TBCBaseEditor.WordStart(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition;
var
  X, Y: Integer;
  LLine: string;
begin
  X := ATextPosition.Char;
  Y := ATextPosition.Line;

  if (Y >= 1) and (Y <= FLines.Count) then
  begin
    LLine := FLines[Y - 1];
    X := Min(X, Length(LLine) + 1);

    if X > 1 then
      if not IsWordBreakChar(LLine[X - 1]) then
        X := StringReverseScan(LLine, X - 1, IsWordBreakChar) + 1
      else
        X := X - 1;
  end;
  Result.Char := X;
  Result.Line := Y;
end;

procedure TBCBaseEditor.AddFocusControl(aControl: TWinControl);
begin
  FFocusList.Add(aControl);
end;

procedure TBCBaseEditor.AddKeyCommand(ACommand: TBCEditorCommand; AKey1: Word; AShift1: TShiftState;
  AKey2: Word; AShift2: TShiftState);
var
  LKeyCommand: TBCEditorKeyCommand;
begin
  LKeyCommand := KeyCommands.Add;
  with LKeyCommand do
  begin
    Command := ACommand;
    Key := AKey1;
    Key2 := AKey2;
    ShiftState := AShift1;
    ShiftState2 := AShift2;
  end;
end;

procedure TBCBaseEditor.AddKeyDownHandler(AHandler: TKeyEvent);
begin
  FKeyboardHandler.AddKeyDownHandler(AHandler);
end;

procedure TBCBaseEditor.AddKeyPressHandler(AHandler: TBCEditorKeyPressWEvent);
begin
  FKeyboardHandler.AddKeyPressHandler(AHandler);
end;

procedure TBCBaseEditor.AddKeyUpHandler(AHandler: TKeyEvent);
begin
  FKeyboardHandler.AddKeyUpHandler(AHandler);
end;

procedure TBCBaseEditor.AddMouseCursorHandler(AHandler: TBCEditorMouseCursorEvent);
begin
  FKeyboardHandler.AddMouseCursorHandler(AHandler);
end;

procedure TBCBaseEditor.AddMouseDownHandler(AHandler: TMouseEvent);
begin
  FKeyboardHandler.AddMouseDownHandler(AHandler);
end;

procedure TBCBaseEditor.AddMouseUpHandler(AHandler: TMouseEvent);
begin
  FKeyboardHandler.AddMouseUpHandler(AHandler);
end;

procedure TBCBaseEditor.BeginUndoBlock;
begin
  FUndoList.BeginBlock;
end;

procedure TBCBaseEditor.BeginUpdate;
begin
  IncPaintLock;
end;

procedure TBCBaseEditor.CaretZero;
begin
  CaretX := 0;
  CaretY := 0;
end;

procedure TBCBaseEditor.ChainEditor(AEditor: TBCBaseEditor);
begin
  HookEditorLines(AEditor.Lines, AEditor.UndoList, AEditor.RedoList);

  FChainedEditor := AEditor;
  AEditor.FreeNotification(Self);
end;

procedure TBCBaseEditor.Clear;
begin
  UpdateWordWrapHiddenOffsets;
  FLines.Clear;
  FMarkList.Clear;
  FillChar(FBookmarks, SizeOf(FBookmarks), 0);
  FUndoList.Clear;
  FRedoList.Clear;
  Modified := False;
end;

procedure TBCBaseEditor.ClearBookmark(ABookmark: Integer);
begin
  if (ABookmark in [0 .. 8]) and Assigned(FBookmarks[ABookmark]) then
  begin
    DoOnBeforeClearBookmark(FBookmarks[ABookmark]);
    FMarkList.Remove(FBookmarks[ABookmark]);
    FBookmarks[ABookmark] := nil;
    DoOnAfterClearBookmark;
  end
end;

procedure TBCBaseEditor.ClearBookmarks;
var
  i: Integer;
begin
  for i := 0 to Length(FBookmarks) - 1 do
    if Assigned(FBookmarks[i]) then
      ClearBookmark(i);
end;

procedure TBCBaseEditor.ClearCodeFolding;
begin
  FAllCodeFoldingRanges.ClearAll;
  SetLength(FCollapsedLinesDifferenceCache, 0);
end;

procedure TBCBaseEditor.ClearMatchingPair;
begin
  FCurrentMatchingPair := trNotFound;
end;

procedure TBCBaseEditor.ClearSelection;
begin
  if SelectionAvailable then
    SelectedText := '';
end;

procedure TBCBaseEditor.ClearUndo;
begin
  FUndoList.Clear;
  FRedoList.Clear;
end;

procedure TBCBaseEditor.CodeFoldingCollapseAll;
var
  i: Integer;
begin
  FLines.BeginUpdate;

  for i := 9 downto 0 do
    CodeFoldingCollapseLevel(i);

  FLines.EndUpdate;
  UpdateScrollbars;
end;

procedure TBCBaseEditor.CodeFoldingCollapseLevel(ALevel: Integer);
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  FLines.BeginUpdate;

  for i := FAllCodeFoldingRanges.AllCount - 1 downto 0 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if (LCodeFoldingRange.FoldRangeLevel = ALevel) and (not LCodeFoldingRange.Collapsed) and
      (not LCodeFoldingRange.ParentCollapsed) and LCodeFoldingRange.Collapsable then
      CodeFoldingCollapse(LCodeFoldingRange);
  end;

  FLines.EndUpdate;
  InvalidateLeftMargin;
end;

procedure TBCBaseEditor.CodeFoldingUncollapseAll;
var
  i: Integer;
  LBlockBeginPosition, LBlockEndPosition: TBCEditorTextPosition;
begin
  LBlockBeginPosition.Char := FSelectionBeginPosition.Char;
  LBlockBeginPosition.Line := GetUncollapsedLineNumber(FSelectionBeginPosition.Line);
  LBlockEndPosition.Char := FSelectionEndPosition.Char;
  LBlockEndPosition.Line := GetUncollapsedLineNumber(FSelectionEndPosition.Line);

  FLines.BeginUpdate;
  for i := 0 to 9 do
    CodeFoldingUncollapseLevel(i, False);
  FLines.EndUpdate;

  FSelectionBeginPosition := LBlockBeginPosition;
  FSelectionEndPosition := LBlockEndPosition;

  UpdateScrollbars;
end;

procedure TBCBaseEditor.CodeFoldingUncollapseLevel(ALevel: Integer; ANeedInvalidate: Boolean);
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  SetLength(FCollapsedLinesDifferenceCache, 0);
  for i := FAllCodeFoldingRanges.AllCount - 1 downto 0 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if (LCodeFoldingRange.FoldRangeLevel = ALevel) and LCodeFoldingRange.Collapsed and
      not LCodeFoldingRange.ParentCollapsed then
      CodeFoldingUncollapse(LCodeFoldingRange);
  end;
  if ANeedInvalidate then
    InvalidateLeftMargin;
end;

procedure TBCBaseEditor.CommandProcessor(ACommand: TBCEditorCommand; AChar: Char; AData: Pointer);
var
  i, LCollapsedCount: Integer;
  LOldSelectionBeginPosition, LOldSelectionEndPosition: TBCEditorTextPosition;

  function CodeFoldingUncollapseLine(ALine: Integer): Integer;
  var
    LCodeFoldingRange: TBCEditorCodeFoldingRange;
  begin
    Result := 0;
    if ALine < Length(FCodeFoldingRangeForLine) then
    begin
      LCodeFoldingRange := FCodeFoldingRangeForLine[ALine];
      if Assigned(LCodeFoldingRange) then
        if LCodeFoldingRange.Collapsed then
        begin
          Result := LCodeFoldingRange.CollapsedLines.Count - 1;
          CodeFoldingUncollapse(LCodeFoldingRange);
          LCodeFoldingRange.UndoListed := False;
        end;
    end;
  end;

begin
  { first the program event handler gets a chance to process the command }
  DoOnProcessCommand(ACommand, AChar, AData);
  if ACommand <> ecNone then
  begin
    { notify hooked command handlers before the command is executed inside of the class }
    NotifyHookedCommandHandlers(False, ACommand, AChar, AData);
    if (ACommand = ecCut) or (ACommand = ecDeleteLine) or
      ((ACommand = ecChar) or (ACommand = ecTab) or (ACommand = ecDeleteChar) or (ACommand = ecDeleteLastChar)) and IsKeywordAtCursorPosition or
      SelectionAvailable and (ACommand = ecLineBreak) or
      ((ACommand = ecChar) and CharInSet(AChar, FHighlighter.SkipOpenKeyChars + FHighlighter.SkipCloseKeyChars)) then
      FNeedToRescanCodeFolding := True;

    if FCodeFolding.Visible then
    case ACommand of
      ecDeleteLastChar, ecDeleteChar, ecDeleteWord, ecDeleteLastWord, ecDeleteLine, ecClear, ecLineBreak, ecChar,
      ecString, ecImeStr, ecCut, ecPaste, ecBlockIndent, ecBlockUnindent, ecTab:
        if SelectionAvailable then
        begin
          LOldSelectionBeginPosition := GetSelectionBeginPosition;
          LOldSelectionEndPosition := GetSelectionEndPosition;
          LCollapsedCount := 0;
          for i := LOldSelectionBeginPosition.Line to LOldSelectionEndPosition.Line do
            LCollapsedCount := LCollapsedCount + CodeFoldingUncollapseLine(i);
          FSelectionBeginPosition := LOldSelectionBeginPosition;
          FSelectionEndPosition := LOldSelectionEndPosition;
          FSelectionEndPosition.Line := FSelectionEndPosition.Line + LCollapsedCount
          // TODO: If last line was folded, set the selection char
        end
        else
          CodeFoldingUncollapseLine(CaretY);
    end;

    { internal command handler }
    if {(ACommand <> ecNone) and} (ACommand < ecUserFirst) then
      ExecuteCommand(ACommand, AChar, AData);

    { notify hooked command handlers after the command was executed inside of the class }
    //if ACommand <> ecNone then
    NotifyHookedCommandHandlers(True, ACommand, AChar, AData);
  end;
  DoOnCommandProcessed(ACommand, AChar, AData);
end;

procedure TBCBaseEditor.CopyToClipboard;
var
  LText: string;
  LChangeTrim: Boolean;
begin
  if SelectionAvailable then
  begin
    LChangeTrim := (FSelection.ActiveMode = smColumn) and (eoTrimTrailingSpaces in Options);
    try
      if LChangeTrim then
        Exclude(FOptions, eoTrimTrailingSpaces);
      LText := SelectedText;
    finally
      if LChangeTrim then
        Include(FOptions, eoTrimTrailingSpaces);
    end;
    DoCopyToClipboard(LText);
  end;
end;

procedure TBCBaseEditor.CutToClipboard;
begin
  CommandProcessor(ecCut, #0, nil);
end;

procedure TBCBaseEditor.DeleteWhitespace;
var
  LStrings: TStringList;
begin
  if Focused then
  begin
    if SelectionAvailable then
    begin
      LStrings := TStringList.Create;
      try
        LStrings.Text := SelectedText;
        SelectedText := BCEditor.Utils.DeleteWhiteSpace(LStrings.Text);
      finally
        LStrings.Free;
      end;
    end
    else
      Text := BCEditor.Utils.DeleteWhiteSpace(Text);
  end;
end;

procedure TBCBaseEditor.DoCutToClipboard;
begin
  if not ReadOnly and SelectionAvailable then
  begin
    BeginUndoBlock;
    try
      DoCopyToClipboard(SelectedText);
      SelectedText := '';
    finally
      EndUndoBlock;
    end;
  end;
end;

procedure TBCBaseEditor.DragDrop(Source: TObject; X, Y: Integer);
var
  LNewCaretPosition: TBCEditorTextPosition;
  LDoDrop, LDropAfter, LDropMove: Boolean;
  LSelectionBeginPosition, LSelectionEndPosition: TBCEditorTextPosition;
  LDragDropText: string;
  LChangeScrollPastEndOfLine: Boolean;
begin
  if not ReadOnly and (Source is TBCBaseEditor) and TBCBaseEditor(Source).SelectionAvailable then
  begin
    IncPaintLock;
    try
      inherited;
      ComputeCaret(X, Y);
      LNewCaretPosition := CaretPosition;

      if Source <> Self then
      begin
        LDropMove := GetKeyState(VK_SHIFT) < 0;
        LDoDrop := True;
        LDropAfter := False;
      end
      else
      begin
        LDropMove := GetKeyState(VK_CONTROL) >= 0;
        LSelectionBeginPosition := SelectionBeginPosition;
        LSelectionEndPosition := SelectionEndPosition;
        LDropAfter := (LNewCaretPosition.Line > LSelectionEndPosition.Line) or
          ((LNewCaretPosition.Line = LSelectionEndPosition.Line) and ((LNewCaretPosition.Char > LSelectionEndPosition.Char) or
          ((not LDropMove) and (LNewCaretPosition.Char = LSelectionEndPosition.Char))));
        LDoDrop := LDropAfter or (LNewCaretPosition.Line < LSelectionBeginPosition.Line) or
          ((LNewCaretPosition.Line = LSelectionBeginPosition.Line) and ((LNewCaretPosition.Char < LSelectionBeginPosition.Char) or
          ((not LDropMove) and (LNewCaretPosition.Char = LSelectionBeginPosition.Char))));
      end;
      if LDoDrop then
      begin
        BeginUndoBlock;
        try
          LDragDropText := TBCBaseEditor(Source).SelectedText;

          if LDropMove then
          begin
            if Source <> Self then
              TBCBaseEditor(Source).SelectedText := ''
            else
            begin
              SelectedText := '';
              if LDropAfter and (LNewCaretPosition.Line = LSelectionEndPosition.Line) then
                Dec(LNewCaretPosition.Char, LSelectionEndPosition.Char - LSelectionBeginPosition.Char);
              if LDropAfter and (LSelectionEndPosition.Line > LSelectionBeginPosition.Line) then
                Dec(LNewCaretPosition.Line, LSelectionEndPosition.Line - LSelectionBeginPosition.Line);
            end;
          end;

          LChangeScrollPastEndOfLine := not(soPastEndOfLine in FScroll.Options);
          try
            if LChangeScrollPastEndOfLine then
              FScroll.Options := FScroll.Options + [soPastEndOfLine];
            InternalCaretPosition := LNewCaretPosition;
            SelectionBeginPosition := LNewCaretPosition;

            Assert(not SelectionAvailable);
            LockUndo;
            try
              SelectedText := LDragDropText;
            finally
              UnlockUndo;
            end;
          finally
            if LChangeScrollPastEndOfLine then
              FScroll.Options := FScroll.Options - [soPastEndOfLine];
          end;
          if Source = Self then
            FUndoList.AddChange(crDragDropInsert, LNewCaretPosition, SelectionEndPosition, SelectedText, FSelection.ActiveMode)
          else
            FUndoList.AddChange(crInsert, LNewCaretPosition, SelectionEndPosition, SelectedText, FSelection.ActiveMode);
          SelectionEndPosition := CaretPosition;
          CommandProcessor(ecSelectionGotoXY, BCEDITOR_NONE_CHAR, @LNewCaretPosition);
        finally
          EndUndoBlock;
        end;
      end;
    finally
      DecPaintLock;
    end;
  end
  else
    inherited;
end;

procedure TBCBaseEditor.EndUndoBlock;
begin
  FUndoList.EndBlock;
end;

procedure TBCBaseEditor.EndUpdate;
begin
  DecPaintLock;
end;

procedure TBCBaseEditor.EnsureCursorPositionVisible;
begin
  EnsureCursorPositionVisible(False);
end;

procedure TBCBaseEditor.EnsureCursorPositionVisible(AForceToMiddle: Boolean; AEvenIfVisible: Boolean = False);
var
  LMiddle: Integer;
  LVisibleX: Integer;
  LCaretRow: Integer;
begin
  if FCharsInWindow <= 0 then
    Exit;
  HandleNeeded;
  IncPaintLock;
  try
    LVisibleX := DisplayX;
    if LVisibleX < LeftChar then
      LeftChar := LVisibleX
    else
    if LVisibleX >= CharsInWindow + LeftChar then
      LeftChar := LVisibleX - CharsInWindow + 1
    else
      LeftChar := LeftChar;

    LCaretRow := DisplayY;
    if AForceToMiddle then
    begin
      if LCaretRow < TopLine - 1 then
      begin
        LMiddle := VisibleLines div 2;
        if LCaretRow - LMiddle < 0 then
          TopLine := 1
        else
          TopLine := LCaretRow - LMiddle + 1;
      end
      else
      if LCaretRow > TopLine + VisibleLines - 2 then
      begin
        LMiddle := VisibleLines div 2;
        TopLine := LCaretRow - VisibleLines - 1 + LMiddle;
      end
      { Forces to middle even if visible in viewport }
      else
      if AEvenIfVisible then
      begin
        LMiddle := FVisibleLines div 2;
        TopLine := LCaretRow - LMiddle + 1;
      end;
    end
    else
    begin
      if LCaretRow < TopLine then
        TopLine := LCaretRow
      else
      if LCaretRow > TopLine + Max(1, VisibleLines) - 1 then
        TopLine := LCaretRow - (VisibleLines - 1)
      else
        TopLine := TopLine;
    end;
  finally
    DecPaintLock;
  end;
end;

procedure TBCBaseEditor.ExecuteCommand(ACommand: TBCEditorCommand; AChar: Char; AData: pointer);

  function SaveTrimmedWhitespace(const S: string; P: Integer): string;
  var
    i: Integer;
  begin
    i := P - 1;
    while (i > 0) and (S[i] < BCEDITOR_EXCLAMATION_MARK) do
      Dec(i);
    Result := Copy(S, i + 1, P - i - 1);
  end;

  procedure ForceCaretX(aCaretX: Integer);
  var
    LRestoreScroll: Boolean;
  begin
    LRestoreScroll := not (soPastEndOfLine in FScroll.Options);
    FScroll.Options := FScroll.Options + [soPastEndOfLine];
    try
      InternalCaretX := aCaretX;
    finally
      if LRestoreScroll then
        FScroll.Options := FScroll.Options - [soPastEndOfLine];
    end;
  end;

  function AllWhiteUpToCaret(const Ln: string; Len: Integer): Boolean;
  var
    j: Integer;
  begin
    if (Len = 0) or (FCaretX = 1) then
    begin
      Result := True;
      Exit;
    end;
    Result := False;
    j := 1;
    while (j <= Len) and (j < FCaretX) do
    begin
      if Ln[j] > BCEDITOR_SPACE_CHAR then
        Exit;
      Inc(j);
    end;
    Result := True;
  end;

var
  i: Integer;
  LLength: Integer;
  LLineText: string;
  LHelper: string;
  LTabBuffer: string;
  LSpaceBuffer: string;
  LSpaceCount1: Integer;
  LSpaceCount2: Integer;
  LVisualSpaceCount1, LVisualSpaceCount2: Integer;
  LBackCounter: Integer;
  LBlockStartPosition: TBCEditorTextPosition;
  LChangeScroll: Boolean;
  LMoveBookmark: Boolean;
  LWordPosition: TBCEditorTextPosition;
  LCaretPosition: TBCEditorTextPosition;
  LCaretNewPosition: TBCEditorTextPosition;
  LOldSelectionMode: TBCEditorSelectionMode;
  LCounter: Integer;
  LInsertCount, LInsertDelta: Integer;
  LUndoBeginPosition, LUndoEndPosition: TBCEditorTextPosition;
  LCaretRow: Integer;
  S: string;
  LIsJustIndented: Boolean;
  LFoldRange: TBCEditorCodeFoldingRange;
  LChar: Char;
begin
  if FCodeFolding.Visible and not (csDestroying in ComponentState) then
  begin
    LFoldRange := CodeFoldingCollapsableFoldRangeForLine(CaretY);
    if Assigned(LFoldRange) and (LFoldRange.Collapsed) then
      if ((ACommand >= ecDeleteLastChar) and (ACommand < ecUndo)) or
        (ACommand = ecTab) or (ACommand = ecShiftTab) or (ACommand = ecString) then
        Exit;
  end;
{ Process a comand }
  LHelper := '';
  IncPaintLock;
  try
    case ACommand of
      { Horizontal caret movement or selection }
      ecLeft, ecSelectionLeft:
        MoveCaretHorizontally(-1, ACommand = ecSelectionLeft);
      ecRight, ecSelectionRight:
        MoveCaretHorizontally(1, ACommand = ecSelectionRight);
      ecPageLeft, ecSelectionPageLeft:
        MoveCaretHorizontally(-CharsInWindow, ACommand = ecSelectionPageLeft);
      ecPageRight, ecSelectionPageRight:
        MoveCaretHorizontally(CharsInWindow, ACommand = ecSelectionPageRight);
      ecLineStart, ecSelectionLineStart:
        DoHomeKey(ACommand = ecSelectionLineStart);
      ecLineEnd, ecSelectionLineEnd:
        DoEndKey(ACommand = ecSelectionLineEnd);
      { Vertical caret movement or selection }
      ecUp, ecSelectionUp:
        begin
          MoveCaretVertically(-1, ACommand = ecSelectionUp);
          Update;
        end;
      ecDown, ecSelectionDown:
        begin
          MoveCaretVertically(1, ACommand = ecSelectionDown);
          Update;
        end;
      ecPageUp, ecSelectionPageUp, ecPageDown, ecSelectionPageDown:
        begin
          LCounter := FVisibleLines shr Ord(soHalfPage in FScroll.Options);

          if ACommand in [ecPageUp, ecSelectionPageUp] then
            LCounter := -LCounter;
          TopLine := TopLine + LCounter;
          MoveCaretVertically(LCounter, ACommand in [ecSelectionPageUp, ecSelectionPageDown]);
          Update;
        end;
      ecPageTop, ecSelectionPageTop:
        begin
          LCaretNewPosition := DisplayToTextPosition(GetDisplayPosition(DisplayX, TopLine));
          MoveCaretAndSelection(CaretPosition, LCaretNewPosition, ACommand = ecSelectionPageTop);
          Update;
        end;
      ecPageBottom, ecSelectionPageBottom:
        begin
          LCaretNewPosition := DisplayToTextPosition(GetDisplayPosition(DisplayX, TopLine + VisibleLines - 1));
          MoveCaretAndSelection(CaretPosition, LCaretNewPosition, ACommand = ecSelectionPageBottom);
          Update;
        end;
      ecEditorTop, ecSelectionEditorTop:
        begin
          with LCaretNewPosition do
          begin
            Char := 1;
            Line := 1;
          end;
          MoveCaretAndSelection(CaretPosition, LCaretNewPosition, ACommand = ecSelectionEditorTop);
          Update;
        end;
      ecEditorBottom, ecSelectionEditorBottom:
        begin
          with LCaretNewPosition do
          begin
            Char := 1;
            Line := FLines.Count;
            if Line > 0 then
              Char := Length(Lines[Line - 1]) + 1;
          end;
          MoveCaretAndSelection(CaretPosition, LCaretNewPosition, ACommand = ecSelectionEditorBottom);
          Update;
        end;
      { Go to the given line / column position }
      ecGotoXY, ecSelectionGotoXY:
        if Assigned(AData) then
        begin
          MoveCaretAndSelection(CaretPosition, TBCEditorTextPosition(AData^), ACommand = ecSelectionGotoXY);
          Update;
        end;
      { Go by given line / column offset }
      ecOffsetCaret, ecSelOffsetCaret:
        if Assigned(AData) then
        begin
          LCaretNewPosition := TBCEditorTextPosition(AData^);
          LCaretNewPosition := GetTextPosition(CaretPosition.Char + LCaretNewPosition.Char, CaretPosition.Line + LCaretNewPosition.Line);
          with LCaretNewPosition do
          begin
            Char := Max(Char, 1);
            Line := MinMax(Line, 1, FLines.Count);
          end;
          MoveCaretAndSelection(CaretPosition, LCaretNewPosition, ACommand = ecSelOffsetCaret);
          Update;
        end;
      ecGotoBookmark1 .. ecGotoBookmark9:
        begin
          if FLeftMargin.Bookmarks.ShortCuts then
            GotoBookmark(ACommand - ecGotoBookmark1);
        end;
      ecSetBookmark1 .. ecSetBookmark9:
        begin
          if FLeftMargin.Bookmarks.ShortCuts then
          begin
            i := ACommand - ecSetBookmark1;
            if Assigned(AData) then
              LCaretPosition := TBCEditorTextPosition(AData^)
            else
              LCaretPosition := CaretPosition;
            if Assigned(FBookmarks[i]) then
            begin
              LMoveBookmark := FBookmarks[i].Line <> LCaretPosition.Line;
              ClearBookmark(i);
              if LMoveBookmark then
                SetBookmark(i, LCaretPosition.Char, LCaretPosition.Line);
            end
            else
              SetBookmark(i, LCaretPosition.Char, LCaretPosition.Line);
          end;
        end;
      { Word selection, selection }
      ecWordLeft, ecSelectionWordLeft:
        begin
          LCaretNewPosition := WordStart;
          if AreCaretsEqual(LCaretNewPosition, CaretPosition) then
            LCaretNewPosition := PreviousWordPosition;
          MoveCaretAndSelection(CaretPosition, LCaretNewPosition, ACommand = ecSelectionWordLeft);
        end;
      ecWordRight, ecSelectionWordRight:
        begin
          LCaretNewPosition := WordEnd;
          if AreCaretsEqual(LCaretNewPosition, CaretPosition) then
            LCaretNewPosition := NextWordPosition;
          MoveCaretAndSelection(CaretPosition, LCaretNewPosition, ACommand = ecSelectionWordRight);
        end;
      ecSelectionWord:
        SetSelectedWord;
      ecSelectAll:
        SelectAll;
      { Backspace command }
      ecDeleteLastChar:
        if not ReadOnly then
        begin
          if SelectionAvailable then
            SetSelectedTextEmpty
          else
          begin
            LLineText := LineText;
            LLength := Length(LLineText);
            LTabBuffer := FLines.Strings[FCaretY - 1];
            LCaretPosition := CaretPosition;
            LIsJustIndented := False;
            { Behind EndOfLine? Simply move the cursor }
            if CaretX > LLength + 1 then
            begin
              LIsJustIndented := True;
              LHelper := '';
              { It's at the end of the line, move it to the length }
              if LLength > 0 then
                InternalCaretX := LLength + 1
              else
              begin
                { move it as if there were normal spaces there }
                LSpaceCount1 := CaretX - 1;
                LSpaceCount2 := 0;
                { unindent }
                if LSpaceCount1 > 0 then
                begin
                  LBackCounter := CaretY - 2;
                  { It's better not to have if statement inside loop }
                  if (eoTrimTrailingSpaces in Options) and (LLength = 0) then
                  while LBackCounter >= 0 do
                  begin
                    LSpaceCount2 := LeftSpaceCount(Lines[LBackCounter], True);
                    if LSpaceCount2 < LSpaceCount1 then
                      Break;
                    Dec(LBackCounter);
                  end
                  else
                  while LBackCounter >= 0 do
                  begin
                    LSpaceCount2 := LeftSpaceCount(Lines[LBackCounter]);
                    if LSpaceCount2 < LSpaceCount1 then
                      Break;
                    Dec(LBackCounter);
                  end;
                  if (LBackCounter = -1) and (LSpaceCount2 > LSpaceCount1) then
                    LSpaceCount2 := 0;
                end;
                if LSpaceCount2 = LSpaceCount1 then
                  LSpaceCount2 := 0;
                { Move caret }
                FCaretX := FCaretX - (LSpaceCount1 - LSpaceCount2);
                FStateFlags := FStateFlags + [sfCaretChanged];
              end;
            end
            else
              { Deleting while on beginning of line? }
              if CaretX = 1 then
              begin
                { join this line with the last line if possible }
                if CaretY > 1 then
                begin
                  InternalCaretY := CaretY - 1;
                  InternalCaretX := Length(Lines[CaretY - 1]) + 1;

                  FUndoList.AddChange(crSilentDelete, CaretPosition, LCaretPosition, sLineBreak, smNormal);

                  FLines.delete(CaretY);
                  DoLinesDeleted(CaretY, 1, True);
                  if eoTrimTrailingSpaces in Options then
                    LLineText := TrimRight(LLineText);

                  LineText := LineText + LLineText;
                  LHelper := BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
                end;
              end
              else
              begin
                { Delete text before the caret }
                LSpaceCount1 := LeftSpaceCount(LLineText);
                LSpaceCount2 := 0;
                if (LLineText[CaretX - 1] <= BCEDITOR_SPACE_CHAR) and (LSpaceCount1 = CaretX - 1) then
                begin
                  { Unindent, count visual whitespace on current previous lines }
                  LVisualSpaceCount1 := GetLeadingExpandedLength(LLineText, FTabs.Width);
                  LVisualSpaceCount2 := 0;
                  LBackCounter := FCaretY - 2;
                  while LBackCounter >= 0 do
                  begin
                    LVisualSpaceCount2 := GetLeadingExpandedLength(FLines[LBackCounter], FTabs.Width);
                    if LVisualSpaceCount2 < LVisualSpaceCount1 then
                    begin
                      LSpaceCount2 := LeftSpaceCount(FLines[LBackCounter]);
                      Break;
                    end;
                    Dec(LBackCounter);
                  end;

                  if (LBackCounter = -1) and (LSpaceCount2 > LSpaceCount1) then
                    LSpaceCount2 := 0;
                  if LSpaceCount2 = LSpaceCount1 then
                    LSpaceCount2 := 0;

                  if LSpaceCount2 > 0 then
                  begin
                    i := FCaretX - 2;
                    LLength := GetLeadingExpandedLength(LLineText, FTabs.Width, i);
                    while LLength > LVisualSpaceCount2 do
                    begin
                      Dec(i);
                      LLength := GetLeadingExpandedLength(LLineText, FTabs.Width, i);
                    end;

                    LHelper := Copy(LLineText, i + 1, LSpaceCount1 - i);
                    Delete(LLineText, i + 1, LSpaceCount1 - i);
                    FUndoList.BeginBlock;
                    try
                      FUndoList.AddChange(crSilentDelete, GetTextPosition(i + 1, FCaretY), LCaretPosition, LHelper, smNormal);

                      { If there's visual diffirence after deletion, that
                        means there are BCEDITOR_SPACE_CHAR spaces chars which we need to
                        compensate with BCEDITOR_SPACE_CHAR spaces. They cannot exceed tab
                        width }
                      if LVisualSpaceCount2 - LLength > 0 then
                        LSpaceBuffer := StringOfChar(BCEDITOR_SPACE_CHAR, LVisualSpaceCount2 - LLength);
                      Insert(LSpaceBuffer, LLineText, i + 1);
                    finally
                      FUndoList.EndBlock;
                    end;
                    FCaretX := i + Length(LSpaceBuffer) + 1;
                  end
                  else
                  begin
                    LVisualSpaceCount2 := LVisualSpaceCount1 - (LVisualSpaceCount1 mod FTabs.Width);

                    if LVisualSpaceCount2 = LVisualSpaceCount1 then
                      LVisualSpaceCount2 := Max(LVisualSpaceCount2 - FTabs.Width, 0);

                    i := FCaretX - 2;
                    LLength := GetLeadingExpandedLength(LLineText, FTabs.Width, i);
                    while (i > 0) and (LLength > LVisualSpaceCount2) do
                    begin
                      Dec(i);
                      LLength := GetLeadingExpandedLength(LLineText, FTabs.Width, i);
                    end;

                    LHelper := Copy(LLineText, i + 1, LSpaceCount1 - i);
                    Delete(LLineText, i + 1, LSpaceCount1 - i);
                    FUndoList.AddChange(crSilentDelete, GetTextPosition(i + 1, FCaretY),  LCaretPosition, LHelper, smNormal);
                    FCaretX := i + 1;
                  end;
                FLines[FCaretY - 1] := LLineText;
                FStateFlags := FStateFlags + [sfCaretChanged];
              end
              else
              begin
                LChar := LLineText[FCaretX - 1];
                i := 1;
                if TCharacter.IsSurrogate(LChar) then
                  i := 2;
                LHelper := Copy(LLineText, FCaretX - i, i);
                FUndoList.AddChange(crSilentDelete, GetTextPosition(FCaretX - i, FCaretY), LCaretPosition,
                  LHelper, smNormal);

                Delete(LLineText, FCaretX - i, i);
                FLines[FCaretY - 1] := LLineText;

                InternalCaretX := FCaretX - i;
              end;
            end;
            if not LIsJustIndented then
              FLines.Attributes[FCaretY - 1].LineState := lsModified;
          end;
        end;
      { Delete command }
      ecDeleteChar:
        if not ReadOnly then
        begin
          if SelectionAvailable then
            SetSelectedTextEmpty
          else
          begin
            LCaretNewPosition := CaretPosition; // ?

            LLineText := LineText;
            LLength := Length(LLineText);
            if CaretX <= LLength then
            begin
              LCounter := 1;
              LHelper := Copy(LLineText, CaretX, LCounter);
              LCaretPosition.Char := CaretX + LCounter;
              LCaretPosition.Line := CaretY;
              Delete(LLineText, CaretX, LCounter);
              ProperSetLine(CaretY - 1, LLineText);
              FUndoList.AddChange(crSilentDeleteAfterCursor, CaretPosition, LCaretPosition, LHelper, smNormal);
            end
            else
            begin
              if CaretY < FLines.Count then
              begin
                LSpaceCount1 := FCaretX - 1 - LLength;
                if toTabsToSpaces in FTabs.Options then
                  LSpaceBuffer := StringOfChar(BCEDITOR_SPACE_CHAR, LSpaceCount1)
                else
                if AllWhiteUpToCaret(LLineText, LLength) then
                  LSpaceBuffer := StringOfChar(BCEDITOR_TAB_CHAR, LSpaceCount1 div FTabs.Width) +
                    StringOfChar(BCEDITOR_SPACE_CHAR, LSpaceCount1 mod FTabs.Width)
                else
                  LSpaceBuffer := StringOfChar(BCEDITOR_SPACE_CHAR, LSpaceCount1);

                with LCaretPosition do
                begin
                  Char := 1;
                  Line := FCaretY + 1;
                end;

                if LSpaceCount1 > 0 then
                  FUndoList.BeginBlock;
                LHelper := sLineBreak;
                FUndoList.AddChange(crSilentDeleteAfterCursor, CaretPosition, LCaretPosition, LHelper, smNormal);
                if LSpaceCount1 > 0 then
                  FUndoList.EndBlock;

                FLines[FCaretY - 1] := LLineText + LSpaceBuffer + FLines[FCaretY];
                FLines.Attributes[Pred(FCaretY)].LineState := lsModified;
                FLines.Delete(CaretY);
                DoLinesDeleted(CaretY, 1, True);
              end;
            end;
          end;
        end;
      { Other deletion commands }
      ecDeleteWord, ecDeleteEndOfLine:
        if not ReadOnly then
        begin
          LLength := Length(LineText);
          if ACommand = ecDeleteWord then
          begin
            LWordPosition := WordEnd;
            LLineText := LineText;
            if (LWordPosition.Char < CaretX) or ((LWordPosition.Char = CaretX) and (LWordPosition.Line < FLines.Count)) then
            begin
              if LWordPosition.Char > LLength then
              begin
                Inc(LWordPosition.Line);
                LWordPosition.Char := 1;
                LLineText := FLines[LWordPosition.Line - 1];
              end
              else
              if LLineText[LWordPosition.Char] <> BCEDITOR_SPACE_CHAR then
                Inc(LWordPosition.Char);
            end
            else
            if (LWordPosition.Char = FCaretX) and (LWordPosition.Line = FCaretY) then
            begin
              LWordPosition.Char := LLength + 1;
              LWordPosition.Line := FCaretY;
            end;
            if LLineText <> '' then
              while LLineText[LWordPosition.Char] = BCEDITOR_SPACE_CHAR do
                Inc(LWordPosition.Char);
          end
          else
          begin
            LWordPosition.Char := LLength + 1;
            LWordPosition.Line := CaretY;
          end;
          if (LWordPosition.Char <> CaretX) or (LWordPosition.Line <> CaretY) then
          begin
            SetSelectionBeginPosition(CaretPosition);
            SetSelectionEndPosition(LWordPosition);
            FSelection.ActiveMode := smNormal;
            LHelper := SelectedText;
            SetSelectedTextPrimitive(StringOfChar(' ', CaretX - SelectionBeginPosition.Char));
            FUndoList.AddChange(crSilentDeleteAfterCursor, CaretPosition, LWordPosition, LHelper, smNormal);
            InternalCaretPosition := CaretPosition;
          end;
        end;
      ecDeleteLastWord, ecDeleteBeginningOfLine:
        if not ReadOnly then
        begin
          if ACommand = ecDeleteLastWord then
            LWordPosition := PreviousWordPosition
          else
          begin
            LWordPosition.Char := 1;
            LWordPosition.Line := CaretY;
          end;
          if (LWordPosition.Char <> CaretX) or (LWordPosition.Line <> CaretY) then
          begin
            LOldSelectionMode := FSelection.Mode;
            try
              FSelection.Mode := smNormal;
              SetSelectionBeginPosition(CaretPosition);
              SetSelectionEndPosition(LWordPosition);
              LHelper := SelectedText;
              SetSelectedTextPrimitive('');
              FUndoList.AddChange(crSilentDelete, LWordPosition, CaretPosition, LHelper, smNormal);
              InternalCaretPosition := LWordPosition;
            finally
              FSelection.Mode := LOldSelectionMode;
            end;
            InternalCaretPosition := LWordPosition;
          end;
        end;
      ecDeleteLine:
        if not ReadOnly and (Lines.Count > 0) and not ((CaretY = FLines.Count) and (Length(Lines[CaretY - 1]) = 0)) then
        begin
          if SelectionAvailable then
            SetSelectionBeginPosition(CaretPosition);
          LHelper := LineText;
          if CaretY = FLines.Count then
          begin
            FLines[CaretY - 1] := '';
            FUndoList.AddChange(crSilentDeleteAfterCursor, GetTextPosition(1, CaretY),
              GetTextPosition(Length(LHelper) + 1, CaretY), LHelper, smNormal);
          end
          else
          begin
            FLines.Delete(CaretY - 1);
            LHelper := LHelper + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
            FUndoList.AddChange(crSilentDeleteAfterCursor, GetTextPosition(1, CaretY), GetTextPosition(1, CaretY + 1),
              LHelper, smNormal);
            DoLinesDeleted(CaretY - 1, 1, True);
          end;
          InternalCaretPosition := GetTextPosition(1, CaretY);
        end;
      { Moving }
      ecMoveLineUp:
        begin
          FCommandDrop := True;
          try
            LUndoBeginPosition := SelectionBeginPosition;
            LUndoEndPosition := SelectionEndPosition;
            with LBlockStartPosition do
            begin
              Char := Min(LUndoBeginPosition.Char, LUndoEndPosition.Char);
              Line := Min(LUndoBeginPosition.Line, LUndoEndPosition.Line);
            end;
            LBlockStartPosition := TBCEditorTextPosition(RowColumnToPixels(TextToDisplayPosition(LBlockStartPosition)));
            Dec(LBlockStartPosition.Line, FTextHeight);
            DragDrop(Self, LBlockStartPosition.Char, LBlockStartPosition.Line);
          finally
            FCommandDrop := False;
          end;
        end;
      ecMoveLineDown:
        begin
          FCommandDrop := True;
          try
            LUndoBeginPosition := SelectionBeginPosition;
            LUndoEndPosition := SelectionEndPosition;
            with LBlockStartPosition do
            begin
              Char := Min(LUndoBeginPosition.Char, LUndoEndPosition.Char);
              Line := Max(LUndoBeginPosition.Line, LUndoEndPosition.Line);
            end;
            LBlockStartPosition := TBCEditorTextPosition(RowColumnToPixels(TextToDisplayPosition(LBlockStartPosition)));
            Inc(LBlockStartPosition.Line, FTextHeight);
            DragDrop(Self, LBlockStartPosition.Char, LBlockStartPosition.Line);
          finally
            FCommandDrop := False;
          end;
        end;
      ecMoveCharLeft:
        begin
          FCommandDrop := True;
          try
            LUndoBeginPosition := SelectionBeginPosition;
            LUndoEndPosition := SelectionEndPosition;
            with LBlockStartPosition do
            begin
              Char := Min(LUndoBeginPosition.Char, LUndoEndPosition.Char);
              Line := Min(LUndoBeginPosition.Line, LUndoEndPosition.Line);
            end;
            LBlockStartPosition := TBCEditorTextPosition(RowColumnToPixels(TextToDisplayPosition(GetTextPosition(LBlockStartPosition.Char - 1,
              LBlockStartPosition.Line))));
            DragDrop(Self, LBlockStartPosition.Char, LBlockStartPosition.Line);
          finally
            FCommandDrop := False;
          end;
        end;
      ecMoveCharRight:
        begin
          FCommandDrop := True;
          try
            LUndoBeginPosition := SelectionBeginPosition;
            LUndoEndPosition := SelectionEndPosition;
            with LBlockStartPosition do
            begin
              Char := Max(LUndoBeginPosition.Char, LUndoEndPosition.Char);
              Line := Min(LUndoBeginPosition.Line, LUndoEndPosition.Line);
            end;
            LBlockStartPosition := TBCEditorTextPosition(RowColumnToPixels(TextToDisplayPosition(GetTextPosition(LBlockStartPosition.Char + 1,
              LBlockStartPosition.Line))));
            DragDrop(Self, LBlockStartPosition.Char, LBlockStartPosition.Line);
          finally
            FCommandDrop := False;
          end;
        end;
      { Search }
      ecSearchNext:
        FindNext;
      ecSearchPrevious:
        FindPrevious;
      { Delete everything }
      ecClear:
        if not ReadOnly then
          Clear;
      { New line insertion / break }
      ecInsertLine, ecLineBreak:
        if not ReadOnly then
        begin
          UndoList.BeginBlock;
          try
            LInsertCount := 1;
            if SelectionAvailable then
            begin
              LInsertCount := 0;
              SetSelectedTextEmpty;
            end;
            LLineText := LineText;
            LInsertDelta := Ord(CaretX = 1);
            LLength := Length(LLineText);

            LCaretPosition := CaretPosition;

            if LLength > 0 then
            begin
              if LLength >= FCaretX then
              begin
                if FCaretX > 1 then
                begin
                  if eoTrimTrailingSpaces in FOptions then
                    LTabBuffer := SaveTrimmedWhitespace(LLineText, FCaretX);

                  LSpaceCount2 := 0;
                  if eoAutoIndent in FOptions then
                    if toTabsToSpaces in FTabs.Options then
                    begin
                      LSpaceCount1 := 1;
                      LSpaceCount2 := GetLeadingExpandedLength(LLineText, FTabs.Width);
                    end
                    else
                      LSpaceCount1 := LeftSpaceCount(LLineText)
                  else
                    LSpaceCount1 := 0;

                  if LSpaceCount1 > 0 then
                  begin
                    if toTabsToSpaces in FTabs.Options then
                      LSpaceBuffer := GetLeftSpacing(LSpaceCount2, False)
                    else
                      LSpaceBuffer := Copy(LLineText, 1, LSpaceCount1);
                  end;

                  FLines[FCaretY - 1] := Copy(LLineText, 1, FCaretX - 1);

                  LLineText := Copy(LLineText, FCaretX, MaxInt);
                  if (eoAutoIndent in FOptions) and (LSpaceCount1 > 0) then
                    FLines.Insert(FCaretY, LSpaceBuffer + LLineText)
                  else
                    FLines.Insert(FCaretY, LLineText);

                  if (eoTrimTrailingSpaces in FOptions) and (LTabBuffer <> '') then
                    FUndoList.AddChange(crLineBreak, LCaretPosition, LCaretPosition, LTabBuffer + LLineText, smNormal)
                  else
                    FUndoList.AddChange(crLineBreak, LCaretPosition, LCaretPosition, LLineText, smNormal);

                  with FLines do
                  begin
                    Attributes[LCaretPosition.Line - 1].LineState := lsModified;
                    Attributes[LCaretPosition.Line].LineState := lsModified;
                  end;

                  if ACommand = ecLineBreak then
                    if toTabsToSpaces in FTabs.Options then
                      InternalCaretPosition := GetTextPosition(LSpaceCount2 + 1, FCaretY + 1)
                    else
                      InternalCaretPosition := GetTextPosition(LSpaceCount1 + 1, FCaretY + 1);
                end
                else
                begin
                  FLines.Insert(FCaretY - 1, '');

                  FUndoList.AddChange(crLineInsert, LCaretPosition, LCaretPosition, '', smNormal);

                  with FLines do
                  begin
                    Attributes[FCaretY - 1].LineState := lsModified;
                    Attributes[FCaretY].LineState := lsModified;
                  end;

                  if ACommand = ecLineBreak then
                    InternalCaretY := FCaretY + 1;
                end;
              end
              else
              begin
                LSpaceCount1 := 0;
                LSpaceCount2 := 0;
                LBackCounter := FCaretY;
                if (ACommand = ecLineBreak) and (eoAutoIndent in FOptions) then
                begin
                  repeat
                    Dec(LBackCounter);
                    if FLines.AccessStringLength(LBackCounter) > 0 then
                    begin
                      if toTabsToSpaces in FTabs.Options then
                      begin
                        LSpaceCount1 := 1;
                        LSpaceCount2 := GetLeadingExpandedLength(Lines[LBackCounter], FTabs.Width);
                      end
                      else
                        LSpaceCount1 := LeftSpaceCount(Lines[LBackCounter]);
                      Break;
                    end;
                  until LBackCounter = 0;

                  if (LSpaceCount1 = 0) and (FCaretY < FLines.Count) then
                  begin
                    LBackCounter := FCaretY - 1;
                    repeat
                      Inc(LBackCounter);
                      if FLines.AccessStringLength(LBackCounter) > 0 then
                      begin
                        if toTabsToSpaces in FTabs.Options then
                        begin
                          LSpaceCount1 := 1;
                          LSpaceCount2 := GetLeadingExpandedLength(Lines[LBackCounter], FTabs.Width);
                        end
                        else
                          LSpaceCount1 := LeftSpaceCount(Lines[LBackCounter]);
                        Break;
                        Inc(LBackCounter);
                        Break;
                      end;
                    until LBackCounter = FLines.Count - 1;
                  end;
                end;
                FLines.Insert(FCaretY, '');

                FUndoList.AddChange(crLineBreak, LCaretPosition, LCaretPosition, '', smNormal);

                with FLines do
                begin
                  Attributes[FCaretY - 1].LineState := lsModified;
                  Attributes[FCaretY].LineState := lsModified;
                end;

                if ACommand = ecLineBreak then
                begin
                  if LSpaceCount1 > 0 then
                  begin
                    if toTabsToSpaces in FTabs.Options then
                      LSpaceBuffer := GetLeftSpacing(LSpaceCount2, False)
                    else
                      LSpaceBuffer := Copy(Lines[LBackCounter], 1, LSpaceCount1);

                    InternalCaretPosition := GetTextPosition(Length(LSpaceBuffer) + 1, FCaretY + 1);

                    FLines[FCaretY - 1] := LSpaceBuffer + FLines[FCaretY - 1];
                  end
                  else
                    InternalCaretPosition := GetTextPosition(1, FCaretY + 1);
                end;
              end;
            end
            else
            begin
              if FLines.Count = 0 then
                FLines.Add('');

              LSpaceCount1 := 0;
              LSpaceCount2 := 0;
              LBackCounter := FCaretY;

              if (ACommand = ecLineBreak) and (eoAutoIndent in FOptions) and (FLines.Count > 1) then
              begin
                repeat
                  Dec(LBackCounter);
                  if FLines.AccessStringLength(LBackCounter) > 0 then
                  begin
                    if toTabsToSpaces in FTabs.Options then
                    begin
                      LSpaceCount1 := 1;
                      LSpaceCount2 := GetLeadingExpandedLength(Lines[LBackCounter], FTabs.Width);
                    end
                    else
                      LSpaceCount1 := LeftSpaceCount(Lines[LBackCounter]);
                    Break;
                  end;
                until LBackCounter = 0;

                if (LSpaceCount1 = 0) and (FCaretY < FLines.Count) then
                begin
                  LBackCounter := FCaretY - 1;
                  repeat
                    Inc(LBackCounter);
                    if FLines.AccessStringLength(LBackCounter) > 0 then
                    begin
                      if toTabsToSpaces in FTabs.Options then
                      begin
                        LSpaceCount1 := 1;
                        LSpaceCount2 := GetLeadingExpandedLength(Lines[LBackCounter], FTabs.Width);
                      end
                      else
                        LSpaceCount1 := LeftSpaceCount(Lines[LBackCounter]);
                      Break;
                      Inc(LBackCounter);
                      Break;
                    end;
                  until LBackCounter = FLines.Count - 1;
                end;
              end;

              FLines.Insert(FCaretY - 1, '');

              FUndoList.AddChange(crLineBreak, CaretPosition, CaretPosition, '', smNormal);

              with FLines do
              begin
                Attributes[FCaretY - 1].LineState := lsModified;
                Attributes[FCaretY].LineState := lsModified;
              end;

              if ACommand = ecLineBreak then
              begin
                if LSpaceCount1 > 0 then
                begin
                  if toTabsToSpaces in FTabs.Options then
                    LSpaceBuffer := GetLeftSpacing(LSpaceCount2, False)
                  else
                    LSpaceBuffer := Copy(Lines[LBackCounter], 1, LSpaceCount1);

                  InternalCaretPosition := GetTextPosition(Length(LSpaceBuffer) +  1, FCaretY + 1);

                  FLines[FCaretY - 1] := LSpaceBuffer + FLines[FCaretY - 1];
                end
                else
                  InternalCaretPosition := GetTextPosition(1, FCaretY + 1);
              end;
            end;
            DoTrimTrailingSpaces(LCaretPosition.Line);

            DoLinesInserted(CaretY - LInsertDelta, LInsertCount);
            SelectionBeginPosition := CaretPosition;
            SelectionEndPosition := CaretPosition;
            EnsureCursorPositionVisible;
          finally
            UndoList.EndBlock;
          end;
        end;
      { Tabbing }
      ecTab:
        if not ReadOnly then
          DoTabKey;
      ecShiftTab:
        if not ReadOnly then
          DoShiftTabKey;
      ecChar:
        if not ReadOnly and (AChar >= BCEDITOR_SPACE_CHAR) and (AChar <> BCEDITOR_CTRL_BACKSPACE) then
        begin
          if SelectionAvailable then
            SetSelectedTextEmpty(AChar)
          else
          begin
            LCaretPosition := CaretPosition;  // ?

            LLineText := LineText;
            LLength := Length(LLineText);

            LSpaceCount1 := 0;
//            LSpaceCount2 := 0;
            if LLength < FCaretX - 1 then
            begin
              if toTabsToSpaces in FTabs.Options then
                LSpaceBuffer := StringOfChar(BCEDITOR_SPACE_CHAR, FCaretX - LLength - Ord(FInsertMode))
              else
              if AllWhiteUpToCaret(LLineText, LLength) then
                LSpaceBuffer := StringOfChar(BCEDITOR_TAB_CHAR, (FCaretX - LLength - Ord(FInsertMode)) div FTabs.Width) +
                  StringOfChar(BCEDITOR_SPACE_CHAR, (FCaretX - LLength - Ord(FInsertMode)) mod FTabs.Width)
              else
                LSpaceBuffer := StringOfChar(BCEDITOR_SPACE_CHAR, FCaretX - LLength - Ord(FInsertMode));
              LSpaceCount1 := Length(LSpaceBuffer);
//              LSpaceCount2 := GetLeadingExpandedLength(LSpaceBuffer, FTabs.Width);
            end;

            LBlockStartPosition := CaretPosition;

            if FInsertMode then
            begin
              if not GetWordWrap and not (soAutosizeMaxWidth in FScroll.Options) and (CaretX > FScroll.MaxWidth) then
                Exit;

              if LSpaceCount1 > 0 then
                LLineText := LLineText + LSpaceBuffer + AChar
              else
                Insert(AChar, LLineText, FCaretX);

              FLines[FCaretY - 1] := LLineText;

              if LSpaceCount1 > 0 then
              begin
                BeginUndoBlock;
                try
                  FUndoList.AddChange(crInsert, GetTextPosition(LLength + LSpaceCount1 + 1, FCaretY),
                    GetTextPosition(LLength + LSpaceCount1 + 2, FCaretY), '', smNormal);
                  FLines.Attributes[FCaretY - 1].LineState := lsModified;

                  InternalCaretX := LLength + LSpaceCount1 + 2;
                finally
                  EndUndoBlock;
                end;
              end
              else
              begin
                FUndoList.AddChange(crInsert, LBlockStartPosition, GetTextPosition(FCaretX + 1, FCaretY), '', smNormal);
                FLines.Attributes[FCaretY - 1].LineState := lsModified;

                InternalCaretX := FCaretX + 1;
              end;
            end
            else
            begin
              if FCaretX <= LLength then
                LHelper := Copy(LLineText, FCaretX, 1);

              if FCaretX <= LLength then
                LLineText[FCaretX] := AChar
              else
              if LSpaceCount1 > 0 then
              begin
                LSpaceBuffer[LSpaceCount1] := AChar;
                LLineText := LLineText + LSpaceBuffer;
              end
              else
                LLineText := LLineText + AChar;
              FLines[FCaretY - 1] := LLineText;

              if LSpaceCount1 > 0 then
              begin
                BeginUndoBlock;
                try
                  FUndoList.AddChange(crInsert, GetTextPosition(LLength + LSpaceCount1, FCaretY),
                    GetTextPosition(LLength + LSpaceCount1 + 1, FCaretY), '', smNormal);
                  FLines.Attributes[FCaretY - 1].LineState := lsModified;

                  InternalCaretX := LLength + LSpaceCount1 + 1;
                finally
                  EndUndoBlock;
                end;
              end
              else
              begin
                FUndoList.AddChange(crInsert, LBlockStartPosition, GetTextPosition(FCaretX + 1, FCaretY), LHelper, smNormal);
                FLines.Attributes[FCaretY - 1].LineState := lsModified;

                InternalCaretX := FCaretX + 1;
              end;
            end;

            if CaretX >= LeftChar + FCharsInWindow then
              LeftChar := LeftChar + Min(25, FCharsInWindow - 1);
          end;
        end;
      ecUpperCase, ecLowerCase, ecAlternatingCase, ecSentenceCase, ecTitleCase, ecUpperCaseBlock, ecLowerCaseBlock,
      ecAlternatingCaseBlock:
        if not ReadOnly then
          DoToggleSelectedCase(ACommand);
      { Undo / Redo }
      ecUndo:
        if not readonly then
        begin
          FUndoRedo := True;
          try
            DoInternalUndo;
          finally
            FUndoRedo := False;
          end;
        end;
      ecRedo:
        if not readonly then
        begin
          FUndoRedo := True;
          try
            DoInternalRedo;
          finally
            FUndoRedo := False;
          end;
        end;
      ecCut:
        if (not ReadOnly) and SelectionAvailable then
          DoCutToClipboard;
      ecCopy:
        CopyToClipboard;
      ecPaste:
        if not ReadOnly then
          DoPasteFromClipboard;
      { Scrolling }
      ecScrollUp, ecScrollDown:
        begin
          LCaretRow := DisplayY;
          if (LCaretRow < TopLine) or (LCaretRow >= TopLine + VisibleLines) then
            EnsureCursorPositionVisible
          else
          begin
            if ACommand = ecScrollUp then
            begin
              TopLine := TopLine - 1;
              if LCaretRow > TopLine + VisibleLines - 1 then
                MoveCaretVertically((TopLine + VisibleLines - 1) - LCaretRow, False);
            end
            else
            begin
              TopLine := TopLine + 1;
              if LCaretRow < TopLine then
                MoveCaretVertically(TopLine - LCaretRow, False);
            end;
            EnsureCursorPositionVisible;
            Update;
          end;
        end;
      ecScrollLeft:
        begin
          LeftChar := LeftChar - 1;
          Update;
        end;
      ecScrollRight:
        begin
          LeftChar := LeftChar + 1;
          Update;
        end;
      { Editing mode }
      ecInsertMode:
        InsertMode := True;
      ecOverwriteMode:
        InsertMode := False;
      ecToggleMode:
        InsertMode := not InsertMode;
      { Indentation }
      ecBlockIndent:
        if not ReadOnly then
          DoBlockIndent;
      ecBlockUnindent:
        if not ReadOnly then
          DoBlockUnindent;
      { Selection mode }
      ecNormalSelect:
        FSelection.Mode := smNormal;
      ecColumnSelect:
        FSelection.Mode := smColumn;
      ecLineSelect:
        FSelection.Mode := smLine;
      { Fires event with word under cursor }
      ecContextHelp:
        begin
          if Assigned(FOnContextHelp) then
            FOnContextHelp(Self, WordAtCursor);
        end;
      { IME }
      ecImeStr:
        if not ReadOnly then
        begin
          SetString(S, PChar(AData), Length(PChar(AData)));
          if SelectionAvailable then
          begin
            BeginUndoBlock;
            try
              FUndoList.AddChange(crDelete, FSelectionBeginPosition, FSelectionEndPosition, LHelper, smNormal);
              LBlockStartPosition := FSelectionBeginPosition;
              SetSelectedTextPrimitive(S);
              FUndoList.AddChange(crInsert, FSelectionBeginPosition, FSelectionEndPosition, LHelper, smNormal);
            finally
              EndUndoBlock;
            end;
            InvalidateLeftMarginLines(-1, -1);
          end
          else
          begin
            LLineText := LineText;
            LLength := Length(LLineText);
            if LLength < CaretX then
              LLineText := LLineText + StringOfChar(BCEDITOR_SPACE_CHAR, CaretX - LLength - 1);
            LChangeScroll := not (soPastEndOfLine in FScroll.Options);
            try
              if LChangeScroll then
                FScroll.Options := FScroll.Options + [soPastEndOfLine];
              LBlockStartPosition := CaretPosition;
              LLength := Length(S);
              if not FInsertMode then
              begin
                LHelper := Copy(LLineText, CaretX, LLength);
                Delete(LLineText, CaretX, LLength);
              end;
              Insert(S, LLineText, CaretX);
              InternalCaretX := (CaretX + LLength);
              ProperSetLine(CaretY - 1, LLineText);
              if FInsertMode then
                LHelper := '';
              FUndoList.AddChange(crInsert, LBlockStartPosition, CaretPosition, LHelper, smNormal);
              if CaretX >= LeftChar + FCharsInWindow then
                LeftChar := LeftChar + Min(25, FCharsInWindow - 1);
            finally
              if LChangeScroll then
                FScroll.Options := FScroll.Options - [soPastEndOfLine];
            end;
          end;
        end;
    end;
  finally
    DecPaintLock;
  end;
end;

procedure TBCBaseEditor.GotoBookmark(ABookmark: Integer);
var
  LTextPosition: TBCEditorTextPosition;
begin
  if (ABookmark in [0 .. 8]) and Assigned(FBookmarks[ABookmark]) and (FBookmarks[ABookmark].Line <= FLines.Count) then
  begin
    LTextPosition.Char := FBookmarks[ABookmark].Char;
    LTextPosition.Line := FBookmarks[ABookmark].Line;
    SetCaretPosition(False, LTextPosition);
    EnsureCursorPositionVisible(True);
    if SelectionAvailable then
      InvalidateSelection;
    FSelectionBeginPosition.Char := FCaretX;
    FSelectionBeginPosition.Line := FCaretY;
    FSelectionEndPosition := FSelectionBeginPosition;
  end;
end;

procedure TBCBaseEditor.GotoLineAndCenter(ALine: Integer);
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  if FCodeFolding.Visible then
  for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if LCodeFoldingRange.FromLine > ALine then
      Break
    else
    if (LCodeFoldingRange.FromLine <= ALine) and LCodeFoldingRange.Collapsed then
      CodeFoldingUncollapse(LCodeFoldingRange);
  end;
  SetCaretPosition(False, GetTextPosition(1, ALine));
  if SelectionAvailable then
    InvalidateSelection;
  FSelectionBeginPosition.Char := FCaretX;
  FSelectionBeginPosition.Line := FCaretY;
  FSelectionEndPosition := FSelectionBeginPosition;
  EnsureCursorPositionVisible(True);
end;

procedure TBCBaseEditor.HookEditorLines(ABuffer: TBCEditorLines; AUndo, ARedo: TBCEditorUndoList);
var
  LOldWrap: Boolean;
begin
  Assert(not Assigned(FChainedEditor));
  Assert(FLines = FOriginalLines);

  LOldWrap := GetWordWrap;
  UpdateWordWrap(False);

  if Assigned(FChainedEditor) then
    RemoveChainedEditor
  else
  if FLines <> FOriginalLines then
    UnhookEditorLines;

  FChainListCleared := ABuffer.OnCleared;
  ABuffer.OnCleared := ChainListCleared;
  FChainListDeleted := ABuffer.OnDeleted;
  ABuffer.OnDeleted := ChainListDeleted;
  FChainListInserted := ABuffer.OnInserted;
  ABuffer.OnInserted := ChainListInserted;
  FChainListPutted := ABuffer.OnPutted;
  ABuffer.OnPutted := ChainListPutted;
  FChainLinesChanging := ABuffer.OnChanging;
  ABuffer.OnChanging := ChainLinesChanging;
  FChainLinesChanged := ABuffer.OnChange;
  ABuffer.OnChange := ChainLinesChanged;

  FChainUndoAdded := AUndo.OnAddedUndo;
  AUndo.OnAddedUndo := ChainUndoRedoAdded;
  FChainRedoAdded := ARedo.OnAddedUndo;
  ARedo.OnAddedUndo := ChainUndoRedoAdded;

  FLines := ABuffer;
  FUndoList := AUndo;
  FRedoList := ARedo;
  LinesHookChanged;

  UpdateWordWrap(LOldWrap);
end;

procedure TBCBaseEditor.InitCodeFolding;
begin
  ClearCodeFolding;
  SetLength(FCollapsedLinesDifferenceCache, 0);
  ScanCodeFoldingRanges(FAllCodeFoldingRanges, FLines);
  CodeFoldingPrepareRangeForLine;
end;

procedure TBCBaseEditor.InsertBlock(const ABlockBeginPosition, ABlockEndPosition: TBCEditorTextPosition; AChangeStr: PChar; AAddToUndoList: Boolean);
begin
  SetCaretAndSelection(ABlockBeginPosition, ABlockBeginPosition, ABlockEndPosition);
  FSelection.ActiveMode := smColumn;
  SetSelectedTextPrimitive(smColumn, AChangeStr, AAddToUndoList);
end;

procedure TBCBaseEditor.InvalidateLeftMargin;
begin
  InvalidateLeftMarginLines(-1, -1);
end;

procedure TBCBaseEditor.InvalidateLeftMarginLine(ALine: Integer);
begin
  if (ALine < 1) or (ALine > FLines.Count) then
    Exit;

  InvalidateLeftMarginLines(ALine, ALine);
end;

procedure TBCBaseEditor.InvalidateLeftMarginLines(AFirstLine, ALastLine: Integer);
var
  LInvalidationRect: TRect;
begin
  if Visible and HandleAllocated then
  begin
    if (AFirstLine = -1) and (ALastLine = -1) then
    begin
      LInvalidationRect := Rect(0, 0, FLeftMargin.GetWidth, ClientHeight);

      if sfLinesChanging in FStateFlags then
        UnionRect(FInvalidateRect, FInvalidateRect, LInvalidationRect)
      else
        InvalidateRect(LInvalidationRect);
    end
    else
    begin
      if ALastLine < AFirstLine then
        SwapInt(ALastLine, AFirstLine);
      AFirstLine := Max(LineToRow(AFirstLine), TopLine);
      ALastLine := Min(LineToRow(ALastLine), TopLine + VisibleLines);
      if GetWordWrap then
        if ALastLine > FLines.Count then
          ALastLine := TopLine + VisibleLines;

      if ALastLine >= AFirstLine then
      begin
        LInvalidationRect := Rect(0, LineHeight * (AFirstLine - TopLine), FLeftMargin.GetWidth,
          LineHeight * (ALastLine - TopLine + 1));

        if sfLinesChanging in FStateFlags then
          UnionRect(FInvalidateRect, FInvalidateRect, LInvalidationRect)
        else
          InvalidateRect(LInvalidationRect);
      end;
    end;
  end;
end;

procedure TBCBaseEditor.InvalidateLine(ALine: Integer);
var
  LInvalidationRect: TRect;
begin
  if (not HandleAllocated) or (ALine < 1) or (ALine > FLines.Count) or (not Visible) then
    Exit;

  if GetWordWrap then
  begin
    InvalidateLines(ALine, ALine);
    Exit;
  end;

  if (ALine >= TopLine) and (ALine <= TopLine + VisibleLines) then
  begin
    LInvalidationRect := Rect(0, LineHeight * (ALine - TopLine), ClientWidth - FMinimap.GetWidth - FSearch.Map.GetWidth, 0);
    LInvalidationRect.Bottom := LInvalidationRect.Top + LineHeight;
    DeflateMinimapRect(LInvalidationRect);

    if sfLinesChanging in FStateFlags then
      UnionRect(FInvalidateRect, FInvalidateRect, LInvalidationRect)
    else
      InvalidateRect(LInvalidationRect);
  end;
end;

procedure TBCBaseEditor.InvalidateLines(AFirstLine, ALastLine: Integer);
var
  LInvalidationRect: TRect;
begin
  if Visible and HandleAllocated then
  begin
    if (AFirstLine = -1) and (ALastLine = -1) then
    begin
      LInvalidationRect := ClientRect;
      DeflateMinimapRect(LInvalidationRect);
      if sfLinesChanging in FStateFlags then
        UnionRect(FInvalidateRect, FInvalidateRect, LInvalidationRect)
      else
        InvalidateRect(LInvalidationRect);
    end
    else
    begin
      AFirstLine := Max(AFirstLine, 1);
      ALastLine := Max(ALastLine, 1);
      if ALastLine < AFirstLine then
        SwapInt(ALastLine, AFirstLine);
      AFirstLine := Max(LineToRow(AFirstLine), TopLine);
      ALastLine := Min(LineToRow(ALastLine), TopLine + VisibleLines);
      if GetWordWrap then
        if ALastLine > FLines.Count then
          ALastLine := TopLine + VisibleLines;
      if ALastLine >= AFirstLine then
      begin
        LInvalidationRect := Rect(0, LineHeight * (AFirstLine - TopLine), ClientWidth, LineHeight * (ALastLine - TopLine + 1));
        DeflateMinimapRect(LInvalidationRect);
        if sfLinesChanging in FStateFlags then
          UnionRect(FInvalidateRect, FInvalidateRect, LInvalidationRect)
        else
          InvalidateRect(LInvalidationRect);
      end;
    end;
  end;
end;

procedure TBCBaseEditor.InvalidateMinimap;
var
  LInvalidationRect: TRect;
begin
  LInvalidationRect := Rect(ClientWidth - FMinimap.GetWidth - FSearch.Map.GetWidth, 0, ClientWidth - FSearch.Map.GetWidth,
    ClientHeight);
  InvalidateRect(LInvalidationRect);
end;

procedure TBCBaseEditor.InvalidateSelection;
begin
  InvalidateLines(SelectionBeginPosition.Line, SelectionEndPosition.Line);
end;

procedure TBCBaseEditor.LeftMarginChanged(Sender: TObject);
var
  LWidth: Integer;
begin
  if not (csLoading in ComponentState) and Assigned(FHighlighter) and not FHighlighter.Loading then
  begin
    if FLeftMargin.LineNumbers.Visible and FLeftMargin.Autosize then
      FLeftMargin.AutosizeDigitCount(Lines.Count);

    if FLeftMargin.Autosize then
    begin
      FTextDrawer.SetBaseFont(FLeftMargin.Font);
      LWidth := FLeftMargin.RealLeftMarginWidth(FTextDrawer.CharWidth);
      FLeftMarginCharWidth := FTextDrawer.CharWidth;
      FTextDrawer.SetBaseFont(Font);
      SetLeftMarginWidth(LWidth);
    end
    else
      SetLeftMarginWidth(FLeftMargin.GetWidth);
    Invalidate;
  end;
end;

procedure TBCBaseEditor.LoadFromFile(const AFileName: String);
var
  LFileStream: TFileStream;
  LBuffer: TBytes;
  LWithBOM: Boolean;
  LWordWrapEnabled: Boolean;
begin
  FEncoding := nil;
  ClearMatchingPair;
  LWordWrapEnabled := FWordWrap.Enabled;
  FWordWrap.Enabled := False;
  ClearCodeFolding;
  ClearBookmarks;
  LFileStream := TFileStream.Create(AFileName, fmOpenRead);
  try
    { Identify encoding }
    if IsUTF8(LFileStream, LWithBOM) then
    begin
      if LWithBOM then
        FEncoding := TEncoding.UTF8
      else
        FEncoding := BCEditor.Encoding.TEncoding.UTF8WithoutBOM;
    end
    else
    { Read file into buffer }
    begin
      SetLength(LBuffer, LFileStream.Size);
      LFileStream.ReadBuffer(pointer(LBuffer)^, Length(LBuffer));
      TEncoding.GetBufferEncoding(LBuffer, FEncoding);
    end;
    LFileStream.Position := 0;
    FLines.LoadFromStream(LFileStream, FEncoding);
  finally
    LFileStream.Free;
  end;
  if FCodeFolding.Visible then
    InitCodeFolding;
  if CanFocus then
    SetFocus;
  FWordWrap.Enabled := LWordWrapEnabled;
  SizeOrFontChanged(True);
end;

procedure TBCBaseEditor.LockUndo;
begin
  FUndoList.Lock;
  FRedoList.Lock;
end;

procedure TBCBaseEditor.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  inherited Notification(AComponent, AOperation);

  if AOperation = opRemove then
  begin
    if AComponent = FChainedEditor then
      RemoveChainedEditor;

    if Assigned(FLeftMargin) then
      if Assigned(FLeftMargin.Bookmarks) then
        if Assigned(FLeftMargin.Bookmarks.Images) then
          if (AComponent = FLeftMargin.Bookmarks.Images) then
          begin
            FLeftMargin.Bookmarks.Images := nil;
            InvalidateLeftMarginLines(-1, -1);
          end;
  end;
end;

procedure TBCBaseEditor.PasteFromClipboard;
begin
  CommandProcessor(ecPaste, #0, nil);
end;

procedure TBCBaseEditor.DoPasteFromClipboard;
var
  LStartPositionOfBlock: TBCEditorTextPosition;
  LEndPositionOfBlock: TBCEditorTextPosition;
  LPasteMode: TBCEditorSelectionMode;
  LGlobalMem: HGLOBAL;
  P: PByte;
  LFoldRange: TBCEditorCodeFoldingRange;
begin
  if FCodeFolding.Visible then
  begin
    LFoldRange := CodeFoldingCollapsableFoldRangeForLine(CaretY);
    if Assigned(LFoldRange) and LFoldRange.Collapsed then
      Exit;
  end;
  if not CanPaste then
    Exit;

  BeginUndoBlock;
  LPasteMode := FSelection.Mode;
  try
    if Clipboard.HasFormat(ClipboardFormatBCEditor) then
    begin
      Clipboard.Open;
      try
        LGlobalMem := Clipboard.GetAsHandle(ClipboardFormatBCEditor);
        P := GlobalLock(LGlobalMem);
        try
          if Assigned(P) then
            LPasteMode := PBCEditorSelectionMode(P)^;
        finally
          GlobalUnlock(LGlobalMem);
        end
      finally
        Clipboard.Close;
      end;
    end
    else
    if Clipboard.HasFormat(ClipboardFormatBorland) then
    begin
      Clipboard.Open;
      try
        LGlobalMem := Clipboard.GetAsHandle(ClipboardFormatBorland);
        P := GlobalLock(LGlobalMem);
        try
          if Assigned(P) then
            if P^ = $02 then
              LPasteMode := smColumn
            else
              LPasteMode := smNormal;
        finally
          GlobalUnlock(LGlobalMem);
        end
      finally
        Clipboard.Close;
      end;
    end
    else
    if Clipboard.HasFormat(ClipboardFormatMSDev) then
      LPasteMode := smColumn;

    if SelectionAvailable then
      FUndoList.AddChange(crDelete, FSelectionBeginPosition, FSelectionEndPosition, GetSelectedText, FSelection.ActiveMode)
    else
      FSelection.ActiveMode := Selection.Mode;

    if SelectionAvailable then
    begin
      LStartPositionOfBlock := SelectionBeginPosition;
      LEndPositionOfBlock := SelectionEndPosition;
      FSelectionBeginPosition := LStartPositionOfBlock;
      FSelectionEndPosition := LEndPositionOfBlock;

      if FSelection.ActiveMode = smLine then
        LStartPositionOfBlock.Char := 1;
    end
    else
      LStartPositionOfBlock := CaretPosition;

    SetSelectedTextPrimitive(LPasteMode, PChar(GetClipboardText), True);
    LEndPositionOfBlock := SelectionEndPosition;
    if LPasteMode = smNormal then
      FUndoList.AddChange(crPaste, LStartPositionOfBlock, LEndPositionOfBlock, SelectedText, LPasteMode)
    else
    if LPasteMode = smLine then
    begin
      if CaretX = 1 then
        FUndoList.AddChange(crPaste, GetTextPosition(1, LStartPositionOfBlock.Line),
          GetTextPosition(CharsInWindow, LEndPositionOfBlock.Line - 1), SelectedText, smLine)
      else
        FUndoList.AddChange(crPaste, GetTextPosition(1, LStartPositionOfBlock.Line), LEndPositionOfBlock, SelectedText, smNormal);
    end;
  finally
    EndUndoBlock;
  end;

  EnsureCursorPositionVisible;
  RescanCodeFoldingRanges;
  Invalidate;
end;

procedure TBCBaseEditor.DoRedo;
begin
  CommandProcessor(ecRedo, #0, nil);
end;

procedure TBCBaseEditor.DoInternalRedo;

  procedure RemoveGroupBreak;
  var
    LUndoItem: TBCEditorUndoItem;
    LOldBlockNumber: Integer;
  begin
    if FRedoList.LastChangeReason = crGroupBreak then
    begin
      LOldBlockNumber := UndoList.BlockChangeNumber;
      LUndoItem := FRedoList.PopItem;
      try
        UndoList.BlockChangeNumber := LUndoItem.ChangeNumber;
        FUndoList.AddGroupBreak;
      finally
        UndoList.BlockChangeNumber := LOldBlockNumber;
        LUndoItem.Free;
      end;
      UpdateModifiedStatus;
    end;
  end;

var
  LUndoItem: TBCEditorUndoItem;
  LOldChangeNumber: Integer;
  LSaveChangeNumber: Integer;
  LLastChangeReason: TBCEditorChangeReason;
  LLastChangeString: string;
  LAutoComplete: Boolean;
  LPasteAction: Boolean;
  LKeepGoing: Boolean;
  LCodeFoldingAction: Boolean;
begin
  if ReadOnly then
    Exit;

  LLastChangeReason := FRedoList.LastChangeReason;
  LLastChangeString := FRedoList.LastChangeString;
  LAutoComplete := LLastChangeReason = crAutoCompleteBegin;
  LPasteAction := LLastChangeReason = crPaste;
  LCodeFoldingAction := FCodeFolding.Visible and (LLastChangeReason in [crCollapseFold, crUncollapseFold]);

  LUndoItem := FRedoList.PeekItem;
  if Assigned(LUndoItem) then
  begin
    LOldChangeNumber := LUndoItem.ChangeNumber;
    LSaveChangeNumber := FUndoList.BlockChangeNumber;
    FUndoList.BlockChangeNumber := LUndoItem.ChangeNumber;
    try
      repeat
        RedoItem;
        LUndoItem := FRedoList.PeekItem;
        if not Assigned(LUndoItem) then
          LKeepGoing := False
        else
        begin
          if LAutoComplete then
            LKeepGoing := FRedoList.LastChangeReason <> crAutoCompleteEnd
          else
          if LPasteAction then
            LKeepGoing := (uoGroupUndo in FUndo.Options) and (FRedoList.LastChangeString = LLastChangeString)
          else
          if LCodeFoldingAction then
            LKeepGoing := False
          else
          if LUndoItem.ChangeNumber = LOldChangeNumber then
            LKeepGoing := True
          else
          begin
            LKeepGoing := ((uoGroupUndo in FUndo.Options) and (LLastChangeReason = LUndoItem.ChangeReason) and
              not (LLastChangeReason in [crIndent, crUnindent]));
          end;
          LLastChangeReason := LUndoItem.ChangeReason;
        end;
      until not LKeepGoing;

      if LAutoComplete and (FRedoList.LastChangeReason = crAutoCompleteEnd) then
      begin
        RedoItem;
        UpdateModifiedStatus;
      end;

    finally
      FUndoList.BlockChangeNumber := LSaveChangeNumber;
    end;
    RemoveGroupBreak;
  end;
end;

procedure TBCBaseEditor.RegisterCommandHandler(const AHookedCommandEvent: TBCEditorHookedCommandEvent; AHandlerData: Pointer);
begin
  if not Assigned(AHookedCommandEvent) then
    Exit;
  if not Assigned(FHookedCommandHandlers) then
    FHookedCommandHandlers := TObjectList.Create;
  if FindHookedCommandEvent(AHookedCommandEvent) = -1 then
    FHookedCommandHandlers.Add(TBCEditorHookedCommandHandler.Create(AHookedCommandEvent, AHandlerData))
end;

procedure TBCBaseEditor.RemoveChainedEditor;
begin
  if Assigned(FChainedEditor) then
    RemoveFreeNotification(FChainedEditor);
  FChainedEditor := nil;

  UnhookEditorLines;
end;

procedure TBCBaseEditor.RemoveFocusControl(AControl: TWinControl);
begin
  FFocusList.Remove(AControl);
end;

procedure TBCBaseEditor.RemoveKeyDownHandler(AHandler: TKeyEvent);
begin
  FKeyboardHandler.RemoveKeyDownHandler(AHandler);
end;

procedure TBCBaseEditor.RemoveKeyPressHandler(AHandler: TBCEditorKeyPressWEvent);
begin
  FKeyboardHandler.RemoveKeyPressHandler(AHandler);
end;

procedure TBCBaseEditor.RemoveKeyUpHandler(AHandler: TKeyEvent);
begin
  FKeyboardHandler.RemoveKeyUpHandler(AHandler);
end;

procedure TBCBaseEditor.RemoveMouseCursorHandler(AHandler: TBCEditorMouseCursorEvent);
begin
  FKeyboardHandler.RemoveMouseCursorHandler(AHandler);
end;

procedure TBCBaseEditor.RemoveMouseDownHandler(AHandler: TMouseEvent);
begin
  FKeyboardHandler.RemoveMouseDownHandler(AHandler);
end;

procedure TBCBaseEditor.RemoveMouseUpHandler(AHandler: TMouseEvent);
begin
  FKeyboardHandler.RemoveMouseUpHandler(AHandler);
end;

procedure TBCBaseEditor.RescanCodeFoldingRanges;
var
  i, j: Integer;
  LCount, LLinesWithFoldsCount: Integer;
  LFoldRangeLookup: array of Boolean;
  LUncollapsedLinenumbersLookup: array of Integer;
  LTemporaryLines: TStringList;
  LTemporaryAllCodeFoldingRanges: TBCEditorAllCodeFoldingRanges;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  FNeedToRescanCodeFolding := False;

  { Delete all uncollapsed folds, if not in redo list }
  for i := FAllCodeFoldingRanges.AllCount - 1 downto 0 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if Assigned(LCodeFoldingRange) then
    begin
      if not LCodeFoldingRange.Collapsed and not LCodeFoldingRange.ParentCollapsed and
        not LCodeFoldingRange.UndoListed then
      begin
        FreeAndNil(LCodeFoldingRange);
        FAllCodeFoldingRanges.List.Delete(i);
      end;
    end;
  end;

  SetLength(LFoldRangeLookup, FLines.Count + 1);
  LCount := FAllCodeFoldingRanges.AllCount - 1;
  LLinesWithFoldsCount := 0;

  for i := 0 to LCount do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if Assigned(LCodeFoldingRange) then
      if not LCodeFoldingRange.ParentCollapsed then
        if LCodeFoldingRange.FromLine <= Length(LFoldRangeLookup) then
        begin
          LFoldRangeLookup[LCodeFoldingRange.FromLine] := True;
          Inc(LLinesWithFoldsCount);
        end;
  end;

  LTemporaryLines := TStringList.Create;
  try
    SetLength(LUncollapsedLinenumbersLookup, (Lines.Count - LLinesWithFoldsCount) + 1);
    LCount := FLines.Count - 1;

    for i := 0 to LCount do
    if not LFoldRangeLookup[Succ(i)] then
    begin
      LTemporaryLines.Add(Lines[i]);
      LUncollapsedLinenumbersLookup[LTemporaryLines.Count] := Succ(i);
    end;
    LTemporaryAllCodeFoldingRanges := FAllCodeFoldingRanges; { pointer to old ranges }
    FAllCodeFoldingRanges := TBCEditorAllCodeFoldingRanges.Create;

    ScanCodeFoldingRanges(FAllCodeFoldingRanges, LTemporaryLines);

    { correct the FromLine and ToLine properites of newly created folds because they don't encapsulate the real line numbers }
    LCount := FAllCodeFoldingRanges.AllCount - 1;

    for i := 0 to LCount do
    begin
      LCodeFoldingRange := FAllCodeFoldingRanges[i];
      LCodeFoldingRange.FromLine := LUncollapsedLinenumbersLookup[LCodeFoldingRange.FromLine];
      LCodeFoldingRange.ToLine := LUncollapsedLinenumbersLookup[LCodeFoldingRange.ToLine];
    end;

    if LTemporaryAllCodeFoldingRanges.AllCount > 0 then
    begin
      { combine collapsed items with new items }
      for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
      begin
        LCodeFoldingRange := FAllCodeFoldingRanges[i];
        for j := 0 to LTemporaryAllCodeFoldingRanges.AllCount - 1 do
        begin
          if FAllCodeFoldingRanges[i].FromLine < LTemporaryAllCodeFoldingRanges[j].FromLine then
          begin
            LTemporaryAllCodeFoldingRanges.List.Insert(j, LCodeFoldingRange);
            FAllCodeFoldingRanges[i] := nil; { destroy pointer }
            Break;
          end;
          if j = LTemporaryAllCodeFoldingRanges.AllCount - 1 then
          begin
            LTemporaryAllCodeFoldingRanges.List.Add(LCodeFoldingRange);
            FAllCodeFoldingRanges[i] := nil; { destroy pointer }
          end;
        end;
      end;
      FAllCodeFoldingRanges.ClearAll;
      FAllCodeFoldingRanges.Free;
      FAllCodeFoldingRanges := nil;
      FAllCodeFoldingRanges := LTemporaryAllCodeFoldingRanges;
    end
    else
    begin
      LTemporaryAllCodeFoldingRanges.ClearAll;
      LTemporaryAllCodeFoldingRanges.Free;
    end;
  finally
    CodeFoldingPrepareRangeForLine;
    Finalize(LFoldRangeLookup);
    LFoldRangeLookup := nil;
    Finalize(LUncollapsedLinenumbersLookup);
    LUncollapsedLinenumbersLookup := nil;
    LTemporaryLines.Free;
  end;
  Invalidate;
end;

procedure TBCBaseEditor.SaveToFile(const AFileName: String);
var
  LUncollapsedLines: TStringList;
var
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFileName, fmCreate);
  try
    LUncollapsedLines := CreateUncollapsedLines;
    try
      LUncollapsedLines.SaveToStream(LFileStream, FEncoding);
    finally
      LUncollapsedLines.Free;
    end;
    FModified := False;
  finally
    LFileStream.Free;
  end;
end;

procedure TBCBaseEditor.SelectAll;
var
  LOldCaretPosition, LLastTextPosition: TBCEditorTextPosition;
begin
  LOldCaretPosition := CaretPosition;
  LLastTextPosition.Char := 1;
  LLastTextPosition.Line := FLines.Count;
  if LLastTextPosition.Line > 0 then
    Inc(LLastTextPosition.Char, Length(Lines[LLastTextPosition.Line - 1]))
  else
    LLastTextPosition.Line := 1;
  SetCaretAndSelection(LOldCaretPosition, GetTextPosition(1, 1), LLastTextPosition);
  FLastSortOrder := soDesc;
  Invalidate;
end;

procedure TBCBaseEditor.SetBookmark(AIndex: Integer; X: Integer; Y: Integer);
var
  LBookmark: TBCEditorBookmark;
begin
  if (AIndex in [0 .. 8]) and (Y >= 1) and (Y <= Max(1, FLines.Count)) then
  begin
    LBookmark := TBCEditorBookmark.Create(Self);
    with LBookmark do
    begin
      Line := Y;
      Char := X;
      ImageIndex := AIndex;
      Index := AIndex;
      Visible := True;
      InternalImage := not Assigned(FLeftMargin.Bookmarks.Images);
    end;
    DoOnBeforeBookmarkPlaced(LBookmark);
    if Assigned(LBookmark) then
    begin
      if Assigned(FBookmarks[AIndex]) then
        ClearBookmark(AIndex);
      FBookmarks[AIndex] := LBookmark;
      FMarkList.Add(FBookmarks[AIndex]);
    end;
    DoOnAfterBookmarkPlaced;
  end;
end;

procedure TBCBaseEditor.SetCaretAndSelection(const CaretPosition, BlockBeginPosition, BlockEndPosition: TBCEditorTextPosition; ACaret: Integer = -1);
var
  LOldSelectionMode: TBCEditorSelectionMode;
begin
  LOldSelectionMode := FSelection.ActiveMode;
  IncPaintLock;
  try
    InternalCaretPosition := CaretPosition;
    SetSelectionBeginPosition(BlockBeginPosition);
    SetSelectionEndPosition(BlockEndPosition);
  finally
    FSelection.ActiveMode := LOldSelectionMode;
    DecPaintLock;
  end;
end;

procedure TBCBaseEditor.SetFocus;
begin
  if FFocusList.Count > 0 then
  begin
    if TWinControl(FFocusList.Last).CanFocus then
      TWinControl(FFocusList.Last).SetFocus;
    Exit;
  end;
  Windows.SetFocus(Handle);
  inherited;
end;

procedure TBCBaseEditor.SetLineColor(ALine: Integer; AForegroundColor, ABackgroundColor: TColor);
begin
  if (ALine >= 0) and (ALine < FLines.Count) then
  begin
    FLines.Attributes[ALine].Mask := FLines.Attributes[ALine].Mask + [amBackground, amForeground];
    FLines.Attributes[ALine].Foreground := AForegroundColor;
    FLines.Attributes[ALine].Background := ABackgroundColor;
    InvalidateLine(ALine + 1);
  end;
end;

procedure TBCBaseEditor.SetLineColorToDefault(ALine: Integer);
begin
  if (ALine >= 0) and (ALine < FLines.Count) then
  begin
    FLines.Attributes[ALine].Mask := FLines.Attributes[ALine].Mask - [amBackground, amForeground];
    InvalidateLine(ALine + 1);
  end;
end;

procedure TBCBaseEditor.Sort(ASortOrder: TBCEditorSortOrder = soToggle);
var
  i, LLastLength: Integer;
  s: string;
  LStringList: TStringList;
  LOldSelectionBeginPosition, LOldSelectionEndPosition: TBCEditorTextPosition;
begin
  if Focused then
  begin
    LStringList := TStringList.Create;
    try
      if SelectionAvailable then
        LStringList.Text := SelectedText
      else
        LStringList.Text := Text;
      LStringList.Sort;
      s := '';
      if (ASortOrder = soDesc) or (ASortOrder = soToggle) and (FLastSortOrder = soAsc) then
      begin
        FLastSortOrder := soDesc;
        for i := LStringList.Count - 1 downto 0 do
        begin
          s := s + LStringList.Strings[i];
          if i <> 0 then
            s := s + Chr(13) + Chr(10);
        end;
      end
      else
      begin
        FLastSortOrder := soAsc;
        s := LStringList.Text;
      end;
      s := TrimRight(s);
      LStringList.Text := s;

      if SelectionAvailable then
      begin
        LOldSelectionBeginPosition := GetSelectionBeginPosition;
        LOldSelectionEndPosition := GetSelectionEndPosition;
        SelectedText := s;
        FSelectionBeginPosition := LOldSelectionBeginPosition;
        FSelectionEndPosition := LOldSelectionEndPosition;
        LLastLength := Length(LStringList.Strings[LStringList.Count - 1]) + 1;
        FSelectionEndPosition.Char := LLastLength
      end
      else
        Text := s;
    finally
      LStringList.Free;
    end;
  end;
end;

procedure TBCBaseEditor.ToggleBookmark(AIndex: Integer = -1);
var
  i: Integer;
  X, Y: Integer;
begin
  if AIndex <> -1 then
  begin
    if not GetBookmark(AIndex, X, Y) then
      SetBookmark(AIndex, CaretX, CaretY)
    else
      ClearBookmark(AIndex);
  end
  else
  begin
    for i := 0 to Marks.Count - 1 do
      if CaretY = Marks[i].Line then
      begin
        ClearBookmark(Marks[i].Index);
        Exit;
      end;
    X := CaretX;
    Y := CaretY;
    for i := 0 to 8 do
      if not GetBookmark(i, X, Y) then { variables used because X and Y are var parameters }
      begin
        SetBookmark(i, CaretX, CaretY);
        Exit;
      end;
  end;
end;

procedure TBCBaseEditor.UnhookEditorLines;
var
  LOldWrap: Boolean;
begin
  Assert(not Assigned(FChainedEditor));
  if FLines = FOriginalLines then
    Exit;

  LOldWrap := GetWordWrap;
  UpdateWordWrap(False);

  with FLines do
  begin
    OnCleared := FChainListCleared;
    OnDeleted := FChainListDeleted;
    OnInserted := FChainListInserted;
    OnPutted := FChainListPutted;
    OnChanging := FChainLinesChanging;
    OnChange := FChainLinesChanged;
  end;
  FUndoList.OnAddedUndo := FChainUndoAdded;
  FRedoList.OnAddedUndo := FChainRedoAdded;

  FChainListCleared := nil;
  FChainListDeleted := nil;
  FChainListInserted := nil;
  FChainListPutted := nil;
  FChainLinesChanging := nil;
  FChainLinesChanged := nil;
  FChainUndoAdded := nil;

  FLines := FOriginalLines;
  FUndoList := FOriginalUndoList;
  FRedoList := FOriginalRedoList;
  LinesHookChanged;

  UpdateWordWrap(LOldWrap);
end;

procedure TBCBaseEditor.ToggleSelectedCase(ACase: TBCEditorCase = cNone);
var
  LSelectionStart, LSelectionEnd: TBCEditorTextPosition;
begin
  if UpperCase(SelectedText) <> UpperCase(FSelectedCaseText) then
  begin
    FSelectedCaseCycle := cUpper;
    FSelectedCaseText := SelectedText;
  end;
  if ACase <> cNone then
    FSelectedCaseCycle := ACase;

  BeginUpdate;
  LSelectionStart := SelectionBeginPosition;
  LSelectionEnd := SelectionEndPosition;
  case FSelectedCaseCycle of
    cUpper: { UPPERCASE }
      if FSelection.ActiveMode = smColumn then
        CommandProcessor(ecUpperCaseBlock, #0, nil)
      else
        CommandProcessor(ecUpperCase, #0, nil);
    cLower: { lowercase }
      if FSelection.ActiveMode = smColumn then
        CommandProcessor(ecLowerCaseBlock, #0, nil)
      else
        CommandProcessor(ecLowerCase, #0, nil);
    cAlternating: { aLtErNaTiNg cAsE }
      if FSelection.ActiveMode = smColumn then
        CommandProcessor(ecAlternatingCaseBlock, #0, nil)
      else
        CommandProcessor(ecAlternatingCase, #0, nil);
    cSentence: { Sentence case }
       CommandProcessor(ecSentenceCase, #0, nil);
    cTitle: { Title Case }
      CommandProcessor(ecTitleCase, #0, nil);
    cOriginal: { Original text }
      SelectedText := FSelectedCaseText;
  end;
  SelectionBeginPosition := LSelectionStart;
  SelectionEndPosition := LSelectionEnd;
  EndUpdate;

  Inc(FSelectedCaseCycle);
  if FSelectedCaseCycle > cOriginal then
    FSelectedCaseCycle := cUpper;
end;

procedure TBCBaseEditor.UnlockUndo;
begin
  FUndoList.Unlock;
  FRedoList.Unlock;
end;

procedure TBCBaseEditor.UnregisterCommandHandler(AHookedCommandEvent: TBCEditorHookedCommandEvent);
var
  i: Integer;
begin
  if not Assigned(AHookedCommandEvent) then
    Exit;
  i := FindHookedCommandEvent(AHookedCommandEvent);
  if i > -1 then
    FHookedCommandHandlers.Delete(i)
end;

procedure TBCBaseEditor.UpdateCaret;
var
  X, Y: Integer;
  LClientRect: TRect;
  LCaretDisplayPosition: TBCEditorDisplayPosition;
  LCaretPoint: TPoint;
  LCompositionForm: TCompositionForm;
begin
  if (PaintLock <> 0) or not (Focused or FAlwaysShowCaret) then
    Include(FStateFlags, sfCaretChanged)
  else
  begin
    Exclude(FStateFlags, sfCaretChanged);
    LCaretDisplayPosition := DisplayPosition;
    if GetWordWrap and (LCaretDisplayPosition.Column > CharsInWindow + 1) then
      LCaretDisplayPosition.Column := CharsInWindow + 1;
    LCaretPoint := RowColumnToPixels(LCaretDisplayPosition);
    X := LCaretPoint.X + FCaretOffset.X;
    Y := LCaretPoint.Y + FCaretOffset.Y;
    LClientRect := ClientRect;
    DeflateMinimapRect(LClientRect);

    if (X >= ClientRect.Left + FLeftMargin.Width + FCodeFolding.GetWidth) and (X < ClientRect.Right) and (Y >= ClientRect.Top) and (Y < ClientRect.Bottom) then
    begin
      SetCaretPos(X, Y);
      ShowCaret;
    end
    else
    begin
      SetCaretPos(X, Y);
      HideCaret;
    end;

    LCompositionForm.dwStyle := CFS_POINT;
    LCompositionForm.ptCurrentPos := Point(X, Y);
    ImmSetCompositionWindow(ImmGetContext(Handle), @LCompositionForm);

    if Assigned(FOnCaretChanged) then
      FOnCaretChanged(Self, CaretX, CaretY);
  end;
end;

function IsTextMessage(Msg: Cardinal): Boolean;
begin
  Result := (Msg = WM_SETTEXT) or (Msg = WM_GETTEXT) or (Msg = WM_GETTEXTLENGTH);
end;

procedure TBCBaseEditor.WndProc(var Message: TMessage);
const
  ALT_KEY_DOWN = $20000000;
{$IFDEF USE_ALPHASKINS}
var
  PS: TPaintStruct;
{$ENDIF}
begin
  { Prevent Alt-Backspace from beeping }
  if (Message.Msg = WM_SYSCHAR) and (Message.wParam = VK_BACK) and (Message.LParam and ALT_KEY_DOWN <> 0) then
    Message.Msg := 0;

  { handle direct WndProc calls that could happen through VCL-methods like Perform }
  if HandleAllocated and IsWindowUnicode(Handle) then
  begin
    if not FWindowProducedMessage then
    begin
      FWindowProducedMessage := True;
      if IsTextMessage(Message.Msg) then
      begin
        with Message do
          Result := SendMessageA(Handle, Msg, wParam, LParam);
        Exit;
      end;
    end
    else
      FWindowProducedMessage := False;
  end;
  {$IFDEF USE_ALPHASKINS}
  case Message.Msg of
    SM_ALPHACMD:
      case Message.WParamHi of
        AC_CTRLHANDLED:
          begin
            Message.Result := 1;
            Exit;
          end;

        AC_SETNEWSKIN:
          if ACUInt(Message.LParam) = ACUInt(SkinData.SkinManager) then
          begin
            CommonWndProc(Message, FCommonData);
            Exit;
          end;

        AC_REMOVESKIN:
          if ACUInt(Message.LParam) = ACUInt(SkinData.SkinManager) then
          begin
            if FScrollWnd <> nil then
              FreeAndNil(FScrollWnd);

            CommonWndProc(Message, FCommonData);
            RecreateWnd;
            Exit;
          end;

        AC_REFRESH:
          if ACUInt(Message.LParam) = ACUInt(SkinData.SkinManager) then
          begin
            CommonWndProc(Message, FCommonData);
            RefreshEditScrolls(SkinData, FScrollWnd);
            if HandleAllocated and Visible then
              RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_ERASE or RDW_FRAME);

            Exit;
          end
      end;

    CM_FONTCHANGED:
      if Showing and HandleAllocated then
        RedrawWindow(Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_FRAME);
  end;

  if not ControlIsReady(Self) or not FCommonData.Skinned then
    inherited
  else
  begin
    case Message.Msg of
      WM_PAINT:
        begin
          if InUpdating(FCommonData) then
          begin
            BeginPaint(Handle, PS);
            EndPaint  (Handle, PS);
            Exit;
          end;
          inherited;
          Exit;
        end;
    end;
    if CommonWndProc(Message, FCommonData) then
      Exit;

    inherited;

    case Message.Msg of
      CM_SHOWINGCHANGED:
        RefreshEditScrolls(SkinData, FScrollWnd);

      CM_VISIBLECHANGED, CM_ENABLEDCHANGED, WM_SETFONT:
        FCommonData.Invalidate;

      CM_TEXTCHANGED, CM_CHANGED:
        if Assigned(FScrollWnd) then
          UpdateScrolls(FScrollWnd, True);
    end;
  end;
  {$ELSE}
  inherited;
  {$ENDIF}
end;

initialization

  {$IFDEF USE_VCL_STYLES}
  TCustomStyleEngine.RegisterStyleHook(TBCBaseEditor, TBCEditorStyleHook);
  {$ENDIF}
  ClipboardFormatBCEditor := RegisterClipboardFormat(BCEDITOR_CLIPBOARD_FORMAT_BCEDITOR);
  ClipboardFormatBorland := RegisterClipboardFormat(BCEDITOR_CLIPBOARD_FORMAT_BORLAND);
  ClipboardFormatMSDev := RegisterClipboardFormat(BCEDITOR_CLIPBOARD_FORMAT_MSDEV);

finalization
  {$IFDEF USE_VCL_STYLES}
  TCustomStyleEngine.UnregisterStyleHook(TBCBaseEditor, TBCEditorStyleHook);
  {$ENDIF}

end.
