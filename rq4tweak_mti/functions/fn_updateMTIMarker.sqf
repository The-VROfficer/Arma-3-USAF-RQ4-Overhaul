/*
	Author: Myth

    Locality: Server.

	Description:
		Updates an existing MTI marker on the map for the given target, but only renders the marker for MTI-recipient qualified clients. Also calls functions that add the updating of the marker to the JIP queue.

	Parameter(s):
		0: <OBJECT> - The AV.
		0: <OBJECT> - The object to have a MTI marker created for.

	Returns:
		

	Examples:
		[_myGlobalHawk, boat_420] call MM_fnc_updateMTIMarker
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

params [
	["_gh", objNull, [objNull]],
	["_target", objNull, [objNull]]
];

// DEBUG LVL 3
LOG(format ["MM_fnc_updateMTIMarker, %1: Started - Params: %1, %2", _gh, _target]);

// Add TOI name sequence protection, in case this function was executed out of order.
private _totalTOIs = _gh getVariable ["RQ4Tweak_totalTOIs", []];

if ( _totalTOIs isEqualTo [] ) exitWith {
	// DEBUG LVL 2
	WARNING(format ["MM_fnc_updateMTIMarker, %1: Abnormal exit, totalTOIs is not defined and is needed for updating.", _gh]);
};

// ---------------------------------
// Perform Marker Updating
// ---------------------------------

// Check if passed target has mtiMarkerParams var assigned.
private _mtiMarkerParams = _target getVariable ["RQ4Tweak_mtiMarkerParams", []];

if ( _mtiMarkerParams isEqualTo [] ) exitWith {
	// DEBUG LVL 2
	WARNING(format ["MM_fnc_updateMTIMarker, %1: Abnormal exit, mtiMarkerParams is not defined for target %2.", _gh, _target]);
};

private _mtiMarker = _mtiMarkerParams select 0 select 0;

// Set the existing marker's opacity back to 100%, undoing the fade done by fn_fadeMarker.
_mtiMarker setMarkerAlphaLocal 1;

// Update marker's name to reflect most up-to-date lastSeen var data.
private _lastSeenData = _target getVariable "RQ4Tweak_lastSeen";

private _currentName = _mtiMarkerData select 8;
private _simpleName = _currentName splitString "";
private _shortName = _simpleName resize ( (count _simpleName) - 7 );
private _reconstructedName = _shortName joinString "";

private _newName = _reconstructedName + ( format [["[%1:%2]"], _lastSeenData select 1 select 0, _lastSeenData select 1 select 1] );

// Apply marker position randomization.
private _mtiSector = _target getVariable ["RQ4Tweak_mtiSector", []];

if ( _mtiSector isEqualTo [] ) exitWith {
	// DEBUG LVL 2
	WARNING(format ["MM_fnc_createMTIMarker, %1: Abnormal exit, target %2 has no defined mtiSector variable.", _gh, _target]);
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

// Update mtiMarkerParams, pass it globally.
private _mtiMarkerParams = _mtiMarker call BIS_fnc_markerParams;
_target setVariable ["RQ4Tweak_mtiMarkerParams", _mtiMarkerParams, true];

// ---------------------------------
// Update JIP Queue and Send to Clients
// ---------------------------------

// Recall MTI receipients, if none, array returns empty and remoteExec below is broadcast to no one.
private _mtiRecipients = missionNamespace getVariable ["RQ4Tweak_mtiRecipients", []];

//  Created as an inline function to be sent to client's computer.
private _updateMTIMarker = [_gh, _target] call {
	params ["_gh", "_target"];

	// Intuitive workaround for locality. These params will exist globally (attached to the target object), so they can be called easily on the client's computer.
	private _mtiMarkerParams = _target getVariable "RQ4Tweak_mtiMarkerParams";
	_mtiMarkerParams params ["_varName", "_pos", "_size", "_color", "_type", "_brush", "_shape", "_alpha", "_text"];

	// varName is an array with string, so select the first index.
	private _markerName = _varName select 0;

	_markerName setMarkerTextLocal _text;
	_markerName setMarkerPosLocal _pos;
};

private _mtiMarkerJIPU = [] remoteExecCall ["_updateMTIMarker", _mtiRecipients, true]; 

// Add variable to the target to keep track of the most recent update "command" in the JIP queue.
_target setVariable ["RQ4Tweak_mtiMarkerJIPU", _mtiMarkerJIPU, true];