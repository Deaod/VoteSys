class VS_UIS_PageAdmin extends VS_UIS_Page;

var VS_ServerSettings Settings;
var VS_ClientPresetList Presets;
var bool bSettingsLoaded;

var UWindowSmallButton Btn_RestartServer;
var localized string Text_RestartServer;

var UWindowSmallButton Btn_ReloadSettings;
var localized string Text_ReloadSettings;

var UWindowLabelControl Lbl_SettingsState;
var localized string Text_SettingsState_New;
var localized string Text_SettingsState_Complete;
var localized string Text_SettingsState_NotAdmin;

function Created() {
	super.Created();

	Btn_RestartServer = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 4, 334, 80, 16));
	Btn_RestartServer.SetText(Text_RestartServer);

	Btn_ReloadSettings = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 88, 334, 80, 16));
	Btn_ReloadSettings.SetText(Text_ReloadSettings);

	Lbl_SettingsState = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 172, 334, 114, 16));
	Lbl_SettingsState.Align = TA_Right;
}

function LoadServerSettings() {}
function EnableInteraction(bool bEnable) {}

function LoadSettings(VS_PlayerChannel C) {
	super.LoadSettings(C);

	Settings = C.GetServerSettings();
	Presets = C.GetServerPresets();
	LoadServerSettings();

	EnableInteraction(bSettingsLoaded);
}

function SaveSettings() {
	Channel.SaveServerSettings();
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	super.BeforePaint(C, MouseX, MouseY);

	switch(Settings.SState) {
		case S_NEW:
			Lbl_SettingsState.SetText(Text_SettingsState_New);
			break;
		case S_COMPLETE:
			Lbl_SettingsState.SetText(Text_SettingsState_Complete);
			break;
		case S_NOTADMIN:
			Lbl_SettingsState.SetText(Text_SettingsState_NotAdmin);
			break;
	}

	if (bSettingsLoaded == false && Settings.SState == S_COMPLETE && Presets.TransmissionState == TS_Complete) {
		LoadServerSettings();
		EnableInteraction(true);
		bSettingsLoaded = true;
	}
}

function Notify(UWindowDialogControl C, byte E) {
	super.Notify(C, E);

	if (E == DE_Click) {
		if (C == Btn_RestartServer) {
			GetPlayerOwner().ConsoleCommand("admin exit");
		} else if (C == Btn_ReloadSettings) {
			bSettingsLoaded = false;
			Settings = Channel.ReloadServerSettings();
			Presets = Channel.ReloadServerPresets();
			EnableInteraction(false);
		}
	}
}

function bool CanSaveSettings() {
	return bSettingsLoaded;
}

defaultproperties {
	Text_RestartServer="Restart Server"
	Text_ReloadSettings="Reload Settings"
	Text_SettingsState_New="Loading"
	Text_SettingsState_Complete="Loaded"
	Text_SettingsState_NotAdmin="Unauthorized"
}
