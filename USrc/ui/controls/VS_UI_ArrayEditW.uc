class VS_UI_ArrayEditW extends UWindowFramedWindow;

var VS_UI_ArrayEditBase Owner;

function SetOwner(VS_UI_ArrayEditBase O) {
	local UWindowWindow P;

	Owner = O;
	VS_UI_ArrayEditCW(ClientArea).SetOwner(O);

	P = Owner.GetParent(class'UWindowFramedWindow');
	P.WindowToGlobal(int((P.WinWidth - WinWidth) / 2.0), int((P.WinHeight - WinHeight) / 2.0), WinLeft, WinTop);

	MinWinWidth = 150;
	MinWinHeight = 100;
}

function Close(optional bool bByParent) {
	Super.Close(bByParent);
	Owner.EditWindowClosed(Self);
}

function SetTheme(VS_UI_ThemeBase T) {
	VS_UI_ArrayEditCW(ClientArea).SetTheme(T);
}

function AddElement(string Text) {
	VS_UI_ArrayEditCW(ClientArea).AddElement(Text);
}

defaultproperties {
	ClientClass=class'VS_UI_ArrayEditCW'
	bStatusBar=False
	bSizable=True
	bLeaveOnScreen=True
}
