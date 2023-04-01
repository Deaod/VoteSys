class VS_UI_SettingsClientWindow extends UWindowPageControl;

function Created() {
	super.Created();

	AddPage("Client", class'VS_UI_ClientSettingsPage');
}

