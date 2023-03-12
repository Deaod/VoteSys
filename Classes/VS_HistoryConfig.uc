class VS_HistoryConfig extends Object
	perobjectconfig;

struct HistoryEntry {
	var() config string Category;
	var() config string PresetName;
	var() config string MapName;
	var() config int Sequence;
	var() config int NumVoted;
};

var config array<HistoryEntry> Entry;

function InsertVote(VS_Preset Preset, string MapName) {
	local int BestIndex;
	local int i;

	BestIndex = -1;

	for (i = 0; i < Entry.Length; i++) {
		if (Entry[i].MapName == MapName && Entry[i].Category == Preset.Category && Entry[i].PresetName == Preset.PresetName)
			BestIndex = i;
	}

	if (BestIndex == -1) {
		BestIndex = Entry.Length;
		Entry.Insert(BestIndex, 1);
		Entry[BestIndex].Category = Preset.Category;
		Entry[BestIndex].PresetName = Preset.PresetName;
		Entry[BestIndex].MapName = MapName;
	}
	Preset.MaxSequenceNumber++;
	Entry[BestIndex].Sequence = Preset.MaxSequenceNumber;
	Entry[BestIndex].NumVoted++;
}
