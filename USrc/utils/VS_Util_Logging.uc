class VS_Util_Logging extends Object abstract;

static final function LogDbg(coerce string M) {
	Log(M, 'VoteSysDebug');
}

static final function LogMsg(coerce string M) {
	Log(M, 'VoteSys');
}

static final function LogErr(coerce string M) {
	Log(M, 'VoteSysError');
}
