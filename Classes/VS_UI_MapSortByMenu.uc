class VS_UI_MapSortByMenu extends UWindowPulldownMenu;

var UWindowPullDownMenuItem ItemName;
var localized string ItemNameText;
var UWindowPullDownMenuItem ItemRecency;
var localized string ItemRecencyText;
var UWindowPullDownMenuItem ItemPlayCount;
var localized string ItemPlayCountText;

function Created() {
	super.Created();

	ItemName = AddMenuItem(ItemNameText, none);
	ItemRecency = AddMenuItem(ItemRecencyText, none);
	ItemPlayCount = AddMenuItem(ItemPlayCountText, none);
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
	switch(I) {
		case ItemName:
			VS_UIV_ClientWindow(OwnerWindow.OwnerWindow).Settings.MapListSort = MLS_Name;
			break;
		case ItemRecency:
			VS_UIV_ClientWindow(OwnerWindow.OwnerWindow).Settings.MapListSort = MLS_Recency;
			break;
		case ItemPlayCount:
			VS_UIV_ClientWindow(OwnerWindow.OwnerWindow).Settings.MapListSort = MLS_PlayCount;
			break;
	}

	VS_UIV_ClientWindow(OwnerWindow.OwnerWindow).Settings.SaveConfig();
	UpdateCheckmark();

	super.ExecuteItem(I);
}

function CloseUp(optional bool bByOwner) {
	Super.CloseUp(bByOwner);
	HideWindow();
}

function UpdateCheckmark() {
	local UWindowPullDownMenuItem I;

	ItemName.bChecked = false;
	ItemRecency.bChecked = false;
	ItemPlayCount.bChecked = false;

	switch(VS_UIV_ClientWindow(OwnerWindow.OwnerWindow).Settings.MapListSort) {
		case MLS_Name:
			I = ItemName;
			break;
		case MLS_Recency:
			I = ItemRecency;
			break;
		case MLS_PlayCount:
			I = ItemPlayCount;
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
}
