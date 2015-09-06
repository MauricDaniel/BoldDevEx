# BoldDevEx
Bold-aware DevEx controls

'Express BoldEditors' component tab in IDE contains:

TcxBoldTextEdit, TcxBoldDateEdit, TcxBoldTimeEdit, TcxBoldMemo, TcxBoldCurrencyEdit, TcxBoldMaskEdit, TcxBoldCheckBox, TcxBoldComboBox, TcxBoldSpinEdit, TcxBoldButtonEdit, TcxBoldHyperLinkEdit, TcxBoldProgressBar, TcxBoldLabel, TcxBoldImage, TcxBoldRichEdit, TcxBoldListBox, TcxBoldCheckListBox, TcxBoldSelectionCheckListBox, TcxBoldListView, TcxBoldExtLookupComboBox, TcxBoldLookupComboBox, TcxBoldNBLookupComboBox, TcxBoldNBExtLookupComboBox, TdxBarBoldNavigator.

Also the following Bold aware Grid views are available:
  TcxGridBoldTableView, TcxGridBoldBandedTableView, TcxGridBoldCardView, TcxGridBoldLayoutView.
  
Please note that Layout view is declared but not implemented. Card view is implemented but not tested much.

All controls implement IBoldValidateableComponent which means they can be validated at design time via Bold menu/Validate Current Form

Installation

Tested in Delphi 2007. Might work, but not tested in Delphi 7.
Works with latest official release Bold for Delphi 2006.

1. Patching Bold source code. (see docs\BoldEnvironmentVCL.pas.html and docs\BoldQueue.pas.html)

BoldDevEx requires small changes in Bold source. It is necessary to apply these changes for BoldDevEx.dpk to compile.
Bold design package also needs te be recompiled.

2. Patching DevEx source (see docs\cxGridCustomTableView.pas.html)

There is a change in DevEx source which is optional. It marks GetFilterValues virtual allowing override to efficiently prefetch value for the filtered column. If you decide to patch this file please include DevExChanges conditional define in Project Options.

3. Build and install BoldDevEx.dpk

BoldDevEx.dpk package needs to be installed in IDE.


Usage

Controls are available via 'Express BoldEditors' component tab in IDE.
Grid views are available for selection when creating new grid views.


Converting existing forms to use BoldDevEx controls

There are two converter components available which help convert forms with standard Bold controls into BoldDevEx versions. To use it, drop TBoldToCxConverter or TBoldToCxGridConverter on a form and a conversion dialog will appear. Finally delete the converter component.
