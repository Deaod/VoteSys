# VoteSys
A new, independent implementation of map vote.

* Unlimited number of presets
* Unlimited number of maps
* Quicker transfer of data to clients
* Automatic management of ServerPackages
  * Opt-in (`bManageServerPackages`)
  * Before server version 469c `DefaultPackages` have to be configured correctly
  * With 469c no further configuration is necessary
* Map repeat limits (`MinimumMapRepeatDistance`)

Servers must run at least UT v469.  
Clients must run at least UT v436.

## [UI Documentation](Docs/ui.md)

## Installation
1. Make sure the VoteSys .u and .int files are in the System folder
2. Add VoteSys mutator to URL when starting the server
3. Add VoteSys to list of ServerPackages in INI
4. If your server has a firewall:
    1. Open a TCP port in it
    2. Set [DataPort](#dataport) to the port you just opened
5. If you have proxy servers for players to connect to:
    1. Set [ServerAddress](#serveraddress) to the actual address of your server
    2. Set [DataPort](#dataport) to a port of your choice, if you did not set it already

## Server Setup

Server settings are split between multiple INI files.
* VoteSys.ini
* VoteSysPresets.ini
* VoteSysMapLists.ini

In addition there are INI files that dont contain configuration, but are used to store data between map-changes:

* VoteSysTemp.ini
* VoteSysHistory.ini

### Full Preset Names

Sometimes during configuration, you will be asked to refer to presets using their full names. A full preset name is `"<Category>/<PresetName>"`.

For example, given the following preset:
```ini
[VS_PresetConfig0]
PresetName=Custom Preset Name
Category=My Category
...
```

its full preset name is `"My Category/Custom Preset Name"`.

### VoteSys.ini
```ini
[ServerSettings]
GameEndedVoteDelay=5
VoteTimeLimit=30
MidGameVoteThreshold=0.5
MidGameVoteTimeLimit=30
VoteEndCondition=VEC_TimerOnly
bRetainCandidates=False
MultiRoundGameModes=Botpack.Assault
MinimumMapRepeatDistance=0
KickVoteThreshold=0.6
DefaultTimeMessageClass=Botpack.TimeMessage
DefaultPreset=DM/Team DeathMatch
DefaultMap=DM-Deck16
ServerAddress=
DataPort=0
ClientDataPort=0
bManageServerPackages=False
bUseServerPackagesCompatibilityMode=False
bUseServerActorsCompatibilityMode=False
PresetProbeDepth=1
IdleTimeout=0
GameNameMode=GNM_DoNotModify
bAlwaysUseDefaultPreset=True
bAlwaysUseDefaultMap=False
DefaultPackages=SoldierSkins
DefaultPackages=CommandoSkins
DefaultPackages=FCommandoSkins
DefaultPackages=SGirlSkins
DefaultPackages=BossSkins
DefaultPackages=Botpack
DefaultActors=IpDrv.UdpBeacon
DefaultActors=UWeb.WebServer
DefaultActors=IpServer.UdpServerQuery
DefaultActors=IpServer.UdpServerUplink MasterServerAddress=utmaster.epicgames.com MasterServerPort=27900
DefaultActors=IpServer.UdpServerUplink MasterServerAddress=333networks.com MasterServerPort=27900
DefaultActors=IpServer.UdpServerUplink MasterServerAddress=unreal.epicgames.com MasterServerPort=27900

```

1. [GameEndedVoteDelay](#gameendedvotedelay)
1. [VoteTimeLimit](#votetimelimit)
1. [MidGameVoteThreshold](#midgamevotethreshold)
1. [MidGameVoteTimeLimit](#midgamevotetimelimit)
1. [VoteEndCondition](#voteendcondition)
1. [bRetainCandidates](#bretaincandidates)
1. [MultiRoundGameModes](#multiroundgamemodes)
1. [MinimumRepeatDistance](#minimumrepeatdistance)
1. [KickVoteThreshold](#kickvotethreshold)
1. [DefaultTimeMessageClass](#defaulttimemessageclass)
1. [DefaultPreset](#defaultpreset)
1. [bAlwaysUseDefaultPreset](#balwaysusedefaultpreset)
1. [DefaultMap](#defaultmap)
1. [bAlwaysUseDefaultMap](#balwaysusedefaultmap)
1. [ServerAddress](#serveraddress)
1. [DataPort](#dataport)
1. [ClientDataPort](#clientdataport)
1. [bManageServerPackages](#bmanageserverpackages)
1. [bUseServerPackagesCompatibilityMode](#buseserverpackagescompatibilitymode)
1. [bUseServerActorsCompatibilityMode](#buseserveractorscompatibilitymode)
1. [PresetProbeDepth](#presetprobedepth)
1. [IdleTimeout](#idletimeout)
1. [DefaultPackages](#defaultpackages)
1. [DefaultActors](#defaultactors)
1. [GameNameMode](#gamenamemode)

#### GameEndedVoteDelay

Number of seconds to wait before opening the map vote menu at the end of the game.

Defaults to 5.

#### VoteTimeLimit

Number of seconds players have to vote for the next map.

Defaults to 30.

#### MidGameVoteThreshold

Fraction of eligible players that have to have voted before mid-game voting is initiated.

Defaults to 0.5.

#### MidGameVoteTimeLimit

Number of seconds players have to vote for the next map while the current map is still being played. If 0 or less, VoteTimeLimit will be used instead.

Defaults to 0.

#### VoteEndCondition

Controls how votes can end. Supported values are:

* `VEC_TimerOnly`  
Votes always end after the timer runs out
* `VEC_TimerOrAllVotesIn`  
Votes end after the timer runs out, or sooner if all eligible voters have cast their vote
* `VEC_TimerOrResultDetermined`  
Votes end after the timer runs out, or sooner if the outstanding votes can no longer influence the result.

Defaults to `VEC_TimerOnly`.

#### bRetainCandidates

If true, candidates that no longer have any votes for them get retained. If false, candidates with no votes disappear from the list.

Defaults to false.

#### MultiRoundGameModes

List of game modes that are played over multiple rounds with restarts in between. You can specify either the full name of the gamemode class (Package.ClassName), or just the name of the class.

VoteSys will not detect end of game until `bDontRestart` is set to `True` on the GameInfo object.

List contains "Botpack.Assault" by default.

#### MinimumRepeatDistance

Number of different maps that must be played before being able to play the current map again.

Same map, but a different preset does not count as the same map for the purposes of this check.

Defaults to 0.

#### KickVoteThreshold

Fraction of eligible players that have to be in favor of kicking another player for that player to be kicked.

Default is 0.6

#### DefaultTimeMessageClass

Specifies a message class that is used when the PlayerPawn class is not based on TournamentPlayer.

Defaults to Botpack.TimeMessage.

#### DefaultPreset

Specifies the preset thats selected by default should the server not know what preset was voted last. Uses a [full preset name](#full-preset-names). If empty, the first detected preset will be selected as default preset.

Empty by default.

#### DefaultMap

Specifies the map that VoteSys should switch to when using `DefaultPreset`. If empty, a random map will be selected. Map must be part of the map list for `DefaultPreset`, otherwise it will be treated as if no map was specified.

Empty by default.

#### ServerAddress

Specifies the address that clients will connect to for VoteSys data transfer. If empty, clients will reuse the address they connected to.

Empty by default.

#### DataPort

Specifies the TCP port on the server to listen on for connections by clients.

Use this if you are running behind a firewall and need to explicitly allow connections on specific TCP ports.

Values less than 1024 should not really be used as they might fail to bind (check server log if you suspect this). 0 lets VoteSys grab a random port (greater than 1024).

0 by default.

#### ClientDataPort

Specifies the port clients should connect to, in order to receive preset data.

Useful when there is a proxy between clients and the game server. Both `DataPort` and `ClientDataPort` must be non-zero for `ClientDataPort` to be used.

Clients will connect to `ClientDataPort`, the server will listen on `DataPort`, and the proxy in between client and server will need to forward connections on `ClientDataPort` to the server on `DataPort`.

If `DataPort` is 0 or specifies a port that cannot be used, `ClientDataPort` will be disregarded. This means clients will try to connect on the same port as the one the server is listening on.

0 by default.

#### bManageServerPackages

If True, VoteSys will automatically adjust the ServerPackages depending on the currently running preset.
If False, VoteSys will not adjust ServerPackages at all.

Defaults to False.

Prior to 469c, automatically adjusting ServerPackages requires modifying the INI, which VoteSys will do automatically. DefaultPackages is used to restore a clean state. If you as server admin want to add new packages to the list of ServerPackages, you should add them to DefaultPackages instead.

On 469c and later modifying the INI is no longer required.

Only Packages that do **not** have the ServerSideOnly flag set are added to ServerPackages automatically.

#### bUseServerPackagesCompatibilityMode

If True, VoteSys will always use the INI (even on 469c or later servers) to change the ServerPackages.

This setting is irrelevant if `bManageServerPackages` is False.

Defaults to False.

#### bUseServerActorsCompatibilityMode

If True, VoteSys will modify the ServerActors list to spawn the Actors specific to a preset. DefaultActors is used to restore a standard list of ServerActors to add the preset's ServerActors to.
If False, VoteSys will spawn the presets Actors itself.

Defaults to False.

Only set to True if you want to use at least one ServerActor that does not work correctly without this option set to True, but does work correctly when activated statically through the ServerActors list.

#### PresetProbeDepth

Controls how many consecutive presets must have an empty `PresetName` before VoteSys stops probing. Settings lower than 1 will be reset to 1.

If you have gaps in your list of presets, you can modify this setting to skip over those gaps.

1 by default.

#### IdleTimeout

How long in seconds the server will wait before switching to DefaultPreset if there are no players on the server (spectators dont count).

If the value is 1 or less the server will wait indefinitely.

0 by default.

#### DefaultPackages

Filled in automatically after `bManageServerPackages` is set to True. While that setting is True, edit this list to change the static `ServerPackages`.

The format for this variable matches that of `ServerPackages` in the UT INI: One package per line. You cannot combine multiple packages in a single `DefaultPackages` entry.

By default no entries for this variable exist.

#### DefaultActors

Filled in automatically after `bUseServerActorsCompatibilityMode` is set to True. While this setting is True, edit this list to change the static `ServerActors`.

The format for this variable matches that of `ServerActors` in the UT INI: One Actor per line. You cannot combine multiple actors in a single `DefaultActors` entry.

By default no entries for this variable exist.

#### GameNameMode

Controls how the GameName property of game modes is changed by VoteSys. Valid values are:
* `GNM_DoNotModify` - VoteSys will not modify GameName
* `GNM_PresetName` - VoteSys will write the name of the current preset into GameName
* `GNM_CategoryAndPresetName` - VoteSys will write the full preset name into GameName

Defaults to `GNM_DoNotModify`.

#### bAlwaysUseDefaultPreset

If true, uses `DefaultPreset` setting whenever switching maps without any votes by players.  
If false, only uses `DefaultPreset` setting when recovering from crashes or server restarts. Uses the the current preset instead if no player voted at the end of a match.

Defaults to true.

#### bAlwaysUseDefaultMap

If true, uses the `DefaultMap` setting whenever switching maps without any votes by players.  
If false, only uses the `DefaultMap` setting when recovering from crashes or server restarts.

If `bAlwaysUseDefaultPreset` is false, this setting has no effect in order to avoid switching to maps that do not exist for the automatically selected preset.

Defaults to false.

### VoteSysPresets.ini
```ini
[VS_PresetConfig0]
PresetName=DeathMatch
Abbreviation=DM
Category=DM
SortPriority=15
Game=Botpack.DeathMatchPlus
MapListName=CustomMapList
Mutators=
Parameters=
GameSettings=

[VS_PresetConfig1]
PresetName=Team DeathMatch
Abbreviation=TDM
Category=DM
SortPriority=30
Game=Botpack.TeamGamePlus
MapListName=
Mutators=UTPureRC7H.UTPure,UTPureRC7H.PureAutoPause
Parameters=?MaxPlayers=8
Parameters=?TimeLimit=15
GameSettings=bTournament=True
GameSettings=bAllowTranslocator=True
bDisabled=False
MinimumMapRepeatDistance=2

[VS_PresetConfig2]
PresetName=2v2v2v2 TDM
Abbreviation=xTDM
Category=DM
InheritFrom=DM/Team DeathMatch
GameSettings=MaxTeams=4
Mutators=Botpack.InstaGibDM
MinimumMapRepeatDistance=4
MinPlayers=4
MaxPlayers=8
```

Each preset is a different section inside VoteSysPresets.ini (e.g. `[VS_PresetConfig0]`, `[VS_PresetConfig1]`, etc.). Each preset section needs to start with VS_PresetConfig, followed by a number. The number needs to start from 0 and can go as high as you want. You can not leave out numbers.

#### Preset Identification
Each preset has a `Name`, a `Category` and an `Abbreviation`.  
`Category` and `Name` are used to uniquely identify presets, so you may not have two presets with the same `Category` and `Name`.  
`Category` and `Abbreviation` may be blank.  
`Name` may not be blank.

#### Inheriting From Other Preset
`InheritFrom` is used to inherit certain elements from other presets.

You can inherit from an arbitrary number of other presets.  
Refer to other preset using their [full preset names](#full-preset-names).

You can inherit `Game`, `Mutators`, `Parameters`, `GameSettings`, `MinimumMapRepeatDistance`, `MinPlayers`, and `MaxPlayers`. Other elements cannot be inherited.

If you dont specify a value for `Game` in the current preset, the first non-empty value in the list of presets you inherit from will be used.

If you dont specify a value, or if you specify a negative value for `MinimumMapRepeatDistance`, `MinPlayers`, or `MaxPlayers` in the current preset, the first non-empty and non-negative value in the list of presets you inherit from will be used.

For `Mutators`, `Parameters`, and `GameSettings` the values will be combined in the same order you specified the base presets. If you specify any addition values in the current preset, they will be added at the end.

#### Sort Priority
`SortPriority` can be used to make presets appear above others within a category. Higher values mean the preset will appear higher in the list.

Default is 0.

#### Game Type
`Game` is used to identify the gametype for the preset. It must not be blank for enabled presets.

#### Map List
`MapListName` can be used to specify a custom list of maps that can be used with the preset. If `MapListName` is blank, all maps for the specified gametype are used.

#### Mutators
`Mutators` can be used to specify both Mutators and ServerActors.

```
Mutators=Package1.ExampleMutator1
Mutators=Package2.ExampleMutator2
```
is equivalent to
```
Mutators=Package1.ExampleMutator1,Package2.ExampleMutator2
```

#### Parameters
Can be used to specify URL parameters.
```
Parameters=?Parameter1=Value1
Parameters=?Parameter2=Value2
```
is equivalent to
```
Parameters=?Parameter1=Value1?Parameter2=Value2
```

#### Game Settings
Can be used to specify changes to the gametype from the defaults.
```
GameSettings=Variable1=Value1
GameSettings=Variable2=Value2
```
is equivalent to
```
GameSettings=Variable1=Value1,Variable2=Value2
```

#### Packages
Can be used to specify additional packages that need to exist on clients. This setting has no effect if `bManageServerPackages` is False.
```
Packages=Package1
Packages=Package2
```
is equivalent to
```
Packages=Package1,Package2
```

#### bDisabled

If `True` the preset will not be shown to users and will not be eligible to become the default preset if [`DefaultPreset`](#defaultpreset) is empty.

This setting does not need to be mentioned explicitly. Its default value will be used if it is not mentioned.

Default is `False`.

#### MinimumMapRepeatDistance

Specifying this setting allows you to override the server-wide setting on a per-preset basis. If not specified and not inherited from other presets, the server-wide setting will be used.

#### MinPlayers

Specifies the minimum number of players that have to be present on the server in order to be allowed to vote for this preset.

#### MaxPlayers

Specifies the maximum number of players that can be present on the server to still be allowed to vote for this preset.

### VoteSysMapLists.ini
```ini
[CustomMapList]
Map=DM-Deck16][
Map=DM-Agony
Map=DM-StalwartXL,MinPlayers=4,MaxPlayers=8
Map=DM-Morpheus

[CustomMapListNoAgony]
IncludeList=CustomMapList
IgnoreMap=DM-Agony

[DMMapsNotInCustomMapList]
IncludeMapsWithPrefix=DM-
IgnoreList=CustomMapList

[BTMaps]
Map=CTF-AwesomeBTMap
IncludeMapsWithPrefix=CTF-BT+
IncludeMapsWithPrefix=CTF-BT-

[CTFbutNotVCTFNorBTMaps]
IncludeMapsWithPrefix=CTF-
IgnoreMapsWithPrefix=CTF-XV-
IgnoreList=BTMaps
```
Map lists are specified in this file. To build the map list, VoteSys will first gather up all included maps, and then will remove any ignored maps. Ignored maps will always take precedence over included ones, and the ordering of included vs. ignored ones will not make a difference. If you want to include a map that was previously ignored, you can make another map list that includes it and the map list in question.

#### Map/IgnoreMap
Specify individual maps to add or remove from the map list.

You can append `,MinPlayers=` followed by a number in order to specify that at least this many players need to be on the server to vote for this map.  
You can append `,MaxPlayers=` followed by a number in order to specify that at most this many players can be on the server to vote for this map. Values less than 1 are interpreted as unlimited.  
You can append both at the same time in any order.

#### IncludeMapsWithPrefix/IgnoreMapsWithPrefix
Adds or removes all maps that match a specified prefix from the map list.

#### IncludeList/IgnoreList
Adds or removes all maps in another map list from the map list.

## Build
In order to build this mutator, you need to be using UT99 v469c.

1. Go to the installation directory of UT99 in a command shell
2. Use `git clone https://github.com/Deaod/VoteSys` to clone the repo
3. Navigate to the newly created directory `VoteSys`
4. Execute `Build.bat`
5. The result of the build process will be available in the `System` folder that is next to `Build.bat`
