class VS_HistoryProcessor extends Actor
	imports(VS_Util_Logging);

var MutVoteSys VoteSys;
var VS_HistoryConfig History;
var VS_Preset PresetList;
var int ProcessingTicks;
var float ProcessingTime;
var int ProcessedEntry;
const EntriesPerTick = 200;

event Tick(float Delta) {
	local int End;
	local string Cat, Pre, Map;
	local VS_Preset P;
	local VS_Map M;
	local float Rating;
	local int Ratings;

	if (VoteSys == none)
		return;
	if (History == none)
		return;

	End = Min(ProcessedEntry + EntriesPerTick, History.Entry.Length);
	while(ProcessedEntry < End) {
		Cat = History.Entry[ProcessedEntry].Category;
		Pre = History.Entry[ProcessedEntry].PresetName;
		Map = History.Entry[ProcessedEntry].MapName;

		for (P = PresetList; P != none; P = P.Next) {
			if (P.bDisabled == false && P.Category == Cat && P.PresetName == Pre) {
				for (M = P.MapList; M != none; M = M.Next) {
					if (M.MapName == Map) {
						M.Sequence = History.Entry[ProcessedEntry].Sequence;
						P.MaxSequenceNumber = Max(P.MaxSequenceNumber, M.Sequence);
						M.PlayCount = History.Entry[ProcessedEntry].NumVoted;

						Rating =
							History.Entry[ProcessedEntry].Rating2   +
							History.Entry[ProcessedEntry].Rating3*2 +
							History.Entry[ProcessedEntry].Rating4*3 +
							History.Entry[ProcessedEntry].Rating5*4;
						Ratings =
							History.Entry[ProcessedEntry].Rating1 +
							History.Entry[ProcessedEntry].Rating2 +
							History.Entry[ProcessedEntry].Rating3 +
							History.Entry[ProcessedEntry].Rating4 +
							History.Entry[ProcessedEntry].Rating5;

						if (Ratings >= VoteSys.Settings.MinimumNumberOfRatings)
							M.Rating = int((Rating / (float(Ratings) * 4.0)) * 65535.0);
						else
							M.Rating = -1;
					}
				}
			}
		}

		ProcessedEntry++;
	}

	ProcessingTicks += 1;
	ProcessingTime += Delta;

	if (ProcessedEntry == History.Entry.Length) {
		VoteSys.HistoryProcessor = none;
		LogMsg("Processed history in"@ProcessingTime@"seconds ("$ProcessingTicks$" ticks)");
		Destroy();
	}
}

defaultproperties {
	bHidden=True
	RemoteRole=ROLE_None
	DrawType=DT_None
	bAlwaysTick=True
}
