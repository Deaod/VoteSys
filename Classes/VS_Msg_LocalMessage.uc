class VS_Msg_LocalMessage extends LocalMessagePlus;

var localized string MsgNobodyVoted;
var localized string MsgVotesTied;
var localized string MsgHaveWinner;
var localized string MsgMidGame;
var localized string MsgGameEnded;
var localized string MsgPlayerVoted;
var localized string MsgAdminForceTravel;

var localized string ErrStillLoading;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
) {
	local string Result;
	local VS_Msg_ParameterContainer Params;

	Params = VS_Msg_ParameterContainer(OptionalObject);

	switch(Switch) {
		case 1: Result = default.MsgNobodyVoted; break;
		case 2: Result = default.MsgVotesTied; break;
		case 3: Result = default.MsgHaveWinner; break;
		case 4: Result = default.MsgMidGame; break;
		case 5: Result = default.MsgGameEnded; break;
		case 6: Result = default.MsgPlayerVoted; break;
		case 7: Result = default.MsgAdminForceTravel; break;

		case -1: Result = default.ErrStillLoading; break;

		default:
			return "";
	}
	
	if (Params == none)
		return Result;
	return Params.ApplyParameters(Result);
}

static function ClientReceive( 
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
) {
	local string Msg;

	Msg = static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (P.myHUD != none)
		P.myHUD.Message(P.PlayerReplicationInfo, Msg, 'VoteSys');

	if ( Default.bBeep && P.bMessageBeep )
		P.PlayBeepSound();

	if ( Default.bIsConsoleMessage )
	{
		if ((P.Player != None) && (P.Player.Console != None))
			P.Player.Console.Message(P.PlayerReplicationInfo, Msg, 'VoteSys');
	}
}

defaultproperties {
	bIsConsoleMessage=True
	bComplexString=True
	Lifetime=5

	MsgNobodyVoted="Nobody voted, randomly selecting {1}"
	MsgVotesTied="Tied, randomly selecting {1}"
	MsgHaveWinner="{1} won"
	MsgMidGame="Initiating mid-game voting, opening Vote Menu"
	MsgGameEnded="Game ended, opening Vote Menu"
	MsgPlayerVoted="{1} voted for {2}"
	MsgAdminForceTravel="Admin {1} forced switching to {2}"

	ErrStillLoading="Vote Menu data is still being transferred, please try again"
}
