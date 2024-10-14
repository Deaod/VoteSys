class VS_UI_MapListLB extends VS_UI_ListBox;

function float ItemWidth(Canvas C, UWindowList Item, float VisibleWidth) {
	local VS_UI_MapListLI I;
	local float W, H;

	I = VS_UI_MapListLI(Item);
	TextSize(C, I.MapList.MapListName, W, H);

	return FMax(W + 4.0, VisibleWidth);
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H) {
	local VS_UI_MapListLI I;

	super.DrawItem(C, Item, X, Y, W, H);

	I = VS_UI_MapListLI(Item);
	ClipText(C, X, Y, I.MapList.MapListName);
}

defaultproperties {
	HorizontalScrollbarMode=HSM_Show
	ListClass=class'VS_UI_MapListLI'
	bCanDrag=True
}
