# Configuring ACE

This document describes how to configure ACE on a per-preset basis. If you don't know what ACE is, this document is probably not relevant to you.

Please back up your original configuration files before any modifications. You will need them, should something go wrong.

ACE is not intended to be turned off and on while a server is running. You can do it, but its not straightforward.

Changing the version of ACE you want to run without restarting the server leads to clients being disconnected due to internal ACE errors.

## 1. Preparing ServerActors Compatibility Mode

Look at UnrealTournament.ini in your System directory and find the following:  
```ini
[Engine.GameEngine]
ServerActors=...
```

Copy all lines starting with `ServerActors=` to the end of VoteSys.ini (do not leave empty lines), then replace `ServerActors=` at the start of each line with `DefaultActors=`.

Delete all Actors from the new list of `DefaultActors` that are related to ACE (NPLoader_\[...\], ACE\[...\]\_S, ACE\[...\]\_EH).

Finally, change the setting `bUseServerActorsCompatibilityMode` in VoteSys.ini to `True`.

## 2. Preparing ServerPackages

In UnrealTournament.ini, remove all `ServerPackages=` lines that contain packages related to ACE and NPLoader.

Then change `bManageServerPackages` to `True` in VoteSys.ini

## 3. Preparing NPLoader

In UnrealTournament.ini look for section `[NPLoader_[...].NPLActor]` (make sure the youre picking the right one for the ACE version you want to run).

In that section move all classes in the `ModInfoClasses` array to the `IgnoredClasses` array a bit further down in the same section.

After this, no classes should remain in the `ModInfoClasses` array.

## 4. Adding An ACE Preset

Use the following template to add a new preset for ACE to your list of presets:  
```ini
[VS_PresetConfig0]
PresetName=1.3b
Category=ACE
bDisabled=True
Mutators=NPLoader_v19b.NPLActor ModInfoClasses=ACEv13b_S.ACEInfo
Mutators=ACEv13b_S.ACEActor
Mutators=ACEv13b_EH.ACEEventActor
Packages=NPLoader_v19b
Packages=NPLoaderLLU_v18b
Packages=NPLoaderLLD_v18b
Packages=NPLoaderLLS_v18b
Packages=NPLoaderLLDL_v18b
Packages=ACEv13b_Cdll
Packages=IACEv13
Packages=ACEv13b_C
```

Make sure the number after `VS_PresetConfig` is unique within VoteSysPresets.ini and that there are no gaps between numbers.

Modify this template for different ACE versions.  
ACE v1.2e (the latest publicly released version) uses the same NPLoader version as v1.3b, so you just need to replace the ACE version here.  
ACE 1.1f uses a different NPLoader version. You should install ACE using ACE's installation instructions and then see what changed in your UnrealTournament.ini to figure out the detailed list of packages and Actors you need to add.

Remember that `Mutators=` lines in presets works with both Actors and actual Mutators.

## 5. Using The ACE Preset

Use the `InheritFrom=` setting of presets to add the ACE preset you created in the last step to presets players can vote for.

```ini
[VS_PresetConfig1]
PresetName=CTF 5v5
Category=CTF
Game=NewCTF_v17.NewCTF
InheritFrom=ACE/1.3b
GameSettings=MaxPlayers=10
GameSettings=TimeLimit=20
GameSettings=MaxSpectators=10
GameSettings=bTournament=True
GameSettings=bUseTranslocator=False
GameSettings=bAllowOvertime=True
```

## Limitations

It bears repeating that you may not switch ACE versions without restarting the server. The only configurability possible at the moment is switching a single ACE version off and on.
