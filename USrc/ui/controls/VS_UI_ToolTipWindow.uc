class VS_UI_ToolTipWindow extends UWindowWindow;

var private string ToolTipText;
var float MaxWidth;
var color ToolTipBackgroundColor;
var color ToolTipBorderColor;
var color ToolTipTextColor;

const Ellipsis = "...";

function SetText(string T) {
	ToolTipText = T;
}

function string CutDownText(Canvas C, string Text, float MaxW) {
	local float W,H;
	local int F, L, M;
	local string T;

	F = 0;
	L = Len(Text);

	while (F <= L) {
		M = F + ((L - F) / 2);
		T = Left(Text, M)$Ellipsis;
		TextSize(C, T, W, H);
		if (W > MaxW) {
			L = (M - 1);
		} else if (W < MaxW) {
			TextSize(C, Left(Text, M + 1)$Ellipsis, W, H);
			if (W >= MaxW)
				return T;
			F = (M + 1);
		} else {
			return T;
		}
	}

	return Left(Text, L)$Ellipsis;
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	local float W,H;

	super.BeforePaint(C, MouseX, MouseY);

	TextSize(C, ToolTipText, W, H);

	WinLeft = Root.MouseX;
	WinTop = Root.MouseY + (20/Root.GUIScale);
	WinHeight = H + 4;
	WinWidth = Min(W, MaxWidth) + 4;

	if (W > MaxWidth) {
		ToolTipText = CutDownText(C, ToolTipText, MaxWidth);
	}
}

function Paint(Canvas C, float MouseX, float MouseY) {
	local color PrevColor;

	super.Paint(C, MouseX, MouseY);
	
	PrevColor = C.DrawColor;

	C.DrawColor = ToolTipBorderColor;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'WhiteTexture');
	C.DrawColor = ToolTipBackgroundColor;
	DrawStretchedTexture(C, 1, 1, WinWidth - 2, WinHeight - 2, Texture'WhiteTexture');
	C.DrawColor = ToolTipTextColor;
	ClipText(C, 2, 2, ToolTipText);

	C.DrawColor = PrevColor;
}

function bool CheckMousePassThrough(float X, float Y) {
	return true;
}


defaultproperties {
	MaxWidth=400.0

	ToolTipBackgroundColor=(R=255,G=255,B=204,A=255)
	ToolTipBorderColor=(R=0,G=0,B=0,A=255)
	ToolTipTextColor=(R=0,G=0,B=0,A=255)

	bAlwaysOnTop=True
	bTransient=True
	bLeaveOnScreen=True
}
