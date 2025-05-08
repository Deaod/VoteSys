class VS_UI_Logo extends UWindowDialogControl
	imports(VS_Util_Logging);

var Texture LogoTexture;
var Region LogoRegion;
var Region DrawRegionConfig;
var Region DrawRegion;

var UWindowButton DismissButton;

const DE_VoteSys_LogoDismiss = 129;

function Created() {
	super.Created();

	DismissButton = VS_UI_LogoDismissButton(CreateWindow(class'VS_UI_LogoDismissButton', 0, 0, 0, 0));
}

function SetLogoTexture(string TextureRef) {
	if (TextureRef == "")
		return;
		
	LogoTexture = Texture(DynamicLoadObject(TextureRef, class'Texture', true));
	if (LogoTexture == none) {
		LogErr("Logo texture \""$TextureRef$"\" failed to load!");
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

function SetDrawRegion(int X, int Y, int W, int H) {
	DrawRegionConfig.X = X;
	DrawRegionConfig.Y = Y;
	DrawRegionConfig.W = W;
	DrawRegionConfig.H = H;
}

function BeforePaint(Canvas C, float X, float Y) {
	local float DrawScale;
	local UWindowButton CloseBox;

	if (DrawRegionConfig.X == 0 && DrawRegionConfig.Y == 0 && DrawRegionConfig.W == 0 && DrawRegionConfig.H == 0) {
		DrawRegion = NewRegion(0,0,WinWidth,WinHeight);
	} else {
		DrawRegion = DrawRegionConfig;
	}

	DrawScale = FMin(float(DrawRegion.W) / LogoRegion.W, float(DrawRegion.H) / LogoRegion.H);

	DrawRegion.W = int(LogoRegion.W * DrawScale);
	DrawRegion.H = int(LogoRegion.H * DrawScale);
	DrawRegion.X = DrawRegionConfig.X + int(0.5 * (WinWidth - DrawRegion.W));
	DrawRegion.Y = DrawRegionConfig.Y + int(0.5 * (WinHeight - DrawRegion.H));

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
