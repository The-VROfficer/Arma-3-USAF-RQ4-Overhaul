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

params [
	["_gh", objNull, [obNull]],
	["_unsortedTargets", [], [[true]]]
];

// DEBUG LVL 3
LOG(format ["MM_fnc_genericFilter, %1: Running / Params: %1, %2", _gh, _unsortedTargets]);

// If passed target array is empty, exit.
if ( count _unsortedTargets < 1 ) exitWith {
	
	// DEBUG LVL 3
	ERROR(format ["MM_fnc_genericFilter, %1: Exiting at target array data check, array is empty.", _gh]);
};

// ---------------------------------
// Filter Execution
// ---------------------------------

// Find if AV is in the target list, if it is, remove it.
private _indexToDelete = _unsortedTargets findIf { _x isEqualTo _gh };
if ( _indexToDelete > -1 ) then {
	_unsortedTargets deleteAt _indexToDelete;

	// DEBUG LVL 3
	LOG(format ["MM_fnc_genericFilter, %1: Found %1 in unsortedTargets, deleting for array.", _gh]);
};

// Create forEach loop to check all targets passed in unsortedTargets for validity.
{
	// If target has been spotted by a different AV, and Dupe Markers addon option is not enabled, remove the target to prevent unwanted duplication.
	private _lastSpottedBy = _x getVariable ["RQ4Tweak_lastSeen", []] select 2;
	if ( (_lastSpottedBy isNotEqualTo _gh) and (not MM_RQ4_Allow_Duplicate_Markers) ) then {
		// DEBUG LVL 3
		LOG(format ["MM_fnc_genericFilter, %1: Target %2 already spotted by %3, deleting.", _gh, _x, _lastSpottedBy]);

		_unsortedTargets deleteAt _forEachIndex;

		continue;
	};

	// Check LOS from AV to target, if less than 0.4, remove target.
	private _losDecimal = [objNull, "GEOM"] checkVibility [getPosASL _gh, getPosASL _x];
	if ( _losDecimal < 0.4 ) then {
		// DEBUG LVL 3
		LOG(format ["MM_fnc_genericFilter, %1: Target %2 is below LOS threshold (%3), deleting.", _gh, _x, _losDecimal]);
		
		_unsortedTargets deleteAt _forEachIndex;

		continue;
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
		_unsortedTargets deleteAt _forEachIndex;

		continue;
	};

	// Check target speed, if too fast or too slow, remove it.
	if ( (speed _x > MM_RQ4_Max_Speed) or (speed _x < MM_RQ4_Min_Speed) ) then {
		// DEBUG LVL 3
		LOG(format ["MM_fnc_genericFilter, %1: Target %2 is outside of speed threshold (%3), deleting.", _gh, _x, speed _x]);
		
		_unsortedTargets deleteAt _forEachIndex;

		continue;
	};

	// Check if the target is inside the AV's sensor blindspot (nose and tail).
	if ( 
		((_gh getRelDir _x) > (LFOVFront) and ((_gh getRelDir _x) < (RFOVFront)))   // Targets in the nose blindspot
        or
        ((_gh getRelDir _x) > (LFOVRear) and ((_gh getRelDir _x) < (RFOVRear)))
	) then {
		// DEBUG LVL 3
		LOG(format ["MM_fnc_genericFilter, %1: Target %2 is blindspot (%3 relDir), deleting.", _gh, _x, _gh getRelDir _x]);
		
		_unsortedTargets deleteAt _forEachIndex;

		continue;
	};

	// Check if target is in the FoR boundaries for the current side the radar beam is on (slew), if not, remove target.
	private _slewSide = _gh getVariable ["RQ4Tweak_slewSide", 0];
	if (
		not ( 
			( (_gh getRelDir _x) >= (BothFOV select _slewSide select 0) )
			and
			( (_gh getRelDir _x) <= (BothFOV select _slewSide select 1) )
		)
	) then {
		// DEBUG LVL 3
		LOG(format ["MM_fnc_genericFilter, %1: Target %2 is outside of FoR boundaries (%3 | %4-%5), deleting.", _gh, _x, _gh getRelDir _x, BothFOV select _slewSide select 0, BothFOV select _slewSide select 1]);
		
		_unsortedTargets deleteAt _forEachIndex;

		continue;
	};
} forEach _unsortedTargets;

// ---------------------------------
// Returns
// ---------------------------------

// DEBUG LVL 3
LOG(format ["MM_fnc_genericFilter, %1: Complete - Returns: %2", _gh, _unsortedTargets]);

// Says unsortedTargets, but targets are actually sorted from the forEach loop above.
_unsortedTargets;