class VS_UIS_ClientWindow extends UWindowPageControl;

var VS_PlayerChannel Channel;

var VS_UIS_PageClient ClientSettingsPage;
var VS_UIS_PageAdminVoting PageAdminVoting;
var VS_UIS_PageAdminUI PageAdminUI;
var VS_UIS_PageAdminSetup PageAdminSetup;

function Created() {
	super.Created();

	ClientSettingsPage = VS_UIS_PageClient(AddPage("Client", class'VS_UIS_PageClient').Page);
}

function BeforePaint(Canvas C, float X, float Y) {
	local PlayerPawn O;
	local bool bIsAdmin;

	O = GetPlayerOwner();
	bIsAdmin = O != none && O.PlayerReplicationInfo != none && O.PlayerReplicationInfo.bAdmin;

	if (bIsAdmin) {
		if (PageAdminVoting == none) {
			PageAdminVoting = VS_UIS_PageAdminVoting(AddPage("[A] Voting", class'VS_UIS_PageAdminVoting').Page);
			PageAdminVoting.LoadSettings(Channel);
		}
		if (PageAdminUI == none) {
			PageAdminUI = VS_UIS_PageAdminUI(AddPage("[A] UI", class'VS_UIS_PageAdminUI').Page);
			PageAdminUI.LoadSettings(Channel);
		}
		if (PageAdminSetup == none) {
			PageAdminSetup = VS_UIS_PageAdminSetup(AddPage("[A] Setup", class'VS_UIS_PageAdminSetup').Page);
			PageAdminSetup.LoadSettings(Channel);
		}
	} else {
		if (PageAdminVoting != none) {
			DeletePage(PageAdminVoting.OwnerTab);
			PageAdminVoting = none;
		}
		if (PageAdminUI != none) {
			DeletePage(PageAdminUI.OwnerTab);
			PageAdminUI = none;
		}
		if (PageAdminSetup != none) {
			DeletePage(PageAdminSetup.OwnerTab);
			PageAdminSetup = none;
		}
	}

	super.BeforePaint(C, X, Y);
}

function LoadSettings(VS_PlayerChannel C) {
	Channel = C;

	ClientSettingsPage.LoadSettings(Channel);

	if (PageAdminVoting != none)
		PageAdminVoting.LoadSettings(Channel);
	if (PageAdminUI != none)
		PageAdminUI.LoadSettings(Channel);
	if (PageAdminSetup != none)
		PageAdminSetup.LoadSettings(Channel);
}
