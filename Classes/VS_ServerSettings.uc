class VS_ServerSettings extends Object
	perobjectconfig;

var config int GameEndedVoteDelay;
var config int VoteTimeLimit;
var config int MinimumMapRepeatDistance;
var config string DefaultTimeMessageClass;
var config string DefaultPreset;
var config string ServerAddress;
var config bool bManageServerPackages;
var config bool bUseServerActorsCompatibilityMode;
var config array<string> DefaultPackages;
var config array<string> DefaultActors;

defaultproperties {
	GameEndedVoteDelay=5
	VoteTimeLimit=30
	DefaultTimeMessageClass="Botpack.TimeMessage"
	DefaultPreset=
	ServerAddress=
	bManageServerPackages=False
	bUseServerActorsCompatibilityMode=False
	MinimumMapRepeatDistance=0
}
