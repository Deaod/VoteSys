class VS_UI_AboutButton extends UWindowButton;

#exec TEXTURE IMPORT Name=VoteSys_AboutButton File="Textures/AboutButton.bmp" MIPS=ON
#exec TEXTURE IMPORT Name=VoteSys_AboutButtonGold File="Textures/AboutButtonGold.bmp" MIPS=ON
#exec TEXTURE IMPORT Name=VoteSys_AboutButtonMetal File="Textures/AboutButtonMetal.bmp" MIPS=ON
#exec TEXTURE IMPORT Name=VoteSys_AboutButtonInactive File="Textures/AboutButtonInactive.bmp" MIPS=ON

function Texture SelectTexture() {
	if (IsActive() == false) {
		return Texture'VoteSys_AboutButtonInactive';
	} else if (LookAndFeel.IsA('UMenuBlueLookAndFeel')) {
		return Texture'VoteSys_AboutButton';
	} else if (LookAndFeel.IsA('UMenuMetalLookAndFeel')) {
		return Texture'VoteSys_AboutButtonMetal';
	} else if (LookAndFeel.IsA('UMenuGoldLookAndFeel')) {
		return Texture'VoteSys_AboutButtonGold';
	}
	return Texture'VoteSys_AboutButton';
}

function Created() {
	bNoKeyboard = true;
	super.Created();

	bUseRegion = true;
	UpRegion = NewRegion(128, 0, 88, 88);
	DownRegion = NewRegion(128, 88, 88, 88);
	OverRegion = NewRegion(128, 0, 88, 88);
	DisabledRegion = NewRegion(128, 0, 88, 88);
	RegionScale = WinWidth / 88.0;
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	local Texture T;
	
	T = SelectTexture();
	UpTexture = T;
	DownTexture = T;
	OverTexture = T;
	DisabledTexture = T;

	super.BeforePaint(C, MouseX, MouseY);
}

function Click(float X, float Y) {
	local VS_UIA_Window AboutWin;

	AboutWin = VS_UIA_Window(Root.CreateWindow(
		class'VS_UIA_Window',
		0,0, // Position set after Size
		0,0 // Size set internally
	));

	AboutWin.WinLeft = ParentWindow.WinLeft + (ParentWindow.WinWidth / 2.0) - (AboutWin.WinWidth / 2.0);
	AboutWin.WinTop = ParentWindow.WinTop + (ParentWindow.WinHeight / 2.0) - (AboutWin.WinHeight / 2.0);
	AboutWin.bLeaveOnScreen = true;
}

// No keyboard support
function KeyDown(int Key, float X, float Y) {}
