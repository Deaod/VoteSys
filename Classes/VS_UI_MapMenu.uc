class VS_UI_MapMenu extends UWindowRightClickMenu;

var UWindowPullDownMenuItem SortBy;
var localized string SortByText;
var UWindowPullDownMenu SortByMenu;

function Created() {
	super.Created();

	//AddMenuItem("-", none);
	SortBy = AddMenuItem(SortByText, none);
	SortByMenu = SortBy.CreateSubMenu(class'VS_UI_MapSortByMenu', OwnerWindow);
}

defaultproperties {
	bLeaveOnScreen=True

	SortByText="Sort By"
}
