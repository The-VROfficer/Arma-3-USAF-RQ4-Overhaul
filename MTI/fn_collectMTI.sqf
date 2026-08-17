/*
	Author: Myth

    Locality: Server.

	Description:
		Manages functions that collect entities near the AV and filter down the list to only applicable MTI targets. Once only applicable MTI targets are remaining, calls functions to display them on the map.
		Runs when radar is enabled through the sensor control GUI, and only if jet is alive. Time between iterations is determined in addon options.

	Parameter(s):
		0: <OBJECT> - The AV.

	Returns:
		Nothing

	Examples:
		[myGlobalHawk] spawn MM_fnc_collectMTI
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

params [
	["_gh", objNull, [objNull]]
];

// Check if this is a duplicate execution for this AV.
if ( (_gh getVariable ["RQ4Tweak_collectMTIRunning", []]) isNotEqualTo [] ) exitWith {
	// DEBUG LVL 2
	WARNING(format ["MM_fnc_collectMTI, %1: Exiting at beginning, this function is a duplicate.", _gh]);
};

// DEBUG LVL 3
LOG(format ["MM_fnc_collectMTI, %1: Started.", _gh]);

// Handle deletion of the AV.
private _ghDeletedEH = addEventHandler ["Deleted",{
	params ["_entity"];
	
	WARNING(format ["MM_fnc_collectMTI, %1, _ghDeletedEH: Deletion protection triggered, %1 was deleted.", _gh]);

	// Add logic for GUI deletion HERE
	//

	// Add logic for deletion of all markers associated with this AV HERE
	//

	_entity removeEventHandler ["Deleted", _thisEventHandler];
}];

// The query for MTI receipients (both server-wide and on AV's side) were made into in-line functions to facilitate real-time updating.
// If the "object getVariable 'yada'" is run once at the beginning of the script, it doesn't update unless it's called again.
private _mtiRecipients = {
	private _array = missionNamespace getVariable ["RQ4Tweak_mtiRecipients", []];

	// DEBUG LVL 3
	LOG(format ["MM_fnc_collectMTI, %1, _mtiRecipient - Results: %2", _gh, _array]);

	_array;
};

private _sideRecipients = {
	private _array = [];

	{
		if ( side _x isEqualTo side _gh ) then {
			_array pushBackUnique _x;
		};
	} forEach (call _mtiRecipients);

	// DEBUG LVL 3
	LOG(format ["MM_fnc_collectMTI, %1, _sideRecipient - Results: %2, %3", _gh, side _gh, _array]);

	_array;
};

// Evaluate if there are any MTI recipient players (on the entire server first, then on this AV's side specifically). If none exist, exit.
if ( ( count (call _mtiRecipients) < 1) or (count (call _sideRecipients) < 1) ) exitWith {
	// DEBUG LVL 3
	LOG(format ["MM_fnc_collectMTI, %1: Exiting at MTI recipient check - Total recipients: %2, Sames-side recipients: %3", _gh, _mtiRecipients, _sideRecipients]);
};

// ---------------------------------
// Target Collection, Randomization, and Marking
// ---------------------------------

// Begin loop to collect targets, initially defined conditions is boiler plate and more are defined below through the use of the "breakWith" command.
_collectionLoop = while { not isNull _gh } do {
	// Define all break out conditions
	if ( not alive _gh ) then {
		breakWith "DEAD";
		// DEBUG LVL 3
		LOG(format ["MM_fnc_collectMTI, %1: Collection loop canceled, %1 is dead.", _gh]);
	};

	if ( count (call _sideRecipients) < 1 ) then {
		breakWith "NO_SIDE_RECIPIENTS";
		// DEBUG LVL 3
		LOG(format ["MM_fnc_collectMTI, %1: Collection loop canceled, no MTI recipients on side of %1.", _gh, call _sideRecipients]);
	};

	if ( (getPosATL _gh select 2) < 3000 ) then {
		breakWith "LOW_ALT";
		// DEBUG LVL 3
		LOG(format ["MM_fnc_collectMTI, %1: Collection loop canceled, %1 altitude AGL is too low (%2).", _gh, getPosATL _gh select 2]);
	};

	if ( _gh getVariable ["RQ4Tweak_sensorOn", []] isNotEqualTo true ) then {
		breakWith "SENSOR_OFF";
		// DEBUG LVL 3
		LOG(format ["MM_fnc_collectMTI, %1: Collection loop canceled, %1 sensor is off (%2).", _gh, _gh getVariable ["RQ4Tweak_sensorOn", []]]);
	};

	// Determine GUI selected MTI mode and change passed arguments as appropriate.
	// This if statement will return an array of arrays containing the sorted and valid targets.
	_filteredTargets = if ( _gh getVariable ["RQ4Tweak_mtiMode", "RRCA"] isEqualTo "RRCA") then {
		LOG(format ["MM_fnc_collectMTI, %1: Calling MM_fnc_radarScan - Params: %1, null (RRCA).", _gh]);

		[_gh] call MM_fnc_radarScan;
	} else {
		// DEBUG LVL 3
		LOG(format ["MM_fnc_collectMTI, %1: Calling MM_fnc_radarScan - Params: %1, true (GRCA).", _gh]);

		[_gh, true] call MM_fnc_radarScan;
	};

	// Perform Probability of Detect randomization
	_finalTargets = [_filteredTargets] call MM_fnc_applyPoD;

	// Now that filtering is complete, tag remaining targets as "seen" by this AV.
	{
		private _hourSpotted = floor dayTime;
		private _minuteSpotted = floor ((dayTime - _hourSpotted) * 60);
		if ( _minuteSpotted < 10 ) then {
			_minuteSpotted = format ["0%1", _minuteSpotted]
		};
		
		_x setVariable ["RQ4Tweak_lastSeen", [time, [_hourSpotted, _minuteSpotted], _gh], true];

		// DEBUG LVL 3
		LOG(format ["MM_fnc_collectMTI, %1: %2 update to lastSeen [%3, %4, %1].", _gh, _x, time, [_hourSpotted, _minuteSpotted]]);
	} forEach _finalTargets;

	// Send final targets to be created (or updated if already exists) on MTI recipients' maps via fnc_handleMTIMarker
	[_gh, _finalTargets] call MM_fnc_handleMTIMarker;

	// Wait until next simulated radar sweep
	sleep MM_RQ4_Update_Rate;
};

// ---------------------------------
// Assess Loop Termination Reason
// ---------------------------------

if ( isNull _gh ) exitWith {
	// DEBUG LVL 2
	WARNING("MM_fnc_collectMTI, NULL: Exiting at loop termination assessment, AV was deleted.");

	// Figure out if we need additional logic for cleanup if AV is deleted HERE 
	//
};

if ( _collectionLoop isEqualTo "LOW_ALT" ) then {
	// Add logic for greying out SENSOR ON button on sensor control GUI HERE 
	//

	// Add logic for notifying connected UAV operator that the AV has gotten too low HERE 
	//

	// Maybe this can aid in changing the color of the SENSOR ON button in the GUI?
	_gh setVariable ["RQ4Tweak_sensorOn", false, true];
};

// Add logic to handle different cases for why the _collectionLoop would exit, whether as planned or prematurely HERE
//

// ---------------------------------
// End of Script Cleanup
// ---------------------------------

_gh removeEventHandler ["Deleted", _ghDeletedEH];

// Allow for the re-running of the script post-cleanup.
_gh setVariable ["RQ4Tweak_collectMTIRunning", nil, true];