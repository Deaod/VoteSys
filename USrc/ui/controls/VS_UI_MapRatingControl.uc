class VS_UI_MapRatingControl extends UWindowDialogControl
	imports(VS_Util_Logging);

var VS_UI_ThemeBase Theme;

var bool bDisabled;
var float StarSpacing;
var Texture StarEmpty;
var Texture StarFilled;

var int Rating;

var transient float TextEndX;
var transient float TextWidth;
var transient Texture Stars[5];

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	local float W, H;
	local int I;

	super.BeforePaint(C, MouseX, MouseY);

	TextEndX = WinWidth - 5 * (WinHeight + StarSpacing);

	if (Text != "") {
		TextSize(C, Text, W, H);
		TextWidth = W;
		TextY = (WinHeight - H);
	}

	if (bDisabled == false && MouseIsOver() && MouseX >= TextEndX) {
		Rating = int((MouseX - TextEndX) / (WinHeight + StarSpacing)) + 1;
	}

	for (I = 0; I < Rating; I++) {
		Stars[I] = StarFilled;
	}
	while(I < arraycount(Stars)) {
		Stars[I] = StarEmpty;
		I++;
	}
}

function Paint( Canvas C, float MouseX, float MouseY) {
	local float X;

	C.Style = 2;
	C.Font = Root.Fonts[0];
	Theme.DrawBox(C, self, 0, 0, WinWidth, WinHeight);

	if (bDisabled) {
		C.DrawColor = Theme.InactiveFG;
	} else {
		C.DrawColor = Theme.Foreground;
	}

	if (Text != "") {
		ClipText(C, TextEndX - TextWidth, TextY - 1, Text, true);
	}

	X = TextEndX;
	X += StarSpacing / 2.0;
	DrawStretchedTexture(C, X, 0, WinHeight, WinHeight, Stars[0]);
	X += WinHeight + StarSpacing;
	DrawStretchedTexture(C, X, 0, WinHeight, WinHeight, Stars[1]);
	X += WinHeight + StarSpacing;
	DrawStretchedTexture(C, X, 0, WinHeight, WinHeight, Stars[2]);
	X += WinHeight + StarSpacing;
	DrawStretchedTexture(C, X, 0, WinHeight, WinHeight, Stars[3]);
	X += WinHeight + StarSpacing;
	DrawStretchedTexture(C, X, 0, WinHeight, WinHeight, Stars[4]);

	C.DrawColor = Theme.Background;
}

function Click(float MouseX, float MouseY) {
	if (bDisabled)
		return;
		
	TextEndX = WinWidth - 5*(WinHeight+StarSpacing);
	if (MouseX >= TextEndX) {
		Rating = int((MouseX - TextEndX) / (WinHeight + StarSpacing)) + 1;
		Notify(DE_Click);
	}
}

defaultproperties {
	StarSpacing=4
	StarEmpty=Texture'StarEmpty'
	StarFilled=Texture'StarFilled'
}
