class VS_ClientSettings extends Object
	config(VoteSys)
	perobjectconfig;

enum ETheme {
	TH_Bright,
	TH_Dark
};

var config ETheme Theme;

var config float MenuX;
var config float MenuY;

var config float SettingsX;
var config float SettingsY;

defaultproperties {
	Theme=TH_Bright
	
	MenuX=-1.0
	MenuY=-1.0

	SettingsX=-1.0
	SettingsY=-1.0
}
