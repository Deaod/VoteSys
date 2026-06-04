class VS_UIA_Window extends UWindowFramedWindow;

function Created() {
	super.Created();

	WinWidth = 360;
	WinHeight = 240;
}

defaultproperties
{
	ClientClass=class'VS_UIA_ClientWindow'
	WindowTitle="About VoteSys"
	bStatusBar=False
}
