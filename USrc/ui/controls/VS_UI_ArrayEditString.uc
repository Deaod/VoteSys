class VS_UI_ArrayEditString extends VS_UI_ArrayEditBase;

var array<string> Entries;

function LaunchEditWindow() {
	local int i;

	super.LaunchEditWindow();

	SetPropertyText("Entries", EditBox.GetValue());
	for (i = 0; i < Entries.Length; i++)
		EditWindow.AddElement(Entries[i]);
}

function EditWindowClosed(VS_UI_ArrayEditW Wnd) {
	local int i, Count;
	local VS_UI_ArrayEditLI It;

	Count = VS_UI_ArrayEditCW(EditWindow.ClientArea).Lst_Elements.Items.Count();
	Entries.Remove(0, Entries.Length);
	Entries.Insert(0, Count);

	It = VS_UI_ArrayEditLI(VS_UI_ArrayEditCW(EditWindow.ClientArea).Lst_Elements.Items.Next);
	for (i = 0; It != none; It = VS_UI_ArrayEditLI(It.Next))
		Entries[i++] = It.Text;

	EditBox.SetValue(GetPropertyText("Entries"));
}

function Clear() {
	Entries.Remove(0, Entries.Length);
	super.Clear();
}