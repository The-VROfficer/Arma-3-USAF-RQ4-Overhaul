/*
	Author: Myth

	Locality: Local, the MTI recipient's machine.

	Description:
		Executes the local fading of an MTI marker, as queued by fn_handleFadeMarker.

	Parameter(s):
		0: <OBJECT> - The AV the target belongs to.
		1: <OBJECT> - The target the TOI marker belongs to.

	Returns:
		None

	Examples:
		[myGlobalHawk, enemyTruck] spawn MM_fnc_fadeMarkerLocal
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_fadeMarkerLocal";

params [
	["_gh", objNull, [objNull]],
	["_target", objNull, [objNull]]
];

//DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1, %2]", _gh, _target];
DEBUG_RPT(_msg, _curFunc);

// Prevent duplicate execution.
if ( not (_target getVariable ["RQ4Tweak_isFadingLocal", []] isEqualTo []) ) exitWith {
	// DEBUG LVL 2
	private _msg = format ["%1 - %2: Fadeout called, but fadeout is already running! Exiting.", _gh, _target];
	ERROR_RPT(_msg, _curFunc);
};

// Prevent accidental revealing of hidden targets (if user was just removed from mtiRecipients list).
if ( (_target getVariable ["RQ4Tweak_isTOIHidden", []]) isNotEqualTo [] ) exitWith {
	// DEBUG LVL 2
	private _msg = format ["%1 - %2: Fadeout called, but requested marker is hidden. User must have been removed from mtiRecipients. Exiting.", _gh, _target];
	ERROR_RPT(_msg, _curFunc);
};

_target setVariable ["RQ4Tweak_isFadingLocal", true];

// ---------------------------------
// Perform the fadeout
// ---------------------------------

private _marker = (_target getVariable ["RQ4Tweak_mtiMarkerParams", []]) select 0 select 0;

// Add missing params protection.
if ( _marker isEqualTo [] ) exitWith {
	private _msg = format ["%1 - %2: Target %2 is missing mtiMarkerParams! Exiting.", _gh, _target];
	ERROR_RPT(_msg, _curFunc);

	_target setVariable ["RQ4Tweak_isFadingLocal", nil];
};

private _markerOpacity = 1.0;

// Create loop to fade out marker. If target is respotted by the AV loop and script stop.
while { (_target getVariable ["RQ4Tweak_isFading", false]) and (_markerOpacity > 0.01) and ( (_target getVariable ["RQ4Tweak_isTOIHidden", []]) isEqualTo [] )} do {
	_markerOpacity = (_markerOpacity - (1 / parseNumber MM_RQ4_Fade_Time)) max 0;
        
	_marker setMarkerAlphaLocal _markerOpacity;

	//DEBUG LVL 3
	private _msg = format ["%1 - %2: Opacity reduced to %3.", _gh, _target, _markerOpacity];
	DEBUG_RPT(_msg, _curFunc);

	sleep 1;
};

// ---------------------------------
// Perform loop exit reason checks
// ---------------------------------

if ( isNull _target ) exitWith {
	//DEBUG LVL 3
	private _msg = format ["%1: Fadeout exit, %1 was deleted.", _target];
	DEBUG_RPT(_msg, _curFunc);
};

if ( (_target getVariable ["RQ4Tweak_isFading", []]) isEqualTo [] ) exitWith {
	//DEBUG LVL 3
	private _msg = format ["%1 - %2: Fadeout exit, var isFading was deleted.", _gh, _target];
	DEBUG_RPT(_msg, _curFunc);

	_target setVariable ["RQ4Tweak_isFadingLocal", nil];
};

if ( not (_target getVariable "RQ4Tweak_isFading") ) exitWith {
	//DEBUG LVL 3
	private _msg = format ["%1 - %2: Fadeout exit, %2 was respotted by an AV.", _gh, _target];
	DEBUG_RPT(_msg, _curFunc);

	_target setVariable ["RQ4Tweak_isFadingLocal", nil];
};

if ( ( (_target getVariable ["RQ4Tweak_isTOIHidden", []]) isNotEqualTo [] ) ) exitWith {
	//DEBUG LVL 3
	private _msg = format ["%1 - %2: Fadeout exit, %2 isTOIHidden=true.", _gh, _target];
	DEBUG_RPT(_msg, _curFunc);

	_target setVariable ["RQ4Tweak_isFadingLocal", nil];
};

// If fadeout was completed normally, set the opacity fully to 0 just to make sure.
_marker setMarkerAlphaLocal 0;

_target setVariable ["RQ4Tweak_isFadingLocal", nil];