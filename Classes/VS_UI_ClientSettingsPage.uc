class VS_UI_ClientSettingsPage extends UWindowPageWindow;

var VS_ClientSettings Settings;

var UWindowSmallCloseButton CloseButton;

function Created() {
	super.Created();

	CloseButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', 350, 334, 32, 12));
}

function LoadSettings(VS_ClientSettings S) {
	Settings = S;
}
