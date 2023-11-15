class VS_Preset extends Object;

var VS_Preset       Next;
var VS_PresetConfig Storage;
var string          PresetName;
var string          Abbreviation;
var string          Category;
var int             SortPriority;
var class<GameInfo> Game;
var VS_Map          MapList;
var string          Mutators;
var string          Parameters;
var string          GameSettings;
var string          Packages;
var bool            bDisabled;
var bool            bLoading;
var bool            bLoaded;
var int             MaxSequenceNumber;
var int             MinimumMapRepeatDistance;

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

function AppendPackage(string Pkg) {
	if (Pkg == "")
		return;

	if (Packages == "") {
		Packages = Pkg;
	} else {
		Packages = Packages$","$Pkg;
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

function VS_Map SelectRandomMapFromList() {
	local float Target;
	local float TargetCount;
	local VS_Map M;
	local VS_Map Result;

	if (MapList == none)
		return none;

	Target = FRand();
	M = MapList;
	Result = MapList;
	while (M.Next != none) {
		M = M.Next;
		if (M.Sequence > MaxSequenceNumber - MinimumMapRepeatDistance)
			continue;
		TargetCount += Target;
		if (TargetCount >= 1.0) {
			TargetCount -= 1.0;
			Result = Result.Next;
		}
	}

	return Result;
}
