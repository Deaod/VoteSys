class VS_UI_ScrollbarV extends UWindowVScrollBar
	imports(Console);

function KeyUp(int Key, float X, float Y) {
	// pre-469 mouse scrolling
	if (Key == EInputKey.IK_MouseWheelUp) {
		Scroll(-ScrollAmount);
	} else if (Key == EInputKey.IK_MouseWheelDown) {
		Scroll(ScrollAmount);
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
				Scroll(float(Key) * ScrollAmount);
			break;
		default:
			super.WindowEvent(Msg, C, X, Y, Key);
			break;
	}
}
