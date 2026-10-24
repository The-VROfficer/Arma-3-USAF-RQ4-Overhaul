/*
	Author: Myth

    Locality: Local, MTI recipient's machine.

	Description:
		Updates an existing MTI marker on the map for the given target, but the marker only appears on the local client's map.

	Parameter(s):
		0: <OBJECT> - The AV (globally defined).
		1: <OBJECT> - The target to have an MTI marker created for (globally-defined).
		2: <BOOLEAN> - True, script runs logic to create the marker for the very first time. False, the script updates an existing marker.

	Returns:
		Nothing.

	Examples:
		[myGlobalHawk, mrap_1] call MM_fnc_clientMarkerUpdate
*/

#define DEBUG_ENABLED

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_clientMarkerUpdate";

params [
	["_gh", objNull, [objNull]],
	["_target", objNull, [objNull]],
	["_creation", false, [false]]
];

// DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1, %2, %3]", _gh, _target, _creation];
DEBUG_RPT(_msg, _curFunc);	// This log will appear in the user's RPT, not the server's.

// ---------------------------------
// Execute marker creation/update based on passed params
// ---------------------------------

private _mtiMarkerParams = _target getVariable ["RQ4Tweak_mtiMarkerParams", []];

// Add undefined var protection
if ( _mtiMarkerParams isEqualTo [] ) exitWith {
	// DEBUG LVL 3
	private _msg = format ["%1: Abnormal exit, target %2 does not have a defined mtiMarkerParams var!", _gh, _target];
	ERROR_RPT(_msg, _curFunc);
};

_mtiMarkerParams params ["_varName", "_pos", "_size", "_color", "_type", "_brush", "_shape", "_alpha", "_text"];

// The TOI markers will exist on all client's computers, but will not actually be rendered unless they are an MTI recipient,
// this simplifies JIP execution since fn_clientMarkerUpdate is run on every client upon joining.
if ( _creation ) exitWith {
	private _mtiMarkerName = _varName select 0;
	_mtiMarker = createMarkerLocal [_mtiMarkerName, [0, 0, 0]];
	_mtiMarker setMarkerAlphaLocal 0;
};

private _mtiMarker = _varName select 0;

_mtiMarker setMarkerPosLocal _pos;
_mtiMarker setMarkerTextLocal _text;
_mtiMarker setMarkerShapeLocal "ICON";
_mtiMarker setMarkerTypeLocal _type;

// If marker is currently highlighted locally (via fn_highlightMarker), don't overwrite its color. 
if ( missionNamespace getVariable ["RQ4Tweak_markerSelected", []] isEqualTo [] ) then {
	_mtiMarker setMarkerColorLocal _color;
};

_mtiMarker setMarkerSizeLocal _size;

// Dual-role, makes it so that player's can't see MTI updates when loading in as JIP OR after they die.
if ( not alive player ) then {
	_mtiMarker setMarkerAlphaLocal 0;
} else {
	_mtiMarker setMarkerAlphaLocal _alpha;
};

// DEBUG LVL 3
private _msg = format ["%1: Complete ( %2 ).", _gh, _mtiMarker];
DEBUG_RPT(_msg, _curFunc);