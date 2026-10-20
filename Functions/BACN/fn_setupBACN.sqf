/*
	Author: Myth

    Locality: Server.

	Description: Configures the BACN payload on the passed AV (ideally an RQ-4 Block 20).


	Parameter(s):
		0: <OBJECT> - The AV to have BACN setup on.
		1: <STRING> - (Optional) The name to give the BACN, appears on the ACE self action.

	Returns:
		0: <BOOLEAN> - Completion flag.

	Examples:
		[myGlobalHawk] call MM_fnc_setupBACN;
*/

#define DEBUG_ENABLED

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_setupBACN";

params [
	["_gh", objNull, [objNull]],
	["_bacnName", "", [""]]
];

// DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1].", _gh];
DEBUG_RPT(_msg, _curFunc);

// ---------------------------------
// Determine Communication System, Take Action
// ---------------------------------

private _commSys = call MM_fnc_checkCommSysType;

if ( _commSys isEqualTo "Vanilla" ) exitWith {
	// DEBUG LVL 3
	private _msg = format ["%1: Exiting, server is using vanilla (or other) communications.", _gh];
	DEBUG_RPT(_msg, _curFunc);
};

if ( _commSys isEqualTo "ERROR" ) exitWith {
	// DEBUG LVL 2
	private _msg = format ["%1: Abnormal exit, MM_fnc_checkCommSysType returned an error!", _gh];
	ERROR_RPT(_msg, _curFunc);
};

if ( _commSys isEqualTo "ACRE" ) then {
	["ACRE_Interact", _gh, _bacnName] spawn MM_fnc_bacnConnectAction;
} else {	// The system must be TFAR.
	// Replace this string with ACTION PARENT PATH e.g. "ACE_SelfActions"
	["ACE_Equipment", _gh, _bacnName] spawn MM_fnc_bacnConnectAction;
};

// ---------------------------------
// Returns
// ---------------------------------

true;