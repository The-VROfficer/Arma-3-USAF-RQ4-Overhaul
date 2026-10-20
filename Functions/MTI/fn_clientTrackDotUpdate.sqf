/*
	Author: Myth

    Locality: Local, MTI recipient's machine.

	Description:
		Creates/updates track dots for the passed MTI target. Track dots only appear on the local client's map.

	Parameter(s):
		0: <OBJECT> - The AV (globally defined).
		1: <OBJECT> - The target to have an MTI marker created for (globally-defined).
		2: <ARRAY> - The results of BIS_fnc_markerParams, as passed by fn_updateMTIMarker.

	Returns:
		Nothing.

	Examples:
		[myGlobalHawk, mrap_1] spawn MM_fnc_clientTrackDotUpdate
*/

#define DEBUG_ENABLED

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_clientTrackDotUpdate";

params [
	["_gh", objNull, [objNull]],
	["_target", objNull, [objNull]],
	["_trackDotMarkerParams", [], []]
];

// DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1, %2, %3]", _gh, _target, _trackDotMarkerParams];
DEBUG_RPT(_msg, _curFunc);

_trackDotMarkerParams params ["_varName", "_pos", "_size", "_color", "_type", "_brush", "_shape", "_alpha", "_text"];

// ---------------------------------
// Create track dot and handle fade logic
// ---------------------------------

private _trackDotClient = createMarkerLocal [_varName select 0, _pos];
_trackDotClient setMarkerColorLocal _color;
_trackDotClient setMarkerTypeLocal "mil_dot";

[_trackDotClient] spawn {
	params ["_trackDotClient"];

	private _markerOpacity = 1.0;

	// Create loop to fade out marker. There's no stopping it.
	while { _markerOpacity > 0.01 } do {
		_markerOpacity = (_markerOpacity - 0.05) max 0;
			
		_trackDotClient setMarkerAlphaLocal _markerOpacity;

		sleep 1;
	};
};