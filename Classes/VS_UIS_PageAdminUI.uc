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

var VS_UI_EditControl Edt_LogoButton0Label;
var localized string Text_LogoButton0Label;

var VS_UI_EditControl Edt_LogoButton0LinkURL;
var localized string Text_LogoButton0LinkURL;

var VS_UI_EditControl Edt_LogoButton1Label;
var localized string Text_LogoButton1Label;

var VS_UI_EditControl Edt_LogoButton1LinkURL;
var localized string Text_LogoButton1LinkURL;

var VS_UI_EditControl Edt_LogoButton2Label;
var localized string Text_LogoButton2Label;

var VS_UI_EditControl Edt_LogoButton2LinkURL;
var localized string Text_LogoButton2LinkURL;

function EnableInteraction(bool bEnable) {
	Chk_RetainCandidates.bDisabled = !bEnable;
	Edt_DefaultTimeMessageClass.EditBox.SetEditable(bEnable);
	Edt_LogoTexture.EditBox.SetEditable(bEnable);
	Edt_LogoRegionX.EditBox.SetEditable(bEnable);
	Edt_LogoRegionY.EditBox.SetEditable(bEnable);
	Edt_LogoRegionW.EditBox.SetEditable(bEnable);
	Edt_LogoRegionH.EditBox.SetEditable(bEnable);
	Edt_LogoButton0Label.EditBox.SetEditable(bEnable);
	Edt_LogoButton0LinkURL.EditBox.SetEditable(bEnable);
	Edt_LogoButton1Label.EditBox.SetEditable(bEnable);
	Edt_LogoButton1LinkURL.EditBox.SetEditable(bEnable);
	Edt_LogoButton2Label.EditBox.SetEditable(bEnable);
	Edt_LogoButton2LinkURL.EditBox.SetEditable(bEnable);
}

function LoadServerSettings() {
	Chk_RetainCandidates.bChecked = Settings.bRetainCandidates;
	Edt_DefaultTimeMessageClass.SetValue(Settings.DefaultTimeMessageClass);
	Edt_LogoTexture.SetValue(Settings.LogoTexture);
	Edt_LogoRegionX.SetValue(string(Settings.LogoRegion.X));
	Edt_LogoRegionY.SetValue(string(Settings.LogoRegion.Y));
	Edt_LogoRegionW.SetValue(string(Settings.LogoRegion.W));
	Edt_LogoRegionH.SetValue(string(Settings.LogoRegion.H));
	Edt_LogoButton0Label.SetValue(Settings.LogoButton0.Label);
	Edt_LogoButton0LinkURL.SetValue(Settings.LogoButton0.LinkURL);
	Edt_LogoButton1Label.SetValue(Settings.LogoButton1.Label);
	Edt_LogoButton1LinkURL.SetValue(Settings.LogoButton1.LinkURL);
	Edt_LogoButton2Label.SetValue(Settings.LogoButton2.Label);
	Edt_LogoButton2LinkURL.SetValue(Settings.LogoButton2.LinkURL);
}

function SaveSettings() {
	Settings.bRetainCandidates = Chk_RetainCandidates.bChecked;
	Settings.DefaultTimeMessageClass = Edt_DefaultTimeMessageClass.GetValue();
	Settings.LogoTexture = Edt_LogoTexture.GetValue();
	Settings.LogoRegion.X = int(Edt_LogoRegionX.GetValue());
	Settings.LogoRegion.Y = int(Edt_LogoRegionY.GetValue());
	Settings.LogoRegion.W = int(Edt_LogoRegionW.GetValue());
	Settings.LogoRegion.H = int(Edt_LogoRegionH.GetValue());
	Settings.LogoButton0.Label = Edt_LogoButton0Label.GetValue();
	Settings.LogoButton0.LinkURL = Edt_LogoButton0LinkURL.GetValue();
	Settings.LogoButton1.Label = Edt_LogoButton1Label.GetValue();
	Settings.LogoButton1.LinkURL = Edt_LogoButton1LinkURL.GetValue();
	Settings.LogoButton2.Label = Edt_LogoButton2Label.GetValue();
	Settings.LogoButton2.LinkURL = Edt_LogoButton2LinkURL.GetValue();

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

	Edt_LogoButton0Label = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 108, 188, 16));
	Edt_LogoButton0Label.SetText(Text_LogoButton0Label);
	Edt_LogoButton0Label.EditBoxWidth = 100;

	Edt_LogoButton0LinkURL = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 128, 188, 16));
	Edt_LogoButton0LinkURL.SetText(Text_LogoButton0LinkURL);
	Edt_LogoButton0LinkURL.EditBoxWidth = 100;

	Edt_LogoButton1Label = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 148, 188, 16));
	Edt_LogoButton1Label.SetText(Text_LogoButton1Label);
	Edt_LogoButton1Label.EditBoxWidth = 100;

	Edt_LogoButton1LinkURL = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 168, 188, 16));
	Edt_LogoButton1LinkURL.SetText(Text_LogoButton1LinkURL);
	Edt_LogoButton1LinkURL.EditBoxWidth = 100;

	Edt_LogoButton2Label = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 188, 188, 16));
	Edt_LogoButton2Label.SetText(Text_LogoButton2Label);
	Edt_LogoButton2Label.EditBoxWidth = 100;

	Edt_LogoButton2LinkURL = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 208, 188, 16));
	Edt_LogoButton2LinkURL.SetText(Text_LogoButton2LinkURL);
	Edt_LogoButton2LinkURL.EditBoxWidth = 100;
}

function ApplyTheme() {
	//Chk_RetainCandidates // not themed
	Edt_DefaultTimeMessageClass.Theme = Theme;
	Edt_LogoTexture.Theme = Theme;
	Edt_LogoRegionX.Theme = Theme;
	Edt_LogoRegionY.Theme = Theme;
	Edt_LogoRegionW.Theme = Theme;
	Edt_LogoRegionH.Theme = Theme;
	Edt_LogoButton0Label.Theme = Theme;
	Edt_LogoButton0LinkURL.Theme = Theme;
	Edt_LogoButton1Label.Theme = Theme;
	Edt_LogoButton1LinkURL.Theme = Theme;
	Edt_LogoButton2Label.Theme = Theme;
	Edt_LogoButton2LinkURL.Theme = Theme;
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
	Text_LogoButton0Label="Button 1 Label"
	Text_LogoButton0LinkURL="Button 1 URL"
	Text_LogoButton1Label="Button 2 Label"
	Text_LogoButton1LinkURL="Button 2 URL"
	Text_LogoButton2Label="Button 3 Label"
	Text_LogoButton2LinkURL="Button 3 URL"
}
