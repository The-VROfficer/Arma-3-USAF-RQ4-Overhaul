/*
	Author: Myth

    Locality: Server.

	Description:
		Creates a new MTI marker on the map for the given target, but only renders the marker for MTI-recipient qualified clients. Also calls functions that add the creation of markers to the JIP queue.

	Parameter(s):
		0: <OBJECT> - The AV.
		0: <OBJECT> - The object to have a MTI marker created for.

	Returns:
		

	Examples:
		[_myGlobalHawk, apc_69] call MM_fnc_createMTIMarker
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

params [
	["_gh", objNull, [objNull]],
	["_target", objNull, [objNull]]
];

// DEBUG LVL 3
LOG(format ["MM_fnc_createMTIMarker, %1: Started - Params: %1, %2", _gh, _target]);

