class VS_UI_ListBox extends UWindowListBox;

var VS_UI_ThemeBase Theme;

var VS_UI_ListItem HoverItem;

var float TotalBevelWidth, TotalBevelHeight;

enum EHorizontalScrollbarMode {
	HSM_Hide,
	HSM_Show,
	HSM_Auto
};
var EHorizontalScrollbarMode HorizontalScrollbarMode;
var float MaxItemWidth;
var UWindowHScrollbar HorSB;

const DE_VoteSys_ClickDone = 128;

function Created() {
	super.Created();

	HorSB = UWindowHScrollbar(CreateWindow(class'UWindowHScrollbar',
		0,
		WinHeight - LookAndFeel.Size_ScrollbarWidth,
		WinWidth - LookAndFeel.Size_ScrollbarWidth,
		LookAndFeel.Size_ScrollbarWidth
	));
}

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
	if (HorSB.bWindowVisible)
		YLimit -= LookAndFeel.Size_ScrollbarWidth;

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

function float ItemWidth(Canvas C, UWindowList Item, float VisibleWidth) {
	return VisibleWidth;
}

function float CalcMaxItemWidth(Canvas C, float VisibleWidth) {
	local UWindowList I;
	local float MaxWidth;

	if (HorizontalScrollbarMode == HSM_Hide)
		return VisibleWidth;

	for (I = Items.Next; I != none; I = I.Next) {
		MaxWidth = FMax(MaxWidth, ItemWidth(C, I, VisibleWidth));
	}

	return MaxWidth;
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	local string NewHelpText;
	local int BevelType;
	local float TotalBevelWidth, TotalBevelHeight;
	local float VisibleHeight;
	local float VisibleWidth;
	local float BevelScale;

	BevelType = LookAndFeel.EditBoxBevel;
	BevelScale = FMin(Max(1, int(Root.GUIScale)), Root.GUIScale) / Root.GUIScale;
	TotalBevelWidth  = (LookAndFeel.MiscBevelL[BevelType].W + LookAndFeel.MiscBevelR[BevelType].W) * BevelScale;
	TotalBevelHeight = (LookAndFeel.MiscBevelT[BevelType].H + LookAndFeel.MiscBevelB[BevelType].H) * BevelScale;

	VisibleWidth = WinWidth - VertSB.WinWidth - TotalBevelWidth;
	MaxItemWidth = CalcMaxItemWidth(C, VisibleWidth);

	if (HorizontalScrollbarMode == HSM_Show || MaxItemWidth > VisibleWidth) {
		HorSB.ShowWindow();
		HorSB.WinLeft = 0;
		HorSB.WinTop = WinHeight - LookAndFeel.Size_ScrollbarWidth;
		HorSB.WinHeight = LookAndFeel.Size_ScrollbarWidth;
		HorSB.WinWidth = WinWidth - LookAndFeel.Size_ScrollbarWidth;
		HorSB.SetRange(0, MaxItemWidth, VisibleWidth);
	} else {
		HorSB.HideWindow();
	}

	VisibleHeight = WinHeight - TotalBevelHeight;
	if (HorSB.bWindowVisible) {
		VisibleHeight -= HorSB.WinHeight;
		VertSB.WinHeight = WinHeight - LookAndFeel.Size_ScrollbarWidth;
	}
	VertSB.SetRange(0, Items.CountShown(), int(VisibleHeight / ItemHeight));

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
	local float VisibleWidth;
	local float YLimit;
	local float BevelScale;

	local Region OldClipRegion;
	local float OrgX,OrgY;
	local float ClipX,ClipY;

	BevelType = LookAndFeel.EditBoxBevel;

	if (HorSB.bWindowVisible)
		Theme.DrawBox(C, self,
			0,
			0,
			WinWidth - LookAndFeel.Size_ScrollbarWidth,
			WinHeight - LookAndFeel.Size_ScrollbarWidth
		);
	else
		Theme.DrawBox(C, self,
			0,
			0,
			WinWidth - LookAndFeel.Size_ScrollbarWidth,
			WinHeight
		);

	CurItem = Items.Next;
	i = 0;
	VisibleWidth = WinWidth - VertSB.WinWidth - TotalBevelWidth;
	YLimit = WinHeight - TotalBevelHeight;
	if (HorSB.bWindowVisible)
		YLimit -= LookAndFeel.Size_ScrollbarWidth;

	OrgX = C.OrgX; OrgY = C.OrgY;
	ClipX = C.ClipX; ClipY = C.ClipY;
	OldClipRegion = ClippingRegion;

	BevelScale = FMin(Max(1, int(Root.GUIScale)), Root.GUIScale);
	C.OrgX = int(C.OrgX + LookAndFeel.MiscBevelL[BevelType].W * BevelScale);
	C.OrgY = int(C.OrgY + LookAndFeel.MiscBevelT[BevelType].H * BevelScale);
	C.ClipX = VisibleWidth * Root.GUIScale;
	C.ClipY = YLimit * Root.GUIScale;
	ClippingRegion.X = 0.0;
	ClippingRegion.Y = 0.0;
	ClippingRegion.W = VisibleWidth;
	ClippingRegion.H = YLimit;

	while ((CurItem != None) && (i < VertSB.Pos)) {
		if (CurItem.ShowThisItem())
			i++;
		CurItem = CurItem.Next;
	}

	for (Y = 0; (Y < YLimit) && (CurItem != None); CurItem = CurItem.Next) {
		if (CurItem.ShowThisItem()) {
			DrawItem(C, CurItem, -HorSB.Pos, Y, MaxItemWidth, ItemHeight);
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
	if (NewSelected != none && NewSelected.bEnabled)
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
	HorizontalScrollbarMode=HSM_Hide
	ListClass=class'VS_UI_ListItem'
	ItemHeight=13
}
