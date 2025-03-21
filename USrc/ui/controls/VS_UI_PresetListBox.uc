class VS_UI_PresetListBox extends VS_UI_ListBox;

function float ItemWidth(Canvas C, UWindowList Item, float VisibleWidth) {
	local VS_UI_PresetListItem I;
	local float W, H;

	I = VS_UI_PresetListItem(Item);
	TextSize(C, I.Preset.Category$"/"$I.Preset.PresetName, W, H);

	return FMax(W + 4.0, VisibleWidth);
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H) {
	local VS_UI_PresetListItem I;

	super.DrawItem(C, Item, X, Y, W, H);

	I = VS_UI_PresetListItem(Item);
	ClipText(C, X + 2.0, Y, I.Preset.Category$"/"$I.Preset.PresetName);
}

defaultproperties {
	HorizontalScrollbarMode=HSM_Show
	ListClass=class'VS_UI_PresetListItem'
	bCanDrag=True
}
