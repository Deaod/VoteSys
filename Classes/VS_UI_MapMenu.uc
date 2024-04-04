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

function SetSelected(float X, float Y) {
	if (Y >= VBorder)
		super.SetSelected(X, Y);
	else
		PerformSelect(none);
}

function BeforeExecuteItem(UWindowPulldownMenuItem I) {
	if (I != SortBy)
		super.BeforeExecuteItem(I);
}

function ExecuteItem(UWindowPulldownMenuItem I) {
	if (I != SortBy)
		super.ExecuteItem(I);
}

defaultproperties {
	bLeaveOnScreen=True

	SortByText="Sort By"
}
