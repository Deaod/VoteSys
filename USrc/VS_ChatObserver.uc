class VS_ChatObserver extends MessagingSpectator;

var MutVoteSys VoteSys;

event TeamMessage(PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep) {
	if (Type == 'Say') {
		VoteSys.ChatMessage(PRI, S);
	}
}

function ClientMessage(coerce string S, optional name Type, optional bool bBeep) {}

function ClientVoiceMessage(
	PlayerReplicationInfo Sender,
	PlayerReplicationInfo Recipient,
	name messagetype,
	byte messageID
) {}

function ReceiveLocalizedMessage(
	class<LocalMessage> Message,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
) {}
