class VS_UI_CandidateListItem extends UWindowListBoxItem;

var string Preset;
var string MapName;
var int Votes;

var bool bHover;

function int Compare(UWindowList T, UWindowList B) {
	if(VS_UI_CandidateListItem(T).Votes < VS_UI_CandidateListItem(B).Votes)
		return 1;

	return -1;
}
