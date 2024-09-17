class VS_ClientSettings extends Object
	config(VoteSys)
	perobjectconfig;

enum ETheme {
	TH_Bright,
	TH_Dark,
	TH_Black
};

enum EMapListSort {
	MLS_Name,
	MLS_Recency,
	MLS_PlayCount
};

var config ETheme Theme;
var config EMapListSort MapListSort;

var config string FavoritesList;
var config bool bFavoritesFirst;

var config bool bShowPlayerList;

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

static final function EMapListSort IntToMapListSort(int A) {
	switch(A) {
		case 0: return MLS_Name;
		case 1: return MLS_Recency;
		case 2: return MLS_PlayCount;
	}
	return default.MapListSort;
}

defaultproperties {
	Theme=TH_Bright
	MapListSort=MLS_Name
	FavoritesList=
	bFavoritesFirst=True
	bShowPlayerList=True
	
	MenuX=-1.0
	MenuY=-1.0

	SettingsX=-1.0
	SettingsY=-1.0
}
