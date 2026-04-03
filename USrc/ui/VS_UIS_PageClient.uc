class VS_UIS_PageClient extends VS_UIS_Page
	imports(VS_Util_Logging);

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
var localized string MapListSortRating;

var VS_UI_Checkbox Chk_FavoritesFirst;
var localized string FavoritesFirstText;

var VS_UI_Checkbox Chk_ShowPlayerList;
var localized string ShowPlayerListText;

var localized string HotkeyResetInstructions;

var UWindowLabelControl Lbl_HotkeyVoteMenu;
var localized string HotkeyVoteMenuText;
var UMenuRaisedButton Btn_HotkeyVoteMenuSet;

var UWindowLabelControl Lbl_HotkeySettings;
var localized string HotkeySettingsText;
var UMenuRaisedButton Btn_HotkeySettingsSet;

var string RealKeyName[256];
var int HotkeyVoteMenuIndex;
var int HotkeyVoteMenuIndexOld;
var int HotkeySettingsIndex;
var int HotkeySettingsIndexOld;
var UMenuRaisedButton HotkeyCaptureButton;

var VS_Msg_ParameterContainer OverwriteMessageFormatter;
var UWindowMessageBox OverwriteMessageBox;
var localized string OverwriteTitle;
var localized string OverwriteMessage;
var int OverwritePendingKey;

var string CommandVoteMenu;
var string CommandSettings;

function Created() {
	SetAcceptsFocus();

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
	Cmb_MapListSort.AddItem(MapListSortRating);
	Cmb_MapListSort.SetEditable(false);

	Chk_FavoritesFirst = VS_UI_Checkbox(CreateControl(class'VS_UI_Checkbox', 8, 48, 188, 16));
	Chk_FavoritesFirst.SetText(FavoritesFirstText);

	Chk_ShowPlayerList = VS_UI_Checkbox(CreateControl(class'VS_UI_Checkbox', 8, 68, 188, 16));
	Chk_ShowPlayerList.SetText(ShowPlayerListText);

	Lbl_HotkeyVoteMenu = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 8, 90, 128, 16));
	Lbl_HotkeyVoteMenu.SetText(HotkeyVoteMenuText);

	Btn_HotkeyVoteMenuSet = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 136, 88, 60, 16));
	Btn_HotkeyVoteMenuSet.SetHelpText(HotkeyResetInstructions);
	Btn_HotkeyVoteMenuSet.CancelAcceptsFocus();
	Btn_HotkeyVoteMenuSet.bIgnoreLDoubleClick = True;
	Btn_HotkeyVoteMenuSet.bIgnoreMDoubleClick = True;
	Btn_HotkeyVoteMenuSet.bIgnoreRDoubleClick = True;

	Lbl_HotkeySettings = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 8, 110, 128, 16));
	Lbl_HotkeySettings.SetText(HotkeySettingsText);

	Btn_HotkeySettingsSet = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 136, 108, 60, 16));
	Btn_HotkeySettingsSet.SetHelpText(HotkeyResetInstructions);
	Btn_HotkeySettingsSet.CancelAcceptsFocus();
	Btn_HotkeySettingsSet.bIgnoreLDoubleClick = True;
	Btn_HotkeySettingsSet.bIgnoreMDoubleClick = True;
	Btn_HotkeySettingsSet.bIgnoreRDoubleClick = True;

	OverwriteMessageFormatter = new(none) class'VS_Msg_ParameterContainer';
	OverwriteMessageBox = UWindowMessageBox(Root.CreateWindow(class'UWindowMessageBox', 100, 100, 100, 100, self));
	OverwriteMessageBox.HideWindow();

	super.Created();
}

function CheckHotkeys() {
	local PlayerPawn P;
	local int i;
	local string Cmd;

	P = GetPlayerOwner();
	for (i = 0; i < arraycount(RealKeyName); i++) {
		RealKeyName[i] = P.ConsoleCommand("KEYNAME"@i);
		Cmd = P.ConsoleCommand("KEYBINDING"@RealKeyName[i]);
		if (Cmd ~= CommandVoteMenu)
			HotkeyVoteMenuIndex = i;
		if (Cmd ~= CommandSettings)
			HotkeySettingsIndex = i;
	}
	HotkeyVoteMenuIndexOld = HotkeyVoteMenuIndex;
	HotkeySettingsIndexOld = HotkeySettingsIndex;
}

function LoadSettings(VS_PlayerChannel C) {
	super.LoadSettings(C);

	Settings = C.Settings;

	Cmb_Theme.SetSelectedIndex(Settings.Theme);
	Cmb_MapListSort.SetSelectedIndex(Settings.MapListSort);
	Chk_FavoritesFirst.bChecked = Settings.bFavoritesFirst;
	Chk_ShowPlayerList.bChecked = Settings.bShowPlayerList;

	CheckHotkeys();

	ResetHotkeyButtonText();
}

function SaveSettings() {
	Settings.Theme = Settings.IntToTheme(Cmb_Theme.GetSelectedIndex());
	Settings.MapListSort = Settings.IntToMapListSort(Cmb_MapListSort.GetSelectedIndex());
	Settings.bFavoritesFirst = Chk_FavoritesFirst.bChecked;
	Settings.bShowPlayerList = Chk_ShowPlayerList.bChecked;

	Settings.SaveConfig();

	if (HotkeyVoteMenuIndex != HotkeyVoteMenuIndexOld)
		GetPlayerOwner().ConsoleCommand("SET INPUT"@RealKeyName[HotkeyVoteMenuIndexOld]);
	if (HotkeySettingsIndex != HotkeySettingsIndexOld)
		GetPlayerOwner().ConsoleCommand("SET INPUT"@RealKeyName[HotkeySettingsIndexOld]);

	HotkeyVoteMenuIndexOld = HotkeyVoteMenuIndex;
	HotkeySettingsIndexOld = HotkeySettingsIndex;

	if (HotkeyVoteMenuIndex != 0)
		GetPlayerOwner().ConsoleCommand("SET INPUT"@RealKeyName[HotkeyVoteMenuIndex]@CommandVoteMenu);
	if (HotkeySettingsIndex != 0)
		GetPlayerOwner().ConsoleCommand("SET INPUT"@RealKeyName[HotkeySettingsIndex]@CommandSettings);
}

function ApplyTheme() {
	Cmb_Theme.Theme = Theme;
	Cmb_MapListSort.Theme = Theme;
}

function ResetHotkeyButtonText() {
	Btn_HotkeyVoteMenuSet.SetText(class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[HotkeyVoteMenuIndex]);
	Btn_HotkeySettingsSet.SetText(class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[HotkeySettingsIndex]);
}

function HotkeyAssignStart(UMenuRaisedButton Btn) {
	HotkeyCaptureButton = Btn;
	Cmb_Theme.CancelAcceptsFocus();
	Cmb_MapListSort.CancelAcceptsFocus();
	Chk_FavoritesFirst.CancelAcceptsFocus();
	Chk_ShowPlayerList.CancelAcceptsFocus();
}

function HotkeyAssignKey(int Key) {
	if (HotkeyCaptureButton == Btn_HotkeyVoteMenuSet) {
		HotkeyVoteMenuIndex = Key;
	} else if (HotkeyCaptureButton == Btn_HotkeySettingsSet) {
		HotkeySettingsIndex = Key;
	}
}

function HotkeyAssignDone() {
	ResetHotkeyButtonText();
	HotkeyCaptureButton = none;
	Cmb_Theme.SetAcceptsFocus();
	Cmb_MapListSort.SetAcceptsFocus();
	Chk_FavoritesFirst.SetAcceptsFocus();
	Chk_ShowPlayerList.SetAcceptsFocus();
}

function bool CheckExistingBind(int Key) {
	local PlayerPawn P;
	local string Cmd;
	local int i;
	local UWindowFramedWindow F;

	P = GetPlayerOwner();

	Cmd = P.ConsoleCommand("KEYBINDING"@RealKeyName[Key]);
	if (Cmd == "")
		return true;

	if (Cmd ~= "none") // Marker for Console/Speech Key
		return false; // Im not going to mess with those

	for (i = 0; i < arraycount(class'UTCustomizeClientWindow'.default.AliasNames); i++)
		if (Cmd ~= class'UTCustomizeClientWindow'.default.AliasNames[i])
			Cmd = class'UTCustomizeClientWindow'.default.LabelList[i];

	OverwriteMessageFormatter.Params[1] = class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[Key];
	OverwriteMessageFormatter.Params[2] = Cmd;

	OverwriteMessageBox.bSetupSize = false;
	OverwriteMessageBox.SetupMessageBox(
		OverwriteTitle,
		OverwriteMessageFormatter.ApplyParameters(OverwriteMessage),
		MB_YesNo,
		MR_No, // Esc Result
		MR_Yes, // Enter Result
		0
	);
	OverwriteMessageBox.bLeaveOnScreen = true;

	F = UWindowFramedWindow(GetParent(class'UWindowFramedWindow'));
	F.ShowModal(OverwriteMessageBox);

	OverwritePendingKey = Key;

	return false;
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result) {
	if (W != OverwriteMessageBox) {
		super.MessageBoxDone(W, Result);
		return;
	}

	if (Result == MR_Yes)
		HotkeyAssignKey(OverwritePendingKey);
	HotkeyAssignDone();
}

function KeyDown(int Key, float X, float Y) {
	local PlayerPawn P;

	LogMsg("KeyDown"@Key@X@Y);

	P = GetPlayerOwner();
	if (HotkeyCaptureButton == none) {
		super.KeyDown(Key, X, Y);
		return;
	}

	HotkeyCaptureButton.SetText(HotkeyCaptureButton.Text$Chr(Key));

	if (Key == P.EInputKey.IK_Escape) {
		HotkeyAssignDone();
		return;
	}

	if (CheckExistingBind(Key) == false)
		return;

	HotkeyAssignKey(Key);
	HotkeyAssignDone();
}

function Notify(UWindowDialogControl C, byte E) {
	switch(E) {
		case DE_Click:
			if (C != none && C == HotkeyCaptureButton) {
				HotkeyAssignDone();
				break;
			}

			if (C == Btn_HotkeyVoteMenuSet || C == Btn_HotkeySettingsSet) {
				C.SetText("???");
				HotkeyAssignStart(UMenuRaisedButton(C));
			} else {
				super.Notify(C, E);
			}
			break;

		case DE_RClick:
			if (C == Btn_HotkeyVoteMenuSet || C == Btn_HotkeySettingsSet) {
				HotkeyAssignStart(UMenuRaisedButton(C));
				HotkeyAssignKey(0);
				HotkeyAssignDone();
			} else {
				super.Notify(C, E);
			}
			break;

		default:
			super.Notify(C, E);
			break;
	}
}

function Close(optional bool bByParent) {
	HotkeyAssignDone();
	super.Close(bByParent);
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
	MapListSortRating="Rating"

	FavoritesFirstText="Sort Favorites First"
	ShowPlayerListText="Show Player List"
	HotkeyResetInstructions="Left-Click to Bind, Right-Click to Unbind Hotkey"
	HotkeyVoteMenuText="Hotkey Vote Menu"
	HotkeySettingsText="Hotkey Settings"

	OverwriteTitle="Overwrite Bind?"
	OverwriteMessage="The key '{1}' is already bound to:\\n>> {2}\\nDo you want to overwrite it?"

	CommandVoteMenu="mutate bdbmapvote votemenu"
	CommandSettings="mutate votesys settings"
}
