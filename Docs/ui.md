# VoteSys User Interface

## Vote Menu

![Overview](Overview.png)

### Dark Mode

![Dark Mode Overview](OverviewDark.png)

### Category Tabs

![Category Tabs](CategoryHighlight.png)

Each category has its own tab here. If the category of a preset is empty, it will appear in a tab called "Default".

### Preset Dropdown

![Preset Dropdown](PresetHighlight.png)

Selects which map list to show. When first opening the voting menu, the category and preset that are currently in use are selected.

### Map List Filter

![Map List Filter](MapFilterHighlight.png)

Allows filtering the map list. Only maps containing the sequence of letters entered here will be shown.

![Map List Filter Applied](MapFilterApplied.png)

### Map List

![Map List](MapListHighlight.png)

Shows the maps available to be used with the currently selected preset.

Selecting a map clears any current selection in the candidate list.  
Double-clicking votes for the map and preset combination.  
Alternatively, you can vote for a map/preset combination by selecting a map in the list and pressing the "Vote" button.

The "Random" button will place your vote for a random map of the currently selected preset.

#### Map Screenshot Preview

After hovering over a map in the map list for half a second, a window showing the screenshot of the map will appear.

![Map Screenshot Window](MapPreview.png)

### Candidate List

![Candidate List](CandidateListHighlight.png)

Shows all preset and map combinations with at least one vote. Candidates are sorted by the amount of votes for them.

Selecting a candidate clears any current selection in the map list.  
Double-clicking a candidate adds your vote to it.  
Alternatively, you can vote for a candidate by selecting one and pressing the "Vote" button.

### Chat Area

![Chat Area](ChatHighlight.png)

Shows chat messages sent by other players. Does not show messages sent only to your own team.

You can write a message in the field at the bottom and either press the "Say" button or press the "Enter" key.

If you hold the "Ctrl" key while sending a message, it will be sent to your own team exclusively (and not show up in the chat area).

You can recall past messages sent by you by pressing the Up arrow key repeatedly.

### Player List

![Player List](PlayerListHighlight.png)

Shows a list of players and whether they have voted already.

Right clicking on a player opens a context menu.

![Player Context Menu](PlayerListContextHighlight.png)

This menu contains the ID of the player, and a way to kick or ban the player. Banning is only possible with admin rights and also requires confirming the ban.

Selecting Kick in the menu without admin privileges places a vote to kick that player. Opening the menu for the same player again will show a checkmark next to the Kick entry. Selecting Kick again will retract your vote to kick the player.

With admin privileges Kick will instantly kick the player and prevent players from the same IP from joining again for the duration of the current match.

### Close Button

![Close Button](CloseButton.png)

The Close button does exactly what it says: It closes the vote menu.

### Settings Button

![Settings Button](SettingsButton.png)

The Settings button with the gear icon opens a settings menu. See [Settings Menu](#settings-menu).

## Settings Menu

### Client Settings

![Client Settings](ClientSettings.png)

Allows changing client-side settings.

The Save button saves the current state of settings. The Close button closes the Settings Menu without saving.

### Server Settings

![Server Settings](ServerSettings.png)

Allows changing server-side settings. Only visible when logged in as admin.
