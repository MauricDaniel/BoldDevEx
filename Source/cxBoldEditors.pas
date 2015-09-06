unit cxBoldEditors;

{$ASSERTIONS ON}

{.$DEFINE Constraints}
{.$DEFINE BoldDevExLog}
{.$DEFINE LOGCHANGES}

interface

uses
  Classes,

  cxClasses,
  cxControls,
  cxEdit,
  cxTextEdit,
  cxDropDownEdit,
  cxCalendar,
  cxTimeEdit,
  cxMemo,
  cxCurrencyEdit,
  cxMaskEdit,
  cxCheckBox,
  cxSpinEdit,
  cxButtonEdit,
  cxHyperLinkEdit,
  cxProgressBar,
  cxBarEditItem,
  dxBar,
  cxContainer,
  {$IFDEF DevExScheduler}
  cxDateNavigator,
  {$ENDIF}
  cxLabel,
  cxImage,
  cxRichEdit,
  cxCheckListBox,
  cxListBox,
  cxListView, ComCtrls,
  cxDataUtils,

  cxLookAndFeelPainters, // for  TcxCheckBoxState = (cbsUnchecked, cbsChecked, cbsGrayed);
  StdCtrls, // for    TCheckBoxState = (cbUnchecked, cbChecked, cbGrayed);
  cxGraphics,
  Controls,// for TCaption
  Messages, // for TMessage
  Windows,

  BoldSubscription,
  BoldVariantControlPack,
  BoldCheckboxStateControlPack,
  BoldControllerListControlPack,
  BoldElementHandleFollower,
  BoldControlPack,
  BoldHandles,
  BoldElements,
  BoldControlPackDefs,
  BoldSystem,
  BoldSystemRT,
  BoldListHandleFollower,
  BoldListListControlPack,
  BoldControlsDefs,
  BoldDefs,
  BoldAbstractListHandle,
  BoldQueue,
  BoldComponentvalidator;

type
  TcxCustomBoldEditDefaultValuesProvider = class;
  TcxBoldEditDataBinding = class;
  TBoldComboListController = class;
  TcxCustomBoldTextEditProperties = class;
  TcxBoldTextEditProperties = class;
  TcxBoldTextEdit = class;
  TcxBoldDateEdit = class;

  IcxBoldEditProperties = Interface
  ['{D50859F1-F550-4CE6-84DE-5074921512E5}']
    procedure SetStoredValue(aValue: Variant; aBoldHandle: TBoldElementHandle; aEdit: TcxCustomEdit; aFollower: TBoldFollower; var aDone: boolean);
    function BoldElementToEditValue(aFollower: TBoldFollower; aElement: TBoldElement; aEdit: TcxCustomEdit): variant;
    function CanEdit(aBoldHandle: TBoldElementHandle; aFollower: TBoldFollower): boolean;
  end;

  TBoldComboListController = class(TBoldAbstractListAsFollowerListController)
  published
     property NilElementMode;
  end;

  TcxCustomBoldTextEditProperties = class(TcxCustomTextEditProperties, IcxBoldEditProperties, IBoldValidateableComponent)
  private
    fListHandleFollower: TBoldListHandleFollower;
    fBoldListProperties: TBoldAbstractListAsFollowerListController; // TBoldComboListController;
    fBoldRowProperties: TBoldVariantFollowerController;
    fBoldSelectChangeAction: TBoldComboSelectChangeAction;
    fBoldSetValueExpression: TBoldExpression;
    function GetBoldListHandle: TBoldAbstractListHandle;
    function GetListFollower: TBoldFollower;
    procedure SetBoldListHandle(const Value: TBoldAbstractListHandle);
    procedure SetBoldListProperties(const Value: TBoldAbstractListAsFollowerListController);
    procedure SetRowProperties(const Value: TBoldVariantFollowerController);
    function GetContextForBoldRowProperties: TBoldElementTypeInfo;
    procedure SetBoldSelectChangeAction(Value: TBoldComboSelectChangeAction);
    // IBoldValidateableComponent
    function ValidateComponent(ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean;
    // IcxBoldEditProperties
    procedure SetStoredValue(aValue: Variant; aBoldHandle: TBoldElementHandle; aEdit: TcxCustomEdit; aFollower: TBoldFollower; var aDone: boolean);
    function BoldElementToEditValue(aFollower: TBoldFollower; aElement: TBoldElement; aEdit: TcxCustomEdit): variant;
    function CanEdit(aBoldHandle: TBoldElementHandle; aFollower: TBoldFollower): boolean;
    procedure SetBoldSetValueExpression(const Value: TBoldExpression);
  protected
{$IFNDEF AttracsBold}
    procedure _InsertItem(Follower: TBoldFollower);
{$ELSE}
    procedure _InsertItem(Index: Integer; Follower: TBoldFollower);
{$ENDIF}
    procedure _DeleteItem(Index: Integer; OwningFollower: TBoldFollower);
    procedure _RowAfterMakeUptoDate(Follower: TBoldFollower);
    procedure _BeforeMakeUptoDate(Follower: TBoldFollower);
    procedure _AfterMakeUptoDate(Follower: TBoldFollower);
    property BoldLookupListHandle: TBoldAbstractListHandle read GetBoldListHandle write SetBoldListHandle;
    property BoldLookupListProperties: TBoldAbstractListAsFollowerListController read fBoldListProperties write SetBoldListProperties;
    property BoldRowProperties: TBoldVariantFollowerController read fBoldRowProperties write SetRowProperties;
    property BoldSelectChangeAction: TBoldComboSelectChangeAction read fBoldSelectChangeAction write SetBoldSelectChangeAction default bdcsSetValue;
    property BoldSetValueExpression: TBoldExpression read fBoldSetValueExpression write SetBoldSetValueExpression;
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    class function GetContainerClass: TcxContainerClass; override;
    property LookupListFollower: TBoldFollower read GetListFollower;
  end;

  TcxBoldComboBoxProperties = class(TcxCustomComboBoxProperties, IcxBoldEditProperties, IBoldValidateableComponent)
  private
    fListHandleFollower: TBoldListHandleFollower;
    fBoldListProperties: TBoldComboListController;
    fBoldRowProperties: TBoldVariantFollowerController;
    fBoldSelectChangeAction: TBoldComboSelectChangeAction;
    fBoldSetValueExpression: TBoldExpression;
    function GetBoldListHandle: TBoldAbstractListHandle;
    function GetListFollower: TBoldFollower;
    procedure SetBoldListHandle(const Value: TBoldAbstractListHandle);
    procedure SetBoldListProperties(const Value: TBoldComboListController);
    procedure SetRowProperties(const Value: TBoldVariantFollowerController);
    function GetContextForBoldRowProperties: TBoldElementTypeInfo;
    procedure SetBoldSelectChangeAction(Value: TBoldComboSelectChangeAction);
    // IBoldValidateableComponent
    function ValidateComponent(ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean;
    // IcxBoldEditProperties
    procedure SetStoredValue(aValue: Variant; aBoldHandle: TBoldElementHandle; aEdit: TcxCustomEdit; aFollower: TBoldFollower; var aDone: boolean);
    function BoldElementToEditValue(aFollower: TBoldFollower; aElement: TBoldElement; aEdit: TcxCustomEdit): variant;
    function CanEdit(aBoldHandle: TBoldElementHandle; aFollower: TBoldFollower): boolean;
    procedure SetBoldSetValueExpression(const Value: TBoldExpression);
  protected
{$IFNDEF AttracsBold}
    procedure _InsertItem(Follower: TBoldFollower);
{$ELSE}
    procedure _InsertItem(Index: Integer; Follower: TBoldFollower);
{$ENDIF}
    procedure _DeleteItem(Index: Integer; OwningFollower: TBoldFollower);
    procedure _RowAfterMakeUptoDate(Follower: TBoldFollower);
    procedure _BeforeMakeUptoDate(Follower: TBoldFollower);
    procedure _AfterMakeUptoDate(Follower: TBoldFollower);
    function GetAlwaysPostEditValue: Boolean; override;
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    class function GetContainerClass: TcxContainerClass; override;
    property LookupListFollower: TBoldFollower read GetListFollower;
  published
    property BoldLookupListHandle: TBoldAbstractListHandle read GetBoldListHandle write SetBoldListHandle;
    property BoldLookupListProperties: TBoldComboListController read fBoldListProperties write SetBoldListProperties;
    property BoldRowProperties: TBoldVariantFollowerController read fBoldRowProperties write SetRowProperties;
    property BoldSelectChangeAction: TBoldComboSelectChangeAction read fBoldSelectChangeAction write SetBoldSelectChangeAction default bdcsSetValue;
    property BoldSetValueExpression: TBoldExpression read fBoldSetValueExpression write SetBoldSetValueExpression;

    property Alignment;
    property AssignedValues;
    property AutoSelect;
    property BeepOnError;
    property ButtonGlyph;
    property CaseInsensitive;
    property CharCase;
    property ClearKey;
    property DropDownAutoWidth;
    property DropDownListStyle;
    property DropDownRows;
    property DropDownSizeable;
    property DropDownWidth;
    property HideSelection;
    property IgnoreMaskBlank;
    property ImeMode;
    property ImeName;
    property ImmediateDropDown;
//    property ImmediatePost;
    property ImmediateUpdateText;
    property IncrementalSearch;
    property ItemHeight;
    property MaskKind;
    property EditMask;
    property MaxLength;
    property OEMConvert;
    property PopupAlignment;
    property PostPopupValueOnTab;
    property ReadOnly;
    property Revertable;
//    property Sorted;
    property UseLeftAlignmentOnEditing;
    property ValidateOnEnter;
    property ValidationOptions;
    property OnChange;
    property OnCloseUp;
    property OnDrawItem;
    property OnEditValueChanged;
    property OnInitPopup;
    property OnMeasureItem;
    property OnNewLookupDisplayText;
    property OnPopup;
    property OnValidate;
  end;

  TcxSingleLinkEditProperties = class(TcxCustomHyperLinkEditProperties {TcxCustomHyperLinkEditProperties})
  published
    property Alignment;
    property AssignedValues;
//    property AutoComplete; // deprecated
    property AutoSelect;
    property ClearKey;
    property ImeMode;
    property ImeName;
    property IncrementalSearch;
    property LinkColor;
    property LookupItems;
//    property LookupItemsSorted;
//    property Prefix;
    property ReadOnly;
    property StartKey;
    property SingleClick;
    property UseLeftAlignmentOnEditing;
//    property UsePrefix;
    property ValidateOnEnter;
    property ValidationOptions;    
    property OnChange;
    property OnEditValueChanged;
    property OnStartClick;
    property OnValidate;
  end;


  TcxBoldTextEditProperties = class(TcxCustomBoldTextEditProperties)
  published
    property BoldLookupListHandle;
    property BoldLookupListProperties;
    property BoldRowProperties;
    property BoldSelectChangeAction;
    property BoldSetValueExpression;
    property Alignment;
    property AssignedValues;
    property AutoSelect;
    property BeepOnError;
    property CharCase;
    property ClearKey;
    property EchoMode;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property IncrementalSearch;
    property OEMConvert;
    property PasswordChar;
    property ReadOnly;
    property UseLeftAlignmentOnEditing;

    property ValidateOnEnter;
    property ValidationOptions;    
    property OnChange;
    property OnEditValueChanged;
    property OnNewLookupDisplayText;
    property OnValidate;
  end;

{$IFNDEF AttracsBold}
TBoldAbstractHandleFollower = TBoldQueueable;
{$ENDIF}

  TcxCustomBoldEditDefaultValuesProvider = class(TcxCustomEditDefaultValuesProvider)
  private
    fBoldHandleFollower: TBoldAbstractHandleFollower; // handle follower is needed if we end up needing to access follower
    fBoldProperties: TBoldFollowerController;
//    fcxBoldEditDataBinding: TcxBoldEditDataBinding;

// TODO: Place subscriptions instead of FreeNotification
//    procedure FreeNotification(Sender: TComponent);

    function GetFollower: TBoldFollower;
//    procedure SetBoldHandle(const Value: TBoldElementHandle);
    procedure SetBoldProperties(const Value: TBoldFollowerController);
    procedure SetHandleFollower(const Value: TBoldAbstractHandleFollower);
    function GetBoldHandle: TBoldElementHandle;
  protected
    function GetBoldElementTypeInfo: TBoldElementTypeInfo;
//    property DataBinding: TcxBoldEditDataBinding read fcxBoldEditDataBinding;
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
//    function CanSetEditMode: Boolean; override;
    function DefaultAlignment: TAlignment; override;
    function DefaultBlobKind: TcxBlobKind; override;
    function DefaultCanModify: Boolean; override;
//    function DefaultDisplayFormat: string; override;
//    function DefaultEditFormat: string; override;
//    function DefaultEditMask: string; override;
    function DefaultIsFloatValue: Boolean; override;
    function DefaultMaxLength: Integer; override;
//    function DefaultMaxValue: Double; override;
//    function DefaultMinValue: Double; override;
//    function DefaultPrecision: Integer; override;
//    function DefaultReadOnly: Boolean; override;
//    function DefaultRequired: Boolean; override;
    function IsBlob: Boolean; override;
    function IsCurrency: Boolean; override;
    function IsDataAvailable: Boolean; override;
//    function IsDataStorage: Boolean; override;
//    function IsDisplayFormatDefined(AIsCurrencyValueAccepted: Boolean): Boolean; override;
//    function IsOnGetTextAssigned: Boolean; override;
//    function IsOnSetTextAssigned: Boolean; override;
    function IsValidChar(AChar: Char): Boolean; override;

    property Follower: TBoldFollower read GetFollower;
    property BoldHandle: TBoldElementHandle read GetBoldHandle{ write SetBoldHandle};
    property BoldProperties: TBoldFollowerController read fBoldProperties write SetBoldProperties;
    property BoldHandleFollower: TBoldAbstractHandleFollower read fBoldHandleFollower write SetHandleFollower;
  end;

  TcxBoldEditDataBinding = class(TcxEditDataBinding)
  private
    fInternalChange: integer;
    fBoldHandleFollower: TBoldElementHandleFollower;
    fCurrentElementType: TBoldElementTypeInfo;
    fBoldFollowerController: TBoldFollowerController;
    fValueOrDefinitionInvalid: boolean;
    procedure SetBoldHandle(const Value: TBoldElementHandle);
    function GetFollower: TBoldFollower;
    function GetBoldHandle: TBoldElementHandle;
    function GetDefaultValuesProvider: TcxCustomBoldEditDefaultValuesProvider;

    procedure SetBoldProperties(const Value: TBoldVariantFollowerController);
    function GetBoldProperties: TBoldVariantFollowerController;

{$IFDEF Constraints}
    procedure SubscribeToConstraints(aElement: TBoldElement);
{$ENDIF}
    procedure SetValueOrDefinitionInvalid(const Value: boolean);
  protected
    // IBoldOCLComponent
    function GetContextType: TBoldElementTypeInfo;
    procedure SetExpression({$IFDEF AttracsBold}const{$ENDIF} Value: TBoldExpression);
    function GetVariableList: TBoldExternalVariableList;
    function GetExpression: TBoldExpression;

    // IBoldValidateableComponent
    function ValidateComponent(ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean;

    procedure _AfterMakeUptoDate(Follower: TBoldFollower); virtual;

    function ValidateTypeConforms(aExpressionType: TBoldElementTypeInfo): string; virtual;

    function MayModify: boolean; virtual;
    procedure TypeMayHaveChanged;
    procedure DoChanged; virtual;

    property BoldFollowerController: TBoldFollowerController read fBoldFollowerController;

    procedure InternalSetValue(const aValue: TcxEditValue); virtual;

    function ImmediatePost: boolean; virtual;

    procedure DefaultValuesChanged; override;
    function GetModified: Boolean; override;
    function GetStoredValue: TcxEditValue; override;
    function IsRefreshDisabled: Boolean;
    procedure Reset; override;
    procedure SetStoredValue(const Value: TcxEditValue); override;
    procedure DataChanged; virtual;
    procedure DataSetChange; virtual;
    procedure EditingChanged; virtual;
    function IsLookupControl: Boolean; virtual;
    procedure UpdateData; virtual;
    property DefaultValuesProvider: TcxCustomBoldEditDefaultValuesProvider read GetDefaultValuesProvider;
    procedure DoExit; virtual;
    property ValueOrDefinitionInvalid: boolean read fValueOrDefinitionInvalid write SetValueOrDefinitionInvalid;
  public
    constructor Create(AEdit: TcxCustomEdit); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function CanCheckEditorValue: Boolean; override;
    function CanModify: Boolean; override;
    function CanPostEditorValue: Boolean; override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    class function GetDefaultValuesProviderClass: TcxCustomEditDefaultValuesProviderClass; override;
    procedure SetModified; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    procedure UpdateDisplayValue; override;
    property Follower: TBoldFollower read GetFollower;
  published
    property BoldHandle: TBoldElementHandle read GetBoldHandle write SetBoldHandle;
//    property BoldHandleFollower: TBoldElementHandleFollower read fBoldHandleFollower write SetBoldHandleFollower;
//    property BoldProperties: TBoldVariantFollowerController read fBoldProperties write SetBoldProperties;
    property BoldProperties: TBoldVariantFollowerController read GetBoldProperties write SetBoldProperties;
  end;

  TcxBoldTextEditDataBinding = class(TcxBoldEditDataBinding)
  end;

  TcxBoldDateTimeEditDataBinding = class(TcxBoldEditDataBinding)
  protected
    function ValidateTypeConforms(aExpressionType: TBoldElementTypeInfo): string; override;
  end;

  TcxBoldTimeEditDataBinding = class(TcxBoldEditDataBinding)
  protected
    function ValidateTypeConforms(aExpressionType: TBoldElementTypeInfo): string; override;
  end;

  TcxBoldCheckBoxEditDataBinding = class(TcxBoldEditDataBinding)
  protected
    function ValidateTypeConforms(aExpressionType: TBoldElementTypeInfo): string; override;
    function ImmediatePost: boolean; override;
  public
    function MayModify: boolean; override; // TODO: move this up to TcxBoldEditDataBinding
  end;

  TcxBoldNumericEditDataBinding = class(TcxBoldEditDataBinding)
  protected
    function ValidateTypeConforms(aExpressionType: TBoldElementTypeInfo): string; override;
  end;

  TcxBoldFloatEditDataBinding = class(TcxBoldEditDataBinding)
  protected
    function ValidateTypeConforms(aExpressionType: TBoldElementTypeInfo): string; override;
  end;

  TcxBoldCurrencyEditDataBinding = class(TcxBoldEditDataBinding)
  protected
    function ValidateTypeConforms(aExpressionType: TBoldElementTypeInfo): string; override;
  end;

  TcxBoldBlobEditDataBinding = class(TcxBoldEditDataBinding)
  protected
    function ValidateTypeConforms(aExpressionType: TBoldElementTypeInfo): string; override;
  end;

  TcxBoldComboBoxEditDataBinding = class(TcxBoldTextEditDataBinding)
  protected
    function GetModified: Boolean; override;
    function ImmediatePost: boolean; override;
  end;

  TcxBoldTextEdit = class(TcxCustomTextEdit, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxBoldTextEditProperties;
    function GetProperties: TcxBoldTextEditProperties;
    procedure SetProperties(Value: TcxBoldTextEditProperties);
    function GetDataBinding: TcxBoldTextEditDataBinding;
    procedure SetDataBinding(Value: TcxBoldTextEditDataBinding);
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    function ValidateKeyDown(var Key: Word; Shift: TShiftState): Boolean; override;
    function ValidateKeyPress(var Key: Char): Boolean; override;
    procedure DoOnChange; override;
    procedure DoChange; override;
    procedure Paint; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxBoldTextEditProperties read GetActiveProperties;
    procedure DoExit; override;
  published
    property DataBinding: TcxBoldTextEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property Properties: TcxBoldTextEditProperties read GetProperties write SetProperties;
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
{$IFDEF DELPHI12}
    property TextHint;
{$ENDIF}
    property Visible;
    property OnClick;
{$IFDEF DELPHI5}
    property OnContextPopup;
{$ENDIF}
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    property OnEndDock;
    property OnStartDock;
  end;
{
  TcxCustomBoldDateEditProperties = class(TcxCustomDateEditProperties)
  end;

  TcxBoldDateEditProperties = class(TcxCustomBoldDateEditProperties)
  end;
}

  TcxBoldDateEdit = class(TcxCustomDateEdit, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxDateEditProperties;
    function GetProperties: TcxDateEditProperties;
    procedure SetProperties(Value: TcxDateEditProperties);
    function GetDataBinding: TcxBoldDateTimeEditDataBinding;
    procedure SetDataBinding(Value: TcxBoldDateTimeEditDataBinding);
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    function ValidateKeyDown(var Key: Word; Shift: TShiftState): Boolean; override;
    function ValidateKeyPress(var Key: Char): Boolean; override;
    procedure DoChange; override;
    procedure DoOnChange; override;
    function CanDropDown: Boolean; override;
    procedure Paint; override;
    procedure HidePopup(Sender: TcxControl; AReason: TcxEditCloseUpReason); override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxDateEditProperties read GetActiveProperties;
    procedure DoExit; override;
  published
    property DataBinding: TcxBoldDateTimeEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property Properties: TcxDateEditProperties read GetProperties write SetProperties;
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
//    property BiDiMode;
    property Constraints;
    property DragCursor;
    property DragKind;
//    property Date;
    property DragMode;
//    property EditValue;
    property Enabled;
    property ImeMode;
    property ImeName;
//    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop default True;
{$IFDEF DELPHI12}
    property TextHint;
{$ENDIF}
    property Visible;
    property OnClick;
  {$IFDEF DELPHI5}
    property OnContextPopup;
  {$ENDIF}
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    property OnStartDock;
  end;

  TcxBoldMemo = class(TcxCustomMemo, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxMemoProperties;
    function GetDataBinding: TcxBoldTextEditDataBinding;
    function GetProperties: TcxMemoProperties;
    procedure SetDataBinding(Value: TcxBoldTextEditDataBinding);
    procedure SetProperties(Value: TcxMemoProperties);
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    procedure DoChange; override;
    procedure Paint; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxMemoProperties read GetActiveProperties;
    procedure DoExit; override;
  published
    property Align;
    property Anchors;
    property Constraints;
    property DataBinding: TcxBoldTextEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxMemoProperties read GetProperties write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
{$IFDEF DELPHI12}
    property TextHint;
{$ENDIF}
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TcxBoldTimeEdit = class(TcxCustomTimeEdit, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxTimeEditProperties;
    function GetDataBinding: TcxBoldTimeEditDataBinding;
    function GetProperties: TcxTimeEditProperties;
    procedure SetDataBinding(Value: TcxBoldTimeEditDataBinding);
    procedure SetProperties(Value: TcxTimeEditProperties);
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    procedure DoChange; override;
    function ValidateKeyDown(var Key: Word; Shift: TShiftState): Boolean; override;
    function ValidateKeyPress(var Key: Char): Boolean; override;
    procedure Paint; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxTimeEditProperties read GetActiveProperties;
    procedure DoExit; override;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property DataBinding: TcxBoldTimeEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxTimeEditProperties read GetProperties write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
{$IFDEF DELPHI12}
    property TextHint;
{$ENDIF}
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TcxBoldCurrencyEdit = class(TcxCustomCurrencyEdit, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxCurrencyEditProperties;
    function GetDataBinding: TcxBoldCurrencyEditDataBinding;
    function GetProperties: TcxCurrencyEditProperties;
    procedure SetDataBinding(Value: TcxBoldCurrencyEditDataBinding);
    procedure SetProperties(Value: TcxCurrencyEditProperties);
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    procedure DoChange; override;
    procedure Paint; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxCurrencyEditProperties read GetActiveProperties;
    procedure DoExit; override;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property DataBinding: TcxBoldCurrencyEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxCurrencyEditProperties read GetProperties write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
{$IFDEF DELPHI12}
    property TextHint;
{$ENDIF}
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnEditing;
    property OnEndDock;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
  end;

  TcxBoldMaskEdit = class(TcxCustomMaskEdit, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxMaskEditProperties;
    function GetDataBinding: TcxBoldTextEditDataBinding;
    function GetProperties: TcxMaskEditProperties;
    procedure SetDataBinding(Value: TcxBoldTextEditDataBinding);
    procedure SetProperties(Value: TcxMaskEditProperties);
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    function SupportsSpelling: Boolean; override;
    procedure Paint; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxMaskEditProperties read GetActiveProperties;
    procedure DoExit; override;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property DataBinding: TcxBoldTextEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxMaskEditProperties read GetProperties write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
{$IFDEF DELPHI12}
    property TextHint;
{$ENDIF}
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    property OnEndDock;
    property OnStartDock;
  end;

  TcxBoldCheckBox = class(TcxCustomCheckBox, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxCheckBoxProperties;
    function GetDataBinding: TcxBoldCheckBoxEditDataBinding;
    function GetProperties: TcxCheckBoxProperties;
    procedure SetDataBinding(Value: TcxBoldCheckBoxEditDataBinding);
    procedure SetProperties(Value: TcxCheckBoxProperties);
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    procedure Toggle; override;
    procedure Paint; override;
    procedure Initialize; override;
    procedure DoChange; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxCheckBoxProperties read GetActiveProperties;
    procedure DoExit; override;
    property Checked;
  published
    property Action;
    property Align;
    property Anchors;
    property AutoSize;
    property Caption;
    property Constraints;
    property DataBinding: TcxBoldCheckBoxEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentBackground;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxCheckBoxProperties read GetProperties write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Transparent;
//    property TextHint;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    property OnEndDock;
    property OnStartDock;
  end;

  TcxBoldComboBox = class(TcxCustomComboBox, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxBoldComboBoxProperties;
    function GetDataBinding: TcxBoldComboBoxEditDataBinding;
    function GetProperties: TcxBoldComboBoxProperties;
    procedure SetDataBinding(Value: TcxBoldComboBoxEditDataBinding);
    procedure SetProperties(Value: TcxBoldComboBoxProperties);
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    function SupportsSpelling: Boolean; override;
    function CanDropDown: Boolean; override;
    procedure Paint; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxBoldComboBoxProperties read GetActiveProperties;
    procedure DoExit; override;
    property ItemIndex;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property DataBinding: TcxBoldComboBoxEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxBoldComboBoxProperties read GetProperties write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
{$IFDEF DELPHI12}
    property TextHint;
{$ENDIF}
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    property OnEndDock;
    property OnStartDock;
  end;

  // perhaps use TBoldIntegerFollowerController ?
  TcxBoldSpinEdit = class(TcxCustomSpinEdit, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxSpinEditProperties;
    function GetProperties: TcxSpinEditProperties;
    function GetDataBinding: TcxBoldNumericEditDataBinding;
    procedure SetDataBinding(Value: TcxBoldNumericEditDataBinding);
    procedure SetProperties(Value: TcxSpinEditProperties);
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    procedure Paint; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxSpinEditProperties read GetActiveProperties;
    procedure DoExit; override;
    property Value;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property DataBinding: TcxBoldNumericEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxSpinEditProperties read GetProperties write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
{$IFDEF DELPHI12}
    property TextHint;
{$ENDIF}
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TcxBoldButtonEdit = class(TcxCustomButtonEdit, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxButtonEditProperties;
    function GetDataBinding: TcxBoldTextEditDataBinding;
    function GetProperties: TcxButtonEditProperties;
    procedure SetDataBinding(Value: TcxBoldTextEditDataBinding);
    procedure SetProperties(Value: TcxButtonEditProperties);
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    procedure Paint; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxButtonEditProperties read GetActiveProperties;
    procedure DoExit; override;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property DataBinding: TcxBoldTextEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxButtonEditProperties read GetProperties write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
{$IFDEF DELPHI12}
    property TextHint;
{$ENDIF}
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    property OnEndDock;
    property OnStartDock;
  end;

  TcxBoldHyperLinkEdit = class(TcxCustomHyperLinkEdit, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxHyperLinkEditProperties;
    function GetDataBinding: TcxBoldTextEditDataBinding;
    function GetProperties: TcxHyperLinkEditProperties;
    procedure SetDataBinding(Value: TcxBoldTextEditDataBinding);
    procedure SetProperties(Value: TcxHyperLinkEditProperties);
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    procedure Paint; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxHyperLinkEditProperties read GetActiveProperties;
    procedure DoExit; override;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property DataBinding: TcxBoldTextEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxHyperLinkEditProperties read GetProperties write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
{$IFDEF DELPHI12}
    property TextHint;
{$ENDIF}
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnEditing;
    property OnEndDock;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
  end;

  TcxBoldProgressBar = class(TcxCustomProgressBar, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxProgressBarProperties;
    function GetDataBinding: TcxBoldNumericEditDataBinding;
    procedure SetDataBinding(Value: TcxBoldNumericEditDataBinding);
    function GetProperties: TcxProgressBarProperties;
    procedure SetProperties(Value: TcxProgressBarProperties);
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    procedure Initialize; override;
    procedure Paint; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxProgressBarProperties read GetActiveProperties;
  published
    property Align;
    property Anchors;
    property AutoSize;
    property Constraints;
    property DataBinding: TcxBoldNumericEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxProgressBarProperties read GetProperties write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Transparent;
    property Visible;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TcxBarBoldEditItem = class(TcxCustomBarEditItem)
  private
    fInternalChange: integer;
    fBoldHandleFollower: TBoldElementHandleFollower;
    fBoldProperties: TBoldVariantFollowerController;
    procedure SetBoldHandle(const Value: TBoldElementHandle);
    function GetFollower: TBoldFollower;
    function GetBoldHandle: TBoldElementHandle;
    procedure SetBoldProperties(const Value: TBoldVariantFollowerController);
  protected
    function GetContextType: TBoldElementTypeInfo;
    procedure _AfterMakeUptoDate(Follower: TBoldFollower);
//    function CanEdit: Boolean; override;
//    procedure DoEditValueChanged(Sender: TObject); override;
    procedure EditValueChanged(Sender: TObject);
    procedure EditExit(Sender: TObject);
    function GetControlClass(AIsVertical: Boolean): TdxBarItemControlClass; override;

    procedure KeyPress(var Key: Char); override;

    procedure DoEnter; override;
    procedure DoExit; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Follower: TBoldFollower read GetFollower;
  published
    property BoldHandle: TBoldElementHandle read GetBoldHandle write SetBoldHandle;
    property BoldProperties: TBoldVariantFollowerController read fBoldProperties write SetBoldProperties;
    property CanSelect;
//    property EditValue;
    property Height;
    property Properties;
    property RepositoryItem;
    property StyleEdit;
//    property TextHint;
  end;

  TcxBarBoldEditItemControl = class(TcxBarEditItemControl)
  private
  protected
//    procedure DoPostEditValue(Sender: TObject); override;
//    procedure DoValidate(Sender: TObject; var DisplayValue: TcxEditValue;
//      var ErrorText: TCaption; var Error: Boolean); override;
    procedure RestoreDisplayValue; override;
    procedure StoreDisplayValue; override;
//    procedure DoPaint(ARect: TRect; PaintType: TdxBarPaintType); override;
  public
  end;

{$IFDEF DevExScheduler}
  TcxBoldDateNavigator = class(TcxCustomDateNavigator, IBoldValidateableComponent)
  private
    fInternalChange: integer;
    fBoldStartHandleFollower: TBoldElementHandleFollower;
    fBoldEndHandleFollower: TBoldElementHandleFollower;
    fBoldStartProperties: TBoldVariantFollowerController;
    fBoldEndProperties: TBoldVariantFollowerController;
//    fValueOrDefinitionInvalid: boolean;
    function GetStartFollower: TBoldFollower;
    function GetEndFollower: TBoldFollower;
    procedure SetBoldStartProperties(const Value: TBoldVariantFollowerController);
    procedure SetBoldEndProperties(const Value: TBoldVariantFollowerController);
    function GetBoldEndHandle: TBoldElementHandle;
    function GetBoldStartHandle: TBoldElementHandle;
    procedure SetBoldEndHandle(const Value: TBoldElementHandle);
    procedure SetBoldStartHandle(const Value: TBoldElementHandle);
    procedure _AfterMakeUptoDate(Follower: TBoldFollower);

    procedure ValidateSelf;

    // IBoldValidateableComponent
    function ValidateComponent(ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean;
  protected
    function GetStartContextType: TBoldElementTypeInfo;
    function GetEndContextType: TBoldElementTypeInfo;
//    function CanSelectPeriod: Boolean; // overriden to return false, as we don't support range
    procedure DateNavigatorSelectionChanged; override;
//    procedure DoSelectionChangedEvent; override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property StartFollower: TBoldFollower read GetStartFollower;
    property EndFollower: TBoldFollower read GetEndFollower;
  published
    property BoldStartHandle: TBoldElementHandle read GetBoldStartHandle write SetBoldStartHandle;
    property BoldStartProperties: TBoldVariantFollowerController read fBoldStartProperties write SetBoldStartProperties;
    property BoldEndHandle: TBoldElementHandle read GetBoldEndHandle write SetBoldEndHandle;
    property BoldEndProperties: TBoldVariantFollowerController read fBoldEndProperties write SetBoldEndProperties;
    property Align;
    property Anchors;
    property BorderStyle;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FirstWeekOfYear;
    property Font;
    property HolidayColor;
    property LookAndFeel;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Scheduler;
    property SelectPeriod;
    property ShowDatesContainingEventsInBold;
    property ShowDatesContainingHolidaysInColor;
    property ShowWeekNumbers;
    property StartOfWeek;
    property Storage;
    property Styles;
    property TabOrder;
    property TabStop;
    property UnlimitedSelection;
    property Visible;

    property OnClick;
  {$IFDEF DELPHI5}
    property OnContextPopup;
  {$ENDIF}
    property OnCustomDrawBackground;
    property OnCustomDrawContent;
    property OnCustomDrawDayCaption;
    property OnCustomDrawDayNumber;
    property OnCustomDrawHeader;
    property OnPeriodChanged;
    property OnSelectionChanged;
    property OnShowDateHint;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
  end;
{$ENDIF}

  { TcxBoldLabel }

  TcxBoldLabel = class(TcxCustomLabel, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxLabelProperties;
    function GetDataBinding: TcxBoldTextEditDataBinding;
    function GetProperties: TcxLabelProperties;
    procedure SetDataBinding(Value: TcxBoldTextEditDataBinding);
    procedure SetProperties(Value: TcxLabelProperties);
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    procedure Initialize; override;
    procedure SetEditAutoSize(Value: Boolean); override;
    procedure Paint; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxLabelProperties read GetActiveProperties;
  published
    property Align;
    property Anchors;
    property AutoSize {default False};
    property Constraints;
    property DataBinding: TcxBoldTextEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxLabelProperties read GetProperties
      write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Transparent;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TcxBoldImage = class(TcxCustomImage, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxImageProperties;
    function GetDataBinding: TcxBoldBlobEditDataBinding;
    function GetProperties: TcxImageProperties;
    procedure SetDataBinding(Value: TcxBoldBlobEditDataBinding);
    procedure SetProperties(Value: TcxImageProperties);
//    function GetViewer: TBoldAbstractViewAdapter;
//    procedure SetViewer(Value: TBoldAbstractViewAdapter);
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    procedure Initialize; override;
    procedure Paint; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxImageProperties read GetActiveProperties;
//    property Viewer: TBoldAbstractViewAdapter read GetViewer write SetViewer;
  published
    property Align;
    property Anchors;
    property AutoSize;
    property Constraints;
    property DataBinding: TcxBoldBlobEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentColor;
    property PopupMenu;
    property Properties: TcxImageProperties read GetProperties write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetGraphicClass;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TcxBoldRichEdit = class(TcxCustomRichEdit, IBoldValidateableComponent, IBoldOCLComponent)
  private
    function GetActiveProperties: TcxRichEditProperties;
    function GetDataBinding: TcxBoldTextEditDataBinding;
    function GetProperties: TcxRichEditProperties;
    procedure SetDataBinding(Value: TcxBoldTextEditDataBinding);
    procedure SetProperties(Value: TcxRichEditProperties);
  protected
    procedure EditingChanged; override;
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
    function RealReadOnly: Boolean; override;
    procedure Paint; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxRichEditProperties read GetActiveProperties;
  published
    property Align;
    property Anchors;
    property Constraints;
    property DataBinding: TcxBoldTextEditDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxRichEditProperties read GetProperties
      write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDock;
    property OnStartDrag;
  end;
  
  TcxBoldListBox = class(TcxListBox, IBoldValidateableComponent)
  private
    fInternalUpdate: boolean;
    fListHandleFollower: TBoldListHandleFollower;
    fBoldListProperties: TBoldListAsFollowerListController;
    fBoldRowProperties: TBoldVariantFollowerController;
    function GetBoldListHandle: TBoldAbstractListHandle;
    procedure SetBoldListHandle(const Value: TBoldAbstractListHandle);
    procedure SetBoldListProperties(
      const Value: TBoldListAsFollowerListController);
    procedure SetRowProperties(
      const Value: TBoldVariantFollowerController);
    function GetBoldHandleIndexLock: Boolean;
    procedure SetBoldHandleIndexLock(const Value: Boolean);
    function GetFollower: TBoldFollower;
    function GetMutableList: TBoldList;
    procedure SyncSelection;
    // IBoldValidateableComponent
    function ValidateComponent(ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean;
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure DblClick; override;
    procedure Loaded; override;
{$IFNDEF AttracsBold}
    procedure _InsertItem(Follower: TBoldFollower);
{$ELSE}
    procedure _InsertItem(Index: Integer; Follower: TBoldFollower);
{$ENDIF}
    procedure _DeleteItem(Index: Integer; OwningFollower: TBoldFollower);
    procedure _RowAfterMakeUptoDate(Follower: TBoldFollower);
    procedure _BeforeMakeUptoDate(Follower: TBoldFollower);
    procedure _AfterMakeUptoDate(Follower: TBoldFollower);

    function DrawItem(ACanvas: TcxCanvas; AIndex: Integer; const ARect: TRect;
      AState: TOwnerDrawState): Boolean; override;
    procedure DefaultSetFontAndColor(Index: integer); virtual;

    procedure DoStartDrag(var DragObject: TDragObject); override;
    procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;

    function GetListFollower: TBoldFollower;
    function GetContextForBoldRowProperties: TBoldElementTypeInfo;
    property Follower: TBoldFollower read GetFollower;
    property MutableList: TBoldList read GetMutableList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DefaultDrawItem(Index: integer; aRect: TRect); virtual;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
  published
//    property DataBinding: TcxBoldDataBinding read GetDataBinding write SetDataBinding implements IBoldValidateableComponent, IBoldOCLComponent;
    property BoldListHandle: TBoldAbstractListHandle read GetBoldListHandle write SetBoldListHandle;
    property BoldListProperties: TBoldListAsFollowerListController read fBoldListProperties write SetBoldListProperties;
    property BoldRowProperties: TBoldVariantFollowerController read fBoldRowProperties write SetRowProperties;
    property BoldHandleIndexLock: Boolean read GetBoldHandleIndexLock write SetBoldHandleIndexLock default true;
  end;


  TcxBoldCustomCheckListBox = class(TcxCustomCheckListBox, IBoldValidateableComponent)
  private
    fInternalUpdate: boolean;
    fListHandleFollower: TBoldListHandleFollower;
    fBoldListProperties: TBoldAbstractListAsFollowerListController;
    fBoldRowProperties: TBoldVariantFollowerController;

    fBoldRowCheckBoxProperties: TBoldCheckBoxStateFollowerController;
    fControllerList: TBoldControllerList;

    function GetBoldListHandle: TBoldAbstractListHandle;
    procedure SetBoldListHandle(const Value: TBoldAbstractListHandle);
    procedure SetBoldListProperties(
      const Value: TBoldAbstractListAsFollowerListController);
    procedure SetRowProperties(
      const Value: TBoldVariantFollowerController);
    function GetBoldHandleIndexLock: Boolean;
    procedure SetBoldHandleIndexLock(const Value: Boolean);
    function GetFollower: TBoldFollower;
    procedure SetBoldRowCheckBoxProperties(const Value: TBoldCheckBoxStateFollowerController);
    // IBoldValidateableComponent
    function ValidateComponent(ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean; virtual; abstract;
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure SyncSelection;
    function GetInnerCheckListBoxClass: TcxCustomInnerCheckListBoxClass; override;

    procedure Loaded; override;

    function GetContextType: TBoldElementTypeInfo;
    procedure _DisplayCheckBox(Follower: TBoldFollower);
    procedure _DisplayString(Follower: TBoldFollower);
{$IFNDEF AttracsBold}
    procedure _ListInsertItem(Follower: TBoldFollower);
{$ELSE}
    procedure _ListInsertItem(Index: integer; Follower: TBoldFollower);
{$ENDIF}
    procedure _ListDeleteItem(Index: integer; Follower: TBoldFollower);
    procedure _ListBeforeMakeUpToDate(Follower: TBoldFollower);
    procedure _ListAfterMakeUpToDate(Follower: TBoldFollower);
    property BoldRowCheckBoxProperties: TBoldCheckBoxStateFollowerController read fBoldRowCheckBoxProperties write SetBoldRowCheckBoxProperties;
    property Follower: TBoldFollower read GetFollower;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
//    procedure DefaultDrawItem(Index: integer; aRect: TRect); virtual;
//    procedure DragDrop(Source: TObject; X, Y: Integer); override;
  published
    property BoldListHandle: TBoldAbstractListHandle read GetBoldListHandle write SetBoldListHandle;
    property BoldListProperties: TBoldAbstractListAsFollowerListController read fBoldListProperties write SetBoldListProperties;
    property BoldRowProperties: TBoldVariantFollowerController read fBoldRowProperties write SetRowProperties;
    property BoldHandleIndexLock: Boolean read GetBoldHandleIndexLock write SetBoldHandleIndexLock default true;

    property Align;
    property AllowDblClickToggle;
    property AllowGrayed;
    property Anchors;
    property AutoComplete;
    property AutoCompleteDelay;
    property BiDiMode;
    property Columns;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property EditValueFormat;
    property Enabled;
    property Glyph;
    property GlyphCount;
    property Images;
    property ImageLayout;
    property ImeMode;
    property ImeName;
    property IntegralHeight;
//    property Items;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ScrollWidth;
    property ShowChecks;
    property ShowHint;
    property Sorted;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property TabWidth;
    property Visible;
    property OnCheckStatesToEditValue;
    property OnClick;
    property OnClickCheck;
    property OnCompare;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnEditValueToCheckStates;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TcxBoldCheckListBox = class(TcxBoldCustomCheckListBox{, IBoldValidateableComponent, IBoldOCLComponent})
  private
    // IBoldValidateableComponent
    function ValidateComponent(ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean; override;
  published
    property BoldRowCheckBoxProperties;
  end;


const
  beSelectionHandleChanged = 400;

type
  TcxBoldSelectionCheckListBox = class(TcxBoldCustomCheckListBox{, IBoldValidateableComponent, IBoldOCLComponent})
  private
    fCheckBoxRenderer: TBoldAsCheckBoxStateRenderer;
    fPublisher: TBoldPublisher;
    fBoldSelectionHandle: TBoldAbstractListHandle;
{$IFNDEF AttracsBold}
    function GetAsCheckBoxState(Element: TBoldElement; Representation: TBoldRepresentation; Expression: TBoldExpression): TCheckBoxState;
    procedure SetAsCheckBoxState(Element: TBoldElement; newValue: TCheckBoxState; Representation: TBoldRepresentation; Expression: TBoldExpression);
    procedure OnSubscribe(Element: TBoldElement; Representation: TBoldRepresentation; Expression: TBoldExpression; Subscriber: TBoldSubscriber);
{$ELSE}
    function GetAsCheckBoxState(aFollower: TBoldFollower): TCheckBoxState;
    procedure SetAsCheckBoxState(aFollower: TBoldFollower; newValue: TCheckBoxState);
    procedure OnSubscribe(aFollower: TBoldFollower; Subscriber: TBoldSubscriber);
{$ENDIF}
    procedure SetSelectionHandle(const Value: TBoldAbstractListHandle);
    // IBoldValidateableComponent
    function ValidateComponent(ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean; override;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property BoldSelectionHandle: TBoldAbstractListHandle read fBoldSelectionHandle write SetSelectionHandle;
  end;

  TcxBoldListView = class(TcxCustomListView{, IBoldValidateableComponent, IBoldOCLComponent})
  private
    fListHandleFollower: TBoldListHandleFollower;
    fBoldProperties: TBoldAbstractListAsFollowerListController;
    fBoldRowProperties: TBoldVariantFollowerController;
    function GetContextType: TBoldElementTypeInfo;

    function GetBoldHandle: TBoldAbstractListHandle;
    procedure SetBoldHandle(value: TBoldAbstractListHandle);
    function GetFollower: TBoldFollower;
    procedure SetBoldProperties(Value: TBoldAbstractListAsFollowerListController);
    procedure SetRowProperties(const Value: TBoldVariantFollowerController);
    function GetBoldHandleIndexLock: Boolean;
    procedure SetBoldHandleIndexLock(Value: Boolean);
    function GetBoldList: TBoldList;
    function GetCurrentBoldElement: TBoldElement;
    function GetCurrentBoldObject: TBoldObject;
  protected
    procedure _BeforeMakeUptoDate(Follower: TBoldFollower);
    procedure _AfterMakeUptoDate(Follower: TBoldFollower);
{$IFNDEF AttracsBold}
    procedure _InsertItem(Follower: TBoldFollower);
{$ELSE}
    procedure _InsertItem(Index: Integer; Follower: TBoldFollower);
{$ENDIF}
    procedure _DeleteItem(index: Integer; OwningFollower: TBoldFollower);
    procedure _RowAfterMakeUptoDate(Follower: TBoldFollower);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Follower: TBoldFollower read GetFollower;
    property ListViewCanvas;
    property BoldList: TBoldList read GetBoldList;
  published
    property BoldHandle: TBoldAbstractListHandle read GetBoldHandle write SetBoldHandle;
    property BoldHandleIndexLock: Boolean read GetBoldHandleIndexLock write SetBoldHandleIndexLock default true;
    property BoldProperties: TBoldAbstractListAsFollowerListController read fBoldProperties write SetBoldProperties;
    property BoldRowProperties: TBoldVariantFollowerController read fBoldRowProperties write SetRowProperties;

    property CurrentBoldObject: TBoldObject read GetCurrentBoldObject;
    property CurrentBoldElement: TBoldElement read GetCurrentBoldElement;

    property Align;
    property AllocBy default 0;
    property Anchors;
    property BiDiMode;
    property Checkboxes;
    property ColumnClick default True;
    property Columns;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property HideSelection default True;
    property HotTrack default False;
    property HoverTime default -1;
    property IconOptions;
  {$IFDEF DELPHI6}
    property ItemIndex;
  {$ENDIF}
//    property Items;
    property LargeImages;
    property MultiSelect default False;
    property OwnerData default False;
    property OwnerDraw default False;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly default False;
    property RowSelect default False;
    property ShowColumnHeaders default True;
    property ShowHint;
    property ShowWorkAreas default False;
    property SmallImages;
    property SortType default stNone;
    property StateImages;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property ViewStyle default vsIcon;
    property Visible;
    property OnAdvancedCustomDraw;
    property OnAdvancedCustomDrawItem;
    property OnAdvancedCustomDrawSubItem;
    property OnCancelEdit;
    property OnChange;
    property OnChanging;
    property OnClick;
    property OnColumnClick;
    property OnColumnDragged;
    property OnColumnRightClick;
    property OnCompare;
    property OnContextPopup;
  {$IFDEF DELPHI6}
    property OnCreateItemClass;
  {$ENDIF}
    property OnCustomDraw;
    property OnCustomDrawItem;
    property OnCustomDrawSubItem;
    property OnData;
    property OnDataFind;
    property OnDataHint;
    property OnDataStateChange;
    property OnDblClick;
    property OnDeletion;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnEdited;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImageIndex;
    property OnGetSubItemImage;
    property OnInfoTip;
    property OnInsert;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnSelectItem;
    property OnStartDock;
    property OnStartDrag;
  end;

{$IFDEF BoldDevExLog}
  TcxBoldEditorsLogProc = procedure(aMessage: string; aCategory: string = '') of object;
{$ENDIF}

{$IFDEF BoldDevExLog}
var
  cxBoldEditorsLogProc: TcxBoldEditorsLogProc;
{$ENDIF}

procedure InternalComboSetValue(
  aBoldHandle: TBoldElementHandle;
  aFollower: TBoldFollower;
  aSelectedElement: TBoldElement;
  aBoldSelectChangeAction: TBoldComboSelectChangeAction;
  aBoldSetValueExpression: TBoldExpression;
  aListHandle: TBoldAbstractListHandle);

procedure _ValidateEdit(aEdit: TcxCustomEdit);

implementation

uses
  BoldAttributes,
  BoldBase,
  SysUtils,
  Variants,
  Graphics,
  BoldEnvironment,
  cxFilterControlUtils,
  cxBoldEditConsts,
  BoldReferenceHandle,
  BoldValueInterfaces,
  cxDateUtils,
  {$IFDEF DevExScheduler}
  cxSchedulerDateNavigator,
  {$ENDIF}
  BoldLogHandler,
  BoldCoreConsts,
  BoldDomainElement,
  BoldOCL,
  BoldGuard,
  BoldAFP,
  BoldGUI,
  Forms;

type
  TcxCustomEditAccess = class(TcxCustomEdit);
  TBoldFollowerControllerAccess = class(TBoldFollowerController);

{$IFDEF BoldDevExLog}
procedure _Log(aMessage: string; aCategory: string = '');
begin
  if Assigned(cxBoldEditorsLogProc) then
    cxBoldEditorsLogProc(aMessage, aCategory);
end;
{$ENDIF}

procedure _ValidateEdit(aEdit: TcxCustomEdit);
var
  lBoldValidateableComponent: IBoldValidateableComponent;

  procedure InternalValidate;
  var
    lBoldComponentValidator: TBoldComponentValidator;
  begin
    lBoldComponentValidator := TBoldComponentValidator.Create;
    try
      lBoldValidateableComponent.ValidateComponent(lBoldComponentValidator, aEdit.Name);
    finally
      lBoldComponentValidator.free;
    end;
  end;

var
  lcxBoldEditDataBinding: TcxBoldEditDataBinding;
  lValue: Variant;
  lFollower: TBoldFollower;
  s: string;
  lContext: TBoldElementTypeInfo;
  lEvaluator: TBoldOCL;
  lBoldMemberRTInfo: TBoldMemberRTInfo;
  lExpression: string;
begin
  if Supports(aEdit, IBoldValidateableComponent, lBoldValidateableComponent) then
  begin
    InternalValidate;

    lcxBoldEditDataBinding := TcxCustomEditAccess(aEdit).DataBinding as TcxBoldEditDataBinding;
    lContext := lcxBoldEditDataBinding.GetContextType;
    if not Assigned(lcxBoldEditDataBinding.BoldHandle) then
      lValue := '< no handle >'
    else
    if (lContext = nil) then
      lValue := '< no context >'
    else
    if Assigned(lcxBoldEditDataBinding.Follower) then
    begin
      lFollower := lcxBoldEditDataBinding.Follower;
      lEvaluator := lContext.Evaluator as TBoldOCL;
      lExpression := TBoldFollowerControllerAccess(lFollower.Controller).Expression;

      lBoldMemberRTInfo := lEvaluator.RTInfo(lExpression, lContext, false, {$IFDEF AttracsBold}lFollower.Controller.VariableList{$ENDIF});
      if Assigned(lBoldMemberRTInfo) then
        lValue := lBoldMemberRTInfo.AsString
      else
      begin
        lContext := lEvaluator.ExpressionType(lExpression, lContext, false, lFollower.Controller.VariableList);
        if Assigned(lContext) then
          lValue := lContext.AsString;
      end;
    end;
    if VarIsNull(lValue) or (lValue = '') then
      lValue := TBoldFollowerControllerAccess(lcxBoldEditDataBinding.BoldFollowerController).Expression;

//    TcxCustomEditAccess(aEdit).SetInternalEditValue(lValue);
    TcxCustomEditAccess(aEdit).SetInternalDisplayValue(lValue);

    if aEdit.name <> '' then
      s := '_ValidateEdit ' + aEdit.name + ':' + lValue
    else
      s := '_ValidateEdit ' + aEdit.ClassName + ':' + lValue;

    OutPutDebugString(PChar(S));
  end
  else
  if Supports(aEdit.ActiveProperties, IBoldValidateableComponent, lBoldValidateableComponent) then
    InternalValidate;
end;

procedure InternalComboSetValue(
  aBoldHandle: TBoldElementHandle;
  aFollower: TBoldFollower;
  aSelectedElement: TBoldElement;
  aBoldSelectChangeAction: TBoldComboSelectChangeAction;
  aBoldSetValueExpression: TBoldExpression;
  aListHandle: TBoldAbstractListHandle);

var
//  LocalSelectedElement: TBoldElement;
  ElementToAssignTo: TBoldElement;
  lValue: Variant;
  lOldValue: IBoldValue;
  lHasOldValue: boolean;
{$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
//  lItemIndex: Integer;
begin
  case aBoldSelectChangeAction of
    bdscSetText:
      begin
//        aDone := false;
      end;
    bdcsSetValue:
      begin
        if not (Assigned(aFollower.Element)) then
          exit;
        if trim(aBoldSetValueExpression) <> '' then
          ElementToAssignTo := aFollower.Element.EvaluateExpressionAsDirectElement(aBoldSetValueExpression, TBoldFollowerControllerAccess(aFollower.Controller).VariableList)
        else
        begin
        {$IFNDEF AttracsBold}
          lGuard := TBoldGuard.Create(lIE);
          lIE := TBoldIndirectElement.Create;
          aFollower.Element.EvaluateExpression(TBoldFollowerControllerAccess(aFollower.Controller).Expression, lIE, false, TBoldFollowerControllerAccess(aFollower.Controller).VariableList);
          ElementToAssignTo := lIE.Value;
        {$ELSE}
          ElementToAssignTo := aFollower.actualElement;
        {$ENDIF}
        end;

        if assigned(ElementToAssignTo) and ElementToAssignTo.Mutable and
          // must check the element (and not the follower) since we might have a BoldSetValueExpression...
          (not (elementToAssignTo is TBoldMember) or
           TBoldMember(ElementToAssignTo).CanModify) then
          try
            if elementToAssignTo is TBoldObjectReference then
            begin
              if aFollower.Controller.CleanOnEqual and TBoldObjectReference(elementToAssignTo).BoldMemberRTInfo.CanHaveOldValue then
              {and TBoldObjectReference(elementToAssignTo).HasOldValues} // TODO: fix HasOldValues, currently it doesn't get updated - DM
              begin
                lOldValue := TBoldObjectReference(elementToAssignTo).OldValue;
                lHasOldValue := Assigned(lOldValue);
              end
              else
                lHasOldValue := false;


              if not ElementToAssignTo.IsEqual(aSelectedElement) then
              begin
                {$IFDEF BoldDevExLog}
                {$IFDEF LOGCHANGES}
                _Log(Format('%s "%s"->"%s"', [ElementToAssignTo.DisplayName, ElementToAssignTo.asString, aSelectedElement.asString]), 'Follower Changes');
                {$ENDIF}
                {$ENDIF}
                ElementToAssignTo.Assign(aSelectedElement);
              end;
              if lHasOldValue and TBoldObjectReference(ElementToAssignTo).IsEqualToValue(lOldValue) then
              begin
                TBoldObjectReference(ElementToAssignTo).BoldPersistenceState := bvpsCurrent;
              end;
{
              if aFollower.Controller.CleanOnEqual then
              begin
                lBoldObjectIdRef := TBoldMember(ElementToAssignTo).OldValue as IBoldObjectIdRef;
//                lBoldNullableValue := lBoldObjectIdRef as IBoldNullableValue;
                if (not Assigned(LocalSelectedElement) and (not Assigned(lBoldObjectIdRef.Id)))
                   or ((LocalSelectedElement is TBoldObject) and (LocalSelectedElement as TBoldObject).BoldObjectLocator.BoldobjectId.IsEqual[lBoldObjectIdRef.Id])
                   then
                begin
                  (elementToAssignTo as TBoldObjectReference).Discard;
                  (elementToAssignTo as TBoldObjectReference).EnsureContentsCurrent;
                  TBoldObjectReference(ElementToAssignTo).BoldPersistenceState := bvpsCurrent;
                end;
              end;
}
            end
            else
//            if elementToAssignTo is TBoldAttribute then
            begin
              lValue := Null;
              if Assigned(aSelectedElement) then
                lValue := aSelectedElement.GetAsVariant;
              ElementToAssignTo.SetAsVariant(lValue);
//              (aFollower.Controller as TBoldVariantFollowerController).MayHaveChanged(lValue, aFollower);
            end;
          except
            on E: Exception do
            begin
//              if not HandleApplyException(E, ElementToAssignTo, Discard) then
                raise;
//              if Discard then
//                Follower.DiscardChange;
            end;
          end;
      end;
    bdcsNone:
      begin

      end;
    bdcsSetReference:
      begin
        if aBoldHandle is TBoldReferenceHandle then
          TBoldReferenceHandle(aBoldHandle).Value := aSelectedElement;
{        aFollower.DiscardChange;
        if assigned(aBoldHandle) and (aBoldHandle is TBoldReferenceHandle) then
          (aBoldHandle as TBoldReferenceHandle).Value := LocalSelectedElement;
}
      end;
    bdcsSetListIndex:
      begin
        aFollower.DiscardChange;
        if assigned(aListHandle) then
        begin
          aListHandle.CurrentIndex := aListHandle.List.IndexOf(aSelectedElement);
        end;
      end;
  end;

end;

(*
procedure InternalSetToNull(aFollower: TBoldFollower);
var
{$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
  lElement: TBoldElement;
begin
  {$IFNDEF AttracsBold}
    if Assigned(aFollower.Element) then
    begin
      lGuard := TBoldGuard.Create(lIE);
      lIE := TBoldIndirectElement.Create;
      aFollower.Element.EvaluateExpression(aFollower.Controller.Expression, lIE);
      lElement := lIE.Value;
    end
    else
      lElement := nil;
  {$ELSE}
    lElement := aFollower.ActualElement;
  {$ENDIF}
    if lElement is TBoldAttribute then
      TBoldAttribute(lElement).SetToNull; // check if this conflicts with Observer
//      BoldProperties.MayHaveChanged(0, aFollower) // TODO brk BUG !!! figure out how to set to nil
end;
*)

{ TcxBoldTextEditProperties }

procedure TcxCustomBoldTextEditProperties._DeleteItem(Index: Integer;
  OwningFollower: TBoldFollower);
begin
  LookupItems.Delete(index);
end;

{$IFNDEF AttracsBold}
procedure TcxCustomBoldTextEditProperties._InsertItem(Follower: TBoldFollower);
{$ELSE}
procedure TcxCustomBoldTextEditProperties._InsertItem(Index: Integer; Follower: TBoldFollower);
{$ENDIF}
begin
  Assert(Assigned(Follower));
  Follower.EnsureDisplayable;
{$IFNDEF AttracsBold}
  LookupItems.Insert(Follower.Index, VarToStr(TBoldVariantFollowerController(Follower.Controller).GetCurrentAsVariant(Follower)));
{$ELSE}
  LookupItems.Insert(Index, VarToStr(TBoldVariantFollowerController(Follower.Controller).GetCurrentAsVariant(Follower)));
{$ENDIF}
end;

procedure TcxCustomBoldTextEditProperties._RowAfterMakeUptoDate(
  Follower: TBoldFollower);
var
  index: Integer;
begin
{  OutputDebugString('TcxCustomBoldTextEditProperties._RowAfterMakeUptoDate');
  if (Owner is TcxCustomEdit) and TcxCustomEdit(Owner).IsDesigning then
  begin
    ValidateEdit(TcxCustomEdit(Owner));
  end;
}
  index := Follower.index;
  if (index > -1) and (index < LookupItems.Count) then
    LookupItems[index] := VarToStr(TBoldVariantFollowerController(Follower.Controller).GetCurrentAsVariant(Follower));
//  LookupDataChanged(self);
  // forces a redisplay of the edit-area, the windows component might go blank if the active row is removed and then reinserted
//  fBoldHandleFollower.Follower.MarkValueOutOfDate; // do we really need this here ? Danny
end;

function TcxCustomBoldTextEditProperties.GetBoldListHandle: TBoldAbstractListHandle;
begin
  Result := fListHandleFollower.BoldHandle;
end;

function TcxCustomBoldTextEditProperties.GetContextForBoldRowProperties: TBoldElementTypeInfo;
begin
  if assigned(BoldLookupListHandle) then
    result := BoldLookupListHandle.StaticBoldType
  else
    result := nil;
end;

function TcxCustomBoldTextEditProperties.GetListFollower: TBoldFollower;
begin
  Result := fListHandleFollower.Follower;
end;

procedure TcxCustomBoldTextEditProperties.SetBoldListHandle(
  const Value: TBoldAbstractListHandle);
begin
  fListHandleFollower.BoldHandle := value;
end;

procedure TcxCustomBoldTextEditProperties.SetBoldListProperties(
  const Value: TBoldAbstractListAsFollowerListController);
begin
  fBoldListProperties.Assign(Value);
end;
{
procedure TcxCustomBoldTextEditProperties.SetBoldSelectChangeAction(
  const Value: TBoldComboSelectChangeAction);
begin
  fBoldSelectChangeAction := Value;
end;
}
procedure TcxCustomBoldTextEditProperties.SetRowProperties(
  const Value: TBoldVariantFollowerController);
begin
  fBoldRowProperties.Assign(Value);
end;

constructor TcxCustomBoldTextEditProperties.Create(AOwner: TPersistent);
var
  lMatchObject: TComponent;
begin
  inherited;
  if aOwner is TComponent then
    lMatchObject := aOwner as TComponent
  else
    lMatchObject := nil;
  fBoldRowProperties := TBoldVariantFollowerController.Create(lMatchObject);
  fBoldRowProperties.AfterMakeUptoDate := _RowAfterMakeUptoDate;
  fBoldRowProperties.OnGetContextType := GetContextForBoldRowProperties;
  fBoldListProperties := TBoldAbstractListAsFollowerListController.Create(lMatchObject, fBoldRowProperties);
  with fBoldListProperties do
  begin
    OnAfterInsertItem := _InsertItem;
    OnAfterDeleteItem := _DeleteItem;
    BeforeMakeUptoDate := _BeforeMakeUptoDate;
    AfterMakeUptoDate := _AfterMakeUptoDate;
  end;
  fListHandleFollower := TBoldListHandleFollower.Create(Owner, fBoldListProperties);
  BoldSelectChangeAction := bdcsSetValue;
end;

destructor TcxCustomBoldTextEditProperties.Destroy;
begin
  FreeAndNil(fListHandleFollower);
  FreeAndNil(fBoldListProperties);
  FreeAndNil(fBoldRowProperties);
  inherited;
end;

procedure TcxCustomBoldTextEditProperties._AfterMakeUptoDate(
  Follower: TBoldFollower);
begin
  fBoldRowProperties.AfterMakeUptoDate := _RowAfterMakeUptoDate;
  LookupItems.EndUpdate;
end;

procedure TcxCustomBoldTextEditProperties._BeforeMakeUptoDate(
  Follower: TBoldFollower);
begin
  fBoldRowProperties.AfterMakeUptoDate := nil;
  LookupItems.BeginUpdate;
end;


{ TcxBoldEditDataBinding }

constructor TcxBoldEditDataBinding.Create(AEdit: TcxCustomEdit);
begin
  inherited Create(AEdit);
//  DefaultValuesProvider.fcxBoldEditDataBinding := self;
  fBoldFollowerController:= TBoldVariantFollowerController.Create(AEdit);
//  fBoldProperties := TBoldVariantFollowerController.Create(AEdit);
  BoldFollowerController.AfterMakeUptoDate := _AfterMakeUptoDate;
  BoldFollowerController.OnGetContextType := GetContextType;
  fBoldHandleFollower := TBoldElementHandleFollower.Create(AEdit, BoldFollowerController);

  DefaultValuesProvider.BoldProperties := BoldFollowerController;
  DefaultValuesProvider.BoldHandleFollower := fBoldHandleFollower;
{  if AEdit.InnerControl <> nil then
    FDataLink.Control := AEdit.InnerControl
  else
    FDataLink.Control := AEdit;
}
end;

destructor TcxBoldEditDataBinding.Destroy;
begin
  case BoldFollowerController.ApplyPolicy of
    bapChange, bapExit: try
      Follower.Apply;
    except
      Follower.DiscardChange;
    end;
    bapDemand: Follower.DiscardChange;
  end;
  FreeAndNil(fBoldHandleFollower);
  FreeAndNil(fBoldFollowerController);
  Edit.ViewInfo.OnPaint := nil;
  inherited Destroy;
end;

function TcxBoldEditDataBinding.GetBoldHandle: TBoldElementHandle;
begin
  Result := fBoldHandleFollower.BoldHandle
end;

function TcxBoldEditDataBinding.GetFollower: TBoldFollower;
begin
  Result := fBoldHandleFollower.Follower
end;

procedure TcxBoldEditDataBinding.SetBoldHandle(
  const Value: TBoldElementHandle);
begin
//  if not (Edit.IsLoading) then
  begin
    fBoldHandleFollower.BoldHandle := value;
    DefaultValuesProvider.fBoldHandleFollower := fBoldHandleFollower;
    if (Edit.IsDesigning) and not (Edit.IsLoading) then
    begin
      _ValidateEdit(Edit);
    end;
//    DefaultValuesProvider.BoldHandle := value;
//    DefaultValuesProvider.BoldProperties := BoldProperties;
  end;
end;

procedure TcxBoldEditDataBinding.Assign(Source: TPersistent);
begin
  if Source is TcxBoldEditDataBinding then
  begin
    // TODO: what about HandleFollower ?
    BoldHandle := TcxBoldEditDataBinding(Source).BoldHandle;
    fBoldFollowerController := TcxBoldEditDataBinding(Source).BoldFollowerController;
    DataChanged; // ?
  end;
  inherited Assign(Source);
end;

function TcxBoldEditDataBinding.ImmediatePost: boolean;
begin
  result := BoldFollowerController.ApplyPolicy = bapChange;
end;

function TcxBoldEditDataBinding.CanCheckEditorValue: Boolean;
begin
  result := inherited CanCheckEditorValue;
end;

function TcxBoldEditDataBinding.CanPostEditorValue: Boolean;
begin
  Result := IsDataAvailable and (fInternalChange = 0) and not FEdit.ActiveProperties.ReadOnly and Modified;
//  Result := Editing and Edit.IsFocused; //or (BoldProperties.ApplyPolicy = bapExit);
//  result := false; // inherited CanPostEditorValue;
//  Result := Editing and DataLink.FModified;
end;

procedure TcxBoldEditDataBinding.DataChanged;
begin
  inherited;
end;

procedure TcxBoldEditDataBinding.DataSetChange;
begin
  inherited;
end;

procedure TcxBoldEditDataBinding.DefaultValuesChanged;
begin
  inherited DefaultValuesChanged;
end;

procedure TcxBoldEditDataBinding.EditingChanged;
begin
  TcxCustomEditAccess(Edit).EditingChanged;
end;

function TcxBoldEditDataBinding.ExecuteAction(
  Action: TBasicAction): Boolean;
begin
  result := inherited ExecuteAction(Action);
end;

function TcxBoldEditDataBinding.GetDefaultValuesProvider: TcxCustomBoldEditDefaultValuesProvider;
begin
  Result := TcxCustomBoldEditDefaultValuesProvider(IDefaultValuesProvider.GetInstance);
end;

class function TcxBoldEditDataBinding.GetDefaultValuesProviderClass: TcxCustomEditDefaultValuesProviderClass;
begin
  result := TcxCustomBoldEditDefaultValuesProvider;
end;

type
  TcxCustomTextEditAccess = class(TcxTextEdit);

function TcxBoldEditDataBinding.GetModified: Boolean;
var
  lcxBoldEditProperties: IcxBoldEditProperties;
  lValue: Variant;
  lEditValue: variant;
//  lElement: TBoldElement;
begin
  if not IsDataAvailable or FEdit.ActiveProperties.ReadOnly then
  begin
    result := false;
  end
  else
  begin
    if Supports(Edit.ActiveProperties, IcxBoldEditProperties, lcxBoldEditProperties) then
    begin
      if Edit is TcxCustomComboBox then
        lEditValue := TcxCustomComboBox(Edit).ILookupData.CurrentKey
      else
        lEditValue := Edit.EditValue;
      lValue := lcxBoldEditProperties.BoldElementToEditValue(Follower, Follower.Element, Edit);
//      result := (Follower.AssertedController.EffectiveRenderer as TBoldAsVariantRenderer).IsChanged(Follower, lValue);
      result := not cxEditVarEquals(lEditValue, lValue);
    end
    else
    begin
      result := (TBoldFollowerControllerAccess(Follower.AssertedController).EffectiveRenderer as TBoldAsVariantRenderer).IsChanged(Follower, Edit.EditValue);
    end;
  end;
end;

function TcxBoldEditDataBinding.GetStoredValue: TcxEditValue;
var
  lElement: TBoldElement;
{$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
begin
  Assert(assigned(Follower));
  result := ((Follower.Controller) as TBoldVariantFollowerController).GetCurrentAsVariant(Follower);
{  
  lElement := Follower.ActualElement;
  if Assigned(lElement) then
    Assert(result = lElement.GetAsVariant)
  else
    Assert(VarIsEmpty(result) or (result = Null));
  exit;
}
{$IFNDEF AttracsBold}
  if Assigned(Follower.Element) then
  begin
    lGuard := TBoldGuard.Create(lIE);
    lIE := TBoldIndirectElement.Create;
    Follower.Element.EvaluateExpression(TBoldFollowerControllerAccess(Follower.Controller).Expression, lIE, false, TBoldFollowerControllerAccess(Follower.Controller).VariableList);
    lElement := lIE.Value;
  end
  else
    lElement := nil;
{$ELSE}
  lElement := Follower.ActualElement;
{$ENDIF}
  if Assigned(lElement) then
    result := lElement.GetAsVariant
  else
    result := Null;
end;

function TcxBoldEditDataBinding.IsLookupControl: Boolean;
begin
  result := false; // inherited IsLookupControl;
end;

function TcxBoldEditDataBinding.IsRefreshDisabled: Boolean;
begin
  result := false; // inherited IsRefreshDisabled;
end;

procedure TcxBoldEditDataBinding.Reset;
begin
  case BoldFollowerController.ApplyPolicy of
    bapExit, bapDemand: Follower.DiscardChange;
  end;
  TBoldQueueable.DisplayAll;
  inherited;
  Edit.SelectAll;
end;

procedure TcxBoldEditDataBinding.SetModified;
begin
  if (fInternalChange = 0) and Editing then
  begin
    inherited;
  end;
end;

procedure TcxBoldEditDataBinding.SetStoredValue(const Value: TcxEditValue);
var
  lIcxBoldEditProperties: IcxBoldEditProperties;
  lDone: Boolean;
begin
  lDone := false;
  if Supports(Edit.ActiveProperties, IcxBoldEditProperties, lIcxBoldEditProperties) then
  begin
    lIcxBoldEditProperties.SetStoredValue(Value, BoldHandle, Edit, Follower, lDone);
  end;
  if not lDone then
  begin
    InternalSetValue(Value);
  end;
  TBoldQueueable.DisplayAll;
//  Follower.Apply;
  inherited;
end;

function TcxBoldEditDataBinding.UpdateAction(
  Action: TBasicAction): Boolean;
begin
  result := inherited UpdateAction(Action);
end;

procedure TcxBoldEditDataBinding.UpdateData;
begin
  inherited;
end;

procedure TcxBoldEditDataBinding.UpdateDisplayValue;
begin
  Edit.LockClick(True);
  inc(fInternalChange);
  try
    inherited UpdateDisplayValue;
  finally
    dec(fInternalChange);
    Edit.LockClick(False);
  end;
  if Edit.IsDesigning and not Edit.IsLoading then
  begin
    _ValidateEdit(Edit);
  end;
end;

type
  TcxCustomTextEditPropertiesAccess = class(TcxCustomTextEditProperties)
  end;

procedure TcxBoldEditDataBinding._AfterMakeUptoDate(
  Follower: TBoldFollower);
var
  lValue: Variant;
//  lcxBoldComboBoxProperties: TcxBoldComboBoxProperties;
  lElement: TBoldElement;
  lIcxBoldEditProperties: IcxBoldEditProperties;
{$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
begin
  if fInternalChange > 0 then
  begin
    {$IFDEF BoldDevExLog}
    Assert(assigned(self));
    _Log('TcxBoldEditDataBinding._AfterMakeUptoDate: fInternalChange ' + Edit.Name, className);
    {$ENDIF}
    {$IFDEF Constraints}
    SubscribeToConstraints(Follower.ActualElement);
    {$ENDIF}
    exit;
  end;
  Edit.LockClick(True);
  inc(fInternalChange);
  try
    // this is not really the perfect place for setting ImmediatePost
    Edit.ActiveProperties.ImmediatePost := ImmediatePost;
    lValue := null;
    if Edit.IsDesigning then
    begin
(*
      if not Assigned(BoldHandle) then
        lValue := '< not connected >'
      else
  {$IFDEF AttracsBold}
      if IsDataAvailable and Assigned(Follower.ActualElement) then
        lValue := Follower.ActualElement.DisplayName
      else
  {$ENDIF}
      lValue := TBoldFollowerControllerAccess(BoldFollowerController).Expression;
*)
      _ValidateEdit(Edit);
    end
    else
    begin
  {    if (Edit.ActiveProperties is TcxBoldComboBoxProperties) then
      begin
        lcxBoldComboBoxProperties := (Edit.ActiveProperties as TcxBoldComboBoxProperties);
        if (Edit is TcxCustomComboBox) and Assigned(TcxCustomComboBox(Edit).ILookupData.ActiveControl) then
        begin
          TcxCustomEditListBox(TcxCustomComboBox(Edit).ILookupData.ActiveControl).ItemIndex := lcxBoldComboBoxProperties.LookupListFollower.CurrentIndex;
        end;
      end;
  }
      TypeMayHaveChanged;

//      if Supports(Edit.ActiveProperties, IcxBoldEditProperties, lIcxBoldEditProperties) then
//      begin
      {$IFNDEF AttracsBold}
        if Assigned(Follower.Element) then
        begin
          lGuard := TBoldGuard.Create(lIE);
          lIE := TBoldIndirectElement.Create;
          Follower.Element.EvaluateExpression(TBoldFollowerControllerAccess(Follower.Controller).Expression, lIE, false, TBoldFollowerControllerAccess(Follower.Controller).VariableList);
          lElement := lIE.Value;
        end
        else
          lElement := nil;
      {$ELSE}
        lElement := Follower.ActualElement;
      {$ENDIF}

        {$IFDEF Constraints}
        SubscribeToConstraints(lElement);
        {$ENDIF}

        if Supports(Edit.ActiveProperties, IcxBoldEditProperties, lIcxBoldEditProperties) then
        begin
//          if Assigned(lElement) then
            lValue := lIcxBoldEditProperties.BoldElementToEditValue(Follower, lElement, Edit);
        end
        else
        begin
//        lValue := lElement.AsVariant;
          lValue := TBoldVariantFollowerController(Follower.Controller).GetCurrentAsVariant(Follower);
          if VarIsEmpty(lValue) then
            lValue := Null;
        end;
//  {$IFDEF Constraints}
//      SubscribeToConstraints(lElement);
//  {$ENDIF}
      if Edit.ModifiedAfterEnter and not Edit.IsPosting then
        Edit.Reset;
      if not cxEditVarEquals(Edit.EditValue, lValue) then
      begin
        TcxCustomEditAccess(Edit).SetInternalEditValue(lValue);
      end;
    end;
  finally
    Edit.LockClick(False);
    dec(fInternalChange);
  end;
end;

function TcxBoldEditDataBinding.GetContextType: TBoldElementTypeInfo;
begin
  if assigned(BoldHandle) then
    result := BoldHandle.StaticBoldType
  else
    result := nil;
end;

function TcxBoldEditDataBinding.CanModify: Boolean;
begin
  result := inherited CanModify and MayModify;
end;

procedure TcxBoldEditDataBinding.TypeMayHaveChanged;
begin
//  Edit.IsDesigning
// BoldEffectiveEnvironment.RunningInIDE or
  if not Assigned(BoldHandle) or not Assigned(BoldHandle.Value) then
    Exit; // only update at runtime if there are values, avoids update on every UML model change.
  if fCurrentElementType <> BoldHandle.BoldType then
  begin
    fCurrentElementType := BoldHandle.BoldType;
    if Edit is TcxCustomTextEdit then
      TcxCustomTextEditAccess(Edit).LockLookupDataTextChanged;
    try
      TcxCustomEditAccess(Edit).PropertiesChanged(nil);
    finally
      if Edit is TcxCustomTextEdit then
        TcxCustomTextEditAccess(Edit).UnlockLookupDataTextChanged;
    end;
  end;
end;

function TcxBoldEditDataBinding.MayModify: boolean;
var
  lcxBoldEditProperties: IcxBoldEditProperties;
begin
  result := BoldFollowerController.MayModify(Follower);
  if result and Supports(Edit.ActiveProperties, IcxBoldEditProperties, lcxBoldEditProperties) then
  begin
    result := lcxBoldEditProperties.CanEdit(BoldHandle, Follower);
  end;
end;

procedure TcxBoldEditDataBinding.DoChanged;
begin
  if Editing and (fInternalChange = 0) then
  begin
    inc(fInternalChange);
    try
      InternalSetValue(Edit.EditingValue);
      if ImmediatePost  then
      begin
        Follower.Apply;
        TBoldQueueable.DisplayAll;
      end;
    finally
      dec(fInternalChange);
    end;
  end;
end;

procedure TcxBoldEditDataBinding.DoExit;
begin
  if (Follower.State = bfsDirty) and (Follower.Controller.ApplyPolicy <> bapDemand) then
    Follower.Apply;
end;

{$IFDEF Constraints}
procedure TcxBoldEditDataBinding.SubscribeToConstraints(
  aElement: TBoldElement);
var
  lValid: boolean;
  s: string;
  lIE: TBoldIndirectElement;
  lConstraintList: TBoldList;
const
  ECM_FIRST = $1500;
  EM_SETCUEBANNER = ECM_FIRST + 1;
begin
  lValid := true;
  if ((aElement is TBoldObject) {and (TBoldObject(aElement).BoldClassTypeInfo.ConstraintCount > 0)})
  or (aElement is TBoldObjectReference)
  or ((aElement is TBoldMember) and Assigned(TBoldMember(aElement).BoldMemberRTInfo) and (TBoldMember(aElement).BoldMemberRTInfo.ConstraintCount > 0)) then
  begin
    lIE := TBoldIndirectElement.Create;
    try
      aElement.EvaluateExpression('constraints->select(c|not c)', lIe);
      lConstraintList := lIE.Value as TBoldList;
      lValid := lConstraintList.Count = 0;
      if (fValueOrDefinitionInvalid <> not lValid) then
      begin
        if not lValid and (VarisNull(Edit.EditingValue) or (Edit.EditingValue = ''))  then
          s := lConstraintList[0].StringRepresentation[11]
        else
          s := '';
        if Assigned(Edit) and Assigned(TcxCustomEditAccess(Edit).InnerEdit) then
          SendMessage(TcxCustomEditAccess(Edit).InnerEdit.Control.Handle, EM_SETCUEBANNER, 1, LParam(PWideChar(WideString(s))));
      end;
    finally
      lIE.free;
    end;
  end;
  ValueOrDefinitionInvalid := not lValid;
end;
{$ENDIF}

function TcxBoldEditDataBinding.ValidateComponent(
  ComponentValidator: TBoldComponentValidator;
  NamePrefix: string): Boolean;
var
  lContext: TBoldElementTypeInfo;
  lExpressionType: TBoldElementTypeInfo;
  lBoldValidateableComponent: IBoldValidateableComponent;
  s: string;
begin
  lContext := GetContextType;
  result := Assigned(lContext);
  if not result then
  begin
    BoldLog.LogFmt(sNoContext, [Edit.Name])
  end
  else
  begin
    result := ComponentValidator.ValidateExpressionInContext(
      TBoldFollowerControllerAccess(BoldFollowerController).Expression,
      lContext,
      format('%s %s.Expression', [NamePrefix, Edit.Name]){$IFDEF AttracsBold}, TBoldFollowerControllerAccess(BoldFollowerController).VariableList{$ENDIF}) and result; // do not localize

    if result then
    begin
      lExpressionType := lContext.Evaluator.ExpressionType(TBoldFollowerControllerAccess(BoldFollowerController).Expression, lContext, false, TBoldFollowerControllerAccess(BoldFollowerController).VariableList);
      if Assigned(lExpressionType) then
      begin
        s := ValidateTypeConforms(lExpressionType);
        if s <> '' then
        begin
          result := false;
          BoldLog.Log('*** ' + s + ' in ' + Edit.Name);
        end;
      end;
    end;
  end;
  if Supports(Edit.ActiveProperties, IBoldValidateableComponent, lBoldValidateableComponent) then
  begin
    result := lBoldValidateableComponent.ValidateComponent(ComponentValidator, NamePrefix) and result;
  end;
  ValueOrDefinitionInvalid := not result;
end;

function TcxBoldEditDataBinding.ValidateTypeConforms(
  aExpressionType: TBoldElementTypeInfo): string;
begin
  result := '';
end;

procedure TcxBoldEditDataBinding.SetValueOrDefinitionInvalid(
  const Value: boolean);
begin
  if fValueOrDefinitionInvalid <> Value then
  begin
    fValueOrDefinitionInvalid := Value;
//    Edit.Refresh;
//    Edit.Invalidate;
    Edit.Repaint;
  end;
end;

function TcxBoldEditDataBinding.GetBoldProperties: TBoldVariantFollowerController;
begin
  result := BoldFollowerController as TBoldVariantFollowerController;
end;

procedure TcxBoldEditDataBinding.InternalSetValue(
  const aValue: TcxEditValue);
begin
  {$IFDEF BoldDevExLog}
  if Follower.State = bfsSubscriptionOutOfDate then
  begin
    _Log('TcxBoldEditDataBinding.InternalSetValue, Follower.State = bfsSubscriptionOutOfDate', 'Follower debug');
  end;
  {$ENDIF}
  BoldProperties.MayHaveChanged(aValue, Follower);
end;

procedure TcxBoldEditDataBinding.SetBoldProperties(
  const Value: TBoldVariantFollowerController);
begin
  BoldFollowerController.Assign(Value);
end;

function TcxBoldEditDataBinding.GetExpression: TBoldExpression;
begin
  result := BoldProperties.Expression;
end;

function TcxBoldEditDataBinding.GetVariableList: TBoldExternalVariableList;
begin
  result := BoldProperties.VariableList;
end;

procedure TcxBoldEditDataBinding.SetExpression({$IFDEF AttracsBold}const{$ENDIF} Value: TBoldExpression);
begin
  BoldProperties.Expression := Value;
end;

{ TcxBoldTextEdit }

class function TcxBoldTextEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxBoldTextEditProperties;
end;

function TcxBoldTextEdit.GetActiveProperties: TcxBoldTextEditProperties;
begin
  Result := TcxBoldTextEditProperties(InternalGetActiveProperties);
//  FProperties.ValidateOnEnter := true;
end;

function TcxBoldTextEdit.GetProperties: TcxBoldTextEditProperties;
begin
  Result := TcxBoldTextEditProperties(FProperties);
//  FProperties.ImmediatePost := true;
//  FProperties.ValidateOnEnter := true;
end;

procedure TcxBoldTextEdit.SetProperties(
  Value: TcxBoldTextEditProperties);
begin
  FProperties.Assign(Value);
end;

class function TcxBoldTextEdit.GetDataBindingClass: TcxEditDataBindingClass;
begin
  Result := TcxBoldTextEditDataBinding;
end;

function TcxBoldTextEdit.GetDataBinding: TcxBoldTextEditDataBinding;
begin
  Result := FDataBinding as TcxBoldTextEditDataBinding;
end;

procedure TcxBoldTextEdit.SetDataBinding(
  Value: TcxBoldTextEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

function TcxBoldTextEdit.ValidateKeyDown(var Key: Word;
  Shift: TShiftState): Boolean;
begin
  result := DataBinding.IsDataAvailable and inherited ValidateKeyDown(Key, Shift);
end;

function TcxBoldTextEdit.ValidateKeyPress(var Key: Char): Boolean;
begin
  result := DataBinding.MayModify and inherited ValidateKeyPress(Key);
  if not result then
    Key := #0
  else
  begin
    if (Key = #13) and (DataBinding.Follower.Controller.ApplyPolicy <> bapDemand) then
    begin
      DataBinding.Follower.Apply;
      SelectAll;
    end;
  end;
end;

procedure TcxBoldTextEdit.DoOnChange;
begin
  inherited;
  PostEditValue;
end;

procedure TcxBoldTextEdit.DoChange;
begin
  inherited;
  DataBinding.DoChanged;
end;

procedure TcxBoldTextEdit.DoExit;
begin
  inherited;
  DataBinding.DoExit;
end;
{
function TcxBoldTextEdit.ValidateComponent(
  ComponentValidator: TBoldComponentValidator;
  NamePrefix: string): Boolean;
begin
  result := DataBinding.ValidateComponent(ComponentValidator, NamePrefix);
  result := GetActiveProperties.ValidateComponent(ComponentValidator, NamePrefix) and result;
end;
}
procedure TcxBoldTextEdit.Paint;
begin
  inherited Paint;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 2 - Ord(IsNativeStyle));
end;

{ TcxCustomBoldEditDefaultValuesProvider }

function TcxCustomBoldEditDefaultValuesProvider.GetBoldElementTypeInfo: TBoldElementTypeInfo;
begin
  if Assigned({DataBinding.}BoldHandle)then
    result := {DataBinding.}BoldHandle.StaticBoldType
  else
    result := nil;
end;

function TcxCustomBoldEditDefaultValuesProvider.IsDataAvailable: Boolean;
begin
  Result := ({DataBinding.}BoldHandle <> nil) {and (DataBinding.BoldHandle.Value <> nil)};
end;

function TcxCustomBoldEditDefaultValuesProvider.DefaultAlignment: TAlignment;
var
  lElement: TBoldElement;
{$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
begin
  Result := taLeftJustify;
//  exit;
  if IsDataAvailable then
  begin
  {$IFNDEF AttracsBold}
    if Assigned(Follower.Element) then
    begin
      lGuard := TBoldGuard.Create(lIE);
      lIE := TBoldIndirectElement.Create;
      Follower.Element.EvaluateExpression(TBoldFollowerControllerAccess(Follower.Controller).Expression, lIE, false, TBoldFollowerControllerAccess(Follower.Controller).VariableList);
      lElement := lIE.Value;
    end
    else
      lElement := nil;
  {$ELSE}
    lElement := Follower.ActualElement;
  {$ENDIF}
    if (lElement is TBAMoment) or (lElement is TBANumeric) then
      result := taRightJustify;
  end;
end;

function TcxCustomBoldEditDefaultValuesProvider.DefaultBlobKind: TcxBlobKind;
var
  lElement: TBoldElement;
{$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
begin
  Result := cxEdit.bkNone;
{$IFNDEF AttracsBold}
  if Assigned(Follower.Element) then
  begin
    lGuard := TBoldGuard.Create(lIE);
    lIE := TBoldIndirectElement.Create;
    Follower.Element.EvaluateExpression(TBoldFollowerControllerAccess(Follower.Controller).Expression, lIE, false, TBoldFollowerControllerAccess(Follower.Controller).VariableList);
    lElement := lIE.Value;
  end
  else
    lElement := nil;
{$ELSE}
  lElement := Follower.ActualElement;
{$ENDIF}
  if (lElement is TBABlob) then
  begin
    if (lElement is TBABlobImageBMP) or (lElement is TBABlobImageJPEG) then
      Result := bkGraphic
    else
    if (lElement is TBATypedBlob) then
    begin
      Result := bkBlob;
//    TcxBlobKind = (bkNone, bkBlob, bkGraphic, bkMemo, bkOle);
{
  MIME decode to see what type it is
            (Follower.ActualElement as TBATypedBlob).ContentType
}
    end
    else
  end;
end;

function TcxCustomBoldEditDefaultValuesProvider.DefaultCanModify: Boolean;
begin
// TODO: 'not Assigned(Follower.Element)' is a temp workaround for cases where Value is nil and hence not allowed to be modified as per TBoldRenderer.DefaultMayModify
  Result := not DefaultReadOnly and IsDataAvailable and (Follower.Controller.MayModify(Follower) or not Assigned(Follower.Element)) {DataBinding.MayModify};
end;

function TcxCustomBoldEditDefaultValuesProvider.DefaultIsFloatValue: Boolean;
var
{$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
  lElement: TBoldElement;
begin
{$IFNDEF AttracsBold}
  if Assigned(Follower.Element) then
  begin
    lGuard := TBoldGuard.Create(lIE);
    lIE := TBoldIndirectElement.Create;
    Follower.Element.EvaluateExpression(TBoldFollowerControllerAccess(Follower.Controller).Expression, lIE, false, TBoldFollowerControllerAccess(Follower.Controller).VariableList);
    lElement := lIE.Value;
  end
  else
    lElement := nil;
{$ELSE}
  lElement := Follower.ActualElement;
{$ENDIF}
  result := (lElement is TBAFloat) or (lElement is TBACurrency);
end;

function TcxCustomBoldEditDefaultValuesProvider.DefaultMaxLength: Integer;
var
{$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
  lElement: TBoldElement;
begin
{$IFNDEF AttracsBold}
  if Assigned(Follower.Element) then
  begin
    lGuard := TBoldGuard.Create(lIE);
    lIE := TBoldIndirectElement.Create;
    Follower.Element.EvaluateExpression(TBoldFollowerControllerAccess(Follower.Controller).Expression, lIE, false, TBoldFollowerControllerAccess(Follower.Controller).VariableList);
    lElement := lIE.Value;
  end
  else
    lElement := nil;
{$ELSE}
  lElement := Follower.ActualElement;
{$ENDIF}
  if (lElement is TBAString) and Assigned(TBAString(lElement).BoldAttributeRTInfo) then
  begin
    result := TBAString(lElement).BoldAttributeRTInfo.Length;
    if result < 1 then
      Result := inherited DefaultMaxLength;
  end
  else
    Result := inherited DefaultMaxLength;
end;

function TcxCustomBoldEditDefaultValuesProvider.IsBlob: Boolean;
var
{$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
  lElement: TBoldElement;
begin
  result := IsDataAvailable;
  if result then
  begin
{$IFNDEF AttracsBold}
    if Assigned(Follower.Element) then
    begin
      lGuard := TBoldGuard.Create(lIE);
      lIE := TBoldIndirectElement.Create;
      Follower.Element.EvaluateExpression(TBoldFollowerControllerAccess(Follower.Controller).Expression, lIE, false, TBoldFollowerControllerAccess(Follower.Controller).VariableList);
      lElement := lIE.Value;
    end
    else
      lElement := nil;
{$ELSE}
    lElement := Follower.ActualElement;
{$ENDIF}
    result := (lElement is TBABlob);
  end;
end;

function TcxCustomBoldEditDefaultValuesProvider.IsCurrency: Boolean;
var
{$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
  lElement: TBoldElement;
begin
  result := IsDataAvailable;
  if result then
  begin
{$IFNDEF AttracsBold}
    if Assigned(Follower.Element) then
    begin
      lGuard := TBoldGuard.Create(lIE);
      lIE := TBoldIndirectElement.Create;
      Follower.Element.EvaluateExpression(TBoldFollowerControllerAccess(Follower.Controller).Expression, lIE, false, TBoldFollowerControllerAccess(Follower.Controller).VariableList);
      lElement := lIE.Value;
    end
    else
      lElement := nil;
{$ELSE}
    lElement := Follower.ActualElement;
{$ENDIF}
    result := (lElement is TBACurrency);
  end;
end;

function TcxCustomBoldEditDefaultValuesProvider.IsValidChar(
  AChar: Char): Boolean;
begin
  result := inherited IsValidChar(AChar);
  if result and (BoldProperties is TBoldVariantFollowerController) then
    result := TBoldVariantFollowerController(BoldProperties).ValidateCharacter(AChar, Follower);
end;

function TcxCustomBoldEditDefaultValuesProvider.GetFollower: TBoldFollower;
begin
{$IFDEF AttracsBold}
  result := BoldHandleFollower.Follower;
{$ELSE}
  if BoldHandleFollower is TBoldElementHandleFollower then
    result := TBoldElementHandleFollower(BoldHandleFollower).Follower
  else
  if BoldHandleFollower is TBoldListHandleFollower then
    result := TBoldListHandleFollower(BoldHandleFollower).Follower
  else
    result := nil;
{$ENDIF}
end;

procedure TcxCustomBoldEditDefaultValuesProvider.SetBoldProperties(
  const Value: TBoldFollowerController);
begin
  fBoldProperties := Value;
end;

procedure TcxCustomBoldEditDefaultValuesProvider.SetHandleFollower(
  const Value: TBoldAbstractHandleFollower);
begin
  fBoldHandleFollower := Value;
end;

function TcxCustomBoldEditDefaultValuesProvider.GetBoldHandle: TBoldElementHandle;
begin
{$IFDEF AttracsBold}
  result := BoldHandleFollower.BoldHandle;
{$ELSE}
  if BoldHandleFollower is TBoldElementHandleFollower then
    result := TBoldElementHandleFollower(BoldHandleFollower).BoldHandle
  else
  if BoldHandleFollower is TBoldListHandleFollower then
    result := TBoldListHandleFollower(BoldHandleFollower).BoldHandle
  else
    result := nil;
{$ENDIF}
end;

constructor TcxCustomBoldEditDefaultValuesProvider.Create(
  AOwner: TPersistent);
begin
  inherited;

end;

destructor TcxCustomBoldEditDefaultValuesProvider.Destroy;
begin

  inherited;
end;

{ TcxBoldFloatEditDataBinding }

function TcxBoldFloatEditDataBinding.ValidateTypeConforms(
  aExpressionType: TBoldElementTypeInfo): string;
var
  lFloatTypeInfo: TBoldAttributeTypeInfo;
  lCurrencyTypeInfo: TBoldAttributeTypeInfo;
begin
  result := '';
  with (aExpressionType.SystemTypeInfo as TBoldSystemTypeInfo) do
  begin
    lCurrencyTypeInfo := AttributeTypeInfoByExpressionName['Currency']; // do not localize
    lFloatTypeInfo := AttributeTypeInfoByExpressionName['Float']; // do not localize
  end;
  if not aExpressionType.ConformsTo(lCurrencyTypeInfo) and not aExpressionType.ConformsTo(lFloatTypeInfo) then
    result := Format(sPossiblyBadConformance, [aExpressionType.ModelName , lFloatTypeInfo.ModelName]);
end;

{ TcxBoldDateTimeEditDataBinding }

function TcxBoldDateTimeEditDataBinding.ValidateTypeConforms(
  aExpressionType: TBoldElementTypeInfo): string;
var
  lDateTimeTypeInfo: TBoldAttributeTypeInfo;
  lDateTypeInfo: TBoldAttributeTypeInfo;
begin
  result := '';
  with (aExpressionType.SystemTypeInfo as TBoldSystemTypeInfo) do
  begin
    lDateTimeTypeInfo := AttributeTypeInfoByExpressionName['DateTime']; // do not localize
    lDateTypeInfo := AttributeTypeInfoByExpressionName['Date']; // do not localize
  end;
  if not (aExpressionType.ConformsTo(lDateTimeTypeInfo) or aExpressionType.ConformsTo(lDateTypeInfo)) then
    result := Format(sPossiblyBadConformance, [aExpressionType.ModelName , lDateTimeTypeInfo.ModelName + ' nor ' + lDateTypeInfo.ModelName]);
end;

{ TcxBoldDateEdit }

function TcxBoldDateEdit.CanDropDown: Boolean;
begin
  result := inherited CanDropDown and DataBinding.IsDataAvailable;
end;

procedure TcxBoldDateEdit.DoChange;
begin
  inherited;
  DataBinding.DoChanged;
end;

procedure TcxBoldDateEdit.DoExit;
begin
  inherited;
  DataBinding.DoExit;
end;

procedure TcxBoldDateEdit.DoOnChange;
begin
  inherited;
  PostEditValue;
end;

{ TcxBoldDateEdit }

function TcxBoldDateEdit.GetActiveProperties: TcxDateEditProperties;
begin
  Result := TcxDateEditProperties(InternalGetActiveProperties);
end;

function TcxBoldDateEdit.GetDataBinding: TcxBoldDateTimeEditDataBinding;
begin
  Result := TcxBoldDateTimeEditDataBinding(FDataBinding);
end;

class function TcxBoldDateEdit.GetDataBindingClass: TcxEditDataBindingClass;
begin
  Result := TcxBoldDateTimeEditDataBinding;
end;

function TcxBoldDateEdit.GetProperties: TcxDateEditProperties;
begin
  Result := TcxDateEditProperties(FProperties);
end;

class function TcxBoldDateEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxDateEditProperties;
end;

procedure TcxBoldDateEdit.HidePopup(Sender: TcxControl;
  AReason: TcxEditCloseUpReason);
begin
  inherited;
// this will post the value when the calednar popup is closed with ok or enter
// the idea being to post the value even if using bapExit  
  if AReason = crEnter then
  begin
    DataBinding.InternalSetValue(EditingValue);
    if (DataBinding.BoldFollowerController.ApplyPolicy <> bapDemand) then
      DataBinding.Follower.Apply;
  end;
end;

procedure TcxBoldDateEdit.Paint;
begin
  inherited Paint;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 2 - Ord(IsNativeStyle));
end;

procedure TcxBoldDateEdit.SetDataBinding(
  Value: TcxBoldDateTimeEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxBoldDateEdit.SetProperties(
  Value: TcxDateEditProperties);
begin
  FProperties.Assign(Value);
end;

function TcxBoldDateEdit.ValidateKeyDown(var Key: Word;
  Shift: TShiftState): Boolean;
begin
  result := DataBinding.IsDataAvailable and inherited ValidateKeyDown(Key, Shift);
end;

function TcxBoldDateEdit.ValidateKeyPress(var Key: Char): Boolean;
begin
  result := DataBinding.MayModify and inherited ValidateKeyPress(Key);
  if not result then
    Key := #0
  else
  begin
    if (Key = #13) and (DataBinding.Follower.Controller.ApplyPolicy <> bapDemand) then
    begin
      DataBinding.Follower.Apply;
      SelectAll;
    end;
  end;
end;

{ TcxBoldMemo }

procedure TcxBoldMemo.DoChange;
begin
  inherited;
  DataBinding.DoChanged;
end;

procedure TcxBoldMemo.DoExit;
begin
  inherited;
  DataBinding.DoExit;
end;

function TcxBoldMemo.GetActiveProperties: TcxMemoProperties;
begin
  Result := TcxMemoProperties(InternalGetActiveProperties);
end;

function TcxBoldMemo.GetDataBinding: TcxBoldTextEditDataBinding;
begin
  Result := TcxBoldTextEditDataBinding(FDataBinding);
end;

class function TcxBoldMemo.GetDataBindingClass: TcxEditDataBindingClass;
begin
  result := TcxBoldTextEditDataBinding;
end;

function TcxBoldMemo.GetProperties: TcxMemoProperties;
begin
  Result := TcxMemoProperties(FProperties);
end;

class function TcxBoldMemo.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxMemoProperties;
end;

procedure TcxBoldMemo.Paint;
begin
  inherited Paint;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 2 - Ord(IsNativeStyle));
end;

procedure TcxBoldMemo.SetDataBinding(Value: TcxBoldTextEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxBoldMemo.SetProperties(Value: TcxMemoProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxBoldTimeEdit }

procedure TcxBoldTimeEdit.DoChange;
begin
  inherited;
  DataBinding.DoChanged;
end;

procedure TcxBoldTimeEdit.DoExit;
begin
  inherited;
  DataBinding.DoExit;
end;

function TcxBoldTimeEdit.GetActiveProperties: TcxTimeEditProperties;
begin
  Result := TcxTimeEditProperties(InternalGetActiveProperties);
end;

function TcxBoldTimeEdit.GetDataBinding: TcxBoldTimeEditDataBinding;
begin
  Result := TcxBoldTimeEditDataBinding(FDataBinding);
end;

class function TcxBoldTimeEdit.GetDataBindingClass: TcxEditDataBindingClass;
begin
  result := TcxBoldTimeEditDataBinding;
end;

function TcxBoldTimeEdit.GetProperties: TcxTimeEditProperties;
begin
  Result := TcxTimeEditProperties(FProperties);
end;

class function TcxBoldTimeEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxTimeEditProperties;
end;

procedure TcxBoldTimeEdit.Paint;
begin
  inherited Paint;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 2 - Ord(IsNativeStyle));
end;

procedure TcxBoldTimeEdit.SetDataBinding(
  Value: TcxBoldTimeEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxBoldTimeEdit.SetProperties(Value: TcxTimeEditProperties);
begin
  FProperties.Assign(Value);
end;

function TcxBoldTimeEdit.ValidateKeyDown(var Key: Word;
  Shift: TShiftState): Boolean;
begin
  result := DataBinding.IsDataAvailable and inherited ValidateKeyDown(Key, Shift);
end;

function TcxBoldTimeEdit.ValidateKeyPress(var Key: Char): Boolean;
begin
  result := DataBinding.MayModify and inherited ValidateKeyPress(Key);
  if not result then
    Key := #0
  else
  begin
    if (Key = #13) and (DataBinding.Follower.Controller.ApplyPolicy <> bapDemand) then
    begin
      DataBinding.Follower.Apply;
      SelectAll;
    end;
  end;
end;

{ TcxBoldCurrencyEdit }

procedure TcxBoldCurrencyEdit.DoExit;
begin
  inherited;
  DataBinding.DoExit;
end;

function TcxBoldCurrencyEdit.GetActiveProperties: TcxCurrencyEditProperties;
begin
  Result := TcxCurrencyEditProperties(InternalGetActiveProperties);
end;

function TcxBoldCurrencyEdit.GetDataBinding: TcxBoldCurrencyEditDataBinding;
begin
  Result := TcxBoldCurrencyEditDataBinding(FDataBinding);
end;

class function TcxBoldCurrencyEdit.GetDataBindingClass: TcxEditDataBindingClass;
begin
  Result := TcxBoldCurrencyEditDataBinding;
end;

function TcxBoldCurrencyEdit.GetProperties: TcxCurrencyEditProperties;
begin
  Result := TcxCurrencyEditProperties(FProperties);
end;

class function TcxBoldCurrencyEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCurrencyEditProperties;
end;

procedure TcxBoldCurrencyEdit.Paint;
begin
  inherited Paint;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 2 - Ord(IsNativeStyle));
end;

procedure TcxBoldCurrencyEdit.SetDataBinding(
  Value: TcxBoldCurrencyEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxBoldCurrencyEdit.SetProperties(
  Value: TcxCurrencyEditProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxBoldCurrencyEdit.DoChange;
begin
  inherited;
  DataBinding.DoChanged;
end;

{ TcxBoldTextEditDataBinding }
{
procedure TcxBoldTextEditDataBinding.InternalSetValue(
  const aValue: TcxEditValue);
begin
  if VarIsNull(aValue) then
    BoldProperties.MayHaveChanged('', Follower)
  else
    BoldProperties.MayHaveChanged(aValue, Follower);
end;
}
{ TcxBoldMaskEdit }

procedure TcxBoldMaskEdit.DoExit;
begin
  inherited;
  DataBinding.DoExit;
end;

function TcxBoldMaskEdit.GetActiveProperties: TcxMaskEditProperties;
begin
  Result := TcxMaskEditProperties(InternalGetActiveProperties);
end;

function TcxBoldMaskEdit.GetDataBinding: TcxBoldTextEditDataBinding;
begin
  Result := TcxBoldTextEditDataBinding(FDataBinding);
end;

class function TcxBoldMaskEdit.GetDataBindingClass: TcxEditDataBindingClass;
begin
  Result := TcxBoldTextEditDataBinding;
end;

function TcxBoldMaskEdit.GetProperties: TcxMaskEditProperties;
begin
  Result := TcxMaskEditProperties(FProperties);
end;

class function TcxBoldMaskEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxMaskEditProperties;
end;

procedure TcxBoldMaskEdit.Paint;
begin
  inherited Paint;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 2 - Ord(IsNativeStyle));
end;

procedure TcxBoldMaskEdit.SetDataBinding(
  Value: TcxBoldTextEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxBoldMaskEdit.SetProperties(Value: TcxMaskEditProperties);
begin
  FProperties.Assign(Value);
end;

function TcxBoldMaskEdit.SupportsSpelling: Boolean;
begin
  Result := IsTextInputMode;
end;

{ TcxBoldCheckBoxEditDataBinding }


function TcxBoldCheckBoxEditDataBinding.MayModify: boolean;
begin
  result := inherited MayModify and (fCurrentElementType is TBoldAttributeTypeInfo) and TBoldAttributeTypeInfo(fCurrentElementType).AttributeClass.InheritsFrom(TBABoolean);
end;


function TcxBoldCheckBoxEditDataBinding.ValidateTypeConforms(
  aExpressionType: TBoldElementTypeInfo): string;
var
  lBooleanTypeInfo: TBoldAttributeTypeInfo;
begin
  result := '';
  with (aExpressionType.SystemTypeInfo as TBoldSystemTypeInfo) do
  begin
    lBooleanTypeInfo := AttributeTypeInfoByExpressionName['Boolean']; // do not localize
  end;
  if not aExpressionType.ConformsTo(lBooleanTypeInfo) then
    result := Format(sPossiblyBadConformance, [aExpressionType.ModelName , lBooleanTypeInfo.ModelName]);
end;

function TcxBoldCheckBoxEditDataBinding.ImmediatePost: boolean;
begin
  result := true;
end;

{ TcxBoldCheckBox }

procedure TcxBoldCheckBox.DoChange;
begin
  inherited;
  DataBinding.DoChanged;
end;

procedure TcxBoldCheckBox.DoExit;
begin
  inherited;
  DataBinding.DoExit;
end;

function TcxBoldCheckBox.GetActiveProperties: TcxCheckBoxProperties;
begin
  Result := TcxCheckBoxProperties(InternalGetActiveProperties);
end;

function TcxBoldCheckBox.GetDataBinding: TcxBoldCheckBoxEditDataBinding;
begin
  Result := FDataBinding as TcxBoldCheckBoxEditDataBinding;
end;

class function TcxBoldCheckBox.GetDataBindingClass: TcxEditDataBindingClass;
begin
  result := TcxBoldCheckBoxEditDataBinding;
end;

function TcxBoldCheckBox.GetProperties: TcxCheckBoxProperties;
begin
  Result := TcxCheckBoxProperties(FProperties);
end;

class function TcxBoldCheckBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCheckBoxProperties;
end;

procedure TcxBoldCheckBox.Initialize;
begin
  inherited;
  if IsDesigning and not IsLoading then
  begin
    _ValidateEdit(self);
  end;
end;

procedure TcxBoldCheckBox.Paint;
begin
  inherited;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 3);
end;

procedure TcxBoldCheckBox.SetDataBinding(
  Value: TcxBoldCheckBoxEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxBoldCheckBox.SetProperties(Value: TcxCheckBoxProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxBoldCheckBox.Toggle;
begin
  // this is a bit hacky, would be better if we can set it somewhere once
  FProperties.ImmediatePost := DataBinding.ImmediatePost;
  if CanModify and Assigned(DataBinding.Follower.Element) then
    inherited Toggle;
  DataBinding.Follower.Apply;
end;

{ TcxBoldComboBoxProperties }

procedure TcxBoldComboBoxProperties._DeleteItem(Index: Integer;
  OwningFollower: TBoldFollower);
begin
  Items.Delete(index);
end;

{$IFNDEF AttracsBold}
procedure TcxBoldComboBoxProperties._InsertItem(Follower: TBoldFollower);
{$ELSE}
procedure TcxBoldComboBoxProperties._InsertItem(Index: Integer; Follower: TBoldFollower);
{$ENDIF}
begin
  if Assigned(Follower) then
  begin
    Follower.EnsureDisplayable;
    Items.Insert(Follower.Index, VarToStr(TBoldVariantFollowerController(Follower.Controller).GetCurrentAsVariant(Follower)));
  end
  else
  begin
{$IFDEF AttracsBold}
    Items.Insert(Index, BoldRowProperties.NilRepresentation);
{$ENDIF}
  end;
end;

procedure TcxBoldComboBoxProperties._RowAfterMakeUptoDate(
  Follower: TBoldFollower);
var
  index: Integer;
begin
  index := Follower.index;
  if (index > -1) and (index < Items.Count) then
    Items[index] := VarToStr(TBoldVariantFollowerController(Follower.Controller).GetCurrentAsVariant(Follower));
//  LookupDataChanged(self);
  // forces a redisplay of the edit-area, the windows component might go blank if the active row is removed and then reinserted
//  fBoldHandleFollower.Follower.MarkValueOutOfDate; // do we really need this here ? Danny
end;

procedure TcxBoldComboBoxProperties._AfterMakeUptoDate(
  Follower: TBoldFollower);
begin
  fBoldRowProperties.AfterMakeUptoDate := _RowAfterMakeUptoDate;
  Items.EndUpdate;
end;

procedure TcxBoldComboBoxProperties._BeforeMakeUptoDate(
  Follower: TBoldFollower);
begin
  fBoldRowProperties.AfterMakeUptoDate := nil;
  Items.BeginUpdate;
end;

constructor TcxBoldComboBoxProperties.Create(AOwner: TPersistent);
var
  lMatchObject: TComponent;
//  lBoldAwareViewItem: IBoldAwareViewItem;
begin
  inherited;
  if aOwner is TComponent then
    lMatchObject := aOwner as TComponent
  else
    lMatchObject := nil;
  fBoldRowProperties := TBoldVariantFollowerController.Create(lMatchObject);
  fBoldRowProperties.AfterMakeUptoDate := _RowAfterMakeUptoDate;
  fBoldRowProperties.OnGetContextType := GetContextForBoldRowProperties;
  fBoldListProperties := TBoldComboListController.Create(lMatchObject, fBoldRowProperties);
  with fBoldListProperties do
  begin
    OnAfterInsertItem := _InsertItem;
    OnAfterDeleteItem := _DeleteItem;
    BeforeMakeUptoDate := _BeforeMakeUptoDate;
    AfterMakeUptoDate := _AfterMakeUptoDate;
  end;
  fListHandleFollower := TBoldListHandleFollower.Create(Owner, fBoldListProperties);
  ImmediatePost := false;
  BoldSelectChangeAction := bdcsSetValue;
//  if aOwner.GetInterface(IBoldAwareViewItem, lBoldAwareViewItem) then
//    BoldSetValueExpression := lBoldAwareViewItem.DataBinding.BoldProperties.Expression;
end;

destructor TcxBoldComboBoxProperties.Destroy;
begin
  FreeAndNil(fListHandleFollower);
  FreeAndNil(fBoldListProperties);
  FreeAndNil(fBoldRowProperties);
  inherited;
end;

function TcxBoldComboBoxProperties.GetBoldListHandle: TBoldAbstractListHandle;
begin
  Result := fListHandleFollower.BoldHandle;
end;

function TcxBoldComboBoxProperties.GetContextForBoldRowProperties: TBoldElementTypeInfo;
begin
  if assigned(BoldLookupListHandle) then
    result := BoldLookupListHandle.StaticBoldType
  else
    result := nil;
end;

function TcxBoldComboBoxProperties.GetListFollower: TBoldFollower;
begin
  Result := fListHandleFollower.Follower;
end;

procedure TcxBoldComboBoxProperties.SetBoldListHandle(
  const Value: TBoldAbstractListHandle);
begin
  fListHandleFollower.BoldHandle := value;
end;

procedure TcxBoldComboBoxProperties.SetBoldListProperties(
  const Value: TBoldComboListController);
begin
  fBoldListProperties.Assign(Value);
end;

procedure TcxBoldComboBoxProperties.SetRowProperties(
  const Value: TBoldVariantFollowerController);
begin
  fBoldRowProperties.Assign(Value);
end;

procedure TcxBoldComboBoxProperties.SetBoldSelectChangeAction(
  Value: TBoldComboSelectChangeAction);
begin
{  if (Value = bdcsSetReference) and assigned(BoldHandle) and
     not (BoldHandle is TBoldReferenceHandle) then
    raise EBold.Create(sChangeActionCannotBeSetReference);
}
  fBoldSelectChangeAction := Value;
end;

procedure TcxBoldComboBoxProperties.SetStoredValue(
  aValue: Variant;
  aBoldHandle: TBoldElementHandle;
  aEdit: TcxCustomEdit;
  aFollower: TBoldFollower;
  var aDone: boolean);
var
  LocalSelectedElement: TBoldElement;
  lItemIndex: Integer;
begin
  Assert(aEdit is TcxCustomComboBox);
  lItemIndex := (aEdit as TcxCustomComboBox).ItemIndex;
  if lItemIndex = -1 then
  begin
    // if DropDownListStyle = lsEditList then we might want to let default handling make modifications
    // on other cases we set aDone := true as we're sure that with a fixed list item that isn't in the list won't make changes.
    if DropDownListStyle <> lsEditList then
      aDone := true;
    exit;
  end
  else
  begin
    if ((lItemIndex = LookupListFollower.SubFollowerCount-1) and (BoldLookupListProperties.NilElementMode = neAddLast))
    or ((lItemIndex = 0) and (BoldLookupListProperties.NilElementMode = neInsertFirst)) then
    begin
      LocalSelectedElement := nil
    end
    else
    begin
      if (BoldLookupListProperties.NilElementMode = neInsertFirst) then
        dec(lItemIndex);
      LocalSelectedElement := BoldLookupListHandle.List[lItemIndex];
    end;
  end;
  InternalComboSetValue(aBoldHandle, aFollower, LocalSelectedElement, BoldSelectChangeAction, BoldSetValueExpression, BoldLookupListHandle);
  aDone := true;
end;

class function TcxBoldComboBoxProperties.GetContainerClass: TcxContainerClass;
begin
  result := inherited GetContainerClass;
//  result := TcxBoldComboBox;
end;

function TcxBoldComboBoxProperties.GetAlwaysPostEditValue: Boolean;
begin
  result := false;
end;

function TcxBoldComboBoxProperties.ValidateComponent(
  ComponentValidator: TBoldComponentValidator;
  NamePrefix: string): Boolean;
var
  lContext: TBoldElementTypeInfo;
  lName: string;
  lcxBoldEditDataBinding: TcxBoldEditDataBinding;
begin
  result := true;
  if (Owner is TComponent) and (TComponent(Owner).Name <> '') then
    lName := TComponent(Owner).Name
  else
  if Assigned(Owner) then
    lName := Owner.ClassName
  else
    lName := ClassName;

//  OutPutDebugString(PChar(lName));

  lContext := GetContextForBoldRowProperties;
  if assigned(lContext) then
  begin
    result := ComponentValidator.ValidateExpressionInContext(
      BoldRowProperties.Expression,
      lContext,
      format('%s %s.BoldRowProperties.Expression', [NamePrefix, lName]){$IFDEF AttracsBold}, BoldRowProperties.VariableList{$ENDIF}) and result; // do not localize

    if (BoldSelectChangeAction = bdcsSetValue) and (Owner is TcxCustomEdit) then
    begin
      lcxBoldEditDataBinding := TcxCustomEditAccess(TcxCustomEdit(Owner)).DataBinding as TcxBoldEditDataBinding;
      lContext := lcxBoldEditDataBinding.GetContextType;
      result := ComponentValidator.ValidateExpressionInContext(
        BoldSetValueExpression,
        lContext,
        format('%s %s.BoldSetValueExpression', [NamePrefix, lName])
        {$IFDEF AttracsBold},lcxBoldEditDataBinding.BoldProperties.VariableList{$ENDIF}) and result; // do not localize
    end;
  end;
end;

function TcxBoldComboBoxProperties.BoldElementToEditValue(
  aFollower: TBoldFollower; aElement: TBoldElement; aEdit: TcxCustomEdit): variant;
begin
  result := BoldRowProperties.GetCurrentAsVariant(aFollower);
end;

procedure TcxBoldComboBoxProperties.Assign(Source: TPersistent);
begin
  if Source is TcxBoldComboBoxProperties then
  begin
    BeginUpdate;
    try
      BoldLookupListHandle := TcxBoldComboBoxProperties(Source).BoldLookupListHandle;
      BoldLookupListProperties := TcxBoldComboBoxProperties(Source).BoldLookupListProperties;
      BoldRowProperties := TcxBoldComboBoxProperties(Source).BoldRowProperties;
      BoldSetValueExpression := TcxBoldComboBoxProperties(Source).BoldSetValueExpression;
      BoldSelectChangeAction := TcxBoldComboBoxProperties(Source).BoldSelectChangeAction;
      inherited Assign(Source);


//      (FIDefaultValuesProvider.GetInstance as TcxCustomBoldEditDefaultValuesProvider).BoldHandleFollower := (TcxBoldComboBoxProperties(Source).FIDefaultValuesProvider.GetInstance as TcxCustomBoldEditDefaultValuesProvider).BoldHandleFollower;
//      (FIDefaultValuesProvider.GetInstance as TcxCustomBoldEditDefaultValuesProvider).BoldProperties  := (TcxBoldComboBoxProperties(Source).FIDefaultValuesProvider.GetInstance as TcxCustomBoldEditDefaultValuesProvider).BoldProperties;

      TBoldQueueable.DisplayAll;
    finally
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

function TcxBoldComboBoxProperties.CanEdit(aBoldHandle: TBoldElementHandle;
  aFollower: TBoldFollower): boolean;
begin
  result := (LookupListFollower.SubFollowerCount > 0) or (DropDownListStyle = lsEditList);
end;

procedure TcxBoldComboBoxProperties.SetBoldSetValueExpression(
  const Value: TBoldExpression);
begin
  fBoldSetValueExpression := Value;
  if Owner is TcxCustomEdit and (TcxCustomEdit(Owner).IsDesigning) and not (TcxCustomEdit(Owner).IsLoading) then
  begin
    _ValidateEdit(TcxCustomEdit(Owner));
  end;  
end;

{ TcxBoldComboBox }

function TcxBoldComboBox.CanDropDown: Boolean;
var
  lElementToAssignTo: TBoldElement;
begin
  result := inherited CanDropDown and DataBinding.IsDataAvailable;
  if result then
  begin
    case ActiveProperties.BoldSelectChangeAction of
      bdcsSetValue:
        begin
          if (Assigned(DataBinding.Follower.Element)) then
          begin
            if trim(ActiveProperties.BoldSetValueExpression) <> '' then
            begin
              lElementToAssignTo := DataBinding.Follower.Element.EvaluateExpressionAsDirectElement(ActiveProperties.BoldSetValueExpression, TBoldFollowerControllerAccess(DataBinding.Follower.Controller).VariableList);
              result := assigned(lElementToAssignTo) and lElementToAssignTo.Mutable;
            end;
          end
          else
            result := false;
        end;
    end;
  end;
end;

procedure TcxBoldComboBox.DoExit;
begin
  inherited;
  DataBinding.DoExit;
end;

function TcxBoldComboBox.GetActiveProperties: TcxBoldComboBoxProperties;
begin
  Result := TcxBoldComboBoxProperties(InternalGetActiveProperties);
end;

function TcxBoldComboBox.GetDataBinding: TcxBoldComboBoxEditDataBinding;
begin
  Result := TcxBoldComboBoxEditDataBinding(FDataBinding);
end;

class function TcxBoldComboBox.GetDataBindingClass: TcxEditDataBindingClass;
begin
  result := TcxBoldComboBoxEditDataBinding; //TcxBoldTextEditDataBinding;
end;

function TcxBoldComboBox.GetProperties: TcxBoldComboBoxProperties;
begin
  Result := TcxBoldComboBoxProperties(FProperties);
end;

class function TcxBoldComboBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  result := TcxBoldComboBoxProperties;
end;

procedure TcxBoldComboBox.Paint;
begin
  inherited Paint;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 2 - Ord(IsNativeStyle));
end;

procedure TcxBoldComboBox.SetDataBinding(
  Value: TcxBoldComboBoxEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxBoldComboBox.SetProperties(Value: TcxBoldComboBoxProperties);
begin
  FProperties.Assign(Value);
end;

function TcxBoldComboBox.SupportsSpelling: Boolean;
begin
  Result := IsTextInputMode;
end;
{
function TcxBoldComboBox.ValidateComponent(
  ComponentValidator: TBoldComponentValidator;
  NamePrefix: string): Boolean;
begin
  result := DataBinding.ValidateComponent(ComponentValidator, NamePrefix);
  result := GetActiveProperties.ValidateComponent(ComponentValidator, NamePrefix) and result;
end;
}
{ TcxBoldSpinEdit }

procedure TcxBoldSpinEdit.DoExit;
begin
  inherited;
  DataBinding.DoExit;
end;

function TcxBoldSpinEdit.GetActiveProperties: TcxSpinEditProperties;
begin
  Result := TcxSpinEditProperties(InternalGetActiveProperties);
end;

function TcxBoldSpinEdit.GetDataBinding: TcxBoldNumericEditDataBinding;
begin
  Result := TcxBoldNumericEditDataBinding(FDataBinding);
end;

class function TcxBoldSpinEdit.GetDataBindingClass: TcxEditDataBindingClass;
begin
  Result := TcxBoldNumericEditDataBinding;
end;

function TcxBoldSpinEdit.GetProperties: TcxSpinEditProperties;
begin
  Result := TcxSpinEditProperties(FProperties);
end;

class function TcxBoldSpinEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxSpinEditProperties;
end;

procedure TcxBoldSpinEdit.Paint;
begin
  inherited Paint;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 2 - Ord(IsNativeStyle));
end;

procedure TcxBoldSpinEdit.SetDataBinding(
  Value: TcxBoldNumericEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxBoldSpinEdit.SetProperties(Value: TcxSpinEditProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxBoldButtonEdit }

procedure TcxBoldButtonEdit.DoExit;
begin
  inherited;
  DataBinding.DoExit;
end;

function TcxBoldButtonEdit.GetActiveProperties: TcxButtonEditProperties;
begin
  Result := TcxButtonEditProperties(InternalGetActiveProperties);
end;

function TcxBoldButtonEdit.GetDataBinding: TcxBoldTextEditDataBinding;
begin
  Result := TcxBoldTextEditDataBinding(FDataBinding);
end;

class function TcxBoldButtonEdit.GetDataBindingClass: TcxEditDataBindingClass;
begin
  Result := TcxBoldTextEditDataBinding;
end;

function TcxBoldButtonEdit.GetProperties: TcxButtonEditProperties;
begin
  Result := TcxButtonEditProperties(FProperties);
end;

class function TcxBoldButtonEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxButtonEditProperties;
end;

procedure TcxBoldButtonEdit.Paint;
begin
  inherited Paint;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 2 - Ord(IsNativeStyle));
end;

procedure TcxBoldButtonEdit.SetDataBinding(
  Value: TcxBoldTextEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxBoldButtonEdit.SetProperties(Value: TcxButtonEditProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxBoldHyperLinkEdit }

procedure TcxBoldHyperLinkEdit.DoExit;
begin
  inherited;
  DataBinding.DoExit;
end;

function TcxBoldHyperLinkEdit.GetActiveProperties: TcxHyperLinkEditProperties;
begin
  Result := TcxHyperLinkEditProperties(InternalGetActiveProperties);
end;

function TcxBoldHyperLinkEdit.GetDataBinding: TcxBoldTextEditDataBinding;
begin
  Result := TcxBoldTextEditDataBinding(FDataBinding);
end;

class function TcxBoldHyperLinkEdit.GetDataBindingClass: TcxEditDataBindingClass;
begin
  Result := TcxBoldTextEditDataBinding;
end;

function TcxBoldHyperLinkEdit.GetProperties: TcxHyperLinkEditProperties;
begin
  Result := TcxHyperLinkEditProperties(FProperties);
end;

class function TcxBoldHyperLinkEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxHyperLinkEditProperties;
end;

procedure TcxBoldHyperLinkEdit.Paint;
begin
  inherited Paint;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 2 - Ord(IsNativeStyle));
end;

procedure TcxBoldHyperLinkEdit.SetDataBinding(
  Value: TcxBoldTextEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxBoldHyperLinkEdit.SetProperties(
  Value: TcxHyperLinkEditProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxBoldProgressBar }

function TcxBoldProgressBar.GetActiveProperties: TcxProgressBarProperties;
begin
  Result := TcxProgressBarProperties(InternalGetActiveProperties);
end;

function TcxBoldProgressBar.GetDataBinding: TcxBoldNumericEditDataBinding;
begin
  Result := TcxBoldNumericEditDataBinding(FDataBinding);
end;

class function TcxBoldProgressBar.GetDataBindingClass: TcxEditDataBindingClass;
begin
  Result := TcxBoldNumericEditDataBinding;
end;

function TcxBoldProgressBar.GetProperties: TcxProgressBarProperties;
begin
  Result := TcxProgressBarProperties(FProperties);
end;

class function TcxBoldProgressBar.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxProgressBarProperties;
end;

procedure TcxBoldProgressBar.Initialize;
begin
  inherited;
  if IsDesigning and not IsLoading then
  begin
    _ValidateEdit(self);
  end;
end;

procedure TcxBoldProgressBar.Paint;
begin
  inherited Paint;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 2 - Ord(IsNativeStyle));
end;

procedure TcxBoldProgressBar.SetDataBinding(
  Value: TcxBoldNumericEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxBoldProgressBar.SetProperties(
  Value: TcxProgressBarProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxBarBoldEditItem }

procedure TcxBarBoldEditItem._AfterMakeUptoDate(Follower: TBoldFollower);
var
  lValue: variant;//string;
  lElement: TBoldElement;
  lIcxBoldEditProperties: IcxBoldEditProperties;  
{$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
begin
//  lValue := BoldProperties.GetCurrentAsVariant(Follower);
  if fInternalChange = 0 then
  begin
  {$IFNDEF AttracsBold}
    if Assigned(Follower.Element) then
    begin
      lGuard := TBoldGuard.Create(lIE);
      lIE := TBoldIndirectElement.Create;
      Follower.Element.EvaluateExpression(TBoldFollowerControllerAccess(Follower.Controller).Expression, lIE, false, TBoldFollowerControllerAccess(Follower.Controller).VariableList);
      lElement := lIE.Value;
    end
    else
      lElement := nil;
  {$ELSE}
    lElement := Follower.ActualElement;
  {$ENDIF}

    if Supports(Properties, IcxBoldEditProperties, lIcxBoldEditProperties) then
    begin
        lValue := lIcxBoldEditProperties.BoldElementToEditValue(Follower, lElement, nil);
    end
    else
    begin
      lValue := TBoldVariantFollowerController(Follower.Controller).GetCurrentAsVariant(Follower);
      if VarIsEmpty(lValue) then
        lValue := Null;
    end;

    inc(fInternalChange);
    try
      if not cxEditVarEquals(EditValue, lValue) then
        EditValue := lValue;
    finally
      dec(fInternalChange);
    end;
  end;
end;

constructor TcxBarBoldEditItem.Create(AOwner: TComponent);
begin
  inherited;
  fBoldProperties := TBoldVariantFollowerController.Create(Self);
  fBoldProperties.AfterMakeUptoDate := _AfterMakeUptoDate;
  fBoldProperties.OnGetContextType := GetContextType;
  fBoldHandleFollower := TBoldElementHandleFollower.Create(Owner, fBoldProperties);
  self.OnExit := EditExit;
end;

destructor TcxBarBoldEditItem.Destroy;
begin
  case BoldProperties.ApplyPolicy of
    bapChange, bapExit: try
      Follower.Apply;
    except
      Follower.DiscardChange;
    end;
    bapDemand: Follower.DiscardChange;
  end;
  FreeAndNil(fBoldHandleFollower);
  FreeAndNil(fBoldProperties);
  inherited;
end;

function TcxBarBoldEditItem.GetBoldHandle: TBoldElementHandle;
begin
  Result := fBoldHandleFollower.BoldHandle;
end;

function TcxBarBoldEditItem.GetContextType: TBoldElementTypeInfo;
begin
  if assigned(BoldHandle) then
    result := BoldHandle.StaticBoldType
  else
    result := nil;
end;

function TcxBarBoldEditItem.GetFollower: TBoldFollower;
begin
  Result := fBoldHandleFollower.Follower;
end;

procedure TcxBarBoldEditItem.SetBoldHandle(
  const Value: TBoldElementHandle);
begin
  fBoldHandleFollower.BoldHandle := value;
end;

procedure TcxBarBoldEditItem.SetBoldProperties(
  const Value: TBoldVariantFollowerController);
begin
  fBoldProperties.Assign(Value);
end;

procedure TcxBarBoldEditItem.EditValueChanged(Sender: TObject);
var
  lIcxBoldEditProperties: IcxBoldEditProperties;
  lDone: Boolean;
  lEdit: TcxCustomEdit;
begin
  if fInternalChange = 0 then
  begin
    lDone := false;
    lEdit := Sender as TcxCustomEdit;
    if Supports(Properties, IcxBoldEditProperties, lIcxBoldEditProperties) then
    begin
      lIcxBoldEditProperties.SetStoredValue(Null, BoldHandle, lEdit, Follower, lDone);
    end;
    if not lDone then
    begin
      if VarIsNull(EditValue) then
        BoldProperties.MayHaveChanged('', Follower)
      else
      BoldProperties.MayHaveChanged(EditValue, Follower);
    end;
    TBoldQueueable.DisplayAll;
  end;
end;

procedure TcxBarBoldEditItem.EditExit(Sender: TObject);
begin
  if (Follower.Controller.ApplyPolicy <> bapDemand) then
    Follower.Apply;
end;

class function TcxCustomBoldTextEditProperties.GetContainerClass: TcxContainerClass;
begin
  result := inherited GetContainerClass;
//  result := TcxBoldTextEdit;
end;

procedure TcxBarBoldEditItem.DoEnter;
begin
  inherited;

end;

procedure TcxBarBoldEditItem.DoExit;
begin
  inherited;
end;

function TcxBarBoldEditItem.GetControlClass(
  AIsVertical: Boolean): TdxBarItemControlClass;
begin
  if AIsVertical then
    Result := inherited GetControlClass(AIsVertical)
  else
    Result := TcxBarBoldEditItemControl;
end;

procedure TcxBarBoldEditItem.KeyPress(var Key: Char);
begin
  inherited;
  if (not Follower.Controller.MayModify(Follower)) or (not BoldProperties.ValidateCharacter(Key, Follower)) then
    Key := #0;
end;

procedure TcxBarBoldEditItemControl.RestoreDisplayValue;
begin
  inherited;
  Properties.ImmediatePost := true;
end;

procedure TcxBarBoldEditItemControl.StoreDisplayValue;
begin
  inherited;
  (Item as TcxBarBoldEditItem).EditValueChanged(Edit);
end;

function TcxCustomBoldTextEditProperties.ValidateComponent(
  ComponentValidator: TBoldComponentValidator;
  NamePrefix: string): Boolean;
var
  lContext: TBoldElementTypeInfo;
  lName: string;
begin
  result := true;
  if (Owner is TComponent) and (TComponent(Owner).Name <> '') then
    lName := TComponent(Owner).Name
  else
    lName := ClassName;
  if Assigned(BoldLookupListHandle) then
  begin
    lContext := GetContextForBoldRowProperties;
    if not Assigned(lContext) then
      BoldLog.LogFmt(sNoContext, [lName])
    else
    begin
      result := ComponentValidator.ValidateExpressionInContext(
        BoldRowProperties.Expression,
        lContext,
        format('%s %s.BoldRowProperties.Expression', [NamePrefix, lName])
        {$IFDEF AttracsBold}, BoldRowProperties.VariableList{$ENDIF}) and result; // do not localize
    end;
  end;
end;

{ TcxBoldDateNavigator }

{$IFDEF DevExScheduler}

procedure TcxBoldDateNavigator._AfterMakeUptoDate(Follower: TBoldFollower);
var
  lValue: variant;//string;
  lElement: TBoldElement;
{$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
  i,j: integer;
  lBoldComponentValidator: TBoldComponentValidator;
begin
  if IsDesigning then
  begin
    lBoldComponentValidator := TBoldComponentValidator.Create;
    try
      ValidateComponent(lBoldComponentValidator, Name);
    finally
      lBoldComponentValidator.free;
    end;
    exit;
  end;
{$IFNDEF AttracsBold}
  if Assigned(Follower.Element) then
  begin
    lGuard := TBoldGuard.Create(lIE);
    lIE := TBoldIndirectElement.Create;
    Follower.Element.EvaluateExpression(TBoldFollowerControllerAccess(Follower.Controller).Expression, lIE, false, TBoldFollowerControllerAccess(Follower.Controller).VariableList);
    lElement := lIE.Value;
  end
  else
    lElement := nil;
{$ELSE}
  lElement := Follower.ActualElement;
{$ENDIF}
  if Assigned(lElement) then
    lValue := lElement.AsVariant
  else
    lValue := Null;
  InnerDateNavigator.EventOperations.ReadOnly := not Assigned(lElement);
  inc(fInternalChange);
  try
    if Follower = StartFollower then
    begin
      if VarIsNull(lValue) or (lValue = 0) then
      begin
        if (self.Date <> NullDate) then
        begin
          SelectedDays.Clear;
          DateNavigator.Refresh;
        end
      end
      else
      begin
        if lValue <> self.Date then
          self.Date := lValue;
      end;
    end
    else
    begin
      if not VarIsNull(lValue) and (lValue <> 0) and (lValue <> RealLastDate) and (self.date <> NullDate) then
      begin
        j := Trunc(self.date);
        SelectedDays.Clear;
        for i := j to lValue do
          SelectedDays.Add(i);
        DateNavigator.Refresh;
      end;
    end;
  finally
    dec(fInternalChange);
  end;
end;

constructor TcxBoldDateNavigator.Create(AOwner: TComponent);
begin
  inherited;
  fBoldStartProperties := TBoldVariantFollowerController.Create(Self);
  fBoldStartProperties.AfterMakeUptoDate := _AfterMakeUptoDate;
  fBoldStartProperties.OnGetContextType := GetStartContextType;

  fBoldEndProperties := TBoldVariantFollowerController.Create(Self);
  fBoldEndProperties.AfterMakeUptoDate := _AfterMakeUptoDate;
  fBoldEndProperties.OnGetContextType := GetEndContextType;

  fBoldStartHandleFollower := TBoldElementHandleFollower.Create(AOwner, fBoldStartProperties);
  fBoldEndHandleFollower := TBoldElementHandleFollower.Create(AOwner, fBoldEndProperties);

  if IsDesigning and not isLoading then
    ValidateSelf;
end;

procedure TcxBoldDateNavigator.DateNavigatorSelectionChanged;
begin
  inherited;
  if (fInternalChange = 0) {and Assigned(Follower) and Follower.Controller.MayModify(Follower)} then
  begin
    if Assigned(StartFollower) and StartFollower.Controller.MayModify(StartFollower) then
      BoldStartProperties.MayHaveChanged(self.date, StartFollower);
    if Assigned(EndFollower) and EndFollower.Controller.MayModify(EndFollower) then
      BoldEndProperties.MayHaveChanged(self.RealLastDate, EndFollower);
  end;
end;

destructor TcxBoldDateNavigator.Destroy;
begin
  case BoldStartProperties.ApplyPolicy of
    bapChange, bapExit: try
      StartFollower.Apply;
    except
      StartFollower.DiscardChange;
    end;
    bapDemand: StartFollower.DiscardChange;
  end;
  case BoldEndProperties.ApplyPolicy of
    bapChange, bapExit: try
      EndFollower.Apply;
    except
      EndFollower.DiscardChange;
    end;
    bapDemand: EndFollower.DiscardChange;
  end;
  FreeAndNil(fBoldStartHandleFollower);
  FreeAndNil(fBoldEndHandleFollower);
  FreeAndNil(fBoldStartProperties);
  FreeAndNil(fBoldEndProperties);
  inherited;
end;


function TcxBoldDateNavigator.GetBoldEndHandle: TBoldElementHandle;
begin
  Result := fBoldEndHandleFollower.BoldHandle;
end;

function TcxBoldDateNavigator.GetEndContextType: TBoldElementTypeInfo;
begin
  if assigned(BoldEndHandle) then
    result := BoldEndHandle.StaticBoldType
  else
    result := nil;
end;

function TcxBoldDateNavigator.GetEndFollower: TBoldFollower;
begin
  result := fBoldEndHandleFollower.Follower;
end;

function TcxBoldDateNavigator.GetBoldStartHandle: TBoldElementHandle;
begin
  Result := fBoldStartHandleFollower.BoldHandle;
end;

function TcxBoldDateNavigator.GetStartContextType: TBoldElementTypeInfo;
begin
  if assigned(BoldStartHandle) then
    result := BoldStartHandle.StaticBoldType
  else
    result := nil;
end;

function TcxBoldDateNavigator.GetStartFollower: TBoldFollower;
begin
  result := fBoldStartHandleFollower.Follower;
end;

procedure TcxBoldDateNavigator.SetBoldEndHandle(
  const Value: TBoldElementHandle);
begin
  fBoldEndHandleFollower.BoldHandle := value;
end;

procedure TcxBoldDateNavigator.SetBoldEndProperties(
  const Value: TBoldVariantFollowerController);
begin
  fBoldEndProperties.Assign(Value);
end;

procedure TcxBoldDateNavigator.SetBoldStartHandle(
  const Value: TBoldElementHandle);
begin
  fBoldStartHandleFollower.BoldHandle := value;
end;

procedure TcxBoldDateNavigator.SetBoldStartProperties(
  const Value: TBoldVariantFollowerController);
begin
  fBoldStartProperties.Assign(Value);
end;

type TcxInnerDateNavigatorAccess = class(TcxInnerDateNavigator);

function TcxBoldDateNavigator.ValidateComponent(
  ComponentValidator: TBoldComponentValidator;
  NamePrefix: string): Boolean;
var
  lContext: TBoldElementTypeInfo;
  lExpressionType: TBoldElementTypeInfo;
  lDateTimeTypeInfo: TBoldAttributeTypeInfo;
  lDateTypeInfo: TBoldAttributeTypeInfo;
begin
  lContext := GetStartContextType;
  result := Assigned(lContext);
  if not result then
  begin
    BoldLog.LogFmt(sNoContext, [Name])
  end
  else
  begin
    with (lContext.SystemTypeInfo as TBoldSystemTypeInfo) do
    begin
      lDateTimeTypeInfo := AttributeTypeInfoByExpressionName['DateTime']; // do not localize
      lDateTypeInfo := AttributeTypeInfoByExpressionName['Date']; // do not localize
    end;
    result := ComponentValidator.ValidateExpressionInContext(
      TBoldFollowerControllerAccess(BoldStartProperties).Expression,
      lContext,
      format('%s %s.Expression', [NamePrefix, Name]),
      BoldStartProperties.VariableList); // do not localize

    if result then
    begin
      lExpressionType := lContext.Evaluator.ExpressionType(TBoldFollowerControllerAccess(BoldStartProperties).Expression, lContext, false, TBoldFollowerControllerAccess(BoldStartProperties).VariableList);
      if not (lExpressionType.ConformsTo(lDateTimeTypeInfo) or lExpressionType.ConformsTo(lDateTypeInfo)) then
      begin
        result := false;
        BoldLog.LogFmt(sPossiblyBadConformance, [lExpressionType.ModelName , lDateTimeTypeInfo.ModelName + ' nor ' + lDateTypeInfo.ModelName]);
      end;
    end;

    lContext := GetEndContextType;
    if Assigned(lContext) then
    begin
      result := ComponentValidator.ValidateExpressionInContext(
        TBoldFollowerControllerAccess(BoldEndProperties).Expression,
        lContext,
        format('%s %s.Expression', [NamePrefix, Name]),
        BoldEndProperties.VariableList) and result; // do not localize

      if result then
      begin
        lExpressionType := lContext.Evaluator.ExpressionType(TBoldFollowerControllerAccess(BoldEndProperties).Expression, lContext, false, TBoldFollowerControllerAccess(BoldEndProperties).VariableList);
        if not (lExpressionType.ConformsTo(lDateTimeTypeInfo) or lExpressionType.ConformsTo(lDateTypeInfo)) then
        begin
          result := false;
          BoldLog.LogFmt(sPossiblyBadConformance, [lExpressionType.ModelName , lDateTimeTypeInfo.ModelName + ' nor ' + lDateTypeInfo.ModelName]);
        end;
      end;
    end;
  end;
end;

procedure TcxBoldDateNavigator.Loaded;
begin
  inherited;
  if IsDesigning then
    ValidateSelf;
end;

procedure TcxBoldDateNavigator.ValidateSelf;
var
  lBoldComponentValidator: TBoldComponentValidator;
begin
  if IsDesigning then
  begin
    lBoldComponentValidator := TBoldComponentValidator.Create;
    try
      ValidateComponent(lBoldComponentValidator, Name);
    finally
      lBoldComponentValidator.free;
    end;
  end;
end;

{$ENDIF}

{ TcxBoldLabel }

function TcxBoldLabel.GetActiveProperties: TcxLabelProperties;
begin
  Result := TcxLabelProperties(InternalGetActiveProperties);
end;

function TcxBoldLabel.GetDataBinding: TcxBoldTextEditDataBinding;
begin
  Result := FDataBinding as TcxBoldTextEditDataBinding;
end;

class function TcxBoldLabel.GetDataBindingClass: TcxEditDataBindingClass;
begin
  Result := TcxBoldTextEditDataBinding;
end;

function TcxBoldLabel.GetProperties: TcxLabelProperties;
begin
  Result := TcxLabelProperties(FProperties);
end;

class function TcxBoldLabel.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxLabelProperties;
end;

procedure TcxBoldLabel.Initialize;
begin
  inherited Initialize;
  if IsDesigning and not IsLoading then
  begin
    _ValidateEdit(self);
  end;
end;

procedure TcxBoldLabel.Paint;
begin
  inherited;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 3);
end;

procedure TcxBoldLabel.SetDataBinding(Value: TcxBoldTextEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxBoldLabel.SetEditAutoSize(Value: Boolean);
begin
  inherited;

end;

procedure TcxBoldLabel.SetProperties(Value: TcxLabelProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxBoldImage }

function TcxBoldImage.GetActiveProperties: TcxImageProperties;
begin
  Result := TcxImageProperties(InternalGetActiveProperties);
end;

function TcxBoldImage.GetDataBinding: TcxBoldBlobEditDataBinding;
begin
  Result := FDataBinding as TcxBoldBlobEditDataBinding;
end;

class function TcxBoldImage.GetDataBindingClass: TcxEditDataBindingClass;
begin
  result := TcxBoldBlobEditDataBinding;
end;

function TcxBoldImage.GetProperties: TcxImageProperties;
begin
  Result := TcxImageProperties(FProperties);
end;

class function TcxBoldImage.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxImageProperties;
end;

procedure TcxBoldImage.Initialize;
begin
  inherited;
  if IsDesigning and not IsLoading then
  begin
    _ValidateEdit(self);
  end;
end;

procedure TcxBoldImage.Paint;
begin
  inherited Paint;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 2 - Ord(IsNativeStyle));
end;

procedure TcxBoldImage.SetDataBinding(Value: TcxBoldBlobEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxBoldImage.SetProperties(Value: TcxImageProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxBoldRichEdit }

procedure TcxBoldRichEdit.EditingChanged;
begin
  inherited;

end;

function TcxBoldRichEdit.GetActiveProperties: TcxRichEditProperties;
begin
  Result := TcxRichEditProperties(InternalGetActiveProperties);
end;

function TcxBoldRichEdit.GetDataBinding: TcxBoldTextEditDataBinding;
begin
  Result := FDataBinding as TcxBoldTextEditDataBinding;
end;

class function TcxBoldRichEdit.GetDataBindingClass: TcxEditDataBindingClass;
begin
  Result := TcxBoldTextEditDataBinding;
end;

function TcxBoldRichEdit.GetProperties: TcxRichEditProperties;
begin
  Result := TcxRichEditProperties(FProperties);
end;

class function TcxBoldRichEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxRichEditProperties;
end;

procedure TcxBoldRichEdit.Paint;
begin
  inherited Paint;
  if DataBinding.ValueOrDefinitionInvalid then
    Canvas.FrameRect(Bounds, clRed, 2 - Ord(IsNativeStyle));
end;

function TcxBoldRichEdit.RealReadOnly: Boolean;
begin
  Result := inherited RealReadOnly or not DataBinding.Editing;
end;

procedure TcxBoldRichEdit.SetDataBinding(
  Value: TcxBoldTextEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxBoldRichEdit.SetProperties(Value: TcxRichEditProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxBoldComboBoxEditDataBinding }

function TcxBoldComboBoxEditDataBinding.GetModified: Boolean;
var
  lItemIndex: integer;
  lCount: integer;
  lOriginalElement, lNewElement: TBoldElement;
  lcxBoldComboBox: TcxBoldComboBox;
{$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
begin
  if not IsDataAvailable or FEdit.ActiveProperties.ReadOnly then
  begin
    result := false;
    exit;
  end;
  result := not cxEditVarEquals(Edit.EditValue, StoredValue); //not ((VarType(Edit.EditValue) = VarType(StoredValue)) and VarSameValue(StoredValue, Edit.EditValue));
  if result and ((VarIsNull(Edit.EditValue) and VarIsStr(StoredValue) and (StoredValue = ''))
    or (VarIsNull(StoredValue) and VarIsStr(Edit.EditValue) and (Edit.EditValue = ''))) then
    result := false;
  begin
    lcxBoldComboBox := Edit as TcxBoldComboBox;
{$IFNDEF AttracsBold}
    if Assigned(lcxBoldComboBox.DataBinding.Follower.Element) then
    begin
      lGuard := TBoldGuard.Create(lIE);
      lIE := TBoldIndirectElement.Create;
      lcxBoldComboBox.DataBinding.Follower.Element.EvaluateExpression(lcxBoldComboBox.DataBinding.BoldProperties.Expression, lIE, false, lcxBoldComboBox.DataBinding.BoldProperties.VariableList);
      lOriginalElement := lIE.Value;
    end
    else
      lOriginalElement := nil;
{$ELSE}
    lOriginalElement := lcxBoldComboBox.DataBinding.Follower.ActualElement;
{$ENDIF}
    if lOriginalElement is TBoldObjectReference then
      lOriginalElement := TBoldObjectReference(lOriginalElement).BoldObject;
    lCount := lcxBoldComboBox.ActiveProperties.LookupListFollower.SubFollowerCount-1;
    lItemIndex := TcxCustomEditListBox(TcxCustomTextEditAccess(Edit).ILookupData.ActiveControl).itemIndex;

    if ((lItemIndex = lCount) and (lcxBoldComboBox.ActiveProperties.BoldLookupListProperties.NilElementMode = neAddLast))
    or ((lItemIndex = 0) and (lcxBoldComboBox.ActiveProperties.BoldLookupListProperties.NilElementMode = neInsertFirst))
    then
    begin
      Result := lOriginalElement <> nil;
      exit;
    end;
    if lItemIndex <> -1 then
    begin
      //  lcxBoldComboBox.ActiveProperties.BoldLookupListProperties.ListIndexToIndex(lItemIndex);
      if (lcxBoldComboBox.ActiveProperties.BoldLookupListProperties.NilElementMode = neInsertFirst) then
        Dec(lItemIndex);
      lNewElement := lcxBoldComboBox.ActiveProperties.BoldLookupListHandle.List[lItemIndex];
      Result := lOriginalElement <> lNewElement;
    end
    else
    begin
      if not ((lcxBoldComboBox.Properties.BoldSelectChangeAction in [bdcsSetValue]) and (lOriginalElement is TBoldAttribute)) then
      result := false;
    end;
  end;
end;

function TcxBoldComboBoxEditDataBinding.ImmediatePost: boolean;
begin
  result := true;
end;

{ TcxBoldIntegerEditDataBinding }

function TcxBoldNumericEditDataBinding.ValidateTypeConforms(
  aExpressionType: TBoldElementTypeInfo): string;
var
  lNumericTypeInfo: TBoldAttributeTypeInfo;
begin
  result := '';
  with (aExpressionType.SystemTypeInfo as TBoldSystemTypeInfo) do
  begin
    lNumericTypeInfo := AttributeTypeInfoByExpressionName['Numeric']; // do not localize
  end;
  if not aExpressionType.ConformsTo(lNumericTypeInfo) then
    result := Format(sPossiblyBadConformance, [aExpressionType.ModelName , lNumericTypeInfo.ModelName]);
end;

{ TcxBoldBlobEditDataBinding }

function TcxBoldBlobEditDataBinding.ValidateTypeConforms(
  aExpressionType: TBoldElementTypeInfo): string;
var
  lBlobTypeInfo: TBoldAttributeTypeInfo;
begin
  result := '';
  with (aExpressionType.SystemTypeInfo as TBoldSystemTypeInfo) do
  begin
    lBlobTypeInfo := AttributeTypeInfoByExpressionName['Blob']; // do not localize
  end;
  if not aExpressionType.ConformsTo(lBlobTypeInfo) then
    result := Format(sPossiblyBadConformance, [aExpressionType.ModelName , lBlobTypeInfo.ModelName]);
end;

{ TcxBoldTimeEditDataBinding }

function TcxBoldTimeEditDataBinding.ValidateTypeConforms(
  aExpressionType: TBoldElementTypeInfo): string;
var
  lDateTimeTypeInfo: TBoldAttributeTypeInfo;
  lTimeTypeInfo: TBoldAttributeTypeInfo;
begin
  result := '';
  with (aExpressionType.SystemTypeInfo as TBoldSystemTypeInfo) do
  begin
    lDateTimeTypeInfo := AttributeTypeInfoByExpressionName['DateTime']; // do not localize
    lTimeTypeInfo := AttributeTypeInfoByExpressionName['Time']; // do not localize
  end;
  if not (aExpressionType.ConformsTo(lDateTimeTypeInfo) or aExpressionType.ConformsTo(lTimeTypeInfo)) then
    result := Format(sPossiblyBadConformance, [aExpressionType.ModelName , lDateTimeTypeInfo.ModelName + ' nor ' + lTimeTypeInfo.ModelName]);
end;

function TcxCustomBoldTextEditProperties.BoldElementToEditValue(
  aFollower: TBoldFollower; aElement: TBoldElement;
  aEdit: TcxCustomEdit): variant;
begin
  result := BoldRowProperties.GetCurrentAsVariant(aFollower);
end;

procedure TcxCustomBoldTextEditProperties.SetBoldSelectChangeAction(
  Value: TBoldComboSelectChangeAction);
begin
  fBoldSelectChangeAction := Value;
end;

procedure TcxCustomBoldTextEditProperties.SetStoredValue(aValue: Variant;
  aBoldHandle: TBoldElementHandle; aEdit: TcxCustomEdit;
  aFollower: TBoldFollower; var aDone: boolean);
var
  LocalSelectedElement: TBoldElement;
  lItemIndex: Integer;
begin
  lItemIndex := -1;
  if Assigned(TcxTextEdit(aEdit).ILookupData) then
    lItemIndex := TcxTextEdit(aEdit).ILookupData.CurrentKey;
  if lItemIndex = -1 then
  begin
    aDone := false;
    exit;
  end
  else
  begin
    LocalSelectedElement := BoldLookupListHandle.List[lItemIndex];
  end;
  InternalComboSetValue(aBoldHandle, aFollower, LocalSelectedElement, BoldSelectChangeAction, BoldSetValueExpression, BoldLookupListHandle);
  aDone := true;
end;

function TcxCustomBoldTextEditProperties.CanEdit(
  aBoldHandle: TBoldElementHandle; aFollower: TBoldFollower): boolean;
begin
  result := true;
end;

procedure TcxCustomBoldTextEditProperties.SetBoldSetValueExpression(
  const Value: TBoldExpression);
begin
  fBoldSetValueExpression := Value;
  if Owner is TcxCustomEdit and (TcxCustomEdit(Owner).IsDesigning) and not (TcxCustomEdit(Owner).IsLoading) then
  begin
    _ValidateEdit(TcxCustomEdit(Owner));
  end;
end;

{ TcxBoldCurrencyEditDataBinding }

function TcxBoldCurrencyEditDataBinding.ValidateTypeConforms(
  aExpressionType: TBoldElementTypeInfo): string;
var
  lCurrencyTypeInfo: TBoldAttributeTypeInfo;
  lFloatTypeInfo: TBoldAttributeTypeInfo;
begin
  result := '';
  with (aExpressionType.SystemTypeInfo as TBoldSystemTypeInfo) do
  begin
    lCurrencyTypeInfo := AttributeTypeInfoByExpressionName['Currency']; // do not localize
    lFloatTypeInfo := AttributeTypeInfoByExpressionName['Float']; // do not localize
  end;
  if not aExpressionType.ConformsTo(lCurrencyTypeInfo) and not aExpressionType.ConformsTo(lFloatTypeInfo) then
    result := Format(sPossiblyBadConformance, [aExpressionType.ModelName , lCurrencyTypeInfo.ModelName]);
end;

{ TcxBoldListBox }

procedure TcxBoldListBox._DeleteItem(Index: Integer;
  OwningFollower: TBoldFollower);
begin
  if not (ListStyle in [lbVirtual, lbVirtualOwnerDraw]) then
    Items.Delete(index);
end;

{$IFNDEF AttracsBold}
procedure TcxBoldListBox._InsertItem(Follower: TBoldFollower);
{$ELSE}
procedure TcxBoldListBox._InsertItem(Index: Integer; Follower: TBoldFollower);
{$ENDIF}
begin
  Assert(Assigned(Follower));
  Follower.EnsureDisplayable;
  if not (ListStyle in [lbVirtual, lbVirtualOwnerDraw]) then
    Items.Insert(Follower.Index, VarToStr(TBoldVariantFollowerController(Follower.Controller).GetCurrentAsVariant(Follower)))
end;

procedure TcxBoldListBox._RowAfterMakeUptoDate(Follower: TBoldFollower);
var
  index: Integer;
  s: string;
begin
  index := Follower.index;
  if (index > -1) and (index < Items.Count) then
  begin
    s := VarToStr(TBoldVariantFollowerController(Follower.Controller).GetCurrentAsVariant(Follower));
    if s <> Items[index] then
      Items[index] := s;
  end;
end;

procedure TcxBoldListBox._AfterMakeUptoDate(Follower: TBoldFollower);
begin
  fBoldRowProperties.AfterMakeUptoDate := _RowAfterMakeUptoDate;
  if not fInternalUpdate then
  begin
    if ListStyle in [lbVirtual, lbVirtualOwnerDraw] then
      Count := self.Follower.SubFollowerCount;
    ItemIndex := Follower.CurrentIndex;
    if MultiSelect then
      ClearSelection;
    if ItemIndex <> -1 then
      Selected[ItemIndex] := true;
  end;
  SyncSelection;
  Items.EndUpdate;
end;

procedure TcxBoldListBox._BeforeMakeUptoDate(Follower: TBoldFollower);
begin
  fBoldRowProperties.AfterMakeUptoDate := nil;
  if assigned(BoldListHandle) and assigned(BoldListHandle.list) then
    BoldListHandle.list.EnsureRange(0, BoldListHandle.list.Count-1);
  Items.BeginUpdate;
end;

function TcxBoldListBox.GetBoldListHandle: TBoldAbstractListHandle;
begin
  Result := fListHandleFollower.BoldHandle;
end;

procedure TcxBoldListBox.SetBoldListHandle(
  const Value: TBoldAbstractListHandle);
begin
  fListHandleFollower.BoldHandle := value;
end;

procedure TcxBoldListBox.SetBoldListProperties(
  const Value: TBoldListAsFollowerListController);
begin
  fBoldListProperties.Assign(Value);
end;

procedure TcxBoldListBox.SetRowProperties(
  const Value: TBoldVariantFollowerController);
begin
  fBoldRowProperties.Assign(Value);
end;

function TcxBoldListBox.GetListFollower: TBoldFollower;
begin
  Result := fListHandleFollower.Follower;
end;

constructor TcxBoldListBox.Create(AOwner: TComponent);
begin
  inherited;
  fBoldRowProperties := TBoldVariantFollowerController.Create(AOwner);
  fBoldRowProperties.AfterMakeUptoDate := _RowAfterMakeUptoDate;
  fBoldRowProperties.OnGetContextType := GetContextForBoldRowProperties;
  fBoldListProperties := TBoldListAsFollowerListController.Create(AOwner, fBoldRowProperties);
  with fBoldListProperties do
  begin
    OnAfterInsertItem := _InsertItem;
    OnAfterDeleteItem := _DeleteItem;
    BeforeMakeUptoDate := _BeforeMakeUptoDate;
    AfterMakeUptoDate := _AfterMakeUptoDate;
  end;
  fListHandleFollower := TBoldListHandleFollower.Create(Owner, fBoldListProperties);
end;

destructor TcxBoldListBox.Destroy;
begin
  FreeAndNil(fListHandleFollower);
  FreeAndNil(fBoldListProperties);
  FreeAndNil(fBoldRowProperties);
  inherited;
end;

function TcxBoldListBox.GetContextForBoldRowProperties: TBoldElementTypeInfo;
begin
  if assigned(BoldListHandle) then
    result := BoldListHandle.StaticBoldType
  else
    result := nil;
end;

function TcxBoldListBox.GetBoldHandleIndexLock: Boolean;
begin
  Result := fListHandleFollower.HandleIndexLock;
end;

procedure TcxBoldListBox.SetBoldHandleIndexLock(const Value: Boolean);
begin
  fListHandleFollower.HandleIndexLock := Value;
end;

procedure TcxBoldListBox.WndProc(var Message: TMessage);
begin
  inherited;
  if (InnerListBox <> nil) and (Message.Msg = WM_COMMAND) and (Message.WParamHi = LBN_SELCHANGE) then
  begin
    fListHandleFollower.SetFollowerIndex(ItemIndex);
    fInternalUpdate := true;
    try
      TBoldQueueable.DisplayAll;
    finally
      fInternalUpdate := false;
    end;
  end;
end;

procedure TcxBoldListBox.DblClick;
var
  lAutoForm: TForm;
  lElement: TBoldElement;
begin
  inherited;
  if fBoldListProperties.DefaultDblClick and
  {$IFDEF AttracsBold}Assigned(Follower.CurrentSubFollower) and Assigned(Follower.CurrentSubFollower.Element){$ELSE}
  (Follower.CurrentIndex <> -1) and Assigned(Follower.SubFollowers[Follower.CurrentIndex]) and Assigned(Follower.SubFollowers[Follower.CurrentIndex].Element){$ENDIF} then
  begin
  {$IFDEF AttracsBold}
    lElement := Follower.CurrentSubFollower.Element;
  {$ELSE}
    lElement := Follower.SubFollowers[Follower.CurrentIndex].Element;
  {$ENDIF}
    lAutoForm := AutoFormProviderRegistry.FormForElement(lElement);
    if assigned(lAutoForm) then
    begin
      lAutoForm.Show;
    end
  end;
end;

function TcxBoldListBox.GetFollower: TBoldFollower;
begin
  result := fListHandleFollower.Follower;
end;

procedure TcxBoldListBox.Loaded;
begin
  inherited;
  Items.Clear;
  DragMode := dmAutomatic;
end;

procedure TcxBoldListBox.DoEndDrag(Target: TObject; X, Y: Integer);
begin
  BoldListProperties.EndDrag;
  inherited DoEndDrag(Target, X, Y);
end;

procedure TcxBoldListBox.DoStartDrag(var DragObject: TDragObject);
begin
  SyncSelection;
  BoldListProperties.StartDrag(Follower);
  inherited DoStartDrag(DragObject);
end;

procedure TcxBoldListBox.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if Assigned(OnDragOver)
    or (BoldListProperties.DropMode = bdpNone)
    or ((Source = Self) and (not BoldListProperties.InternalDrag)) then
    inherited DragOver(Source, X, Y, State, Accept)
  else
    Accept := BoldListProperties.DragOver(Follower, MutableList, ItemAtPos(Point(X, Y), False));
end;

procedure TcxBoldListBox.DragDrop(Source: TObject; X, Y: Integer);
begin
  if Assigned(OnDragDrop) then
  begin
    if BoldGuiHandler.ActivateTargetFormOnDrop then
      BoldGUIHandler.TryToFocusHostingForm(self);
    inherited DragDrop(Source, X, Y);
  end
  else
    BoldListProperties.DragDrop(Follower, MutableList, ItemAtPos(Point(X, Y), False));
end;

function TcxBoldListBox.DrawItem(ACanvas: TcxCanvas; AIndex: Integer;
  const ARect: TRect; AState: TOwnerDrawState): Boolean;
begin
  DefaultSetFontAndColor(AIndex);
  Result := inherited DrawItem(ACanvas, AIndex, ARect, AState);
end;

procedure TcxBoldListBox.DefaultDrawItem(Index: integer; aRect: TRect);
begin
  BoldRowProperties.DrawOnCanvas(Follower.SubFollowers[index], Canvas.Canvas, aRect, taLeftJustify, Point(2,0));
end;

procedure TcxBoldListBox.DefaultSetFontAndColor(Index: integer);
var
  ec: tColor;
  SubFollower: TBoldFollower;
begin
  BoldRowProperties.SetFont(InnerListBox.Canvas.Font, InnerListBox.Canvas.Font, Follower.SubFollowers[index]);
  BoldRowProperties.SetColor(ec, InnerListBox.Canvas.Brush.Color, Follower.SubFollowers[index]);
  InnerListBox.Canvas.Brush.Color := ec;
  SubFollower := Follower.SubFollowers[index];
  if assigned(Subfollower) and Subfollower.Selected then
    with InnerListBox.Canvas do
    begin
      Brush.Color := clHighlight;
      Font.Color := clHighlightText;
    end;
end;

function TcxBoldListBox.GetMutableList: TBoldList;
begin
  if assigned(BoldListHandle) then
    result := BoldListHandle.MutableList
  else
    result := nil;
end;

procedure TcxBoldListBox.SyncSelection;
var
  i: integer;
begin
  BoldListProperties.SelectAll(Follower, False);
  if multiselect then
  begin
    if SelCount > 0 then
    begin
      for i := 0 to Count - 1 do
      begin
        BoldListProperties.SetSelected(Follower, i, Selected[i]);
      end;
    end;
  end
  else
  begin
    if ItemIndex <> -1 then
      BoldListProperties.SetSelected(Follower, ItemIndex, true);
  end;
  if BoldListHandle.CurrentIndex <> ItemIndex then
  begin
    BoldListHandle.CurrentIndex := ItemIndex;
    TBoldQueueable.DisplayAll;
  end;
end;

function TcxBoldListBox.ValidateComponent(
  ComponentValidator: TBoldComponentValidator;
  NamePrefix: string): Boolean;
var
  lContext: TBoldElementTypeInfo;
begin
  result := false;
  lContext := GetContextForBoldRowProperties;
  if assigned(lContext) then
  begin
    result := ComponentValidator.ValidateExpressionInContext(
      BoldRowProperties.Expression,
      lContext,
      format('%s %s.BoldRowProperties.Expression', [NamePrefix, Name]){$IFDEF AttracsBold}, BoldRowProperties.VariableList{$ENDIF}); // do not localize
  end;
end;

{ TcxBoldListView }

procedure TcxBoldListView._BeforeMakeUptoDate(Follower: TBoldFollower);
begin
  // Will fetch all
  if assigned(BoldHandle) and assigned(Boldhandle.list) then
    BoldHandle.list.EnsureRange(0, BoldHandle.list.Count-1);
  Items.BeginUpdate;
end;

procedure TcxBoldListView._AfterMakeUptoDate(Follower: TBoldFollower);
begin
  ItemIndex := Follower.CurrentIndex;
  if ItemIndex = -1 then
    fBoldProperties.SelectAll(Follower, False)
  else
    ;
  Items.EndUpdate;
end;

{$IFNDEF AttracsBold}
procedure TcxBoldListView._InsertItem(Follower: TBoldFollower);
{$ELSE}
procedure TcxBoldListView._InsertItem(Index: Integer; Follower: TBoldFollower);
{$ENDIF}
var
  lItem: TListItem;
{$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
begin
  Assert(Assigned(Follower));
  lItem := Items.Insert(Follower.Index);
{$IFNDEF AttracsBold}
  if assigned(Follower.Element) then
  begin
    lGuard := TBoldGuard.Create(lIE);
    lIE := TBoldIndirectElement.Create;
    Follower.Element.EvaluateExpression(TBoldFollowerControllerAccess(Follower.Controller).Expression, lIE, false, TBoldFollowerControllerAccess(Follower.Controller).VariableList);
    lItem.Caption := lIE.Value.asString;
  end;
{$ELSE}
  lItem.Caption := Follower.ActualElement.AsString;
{$ENDIF}
  lItem.ImageIndex := 0;
end;

procedure TcxBoldListView._DeleteItem(index: Integer;
  OwningFollower: TBoldFollower);
begin
  Items.Delete(index);
end;

procedure TcxBoldListView._RowAfterMakeUptoDate(Follower: TBoldFollower);
{$IFNDEF AttracsBold}
var
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
{$ENDIF}
begin
{$IFNDEF AttracsBold}
  if assigned(Follower.Element) then
  begin
    lGuard := TBoldGuard.Create(lIE);
    lIE := TBoldIndirectElement.Create;
    Follower.Element.EvaluateExpression(TBoldFollowerControllerAccess(Follower.Controller).Expression, lIE, false, TBoldFollowerControllerAccess(Follower.Controller).VariableList);
    Items[Follower.index].Caption := lIE.Value.AsString;
  end;
{$ELSE}
  Items[Follower.index].Caption := Follower.ActualElement.AsString;
{$ENDIF}
end;

function TcxBoldListView.GetBoldHandle: TBoldAbstractListHandle;
begin
  Result := fListHandleFollower.BoldHandle;
end;

function TcxBoldListView.GetBoldHandleIndexLock: Boolean;
begin
  Result := fListHandleFollower.HandleIndexLock;
end;

function TcxBoldListView.GetBoldList: TBoldList;
begin
  //CHECKME We may have to remove this because the list is not necessarily equal with the rendered list!!! /FH
  if Assigned(BoldHandle) then
    Result := BoldHandle.List
  else
    Result := nil;
end;

function TcxBoldListView.GetContextType: TBoldElementTypeInfo;
begin
  if assigned(BoldHandle) then
    result := BoldHandle.StaticBoldType
  else
    result := nil;
end;

function TcxBoldListView.GetCurrentBoldElement: TBoldElement;
var
  Subfollower: TBoldFollower;
begin
  Result := nil;
  if ItemIndex <> -1 then
  begin
    SubFollower := Follower.SubFollowers[ItemIndex];
    if assigned(SubFollower) then
      Result := Subfollower.Element;
  end;
end;

function TcxBoldListView.GetCurrentBoldObject: TBoldObject;
begin
  if CurrentBoldElement is TBoldObject then
    Result := CurrentBoldElement as TBoldObject
  else
    Result := nil;
end;

function TcxBoldListView.GetFollower: TBoldFollower;
begin
  Result := fListHandleFollower.Follower;
end;

procedure TcxBoldListView.SetBoldHandle(value: TBoldAbstractListHandle);
begin
  fListHandleFollower.BoldHandle := value;
end;

procedure TcxBoldListView.SetBoldHandleIndexLock(Value: Boolean);
begin
  fListHandleFollower.HandleIndexLock := Value;
end;

procedure TcxBoldListView.SetBoldProperties(
  Value: TBoldAbstractListAsFollowerListController);
begin
  fBoldProperties.Assign(Value);
end;

procedure TcxBoldListView.SetRowProperties(
 const Value: TBoldVariantFollowerController);
begin
  fBoldRowProperties.Assign(Value);
end;

constructor TcxBoldListView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fBoldRowProperties := TBoldVariantFollowerController.Create(Self);
  fBoldRowProperties.AfterMakeUptoDate := _RowAfterMakeUptoDate;
  fBoldRowProperties.OnGetContextType := GetContextType;
  fBoldProperties := TBoldAbstractListAsFollowerListController.Create(Self, fBoldRowProperties);
  with fBoldProperties do
  begin
    OnAfterInsertItem := _InsertItem;
    OnAfterDeleteItem := _DeleteItem;
    BeforeMakeUptoDate := _BeforeMakeUptoDate;
    AfterMakeUptoDate := _AfterMakeUptoDate;
  end;
  fListHandleFollower := TBoldListHandleFollower.Create(Owner, fBoldProperties);
  DragMode := dmAutomatic;
  ViewStyle := vsIcon;
end;

destructor TcxBoldListView.Destroy;
begin
  FreeAndNil(fListHandleFollower);
  FreeAndNil(fBoldProperties);
  FreeAndNil(fBoldRowProperties);
  inherited Destroy;
end;

{ TcxBoldCustomCheckListBox }

constructor TcxBoldCustomCheckListBox.Create(AOwner: TComponent);
begin
  inherited;
  fBoldRowProperties := TBoldVariantFollowerController.Create(self);
  fBoldRowProperties.OnGetContextType := GetContextType;
  fBoldRowCheckBoxProperties := TBoldCheckBoxStateFollowerController.Create(self);
  fBoldRowCheckBoxProperties.OnGetContextType := GetContextType;

  fControllerList := TBoldControllerList.Create(self);
  fControllerList.Add(fBoldRowCheckBoxProperties);
  fControllerLIst.Add(fBoldRowProperties);

  fBoldRowProperties.AfterMakeUptoDate := _DisplayString;
  fBoldRowCheckBoxProperties.AfterMakeUpToDate := _DisplayCheckBox;

  fBoldListProperties := TBoldAbstractListAsFollowerListController.Create(self, fControllerList);
  fBoldListProperties.OnGetContextType := GetContextType;
  fBoldListProperties.AfterMakeUptoDate := _ListAfterMakeUpToDate;
  fBoldListProperties.BeforeMakeUptoDate := _ListBeforeMakeUpToDate;
  fBoldlistProperties.OnAfterInsertItem := _ListInsertItem;
  fBoldListProperties.OnAfterDeleteItem := _ListDeleteItem;
//  fBoldListProperties.DefaultDblClick := false;
  fListHandleFollower := TBoldListHandleFollower.Create(self, fBoldListProperties);
end;

destructor TcxBoldCustomCheckListBox.Destroy;
begin
  FreeAndNil(fListHandleFollower);
  FreeAndNil(fBoldListProperties);
  FreeAndNil(fControllerList);
  inherited;
end;

function TcxBoldCustomCheckListBox.GetBoldHandleIndexLock: Boolean;
begin
  Result := fListHandleFollower.HandleIndexLock;
end;

function TcxBoldCustomCheckListBox.GetBoldListHandle: TBoldAbstractListHandle;
begin
  Result := fListHandleFollower.BoldHandle;
end;

function TcxBoldCustomCheckListBox.GetContextType: TBoldElementTypeInfo;
begin
  if Assigned(BoldListHandle) then
    result := BoldListHandle.StaticBoldType
  else
    result := nil;
end;

function TcxBoldCustomCheckListBox.GetFollower: TBoldFollower;
begin
  result := fListHandleFollower.Follower;
end;

type
  TcxBoldCustomInnerCheckListBox = class(TcxCustomInnerCheckListBox)
  protected
    procedure DoClickCheck(const AIndex: Integer; const OldState, NewState: TcxCheckBoxState); override;
  end;

{ TcxBoldCustomInnerCheckListBox }

const
  CHECKBOXFOLLOWER_INDEX = 0;
  STRINGFOLLOWER_INDEX = 1;

procedure TcxBoldCustomInnerCheckListBox.DoClickCheck(
  const AIndex: Integer; const OldState, NewState: TcxCheckBoxState);
var
  CheckBoxFollower: TBoldFollower;
  lOwningCheckListBox: TcxBoldCustomCheckListBox;
begin
  lOwningCheckListBox := (fContainer as TcxBoldCustomCheckListBox);
  if not (csDesigning in ComponentState) and (ItemIndex <> - 1) then
  begin
    CheckBoxFollower := lOwningCheckListBox.fListHandleFollower.Follower.SubFollowers[AIndex].SubFollowers[CHECKBOXFOLLOWER_INDEX];
    TBoldCheckBoxStateFollowerController(CheckBoxFollower.Controller).SetAsCheckBoxState(TCheckBoxState(NewState), CheckBoxFollower);
    lOwningCheckListBox.fListHandleFollower.SetFollowerIndex(AIndex);
  end;
  inherited;
end;

function TcxBoldCustomCheckListBox.GetInnerCheckListBoxClass: TcxCustomInnerCheckListBoxClass;
begin
  result := TcxBoldCustomInnerCheckListBox;
end;

procedure TcxBoldCustomCheckListBox.Loaded;
begin
  inherited;
  Items.Clear;
  DragMode := dmAutomatic;
end;

procedure TcxBoldCustomCheckListBox.SetBoldHandleIndexLock(
  const Value: Boolean);
begin
  fListHandleFollower.HandleIndexLock := Value;
end;

procedure TcxBoldCustomCheckListBox.SetBoldListHandle(
  const Value: TBoldAbstractListHandle);
begin
  fListHandleFollower.BoldHandle := value;
end;

procedure TcxBoldCustomCheckListBox.SetBoldListProperties(
  const Value: TBoldAbstractListAsFollowerListController);
begin
  FBoldListProperties.Assign(Value);
end;

procedure TcxBoldCustomCheckListBox.SetBoldRowCheckBoxProperties(
  const Value: TBoldCheckBoxStateFollowerController);
begin
  fBoldRowCheckBoxProperties.Assign(Value);
end;

procedure TcxBoldCustomCheckListBox.SetRowProperties(
  const Value: TBoldVariantFollowerController);
begin
  fBoldRowProperties.Assign(Value);
end;

procedure TcxBoldCustomCheckListBox.SyncSelection;
var
  i: integer;
begin
  BoldListProperties.SelectAll(Follower, False);
  if InnerCheckListBox.multiselect then
  begin
    if InnerCheckListBox.SelCount > 0 then
    begin
      for i := 0 to Count - 1 do
      begin
        BoldListProperties.SetSelected(Follower, i, Selected[i]);
      end;
    end
  end
  else
  begin
    if ItemIndex <> -1 then
      BoldListProperties.SetSelected(Follower, ItemIndex, true)
  end;
end;

procedure TcxBoldCustomCheckListBox.WndProc(var Message: TMessage);
begin
  inherited;
  if (InnerCheckListBox <> nil) and (Message.Msg = WM_COMMAND) and (Message.WParamHi = LBN_SELCHANGE) then
  begin
    fListHandleFollower.SetFollowerIndex(ItemIndex);
    fInternalUpdate := true;
    try
      TBoldQueueable.DisplayAll;
    finally
      fInternalUpdate := false;
    end;
  end;
end;

procedure TcxBoldCustomCheckListBox._DisplayCheckBox(
  Follower: TBoldFollower);
var
  index: integer;
begin
  index := Follower.OwningFollower.index;
  if (index > -1) and (index < Items.Count) then
  begin
    Items[Index].State := TcxCheckBoxState(TBoldCheckBoxStateFollowerController(Follower.Controller).GetCurrentAsCheckBoxState(Follower));
  end;
end;

procedure TcxBoldCustomCheckListBox._DisplayString(
  Follower: TBoldFollower);
var
  index: integer;
begin
  index := Follower.OwningFollower.index;
  if (index > -1) and (index < Items.Count) then
  begin
    Items[Index].Text := VarToStr(TBoldVariantFollowerController(Follower.Controller).GetCurrentAsVariant(Follower));
  end;
end;

procedure TcxBoldCustomCheckListBox._ListAfterMakeUpToDate(
  Follower: TBoldFollower);
var
  lIndex: integer;
begin
  Items.EndUpdate;
  if not fInternalUpdate then
  begin
    lIndex := Follower.CurrentIndex;
    ItemIndex := lIndex;
    if self.InnerCheckListBox.MultiSelect then
      InnerCheckListBox.ClearSelection;
    if lIndex <> -1 then
      Selected[lIndex] := true;
  end;
  SyncSelection;
end;

procedure TcxBoldCustomCheckListBox._ListBeforeMakeUpToDate(
  Follower: TBoldFollower);
begin
  // will fetch all
  if Assigned(BoldListHandle) and Assigned(BoldListHandle.List) then
    BoldListHandle.List.EnsureRange(0, BoldListHandle.List.Count - 1);
  Items.BeginUpdate;
end;

procedure TcxBoldCustomCheckListBox._ListDeleteItem(Index: integer;
  Follower: TBoldFollower);
begin
  Items.Delete(Index);
end;

{$IFNDEF AttracsBold}
procedure TcxBoldCustomCheckListBox._ListInsertItem(Follower: TBoldFollower);
{$ELSE}
procedure TcxBoldCustomCheckListBox._ListInsertItem(Index: Integer; Follower: TBoldFollower);
{$ENDIF}
var
  lCheckListBoxItem: TcxCheckListBoxItem;
begin
  Assert(Assigned(Follower));
  lCheckListBoxItem := Items.Insert(Follower.Index) as TcxCheckListBoxItem;
  if Assigned(Follower) then
  begin
    Follower.EnsureDisplayable;
    {$IFNDEF AttracsBold}
      if Assigned(Follower.Element) then
        lCheckListBoxItem.Text := Follower.Element.EvaluateExpressionAsString(TBoldFollowerControllerAccess(Follower.Controller).Expression, brDefault, false, TBoldFollowerControllerAccess(Follower.Controller).VariableList);
    {$ELSE}
      if Assigned(Follower.ActualElement) then
        lCheckListBoxItem.Text := Follower.ActualElement.AsString;
    {$ENDIF}
  end;
end;

{ TcxBoldSelectionCheckListBox }

constructor TcxBoldSelectionCheckListBox.Create(AOwner: TComponent);
begin
  inherited;
  fPublisher := TBoldPublisher.Create;
  fCheckBoxRenderer := TBoldAsCheckBoxStateRenderer.Create(self);
  fCheckBoxRenderer.OnGetAsCheckBoxState := GetAsCheckBoxState;
  fCheckBoxRenderer.OnSetAsCheckBoxState := SetAsCheckBoxState;
  fCheckBoxRenderer.OnSubscribe := OnSubscribe;
  BoldRowCheckBoxProperties.Renderer := fCheckBoxRenderer;
end;

destructor TcxBoldSelectionCheckListBox.Destroy;
begin
  fPublisher.NotifySubscribersAndClearSubscriptions(self);
  FreeAndNil(fPublisher);
  inherited;
end;

function TcxBoldSelectionCheckListBox.GetAsCheckBoxState(
{$IFNDEF AttracsBold}
  Element: TBoldElement; Representation: TBoldRepresentation; Expression: TBoldExpression
{$ELSE}
  aFollower: TBoldFollower
{$ENDIF}
  ): TCheckBoxState;
begin
  if Assigned(BoldSelectionHandle) then
  begin
{$IFNDEF AttracsBold}
    if (BoldSelectionHandle.List.IndexOf(Element) <> -1 ) then
{$ELSE}
    if (BoldSelectionHandle.List.IndexOf(aFollower.Element) <> -1 ) then
{$ENDIF}
      Result := cbChecked
    else
      Result := cbUnChecked;
   end
   else
     Result := cbGrayed;
end;

procedure TcxBoldSelectionCheckListBox.SetAsCheckBoxState(
{$IFNDEF AttracsBold}
  Element: TBoldElement; newValue: TCheckBoxState; Representation: TBoldRepresentation; Expression: TBoldExpression);
{$ELSE}
  aFollower: TBoldFollower; newValue: TCheckBoxState);
{$ENDIF}
var
  lElement: TBoldElement;
begin
{$IFNDEF AttracsBold}
  lElement := Element;
{$ELSE}
  lElement := aFollower.Element;
{$ENDIF}
  if Assigned(BoldSelectionHandle) then
  begin
    case newValue of
      cbChecked: BoldSelectionHandle.MutableList.Add(lElement);
      cbUnChecked: if (BoldSelectionHandle.List.IndexOf(lElement) <> -1) then BoldSelectionHandle.MutableList.Remove(lElement);
      cbGrayed: ;
    end;
  end;
end;

procedure TcxBoldSelectionCheckListBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = BoldSelectionHandle) and (Operation = opRemove) then
    BoldSelectionHandle := nil;
end;

procedure TcxBoldSelectionCheckListBox.OnSubscribe(
{$IFNDEF AttracsBold}
  Element: TBoldElement; Representation: TBoldRepresentation; Expression: TBoldExpression; Subscriber: TBoldSubscriber);
{$ELSE}
  aFollower: TBoldFollower; Subscriber: TBoldSubscriber);
{$ENDIF}
begin
  if Assigned(BoldSelectionHandle) then
  begin
    BoldSelectionHandle.AddSmallSubscription(Subscriber, [beValueIdentityChanged, beDestroying], breReSubscribe);
    if Assigned(BoldSelectionHandle.List) then
      BoldSelectionHandle.List.DefaultSubscribe(Subscriber);
  end;
  fPublisher.AddSubscription(Subscriber, beSelectionHandleChanged, breReSubscribe);
end;

procedure TcxBoldSelectionCheckListBox.SetSelectionHandle(
  const Value: TBoldAbstractListHandle);
begin
  if (fBoldSelectionHandle <> Value) then
  begin
    fBoldSelectionHandle := Value;
    fPublisher.SendExtendedEvent(self, beSelectionHandleChanged, []);
  end;
end;

function TcxBoldSelectionCheckListBox.ValidateComponent(
  ComponentValidator: TBoldComponentValidator;
  NamePrefix: string): Boolean;
var
  lContext: TBoldElementTypeInfo;
begin
  result := false;
  lContext := GetContextType;
  if assigned(lContext) then
  begin
    result := ComponentValidator.ValidateExpressionInContext(
      BoldRowProperties.Expression,
      lContext,
      format('%s %s.BoldRowProperties.Expression', [NamePrefix, Name]){$IFDEF AttracsBold}, BoldRowProperties.VariableList{$ENDIF}); // do not localize
  end;
end;

{ TcxBoldCheckListBox }

function TcxBoldCheckListBox.ValidateComponent(
  ComponentValidator: TBoldComponentValidator;
  NamePrefix: string): Boolean;
var
  lContext: TBoldElementTypeInfo;
begin
  result := false;
  lContext := GetContextType;
  if assigned(lContext) then
  begin
    result := ComponentValidator.ValidateExpressionInContext(
      BoldRowProperties.Expression,
      lContext,
      format('%s %s.BoldRowProperties.Expression', [NamePrefix, Name]){$IFDEF AttracsBold}, BoldRowProperties.VariableList{$ENDIF}); // do not localize
    result := ComponentValidator.ValidateExpressionInContext(
      BoldRowCheckBoxProperties.Expression,
      lContext,
      format('%s %s.BoldRowProperties.Expression', [NamePrefix, Name]){$IFDEF AttracsBold}, BoldRowCheckBoxProperties.VariableList{$ENDIF}) and result; // do not localize
  end;
end;

initialization
  GetRegisteredEditProperties.Register(TcxBoldTextEditProperties, scxSBoldEditRepositoryTextItem);
  GetRegisteredEditProperties.Register(TcxBoldComboBoxProperties, scxSBoldComboBoxRepositoryTextItem);
  FilterEditsController.Register(TcxBoldTextEditProperties, TcxFilterTextEditHelper);
  FilterEditsController.Register(TcxBoldComboBoxProperties, TcxFilterComboBoxHelper);
  dxBarRegisterItem(TcxBarBoldEditItem, TcxBarEditItemControl, True);


finalization
  FilterEditsController.Unregister(TcxBoldTextEditProperties, TcxFilterTextEditHelper);
  FilterEditsController.Unregister(TcxBoldComboBoxProperties, TcxFilterComboBoxHelper);
  dxBarUnregisterItem(TcxBarBoldEditItem);

end.
