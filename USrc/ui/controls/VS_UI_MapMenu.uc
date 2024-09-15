class VS_UI_MapMenu extends UWindowRightClickMenu;

var VS_UI_MapListItem ContextItem;

var UWindowPulldownMenuItem Favorite;
var localized string FavoriteText;

var UWindowPulldownMenuItem SortBy;
var localized string SortByText;
var UWindowPulldownMenu SortByMenu;

function Created() {
	super.Created();

	Favorite = AddMenuItem(FavoriteText, none);
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

	if (I == Favorite) {
		VS_UIV_ClientWindow(OwnerWindow.OwnerWindow).ToggleFavorite(ContextItem.MapRef);
	}
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	super.BeforePaint(C, MouseX, MouseY);

	if (ContextItem != none && ContextItem.MapRef != none)
		Favorite.bChecked = ContextItem.MapRef.bClientFavorite;
}

defaultproperties {
	bLeaveOnScreen=True

	FavoriteText="Favorite"
	SortByText="Sort By"
}
