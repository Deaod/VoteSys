class VS_UI_CandidateListBox extends UWindowListBox;

var VS_UI_ThemeBase Theme;

var VS_UI_CandidateListItem HoverItem;
var localized string PresetColumnHeader;
var localized string MapColumnHeader;
var localized string VotesColumnHeader;

var localized string RandomMapDisplayName;

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

	while ((CurItem != none) && (i < VertSB.Pos)) {
		if (CurItem.ShowThisItem())
			i++;
		CurItem = CurItem.Next;
	}

	for (y = LookAndFeel.MiscBevelT[LookAndFeel.EditBoxBevel].H+ItemHeight+1; (y < YLimit) && (CurItem != none); CurItem = CurItem.Next) {
		if (CurItem.ShowThisItem()) {
			if (MouseY >= y && MouseY < y+ItemHeight)
				return UWindowListBoxItem(CurItem);
			y = y + ItemHeight;
		}
	}

	return none;
}

function CalcColors(VS_UI_CandidateListItem Item, int Index, out color BG, out color FG, out color Sep) {
	if (Item.bSelected) {
		FG = Theme.SelectFG;
		BG = Theme.SelectBG;
		Sep = Theme.SelectSep;
	} else if (Item.bHover) {
		FG = Theme.HighlitFG;
		BG = Theme.HighlitBG;
		Sep = Theme.HighlitSep;
	} else if ((Index & 1) != 0) {
		FG = Theme.ForegroundAlt;
		BG = Theme.BackgroundAlt;
		Sep = Theme.SeparatorAlt;
	} else {
		FG = Theme.Foreground;
		BG = Theme.Background;
		Sep = Theme.Separator;
	}
}

function DrawCandidate(Canvas C, VS_UI_CandidateListItem Item, int Index, float X, float Y, float W, float H) {
	local color BG, FG, Sep;
	local Region OldClipRegion;
	local float VW,VH;
	local string MapName;

	OldClipRegion = ClippingRegion;

	CalcColors(Item, Index, BG, FG, Sep);

	C.DrawColor = BG;
	DrawStretchedTexture(C, X, Y, W, H, Texture'WhiteTexture');

	C.DrawColor = FG;
	C.Font = Root.Fonts[F_Normal];
	ClippingRegion.W = FMin(163.0, ClippingRegion.W);
	ClipText(C, X+2, Y, Item.Candidate.Preset);
	ClippingRegion = OldClipRegion;

	C.DrawColor = Sep;
	DrawStretchedTexture(C, X+165, Y, 1, H, Texture'WhiteTexture');

	MapName = Item.Candidate.MapName;
	if (MapName == class'VS_Info'.default.RandomMapNameIdentifier)
		MapName = RandomMapDisplayName;

	C.DrawColor = FG;
	ClippingRegion.W = FMin(353.0, ClippingRegion.W);
	ClipText(C, X+168, Y, MapName);
	ClippingRegion = OldClipRegion;

	C.DrawColor = Sep;
	DrawStretchedTexture(C, X+355, Y, 1, H, Texture'WhiteTexture');

	C.DrawColor = FG;
	C.StrLen(Item.Candidate.Votes, VW, VH);
	VW /= Root.GUIScale;
	ClipText(C, X+W-VW-3, Y, Item.Candidate.Votes);
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	local string NewHelpText;
	local int BevelType;

	BevelType = LookAndFeel.EditBoxBevel;

	VertSB.SetRange(
		0,
		Items.CountShown(),
		int((WinHeight - (LookAndFeel.MiscBevelT[BevelType].H + LookAndFeel.MiscBevelB[BevelType].H + (ItemHeight + 1))) / ItemHeight)
	);

	if (HoverItem != none)
		HoverItem.bHover = false;
	HoverItem = VS_UI_CandidateListItem(GetItemAt(MouseX, MouseY));
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

	local float XL, YL;

	local Region OldClipRegion;
	local float OrgX,OrgY;
	local float ClipX,ClipY;

	BevelType = LookAndFeel.EditBoxBevel;

	Theme.DrawBox(C, self, 0, 0, WinWidth - VertSB.WinWidth, WinHeight);

	CurItem = Items.Next;
	i = 0;
	ItemWidth = WinWidth - VertSB.WinWidth - LookAndFeel.MiscBevelL[BevelType].W - LookAndFeel.MiscBevelR[BevelType].W;
	YLimit = WinHeight - LookAndFeel.MiscBevelT[BevelType].H - LookAndFeel.MiscBevelB[BevelType].H - (ItemHeight + 1);

	C.DrawColor = Theme.HighlitBG;
	DrawStretchedTexture(
		C,
		LookAndFeel.MiscBevelL[BevelType].W,
		LookAndFeel.MiscBevelT[BevelType].H,
		ItemWidth,
		ItemHeight,
		Texture'WhiteTexture'
	);

	C.DrawColor = Theme.Separator;
	DrawStretchedTexture(
		C,
		LookAndFeel.MiscBevelL[BevelType].W,
		LookAndFeel.MiscBevelT[BevelType].H + ItemHeight,
		ItemWidth,
		1,
		Texture'WhiteTexture'
	);
	DrawStretchedTexture(
		C,
		LookAndFeel.MiscBevelL[BevelType].W + 165,
		LookAndFeel.MiscBevelT[BevelType].H,
		1,
		ItemHeight,
		Texture'WhiteTexture'
	);
	DrawStretchedTexture(
		C,
		LookAndFeel.MiscBevelL[BevelType].W + 355,
		LookAndFeel.MiscBevelT[BevelType].H,
		1,
		ItemHeight,
		Texture'WhiteTexture'
	);

	C.DrawColor = Theme.Foreground;
	C.StrLen(PresetColumnHeader, XL, YL);
	XL /= Root.GUIScale;
	ClipText(
		C,
		LookAndFeel.MiscBevelL[BevelType].W + ((165 - XL) / 2),
		LookAndFeel.MiscBevelT[BevelType].H,
		PresetColumnHeader
	);

	C.StrLen(MapColumnHeader, XL, YL);
	XL /= Root.GUIScale;
	ClipText(
		C,
		LookAndFeel.MiscBevelL[BevelType].W + 166 + ((189 - XL) / 2),
		LookAndFeel.MiscBevelT[BevelType].H,
		MapColumnHeader
	);
	C.StrLen(VotesColumnHeader, XL, YL);
	XL /= Root.GUIScale;
	ClipText(
		C,
		LookAndFeel.MiscBevelL[BevelType].W + 356 + ((ItemWidth - 356 - XL) / 2), 
		LookAndFeel.MiscBevelT[BevelType].H,
		VotesColumnHeader
	);

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	OrgX = C.OrgX; OrgY = C.OrgY;
	ClipX = C.ClipX; ClipY = C.ClipY;
	OldClipRegion = ClippingRegion;

	C.OrgX = int(C.OrgX + LookAndFeel.MiscBevelL[BevelType].W * Root.GUIScale);
	C.OrgY = int(C.OrgY + (LookAndFeel.MiscBevelT[BevelType].H + ItemHeight + 1) * Root.GUIScale);
	C.ClipX = ItemWidth * Root.GUIScale;
	C.ClipY = YLimit * Root.GUIScale;
	ClippingRegion.X = 0.0;
	ClippingRegion.Y = 0.0;
	ClippingRegion.W = ItemWidth;
	ClippingRegion.H = YLimit;

	C.DrawColor = Theme.Separator;
	DrawStretchedTexture(C, 165, 0, 1, YLimit, Texture'WhiteTexture');
	DrawStretchedTexture(C, 355, 0, 1, YLimit, Texture'WhiteTexture');
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	while ((CurItem != None) && (i < VertSB.Pos)) {
		if (CurItem.ShowThisItem())
			i++;
		CurItem = CurItem.Next;
	}

	for(Y = 0; (Y < YLimit) && (CurItem != None); CurItem = CurItem.Next) {
		if(CurItem.ShowThisItem()) {
			DrawCandidate(C, VS_UI_CandidateListItem(CurItem), i++, 0, Y, ItemWidth, ItemHeight);
			Y += ItemHeight;
		}
	}

	C.OrgX = OrgX; C.OrgY = OrgY;
	C.ClipX = ClipX; C.ClipY = ClipY;
	ClippingRegion = OldClipRegion;
}

function DoubleClickItem(UWindowListBoxItem I) {
	Notify(DE_DoubleClick);
}

function ClearSelection() {
	if (SelectedItem != none) {
		SelectedItem.bSelected = false;
		SelectedItem = none;
	}
}

defaultproperties {
	ListClass=class'VS_UI_CandidateListItem'
	ItemHeight=13
	PresetColumnHeader="Preset"
	MapColumnHeader="Map"
	VotesColumnHeader="Votes"
	RandomMapDisplayName="<Random>"
}
