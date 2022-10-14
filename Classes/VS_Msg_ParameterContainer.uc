class VS_Msg_ParameterContainer extends Object;

var string Params[6];

function string ApplyParameters(string Input) {
	local string Result;
	local int OpenPos;
	local int ClosePos;
	local int Index;

	OpenPos = InStr(Input, "{");
	while (OpenPos >= 0) {
		Result = Result $ Left(Input, OpenPos);
		Input = Mid(Input, OpenPos+1);
		ClosePos = InStr(Input, "}");
		if (ClosePos == -1)
			return Result $ Input;
		
		Index = int(Left(Input, ClosePos));
		Input = Mid(Input, ClosePos+1);
		if (Index > 0 && Index < arraycount(Params))
			Result = Result $ Params[Index];

		OpenPos = InStr(Input, "{");
	}

	return Result$Input;
}
