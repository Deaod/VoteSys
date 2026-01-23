class VS_UI_MapSortByMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem ItemName;
var localized string ItemNameText;
var UWindowPulldownMenuItem ItemRecency;
var localized string ItemRecencyText;
var UWindowPulldownMenuItem ItemPlayCount;
var localized string ItemPlayCountText;
var UWindowPulldownMenuItem ItemRating;
var localized string ItemRatingText;

var UWindowPulldownMenuItem FavoritesFirst;
var localized string FavoritesFirstText;

function Created() {
	super.Created();

	ItemName = AddMenuItem(ItemNameText, none);
	ItemRecency = AddMenuItem(ItemRecencyText, none);
	ItemPlayCount = AddMenuItem(ItemPlayCountText, none);
	ItemRating = AddMenuItem(ItemRatingText, none);
	AddMenuItem("-", none);
	FavoritesFirst = AddMenuItem(FavoritesFirstText, none);
}

function ShowWindow() {
	super.ShowWindow();

	UpdateCheckmark();
}

function SetSelected(float X, float Y) {
	if (Y >= VBorder)
		super.SetSelected(X, Y);
	else
		PerformSelect(none);
}

function ExecuteItem(UWindowPullDownMenuItem I) {
	local VS_ClientSettings Settings;

	Settings = VS_UIV_ClientWindow(OwnerWindow.OwnerWindow).Settings;

	switch(I) {
		case ItemName:
			Settings.MapListSort = MLS_Name;
			break;
		case ItemRecency:
			Settings.MapListSort = MLS_Recency;
			break;
		case ItemPlayCount:
			Settings.MapListSort = MLS_PlayCount;
			break;
		case ItemRating:
			Settings.MapListSort = MLS_Rating;
			break;
		case FavoritesFirst:
			Settings.bFavoritesFirst = !Settings.bFavoritesFirst;
			break;
	}

	Settings.SaveConfig();
	UpdateCheckmark();

	super.ExecuteItem(I);
}

function CloseUp(optional bool bByOwner) {
	Super.CloseUp(bByOwner);
	HideWindow();
}

function UpdateCheckmark() {
	local UWindowPullDownMenuItem I;
	local VS_ClientSettings Settings;

	Settings = VS_UIV_ClientWindow(OwnerWindow.OwnerWindow).Settings;

	ItemName.bChecked = false;
	ItemRecency.bChecked = false;
	ItemPlayCount.bChecked = false;
	ItemRating.bChecked = false;
	FavoritesFirst.bChecked = Settings.bFavoritesFirst;

	switch(Settings.MapListSort) {
		case MLS_Name:
			I = ItemName;
			break;
		case MLS_Recency:
			I = ItemRecency;
			break;
		case MLS_PlayCount:
			I = ItemPlayCount;
			break;
		case MLS_Rating:
			I = ItemRating;
			break;
	}

	I.bChecked = true;
}

defaultproperties {
	bTransient=True
	bLeaveOnScreen=True

	ItemNameText="Name"
	ItemRecencyText="Recency"
	ItemPlayCountText="Play Count"
	ItemRatingText="Rating"
	FavoritesFirstText="Favorites First"
}
