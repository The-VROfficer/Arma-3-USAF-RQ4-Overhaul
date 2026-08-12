/*
	Author: Myth

	Locality: Local, executed on the aircraft.

	Description:
		Sets up data to be passed to JIP players, actual passing of data occurs in MM_fnc_executeJIP.

	Parameter(s):
		0: <OBJECT> - The MTI vehicle that detected/is detecting the targets.
		1: <OBJECT> - The target that is supposed to have a GMTI marker on it.

	Returns:
		0: <BOOLEAN> - Completion flag.

	Examples:
		[] call MM_fnc_addToJIP
*/

params [
	["_gh", objNull, [objNull]],
	["_target", objNull, [objNull]]
];

private _GMTI_Marker_Info = _target getVariable ["GMTI_Marker_Info", []];
if (_GMTI_Marker_Info isEqualTo []) exitWith {};	// Failsafe in case some undetected target gets passed.

private _newJIPQueue = _gh getVariable ["GMTI_JIP_Data", []];	// If current JIP data for passed MTI vehicle doesn't exist, create it.

// ---- If the marker data has been added before, clear out the old data and add the new stuff.
private _indexToDelete = _newJIPQueue findIf { (_x select 0) in (_GMTI_Marker_Info select 0) };

_newJIPQueue deleteAt _indexToDelete;	// If no old data is found, doesn't delete anything.

_newJIPQueue pushBackUnique _GMTI_Marker_Info;

_gh setVariable ["GMTI_JIP_Data", _newJIPQueue, true];

true;