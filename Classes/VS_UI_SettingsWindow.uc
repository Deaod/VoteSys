class VS_UI_SettingsWindow extends UWindowFramedWindow;

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

function LoadSettings(VS_ClientSettings CS) {
	Settings = CS;
	VS_UI_SettingsClientWindow(ClientArea).LoadSettings(CS);
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
		Root.Console.CloseUWindow();

	Settings.SettingsX = WinLeft;
	Settings.SettingsY = WinTop;
	Settings.SaveConfig();
}

defaultproperties
{
	ClientClass=class'VS_UI_SettingsClientWindow'
	WindowTitle="VoteSys Settings"
	bStatusBar=False
}
