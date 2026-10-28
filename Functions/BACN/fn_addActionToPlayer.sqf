/*
	Author: Myth

    Locality: Local.

	Description: Adds the "Connect to BACN" action where player is local.


	Parameter(s):
		0: <OBJECT> - The AV to connect the player to.
		1: <ARRAY> - The ACE add action content as passed by fn_bacnConnectAction.
		2: <ARRAY> - The ACE remove action content as passed by fn_bacnConnectAction.
		3: <STRING> - Parent action path of whichever comm system the server is using, as determined in fn_checkCommSysType.

	Returns:
		0: <BOOLEAN> - Completion flag.

	Examples:
		[myGlobalHawk, _actionContent, "ACRE"] call MM_fnc_addActionToPlayer;
*/

// ---------------------------------
// Script Start and Params
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_addActionToPlayer";

params [
	["_gh", objNull, [objNull]],
	["_addActionContent", [], [[]]],
	["_removeActionContent", [], [[]]],
	["_parentPath", "", [""]]
];

// If headless client was passed, exit.
if (not hasInterface) exitWith {
	// DEBUG LVL 3
	private _msg = format ["%1: Passed client does not have an interface. Exiting.", _gh];
	DEBUG_RPT(_msg, _curFunc);
};

// DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1, %2, %3].", _gh, ["action content withheld due to log size"], _gh];
DEBUG_RPT(_msg, _curFunc);

// ---------------------------------
// Add the Action
// ---------------------------------

private _addAction = _addActionContent call ace_interact_menu_fnc_createAction;
private _addAction = [player, 1, ["ACE_SelfActions", _parentPath], _addAction] call ace_interact_menu_fnc_addActionToObject;

private _removeAction = _removeActionContent call ace_interact_menu_fnc_createAction;
private _removeAction = [player, 1, ["ACE_SelfActions", _parentPath], _removeAction] call ace_interact_menu_fnc_addActionToObject;

// Add var to the AV so it can be deleted through external means later. This will be LOCAL, but basically the identical across all clients.
_gh setVariable ["RQ4Tweak_bacnAddActionPath", _addAction];
_gh setVariable ["RQ4Tweak_bacnRemoveActionPath", _removeAction];

// ---------------------------------
// Returns
// ---------------------------------

// DEBUG LVL 3
private _msg = format ["%1: Added actions to player %2 successfully. Exiting.", _gh, player];
DEBUG_RPT(_msg, _curFunc);

// Very short and sweet lol.
true;