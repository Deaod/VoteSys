class VS_UI_EditControl extends UWindowEditControl;

var VS_UI_ThemeBase Theme;
var bool bEmptyIsError;

function Created() {
	local VS_UI_EditBox EB;

	Super(UWindowDialogControl).Created();
	
	EB = VS_UI_EditBox(CreateWindow(class'VS_UI_EditBox', 0, 0, WinWidth, WinHeight)); 
	EB.NotifyOwner = Self;
	EB.bSelectOnFocus = True;
	EB.EmptyText = Text;
	EditBox = EB;

	EditBoxWidth = WinWidth;

	SetEditTextColor(LookAndFeel.EditBoxTextColor);
}

function SetEmptyText(string NewText) {
	VS_UI_EditBox(EditBox).EmptyText = NewText;
}

function SetNumericNegative(bool bEnable) {
	VS_UI_EditBox(EditBox).bNumericNegative = bEnable;
}

function Paint(Canvas C, float MouseX, float MouseY) {
	Theme.DrawBox(C, self, EditAreaDrawX, 0, EditBoxWidth, WinHeight);

	if(Text != "") {
		C.DrawColor = TextColor;
		ClipText(C, TextX, TextY, Text);
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	}

	super(UWindowDialogControl).Paint(C, MouseX, MouseY);
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	super.BeforePaint(C, MouseX, MouseY);
	EditBox.TextColor = Theme.Foreground;
	if (bEmptyIsError)
		VS_UI_EditBox(EditBox).EmptyTextColor = Theme.ErrorFG;
	else
		VS_UI_EditBox(EditBox).EmptyTextColor = Theme.InactiveFG;
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) {
	// 469+ mouse scrolling
	// scrolling should not activate this control
	SetPropertyText("bHandledEvent", "True");
	switch(Msg) {
		case WM_MouseWheelDown:
		case WM_MouseWheelUp:
			if (!MessageClients(Msg, C, X, Y, Key))
				SetPropertyText("bHandledEvent", "False");
			break;
		default:
			super.WindowEvent(Msg, C, X, Y, Key);
			break;
	}
}