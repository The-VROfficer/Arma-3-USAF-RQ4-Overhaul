/*
	Author: Myth

    Locality: Local, executed on the aircraft. If spawned in by Zeus, the aircraft is local to the Zeus's computer. If placed in the mission file, it belongs to the server.

	Description:
		Creates a custom eventhandler to manage player connect/disconnect to the passed UAV, defines variables needed for dependent scripts, creates object deletion handling, and performs CBA addon option handling.
		Is called automatically from the config file of the USAF RQ-4A upon spawning/initialization.

	Parameter(s):
		0: <OBJECT> - The MTI vehicle.

	Returns:
		BOOLEAN - Completion flag.
*/

params [
	["_gh", objNull, [objNull]]
];

if ( not isServer ) exitWith { false };	// This script should be executed on the server only to prevent duplication.

// ---- Add deletion protection
_gh addEventHandler ["Deleted",{
	params ["_entity"];

	private _gh = _entity;

	// ---- Evaluates and fade this aircraft's targets
	private _targets = nearestObjects [_gh, ["Car", "Helicopter", "Plane", "Ship", "Tank", "Truck", "UAV"], parseNumber MM_RQ4_Ranges_S3_Max, true];
	hint str _targets;

	if (count _targets > 0) then {
		{
			private _GMTI_Marker_Info = _x getVariable ["GMTI_Marker_Info", []];
			private _GMTI_Marker = _GMTI_Marker_Info select 0;
       	 	private _GMTI_Fading = _x getVariable ["GMTI_Fading", []];

			if ( not (_GMTI_Marker_Info isEqualTo []) and (_GMTI_Fading isEqualTo []) ) then {     // If target has been spotted before and is not already fading, assess using the fade script
				if ( _x getVariable "GMTI_Fading" == 1 ) exitwith {};   // If target has completed fadeout, skip this TOI, otherwise...
				[_x, _GMTI_Marker] spawn MM_fnc_fadeMTI;    // ...begin fadeout for this TOI
			};
		} forEach _targets;
	};

	// ---- Terminate fnc_drawFoR, run fnc_clearFoR
	if ( not (isNil {missionNamespace getVariable "GMTI_FoR_On"}) ) then {		// Prevents errors in case FoR was never drawn.
		(findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler ["Draw", missionNamespace getVariable "GMTI_FoR_On" select 1];
    	(findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler ["Draw", missionNamespace getVariable "GMTI_FoR_On" select 2];
	};

	private _ghPilot = ([_gh] call MM_fnc_checkConnected) select 1;
	[_gh, _ghPilot] call MM_fnc_cleanFoR;

	// ---- Remove GRCAs associated with the aircraft
	private _GRCAs = _gh getVariable ["GMTI_GRCAs", []];

	if (not (_GRCAs isEqualTo [])) then {		// Some GRCAs have been created.
		_GRCAs apply { deleteMarker (_x select 4); deleteMarker (_x select 5) };
	};
}];

_gh setVariable ["GMTI_Slew_Side", MM_RQ4_StartSlew, true];
_gh setVariable ["GMTI_isSlewing", false, true];
_gh setVariable ["GMTI_Mode", "RRCA", true];

sleep 1;

// ---- Start checking for UAV controller (kind of a custom eventhandler) and all valid MTI recipients.
[_gh] spawn {
	params ["_gh"];

	while { not isNull _gh } do {	// If the aircraft has been deleted, stop checking if a player is connected.
		if (not alive _gh) exitWith {};

		// ---- Detect JIP players, add markers for them.
		{
			if ( (alive _x) and (isNil {_x getVariable "GMTI_JIP_Complete"}) ) then {
				[_gh, _x] remoteExecCall ["MM_fnc_executeJIP", _x];
			};
		} forEach allPlayers;

		// ---- Detect and handle current UAV pilot and MTI recipients
		private _ghPilot = if ( (([_gh] call MM_fnc_checkConnected) select 1) isEqualTo objNull ) then {
			objNull;
		} else {
			([_gh] call MM_fnc_checkConnected) select 1;
		};

		_gh setVariable ["GMTI_Pilot", _ghPilot, true];

		// NEW CODE
		_gh setVariable ["GMTI_allRecipients", [], true];	// Resets every iteration to prevent stale data.

		private _recipients = [_gh] call MM_fnc_checkRecipient;

		// NEW CODE
		_gh setVariable ["GMTI_allRecipients", _recipients, true];

		// OLD CODE, this still may work so give it a try
		/*
		if ( _ghPilot isEqualTo objNull ) then {	// This check prevents errors being thrown due to the GH pilot being undefined, this is important as GMTI_allRecipients is used in MM_fnc_targetCollection.
			_gh setVariable ["GMTI_allRecipients", _recipients, true];
		} else {
			_gh setVariable ["GMTI_allRecipients", _recipients + [_ghPilot], true];
		};
		*/

		sleep 1;
	};

	if ( not isNull _gh ) then {
		if ( not alive _gh ) then {		// Aircraft has died, but not deleted.
			[_gh, _gh getVariable "GMTI_Pilot"] call MM_fnc_cleanFoR;
		};
	}; 

};

if (MM_RQ4_RangesSimple) then {
	MM_RQ4_Ranges_S1_Min = "1000";
	MM_RQ4_Ranges_S1_Max = "2999";
	MM_RQ4_Ranges_S2_Min = "3000";
	MM_RQ4_Ranges_S2_Max = "5999";
	MM_RQ4_Ranges_S3_Min = "6000";
	MM_RQ4_Ranges_S3_Max = "12000";
};

[_gh] spawn MM_fnc_targetCollection;

true;