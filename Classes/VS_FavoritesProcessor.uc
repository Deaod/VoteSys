class VS_FavoritesProcessor extends Actor
	imports(VS_Util_String);

var VS_Preset PresetList;
var string RemainingRules;

var string CurR;
var VS_Preset CurP;
var VS_Map CurM;

const MaxOpsPerTick = 1000;

event PostBeginPlay() {
	Disable('Tick');
}

function UpdateFavorites(VS_Preset Presets, string FavoritesRules) {
	RemainingRules = FavoritesRules;
	if (PeekRule() == "")
		PopRule();

	PresetList = Presets;

	ClearFavorites();
	Enable('Tick');
}

event Tick(float Delta) {
	local int OpsRemaining;

	OpsRemaining = MaxOpsPerTick;

	if (CurR == "")
		CurR = PeekRule();
	while (CurR != "") {

		if (CurP == none)
			CurP = PresetList;
		while (CurP != none) {

			if (CurM == none)
				CurM = CurP.MapList;
			while(CurM != none) {
				CurM.bClientFavorite = CurM.bClientFavorite || (CurM.MapName ~= CurR);

				if (--OpsRemaining == 0)
					return;

				CurM = CurM.Next;
			}

			CurP = CurP.Next;
		}

		PopRule();
		CurR = PeekRule();
	}

	Disable('Tick');
	VS_PlayerChannel(Owner).UpdateFavoritesEnd();
}

function ClearFavorites() {
	local VS_Preset P;
	local VS_Map M;

	P = PresetList;
	while(P != none) {
		M = P.MapList;
		while(M != none) {
			M.bClientFavorite = false;
			M = M.Next;
		}
		P = P.Next;
	}
}

function string PeekRule() {
	local int Pos;

	Pos = InStr(RemainingRules, ",");
	if (Pos >= 0)
		return Trim(Left(RemainingRules, Pos));

	return Trim(RemainingRules);
}

function PopRule() {
	local int Pos;

	do {
		Pos = InStr(RemainingRules, ",");
		if (Pos >= 0)
			RemainingRules = Mid(RemainingRules, Pos+1);
	} until(Len(RemainingRules) == 0 || PeekRule() != "");
}

defaultproperties {
	bHidden=True
	RemoteRole=ROLE_None
	DrawType=DT_None
	bAlwaysTick=True
}
