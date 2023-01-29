class VS_Preset extends Object;

var VS_Preset       Next;
var string          PresetName;
var string          Abbreviation;
var string          Category;
var class<GameInfo> Game;
var VS_Map          MapList;
var string          Mutators;
var string          Parameters;
var string          GameSettings;
var bool            bDisabled;

function AppendMutator(string Mut) {
	if (Mut == "")
		return;

	if (Mutators == "") {
		Mutators = Mut;
	} else {
		Mutators = Mutators$","$Mut;
	}
}

function AppendParameter(string Param) {
	Parameters = Parameters$Param;
}

function AppendGameSetting(string Setting) {
	if (Setting == "")
		return;

	if (GameSettings == "") {
		GameSettings = Setting;
	} else {
		GameSettings = GameSettings$","$Setting;
	}
}

function string GetDisplayCategory() {
	if (Category == "")
		return "Default";
	return Category;
}

function string GetFullName() {
	return Category$"/"$PresetName;
}
