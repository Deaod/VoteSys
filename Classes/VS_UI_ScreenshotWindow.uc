class VS_UI_ScreenshotWindow extends UWindowWindow;

var Texture Screenshot;

function Paint(Canvas C, float MouseX, float MouseY) {
	super.Paint(C, MouseX, MouseY);

	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Screenshot);
}

defaultproperties {
	bAlwaysOnTop=True
	bTransient=True
	bLeaveOnScreen=True
}
