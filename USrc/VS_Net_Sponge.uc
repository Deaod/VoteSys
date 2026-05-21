class VS_Net_Sponge extends VS_Net_ChannelLink
	imports(VS_Util_Logging)
	transient;

simulated function Tick(float Delta) {
	// deliberately empty
}

simulated function string GetIdentifier() {
	return "Sponge";
}

defaultproperties {
	RemoteRole=ROLE_None
}
