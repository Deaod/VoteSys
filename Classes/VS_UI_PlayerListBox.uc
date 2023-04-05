class VS_UI_PlayerListBox extends UWindowListBox;

var VS_UI_ThemeBase Theme;

var UWindowCheckbox DummyCheckbox;

var float CheckboxOffsetX;
var float CheckboxOffsetY;
var float PlayerNameOffsetX;
var float PlayerNameOffsetY;

var VS_UI_PlayerListItem HoverItem;
var VS_UI_PlayerMenu ContextMenu;


var transient GameReplicationInfo GRI;

function Created() {
	super.Created();

	DummyCheckbox = new class'UWindowCheckbox';
	DummyCheckbox.Root = Root;

	ContextMenu = VS_UI_PlayerMenu(Root.CreateWindow(class'VS_UI_PlayerMenu', 0, 0, 100, 100, self));
	ContextMenu.HideWindow();
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
	local color SavedColor;
	I = VS_UI_PlayerListItem(Item);

	if (I.bHover) {
		C.DrawColor = Theme.HighlitBG;
		DrawStretchedTexture(C, X, Y, W, H, Texture'WhiteTexture');
		C.DrawColor = Theme.HighlitFG;
	} else {
		C.DrawColor = Theme.Foreground;
	}

	SavedColor = C.DrawColor;

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.DrawColor.A = 255;

	DummyCheckbox.bChecked = I.PlayerInfo.bHasVoted;
	DummyCheckbox.bDisabled = I.PlayerInfo.bCanVote == false;
	DummyCheckbox.BeforePaint(C, 0, 0);
	DummyCheckbox.ImageX = X+CheckboxOffsetX;
	DummyCheckbox.ImageY = Y+CheckboxOffsetY;
	DummyCheckbox.Paint(C, 0, 0);

	C.Font = Root.Fonts[F_Normal];

	C.DrawColor = SavedColor;
	ClipText(C, X+PlayerNameOffsetX, Y+PlayerNameOffsetY, I.PlayerInfo.PRI.PlayerName);

	if (GRI != none &&
		GRI.bTeamGame &&
		(I.PlayerInfo.PRI.bIsSpectator == false || I.PlayerInfo.PRI.bWaitingPlayer) &&
		I.PlayerInfo.PRI.Team < 4 &&
		Len(I.PlayerInfo.PRI.TeamName) > 0
	) {
		C.DrawColor = class'ChallengeTeamHUD'.default.TeamColor[I.PlayerInfo.PRI.Team];
	}

	ClipText(C, X+PlayerNameOffsetX, Y+PlayerNameOffsetY, I.PlayerInfo.PRI.PlayerName);
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

	if (HoverItem != none)
		HoverItem.bHover = false;
	HoverItem = VS_UI_PlayerListItem(GetItemAt(MouseX, MouseY));
	if (HoverItem != none)
		HoverItem.bHover = true;

	VertSB.SetRange(
		0,
		Items.CountShown(),
		int((WinHeight - (LookAndFeel.MiscBevelT[BevelType].H + LookAndFeel.MiscBevelB[BevelType].H)) / ItemHeight)
	);

	if (GRI == none)
		foreach GetLevel().AllActors(class'GameReplicationInfo', GRI)
			break;
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

function Close(optional bool bByParent) {
	if (ContextMenu.bWindowVisible)
		ContextMenu.CloseUp();
	super.Close(bByParent);
}

function RMouseDown(float MouseX, float MouseY) {
	local VS_UI_PlayerListItem I;
	super.RMouseDown(MouseX, MouseY);

	I = VS_UI_PlayerListItem(GetItemAt(MouseX, MouseY));
	if (I == none)
		return;

	ContextMenu.WinLeft = Root.MouseX;
	ContextMenu.WinTop = Root.MouseY;
	ContextMenu.PlayerBan.bDisabled = (GetPlayerOwner().PlayerReplicationInfo.bAdmin == false);

	// ContextMenu.PRI MUST be set before ShowWindow is invoked,
	// ShowWindow renames the ContextMenu items depending on PRI
	ContextMenu.PRI = I.PlayerInfo.PRI;
	ContextMenu.ShowWindow();
}

defaultproperties {
	ListClass=class'VS_UI_PlayerListItem'
	ItemHeight=13
}
