class VS_UI_CandidateListItem extends UWindowListBoxItem;

var VS_Candidate Candidate;

var bool bHover;

function int Compare(UWindowList T, UWindowList B) {
	if(VS_UI_CandidateListItem(T).Candidate.Votes < VS_UI_CandidateListItem(B).Candidate.Votes)
		return 1;

	return -1;
}
