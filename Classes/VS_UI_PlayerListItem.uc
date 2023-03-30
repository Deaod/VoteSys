class VS_UI_PlayerListItem extends UWindowListBoxItem;

var bool bHover;

var VS_PlayerInfo PlayerInfo;

function bool ShowThisItem() {
	return PlayerInfo != none && PlayerInfo.bIsPlayer;
}

