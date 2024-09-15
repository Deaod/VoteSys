class VS_UIS_PageAdminVoting extends VS_UIS_PageAdmin;

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

var UWindowCheckbox Chk_EnableKickVoting;
var localized string Text_EnableKickVoting;

var VS_UI_EditControl Edt_KickVoteThreshold;
var localized string Text_KickVoteThreshold;

var VS_UI_EditControl Edt_MinimumMapRepeatDistance;
var localized string Text_MinimumMapRepeatDistance;

function EnableInteraction(bool bEnable) {
	Edt_MidGameVoteThreshold.EditBox.SetEditable(bEnable);
	Edt_MidGameVoteTimeLimit.EditBox.SetEditable(bEnable);
	Edt_GameEndedVoteDelay.EditBox.SetEditable(bEnable);
	Edt_VoteTimeLimit.EditBox.SetEditable(bEnable);
	Cmb_VoteEndCondition.SetEnabled(bEnable);
	Chk_EnableKickVoting.bDisabled = !bEnable;
	Edt_KickVoteThreshold.EditBox.SetEditable(bEnable);
	Edt_MinimumMapRepeatDistance.EditBox.SetEditable(bEnable);
}

function LoadServerSettings() {
	Edt_MidGameVoteThreshold.SetValue(string(Settings.MidGameVoteThreshold));
	Edt_MidGameVoteTimeLimit.SetValue(string(Settings.MidGameVoteTimeLimit));
	Edt_GameEndedVoteDelay.SetValue(string(Settings.GameEndedVoteDelay));
	Edt_VoteTimeLimit.SetValue(string(Settings.VoteTimeLimit));
	Cmb_VoteEndCondition.SetSelectedIndex(int(Settings.VoteEndCondition));
	Chk_EnableKickVoting.bChecked = Settings.bEnableKickVoting;
	Edt_KickVoteThreshold.SetValue(string(Settings.KickVoteThreshold));
	Edt_MinimumMapRepeatDistance.SetValue(string(Settings.MinimumMapRepeatDistance));
}

function SaveSettings() {
	Settings.MidGameVoteThreshold = float(Edt_MidGameVoteThreshold.GetValue());
	Settings.MidGameVoteTimeLimit = int(Edt_MidGameVoteTimeLimit.GetValue());
	Settings.GameEndedVoteDelay = int(Edt_GameEndedVoteDelay.GetValue());
	Settings.VoteTimeLimit = int(Edt_VoteTimeLimit.GetValue());
	Settings.VoteEndCondition = Settings.IntToVoteEndCond(Cmb_VoteEndCondition.GetSelectedIndex());
	Settings.bEnableKickVoting = Chk_EnableKickVoting.bChecked;
	Settings.KickVoteThreshold = float(Edt_KickVoteThreshold.GetValue());
	Settings.MinimumMapRepeatDistance = int(Edt_MinimumMapRepeatDistance.GetValue());

	super.SaveSettings();
}

function Created() {
	super.Created();

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

	Chk_EnableKickVoting = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 4, 108, 188, 16));
	Chk_EnableKickVoting.SetText(Text_EnableKickVoting);

	Edt_KickVoteThreshold = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 128, 188, 16));
	Edt_KickVoteThreshold.SetText(Text_KickVoteThreshold);
	Edt_KickVoteThreshold.EditBoxWidth = 60;
	Edt_KickVoteThreshold.SetNumericOnly(true);
	Edt_KickVoteThreshold.SetNumericFloat(true);

	Edt_MinimumMapRepeatDistance = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 148, 188, 16));
	Edt_MinimumMapRepeatDistance.SetText(Text_MinimumMapRepeatDistance);
	Edt_MinimumMapRepeatDistance.EditBoxWidth = 60;
	Edt_MinimumMapRepeatDistance.SetNumericOnly(true);
}

function ApplyTheme() {
	Edt_MidGameVoteThreshold.Theme = Theme;
	Edt_MidGameVoteTimeLimit.Theme = Theme;
	Edt_GameEndedVoteDelay.Theme = Theme;
	Edt_VoteTimeLimit.Theme = Theme;
	Cmb_VoteEndCondition.Theme = Theme;
	//Chk_EnableKickVoting.Theme = Theme; // not themed
	Edt_KickVoteThreshold.Theme = Theme;
	Edt_MinimumMapRepeatDistance.Theme = Theme;
}

defaultproperties {
	Text_MidGameVoteThreshold="Mid-Game Vote Threshold"
	Text_MidGameVoteTimeLimit="Mid-Game Vote Time Limit"
	Text_GameEndedVoteDelay="Game Ended Vote Delay"
	Text_VoteTimeLimit="Vote Time Limit"
	Text_VoteEndCondition="Vote End Rules"
	Text_VoteEndCondition_TimerOnly="Timer Only"
	Text_VoteEndCondition_TimerOrAllVotesIn="Everyone Voted"
	Text_VoteEndCondition_TimerOrResultDetermined="Result Certain"
	Text_EnableKickVoting="Enable Kick Voting"
	Text_KickVoteThreshold="Kick Vote Threshold"
	Text_MinimumMapRepeatDistance="Map Repeat Distance"
}
