/*
	Author: Myth

	Locality: Local, the AV pilot's PC.

	Description:
		Collects the inputs from the marker side, type, and color combo boxes and applies them to the currently highlighted marker.

	Parameter(s):
		None.

	Returns:
		Nothing.

	Examples:
		onButtonClick = " [] call MM_fnc_updateMarker; "; 
*/

hintSilent "";

private _uav = getConnectedUAV player;

if ( isNull _uav ) exitWith {};

private _markerData = missionNamespace getVariable ["RQ4Tweak_markerSelected", []];

if ( _markerData isEqualTo [] ) exitWith {
	systemChat "COMMAND REJECTED - There is no selected marker.";
};

private _marker = _markerData select 1;

if ( markerAlpha _marker < 0.1 ) exitWith {
	systemChat "COMMAND REJECTED - Selected marker is not visible.";
	
	_marker setMarkerColorLocal (((_markerData select 2) getVariable "RQ4Tweak_mtiMarkerParams") select 4);
};

// ---------------------------------
// Get the current combo selections
// ---------------------------------

private _markerSide = if ( (lbCurSel 1625) == -1 ) then {
	// Nothing has been selected, imply user wants to use "default" marker.
	"n_";
} else {
	lbData [1625, lbCurSel 1625];	// Returns either "b_", "o_", or "n_".
};

private _markerType = if ( (lbCurSel 1626) == -1 ) then {
	// Nothing has been selected, imply user wants to use "default" type.
	"unknown";
} else {
	lbData [1626, lbCurSel 1626];
};

private _markerColor = if ( (lbCurSel 1632) == -1 ) then {
	// Nothing has been selected, imply user wants to use "default" color.
	_uav getVariable ["RQ4Tweak_mtiMarkerColor", "ColorGUER"];
} else {
	lbData [1632, lbCurSel 1632];
};

// ---------------------------------
// Apply selections to the current marker
// ---------------------------------

private _markerTypeComplete = _markerSide + _markerType;

// This is not redundant, it handles an edge case where user is removed from mtiRecipients but still has the marker fading.
_marker setMarkerTypeLocal _markerTypeComplete;
_marker setMarkerColorLocal _markerColor;

_mtiRecipients = missionNamespace getVariable ["RQ4Tweak_mtiRecipients", []];
[[_marker, _markerTypeComplete, _markerType, _markerColor, _mtiRecipients],{
	params ["_marker", "_markerTypeComplete", "_markerType", "_markerColor", "_mtiRecipients"];

	_marker setMarkerTypeLocal _markerTypeComplete;
	_marker setMarkerColorLocal _markerColor;
}] remoteExec ["spawn", _mtiRecipients, true];

[[_marker, _markerTypeComplete, _markerType, _markerColor, _mtiRecipients],{
	params ["_marker", "_markerTypeComplete", "_markerType", "_markerColor", "_mtiRecipients"];

	_marker setMarkerTypeLocal _markerTypeComplete;
	_marker setMarkerColorLocal _markerColor;
}] remoteExec ["spawn", 2, true];	// Server isn't normally an mtiRecipient and can't "see" the change, leading to overwriting. Its inclusion here fixes that.


// ---------------------------------
// Pass new marker params globally
// ---------------------------------

private _target = _markerData select 2;
_target setVariable ["RQ4Tweak_mtiUserStyle", [_markerColor, _markerTypeComplete], true];

// ---------------------------------
// Turn off highlighting on the selected marker, delete the "deselect click" EH
// ---------------------------------

removeMissionEventHandler ["MapSingleClick", (missionNamespace getVariable "RQ4Tweak_markerSelected") select 3];

missionNamespace setVariable ["RQ4Tweak_markerSelected", nil];
hintSilent "";