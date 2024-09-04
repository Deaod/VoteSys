class VS_FavoritesProcessor extends Actor
	imports(VS_Util_String);

var VS_Preset PresetList;
var VS_Preset FirstPreset;
var string FavoritesRules;

var VS_Preset CurP;
var VS_Map CurM;

const MaxOpsPerTick = 1000;

event PostBeginPlay() {
	Disable('Tick');
}

// PrioPreset indicates that out of the list of Presets, this specific preset
// should be updated first.
function UpdateFavorites(VS_Preset Presets, string Rules, optional VS_Preset PrioPreset) {
	FavoritesRules = Rules;
	PresetList = Presets;
	FirstPreset = PrioPreset;
	if (FirstPreset == none)
		FirstPreset = PresetList;
	CurP = FirstPreset;

	Enable('Tick');
}

event Tick(float Delta) {
	local int OpsRemaining;

	OpsRemaining = MaxOpsPerTick;

	do {
		if (CurM == none)
			CurM = CurP.MapList;
		while(CurM != none) {
			CurM.bClientFavorite = (InStr(FavoritesRules, CurM.MapName$",") >= 0);

			if (--OpsRemaining == 0)
				return;

			CurM = CurM.Next;
		}

		// Eagerly notify when the first preset has been processed, FirstPreset
		// could be the PrioPreset passed to UpdateFavorites, so we want to
		// update the UI ASAP after updating favorites for it.
		if (CurP == FirstPreset)
			VS_PlayerChannel(Owner).UpdateFavoritesEnd();

		CurP = CurP.Next;
		if (CurP == none)
			CurP = PresetList;
	} until(CurP == FirstPreset);

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

defaultproperties {
	bHidden=True
	RemoteRole=ROLE_None
	DrawType=DT_None
	bAlwaysTick=True
}
