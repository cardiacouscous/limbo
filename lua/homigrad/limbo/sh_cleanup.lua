-- Limbo: corpse and dropped weapon cleanup (settings, shared so the settings menu can read them)

local flags = bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY)

CreateConVar("limbo_cleanup", "1", flags, "Remove old corpses and dropped weapons", 0, 1)
CreateConVar("limbo_cleanup_time", "10", flags, "Minutes before a corpse or dropped weapon can be removed", 1, 60)
CreateConVar("limbo_cleanup_keeplast", "1", flags, "Each player's latest corpse (and the gear on it) is never removed until they die again", 0, 1)
CreateConVar("limbo_cleanup_radius", "1000", flags, "Nothing is removed while a living player is this close (0 = ignore distance)", 0, 10000)
