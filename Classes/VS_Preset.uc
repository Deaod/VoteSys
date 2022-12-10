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

function string GetDisplayCategory() {
	if (Category == "")
		return "Default";
	return Category;
}

function string GetFullName() {
	return Category$"/"$PresetName;
}
