class VS_UI_ScreenshotWindow extends UWindowWindow;

var Texture Screenshot;
var float TextHeight;
var color TextColor;
var string PlayersText;
var localized string TextPlayerCount;

function SetUpFor(VS_Map M) {
	local Texture T;
	local float Ratio;
	local Region Bevel;
	

	T = Texture(DynamicLoadObject(M.MapName$".Screenshot", class'Texture', true));
	if (T == none)
		T = Texture'BlackTexture';
	Screenshot = T;

	Ratio = FMin(WinWidth/T.USize, WinHeight/T.VSize);
	Bevel = GetBevelSize();
	TextHeight = 0;
	PlayersText = "";

	if (M.MinPlayers > 0 || M.MaxPlayers > 0) {
		TextHeight += 18;

		if (M.MaxPlayers > 0) {
			if (M.MinPlayers != M.MaxPlayers)
				PlayersText = TextPlayerCount@Max(M.MinPlayers, 0)@"-"@Min(M.MaxPlayers, 32);
			else
				PlayersText = TextPlayerCount@Min(M.MaxPlayers, 32);
		} else {
			PlayersText = TextPlayerCount@Min(M.MinPlayers, 32)$"+";
		}
	}

	if (TextHeight != 0)
		TextHeight += 2;

	WinLeft = Root.MouseX;
	WinTop = Root.MouseY + (20/Root.GUIScale);
	WinWidth = (T.USize * Ratio) + Bevel.X + Bevel.W;
	WinHeight = (T.VSize * Ratio) + Bevel.Y + Bevel.H + TextHeight;
}

function Region GetBevelSize() {
	local float S;

	if ( Root.GUIScale > 1 )
		S = float(int(Root.GUIScale)) / Root.GUIScale;
	else
		S = 1;

	return NewRegion(
		LookAndFeel.BevelUpL.W * S,
		LookAndFeel.BevelUpT.H * S,
		LookAndFeel.BevelUpR.W * S,
		LookAndFeel.BevelUpB.H * S
	);
}

function Paint(Canvas C, float MouseX, float MouseY) {
	local Region Bevel;
	local float TextW, TextH;

	super.Paint(C, MouseX, MouseY);

	Bevel = GetBevelSize();
	DrawUpBevel(C, 0, 0, WinWidth, WinHeight, GetLookAndFeelTexture());
	
	if (Screenshot != none)
		DrawStretchedTexture(C,
			/*X*/Bevel.X,
			/*Y*/Bevel.Y + TextHeight,
			/*W*/WinWidth - Bevel.X - Bevel.W,
			/*H*/WinHeight - Bevel.Y - Bevel.H - TextHeight,
			Screenshot
		);

	if (PlayersText != "") {
		C.DrawColor = TextColor;
		TextSize(C, PlayersText, TextW, TextH);
		ClipText(C, (WinWidth - TextW - 4) / 2, 2, PlayersText);
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	}
}

defaultproperties {
	TextColor=(R=0,G=0,B=0,A=255)
	TextPlayerCount="Players:"

	bAlwaysOnTop=True
	bTransient=True
	bLeaveOnScreen=True
}
