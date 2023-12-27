class VS_UI_ListBox extends UWindowListBox;

var VS_UI_ThemeBase Theme;

var VS_UI_ListItem HoverItem;

const DE_VoteSys_ClickDone = 128;

function UWindowListBoxItem GetItemAt(float MouseX, float MouseY) {
	local float y;
	local UWindowList CurItem;
	local int i;
	local float YLimit;
	
	if (MouseX < LookAndFeel.MiscBevelL[LookAndFeel.EditBoxBevel].W ||
		MouseX >= (WinWidth-VertSB.WinWidth-LookAndFeel.MiscBevelR[LookAndFeel.EditBoxBevel].W)
	) {
		return none;
	}

	CurItem = Items.Next;
	i = 0;
	YLimit = WinHeight - LookAndFeel.MiscBevelB[LookAndFeel.EditBoxBevel].H;

	while((CurItem != none) && (i < VertSB.Pos)) {
		if(CurItem.ShowThisItem())
			i++;
		CurItem = CurItem.Next;
	}

	for(y=LookAndFeel.MiscBevelT[LookAndFeel.EditBoxBevel].H;(y < YLimit) && (CurItem != none);CurItem = CurItem.Next) {
		if (CurItem.ShowThisItem()) {
			if (MouseY >= y && MouseY < y+ItemHeight)
				return VS_UI_ListItem(CurItem);
			y = y + ItemHeight;
		}
	}

	return none;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H) {
	local VS_UI_ListItem I;
	I = VS_UI_ListItem(Item);
	if (I.bEnabled == false) {
		C.DrawColor = Theme.InactiveFG;
	} else if (I.bSelected) {
		C.DrawColor = Theme.SelectBG;
		DrawStretchedTexture(C, X, Y, W, H, Texture'WhiteTexture');
		C.DrawColor = Theme.SelectFG;
	} else if (I.bHover) {
		C.DrawColor = Theme.HighlitBG;
		DrawStretchedTexture(C, X, Y, W, H, Texture'WhiteTexture');
		C.DrawColor = Theme.HighlitFG;
	} else {
		C.DrawColor = Theme.Foreground;
	}

	C.Font = Root.Fonts[F_Normal];
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	local string NewHelpText;
	local int BevelType;

	BevelType = LookAndFeel.EditBoxBevel;

	VertSB.SetRange(
		0,
		Items.CountShown(),
		int((WinHeight - (LookAndFeel.MiscBevelT[BevelType].H + LookAndFeel.MiscBevelB[BevelType].H)) / ItemHeight)
	);

	if (HoverItem != none)
		HoverItem.bHover = false;
	HoverItem = VS_UI_ListItem(GetItemAt(MouseX, MouseY));
	if (HoverItem != none)
		HoverItem.bHover = true;

	NewHelpText = DefaultHelpText;
	if (SelectedItem != None && HoverItem != none && HoverItem == SelectedItem && HoverItem.HelpText != "")
		NewHelpText = HoverItem.HelpText;
	
	if (NewHelpText != HelpText) {
		HelpText = NewHelpText;
		Notify(DE_HelpChanged);
	}
}


function Paint(Canvas C, float MouseX, float MouseY) {
	local int BevelType;
	local float Y;
	local UWindowList CurItem;
	local int i;
	local float ItemWidth;
	local float YLimit;

	local Region OldClipRegion;
	local float OrgX,OrgY;
	local float ClipX,ClipY;

	BevelType = LookAndFeel.EditBoxBevel;

	Theme.DrawBox(C, self, 0, 0, WinWidth - VertSB.WinWidth, WinHeight);

	CurItem = Items.Next;
	i = 0;
	ItemWidth = WinWidth - VertSB.WinWidth - LookAndFeel.MiscBevelL[BevelType].W - LookAndFeel.MiscBevelR[BevelType].W;
	YLimit = WinHeight - LookAndFeel.MiscBevelT[BevelType].H - LookAndFeel.MiscBevelB[BevelType].H;

	OrgX = C.OrgX; OrgY = C.OrgY;
	ClipX = C.ClipX; ClipY = C.ClipY;
	OldClipRegion = ClippingRegion;

	C.OrgX = int(C.OrgX + LookAndFeel.MiscBevelL[BevelType].W * Root.GUIScale);
	C.OrgY = int(C.OrgY + LookAndFeel.MiscBevelT[BevelType].H * Root.GUIScale);
	C.ClipX = ItemWidth * Root.GUIScale;
	C.ClipY = YLimit * Root.GUIScale;
	ClippingRegion.X = 0.0;
	ClippingRegion.Y = 0.0;
	ClippingRegion.W = ItemWidth;
	ClippingRegion.H = YLimit;

	while ((CurItem != None) && (i < VertSB.Pos)) {
		if (CurItem.ShowThisItem())
			i++;
		CurItem = CurItem.Next;
	}

	for(Y = 0; (Y < YLimit) && (CurItem != None); CurItem = CurItem.Next) {
		if(CurItem.ShowThisItem()) {
			DrawItem(C, CurItem, 0, Y, ItemWidth, ItemHeight);
			Y += ItemHeight;
		}
	}

	C.OrgX = OrgX; C.OrgY = OrgY;
	C.ClipX = ClipX; C.ClipY = ClipY;
	ClippingRegion = OldClipRegion;
}

function SetSelected(float X, float Y) {
	local VS_UI_ListItem NewSelected;

	NewSelected = VS_UI_ListItem(GetItemAt(X, Y));
	if (NewSelected.bEnabled)
		SetSelectedItem(NewSelected);
}

function DoubleClickItem(UWindowListBoxItem I) {
	Notify(DE_DoubleClick);
}

function LMouseUp(float X, float Y) {
	super.LMouseUp(X, Y);

	Notify(DE_VoteSys_ClickDone);
}

function ClearSelection() {
	if (SelectedItem != none) {
		SelectedItem.bSelected = false;
		SelectedItem = none;
	}
}

defaultproperties {
	ListClass=class'VS_UI_ListItem'
	ItemHeight=13
}
