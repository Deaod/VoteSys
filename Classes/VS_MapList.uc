class VS_MapList extends Object;

var VS_MapList Next;
var string Prefix;
var string ListName;
var array<string> Maps;

// Finds either the exact index of the MapName in the Maps array or the first
// index that returns true for (Maps[Index] > MapName)
function int FindIndexForMap(string MapName) {
	local int F, C;
	local int Index;
	local string CompMap;

	MapName = Caps(MapName);
	F = 0;
	C = Maps.Length - 1;

	while(F <= C) {
		Index = F + ((C - F) / 2);
		CompMap = Caps(Maps[Index]);
		if (CompMap < MapName)
			F = Index+1;
		else if (CompMap > MapName)
			C = Index-1;
		else
			return Index;
	}

	if (Index < Maps.Length && Caps(Maps[Index]) < Caps(MapName))
		Index += 1;

	return Index;
}

function bool HaveMap(string MapName) {
	local int Index;

	Index = FindIndexForMap(MapName);
	if (Index >= Maps.Length)
		return false;
	return Maps[Index] ~= MapName;
}

function AddMap(string MapName) {
	local int i;

	i = FindIndexForMap(MapName);
	if (i < Maps.Length && Maps[i] ~= MapName)
		return;

	Maps.Insert(i, 1);
	Maps[i] = MapName;
}

function RemoveMap(string MapName) {
	local int i;

	i = FindIndexForMap(MapName);
	if (i < Maps.Length && Maps[i] ~= MapName)
		Maps.Remove(i, 1);
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
		M.MapName = Maps[i];
		
		if (++i >= Maps.Length)
			break;

		M.Next = new(Outer) class'VS_Map';
		M = M.Next;
	}

	return F;
}
