class VS_UI_CategoryTabControl extends UWindowTabControl;

function Paint(Canvas C, float X, float Y) {
	
	super.Paint(C, X, Y);
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) {
	// 469+ mouse scrolling
	SetPropertyText("bHandledEvent", "True");
	switch(Msg) {
		case WM_MouseWheelDown:
			if (!MessageClients(Msg, C, X, Y, Key) && FindWindowUnder(X,Y) == TabArea) {
				if (Key > 0 && RightButton.bDisabled == false)
					TabArea.TabOffset++;
				else if (Key < 0 && LeftButton.bDisabled == false)
					TabArea.TabOffset--;
			}
			break;
		case WM_MouseWheelUp:
			MessageClients(Msg, C, X, Y, Key);
			break;
		default:
			super.WindowEvent(Msg, C, X, Y, Key);
			break;
	}
}


defaultproperties {
	ListClass=class'VS_UI_CategoryTabItem'
}
