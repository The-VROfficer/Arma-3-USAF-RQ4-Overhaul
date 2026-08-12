/*
	Author: Myth

    Locality: Server.

	Description:
		Collects all applicable object types near the AV, calls MM_fnc_genericFilter to disqualify unsuitable objects, then sorts the filtered results by range (and determines if target object is in a GRCA, if enabled).
		Lastly, it sends the list back to MM_fnc_collectMTI.

	Parameter(s):
		0: <OBJECT> - The AV.
		1: <BOOLEAN> - Evaluate if target is in drawn GRCAs.
			0=Disabled, 1=Enabled.

	Returns:
		Array of arrays
			0: Range bin 1 - 1: Range bin 2 - 2: Range bin 3

	Examples:
		[myGlobalHawk, true] call MM_fnc_radarScan
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

params [
	[_gh, objNull, [objNull]],
	[_grcaEnabled, false, [true]]
];

// DEBUG LVL 3
LOG(format ["MM_fnc_radarScan, %1: Started, grcaEnabled = %2.", _gh, _grcaEnabled]);

// If GRCA mode is on, check for existing GRCAs on this AV. If none exist, exit.
private _grcas = _gh getVariable ["RQ4Tweak_grcas", []];
if ( _grcas isEqualTo [] ) exitWith {
	
	// DEBUG LVL 3
	LOG(format ["MM_fnc_radarScan, %1: Exiting at GRCA existence check, no GRCAs for AV %1 (%2).", _gh, _grcas]);
};

// Get AV's current position, heading, altitude.
private _ghPosASL = getPosASL _gh;
private _ghHdg = getDir _gh;
private _ghAlt = _ghPosASL select 2;
// DEBUG LVL 3
LOG(format ["MM_fnc_radarScan, %1: Position: %2 / Hdg: %3 / Alt: %4", _gh, _ghPosASL, _ghHdg, _ghAlt]);

// Create empty range bins for use in the next section.
private _s1Targets = [];
private _s2Targets = [];
private _s3Targets = [];

// ---------------------------------
// Target Collection and Filtering
// ---------------------------------

private _detectableKinds = ["Car", "Helicopter", "Plane", "Ship", "Tank", "Truck", "UAV"];

// If addon option for infantry detection is ticked, append that entity type to the list of detectable kindOfs
if ( MM_RQ4_DetectInfantry ) then {
	_destactableKinds pushBackUnique "Man";
};

private _unsortedTargets = _ghPosASL nearEntities [_detectableKinds, MM_RQ4_Ranges_S3_Max];

// If no nearby entities exist, exit and log an abnormal exit.
if ( count _unsortedTargets < 1 ) exitWith {
	// DEBUG LVL 2
	WARNING(format ["MM_fnc_radarScan, %1: Abnormal exit at unsortedTargets count. No nearby entities exist.", _gh]);
};

// Remove already spotted (by other AV), dead, model hidden, mounted, out of LOS, out of speed limits, out of FoR based on slew side, out of FoR based on angle.
private _filteredTargets = [_unsortedEntities] call MM_fnc_genericFilter;
// DEBUG LVL 3
LOG(format ["MM_fnc_radarScan, %1: Filtered targets: %2", _gh, _filteredTargets]);

// Sort filtered targets into their corresponding range sector
{
	switch (true) do {
		case (((_gh distance _x) >= parseNumber MM_RQ4_Ranges_S1_Min) and ((_gh distance _x) <= parseNumber MM_RQ4_Ranges_S1_Max)): { _s1Targets pushBackUnique _x };
		case (((_gh distance _x) >= parseNumber MM_RQ4_Ranges_S2_Min) and ((_gh distance _x) <= parseNumber MM_RQ4_Ranges_S2_Max)): { _s2Targets pushBackUnique _x };
		case (((_gh distance _x) >= parseNumber MM_RQ4_Ranges_S3_Min) and ((_gh distance _x) <= parseNumber MM_RQ4_Ranges_S3_Max)): { _s3Targets pushBackUnique _x };
	};
} forEach _filteredTargets;

// If collection mode is RRCA, skip the rest of the script and push returns back to MM_fnc_collectMTI.
if ( _grcaEnabled isNotEqualTo true ) exitWith {
	// DEBUG LVL 3
	LOG(format ["MM_fnc_radarScan, %1: Exiting at GRCA check, grcaEnabled is not true (%2).", _gh, _grcaEnabled]);
	
	[_s1Targets, _s2Targets, _s3Targets];
};

// ---------------------------------
// Geographic Filtering (GRCA)
// ---------------------------------

// Make new arrays for the GRCA-qualified targets. Makes debugging easier.
private _s1GrcaTargets = [];
private _s2GrcaTargets = [];
private _s3GrcaTargets = [];

// Iterate through every target in each range bin and check if it's in a GRCA, if not, remove it.
{
	private _xGrca = _x;
	{
		private _xTarget = _x;

		if ( _xTarget inArea ((_xGrca getVariable "RQ4Tweak_grcaParams") select 0) ) then {
			switch (true) do {
				case ( _xTarget in _s1Targets ): { _s1GrcaTargets pushBackUnique _xTarget; };
				case ( _xTarget in _s2Targets ): { _s2GrcaTargets pushBackUnique _xTarget; };
				case ( _xTarget in _s3Targets ): { _s3GrcaTargets pushBackUnique _xTarget; };
			};
		};
	} forEach _s1Targets + _s2Targets + _s3Targets;
} forEach _grcas;

[_s1GrcaTargets, _s2GrcaTargets, _s3GrcaTargets];