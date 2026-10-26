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
private _curFunc = "MM_fnc_readdGRCA";

params [
	["_grca", "", [""]],
	["_grcaID", -1, [-1]],
	["_areaCenterX", -1, [-1]],
	["_areaCenterY", -1, [-1]],
	["_areaCenterTrue", [0, 0], [[0, 0]]],
	["_bottomRightMarker", "", [""]],
	["_dotPos", [0, 0], [[0, 0]]]
];

// DEBUG LVL 3
private _msg = format ["Started - Params: [%1, %2, %3, %4, %5, %6, %7]", _grca, _grcaID, _areaCenterX, _areaCenterY, _areaCenterTrue, _bottomRightMarker, _dotPos];
DEBUG_RPT(_msg, _curFunc);

// ---------------------------------
// Create the markers on the pilot's computer
// ---------------------------------

private _existingGRCA = createMarkerLocal [_grca, _areaCenterTrue];
_existingGRCA setMarkerShapeLocal "RECTANGLE";
_existingGRCA setMarkerSizeLocal [_areaCenterX, _areaCenterY];
_existingGRCA setMarkerColorLocal "#(0, 0, 1, 1)";
_existingGRCA setMarkerAlphaLocal 0.3;

// Create the bottom right marker.
private _exitingBottomRightMarker = createMarkerLocal [_bottomRightMarker, _dotPos];
_exitingBottomRightMarker setMarkerTypeLocal "mil_dot";
_exitingBottomRightMarker setMarkerTextLocal format ["GRCA %1", _grcaID];

true;