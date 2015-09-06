unit cxGridBoldSupportUnit;

{$ASSERTIONS ON}

{.$DEFINE IEJpegImage}
{.$DEFINE DefaultDragMode}
{.$DEFINE FireAfterLoadOnChangeOnly}
{.$DEFINE BoldDevExLog}


(*
  features
    - on demand fetching
    - optimized to prevent multiple data reloads
    - calling EnsureRange before grid operations that iterate records
    - appropriate column properties for each BoldAttribute, including ComboBoxProperties with possible values for TBAValueSet
    - smart drag & drop support, across views and within single view if list is ordered, etc...
    - constraint column with hints that contain broken constraints messages
    - implements IBoldValidateableComponent
    - global var cxBoldDataSourceClass allows to plugin a custom TcxBoldDataSource subclass

    non bold related features
    - ctrl+home and ctrl+end go to top and bottom of the list, respectively
    - ctrl+numeric plus toggles ApplyBestFit for the visible range of records

  known issues
    - Drag drop is currently not supported in the CardView
    - Master detail views only supported when connected to BoldListHandles
    - TcxGridBoldLayoutView is declared but not implemented

  how to use
    - Make changes to Bold source files as described in documentation
    - If you also patched DevEx source, then add DevExChanges to project conditionals.
*)

interface

uses
  Classes,
  Controls,
  Types,
  Messages,

  cxGridCustomTableView,
  cxCustomData,
  cxGridCustomView,
  cxGridTableView,
  cxStorage,
  cxDataStorage,
  cxData,
  cxDataUtils,
  cxEdit,
  cxDropDownEdit,
  cxGridCardView,
//  cxGridChartView,
  cxGridBandedTableView,
  cxGridLayoutView,
  cxFilter,
  cxGraphics,

  BoldSystem,
  BoldEnvironmentVCL, // Make sure VCL environement loaded, and finalized after
  BoldComponentvalidator,
  BoldSystemRT,
  BoldControlPack,
  BoldVariantControlPack,
  BoldListHandleFollower,
  BoldListListControlPack,
  BoldControllerListControlPack,
  BoldAbstractListHandle,
  BoldElements,
  BoldSubscription,

  cxBoldEditors; // for IcxBoldEditProperties, perhaps extract that class to another unit later on and use that instead

type
  TcxGridBoldTableView = class;
  TcxGridBoldColumn = class;
  TcxGridItemBoldDataBinding = class;
  TcxBoldDataController = class;
  TcxGridBoldDataController = class;
  TcxBoldDataSource = class;
  TcxGridBoldTableController = class;
  TcxGridBoldCardView = class;
(*
  TcxBoldGridChartView = class;
  TcxGridBoldChartDataController = class;
  TcxGridBoldChartCategories = class;
  TcxGridBoldChartDataGroup = class;
  TcxGridBoldChartSeries = class;
*)
  TcxGridBoldBandedTableView = class;
  TcxGridBoldBandedColumn = class;
  TcxGridBoldBandedTableController = class;
  TcxBoldDataControllerSearch = class;
  TcxBoldCustomDataProvider = class;
  TcxGridBoldEditingController = class;

  TcxGridBoldLayoutView = class;
  TcxGridBoldLayoutViewItem = class;

  TBoldCxGridVariantFollowerController = class;

  IBoldAwareViewItem = interface
    ['{187C2B47-FD11-4A01-9340-6BC608B6FF38}']
    function GetBoldProperties: TBoldVariantFollowerController;
    property BoldProperties: TBoldVariantFollowerController read GetBoldProperties;
  end;

  IBoldAwareView = interface
    ['{51A80761-FCA5-4D4E-8585-907B8C08C404}']
    function GetDataController: TcxGridBoldDataController;
    procedure SetDataController(Value: TcxGridBoldDataController);
    property DataController: TcxGridBoldDataController read GetDataController write SetDataController;
    function GetItemCount: Integer;
    property ItemCount: Integer read GetItemCount;
    function GetItem(Index: Integer): IBoldAwareViewItem;
    property Items[Index: Integer]: IBoldAwareViewItem read GetItem; default;
    function GetSelection: TBoldList;
    property Selection: TBoldList read GetSelection;
    procedure DoSelectionChanged;
    procedure ClearItems;

    function GetCurrentBoldObject: TBoldObject;
    function GetCurrentIndex: integer;
    function GetCurrentElement: TBoldElement;

    property CurrentBoldObject: TBoldObject read GetCurrentBoldObject;
    property CurrentElement: TBoldElement read GetCurrentElement;
    property CurrentIndex: integer read GetCurrentIndex;
  end;

  TBoldCxGridVariantFollowerController = class(TBoldVariantFollowerController)
  protected
    cxGridItemBoldDataBinding: TcxGridItemBoldDataBinding;
  public
{$IFDEF AttracsBold}
    function SubFollowersActive: boolean; override;
{$ENDIF}
    constructor Create(aOwningComponent: TComponent); reintroduce;
  end;

  TcxGridBoldDefaultValuesProvider = class(TcxCustomBoldEditDefaultValuesProvider)
  public
    function DefaultCanModify: Boolean; override;
    function IsDisplayFormatDefined(AIsCurrencyValueAccepted: Boolean): Boolean; override;
  end;


  TcxBoldDataSource = class(TcxCustomDataSource)
  private
    fBoldDataController: TcxBoldDataController;
    fIsBoldInitiatedChange: boolean;
  protected
    function GetRecordCount: Integer; override;
    function GetValue(ARecordHandle: TcxDataRecordHandle;
      AItemHandle: TcxDataItemHandle): Variant; override;
    procedure SetValue(ARecordHandle: TcxDataRecordHandle;
      AItemHandle: TcxDataItemHandle; const AValue: Variant); override;
    function GetItemHandle(AItemIndex: Integer): TcxDataItemHandle; override;
    function GetRecordHandle(ARecordIndex: Integer): TcxDataRecordHandle; override;
    function IsRecordIdSupported: Boolean; override;
    function GetRecordId(ARecordHandle: TcxDataRecordHandle): Variant; override;
    function GetDetailHasChildren(ARecordIndex, ARelationIndex: Integer): Boolean; override;
    procedure LoadRecordHandles; override;
  public
    constructor Create(aBoldDataController: TcxBoldDataController); virtual;
    destructor Destroy; override;
    procedure DeleteRecord(ARecordHandle: TcxDataRecordHandle); override;
    {$IFDEF DevExChanges}
    function GetRecordHandleByIndex(ARecordIndex: Integer): TcxDataRecordHandle; override;
    {$ENDIF}
  end;

  TcxGridUserQueryEvent = procedure (Sender: TObject; var Allow: boolean) of object;

  TcxBoldDataController = class(TcxCustomDataController)
  private
    fBoldHandleFollower: TBoldListHandleFollower;
    fBoldProperties: TBoldListAsFollowerListController;
    fBoldColumnsProperties: TBoldControllerList;
    fSubscriber: TBoldPassthroughSubscriber;
    FSkipMakeCellUptoDate: integer;
    FSkipSyncFocusedRecord: integer;
    fCurrentListElementType: TBoldElementTypeInfo;
    fSelection: TBoldList;
    fBoldAutoColumns: Boolean;
    fDataChanged: boolean;
    fInvalidating: boolean;
    fFetchedAll: boolean;
//    fBeforeLoad: TNotifyEvent;
    fAfterLoad: TNotifyEvent;
    fLoadAll: boolean;
    fSkipCancel: boolean;
    fOnDelete: TNotifyEvent;
    fOnInsert: TNotifyEvent;
    fCanInsert: TcxGridUserQueryEvent;
    fCanDelete: TcxGridUserQueryEvent;
    function GetRecNo: Integer;
    procedure SetRecNo(const Value: Integer);
    function GetBoldHandle: TBoldAbstractListHandle;
    function GetBoldHandleIndexLock: Boolean;
    procedure SetBoldHandle(const Value: TBoldAbstractListHandle);
    procedure SetBoldHandleIndexLock(const Value: Boolean);
    procedure SetController(const Value: TBoldListAsFollowerListController);
    function GetRowFollower(DataRow: Integer): TBoldFollower;
    function GetFollower: TBoldFollower;
    function GetCellFollower(ListCol, DataRow: Integer): TBoldFollower;
    function GetSelection: TBoldList;
    function GetBoldList: TBoldList;
    procedure SetDataChanged(const Value: boolean);
    procedure Receive(Originator: TObject; OriginalEvent: TBoldEvent; RequestedEvent: TBoldRequestedEvent);    
  protected
    function GetDataProviderClass: TcxCustomDataProviderClass; override;
    function GetSearchClass: TcxDataControllerSearchClass; override;
    function IsDataLinked: Boolean;
    function IsSmartRefresh: Boolean; override;
    function GetCurrentBoldObject: TBoldObject;
    function GetCurrentIndex: integer;
    function GetCurrentElement: TBoldElement;
    procedure DataChangedEvent(Sender: TObject); virtual;
    function BoldSetValue(AItemHandle: TcxDataItemHandle; ACellFollower: TBoldFollower; const AValue: variant): boolean; virtual;
    function RequiresAllRecords: boolean; overload; virtual;
    function RequiresAllRecords(AItem: TObject): boolean; overload; virtual;
    procedure SelectionChanged; virtual;
    procedure FilterChanged; override;
    function FindItemByData(AData: Integer): TObject;
    function GetItemData(AItem: TObject): Integer; virtual; abstract;
    function BoldPropertiesFromItem(aIndex: integer): TBoldVariantFollowerController;
{$IFNDEF AttracsBold}
    procedure _InsertRow(Follower: TBoldFollower); virtual;
{$ELSE}
    procedure _InsertRow(index: Integer; Follower: TBoldFollower); virtual;
{$ENDIF}
    procedure _DeleteRow(index: Integer; owningFollower: TBoldFollower); virtual;
    procedure _BeforeMakeListUpToDate(Follower: TBoldFollower); virtual;
    procedure _AfterMakeListUptoDate(Follower: TBoldFollower); virtual;
    procedure _AfterMakeCellUptoDate(Follower: TBoldFollower); virtual;
    function GetHandleListElementType: TBoldElementTypeInfo;
    function TypeMayHaveChanged: boolean;
    procedure TypeChanged(aNewType, aOldType: TBoldElementTypeInfo); virtual;
    property BoldHandleIndexLock: Boolean read GetBoldHandleIndexLock write SetBoldHandleIndexLock default true;
    property CellFollowers[ListCol, DataRow: Integer]: TBoldFollower read GetCellFollower;
    property BoldAutoColumns: Boolean read fBoldAutoColumns write fBoldAutoColumns default false;
    property BoldColumnsProperties: TBoldControllerList read fBoldColumnsProperties;
    property DataHasChanged: boolean read fDataChanged write SetDataChanged;
    property SkipMakeCellUptoDate: integer read FSkipMakeCellUptoDate;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function IsProviderMode: Boolean; override;
    function GetRecordCount: Integer; override;
    procedure Cancel; override;
    procedure AdjustActiveRange(aList: TBoldObjectList = nil; aItem: integer = -1); overload; virtual;
    procedure AdjustActiveRange(aRecordIndex: integer; aItem: integer = -1); overload;
    procedure PreFetchColumns(aList: TBoldList = nil; aItem: integer = -1); virtual;
    function GetHandleStaticType: TBoldElementTypeInfo;
    function GetCurrentDetailDataController(ARelationIndex: integer = 0): TcxBoldDataController;
    property BoldProperties: TBoldListAsFollowerListController read fBoldProperties write SetController;
    property BoldHandle: TBoldAbstractListHandle read GetBoldHandle write SetBoldHandle;
    property BoldHandleFollower: TBoldListHandleFollower read fBoldHandleFollower;
    property RecNo: Integer read GetRecNo write SetRecNo; // Sequenced
    property Follower: TBoldFollower read GetFollower;
    property CurrentBoldObject: TBoldObject read GetCurrentBoldObject;
    property CurrentElement: TBoldElement read GetCurrentElement;
    property CurrentIndex: integer read GetCurrentIndex;
//    property OnBeforeLoad: TNotifyEvent read fBeforeLoad write fBeforeLoad;
    property OnAfterLoad: TNotifyEvent read fAfterLoad write fAfterLoad;
    property LoadAll: boolean read fLoadAll write fLoadAll default false;
    property Selection: TBoldList read GetSelection;
    property BoldList: TBoldList read GetBoldList;
  published
    property OnInsert: TNotifyEvent read fOnInsert write fOnInsert;
    property OnDelete: TNotifyEvent read fOnDelete write fOnDelete;
    property CanInsert: TcxGridUserQueryEvent read fCanInsert write fCanInsert;
    property CanDelete: TcxGridUserQueryEvent read fCanDelete write fCanDelete;

  end;

  TcxGridBoldDataController = class(TcxBoldDataController, IcxCustomGridDataController, IcxGridDataController)
  private
    FPrevScrollBarPos: Integer;
    fCreatingColumns: boolean;
    fInternalChange: boolean;
    function GetController: TcxCustomGridTableController;
    function GetGridViewValue: TcxCustomGridTableView;
  protected
    function GetSummaryItemClass: TcxDataSummaryItemClass; override;
    function GetSummaryGroupItemLinkClass: TcxDataSummaryGroupItemLinkClass; override;

    procedure CheckDataSetCurrent; override; // used to get CurrentIndex (ie. current record after change)
    procedure ConstraintColumnCustomDrawCell(Sender: TcxCustomGridTableView;
      ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
    procedure ColumnCustomDrawCell(Sender: TcxCustomGridTableView;
      ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
    procedure GetCellHint(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      ACellViewInfo: TcxGridTableDataCellViewInfo; const AMousePos: TPoint;
      var AHintText: TCaption; var AIsHintMultiLine: Boolean; var AHintTextRect: TRect);
    procedure SelectionChanged; override;

    function DoEditing(AItem: TcxCustomGridTableItem): Boolean;
    function BoldSetValue(AItemHandle: TcxDataItemHandle; ACellFollower: TBoldFollower; const AValue: variant): boolean; override;

    function GetOwnerOrView: TComponent;
    { IcxCustomGridDataController }
    procedure AssignData(ADataController: TcxCustomDataController);
    procedure DeleteAllItems;
    procedure GetFakeComponentLinks(AList: TList);
    function GetGridView: TcxCustomGridView;
    function HasAllItems: Boolean;
    function IsDataChangeable: Boolean;
    function IsDataLinked: Boolean;
    function SupportsCreateAllItems: Boolean;

    { IcxGridDataController }
    procedure CheckGridModeBufferCount;
    function DoScroll(AForward: Boolean): Boolean;
    function DoScrollPage(AForward: Boolean): Boolean;
    //function GetFilterPropertyValue(const AName: string; var AValue: Variant): Boolean;
    function GetItemDataBindingClass: TcxGridItemDataBindingClass;
    function GetItemDefaultValuesProviderClass: TcxCustomEditDefaultValuesProviderClass;
    function GetNavigatorIsBof: Boolean;
    function GetNavigatorIsEof: Boolean;
    function GetScrollBarPos: Integer;
    function GetScrollBarRecordCount: Integer;
    //function SetFilterPropertyValue(const AName: string; const AValue: Variant): Boolean;
    function SetScrollBarPos(Value: Integer): Boolean;

    function SupportsScrollBarParams: Boolean; virtual;
    function GetItemData(AItem: TObject): Integer; override;
    function RequiresAllRecords: boolean; overload; override;
    function RequiresAllRecords(AItem: TObject): boolean; overload; override;
    function CanSelectRow(ARowIndex: Integer): Boolean; override;
    function CompareByField(ARecordIndex1, ARecordIndex2: Integer;
      AField: TcxCustomDataField; AMode: TcxDataControllerComparisonMode): Integer; override;
    procedure DoValueTypeClassChanged(AItemIndex: Integer); override;
    procedure FilterChanged; override;
    function GetDefaultActiveRelationIndex: Integer; override;
    function GetFilterDisplayText(ARecordIndex, AItemIndex: Integer): string; override;
    function GetItemID(AItem: TObject): Integer; override;
//    function GetItemData(AItem: TObject): Integer; virtual;
    function GetSortingBySummaryEngineClass: TcxSortingBySummaryEngineClass; override;
    function InternalCreateItem(aGridView: TcxCustomGridTableView; aExpression: string; aCaption: string; aValueType: string; aName: string): TcxCustomGridTableItem;
    { Bold methods }
    procedure _BeforeMakeListUpToDate(Follower: TBoldFollower); override;
    procedure _AfterMakeListUptoDate(Follower: TBoldFollower); override;
    procedure _AfterMakeCellUptoDate(Follower: TBoldFollower); override;
    procedure TypeChanged(aNewType, aOldType: TBoldElementTypeInfo); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreateAllItems(AMissingItemsOnly: Boolean);
    procedure EnsureConstraintColumn;
    function GetItemByExpression(const AExpression: string): TObject;
    function GetItem(Index: Integer): TObject; override;

    procedure DoStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure DoDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure DoDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure DoEndDrag(Sender, Target: TObject; X, Y: Integer);

    procedure BeginFullUpdate; override;
    procedure EndFullUpdate; override;
    function CreateDetailLinkObject(ARelation: TcxCustomDataRelation;
      ARecordIndex: Integer): TObject; override;
    procedure FocusControl(AItemIndex: Integer; var Done: Boolean); override;
    function GetDetailDataControllerByLinkObject(ALinkObject: TObject): TcxCustomDataController; override;
    function GetDisplayText(ARecordIndex, AItemIndex: Integer): string; override;
    function GetFilterDataValue(ARecordIndex: Integer; AField: TcxCustomDataField): Variant; override;
    function GetFilterItemFieldCaption(AItem: TObject): string; override;
    function GetItemSortByDisplayText(AItemIndex: Integer; ASortByDisplayText: Boolean): Boolean; override;
    function GetItemValueSource(AItemIndex: Integer): TcxDataEditValueSource; override;
    procedure UpdateData; override;

    procedure AdjustActiveRange(aList: TBoldObjectList = nil; aItem: integer = -1); override;
    procedure PreFetchColumns(aList: TBoldList = nil; aItem: integer = -1); override;
//    procedure DoGroupingChanged; override;
//    procedure DoSortingChanged; override;
    // Master-Detail: Grid Notifications
    procedure SetMasterRelation(AMasterRelation: TcxCustomDataRelation; AMasterRecordIndex: Integer); override;
    procedure SetValueTypeAndProperties(aMember: TBoldMemberRtInfo; aItem: TcxCustomGridTableItem; aChangeProperties: boolean = true); overload;
    procedure SetValueTypeAndProperties(aElementTypeInfo: TBoldElementTypeInfo; aItem: TcxCustomGridTableItem; aChangeProperties: boolean = true); overload;
    procedure ForEachRow(ASelectedRows: Boolean; AProc: TcxDataControllerEachRowProc); override;
    property GridView: TcxCustomGridTableView read GetGridViewValue;
    property Controller: TcxCustomGridTableController read GetController;
  published
    property BoldProperties;
    property BoldHandle;
    property BoldHandleIndexLock;
    property BoldAutoColumns;
//    property OnBeforeLoad;
    property OnAfterLoad;
    property LoadAll;

    property Filter;
    property Options;
    property Summary;
    property OnAfterCancel;
    property OnAfterDelete;
    property OnAfterInsert;
    property OnAfterPost;
    property OnBeforeCancel;
    property OnBeforeDelete;
    property OnBeforeInsert;
    property OnBeforePost;
    property OnNewRecord;
    property OnCompare;
    property OnDataChanged;
    property OnDetailCollapsing;
    property OnDetailCollapsed;
    property OnDetailExpanding;
    property OnDetailExpanded;
    property OnFilterRecord;
    property OnGroupingChanged;
    property OnRecordChanged;
    property OnSortingChanged;
  end;

  TcxGridItemBoldDataBinding = class(TcxGridItemDataBinding)
  private
    fBoldProperties: TBoldVariantFollowerController;
    fSubscriber: TBoldPassthroughSubscriber;
    procedure Receive(Originator: TObject; OriginalEvent: TBoldEvent; RequestedEvent: TBoldRequestedEvent);
    function GetDataController: TcxGridBoldDataController;
    function GetBoldProperties: TBoldVariantFollowerController;
    procedure SetBoldProperties(Value: TBoldVariantFollowerController);
  protected
    function GetDefaultValueTypeClass: TcxValueTypeClass; override;
    procedure Init; override;
    procedure Remove;
  public
    constructor Create(AItem: TcxCustomGridTableItem); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    {$IFDEF DevExChanges}
    procedure GetFilterValues(AValueList: TcxGridFilterValueList; AValuesOnly: Boolean = True;
      AInitSortByDisplayText: Boolean = False; ACanUseFilteredValues: Boolean = False); override;
    {$ENDIF}
    property DataController: TcxGridBoldDataController read GetDataController;
  published
    property BoldProperties: TBoldVariantFollowerController read GetBoldProperties write SetBoldProperties;
  end;

  TcxGridBoldColumn = class(TcxGridColumn, IBoldAwareViewItem, IcxStoredObject)
  private
    function GetDataBinding: TcxGridItemBoldDataBinding;
    procedure SetDataBinding(Value: TcxGridItemBoldDataBinding);
  protected
    // IcxStoredObject
    function GetProperties(AProperties: TStrings): Boolean;
    procedure GetPropertyValue(const AName: string; var AValue: Variant); override;
    procedure SetPropertyValue(const AName: string; const AValue: Variant); override;
    function CalculateBestFitWidth: Integer; override;
    procedure VisibleChanged; override;
  public
    destructor Destroy; override;
  published
    property DataBinding: TcxGridItemBoldDataBinding read GetDataBinding write SetDataBinding implements IBoldAwareViewItem;
  end;

  TcxBoldDataControllerSearch = class(TcxDataControllerSearch)
  public
  // the sole purpose of these overrides is to ensure range (fetch in 1 pass)
    function Locate(AItemIndex: Integer; const ASubText: string; AIsAnywhere: Boolean = False): Boolean; override;
    function LocateNext(AForward: Boolean; AIsAnywhere: Boolean = False): Boolean; override;
  end;

  TcxGridBoldCardsViewInfo = class(TcxGridCardsViewInfo)
  protected
    procedure CalculateVisibleCount; override;
  end;

  TcxGridBoldCardViewViewInfo = class(TcxGridCardViewViewInfo)
  protected
    function GetRecordsViewInfoClass: TcxCustomGridRecordsViewInfoClass; override;
  end;

  TcxGridBoldCardView = class(TcxGridCardView, IBoldAwareView, IBoldValidateableComponent)
  private
    function GetDataController: TcxGridBoldDataController;
    procedure SetDataController(Value: TcxGridBoldDataController);
    // IBoldValidateableComponent
    function ValidateComponent(ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean;
    // IBoldAwareView
    function GetItemCount: Integer;
    function GetItem(Index: Integer): IBoldAwareViewItem;
    function GetSelection: TBoldList;
    function GetCurrentBoldObject: TBoldObject;
    function GetCurrentIndex: integer;
    function GetCurrentElement: TBoldElement;
  protected
    function GetDataControllerClass: TcxCustomDataControllerClass; override;
    function GetControllerClass: TcxCustomGridControllerClass; override;
    function GetItemClass: TcxCustomGridTableItemClass; override;
    function DoEditing(AItem: TcxCustomGridTableItem): Boolean; override;
    function DoCellDblClick(ACellViewInfo: TcxGridTableDataCellViewInfo;
      AButton: TMouseButton; AShift: TShiftState): Boolean; override;
    procedure DoSelectionChanged; override;
    function GetViewInfoClass: TcxCustomGridViewInfoClass; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Items[Index: Integer]: IBoldAwareViewItem read GetItem; default;
    property ItemCount: Integer read GetItemCount;
    property Selection: TBoldList read GetSelection;
    property CurrentBoldObject: TBoldObject read GetCurrentBoldObject;
    property CurrentElement: TBoldElement read GetCurrentElement;
    property CurrentIndex: integer read GetCurrentIndex;
  published
    property DataController: TcxGridBoldDataController read GetDataController write SetDataController;
  end;

  TcxGridBoldCardViewRow = class(TcxGridCardViewRow, IBoldAwareViewItem)
  private
    function GetDataBinding: TcxGridItemBoldDataBinding;
    procedure SetDataBinding(Value: TcxGridItemBoldDataBinding);
  protected
    // IcxStoredObject
    {function GetStoredProperties(AProperties: TStrings): Boolean; override;
    procedure GetPropertyValue(const AName: string; var AValue: Variant); override;
    procedure SetPropertyValue(const AName: string; const AValue: Variant); override;}
    function CalculateBestFitWidth: Integer; override;
    procedure VisibleChanged; override;
  public
    destructor Destroy; override;
  published
    property DataBinding: TcxGridItemBoldDataBinding read GetDataBinding write SetDataBinding implements IBoldAwareViewItem;
  end;
(*
  TcxGridBoldChartDataController = class(TcxBoldDataController, {TcxGridBoldDataController} IcxCustomGridDataController,
    IcxGridChartViewItemsProvider)
  private
    { IcxGridChartViewItemsProvider }
    function IcxGridChartViewItemsProvider.GetItem = GetChartItem;
    function GetChartItem(AItemClass: TcxGridChartItemClass; AIndex: Integer): TcxGridChartItem;
    procedure GetItemCaptions(AItemClass: TcxGridChartItemClass; ACaptions: TStringList);
    procedure InitItem(AItem: TcxGridChartItem; AIndex: Integer);
    procedure GetValidValueFields(AItemClass: TcxGridChartItemClass; AFields: TList);
    { IcxCustomGridDataController }
    procedure AssignData(ADataController: TcxCustomDataController);
    procedure CreateAllItems(AMissingItemsOnly: Boolean);
    procedure DeleteAllItems;
    procedure GetFakeComponentLinks(AList: TList);
    function HasAllItems: Boolean;
    function IsDataChangeable: Boolean;
    function SupportsCreateAllItems: Boolean;
  published
    property Options;
//    property OnAfterSummary: TcxAfterSummaryEvent read GetOnAfterSummary write SetOnAfterSummary;
    property OnCompare;
    property OnDataChanged;
    property OnFilterRecord;
//    property OnSummary: TcxSummaryEvent read GetOnSummary write SetOnSummary;
  end;

  TcxGridBoldChartItemDataBinding = class(TcxGridChartItemDataBinding)
  private
    fBoldProperties: TBoldVariantFollowerController;
    procedure SetBoldProperties(Value: TBoldVariantFollowerController);
    function GetDataController: TcxGridBoldChartDataController;
  public
    constructor Create(AGridView: TcxGridChartView; AIsValue: Boolean;
      ADefaultValueTypeClass: TcxValueTypeClass); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property DataController: TcxGridBoldChartDataController read GetDataController;
    property BoldProperties: TBoldVariantFollowerController read fBoldProperties write SetBoldProperties;
  end;

  TcxGridBoldChartCategories = class(TcxGridChartCategories)
  private
    function GetDataBinding: TcxGridBoldChartItemDataBinding;
    procedure SetDataBinding(Value: TcxGridBoldChartItemDataBinding);
  published
    property DataBinding: TcxGridBoldChartItemDataBinding read GetDataBinding write SetDataBinding;
  end;

  TcxGridBoldChartDataGroup = class(TcxGridChartDataGroup)
  private
    function GetDataBinding: TcxGridBoldChartItemDataBinding;
    procedure SetDataBinding(Value: TcxGridBoldChartItemDataBinding);
  published
    property DataBinding: TcxGridBoldChartItemDataBinding read GetDataBinding write SetDataBinding;
  end;

  TcxGridBoldChartSeries = class(TcxGridChartSeries)
  private
    function GetDataBinding: TcxGridBoldChartItemDataBinding;
    procedure SetDataBinding(Value: TcxGridBoldChartItemDataBinding);
  published
    property DataBinding: TcxGridBoldChartItemDataBinding read GetDataBinding write SetDataBinding;
  end;

  TcxBoldGridChartView = class(TcxGridChartView, IBoldAwareView, IBoldValidateableComponent)
  private
    function GetCategories: TcxGridBoldChartCategories;
    function GetDataController: TcxGridBoldChartDataController;
    function GetDataGroup(Index: Integer): TcxGridBoldChartDataGroup;
    function GetSeries(Index: Integer): TcxGridBoldChartSeries;
    procedure SetCategories(Value: TcxGridBoldChartCategories);
    procedure SetDataController(Value: TcxGridBoldChartDataController);
    procedure SetDataGroup(Index: Integer; Value: TcxGridBoldChartDataGroup);
    procedure SetSeries(Index: Integer; Value: TcxGridBoldChartSeries);
    procedure ClearItems;
    // IBoldValidateableComponent
    function ValidateComponent(ComponentValidator: TBoldComponentValidator; NamePrefix: String): Boolean;
    // IBoldAwareView
    function GetItemCount: Integer;
    function GetItem(Index: Integer): IBoldAwareViewItem;
    function GetSelection: TBoldList;
    property Selection: TBoldList read GetSelection;
  protected
    function GetCategoriesClass: TcxGridChartCategoriesClass; override;
    function GetDataControllerClass: TcxCustomDataControllerClass; override;
    function GetItemDataBindingClass: TcxGridChartItemDataBindingClass; override;

    function FindItemByFieldName(AItemClass: TcxGridChartItemClass; const AFieldName: string): TcxGridChartItem;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Items[Index: Integer]: IBoldAwareViewItem read GetItem; default;
    property ItemCount: Integer read GetItemCount;

    function CreateDataGroup: TcxGridBoldChartDataGroup;
    function FindDataGroupByFieldName(const AFieldName: string): TcxGridBoldChartDataGroup;
    function GetDataGroupClass: TcxGridChartDataGroupClass; override;
    property DataGroups[Index: Integer]: TcxGridBoldChartDataGroup read GetDataGroup write SetDataGroup;

    function CreateSeries: TcxGridBoldChartSeries;
    function FindSeriesByFieldName(const AFieldName: string): TcxGridBoldChartSeries;
    function GetSeriesClass: TcxGridChartSeriesClass; override;
    property Series[Index: Integer]: TcxGridBoldChartSeries read GetSeries write SetSeries;
  published
    property Categories: TcxGridBoldChartCategories read GetCategories write SetCategories;
    property DataController: TcxGridBoldChartDataController read GetDataController write SetDataController;
  end;
*)

  TcxGridBoldBandedColumn = class(TcxGridBandedColumn, IBoldAwareViewItem {,IcxStoredObject})
  private
    function GetDataBinding: TcxGridItemBoldDataBinding;
    procedure SetDataBinding(Value: TcxGridItemBoldDataBinding);
//    procedure HyperLinkClick(Sender: TObject);
  protected
    // IcxStoredObject
//    function GetProperties(AProperties: TStrings): Boolean;
//    procedure GetPropertyValue(const AName: string; var AValue: Variant); override;
//    procedure SetPropertyValue(const AName: string; const AValue: Variant); override;
    function CalculateBestFitWidth: Integer; override;
    procedure VisibleChanged; override;
  public
    destructor Destroy; override;
  published
    property DataBinding: TcxGridItemBoldDataBinding read GetDataBinding write SetDataBinding implements IBoldAwareViewItem;
  end;

  TcxGridBoldBandedRowsViewInfo = class(TcxGridBandedRowsViewInfo)
  protected
    procedure CalculateVisibleCount; override;
  end;

  TcxGridBoldBandedTableViewInfo = class(TcxGridBandedTableViewInfo)
  protected
    function GetRecordsViewInfoClass: TcxCustomGridRecordsViewInfoClass; override;
  end;

  TcxGridBoldBandedTableView = class(TcxGridBandedTableView, IBoldAwareView, IBoldValidateableComponent)
  private
    procedure HookDragDrop;
    function GetDataController: TcxGridBoldDataController;
    procedure SetDataController(Value: TcxGridBoldDataController);
    // IBoldValidateableComponent
    function ValidateComponent(ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean;
    // IBoldAwareView
    function GetItemCount: Integer;
    function GetItem(Index: Integer): IBoldAwareViewItem;
    function GetSelection: TBoldList;
    function GetCurrentBoldObject: TBoldObject;
    function GetCurrentIndex: integer;
    function GetCurrentElement: TBoldElement;
  protected
    function GetDataControllerClass: TcxCustomDataControllerClass; override;
    function GetControllerClass: TcxCustomGridControllerClass; override;
    function GetItemClass: TcxCustomGridTableItemClass; override;
    function DoCellDblClick(ACellViewInfo: TcxGridTableDataCellViewInfo;
      AButton: TMouseButton; AShift: TShiftState): Boolean; override;
    function DoEditing(AItem: TcxCustomGridTableItem): Boolean; override;
    procedure DoSelectionChanged; override;
    function GetViewInfoClass: TcxCustomGridViewInfoClass; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Items[Index: Integer]: IBoldAwareViewItem read GetItem; default;
    property ItemCount: Integer read GetItemCount;
    property Selection: TBoldList read GetSelection;
    property CurrentBoldObject: TBoldObject read GetCurrentBoldObject;
    property CurrentElement: TBoldElement read GetCurrentElement;
    property CurrentIndex: integer read GetCurrentIndex;
  published
    property DataController: TcxGridBoldDataController read GetDataController write SetDataController;
  end;

  TLinkClickEvent = procedure(Sender: TObject; aElement: TBoldElement) of object;

  TcxBoldGridRowsViewInfo = class(TcxGridRowsViewInfo)
  protected
    procedure CalculateVisibleCount; override;
  end;

  TcxGridBoldTableViewInfo = class(TcxGridTableViewInfo)
  protected
    function GetRecordsViewInfoClass: TcxCustomGridRecordsViewInfoClass; override;
  end;

  TcxGridBoldTableView = class(TcxGridTableView, IBoldAwareView, IBoldValidateableComponent)
  private
    fOnLinkClick: TLinkClickEvent;
    procedure HookDragDrop;
    function GetDataController: TcxGridBoldDataController;
    procedure SetDataController(Value: TcxGridBoldDataController);
    function GetSelection: TBoldList;
    function GetCurrentBoldObject: TBoldObject;
    function GetCurrentIndex: integer;
    function GetCurrentElement: TBoldElement;
    // IBoldValidateableComponent
    function ValidateComponent(ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean;
    // IBoldAwareView
    function GetItemCount: Integer;
    function GetItem(Index: Integer): IBoldAwareViewItem;
    function GetFake: TNotifyEvent;
    procedure SetFake(const Value: TNotifyEvent);
  protected
    function GetDataControllerClass: TcxCustomDataControllerClass; override;
    function GetControllerClass: TcxCustomGridControllerClass; override;
    function GetItemClass: TcxCustomGridTableItemClass; override;
    function DoEditing(AItem: TcxCustomGridTableItem): Boolean; override;
    procedure DoEditKeyPress(AItem: TcxCustomGridTableItem; AEdit: TcxCustomEdit;
      var Key: Char); override;
    function DoCellDblClick(ACellViewInfo: TcxGridTableDataCellViewInfo;
      AButton: TMouseButton; AShift: TShiftState): Boolean; override;
    procedure DoSelectionChanged; override;
    function GetViewInfoClass: TcxCustomGridViewInfoClass; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Items[Index: Integer]: IBoldAwareViewItem read GetItem; default;
    property ItemCount: Integer read GetItemCount;
    property Selection: TBoldList read GetSelection;
    property CurrentBoldObject: TBoldObject read GetCurrentBoldObject;
    property CurrentElement: TBoldElement read GetCurrentElement;
    property CurrentIndex: integer read GetCurrentIndex;
  published
    property DataController: TcxGridBoldDataController read GetDataController write SetDataController;
    property DragMode;
    property OnDelete: TNotifyEvent read GetFake write SetFake;
    property OnInsert: TNotifyEvent read GetFake write SetFake;

    property OnLinkClick: TLinkClickEvent read fOnLinkClick write fOnLinkClick;
  end;

  TcxGridBoldLayoutView = class(TcxGridLayoutView, IBoldAwareView, IBoldValidateableComponent)
  private
    function GetDataController: TcxGridBoldDataController;
//    function GetItem(Index: Integer): TcxGridBoldLayoutViewItem;
    procedure SetDataController(Value: TcxGridBoldDataController);
//    procedure SetItem(Index: Integer; Value: TcxGridBoldLayoutViewItem);
    // IBoldValidateableComponent
    function ValidateComponent(ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean;
    // IBoldAwareView
    function GetItemCount: Integer;
    function GetItem(Index: Integer): IBoldAwareViewItem;
    function GetSelection: TBoldList;
    function GetCurrentBoldObject: TBoldObject;
    function GetCurrentIndex: integer;
    function GetCurrentElement: TBoldElement;
  protected
    function GetDataControllerClass: TcxCustomDataControllerClass; override;
    function GetItemClass: TcxCustomGridTableItemClass; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CreateItem: TcxGridBoldLayoutViewItem;
//    property Items[Index: Integer]: TcxGridBoldLayoutViewItem read GetItem write SetItem;
    property Items[Index: Integer]: IBoldAwareViewItem read GetItem; default;
    property ItemCount: Integer read GetItemCount;
    property Selection: TBoldList read GetSelection;
    property CurrentBoldObject: TBoldObject read GetCurrentBoldObject;
    property CurrentElement: TBoldElement read GetCurrentElement;
    property CurrentIndex: integer read GetCurrentIndex;
  published
    property DataController: TcxGridBoldDataController read GetDataController write SetDataController;
  end;

  TcxGridBoldLayoutViewItem = class(TcxGridLayoutViewItem, IBoldAwareViewItem)
  private
    function GetDataBinding: TcxGridItemBoldDataBinding;
    procedure SetDataBinding(Value: TcxGridItemBoldDataBinding);
  public
    destructor Destroy; override;    
  published
    property DataBinding: TcxGridItemBoldDataBinding read GetDataBinding write SetDataBinding implements IBoldAwareViewItem;
  end;


  TcxBoldCustomDataProvider = class(TcxCustomDataProvider)
  protected
    function GetValue(ARecordIndex: Integer; AField: TcxCustomDataField): Variant; override;
    procedure SetValue(ARecordIndex: Integer; AField: TcxCustomDataField; const Value: Variant); override;
    function CanInsert: Boolean; override;
    function CanDelete: Boolean; override;
    procedure DeleteRecords(AList: TList); override;
    function SetEditValue(ARecordIndex: Integer; AField: TcxCustomDataField; const AValue: Variant; AEditValueSource: TcxDataEditValueSource): Boolean; override;
  end;

  TcxGridBoldTableController = class(TcxGridTableController)
  protected
{    procedure FocusedRecordChanged(APrevFocusedRecordIndex, AFocusedRecordIndex,
      APrevFocusedDataRecordIndex, AFocusedDataRecordIndex: Integer;
      ANewItemRecordFocusingChanged: Boolean); override;
}
    function GetEditingControllerClass: TcxGridEditingControllerClass; override;
  public
    procedure WndProc(var Message: TMessage); override;
    procedure DoKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  end;

  TcxGridBoldBandedTableController = class(TcxGridBandedTableController)
  protected
    function GetEditingControllerClass: TcxGridEditingControllerClass; override;
  public
    procedure WndProc(var Message: TMessage); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  end;

  TcxGridBoldEditingController = class(TcxGridTableEditingController)
  protected
    procedure DoEditKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure EditChanged(Sender: TObject); override;
    procedure EditExit(Sender: TObject); override;
  public
    procedure HideEdit(Accept: Boolean); override;
  end;

  TcxGridBoldCardViewController = class(TcxGridCardViewController)
  protected
    function GetEditingControllerClass: TcxGridEditingControllerClass; override;
//    procedure DoEditKeyDown(var Key: Word; Shift: TShiftState); override;
//    procedure EditChanged(Sender: TObject); override;
  public
    procedure WndProc(var Message: Messages.TMessage); override;
  end;

  TcxGridBoldCardEditingController = class(TcxGridEditingController)
  protected
//    procedure DoEditKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure EditChanged(Sender: TObject); override;
//    procedure EditExit(Sender: TObject); override;
  public
//    procedure HideEdit(Accept: Boolean); override;
  end;


  TcxBoldDataSourceClass = class of TcxBoldDataSource;
{$IFDEF BoldDevExLog}
  TcxBoldGridLogProc = procedure(aMessage: string; aCategory: string = '') of object;
{$ENDIF}

var
  cxBoldDataSourceClass: TcxBoldDataSourceClass = TcxBoldDataSource;
{$IFDEF BoldDevExLog}
  cxBoldGridLogProc: TcxBoldGridLogProc;
{$ENDIF}

{$IFDEF BoldDevExLog}
procedure _Log(aMessage: string; aCategory: string = '');
{$ENDIF}

implementation

uses
  Dialogs,
  Forms,
  Graphics,
  Math,
  SysUtils,
  Variants,
  Windows,

  BoldAFP,
  BoldAttributes,
  BoldCommonBitmaps,
  BoldControlPackDefs,
  BoldDefs,
  BoldDerivedValueSet,
  BoldElementList,
  BoldEnvironment,
  BoldGui,
  BoldId,
  BoldListControlPack,
  BoldListHandle,
  BoldMLAttributes,
  BoldOcl,
  BoldQueue,
  BoldReferenceHandle,
  BoldSystemPersistenceHandler,

  cxCalendar,
  cxCheckBox,
  cxClasses,
  cxControls,
  cxCurrencyEdit,
  cxFilterConsts,
  cxFilterControlUtils,
  cxGridCommon,
  cxGridLevel,
  cxGridRows,
  cxHyperLinkEdit,
  cxImage,
  cxSpinEdit,
  cxTextEdit,
  cxTimeEdit,

{$IFNDEF DESIGNONLY}
{$IFDEF AttracsBold}
  AttracsSpanFetchManager,
{$ENDIF}
{$ENDIF}
  BoldGuard;

const
  cOCLConstraint = 'constraints->select(c|not c)->size = 0';

type
  EcxGridBoldSupport = class(Exception);

  TcxCustomDataControllerAccess = class(TcxCustomDataController);
  TBoldListHandleFollowerAccess = class(TBoldListHandleFollower);
  TBoldFollowerAccess = class(TBoldFollower);
  TBoldFollowerControllerAccess = class(TBoldFollowerController);
  TcxCustomGridTableItemAccess = class(TcxCustomGridTableItem);
  TcxGridLevelAccess = class(TcxGridLevel);
  TcxCustomDataProviderAccess = class(TcxCustomDataProvider);
  TcxCustomGridRecordAccess = class(TcxCustomGridRecord);


{$IFDEF BoldDevExLog}
procedure _Log(aMessage: string; aCategory: string = '');
begin
  if Assigned(cxBoldGridLogProc) then
    cxBoldGridLogProc(aMessage, aCategory);
end;
{$ENDIF}

function InternalSetValue(aFollower: TBoldFollower; const AValue: Variant): boolean;
var
  lController: TBoldVariantFollowerController;
begin
  result := false;
  lController := aFollower.Controller as TBoldVariantFollowerController;
  if VarIsNull(aValue) then
    lController.MayHaveChanged('', aFollower)
  else
    lController.MayHaveChanged(aValue, aFollower);
end;

{ TcxGridBoldDataController }

procedure TcxGridBoldDataController.SetValueTypeAndProperties(
  aElementTypeInfo: TBoldElementTypeInfo; aItem: TcxCustomGridTableItem;
  aChangeProperties: boolean);
var
  lAttributeClass: TClass;
  lValueType: string;
  lBAValueSet: TBAValueSet;
  lBoldAttributeTypeInfo: TBoldAttributeTypeInfo;
  i: integer;
begin
  lValueType := 'String';
  if aElementTypeInfo is TBoldAttributeTypeInfo then
  begin
    lBoldAttributeTypeInfo := TBoldAttributeTypeInfo(aElementTypeInfo);
    lAttributeClass := lBoldAttributeTypeInfo.AttributeClass;
    if not Assigned(lAttributeClass) then
    begin
      raise EcxGridBoldSupport.Create('Custom attribute ' + aElementTypeInfo.ModelName + ' is not installed in IDE.');
    end;
    // Blob, ValueSet and Associations map to string
    if lAttributeClass.InheritsFrom(TBAString) then
    begin
      lValueType := 'String';
      if aChangeProperties then
        aItem.PropertiesClass := TcxTextEditProperties;
    end
    else
      if lAttributeClass.InheritsFrom(TBATime) then
      begin
        lValueType := 'DateTime';
        if aChangeProperties then
        begin
          aItem.PropertiesClass := TcxTimeEditProperties;
          (aItem.Properties as TcxTimeEditProperties).Alignment.Horz := taRightJustify;
        end;
      end
      else
        if lAttributeClass.InheritsFrom(TBAMoment) then
        begin
          lValueType := 'DateTime';
          if aChangeProperties then
          begin
            aItem.PropertiesClass := TcxDateEditProperties;
            (aItem.Properties as TcxDateEditProperties).Alignment.Horz := taRightJustify;
          end;
        end
        else
          if lAttributeClass.InheritsFrom(TBABoolean) then
          begin
            lValueType := 'Boolean';
            if aChangeProperties then
              aItem.PropertiesClass := TcxCheckBoxProperties;
          end
          else
            if lAttributeClass.InheritsFrom(TBACurrency) then
            begin
              lValueType := 'Currency';
              if aChangeProperties then
              begin
                aItem.PropertiesClass := TcxCurrencyEditProperties;
                (aItem.Properties as TcxCurrencyEditProperties).Alignment.Horz := taRightJustify;
              end;
            end
            else
              if lAttributeClass.InheritsFrom(TBANumeric) then
              begin
                if aChangeProperties then
                begin
                  aItem.PropertiesClass := TcxSpinEditProperties;
                  (aItem.properties as TcxSpinEditProperties).SpinButtons.Visible := false;
                  (aItem.Properties as TcxSpinEditProperties).Alignment.Horz := taRightJustify;
                  (aItem.Properties as TcxSpinEditProperties).Increment := 0;
                  (aItem.Properties as TcxSpinEditProperties).LargeIncrement := 0;                                    
                end;
                if lAttributeClass.InheritsFrom(TBAFloat) then
                begin
                  lValueType := 'Float';
                  if aItem.properties is TcxSpinEditProperties then
                    (aItem.properties as TcxSpinEditProperties).ValueType := vtFloat;
                end
                else
                  if lAttributeClass.InheritsFrom(TBASMallInt) then
                  begin
                    lValueType := 'Smallint';
                    if aItem.properties is TcxSpinEditProperties then
                      (aItem.properties as TcxSpinEditProperties).ValueType := vtInt;
                  end
                  else
                    if lAttributeClass.InheritsFrom(TBAWord) then
                    begin
                      lValueType := 'Word';
                      if aItem.properties is TcxSpinEditProperties then
                        (aItem.properties as TcxSpinEditProperties).ValueType := vtInt;
                    end
                    else
                      if lAttributeClass.InheritsFrom(TBAInteger) then
                      begin
                        lValueType := 'Integer';
                        if aItem.properties is TcxSpinEditProperties then
                          (aItem.properties as TcxSpinEditProperties).ValueType := vtInt;
                      end;
              end
              else
                {$IFDEF IEJpegImage}
                if lAttributeClass.InheritsFrom(TBABlobImageJPEG) then
                begin
                  lValueType := '';
                  if aChangeProperties then
                  begin
                    aItem.PropertiesClass := TcxImageProperties;
                    (aItem.properties as TcxImageProperties).GraphicClassName := 'TIEJpegImage';
                  end;
                end
                else
                  {$ENDIF}
                  if lAttributeClass.InheritsFrom(TBABlobImageBMP) or lAttributeClass.InheritsFrom(TBABlobImageJPEG) then
                  begin
                    lValueType := '';
                    if aChangeProperties then
                      aItem.PropertiesClass := TcxImageProperties;
                  end
                  else
                    if aChangeProperties and lAttributeClass.InheritsFrom(TBAValueSet) then
                    begin
                      if lAttributeClass.InheritsFrom(TBALanguage) or lAttributeClass.InheritsFrom(TBADerivedValueSetValueList) and GridView.IsDesigning then
                      begin
                        MessageDlg(Format('Combo values for ''%s'' can only be fetched at run time', [aElementTypeInfo.expressionName]), mtError, [mbOk], 0);
                      end
                      else
                      begin
                        lBAValueSet := TBoldMemberFactory.CreateMemberFromBoldType(aElementTypeInfo) as TBAValueSet;
                        try
                          aItem.PropertiesClass := TcxComboBoxProperties;
                          (aItem.Properties as TcxComboBoxProperties).Items.Clear;
                          for i := 0 to lBAValueSet.Values.Count - 1 do
                          begin
                            (aItem.Properties as TcxComboBoxProperties).Items.Add(lBAValueSet.Values[i].AsString);
                          end;
                          (aItem.Properties as TcxComboBoxProperties).DropDownListStyle := lsEditFixedList;
                          (aItem.Properties as TcxComboBoxProperties).DropDownRows := lBAValueSet.Values.Count;
                        finally
                          lBAValueSet.Free;
                        end;
                      end;
                    end;
  end;
  aItem.DataBinding.ValueType := lValueType;
end;

procedure TcxGridBoldDataController.SetValueTypeAndProperties(aMember: TBoldMemberRtInfo; aItem: TcxCustomGridTableItem; aChangeProperties: boolean);
begin
  SetValueTypeAndProperties(aMember.boldType, aItem);
end;

procedure TcxGridBoldDataController.CheckDataSetCurrent;
var
  i: integer;
  lChanged: boolean;
  lState : TKeyboardState;
begin
  inherited;
  if Assigned(BoldHandle) and Assigned(CustomDataSource) and (FSkipSyncFocusedRecord = 0) and not (csDestroying in GridView.ComponentState) then
  begin
    i := FocusedRecordIndex;
    if (i >= RecordCount) then
    begin
      FocusedRecordIndex := -1;
      i := -1;
    end;
    lChanged := (i <> Follower.CurrentIndex) {or (i <> BoldHandle.CurrentIndex)};
    if not lChanged and (i <> BoldHandle.CurrentIndex) then
      lChanged := true;

    if lChanged then
    begin
      {$IFDEF BoldDevExLog}
      if GridView <> nil then
        _Log(GridView.Name + ':CheckDataSetCurrent', className)
      else
        _Log(':CheckDataSetCurrent', className);
      {$ENDIF}
      fBoldProperties.AfterMakeUptoDate := nil;
      fBoldProperties.BeforeMakeUptoDate := nil;
      inc(FSkipMakeCellUptoDate);
      try
        TBoldQueueable.DisplayAll;
        fBoldHandleFollower.SetFollowerIndex(i);
        if BoldHandleFollower.IsInDisplayList then
          TBoldListHandleFollowerAccess(BoldHandleFollower).Display;
        GetKeyboardState(lState);
        if i <> -1 then
        begin
          i := GetRowIndexByRecordIndex(i, false);
        end;
        if not (((lState[VK_CONTROL] and 128) <> 0) or ((lState[VK_SHIFT] and 128) <> 0)) and ((i = -1) or not IsRowSelected(i)) then
        begin
          Controller.ClearSelection;
          if Assigned(Controller.FocusedRecord) then
            Controller.FocusedRecord.Selected := true;
        end;
        TBoldQueueable.DisplayAll;
      finally
        fBoldProperties.AfterMakeUptoDate := _AfterMakeListUptoDate;
        fBoldProperties.BeforeMakeUptoDate := _BeforeMakeListUptoDate;
        dec(FSkipMakeCellUptoDate);
      end;
    end;
  end;
end;

procedure TcxGridBoldDataController.ConstraintColumnCustomDrawCell(
  Sender: TcxCustomGridTableView; ACanvas: TcxCanvas;
  AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
var
  ARect: TRect;
  lConstraintBitmap: Graphics.TBitmap;
  lValue: Variant;
begin
  if AViewInfo is TcxGridCardRowCaptionViewInfo then exit;
  with AViewInfo do
  begin
    ARect := Bounds;
//    ACanvas.Brush.Style := bsClear;
    ACanvas.FillRect(ARect, ACanvas.Brush.Color);
    if AViewInfo.RecordViewInfo.Index = -1 then
    begin
      // draw nothing
    end
    else
    begin
      lValue := Value;
      if not VarIsNull(lValue) and lValue then
        lConstraintBitmap := bmpBoldGridConstraint_true
      else
        lConstraintBitmap := bmpBoldGridConstraint_false;
      lConstraintBitmap.Transparent := true;
      ACanvas.Draw(ARect.Left + 4, ARect.Top + 4, lConstraintBitmap);
    end;
  end;
  ADone := true;
end;

procedure TcxGridBoldDataController.ColumnCustomDrawCell(
  Sender: TcxCustomGridTableView; ACanvas: TcxCanvas;
  AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
var
  lBoldVariantFollowerController: TBoldVariantFollowerController;
  lColor: TColor;
  lCellFollower: TBoldFollower;
begin
  if not AViewInfo.RecordViewInfo.Focused then
  begin
    lBoldVariantFollowerController := BoldPropertiesFromItem(AViewInfo.Item.Index);
    lCellFollower := CellFollowers[AViewInfo.Item.Index, AViewInfo.RecordViewInfo.GridRecord.RecordIndex];
    lBoldVariantFollowerController.SetColor(lColor, ACanvas.Brush.Color, lCellFollower);
    lBoldVariantFollowerController.SetFont(ACanvas.Font, ACanvas.Font, lCellFollower);
    ACanvas.Brush.Color := lColor;
  end;
end;

procedure TcxGridBoldDataController.GetCellHint(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  ACellViewInfo: TcxGridTableDataCellViewInfo; const AMousePos: TPoint;
  var AHintText: TCaption; var AIsHintMultiLine: Boolean; var AHintTextRect: TRect);
{$IFNDEF AttracsBold}
  function AsCommaText(AList: TBoldList; AIncludeType: boolean; Representation: TBoldRepresentation; const ASeparator: string = ','): string;
  var
    i: integer;
    s: string;
  begin
    result := '';
    for I := 0 to AList.Count - 1 do
    begin
      if Assigned(AList.Elements[i]) then
      begin
        s := AList.Elements[i].StringRepresentation[Representation];
        if AIncludeType then
         s := AList.Elements[i].ClassName + ':' + s;
      end
      else
        s := 'nil';
      if i < AList.count-1 then
        s := s + ASeparator;
      result := result + s;
    end;
  end;
{$ENDIF}
var
  lIE: TBoldIndirectElement;
begin
  if VarIsType(ACellViewInfo.Value, varBoolean) and (not ACellViewInfo.Value) then
//  if (not VarIsNull(ACellViewInfo.Value)) and (not ACellViewInfo.Value) then
  begin
    lIE := TBoldIndirectElement.Create;
    try
      Follower.SubFollowers[ARecord.RecordIndex].Element.EvaluateExpression('constraints->select(c|not c)', lIE);
{$IFDEF AttracsBold}
      AHintText := (lIE.Value as TBoldList).AsCommaText(false, 11);
{$ELSE}
      AHintText := AsCommaText((lIE.Value as TBoldList), false, 11);
{$ENDIF}
    finally
      lIE.free;
    end;
  end;
end;

procedure TcxGridBoldDataController.CreateAllItems(
  AMissingItemsOnly: Boolean);
  
function ClassTypeHasConstraints(aBoldClassTypeInfo: TBoldClassTypeInfo): boolean;
var
  lBoldClassTypeInfo: TBoldClassTypeInfo;
begin
  lBoldClassTypeInfo := aBoldClassTypeInfo;
  repeat
  // BoldClassTypeInfo.ConstraintCount doesn't include inherited constraints so we have to iterate
    result := lBoldClassTypeInfo.ConstraintCount > 0;
    lBoldClassTypeInfo := lBoldClassTypeInfo.SuperClassTypeInfo;
  until result or (lBoldClassTypeInfo = nil);
end;

var
  I: Integer;
  lListElementType: TBoldElementTypeInfo;
  lClasstypeInfo: TBoldClassTypeInfo;
  lMember: TBoldMemberRtInfo;
  lcxCustomGridTableItem: TcxCustomGridTableItem;
begin
  if (BoldHandle = nil) or (BoldHandle.ListElementType = nil) then Exit;
  ShowHourglassCursor;
  fCreatingColumns := true;
  try
    GridView.BeginUpdate;
    BeginUpdateFields;
    try
      lListElementType := BoldHandle.ListElementType;
      if (lListElementType is TBoldClassTypeInfo) then
      begin
        lClassTypeInfo := lListElementType as TBoldClassTypeInfo;
        if ClassTypeHasConstraints(lClassTypeInfo) and (not AMissingItemsOnly or (GetItemByExpression(cOCLConstraint) = nil)) then
        begin
          // create constraint column
          EnsureConstraintColumn;
        end;
        if (lClassTypeInfo.DefaultStringRepresentation <> '') and (lClassTypeInfo.AllMembers.Count = 0) then
        begin
          if not AMissingItemsOnly or (GetItemByExpression('') = nil) then
          begin
            InternalCreateItem(GridView, '', lClassTypeInfo.ModelName, 'String', 'DefaultStringRepresentation');
          end;
        end;
        for i := 0 to lClassTypeInfo.AllMembers.Count - 1 do
        begin
          lMember := lClassTypeInfo.AllMembers[I];
          if (lMember.IsAttribute or (lMember.IsSingleRole and TBoldRoleRTInfo(lMember).IsNavigable)) and not lMember.DelayedFetch then
          begin
            if not AMissingItemsOnly or (GetItemByExpression(lMember.ExpressionName) = nil) then
            begin
              lcxCustomGridTableItem := InternalCreateItem(GridView, lMember.ExpressionName, lMember.ModelName, 'String', lMember.ModelName);
              if lMember.IsSingleRole then
              begin
                lcxCustomGridTableItem.DataBinding.ValueType := 'String';
              end
              else
              begin
                SetValueTypeAndProperties(lMember, lcxCustomGridTableItem);
              end;
            end;
          end;
        end;
      end
      else if (lListElementType is TBoldAttributeTypeInfo) then
      begin
        if not AMissingItemsOnly or (GetItemByExpression('') = nil) then
        begin
          InternalCreateItem(GridView, '', TBoldAttributeTypeInfo(lListElementType).ModelName, 'String', TBoldAttributeTypeInfo(lListElementType).ModelName);
        end;
      end
      else if (lListElementType is TBoldListTypeInfo) then
      begin
        if not AMissingItemsOnly or (GetItemByExpression('') = nil) then
        begin
          InternalCreateItem(GridView, '', 'ClassName', 'String', 'ClassName');
        end;
      end;
      if (GridView.ItemCount = 0) or ((GridView.ItemCount = 1) and ((GridView.Items[0] as IBoldAwareViewItem).BoldProperties.expression = cOCLConstraint)) then
      begin
        InternalCreateItem(GridView, '', lListElementType.asString, 'String', lListElementType.asString);
      end;
    finally
      EndUpdateFields;
      GridView.EndUpdate;
    end;
  finally
    HideHourglassCursor;
    fCreatingColumns := false;
  end;
end;

{
procedure TcxGridBoldDataController.DoGroupingChanged;
begin
  inherited;

end;

procedure TcxGridBoldDataController.DoSortingChanged;
begin
  inherited;

end;
}

function TcxGridBoldDataController.GetController: TcxCustomGridTableController;
begin
  Result := GridView.Controller;
end;

function TcxGridBoldDataController.GetGridViewValue: TcxCustomGridTableView;
begin
  result := TcxCustomGridTableView(GetGridView);
end;

function TcxGridBoldDataController.GetItem(Index: Integer): TObject;
begin
  Result := GridView.Items[Index];
end;

function TcxGridBoldDataController.GetItemByExpression(
  const aExpression: string): TObject;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ItemCount - 1 do
  begin
    if AnsiCompareText(BoldPropertiesFromItem(i).Expression, aExpression) = 0 then
    begin
      Result := GetItem(I);
      Break;
    end;
  end;
end;

function TcxGridBoldDataController.GetItemData(AItem: TObject): Integer;
begin
  if AItem is TcxCustomGridTableItem then
    Result := Integer(TcxCustomGridTableItem(AItem).DataBinding.Data)
  else
    Result := -1;
end;

function TcxGridBoldDataController.GetItemDataBindingClass: TcxGridItemDataBindingClass;
begin
  Result := TcxGridItemBoldDataBinding;
end;

function TcxGridBoldDataController.HasAllItems: Boolean;
begin
  result := false;
end;

function TcxGridBoldDataController.SupportsCreateAllItems: Boolean;
begin
  result := true;
end;

procedure TcxGridBoldDataController.ForEachRow(ASelectedRows: Boolean;
  AProc: TcxDataControllerEachRowProc);
var
  i: integer;
  lList: TBoldObjectList;
begin
  if ASelectedRows then
  begin
    if GetSelectedCount > 0 then
    begin
      lList := TBoldObjectList.Create;
      try
        for i := 0 to GetSelectedCount - 1 do // or Controller.SelectedRecordCount ?
        begin
          lList.AddLocator( (Follower.Element as TBoldObjectList).Locators[Controller.SelectedRecords[i].RecordIndex] );
        end;
        AdjustActiveRange(lList);
      finally
        lList.free;
      end;
    end;
  end
  else
  begin
    AdjustActiveRange;
  end;
  inherited;
end;

procedure TcxGridBoldDataController.SetMasterRelation(
  AMasterRelation: TcxCustomDataRelation; AMasterRecordIndex: Integer);
var
  lReferenceHandle: TBoldReferenceHandle;
  lListHandle: TBoldListHandle;
  lGridLevel: TcxGridLevel;
  lPatternView: IBoldAwareView;
  lMasterElement: TBoldElement;
  lBoldAwareView: IBoldAwareView;
begin
  if Assigned(AMasterRelation) and (AMasterRelation.Item is TcxGridLevel) then
  begin
    lGridLevel := (AMasterRelation.Item as TcxGridLevel);
    if lGridLevel.GridView.IsPattern and (lGridLevel.GridView <> GridView) then
    begin
      lBoldAwareView := lGridLevel.GridView.MasterGridView as IBoldAwareView;
      Assert(lBoldAwareView.DataController.BoldHandle.List.count > AMasterRecordIndex);
      lBoldAwareView.DataController.BoldHandle.CurrentIndex := AMasterRecordIndex;
      lMasterElement := lBoldAwareView.DataController.BoldHandle.Value;
      lPatternView := (lGridLevel.GridView as IBoldAwareView);
      lReferenceHandle := TBoldReferenceHandle.Create(GetOwnerOrView);
      lReferenceHandle.Value := lMasterElement;
      lListHandle := TBoldListHandle.Create(GetOwnerOrView);
      lListHandle.RootHandle := lReferenceHandle;
      if Assigned(lPatternView.DataController.BoldHandle) and (lPatternView.DataController.BoldHandle is TBoldListHandle) then
      begin
        lListHandle.expression := (lPatternView.DataController.BoldHandle as TBoldListHandle).Expression;
        lListHandle.mutableListexpression := (lPatternView.DataController.BoldHandle as TBoldListHandle).mutableListexpression;
        lListHandle.name := CreateUniqueName(GetOwnerOrView, GridView, lListHandle, '', 'md_' + lPatternView.DataController.BoldHandle.name);
      end;
      BoldAutoColumns := false; // lPatternView.DataController.BoldAutoColumns;
      BoldHandle := lListHandle;
      GridView.Name := CreateUniqueName(GetOwnerOrView, GetOwnerOrView, GridView, '', lGridLevel.GridView.Name);
    end;
  end;
  inherited;
end;

type
  TcxCustomGridTableControllerHack = class(TcxCustomGridTableController);

procedure TcxGridBoldDataController.SelectionChanged;
var
  i, j: integer;
  lSelectedIndex: integer;
  lFollower: TBoldFollower;
  lCount: integer;
  lList: TBoldList;
  lIndex: integer;
//  lBoldAwareView: IBoldAwareView;
  lSelection: TBoldList;
  lRecordCount: integer;
begin
  {$IFDEF BoldDevExLog}
  _Log(GridView.Name + ':DoSelectionChanged', className);
  {$ENDIF}
//  GridView.GetInterface(IBoldAwareView, lBoldAwareView);
  lSelection := fSelection;// lBoldAwareView.Selection;
  if Assigned(lSelection) then
    lSelection.Clear;
  lFollower := Follower;
  j := Controller.SelectedRecordCount;
  if Assigned(BoldHandle) and Assigned(Follower.Element) and (lFollower.Element is TBoldObjectList) then
  begin
    lList := Follower.Element as TBoldList;
    if (j > 0) and (j >= Follower.SubFollowerCount) then
    begin
      if Assigned(lSelection) then
        lSelection.AddList(lList);
      BoldProperties.SelectAll(lFollower, true);
    end
    else
    begin
      lCount := lList.count;
      lRecordCount := TcxCustomGridTableControllerHack(GridView.Controller).ViewData.RecordCount;
      BoldProperties.SelectAll(lFollower, false);
      for i := 0 to j - 1 do
      begin
        lIndex := GetSelectedRowIndex(i);
        if lIndex < lRecordCount then
        begin
          lSelectedIndex := Controller.SelectedRecords[i].RecordIndex;
          if lSelectedIndex < lCount then
          begin
            if Assigned(lSelection) then
              lSelection.Add(lList[lSelectedIndex]);
            BoldProperties.SetSelected(lFollower, lSelectedIndex, true);
          end;
        end;
      end;
    end;
    if {(lSelection.Count = 0) and} (Follower.SubFollowerCount > 0) and (Follower.CurrentIndex <> -1) then
    begin
      if Assigned(lSelection) and (Follower.CurrentIndex <> -1) then
{$IFDEF AttracsBold}
        lSelection.Add(Follower.CurrentSubFollower.Element);
{$ELSE}
        lSelection.Add(Follower.SubFollowers[Follower.CurrentIndex].Element);
{$ENDIF}
      BoldProperties.SetSelected(lFollower, Follower.CurrentIndex, true);
    end;
  end
  else
  begin
    if Assigned(lSelection) then
      lSelection.Clear;
    BoldProperties.SelectAll(lFollower, false);
  end;
  {$IFDEF DisplayAll}
  TBoldQueueable.DisplayAll;
  {$ENDIF}
end;

function TcxGridBoldDataController.DoEditing(AItem: TcxCustomGridTableItem): Boolean;
var
  lRecord: integer;
  lFollower: TBoldFollower;
  lIcxBoldEditProperties: IcxBoldEditProperties;
begin
  lRecord := RecNo;
  Assert(lRecord <> -1, 'lRecord <> -1');
  lFollower := CellFollowers[AItem.ID, lRecord];
  if not Assigned(lFollower) then
  begin
    TBoldQueueable.DisplayAll;
    lFollower := CellFollowers[AItem.ID, lRecord];
//    Assert(Assigned(lFollower));
  end;
  result := Assigned(lFollower);
  if Assigned(lFollower) then
  begin
    lFollower.EnsureDisplayable;
    result := lFollower.Controller.MayModify(lFollower);
    Assert(AItem.GetProperties <> nil);
    if Supports(AItem.GetProperties, IcxBoldEditProperties, lIcxBoldEditProperties) then
    begin
      result := lIcxBoldEditProperties.CanEdit(BoldHandle, lFollower);
    end
  end;
end;

procedure TcxGridBoldDataController.AssignData(
  ADataController: TcxCustomDataController);
begin
end;

procedure TcxGridBoldDataController.CheckGridModeBufferCount;
begin
//  UpdateGridModeBufferCount;
end;

procedure TcxGridBoldDataController.DeleteAllItems;
begin
  GridView.ClearItems;
end;

function TcxGridBoldDataController.DoScroll(AForward: Boolean): Boolean;
begin
  Result := SupportsScrollBarParams;
  if Result then
    if AForward then
      Controller.GoToNext(False, False)
    else
      Controller.GoToPrev(False, False);
end;

function TcxGridBoldDataController.DoScrollPage(
  AForward: Boolean): Boolean;
begin
  Result := SupportsScrollBarParams;
  if Result then
    if AForward then
      TcxCustomGridTableControllerAccess.FocusNextPage(Controller, False)
    else
      TcxCustomGridTableControllerAccess.FocusPrevPage(Controller, False);
end;

procedure TcxGridBoldDataController.GetFakeComponentLinks(AList: TList);
begin
  if (BoldHandle <> nil) and (BoldHandle.Owner <> GetOwnerOrView) and
    (AList.IndexOf(BoldHandle.Owner) = -1) then
    AList.Add(BoldHandle.Owner);
end;

function TcxGridBoldDataController.GetGridView: TcxCustomGridView;
begin
  Result := TcxCustomGridView(GetOwner);
end;

function TcxGridBoldDataController.GetItemDefaultValuesProviderClass: TcxCustomEditDefaultValuesProviderClass;
begin
  Result := TcxGridDefaultValuesProvider;
//  Result := TcxGridBoldDefaultValuesProvider;
end;

function TcxGridBoldDataController.GetNavigatorIsBof: Boolean;
begin
  Result := GridView.Controller.IsStart;
end;

function TcxGridBoldDataController.GetNavigatorIsEof: Boolean;
begin
  Result := GridView.Controller.IsFinish;
end;

function TcxGridBoldDataController.GetScrollBarPos: Integer;
begin
  if SupportsScrollBarParams then
    if dceInsert in EditState then
      Result := FPrevScrollBarPos
    else
      Result := RecNo - 1
  else
    Result := -1;
  FPrevScrollBarPos := Result;
end;

function TcxGridBoldDataController.GetScrollBarRecordCount: Integer;
begin
// TODO see how to properly replace DataSetRecordCount, perhaps add BoldHandleRecordCount
  if SupportsScrollBarParams then
    Result := {DataSetRecordCount +} GridView.ViewInfo.VisibleRecordCount - 1
  else
    Result := -1;
end;

function TcxGridBoldDataController.InternalCreateItem(
  aGridView: TcxCustomGridTableView; aExpression, aCaption, aValueType,
  aName: string): TcxCustomGridTableItem;
begin
  result := aGridView.CreateItem;
  (result as IBoldAwareViewItem).BoldProperties.Expression := aExpression;
  result.DataBinding.ValueType := aValueType;
  result.Caption := aCaption;
  result.Name := CreateUniqueName(GetOwnerOrView, GridView, result, ScxGridPrefixName, aName);
end;

function TcxGridBoldDataController.IsDataChangeable: Boolean;
begin
  Result := False;
end;

function TcxGridBoldDataController.IsDataLinked: Boolean;
begin
  Result := BoldHandle <> nil;
end;

procedure TcxGridBoldDataController.PreFetchColumns(aList: TBoldList; aItem: integer);

  procedure ActivateFollowers(ListToActivate: TBoldList; ItemIndex: integer);
  var
    MainFollower: TBoldFollower;
    RowFollower: TBoldFollower;
    CellFollower: TBoldFollower;
    List: TBoldList;
    i: integer;
  begin
    MainFollower := Follower;
    List := BoldList;
    for i := 0 to ListToActivate.Count - 1 do
    begin
      RowFollower := MainFollower.SubFollowers[List.IndexOf(ListToActivate[i])];
      CellFollower := RowFollower.SubFollowers[ItemIndex];
      if not Assigned(CellFollower) then
      begin
        RowFollower.EnsureDisplayable;
        CellFollower := RowFollower.SubFollowers[ItemIndex];
      end;
      CellFollower.EnsureDisplayable;
    end;
  end;
{$IFDEF AttracsBold}
var
  i,j: integer;
  lOcl: string;
  lBoldAwareViewItem: IBoldAwareViewItem;
  lItem: TcxCustomGridTableItem;
  lFollower: TBoldFollower;
{$ENDIF}  
begin
{$IFNDEF DESIGNONLY}
{$IFDEF AttracsBold}
  lFollower := Follower;
  if (aItem <> -1) then
  begin
    GetItem(aItem).GetInterface(IBoldAwareViewItem, lBoldAwareViewItem);
    lOcl := lBoldAwareViewItem.BoldProperties.Expression;
    if (aList.Count = 0) then
    begin
      FetchOclSpan(lFollower.Element as TBoldList, lOcl);
      for j := 0 to lFollower.SubFollowerCount - 1 do
      begin
        lFollower.SubFollowers[j].EnsureDisplayable;
        lFollower.SubFollowers[j].SubFollowers[aItem].EnsureDisplayable;
      end;
    end
    else
    begin
      FetchOclSpan(aList, lOcl);
      ActivateFollowers(aList, aItem);
    end;
  end
  else
  begin
    for I := 0 to ItemCount - 1 do
    begin
      lItem := TcxCustomGridTableItem(GetItem(i));
      if lItem.ActuallyVisible then
      begin
        GetItem(i).GetInterface(IBoldAwareViewItem, lBoldAwareViewItem);
        lOcl := lBoldAwareViewItem.BoldProperties.Expression;

        if LoadAll or RequiresAllRecords(lItem) then
        begin
          FetchOclSpan(lFollower.Element as TBoldList, lOcl);
          for j := 0 to lFollower.SubFollowerCount - 1 do
          begin
            lFollower.SubFollowers[j].EnsureDisplayable;
            lFollower.SubFollowers[j].SubFollowers[i].EnsureDisplayable;
          end;
        end
        else
        begin
          if aList.count > 0 then
          begin
            FetchOclSpan(aList, lOcl);
            ActivateFollowers(aList, i);
          end;
        end;
      end;
    end;
  end;
{$ENDIF}  
{$ENDIF}
end;

function TcxGridBoldDataController.RequiresAllRecords(AItem: TObject): boolean;
var
  lItem: TcxCustomGridTableItemAccess;
begin
  result := false;
  if (AItem is TcxCustomGridTableItem) then
  begin
    lItem := TcxCustomGridTableItemAccess(AItem);
    result := (lItem.SortIndex <> -1) or (lItem.GroupIndex <> -1) or lItem.Filtered or
           ((AItem is TcxGridColumn) and
           (
           (TcxGridColumn(AItem).Summary.FooterKind <> skNone ) or
           (TcxGridColumn(AItem).Summary.GroupFooterKind  <> skNone ) or
           (TcxGridColumn(AItem).Summary.GroupKind <> skNone )
           ));
  end;
end;

function TcxGridBoldDataController.RequiresAllRecords: boolean;
var
  lcxCustomGridTableView: TcxCustomGridTableView;
  i: integer;
begin
  lcxCustomGridTableView := GridView as TcxCustomGridTableView;
  result := (lcxCustomGridTableView.SortedItemCount > 0)
    or (lcxCustomGridTableView.GroupedItemCount > 0)
    or (Summary.FooterSummaryItems.Count > 0)
    or (Assigned(Filter) and Filter.Active and (Filter.Root.Count > 0));
  for I := 0 to lcxCustomGridTableView.ItemCount - 1 do
    result := result or RequiresAllRecords(lcxCustomGridTableView.Items[i]);
end;

function TcxGridBoldDataController.GetOwnerOrView: TComponent;
begin
  if Assigned(GridView.Owner) then
    result := GridView.Owner
  else
    result := GridView;
end;

function TcxGridBoldDataController.SetScrollBarPos(
  Value: Integer): Boolean;
begin
  Result := SupportsScrollBarParams;
  if Result then
    RecNo := Value + 1;
end;

function TcxGridBoldDataController.SupportsScrollBarParams: Boolean;
begin
  Result := IsGridMode and TcxCustomGridTableViewAccess.IsEqualHeightRecords(GridView);
end;

constructor TcxGridBoldDataController.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TcxGridBoldDataController.Destroy;
begin
  inherited;
end;

procedure TcxGridBoldDataController.AdjustActiveRange(
  aList: TBoldObjectList = nil; aItem: integer = -1);
var
  i,j: integer;
  lFollower: TBoldFollower;
  lRecordIndex: integer;
  lList: TBoldObjectList;
  lGuard: IBoldGuard;
  lWholeList: TBoldObjectList;
  lRecord: TcxCustomGridRecord;
begin
  lFollower := Follower;
  lList := aList;
  if Assigned(lFollower) then
  begin
    if not Assigned(aList) and not LoadAll and (lFollower.Element is TBoldObjectList) {and not RequiresAllRecords} then
    begin
      lGuard := TBoldGuard.Create(lList);
      lList := TBoldObjectList.Create;
      i := TcxCustomGridTableView(GridView).Controller.TopRecordIndex;
      if i <> -1 then
      begin
        aItem := -1; // since, at this point we know the visible records process all columns
        j := i + TcxCustomGridTableView(GridView).ViewInfo.VisibleRecordCount+2; // there can be at most 2 partially visible records
        i := (i div 10) * 10;
        j := (j div 10 +1) * 10;
        if j >= TcxCustomGridTableView(GridView).DataController.DataControllerInfo.GetRowCount then
          j := TcxCustomGridTableView(GridView).DataController.DataControllerInfo.GetRowCount -1;
        lWholeList := lFollower.Element as TBoldObjectList;
        for i := i to j do
        begin
          lRecord := TcxCustomGridTableView(GridView).ViewData.GetRecordByIndex(i);
          if Assigned(lRecord) then
          begin
            lRecordIndex := lRecord.RecordIndex;
            if (lRecordIndex > -1) and (lRecordIndex < lWholeList.count) then
              lList.AddLocator(lWholeList.Locators[lRecordIndex]);
          end;
        end;
      end;
    end;
  end;
  if LoadAll then
    aItem := -1;
  inherited AdjustActiveRange(lList, aItem);
end;

procedure TcxGridBoldDataController._BeforeMakeListUpToDate(
  Follower: TBoldFollower);
//var
//  lFirstLoad: boolean;
begin
//  lFirstLoad := CustomDataSource = nil;
  inherited;
{  if lFirstLoad then
  begin
    if Assigned(OnBeforeLoad) then
      OnBeforeLoad(GridView);
  end;
}
end;

procedure TcxGridBoldDataController._AfterMakeListUptoDate(
  Follower: TBoldFollower);
var
  i: integer;
  lcxBoldDataSource: TcxBoldDataSource;
  lBoldAwareView: IBoldAwareView;
  lFirstLoad: boolean;
  lDataChanged: boolean;
  lTypeChanged: boolean;
begin
  {$IFDEF BoldDevExLog}
  _Log((GetOwner as TComponent).Name + ':_AfterMakeListUpToDate:' +IntToStr(FSkipMakeCellUptoDate), className);
  {$ENDIF}

  lTypeChanged := false;
  lBoldAwareView := GridView as IBoldAwareView;
  lFirstLoad := (CustomDataSource = nil);
  if not lFirstLoad and (DataStorage.RecordCount <> Follower.SubfollowerCount) then
    DataHasChanged := true;
  try
    if GridView.IsDesigning {or isPattern} then // isPattern needs to be tested for detail views
    begin
      exit;
    end;
//    TypeMayHaveChanged;
    if lFirstLoad then
    begin
      fFetchedAll := false;
      lcxBoldDataSource := cxBoldDataSourceClass.Create(self as TcxGridBoldDataController);

      if {BoldAutoColumns and} (GetHandleListElementType <> fCurrentListElementType) and Assigned(fCurrentListElementType) and (GetHandleListElementType <> nil) then
      if not GetHandleListElementType.ConformsTo(fCurrentListElementType) then
        lBoldAwareView.ClearItems;
      CustomDataSource := lcxBoldDataSource;

      if (Follower.Element = nil) or Follower.ElementValid then
      begin
        lTypeChanged := TypeMayHaveChanged;
      end;
      for i := 0 to ItemCount - 1 do
      begin
        BoldPropertiesFromItem(i).AfterMakeUptoDate := nil;
      end;
    end
    else
    begin
      TypeMayHaveChanged;
  //    EndUpdate;
    end;
  finally
    lDataChanged := DataHasChanged;
    if not lDataChanged then
      dec(FSkipMakeCellUptoDate);
    if lDataChanged and (FSkipMakeCellUptoDate = 1) and Assigned(CustomDataSource) then
    begin
      if CustomDataSource.Provider = nil then
        TcxBoldDataSource(CustomDataSource).CurrentProvider := Provider;
      CustomDataSource.DataChanged;
      TcxBoldDataSource(CustomDataSource).DataController.DataControllerInfo.Refresh;

  //    Summary.Calculate;
      DataHasChanged := false;
    end;
//    OnAfterDisplay(nil);

    if lDataChanged then
      dec(FSkipMakeCellUptoDate);
    for i := 0 to ItemCount - 1 do
    begin
      BoldPropertiesFromItem(i).AfterMakeUptoDate := _AfterMakeCellUptoDate;
    end;
{    if (lFirstLoad or lDataChanged) and Assigned(Follower.Element) and ((Follower.Element as TBoldObjectList).count > 0) then
    begin
     AdjustActiveRange(Follower.Element as TBoldObjectList);
    end;
}
{    if lDataChanged then
    begin
      DataStorage.BeginLoad;
      TcxBoldDataSource(CustomDataSource).LoadRecordHandles;
      DataStorage.EndLoad;
    end;
}
    if not lFirstLoad and not lDataChanged and (Follower.SubFollowerCount <> DataStorage.RecordCount) then
    begin
      if CustomDataSource.Provider = nil then
        TcxBoldDataSource(CustomDataSource).CurrentProvider := Provider;
      DataStorage.BeginLoad;
      try
        TcxBoldDataSource(CustomDataSource).LoadRecordHandles;
        Assert(Follower.SubFollowerCount = DataStorage.RecordCount, 'Follower.SubFollowerCount = DataStorage.RecordCount' + IntToStr(Follower.SubFollowerCount) + ',' + IntToStr(DataStorage.RecordCount) );
      finally
        DataStorage.EndLoad;
      end;
    end;
    inc(FSkipSyncFocusedRecord);
    try
      EndFullUpdate;
    finally
      dec(FSkipSyncFocusedRecord);
    end;
    Assert(((Follower.SubFollowerCount = DataStorage.RecordCount) or (DetailMode = dcdmPattern) or lFirstLoad), 'TcxGridBoldDataController._AfterMakeListUptoDate (Assert2)');
    if Assigned(CustomDataSource) then
      TcxBoldDataSource(CustomDataSource).fIsBoldInitiatedChange := false;
    fBoldProperties.OnAfterInsertItem := _InsertRow;
    fBoldProperties.OnAfterDeleteItem := _DeleteRow;
    BeginUpdate;
    try
      if (Follower.CurrentIndex <> FocusedRecordIndex) and (FSkipMakeCellUptoDate < 2) then
      begin
        Controller.ClearSelection;
        if {(Follower.CurrentIndex <> -1) and} (Follower.CurrentIndex < RecordCount) then
          FocusedRecordIndex := Follower.CurrentIndex
        else
        if RecordCount > 0 then
        begin
          Follower.CurrentIndex := 0;
          FocusedRecordIndex := 0;
        end;
        if Assigned(Controller.FocusedRecord) then
          Controller.FocusedRecord.Selected := true;
      end;
      Change([dccSelection]);
    finally
      EndUpdate;
    end;

    if lTypeChanged and BoldAutoColumns {(GridView.OptionsView is TcxGridTableOptionsView) and TcxGridTableOptionsView(GridView.OptionsView).ColumnAutoWidth} then
    begin
//      TcxGridTableOptionsView(GridView.OptionsView).ColumnAutoWidth := false;
      ShowHourglassCursor;
      GridView.BeginUpdate;
      try
        GridView.ApplyBestFit(nil, true, false);
      finally
        GridView.EndUpdate;
        HideHourglassCursor;
//        TcxGridTableOptionsView(GridView.OptionsView).ColumnAutoWidth := true
      end;
    end;

    if lDataChanged or lFirstLoad then
    begin
      {$IFDEF FireAfterLoadOnChangeOnly}
      if Assigned(OnAfterLoad) then
        OnAfterLoad(GridView);
      {$ENDIF}
    end;
    {$IFNDEF FireAfterLoadOnChangeOnly}
    if Assigned(OnAfterLoad) then
      OnAfterLoad(GridView);
    {$ENDIF}
  end;
end;

procedure TcxGridBoldDataController.TypeChanged(aNewType, aOldType: TBoldElementTypeInfo);
begin
  inherited;
  if not Assigned(fCurrentListElementType) then
  begin
    if BoldAutoColumns then
    begin
      TcxCustomGridTableView(GridView).ClearItems;
      fFetchedAll := false;
    end;
  end
  else
  if Assigned(aOldType) and BoldAutoColumns or (TcxCustomGridTableView(GridView).ItemCount = 0) then
  begin
    TcxCustomGridTableView(GridView).ClearItems;
    TcxGridBoldDataController(self).CreateAllItems(false);
    fFetchedAll := false;
  end;
end;

function TcxGridBoldDataController.GetSummaryGroupItemLinkClass: TcxDataSummaryGroupItemLinkClass;
begin
  Result := TcxGridTableSummaryGroupItemLink;
end;

function TcxGridBoldDataController.GetSummaryItemClass: TcxDataSummaryItemClass;
begin
  Result := TcxGridTableSummaryItem;
end;

procedure TcxGridBoldDataController._AfterMakeCellUptoDate(
  Follower: TBoldFollower);
var
  lcxCustomGridRecordViewInfo: TcxCustomGridRecordViewInfo;
  lcxCustomGridTableView: TcxCustomGridTableView;
//  lcxGridBoldCardViewRow: TcxGridBoldCardViewRow;
  lItem: TcxCustomGridTableItemAccess;
//  lcxGridBoldCardView: TcxGridBoldCardView;
  lcxGridTableDataCellViewInfo: TcxGridTableDataCellViewInfo;
  lcxCustomGridRecord: TcxCustomGridRecord;
  lPreview: TcxGridPreview;
begin
  if DataHasChanged or (FSkipMakeCellUptoDate > 0) then
    exit;
{  BoldInstalledQueue.AddAfterDisplayNotification(DataChangedEvent);
  fDataChanged := true;
  exit;
}
  lcxCustomGridTableView := GridView as TcxCustomGridTableView;
  lItem := TcxCustomGridTableItemAccess(GetItem(Follower.index));
  inc(FSkipMakeCellUptoDate);
  try
    {$IFDEF BoldDevExLog}
    _Log((GetOwner as TComponent).Name + '_AfterMakeCellUptoDate:' + Follower.ContextString, className);
    {$ENDIF}
//    s := IntToStr(Follower.OwningFollower.index) + ',' + IntToStr(Follower.index);
//    lItemIndex := Integer(AItemHandle);
//    lItem := lcxBoldDataController.GetItem(lItemIndex);

//    lItem := TcxCustomGridTableItemAccess(TcxGridItemBoldDataBinding(TcxBoldDataSource(CustomDataSource).GetItemHandle(Follower.index)).Item);
    if (lItem.GroupIndex = -1) and (lItem.SortIndex = -1) and (not lItem.Filtered) and (Follower.OwningFollower.index <= RecordCount) then
    begin
//      if not lItem.Visible then
//        exit;
      lcxCustomGridRecord := lcxCustomGridTableView.ViewData.GetRecordByRecordIndex(Follower.OwningFollower.index);
      if not Assigned(lcxCustomGridRecord) then
      begin
        exit;
      end;
      lcxCustomGridRecordViewInfo := lcxCustomGridRecord.ViewInfo;
      if not Assigned(lcxCustomGridRecordViewInfo) then
        exit;
      // workaround for what seems like a bug in cxGridRows TcxGridDataRowViewInfo.GetCellViewInfoByItem(
      // lcxCustomGridRecordViewInfo.GridView.Control can be nil and then GetCellViewInfoByItem fails
      if Assigned(lcxCustomGridRecordViewInfo.GridView.Control) then
        lcxGridTableDataCellViewInfo := lcxCustomGridRecordViewInfo.GetCellViewInfoByItem(lItem)
      else
        lcxGridTableDataCellViewInfo := nil;

      if Assigned(lcxGridTableDataCellViewInfo) then
      begin
        if not fInvalidating then
        begin
          fInvalidating := true;
          try
            if not fInternalChange and lcxGridTableDataCellViewInfo.Editing then
              lcxGridTableDataCellViewInfo.Item.Editing := false;
              // this ensures that any ongoing editing is canceled if there is a change from other controls or perhaps via OSS

            lcxGridTableDataCellViewInfo.Invalidate(True);
          finally
            fInvalidating := false;
          end;
        end
        else
        begin
          lcxGridTableDataCellViewInfo.Invalidate(false);
        end;
      end;

      if not lItem.Visible then
      begin
        if (lcxCustomGridTableView is TcxGridBoldTableView) then
          lPreview := TcxGridBoldTableView(lcxCustomGridTableView).Preview
        else
        if (lcxCustomGridTableView is TcxGridBoldBandedTableView) then
          lPreview := TcxGridBoldBandedTableView(lcxCustomGridTableView).Preview
        else
          lPreview := nil;
        if Assigned(lPreview) and lPreview.Active and lPreview.Visible and lPreview.AutoHeight then
        begin
          lcxCustomGridTableView.Changed(vcSize);
        end;
      end;
{
      if Assigned(lcxGridColumn) and (lcxGridColumn.Summary.FooterKind <> skNone) then
      begin
        i := Summary.FooterSummaryItems.ItemOfItemLink(lcxGridColumn).Index;
        Summary.FooterSummaryItems.Items[i].BeginUpdate;
        Summary.Calculate;
        Summary.FooterSummaryItems.Items[i].EndUpdate;
      end;
}
    end
    else
    begin
      DataHasChanged := true;

      {$IFDEF BoldDevExLog}
      _Log((GetOwner as TComponent).Name + ':DataChanged3', className);
      {$ENDIF}
    end;
  finally
    if (Summary.FooterSummaryItems.IndexOfItemLink(lItem) <> -1) or (Assigned(Summary.SummaryGroups.FindByItemLink(lItem))) then
      Summary.Recalculate;
    dec(FSkipMakeCellUptoDate);
  end;
end;

procedure TcxGridBoldDataController.BeginFullUpdate;
begin
  GridView.BeginUpdate;
  inherited;
end;

function TcxGridBoldDataController.BoldSetValue(AItemHandle: TcxDataItemHandle;
  ACellFollower: TBoldFollower; const AValue: variant): boolean;
var
  lcxCustomGridTableItem: TcxCustomGridTableItem;
  lcxBoldEditProperties: IcxBoldEditProperties;
  lEdit: TcxCustomEdit;
begin
  lcxCustomGridTableItem := GetItem(Integer(AItemHandle)) as TcxCustomGridTableItem;
  if Supports(lcxCustomGridTableItem.GetProperties, IcxBoldEditProperties, lcxBoldEditProperties) then
  begin
    lEdit := Controller.EditingController.Edit;
    lcxBoldEditProperties.SetStoredValue(AValue, nil, lEdit, ACellFollower, result);
  end;
end;

procedure TcxGridBoldDataController.EndFullUpdate;
begin
  if (not GridView.IsDestroying) and (not GridView.IsLoading) then
  begin
    TBoldQueueable.DisplayAll;
    if BoldHandleFollower.IsInDisplayList then
    begin
      TBoldListHandleFollowerAccess(BoldHandleFollower).Display;
      Assert(not BoldHandleFollower.IsInDisplayList);
    end;
  end;
  inherited;
  GridView.EndUpdate;
end;

procedure TcxGridBoldDataController.EnsureConstraintColumn;
var
  lItem: TcxCustomGridTableItemAccess;
begin
  lItem := TcxCustomGridTableItemAccess(GetItemByExpression(cOCLConstraint));
  if not Assigned(lItem) then
    lItem := TcxCustomGridTableItemAccess(InternalCreateItem(GridView, cOCLConstraint, '§', 'Boolean', 'Constraints'));
  lItem.OnCustomDrawCell := ConstraintColumnCustomDrawCell;
  lItem.Index := 0;
  lItem.BestFitMaxWidth := 16;
  lItem.Width := 16;
  lItem.MinWidth := 16;
  lItem.Options.Focusing := false;
  lItem.Options.Editing := false;
  lItem.Options.IncSearch := false;
  if lItem.Options is TcxGridColumnOptions then
  begin
    TcxGridColumnOptions(lItem.Options).HorzSizing := false;
    TcxGridColumnOptions(lItem.Options).Moving := false;
  end;
end;

type
  TcxCustomGridTableViewAccess = class(TcxCustomGridTableView);

function TcxGridBoldDataController.CanSelectRow(
  ARowIndex: Integer): Boolean;
begin
  Result := TcxCustomGridTableViewAccess(GridView).CanSelectRecord(ARowIndex);
end;

function TcxGridBoldDataController.CompareByField(ARecordIndex1,
  ARecordIndex2: Integer; AField: TcxCustomDataField;
  AMode: TcxDataControllerComparisonMode): Integer;
begin
  if GridView.ViewData.NeedsCustomDataComparison(AField, AMode) then
    Result := GridView.ViewData.CustomCompareDataValues(AField,
      GetComparedValue(ARecordIndex1, AField), GetComparedValue(ARecordIndex2, AField), AMode)
  else
    Result := inherited CompareByField(ARecordIndex1, ARecordIndex2, AField, AMode);
end;

function TcxGridBoldDataController.CreateDetailLinkObject(
  ARelation: TcxCustomDataRelation; ARecordIndex: Integer): TObject;
begin
  Result := TcxGridLevelAccess(ARelation.Item).CreateLinkObject(ARelation, ARecordIndex);
end;

procedure TcxGridBoldDataController.DoValueTypeClassChanged(
  AItemIndex: Integer);
begin
  inherited;
  TcxCustomGridTableViewAccess(GridView).ItemValueTypeClassChanged(AItemIndex);
end;

procedure TcxGridBoldDataController.FilterChanged;
begin
  inherited;
  TcxCustomGridTableViewAccess(GridView).FilterChanged;
end;

procedure TcxGridBoldDataController.FocusControl(AItemIndex: Integer;
  var Done: Boolean);
begin
  inherited;
  TcxCustomGridTableViewAccess(GridView).FocusEdit(AItemIndex, Done);
end;

function TcxGridBoldDataController.GetDefaultActiveRelationIndex: Integer;
begin
  Result := TcxCustomGridTableViewAccess(GridView).GetDefaultActiveDetailIndex;
end;

function TcxGridBoldDataController.GetDetailDataControllerByLinkObject(
  ALinkObject: TObject): TcxCustomDataController;
begin
  Result := TcxCustomGridView(ALinkObject).DataController;
end;

function TcxGridBoldDataController.GetDisplayText(ARecordIndex,
  AItemIndex: Integer): string;
begin
  if not GridView.ViewData.GetDisplayText(ARecordIndex, AItemIndex, Result) then
    Result := inherited GetDisplayText(ARecordIndex, AItemIndex);
  TcxCustomGridTableItemAccess(GridView.Items[AItemIndex]).DoGetDataText(ARecordIndex, Result);
end;

function TcxGridBoldDataController.GetFilterDataValue(
  ARecordIndex: Integer; AField: TcxCustomDataField): Variant;
begin
  Result := inherited GetFilterDataValue(ARecordIndex, AField);
  if GridView.ViewData.HasCustomDataHandling(AField, doFiltering) then
    Result := GridView.ViewData.GetCustomDataValue(AField, Result, doFiltering);
end;

function TcxGridBoldDataController.GetFilterDisplayText(ARecordIndex,
  AItemIndex: Integer): string;
begin
  if GridView.ViewData.HasCustomDataHandling(Fields[AItemIndex], doFiltering) then
    Result := GridView.ViewData.GetCustomDataDisplayText(ARecordIndex, AItemIndex, doFiltering)
  else
    Result := inherited GetFilterDisplayText(ARecordIndex, AItemIndex);
end;

function TcxGridBoldDataController.GetFilterItemFieldCaption(
  AItem: TObject): string;
begin
  Result := TcxCustomGridTableItemAccess(AItem).FilterCaption;
end;

function TcxGridBoldDataController.GetItemID(AItem: TObject): Integer;
begin
  if AItem is TcxCustomGridTableItem then
    Result := TcxCustomGridTableItem(AItem).ID
  else
    Result := -1;
end;

function TcxGridBoldDataController.GetItemSortByDisplayText(
  AItemIndex: Integer; ASortByDisplayText: Boolean): Boolean;
begin
  Result := TcxCustomGridTableViewAccess(GridView).GetItemSortByDisplayText(AItemIndex, ASortByDisplayText);
end;

function TcxGridBoldDataController.GetItemValueSource(
  AItemIndex: Integer): TcxDataEditValueSource;
begin
  Result := TcxCustomGridTableViewAccess(GridView).GetItemValueSource(AItemIndex);
end;

function TcxGridBoldDataController.GetSortingBySummaryEngineClass: TcxSortingBySummaryEngineClass;
begin
  Result := GridView.ViewData.GetSortingBySummaryEngineClass;
end;

procedure TcxGridBoldDataController.UpdateData;
begin
  inherited;
  TcxCustomGridTableViewAccess(GridView).UpdateRecord;
end;


procedure TcxGridBoldDataController.DoDragOver(
  Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
{$IFNDEF AttracsBold}
  function IncludesAll(Self: TBoldList; aList: TBoldList): Boolean;
  var
    i: integer;
  begin
    result := true;
    for i := 0 to aList.Count - 1 do
    begin
      if not self.includes(aList[i]) then
      begin
        result := false;
        exit;
      end;
    end;
  end;
{$ENDIF}
var
  lcxGridSite: TcxGridSite;
  lcxCustomGridHitTest: TcxCustomGridHitTest;
  lcxGridRecordCellHitTest: TcxGridRecordCellHitTest;
  lBoldRoleRTInfo: TBoldRoleRTInfo;
  lBoldList: TBoldList;
begin
  Accept := false;
  lcxGridSite := TcxGridSite(Sender);
  lcxCustomGridHitTest := lcxGridSite.ViewInfo.GetHitTest(X, Y);
  lBoldList := BoldHandle.MutableList;
  if Assigned(lBoldList) then
  begin
    lBoldRoleRTInfo := lBoldList.BoldMemberRTInfo as TBoldRoleRTInfo;
    // not allowed for association classes
    Accept := not Assigned(lBoldRoleRTInfo) or not (lBoldRoleRTInfo.RoleType = rtLinkRole);
    // do not allow drag in a single grid if the list is a member and is not ordered
    Accept := Accept and not ((TcxDragControlObject(Source).Control = Sender) and (Assigned(lBoldRoleRTInfo) and not lBoldRoleRTInfo.IsOrdered));
    // do not allow drop in the system owned class list (ie all instances)
    Accept := Accept and not (lBoldList.OwningElement is TBoldSystem);
    // accept drop only where applicable
    Accept := Accept and ((lcxCustomGridHitTest is TcxGridViewNoneHitTest) or (lcxCustomGridHitTest is TcxGridRecordCellHitTest));
    // do not allow drop after the last row of the grid if the dragged item is already last in the list
    if Accept and (lcxCustomGridHitTest is TcxGridViewNoneHitTest) and (TcxDragControlObject(Source).Control = Sender) then
    begin
      Accept := Follower.CurrentIndex <> Follower.SubFollowerCount - 1;
    end
    else
      if Accept and (lcxCustomGridHitTest is TcxGridRecordCellHitTest) and (TcxDragControlObject(Source).Control = Sender) then
      begin
        lcxGridRecordCellHitTest := TcxGridRecordCellHitTest(lcxCustomGridHitTest);
      // do not allow source and desination row to be same if drag within single grid
        Accept := Accept and (lcxGridRecordCellHitTest.GridRecord.RecordIndex <> FocusedRecordIndex);
      end;
    // check if destination already contains all source objects (and the desination is not ordered)
    if Accept and Assigned(lBoldRoleRTInfo) and not lBoldRoleRTInfo.IsOrdered and
     {$IFDEF AttracsBold}lBoldList.IncludesAll(BoldGUIHandler.DraggedObjects){$ELSE}
     IncludesAll(lBoldList, BoldGUIHandler.DraggedObjects)
     {$ENDIF}
      then
      Accept := false;
  end;
  Accept := Accept and BoldProperties.DragOver(Follower, BoldHandle.MutableList, Y);
end;

procedure TcxGridBoldDataController.DoDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  i: integer;
  lIndex: integer;
  lcxCustomGridHitTest: TcxCustomGridHitTest;
  lcxGridSite: TcxGridSite;
begin
  lcxGridSite := TcxGridSite(Sender);
  lcxCustomGridHitTest := lcxGridSite.ViewInfo.GetHitTest(X, Y);

  lIndex := -1;
  if lcxCustomGridHitTest is TcxGridRecordCellHitTest then
  begin
    lIndex := TcxGridRecordCellHitTest(lcxCustomGridHitTest).GridRecord.RecordIndex;
  end;

  BoldProperties.DragDrop(Follower, BoldHandle.MutableList, lIndex);
  TcxBoldDataSource(CustomDataSource).fIsBoldInitiatedChange := true;
  try
    {$IFDEF DisplayAll}
    TBoldQueueable.DisplayAll;
    {$ENDIF}
    CustomDataSource.DataChanged;
    BeginUpdate;
    try
      ClearSelection;
      for I := 0 to BoldGUIHandler.DraggedObjects.Count - 1 do
      begin
        lIndex := BoldHandle.List.IndexOf(BoldGUIHandler.DraggedObjects[i]);
        if lIndex < RowCount then
          ChangeRowSelection(lIndex, True);
      end;
    finally
      EndUpdate;
    end;
  finally
    TcxBoldDataSource(CustomDataSource).fIsBoldInitiatedChange := false
  end;
end;

procedure TcxGridBoldDataController.DoEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  BoldProperties.EndDrag;
end;

procedure TcxGridBoldDataController.DoStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  {$IFDEF DisplayAll}
  TBoldQueueable.DisplayAll;
  {$ENDIF}
  SelectionChanged; // make sure the follower selection is updated
  BoldProperties.StartDrag(Follower);
end;

{ TcxGridItemBoldDataBinding }

procedure TcxGridItemBoldDataBinding.Assign(Source: TPersistent);
begin
  if Source is TcxGridItemBoldDataBinding then
    fBoldProperties.Assign(TcxGridItemBoldDataBinding(Source).BoldProperties);
  inherited;
end;

constructor TcxGridItemBoldDataBinding.Create(
  AItem: TcxCustomGridTableItem);
begin
  inherited Create(AItem);
  fSubscriber := TBoldPassthroughSubscriber.Create(Receive);
  fBoldProperties := TBoldCxGridVariantFollowerController.Create(DataController.GetOwnerOrView);
  (fBoldProperties as TBoldCxGridVariantFollowerController).cxGridItemBoldDataBinding := self;
  fBoldProperties.ApplyPolicy := bapExit;
  DataController.fBoldColumnsProperties.Add(fBoldProperties);
  fBoldProperties.OnGetContextType := DataController.GetHandleStaticType;
  fBoldProperties.AddSmallSubscription(fSubscriber, [beValueChanged], beValueChanged);
//  FBoldProperties.AfterMakeUptoDate := DataController._AfterMakeCellUptoDate;
  Data := TObject(DataController.fBoldColumnsProperties.Count-1);
//  (DefaultValuesProvider as TcxGridBoldDefaultValuesProvider).BoldHandleFollower := DataController.BoldHandleFollower;
//  (DefaultValuesProvider as TcxGridBoldDefaultValuesProvider).BoldProperties := fBoldProperties;
end;

destructor TcxGridItemBoldDataBinding.Destroy;
begin
  FreeAndNil(FBoldProperties);
  FreeAndNil(fSubscriber);
  inherited;
end;

function TcxGridItemBoldDataBinding.GetDataController: TcxGridBoldDataController;
begin
  Result := TcxGridBoldDataController(inherited DataController);
end;

function TcxGridItemBoldDataBinding.GetDefaultValueTypeClass: TcxValueTypeClass;
begin
  Result := TcxStringValueType;
end;

{$IFDEF DevExChanges}
procedure TcxGridItemBoldDataBinding.GetFilterValues(
  AValueList: TcxGridFilterValueList; AValuesOnly, AInitSortByDisplayText,
  ACanUseFilteredValues: Boolean);
var
  StoredLoadAll: boolean;
begin
  StoredLoadAll := DataController.fLoadAll;
  DataController.fLoadAll := true;
  try
    DataController.AdjustActiveRange(DataController.Follower.Element as TBoldObjectList, Item.Index);
    inherited;
  finally
    DataController.fLoadAll := StoredLoadAll;
  end;
end;

{$ENDIF}

procedure TcxGridItemBoldDataBinding.Init;
begin
  inherited;
  with Item do
  if BoldProperties.Expression = cOCLConstraint then
  begin
    OnCustomDrawCell := DataController.ConstraintColumnCustomDrawCell;
    OnGetCellHint := DataController.GetCellHint;
  end
  else
  begin
    if not Assigned(OnCustomDrawCell) then    
      OnCustomDrawCell := DataController.ColumnCustomDrawCell;
  end;
end;

procedure TcxGridItemBoldDataBinding.SetBoldProperties(
  Value: TBoldVariantFollowerController);
begin
  if Assigned(Value) then
    fBoldProperties.Assign(Value);
end;

procedure TcxGridItemBoldDataBinding.Receive(Originator: TObject;
  OriginalEvent: TBoldEvent; RequestedEvent: TBoldRequestedEvent);
var
  lContextType: TBoldElementTypeInfo;
  lResultType: TBoldElementTypeInfo;
  lBoldMemberRTInfo: TBoldMemberRTInfo;
  lEvaluator: TBoldOcl;
begin
  if not GridView.IsLoading and not DataController.fCreatingColumns then
    if Assigned(DataController.BoldHandle) and Assigned(DataController.BoldHandle.ListElementType) then
    begin
      lContextType := DataController.BoldHandle.ListElementType;
      lEvaluator := lContextType.Evaluator as TBoldOcl;
      Assert(Assigned(lEvaluator));
      lResultType := lEvaluator.ExpressionType(BoldProperties.Expression, lContextType, false, BoldProperties.VariableList);
      if Assigned(lResultType) then
      begin
        DataController.SetValueTypeAndProperties(lResultType, Item, (Item.RepositoryItem = nil) and (Item.PropertiesClassName = ''));
      end;
      if (Item.Caption = '') then
      begin
        lBoldMemberRTInfo := lEvaluator.RTInfo(BoldProperties.Expression, lContextType, false{$IFDEF AttracsBold}, BoldProperties.VariableList{$ENDIF});
        if Assigned(lBoldMemberRTInfo) then
        begin
          Item.Caption := lBoldMemberRTInfo.ModelName;
        end;
      end;
    end;
end;

procedure TcxGridItemBoldDataBinding.Remove;
{$IFNDEF AttracsBold}
  function IndexOfController(Self: TBoldControllerList; ABoldFollowerController: TBoldFollowerController): integer;
  var
    i: integer;
  begin
    for i := 0 to self.count - 1 do
      if self.Items[i] = ABoldFollowerController then
      begin
        result := i;
        exit;
      end;
    result := -1;
  end;
{$ENDIF}
var
  i: integer;
  lBoldColumnsProperties: TBoldControllerList;
  lcxGridItemBoldDataBinding: TcxGridItemBoldDataBinding;
begin
  DataController.fBoldColumnsProperties.Remove(fBoldProperties);
  if (not GridView.IsDestroying) then
  begin
    lBoldColumnsProperties := DataController.fBoldColumnsProperties;
    for I := 0 to DataController.ItemCount - 1 do
    begin
      lcxGridItemBoldDataBinding := ((DataController.GetItem(i) as TcxCustomGridTableItem).DataBinding as TcxGridItemBoldDataBinding);
{$IFDEF AttracsBold}
      lcxGridItemBoldDataBinding.Data := TObject(lBoldColumnsProperties.IndexOf(lcxGridItemBoldDataBinding.fBoldProperties));
{$ELSE}
      lcxGridItemBoldDataBinding.Data := TObject(IndexOfController(lBoldColumnsProperties, lcxGridItemBoldDataBinding.fBoldProperties));
{$ENDIF}
    end;
  end;
  inherited;
end;

function TcxGridItemBoldDataBinding.GetBoldProperties: TBoldVariantFollowerController;
begin
  result := fBoldProperties;
end;

{ TcxBoldDataController }

function TcxBoldDataController.GetBoldHandle: TBoldAbstractListHandle;
begin
  if not assigned(fBoldHandleFollower) then
    result := nil
  else
    Result := fBoldHandleFollower.BoldHandle;
end;

procedure TcxBoldDataController.SetBoldHandle(
  const Value: TBoldAbstractListHandle);
begin
  if fBoldHandleFollower.BoldHandle <> Value then
  begin
    CustomDataSource.free;
    CustomDataSource := nil;
    fBoldHandleFollower.BoldHandle := value;
  end;
end;

function TcxBoldDataController.GetBoldHandleIndexLock: Boolean;
begin
  Result := fBoldHandleFollower.HandleIndexLock;
end;

procedure TcxBoldDataController.SetBoldHandleIndexLock(
  const Value: Boolean);
begin
  fBoldHandleFollower.HandleIndexLock := Value;
end;

procedure TcxBoldDataController.SetController(
  const Value: TBoldListAsFollowerListController);
begin
  fBoldProperties.Assign(Value);
end;

procedure TcxBoldDataController.SetDataChanged(const Value: boolean);
begin
  if fDataChanged = value then
    Exit;
  fDataChanged := Value;
  if Value then
    BoldInstalledQueue.AddEventToPostDisplayQueue(DataChangedEvent, nil, self)
  else
    BoldInstalledQueue.RemoveFromPostDisplayQueue(self);
end;

procedure TcxBoldDataController.SetRecNo(const Value: Integer);
begin
  fBoldHandleFollower.SetFollowerIndex(Value);
end;

constructor TcxBoldDataController.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fBoldColumnsProperties := TBoldControllerList.Create(AOwner{GridView});
  fBoldProperties := TBoldListAsFollowerListController.Create(AOwner{GridView}, fBoldColumnsProperties);
  fBoldHandleFollower := TBoldListHandleFollower.Create(AOwner{GridView}, fBoldProperties);
  Options := Options + [dcoImmediatePost];
  fSubscriber := TBoldPassthroughSubscriber.Create(Receive);

  if GetOwner is TcxComponent and TcxComponent(GetOwner).IsDesigning then
  begin
    // nothing needed at design time
  end
  else
  begin
//  don't need insert before we hook up datasource in _AfterMakeListUptoDate, so will set it there
//    fBoldProperties.OnAfterInsertItem := _InsertRow;
    fBoldProperties.OnAfterDeleteItem := _DeleteRow;
    fBoldProperties.AfterMakeUptoDate := _AfterMakeListUptoDate;
    fBoldProperties.BeforeMakeUptoDate := _BeforeMakeListUptoDate;
    fBoldProperties.OnGetContextType := GetHandleStaticType;
  end;
  fBoldProperties.OnGetContextType := GetHandleStaticType;
end;

procedure TcxBoldDataController.DataChangedEvent(Sender: TObject);
begin
  {$IFDEF BoldDevExLog}
  _Log('DataChanged Dequeued', className);
  {$ENDIF}
  AdjustActiveRange();
  DataChanged(dcTotal, -1, -1);
  DataHasChanged := false;
//  self.Refresh;
  CheckDataSetCurrent;
end;

destructor TcxBoldDataController.Destroy;
begin
  BoldInstalledQueue.RemoveFromPostDisplayQueue(Self);
  fBoldProperties.OnAfterInsertItem := nil;
  fBoldProperties.OnAfterDeleteItem := nil;
  FreeAndNil(fBoldHandleFollower);
  FreeAndNil(fBoldProperties);
  CustomDataSource.Free;
  CustomDataSource := nil;
  FreeAndNil(fBoldColumnsProperties);
  FreeAndNil(fSubscriber);
  FreeAndNil(fSelection);
  inherited Destroy;
end;


procedure TcxBoldDataController._BeforeMakeListUpToDate(
  Follower: TBoldFollower);
var
  i: integer;
begin
  {$IFDEF BoldDevExLog}
  _Log((GetOwner as TComponent).Name + ':_BeforeMakeListUpToDate:' + IntToStr(FSkipMakeCellUptoDate), className);
  {$IFDEF AttracsBold}
  _Log(Follower.ContextString, className);
  {$ENDIF}
  {$ENDIF}
  inc(FSkipMakeCellUptoDate);
  BeginFullUpdate;

  if GetOwner is TcxComponent and TcxComponent(GetOwner).IsDesigning then exit;

  if (Assigned(CustomDataSource) and (GetHandleListElementType <> fCurrentListElementType)) or (not Assigned(CustomDataSource) and Assigned(fCurrentListElementType)) then
  begin
    fFetchedAll := false;
    CustomDataSource.free;
    fBoldProperties.OnAfterInsertItem := nil;
    fBoldProperties.OnAfterDeleteItem := nil;
  end;
  if (CustomDataSource = nil) then
  begin
// TODO:
//    if Assigned(OnBeforeLoad) then
//      OnBeforeLoad(GridView);
  end;
  if (CustomDataSource = nil) or (Follower.SubFollowerCount = 0) then
  begin
//    if not LoadAll then
    // we need to set ActiveRange here, otherwise all followers will be active and all objects will be fetched
      BoldProperties.SetActiveRange(Follower, 0, -1, 0);
  end;
  if Assigned(CustomDataSource) then
    TcxBoldDataSource(CustomDataSource).fIsBoldInitiatedChange := true;
  for i := 0 to ItemCount - 1 do
  begin
    BoldPropertiesFromItem(i).AfterMakeUptoDate := nil;
  end;
end;

procedure TcxBoldDataController._AfterMakeListUptoDate(
  Follower: TBoldFollower);
var
  lcxBoldDataSource: TcxBoldDataSource;
  lFirstLoad: boolean;
  i: integer;
begin
  {$IFDEF BoldDevExLog}
  _Log((GetOwner as TComponent).Name + ':_AfterMakeListUpToDate:' + IntToStr(FSkipMakeCellUptoDate), className);
  {$ENDIF}

  lFirstLoad := (CustomDataSource = nil);
  if lFirstLoad then
  begin
    lcxBoldDataSource := cxBoldDataSourceClass.Create(self);
    CustomDataSource := lcxBoldDataSource;
    TypeMayHaveChanged;
  end;
  dec(FSkipMakeCellUptoDate);

    CustomDataSource.DataChanged;
    for i := 0 to ItemCount - 1 do
    begin
      BoldPropertiesFromItem(i).AfterMakeUptoDate := _AfterMakeCellUptoDate;
    end;

  EndFullUpdate;

    if Assigned(CustomDataSource) then
      TcxBoldDataSource(CustomDataSource).fIsBoldInitiatedChange := false;
    fBoldProperties.OnAfterInsertItem := _InsertRow;
    fBoldProperties.OnAfterDeleteItem := _DeleteRow;
end;

{$IFNDEF AttracsBold}
procedure TcxBoldDataController._InsertRow(Follower: TBoldFollower);
{$ELSE}
procedure TcxBoldDataController._InsertRow(index: Integer; Follower: TBoldFollower);
{$ENDIF}
begin
  DataHasChanged := true;
  fBoldProperties.OnAfterInsertItem := nil;
  fBoldProperties.OnAfterDeleteItem := nil;
end;

procedure TcxBoldDataController._DeleteRow(index: Integer;
  owningFollower: TBoldFollower);
begin
  DataHasChanged := true;
  fBoldProperties.OnAfterInsertItem := nil;
  fBoldProperties.OnAfterDeleteItem := nil;
end;

function TcxBoldDataController.GetHandleStaticType: TBoldElementTypeInfo;
begin
  if assigned(BoldHandle) then
    result := BoldHandle.StaticBoldType
  else
    result := nil;
end;

procedure TcxBoldDataController._AfterMakeCellUptoDate(
  Follower: TBoldFollower);
begin
// TODO: ?
end;

function TcxBoldDataController.GetFollower: TBoldFollower;
begin
  Assert(Assigned(fBoldHandleFollower), 'Assigned(fBoldHandleFollower)1');
  Result := fBoldHandleFollower.Follower;
end;

function TcxBoldDataController.GetCellFollower(ListCol, DataRow: Integer): TBoldFollower;
var
  lRowFollower: TBoldFollower;
begin
  lRowFollower := GetRowFollower(DataRow);
  if assigned(lRowFollower) and
    (ListCol >= 0) and
    (listCol < lRowFollower.SubFollowerCount) then
    Result := lRowFollower.SubFollowers[ListCol]
  else
    result := nil;
end;

function TcxBoldDataController.GetDataProviderClass: TcxCustomDataProviderClass;
begin
  Result := TcxBoldCustomDataProvider;
end;

function TcxBoldDataController.GetRecNo: Integer;
begin
  result := Follower.CurrentIndex;
end;

function TcxBoldDataController.GetRecordCount: Integer;
begin
  if (DetailMode = dcdmPattern) or not Assigned(TcxCustomDataProviderAccess(provider).CustomDataSource) then
    result := inherited GetRecordCount
  else
  begin
    Result := TcxBoldDataSource(TcxCustomDataProviderAccess(provider).CustomDataSource).GetRecordCount;
  end;
end;

function TcxBoldDataController.GetRowFollower(
  DataRow: Integer): TBoldFollower;
var
  lFollower: TBoldFollower;
begin
  lFollower := Follower;
  if datarow < lFollower.SubFollowerCount then
    Result := lFollower.SubFollowers[DataRow]
  else
    result := nil;
end;

function TcxBoldDataController.GetSearchClass: TcxDataControllerSearchClass;
begin
  result := TcxBoldDataControllerSearch;
end;

function TcxBoldDataController.IsDataLinked: Boolean;
begin
  Result := BoldHandle <> nil;
end;

function TcxBoldDataController.IsSmartRefresh: Boolean;
begin
  result := false;
end;

procedure TcxBoldDataController.AdjustActiveRange(aList: TBoldObjectList = nil; aItem: integer = -1);
var
  i,j: integer;
  lFrom, lTo: integer;
  lFollower: TBoldFollower;
  vWholeList: TBoldObjectList;
begin
  lFollower := Follower;
  if Assigned(lFollower) and Assigned(lFollower.element) and (lFollower.Element is TBoldList) then
  begin
    if (aList = nil) or LoadAll or not (lFollower.Element is TBoldObjectList) or (TBoldObjectList(lFollower.Element).DuplicateMode = bldmAllow)  then
    begin
      lFrom := 0;
      lTo := lFollower.SubFollowerCount-1;
    end
    else
    begin
      Assert(lFollower.Element is TBoldObjectList);
      lFrom := maxInt;
      lTo := 0;
      vWholeList := (lFollower.Element as TBoldObjectList);
      for I := 0 to aList.Count - 1 do
      begin
        j := vWholeList.IndexOfLocator(aList.Locators[i]);
        lFrom := Min(lFrom, j);
        lTo := max(lTo, j);
      end;
    end;
    {$IFDEF BoldDevExLog}
    _Log((GetOwner as TComponent).Name + ':ActiveRange:' + IntToStr(lFrom) + ':' + IntToStr(lTo) + ',' + IntToStr(aItem), className);
    {$ENDIF}
    for i := 0 to ItemCount - 1 do
    begin
      BoldPropertiesFromItem(i).AfterMakeUptoDate := nil;
    end;
    fBoldProperties.OnAfterInsertItem := nil;
    fBoldProperties.OnAfterDeleteItem := nil;
    try
      if RequiresAllRecords or LoadAll then
        BoldProperties.SetActiveRange(lFollower, 0, lFollower.SubFollowerCount-1, 0)
      else
        BoldProperties.SetActiveRange(lFollower, lFrom, lTo, 0);
      if aList = nil then
        PreFetchColumns(lFollower.Element as TBoldList, aItem)
      else
        PreFetchColumns(aList, aItem);
    finally
      if not DataHasChanged then
      begin
        fBoldProperties.OnAfterInsertItem := _InsertRow;
        fBoldProperties.OnAfterDeleteItem := _DeleteRow;
      end;
      for i := 0 to ItemCount - 1 do
      begin
        BoldPropertiesFromItem(i).AfterMakeUptoDate := _AfterMakeCellUptoDate;
      end;
    end;
  end;
end;

procedure TcxBoldDataController.AdjustActiveRange(aRecordIndex: integer; aItem: integer = -1);
var
  lList: TBoldObjectList;
begin
  if (Follower.Element is TBoldObjectList) and (aRecordIndex >= 0) and (aRecordIndex < TBoldObjectList(Follower.Element).Count) then
  begin
    lList := TBoldObjectList.Create;
    try
      lList.Add( TBoldObjectList(Follower.Element)[aRecordIndex]);
      AdjustActiveRange(lList, aItem);
    finally
      lList.free;
    end;
  end;
end;

function TcxBoldDataController.TypeMayHaveChanged: boolean;
var
  lNewListElementType: TBoldElementTypeInfo;
  lOldListElementType: TBoldElementTypeInfo;
begin
{$IFNDEF AttracsBold}
//  if BoldEffectiveEnvironment.RunningInIDE  then
//    Exit; // only update at runtime if there are values, avoids update on every UML model change.
{$ENDIF}
  result := false;
  if not Assigned(BoldHandle) or not Assigned(BoldHandle.List) then
  begin
    if Assigned(fCurrentListElementType) then
    begin
      lOldListElementType := fCurrentListElementType;
      fCurrentListElementType := nil;
      TypeChanged(nil, lOldListElementType);
      result := true;
    end;
  end
  else
  begin
    lNewListElementType := GetHandleListElementType;
    if (lNewListElementType <> fCurrentListElementType) then
    begin
      {$IFDEF BoldDevExLog}
      if Assigned(fCurrentListElementType) then
      begin
        if Assigned(lNewListElementType) then
          _Log((GetOwner as TComponent).Name + ':TypeMayHaveChanged:' + fCurrentListElementType.AsString + '->' + lNewListElementType.AsString, className)
        else
          _Log((GetOwner as TComponent).Name + ':TypeMayHaveChanged:' + fCurrentListElementType.AsString + '-> nil', className);
      end
      else
        _Log((GetOwner as TComponent).Name + ':TypeMayHaveChanged:' + lNewListElementType.AsString, className);
      {$ENDIF}
      lOldListElementType := fCurrentListElementType;
      fCurrentListElementType := lNewListElementType;
      TypeChanged(lNewListElementType, lOldListElementType);
      result := true;
    end;
  end;
end;

function TcxBoldDataController.GetHandleListElementType: TBoldElementTypeInfo;
begin
  if Assigned(BoldHandle) then
    Result := BoldHandle.ListElementType //BoldType
  else
    Result := nil;
end;

function TcxBoldDataController.BoldPropertiesFromItem(
  aIndex: integer): TBoldVariantFollowerController;
var
  lBoldAwareViewItem: IBoldAwareViewItem;
begin
  if GetItem(aIndex).GetInterface(IBoldAwareViewItem, lBoldAwareViewItem) then
    result := lBoldAwareViewItem.BoldProperties
  else
    result := nil;
end;

function TcxBoldDataController.BoldSetValue(AItemHandle: TcxDataItemHandle;
  ACellFollower: TBoldFollower; const AValue: variant): boolean;
begin
  result := false;
end;

function TcxBoldDataController.GetCurrentBoldObject: TBoldObject;
begin
  if GetCurrentElement is TBoldObject then
    result := TBoldObject(GetCurrentElement)
  else
    result := nil;
end;

function TcxBoldDataController.GetCurrentElement: TBoldElement;
var
  lFollower: TBoldFollower;
begin
  if CurrentIndex = -1 then
    result := nil
  else
  begin
    lFollower := Follower.SubFollowers[CurrentIndex];
    if Assigned(lFollower) then
      result := lFollower.Element
    else
      result := nil;
  end;
end;

function TcxBoldDataController.GetCurrentIndex: integer;
begin
  result := Follower.CurrentIndex;
end;


procedure TcxBoldDataController.Receive(Originator: TObject;
  OriginalEvent: TBoldEvent; RequestedEvent: TBoldRequestedEvent);
begin
  Assert(Originator = fSelection);
  fSelection := nil;
  raise EcxGridBoldSupport.Create('Grid Selection destroyed, do not free the grid selection !');
end;

function TcxBoldDataController.RequiresAllRecords(AItem: TObject): boolean;
begin
  result := true;
end;

function TcxBoldDataController.RequiresAllRecords: boolean;
begin
  result := true;
end;

procedure TcxBoldDataController.TypeChanged(aNewType, aOldType: TBoldElementTypeInfo);
begin
  fSubscriber.CancelAllSubscriptions;
  FreeAndNil(fSelection);
end;

function TcxBoldDataController.IsProviderMode: Boolean;
begin
  result := true;
end;

procedure TcxBoldDataController.PreFetchColumns(aList: TBoldList; aItem: integer);
begin
end;

function TcxBoldDataController.GetCurrentDetailDataController(ARelationIndex: integer = 0): TcxBoldDataController;
begin
  if CurrentIndex = -1 then
    result := nil
  else
    result := GetDetailDataController(CurrentIndex, ARelationIndex) as TcxBoldDataController;
end;

procedure TcxBoldDataController.FilterChanged;
begin
  fSkipCancel := true;
  try
    inherited;
  finally
    fSkipCancel := false;
  end;
end;

function TcxBoldDataController.FindItemByData(AData: Integer): TObject;
var
  I: Integer;
begin
  for I := 0 to ItemCount - 1 do
  begin
    Result := GetItem(I);
    if GetItemData(Result) = AData then
      Exit;
  end;
  Result := nil;
end;

function TcxBoldDataController.GetSelection: TBoldList;
var
  ListType: TBoldElementTypeInfo;
begin
  if not Assigned(fSelection) then
  begin
    if Assigned(fCurrentListElementType) then
    begin
      ListType := (fCurrentListElementType.SystemTypeInfo as TBoldSystemTypeInfo).ListTypeInfoByElement[fCurrentListElementType];
      fSelection := TBoldMemberFactory.CreateMemberFromBoldType(ListType) as TBoldList;
    end
    else
    begin
      fSelection := TBoldElementList.Create;
    end;
    fSelection.AddSubscription(fSubscriber, beDestroying, beDestroying);
    SelectionChanged;
  end;
  result := fSelection;
end;

procedure TcxBoldDataController.Cancel;
var
  i: integer;
  lRowFollower: TBoldFollower;
begin
  if fSkipCancel then
    exit;
  if FocusedRecordIndex = -1 then
    inherited
  else
  begin
    lRowFollower := Follower.SubFollowers[FocusedRecordIndex];
    for i := 0 to lRowFollower.SubFollowerCount - 1 do
    begin
      lRowFollower.SubFollowers[i].DiscardChange;
    end;
  end;
end;

procedure TcxBoldDataController.SelectionChanged;
begin
// do nothing
end;

function TcxBoldDataController.GetBoldList: TBoldList;
begin
  result := Follower.Element as TBoldList;
end;

{ TcxBoldDataSource }

constructor TcxBoldDataSource.Create(
  aBoldDataController: TcxBoldDataController);
begin
  inherited Create;
  fBoldDataController := aBoldDataController;
end;

function TcxBoldDataSource.GetRecordCount: Integer;
begin
  result := fBoldDataController.Follower.SubFollowerCount;
  {$IFDEF BoldDevExLog}
//  if Assigned(provider) then
//    _Log((TcxBoldDataController(DataController).GetOwner as TComponent).Name + ':GetRecordCount: ' + intToStr(result), className);
  {$ENDIF}
end;

function TcxBoldDataSource.GetValue(ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle): Variant;
var
  lRowFollower: TBoldFollower;
  lCellFollower: TBoldFollower;
  lItemIndex: integer;
  lRecordIndex: integer;
  lActualElement: TBoldElement;
  lItem: TObject;
  lcxBoldDataController: TcxBoldDataController;
  lBoldAwareViewItem: IBoldAwareViewItem;
  {$IFNDEF AttracsBold}
  lIE: TBoldIndirectElement;
  lGuard: IBoldGuard;
  {$ELSE}
  {$ENDIF}
  lIcxBoldEditProperties: IcxBoldEditProperties;
begin
  result := Null;
  lcxBoldDataController := DataController as TcxBoldDataController;

  if lcxBoldDataController.BoldHandleFollower.IsInDisplayList then
  begin
    TBoldListHandleFollowerAccess(lcxBoldDataController.BoldHandleFollower).Display;
    Assert(not lcxBoldDataController.BoldHandleFollower.IsInDisplayList, 'HandleFollower still in DisplayList after calling Display');
  end;

  inc(lcxBoldDataController.FSkipMakeCellUptoDate);
  try
    lItemIndex := Integer(AItemHandle);
    lRecordIndex := Integer(ARecordHandle);
    lItem := lcxBoldDataController.FindItemByData(lItemIndex);
    Assert(Assigned(lItem), 'lItem not found for index '+ IntToStr(lItemIndex));
    Assert(lItem.GetInterface(IBoldAwareViewItem, lBoldAwareViewItem), 'lItem.GetInterface(IBoldAwareViewItem, lBoldAwareViewItem)1');

    with (lcxBoldDataController.Follower.RendererData as TBoldFollowerList) do
    if (lRecordIndex < FirstActive) or (lRecordIndex > LastActive) then
    begin
      fBoldDataController.AdjustActiveRange(nil, lItemIndex);
    end;

    lRowFollower := lcxBoldDataController.Follower.SubFollowers[lRecordIndex];
    if not Assigned(lRowFollower) then
    begin
      fBoldDataController.AdjustActiveRange(lRecordIndex, lItemIndex);
      lRowFollower := lcxBoldDataController.Follower.SubFollowers[lRecordIndex];
      if not Assigned(lRowFollower) then
      begin
        TBoldFollowerAccess(TBoldFollowerAccess(lcxBoldDataController.Follower).MostPrioritizedQueuable).Display;
        lRowFollower := lcxBoldDataController.Follower.SubFollowers[lRecordIndex];
        if not Assigned(lRowFollower) then
          fBoldDataController.AdjustActiveRange();
        lRowFollower := lcxBoldDataController.Follower.SubFollowers[lRecordIndex];
        Assert(Assigned(lRowFollower), IntToStr(lRecordIndex) + ':' + lcxBoldDataController.Follower.Controller.GetNamePath);
      end;
    end;

    if (not lRowFollower.Displayable) and ((lRowFollower.State <> bfsInactiveInvalidElement)) then
    begin
      lRowFollower.EnsureDisplayable;
    end;

    Assert(lItemIndex < lRowFollower.SubFollowerCount, 'lItemIndex < lRowFollower.SubFollowerCount' +IntToStr(lItemIndex) + '/' +IntToStr(lRowFollower.SubFollowerCount) );
    if not lRowFollower.SubFollowers[lItemIndex].ElementValid then
      fBoldDataController.AdjustActiveRange(nil, lItemIndex);
    lCellFollower := lRowFollower.SubFollowers[lItemIndex];
    Assert(Assigned(lCellFollower), 'lCellFollower = nil');
    Assert(Assigned(lCellFollower.Controller), 'lCellFollower.Controller = nil');
    if not lCellFollower.Displayable then
    begin
      if not lCellFollower.ElementValid then
        fBoldDataController.AdjustActiveRange(lRecordIndex, lItemIndex);
      lCellFollower.EnsureDisplayable;
    end;
    if (lItem is TcxCustomGridTableItem) and Supports(TcxCustomGridTableItemAccess(lItem).GetProperties, IcxBoldEditProperties, lIcxBoldEditProperties) then
    begin
      {$IFNDEF AttracsBold}
      lGuard := TBoldGuard.Create(lIE);
      lIE := TBoldIndirectElement.Create;
      lCellFollower.Element.EvaluateExpression(TBoldFollowerControllerAccess(lCellFollower.Controller).Expression, lIE, false, TBoldFollowerControllerAccess(lCellFollower.Controller).VariableList);
      lActualElement := lIE.Value;
      {$ELSE}
      lActualElement := lCellFollower.ActualElement;
      {$ENDIF}
      if Assigned(lActualElement) then
      begin
        result := lIcxBoldEditProperties.BoldElementToEditValue(lCellFollower, lActualElement, nil);
      end
      else
      {$IFNDEF AttracsBold}
        result := (lCellFollower.Controller as TBoldVariantFollowerController).GetAsVariant(lCellFollower);
      {$ELSE}
        result := (lCellFollower.Controller as TBoldVariantFollowerController).GetCurrentAsVariant(lCellFollower);
      {$ENDIF}
    end
    else
    begin
    {$IFNDEF AttracsBold}
      result := (lCellFollower.Controller as TBoldVariantFollowerController).GetAsVariant(lCellFollower);
    {$ELSE}
      result := (lCellFollower.Controller as TBoldVariantFollowerController).GetCurrentAsVariant(lCellFollower);
    {$ENDIF}
    end;
  finally
    dec(lcxBoldDataController.FSkipMakeCellUptoDate);
  end;
end;

procedure TcxBoldDataSource.SetValue(ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle; const AValue: Variant);
var
  lRowFollower: TBoldFollower;
  lCellFollower: TBoldFollower;
  lItemIndex: integer;
  lDone: boolean;
begin
  lItemIndex := Integer(AItemHandle);

  lRowFollower := fBoldDataController.Follower.SubFollowers[Integer(ARecordHandle)];
  Assert(Assigned(lRowFollower));

  inc(fBoldDataController.FSkipMakeCellUptoDate);
  try
    lRowFollower.EnsureDisplayable;
  finally
    dec(fBoldDataController.FSkipMakeCellUptoDate);
  end;
  lCellFollower := lRowFollower.SubFollowers[lItemIndex];

  lDone := fBoldDataController.BoldSetValue(AItemHandle, lCellFollower, AValue);

  if not lDone then
  begin
    (lCellFollower.Controller as TBoldVariantFollowerController).MayHaveChanged(aValue, lCellFollower);
  end;
  if (lCellFollower.State = bfsDirty) and (lCellFollower.Controller.ApplyPolicy <> bapDemand) then
  begin
    lCellFollower.Apply;
    {$IFDEF DisplayAll}
    inc(fBoldDataController.FSkipMakeCellUptoDate);
    try
      TBoldQueueable.DisplayAll;
    finally
      dec(fBoldDataController.FSkipMakeCellUptoDate);
    end;
    {$ENDIF}
  end;
end;

procedure TcxBoldDataSource.DeleteRecord(
  ARecordHandle: TcxDataRecordHandle);
var
  lRowFollower: TBoldFollower;
  lIndex: integer;
  lBoldObject: TBoldObject;
begin
  if not fIsBoldInitiatedChange then
  begin
    lIndex := Integer(ARecordHandle);
    lRowFollower := fBoldDataController.Follower.SubFollowers[lIndex];
    Assert(Assigned(lRowFollower));
    Assert(lIndex = lRowFollower.index);
    fIsBoldInitiatedChange := true;
    try
      {$IFDEF DisplayAll}
      TBoldQueueable.DisplayAll;
      {$ENDIF}
      lBoldObject := (lRowFollower.Element as TBoldObject);
      if Assigned(lBoldObject) then
        Assert(lBoldObject = fBoldDataController.BoldHandle.ObjectList[lIndex], 'lBoldObject = fBoldDataController.BoldHandle.ObjectList[lIndex]')
      else
        lBoldObject := fBoldDataController.BoldHandle.ObjectList[lIndex];

      if lBoldObject.BoldClassTypeInfo.IsLinkClass then
      begin
        if lBoldObject.BoldObjectExists then // not already deleted
          lBoldObject.delete;
      end
      else
      begin
        fBoldDataController.BoldHandle.MutableList.Remove(lBoldObject);
      end;
      {$IFDEF BoldDevExLog}
      _Log((TcxBoldDataController(DataController).GetOwner as TComponent).Name + ':DataChanged4', ClassName);
      {$ENDIF}
      DataChanged;
    finally
      fIsBoldInitiatedChange := false;
    end;
  end;
end;

function TcxBoldDataSource.GetDetailHasChildren(ARecordIndex,
  ARelationIndex: Integer): Boolean;
var
  lcxCustomDataController: TcxCustomDataController;
  lFollower: TBoldFollower;
  lOcl: string;
  Ie: TBoldIndirectElement;
  lDetailObject: TcxDetailObject;
  lObject: TObject;
  lGridLevel: TcxGridLevel;
  lcxCustomDataRelation: TcxCustomDataRelation;
  lPatternView: IBoldAwareView;
  lcxCustomDataProviderAccess: TcxCustomDataProviderAccess;
begin
  lcxCustomDataProviderAccess := TcxCustomDataProviderAccess(CurrentProvider);
  Assert(fBoldDataController = lcxCustomDataProviderAccess.DataController);
  result := false;

  if not (lcxCustomDataProviderAccess.DataController is TcxGridBoldDataController) then
    exit;
//  lDetailObject := fBoldDataController.GetDetailLinkObject(ARecordIndex, ARelationIndex) as TcxDetailObject;

  lDetailObject := lcxCustomDataProviderAccess.DataController.Relations.GetDetailObject(ARecordIndex);
  lObject := lDetailObject.LinkObjects[ARelationIndex];

  if Assigned(lObject) then
  begin
    lcxCustomDataController := lcxCustomDataProviderAccess.DataController.GetDetailDataController(ARecordIndex, ARelationIndex);
    result := lcxCustomDataController.RecordCount > 0;
  end
  else
  begin
    lcxCustomDataRelation := lcxCustomDataProviderAccess.DataController.Relations[ARelationIndex];
    lGridLevel := lcxCustomDataRelation.Item as TcxGridLevel;
    if lGridLevel.GridView.IsPattern and (lGridLevel.GridView <> TcxGridBoldDataController(lcxCustomDataProviderAccess.DataController).GridView) then
    begin
      lPatternView := (lGridLevel.GridView as IBoldAwareView);
      if Assigned(lPatternView.DataController.BoldHandle) and (lPatternView.DataController.BoldHandle is TBoldListHandle) then
      begin
        TBoldQueueable.DisplayAll;
        lOcl := (lPatternView.DataController.BoldHandle as TBoldListHandle).Expression;
        Ie := TBoldIndirectElement.Create;
        try
          TcxBoldDataController(lcxCustomDataProviderAccess.DataController).AdjustActiveRange();
          lFollower := TcxBoldDataController(lcxCustomDataProviderAccess.DataController).Follower.SubFollowers[ARecordIndex];
          if not Assigned(lFollower) or not Assigned(lFollower.Element) then
            exit;
          if (lPatternView.DataController.BoldHandle as TBoldListHandle).Variables <> nil then
            lFollower.Element.EvaluateExpression(lOcl, Ie, false, (lPatternView.DataController.BoldHandle as TBoldListHandle).Variables.VariableList)
          else
            lFollower.Element.EvaluateExpression(lOcl, Ie);
          if Ie.Value is TBoldList then
          begin
            result := TBoldList(Ie.Value).Count > 0;
          end
          else
            result := false; //Assigned(Ie.Value);
        finally
          Ie.free;
        end;
      end;
    end;
  end;
end;

function TcxBoldDataSource.GetItemHandle(
  AItemIndex: Integer): TcxDataItemHandle;
var
  lItem: TObject;
begin
  lItem := TcxCustomDataProviderAccess(CurrentProvider).DataController.GetItem(AItemIndex);
  if lItem is TcxCustomGridTableItem then
    result := TcxCustomGridTableItem(lItem).DataBinding.Data
  else
    result := TcxDataItemHandle(AItemIndex); // this handles cxLookupGrid which doesn't allow column moving so indexes are static
end;

function TcxBoldDataSource.GetRecordHandle(
  ARecordIndex: Integer): TcxDataRecordHandle;
begin
  result := TcxDataRecordHandle(ARecordIndex);
end;

{$IFDEF DevExChanges}
function TcxBoldDataSource.GetRecordHandleByIndex(
  ARecordIndex: Integer): TcxDataRecordHandle;
begin
  Result := TcxDataRecordHandle(ARecordIndex);
end;
{$ENDIF}

destructor TcxBoldDataSource.Destroy;
begin
  inherited;
end;

function TcxBoldDataSource.IsRecordIdSupported: Boolean;
begin
  result := true;
end;

procedure TcxBoldDataSource.LoadRecordHandles;
begin
{$IFDEF BoldDevExLog}
  if Assigned(fBoldDataController.BoldHandle) then
    _Log(fBoldDataController.BoldHandle.Name + ':' + IntToStr(GetRecordCount), 'recordhandles');
{$ENDIF}
  inherited;
end;

function TcxBoldDataSource.GetRecordId(
  ARecordHandle: TcxDataRecordHandle): Variant;
begin
  result := Integer(ARecordHandle);
end;

{ TcxGridBoldColumn }

function TcxGridBoldColumn.CalculateBestFitWidth: Integer;
begin
  GridView.OptionsBehavior.BestFitMaxRecordCount := GridView.ViewInfo.VisibleRecordCount;
  result := inherited CalculateBestFitWidth;
end;

destructor TcxGridBoldColumn.Destroy;
begin
  DataBinding.Remove;
  inherited;
end;

function TcxGridBoldColumn.GetDataBinding: TcxGridItemBoldDataBinding;
begin
  Result := TcxGridItemBoldDataBinding(inherited DataBinding);
end;

function TcxGridBoldColumn.GetProperties(AProperties: TStrings): Boolean;
begin
  AProperties.Add('Expression');
  Result := inherited GetStoredProperties(AProperties);
end;

procedure TcxGridBoldColumn.GetPropertyValue(const AName: string;
  var AValue: Variant);
begin
  if AName = 'Expression' then
    AValue := DataBinding.BoldProperties.expression
  else
    inherited;
end;

procedure TcxGridBoldColumn.SetDataBinding(
  Value: TcxGridItemBoldDataBinding);
begin
  inherited DataBinding := Value;
end;

procedure TcxGridBoldColumn.SetPropertyValue(const AName: string;
  const AValue: Variant);
begin
  if AName = 'Expression' then
    DataBinding.BoldProperties.expression := AValue
  else
    inherited;
end;

procedure TcxGridBoldColumn.VisibleChanged;
begin
  inherited;
//  if Visible and not IsLoading then
//    (DataController as TcxGridBoldDataController).AdjustActiveRange();
end;

{ TcxGridBoldTableView }

function TcxGridBoldTableView.DoCellDblClick(
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState): Boolean;
var
  lAutoForm: TForm;
  lElement: TBoldElement;
begin
  result := false;
  if DataController.BoldProperties.DefaultDblClick and not Controller.IsSpecialRowFocused and (DataController.Follower.CurrentIndex <> -1) then
  begin
    lElement := DataController.Follower.SubFollowers[DataController.Follower.CurrentIndex].Element;
    lAutoForm := AutoFormProviderRegistry.FormForElement(lElement);
    if assigned(lAutoForm) then
    begin
      result := true;
      lAutoForm.Show;
    end
  end;
  if not result then
  begin
    result := inherited DoCellDblClick(ACellViewInfo, AButton, AShift);
  end;
end;

function TcxGridBoldTableView.DoEditing(
  AItem: TcxCustomGridTableItem): Boolean;
begin
  if Controller.IsSpecialRowFocused then
  begin
    result := inherited DoEditing(aItem);
  end
  else
  begin
    result := DataController.DoEditing(AItem) and inherited DoEditing(aItem);
  end;
end;

procedure TcxGridBoldTableView.DoEditKeyPress(
  AItem: TcxCustomGridTableItem; AEdit: TcxCustomEdit; var Key: Char);
var
  lRecord: integer;
  lFollower: TBoldFollower;
begin
  lRecord := DataController.RecNo;
  if (lRecord <> -1) and (Key <> #8) and not Controller.IsSpecialRowFocused then
  begin
    lFollower := DataController.CellFollowers[AItem.ID, lRecord];
    if not (lFollower.AssertedController as TBoldVariantFollowerController).ValidateCharacter(key, lFollower) then
    begin
      key := #0;
    end;
  end;
  inherited;
end;

function TcxGridBoldTableView.GetSelection: TBoldList;
begin
  result := DataController.Selection;
end;

procedure TcxGridBoldTableView.DoSelectionChanged;
begin
  DataController.SelectionChanged;
  inherited;
end;

function TcxGridBoldTableView.GetViewInfoClass: TcxCustomGridViewInfoClass;
begin
  result := TcxGridBoldTableViewInfo;
end;

function TcxGridBoldTableView.GetControllerClass: TcxCustomGridControllerClass;
begin
  result := TcxGridBoldTableController;
end;

function TcxGridBoldTableView.GetDataController: TcxGridBoldDataController;
begin
  Result := TcxGridBoldDataController(FDataController);
end;

function TcxGridBoldTableView.GetDataControllerClass: TcxCustomDataControllerClass;
begin
  Result := TcxGridBoldDataController;
end;

function TcxGridBoldTableView.GetFake: TNotifyEvent;
begin
  result := nil;
end;

procedure TcxGridBoldTableView.SetFake(const Value: TNotifyEvent);
begin
end;

function TcxGridBoldTableView.GetItemClass: TcxCustomGridTableItemClass;
begin
  Result := TcxGridBoldColumn;
end;

procedure TcxGridBoldTableView.HookDragDrop;
begin
  OnDragDrop := DataController.DoDragDrop;
  OnStartDrag := DataController.DoStartDrag;
  OnEndDrag := DataController.DoEndDrag;
  OnDragOver := DataController.DoDragOver;
end;

procedure TcxGridBoldTableView.SetDataController(
  Value: TcxGridBoldDataController);
begin
  FDataController.Assign(Value);
end;

function TcxGridBoldTableView.ValidateComponent(
  ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean;
var
  i: integer;
  lContext: TBoldElementTypeInfo;
  lBoldValidateableComponent: IBoldValidateableComponent;
begin
  lContext := DataController.GetHandleStaticType;
  result := ComponentValidator.ValidateExpressionInContext(
    '', lContext, format('%s%s', [NamePrefix, Name])); // do not localize
  if assigned(lContext) then
    for i := 0 to ItemCount - 1 do
    begin
      result := ComponentValidator.ValidateExpressionInContext(
        Items[i].BoldProperties.Expression,
        lContext,
        format('%s%s.Column[%d]', [NamePrefix, Name, i])
        {$IFDEF AttracsBold}, Items[i].BoldProperties.VariableList{$ENDIF}) and result; // do not localize
      if Supports((DataController.GetItem(i) as TcxCustomGridTableItem).GetProperties, IBoldValidateableComponent, lBoldValidateableComponent) then
        result := lBoldValidateableComponent.ValidateComponent(ComponentValidator, namePrefix) and result;
    end;
end;

constructor TcxGridBoldTableView.Create(AOwner: TComponent);
begin
  inherited;
{$IFDEF DefaultDragMode}
  DragMode := dmAutomatic;
{$ENDIF}
  hookDragDrop;
end;

{ TcxGridBoldBandedTableView }

constructor TcxGridBoldBandedTableView.Create(AOwner: TComponent);
begin
  inherited;
{$IFDEF DefaultDragMode}
  DragMode := dmAutomatic;
{$ENDIF}
  hookDragDrop;
end;

destructor TcxGridBoldBandedTableView.Destroy;
begin
  inherited;
end;

function TcxGridBoldBandedTableView.DoCellDblClick(
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState): Boolean;
var
  lAutoForm: TForm;
  lElement: TBoldElement;
begin
  result := false;
  if DataController.BoldProperties.DefaultDblClick and not Controller.IsSpecialRowFocused and (DataController.Follower.CurrentIndex <> -1) then
  begin
    lElement := DataController.Follower.SubFollowers[DataController.Follower.CurrentIndex].Element;
    lAutoForm := AutoFormProviderRegistry.FormForElement(lElement);
    if assigned(lAutoForm) then
    begin
      result := true;
      lAutoForm.Show;
    end
  end;
  if not result then
  begin
    result := inherited DoCellDblClick(ACellViewInfo, AButton, AShift);
  end;
end;

function TcxGridBoldBandedTableView.DoEditing(
  AItem: TcxCustomGridTableItem): Boolean;
begin
  if Controller.IsSpecialRowFocused then
  begin
    result := inherited DoEditing(aItem);
  end
  else
  begin
    result := DataController.DoEditing(AItem) and inherited DoEditing(aItem);
  end;
end;

procedure TcxGridBoldBandedTableView.DoSelectionChanged;
begin
  DataController.SelectionChanged;
  inherited;
end;

function TcxGridBoldBandedTableView.GetControllerClass: TcxCustomGridControllerClass;
begin
  result := TcxGridBoldBandedTableController;
end;

function TcxGridBoldBandedTableView.GetCurrentBoldObject: TBoldObject;
begin
  result := DataController.CurrentBoldObject;
end;

function TcxGridBoldBandedTableView.GetCurrentElement: TBoldElement;
begin
  result := DataController.CurrentElement;
end;

function TcxGridBoldBandedTableView.GetCurrentIndex: integer;
begin
  result := DataController.CurrentIndex;
end;

function TcxGridBoldBandedTableView.GetDataController: TcxGridBoldDataController;
begin
  Result := TcxGridBoldDataController(FDataController);
end;

function TcxGridBoldBandedTableView.GetDataControllerClass: TcxCustomDataControllerClass;
begin
  Result := TcxGridBoldDataController;
end;

function TcxGridBoldBandedTableView.GetItem(Index: Integer): IBoldAwareViewItem;
begin
  result := inherited Items[Index] as IBoldAwareViewItem;
end;

function TcxGridBoldBandedTableView.GetItemClass: TcxCustomGridTableItemClass;
begin
  Result := TcxGridBoldBandedColumn;
end;

function TcxGridBoldBandedTableView.GetItemCount: Integer;
begin
  result := inherited ItemCount;
end;

function TcxGridBoldBandedTableView.GetSelection: TBoldList;
begin
  result := DataController.Selection;
end;

function TcxGridBoldBandedTableView.GetViewInfoClass: TcxCustomGridViewInfoClass;
begin
  Result := TcxGridBoldBandedTableViewInfo;
end;

procedure TcxGridBoldBandedTableView.HookDragDrop;
begin
  OnDragDrop := DataController.DoDragDrop;
  OnStartDrag := DataController.DoStartDrag;
  OnEndDrag := DataController.DoEndDrag;
  OnDragOver := DataController.DoDragOver;
end;

procedure TcxGridBoldBandedTableView.SetDataController(
  Value: TcxGridBoldDataController);
begin
  FDataController.Assign(Value);
end;

function TcxGridBoldBandedTableView.ValidateComponent(
  ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean;
var
  i: integer;
  lContext: TBoldElementTypeInfo;
  lBoldValidateableComponent: IBoldValidateableComponent;
begin
  lContext := DataController.GetHandleStaticType;
  result := ComponentValidator.ValidateExpressionInContext(
    '', lContext, format('%s%s', [NamePrefix, Name])); // do not localize
  if assigned(lContext) then
  begin
    for i := 0 to ItemCount - 1 do
    begin
      result := ComponentValidator.ValidateExpressionInContext(
        Items[i].BoldProperties.Expression,
        lContext,
        format('%s%s.Column[%d]', [NamePrefix, Name, i])
        {$IFDEF AttracsBold}, Items[i].BoldProperties.VariableList{$ENDIF}) and result; // do not localize
      if Supports((DataController.GetItem(i) as TcxCustomGridTableItem).GetProperties, IBoldValidateableComponent, lBoldValidateableComponent) then
        result := lBoldValidateableComponent.ValidateComponent(ComponentValidator, namePrefix) and result;
    end;
  end;
end;

destructor TcxGridBoldTableView.Destroy;
begin
  TBoldFollowerControllerAccess(DataController.fBoldColumnsProperties).FreePublisher;
  inherited;
end;

function TcxGridBoldTableView.GetCurrentBoldObject: TBoldObject;
begin
  result := DataController.CurrentBoldObject;
end;

function TcxGridBoldTableView.GetCurrentIndex: integer;
begin
  result := DataController.CurrentIndex;
end;

function TcxGridBoldTableView.GetCurrentElement: TBoldElement;
begin
  result := DataController.CurrentElement;
end;

function TcxGridBoldTableView.GetItem(Index: Integer): IBoldAwareViewItem;
begin
  result := inherited Items[Index] as IBoldAwareViewItem;
end;

function TcxGridBoldTableView.GetItemCount: Integer;
begin
  result := inherited ItemCount;
end;

{ TcxGridBoldCardView }

constructor TcxGridBoldCardView.Create(AOwner: TComponent);
begin
  inherited;
{$IFDEF DefaultDragMode}
// Drag drop is currently not supported in the CardView
//  DragMode := dmAutomatic;
//  hookDragDrop;
{$ENDIF}
end;

destructor TcxGridBoldCardView.Destroy;
begin
  inherited;
end;

function TcxGridBoldCardView.DoCellDblClick(
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState): Boolean;
var
  lAutoForm: TForm;
  lElement: TBoldElement;
begin
  result := false;
  if DataController.BoldProperties.DefaultDblClick and (DataController.Follower.CurrentIndex <> -1) then
  begin
    lElement := DataController.Follower.SubFollowers[DataController.Follower.CurrentIndex].Element;
    lAutoForm := AutoFormProviderRegistry.FormForElement(lElement);
    if assigned(lAutoForm) then
    begin
      result := true;
      lAutoForm.Show;
    end
  end;
  if not result then
  begin
    result := inherited DoCellDblClick(ACellViewInfo, AButton, AShift);
  end;
end;

function TcxGridBoldCardView.DoEditing(
  AItem: TcxCustomGridTableItem): Boolean;
begin
  result := DataController.DoEditing(AItem) and inherited DoEditing(aItem);
end;

procedure TcxGridBoldCardView.DoSelectionChanged;
begin
  DataController.SelectionChanged;
  inherited;
end;

function TcxGridBoldCardView.GetControllerClass: TcxCustomGridControllerClass;
begin
  result := TcxGridBoldCardViewController;
end;

function TcxGridBoldCardView.GetCurrentBoldObject: TBoldObject;
begin
  result := DataController.CurrentBoldObject;
end;

function TcxGridBoldCardView.GetCurrentElement: TBoldElement;
begin
  result := DataController.CurrentElement;
end;

function TcxGridBoldCardView.GetCurrentIndex: integer;
begin
  result := DataController.CurrentIndex;
end;

function TcxGridBoldCardView.GetDataController: TcxGridBoldDataController;
begin
  Result := TcxGridBoldDataController(FDataController);
end;

function TcxGridBoldCardView.GetDataControllerClass: TcxCustomDataControllerClass;
begin
  Result := TcxGridBoldDataController;
end;

function TcxGridBoldCardView.GetItem(Index: Integer): IBoldAwareViewItem;
begin
  result := inherited Items[Index] as IBoldAwareViewItem;
end;

function TcxGridBoldCardView.GetItemClass: TcxCustomGridTableItemClass;
begin
  Result := TcxGridBoldCardViewRow;
end;

function TcxGridBoldCardView.GetItemCount: Integer;
begin
  result := inherited ItemCount;
end;

function TcxGridBoldCardView.GetSelection: TBoldList;
begin
  result := DataController.Selection;
end;

function TcxGridBoldCardView.GetViewInfoClass: TcxCustomGridViewInfoClass;
begin
  Result := TcxGridBoldCardViewViewInfo;
end;

procedure TcxGridBoldCardView.SetDataController(
  Value: TcxGridBoldDataController);
begin
  FDataController.Assign(Value);
end;

function TcxGridBoldCardView.ValidateComponent(
  ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean;
var
  i: integer;
  lContext: TBoldElementTypeInfo;
  lBoldValidateableComponent: IBoldValidateableComponent;
begin
  lContext := DataController.GetHandleStaticType;
  result := ComponentValidator.ValidateExpressionInContext(
    '', lContext, format('%s%s', [NamePrefix, Name])); // do not localize
  if assigned(lContext) then
  begin
    for i := 0 to ItemCount - 1 do
    begin
      result := ComponentValidator.ValidateExpressionInContext(
        Items[i].BoldProperties.Expression,
        lContext,
        format('%s%s.Column[%d]', [NamePrefix, Name, i])
        {$IFDEF AttracsBold}, Items[i].BoldProperties.VariableList{$ENDIF}) and result; // do not localize
      if Supports((DataController.GetItem(i) as TcxCustomGridTableItem).GetProperties, IBoldValidateableComponent, lBoldValidateableComponent) then
        result := lBoldValidateableComponent.ValidateComponent(ComponentValidator, namePrefix) and result;
    end;
  end;
end;

{ TcxBoldCustomDataProvider }

function TcxBoldCustomDataProvider.GetValue(ARecordIndex: Integer; AField: TcxCustomDataField): Variant;
var
  ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle;
  lBoldDataSource: TcxBoldDataSource;
begin
  lBoldDataSource := CustomDataSource as TcxBoldDataSource;
  if Assigned(lBoldDataSource) then
  begin
    lBoldDataSource.CurrentProvider := Self;
    ARecordHandle := TcxDataRecordHandle(ARecordIndex);
    AItemHandle := lBoldDataSource.GetItemHandle(AField.Index);
    Result := lBoldDataSource.GetValue(ARecordHandle, AItemHandle);
  end
  else
    Result := Null;
end;

function TcxBoldCustomDataProvider.SetEditValue(ARecordIndex: Integer;
  AField: TcxCustomDataField; const AValue: Variant;
  AEditValueSource: TcxDataEditValueSource): Boolean;
begin
  DataController.SetValue(ARecordIndex, AField.Index, AValue);
  SetModified;
  Result := True;
end;

procedure TcxBoldCustomDataProvider.SetValue(ARecordIndex: Integer; AField: TcxCustomDataField; const Value: Variant);
var
  ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle;
  lBoldDataSource: TcxBoldDataSource;
begin
  lBoldDataSource := CustomDataSource as TcxBoldDataSource;
  if Assigned(lBoldDataSource) then
  begin
    lBoldDataSource.CurrentProvider := Self;
    ARecordHandle := TcxDataRecordHandle(ARecordIndex);
    AItemHandle := lBoldDataSource.GetItemHandle(AField.Index);
    lBoldDataSource.SetValue(ARecordHandle, AItemHandle, Value);
  end;
end;

function TcxBoldCustomDataProvider.CanDelete: Boolean;
var
  lcxBoldDataController: TcxBoldDataController;
begin
  lcxBoldDataController := DataController as TcxBoldDataController;
  result := Assigned(lcxBoldDataController) and Assigned(lcxBoldDataController.BoldHandle);
  if result then
  begin
    if Assigned(lcxBoldDataController.fOnDelete) and Assigned(lcxBoldDataController.fCanDelete) then
    begin
      lcxBoldDataController.fCanDelete(lcxBoldDataController, result)
    end
    else
      result := Assigned(lcxBoldDataController.BoldHandle.MutableList);
  end;
end;

function TcxBoldCustomDataProvider.CanInsert: Boolean;
var
  lcxBoldDataController: TcxBoldDataController;
begin
  lcxBoldDataController := DataController as TcxBoldDataController;
  result := Assigned(lcxBoldDataController) and Assigned(lcxBoldDataController.BoldHandle);
  if result then
  begin
    if Assigned(lcxBoldDataController.fOnInsert) and Assigned(lcxBoldDataController.fCanInsert) then
    begin
      lcxBoldDataController.fCanInsert(lcxBoldDataController, result)
    end
    else
      if Assigned(lcxBoldDataController.fCanInsert) then
        lcxBoldDataController.fCanInsert(lcxBoldDataController, result);
      result := result and Assigned(lcxBoldDataController.BoldHandle.MutableList) and lcxBoldDataController.BoldHandle.MutableList.CanCreateNew;
  end;
end;

type TcxCustomDataSourceAccess = class(TcxCustomDataSource);

procedure TcxBoldCustomDataProvider.DeleteRecords(AList: TList);
var
  i, {j,} ARecordIndex: Integer;
  lListToDelete: TBoldObjectList;
  lMutableList: TBoldObjectList;
  lObjectToDelete: TBoldObject;
  lFollower: TBoldFollower;
begin
//  DataController.BeginFullUpdate;
  lListToDelete := TBoldObjectList.Create;
  inc(TcxBoldDataController(DataController).fSkipMakeCellUptoDate);
  try
    for I := AList.Count - 1 downto 0 do
    begin
      ARecordIndex := Integer(AList[I]);
      lFollower := TcxBoldDataController(DataController).Follower.Subfollowers[ARecordIndex];
      lObjectToDelete := lFollower.element as TBoldObject;
      if Assigned(lObjectToDelete) and not lObjectToDelete.BoldObjectIsDeleted then
        lListToDelete.Add(lObjectToDelete);
    end;
    lMutableList := TcxBoldDataController(DataController).BoldHandle.MutableObjectList;
    if Assigned(lMutableList.BoldRoleRTInfo) and (lMutableList.BoldRoleRTInfo.RoleType = rtLinkRole) then
    begin
      for I := lListToDelete.Count - 1 downto 0 do
      begin
        if lListToDelete[i].BoldObjectExists then // not already deleted
          lListToDelete[i].Delete;
      end;
    end
    else
    {$IFDEF AttracsBold}
      lMutableList.RemoveList(lListToDelete);
    {$ELSE}
      while lListToDelete.Count > 0 do
      begin
        i := lListToDelete.Count - 1;
        lObjectToDelete := lListToDelete[i];
        lListToDelete.RemoveByIndex(i);
        lMutableList.Remove(lObjectToDelete);
      end;
    {$ENDIF}
    if TcxCustomDataControllerAccess(DataController).FInDeleteSelection then
      DataController.ClearSelection;
  finally
//    DataController.EndFullUpdate;
    lListToDelete.free;
//    TcxCustomDataControllerAccess(DataController).CheckNearestFocusRow;
    dec(TcxBoldDataController(DataController).fSkipMakeCellUptoDate);
  end;
end;

{ TcxGridBoldTableController }

procedure TcxGridBoldTableController.DoKeyDown(var Key: Word;
  Shift: TShiftState);
var
  lColumnAutoWidth: boolean;
  lVisibleCount: integer;
begin
  if (key = VK_ADD) and (shift = [ssCtrl]) then
  begin
    GridView.BeginUpdate;
    try
      GridView.OptionsView.ColumnAutoWidth := not GridView.OptionsView.ColumnAutoWidth;
      lColumnAutoWidth := GridView.OptionsView.ColumnAutoWidth;
      if not lColumnAutoWidth then
      begin
        lVisibleCount := GridView.ViewInfo.VisibleRecordCount;
        if lVisibleCount <> GridView.OptionsBehavior.BestFitMaxRecordCount then
          GridView.OptionsBehavior.BestFitMaxRecordCount := lVisibleCount;
        ViewInfo.GridView.ApplyBestFit(nil, true, true);
        if lColumnAutoWidth then
          GridView.OptionsView.ColumnAutoWidth := true;
      end;
    finally
      GridView.EndUpdate;
    end;
  end;
  inherited;
end;

function TcxGridBoldTableController.GetEditingControllerClass: TcxGridEditingControllerClass;
begin
  result := TcxGridBoldEditingController;
end;

procedure TcxGridBoldTableController.KeyDown(var Key: Word;
  Shift: TShiftState);
var
  lIndex: integer;
  lBoldHandle: TBoldAbstractListHandle;
  lBoldList: TBoldList;
  lHandled: boolean;
  lAllowed: boolean;
  lcxBoldDataController: TcxBoldDataController;
begin
  lcxBoldDataController := (DataController as TcxBoldDataController);
  if not BlockRecordKeyboardHandling and (FocusedRecord <> nil) then
    TcxCustomGridRecordAccess(FocusedRecord).KeyDown(Key, Shift);
  case Key of
    VK_INSERT:
      if (Shift = []) then
      begin
        Key := 0;
        lHandled := false;
        if Assigned(lcxBoldDataController.fOnInsert) then
        begin
          lAllowed := CanInsert(true);
          if lAllowed then
            lcxBoldDataController.fOnInsert(lcxBoldDataController);
          lHandled := true;
        end
        else
          lAllowed := Assigned(lcxBoldDataController.BoldHandle) and Assigned(lcxBoldDataController.BoldHandle.MutableList);
        if not lHandled and lAllowed then
        begin
          lBoldHandle := TcxBoldDataController(DataController).BoldHandle;
          lBoldList := lBoldHandle.MutableList;
          if Assigned(lBoldList.BoldMemberRTInfo) and TBoldRoleRTInfo(lBoldList.BoldMemberRTInfo).IsOrdered and ((DataController as TcxBoldDataController).Follower.CurrentIndex <> -1) then
          begin
            lIndex := TcxBoldDataController(DataController).Follower.CurrentIndex;
            lBoldList.InsertNew(lIndex);
          end
          else
          begin
            lIndex := lBoldList.IndexOf(lBoldList.AddNew);
          end;
          TBoldQueueable.DisplayAll;
          (DataController as TcxBoldDataController).Follower.CurrentIndex := lIndex;
        end;
      end
      else
        if (Shift = [ssCtrl]) and not IsEditing then
          GridView.CopyToClipboard(False);
    VK_DELETE:
      if ((Shift = []) or (Shift = [ssCtrl])) and (SelectedRecordCount > 0) then
      begin
        Key := 0;
        lHandled := false;
        lAllowed := CanDelete(true);
        if Assigned(lcxBoldDataController.fOnDelete)  then
        begin
          if lAllowed then
            lcxBoldDataController.fOnDelete(lcxBoldDataController);
          lHandled := true;
        end;
        if not lHandled and lAllowed then
        begin
          DeleteSelection;
        end;
        TBoldQueueable.DisplayAll;
      end;
    VK_HOME:
      begin
        if ([ssCtrl] = Shift) or not FocusedRecordHasCells(True) then
        begin
          GoToFirst(True)
        end
        else
          inherited; //FocusNextItem(-1, True, False, False, true);
      end;
    VK_END:
      begin
        if ([ssCtrl] = Shift) or not FocusedRecordHasCells(True) then
        begin
          GoToLast(False, True)
        end
        else
          inherited; // FocusNextItem(-1, False, True, False, true)
      end;
    VK_PRIOR:
      begin
        if (ssShift in Shift) and (ssCtrl in Shift) then
        begin
//          (DataController as TcxGridBoldDataController).AdjustActiveRange();
        end;
        inherited;
      end;
    VK_NEXT:
      begin
        if (ssShift in Shift) and (ssCtrl in Shift) then
        begin
//          (DataController as TcxGridBoldDataController).AdjustActiveRange();
        end;
        inherited;
      end
  else
    inherited
  end;
end;

procedure TcxGridBoldTableController.WndProc(var Message: TMessage);
begin
  inherited;
  if (Message.Msg = WM_PAINT) and not TBoldQueueable.IsDisplayQueueEmpty then
    TBoldQueueable.DisplayAll;
end;

{ TcxGridBoldBandedTableController }

function TcxGridBoldBandedTableController.GetEditingControllerClass: TcxGridEditingControllerClass;
begin
  result := TcxGridBoldEditingController;
end;

procedure TcxGridBoldBandedTableController.KeyDown(var Key: Word;
  Shift: TShiftState);
var
  lIndex: integer;
  lBoldHandle: TBoldAbstractListHandle;
  lBoldList: TBoldList;
  lHandled: boolean;
  lAllowed: boolean;
  lcxBoldDataController: TcxBoldDataController;
begin
  lcxBoldDataController := (DataController as TcxBoldDataController);
  if not BlockRecordKeyboardHandling and (FocusedRecord <> nil) then
    TcxCustomGridRecordAccess(FocusedRecord).KeyDown(Key, Shift);
  case Key of
    VK_INSERT:
      if (Shift = []) then
      begin
        Key := 0;
        lHandled := false;
        if Assigned(lcxBoldDataController.fOnInsert) then
        begin
          lAllowed := CanInsert(true);
          if lAllowed then
            lcxBoldDataController.fOnInsert(lcxBoldDataController);
          lHandled := true;
        end
        else
          lAllowed := Assigned(lcxBoldDataController.BoldHandle) and Assigned(lcxBoldDataController.BoldHandle.MutableList);
        if not lHandled and lAllowed then
        begin
          lBoldHandle := TcxBoldDataController(DataController).BoldHandle;
          lBoldList := lBoldHandle.MutableList;
          if Assigned(lBoldList.BoldMemberRTInfo) and TBoldRoleRTInfo(lBoldList.BoldMemberRTInfo).IsOrdered and ((DataController as TcxBoldDataController).Follower.CurrentIndex <> -1) then
          begin
            lIndex := TcxBoldDataController(DataController).Follower.CurrentIndex;
            lBoldList.InsertNew(lIndex);
          end
          else
          begin
            lIndex := lBoldList.IndexOf(lBoldList.AddNew);
          end;
          TBoldQueueable.DisplayAll;
          (DataController as TcxBoldDataController).Follower.CurrentIndex := lIndex;
        end;
      end
      else
        if (Shift = [ssCtrl]) and not IsEditing then
          GridView.CopyToClipboard(False);
    VK_DELETE:
      if ((Shift = []) or (Shift = [ssCtrl])) and (SelectedRecordCount > 0) then
      begin
        Key := 0;
        lHandled := false;
        lAllowed := true;
        if Assigned(lcxBoldDataController.fOnDelete)  then
        begin
          lAllowed := CanDelete(true);
          if lAllowed then
            lcxBoldDataController.fOnDelete(lcxBoldDataController);
          lHandled := true;
        end;
        if not lHandled and lAllowed then
        begin
          DeleteSelection;
        end;
        TBoldQueueable.DisplayAll;
      end;
    VK_HOME:
      begin
        if ([ssCtrl] = Shift) or not FocusedRecordHasCells(True) then
        begin
          GoToFirst(True)
        end
        else
          inherited; //FocusNextItem(-1, True, False, False, true);
      end;
    VK_END:
      begin
        if ([ssCtrl] = Shift) or not FocusedRecordHasCells(True) then
        begin
          GoToLast(False, True)
        end
        else
          inherited; // FocusNextItem(-1, False, True, False, true)
      end;
    VK_PRIOR:
      begin
        if (ssShift in Shift) and (ssCtrl in Shift) then
        begin
//          (DataController as TcxGridBoldDataController).AdjustActiveRange();
        end;
        inherited;
      end;
    VK_NEXT:
      begin
        if (ssShift in Shift) and (ssCtrl in Shift) then
        begin
//          (DataController as TcxGridBoldDataController).AdjustActiveRange();
        end;
        inherited;
      end
  else
    inherited
  end;
end;

procedure TcxGridBoldBandedTableController.WndProc(var Message: TMessage);
begin
  inherited;
  if (Message.Msg = WM_PAINT) and not TBoldQueueable.IsDisplayQueueEmpty then
    TBoldQueueable.DisplayAll;
end;

{ TcxBoldDataControllerSearch }

function TcxBoldDataControllerSearch.Locate(AItemIndex: Integer; const ASubText: string; AIsAnywhere: Boolean = False): Boolean;
begin
  (DataController as TcxGridBoldDataController).AdjustActiveRange(((DataController as TcxGridBoldDataController).Follower.Element as TBoldObjectList), AItemIndex);
  result := inherited Locate(AItemIndex, ASubText);
end;

function TcxBoldDataControllerSearch.LocateNext(AForward: Boolean; AIsAnywhere: Boolean = False): Boolean;
begin
  (DataController as TcxGridBoldDataController).AdjustActiveRange();
  result := inherited LocateNext(AForward);
end;

{ TcxGridBoldCardViewRow }

function TcxGridBoldCardViewRow.CalculateBestFitWidth: Integer;
begin
  GridView.OptionsBehavior.BestFitMaxRecordCount := GridView.ViewInfo.VisibleRecordCount;
  result := inherited CalculateBestFitWidth;
end;

destructor TcxGridBoldCardViewRow.Destroy;
begin
  DataBinding.Remove;
  inherited;
end;

function TcxGridBoldCardViewRow.GetDataBinding: TcxGridItemBoldDataBinding;
begin
  Result := TcxGridItemBoldDataBinding(inherited DataBinding);
end;

procedure TcxGridBoldCardViewRow.SetDataBinding(
  Value: TcxGridItemBoldDataBinding);
begin
  inherited DataBinding := Value;
end;

procedure TcxGridBoldCardViewRow.VisibleChanged;
begin
  inherited;
//  if Visible and not IsLoading then
//    (DataController as TcxGridBoldDataController).AdjustActiveRange();
end;

{ TcxGridBoldEditingController }

procedure TcxGridBoldEditingController.DoEditKeyDown(var Key: Word;
  Shift: TShiftState);
var
  lWasEditing: boolean;
  lHideFilterRowOnEnter: boolean;
begin
  lHideFilterRowOnEnter := false;
  begin
    lWasEditing := (EditingItem <> nil) and EditingItem.Editing;
    if lWasEditing and (Key = VK_ESCAPE) then
    begin
      Key := VK_ESCAPE;
    end
    else
    if Controller.IsFilterRowFocused then
    begin
      if (Key = VK_RETURN) and lWasEditing then
      begin
        lHideFilterRowOnEnter := true;
      end;
    end;
  end;
  inherited;
  if lHideFilterRowOnEnter and (EditingItem = nil) and (GridView.DataController.FilteredRecordCount > 0) then
    Controller.GridView.FilterRow.Visible := false
end;

procedure TcxGridBoldEditingController.EditChanged(Sender: TObject);
var
  lEdit: TcxCustomEdit;
  lFollower: TBoldFollower;
  lDataController: TcxGridBoldDataController;
  lIcxBoldEditProperties: IcxBoldEditProperties;
  lDone: Boolean;
begin
//  inherited; // moved to the end of the method, coz it fires OnChange event and we don't want that to happen before we make the change
{
  Here we basically ignore ApplyPolicy. We want to mark follower dirty as soon as possible (ie here)
  But we don't want to apply changes to ObjectSpace yet as changes may cause reload of data,
  especially if the view is grouped/sorted and user is editing a grouped/sorted column.
  So if this happens editing loses focus and view reloads data, so we want to avoid this.
}
  if (EditingItem <> nil) {EditingItem is TcxGridBoldColumn} and not Controller.IsSpecialRowFocused then
  begin
    lEdit := Sender as TcxCustomEdit;
    lDataController := EditingItem.DataBinding.DataController as TcxGridBoldDataController;
    lFollower := lDataController.Follower.SubFollowers[lDataController.FocusedRecordIndex];
    if lFollower.Active then
    begin
      lFollower := lFollower.SubFollowers[Integer(EditingItem.DataBinding.Data)];
      lDone := false;
      Assert(EditingItem.GetProperties <> nil);
      if Supports(EditingItem.GetProperties, IcxBoldEditProperties, lIcxBoldEditProperties) then
      begin
        lIcxBoldEditProperties.SetStoredValue(Null, lDataController.BoldHandle, lEdit, lFollower, lDone);
      end;
      if not lDone then
      begin
        lDone := (lFollower.Controller as TBoldVariantFollowerController).MayHaveChanged(Edit.EditingValue, lFollower);
      end;
      if lDone then
      begin
        lDataController.fInternalChange := true;
        try
          TBoldQueueable.DisplayAll;
        finally
          lDataController.fInternalChange := false;
          inherited;
        end;
      end;
    end;
  end
  else
    inherited;
end;

procedure TcxGridBoldEditingController.EditExit(Sender: TObject);
begin
//  self.EditChanged(Sender);
  inherited;
end;

procedure TcxGridBoldEditingController.HideEdit(Accept: Boolean);
var
  lcxBoldDataController: TcxBoldDataController;
  lFollower: TBoldFollower;
begin
  if not Accept and Assigned(Edit) and Edit.ModifiedAfterEnter then
  begin
    lcxBoldDataController := EditingItem.DataBinding.DataController as TcxBoldDataController;
    if (lcxBoldDataController.FocusedRecordIndex <> -1) then
    begin
      lFollower := lcxBoldDataController.Follower.SubFollowers[lcxBoldDataController.FocusedRecordIndex];
      lFollower := lFollower.SubFollowers[Integer(EditingItem.DataBinding.Data)];
      begin
        lFollower.DiscardChange;
      end;
    end;
  end;
//  if Assigned(Edit) and Edit.ModifiedAfterEnter then
//    self.EditChanged(Edit);
  inherited;
end;

{ TcxGridBoldBandedColumn }

function TcxGridBoldBandedColumn.CalculateBestFitWidth: Integer;
begin
  GridView.OptionsBehavior.BestFitMaxRecordCount := GridView.ViewInfo.VisibleRecordCount;
  result := inherited CalculateBestFitWidth;
end;

destructor TcxGridBoldBandedColumn.Destroy;
begin
  DataBinding.Remove;
  inherited;
end;

function TcxGridBoldBandedColumn.GetDataBinding: TcxGridItemBoldDataBinding;
begin
  Result := TcxGridItemBoldDataBinding(inherited DataBinding);
end;

procedure TcxGridBoldBandedColumn.SetDataBinding(
  Value: TcxGridItemBoldDataBinding);
begin
  inherited DataBinding := Value;
end;

procedure TcxGridBoldBandedColumn.VisibleChanged;
begin
  inherited;
//  if Visible and not IsLoading then
//    (DataController as TcxGridBoldDataController).AdjustActiveRange();
end;

{ TcxGridBoldChartDataController }
(*
procedure TcxGridBoldChartDataController.AssignData(
  ADataController: TcxCustomDataController);
begin
end;

procedure TcxGridBoldChartDataController.CreateAllItems(
  AMissingItemsOnly: Boolean);
begin
end;

procedure TcxGridBoldChartDataController.DeleteAllItems;
begin
end;

function TcxGridBoldChartDataController.GetChartItem(
  AItemClass: TcxGridChartItemClass; AIndex: Integer): TcxGridChartItem;
var
  AFields: TList;
begin
  AFields := TList.Create;
  try
    GetValidValueFields(AItemClass, AFields);
//    Result := GridView.FindItemByFieldName(AItemClass, TField(AFields[AIndex]).FieldName);
  finally
    AFields.Free;
  end;
end;

procedure TcxGridBoldChartDataController.GetFakeComponentLinks(AList: TList);
begin
  if (BoldHandle <> nil) and (BoldHandle.Owner <> GridView.Component) and
    (AList.IndexOf(BoldHandle.Owner) = -1) then
    AList.Add(BoldHandle.Owner);
end;

procedure TcxGridBoldChartDataController.GetItemCaptions(
  AItemClass: TcxGridChartItemClass; ACaptions: TStringList);
var
  AFields: TList;
  I: Integer;
begin
  AFields := TList.Create;
  try
    GetValidValueFields(AItemClass, AFields);
//    for I := 0 to AFields.Count - 1 do
//      ACaptions.Add(TField(AFields[I]).DisplayName);
  finally
    AFields.Free;
  end;
end;

procedure TcxGridBoldChartDataController.GetValidValueFields(
  AItemClass: TcxGridChartItemClass; AFields: TList);
var
  I: Integer;
//  AField: TField;
begin
{
  if DataSet = nil then Exit;
  for I := 0 to DataSet.FieldCount - 1 do
  begin
    AField := DataSet.Fields[I];
    if not AItemClass.IsValue or
      IsValueTypeClassValid(GetValueTypeClassByField(AField)) then
      AFields.Add(AField);
  end;
  AFields.Sort(CompareFields);
}
end;

function TcxGridBoldChartDataController.HasAllItems: Boolean;
begin
  Result := True;
end;

procedure TcxGridBoldChartDataController.InitItem(AItem: TcxGridChartItem;
  AIndex: Integer);
var
  AFields: TList;
begin
  AFields := TList.Create;
  try
    GetValidValueFields(TcxGridChartItemClass(AItem.ClassType), AFields);
//    TcxGridBoldChartItemDataBinding(AItem.DataBinding).FieldName := TField(AFields[AIndex]).FieldName;
  finally
    AFields.Free;
  end;
end;

function TcxGridBoldChartDataController.IsDataChangeable: Boolean;
begin
  Result := False;
end;

function TcxGridBoldChartDataController.SupportsCreateAllItems: Boolean;
begin
  Result := False;
end;

{ TcxGridBoldChartItemDataBinding }

procedure TcxGridBoldChartItemDataBinding.Assign(Source: TPersistent);
begin
//  if Source is TcxGridBoldChartItemDataBinding then
//    FieldName := TcxGridBoldChartItemDataBinding(Source).FieldName;
  inherited;
end;

constructor TcxGridBoldChartItemDataBinding.Create(AGridView: TcxGridChartView;
  AIsValue: Boolean; ADefaultValueTypeClass: TcxValueTypeClass);
begin
  inherited Create(AGridView, AIsValue, ADefaultValueTypeClass);
  fBoldProperties := TBoldVariantFollowerController.Create(AGridView.Component);

//  DataController.fBoldColumnsProperties.Add(fBoldProperties);
//  fBoldProperties.OnGetContextType := DataController.GetHandleStaticType;
//  FBoldProperties.AfterMakeUptoDate := DataController._AfterMakeCellUptoDate;
end;

destructor TcxGridBoldChartItemDataBinding.Destroy;
begin
  FreeAndNil(FBoldProperties);
  inherited;
end;

function TcxGridBoldChartItemDataBinding.GetDataController: TcxGridBoldChartDataController;
begin
  Result := TcxGridBoldChartDataController(inherited DataController);
end;

procedure TcxGridBoldChartItemDataBinding.SetBoldProperties(
  Value: TBoldVariantFollowerController);
begin
  if Assigned(Value) then
    fBoldProperties.Assign(Value);
end;

{ TcxGridBoldChartCategories }

function TcxGridBoldChartCategories.GetDataBinding: TcxGridBoldChartItemDataBinding;
begin
  Result := TcxGridBoldChartItemDataBinding(inherited DataBinding);
end;

procedure TcxGridBoldChartCategories.SetDataBinding(
  Value: TcxGridBoldChartItemDataBinding);
begin
  inherited DataBinding := Value;
end;

{ TcxGridBoldChartDataGroup }

function TcxGridBoldChartDataGroup.GetDataBinding: TcxGridBoldChartItemDataBinding;
begin
  Result := TcxGridBoldChartItemDataBinding(inherited DataBinding);
end;

procedure TcxGridBoldChartDataGroup.SetDataBinding(
  Value: TcxGridBoldChartItemDataBinding);
begin
  inherited DataBinding := Value;
end;

{ TcxGridBoldChartSeries }

function TcxGridBoldChartSeries.GetDataBinding: TcxGridBoldChartItemDataBinding;
begin
  Result := TcxGridBoldChartItemDataBinding(inherited DataBinding);
end;

procedure TcxGridBoldChartSeries.SetDataBinding(
  Value: TcxGridBoldChartItemDataBinding);
begin
  inherited DataBinding := Value;
end;

{ TcxBoldGridChartView }

procedure TcxBoldGridChartView.ClearItems;
begin
  ClearSeries;
end;

constructor TcxBoldGridChartView.Create(AOwner: TComponent);
begin
  inherited;
end;

function TcxBoldGridChartView.CreateDataGroup: TcxGridBoldChartDataGroup;
begin
  Result := TcxGridBoldChartDataGroup(inherited CreateDataGroup);
end;

function TcxBoldGridChartView.CreateSeries: TcxGridBoldChartSeries;
begin
  Result := TcxGridBoldChartSeries(inherited CreateSeries);
end;

destructor TcxBoldGridChartView.Destroy;
begin
  inherited;
end;

function TcxBoldGridChartView.FindDataGroupByFieldName(
  const AFieldName: string): TcxGridBoldChartDataGroup;
begin
  Result := TcxGridBoldChartDataGroup(FindItemByFieldName(GetDataGroupClass, AFieldName));
end;

function TcxBoldGridChartView.FindItemByFieldName(
  AItemClass: TcxGridChartItemClass;
  const AFieldName: string): TcxGridChartItem;
var
  AItems: TList;
  I: Integer;
begin
  AItems := GetItemList(AItemClass);
  for I := 0 to AItems.Count - 1 do
  begin
    Result := TcxGridChartItem(AItems[I]);
//    if SameText(TcxGridBoldChartItemDataBinding(Result.DataBinding).FieldName, AFieldName) then Exit;
  end;
  Result := nil;
end;

function TcxBoldGridChartView.FindSeriesByFieldName(
  const AFieldName: string): TcxGridBoldChartSeries;
begin
  Result := TcxGridBoldChartSeries(FindItemByFieldName(GetSeriesClass, AFieldName));
end;

function TcxBoldGridChartView.GetCategories: TcxGridBoldChartCategories;
begin
  Result := TcxGridBoldChartCategories(inherited Categories);
end;

function TcxBoldGridChartView.GetCategoriesClass: TcxGridChartCategoriesClass;
begin
  Result := TcxGridBoldChartCategories;
end;

function TcxBoldGridChartView.GetDataController: TcxGridBoldChartDataController;
begin
  Result := TcxGridBoldChartDataController(inherited DataController);
end;

function TcxBoldGridChartView.GetDataControllerClass: TcxCustomDataControllerClass;
begin
  Result := TcxGridBoldChartDataController;
end;

function TcxBoldGridChartView.GetDataGroup(
  Index: Integer): TcxGridBoldChartDataGroup;
begin
  Result := TcxGridBoldChartDataGroup(inherited DataGroups[Index]);
end;

function TcxBoldGridChartView.GetDataGroupClass: TcxGridChartDataGroupClass;
begin
  Result := TcxGridBoldChartDataGroup;
end;

function TcxBoldGridChartView.GetItem(Index: Integer): IBoldAwareViewItem;
begin
  result := inherited Items[Index] as IBoldAwareViewItem;
end;

function TcxBoldGridChartView.GetItemCount: Integer;
begin
  result := inherited SeriesCount;
end;

function TcxBoldGridChartView.GetItemDataBindingClass: TcxGridChartItemDataBindingClass;
begin
  Result := TcxGridBoldChartItemDataBinding;
end;

function TcxBoldGridChartView.GetSelection: TBoldList;
begin
  result := fSelection;
end;

function TcxBoldGridChartView.GetSeries(Index: Integer): TcxGridBoldChartSeries;
begin
  Result := TcxGridBoldChartSeries(inherited Series[Index]);
end;

function TcxBoldGridChartView.GetSeriesClass: TcxGridChartSeriesClass;
begin
  Result := TcxGridBoldChartSeries;
end;

procedure TcxBoldGridChartView.SetCategories(Value: TcxGridBoldChartCategories);
begin
  inherited Categories := Value;
end;

procedure TcxBoldGridChartView.SetDataController(
  Value: TcxGridBoldChartDataController);
begin
  FDataController.Assign(Value);
end;

procedure TcxBoldGridChartView.SetDataGroup(Index: Integer;
  Value: TcxGridBoldChartDataGroup);
begin
  inherited DataGroups[Index] := Value;
end;

procedure TcxBoldGridChartView.SetSeries(Index: Integer;
  Value: TcxGridBoldChartSeries);
begin
  inherited Series[Index] := Value;
end;

function TcxBoldGridChartView.ValidateComponent(
  ComponentValidator: TBoldComponentValidator; NamePrefix: String): Boolean;
var
  i: integer;
  lContext: TBoldElementTypeInfo;
begin
  lContext := DataController.GetHandleStaticType;
  result := ComponentValidator.ValidateExpressionInContext(
      '', lContext, format('%s%s', [NamePrefix, Name])); // do not localize
  if assigned(lContext) then
    for i := 0 to ItemCount - 1 do
      result := ComponentValidator.ValidateExpressionInContext(
        Items[i].DataBinding.BoldProperties.Expression,
        lContext,
        format('%s%s.Column[%d]', [NamePrefix, Name, i])) and result; // do not localize
end;
*)

{ TcxGridBoldCardViewController }

function TcxGridBoldCardViewController.GetEditingControllerClass: TcxGridEditingControllerClass;
begin
  result := TcxGridBoldCardEditingController; //TcxGridBoldEditingController;
end;

procedure TcxGridBoldCardViewController.WndProc(var Message: TMessage);
begin
  inherited;
  if (Message.Msg = WM_PAINT) and not TBoldQueueable.IsDisplayQueueEmpty then
    TBoldQueueable.DisplayAll;
end;

{ TcxGridBoldCardEditingController }

procedure TcxGridBoldCardEditingController.EditChanged(Sender: TObject);
var
  lEdit: TcxCustomEdit;
  lFollower: TBoldFollower;
  lDataController: TcxGridBoldDataController;
  lIcxBoldEditProperties: IcxBoldEditProperties;
  lDone: Boolean;
begin
//  inherited; // moved to the end of the method, coz it fires OnChange event and we don't want that to happen before we make the change
{
  Here we basically ignore ApplyPolicy. We want to mark follower dirty as soon as possible (ie here)
  But we don't want to apply changes to ObjectSpace yet as changes may cause reload of data,
  especially if the view is grouped/sorted and user is editing a grouped/sorted column.
  So if this happens editing loses focus and view reloads data, so we want to avoid this.
}
  if EditingItem is TcxGridBoldCardViewRow then
  begin
    lEdit := Sender as TcxCustomEdit;
    lDataController := EditingItem.DataBinding.DataController as TcxGridBoldDataController;
    lFollower := lDataController.Follower.SubFollowers[lDataController.FocusedRecordIndex];
    if lFollower.Active then
    begin
      lFollower := lFollower.SubFollowers[Integer(EditingItem.DataBinding.Data)];
      lDone := false;
      Assert(EditingItem.GetProperties <> nil);
      if Supports(EditingItem.GetProperties, IcxBoldEditProperties, lIcxBoldEditProperties) then
      begin
        lIcxBoldEditProperties.SetStoredValue(Null, lDataController.BoldHandle, lEdit, lFollower, lDone);
      end;
      if not lDone then
      begin
        lDone := (lFollower.Controller as TBoldVariantFollowerController).MayHaveChanged(Edit.EditingValue, lFollower);
      end;
      if lDone then
      begin
        lDataController.fInternalChange := true;
        try
          TBoldQueueable.DisplayAll;
        finally
          lDataController.fInternalChange := false;
          inherited;
        end;
      end;
    end;
  end
  else
    inherited;
end;

{ TcxGridBoldDefaultValuesProvider }

function TcxGridBoldDefaultValuesProvider.DefaultCanModify: Boolean;
begin
  Result := inherited DefaultCanModify {and Follower.MayModify};
end;

function TcxGridBoldDefaultValuesProvider.IsDisplayFormatDefined(
  AIsCurrencyValueAccepted: Boolean): Boolean;
begin
  Result := (Owner as TcxGridItemDataBinding).IsDisplayFormatDefined(AIsCurrencyValueAccepted);
end;

{ TcxBoldGridRowsViewInfo }

procedure TcxBoldGridRowsViewInfo.CalculateVisibleCount;
begin
  inherited;
//  if PartVisibleCount > 0 then
//    TcxBoldDataController(GridView.DataController).AdjustActiveRange();
end;

{ TcxGridBoldTableViewInfo }

function TcxGridBoldTableViewInfo.GetRecordsViewInfoClass: TcxCustomGridRecordsViewInfoClass;
begin
  result := TcxBoldGridRowsViewInfo;
end;

procedure TcxGridBoldBandedRowsViewInfo.CalculateVisibleCount;
begin
  inherited;
//  if PartVisibleCount > 0 then
//    TcxBoldDataController(GridView.DataController).AdjustActiveRange();
end;

{ TcxGridBoldBandedTableViewInfo }

function TcxGridBoldBandedTableViewInfo.GetRecordsViewInfoClass: TcxCustomGridRecordsViewInfoClass;
begin
  Result := TcxGridBoldBandedRowsViewInfo;
end;

{ TcxGridBoldCardViewViewInfo }

function TcxGridBoldCardViewViewInfo.GetRecordsViewInfoClass: TcxCustomGridRecordsViewInfoClass;
begin
  Result := TcxGridBoldCardsViewInfo;
end;

{ TcxGridBoldCardsViewInfo }

procedure TcxGridBoldCardsViewInfo.CalculateVisibleCount;
begin
  inherited;
//  if PartVisibleCount > 0 then
//    TcxBoldDataController(GridView.DataController).AdjustActiveRange();
end;

{ TcxGridBoldLayoutView }

constructor TcxGridBoldLayoutView.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TcxGridBoldLayoutView.Destroy;
begin

  inherited;
end;

function TcxGridBoldLayoutView.CreateItem: TcxGridBoldLayoutViewItem;
begin
  Result := TcxGridBoldLayoutViewItem(inherited CreateItem);
end;

function TcxGridBoldLayoutView.GetCurrentBoldObject: TBoldObject;
begin
  result := DataController.CurrentBoldObject;
end;

function TcxGridBoldLayoutView.GetCurrentElement: TBoldElement;
begin
  result := DataController.CurrentElement;
end;

function TcxGridBoldLayoutView.GetCurrentIndex: integer;
begin
  result := DataController.CurrentIndex;
end;

function TcxGridBoldLayoutView.GetDataController: TcxGridBoldDataController;
begin
  Result := TcxGridBoldDataController(FDataController);
end;

function TcxGridBoldLayoutView.GetDataControllerClass: TcxCustomDataControllerClass;
begin
  Result := TcxGridBoldDataController;
end;

function TcxGridBoldLayoutView.GetItem(Index: Integer): IBoldAwareViewItem;
begin
  result := inherited Items[Index] as IBoldAwareViewItem;
end;

function TcxGridBoldLayoutView.GetItemClass: TcxCustomGridTableItemClass;
begin
  Result := TcxGridBoldLayoutViewItem;
end;

function TcxGridBoldLayoutView.GetItemCount: Integer;
begin
  result := inherited ItemCount;
end;

function TcxGridBoldLayoutView.GetSelection: TBoldList;
begin
  result := DataController.Selection;
end;

procedure TcxGridBoldLayoutView.SetDataController(
  Value: TcxGridBoldDataController);
begin
  FDataController.Assign(Value);
end;

function TcxGridBoldLayoutView.ValidateComponent(
  ComponentValidator: TBoldComponentValidator; NamePrefix: string): Boolean;
var
  i: integer;
  lContext: TBoldElementTypeInfo;
  lBoldValidateableComponent: IBoldValidateableComponent;
begin
  lContext := DataController.GetHandleStaticType;
  result := ComponentValidator.ValidateExpressionInContext(
    '', lContext, format('%s%s', [NamePrefix, Name])); // do not localize
  if assigned(lContext) then
  begin
    for i := 0 to ItemCount - 1 do
    begin
      result := ComponentValidator.ValidateExpressionInContext(
        Items[i].BoldProperties.Expression,
        lContext,
        format('%s%s.Column[%d]', [NamePrefix, Name, i])
        {$IFDEF AttracsBold}, Items[i].BoldProperties.VariableList{$ENDIF}) and result; // do not localize
      if Supports((self.DataController.GetItem(i) as TcxCustomGridTableItem).GetProperties, IBoldValidateableComponent, lBoldValidateableComponent) then
        result := lBoldValidateableComponent.ValidateComponent(ComponentValidator, namePrefix) and result;
    end;
  end;
end;

{ TcxGridBoldLayoutViewItem }

destructor TcxGridBoldLayoutViewItem.Destroy;
begin
  DataBinding.Remove;
  inherited;
end;

function TcxGridBoldLayoutViewItem.GetDataBinding: TcxGridItemBoldDataBinding;
begin
  Result := TcxGridItemBoldDataBinding(inherited DataBinding);
end;

procedure TcxGridBoldLayoutViewItem.SetDataBinding(
  Value: TcxGridItemBoldDataBinding);
begin
  inherited DataBinding := Value;
end;

{ TBoldCxGridVariantFollowerController }

constructor TBoldCxGridVariantFollowerController.Create(
  aOwningComponent: TComponent);
begin
  inherited Create(aOwningComponent);
end;

{$IFDEF AttracsBold}
function TBoldCxGridVariantFollowerController.SubFollowersActive: boolean;
begin
  result := false; //cxGridItemBoldDataBinding.Item.ActuallyVisible;
end;
{$ENDIF}

initialization
  cxGridRegisteredViews.Register(TcxGridBoldTableView, 'Bold Table');
  cxGridRegisteredViews.Register(TcxGridBoldCardView, 'Bold Card');
//  cxGridRegisteredViews.Register(TcxBoldGridChartView, 'Bold Chart');
  cxGridRegisteredViews.Register(TcxGridBoldBandedTableView, 'Bold Banded Table');
  cxGridRegisteredViews.Register(TcxGridBoldLayoutView, 'Bold Layout');
  Classes.RegisterClasses([TcxGridBoldColumn, TcxGridItemBoldDataBinding, TcxGridBoldBandedColumn, TcxGridBoldCardViewRow, TcxGridBoldLayoutViewItem]);

finalization
  cxGridRegisteredViews.Unregister(TcxGridBoldTableView);
  cxGridRegisteredViews.Unregister(TcxGridBoldCardView);
//  cxGridRegisteredViews.Unregister(TcxBoldGridChartView);
  cxGridRegisteredViews.Unregister(TcxGridBoldBandedTableView);
  cxGridRegisteredViews.Unregister(TcxGridBoldLayoutView);

end.

