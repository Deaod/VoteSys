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

	super.DrawItem(C, Item, X, Y, W, H);

	I = VS_UI_MapListItem(Item);

	if (I.MapRef.bClientFavorite) {
		DrawStretchedTexture(C, X + W - H, Y, H, H, Texture'StarFilled');
		bDrawStar = true;
	} else if (I.bHover) {
		DrawStretchedTexture(C, X + W - H, Y, H, H, Texture'StarEmpty');
		bDrawStar = true;
	}

	if (bDrawStar)
		ClippingRegion.W -= (H+2);

	ClipText(C, X+2, Y, I.MapRef.MapName);

	if (bDrawStar)
		ClippingRegion.W += (H+2);
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
	ListClass=class'VS_UI_MapListItem'
	ItemHeight=13
}
