class VS_UIS_PageAdminUI extends VS_UIS_PageAdmin;

var UWindowCheckbox Chk_RetainCandidates;
var localized string Text_RetainCandidates;

var VS_UI_EditControl Edt_DefaultTimeMessageClass;
var localized string Text_DefaultTimeMessageClass;

function EnableInteraction(bool bEnable) {
	Chk_RetainCandidates.bDisabled = !bEnable;
	Edt_DefaultTimeMessageClass.EditBox.SetEditable(bEnable);
}

function LoadServerSettings() {
	Chk_RetainCandidates.bChecked = Settings.bRetainCandidates;
	Edt_DefaultTimeMessageClass.SetValue(Settings.DefaultTimeMessageClass);
}

function SaveSettings() {
	Settings.bRetainCandidates = Chk_RetainCandidates.bChecked;
	Settings.DefaultTimeMessageClass = Edt_DefaultTimeMessageClass.GetValue();

	super.SaveSettings();
}

function Created() {
	super.Created();

	Chk_RetainCandidates = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 4, 108, 188, 16));
	Chk_RetainCandidates.SetText(Text_RetainCandidates);

	Edt_DefaultTimeMessageClass = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 228, 188, 16));
	Edt_DefaultTimeMessageClass.SetText(Text_DefaultTimeMessageClass);
	Edt_DefaultTimeMessageClass.EditBoxWidth = 100;
}

function ApplyTheme() {
	//Chk_RetainCandidates // not themed
	Edt_DefaultTimeMessageClass.Theme = Theme;
}

defaultproperties {
	Text_RetainCandidates="Retain Candidates"
	Text_DefaultTimeMessageClass="Time Msg Class"
}
