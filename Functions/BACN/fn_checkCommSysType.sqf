/*
	Author: Myth

    Locality: Server.

	Description: Checks if the player is using vanilla comms, TFAR Beta, or ACRE 2. Configures the rest of the BACN payload appropriately.


	Parameter(s): None.

	Returns:
		0: <STRING> - "Vanilla", "TFAR", or "ACRE" or "ERROR".

	Examples:
		call MM_fnc_checkCommSysType;
*/

#define DEBUG_ENABLED

// ---------------------------------
// Script Start, Evaluation, and Returns
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_checkCommSysType";

// DEBUG LVL 3
private _msg = format ["%1: Started - No params.", _gh];
DEBUG_RPT(_msg, _curFunc);

// Check if BOTH TFAR and ACRE are loaded. If so, throw an error in RPT.
if ( isClass(configFile >> "CfgPatches" >> "") and isClass(configFile >> "CfgPatches" >> "")) exitWith {
	//DEBUG LVL 2
	private _msg = "RQ-4 BACN detects BOTH TFAR and ACRE loaded! Only one should be loaded!";
	ERROR_RPT(_msg, _curFunc);
	
	"ERROR"; 
};

// Check if TFAR is loaded.
if ( isClass(configFile >> "CfgPatches" >> "tfar_core") ) exitWith {
	//DEBUG LVL 2
	private _msg = "Server is using TFAR communication system.";
	DEBUG_RPT(_msg, _curFunc);

	"TFAR";
};

// Check if ACRE 2 is loaded.
if ( isClass(configFile >> "CfgPatches" >> "acre_main") ) exitWith {
	//DEBUG LVL 2
	private _msg = "Server is using ACRE 2 communication system.";
	DEBUG_RPT(_msg, _curFunc);

	"ACRE";
};

// If script gets to this point, player is just running Vanilla (or some obscure shit I don't know about lol).
//DEBUG LVL 3
private _msg = "Server is using vanilla (or other) communication system.";
DEBUG_RPT(_msg, _curFunc);

"Vanilla";