/*
	Author: Myth

    Locality: Server.

	Description:
		Evaluates if MTI marker needs to be created or updated based on passed targets.

	Parameter(s):
		0: <OBJECT> - The AV.
		0: <ARRAY> - The final targets passed by MM_fnc_collectMTI. These do not need to be sorted by range at this point.

	Returns:
		BOOLEAN - Completion flag.

	Examples:
		[_myGlobalHawk, [tank_1, car_69]] call MM_fnc_handleMTIMarker
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

params [
	["_gh", objNull, [objNull]],
	["_finalTargets", [], [[]]]
];

// DEBUG LVL 3
LOG(format ["MM_fnc_handleMTIMarker, %1: Started - Params: %1, %2", _gh, _finalTargets]);

// ---------------------------------
// Create or Update Marker Evaluation
// ---------------------------------

// Evaluate if targets have markers made. If no marker exists, run MM_fnc_createMTIMarker.
{
	private _markerExists = _x getVariable ["RQ4Tweak_mtiMarkerParams", []];
	if ( _markerExists isEqualTo [] ) then {
		[_gh, _x] call MM_fnc_createMTIMarker;

		// DEBUG LVL 3
		LOG(format ["MM_fnc_handleMTIMarker, %1: Target %2 has no MTI marker, creating new marker.", _gh, _x]);
	} else {
		[_gh, _x] call MM_updateMTIMarker;

		// DEBUG LVL 3
		LOG(format ["MM_fnc_handleMTIMarker, %1: Target %2 already has an MTI marker, updating params.", _gh, _x]);
	};
} forEach _finalTargets;

// ---------------------------------
// Returns and End
// ---------------------------------

// DEBUG LVL 3
LOG(format ["MM_fnc_handleMTIMarker, %1: Complete.", _gh]);

true;