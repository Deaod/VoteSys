class VS_UI_Logo extends UWindowDialogControl;

var Texture LogoTexture;
var Region LogoRegion;
var Region DrawRegion;

var UWindowButton DismissButton;

const DE_VoteSys_LogoDismiss = 129;

function Created() {
	DismissButton = VS_UI_LogoDismissButton(CreateWindow(class'VS_UI_LogoDismissButton', 0, 0, 0, 0));
}

function SetLogoTexture(string TextureRef) {
	LogoTexture = Texture(DynamicLoadObject(TextureRef, class'Texture', true));
	if (LogoTexture == none) {
		Log("Logo texture \""$TextureRef$"\" failed to load!", 'VoteSys');
		LogoRegion = NewRegion(0,0,0,0);
	} else  {
		LogoRegion.X = 0;
		LogoRegion.Y = 0;
		LogoRegion.W = LogoTexture.USize;
		LogoRegion.H = LogoTexture.VSize;
	}
}

function SetLogoRegion(int X, int Y, int W, int H) {
	LogoRegion.X = X;
	LogoRegion.Y = Y;
	LogoRegion.W = W;
	LogoRegion.H = H;
}

function BeforePaint(Canvas C, float X, float Y) {
	local float DrawScale;
	local UWindowButton CloseBox;
	DrawScale = FMin(WinWidth / LogoRegion.W, WinHeight / LogoRegion.H);

	DrawRegion.W = int(LogoRegion.W * DrawScale);
	DrawRegion.H = int(LogoRegion.H * DrawScale);
	DrawRegion.X = int(0.5 * (WinWidth - DrawRegion.W));
	DrawRegion.Y = int(0.5 * (WinHeight - DrawRegion.H));

	CloseBox = UWindowFramedWindow(GetParent(class'UWindowFramedWindow')).CloseBox;
	DismissButton.SetSize(CloseBox.WinWidth, CloseBox.WinHeight);
	DismissButton.WinLeft = WinWidth - DismissButton.WinWidth;
	DismissButton.WinTop = 0;
	DismissButton.bUseRegion = CloseBox.bUseRegion;
	DismissButton.UpTexture = CloseBox.UpTexture;
	DismissButton.DownTexture = CloseBox.DownTexture;
	DismissButton.OverTexture = CloseBox.OverTexture;
	DismissButton.DisabledTexture = CloseBox.DisabledTexture;
	DismissButton.UpRegion = CloseBox.UpRegion;
	DismissButton.DownRegion = CloseBox.DownRegion;
	DismissButton.OverRegion = CloseBox.OverRegion;
	DismissButton.DisabledRegion = CloseBox.DisabledRegion;
	DismissButton.RegionScale = CloseBox.RegionScale;
}

function Paint(Canvas C, float X, float Y) {
	if (LogoTexture != none) {
		DrawStretchedTextureSegment(
			C,
			DrawRegion.X, DrawRegion.Y, DrawRegion.W, DrawRegion.H,
			LogoRegion.X, LogoRegion.Y, LogoRegion.W, LogoRegion.H,
			LogoTexture
		);
	}
}

function Dismiss() {
	Notify(DE_VoteSys_LogoDismiss);
}
