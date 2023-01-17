class VS_ServerSettings extends Object
	perobjectconfig;

var config int GameEndedVoteDelay;
var config int VoteTimeLimit;
var config int MinimumMapRepeatDistance;
var config float KickVoteThreshold;
var config string DefaultTimeMessageClass;
var config string DefaultPreset;
var config string ServerAddress;
var config int DataPort;
var config bool bManageServerPackages;
var config bool bUseServerActorsCompatibilityMode;
var config array<string> DefaultPackages;
var config array<string> DefaultActors;

defaultproperties {
	GameEndedVoteDelay=5
	VoteTimeLimit=30
	MinimumMapRepeatDistance=0
	KickVoteThreshold=0.6
	DefaultTimeMessageClass="Botpack.TimeMessage"
	DefaultPreset=
	ServerAddress=
	DataPort=0
	bManageServerPackages=False
	bUseServerActorsCompatibilityMode=False
}
