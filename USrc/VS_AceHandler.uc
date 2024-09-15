class VS_AceHandler extends Actor;

var Actor AceActor;

final function Actor GetACE() {
	if (AceActor == none) {
		foreach AllActors(class'Actor', AceActor)
			if (AceActor.IsA('IACEActor'))
				break;

		if (AceActor == none || AceActor.IsA('IACEActor') == false)
			AceActor = Level;
	} else if (AceActor == Level) {
		return none;
	} else {
		return AceActor;
	}
}

final function int GetAceCheckPlayerId(Actor AceChk) {
	return int(AceChk.GetPropertyText("PlayerID"));
}

final function string GetAceCheckHWHash(Actor AceChk) {
	return AceChk.GetPropertyText("HWHash");
}

defaultproperties {
	RemoteRole=ROLE_None
	bHidden=True
	DrawType=DT_None
}
