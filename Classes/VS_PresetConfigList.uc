class VS_PresetConfigList extends Object;

struct Preset {
	var string PresetName;
	var string Abbreviation;
	var string Category;
	var int    SortPriority;
	var array<string> InheritFrom;
	var string Game;
	var name   MapListName;
	var array<string> Mutators;
	var array<string> Parameters;
	var array<string> GameSettings;
	var array<string> Packages;
	var bool bDisabled;
	var int MinimumMapRepeatDistance;
	var int MinPlayers;
	var int MaxPlayers;
};

var array<Preset> PresetList;

function AllocatePresets(int MaxIndex) {
	local int i;
	i = PresetList.Length;
	if (i <= MaxIndex)
		PresetList.Insert(i, MaxIndex - i + 1);
}

