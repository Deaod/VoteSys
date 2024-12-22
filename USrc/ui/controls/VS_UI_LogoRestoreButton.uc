class VS_UI_LogoRestoreButton extends UWindowButton;

function Created() {
	super.Created();
	
	bUseRegion = true;
	UpRegion = NewRegion(4, 65, 11, 11);
	DownRegion = NewRegion(4, 54, 11, 11);
	OverRegion = UpRegion;
	DisabledRegion = UpRegion;
}

function BeforePaint(Canvas C, float X, float Y) {
	local Texture T;

	super.BeforePaint(C, X, Y);

	T = GetLookAndFeelTexture();
	UpTexture = T;
	DownTexture = T;
	OverTexture = T;
	DisabledTexture = T;

	SetSize(UpRegion.W, UpRegion.H);
}

defaultproperties{
	bUseRegion=True
	UpRegion=(X=4,Y=65,W=11,H=11)
	DownRegion=(X=4,Y=54,W=11,H=11)
	OverRegion=(X=4,Y=65,W=11,H=11)
	DisabledRegion=(X=4,Y=65,W=11,H=11)
}
