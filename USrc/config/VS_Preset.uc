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

// These are used by function SelectRandomMapFromList
var private transient int SequenceCutoff;
var private transient int NumPlayers;

final function AppendMutator(string Mut) {
	if (Mut == "")
		return;

	if (Mutators == "") {
		Mutators = Mut;
	} else {
		Mutators = Mutators$","$Mut;
	}
}

final function AppendParameter(string Param) {
	Parameters = Parameters$Param;
}

final function AppendGameSetting(string Setting) {
	if (Setting == "")
		return;

	if (GameSettings == "") {
		GameSettings = Setting;
	} else {
		GameSettings = GameSettings$","$Setting;
	}
}

final function AppendPackage(string Pkg) {
	if (Pkg == "")
		return;

	if (Packages == "") {
		Packages = Pkg;
	} else {
		Packages = Packages$","$Pkg;
	}
}

final function string GetDisplayCategory() {
	if (Category == "")
		return "Default";
	return Category;
}

final function string GetFullName() {
	return Category$"/"$PresetName;
}

final function bool _ShouldSkip(VS_Map M) {
	if (NumPlayers == 0)
		return false;
	return (M.Sequence > 0 && M.Sequence > SequenceCutoff) ||
		(M.MinPlayers > 0 && NumPlayers < M.MinPlayers) || 
		(M.MaxPlayers > 0 && NumPlayers > M.MaxPlayers);
}

final function VS_Map SelectRandomMapFromList(optional int Players) {
	local float Target;
	local float TargetCount;
	local VS_Map M;
	local VS_Map Result;
	local bool Skip;

	if (MapList == none)
		return none;

	SequenceCutoff = MaxSequenceNumber - MinimumMapRepeatDistance;
	NumPlayers = Players;
	Target = FRand();
	M = MapList;
	Result = MapList;
	while (M.Next != none) {
		Skip = _ShouldSkip(M);
		M = M.Next;
		if (Skip)
			continue;
		TargetCount += Target;
		if (TargetCount >= 1.0) {
			TargetCount -= 1.0;
			do {
				Result = Result.Next;
			} until(_ShouldSkip(Result) == false);
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
