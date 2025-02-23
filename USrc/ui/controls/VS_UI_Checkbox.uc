class VS_UI_Checkbox extends UWindowCheckbox;

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) {
	// 469+ mouse scrolling
	// scrolling should not activate this control
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
