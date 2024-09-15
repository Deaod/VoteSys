class VS_MapList extends Object;

struct MapInfo {
	var string MapName;
	var int MinPlayers;
	var int MaxPlayers;
};

var VS_MapList Next;
var string Prefix;
var string ListName;
var array<MapInfo> Maps;
var VS_MapListConfig Storage;

// Finds either the exact index of the MapName in the Maps array or the first
// index that returns true for (Maps[Index].MapName > MapName)
function int FindIndexForMap(string MapName) {
	local int F, C;
	local int Index;
	local string CompMap;

	MapName = Caps(MapName);
	F = 0;
	C = Maps.Length - 1;

	while(F <= C) {
		Index = F + ((C - F) / 2);
		CompMap = Caps(Maps[Index].MapName);
		if (CompMap < MapName)
			F = ++Index;
		else if (CompMap > MapName)
			C = Index-1;
		else
			return Index;
	}

	return Index;
}

function bool HaveMap(string MapName) {
	local int Index;

	Index = FindIndexForMap(MapName);
	if (Index >= Maps.Length)
		return false;
	return Maps[Index].MapName ~= MapName;
}

function bool AddMapFromConfig(string ConfigLine) {
	local int CPos;
	local string Options;
	local string Option;
	local string MapName;
	local int MinPlayers;
	local int MaxPlayers;

	CPos = InStr(ConfigLine, ",");
	
	if (CPos >= 0) {
		Options = Mid(ConfigLine, CPos+1);
		MapName = Left(ConfigLine, CPos);

		while(CPos >= 0) {
			CPos = InStr(Options, ",");
			if (CPos >= 0) {
				Option = Left(Options, CPos);
				Options = Mid(Options, CPos+1);
			} else {
				Option = Options;
			}

			if (Left(Option, 11) ~= "MinPlayers=") {
				MinPlayers = int(Mid(Option, 11));
			} else if (Left(Option, 11) ~= "MaxPlayers=") {
				MaxPlayers = int(Mid(Option, 11));
			} else {
				Log("Unknown Map Option '"$Option$"'", 'VoteSys');
			}

		}
	} else {
		MapName = ConfigLine;
	}

	if (Right(MapName, 4) ~= ".unr")
		MapName = Left(MapName, Len(MapName) - 4); // we dont care about extension

	return AddMap(MapName, MinPlayers, MaxPlayers);
}

function bool AddMap(string MapName, optional int MinPlayers, optional int MaxPlayers) {
	local int i;

	i = FindIndexForMap(MapName);
	if (i < Maps.Length && Maps[i].MapName ~= MapName)
		return false;

	Maps.Insert(i, 1);
	Maps[i].MapName = MapName;
	Maps[i].MinPlayers = MinPlayers;
	Maps[i].MaxPlayers = MaxPlayers;
	return true;
}

function AddMapList(VS_MapList L) {
	local int i;
	local MapInfo MI;

	for (i = 0; i < L.Maps.Length; i++) {
		MI = L.Maps[i];
		AddMap(MI.MapName, MI.MinPlayers, MI.MaxPlayers);
	}
}

function bool RemoveMap(string MapName) {
	local int i;

	i = FindIndexForMap(MapName);
	if (i < Maps.Length && Maps[i].MapName ~= MapName) {
		Maps.Remove(i, 1);
		return true;
	}
	return false;
}

function RemoveMapList(VS_MapList L) {
	local int i;

	for (i = 0; i < L.Maps.Length; i++)
		RemoveMap(L.Maps[i].MapName);
}

function VS_Map DuplicateList() {
	local int i;
	local VS_Map F;
	local VS_Map M;

	if (Maps.Length == 0)
		return none;

	F = new(Outer) class'VS_Map';
	M = F;
	i = 0;

	while (true) {
		M.MapName = Maps[i].MapName;
		M.MinPlayers = Maps[i].MinPlayers;
		M.MaxPlayers = Maps[i].MaxPlayers;
		
		if (++i >= Maps.Length)
			break;

		M.Next = new(Outer) class'VS_Map';
		M = M.Next;
	}

	return F;
}
