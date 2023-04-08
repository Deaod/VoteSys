class VS_UI_ChatArea extends UWindowDynamicTextArea;

var VS_UI_ThemeBase Theme;
var GameReplicationInfo GRI;

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

function float DrawTextLine2(Canvas C, UWindowDynamicTextRow L, float Y, float Width) {
	local float X, W, H;
	local VS_UI_ChatMessage M;

	M = VS_UI_ChatMessage(L);

	if(bHCenter) {
		TextAreaTextSize(C, M.PlayerName$": "$M.Text, W, H);
		X = int((Width - W) / 2);
	} else {
		X = 2;
	}
	TextAreaClipText(C, X, Y, M.PlayerName$": "$M.Text);

	C.DrawColor = M.PlayerColor;
	TextAreaClipText(C, X, Y, M.PlayerName);
	C.DrawColor = Theme.Foreground;

	return DefaultTextHeight;
}

function AddChat(PlayerReplicationInfo PRI, string Message) {
	local VS_UI_ChatMessage M;
	M = VS_UI_ChatMessage(AddText(Message));
	M.PlayerName = PRI.PlayerName;

	if (GRI == none)
		foreach GetLevel().AllActors(class'GameReplicationInfo', GRI)
			break;

	if (GRI != none && GRI.bTeamGame && (PRI.bIsSpectator == false || PRI.bWaitingPlayer) && PRI.Team < 4 && Len(PRI.TeamName) > 0)
		M.PlayerColor = class'ChallengeTeamHUD'.default.TeamColor[PRI.Team];
	else
		M.PlayerColor = Theme.Foreground;
}

defaultproperties {
	MaxLines=500
	RowClass=class'VS_UI_ChatMessage'
}