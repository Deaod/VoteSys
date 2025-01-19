class VS_UI_ChatArea extends UWindowDynamicTextArea;

var VS_UI_ThemeBase Theme;
var GameReplicationInfo GRI;

// Selection
var bool bVS_Select;
var string VS_SelectedText;

var float VS_ClickX, VS_ClickY;
var float VS_StartX, VS_StartY;
var float VS_EndX, VS_EndY;

// selection
function LMouseDown(float X, float Y) {
	super.LMouseDown(X, Y);
	VS_ClickX = X - LookAndFeel.MiscBevelL[LookAndFeel.EditBoxBevel].W;
	VS_ClickY = Y - LookAndFeel.MiscBevelT[LookAndFeel.EditBoxBevel].H;
}

function LMouseUp(float X, float Y) {
	if (bMouseDown && VS_SelectedText != "")
		GetPlayerOwner().CopyToClipboard(VS_SelectedText);
	super.LMouseUp(X, Y);
}


function Paint(Canvas C, float MouseX, float MouseY) {
	local UWindowDynamicTextRow L;
	local int SkipCount, DrawCount;
	local int i;
	local float Y, Junk;
	local bool bWrapped;
	local int BevelType;

	local float VSBWidth;
	local float ContentLeft, ContentTop;
	local float ContentWidth, ContentHeight;

	local Region OldClipRegion;
	local float OrgX,OrgY;
	local float ClipX,ClipY;

	BevelType = LookAndFeel.EditBoxBevel;
	if (VertSB.bWindowVisible)
		VSBWidth = VertSB.WinWidth;

	ContentWidth = WinWidth - VSBWidth - LookAndFeel.MiscBevelL[BevelType].W - LookAndFeel.MiscBevelR[BevelType].W;
	ContentHeight = WinHeight - LookAndFeel.MiscBevelT[BevelType].H - LookAndFeel.MiscBevelB[BevelType].H;
	ContentLeft = LookAndFeel.MiscBevelL[BevelType].W;
	ContentTop = LookAndFeel.MiscBevelT[BevelType].H;

	Theme.DrawBox(C, self, 0, 0, WinWidth - VSBWidth, WinHeight);

	OrgX = C.OrgX; OrgY = C.OrgY;
	ClipX = C.ClipX; ClipY = C.ClipY;
	OldClipRegion = ClippingRegion;

	C.OrgX = int(C.OrgX + ContentLeft * Root.GUIScale);
	C.OrgY = int(C.OrgY + ContentTop * Root.GUIScale);
	C.ClipX = ContentWidth * Root.GUIScale;
	C.ClipY = ContentHeight * Root.GUIScale;
	ClippingRegion.X = 0.0;
	ClippingRegion.Y = 0.0;
	ClippingRegion.W = ContentWidth;
	ClippingRegion.H = COntentHeight;

	MouseX -= ContentLeft;
	MouseY -= ContentTop;

	VS_SelectedText = "";
	bVS_Select = bMouseDown;
	if (bVS_Select)
	{
		if (MouseY < VS_ClickY) {
			VS_StartX = MouseX;
			VS_EndX = VS_ClickX;
		} else {
			VS_StartX = VS_ClickX;
			VS_EndX = MouseX;
		}

		VS_StartY = FMin(MouseY, VS_ClickY);
		VS_EndY = FMax(MouseY, VS_ClickY);
	}

	C.DrawColor = Theme.Foreground;

	if(AbsoluteFont != None)
		C.Font = AbsoluteFont;
	else
		C.Font = Root.Fonts[Font];

	if(OldW != ContentWidth || OldH != ContentHeight)
	{
		WordWrap(C, True);
		OldW = ContentWidth;
		OldH = ContentHeight;
		bWrapped = True;
	}
	else
	if(bDirty)
	{
		WordWrap(C, False);
		bWrapped = True;
	}

	if(bWrapped)
	{
		TextAreaTextSize(C, "A", Junk, DefaultTextHeight);
		VisibleRows = ContentHeight / DefaultTextHeight;
		Count = List.Count();
		VertSB.SetRange(0, Count, VisibleRows);

		if(bScrollOnResize)
		{
			if(bTopCentric)
				VertSB.Pos = 0;
			else
				VertSB.Pos = VertSB.MaxPos;
		}

		if(bAutoScrollbar && !bVariableRowHeight)
		{
			if(Count <= VisibleRows)
				VertSB.HideWindow();
			else
				VertSB.ShowWindow();
		}
	}

	if(bTopCentric)
	{
		SkipCount = VertSB.Pos;
		L = UWindowDynamicTextRow(List.Next);
		for(i=0; i < SkipCount && (L != None) ; i++)
			L = UWindowDynamicTextRow(L.Next);

		if(bVCenter && Count <= VisibleRows)
			Y = int((ContentHeight - (Count * DefaultTextHeight)) / 2);
		else
			Y = 1;

		DrawCount = 0;
		while(Y < ContentHeight)
		{
			DrawCount++;
			if(L != None)
			{
				Y += DrawTextLine2(C, L, Y, ContentWidth);
				L = UWindowDynamicTextRow(L.Next);
			}
			else
				Y += DefaultTextHeight;
		}

		if(bVariableRowHeight)
		{
			VisibleRows = DrawCount - 1;

			while(VertSB.Pos + VisibleRows > Count)
				VisibleRows--;

			VertSB.SetRange(0, Count, VisibleRows);

			if(bAutoScrollbar)
			{
				if(Count <= VisibleRows)
					VertSB.HideWindow();
				else
					VertSB.ShowWindow();
			}
		}
	}
	else
	{
		SkipCount = Max(0, Count - (VisibleRows + VertSB.Pos));
		L = UWindowDynamicTextRow(List.Last);
		for(i=0; i < SkipCount && (L != List) ; i++)
			L = UWindowDynamicTextRow(L.Prev);

		Y = ContentHeight - DefaultTextHeight;
		while(L != List && L != None && Y > -DefaultTextHeight)
		{
			DrawTextLine2(C, L, Y, ContentWidth);
			Y = Y - DefaultTextHeight;
			L = UWindowDynamicTextRow(L.Prev);
		}
	}

	C.OrgX = OrgX; C.OrgY = OrgY;
	C.ClipX = ClipX; C.ClipY = ClipY;
	ClippingRegion = OldClipRegion;
}

function VS_TextAreaClipText2(Canvas C, float DrawX, float DrawY, coerce string S, optional bool bCheckHotkey) {
	ClipText(C, DrawX, DrawY, S, bCheckHotkey);	
}

function TextAreaClipText(Canvas C, float DrawX, float DrawY, coerce string S, optional bool bCheckHotkey) {
	local int X1, X2, XS;
	local color Prev;
	local string Selected;
	local float DrawSelX;
	local float W, H;
	local int i;
	local float DrawBottomY;

	VS_TextAreaClipText2(C, DrawX, DrawY, S, bCheckHotkey);
	
	if (!bVS_Select)
		return;
	
	DrawBottomY = DrawY + DefaultTextHeight;
	
	if (DrawY > VS_EndY || DrawBottomY <= VS_StartY)
		return;
	
	XS = Len(S);
	X1 = 0;
	X2 = XS;
	if (DrawY <= VS_StartY && VS_StartY < DrawBottomY && VS_StartX > 0)
	{
		if (VS_EndY < DrawBottomY && VS_EndX < VS_StartX) {
			H = VS_EndX;
			VS_EndX = VS_StartX;
			VS_StartX = H;
		}
		X1 = XS;
		for (i = 0; i < XS; i++)
		{
			TextAreaTextSize(C, Left(S, i + 1), W, H);
			if (W > VS_StartX)
			{
				X1 = i;
				break;
			}
		}
	}
	
	if (DrawY <= VS_EndY && VS_EndY < DrawBottomY)
	{
		for (i = X1 + 1; i < XS; i++)
		{
			TextAreaTextSize(C, Left(S, i), W, H);
			if (W > VS_EndX)
			{
				X2 = i;
				break;
			}
		}
	}
	
	TextAreaTextSize(C, Left(S, X1), DrawSelX, H);
	DrawSelX += DrawX;

	Selected = Mid(S, X1, X2 - X1);
	
	if (DrawBottomY < VS_EndY)
		VS_SelectedText = Chr(13) $ Chr(10) $ VS_SelectedText;
	VS_SelectedText = Selected $ VS_SelectedText;
	
	Prev = C.DrawColor;
	C.DrawColor = Theme.SelectBG;
	if (DrawBottomY < VS_EndY) {
		if (VertSB.bWindowVisible || bAutoScrollbar)
			W = WinWidth - VertSB.WinWidth - DrawSelX;
		else
			W = WinWidth - DrawSelX;
	} else {
		TextAreaTextSize(C, Selected, W, H);
	}
	DrawStretchedTexture(C, DrawSelX, DrawY, W, DefaultTextHeight, Texture'WhiteTexture');

	C.DrawColor = Theme.SelectFG;
	VS_TextAreaClipText2(C, DrawSelX, DrawY, Selected, bCheckHotkey);
	C.DrawColor = Prev;
}

function float DrawTextLine2(Canvas C, UWindowDynamicTextRow L, float Y, float Width) {
	local float X, W, H;
	local VS_UI_ChatMessage M;

	M = VS_UI_ChatMessage(L);

	if(bHCenter) {
		TextAreaTextSize(C, M.Text, W, H);
		X = int((Width - W) / 2);
	} else {
		X = 2;
	}

	X = int(X * Root.GUIScale + 0.5) / Root.GUIScale;

	if (M.bTeamMsg) {
		if(M.ColorRef == 0) {
			C.DrawColor = M.PlayerColor;
		} else if (M.ColorRef == 1) {
			C.DrawColor = Theme.Foreground;
		}
	}
	TextAreaClipText(C, X, Y, M.Text);

	if (M.PlayerName != "") {
		if(M.ColorRef == 0) {
			C.DrawColor = M.PlayerColor;
		} else if (M.ColorRef == 1) {
			C.DrawColor = Theme.Foreground;
		}
		VS_TextAreaClipText2(C, X, Y, M.PlayerName);
		C.DrawColor = Theme.Foreground;
	}

	return DefaultTextHeight;
}

function AddChat(PlayerReplicationInfo PRI, string Message, bool bTeamMsg) {
	local VS_UI_ChatMessage M;
	local string Text;

	if (PRI != none && PRI.PlayerName != "")
		Text = PRI.PlayerName$": "$Message;
	else
		Text = Message;
	M = VS_UI_ChatMessage(AddText(Text));
	M.Message = Message;
	M.bTeamMsg = bTeamMsg;
	if (PRI != none)
		M.PlayerName = PRI.PlayerName;
	else
		M.PlayerName = "";

	if (GRI == none)
		foreach GetLevel().AllActors(class'GameReplicationInfo', GRI)
			break;

	if (GRI != none && GRI.bTeamGame &&
		PRI != none &&
		(PRI.bIsSpectator == false || PRI.bWaitingPlayer) &&
		PRI.Team < 4 &&
		Len(PRI.TeamName) > 0
	) {
		M.ColorRef = 0;
		M.PlayerColor = class'ChallengeTeamHUD'.default.TeamColor[PRI.Team];
	} else {
		M.ColorRef = 1;
	}
}

defaultproperties {
	MaxLines=500
	RowClass=class'VS_UI_ChatMessage'
}
