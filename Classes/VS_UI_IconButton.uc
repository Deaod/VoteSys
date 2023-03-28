class VS_UI_IconButton extends UWindowSmallButton;

var Texture Icon;

function Paint(Canvas C, float X, float Y) {
	local float ImgScale;
	local float ImgX, ImgY;
	local float ImgW, ImgH;

	ImgScale = FMin(WinWidth/Icon.USize, WinHeight/Icon.VSize);
	ImgW = Icon.USize * ImgScale - 2;
	ImgH = Icon.VSize * ImgScale - 2;
	ImgX = (WinWidth - ImgW) / 2;
	ImgY = (WinHeight - ImgH) / 2;
	if (bMouseDown) {
		ImgX += 1;
		ImgY += 1;
	}

	LookAndFeel.Button_DrawSmallButton(Self, C);
	C.Style = 2;
	C.DrawColor = TextColor;
	DrawStretchedTexture(C, ImgX, ImgY, ImgW, ImgH, Icon);
}
