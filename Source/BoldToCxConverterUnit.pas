unit BoldToCxConverterUnit;

interface

uses
  Classes,
  Controls,
  SysUtils,
  BoldEdit,
  BoldVariantControlPack,
  BoldStringControlPack,
  BoldComboBox,
  BoldGrid,
  cxBoldEditors,
  cxGridBoldSupportUnit,
  cxGridPopupMenu,
  BoldToCxConverterForm,

  cxGridCustomTableView;

type
  TBoldToCxConverter = class(TComponent)
  private
    fBoldToCxConverterForm : TfrmBoldToCxConverter;
    fBoldComponents : TStringList;

    procedure ConvertGrid(aBoldGrid : TBoldGrid);
    procedure CopyBoldColumn(aBoldColumn : TBoldGridColumn; aCxGridBoldColumn : TCxGridBoldColumn);
    procedure CountNumberOfBoldComponents(var vBoldComponentCount: Integer; AOwner: TComponent);
    procedure FoundGrid(aGrid: TBoldGrid);
    procedure FoundEdit(anEdit: TBoldEdit);
    procedure FoundComboBox(aComboBox : TBoldComboBox);
    procedure FoundBoldComponent(aComponent: TComponent);
    procedure ConvertBoldEdit(aBoldEdit: TBoldEdit);

    procedure ConvertBoldComboBox(aBoldComboBox: TBoldComboBox);
    procedure CopyPublishedProperties(FromControl, ToControl: TControl);
    procedure CopyFollowerProperties(FromFollower: TBoldStringFollowerController; ToFollower: TBoldVariantFollowerController);
    procedure CopyBoldComboListControllerProperties(FromComboListController: BoldComboBox.TBoldComboListController; ToComboListController: cxBoldEditors.TBoldComboListController);
    procedure ConvertBoldEditToDateEdit(aBoldEdit: TBoldEdit);
  protected
    function GridController : TcxGridDataController;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy;override;
    { Public declarations }
  published
    { Published declarations }
  end;

const
  Ctrlf = #13#10;

procedure Register;

implementation
uses Dialogs, cxGrid,Forms, BoldElements,  CxEdit;

procedure Register;
begin
  RegisterComponents('Express BoldEditors', [TBoldToCxConverter]);
end;

{ TBoldToCxGridConverter }

constructor TBoldToCxConverter.Create(AOwner: TComponent);
var
  vBoldComponentCount : Integer;
  I : Integer;
  vComponent: TComponent;
begin
  inherited;
  fBoldComponents := TStringList.Create;
  Application.CreateForm(TfrmBoldToCxConverter,fBoldToCxConverterForm);
  CountNumberOfBoldComponents(vBoldComponentCount, AOwner);
  GridController.RecordCount := vBoldComponentCount;

  for I := 0 to AOwner.ComponentCount - 1 do
  begin
    vComponent := AOwner.Components[I];
    if (vComponent is TBoldGrid) then FoundGrid(vComponent as TBoldGrid);
    if (vComponent is TBoldEdit) then FoundEdit(vComponent as TBoldEdit);
    if (vComponent is TBoldComboBox) then FoundComboBox(vComponent as TBoldComboBox);
  end;
  if fBoldToCxConverterForm.ShowModal = mrOK then
  begin
    for I := fBoldComponents.Count - 1 downto 0 do
    begin
        vComponent := fBoldComponents.Objects[I] as TComponent;
        if vComponent is TBoldGrid then ConvertGrid(vComponent as TBoldGrid);
        if vComponent is TBoldEdit then
        begin
          if GridController.Values[I,3] = 'TcxBoldDateEdit' then
            ConvertBoldEditToDateEdit(vComponent as TBoldEdit)
          else
            ConvertBoldEdit(vComponent as TBoldEdit)
        end;
        if vComponent is TBoldComboBox then ConvertBoldComboBox(vComponent as TBoldComboBox);

        if fBoldToCxConverterForm.cxRemoveAfterConvertionCheckbox.Checked then
          vComponent.Free;
        
    end;
  end;
end;

destructor TBoldToCxConverter.Destroy;
begin
  fBoldToCxConverterForm.Close;
  fBoldToCxConverterForm.Free;
  fBoldComponents.Free;
  inherited;
end;

procedure TBoldToCxConverter.FoundBoldComponent(aComponent : TComponent);
begin
  fBoldComponents.AddObject(aComponent.Name,aComponent);
  GridController.Values[fBoldComponents.Count - 1, 0] := aComponent.Name;
  GridController.Values[fBoldComponents.Count - 1, 1] := aComponent.ClassName;
end;

procedure TBoldToCxConverter.FoundComboBox(aComboBox: TBoldComboBox);
begin
  FoundBoldComponent(aComboBox);
  GridController.Values[fBoldComponents.Count - 1, 3] := 'TcxBoldComboBox';
end;

procedure TBoldToCxConverter.FoundGrid(aGrid : TBoldGrid);
begin
  FoundBoldComponent(aGrid);
  GridController.Values[fBoldComponents.Count - 1, 3] := 'TcxGridBoldTableView';
end;

procedure TBoldToCxConverter.FoundEdit(anEdit : TBoldEdit);
var
  ExpressionType: TBoldElementTypeInfo;
  vProposedComponent: string;
begin
  ExpressionType := nil;
  FoundBoldComponent(anEdit);
  vProposedComponent := 'Unknown';

  if Assigned(anEdit.BoldHandle) and Assigned(anEdit.BoldHandle.BoldType) and Assigned(anEdit.BoldHandle.BoldType.Evaluator) then
    ExpressionType := anEdit.BoldHandle.BoldType.Evaluator.ExpressionType(anEdit.BoldProperties.expression,anEdit.BoldHandle.BoldType,false);

  if Assigned(ExpressionType) then
  begin
    GridController.Values[fBoldComponents.Count - 1, 2] := ExpressionType.DelphiName;

    if ExpressionType.DelphiName = 'TBADateTime' then
      vProposedComponent := 'TcxBoldDateEdit'
    else if ExpressionType.DelphiName = 'TBABoolean' then
      vProposedComponent := 'TcxBoldCheckBox'
    else
      vProposedComponent := 'TcxBoldTextEdit';
  end;
  GridController.Values[fBoldComponents.Count - 1, 3] := vProposedComponent;
end;

function TBoldToCxConverter.GridController: TcxGridDataController;
begin
  Result := fBoldToCxConverterForm.tv.DataController;
end;

procedure TBoldToCxConverter.CountNumberOfBoldComponents(var vBoldComponentCount: Integer; AOwner: TComponent);
var
  I: Integer;
  vComponent: TComponent;
begin
  vBoldComponentCount := 0;
  for I := 0 to AOwner.ComponentCount - 1 do
  begin
    vComponent := AOwner.Components[I];
    if (vComponent is TBoldGrid) or (vComponent is TBoldEdit) or (vComponent is TBoldComboBox) then
      Inc(vBoldComponentCount);
  end;
end;

procedure TBoldToCxConverter.CopyBoldColumn(aBoldColumn: TBoldGridColumn;aCxGridBoldColumn: TCxGridBoldColumn);
begin
    aCxGridBoldColumn.DataBinding.BoldProperties.Expression := aBoldColumn.BoldProperties.Expression;
    aCxGridBoldColumn.Caption := aBoldColumn.Title.Caption;
    try
      aCxGridBoldColumn.name := 'col' + AnsiUpperCase(aBoldColumn.BoldProperties.Expression[1]) + Copy(aBoldColumn.BoldProperties.Expression, 2, 1000);
    except
      aCxGridBoldColumn.name := 'Column' + IntToStr(aCxGridBoldColumn.Index);
    end;
end;

procedure TBoldToCxConverter.CopyBoldComboListControllerProperties(FromComboListController : BoldComboBox.TBoldComboListController; ToComboListController: cxBoldEditors.TBoldComboListController);
begin
  with FromComboListController do
  begin
    ToComboListController.DragMode := DragMode;
    ToComboListController.DropMode := DropMode;
    ToComboListController.NilElementMode := NilElementMode;
  end;

end;

procedure TBoldToCxConverter.ConvertGrid(aBoldGrid : TBoldGrid);
var
  vCxGrid : TCxGrid;
  vCxGridBoldTableView : TcxGridBoldTableView;
  vCol : Integer;
begin
  vCxGrid := TcxGrid.Create(aBoldGrid.Owner);
  CopyPublishedProperties	(aBoldGrid,vCxGrid);

  vCxGridBoldTableView := vCxGrid.CreateView(TcxGridBoldTableView) as TcxGridBoldTableView;
  vCxGridBoldTableView.Name := vCxGrid.Name + 'BoldTableView';

  vCxGridBoldTableView.DataController.BoldHandle := aBoldGrid.BoldHandle;
  vCxGrid.Levels[0].GridView := vCxGridBoldTableView;
  vCxGridBoldTableView.OptionsData.Editing := False;
  vCxGridBoldTableView.OptionsView.GroupByBox := False;
  vCxGridBoldTableView.OptionsBehavior.CellHints := True;
  vCxGridBoldTableView.OptionsSelection.CellSelect := False;

  for vCol := 1 to aBoldGrid.ColCount - 1 do
    CopyBoldColumn(aBoldGrid.Columns[vCol],vCxGridBoldTableView.CreateItem as TcxGridBoldColumn );
end;

procedure TBoldToCxConverter.CopyPublishedProperties(FromControl, ToControl : TControl);
var
  OldName : string;
begin

  with FromControl do
  begin
    ToControl.Align := Align;
    ToControl.AlignWithMargins := AlignWithMargins;
    ToControl.Anchors := Anchors;
    ToControl.Constraints := Constraints;
    ToControl.Cursor := Cursor;
    ToControl.Height := Height;
    ToControl.HelpContext := HelpContext;
    ToControl.HelpKeyword := HelpKeyword;
    ToControl.HelpType := HelpType;
    ToControl.Hint := Hint;
    ToControl.Left := Left;
    ToControl.Margins := Margins;
    ToControl.Parent := Parent;
    ToControl.Tag := Tag;
    ToControl.Top := Top;
    ToControl.Width := Width;
    ToControl.Enabled := Enabled;
    ToControl.ShowHint := ShowHint;

    OldName := Name;
    Name := 'old' + Name;
  end;
  ToControl.Name := OldName;

end;

procedure TBoldToCxConverter.ConvertBoldEdit(aBoldEdit : TBoldEdit);
var
  vCxBoldEdit : TcxBoldTextEdit;
begin
  vCxBoldEdit := TcxBoldTextEdit.Create(aBoldEdit.Owner);
  CopyPublishedProperties(aBoldEdit, vCxBoldEdit);
  vCxBoldEdit.DataBinding.BoldHandle := aBoldEdit.BoldHandle;
  vCxBoldEdit.DataBinding.BoldProperties.Expression := aBoldEdit.BoldProperties.Expression;
  CopyFollowerProperties(aBoldEdit.BoldProperties,vCxBoldEdit.DataBinding.BoldProperties);

  vCxBoldEdit.Properties.Alignment.Horz := aBoldEdit.Alignment;
  vCxBoldEdit.Properties.AutoSelect := aBoldEdit.AutoSelect;
  vCxBoldEdit.Autosize := aBoldEdit.Autosize;
  vCXBoldEdit.Style.BorderStyle := ebsFlat; //ABoldEdit.BorderStyle;
  vCxBoldEdit.Properties.CharCase := aBoldEdit.CharCase;
  vCXBoldEdit.Style.Color := aBoldEdit.Color;
  vCxBoldEdit.DragCursor := aBoldEdit.DragCursor;
  vCxBoldEdit.DragKind := aBoldEdit.DragKind;
  vCxBoldEdit.DragMode := aBoldEdit.DragMode;
  vCxBoldEdit.Style.Font := aBoldEdit.Font;
  vCxBoldEdit.ParentColor := aBoldEdit.ParentColor;
//  vCxBoldEdit.ParentCtl3D := aBoldEdit.ParentCtl3D;
//MaxLength
  vCxBoldEdit.ParentFont := aBoldEdit.ParentFont;
  vCxBoldEdit.Properties.PasswordChar := aBoldEdit.PasswordChar;

  vCxBoldEdit.PopupMenu := aBoldEdit.PopupMenu;
  vCxBoldEdit.Properties.ReadOnly := aBoldEdit.ReadOnly;
  vCxBoldEdit.TabOrder := aBoldEdit.TabOrder;
  vCxBoldEdit.TabStop := aBoldEdit.TabStop;
end;

procedure TBoldToCxConverter.ConvertBoldEditToDateEdit(aBoldEdit : TBoldEdit);
var
  vCxBoldDateEdit : TcxBoldDateEdit;
begin
  vCxBoldDateEdit := TcxBoldDateEdit.Create(aBoldEdit.Owner);
  CopyPublishedProperties(aBoldEdit, vCxBoldDateEdit);
  vCxBoldDateEdit.DataBinding.BoldHandle := aBoldEdit.BoldHandle;
  vCxBoldDateEdit.DataBinding.BoldProperties.Expression := aBoldEdit.BoldProperties.Expression;
  CopyFollowerProperties(aBoldEdit.BoldProperties,vCxBoldDateEdit.DataBinding.BoldProperties);

  vCxBoldDateEdit.Properties.Alignment.Horz := aBoldEdit.Alignment;
  vCxBoldDateEdit.Properties.AutoSelect := aBoldEdit.AutoSelect;
  vCxBoldDateEdit.Autosize := aBoldEdit.Autosize;
  vCxBoldDateEdit.Style.BorderStyle := ebsFlat; //ABoldEdit.BorderStyle;
  vCxBoldDateEdit.Properties.CharCase := aBoldEdit.CharCase;
  vCxBoldDateEdit.Style.Color := aBoldEdit.Color;
  vCxBoldDateEdit.DragCursor := aBoldEdit.DragCursor;
  vCxBoldDateEdit.DragKind := aBoldEdit.DragKind;
  vCxBoldDateEdit.DragMode := aBoldEdit.DragMode;
  vCxBoldDateEdit.Style.Font := aBoldEdit.Font;
  vCxBoldDateEdit.ParentColor := aBoldEdit.ParentColor;
//  vCxBoldDateEdit.ParentCtl3D := aBoldEdit.ParentCtl3D;
//MaxLength
  vCxBoldDateEdit.ParentFont := aBoldEdit.ParentFont;
  vCxBoldDateEdit.Properties.PasswordChar := aBoldEdit.PasswordChar;

  vCxBoldDateEdit.PopupMenu := aBoldEdit.PopupMenu;
  vCxBoldDateEdit.Properties.ReadOnly := aBoldEdit.ReadOnly;
  vCxBoldDateEdit.TabOrder := aBoldEdit.TabOrder;
  vCxBoldDateEdit.TabStop := aBoldEdit.TabStop;
end;


procedure TBoldToCxConverter.CopyFollowerProperties(FromFollower : TBoldStringFollowerController; ToFollower : TBoldVariantFollowerController);
begin
  with FromFollower do
  begin
    ToFollower.Expression := Expression;
    ToFollower.ApplyPolicy := ApplyPolicy;
    ToFollower.CleanOnEqual := CleanOnEqual;
    ToFollower.DragMode := DragMode;
    ToFollower.DropMode := DropMode;
    ToFollower.NilRepresentation := NilStringRepresentation;
    ToFollower.Representation := Representation;
    ToFollower.Variables := Variables;
    //Renderer  One is variant and the other stringrenderer
  end;
end;

procedure TBoldToCxConverter.ConvertBoldComboBox(aBoldComboBox : TBoldComboBox);
var
  vCxBoldComboBox : TcxBoldComboBox;
begin
  vCxBoldComboBox := TcxBoldComboBox.Create(aBoldComboBox.Owner);
  CopyPublishedProperties	(aBoldComboBox, vCxBoldComboBox);
  CopyFollowerProperties(aBoldComboBox.BoldProperties,vCxBoldComboBox.DataBinding.BoldProperties);
  CopyBoldComboListControllerProperties(aBoldComboBox.BoldListProperties, vCxBoldComboBox.Properties.BoldLookupListProperties);

  vCxBoldComboBox.DataBinding.BoldHandle := aBoldComboBox.BoldHandle;
  CopyFollowerProperties(aBoldComboBox.BoldRowProperties, vCxBoldComboBox.Properties.BoldRowProperties);
  vCxBoldComboBox.Properties.BoldLookupListHandle := aBoldComboBox.BoldListHandle;

  vCxBoldComboBox.Properties.Alignment.Horz := aBoldComboBox.Alignment;
  vCxBoldComboBox.AlignWithMargins := ABoldComboBox.AlignWithMargins;
  //vCxBoldComboBox.Properties.AutoSelect := aBoldComboBox.AutoSelect;
  //vCxBoldComboBox.Autosize := aBoldComboBox.Autosize;
  vCXBoldComboBox.Style.BorderStyle := ebsFlat; //ABoldComboBox.BorderStyle;
  vCxBoldComboBox.Properties.CharCase := aBoldComboBox.CharCase;
  vCXBoldComboBox.Style.Color := aBoldComboBox.Color;
  vCxBoldComboBox.DragCursor := aBoldComboBox.DragCursor;
  vCxBoldComboBox.DragKind := aBoldComboBox.DragKind;
  vCxBoldComboBox.DragMode := aBoldComboBox.DragMode;
  vCxBoldComboBox.Style.Font := aBoldComboBox.Font;
  vCxBoldComboBox.ParentColor := aBoldComboBox.ParentColor;
  //  vCxBoldComboBox.ParentCtl3D := aBoldComboBox.ParentCtl3D;
  //MaxLength
  vCxBoldComboBox.ParentFont := aBoldComboBox.ParentFont;
  vCxBoldComboBox.ParentShowHint := aBoldComboBox.ParentShowHint;
  //vCxBoldComboBox.Properties.PasswordChar := aBoldComboBox.PasswordChar;

  vCxBoldComboBox.PopupMenu := aBoldComboBox.PopupMenu;
  vCxBoldComboBox.Properties.ReadOnly := aBoldComboBox.ReadOnly;
  vCxBoldComboBox.TabOrder := aBoldComboBox.TabOrder;
  vCxBoldComboBox.TabStop := aBoldComboBox.TabStop;
  vCxBoldComboBox.Properties.BoldSelectChangeAction := aBoldComboBox.BoldSelectChangeAction;
  vCxBoldComboBox.Properties.BoldSetValueExpression := aBoldComboBox.BoldSetValueExpression;

  vCXBoldCombobox.Properties.OnChange := aBoldComboBox.OnChange;
  vCXBoldCombobox.OnClick := aBoldComboBox.OnClick;
  vCXBoldCombobox.OnContextPopup := aBoldComboBox.OnContextPopup;
  vCXBoldCombobox.OnDblClick := aBoldComboBox.OnDblClick;
  vCXBoldCombobox.OnDragDrop := aBoldComboBox.OnDragDrop;
  vCXBoldCombobox.OnDragOver := aBoldComboBox.OnDragOver;
  //vCXBoldCombobox.Properties.OnDrawItem := aBoldComboBox.OnDrawItem;
  //vCXBoldCombobox.OnDropDown := ????
  vCXBoldCombobox.OnEndDock := aBoldComboBox.OnEndDock;
  vCXBoldCombobox.OnEndDrag := aBoldComboBox.OnEndDrag;
  vCXBoldCombobox.OnEnter := aBoldComboBox.OnEnter;
  vCXBoldCombobox.OnExit := aBoldComboBox.OnExit;
  vCXBoldCombobox.OnKeyDown := aBoldComboBox.OnKeyDown;
  vCXBoldCombobox.OnKeyPress := aBoldComboBox.OnKeyPress;
  vCXBoldCombobox.OnKeyUp := aBoldComboBox.OnKeyUp;
  //vCXBoldCombobox.Properties.OnMeasureItem := aBoldComboBox.OnMeasureItem;
  //vCXBoldCombobox.Properties.OnSelectChanged := aBoldComboBox.OnSelectChanged;
  vCXBoldCombobox.OnStartDock := aBoldComboBox.OnStartDock;
  vCXBoldCombobox.OnStartDrag := aBoldComboBox.OnStartDrag;
  vCXBoldCombobox.PopupMenu := aBoldComboBox.PopupMenu;

end;

end.
