class VS_UIV_Window extends UWindowFramedWindow;

var bool bPlaced;
var VS_ClientSettings Settings;
var VS_PlayerChannel Channel;

function Created() {
	super.Created();

	if (WinLeft != -1.0 || WinTop != -1.0)
		bPlaced = true;

	WinWidth = 614;
	WinHeight = 400;
	WindowTitle = default.WindowTitle@"-"@class'VersionInfo'.default.PackageVersion;
}

function LoadSettings(VS_ClientSettings CS) {
	Settings = CS;
	VS_UIV_ClientWindow(ClientArea).LoadSettings(CS);
}

function BeforePaint(Canvas C, float X, float Y) {
	if (bPlaced == false) {
		WinLeft = FMax((C.SizeX/Root.GUIScale - WinWidth) / 2.0, 0.0);
		WinTop = FMax((C.SizeY/Root.GUIScale - WinHeight) / 2.0, 0.0);
		bPlaced = true;
	}

	super.BeforePaint(C, X, Y);

	if (WaitModal() && ModalWindow.IsA('UWindowMessageBox') && UWindowMessageBox(ModalWindow).bSetupSize == false) {
		ModalWindow.BeforePaint(C, X, Y);
		ModalWindow.WinLeft = FClamp(WinLeft+(WinWidth-ModalWindow.WinWidth)/2.0, 0, C.SizeX-ModalWindow.WinWidth);
		ModalWindow.WinTop = FClamp(WinTop+(WinHeight-ModalWindow.WinHeight)/2.0, 0, C.SizeY-ModalWindow.WinHeight);
	}
}

function Close(optional bool bByParent) {
	super.Close(bByParent);

	if ((Root.Console.IsInState('UWindow') || int(Root.Console.GetPropertyText("zzMyState")) == 1) &&
		(Root.Console.bShowConsole == false)
	) {
		if (Root.ActiveWindow == none ||
			Root.ActiveWindow == UMenuRootWindow(Root).StatusBar ||
			Root.ActiveWindow == UMenuRootWindow(Root).MenuBar
		) {
			Root.Console.CloseUWindow();
		}
	}

	Settings.MenuX = WinLeft;
	Settings.MenuY = WinTop;
	Settings.SaveConfig();
}

function AddPreset(VS_Preset P) {
	VS_UIV_ClientWindow(ClientArea).Channel = Channel;
	VS_UIV_ClientWindow(ClientArea).AddPreset(P);
}

function FocusPreset(VS_Preset P) {
	VS_UIV_ClientWindow(ClientArea).FocusPreset(P);
}

function ConfigureLogo(string Tex, int TexX, int TexY, int TexW, int TexH, int DrawX, int DrawY, int DrawW, int DrawH) {
	VS_UIV_ClientWindow(ClientArea).ConfigureLogo(Tex, TexX, TexY, TexW, TexH, DrawX, DrawY, DrawW, DrawH);
}

function ConfigureLogoButton(int Index, string Label, string LinkURL) {
	VS_UIV_ClientWindow(ClientArea).ConfigureLogoButton(Index, Label, LinkURL);
}

function UpdateFavoritesEnd() {
	VS_UIV_ClientWindow(ClientArea).UpdateFavoritesEnd();
}

defaultproperties
{
	ClientClass=class'VS_UIV_ClientWindow'
	WindowTitle="VoteSys Menu"
	bStatusBar=False
}
