/*
	Author: Myth

    Locality: Server, broadcasts action creation to clients.

	Description: Adds the action to connect to the BACN to ALL clients, including JIP.


	Parameter(s):
		0: <STRING> - The parent path of the new action, as determined in MM_fnc_setupBACN.
		1: <OBJECT> - The AV to connect the player to.
		2: <STRING> - (Optional) The BACN name, as passed by fn_setupBACN.

	Returns:
		0: <BOOLEAN> - Completion flag.

	Examples:
		["ACRE", myGlobalHawk, "SNIPER 20 (RQ4)"] spawn MM_fnc_bacnConnectAction;
*/

// ---------------------------------
// Script Start and Params
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_bacnConnectAction";

params [
	["_parentPath", "", [""]],
	["_gh", objNull, [objNull]],
	["_bacnName", "", [""]]
];

// DEBUG LVL 3
private _msg = format ["%2: Started - Params: [%1, %2].", _parentPath, _gh];
DEBUG_RPT(_msg, _curFunc);

// Allow the created object to be assigned a group by the game engine.
sleep 1;

// ---------------------------------
// Create Action Content w/ Eval Criteria
// ---------------------------------

// Check if BACN name is empty. If so, use the in-game group name.
private _name = if ( count _bacnName > 0 ) then {
	_bacnName;
} else {
	groupID group _gh;
};

private _addActionDispName = format ["Connect to BACN [%1]", _name];
private _addActionName = "RQ4Tweak_connectToBACN_" + str _gh;	

private _removeActionDispName = format ["Disconnect from BACN [%1]", _name];
private _removeActionName = "RQ4Tweak_disconnectFromBACN_" + str _gh;

// Add deletion protection for the users so they don't get softlocked if AV is deleted.
_gh addEventHandler ["Deleted", {
	params ["_entity"];
	{
		if ( _x getVariable ["RQ4Tweak_connectedToBACN", []] isEqualTo _entity ) then {
			_x setVariable ["RQ4Tweak_connectedToBACN", nil, true];
			_x setVariable ["RQ4Tweak_bacnConnectionHeld", nil, true];
			_x setVariable ["RQ4Tweak_playerRadios", nil];	// NOT GLOBAL.
			
			[false] remoteExecCall ["MM_fnc_bacnACREAmplify", _x, true];
			
			[""] remoteExec ["hint", _x];
		};
	} forEach allPlayers;
}];

// Add death protection so the LOS hint doesn't keep firing when the AV dies.
_gh addEventHandler ["Killed", {
	params ["_unit"];
	{
		if ( _x getVariable ["RQ4Tweak_connectedToBACN", []] isEqualTo _unit ) then {
			_x setVariable ["RQ4Tweak_connectedToBACN", nil, true];
			_x setVariable ["RQ4Tweak_bacnConnectionHeld", nil, true];
			_x setVariable ["RQ4Tweak_playerRadios", nil];	// NOT GLOBAL.
			
			[false] remoteExecCall ["MM_fnc_bacnACREAmplify", _x, true];

			[""] remoteExec ["hint", _x];
		};
	} forEach allPlayers;
}];

// Change the code to executed in the ACE action depending on what comm system the server is using.
private _addActionContent = if ( _parentPath isEqualTo "ACRE_Interact" ) then {
	[
		_addActionName,	// This must receive a unique identifier, or else this one action will connect the player to ALL BACNs at the same time (if there are multiple).
		_addActionDispName,
		"x\usaf_rq4a_tweak_v2\Icons\bacn_ca.paa",
		{
			params ["_player", "_target", "_actionParams"];
			private _gh = _actionParams select 0;
			
			// Create death protection, disconnects from BACN.
			private _addActionKilledEH = _player addEventHandler ["Killed",{
				params ["_unit"];

				{
					[false, _x] call MM_fnc_bacnACREAmplify;
				} forEach (_unit getVariable ["RQ4Tweak_playerRadios", []]);

				_unit setVariable ["RQ4Tweak_playerRadios", nil];	// NOT GLOBAL.
				_unit setVariable ["RQ4Tweak_connectedToBACN", nil, true];

				// DEBUG LVL 3
				private _msg = format ["Player %1 is dead, removing their radios from boostedRadios and cleaning up vars.", _unit];
				DEBUG_RPT(_msg, "MM_fnc_bacnConnectAction");
			}];

			player setVariable ["RQ4Tweak_bacnAddActionKilledEH", _addActionKilledEH];	// NOT GLOBAL, will be called on the player's machine only.

			// If LOS is enabled, create monitoring loop that "holds" the connection when LOS is lost.
			if ( MM_RQ4_Enable_BACN_LOS ) then {
				[_player, _gh] spawn {
					params ["_player", "_gh"];

					// DEBUG LVL 3
					private _msg = format ["%1: Performing LOS check for player %2's ACE action.", _gh, _player];
					DEBUG_RPT(_msg, "MM_fnc_bacnConnectAction");

					while { (alive _player) and (_player getVariable ["RQ4Tweak_connectedToBACN", []] isNotEqualTo []) } do {
						
						// If LOS is greated than 25% allow the connection, otherwise hold connection and pass hint (if enabled).
						if ( [_gh, _player] call MM_fnc_checkBACNLOS ) then {
							hintSilent "";
							
							[true] call MM_fnc_bacnACREAmplify;

							_player setVariable ["RQ4Tweak_bacnConnectionHeld", nil, true];
						} else {	
							hintSilent "LOS to BACN obstructed, holding connection.";
							
							[false] call MM_fnc_bacnACREAmplify;

							_player setVariable ["RQ4Tweak_bacnConnectionHeld", true, true];
						};

						sleep 1;
					};

					// Deletes the var once player disconnects from the BACN.
					_player setVariable ["RQ4Tweak_bacnConnectionHeld", nil, true];
				};
			} else {
				[true] call MM_fnc_bacnACREAmplify;
			};

			// Prevents the "connect to BACN" action from appearing while user is connected to the BACN.
			_player setVariable ["RQ4Tweak_connectedToBACN", _gh, true];

			["Connected to BACN", "x\usaf_rq4a_tweak_v2\Icons\bacn_ca.paa", [0, 1, 0], _player] call ace_common_fnc_displayTextPicture;
			playSound "BACN_connected";
		},
		{
			params ["_target", "_player", "_actionParams"];
			private _gh = _actionParams select 0;

			// Build the condition to display the action based on Addon Settings.
			(hasInterface)
			and
			(_player getVariable ["RQ4Tweak_connectedToBACN", []] isEqualTo [])
			and
			( count (["ACRE_PRC152"] call acre_api_fnc_getAllRadiosByType) > 0 or count (["ACRE_PRC117F"] call acre_api_fnc_getAllRadiosByType) > 0 )
			and
			(side _player isEqualTo side _gh)
			and
			((_gh getVariable ["RQ4Tweak_bacnUsers", 0]) < parseNumber MM_RQ4_MaxBACNUsers)
			// Add more criteria if desired later!
		},
		{},
		[_gh]
	];
} else {	// TFAR is in use.
	[
		_addActionName,
		_addActionDispName,
		"x\usaf_rq4a_tweak_v2\Icons\bacn_ca.paa",
		{
			params ["_target", "_player", "_actionParams"];
			private _gh = _actionParams select 0;

			// TFAR needs an eventhandler specially set up to reset the radio params on death, otherwise when player respawns they'll still have the output boost.
			// Create death protection, disconnects from BACN.
			private _addActionKilledEH = _player addEventHandler ["Killed",{
				params ["_unit"];

				_unit setVariable ["tf_sendingDistanceMultiplicator", 1, true];

				// DEBUG LVL 3
				private _msg = format ["Player %1 is dead, setting distance multiplier back to default.", _unit];
				DEBUG_RPT(_msg, "MM_fnc_bacnConnectAction");
			}];

			player setVariable ["RQ4Tweak_bacnAddActionKilledEH", _addActionKilledEH];	// NOT GLOBAL, will be called on the player's machine only.

			// If LOS is enabled, create monitoring loop that "holds" the connection when LOS is lost.
			if ( MM_RQ4_Enable_BACN_LOS ) then {
				[_player, _gh] spawn {
					params ["_player", "_gh"];

					// DEBUG LVL 3
					private _msg = format ["%1: Performing LOS check for player %2's ACE action.", _gh, _player];
					DEBUG_RPT(_msg, "MM_fnc_bacnConnectAction");

					while { _player getVariable ["RQ4Tweak_connectedToBACN", []] isNotEqualTo [] } do {
						
						// If LOS is greated than 25% allow the connection, otherwise hold connection and pass hint (if enabled).
						if ( [_gh, _player] call MM_fnc_checkBACNLOS ) then {
							hintSilent "";
							
							_player setVariable ["tf_sendingDistanceMultiplicator", 50, true];

							_player setVariable ["RQ4Tweak_bacnConnectionHeld", nil, true];
						} else {	
							hintSilent "LOS to BACN obstructed, holding connection.";
							
							_player setVariable ["tf_sendingDistanceMultiplicator", 1, true];

							_player setVariable ["RQ4Tweak_bacnConnectionHeld", true, true];
						};

						sleep 1;
					};

					// Deletes the var once player disconnects from the BACN.
					_player setVariable ["RQ4Tweak_bacnConnectionHeld", nil, true];
				};
			} else {
				_player setVariable ["tf_sendingDistanceMultiplicator", 50, true];
			};

			// Prevents the "connect to BACN" action from appearing while user is connected to the BACN.
			player setVariable ["RQ4Tweak_connectedToBACN", _gh, true];

			["Connected to BACN", "x\usaf_rq4a_tweak_v2\Icons\bacn_ca.paa", [0, 1, 0], _player] call ace_common_fnc_displayTextPicture;
			playSound "BACN_connected";
		},
		{
			params ["_target", "_player", "_actionParams"];
			private _gh = _actionParams select 0;

			// Build the condition to display the action based on Addon Settings.
			(hasInterface)
			and
			(_player getVariable ["RQ4Tweak_connectedToBACN", []] isEqualTo [])
			and
			(side _player isEqualTo side _gh)
			and
			[_player] call TFAR_fnc_hasRadio
			and
			((_gh getVariable ["RQ4Tweak_bacnUsers", 0]) < parseNumber MM_RQ4_MaxBACNUsers)
			// Add more criteria if desired later!
		},
		{},
		[_gh]
	];
};

// ---------------------------------
// Create removal actions
// ---------------------------------

private _removeActionContent = if ( _parentPath isEqualTo "ACRE_Interact" ) then {
	[
		_removeActionName,
		_removeActionDispName,
		"x\usaf_rq4a_tweak_v2\Icons\no_bacn_ca.paa",
		{
			params ["_player", "_target", "_actionParams"];
			private _gh = _actionParams select 0;

			// Reset player radios to default levels.
			[false] call MM_fnc_bacnACREAmplify;

			// Re-enable the action to connect to the BACN.
			_player setVariable ["RQ4Tweak_connectedToBACN", nil, true];
			_player setVariable ["RQ4Tweak_playerRadios", nil, true];
			
			// Remove the Killed eventhandler.
			_addActionKilledEH = player getVariable "RQ4Tweak_bacnAddActionKilledEH";
			player removeEventHandler ["Killed", _addActionKilledEH];
			player setVariable ["RQ4Tweak_bacnAddActionKilledEH", nil];

			hintSilent "";

			["Disconnected from BACN", "x\usaf_rq4a_tweak_v2\Icons\bacn_ca.paa", [1, 0, 0], _player] call ace_common_fnc_displayTextPicture;
		},
		{
			params ["_target", "_player", "_actionParams"];
			private _gh = _actionParams select 0;

			// Build the condition to display the action based on Addon Settings.
			(hasInterface)
			and
			(_player getVariable ["RQ4Tweak_connectedToBACN", []] isEqualTo _gh)
			and
			( count (["ACRE_PRC152"] call acre_api_fnc_getAllRadiosByType) > 0 or count (["ACRE_PRC117F"] call acre_api_fnc_getAllRadiosByType) > 0 )
			and
			(side _player isEqualTo side _gh)
			// Add more criteria if desired later!
		},
		{},
		[_gh]
	];
} else {
	[
		_removeActionName,
		_removeActionDispName,
		"x\usaf_rq4a_tweak_v2\Icons\no_bacn_ca.paa",
		{
			params ["_player", "_target", "_actionParams"];
			private _gh = _actionParams select 0;

			_player setVariable ["tf_sendingDistanceMultiplicator", 1, true];

			// Re-enable the action to connect to the BACN.
			_player setVariable ["RQ4Tweak_connectedToBACN", nil, true];

			// Remove the Killed eventhandler.
			_addActionKilledEH = player getVariable "RQ4Tweak_bacnAddActionKilledEH";
			player removeEventHandler ["Killed", _addActionKilledEH];
			player setVariable ["RQ4Tweak_bacnAddActionKilledEH", nil];

			hintSilent "";

			["Disconnected from BACN", "x\usaf_rq4a_tweak_v2\Icons\bacn_ca.paa", [1, 0, 0], _player] call ace_common_fnc_displayTextPicture;
		},
		{
			params ["_target", "_player", "_actionParams"];
			private _gh = _actionParams select 0;

			// Build the condition to display the action based on Addon Settings.
			(hasInterface)
			and
			(_player getVariable ["RQ4Tweak_connectedToBACN", []] isEqualTo _gh)
			and
			[_player] call TFAR_fnc_hasRadio
			and
			(side _player isEqualTo side _gh)
			// Add more criteria if desired later!
		},
		{},
		[_gh]
	];
};

// ---------------------------------
// RemoteExec the actions so all clients have it
// ---------------------------------

// Assign a var to the AV to make this action deletable through external means.

[_gh, _addActionContent, _removeActionContent, _parentPath] remoteExecCall ["MM_fnc_addActionToPlayer", 0, true];

// DEBUG LVL 3
private _msg = format ["%1: Added actions to all clients successfully.", _gh];
DEBUG_RPT(_msg, _curFunc);

true;