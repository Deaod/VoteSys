class VS_UI_MapListItem extends VS_UI_ListItem
	imports(VS_ClientSettings);

var VS_Map MapRef;
var bool bFilteredOut;

// Sentinel Only
var EMapListSort SortMode;
var bool bFavoritesFirst;

function int Compare(UWindowList T, UWindowList B) {
	local VS_Map M1, M2;

	M1 = VS_UI_MapListItem(T).MapRef;
	M2 = VS_UI_MapListItem(B).MapRef;

	if (VS_UI_MapListItem(Sentinel).bFavoritesFirst && M1.bClientFavorite != M2.bClientFavorite) {
		if (M1.bClientFavorite)
			return -1;
		
		return 1;
	}

	switch(VS_UI_MapListItem(Sentinel).SortMode) {
		case MLS_Recency:
			if (M1.Sequence > M2.Sequence)
				return -1;
			else if (M1.Sequence < M2.Sequence)
				return 1;
			break;

		case MLS_PlayCount:
			if (M1.PlayCount > M2.PlayCount)
				return -1;
			else if (M1.PlayCount < M2.PlayCount)
				return 1;
			break;

		case MLS_Rating:
			if (M1.Rating > M2.Rating)
				return -1;
			else if (M1.Rating < M2.Rating)
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

