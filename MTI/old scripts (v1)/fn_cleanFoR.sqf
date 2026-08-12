/*
	Author: Myth

    Locality: Local, executed on the UAV pilot's computer.

	Description:
		Cleans up global variables and other things when the UAV dies/is deleted, or if the player dies/disconnects.

	Parameter(s):
		0: <OBJECT> - The MTI vehicle to have the lines rendered on (ideally an RQ-4 Global Hawk).
        1: <OBJECT> - The player connected to the UAV.

	Returns:
		BOOLEAN - Completion flag.

	Examples:
		[myGlobalHawk, player] call MM_fnc_cleanFoR
*/

params [
	["_gh", objNull, [objNull]],
	["_ghPilot", objNull, [objNull]]
];

if ( isNil {MTI_Aircraft} ) exitWith {};    // FoR drawing never existed, no need to erase it

if ( not (isNil {missionNamespace getVariable "GMTI_FoR_On"}) ) then {		    // Aircraft with FoR may have been deleted, this catches that case.
	(findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler ["Draw", missionNamespace getVariable "GMTI_FoR_On" select 1];
	(findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler ["Draw", missionNamespace getVariable "GMTI_FoR_On" select 2];
};

missionNamespace setVariable ["GMTI_FoR_On", nil, true];

_ghPilot setVariable ["Assigned_MTI_Aircraft", nil, true];
_ghPilot removeAction (_ghPilot getVariable "GMTI_FoR_Action");
_ghPilot setVariable ["GMTI_FoR_Action", nil, true];

MTI_Aircraft = nil;
MTI_Aircraft_LimTop = nil;
MTI_Aircraft_LimBottom = nil;

true;