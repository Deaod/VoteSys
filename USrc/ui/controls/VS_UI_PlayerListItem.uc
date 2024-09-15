class VS_UI_PlayerListItem extends VS_UI_ListItem;

var VS_PlayerInfo PlayerInfo;

function bool ShowThisItem() {
	return PlayerInfo != none && PlayerInfo.bIsPlayer;
}

