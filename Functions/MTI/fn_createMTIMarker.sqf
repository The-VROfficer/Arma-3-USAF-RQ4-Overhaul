/*
	Author: Myth

    Locality: Server.

	Description:
		Creates a new MTI marker on the map for the given target, but only renders the marker for MTI-recipient qualified clients. Also calls functions that add the creation of markers to the JIP queue.

	Parameter(s):
		0: <OBJECT> - The AV.
		1: <OBJECT> - The object to have a MTI marker created for.

	Returns:
		

	Examples:
		[_myGlobalHawk, apc_69] call MM_fnc_createMTIMarker
*/

#define DEBUG_ENABLED

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_createMTIMarker";

params [
	["_gh", objNull, [objNull]],
	["_target", objNull, [objNull]]
];

// DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1, %2]", _gh, _target];
DEBUG_RPT(_msg, _curFunc);

// Determine if the TOI counter for this AV exists, if not, define it here.
private _totalTOIs = _gh getVariable ["RQ4Tweak_totalTOIs", []];

if ( _totalTOIs isEqualTo [] ) then {
	// DEBUG LVL 3
	private _msg = format ["%1: Variable 'RQ4Tweak_totalTOIs' has not yet been defined for AV %1. Defining now.", _gh];
	DEBUG_RPT(_msg, _curFunc);

	_gh setVariable ["RQ4Tweak_totalTOIs", 0, true];
};

// Also define the "series" number for the TOIs named by this AV.
private _series = (missionNamespace getVariable "RQ4Tweak_allAVs") find _gh;

// ---------------------------------
// Perform Marker Creation
// ---------------------------------

// Begin constructing naming structure for the MTI mark.
private _toiStart = parseNumber MM_RQ4_TOI_Num;
private _spotTimeData = _target getVariable ["RQ4Tweak_lastSeen", []];

// Add undefined RQ4Tweak_lastSeen variable protection.
if ( _spotTimeData isEqualTo [] ) exitWith {
	// DEBUG LVL 2
	private _msg = format ["%1: Abnormal exit - Variable 'RQ4Tweak_lastSeen' is undefined for target %2.", _gh, _target];
	ERROR_RPT(_msg, _curFunc);
};

// Call _totalTOIs again to clear stale data and get most up-to-date values.
private _totalTOIs = (_gh getVariable "RQ4Tweak_totalTOIs") + _toiStart;

// Iterate marker name by +1, create combined name.
private _combinedName = "TOI " + str _series + "-" + (str (_totalTOIs + 1)) + (format [" [%1:", _spotTimeData select 1 select 0]) + (_spotTimeData select 1 select 1) + "]";

// Create a unique marker name for backend identification.
private _ghId = (netId _gh) regexReplace [":", "_"];
private _mtiMarkerName = format ["TOI_%1-%2_%3_marker", _series, _totalTOIs, _ghID];

// Push TOI iteration update globally, allows other new markers to be created instead of overwriting this one.
_gh setVariable ["RQ4Tweak_totalTOIs", _totalTOIs + 1, true];

// Determine marker color from sensor control GUI. If no color is defined in the GUI, defaults to ColorGUER as defined in CfgMarkerColors.
private _markerColor = _gh getVariable ["RQ4Tweak_mtiMarkerColor", "ColorGUER"];

// Determine the size of the marker based on "RCS" (bounding box size) return.
private _markerSize = [1 * (sizeOf typeOf _target / 20), 1 * (sizeOf typeOf _target / 20)];

// Apply marker position randomization.
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

// Create the marker with all previous date combined.
private _mtiMarker = createMarkerLocal [_mtiMarkerName, _randomizedPos];
_mtiMarker setMarkerTextLocal _combinedName;
_mtiMarker setMarkerShapeLocal "ICON";
_mtiMarker setMarkerTypeLocal "n_unknown";
_mtiMarker setMarkerColorLocal _markerColor;
_mtiMarker setMarkerSizeLocal _markerSize;

// Store all marker params in a variable attached to the target object.
private _mtiMarkerParams = _mtiMarker call BIS_fnc_markerParams;

// DEBUG LVL 3
private _msg = format ["%1: %2's mtiMarkerParams are: ( %3 )", _gh, _target, _mtiMarkerParams];
DEBUG_RPT(_msg, _curFunc);

_target setVariable ["RQ4Tweak_mtiMarkerParams", _mtiMarkerParams, true];

_target addEventHandler ["Deleted",{
	params ["_entity"];
	
	// DEBUG LVL 2
	private _msg = format ["%1: Deletion protection triggered, %1 was deleted.", _entity];
	ERROR_RPT(_msg, _curFunc);


	private _marker = (_entity getVariable "RQ4Tweak_mtiMarkerParams") select 0 select 0;
	
	[_marker] spawn {
		params ["_marker"];

		private _markerOpacity = 1.0;

		// Create loop to fade out marker. There's no stopping it.
		while { _markerOpacity > 0.01 } do {
			_markerOpacity = (_markerOpacity - (1 / parseNumber MM_RQ4_Fade_Time)) max 0;
				
			_marker setMarkerAlphaLocal _markerOpacity;

			// Add MP intergration HERE

			//DEBUG LVL 3
			private _msg = format ["%1: Opacity reduced to %2.", _marker, _markerOpacity];
			DEBUG_RPT(_msg, "MM_fnc_createMTIMarker");

			sleep 1;
		};
	};


	_entity removeEventHandler ["Deleted", _thisEventHandler];
}];

// ---------------------------------
// Update JIP Queue and Send to Clients
// ---------------------------------

private _mtiMarkerJIPC = [_gh, _target, true] remoteExecCall ["MM_fnc_clientMarkerUpdate", 0, true]; // This is run on EVERY JIP client regardless of if they are an MTI recipient,
// this is required since MTI receipients can't be assigned before they join the game, and its generally easier to perform JIP stuff when the marker exists (albeit hidden) on each client's computer.

// Add variable to the target to keep track of the creation "command" in the JIP queue.
private _setVarName = "RQ4Tweak_mtiMarkerJIPC_" + str _gh;	// Like fn_updateMTIMarker, a unique var name is required since this var will be attached to the TARGET, therefore overlapping collect would keep resetting this var if it wasn't unique.
_target setVariable [_setVarName, _mtiMarkerJIPC, true];

// DEBUG LVL 3
private _msg = format ["%1: Marker created for ( %2 ), marker name is ( %3 ), JIPC varName is ( %4 ).", _gh, _target, _combinedName, _setVarName];
DEBUG_RPT(_msg, _curFunc);