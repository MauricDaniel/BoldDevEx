# BoldDevEx
Bold-aware DevEx controls

'Express BoldEditors' component tab in IDE contains:

TcxBoldTextEdit, TcxBoldDateEdit, TcxBoldTimeEdit, TcxBoldMemo, TcxBoldCurrencyEdit, TcxBoldMaskEdit, TcxBoldCheckBox, TcxBoldComboBox, TcxBoldSpinEdit, TcxBoldButtonEdit, TcxBoldHyperLinkEdit, TcxBoldProgressBar, TcxBoldLabel, TcxBoldImage, TcxBoldRichEdit, TcxBoldListBox, TcxBoldCheckListBox, TcxBoldSelectionCheckListBox, TcxBoldListView, TcxBoldExtLookupComboBox, TcxBoldLookupComboBox, TcxBoldNBLookupComboBox, TcxBoldNBExtLookupComboBox, TdxBarBoldNavigator.

Also the following Bold aware Grid views are available:
  TcxGridBoldTableView, TcxGridBoldBandedTableView, TcxGridBoldCardView, TcxGridBoldLayoutView.
  
Please note that Layout view is declared but not implemented. Card view is implemented but not tested much.

All contols implement IBoldValidateableComponent which means they can be validated at design time via Bold menu/Validate Current Form

Instalation

1. Patching Bold source code. (see docs\BoldEnvironmentVCL.pas.html and docs\BoldQueue.pas.html)

BoldDevEx requires small changes in Bold source. It is neccesary to apply these changes for BoldDevEx.dpk to compile.
Bold design package also needs te be recompiled.

2. Patching DevEx source (see docs\cxGridCustomTableView.pas.html)

There is a change in DevEx source which is optional. It marks GetFilterValues virtual allowing override to efficiently prefetch value for the filtered column. If you decide to patch this file please include DevExChanges conditional define in Project Options.

3. Build and install BoldDevEx.dpk

BoldDevEx.dpk package needs to be installed in IDE.
