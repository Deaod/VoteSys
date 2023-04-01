class VS_UI_PlayerMenu extends UWindowRightClickMenu;

var PlayerReplicationInfo PRI;

var UWindowPullDownMenuItem PlayerId;
var localized string PlayerIdText;

var UWindowPullDownMenuItem PlayerKick;
var localized string PlayerKickText;

var UWindowPullDownMenuItem PlayerBan;
var localized string PlayerBanText;
var localized string PlayerBanTitle;
var localized string PlayerBanMessage;
var UWindowMessageBox PlayerBanMB;

function Created() {
	super.Created();

	PlayerId = AddMenuItem("ID", none);
	PlayerId.bDisabled = true;
	AddMenuItem("-", none);
	PlayerKick = AddMenuItem("Kick", none);
	PlayerBan = AddMenuItem("Ban", none);
}

function ShowWindow() {
	local VS_PlayerChannel Ch;

	super.ShowWindow();

	PlayerId.SetCaption(PlayerIdText@PRI.PlayerId);
	PlayerKick.SetCaption(PlayerKickText@PRI.PlayerName);
	PlayerBan.SetCaption(PlayerBanText@PRI.PlayerName);

	Ch = VS_UI_VoteClientWindow(OwnerWindow.OwnerWindow).Channel;
	PlayerKick.bChecked = (Ch.WantsToKick(PRI) >= 0);

	if (PlayerBanMB != none)
		PlayerBanMB.Close();
	PlayerBanMB = none;
}

function ExecuteItem(UWindowPullDownMenuItem Item) {
	local VS_PlayerChannel Ch;

	Ch = VS_UI_VoteClientWindow(OwnerWindow.OwnerWindow).Channel;

	if (Item == PlayerKick) {
		if (Ch != none)
			Ch.KickPlayer(PRI);
	} else if (Item == PlayerBan) {
		PlayerBanMB = MessageBox(
			PlayerBanTitle,
			I18N(PlayerBanMessage, PRI.PlayerName),
			MB_YesNo,
			MR_No, // Esc Result
			MR_No // Enter Result
		);
		PlayerBanMB.bLeaveOnScreen = true;
	}
	super.ExecuteItem(Item);
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult R) {
	local VS_PlayerChannel Ch;

	if (W != PlayerBanMB)
		return;

	Ch = VS_UI_VoteClientWindow(OwnerWindow.OwnerWindow).Channel;
	if (Ch != none && R == MR_Yes)
		Ch.BanPlayer(PRI);
}

final function string I18N(
	coerce string Msg,
	optional coerce string P1,
	optional coerce string P2,
	optional coerce string P3,
	optional coerce string P4,
	optional coerce string P5
) {
	ReplaceText(Msg, "{1}", P1);
	ReplaceText(Msg, "{2}", P2);
	ReplaceText(Msg, "{3}", P3);
	ReplaceText(Msg, "{4}", P4);
	ReplaceText(Msg, "{5}", P5);

	return Msg;
}

defaultproperties {
	bLeaveOnScreen=True

	PlayerIdText="ID:"
	PlayerKickText="&Kick"
	PlayerBanText="&Ban"
	PlayerBanTitle="Ban Player"
	PlayerBanMessage="Do you want to permanently ban {1}?"
}
