class VS_UIS_PageClient extends VS_UIS_Page;

var VS_ClientSettings Settings;

var VS_UI_ComboControl Cmb_Theme;
var localized string ThemeText;
var localized string ThemeBright;
var localized string ThemeDark;
var localized string ThemeBlack;

var VS_UI_ComboControl Cmb_MapListSort;
var localized string MapListSortText;
var localized string MapListSortName;
var localized string MapListSortRecency;
var localized string MapListSortPlayCount;

var VS_UI_Checkbox Chk_FavoritesFirst;
var localized string FavoritesFirstText;

var VS_UI_Checkbox Chk_ShowPlayerList;
var localized string ShowPlayerListText;

function Created() {
	super.Created();

	Cmb_Theme = VS_UI_ComboControl(CreateControl(class'VS_UI_ComboControl', 8, 8, 188, 16));
	Cmb_Theme.SetText(ThemeText);
	Cmb_Theme.AddItem(ThemeBright);
	Cmb_Theme.AddItem(ThemeDark);
	Cmb_Theme.AddItem(ThemeBlack);
	Cmb_Theme.SetEditable(false);

	Cmb_MapListSort = VS_UI_ComboControl(CreateControl(class'VS_UI_ComboControl', 8, 28, 188, 16));
	Cmb_MapListSort.SetText(MapListSortText);
	Cmb_MapListSort.AddItem(MapListSortName);
	Cmb_MapListSort.AddItem(MapListSortRecency);
	Cmb_MapListSort.AddItem(MapListSortPlayCount);
	Cmb_MapListSort.SetEditable(false);

	Chk_FavoritesFirst = VS_UI_Checkbox(CreateControl(class'VS_UI_Checkbox', 8, 48, 188, 16));
	Chk_FavoritesFirst.SetText(FavoritesFirstText);

	Chk_ShowPlayerList = VS_UI_Checkbox(CreateControl(class'VS_UI_Checkbox', 8, 68, 188, 16));
	Chk_ShowPlayerList.SetText(ShowPlayerListText);
}

function LoadSettings(VS_PlayerChannel C) {
	super.LoadSettings(C);

	Settings = C.Settings;

	Cmb_Theme.SetSelectedIndex(Settings.Theme);
	Cmb_MapListSort.SetSelectedIndex(Settings.MapListSort);
	Chk_FavoritesFirst.bChecked = Settings.bFavoritesFirst;
	Chk_ShowPlayerList.bChecked = Settings.bShowPlayerList;
}

function SaveSettings() {
	Settings.Theme = Settings.IntToTheme(Cmb_Theme.GetSelectedIndex());
	Settings.MapListSort = Settings.IntToMapListSort(Cmb_MapListSort.GetSelectedIndex());
	Settings.bFavoritesFirst = Chk_FavoritesFirst.bChecked;
	Settings.bShowPlayerList = Chk_ShowPlayerList.bChecked;

	Settings.SaveConfig();
}

function ApplyTheme() {
	Cmb_Theme.Theme = Theme;
	Cmb_MapListSort.Theme = Theme;
}

defaultproperties {
	ThemeText="Theme"
	ThemeBright="Bright"
	ThemeDark="Dark"
	ThemeBlack="Black"

	MapListSortText="Sort Map List By"
	MapListSortName="Name"
	MapListSortRecency="Recency"
	MapListSortPlayCount="Play Count"

	FavoritesFirstText="Sort Favorites First"
	ShowPlayerListText="Show Player List"
}
