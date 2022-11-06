class VS_HistoryProcessor extends Actor;

var MutVoteSys VoteSys;
var VS_HistoryConfig History;
var VS_Preset PresetList;
var int ProcessedEntry;
const EntriesPerTick = 200;

event Tick(float Delta) {
	local int End;
	local string Cat, Pre, Map;
	local VS_Preset P;
	local VS_Map M;

	if (VoteSys == none)
		return;
	if (History == none)
		return;
	if (PresetList == none)
		return;

	End = Min(ProcessedEntry + EntriesPerTick, History.Entry.Length);
	while(ProcessedEntry < End) {
		Cat = History.Entry[ProcessedEntry].Category;
		Pre = History.Entry[ProcessedEntry].PresetName;
		Map = History.Entry[ProcessedEntry].MapName;

		for (P = PresetList; P != none; P = P.Next)
			if (P.Category == Cat && P.PresetName == Pre)
				for (M = P.MapList; M != none; M = M.Next)
					if (M.MapName == Map)
						M.Sequence = History.Entry[ProcessedEntry].Sequence;

		ProcessedEntry++;
	}

	if (ProcessedEntry == History.Entry.Length) {
		VoteSys.HistoryProcessor = none;
		Destroy();
	}
}

defaultproperties {
	bHidden=True
	RemoteRole=ROLE_None
	DrawType=DT_None
}
