class VS_UI_CategoryTabControl extends UWindowTabControl;

function Paint(Canvas C, float X, float Y) {
	
	super.Paint(C, X, Y);
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) {
	// 469+ mouse scrolling
	// scrolling should not activate this control
	SetPropertyText("bHandledEvent", "True");
	switch(Msg) {
		case WM_MouseWheelDown:
			if (Key > 0 && RightButton.bDisabled == false)
				TabArea.TabOffset++;
			else if (Key < 0 && LeftButton.bDisabled == false)
				TabArea.TabOffset--;
			break;
		case WM_MouseWheelUp:
			break;
		default:
			super.WindowEvent(Msg, C, X, Y, Key);
			break;
	}
}


defaultproperties {
	ListClass=class'VS_UI_CategoryTabItem'
}
