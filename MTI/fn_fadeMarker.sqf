/*
	Author: Myth

	Locality: ?

	Description:
		If passed target qualifies, begins fading the TOI marker of the target. Fading auto-stops if the target is re-spotted by the AV.

	Parameter(s):
		0: <OBJECT> - The target to be checked.
		1: <MARKER> - The associated TOI marker to be faded.
		2: <OBJECT> - The AV that spotted the target.

	Returns:
		None

	Examples:
		[enemyTruck, "GMTI_Marker_69", myGlobalHawk] spawn MM_fnc_fadeMarker
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

params [
	["_target", objNull, [objNull]],
	["_marker", "", [""]],
	["_gh", objNull, [objNull]]
];

//DEBUG
LOG(format ["MM_fnc_fadeMarker, %1: Started MM_fnc_fadeMarker. Passed params: %1, %2, %3", _target, _marker, _gh]);

// Define script start time.
private _timeStarted = time;

// Check if target has a last seen time. If it doesn't, exit the script.
if ( _target getVariable ["RQ4Tweak_lastSeen", []] isEqualTo [] ) exitWith {
	//DEBUG
	LOG(format ["MM_fnc_fadeMarker, %1: Exiting MM_fnc_fadeMarker - Reason: %1 does not have a defined lastSeen time.", _target]);
};

// Define time target was last seen by AV.
private _lastSeen = _target getVariable "RQ4Tweak_lastSeen" select 0;

// If timeStarted minus target's last seen time is less than the begin fadeout threshold, exit script.
if ( (_timeStarted - _lastSeen) < MM_RQ4_Update_Rate ) exitWith {
	//DEBUG
	WARNING(format ["MM_fnc_fadeMarker, %1: Abnormal exit of MM_fnc_fadeMarker - Reason: Delta T less than the radar scan interval (%2 < %3).", _target, (_timeStarted - _lastSeen), MM_RQ4_Update_Rate]);
};

// ---------------------------------
// Perform Fadeout
// ---------------------------------

_target setVariable ["RQ4Tweak_isFading", true, true];

private _markerOpacity = 1.0;

// Create loop to fade out marker. If target is respotted by the AV loop and script stop.
while { (_target getVariable "RQ4Tweak_isFading") and (_markerOpacity > 0)} do {
	private _markerOpacity = (_markerOpacity - (1 / parseNumber MM_RQ4_Fade_Time)) max 0;
        
	_marker setMarkerAlphaLocal _markerOpacity;

	// Add MP intergration HERE

	sleep 1;
};

// Check if reason for loop termination was target being respotted by the AV.
if ( (_target getVariable "GMTI_isRQ4Tweak_isFadingFading") isEqualTo false ) exitWith {
	LOG(format ["MM_fnc_fadeMarker, %1: Exiting MM_fnc_fadeMarker at Fade Out - Reason: %1 was respotted by an AV.", _target]);
};

private _countdownTime = MM_RQ4_TOI_Forget_Time;

// Create loop to begin the pseudo-DGS forgetting. At the end of this countdown, marker will be deleted and its data cleared.
while { (_target getVariable "RQ4Tweak_isFading") and (_marker in allMapMarkers) and (_countdownTime > 0)} do {
	_countdownTime = _countdownTime - 1;

	sleep 1;
};

// Check if reason for loop termination was target being respotted by the AV.
if ( (_target getVariable "RQ4Tweak_isFading") isEqualTo false ) exitWith {
	LOG(format ["MM_fnc_fadeMarker, %1: Exiting MM_fnc_fadeMarker at Forget Countdown - Reason: %1 was respotted by an AV.", _target]);
};

// At this point, the target has not been respotted and the forget countdown has expired. Delete the marker and its data.
deleteMarker _marker;

// Add code to remove marker data HERE
//

_target setVariable ["RQ4Tweak_mtiMarkerParams", nil, true];