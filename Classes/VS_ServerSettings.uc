class VS_ServerSettings extends Object
	perobjectconfig;

var config int GameEndedVoteDelay;
var config int VoteTimeLimit;
var config int MinimumMapRepeatDistance;
var config string DefaultTimeMessageClass;
var config string DefaultPreset;
var config string ServerAddress;
var config bool bManageServerPackages;
var config array<string> DefaultPackages;

defaultproperties {
	GameEndedVoteDelay=5
	VoteTimeLimit=30
	DefaultTimeMessageClass="Botpack.TimeMessage"
	DefaultPreset=
	ServerAddress=
	bManageServerPackages=False
	MinimumMapRepeatDistance=0
}
