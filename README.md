

# From the Docs website in case it goes down as well

I am/was (not even sure) a admin on the Prefech Discord. I am not sure what is going on with Prefech/JokeDevil but I wanted to upload these for those that need it. If you have a updated version please let me know so I can update this but this should be working and I do not remember if I changed the code much or not sorry. 
  

## Requirements
-   A Discord Server
-   FXServer

Optional:  screenshot-basic (If you want to use screenshot logs or want to use the  `/screenshot [id]`  command.)

## Main Features
-   Basic logs:
    -   Chat Logs (Messages typed in chat.)
    -   Join Logs (When i player is connecting to the sever.)
    -   Leave Logs (When a player disconnects from the server.)
    -   Death Logs (When a player dies/get killed.)
    -   Shooting Logs (When a player fires a weapon.)
    -   Resource Logs (When a resouce get started/stopped.)
    -   Explotion Logs (When a player creates an explotion.)
    -   Namechange Logs (When someone changes their steam name.)
-   Screenshot Logs (You can add screenshot of the players game to your logs.)
-   Logs with or without embeds.
-   Optional custom logs
    -   Easy to add with the export.
-   ~~Global ban list to keep those known cheaters out!~~ Cant use this no API anymore
-   Anti cheat functions *I dont remember if the AC uses API or not, use at your own will. If it doesnt work dont use it*
    -   Blacklisted Vehicles (Keep everyone out of certain vehicles.)
    -   Blacklisted Commands (To make sure people don’t inject their own “fancy” commands.)
    -   Blacklisted Objects (Get those racing ramps off your server!)
    -   Blacklisted Keys (Opening a mod menu? lets screenshot that!)

# Installation
1.  Download the latest version from here. *Note: If you have a more up to date version PLEASE SHARE!!*
2.  Put the JD_logs folder in the server resource directory
    -   Make sure to remove the  **-master**  from the folder.
3.  Add this to your server.cfg

```
ensure JD_logs
```

4.  Navigate to the config file:  **config/config.json**.
5.  Update the settings in the config to your liking.
6.  Navigate to the webhooks file:  **config/webhooks.json**.
7.  Add webhooks from discord and set the channel options to your liking
    -   ~~Not sure how to make a webhook have a look here:  [https://forum.prefech.com/d/17-creating-discord-webhooks](https://forum.prefech.com/d/17-creating-discord-webhooks)~~
8.  Restart your server and you should see the logs on your discord.
  
 # Configuration

After you have installed JD_logs you can open the config file and change the settings to your needs. You will find the config file in the config folder.

When you just installed JD_logs your config should look like this:

```json
{
    "locals": "en",

    "EnableAcFunctions": true,

    "allLogs": true,
    "postals": true,
    "weaponLog": true,
    "inlineField": true,

    "playerId": true,
    "steamId": true,
    "steamUrl": true,
    "discordId": true,
    "license": true,
    "license2": true,
    "ip": true,
    "playerPing": true,

    "Session": false,
    "PlayTime": false,
    "playerHealth": true,
    "playerArmor": true,
    "timestamp": true,

    "forceSteam": false,

    "nameChangePerms": "jd.staff",
    "logHistoryPerms": "jd.staff",
    "screenshotPerms": "jd.staff",
    "AntiCheatBypass": "jd.staff",

    "DiscordUpdateNotify": true,

    "userName": "Bot Username Here",
    "avatar": "https://via.placeholder.com/30x30",
    "communityName": "Community Name Here",
    "communityLogo": "https://via.placeholder.com/30x30",
    "footerText": "2020 - 2021 © Prefech",
    "footerIcon": "https://via.placeholder.com/30x30",

    "WeaponsNotLogged": [
        "WEAPON_SNOWBALL",
        "WEAPON_FIREEXTINGUISHER",
        "WEAPON_PETROLCAN"
    ],

    "Commands": {
        "logs": ["logs", "lh"],
        "screenshot": ["screenshot", "ss"]
    }
}

```

#### Config settings:

Basic Settings:
![Basic Settings](https://imgur.com/tXK4GoE.png)

![Player Details](https://imgur.com/Qe9yCn1.png)
	
![Additional player details](https://imgur.com/CultErx.png)


![Steam usage settings](https://imgur.com/rKJgbuh.png)
  
  ![Ace Perms Settings](https://imgur.com/d2pGVB3.png)

![Cosmetic Settings for Embeds](https://imgur.com/BjPXtUf.png)

![Not logged weapons](https://imgur.com/wxPCNkD.png)

# Commands

 - logs
	 - Ex: /logs ServerID
		 - Will show you the recent 5 logs made for that user (You can change what channels are kept in the log history.) You need proper perms for this.
- screenshot
	- Ex: /screenshot ServerID
		- Will make a screenshot of the target player and send them to discord. (You need the proper perms)


# How to log

```lua
exports.JD_logs:createLog({
      EmbedMessage = "EMBED MESSAGE",
      player_id = SERVER_ID_PLAYER_ONE,
      player_2_id = SERVER_ID_PLAYER_TWO,
      channel = "CHANNEL FROM WEBHOOKS CONFIG",
      screenshot = true
})
```
*If you change the name of the resource make sure you update that on the logs export as well*
  

### EmbedMessage: This can be anything you want it to say.

- You can even use variables in it as long as they contain a value.

### player_id: This will be the server id of the first player.

- If you don’t have a first player you can remove this.

### player_2_id: This will be the server id of the second player.

- If you don’t have a second player you can remove this.

### channel: This will be the channel you have set in the config/webhooks.json

- This is NOT a webhook url you have to place that in the config/webhooks.json

### screenshot: this can be either true or false it will add a screenshot to embeds

- You need to have embeds enabled on the channel to see screenshots!