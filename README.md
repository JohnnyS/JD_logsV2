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

## EmbedMessage: This can be anything you want it to say.
      - You can even use variables in it as long as they contain a value.
## player_id: This will be the server id of the first player.
      - If you don’t have a first player you can remove this.
## player_2_id: This will be the server id of the second player.
      - If you don’t have a second player you can remove this.
## channel: This will be the channel you have set in the config/webhooks.json
      - This is NOT a webhook url you have to place that in the config/webhooks.json
## screenshot: this can be either true or false it will add a screenshot to embeds
      - You need to have embeds enabled on the channel to see screenshots!