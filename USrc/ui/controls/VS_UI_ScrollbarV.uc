class VS_UI_ScrollbarV extends UWindowVScrollBar;

function bool MouseWheelUp(float ScrollDelta)
{
	Super(UWindowDialogControl).MouseWheelUp(ScrollDelta);
	Scroll(ScrollDelta * ScrollAmount);
	return true;
}
