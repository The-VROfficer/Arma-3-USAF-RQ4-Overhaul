/*
	Author: Myth

    Locality: Local, effects broadcast globally.

	Description: Increases the transmission power for ACRE radios that are connected to the BACN. Note, this boost is applied to the RADIO OBJECT, not the player.


	Parameter(s):
		0: <BOOLEAN> - Whether to amplify or deamplify. True for amplify, false for deamplify.
		1: <STRING> - (Optional, default false) The ACRE unique radio ID for the specific radio to be deamplified.

	Returns:
		0: <BOOLEAN> - Completion flag.

	Examples:
		[false, "acre_prc152_id_1"] call MM_fnc_bacnACREAmplify;
*/

// ---------------------------------
// Script Start and Params
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_bacnACREAmplify";

params [
	["_amp", false, [false]],
	["_radioObject", false, []]
];

// DEBUG LVL 3
private _msg = format ["Started - Params: [%1, %2].", _amp, _radioObject];
DEBUG_RPT(_msg, _curFunc);

// ---------------------------------
// Handle bypass and de-amplify request (if param 2 is defined)
// ---------------------------------

if ( _radioObject isNotEqualTo false ) exitWith {
	// DEBUG LVL 3
	private _msg = format ["Deamplify requested for radio %1.", _radioObject];
	DEBUG_RPT(_msg, _curFunc);

	// First, undefined/empty protection.
	private _data = missionNamespace getVariable ["RQ4Tweak_boostedRadios", []];
	if ( _data isEqualTo [] ) exitWith {
		// DEBUG LVL 2
		private _msg = format ["Cannot deamplify radio %1, RQ4Tweak_boostedRadios is not defined/empty.", _radioObject];
		ERROR_RPT(_msg, _curFunc);
	};

	// Remove this radio from the boostedRadios var, then broadcast the updated list.
	_data deleteAt (_data find _radioObject);
	missionNamespace setVariable ["RQ4Tweak_boostedRadios", _data, true];

	// DEBUG LVL 3
	private _msg = format ["Radio %1 has been successfully deamplified.", _radioObject];
	DEBUG_RPT(_msg, _curFunc);
};

// ---------------------------------
// Get passed player's unique radio IDs
// ---------------------------------

/* if (not alive _player) exitWith {
	// DEBUG LVL 2
	private _msg = format ["Passed player %1 is not alive. Exiting.", _player];
	ERROR_RPT(_msg, _curFunc);
}; */

// Return the ALIVE player's radios (yes, all of them)
// Currently only works w/ the PRC152 and PRC117F
private _prc152s = [];
private _prc117fs = [];
{
	if ( "acre_prc152_id_" in _x ) then { _prc152s pushBackUnique _x };
	if ( "acre_prc117f_id_" in _x ) then { _prc117fs pushBackUnique _x };
} forEach ([player] call acre_sys_core_fnc_getGear);

// Set a var on the player that tracks what radios they have in their inventory.
if ( player getVariable ["RQ4Tweak_playerRadios", false] isEqualTo false ) then {
	player setVariable ["RQ4Tweak_playerRadios", _prc152s + _prc117fs];	// NOT GLOBAL
} else {
	// Add dropped/transfered radio check. If a radio was previously in player's inventory but no longer is, deamplify it (disconnect it from the BACN).
	{
		if ( not (_x in (_prc152s + _prc117fs)) ) then {
			// DEBUG LVL 3
			private _msg = format ["Radio %1 was in %2's inventory but is gone, requesting deamplify.", _x, player];
			DEBUG_RPT(_msg, _curFunc);

			[player, false, _x] call MM_fnc_bacnACREAmplify;
		};
	} forEach (player getVariable "RQ4Tweak_playerRadios");

	player setVariable ["RQ4Tweak_playerRadios", _prc152s + _prc117fs];	// NOT GLOBAL
};

// ---------------------------------
// Handle amplify / de-amplify request
// ---------------------------------

if ( _amp ) then {
	// Create a global var that the setCustomSignalFunc (which is global) will use to perform its "in array" checks.
	if ( missionNamespace getVariable ["RQ4Tweak_boostedRadios", false] isEqualTo false ) then {
		// DEBUG LVL 3
		private _msg = format ["Boosted radio var doesn't exist, defining now with params [%1 + %2].", _prc152s, _prc117fs];
		DEBUG_RPT(_msg, _curFunc);
		
		missionNamespace setVariable ["RQ4Tweak_boostedRadios", _prc152s + _prc117fs, true];

		// DEBUG LVL 3
		private _msg = format ["Boosted radio var now defined ( %1 ).", missionNamespace getVariable "RQ4Tweak_boostedRadios"];
		DEBUG_RPT(_msg, _curFunc);

		// Define the function for the first time, it only needs to be defined once.
		private _fnc = { 
			params ["_freq", "_pwr", "_receiver", "_broadcaster"]; 

			private _coreSignal = [_freq, _pwr, _receiver, _broadcaster] call acre_sys_signal_fnc_getSignalCore; 
			_coreSignal params ["_Px", "_maxSignal"]; 

			_outputPwr = if ( _broadcaster in (missionNamespace getVariable "RQ4Tweak_boostedRadios") ) then { 
				[1, 0];
			} else { 
				// Sets the radio back to its ACRE defined output power.
				[_Px, _maxSignal];
			}; 

			/* private _myHint = format ["TX ACTIVE. Broadcaster: %1 - Px/MaxSig: %2", _broadcaster, _outputPwr];
			[_myHint] remoteExec ["hint", 0]; */

			_outputPwr;
		}; 

		[_fnc] remoteExecCall ["acre_api_fnc_setCustomSignalFunc", 0, true];
	} else {
		private _data = missionNamespace getVariable "RQ4Tweak_boostedRadios";
		
		// Check if player's radios have already been added. If so, delete those radios from the arrays.
		private _radiosToAdd = [];
		{
			if ( not (_x in _data) ) then {
				_radiosToAdd pushBackUnique _x;
			};
		} forEach (_prc152s + _prc117fs);

		// DEBUG LVL 3
		private _msg = format ["Player %1's radios filtered, remaining are ( %2 ).", player, _radiosToAdd];
		DEBUG_RPT(_msg, _curFunc);

		// Add the new data
		//_data set [count _data, _prc152s + _prc117fs];
		{
			_data set [count _data, _x];
		} forEach _radiosToAdd;

		missionNamespace setVariable ["RQ4Tweak_boostedRadios", _data, true];

		// DEBUG LVL 3
		private _msg = format ["Boosted radio var already exists, adding ( %1 ). Var is now ( %2 ).", _radiosToAdd, missionNamespace getVariable "RQ4Tweak_boostedRadios"];
		DEBUG_RPT(_msg, _curFunc);
	};
} else {
	// Add undefined var protection.
	if ( missionNamespace getVariable ["RQ4Tweak_boostedRadios", false] isEqualTo false ) exitWith {
		// DEBUG LVL 3
		private _msg = format ["Attempted to delete local radios from boostedRadios var, but var doesn't exist!", _prc152s, _prc117fs];
		ERROR_RPT(_msg, _curFunc);
	};

	// Retrieve currently boosted radios, find the player's radios in that array, remove them, then broadcast the updated list.
	private _data = missionNamespace getVariable "RQ4Tweak_boostedRadios";
	
	{
		_data deleteAt (_data find _x);
	} forEach _prc152s + _prc117fs;

	missionNamespace setVariable ["RQ4Tweak_boostedRadios", _data, true];

	// DEBUG LVL 3
	private _msg = format ["Removed player %1's radio(s) ( %2 + %3 ) from boostedRadios, var is now ( %4 ).", player, _prc152s, _prc117fs, _data];
	DEBUG_RPT(_msg, _curFunc);
};
