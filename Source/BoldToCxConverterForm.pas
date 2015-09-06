unit BoldToCxConverterForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  Menus, cxContainer, cxCheckBox, StdCtrls, cxButtons, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxClasses, cxGridCustomView, cxGrid;

type
  TfrmBoldToCxConverter = class(TForm)
    DetectedComponentsGrid: TcxGrid;
    DetectedComponentsGridLevel1: TcxGridLevel;
    tv: TcxGridTableView;
    tvColumn1: TcxGridColumn;
    tvColumn2: TcxGridColumn;
    tvColumn3: TcxGridColumn;
    tvColumn4: TcxGridColumn;
    cxConvert: TcxButton;
    cxCancelButton: TcxButton;
    cxRemoveAfterConvertionCheckbox: TcxCheckBox;
    procedure cxCancelButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBoldToCxConverter: TfrmBoldToCxConverter;

implementation

{$R *.dfm}

procedure TfrmBoldToCxConverter.cxCancelButtonClick(Sender: TObject);
begin
  Self.Close;
end;

end.
