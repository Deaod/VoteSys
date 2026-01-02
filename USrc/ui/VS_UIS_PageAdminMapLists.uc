class VS_UIS_PageAdminMapLists extends VS_UIS_PageAdmin;

var VS_UI_MapListLB MapListLB;
var UWindowSmallButton AddMapList;
var UWindowSmallButton RemMapList;
var VS_UI_MapListLI SelectedMapList;
var VS_ClientMapList DefaultMapList;

var VS_UI_EditControl Edt_MapListName;
var localized string Text_MapListName;

var VS_UI_ArrayEditString Adt_Map;
var localized string Text_Map;

var VS_UI_ArrayEditString Adt_IgnoreMap;
var localized string Text_IgnoreMap;

var VS_UI_ArrayEditString Adt_IncludeMapsWithPrefix;
var localized string Text_IncludeMapsWithPrefix;

var VS_UI_ArrayEditString Adt_IgnoreMapsWithPrefix;
var localized string Text_IgnoreMapsWithPrefix;

var VS_UI_ArrayEditName Adt_IncludeList;
var localized string Text_IncludeList;

var VS_UI_ArrayEditName Adt_IgnoreList;
var localized string Text_IgnoreList;

function Created() {
	DefaultMapList = new class'VS_ClientMapList';

	MapListLB = VS_UI_MapListLB(CreateControl(class'VS_UI_MapListLB', 4, 28, 176, 302));

	AddMapList = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 4, 8, 16, 16));
	AddMapList.SetText("+");

	RemMapList = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 24, 8, 16, 16));
	RemMapList.SetText("-");

	Edt_MapListName = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 188, 28, 200, 16));
	Edt_MapListName.SetText(Text_MapListName);
	Edt_MapListName.EditBoxWidth = 100;
	Edt_MapListName.EditBox.MaxLength = 63;

	Adt_Map = VS_UI_ArrayEditString(CreateControl(class'VS_UI_ArrayEditString', 188, 48, 200, 16));
	Adt_Map.SetText(Text_Map);
	Adt_Map.EditBoxWidth = 100;
	Adt_Map.EditBox.MaxLength = 65000;

	Adt_IgnoreMap = VS_UI_ArrayEditString(CreateControl(class'VS_UI_ArrayEditString', 188, 68, 200, 16));
	Adt_IgnoreMap.SetText(Text_IgnoreMap);
	Adt_IgnoreMap.EditBoxWidth = 100;
	Adt_IgnoreMap.EditBox.MaxLength = 65000;

	Adt_IncludeMapsWithPrefix = VS_UI_ArrayEditString(CreateControl(class'VS_UI_ArrayEditString', 188, 88, 200, 16));
	Adt_IncludeMapsWithPrefix.SetText(Text_IncludeMapsWithPrefix);
	Adt_IncludeMapsWithPrefix.EditBoxWidth = 100;
	Adt_IncludeMapsWithPrefix.EditBox.MaxLength = 65000;

	Adt_IgnoreMapsWithPrefix = VS_UI_ArrayEditString(CreateControl(class'VS_UI_ArrayEditString', 188, 108, 200, 16));
	Adt_IgnoreMapsWithPrefix.SetText(Text_IgnoreMapsWithPrefix);
	Adt_IgnoreMapsWithPrefix.EditBoxWidth = 100;
	Adt_IgnoreMapsWithPrefix.EditBox.MaxLength = 65000;

	Adt_IncludeList = VS_UI_ArrayEditName(CreateControl(class'VS_UI_ArrayEditName', 188, 128, 200, 16));
	Adt_IncludeList.SetText(Text_IncludeList);
	Adt_IncludeList.EditBoxWidth = 100;
	Adt_IncludeList.EditBox.MaxLength = 65000;

	Adt_IgnoreList = VS_UI_ArrayEditName(CreateControl(class'VS_UI_ArrayEditName', 188, 148, 200, 16));
	Adt_IgnoreList.SetText(Text_IgnoreList);
	Adt_IgnoreList.EditBoxWidth = 100;
	Adt_IgnoreList.EditBox.MaxLength = 65000;

	super.Created();
}

function ApplyTheme() {
	MapListLB.Theme = Theme;
	Edt_MapListName.Theme = Theme;
	Adt_Map.SetTheme(Theme);
	Adt_IgnoreMap.SetTheme(Theme);
	Adt_IncludeMapsWithPrefix.SetTheme(Theme);
	Adt_IgnoreMapsWithPrefix.SetTheme(Theme);
	Adt_IncludeList.SetTheme(Theme);
	Adt_IgnoreList.SetTheme(Theme);
}

function EnableInteraction(bool bEnable) {
	AddMapList.bDisabled = !bEnable;
	RemMapList.bDisabled = !bEnable;
	Edt_MapListName.EditBox.SetEditable(false);
	Adt_Map.SetEnabled(false);
	Adt_IgnoreMap.SetEnabled(false);
	Adt_IncludeMapsWithPrefix.SetEnabled(false);
	Adt_IgnoreMapsWithPrefix.SetEnabled(false);
	Adt_IncludeList.SetEnabled(false);
	Adt_IgnoreList.SetEnabled(false);
}

function SaveMapListSettings() {
	if (SelectedMapList == none)
		return;

	SelectedMapList.MapList.MapListName = Edt_MapListName.GetValue();
	SelectedMapList.MapList.SetPropertyText("Map", Adt_Map.GetValue());
	SelectedMapList.MapList.SetPropertyText("IgnoreMap", Adt_IgnoreMap.GetValue());
	SelectedMapList.MapList.SetPropertyText("IncludeMapsWithPrefix", Adt_IncludeMapsWithPrefix.GetValue());
	SelectedMapList.MapList.SetPropertyText("IgnoreMapsWithPrefix", Adt_IgnoreMapsWithPrefix.GetValue());
	SelectedMapList.MapList.SetPropertyText("IncludeList", Adt_IncludeList.GetValue());
	SelectedMapList.MapList.SetPropertyText("IgnoreList", Adt_IgnoreList.GetValue());
}

function LoadMapListSettings(VS_ClientMapList M) {
	if (M == none)
		M = DefaultMapList;

	Edt_MapListName.SetValue(M.MapListName);
	Adt_Map.SetValue(M.GetPropertyText("Map"));
	Adt_IgnoreMap.SetValue(M.GetPropertyText("IgnoreMap"));
	Adt_IncludeMapsWithPrefix.SetValue(M.GetPropertyText("IncludeMapsWithPrefix"));
	Adt_IgnoreMapsWithPrefix.SetValue(M.GetPropertyText("IgnoreMapsWithPrefix"));
	Adt_IncludeList.SetValue(M.GetPropertyText("IncludeList"));
	Adt_IgnoreList.SetValue(M.GetPropertyText("IgnoreList"));
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	super.BeforePaint(C, MouseX, MouseY);

	if (SelectedMapList != MapListLB.SelectedItem) {
		SaveMapListSettings();
		SelectedMapList = VS_UI_MapListLI(MapListLB.SelectedItem);
		LoadMapListSettings(SelectedMapList.MapList);

		Edt_MapListName.EditBox.SetEditable(SelectedMapList != none);
		Adt_Map.SetEnabled(SelectedMapList != none);
		Adt_IgnoreMap.SetEnabled(SelectedMapList != none);
		Adt_IncludeMapsWithPrefix.SetEnabled(SelectedMapList != none);
		Adt_IgnoreMapsWithPrefix.SetEnabled(SelectedMapList != none);
		Adt_IncludeList.SetEnabled(SelectedMapList != none);
		Adt_IgnoreList.SetEnabled(SelectedMapList != none);
	}
}

function Notify(UWindowDialogControl C, byte E) {
	if (E == DE_Click && C == AddMapList) {
		MapListLB.SetSelectedItem(UWindowListBoxItem(MapListLB.Items.Append(class'VS_UI_MapListLI')));
		VS_UI_MapListLI(MapListLB.SelectedItem).MapList = new class'VS_ClientMapList';
	} else if (E == DE_Click && C == RemMapList) {
		if (SelectedMapList != none) {
			SelectedMapList.Remove();
			MapListLB.ClearSelection();
		}
	} else if (E == DE_Change && C == Edt_MapListName) {
		if (SelectedMapList != none)
			SelectedMapList.MapList.MapListName = Edt_MapListName.GetValue();
	} else {
		super.Notify(C, E);
	}
}

function LoadServerSettings() {
	local int i;
	local VS_UI_MapListLI M;

	MapListLB.Items.Clear();
	MapListLB.ClearSelection();

	for (i = 0; i < MapLists.MapLists.Length; ++i) {
		if (MapLists.MapLists[i].MapListName == "")
			continue;

		M = VS_UI_MapListLI(MapListLB.Items.Append(class'VS_UI_MapListLI'));
		M.MapList = MapLists.MapLists[i];
	}

	LoadMapListSettings(none);
}

function SaveSettings() {
	local int i;
	local VS_UI_MapListLI M;

	SaveMapListSettings();

	for (M = VS_UI_MapListLI(MapListLB.Items.Next); M != none; M = VS_UI_MapListLI(M.Next)) {
		if (i >= MapLists.MapLists.Length)
			MapLists.MapLists.Insert(i, 1);
		MapLists.MapLists[i++] = M.MapList;
	}

	while(i < MapLists.MapLists.Length) {
		MapLists.MapLists[i++] = none;
	}

	super.SaveSettings();
}

defaultproperties {
	Text_MapListName="Map List Name"
	Text_Map="Include Maps"
	Text_IgnoreMap="Exclude Maps"
	Text_IncludeMapsWithPrefix="Include Prefixes"
	Text_IgnoreMapsWithPrefix="Exclude Prefixes"
	Text_IncludeList="Include Lists"
	Text_IgnoreList="Exclude Lists"
}
