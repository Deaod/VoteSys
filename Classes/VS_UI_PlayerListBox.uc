class VS_UI_PlayerListBox extends VS_UI_ListBox;

var UWindowCheckbox DummyCheckbox;

var float CheckboxOffsetX;
var float CheckboxOffsetY;
var float PlayerNameOffsetX;
var float PlayerNameOffsetY;

var VS_UI_PlayerMenu ContextMenu;

var transient GameReplicationInfo GRI;

function Created() {
	super.Created();

	DummyCheckbox = new class'UWindowCheckbox';
	DummyCheckbox.Root = Root;

	ContextMenu = VS_UI_PlayerMenu(Root.CreateWindow(class'VS_UI_PlayerMenu', 0, 0, 100, 100, self));
	ContextMenu.HideWindow();
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H) {
	local VS_UI_PlayerListItem I;
	local color SavedColor;
	I = VS_UI_PlayerListItem(Item);

	super.DrawItem(C, Item, X, Y, W, H);

	SavedColor = C.DrawColor;

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.DrawColor.A = 255;

	DummyCheckbox.bChecked = I.PlayerInfo.bHasVoted;
	DummyCheckbox.bDisabled = I.PlayerInfo.bCanVote == false;
	DummyCheckbox.BeforePaint(C, 0, 0);
	DummyCheckbox.ImageX = X+CheckboxOffsetX;
	DummyCheckbox.ImageY = Y+CheckboxOffsetY;
	DummyCheckbox.Paint(C, 0, 0);

	C.DrawColor = SavedColor;
	ClipText(C, X+PlayerNameOffsetX, Y+PlayerNameOffsetY, I.PlayerInfo.PRI.PlayerName);

	if (GRI != none &&
		GRI.bTeamGame &&
		(I.PlayerInfo.PRI.bIsSpectator == false || I.PlayerInfo.PRI.bWaitingPlayer) &&
		I.PlayerInfo.PRI.Team < 4 &&
		Len(I.PlayerInfo.PRI.TeamName) > 0
	) {
		C.DrawColor = class'ChallengeTeamHUD'.default.TeamColor[I.PlayerInfo.PRI.Team];
	}

	ClipText(C, X+PlayerNameOffsetX, Y+PlayerNameOffsetY, I.PlayerInfo.PRI.PlayerName);
}

function float ItemWidth(Canvas C, UWindowList Item, float VisibleWidth) {
	local float W, H;

	TextSize(C, VS_UI_PlayerListItem(Item).PlayerInfo.PRI.PlayerName, W, H);

	return FMax(PlayerNameOffsetX + W + 4.0, VisibleWidth);
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	super.BeforePaint(C, MouseX, MouseY);

	CheckboxOffsetX = 2;
	CheckboxOffsetY = 0;
	PlayerNameOffsetX = 20;
	PlayerNameOffsetY = 0;

	DummyCheckbox.WinWidth = 16;
	DummyCheckbox.WinHeight = 16;
	DummyCheckbox.LookAndFeel = LookAndFeel;

	if (GRI == none)
		foreach GetLevel().AllActors(class'GameReplicationInfo', GRI)
			break;
}


function Paint(Canvas C, float MouseX, float MouseY) {
	super.Paint(C, MouseX, MouseY);

	DummyCheckbox.ClippingRegion = ClippingRegion;
}

function Close(optional bool bByParent) {
	if (ContextMenu.bWindowVisible)
		ContextMenu.CloseUp(True);
	super.Close(bByParent);
}

function RMouseDown(float MouseX, float MouseY) {
	local VS_UI_PlayerListItem I;
	local VS_PlayerChannel PlayerChannel;
	local VS_PlayerInfo PlayerInfo;
	local VS_Info VoteInfo;

	super.RMouseDown(MouseX, MouseY);

	I = VS_UI_PlayerListItem(GetItemAt(MouseX, MouseY));
	if (I == none)
		return;

	PlayerChannel = VS_UIV_ClientWindow(ParentWindow).Channel;
	PlayerInfo = PlayerChannel.PlayerInfo();
	VoteInfo = PlayerChannel.VoteInfo();

	ContextMenu.WinLeft = Root.MouseX;
	ContextMenu.WinTop = Root.MouseY;
	ContextMenu.PlayerKick.bDisabled = ! (
		(PlayerInfo != none && PlayerInfo.bCanVote) &&
		(VoteInfo.bEnableKickVoting || GetPlayerOwner().PlayerReplicationInfo.bAdmin)
	);
	ContextMenu.PlayerBan.bDisabled = (GetPlayerOwner().PlayerReplicationInfo.bAdmin == false);

	// ContextMenu.PRI MUST be set before ShowWindow is invoked,
	// ShowWindow renames the ContextMenu items depending on PRI
	ContextMenu.PRI = I.PlayerInfo.PRI;
	ContextMenu.ShowWindow();
}

defaultproperties {
	HorizontalScrollbarMode=HSM_Auto
	ListClass=class'VS_UI_PlayerListItem'
	ItemHeight=17
}
