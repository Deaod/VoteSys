class VS_UI_MapListItem extends VS_UI_ListItem;

var VS_Map MapRef;
var bool bFilteredOut;

// Sentinel Only
var byte SortMode;

function int Compare(UWindowList T, UWindowList B) {
	local VS_Map M1, M2;

	M1 = VS_UI_MapListItem(T).MapRef;
	M2 = VS_UI_MapListItem(B).MapRef;

	switch(VS_UI_MapListItem(Sentinel).SortMode) {
		case 1:
			if (M1.Sequence > M2.Sequence)
				return -1;
			else if (M1.Sequence < M2.Sequence)
				return 1;
			break;

		case 2:
			if (M1.PlayCount > M2.PlayCount)
				return -1;
			else if (M1.PlayCount < M2.PlayCount)
				return 1;
			break;
	}

	if (Caps(M1.MapName) < Caps(M2.MapName))
		return -1;

	return 1;
}

function bool ShowThisItem() {
	return !bFilteredOut;
}

