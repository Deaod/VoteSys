class VS_UI_PlayerListBox extends UWindowListBox;

var UWindowCheckbox DummyCheckbox;

var float CheckboxOffsetX;
var float CheckboxOffsetY;
var float PlayerNameOffsetX;
var float PlayerNameOffsetY;

function Created() {
	super.Created();

	DummyCheckbox = new class'UWindowCheckbox';
	DummyCheckbox.Root = Root;
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

	while((CurItem != none) && (i < VertSB.Pos)) {
		if(CurItem.ShowThisItem())
			i++;
		CurItem = CurItem.Next;
	}

	for(y=LookAndFeel.MiscBevelT[LookAndFeel.EditBoxBevel].H;(y < YLimit) && (CurItem != none);CurItem = CurItem.Next) {
		if (CurItem.ShowThisItem()) {
			if (MouseY >= y && MouseY < y+ItemHeight)
				return UWindowListBoxItem(CurItem);
			y = y + ItemHeight;
		}
	}

	return none;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H) {
	local VS_UI_PlayerListItem I;
	I = VS_UI_PlayerListItem(Item);
	C.DrawColor.r = 255;
	C.DrawColor.g = 255;
	C.DrawColor.b = 255;

	DummyCheckbox.bChecked = I.bHasVoted;
	DummyCheckbox.bDisabled = false;
	DummyCheckbox.BeforePaint(C, 0, 0);
	DummyCheckbox.ImageX = X+CheckboxOffsetX;
	DummyCheckbox.ImageY = Y+CheckboxOffsetY;
	DummyCheckbox.Paint(C, 0, 0);

	C.Font = Root.Fonts[F_Normal];

	C.DrawColor.r = 0;
	C.DrawColor.g = 0;
	C.DrawColor.b = 0;
	ClipText(C, X+PlayerNameOffsetX, Y+PlayerNameOffsetY, I.PRI.PlayerName);
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	local int BevelType;
	local float XL, YL;

	C.Font = Root.Fonts[F_Normal];
	BevelType = LookAndFeel.EditBoxBevel;
	TextSize(C, "T", XL, YL);
	ItemHeight = 17;
	CheckboxOffsetX = 2;
	CheckboxOffsetY = 0;
	PlayerNameOffsetX = 20;
	PlayerNameOffsetY = 0;

	DummyCheckbox.WinWidth = 16;
	DummyCheckbox.WinHeight = 16;
	DummyCheckbox.LookAndFeel = LookAndFeel;

	VertSB.SetRange(
		0,
		Items.CountShown(),
		int((WinHeight - (LookAndFeel.MiscBevelT[BevelType].H + LookAndFeel.MiscBevelB[BevelType].H)) / ItemHeight)
	);
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

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	DrawStretchedTexture(C, 0, 0, WinWidth - VertSB.WinWidth, WinHeight, Texture'WhiteTexture');
	DrawMiscBevel(C, 0, 0, WinWidth - VertSB.WinWidth, WinHeight, LookAndFeel.Misc, BevelType);

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

	DummyCheckbox.ClippingRegion = ClippingRegion;

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

defaultproperties {
	ListClass=class'VS_UI_PlayerListItem'
	ItemHeight=16
}
