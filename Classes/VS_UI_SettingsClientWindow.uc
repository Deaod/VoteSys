class VS_UI_SettingsClientWindow extends UWindowPageControl;

var VS_PlayerChannel Channel;

var VS_UI_ClientSettingsPage ClientSettingsPage;
var VS_UI_ServerSettingsPage ServerSettingsPage;

function Created() {
	super.Created();

	ClientSettingsPage = VS_UI_ClientSettingsPage(AddPage("Client", class'VS_UI_ClientSettingsPage').Page);
}

function BeforePaint(Canvas C, float X, float Y) {
	local PlayerPawn O;
	local bool bIsAdmin;

	O = GetPlayerOwner();
	bIsAdmin = O != none && O.PlayerReplicationInfo != none && O.PlayerReplicationInfo.bAdmin;

	if (bIsAdmin && ServerSettingsPage == none) {
		ServerSettingsPage = VS_UI_ServerSettingsPage(AddPage("Server", class'VS_UI_ServerSettingsPage').Page);
	} else if (bIsAdmin == false && ServerSettingsPage != none) {
		DeletePage(ServerSettingsPage.OwnerTab);
		ServerSettingsPage = none;
	}

	super.BeforePaint(C, X, Y);
}

function LoadSettings(VS_PlayerChannel C) {
	Channel = C;

	ClientSettingsPage.LoadSettings(Channel);

	if (ServerSettingsPage != none)
		ServerSettingsPage.LoadSettings(Channel);
}
