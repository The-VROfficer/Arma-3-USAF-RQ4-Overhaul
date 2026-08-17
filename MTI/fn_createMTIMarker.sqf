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

// ---------------------------------
// Perform Marker Creation
// ---------------------------------

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

// Iterate marker name by +1, create combined name.
private _combinedName = "TOI " + (str (_totalTOIs + 1)) + (format [" [%1:%2]", _spotTimeData select 0, _spotTimeData select 1]);

// Determine marker color from sensor control GUI. If no color is defined in the GUI, defaults to ColorGUER as defined in CfgMarkerColors.
private _markerColor = _gh getVariable ["RQ4Tweak_mtiMarkerColor", "ColorGUER", true];

// Determine the size of the marker based on "RCS" (bounding box size) return.
private _markerSize = [1 * (sizeOf typeOf _target / 20), 1 * (sizeOf typeOf _target / 20)];

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

// Create the marker with all previous date combined.
private _mtiMarker = createMarkerLocal [_combinedName, _randomizedPos];
_mtiMarker setMarkerTextLocal _combinedName;
_mtiMarker setMarkerShapeLocal "ICON";
_mtiMarker setMarkerTypeLocal "n_unknown";
_mtiMarker setMarkerColorLocal _markerColor;
_mtiMarker setMarkerSizeLocal _markerSize;

// Store all marker params in a variable attached to the target object.
private _mtiMarkerParams = _mtiMarker call BIS_fnc_markerParams;
_target setVariable ["RQ4Tweak_mtiMarkerParams", _mtiMarkerParams, true];

// ---------------------------------
// Update JIP Queue and Send to Clients
// ---------------------------------

// Recall MTI receipients, if none, array returns empty and remoteExec below is broadcast to no one.
private _mtiRecipients = missionNamespace getVariable ["RQ4Tweak_mtiRecipients", []];

//  Created as an inline function to be sent to client's computer.
private _createMTIMarker = [_gh, _target] call {
	params ["_gh", "_target"];

	// Intuitive workaround for locality. These params will exist globally (attached to the target object), so they can be called easily on the client's computer.
	private _mtiMarkerParams = _target getVariable "RQ4Tweak_mtiMarkerParams";
	_mtiMarkerParams params ["_varName", "_pos", "_size", "_color", "_type", "_brush", "_shape", "_alpha", "_text"];

	private _varName = createMarkerLocal [_text, _pos];
	_varName setMarkerTextLocal _text;
	_varName setMarkerShapeLocal _shape;
	_varName setMarkerTypeLocal _type;
	_varName setMarkerColorLocal _color;
	_varName setMarkerSizeLocal _size;
};

private _mtiMarkerJIPC = [] remoteExecCall ["_createMTIMarker", _mtiRecipients, true]; 

// Add variable to the target to keep track of the creation "command" in the JIP queue.
_target setVariable ["RQ4Tweak_mtiMarkerJIPC", _mtiMarkerJIPC, true];