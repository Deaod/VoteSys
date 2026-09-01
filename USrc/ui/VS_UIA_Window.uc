class VS_UIA_Window extends UWindowFramedWindow;

function Created() {
	super.Created();

	WinWidth = 360;
	WinHeight = 240;
}

function Close(optional bool bByParent) {
	super.Close(bByParent);

	if ((Root.Console.IsInState('UWindow') || int(Root.Console.GetPropertyText("zzMyState")) == 1) &&
		(Root.Console.bShowConsole == false)
	) {
		if (Root.ActiveWindow == none ||
			Root.ActiveWindow == UMenuRootWindow(Root).StatusBar ||
			Root.ActiveWindow == UMenuRootWindow(Root).MenuBar ||
			(Root.ActiveWindow.Class.Name == 'AutoRecorder' && Root.ActiveWindow.Class.Outer.Name == 'udemo')
		) {
			Root.Console.CloseUWindow();
		}
	}

}

defaultproperties
{
	ClientClass=class'VS_UIA_ClientWindow'
	WindowTitle="About VoteSys"
	bStatusBar=False
}
