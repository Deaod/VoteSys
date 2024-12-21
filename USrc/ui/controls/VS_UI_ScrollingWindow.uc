class VS_UI_ScrollingWindow extends UWindowWindow;

var VS_UI_ScrollbarV VerSB;
var float OldVerSBPos;

function Created() {
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

function bool MouseWheelDown(float ScrollDelta) {
	Super.MouseWheelDown(ScrollDelta);
	return true;
}

function bool MouseWheelUp(float ScrollDelta) {
	Super.MouseWheelUp(ScrollDelta);
	VerSB.Scroll(ScrollDelta*VerSB.ScrollAmount);
	return true;
}
