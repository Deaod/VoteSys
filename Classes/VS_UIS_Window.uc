class VS_UIS_Window extends UWindowFramedWindow;

var bool bPlaced;
var VS_ClientSettings Settings;
var VS_PlayerChannel Channel;

function Created() {
	super.Created();

	if (WinLeft != -1.0 || WinTop != -1.0)
		bPlaced = true;

	WinWidth = 400;
	WinHeight = 400;
}

function LoadSettings(VS_PlayerChannel C) {
	Channel = C;
	Settings = C.Settings;
	VS_UIS_ClientWindow(ClientArea).LoadSettings(C);
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

	if (Root.Console.IsInState('UWindow') && Root.Console.bShowConsole == false)
		if (Root.ActiveWindow == none ||
			Root.ActiveWindow == UMenuRootWindow(Root).StatusBar ||
			Root.ActiveWindow == UMenuRootWindow(Root).MenuBar
		) {
			Root.Console.CloseUWindow();
		}

	Settings.SettingsX = WinLeft;
	Settings.SettingsY = WinTop;
	Settings.SaveConfig();
}

defaultproperties
{
	ClientClass=class'VS_UIS_ClientWindow'
	WindowTitle="VoteSys Settings"
	bStatusBar=False
}
