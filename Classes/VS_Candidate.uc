class VS_Candidate extends ReplicationInfo;

var VS_Info Origin;
var VS_Candidate Next;
var VS_Candidate Prev;

var string Preset;
var string MapName;
var int Votes;

var VS_Preset PresetRef;
var VS_Map MapRef;

var int Mark;

replication {
	reliable if (Role == ROLE_Authority)
		Next,
		Prev,
		Preset,
		MapName,
		Votes;
}

function Fill(VS_Preset P, VS_Map M) {
	PresetRef = P;
	MapRef = M;

	Preset = P.GetFullName();
	MapName = M.MapName;
}

function FillRandom(VS_Preset P) {
	PresetRef = P;
	MapRef = none;

	Preset = P.GetFullName();
	MapName = class'VS_Info'.default.RandomMapNameIdentifier;
}

function Append(VS_Info I) {
	Origin = I;

	if (I.FirstCandidate == none)
		I.FirstCandidate = self;
	if (I.LastCandidate != none) {
		I.LastCandidate.Next = self;
		self.Prev = I.LastCandidate;
	}

	I.LastCandidate = self;
}

function Remove() {
	if (Next != none)
		Next.Prev = Prev;
	if (Prev != none)
		Prev.Next = Next;

	if (Origin.FirstCandidate == self)
		Origin.FirstCandidate = Next;
	if (Origin.LastCandidate == self)
		Origin.LastCandidate = Prev;
}

function SwapWithPrev() {
	local VS_Candidate PP, P, C, N;

	if (Prev == none)
		return;

	PP = Prev.Prev;
	P = Prev;
	C = self;
	N = Next;

	if (PP != none)
		PP.Next = C;
	else
		Origin.FirstCandidate = C;
	
	C.Next = P;
	C.Prev = PP;

	P.Next = N;
	P.Prev = C;

	if (N != none)
		N.Prev = P;
	else
		Origin.LastCandidate = P;
}

function SwapWithNext() {
	local VS_Candidate P, C, N, NN;

	if (Next == none)
		return;

	P = Prev;
	C = self;
	N = Next;
	NN = Next.Next;

	if (P != none)
		P.Next = N;
	else
		Origin.FirstCandidate = N;

	C.Next = NN;
	C.Prev = N;

	N.Next = C;
	N.Prev = P;

	if (NN != none)
		NN.Prev = C;
	else
		Origin.LastCandidate = C;
}

function SortInList() {
	while(true) {
		switch (CalcSortDirection()) {
			case 1: SwapWithPrev(); break;
			case -1: SwapWithNext(); break;
			default: return;
		}
	}
}

function int CalcSortDirection() {
	if (Prev != none && Prev.Votes < Votes)
		return 1;
	if (Next != none && Next.Votes > Votes)
		return -1;

	return 0;
}

function Dump() {
	Log(Votes$"|'"$Preset$"''"$MapName$"'", 'VoteSys');
}

defaultproperties {
	RemoteRole=ROLE_SimulatedProxy
	NetUpdateFrequency=10
}
