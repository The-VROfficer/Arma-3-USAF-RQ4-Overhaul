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

#define DEBUG_ENABLED

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_collectMTI";

params [
	["_gh", objNull, [objNull]],
	["_sound", "", ["a"]]
];

// Check if this is a duplicate execution for this AV.
if ( (_gh getVariable ["RQ4Tweak_collectMTIRunning", []]) isNotEqualTo [] ) exitWith {
	// DEBUG LVL 2
	private _msg = format ["%1: Exiting at beginning, this function is a duplicate.", _gh];
	ERROR_RPT(_msg, _curFunc);
};

// DEBUG LVL 3
private _msg = format ["%1: Started.", _gh];
DEBUG_RPT(_msg, _curFunc);

// Handle deletion of the AV.
private _ghDeletedEH = _gh addEventHandler ["Deleted",{
	params ["_entity"];
	
	// DEBUG LVL 3
	private _msg = format ["%1: Deletion protection triggered, %1 was deleted.", _entity];
	ERROR_RPT(_msg, _curFunc);

	// Add logic for GUI deletion HERE
	//

	// Turn off FOR cone if rendered.
	if ( (_entity getVariable ["RQ4Tweak_forEH", []]) isNotEqualTo [] ) then {
		(_entity getVariable "RQ4Tweak_forEH") params ["_forEH", "_mapCtrl"];

		_mapCtrl ctrlRemoveEventHandler ["Draw", _forEH];

		_entity setVariable ["RQ4Tweak_forEH", nil, true];

		// DEBUG LVL 3
		private _msg = format ["%1: FOR deleted as part of deletion protection.", _entity];
		DEBUG_RPT(_msg, _curFunc);
	};

	// Fadeout markers that were "spotted" by the deleted AV.
	{
		private _mtiMarker = (_x getVariable "RQ4Tweak_mtiMarkerParams") select 0 select 0;

		[_x, _mtiMarker, _entity, true] remoteExec ["MM_fnc_fadeMarker", missionNamespace getVariable ["RQ4Tweak_mtiRecipients", []]];

		// DEBUG LVL 3
		private _msg = format ["%1: Fadeout triggered for %2 due to %1 deletion.", _entity, _mtiMarker];
		ERROR_RPT(_msg, _curFunc);
	} forEach (_entity getVariable ["RQ4Tweak_trackedTargets", []]);

	// Delete all queued marker creation/update commands for JIP clients
	

	_entity removeEventHandler ["Deleted", _thisEventHandler];
}];

// The query for MTI receipients (both server-wide and on AV's side) were made into in-line functions to facilitate real-time updating.
// If the "object getVariable 'yada'" is run once at the beginning of the script, it doesn't update unless it's called again.
private _mtiRecipients = {
	private _array = missionNamespace getVariable ["RQ4Tweak_mtiRecipients", []];

	// DEBUG LVL 3
	private _msg = format ["%1: _mtiRecipient - Results: %2", _gh, _array];
	DEBUG_RPT(_msg, _curFunc);

	_array;
};

private _curMTIRecipients = call _mtiRecipients;

private _sideRecipients = {
	private _array = [];

	{
		if ( side _x isEqualTo side _gh ) then {
			_array pushBackUnique _x;
		};
	} forEach _curMTIRecipients;

	// DISABLED for now, keeps throwing duplicate RPT entries during testing and its really annoying
	/* // DEBUG LVL 3
	private _msg = format ["%1: _sideRecipient - Results: %2, %3", _gh, side _gh, _array];
	DEBUG_RPT(_msg, _curFunc); */

	_array;
};

private _curSideRecipients = call _sideRecipients;

// Evaluate if there are any MTI recipient players (on the entire server first, then on this AV's side specifically). If none exist, exit.
if ( ( count _curMTIRecipients < 1) or (count _curSideRecipients < 1) ) exitWith {
	// DEBUG LVL 3
	private _msg = format ["%1: Exiting at MTI recipient check - Total recipients: %2, Sames-side recipients: %3", _gh, _curMTIRecipients, _curSideRecipients];
	DEBUG_RPT(_msg, _curFunc);
};

// DEBUG LVL 3
private _msg = format ["%1: Passed MTI recipient ( %2 ) and Side ( %3 ) checks. ", _gh, _curMTIRecipients, _curSideRecipients];
DEBUG_RPT(_msg, _curFunc);

sleep 1;

// ---------------------------------
// Target Collection, Randomization, and Marking
// ---------------------------------

// Begin loop to collect targets, initially defined conditions is boiler plate and more are defined below through the use of the "breakWith" command.
_collectionLoop = while { not isNull _gh } do {
	// DEBUG LVL 3
	private _msg = format ["%1: Starting new collectionLoop iteration.", _gh];
	DEBUG_RPT(_msg, _curFunc);
	
	[_sound] remoteExec ["playSound"];	// DEBUG

	// Define all break out conditions
	if ( not alive _gh ) then {
		// DEBUG LVL 3
		private _msg = format ["%1: Collection loop canceled, %1 is dead.", _gh];
		DEBUG_RPT(_msg, _curFunc);

		breakWith "DEAD";
	};

	if ( count (call _sideRecipients) < 1 ) then {
		// DEBUG LVL 3
		private _msg = format ["%1: Collection loop canceled, no MTI recipients on side of %1.", _gh, call _sideRecipients];
		DEBUG_RPT(_msg, _curFunc);

		breakWith "NO_SIDE_RECIPIENTS";
	};

	if ( (getPosATL _gh select 2) < (parseNumber MM_RQ4_Min_Altitude) ) then {
		// DEBUG LVL 3
		private _msg = format ["%1: Collection loop canceled, %1 altitude AGL is too low ( %2 ).", _gh, getPosATL _gh select 2];
		DEBUG_RPT(_msg, _curFunc);

		breakWith "LOW_ALT";
	};

	if ( _gh getVariable ["RQ4Tweak_sensorOn", []] isNotEqualTo true ) then {
		// DEBUG LVL 3
		private _msg = format ["%1: Collection loop canceled, %1's sensor is OFF ( %2 ).", _gh, _gh getVariable ["RQ4Tweak_sensorOn", []]];
		DEBUG_RPT(_msg, _curFunc);

		breakWith "SENSOR_OFF";
	};

	if ( _gh getVariable ["RQ4Tweak_isSlewing", false] == true ) then {
		// DEBUG LVL 3
		private _msg = format ["%1: Radar is slewing, skipping this iteration.", _gh];
		DEBUG_RPT(_msg, _curFunc);

		sleep parseNumber MM_RQ4_Update_Rate;

		continue;
	};

	// Determine GUI selected MTI mode and change passed arguments as appropriate.
	// This if statement will return an array of arrays containing the sorted and valid targets.
	_filteredTargets = if ( _gh getVariable ["RQ4Tweak_mtiMode", "RRCA"] isEqualTo "RRCA") then {
		private _msg = format ["%1: Calling MM_fnc_radarScan - Params: %1, null (defaults to 'RRCA').", _gh];
		DEBUG_RPT(_msg, _curFunc);

		[_gh] call MM_fnc_radarScan;
	} else {
		// DEBUG LVL 3
		private _msg = format ["%1: Calling MM_fnc_radarScan - Params: %1, true (GRCA).", _gh];
		DEBUG_RPT(_msg, _curFunc);

		[_gh, true] call MM_fnc_radarScan;
	};

	// If fn_radarScan returns nothing, skip this collectionLoop iteration, fade all trackedTargets and set trackedTargets to none. Saves performance by not calling empty functions!
	if ( (count (_filteredTargets select 0) < 1) and (count (_filteredTargets select 1) < 1) and (count (_filteredTargets select 2) < 1) ) then {
		// DEBUG LVL 3
		private _msg = format ["%1: filteredTargets is completely empty ( %2 ), skipping this iteration.", _gh, _filteredTargets];
		DEBUG_RPT(_msg, _curFunc);
		
		private _trackedTargets = _gh getVariable ["RQ4Tweak_trackedTargets", []];
		if ( count _trackedTargets > 0 ) then {
			{
				// It's guaranteed by this point, if the target is present in trackedTargets in the first place, that it will have mtiMarkerParams.
				[_x, (_x getVariable "RQ4Tweak_mtiMarkerParams") select 0 select 0, _gh, true] remoteExec ["MM_fnc_fadeMarker", missionNamespace getVariable ["RQ4Tweak_mtiRecipients", []]];
			} forEach _trackedTargets;
		};

		_gh setVariable ["RQ4Tweak_trackedTargets", [], true];

		// Wait until next simulated radar sweep
		sleep parseNumber MM_RQ4_Update_Rate;

		continue;
	};

	// Perform Probability of Detect randomization
	_finalTargets = [_filteredTargets] call MM_fnc_applyPoD;

	// Now that filtering is complete, tag remaining targets as "seen" by this AV.
	{
		private _hourSpotted = floor dayTime;
		private _minuteSpotted = floor ((dayTime - _hourSpotted) * 60);
		if ( _minuteSpotted < 10 ) then {
			_minuteSpotted = format ["0%1", _minuteSpotted];
		} else {
			_minuteSpotted = str _minuteSpotted;
		};
		
		_x setVariable ["RQ4Tweak_isFading", false, true];
		_x setVariable ["RQ4Tweak_lastSeen", [time, [_hourSpotted, _minuteSpotted], _gh], true];

		// DEBUG LVL 3
		private _msg = format ["%1: %2 update to lastSeen [%3, %4, %1].", _gh, _x, time, [_hourSpotted, _minuteSpotted]];
		DEBUG_RPT(_msg, _curFunc);
	} forEach _finalTargets;

	// Attribute the final targets to this AV, allows these targets to be faded immediately if AV is deleted.
	_gh setVariable ["RQ4Tweak_trackedTargets", _finalTargets, true];

	// Send final targets to be created (or updated if already exists) on MTI recipients' maps via fnc_handleMTIMarker
	[_gh, _finalTargets] call MM_fnc_handleMTIMarker;

	// Wait until next simulated radar sweep
	sleep parseNumber MM_RQ4_Update_Rate;
};

// ---------------------------------
// Assess Loop Termination Reason
// ---------------------------------

if ( isNull _gh ) exitWith {
	// DEBUG LVL 2
	private _msg = "NULL: Exiting at loop termination assessment, AV was deleted.";
	ERROR_RPT(_msg, _curFunc);

	// Figure out if we need additional logic for cleanup if AV is deleted HERE 
	//
};

if ( _collectionLoop isEqualTo "LOW_ALT" ) then {
	// Add logic for greying out SENSOR ON button on sensor control GUI HERE 
	//

	// Notifying connected UAV operator that the AV has gotten too low.
	private _pilot = _gh getVariable ["RQ4Tweak_pilot", []];

	[["AV descended below the minimum collection altitude [%1m AGL], sensor <t color='#FF0000'>disabled</t>.", parseNumber MM_RQ4_Min_Altitude], 2.5] remoteExecCall ["ace_common_fnc_displayTextStructured", _pilot];


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