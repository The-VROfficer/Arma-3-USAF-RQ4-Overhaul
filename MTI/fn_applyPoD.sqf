/*
	Author: Myth

    Locality: Server.

	Description:
		

	Parameter(s):
		0: <ARRAY of ARRAYS> - The three populated range bins from MM_fnc_scanRadar that need to be "randomized".

	Returns:
		Array of Objects - The final list of objects to be rendered as MTI targets on the map. Sorting no longer required.

	Examples:
		[[truck_sector1, car_sector1], [tank_sector2], [boat_sector3]] spawn MM_fnc_applyPoD
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

params [
	["_allBins", [[], [], []], [[true], [true], [true]]]
];

// DEBUG LVL 3
LOG(format ["MM_fnc_applyPoD, %1: Running - Params: %2", _gh, _allBins]);

// Break down allBins into its individual components for condition checking below. X is included in the name to avoid specifying if targets are RRCA or GRCA.
private _s1XTargets = _allBins select 0;
private _s2XTargets = _allBins select 1;
private _s3XTargets = _allBins select 2;

// Create forEach loop iterating through each index of all range bins.
// Dice roll, see if distance-sorted targets pass the PoD check, if not, target gets deleted from the detection pool on this pass
{
	switch (true) do {
		case ( _x in _s1XTargets ): { if ( random 1.0 >= MM_RQ4_PoD_S1 ) then { _s1XTargets deleteAt _forEachIndex } };
		case ( _x in _s2XTargets ): { if ( random 1.0 >= MM_RQ4_PoD_S2 ) then { _s2XTargets deleteAt _forEachIndex } };
		case ( _x in _s3XTargets ): { if ( random 1.0 >= MM_RQ4_PoD_S3 ) then { _s3XTargets deleteAt _forEachIndex } };
	};
} forEach _s1XTargets + _s2XTargets + _s3XTargets;

private _finalTargets = _s1XTargets + _s2XTargets + _s3XTargets;

// ---------------------------------
// Returns
// ---------------------------------

// DEBUG LVL 3
LOG(format ["MM_fnc_applyPoD, %1: Complete - Returns: %2", _gh, _finalTargets]);

_finalTargets;