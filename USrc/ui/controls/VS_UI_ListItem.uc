class VS_UI_ListItem extends UWindowListBoxItem;

var bool bEnabled;
var bool bHover;

// For sentinel only
function UWindowList FindEnabledEntry(int Index) {
	local UWindowList L;

	for(L = Next; L != none; L = L.Next) {
		if (VS_UI_ListItem(L).bEnabled) {
			if (Index == 0)
				break;
			Index -= 1;
		}
	}
	if (L != none && VS_UI_ListItem(L).bEnabled)
		return L;
	else
		return none;
}

function int CountEnabled() {
	local int Count;
	local UWindowList L;

	for (L = Sentinel.Next; L != none; L = L.Next)
		if (VS_UI_ListItem(L).bEnabled)
			Count += 1;

	return Count;
}

defaultproperties {
	bEnabled=True
}
