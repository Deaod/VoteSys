class VS_UI_MapListBox extends VS_UI_ListBox;

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H) {
	local VS_UI_MapListItem I;

	super.DrawItem(C, Item, X, Y, W, H);

	I = VS_UI_MapListItem(Item);
	ClipText(C, X+2, Y, I.MapRef.MapName);
}

function AppendMap(VS_Map M, bool bEnabled) {
	local VS_UI_MapListItem I;
	I = VS_UI_MapListItem(Items.Append(ListClass));
	I.MapRef = M;
	I.bEnabled = bEnabled;
}

defaultproperties {
	ListClass=class'VS_UI_MapListItem'
	ItemHeight=13
}
