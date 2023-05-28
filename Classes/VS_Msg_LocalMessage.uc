class VS_Msg_LocalMessage extends LocalMessagePlus;

var localized string MsgNobodyVoted;
var localized string MsgVotesTied;
var localized string MsgHaveWinner;
var localized string MsgMidGame;
var localized string MsgGameEnded;
var localized string MsgPlayerVoted;
var localized string MsgAdminForceTravel;
var localized string MsgAdminKickPlayer;
var localized string MsgAdminBanPlayer;
var localized string MsgKickVotePlaced;
var localized string MsgKickVoteSuccessful;

var localized string ErrStillLoading;
var localized string ErrNoRootWindow;
var localized string ErrCreateDialog;
var localized string ErrWrongConsole;
var localized string ErrMapLoadFailed;
var localized string ErrNoConnection;
var localized string ErrNotAllowed;

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
		case 1:  Result = default.MsgNobodyVoted; break;
		case 2:  Result = default.MsgVotesTied; break;
		case 3:  Result = default.MsgHaveWinner; break;
		case 4:  Result = default.MsgMidGame; break;
		case 5:  Result = default.MsgGameEnded; break;
		case 6:  Result = default.MsgPlayerVoted; break;
		case 7:  Result = default.MsgAdminForceTravel; break;
		case 8:  Result = default.MsgAdminKickPlayer; break;
		case 9:  Result = default.MsgAdminBanPlayer; break;
		case 10: Result = default.MsgKickVotePlaced; break;
		case 11: Result = default.MsgKickVoteSuccessful; break;

		case -1: Result = default.ErrStillLoading; break;
		case -2: Result = default.ErrNoRootWindow; break;
		case -3: Result = default.ErrCreateDialog; break;
		case -4: Result = default.ErrWrongConsole; break;
		case -5: Result = default.ErrMapLoadFailed; break;
		case -6: Result = default.ErrNoConnection; break;
		case -7: Result = default.ErrNotAllowed; break;

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
	MsgAdminKickPlayer="Admin {1} kicked player {2} ({3})"
	MsgAdminBanPlayer="Admin {1} banned player {2} ({3})"
	MsgKickVotePlaced="A player voted to kick {1}"
	MsgKickVoteSuccessful="{1} was kicked"

	ErrStillLoading="Vote Menu data is still being transferred, please try again"
	ErrNoRootWindow="Failed to create {1} window (Root does not exist)"
	ErrCreateDialog="Failed to create {1} window (Could not create Dialog)"
	ErrWrongConsole="Failed to create {1} window (Console not a WindowConsole)"
	ErrMapLoadFailed="Loading map {1} failed, randomly selecting {2}"
	ErrNoConnection="VoteSys has no connection to server, check server firewall"
	ErrNotAllowed="Sorry, you are not allowed to vote"
}
