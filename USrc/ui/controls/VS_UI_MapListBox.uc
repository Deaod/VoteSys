class VS_UI_MapListBox extends VS_UI_ListBox;

var VS_UI_MapMenu ContextMenu;

function Created() {
	super.Created();

	ContextMenu = VS_UI_MapMenu(Root.CreateWindow(class'VS_UI_MapMenu', 0, 0, 100, 100, self));
	ContextMenu.HideWindow();
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H) {
	local VS_UI_MapListItem I;
	local bool bDrawStar;
	local float Offset;
	local color FG;

	super.DrawItem(C, Item, X, Y, W, H);

	I = VS_UI_MapListItem(Item);
	Offset = (H+3);

	if (I.MapRef.bClientFavorite) {
		DrawStretchedTexture(C, ClippingRegion.W - Offset, Y, H, H, Texture'StarFilled');
		bDrawStar = true;
	} else if (I.bHover) {
		DrawStretchedTexture(C, ClippingRegion.W - Offset, Y, H, H, Texture'StarEmpty');
		bDrawStar = true;
	}

	if (I.MapRef.Rating >= 0) {
		DrawStretchedTexture(C, X+2, Y+1, 6.0, 10.0, Texture'WhiteTexture');
		FG = C.DrawColor;
		C.DrawColor = ItemBackground;
		DrawStretchedTexture(
			C,
			X+2 + (1.0/Root.GUIScale),
			Y+1 + (1.0/Root.GUIScale),
			6 - (2.0/Root.GUIScale),
			(65535 - I.MapRef.Rating) * (10.0 - (2.0/Root.GUIScale)) / 65535.0,
			Texture'WhiteTexture'
		);

		C.DrawColor = FG;
	}

	if (bDrawStar)
		ClippingRegion.W -= Offset;

	ClipText(C, X+12, Y, I.MapRef.MapName);

	if (bDrawStar)
		ClippingRegion.W += Offset;
}

function float ItemWidth(Canvas C, UWindowList Item, float VisibleWidth) {
	local float W, H;
	local VS_UI_MapListItem I;

	I = VS_UI_MapListItem(Item);

	TextSize(C, I.MapRef.MapName, W, H);
	if (I.MapRef.bClientFavorite)
		W += ItemHeight;

	return FMax(W + 8.0 + 4.0, VisibleWidth);
}

function AppendMap(VS_Map M, bool bEnabled) {
	local VS_UI_MapListItem I;
	I = VS_UI_MapListItem(Items.Append(ListClass));
	I.MapRef = M;
	I.bEnabled = bEnabled;
}

function Close(optional bool bByParent) {
	if (ContextMenu.bWindowVisible)
		ContextMenu.CloseUp(True);
	super.Close(bByParent);
}

function SetSelected(float X, float Y) {
	local VS_UI_MapListItem NewSelected;

	NewSelected = VS_UI_MapListItem(GetItemAt(X, Y));
	if (NewSelected != none) {
		if (NewSelected.bEnabled)
			SetSelectedItem(NewSelected);

		if (X >= (WinWidth-VertSB.WinWidth-LookAndFeel.MiscBevelR[LookAndFeel.EditBoxBevel].W - ItemHeight))
			VS_UIV_ClientWindow(OwnerWindow).ToggleFavorite(NewSelected.MapRef);
	}

}

function RMouseDown(float MouseX, float MouseY) {
	local VS_UI_MapListItem I;

	super.RMouseDown(MouseX, MouseY);

	I = VS_UI_MapListItem(GetItemAt(MouseX, MouseY));

	ContextMenu.WinLeft = Root.MouseX;
	ContextMenu.WinTop = Root.MouseY;
	ContextMenu.ContextItem = I;
	ContextMenu.ShowWindow();
}

defaultproperties {
	HorizontalScrollbarMode=HSM_Auto
	ListClass=class'VS_UI_MapListItem'
	ItemHeight=13
}
