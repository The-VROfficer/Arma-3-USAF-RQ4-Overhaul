/*
	Author: Myth

	Locality: Server.

	Description:
		Handles the fading of old TOI markers globally and locally.

	Parameter(s):
		0: <OBJECT> - The AV that spotted the target.
		1: <MARKER> - The target that the to-be-faded TOI marker belongs to.
		2: <BOOLEAN> - Optional, force fadeout even if time calculation errors occur <default: false>

	Returns:
		None

	Examples:
		[myGlobalHawk, enemyTruck, true] spawn MM_fnc_handleFadeMarker
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_handleFadeMarker";

params [
	["_gh", objNull, [objNull]],
	["_target", objNull, []],
	["_forceFadeout", false, [false]]
];

//DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1, %2, %3]", _gh, _target, _forceFadeout];
DEBUG_RPT(_msg, _curFunc);

// Add duplicate execution protection. If target has been commanded to fade, exit script to prevent marker "strobing" due to conflicting execution.
if ( (_target getVariable ["RQ4Tweak_isFading", false]) ) exitWith {
	//DEBUG LVL 2
	private _msg = format ["%1: %2 is already fading ( %3 ), exiting.", _gh, _target, _target getVariable "RQ4Tweak_isFading"];
	ERROR_RPT(_msg, _curFunc);
};

// Define script start time.
private _timeStarted = time;

// Check if target has a last seen time. If it doesn't, exit the script.
if ( _target getVariable ["RQ4Tweak_lastSeen", []] isEqualTo [] ) exitWith {
	//DEBUG LVL 2
	private _msg = format ["%1: %2 does not have a defined lastSeen time, exiting.", _gh, _target];
	ERROR_RPT(_msg, _curFunc);
};

// Define time target was last seen by AV.
private _lastSeen = (_target getVariable "RQ4Tweak_lastSeen") select 0;

// If timeStarted minus target's last seen time is less than the begin fadeout threshold, exit script.
if ( ((_timeStarted - _lastSeen) < parseNumber MM_RQ4_Update_Rate) and not _forceFadeout ) exitWith {
	//DEBUG LVL 2
	private _msg = format ["%1: Delta T less than the radar scan interval (%3 < %4) for target %2, exiting.", _gh, _target, (_timeStarted - _lastSeen), parseNumber MM_RQ4_Update_Rate];
	ERROR_RPT(_msg, _curFunc);
};

// ---------------------------------
// Call fadeout on MTI Receipient machines
// ---------------------------------

_target setVariable ["RQ4Tweak_isFading", true, true];

private _mtiRecipients = missionNamespace getVariable ["RQ4Tweak_mtiRecipients", objNull];
[_gh, _target] remoteExec ["MM_fnc_fadeMarkerLocal", _mtiRecipients];	// Don't JIP this. When clients load in, markers will be created but will be invisible until queued by fn_updateMTIMarker. This should also execute even if SP or player-hosted.

// ---------------------------------
// Perform fadeout timing and checks on server
// ---------------------------------

private _markerOpacity = 1.0;

// Create loop that copies the fadeout timing in fn_fadeMarkerLocal. If target is respotted by the AV loop and script stop.
while { (_target getVariable ["RQ4Tweak_isFading", false]) and (_markerOpacity > 0.01)} do {
	_markerOpacity = (_markerOpacity - (1 / parseNumber MM_RQ4_Fade_Time)) max 0;

	sleep 1;
};

if ( isNull _target ) exitWith {
	//DEBUG LVL 3
	private _msg = format ["%1 - %2: Fadeout exit, %1 was deleted.", _gh, _target];
	DEBUG_RPT(_msg, _curFunc);
};

if ( (_target getVariable ["RQ4Tweak_isFading", []]) isEqualTo [] ) exitWith {
	//DEBUG LVL 3
	private _msg = format ["%1 - %2: Fadeout exit, var isFading was deleted.", _gh, _target];
	DEBUG_RPT(_msg, _curFunc);
};

if ( not (_target getVariable "RQ4Tweak_isFading") ) exitWith {
	//DEBUG LVL 3
	private _msg = format ["%1 - %2: Fadeout exit, %1 was respotted by an AV.", _gh, _target];
	DEBUG_RPT(_msg, _curFunc);

	_target setVariable ["RQ4Tweak_isFading", nil, true];
};

// ---------------------------------
// If fadeout completed normally, begin DGS "forgetting"
// ---------------------------------

private _countdownTime = parseNumber MM_RQ4_TOI_Forget_Time;
private _marker = (_target getVariable "RQ4Tweak_mtiMarkerParams") select 0 select 0;

// Create loop to begin the pseudo-DGS forgetting. At the end of this countdown, marker will be deleted and its data cleared.
while { (_target getVariable ["RQ4Tweak_isFading", false]) and (_marker in allMapMarkers) and (_countdownTime > 0)} do {
	_countdownTime = _countdownTime - 1;

	sleep 1;
};

// ---------------------------------
// perform forget loop exit reason checks
// ---------------------------------

// Check if reason for loop termination was due to target object being deleted.
if ( isNull _target ) exitWith {
	//DEBUG LVL 3
	private _msg = format ["%1 - %2: Forget exit, %1 was deleted.", _gh, _target];
	DEBUG_RPT(_msg, _curFunc);
};

// Check if reason for loop termination was due to var being deleted.
if ( (_target getVariable ["RQ4Tweak_isFading", []]) isEqualTo [] ) exitWith {
	//DEBUG LVL 3
	private _msg = format ["%1 - %2: Forget exit, var isFading was deleted.", _gh, _target];
	DEBUG_RPT(_msg, _curFunc);
};

// Check if reason for loop termination was target being respotted by the AV.
if ( not (_target getVariable "RQ4Tweak_isFading") ) exitWith {
	//DEBUG LVL 3
	private _msg = format ["%1 - %2: Forget exit, %2 was respotted by an AV.", _gh, _target];
	DEBUG_RPT(_msg, _curFunc);
};

//DEBUG LVL 3
private _msg = format ["%1: 'Forget' countdown complete, deleting marker ( %2 ).", _target, _marker];
DEBUG_RPT(_msg, _curFunc);

// At this point, the target has not been respotted and the forget countdown has expired. Delete the marker and its data.
_gh setVariable ["RQ4Tweak_allTOIMarkers", (_gh getVariable "RQ4Tweak_allTOIMarkers") - [_marker], true];
deleteMarker ((_target getVariable "RQ4Tweak_mtiMarkerParams") select 0 select 0);

_target setVariable ["RQ4Tweak_mtiUserStyle", nil, true];
_target setVariable ["RQ4Tweak_mtiSector", nil, true];
_target setVariable ["RQ4Tweak_mtiMarkerParams", nil, true];
_target setVariable ["RQ4Tweak_lastSeen", nil, true];

_target setVariable ["RQ4Tweak_isFading", nil, true];

//DEBUG LVL 3
private _msg = format ["%1: Deleted marker cleanup complete.", _target];
DEBUG_RPT(_msg, _curFunc);