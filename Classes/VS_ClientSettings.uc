class VS_ClientSettings extends Object
	config(VoteSys)
	perobjectconfig;

enum ETheme {
	TH_Bright,
	TH_Dark,
	TH_Black
};

var config ETheme Theme;

var config float MenuX;
var config float MenuY;

var config float SettingsX;
var config float SettingsY;

static final function ETheme IntToTheme(int A) {
	switch(A) {
		case 0: return TH_Bright;
		case 1: return TH_Dark;
		case 2: return TH_Black;
	}
	return default.Theme;
}

defaultproperties {
	Theme=TH_Bright
	
	MenuX=-1.0
	MenuY=-1.0

	SettingsX=-1.0
	SettingsY=-1.0
}
