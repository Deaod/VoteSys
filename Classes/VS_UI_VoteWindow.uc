class VS_UI_VoteWindow extends UWindowFramedWindow;

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

	Settings.MenuX = WinLeft;
	Settings.MenuY = WinTop;
	Settings.SaveConfig();
}

function AddPreset(VS_Preset P) {
	VS_UI_VoteClientWindow(ClientArea).Channel = Channel;
	VS_UI_VoteClientWindow(ClientArea).AddPreset(P);
}

function FocusPreset(VS_Preset P) {
	VS_UI_VoteClientWindow(ClientArea).FocusPreset(P);
}

defaultproperties
{
	ClientClass=class'VS_UI_VoteClientWindow'
	WindowTitle="VoteSys Menu"
	bStatusBar=False
}
