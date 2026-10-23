/*
	Author: Myth

    Locality: Server.

	Description:
		Filters out dead, animals, model-hidden, mounted, LOS-blocked, too fast/slow, and out of FoR limits targets. Returns filtered list to MM_fnc_radarScan.

	Parameter(s):
		0: <OBJECT> - The AV that is performing the scan.
		1: <ARRAY> - The objects to be filtered, passed by MM_fnc_radarScan.

	Returns:
		Array of objects - The objects that qualify to become MTI targets.

	Examples:
		[myGlobalHawk, [car_1, myPlane, mrAnderson]] spawn MM_fnc_genericFilter
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#define DEBUG_ENABLED

#include "gh_defines.hpp"
#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_genericFilter";

params [
	["_gh", objNull, [objNull]],
	["_unsortedTargets", [], [[]]]
];

// DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1, %2]", _gh, _unsortedTargets];
DEBUG_RPT(_msg, _curFunc);

// If passed target array is empty, exit.
if ( count _unsortedTargets < 1 ) exitWith {
	
	// DEBUG LVL 2
	private _msg = format ["%1: Exiting at target array data check, array is empty.", _gh];
	ERROR_RPT(_msg, _curFunc);
};

private _mtiRecipients = missionNamespace getVariable ["RQ4Tweak_mtiRecipients", []];

// ---------------------------------
// Filter Execution
// ---------------------------------

// Find if AV is in the target list, if it is, remove it.
private _indexToDelete = _unsortedTargets findIf { _x isEqualTo _gh };
if ( _indexToDelete > -1 ) then {
	_unsortedTargets deleteAt _indexToDelete;

	// DEBUG LVL 3
	private _msg = format ["%1: Found %1 in unsortedTargets, deleting %1 from that array.", _gh];
	DEBUG_RPT(_msg, _curFunc);
};

// Create forEach loop to check all targets passed in unsortedTargets for validity.
private _targetsToDelete = [];

{
	//DEBUG LVL 3
	private _msg = format ["%1: Starting assessment of target %2.", _gh, _x];
	DEBUG_RPT(_msg, _curFunc);

	// If target has been spotted by a different AV, and Dupe Markers addon option is not enabled, remove the target to prevent unwanted duplication.
	private _lastSeen = _x getVariable ["RQ4Tweak_lastSeen", []];
	
	private _lastSpottedBy = if ( _lastSeen isEqualTo [] ) then {
		//DEBUG LVL 3
		private _msg = format ["%1: RQ4Tweak_lastSeen is empty ( %2 ) for target %3, defaulting to AV %1.", _gh, _lastSeen, _x];
		DEBUG_RPT(_msg, _curFunc);

		_gh;
	} else {
		//DEBUG LVL 3
		private _msg = format ["%1: RQ4Tweak_lastSeen is defined for target %3, using AV %2.", _gh, _lastSeen select 2, _x];
		DEBUG_RPT(_msg, _curFunc);

		_lastSeen select 2;
	};

	if ( (_lastSpottedBy isNotEqualTo _gh) and (not MM_RQ4_Allow_Duplicate_Markers) ) then {
		// DEBUG LVL 3
		private _msg = format ["%1: Target %2 already spotted by %3, deleting.", _gh, _x, _lastSpottedBy];
		DEBUG_RPT(_msg, _curFunc);

		_targetsToDelete pushBackUnique _x;

		continue;
	};

	// If enabled, check LOS from AV to target, if less than 0.4, remove target.
	if ( MM_RQ4_Enable_LOS ) then {
		private _losDecimals = [];
		private _losTarget = _x;
		private _losTargetPos = _losTarget modelToWorldVisualWorld [0, 0, 8];

		{
			private _model = _x;

			private _num = [objNull, _model] checkVisibility [_gh modelToWorldVisualWorld [0, 0, -8], _losTargetPos];

			_losDecimals pushBackUnique _num;
		} forEach ["FIRE", "VIEW", "GEOM", "IFIRE", "PHYSX"];

		private _msg = format ["%1: _losDecimals is now ( %2 ).", _gh, _losDecimals];
		DEBUG_RPT(_msg, _curFunc);

		// Take the value of whichever LOS model returns greatest number, circumvents most ArmA engine fuckery.
		private _losDecimal = selectMax _losDecimals;

		if ( _losDecimal < 0.4 ) then {
			// DEBUG LVL 3
			private _msg = format ["%1: Target %2 is below LOS threshold (%3 < 0.4), deleting.", _gh, _x, _losDecimal];
			DEBUG_RPT(_msg, _curFunc);
			
			// DEBUG LVL 3
			private _msg = format ["%1: Passing %2 to fn_fadeMarker with params [%2, %3, %4].", _gh, _x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh];
			DEBUG_RPT(_msg, _curFunc);

			// If no marker has been created for this target, pass an empty marker name to fn_fadeMarker. This will effectively end that script immediately (good thing).
			//[_x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh] spawn MM_fnc_fadeMarker;
			[_x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh] remoteExec ["MM_fnc_fadeMarker", _mtiRecipients];

			_targetsToDelete pushBackUnique _x;

			continue;
		};
	};

	// If target is dead, and animal, objectHidden, or mounted infantry, remove it.
	if (
		(not alive _x)
		or 
		(_x isKindOf "Animal")
		or 
		(isObjectHidden _x)
		or 
		(vehicle _x isNotEqualTo _x)
	) then {
		// DEBUG LVL 3
		private _msg = format ["%1: Passing %2 to fn_fadeMarker with params [%2, %3, %4].", _gh, _x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh];
		DEBUG_RPT(_msg, _curFunc);

		// If no marker has been created for this target, pass an empty marker name to fn_fadeMarker. This will effectively end that script immediately (good thing).
		//[_x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh] spawn MM_fnc_fadeMarker;
		[_x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh] remoteExec ["MM_fnc_fadeMarker", _mtiRecipients];

		_targetsToDelete pushBackUnique _x;

		continue;
	};

	// Check target speed, if too fast or too slow, remove it.
	if ( (speed _x > parseNumber MM_RQ4_Max_Speed) or (speed _x < parseNumber MM_RQ4_Min_Speed) ) then {
		// DEBUG LVL 3
		private _msg = format ["%1: Target %2 is outside of speed threshold (%3 | %4-%5), deleting.", _gh, _x, speed _x, parseNumber MM_RQ4_Min_Speed, parseNumber MM_RQ4_Max_Speed];
		DEBUG_RPT(_msg, _curFunc);

		// DEBUG LVL 3
		private _msg = format ["%1: Passing %2 to fn_fadeMarker with params [%2, %3, %4].", _gh, _x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh];
		DEBUG_RPT(_msg, _curFunc);

		// If no marker has been created for this target, pass an empty marker name to fn_fadeMarker. This will effectively end that script immediately (good thing).
		//[_x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh] spawn MM_fnc_fadeMarker;
		[_x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh] remoteExec ["MM_fnc_fadeMarker", _mtiRecipients];
		
		_targetsToDelete pushBackUnique _x;

		continue;
	};

	// Check if the target is inside the AV's sensor blindspot (nose and tail).
	if ( 
		((_gh getRelDir _x) > (LFOVFront) and ((_gh getRelDir _x) < (RFOVFront)))   // Targets in the nose blindspot
        or
        ((_gh getRelDir _x) > (LFOVRear) and ((_gh getRelDir _x) < (RFOVRear)))
	) then {
		// DEBUG LVL 3
		private _msg = format ["%1: Target %2 is blindspot (%3 relDir), deleting.", _gh, _x, _gh getRelDir _x];
		DEBUG_RPT(_msg, _curFunc);
		
		// DEBUG LVL 3
		private _msg = format ["%1: Passing %2 to fn_fadeMarker with params [%2, %3, %4].", _gh, _x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh];
		DEBUG_RPT(_msg, _curFunc);

		// If no marker has been created for this target, pass an empty marker name to fn_fadeMarker. This will effectively end that script immediately (good thing).
		//[_x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh] spawn MM_fnc_fadeMarker;
		[_x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh] remoteExec ["MM_fnc_fadeMarker", _mtiRecipients];

		_targetsToDelete pushBackUnique _x;

		continue;
	};

	// Check if target is in the FoR boundaries for the current side the radar beam is on (slew), if not, remove target.
	private _slewSide = _gh getVariable ["RQ4Tweak_slewSide", MM_RQ4_StartSlew];
	if (
		not ( 
			( (_gh getRelDir _x) >= (BothFOV select _slewSide select 0) )
			and
			( (_gh getRelDir _x) <= (BothFOV select _slewSide select 1) )
		)
	) then {
		// DEBUG LVL 3
		private _msg = format ["%1: Target %2 is outside of FoR boundaries (%3 | %4-%5), deleting.", _gh, _x, _gh getRelDir _x, BothFOV select _slewSide select 0, BothFOV select _slewSide select 1];
		DEBUG_RPT(_msg, _curFunc);
		
		// DEBUG LVL 3
		private _msg = format ["%1: Passing %2 to fn_fadeMarker with params [%2, %3, %4].", _gh, _x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh];
		DEBUG_RPT(_msg, _curFunc);

		// If no marker has been created for this target, pass an empty marker name to fn_fadeMarker. This will effectively end that script immediately (good thing).
		//[_x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh] spawn MM_fnc_fadeMarker;
		[_x, (_x getVariable ["RQ4Tweak_mtiMarkerParams", [""]]) select 0, _gh] remoteExec ["MM_fnc_fadeMarker", _mtiRecipients];

		_targetsToDelete pushBackUnique _x;

		continue;
	};
} forEach _unsortedTargets;

// I know this is a really stupid way to do it, but I had to shoehorn this in after I wrote everything above lol.
// DEBUG LVL 3
private _msg = format ["%1: Targets to delete are %2.", _gh, _targetsToDelete];
DEBUG_RPT(_msg, _curFunc);

{
	private _target = _x;
	
	private _index = _unsortedTargets findIf {
		_x isEqualTo _target;
	};

	_unsortedTargets deleteAt _index;
} forEach _targetsToDelete;

// ---------------------------------
// Returns
// ---------------------------------

// DEBUG LVL 3
private _msg = format ["%1: Complete - Returns: %2", _gh, _unsortedTargets];
DEBUG_RPT(_msg, _curFunc);

// Says unsortedTargets, but targets are actually sorted from the forEach loop above.
_unsortedTargets;