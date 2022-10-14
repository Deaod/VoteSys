class VS_UI_MapListItem extends UWindowListBoxItem;

var VS_Map MapRef;
var bool bHover;

function int Compare(UWindowList T, UWindowList B) {
	if(Caps(VS_UI_MapListItem(T).MapRef.MapName) < Caps(VS_UI_MapListItem(B).MapRef.MapName))
		return -1;

	return 1;
}

