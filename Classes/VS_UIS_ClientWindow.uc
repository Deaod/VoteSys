class VS_UIS_ClientWindow extends UWindowPageControl;

var VS_PlayerChannel Channel;

var VS_UIS_PageClient ClientSettingsPage;
var VS_UIS_PageAdminVoting ServerSettingsPage;

function Created() {
	super.Created();

	ClientSettingsPage = VS_UIS_PageClient(AddPage("Client", class'VS_UIS_PageClient').Page);
}

function BeforePaint(Canvas C, float X, float Y) {
	local PlayerPawn O;
	local bool bIsAdmin;

	O = GetPlayerOwner();
	bIsAdmin = O != none && O.PlayerReplicationInfo != none && O.PlayerReplicationInfo.bAdmin;

	if (bIsAdmin && ServerSettingsPage == none) {
		ServerSettingsPage = VS_UIS_PageAdminVoting(AddPage("[A] Server", class'VS_UIS_PageAdminVoting').Page);
		ServerSettingsPage.LoadSettings(Channel);
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
