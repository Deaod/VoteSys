class VS_UI_ServerSettingsPage extends VS_UI_SettingsPage;

var VS_ServerSettings Settings;
var bool bSettingsLoaded;

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

function LoadSettings(VS_PlayerChannel C) {
	super.LoadSettings(C);

	Settings = C.GetServerSettings();
	LoadServerSettings();
	Log("ServerSettingsPage LoadSettings", 'VoteSys');

	Edt_MidGameVoteThreshold.EditBox.SetEditable(bSettingsLoaded);
	Edt_MidGameVoteTimeLimit.EditBox.SetEditable(bSettingsLoaded);
	Edt_GameEndedVoteDelay.EditBox.SetEditable(bSettingsLoaded);
	Edt_VoteTimeLimit.EditBox.SetEditable(bSettingsLoaded);
}

function LoadServerSettings() {
	bSettingsLoaded = false;

	if (Settings.SState != S_COMPLETE)
		return;

	Edt_MidGameVoteThreshold.SetValue(string(Settings.MidGameVoteThreshold));
	Edt_MidGameVoteTimeLimit.SetValue(string(Settings.MidGameVoteTimeLimit));
	Edt_GameEndedVoteDelay.SetValue(string(Settings.GameEndedVoteDelay));
	Edt_VoteTimeLimit.SetValue(string(Settings.VoteTimeLimit));

	bSettingsLoaded = true;
}

function SaveSettings() {
	Settings.MidGameVoteThreshold = float(Edt_MidGameVoteThreshold.GetValue());
	Settings.MidGameVoteTimeLimit = int(Edt_MidGameVoteTimeLimit.GetValue());
	Settings.GameEndedVoteDelay = int(Edt_GameEndedVoteDelay.GetValue());
	Settings.VoteTimeLimit = int(Edt_VoteTimeLimit.GetValue());

	Channel.SaveServerSettings();
}

function Created() {
	super.Created();

	Lbl_SettingsState = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 8, 334, 282, 16));
	Lbl_SettingsState.Align = TA_Right;

	Edt_MidGameVoteThreshold = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 8, 8, 188, 16));
	Edt_MidGameVoteThreshold.SetText(Text_MidGameVoteThreshold);
	Edt_MidGameVoteThreshold.EditBoxWidth = 60;
	Edt_MidGameVoteThreshold.SetNumericOnly(true);
	Edt_MidGameVoteThreshold.SetNumericFloat(true);

	Edt_MidGameVoteTimeLimit = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 8, 28, 188, 16));
	Edt_MidGameVoteTimeLimit.SetText(Text_MidGameVoteTimeLimit);
	Edt_MidGameVoteTimeLimit.EditBoxWidth = 60;
	Edt_MidGameVoteTimeLimit.SetNumericOnly(true);

	Edt_GameEndedVoteDelay = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 8, 48, 188, 16));
	Edt_GameEndedVoteDelay.SetText(Text_GameEndedVoteDelay);
	Edt_GameEndedVoteDelay.EditBoxWidth = 60;
	Edt_GameEndedVoteDelay.SetNumericOnly(true);

	Edt_VoteTimeLimit = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 8, 68, 188, 16));
	Edt_VoteTimeLimit.SetText(Text_VoteTimeLimit);
	Edt_VoteTimeLimit.EditBoxWidth = 60;
	Edt_VoteTimeLimit.SetNumericOnly(true);
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
		if (bSettingsLoaded) {
			Edt_MidGameVoteThreshold.EditBox.SetEditable(bSettingsLoaded);
			Edt_MidGameVoteTimeLimit.EditBox.SetEditable(bSettingsLoaded);
			Edt_GameEndedVoteDelay.EditBox.SetEditable(bSettingsLoaded);
			Edt_VoteTimeLimit.EditBox.SetEditable(bSettingsLoaded);
		}
	}
}

function ApplyTheme() {
	Edt_MidGameVoteThreshold.Theme = Theme;
	Edt_MidGameVoteTimeLimit.Theme = Theme;
	Edt_GameEndedVoteDelay.Theme = Theme;
	Edt_VoteTimeLimit.Theme = Theme;
}

defaultproperties {
	Text_SettingsState_New="Loading"
	Text_SettingsState_Complete="Loaded"
	Text_SettingsState_NotAdmin="Unauthorized"

	Text_MidGameVoteThreshold="Mid-Game Vote Threshold"
	Text_MidGameVoteTimeLimit="Mid-Game Vote Time Limit"
	Text_GameEndedVoteDelay="Game Ended Vote Delay"
	Text_VoteTimeLimit="Vote Time Limit"
}
