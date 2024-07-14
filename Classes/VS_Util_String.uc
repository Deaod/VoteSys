class VS_Util_String extends Object;

static final function string Trim(string In) {
	return TrimRight(TrimLeft(In));
}

static final function string TrimLeft(string In) {
	local int Pos;

	Pos = 0;
	while (Mid(In, Pos, 1) == " ")
		Pos++;

	return Mid(In, Pos);
}

static final function string TrimRight(string In) {
	local int Pos;

	Pos = Len(In);
	while (Pos > 0 && Mid(In, Pos - 1, 1) == " ")
		Pos--;

	return Left(In, Pos);
}

