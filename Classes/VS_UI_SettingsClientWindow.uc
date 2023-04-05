class VS_UI_SettingsClientWindow extends UWindowPageControl;

var VS_ClientSettings ClientSettings;
var VS_UI_ClientSettingsPage ClientSettingsPage;

function Created() {
	super.Created();

	ClientSettingsPage = VS_UI_ClientSettingsPage(AddPage("Client", class'VS_UI_ClientSettingsPage').Page);
}

function LoadSettings(VS_ClientSettings CS) {
	ClientSettings = CS;
	ClientSettingsPage.LoadSettings(ClientSettings);
}
