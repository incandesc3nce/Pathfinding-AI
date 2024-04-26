# Lua Pathfinding AI 

Small project I've done during my winter break.

This is a script that adds pathfinding AI to any NPC or a dummy with some waypoints to roam around given map.
Bot walks to given waypoints (patrolling state) using the shortest available path and searches for players.

If the bot detects a player around it, it enters the "chase state" and tries to neutralize the player by utilising shortest path to it's last known position.
If the player manages to outrun or hide from the bot, it walks to it's last known position. Once the bot reaches the position and no player is present there,
it enters the "patrolling state" and continues to roam around random waypoints.