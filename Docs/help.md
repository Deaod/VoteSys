# Troubleshooting VoteSys

Click on a link that most closely describes your problem:

1. VoteSys crashes my server
1. `mutate votemenu` does not open the UI

If you cant find your problem, [please report it directly](#reporting-issues).

## VoteSys crashes my server

Make sure your server is running UT v469a or newer. Older versions cannot run VoteSys.

To verify the version, open the servers log file and look for "Init: Version:" near the top of the file. If what follows on the same line is not 469 or a higher number, this server is incompatible with VoteSys.

You might need to contact your server provider to ask them to upgrade your server version.

## `mutate votemenu` does not open the UI

1. Make sure VoteSys is being loaded by the server
    1. Look at server log and see if any lines starting with "VoteSys" appear
    1. If not, make sure you have followed the [installation instructions](../README.md#installation)
    1. If you followed the installation instructions and the problem persists, [please report it](#reporting-issues)
    1. If you servers log contains messages starting with "VoteSys", proceed
1. [Disable custom data transport](setup.md/#benablecustomdatatransport)

## Reporting Issues

Choose one of the following ways, in order of preference:
* Go to https://github.com/Deaod/VoteSys/issues and open a new issue
* Join the [Discord Server](https://discord.gg/5wWAGHRvMC) and ask for help

Please include as much information as possible, including:
* What you wanted to achieve
* What you did, in as much detail as youre willing to provide
* What you expected to happen after your actions
* What actually happened
* Command used to start the server
* Server log
* Player log (UnrealTournament.log, if applicable)

Be aware that **Issues on GitHub are publicly visible**, so be careful about sharing log files as they may include details you would not ordinarily wish to share.
