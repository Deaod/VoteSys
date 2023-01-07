class VS_UI_ScreenshotWindow extends UWindowWindow;

var Texture Screenshot;

function Paint(Canvas C, float MouseX, float MouseY) {
	local float BevelWL, BevelWR, BevelHT, BevelHB;
	local float S;

	super.Paint(C, MouseX, MouseY);

	if ( Root.GUIScale > 1 )
		S = float(int(Root.GUIScale)) / Root.GUIScale;
	else
		S = 1;

	BevelWL = LookAndFeel.BevelUpL.W * S;
	BevelWR = LookAndFeel.BevelUpR.W * S;
	BevelHT = LookAndFeel.BevelUpT.H * S;
	BevelHB = LookAndFeel.BevelUpB.H * S;
	DrawUpBevel(C, 0, 0, WinWidth, WinHeight, GetLookAndFeelTexture());
	DrawStretchedTexture(C,
		/*X*/BevelWL,
		/*Y*/BevelHT,
		/*W*/WinWidth - BevelWL - BevelWR,
		/*H*/WinHeight - BevelHT - BevelHB,
		Screenshot
	);
}

defaultproperties {
	bAlwaysOnTop=True
	bTransient=True
	bLeaveOnScreen=True
}
