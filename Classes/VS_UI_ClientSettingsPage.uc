class VS_UI_ClientSettingsPage extends VS_UI_SettingsPage;

var VS_ClientSettings Settings;

var VS_UI_ComboControl Cmb_Theme;
var localized string ThemeText;
var localized string ThemeBright;
var localized string ThemeDark;
var localized string ThemeBlack;

function Created() {
	super.Created();

	Cmb_Theme = VS_UI_ComboControl(CreateControl(class'VS_UI_ComboControl', 8, 8, 188, 16));
	Cmb_Theme.SetText(ThemeText);
	Cmb_Theme.AddItem(ThemeBright);
	Cmb_Theme.AddItem(ThemeDark);
	Cmb_Theme.AddItem(ThemeBlack);
	Cmb_Theme.SetEditable(false);
}

function LoadSettings(VS_PlayerChannel C) {
	super.LoadSettings(C);

	Settings = C.Settings;

	Cmb_Theme.SetSelectedIndex(Settings.Theme);
}

function SaveSettings() {
	Settings.Theme = Settings.IntToTheme(Cmb_Theme.GetSelectedIndex());

	Settings.SaveConfig();
}

function ApplyTheme() {
	Cmb_Theme.Theme = Theme;
}

defaultproperties {
	ThemeText="Theme"
	ThemeBright="Bright"
	ThemeDark="Dark"
	ThemeBlack="Black"
}
