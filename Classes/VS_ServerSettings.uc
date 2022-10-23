class VS_ServerSettings extends Object
	perobjectconfig;

var config int GameEndedVoteDelay;
var config int VoteTimeLimit;
var config string DefaultTimeMessageClass;
var config string DefaultPreset;
var config string ServerAddress;

defaultproperties {
	GameEndedVoteDelay=5
	VoteTimeLimit=30
	DefaultTimeMessageClass="Botpack.TimeMessage"
	DefaultPreset=
	ServerAddress=
}
