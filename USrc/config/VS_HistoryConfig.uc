class VS_HistoryConfig extends Object
	config(VoteSysHistory)
	perobjectconfig
	imports(VS_Util_Logging);

struct HistoryEntry {
	var() config string Category;
	var() config string PresetName;
	var() config string MapName;
	var() config int Sequence;
	var() config int NumVoted;
	var() config int Rating1;
	var() config int Rating2;
	var() config int Rating3;
	var() config int Rating4;
	var() config int Rating5;
};

var config array<HistoryEntry> Entry;

var int CurrentMapIndex;

function RateMap(int Stars, int Previous) {
	Stars = Clamp(Stars, 1, 5);
	Previous = Clamp(Previous, 0, 5); // 0 = no vote

	switch(Previous) {
		case 1:
			Entry[CurrentMapIndex].Rating1--;
			break;
		case 2:
			Entry[CurrentMapIndex].Rating2--;
			break;
		case 3:
			Entry[CurrentMapIndex].Rating3--;
			break;
		case 4:
			Entry[CurrentMapIndex].Rating4--;
			break;
		case 5:
			Entry[CurrentMapIndex].Rating5--;
			break;
	}

	switch(Stars) {
		case 1:
			Entry[CurrentMapIndex].Rating1++;
			break;
		case 2:
			Entry[CurrentMapIndex].Rating2++;
			break;
		case 3:
			Entry[CurrentMapIndex].Rating3++;
			break;
		case 4:
			Entry[CurrentMapIndex].Rating4++;
			break;
		case 5:
			Entry[CurrentMapIndex].Rating5++;
			break;
	}

	SaveConfig();
}

function DetermineCurrentMapIndex(VS_Preset Preset, string MapName) {
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

	CurrentMapIndex = BestIndex;
}

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

defaultproperties {
	CurrentMapIndex=-1
}
