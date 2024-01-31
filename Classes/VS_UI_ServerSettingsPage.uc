class VS_UI_ServerSettingsPage extends VS_UI_SettingsPage;

var VS_ServerSettings Settings;
var bool bSettingsLoaded;

var UWindowSmallButton Btn_RestartServer;
var localized string Text_RestartServer;

var UWindowSmallButton Btn_ReloadSettings;
var localized string Text_ReloadSettings;

var UWindowLabelControl Lbl_SettingsState;
var localized string Text_SettingsState_New;
var localized string Text_SettingsState_Complete;
var localized string Text_SettingsState_NotAdmin;

var VS_UI_EditControl Edt_MidGameVoteThreshold;
var localized string Text_MidGameVoteThreshold;

var VS_UI_EditControl Edt_MidGameVoteTimeLimit;
var localized string Text_MidGameVoteTimeLimit;

var VS_UI_EditControl Edt_GameEndedVoteDelay;
var localized string Text_GameEndedVoteDelay;

var VS_UI_EditControl Edt_VoteTimeLimit;
var localized string Text_VoteTimeLimit;

var VS_UI_ComboControl Cmb_VoteEndCondition;
var localized string Text_VoteEndCondition;
var localized string Text_VoteEndCondition_TimerOnly;
var localized string Text_VoteEndCondition_TimerOrAllVotesIn;
var localized string Text_VoteEndCondition_TimerOrResultDetermined;

var UWindowCheckbox Chk_RetainCandidates;
var localized string Text_RetainCandidates;

var VS_UI_EditControl Edt_KickVoteThreshold;
var localized string Text_KickVoteThreshold;

var VS_UI_EditControl Edt_DefaultPreset;
var localized string Text_DefaultPreset;

var UWindowCheckbox Chk_AlwaysUseDefaultPreset;
var localized string Text_AlwaysUseDefaultPreset;

var VS_UI_EditControl Edt_DefaultMap;
var localized string Text_DefaultMap;

var UWindowCheckbox Chk_AlwaysUseDefaultMap;
var localized string Text_AlwaysUseDefaultMap;

var VS_UI_EditControl Edt_DefaultTimeMessageClass;
var localized string Text_DefaultTimeMessageClass;

var VS_UI_EditControl Edt_IdleTimeout;
var localized string Text_IdleTimeout;

var VS_UI_EditControl Edt_MinimumMapRepeatDistance;
var localized string Text_MinimumMapRepeatDistance;

var VS_UI_EditControl Edt_PresetProbeDepth;
var localized string Text_PresetProbeDepth;

var UWindowCheckbox Chk_ManageServerPackages;
var localized string Text_ManageServerPackages;

var UWindowCheckbox Chk_UseServerPackagesCompatibilityMode;
var localized string Text_UseServerPackagesCompatibilityMode;

var VS_UI_ArrayEditControl Adt_DefaultPackages;
var localized string Text_DefaultPackages;

var UWindowCheckbox Chk_UseServerActorsCompatibilityMode;
var localized string Text_UseServerActorsCompatibilityMode;

var VS_UI_ArrayEditControl Adt_DefaultActors;
var localized string Text_DefaultActors;

var VS_UI_ComboControl Cmb_GameNameMode;
var localized string Text_GameNameMode;
var localized string Text_GameNameMode_DoNotModify;
var localized string Text_GameNameMode_PresetName;
var localized string Text_GameNameMode_CategoryAndPresetName;

var VS_UI_EditControl Edt_ServerAddress;
var localized string Text_ServerAddress;

var VS_UI_EditControl Edt_DataPort;
var localized string Text_DataPort;

var VS_UI_EditControl Edt_ClientDataPort;
var localized string Text_ClientDataPort;

function LoadSettings(VS_PlayerChannel C) {
	super.LoadSettings(C);

	Settings = C.GetServerSettings();
	LoadServerSettings();
	Log("ServerSettingsPage LoadSettings", 'VoteSys');

	EnableInteraction(bSettingsLoaded);
}

function EnableInteraction(bool bEnable) {
	Edt_MidGameVoteThreshold.EditBox.SetEditable(bEnable);
	Edt_MidGameVoteTimeLimit.EditBox.SetEditable(bEnable);
	Edt_GameEndedVoteDelay.EditBox.SetEditable(bEnable);
	Edt_VoteTimeLimit.EditBox.SetEditable(bEnable);
	Cmb_VoteEndCondition.SetEnabled(bEnable);
	Chk_RetainCandidates.bDisabled = !bEnable;
	Edt_KickVoteThreshold.EditBox.SetEditable(bEnable);
	Edt_DefaultPreset.EditBox.SetEditable(bEnable);
	Chk_AlwaysUseDefaultPreset.bDisabled = !bEnable;
	Edt_DefaultMap.EditBox.SetEditable(bEnable);
	Chk_AlwaysUseDefaultMap.bDisabled = !bEnable;
	Edt_DefaultTimeMessageClass.EditBox.SetEditable(bEnable);
	Edt_IdleTimeout.EditBox.SetEditable(bEnable);
	Edt_MinimumMapRepeatDistance.EditBox.SetEditable(bEnable);
	Edt_PresetProbeDepth.EditBox.SetEditable(bEnable);
	Chk_ManageServerPackages.bDisabled = !bEnable;
	Chk_UseServerPackagesCompatibilityMode.bDisabled = !bEnable;
	Adt_DefaultPackages.SetEnabled(bEnable);
	Chk_UseServerActorsCompatibilityMode.bDisabled = !bEnable;
	Adt_DefaultActors.SetEnabled(bEnable);
	Cmb_GameNameMode.SetEnabled(bEnable);
	Edt_ServerAddress.EditBox.SetEditable(bEnable);
	Edt_DataPort.EditBox.SetEditable(bEnable);
	Edt_ClientDataPort.EditBox.SetEditable(bEnable);
}

function LoadServerSettings() {
	bSettingsLoaded = false;

	if (Settings.SState != S_COMPLETE)
		return;

	Edt_MidGameVoteThreshold.SetValue(string(Settings.MidGameVoteThreshold));
	Edt_MidGameVoteTimeLimit.SetValue(string(Settings.MidGameVoteTimeLimit));
	Edt_GameEndedVoteDelay.SetValue(string(Settings.GameEndedVoteDelay));
	Edt_VoteTimeLimit.SetValue(string(Settings.VoteTimeLimit));
	Cmb_VoteEndCondition.SetSelectedIndex(int(Settings.VoteEndCondition));
	Chk_RetainCandidates.bChecked = Settings.bRetainCandidates;
	Edt_KickVoteThreshold.SetValue(string(Settings.KickVoteThreshold));
	Edt_DefaultPreset.SetValue(Settings.DefaultPreset);
	Chk_AlwaysUseDefaultPreset.bChecked = Settings.bAlwaysUseDefaultPreset;
	Edt_DefaultMap.SetValue(Settings.DefaultMap);
	Chk_AlwaysUseDefaultMap.bChecked = Settings.bAlwaysUseDefaultMap;
	Edt_DefaultTimeMessageClass.SetValue(Settings.DefaultTimeMessageClass);
	Edt_IdleTimeout.SetValue(string(Settings.IdleTimeout));
	Edt_MinimumMapRepeatDistance.SetValue(string(Settings.MinimumMapRepeatDistance));
	Edt_PresetProbeDepth.SetValue(string(Settings.PresetProbeDepth));
	Chk_ManageServerPackages.bChecked = Settings.bManageServerPackages;
	Chk_UseServerPackagesCompatibilityMode.bChecked = Settings.bUseServerPackagesCompatibilityMode;
	Adt_DefaultPackages.SetValue(Settings.GetPropertyText("DefaultPackages"));
	Chk_UseServerActorsCompatibilityMode.bChecked = Settings.bUseServerActorsCompatibilityMode;
	Adt_DefaultActors.SetValue(Settings.GetPropertyText("DefaultActors"));
	Cmb_GameNameMode.SetSelectedIndex(int(Settings.GameNameMode));
	Edt_ServerAddress.SetValue(Settings.ServerAddress);
	Edt_DataPort.SetValue(string(Settings.DataPort));
	Edt_ClientDataPort.SetValue(string(Settings.ClientDataPort));

	bSettingsLoaded = true;
}

function SaveSettings() {
	if (bSettingsLoaded == false)
		return;

	Settings.MidGameVoteThreshold = float(Edt_MidGameVoteThreshold.GetValue());
	Settings.MidGameVoteTimeLimit = int(Edt_MidGameVoteTimeLimit.GetValue());
	Settings.GameEndedVoteDelay = int(Edt_GameEndedVoteDelay.GetValue());
	Settings.VoteTimeLimit = int(Edt_VoteTimeLimit.GetValue());
	Settings.VoteEndCondition = Settings.IntToVoteEndCond(Cmb_VoteEndCondition.GetSelectedIndex());
	Settings.bRetainCandidates = Chk_RetainCandidates.bChecked;
	Settings.KickVoteThreshold = float(Edt_KickVoteThreshold.GetValue());
	Settings.DefaultPreset = Edt_DefaultPreset.GetValue();
	Settings.bAlwaysUseDefaultPreset = Chk_AlwaysUseDefaultPreset.bChecked;
	Settings.DefaultMap = Edt_DefaultMap.GetValue();
	Settings.bAlwaysUseDefaultMap = Chk_AlwaysUseDefaultMap.bChecked;
	Settings.DefaultTimeMessageClass = Edt_DefaultTimeMessageClass.GetValue();
	Settings.IdleTimeout = int(Edt_IdleTimeout.GetValue());
	Settings.MinimumMapRepeatDistance = int(Edt_MinimumMapRepeatDistance.GetValue());
	Settings.PresetProbeDepth = int(Edt_PresetProbeDepth.GetValue());
	Settings.bManageServerPackages = Chk_ManageServerPackages.bChecked;
	Settings.bUseServerPackagesCompatibilityMode = Chk_UseServerPackagesCompatibilityMode.bChecked;
	Settings.SetPropertyText("DefaultPackages", Adt_DefaultPackages.GetValue());
	Settings.bUseServerActorsCompatibilityMode = Chk_UseServerActorsCompatibilityMode.bChecked;
	Settings.SetPropertyText("DefaultActors", Adt_DefaultActors.GetValue());
	Settings.GameNameMode = Settings.IntToGameNameMode(Cmb_GameNameMode.GetSelectedIndex());
	Settings.ServerAddress = Edt_ServerAddress.GetValue();
	Settings.DataPort = int(Edt_DataPort.GetValue());
	Settings.ClientDataPort = int(Edt_ClientDataPort.GetValue());

	Channel.SaveServerSettings();
}

function Created() {
	super.Created();

	Btn_RestartServer = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 4, 334, 80, 16));
	Btn_RestartServer.SetText(Text_RestartServer);

	Btn_ReloadSettings = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 88, 334, 80, 16));
	Btn_ReloadSettings.SetText(Text_ReloadSettings);

	Lbl_SettingsState = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 172, 334, 114, 16));
	Lbl_SettingsState.Align = TA_Right;

	Edt_MidGameVoteThreshold = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 8, 188, 16));
	Edt_MidGameVoteThreshold.SetText(Text_MidGameVoteThreshold);
	Edt_MidGameVoteThreshold.EditBoxWidth = 60;
	Edt_MidGameVoteThreshold.SetNumericOnly(true);
	Edt_MidGameVoteThreshold.SetNumericFloat(true);

	Edt_MidGameVoteTimeLimit = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 28, 188, 16));
	Edt_MidGameVoteTimeLimit.SetText(Text_MidGameVoteTimeLimit);
	Edt_MidGameVoteTimeLimit.EditBoxWidth = 60;
	Edt_MidGameVoteTimeLimit.SetNumericOnly(true);

	Edt_GameEndedVoteDelay = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 48, 188, 16));
	Edt_GameEndedVoteDelay.SetText(Text_GameEndedVoteDelay);
	Edt_GameEndedVoteDelay.EditBoxWidth = 60;
	Edt_GameEndedVoteDelay.SetNumericOnly(true);

	Edt_VoteTimeLimit = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 68, 188, 16));
	Edt_VoteTimeLimit.SetText(Text_VoteTimeLimit);
	Edt_VoteTimeLimit.EditBoxWidth = 60;
	Edt_VoteTimeLimit.SetNumericOnly(true);

	Cmb_VoteEndCondition = VS_UI_ComboControl(CreateControl(class'VS_UI_ComboControl', 4, 88, 188, 16));
	Cmb_VoteEndCondition.SetText(Text_VoteEndCondition);
	Cmb_VoteEndCondition.AddItem(Text_VoteEndCondition_TimerOnly);
	Cmb_VoteEndCondition.AddItem(Text_VoteEndCondition_TimerOrAllVotesIn);
	Cmb_VoteEndCondition.AddItem(Text_VoteEndCondition_TimerOrResultDetermined);
	Cmb_VoteEndCondition.EditBoxWidth = 100;
	Cmb_VoteEndCondition.SetEditable(false);

	Chk_RetainCandidates = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 4, 108, 188, 16));
	Chk_RetainCandidates.SetText(Text_RetainCandidates);

	Edt_KickVoteThreshold = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 128, 188, 16));
	Edt_KickVoteThreshold.SetText(Text_KickVoteThreshold);
	Edt_KickVoteThreshold.EditBoxWidth = 60;
	Edt_KickVoteThreshold.SetNumericOnly(true);
	Edt_KickVoteThreshold.SetNumericFloat(true);

	Edt_DefaultPreset = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 148, 188, 16));
	Edt_DefaultPreset.SetText(Text_DefaultPreset);
	Edt_DefaultPreset.EditBoxWidth = 100;

	Chk_AlwaysUseDefaultPreset = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 4, 168, 188, 16));
	Chk_AlwaysUseDefaultPreset.SetText(Text_AlwaysUseDefaultPreset);

	Edt_DefaultMap = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 188, 188, 16));
	Edt_DefaultMap.SetText(Text_DefaultMap);
	Edt_DefaultMap.EditBoxWidth = 100;

	Chk_AlwaysUseDefaultMap = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 4, 208, 188, 16));
	Chk_AlwaysUseDefaultMap.SetText(Text_AlwaysUseDefaultMap);

	Edt_DefaultTimeMessageClass = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 228, 188, 16));
	Edt_DefaultTimeMessageClass.SetText(Text_DefaultTimeMessageClass);
	Edt_DefaultTimeMessageClass.EditBoxWidth = 100;

	Edt_IdleTimeout = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 248, 188, 16));
	Edt_IdleTimeout.SetText(Text_IdleTimeout);
	Edt_IdleTimeout.EditBoxWidth = 60;
	Edt_IdleTimeout.SetNumericOnly(true);

	Edt_MinimumMapRepeatDistance = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 268, 188, 16));
	Edt_MinimumMapRepeatDistance.SetText(Text_MinimumMapRepeatDistance);
	Edt_MinimumMapRepeatDistance.EditBoxWidth = 60;
	Edt_MinimumMapRepeatDistance.SetNumericOnly(true);

	Edt_PresetProbeDepth = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 288, 188, 16));
	Edt_PresetProbeDepth.SetText(Text_PresetProbeDepth);
	Edt_PresetProbeDepth.EditBoxWidth = 60;
	Edt_PresetProbeDepth.SetNumericOnly(true);

	//
	// Right Side
	//

	Chk_ManageServerPackages = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 200, 8, 188, 16));
	Chk_ManageServerPackages.SetText(Text_ManageServerPackages);

	Chk_UseServerPackagesCompatibilityMode = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 200, 28, 188, 16));
	Chk_UseServerPackagesCompatibilityMode.SetText(Text_UseServerPackagesCompatibilityMode);

	Adt_DefaultPackages = VS_UI_ArrayEditControl(CreateControl(class'VS_UI_ArrayEditControl', 200, 48, 188, 16));
	Adt_DefaultPackages.SetText(Text_DefaultPackages);
	Adt_DefaultPackages.EditBoxWidth = 100;

	Chk_UseServerActorsCompatibilityMode = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 200, 68, 188, 16));
	Chk_UseServerActorsCompatibilityMode.SetText(Text_UseServerActorsCompatibilityMode);

	Adt_DefaultActors = VS_UI_ArrayEditControl(CreateControl(class'VS_UI_ArrayEditControl', 200, 88, 188, 16));
	Adt_DefaultActors.SetText(Text_DefaultActors);
	Adt_DefaultActors.EditBoxWidth = 100;

	Cmb_GameNameMode = VS_UI_ComboControl(CreateControl(class'VS_UI_ComboControl', 200, 108, 188, 16));
	Cmb_GameNameMode.SetText(Text_GameNameMode);
	Cmb_GameNameMode.AddItem(Text_GameNameMode_DoNotModify);
	Cmb_GameNameMode.AddItem(Text_GameNameMode_PresetName);
	Cmb_GameNameMode.AddItem(Text_GameNameMode_CategoryAndPresetName);
	Cmb_GameNameMode.EditBoxWidth = 100;
	Cmb_GameNameMode.SetEditable(false);

	Edt_ServerAddress = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 200, 128, 188, 16));
	Edt_ServerAddress.SetText(Text_ServerAddress);
	Edt_ServerAddress.EditBoxWidth = 100;

	Edt_DataPort = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 200, 148, 188, 16));
	Edt_DataPort.SetText(Text_DataPort);
	Edt_DataPort.EditBoxWidth = 60;
	Edt_DataPort.SetNumericOnly(true);

	Edt_ClientDataPort = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 200, 168, 188, 16));
	Edt_ClientDataPort.SetText(Text_ClientDataPort);
	Edt_ClientDataPort.EditBoxWidth = 60;
	Edt_ClientDataPort.SetNumericOnly(true);
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

	if (bSettingsLoaded == false) {
		LoadServerSettings();
		if (bSettingsLoaded)
			EnableInteraction(bSettingsLoaded);
	}
}

function ApplyTheme() {
	Edt_MidGameVoteThreshold.Theme = Theme;
	Edt_MidGameVoteTimeLimit.Theme = Theme;
	Edt_GameEndedVoteDelay.Theme = Theme;
	Edt_VoteTimeLimit.Theme = Theme;
	Cmb_VoteEndCondition.Theme = Theme;
	//Chk_RetainCandidates // not themed
	Edt_KickVoteThreshold.Theme = Theme;
	Edt_DefaultPreset.Theme = Theme;
	//Chk_AlwaysUseDefaultPreset // not themed
	Edt_DefaultMap.Theme = Theme;
	//Chk_AlwaysUseDefaultMap // not themed
	Edt_DefaultTimeMessageClass.Theme = Theme;
	Edt_IdleTimeout.Theme = Theme;
	Edt_MinimumMapRepeatDistance.Theme = Theme;
	Edt_PresetProbeDepth.Theme = Theme;
	//Chk_ManageServerPackages // not themed
	//Chk_UseServerPackagesCompatibilityMode // not themed
	Adt_DefaultPackages.SetTheme(Theme);
	//Chk_UseServerActorsCompatibilityMode // not themed
	Adt_DefaultActors.SetTheme(Theme);
	Cmb_GameNameMode.Theme = Theme;
	Edt_ServerAddress.Theme = Theme;
	Edt_DataPort.Theme = Theme;
	Edt_ClientDataPort.Theme = Theme;
}

function Notify(UWindowDialogControl C, byte E) {
	super.Notify(C, E);

	if (E == DE_Click) {
		if (C == Btn_RestartServer) {
			GetPlayerOwner().ConsoleCommand("admin exit");
		} else if (C == Btn_ReloadSettings) {
			bSettingsLoaded = false;
			Settings = Channel.ReloadServerSettings();
			EnableInteraction(false);
		}
	}
}

defaultproperties {
	Text_RestartServer="Restart Server"
	Text_ReloadSettings="Reload Settings"
	Text_SettingsState_New="Loading"
	Text_SettingsState_Complete="Loaded"
	Text_SettingsState_NotAdmin="Unauthorized"

	Text_MidGameVoteThreshold="Mid-Game Vote Threshold"
	Text_MidGameVoteTimeLimit="Mid-Game Vote Time Limit"
	Text_GameEndedVoteDelay="Game Ended Vote Delay"
	Text_VoteTimeLimit="Vote Time Limit"
	Text_VoteEndCondition="Vote End Rules"
	Text_VoteEndCondition_TimerOnly="Timer Only"
	Text_VoteEndCondition_TimerOrAllVotesIn="Everyone Voted"
	Text_VoteEndCondition_TimerOrResultDetermined="Result Certain"
	Text_RetainCandidates="Retain Candidates"
	Text_KickVoteThreshold="Kick Vote Threshold"
	Text_DefaultPreset="Default Preset"
	Text_AlwaysUseDefaultPreset="Always Use Default Preset"
	Text_DefaultMap="Default Map"
	Text_AlwaysUseDefaultMap="Always Use Default Map"
	Text_DefaultTimeMessageClass="Time Msg Class"
	Text_IdleTimeout="Idle Timeout"
	Text_MinimumMapRepeatDistance="Map Repeat Distance"
	Text_PresetProbeDepth="Preset Probe Depth"
	Text_ManageServerPackages="Manage Server Packages"
	Text_UseServerPackagesCompatibilityMode="Use Server Package Compat. Mode"
	Text_DefaultPackages="Default Packages"
	Text_UseServerActorsCompatibilityMode="Use Server Actors Compat. Mode"
	Text_DefaultActors="Default Actors"
	Text_GameNameMode="GameName Mode"
	Text_GameNameMode_DoNotModify="Do Not Modify"
	Text_GameNameMode_PresetName="Preset Name"
	Text_GameNameMode_CategoryAndPresetName="Full Preset Name"
	Text_ServerAddress="Server Address"
	Text_DataPort="Data Port"
	Text_ClientDataPort="Client Data Port"
}
