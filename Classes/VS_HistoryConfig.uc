class VS_HistoryConfig extends Object
	perobjectconfig;

struct HistoryEntry {
	var() config string Category;
	var() config string PresetName;
	var() config string MapName;
	var() config int Sequence;
};

var config array<HistoryEntry> Entry;

function InsertVote(string Category, string PresetName, string MapName) {
	local int BestIndex;
	local int HighestSeqNum;
	local int i;

	BestIndex = -1;

	for (i = 0; i < Entry.Length; i++) {
		if (Entry[i].Sequence > HighestSeqNum)
			HighestSeqNum = Entry[i].Sequence;
		if (Entry[i].MapName == MapName && Entry[i].Category == Category && Entry[i].PresetName == PresetName)
			BestIndex = i;
	}

	if (BestIndex == -1) {
		BestIndex = Entry.Length;
		Entry.Insert(BestIndex, 1);
		Entry[BestIndex].Category = Category;
		Entry[BestIndex].PresetName = PresetName;
		Entry[BestIndex].MapName = MapName;
	}
	Entry[BestIndex].Sequence = HighestSeqNum + 1;
}
