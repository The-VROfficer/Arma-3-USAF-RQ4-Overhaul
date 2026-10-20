/*
	Author: Myth

	Locality: Server

	Description: Slews the sensor of the passed aircraft to the opposite side. 0=left, 1=right.
		

	Parameter(s):
		0: <OBJECT> - The passed MTI vehicle to slew the sensor on.
		1: <OBJECT> - The unit (player) that called the function and is connected to the AV.

	Returns: Nothing.

	Examples:
		[myGh] spawn MM_fnc_slewSide
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_slewSensor";

params [
	["_gh", objNull, [objNull]],
	["_caller", objNull, [objNull]]
];

// DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1, %2]", _gh, _caller];
DEBUG_RPT(_msg, _curFunc);

// Get current slew side, default to left if unknown.
private _currentSlew = _gh getVariable ["RQ4Tweak_slewSide", 0];

// If sensor is slewed to the left, slew it right, vice versa.
private _newSlew = if ( _currentSlew == 0 ) then {
	1
} else {
	0
};

// ---------------------------------
// Perform Radar Cutoff, Slew, and Radar Restart
// ---------------------------------

// This drives a check in fn_collectMTI that will skip the collection iteration until this is false/undefined.
_gh setVariable ["RQ4Tweak_isSlewing", true, true];

private _forMemory = if ( (_gh getVariable ["RQ4Tweak_forEH", []]) isNotEqualTo [] ) then {
	[_gh, false] remoteExec ["MM_fnc_handleFOR", _caller];

	true;
} else {
	false;
};

[_newSlew] spawn {
	params ["_newSlew"];

	private _newSlewText = if ( _newSlew == 0 ) then { 
		"RIGHT" 
	} else {
		"LEFT"
	};

	for "_i" from 0 to (round MM_RQ4_SlewTime) do {
		hintSilent parseText format ["- SENSOR SLEWING %1 -<br />Time Remaining: %2 second(s)", _newSlewText, round MM_RQ4_SlewTime - _i];
		sleep 1;
	};

	hintSilent "";
};

sleep round MM_RQ4_SlewTime;

_gh setVariable ["RQ4Tweak_slewSide", _newSlew, true];

_gh setVariable ["RQ4Tweak_isSlewing", nil, true];

if ( _forMemory and (_caller isEqualTo (_gh getVariable ["RQ4Tweak_pilot", objNull])) ) then {
	[_gh, true] remoteExec ["MM_fnc_handleFOR", _caller];
};

// DEBUG LVL 3
private _msg = format ["%1: Sensor slew complete, new side is ( %2 )", _gh, _newSlew];
DEBUG_RPT(_msg, _curFunc);

true;
