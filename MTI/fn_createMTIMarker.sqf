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

// Determine if the TOI counter for this AV exists, if not, define it here.
private _totalTOIs = _gh getVariable ["RQ4Tweak_totalTOIs", []];

if ( _totalTOIs isEqualTo [] ) then {
	// DEBUG LVL 3
	LOG(format ["MM_fnc_createMTIMarker, %1: Variable 'RQ4Tweak_totalTOIs' has not yet been defined for AV %1. Defining now.", _gh]);

	_gh setVariable ["RQ4Tweak_totalTOIs", 0, true];
};

// Begin constructing naming structure for the MTI mark.
private _toiStart = MM_RQ4_TOI_Num;
private _spotTimeData = _target getVariable ["RQ4Tweak_lastSeen", []];

// Add undefined RQ4Tweak_lastSeen variable protection.
if ( _spotTimeData isEqualTo [] ) exitWith {
	// DEBUG LVL 2
	WARNING(format ["MM_fnc_createMTIMarker, %1: Abnormal exit, variable 'RQ4Tweak_lastSeen' is undefined for target %2.", _gh, _target]);
};

// Call _totalTOIs again to clear stale data and get most up-to-date values.
private _totalTOIs = _gh getVariable "RQ4Tweak_totalTOIs";

private _combinedName = "TOI " + (str (_totalTOIs + 1)) + (format [" [%1:%2]", _spotTimeData select 0, _spotTimeData select 1]);

// ---------------------------------
// 
// ---------------------------------