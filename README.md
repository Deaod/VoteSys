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

## Server Setup

Server settings are split between multiple INI files.
* VoteSys.ini
* VoteSysPresets.ini
* VoteSysMapLists.ini

In addition there are INI files that dont contain configuration, but are used to store data between map-changes:

* VoteSysTemp.ini
* VoteSysHistory.ini

### VoteSys.ini
```ini
[ServerSettings]
GameEndedVoteDelay=5
VoteTimeLimit=30
MinimumMapRepeatDistance=0
KickVoteThreshold=0.6
DefaultTimeMessageClass=Botpack.TimeMessage
DefaultPreset=
ServerAddress=127.0.0.1
DataPort=0
bManageServerPackages=False
bUseServerActorsCompatibilityMode=False
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

#### GameEndedVoteDelay

Number of seconds to wait before opening the map vote menu at the end of the game. Defaults to 5.

#### VoteTimeLimit

Number of seconds players have to vote for the next map. Defaults to 30.

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

Specifies the preset thats selected by default should the server not know what preset was voted last.

Empty by default.

#### ServerAddress

Specifies the IP address thats used by clients should the clients be unable to determine the IP address of the server.

Empty by default.

#### DataPort

Specifies the port on the server that clients are supposed to connect to, in order to receive preset data. Values less than 1024 should not really be used as they might fail to bind (check server log if you suspect this). 0 lets VoteSys grab a random port (greater than 1024).

0 by default.

#### bManageServerPackages

If True, VoteSys will automatically adjust the ServerPackages depending on the currently running preset.
If False, VoteSys will not adjust ServerPackages at all.

Defaults to False.

Prior to 469c, automatically adjusting ServerPackages requires modifying the INI, which VoteSys will do automatically. DefaultPackages is used to restore a clean state. If you as server admin want to add new packages to the list of ServerPackages, you should add them to DefaultPackages instead.

On 469c and later modifying the INI is no longer required.

Only Packages that do **not** have the ServerSideOnly flag set are added to ServerPackages automatically.

#### bUseServerActorsCompatibilityMode

If True, VoteSys will modify the ServerActors list to spawn the Actors specific to a preset. DefaultActors is used to restore a standard list of ServerActors to add the preset's ServerActors to.
If False, VoteSys will spawn the presets Actors itself.

Defaults to False.

Only set to True if you want to use at least one ServerActor that does not work correctly without this option set to True, but does work correctly when activated statically through the ServerActors list.

#### DefaultPackages

Filled in automatically after bManageServerPackages is set to True. While that setting is True, edit this list to change the static ServerPackages.

By default no entries for this variable exists.

#### DefaultActors

Filled in automatically after bUseServerActorsCompatibilityMode is set to True. While this setting is True, edit this list to change the static ServerActors.

By default no entries for this variable exists.

### VoteSysPresets.ini
```ini
[VS_PresetConfig0]
PresetName=DeathMatch
Abbreviation=DM
Category=DM
Game=Botpack.DeathMatchPlus
MapListName=CustomMapList
Mutators=
Parameters=
GameSettings=

[VS_PresetConfig1]
PresetName=Team DeathMatch
Abbreviation=TDM
Category=DM
Game=Botpack.TeamGamePlus
MapListName=
Mutators=
Parameters=?MaxPlayers=8
GameSettings=bTournament=True
```

Each preset is a different section inside VoteSysPresets.ini (e.g. `[VS_PresetConfig0]`, `[VS_PresetConfig1]`, etc.). Each preset section needs to start with VS_PresetConfig, followed by a number. The number needs to start from 0 and can go as high as you want. You can not leave out numbers.

#### Preset Identification
Each preset has a `Name`, a `Category` and an `Abbreviation`.  
`Category` and `Name` are used to uniquely identify presets, so you may not have two presets with the same `Category` and `Name`.  
`Category` and `Abbreviation` may be blank.  
`Name` may not be blank.

#### Game Type
`Game` is used to identify the gametype for the preset. It must not be blank.

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

### VoteSysMapLists.ini
```ini
[CustomMapList]
Map=DM-Deck16][
Map=DM-Agony
Map=DM-StalwartXL
Map=DM-Morpheus

[BTMaps]
Map=CTF-AwesomeBTMap
IncludeMapsWithPrefix=CTF-BT+
IncludeMapsWithPrefix=CTF-BT-
```

#### Map
Specify individual maps to add to the map list.

#### IncludeMapsWithPrefix
Adds all maps that match any of the specified prefixes to the map list.

## Build
In order to build this mutator, you need to be using UT99 v469c.

1. Go to the installation directory of UT99 in a command shell
2. Use `git clone https://github.com/Deaod/VoteSys` to clone the repo
3. Navigate to the newly created directory `VoteSys`
4. Execute `Build.bat`
5. The result of the build process will be available in the `System` folder that is next to `Build.bat`