class VS_UIS_ClientWindow extends UWindowPageControl;

var VS_PlayerChannel Channel;

var localized string PageClientSettingsName;
var VS_UIS_PageClient PageClientSettings;
var localized string PageAdminVotingName;
var VS_UIS_PageAdminVoting PageAdminVoting;
var localized string PageAdminUIName;
var VS_UIS_PageAdminUI PageAdminUI;
var localized string PageAdminSetupName;
var VS_UIS_PageAdminSetup PageAdminSetup;
var localized string PageAdminPresetsName;
var VS_UIS_PageAdminPresets PageAdminPresets;
var localized string PageAdminMapListsName;
var VS_UIS_PageAdminMapLists PageAdminMapLists;

function Created() {
	super.Created();

	PageClientSettings = VS_UIS_PageClient(AddPage(PageClientSettingsName, class'VS_UIS_PageClient').Page);
}

function BeforePaint(Canvas C, float X, float Y) {
	local PlayerPawn O;
	local bool bIsAdmin;

	O = GetPlayerOwner();
	bIsAdmin = O != none && O.PlayerReplicationInfo != none && O.PlayerReplicationInfo.bAdmin;

	if (bIsAdmin) {
		if (PageAdminVoting == none) {
			PageAdminVoting = VS_UIS_PageAdminVoting(AddPage(PageAdminVotingName, class'VS_UIS_PageAdminVoting').Page);
			PageAdminVoting.LoadSettings(Channel);
		}
		if (PageAdminUI == none) {
			PageAdminUI = VS_UIS_PageAdminUI(AddPage(PageAdminUIName, class'VS_UIS_PageAdminUI').Page);
			PageAdminUI.LoadSettings(Channel);
		}
		if (PageAdminSetup == none) {
			PageAdminSetup = VS_UIS_PageAdminSetup(AddPage(PageAdminSetupName, class'VS_UIS_PageAdminSetup').Page);
			PageAdminSetup.LoadSettings(Channel);
		}
		if (PageAdminPresets == none) {
			PageAdminPresets = VS_UIS_PageAdminPresets(AddPage(PageAdminPresetsName, class'VS_UIS_PageAdminPresets').Page);
			PageAdminPresets.LoadSettings(Channel);
		}
		if (PageAdminMapLists == none) {
			PageAdminMapLists = VS_UIS_PageAdminMapLists(AddPage(PageAdminMapListsName, class'VS_UIS_PageAdminMapLists').Page);
			PageAdminMapLists.LoadSettings(Channel);
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
		if (PageAdminPresets != none) {
			DeletePage(PageAdminPresets.OwnerTab);
			PageAdminPresets = none;
		}
		if (PageAdminMapLists != none) {
			DeletePage(PageAdminMapLists.OwnerTab);
			PageAdminMapLists = none;
		}
	}

	super.BeforePaint(C, X, Y);
}

function LoadSettings(VS_PlayerChannel C) {
	Channel = C;

	PageClientSettings.LoadSettings(Channel);

	if (PageAdminVoting != none)
		PageAdminVoting.LoadSettings(Channel);
	if (PageAdminUI != none)
		PageAdminUI.LoadSettings(Channel);
	if (PageAdminSetup != none)
		PageAdminSetup.LoadSettings(Channel);
	if (PageAdminPresets != none)
		PageAdminPresets.LoadSettings(Channel);
	if (PageAdminMapLists != none)
		PageAdminMapLists.LoadSettings(Channel);
}

defaultproperties {
	PageClientSettingsName="Client"
	PageAdminVotingName="[A] Voting"
	PageAdminUIName="[A] UI"
	PageAdminSetupName="[A] Setup"
	PageAdminPresetsName="[A] Presets"
	PageAdminMapListsName="[A] Map Lists"
}
