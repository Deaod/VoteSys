# VoteSys
A new, independent implementation of map vote.

* Unlimited number of presets
* Unlimited number of maps
* Quicker transfer of data to clients
* Automatic management of ServerPackages
  * Opt-in ([`bManageServerPackages`](Docs/setup.md#bmanageserverpackages))
  * Before server version 469c [`DefaultPackages`](Docs/setup.md#defaultpackages) have to be configured correctly
  * With 469c or later no further configuration is necessary
* Map repeat limits ([`MinimumMapRepeatDistance`](Docs/setup.md#minimummaprepeatdistance))

Servers must run at least UT v469.  
Clients must run at least UT v436.  
Admin UI functionality also requires at least UT v469 clients.

## [UI Documentation](Docs/ui.md)

## Installation
1. Make sure the VoteSys .u and .int files are in the System folder
2. Add VoteSys mutator to URL when starting the server
3. Add VoteSys to list of ServerPackages in INI
4. If your server has a firewall:
    1. Open a TCP port in it
    2. Set [`DataPort`](Docs/setup.md#dataport) to the port you just opened
5. If you have proxy servers for players to connect to:
    1. Set [`ServerAddress`](Docs/setup.md#serveraddress) to the actual address of your server
    2. Set [`DataPort`](Docs/setup.md#dataport) to a port of your choice, if you did not set it already

## [Server Configuration](Docs/setup.md)

## Build
In order to build this mutator, you need to be using UT99 v469d or later.

1. Go to the installation directory of UT99 in a command shell
2. Use `git clone https://github.com/Deaod/VoteSys` to clone the repo
3. Navigate to the newly created directory `VoteSys`
4. Execute `Build.bat`
5. The result of the build process will be available in the `System` folder that is next to `Build.bat`
