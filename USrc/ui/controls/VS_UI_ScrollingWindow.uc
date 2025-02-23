class VS_UI_ScrollingWindow extends UWindowWindow
	imports(Console);

var VS_UI_ScrollbarV VerSB;
var float OldVerSBPos;

function Created() {
	SetAcceptsFocus();
	
	VerSB = VS_UI_ScrollbarV(CreateWindow(class'VS_UI_ScrollbarV', WinWidth-12, 0, 12, WinHeight));
	VerSB.bAlwaysOnTop = True;
}

function MoveChildren(float VertMove) {
	local UWindowWindow C;

	for (C = FirstChildWindow; C != none; C = C.NextSiblingWindow)
		if (C != VerSB)
			C.WinTop += VertMove;
}

function BeforePaint(Canvas C, float X, float Y) {
	local UWindowWindow Ch;
	local float MaxVerPos;
	
	super.BeforePaint(C, X, Y);

	MaxVerPos = 0;
	for (Ch = FirstChildWindow; Ch != none; Ch = Ch.NextSiblingWindow)
		if (Ch != VerSB) {
			Ch.WinTop += OldVerSBPos;
			MaxVerPos = FMax(MaxVerPos, Ch.WinTop + Ch.WinHeight);
		}

	VerSB.SetRange(0, MaxVerPos, WinHeight, 20);
}

function Paint(Canvas C, float X, float Y) {
	super.Paint(C, X, Y);

	OldVerSBPos = VerSB.Pos;
	MoveChildren(-OldVerSBPos);
}

function KeyUp(int Key, float X, float Y) {
	// pre-469 mouse scrolling
	if (Key == EInputKey.IK_MouseWheelUp) {
		VerSB.Scroll(-VerSB.ScrollAmount);
	} else if (Key == EInputKey.IK_MouseWheelDown) {
		VerSB.Scroll(VerSB.ScrollAmount);
	}
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) {
	// 469+ mouse scrolling
	switch(Msg) {
		case WM_MouseWheelDown:
			MessageClients(Msg, C, X, Y, Key);
			break;
		case WM_MouseWheelUp:
			if (!MessageClients(Msg, C, X, Y, Key))
				VerSB.Scroll(float(Key) * VerSB.ScrollAmount);
			break;
		default:
			super.WindowEvent(Msg, C, X, Y, Key);
			break;
	}
}
