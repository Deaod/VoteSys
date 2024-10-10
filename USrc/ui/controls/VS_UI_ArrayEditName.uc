class VS_UI_ArrayEditName extends VS_UI_ArrayEditBase;

var array<name> Entries;
var name Dummy;

function FillEditWindow(VS_UI_ArrayEditW Wnd) {
	local int i;

	SetPropertyText("Entries", EditBox.GetValue());
	for (i = 0; i < Entries.Length; i++)
		Wnd.AddElement(string(Entries[i]));
}

function EditWindowClosed(VS_UI_ArrayEditW Wnd) {
	local int i, Count;
	local VS_UI_ArrayEditLI It;
	local VS_UI_ArrayEditCW CW;

	CW = VS_UI_ArrayEditCW(Wnd.ClientArea);
	Count = CW.Lst_Elements.Items.Count();
	Entries.Remove(0, Entries.Length);
	Entries.Insert(0, Count);

	i = 0;
	for (It = VS_UI_ArrayEditLI(CW.Lst_Elements.Items.Next); It != none; It = VS_UI_ArrayEditLI(It.Next)) {
		SetPropertyText("Dummy", It.Text);
		Entries[i++] = Dummy;
	}

	EditBox.SetValue(GetPropertyText("Entries"));
}

function Clear() {
	Entries.Remove(0, Entries.Length);
	super.Clear();
}
