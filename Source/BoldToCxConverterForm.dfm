object frmBoldToCxConverter: TfrmBoldToCxConverter
  Left = 0
  Top = 0
  Caption = 'Standard Bold to DevExpress Boldified converter Options'
  ClientHeight = 440
  ClientWidth = 749
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    749
    440)
  PixelsPerInch = 96
  TextHeight = 13
  object DetectedComponentsGrid: TcxGrid
    Left = 0
    Top = 0
    Width = 749
    Height = 406
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tv: TcxGridTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsSelection.CellSelect = False
      OptionsSelection.HideFocusRectOnExit = False
      OptionsSelection.MultiSelect = True
      object tvColumn1: TcxGridColumn
        Caption = 'Component'
        Width = 209
      end
      object tvColumn2: TcxGridColumn
        Caption = 'Type'
        Width = 132
      end
      object tvColumn3: TcxGridColumn
        Caption = 'Ocl Type'
        Width = 211
      end
      object tvColumn4: TcxGridColumn
        Caption = 'Convert to'
        Width = 186
      end
    end
    object DetectedComponentsGridLevel1: TcxGridLevel
      GridView = tv
    end
  end
  object cxConvert: TcxButton
    Left = 585
    Top = 412
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Convert'
    ModalResult = 1
    TabOrder = 1
  end
  object cxCancelButton: TcxButton
    Left = 666
    Top = 412
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
    OnClick = cxCancelButtonClick
  end
  object cxRemoveAfterConvertionCheckbox: TcxCheckBox
    Left = 3
    Top = 412
    Anchors = [akRight, akBottom]
    Caption = 'Remove old components after convertion'
    State = cbsChecked
    TabOrder = 3
    Width = 222
  end
end
