class VS_UI_LogoDismissButton extends UWindowButton;

function Click(float X, float Y) {
	VS_UI_Logo(ParentWindow).Dismiss();
}
