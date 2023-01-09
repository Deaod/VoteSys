class VS_UI_PlayerMenu extends UWindowRightClickMenu;

var PlayerReplicationInfo PRI;

var UWindowPullDownMenuItem PlayerId;
var localized string PlayerIdText;

var UWindowPullDownMenuItem PlayerKick;
var localized string PlayerKickText;

var UWindowPullDownMenuItem PlayerBan;
var localized string PlayerBanText;

function Created() {
	super.Created();

	PlayerId = AddMenuItem("ID", none);
	PlayerId.bDisabled = true;
	AddMenuItem("-", none);
	PlayerKick = AddMenuItem("Kick", none);
	PlayerBan = AddMenuItem("Ban", none);
}

function ShowWindow() {
	super.ShowWindow();
	PlayerId.SetCaption(PlayerIdText@PRI.PlayerId);
	PlayerKick.SetCaption(PlayerKickText@PRI.PlayerName);
	PlayerBan.SetCaption(PlayerBanText@PRI.PlayerName);
}

function ExecuteItem(UWindowPullDownMenuItem Item) {
	local VS_PlayerChannel Ch;

	Ch = VS_UI_ClientWindow(OwnerWindow.OwnerWindow).Channel;

	if (Item == PlayerKick) {
		if (Ch != none)
			Ch.KickPlayer(PRI);
	} else if (Item == PlayerBan) {
		if (Ch != none)
			Ch.BanPlayer(PRI);
	}
	super.ExecuteItem(Item);
}

defaultproperties {
	bLeaveOnScreen=True

	PlayerIdText="ID:"
	PlayerKickText="&Kick"
	PlayerBanText="&Ban"
}
