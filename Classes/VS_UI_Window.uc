class VS_UI_Window extends UWindowFramedWindow;

var bool bPlaced;
var VS_Settings Settings;
var VS_PlayerChannel Channel;

function Created() {
	super.Created();

	if (WinLeft != -1.0 || WinTop != -1.0)
		bPlaced = true;

	WinWidth = 588;
	WinHeight = 400;
}

function BeforePaint(Canvas C, float X, float Y) {
	if (bPlaced == false) {
		WinLeft = FMax((C.SizeX - WinWidth) / 2.0, 0.0);
		WinTop = FMax((C.SizeY - WinHeight) / 2.0, 0.0);
		bPlaced = true;
	}

	super.BeforePaint(C, X, Y);

	if (WaitModal() && ModalWindow.IsA('UWindowMessageBox') && UWindowMessageBox(ModalWindow).bSetupSize == false) {
		ModalWindow.BeforePaint(C, X, Y);
		ModalWindow.WinLeft = FClamp(WinLeft+(WinWidth-ModalWindow.WinWidth)/2, 0, C.SizeX-ModalWindow.WinWidth);
		ModalWindow.WinTop = FClamp(WinTop+(WinHeight-ModalWindow.WinHeight)/2, 0, C.SizeY-ModalWindow.WinHeight);
	}
}

function Close(optional bool bByParent) {
	super.Close(bByParent);

	if (Root.Console.IsInState('UWindow') && Root.Console.bShowConsole == false)
		Root.Console.CloseUWindow();

	Settings.MenuX = WinLeft;
	Settings.MenuY = WinTop;
	Settings.SaveConfig();
}

function AddPreset(VS_Preset P) {
	local string Cat;

	Cat = P.Category;
	if (Cat == "")
		Cat = "Default";

	if (VS_UI_TabControl(ClientArea).GetPage(Cat) == none) {
		VS_UI_PresetCategoryPage(VS_UI_TabControl(ClientArea).AddPage(Cat, class'VS_UI_PresetCategoryPage').Page).Channel = Channel;
	}
	VS_UI_PresetCategoryPage(VS_UI_TabControl(ClientArea).GetPage(Cat).Page).AddPreset(P);
}

function FocusPreset(string Ref) {
	local string Category, PresetName;
	local int SepPos;
	local UWindowPageControlPage Page;

	SepPos = InStr(Ref, "/");
	Category = Left(Ref, SepPos);
	if (Category == "")
		Category = "Default";
	Presetname = Mid(Ref, SepPos+1);

	Page = VS_UI_TabControl(ClientArea).GetPage(Category);
	if (Page != none)
		VS_UI_TabControl(ClientArea).GotoTab(Page);
	if (PresetName != "" && Page.Page != none)
		VS_UI_PresetCategoryPage(VS_UI_TabControl(ClientArea).GetPage(Category).Page).FocusPreset(PresetName);
}

defaultproperties
{
	ClientClass=class'VS_UI_TabControl'
	WindowTitle="VoteSys Menu"
	bStatusBar=False
}
