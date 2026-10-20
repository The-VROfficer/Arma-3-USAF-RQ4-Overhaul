/*
	Author: Myth

    Locality: Server.

	Description:
		Updates an existing MTI marker on the map for the given target, but only renders the marker for MTI-recipient qualified clients. Also calls functions that update the marker's info in JIP queue.

	Parameter(s):
		0: <OBJECT> - The AV.
		1: <OBJECT> - The object to have a MTI marker updated for.

	Returns:
		

	Examples:
		[_myGlobalHawk, tank_123] call MM_fnc_updateMTIMarker
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#define DEBUG_ENABLED

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_updateMTIMarker";

params [
	["_gh", objNull, [objNull]],
	["_target", objNull, [objNull]]
];

// DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1, %2]", _gh, _target];
DEBUG_RPT(_msg, _curFunc);

// Determine if totalTOIs variable exists, if not, exit.
private _totalTOIs = _gh getVariable ["RQ4Tweak_totalTOIs", []];

if ( _totalTOIs isEqualTo [] ) then {
	// DEBUG LVL 2
	private _msg = format ["%1: Variable 'RQ4Tweak_totalTOIs' has not yet been defined for AV %1. Defining now.", _gh];
	DEBUG_RPT(_msg, _curFunc);

	_gh setVariable ["RQ4Tweak_totalTOIs", 0, true];
};

// ---------------------------------
// Perform Marker Updating
// ---------------------------------

// Check if passed target has an MTI marker (mtiMarkerParams), if not, exit.
private _mtiMarkerParams = _target getVariable ["RQ4Tweak_mtiMarkerParams", []];

if ( _mtiMarkerParams isEqualTo [] ) exitWith {
	// DEBUG LVL 2
	private _msg = format ["%1: Abnormal exit - Attempted to run %2, but variable 'RQ4Tweak_mtiMarkerParams' is not defined for target %3!", _gh, _curFunc, _target];
	ERROR_RPT(_msg, _curFunc);
};

// Breakdown and name all the stored components of that variable.
_mtiMarkerParams params ["_varName", "_pos", "_size", "_color", "_type", "_brush", "_shape", "_alpha", "_text"];
private _mtiMarker = _varName select 0;

// Handles an edge case where marker has mtiMarkerParams (?) but doesn't have associated text or other marker content...
if ( count _text < 1 ) exitWith {
	// DEBUG LVL 2
	private _msg = format ["%1: Abnormal exit - Target %2 has missing mtiMarkerParams! [%3, %4, %5, %6, %7, %8, %9, %10, %11]", _gh, _target, _varName, _pos, _size, _color, _type, _brush, _shape, _alpha, _text];
	ERROR_RPT(_msg, _curFunc);
};

// Set marker opacity back to 100% and (hopefully) undo all fading previously done by fn_fadeMarker.
_mtiMarker setMarkerAlphaLocal 1.0;

// Update marker's name to reflect the most recent "lastSeen" time.
private _spotTimeData = _target getVariable ["RQ4Tweak_lastSeen", []];

// Add undefined RQ4Tweak_lastSeen variable protection.
if ( _spotTimeData isEqualTo [] ) exitWith {
	// DEBUG LVL 2
	private _msg = format ["%1: Abnormal exit - Variable 'RQ4Tweak_lastSeen' is not defined for target %2!", _gh, _target];
	ERROR_RPT(_msg, _curFunc);
};

// Cut out the old time block, retain "TOI # ".
private _cutName = (_text splitString "[") select 0;	// Results in "TOI # "

private _newName = _cutName + "[" + str ((_spotTimeData select 1) select 0) + ":" + ((_spotTimeData select 1) select 1) + "]";

_mtiMarker setMarkerTextLocal _newName;

// Apply PoD position randomization and update the marker's position.
private _mtiSector = _target getVariable ["RQ4Tweak_mtiSector", []];

if ( _mtiSector isEqualTo [] ) exitWith {
	// DEBUG LVL 2
	private _msg = format ["%1: Abnormal exit - Target %2 has no defined mtiSector variable.", _gh, _target];
	ERROR_RPT(_msg, _curFunc);
};

private _podError = switch ( _mtiSector ) do {
	case 1: { MM_RQ4_PoD_Error_S1 };
	case 2: { MM_RQ4_PoD_Error_S2 };
	case 3: { MM_RQ4_PoD_Error_S3 };
};

private _randomizedPos = (getPos _target) apply { _x * random [1 - parseNumber _podError, 1, 1 + parseNumber _podError] };
// Remove the Z-pos index if present.
if ( count _randomizedPos > 2 ) then {
	_randomizedPos deleteAt 2;
};

_mtiMarker setMarkerPosLocal _randomizedPos;

// Create a new "mil_dot" track dot using (now old) mtiMarkerParam var data, start fading it immediately.
private _trackDotName = str _target + "_trackDot_" + str (floor random 10000000);	// literally 1 in 10,000,000 chance it bugs out lol
private _trackDot = createMarkerLocal [_trackDotName, _pos];
_trackDot setMarkerColorLocal _color;
_trackDot setMarkerTypeLocal "mil_dot";

[_trackDot] spawn {
	params ["_trackDot"];

	private _markerOpacity = 1.0;

	// Create loop to fade out marker. There's no stopping it.
	while { _markerOpacity > 0.01 } do {
		_markerOpacity = (_markerOpacity - 0.05) max 0;
			
		_trackDot setMarkerAlphaLocal _markerOpacity;

		sleep 1;
	};
};

// Pushback the track dot to a running list of track dots attached to the target object.
private _trackDotList = _target getVariable ["RQ4Tweak_trackDots", []];
_trackDotList pushBackUnique _trackDot;
_target setVariable ["RQ4Tweak_trackDots", _trackDotList, true];

// Recall MTI receipients, if none, array returns empty and remoteExec below is broadcast to no one.
private _mtiRecipients = missionNamespace getVariable ["RQ4Tweak_mtiRecipients", []];

// Pass the track dot over to the mtiRecipient clients. Local marker creation and fadeout will be handled on the client's machine.
[_gh, _target, _trackDot call BIS_fnc_markerParams] remoteExec ["MM_fnc_clientTrackDotUpdate", _mtiRecipients];

// Update mtiMarkerParams variable data, broadcast globally.
_mtiMarkerParams = _mtiMarker call BIS_fnc_markerParams;
_target setVariable ["RQ4Tweak_mtiMarkerParams", _mtiMarkerParams, true];

// ---------------------------------
// Update JIP Queue and Send to Clients
// ---------------------------------

private _mtiMarkerJIPU = [_gh, _target, false] remoteExecCall ["MM_fnc_clientMarkerUpdate", _mtiRecipients, true]; 

// Add variable to the target to keep track of the creation "command" in the JIP queue.
private _setVarName = "RQ4Tweak_mtiMarkerJIPU_" + str _gh;	// A unique var name is required since this var will be attached to the TARGET, therefore overlapping collect would keep resetting this var if it wasn't unique.
_target setVariable [_setVarName, _mtiMarkerJIPU, true];

// DEBUG LVL 3
private _msg = format ["%1: Marker updated for ( %2 ), marker name is ( %3 ), JIPU varName is ( %4 ).", _gh, _target, _newName, _setVarName];
DEBUG_RPT(_msg, _curFunc);