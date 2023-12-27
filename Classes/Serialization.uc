class Serialization extends Object;

var string CRLF;

static final function Serialization Instance() {
	local Serialization Inst;
	Inst = new(none, 'SerializationInstance') class'Serialization';
	Inst.CRLF = Chr(13)$Chr(10);
	return Inst;
}

final function string EncodeString(string S) {
	local int i;
	local string Result;

	Result = "\"";
	i = InStr(S, "\"");
	while (i >= 0) {
		Result = Result$Left(S, i)$"\\\"";
		S = Mid(S, i+1);
		i = InStr(S, "\"");
	}

	return Result $ S $ "\"";
}

final function string DecodeString(out string S) {
	local int i;
	local string Result;

	if (Left(S, 1) != "\"")
		return "";

	S = Mid(S, 1);

	i = InStr(S, "\"");
	while(i >= 0) {
		if (i == 0) {
			S = Mid(S, 1);
			return Result;
		}

		if (Mid(S, i-1, 1) == "\\") {
			Result = Result $ Left(S, i-1) $ "\"";
			S = Mid(S, i+1);
		} else {
			Result = Result $ Left(S, i);
			S = Mid(S, i+1);
			return Result;
		}

		i = InStr(S, "\"");
	}

	return Result $ S;
}


final function NextVariable(out string L) {
	local int Pos;

	Pos = InStr(L, "/");

	if (Pos >= 0)
		L = Mid(L, Pos+1);
	else
		L = "";
}

final function ParseProperty(string Line, out string PropertyName, out string PropertyValue) {
	PropertyName  = DecodeString(Line); NextVariable(Line);
	PropertyValue = DecodeString(Line);
}

final function VS_Preset ParsePreset(string Line) {
	local VS_Preset P;

	P = new(none) class'VS_Preset';

	Line = Mid(Line, 8);
	//                         |   Parse Content    | Skip /
	P.PresetName               = DecodeString(Line); NextVariable(Line);
	P.Abbreviation             = DecodeString(Line); NextVariable(Line);
	P.Category                 = DecodeString(Line); NextVariable(Line);
	P.MaxSequenceNumber        = int(Line);          NextVariable(Line);
	P.MinimumMapRepeatDistance = int(Line);          NextVariable(Line);
	P.SortPriority             = int(Line);

	return P;
}

final function VS_Map ParseMap(string Line) {
	local VS_Map M;

	M = new(none) class'VS_Map';

	Line = Mid(Line, 5);
	//           |   Parse Content    | Skip /
	M.MapName    = DecodeString(Line); NextVariable(Line);
	M.Sequence   = int(Line);          NextVariable(Line);
	M.PlayCount  = int(Line);          NextVariable(Line);
	M.MinPlayers = int(Line);          NextVariable(Line);
	M.MaxPlayers = int(Line);

	return M;
}

final function string SerializeProperty(string PropertyName, string PropertyValue) {
	return EncodeString(PropertyName)$"/"$EncodeString(PropertyValue);
}

final function string SerializePreset(VS_Preset P) {
	local string Result;

	Result = "/PRESET/";
	Result = Result$EncodeString(P.PresetName)$"/";
	Result = Result$EncodeString(P.Abbreviation)$"/";
	Result = Result$EncodeString(P.Category)$"/";
	Result = Result$P.MaxSequenceNumber$"/";
	Result = Result$P.MinimumMapRepeatDistance$"/";
	Result = Result$P.SortPriority;

	return Result;
}

final function string SerializeMap(VS_Map M) {
	local string Result;

	Result = "/MAP/";
	Result = Result$EncodeString(M.MapName)$"/";
	Result = Result$M.Sequence$"/";
	Result = Result$M.PlayCount$"/";
	Result = Result$M.MinPlayers$"/";
	Result = Result$M.MaxPlayers;

	return Result;
}

