class VS_UI_ArrayEditButton extends UWindowSmallButton;

var float TextW;
var VS_UI_ArrayEditControl Owner;

function Created() {
	Super.Created();

	SetText(".");
	SetFont(F_Large);
}

function Click(float X, float Y) {
	Owner.LaunchEditWindow();
}

function BeforePaint(Canvas C, float X, float Y) {
	local float H;

	C.Font = Root.Fonts[Font];
	
	TextSize(C, RemoveAmpersand(Text), TextW, H);

	TextX = (WinWidth-TextW)/2;
	TextY = (WinHeight-H)/2;

	if (bMouseDown) {
		TextX += 1;
		TextY += 1;
	}

	TextY -= 4;
}

function Paint(Canvas C, float X, float Y) {
	local Texture Tex;
	local Region R;

	LookAndFeel.Button_DrawSmallButton(Self, C);

	C.Font = Root.Fonts[Font];

	Tex = GetButtonTexture2();
	if (Tex != None) {
		if (bUseRegion) {
			R = GetButtonRegion2();
			DrawStretchedTextureSegment(C, ImageX, ImageY, R.W*RegionScale, R.H*RegionScale, R.X, R.Y, R.W, R.H, Tex);
		} else if ( bStretched ) {
			DrawStretchedTexture(C, ImageX, ImageY, WinWidth, WinHeight, Tex);
		} else {
			DrawClippedTexture(C, ImageX, ImageY, Tex);
		}
	}

	if (Text != "") {
		C.DrawColor = TextColor;
		ClipText(C, TextX - (TextW * 0.6), TextY, Text, True);
		ClipText(C, TextX,                 TextY, Text, True);
		ClipText(C, TextX + (TextW * 0.6), TextY, Text, True);
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	}
}

// copy from 469 with different name to preserve compatibility
function Texture GetButtonTexture2()
{
	if      ( bDisabled )     return DisabledTexture;
	else if ( bMouseDown )    return DownTexture;
	else if ( MouseIsOver() ) return OverTexture;
	else                      return UpTexture;
}

// copy from 469 with different name to preserve compatibility
function Region GetButtonRegion2()
{
	if      ( bDisabled )     return DisabledRegion;
	else if ( bMouseDown )    return DownRegion;
	else if ( MouseIsOver() ) return OverRegion;
	else                      return UpRegion;
}
