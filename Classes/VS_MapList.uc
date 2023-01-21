class VS_MapList extends Object;

var VS_MapList Next;
var class<GameInfo> Game;
var string ListName;
var VS_Map First;
var VS_Map Last;

function AppendMap(string MapName) {
	if (Last == none) {
		Last = new class'VS_Map';
		First = Last;
	} else {
		Last.Next = new class'VS_Map';
		Last = Last.Next;
	}
	Last.MapName = MapName;
}

function VS_Map DuplicateList() {
	local VS_Map C;
	local VS_Map F;
	local VS_Map M;

	if (First == none)
		return none;

	F = new(Outer) class'VS_Map';
	M = F;

	for (C = First; C != none; C = C.Next) {
		M.MapName = C.MapName;
		if (C.Next != none) {
			M.Next = new(Outer) class'VS_Map';
			M = M.Next;
		} else {
			return F;
		}
	}

	return F;
}
