/*
	Author: Myth

	Locality: Local, executed on the UAV pilot's computer.

	Description:
		Switches between Radar Reference Collection Area (RRCA) and Ground Reference Collection Area (GRCA), adds actions and reprograms effected scripts.

	Parameter(s):
		0: <OBJECT> - The MTI UAV.
		1: <OBJECT> - The player connected to the UAV via the UAV terminal.

	Returns:
		BOOLEAN - Completion flag.

	Examples:
		[myGlobalHawk, myPilot] call MM_fnc_toggleMode
*/

params [
	["_gh", objNull, [objNull]],
	["_ghPilot", objNull, [objNull]]
];

if ( (not local _ghPilot) or (not hasInterface) ) exitWith {	// This check prevents the script from being run on anything other than a client.
	["RQ-4 ACTION ERROR: Passed unit, '%2' (connected to '%1'), is not LOCAL or is HEADLESS. Exiting MM_fnc_toggleMode.", _gh, _ghPilot] call BIS_fnc_error;
};

if ( not isNil {_ghPilot getVariable "GMTI_Mode_ActionIDs"}) exitWith {};	// This check prevents duplicate addActions from being created. 

// ---- GRCA-related actions
private _grcaAction = _ghPilot addAction [
	"Switch to GRCA",
	{
		params ["_target", "_caller", "_actionId", "_arguments"];
		_gh = _arguments select 0;

		_gh setVariable ["GMTI_Mode", "GRCA", true];
	},
	[_gh],
	100,
	true,
	true,
	"",
	"(getConnectedUAV _target) getVariable 'GMTI_Mode' == 'RRCA'"
];

private _addGRCA = _ghPilot addAction [
	"Draw New GRCA",
	{
		params ["_target", "_caller", "_actionId", "_arguments"];
		_gh = _arguments select 0;

		[_gh] spawn MM_fnc_drawGRCA;
	},
	[_gh],
	101,
	true,
	true,
	"",
	"(getConnectedUAV _target) getVariable 'GMTI_Mode' == 'GRCA'"
];

// ---- RRCA-related actions
private _rrcaAction = _ghPilot addAction [
	"Switch to RRCA",
	{
		params ["_target", "_caller", "_actionId", "_arguments"];
		_gh = _arguments select 0;

		_gh setVariable ["GMTI_Mode", "RRCA", true];
	},
	[_gh],
	100,
	true,
	true,
	"",
	"(getConnectedUAV _target) getVariable 'GMTI_Mode' == 'GRCA'"
];

_ghPilot setVariable ["GMTI_Mode_ActionIDs", [_grcaAction, _addGRCA, _rrcaAction], true];

true