class VS_ClientMapListsContainer extends Object;

var array<VS_ClientMapList> MapLists;

enum ETransmissionState {
	TS_New,
	TS_Complete,
	TS_NotAdmin
};
var ETransmissionState TransmissionState;

function AllocateMapLists(int MaxIndex) {
	local int i;
	i = MapLists.Length;
	if (i <= MaxIndex) {
		MapLists.Insert(i, MaxIndex - i + 1);
		while(i < MapLists.Length) {
			MapLists[i] = new class'VS_ClientMapList';
			i += 1;
		}
	}
}

function VS_ClientMapList AddMapList() {
	local int i;

	if (TransmissionState != TS_Complete)
		return none;

	i = MapLists.Length;
	MapLists.Insert(i, 1);
	MapLists[i] = new class'VS_ClientMapList';
	return MapLists[i];
}
