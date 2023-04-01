class VS_UI_ClientSettingsPage extends UWindowPageWindow;

var UWindowSmallCloseButton CloseButton;

function Created() {
	super.Created();

	CloseButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', 350, 334, 32, 12));
}

