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

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_handleMTIMarker";

params [
	["_gh", objNull, [objNull]],
	["_finalTargets", [], [[]]]
];

// DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1, %2]", _gh, _finalTargets];
DEBUG_RPT(_msg, _curFunc);

// ---------------------------------
// Create or Update Marker Evaluation
// ---------------------------------

// Evaluate if targets have markers made. If no marker exists, run MM_fnc_createMTIMarker.
{
	private _markerExists = _x getVariable ["RQ4Tweak_mtiMarkerParams", []];
	if ( _markerExists isEqualTo [] ) then {
		// DEBUG LVL 3
		private _msg = format ["%1: Target %2 has no MTI marker, creating new marker.", _gh, _x];
		DEBUG_RPT(_msg, _curFunc);

		[_gh, _x] call MM_fnc_createMTIMarker;
	} else {
		// DEBUG LVL 3
		private _msg = format ["%1: Target %2 already has an MTI marker, updating params.", _gh, _x];
		DEBUG_RPT(_msg, _curFunc);
		[_gh, _x] call MM_fnc_updateMTIMarker;
	};
} forEach _finalTargets;

// ---------------------------------
// Returns and End
// ---------------------------------

// DEBUG LVL 3
private _msg = format ["%1: All passed targets complete.", _gh];
DEBUG_RPT(_msg, _curFunc);

true;