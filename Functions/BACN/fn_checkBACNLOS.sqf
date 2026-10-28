/*
	Author: Myth

    Locality: Server, broadcasts action creation to clients.

	Description: Checks the passed player's LOS value to the BACN, superscores with whichever LOD model results in the highest value.


	Parameter(s):
		0: <STRING> - The AV to check.
		1: <OBJECT> - The player to check.

	Returns:
		0: <BOOLEAN> - True or false depending if the LOS value is greated than 0.3 (30%) or not.

	Examples:
		[myGlobalHawk, dude_69] call MM_fnc_checkBACNLOS;
*/

// ---------------------------------
// Script Start and Params
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_checkBACNLOS";

params [
	["_gh", objNull, [objNull]],
	["_player", objNull, [objNull]]
];

// DEBUG LVL 3
private _msg = format ["%1: Started LOS check - Params [%1, %2].", _gh, _player];
DEBUG_RPT(_msg, _curFunc);

// ---------------------------------
// Perform LOS Check
// ---------------------------------

// If BACN LOS calculation is not enabled, auto exit with TRUE.
if ( not MM_RQ4_Enable_BACN_LOS ) exitWith {
	// DEBUG LVL 3
	private _msg = format ["%1: Exiting, BACN LOS not enabled.", _gh];
	DEBUG_RPT(_msg, _curFunc);

	true;
};

private _losDecimals = [];

// Add 10m to the player's Z position, otherwise stupid shit like fences and shrubs will block LOS.
private _playerPos = getPosASLVisual _player;
_playerPos set [2, (_playerPos select 2) + MM_RQ4_BACN_LOS_Adjustment + 1.8];

{
	private _model = _x;

	private _num = [objNull, _model] checkVisibility [_gh modelToWorldVisualWorld [0, 0, -8], _playerPos];

	_losDecimals pushBackUnique _num;
} forEach ["FIRE", "VIEW", "GEOM", "IFIRE", "PHYSX"];

// ---------------------------------
// Returns
// ---------------------------------

// DEBUG LVL 3
private _msg = format ["%1: LOS check complete, best LOS is %2.", _gh, selectMax _losDecimals];
DEBUG_RPT(_msg, _curFunc);

(selectMax _losDecimals) > 0.25;