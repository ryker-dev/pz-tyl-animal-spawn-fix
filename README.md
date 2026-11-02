# 10 Years Later Animal Spawn Fix
Fixes the game kicking you to the main menu with this error when playing with 10 YEARS LATER [Unofficial] on Build 42:
Cannot read field "turnDelta" because "this.adef" is null at IsoAnimal.update

# What's going on
10 Years Later spawns animals on outdoor tiles as the map loads, but doesn't check for water. When an animal gets spawned on a water tile, the game adds it to the world and then stops setting it up, leaving an uninitialized animal. The next time the game updates it, it crashes.

# What this does
Blocks animal spawns on water tiles (those would end up broken anyway)
Removes any animal that still comes back uninitialized
Logs blocked spawns to the console, tagged [TYLAnimalSpawnFix]
Everything else spawns as normal. The game's own animal spawning isn't touched.

# Compatibility
Build 42 (made on 42.21)
Singleplayer and multiplayer (runs on the server)
Safe to add or remove mid-save
Load order doesn't matter

**Workshop ID:** 3829652526
**Mod ID:** TYLAnimalSpawnFix
