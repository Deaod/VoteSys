class VS_UI_ClientSettingsPage extends UWindowPageWindow;

var VS_ClientSettings Settings;
var int ActiveTheme;

var VS_UI_ComboControl Cmb_Theme;
var localized string ThemeText;
var localized string ThemeBright;
var localized string ThemeDark;
var localized string ThemeBlack;

var UWindowSmallButton Btn_Save;
var localized string SaveText;

var UWindowSmallCloseButton Btn_Close;

function Created() {
	super.Created();

	Cmb_Theme = VS_UI_ComboControl(CreateControl(class'VS_UI_ComboControl', 8, 8, 188, 16));
	Cmb_Theme.SetText(ThemeText);
	Cmb_Theme.AddItem(ThemeBright);
	Cmb_Theme.AddItem(ThemeDark);
	Cmb_Theme.AddItem(ThemeBlack);
	Cmb_Theme.SetEditable(false);

	Btn_Save = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 298, 334, 40, 16));
	Btn_Save.SetText(SaveText);

	Btn_Close = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', 342, 334, 40, 16));
}

function LoadSettings(VS_ClientSettings S) {
	Settings = S;

	Cmb_Theme.SetSelectedIndex(S.Theme);
}

function SaveSettings() {
	Settings.Theme = Settings.IntToTheme(Cmb_Theme.GetSelectedIndex());
}

function Notify(UWindowDialogControl C, byte E) {
	if (C == Btn_Save && E == DE_Click) {
		SaveSettings();
	}
}

function BeforePaint(Canvas C, float X, float Y) {
	super.BeforePaint(C, X, Y);

	if (ActiveTheme != Settings.Theme) {
		ActiveTheme = Settings.Theme;
		ApplyTheme(Settings.Theme);
	}
}

function ApplyTheme(byte Theme) {
	local VS_UI_ThemeBase T;

	switch(Settings.IntToTheme(Theme)) {
		case TH_Bright:
			T = new class'VS_UI_ThemeBright';
			break;
		case TH_Dark:
			T = new class'VS_UI_ThemeDark';
			break;
		case TH_Black:
			T = new class'VS_UI_ThemeBlack';
			break;
	}

	if (T == none)
		T = new class'VS_UI_ThemeBright';

	Cmb_Theme.Theme = T;
}

defaultproperties {
	ActiveTheme=-1

	ThemeText="Theme"
	ThemeBright="Bright"
	ThemeDark="Dark"
	ThemeBlack="Black"

	SaveText="Save"
}
