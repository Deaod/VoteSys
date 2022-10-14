class VS_UI_VoteListItem extends UWindowListBoxItem;

var string Preset;
var string MapName;
var int Votes;

var bool bHover;

function int Compare(UWindowList T, UWindowList B) {
	if(VS_UI_VoteListItem(T).Votes < VS_UI_VoteListItem(B).Votes)
		return -1;

	return 1;
}
