class VS_Preset extends Object;

var VS_Preset       Next;
var VS_PresetConfig Storage;
var int             StorageIndex;
var string          PresetName;
var string          Abbreviation;
var string          Category;
var int             SortPriority;
var string          ServerName;
var class<GameInfo> Game;
var VS_Map          MapList;
var string          Mutators;
var string          Parameters;
var string          GameSettings;
var string          Packages;
var bool            bDisabled;
var bool            bOpenVoteMenuAutomatically;
var bool            bLoading;
var bool            bLoaded;
var int             MaxSequenceNumber;
var int             MinimumMapRepeatDistance;
var int             MinPlayers;
var int             MaxPlayers;

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
	local int SequenceCutoff;
	local bool Skip;

	if (MapList == none)
		return none;

	SequenceCutoff = MaxSequenceNumber - MinimumMapRepeatDistance;
	Target = FRand();
	M = MapList;
	Result = MapList;
	while (M.Next != none) {
		Skip = (M.Sequence > 0 && M.Sequence > SequenceCutoff);
		M = M.Next;
		if (Skip)
			continue;
		TargetCount += Target;
		if (TargetCount >= 1.0) {
			TargetCount -= 1.0;
			do {
				Result = Result.Next;
			} until(Result.Sequence == 0 || Result.Sequence <= SequenceCutoff);
		}
	}

	return Result;
}

defaultproperties {
	bOpenVoteMenuAutomatically=True
	MinimumMapRepeatDistance=-1
	MinPlayers=-1
	MaxPlayers=-1
}
