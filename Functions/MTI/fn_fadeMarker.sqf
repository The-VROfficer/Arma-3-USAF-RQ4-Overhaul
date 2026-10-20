/*
	Author: Myth

	Locality: Local, executed on clients

	Description:
		If passed target qualifies, begins fading the TOI marker of the target. Fading auto-stops if the target is re-spotted by the AV.

	Parameter(s):
		0: <OBJECT> - The target to be checked.
		1: <MARKER> - The associated TOI marker to be faded.
		2: <OBJECT> - The AV that spotted the target.
		3: <BOOLEAN> - Optional, force fadeout even if time calculation errors occur <default: false>

	Returns:
		None

	Examples:
		[enemyTruck, "GMTI_Marker_69", myGlobalHawk] spawn MM_fnc_fadeMarker
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_fadeMarker";

params [
	["_target", objNull, []],
	["_marker", "", []],
	["_gh", objNull, [objNull]],
	["_forceFadeout", false, [false]]
];

//DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1, %2, %3]", _target, _marker, _gh];
DEBUG_RPT(_msg, _curFunc);

if ( typeName _marker isEqualTo "ARRAY" ) then {
	_marker = _marker select 0;
};

// Add duplicate execution protection. If target is already fading, exit script to prevent marker "strobing" due to conflicting execution.
if ( (_target getVariable ["RQ4Tweak_isFading", false]) == true ) exitWith {
	//DEBUG LVL 3
	private _msg = format ["%1: Exiting MM_fnc_fadeMarker - Reason: %1 is already fading ( %2 ).", _target, _target getVariable "RQ4Tweak_isFading"];
	DEBUG_RPT(_msg, _curFunc);
};

// Define script start time.
private _timeStarted = time;

// Check if target has a last seen time. If it doesn't, exit the script.
if ( _target getVariable ["RQ4Tweak_lastSeen", []] isEqualTo [] ) exitWith {
	//DEBUG LVL 3
	private _msg = format ["%1: Exiting MM_fnc_fadeMarker - Reason: %1 does not have a defined lastSeen time.", _target];
	DEBUG_RPT(_msg, _curFunc);
};

// Define time target was last seen by AV.
private _lastSeen = _target getVariable "RQ4Tweak_lastSeen" select 0;

// If timeStarted minus target's last seen time is less than the begin fadeout threshold, exit script.
if ( ((_timeStarted - _lastSeen) < parseNumber MM_RQ4_Update_Rate) and not _forceFadeout ) exitWith {
	//DEBUG LVL 2
	private _msg = format ["%1: Abnormal exit of MM_fnc_fadeMarker - Reason: Delta T less than the radar scan interval (%2 < %3).", _target, (_timeStarted - _lastSeen), parseNumber MM_RQ4_Update_Rate];
	ERROR_RPT(_msg, _curFunc);
};

// ---------------------------------
// Perform Fadeout
// ---------------------------------

_target setVariable ["RQ4Tweak_isFading", true, true];

private _markerOpacity = 1.0;

// Create loop to fade out marker. If target is respotted by the AV loop and script stop.
while { (_target getVariable "RQ4Tweak_isFading") and (_markerOpacity > 0.01)} do {
	_markerOpacity = (_markerOpacity - (1 / parseNumber MM_RQ4_Fade_Time)) max 0;
        
	_marker setMarkerAlphaLocal _markerOpacity;

	// Add MP intergration HERE

	//DEBUG LVL 3
	private _msg = format ["%1: Opacity reduced to %2.", _target, _markerOpacity];
	DEBUG_RPT(_msg, _curFunc);

	sleep 1;
};

//DEBUG LVL 3
private _msg = format ["%1: Marker for %1 is faded, beginning 'forget' checks.", _target];
DEBUG_RPT(_msg, _curFunc);

// Check if reason for loop termination was target being respotted by the AV.
if ( (_target getVariable "RQ4Tweak_isFading") isEqualTo false ) exitWith {
	//DEBUG LVL 3
	private _msg = format ["%1: Exiting MM_fnc_fadeMarker at Fade Out - Reason: %1 was respotted by an AV.", _target];
	DEBUG_RPT(_msg, _curFunc);
};

private _countdownTime = parseNumber MM_RQ4_TOI_Forget_Time;

// Create loop to begin the pseudo-DGS forgetting. At the end of this countdown, marker will be deleted and its data cleared.
while { (_target getVariable "RQ4Tweak_isFading") and (_marker in allMapMarkers) and (_countdownTime > 0)} do {
	_countdownTime = _countdownTime - 1;

	sleep 1;
};

// Check if reason for loop termination was target being respotted by the AV.
if ( (_target getVariable "RQ4Tweak_isFading") isEqualTo false ) exitWith {
	//DEBUG LVL 3
	private _msg = format ["%1: Exiting MM_fnc_fadeMarker at Forget Countdown - Reason: %1 was respotted by an AV.", _target];
	DEBUG_RPT(_msg, _curFunc);
};

//DEBUG LVL 3
private _msg = format ["%1: 'Forget' countdown complete, deleting marker ( %2 ).", _target, _marker];
DEBUG_RPT(_msg, _curFunc);

// At this point, the target has not been respotted and the forget countdown has expired. Delete the marker and its data.
deleteMarker _marker;

// Add code to remove marker data HERE
//
_target setVariable ["RQ4Tweak_mtiSector", nil, true];

_target setVariable ["RQ4Tweak_mtiMarkerParams", nil, true];

_target setVariable ["RQ4Tweak_isFading", nil, true];

_target setVariable ["RQ4Tweak_lastSeen", nil, true];

//DEBUG LVL 3
private _msg = format ["%1: Deleted marker cleanup complete.", _target];
DEBUG_RPT(_msg, _curFunc);