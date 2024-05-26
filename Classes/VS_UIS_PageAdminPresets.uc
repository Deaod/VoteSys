class VS_UIS_PageAdminPresets extends VS_UIS_PageAdmin;

var VS_UI_PresetListBox PresetList;
var UWindowSmallButton AddPreset;
var UWindowSmallButton RemPreset;
var VS_UI_PresetListItem SelectedPreset;

var VS_UI_EditControl Edt_PresetName;
var localized string Text_PresetName;

var VS_UI_EditControl Edt_Category;
var localized string Text_Category;

var VS_UI_EditControl Edt_Abbreviation;
var localized string Text_Abbreviation;

var VS_UI_EditControl Edt_SortPriority;
var localized string Text_SortPriority;

var VS_UI_ArrayEditControl Adt_InheritFrom;
var localized string Text_InheritFrom;

var VS_UI_EditControl Edt_Game;
var localized string Text_Game;

var VS_UI_EditControl Edt_MapListName;
var localized string Text_MapListName;

var VS_UI_ArrayEditControl Adt_Mutators;
var localized string Text_Mutators;

var VS_UI_ArrayEditControl Adt_Parameters;
var localized string Text_Parameters;

function Created() {
	super.Created();

	PresetList = VS_UI_PresetListBox(CreateControl(class'VS_UI_PresetListBox', 4, 28, 188, 302));

	AddPreset = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 4, 8, 16, 16));
	AddPreset.SetText("+");

	RemPreset = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 24, 8, 16, 16));
	RemPreset.SetText("-");

	Edt_PresetName = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 200, 8, 188, 16));
	Edt_PresetName.SetText(Text_PresetName);
	Edt_PresetName.EditBoxWidth = 100;
	Edt_PresetName.SetDelayedNotify(true);

	Edt_Category = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 200, 28, 188, 16));
	Edt_Category.SetText(Text_Category);
	Edt_Category.EditBoxWidth = 100;
	Edt_Category.SetDelayedNotify(true);

	Edt_Abbreviation = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 200, 48, 188, 16));
	Edt_Abbreviation.SetText(Text_Abbreviation);
	Edt_Abbreviation.EditBoxWidth = 100;
	Edt_Abbreviation.SetDelayedNotify(true);

	Edt_SortPriority = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 200, 68, 188, 16));
	Edt_SortPriority.SetText(Text_SortPriority);
	Edt_SortPriority.EditBoxWidth = 60;
	Edt_SortPriority.SetNumericOnly(true);
	Edt_SortPriority.SetNumericNegative(true);

	Adt_InheritFrom = VS_UI_ArrayEditControl(CreateControl(class'VS_UI_ArrayEditControl', 200, 88, 188, 16));
	Adt_InheritFrom.SetText(Text_InheritFrom);
	Adt_InheritFrom.EditBoxWidth = 100;

	Edt_Game = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 200, 108, 188, 16));
	Edt_Game.SetText(Text_Game);
	Edt_Game.EditBoxWidth = 100;

	Edt_MapListName = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 200, 128, 188, 16));
	Edt_MapListName.SetText(Text_MapListName);
	Edt_MapListName.EditBoxWidth = 100;

	Adt_Mutators = VS_UI_ArrayEditControl(CreateControl(class'VS_UI_ArrayEditControl', 200, 148, 188, 16));
	Adt_Mutators.SetText(Text_Mutators);
	Adt_Mutators.EditBoxWidth = 100;

	Adt_Parameters = VS_UI_ArrayEditControl(CreateControl(class'VS_UI_ArrayEditControl', 200, 168, 188, 16));
	Adt_Parameters.SetText(Text_Parameters);
	Adt_Parameters.EditBoxWidth = 100;
}

function ApplyTheme() {
	PresetList.Theme = Theme;
	// AddPreset // not themed
	// RemPreset // not themed
	Edt_PresetName.Theme = Theme;
	Edt_Category.Theme = Theme;
	Edt_Abbreviation.Theme = Theme;
	Edt_SortPriority.Theme = Theme;
	Adt_InheritFrom.Theme = Theme;
	Edt_Game.Theme = Theme;
	Edt_MapListName.Theme = Theme;
	Adt_Mutators.Theme = Theme;
	Adt_Parameters.Theme = Theme;
}

function EnableInteraction(bool bEnable) {
	AddPreset.bDisabled = !bEnable;
	RemPreset.bDisabled = !bEnable;
	Edt_PresetName.EditBox.SetEditable(false);
	Edt_Category.EditBox.SetEditable(false);
	Edt_Abbreviation.EditBox.SetEditable(false);
	Edt_SortPriority.EditBox.SetEditable(false);
	Adt_InheritFrom.EditBox.SetEditable(false);
	Edt_Game.EditBox.SetEditable(false);
	Edt_MapListName.EditBox.SetEditable(false);
	Adt_Mutators.EditBox.SetEditable(false);
	Adt_Parameters.EditBox.SetEditable(false);
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	super.BeforePaint(C, MouseX, MouseY);

	if (SelectedPreset != PresetList.SelectedItem) {
		if (SelectedPreset != none) {
			SelectedPreset.Preset.PresetName = Edt_PresetName.GetValue();
			SelectedPreset.Preset.Category = Edt_Category.GetValue();
			SelectedPreset.Preset.Abbreviation = Edt_Abbreviation.GetValue();
			SelectedPreset.Preset.SortPriority = int(Edt_SortPriority.GetValue());
			SelectedPreset.Preset.SetPropertyText("InheritFrom", Adt_InheritFrom.GetValue());
			SelectedPreset.Preset.Game = Edt_Game.GetValue();
			SelectedPreset.Preset.SetPropertyText("MapListName", Edt_MapListName.GetValue());
			SelectedPreset.Preset.SetPropertyText("Mutators", Adt_Mutators.GetValue());
			SelectedPreset.Preset.SetPropertyText("Parameters", Adt_Parameters.GetValue());
		}

		SelectedPreset = VS_UI_PresetListItem(PresetList.SelectedItem);

		if (SelectedPreset != none) {
			Edt_PresetName.SetValue(SelectedPreset.Preset.PresetName);
			Edt_Category.SetValue(SelectedPreset.Preset.Category);
			Edt_Abbreviation.SetValue(SelectedPreset.Preset.Abbreviation);
			Edt_SortPriority.SetValue(string(SelectedPreset.Preset.SortPriority));
			Adt_InheritFrom.SetValue(SelectedPreset.Preset.GetPropertyText("InheritFrom"));
			Edt_Game.SetValue(SelectedPreset.Preset.Game);
			Edt_MapListName.SetValue(string(SelectedPreset.Preset.MapListName));
			Adt_Mutators.SetValue(SelectedPreset.Preset.GetPropertyText("Mutators"));
			Adt_Parameters.SetValue(SelectedPreset.Preset.GetPropertyText("Parameters"));
		} else {
			Edt_PresetName.SetValue(class'VS_PresetConfig'.default.PresetName);
			Edt_Category.SetValue(class'VS_PresetConfig'.default.Category);
			Edt_Abbreviation.SetValue(class'VS_PresetConfig'.default.Abbreviation);
			Edt_SortPriority.SetValue(string(class'VS_PresetConfig'.default.SortPriority));
			Adt_InheritFrom.SetValue("()");
			Edt_Game.SetValue(class'VS_PresetConfig'.default.Game);
			Edt_MapListName.SetValue(string(class'VS_PresetConfig'.default.MapListName));
			Adt_Mutators.SetValue("()");
			Adt_Parameters.SetValue("()");
		}

		Edt_PresetName.EditBox.SetEditable(SelectedPreset != none);
		Edt_Category.EditBox.SetEditable(SelectedPreset != none);
		Edt_Abbreviation.EditBox.SetEditable(SelectedPreset != none);
		Edt_SortPriority.EditBox.SetEditable(SelectedPreset != none);
		Adt_InheritFrom.EditBox.SetEditable(SelectedPreset != none);
		Edt_Game.EditBox.SetEditable(SelectedPreset != none);
		Edt_MapListName.EditBox.SetEditable(SelectedPreset != none);
		Adt_Mutators.EditBox.SetEditable(SelectedPreset != none);
		Adt_Parameters.EditBox.SetEditable(SelectedPreset != none);
	}
}

function Notify(UWindowDialogControl C, byte E) {
	if (E == DE_Click && C == AddPreset) {
		PresetList.SetSelectedItem(UWindowListBoxItem(PresetList.Items.Append(class'VS_UI_PresetListItem')));
		VS_UI_PresetListItem(PresetList.SelectedItem).Preset = new class'VS_ClientPreset';
	} else if (E == DE_Click && C == RemPreset) {
		if (SelectedPreset != none) {
			SelectedPreset.Remove();
			PresetList.SelectedItem = none;
		}
	} else if (E == DE_Change && C == Edt_PresetName) {
		if (SelectedPreset != none)
			SelectedPreset.Preset.PresetName = Edt_PresetName.GetValue();
	} else if (E == DE_Change && C == Edt_Category) {
		if (SelectedPreset != none)
			SelectedPreset.Preset.Category = Edt_Category.GetValue();
	} else if (E == DE_Change && C == Edt_Abbreviation) {
		if (SelectedPreset != none)
			SelectedPreset.Preset.Abbreviation = Edt_Abbreviation.GetValue();
	} else {
		super.Notify(C, E);
	}
}

function LoadServerSettings() {
	local int i;
	local VS_UI_PresetListItem P;

	PresetList.Items.DestroyList();
	for (i = 0; i < Presets.PresetList.Length; ++i) {
		if (Presets.PresetList[i].PresetName == "")
			continue;

		P = VS_UI_PresetListItem(PresetList.Items.Append(class'VS_UI_PresetListItem'));
		P.Preset = Presets.PresetList[i];
	}
}

function SaveSettings() {

	super.SaveSettings();
}

defaultproperties {
	Text_PresetName="Preset Name"
	Text_Category="Category"
	Text_Abbreviation="Abbreviation"
	Text_SortPriority="Sort Priority"
	Text_InheritFrom="Inherit From"
	Text_Game="Game"
	Text_MapListName="Map List Name"
	Text_Mutators="Mutators"
	Text_Parameters="Parameters"
}
