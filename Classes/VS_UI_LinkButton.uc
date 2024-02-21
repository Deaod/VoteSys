class VS_UI_LinkButton extends UWindowSmallButton;

var string LinkURL;

function Click(float X, float Y) {
	GetPlayerOwner().ConsoleCommand("start"@LinkURL);
}

