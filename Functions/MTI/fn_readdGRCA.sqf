/*
	Author: Myth

    Locality: Pilot's computer.

	Description:
		Re-adds the GRCAs to the map that presently exist on the server. Used when a pilot connects to a AV that has been used before.

	Parameter(s):
		0: <OBJECT> - The AV.

	Returns: BOOLEAN, completion flag.

	Examples:
		["GRCA_BOX_1", [123,999], "_USER_DEFINED_GRCA_1_1", [321, 420]] call MM_fnc_readdGRCA;
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_handlePilot";

params [
	["_grcaID", "", [""]],
	["_areaCenterTrue", [0, 0], [[0, 0]]],
	["_bottomRightMarker", "", [""]],
	["_dotPos", [0, 0], [[0, 0]]]
];

// DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1, %2, %3, %4]", _grcaID, _areaCenterTrue, _bottomRightMarker, _dotPos];
DEBUG_RPT(_msg, _curFunc);

// ---------------------------------
// Create the markers on the pilot's computer
// ---------------------------------

private _existingGrca = createMarkerLocal [_grcaID, _areaCenterTrue];
_existingGrca setMarkerShapeLocal "RECTANGLE";
_existingGrca setMarkerColorLocal "#(0, 0, 1, 1)";
_existingGrca setMarkerAlphaLocal 0.3;

// Create the bottom right marker.
private _exitingBottomRightMarker = createMarkerLocal [_bottomRightMarker, _dotPos];
_exitingBottomRightMarker setMarkerTypeLocal "mil_dot";
_exitingBottomRightMarker setMarkerTextLocal format ["GRCA %1", (_grcaID splitString "_") select 2];

true;