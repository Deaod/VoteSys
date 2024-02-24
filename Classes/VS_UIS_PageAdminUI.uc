class VS_UIS_PageAdminUI extends VS_UIS_PageAdmin;

var UWindowCheckbox Chk_RetainCandidates;
var localized string Text_RetainCandidates;

var VS_UI_EditControl Edt_DefaultTimeMessageClass;
var localized string Text_DefaultTimeMessageClass;

var VS_UI_EditControl Edt_LogoTexture;
var localized string Text_LogoTexture;

var UWindowLabelControl Lbl_LogoRegion;
var localized string Text_LogoRegion;

var VS_UI_EditControl Edt_LogoRegionX;
var localized string Text_LogoRegionX;

var VS_UI_EditControl Edt_LogoRegionY;
var localized string Text_LogoRegionY;

var VS_UI_EditControl Edt_LogoRegionW;
var localized string Text_LogoRegionW;

var VS_UI_EditControl Edt_LogoRegionH;
var localized string Text_LogoRegionH;

function EnableInteraction(bool bEnable) {
	Chk_RetainCandidates.bDisabled = !bEnable;
	Edt_DefaultTimeMessageClass.EditBox.SetEditable(bEnable);
	Edt_LogoTexture.EditBox.SetEditable(bEnable);
	Edt_LogoRegionX.EditBox.SetEditable(bEnable);
	Edt_LogoRegionY.EditBox.SetEditable(bEnable);
	Edt_LogoRegionW.EditBox.SetEditable(bEnable);
	Edt_LogoRegionH.EditBox.SetEditable(bEnable);
}

function LoadServerSettings() {
	Chk_RetainCandidates.bChecked = Settings.bRetainCandidates;
	Edt_DefaultTimeMessageClass.SetValue(Settings.DefaultTimeMessageClass);
	Edt_LogoTexture.SetValue(Settings.LogoTexture);
	Edt_LogoRegionX.SetValue(string(Settings.LogoRegion.X));
	Edt_LogoRegionY.SetValue(string(Settings.LogoRegion.Y));
	Edt_LogoRegionW.SetValue(string(Settings.LogoRegion.W));
	Edt_LogoRegionH.SetValue(string(Settings.LogoRegion.H));
}

function SaveSettings() {
	Settings.bRetainCandidates = Chk_RetainCandidates.bChecked;
	Settings.DefaultTimeMessageClass = Edt_DefaultTimeMessageClass.GetValue();
	Settings.LogoTexture = Edt_LogoTexture.GetValue();
	Settings.LogoRegion.X = int(Edt_LogoRegionX.GetValue());
	Settings.LogoRegion.Y = int(Edt_LogoRegionY.GetValue());
	Settings.LogoRegion.W = int(Edt_LogoRegionW.GetValue());
	Settings.LogoRegion.H = int(Edt_LogoRegionH.GetValue());

	super.SaveSettings();
}

function Created() {
	super.Created();

	Chk_RetainCandidates = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 4, 8, 188, 16));
	Chk_RetainCandidates.SetText(Text_RetainCandidates);

	Edt_DefaultTimeMessageClass = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 28, 188, 16));
	Edt_DefaultTimeMessageClass.SetText(Text_DefaultTimeMessageClass);
	Edt_DefaultTimeMessageClass.EditBoxWidth = 100;

	Edt_LogoTexture = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 48, 188, 16));
	Edt_LogoTexture.SetText(Text_LogoTexture);
	Edt_LogoTexture.EditBoxWidth = 100;

	Lbl_LogoRegion = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 4, 80, 84, 16));
	Lbl_LogoRegion.SetText(Text_LogoRegion);

	Edt_LogoRegionX = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 92, 68, 40, 16));
	Edt_LogoRegionX.SetText(Text_LogoRegionX);
	Edt_LogoRegionX.SetNumericOnly(true);
	Edt_LogoRegionX.EditBoxWidth = 30;

	Edt_LogoRegionY = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 152, 68, 40, 16));
	Edt_LogoRegionY.SetText(Text_LogoRegionY);
	Edt_LogoRegionY.SetNumericOnly(true);
	Edt_LogoRegionY.EditBoxWidth = 30;

	Edt_LogoRegionW = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 92, 88, 40, 16));
	Edt_LogoRegionW.SetText(Text_LogoRegionW);
	Edt_LogoRegionW.SetNumericOnly(true);
	Edt_LogoRegionW.EditBoxWidth = 30;

	Edt_LogoRegionH = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 152, 88, 40, 16));
	Edt_LogoRegionH.SetText(Text_LogoRegionH);
	Edt_LogoRegionH.SetNumericOnly(true);
	Edt_LogoRegionH.EditBoxWidth = 30;
}

function ApplyTheme() {
	//Chk_RetainCandidates // not themed
	Edt_DefaultTimeMessageClass.Theme = Theme;
	Edt_LogoTexture.Theme = Theme;
	Edt_LogoRegionX.Theme = Theme;
	Edt_LogoRegionY.Theme = Theme;
	Edt_LogoRegionW.Theme = Theme;
	Edt_LogoRegionH.Theme = Theme;
}

defaultproperties {
	Text_RetainCandidates="Retain Candidates"
	Text_DefaultTimeMessageClass="Time Msg Class"
	Text_LogoTexture="Logo Texture"
	Text_LogoRegion="Logo Region"
	Text_LogoRegionX="X"
	Text_LogoRegionY="Y"
	Text_LogoRegionW="W"
	Text_LogoRegionH="H"
}
