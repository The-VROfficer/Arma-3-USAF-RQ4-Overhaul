/*
	Author: Myth

	Locality: Local, executed on the aircraft.

	Description:
		Checks who is connected to the Global Hawk and adds appropriate scroll wheel and GUI actions to their interface.

	Parameter(s):
		0: <OBJECT> - The MTI vehicle that is being inspected.

	Returns:
		0: <BOOLEAN> - True if a player is connected, false if no one is connected.
		1: <OBJECT> - The player connected to the UAV, objNull if no one is connected.

	Examples:
		[myGlobalHawk] call MM_fnc_checkConnected
*/

params [
	["_gh", objNull, [objNull]]
];

private _ghPilot = [];

{
	[] remoteExecCall ["MM_fnc_checkConnectedPlayer", _x];
	private _playerUAV = _x getVariable ["GMTI_connectedUAV", 0];

    if ( (alive _x) and (_playerUAV isEqualTo _gh) ) then {   // Disqualify all players except the UAV pilot.
		if ( _x isEqualTo (_gh getVariable "GMTI_Pilot") ) exitWith { _ghPilot pushBackUnique _x };	// If player has already had the actions run on them, "exit".
		
		_ghPilot pushBackUnique _x;

		_x setVariable ["Assigned_MTI_Aircraft", _gh, true];
		
		// The following statements check if the detected UAV pilot has had the addActions added to them yet. If not or if they have been previously removed, it adds them.
		if ( isNil {_x getVariable "GMTI_FoR_Action"} ) then {
			[_gh, _x, _gh getVariable "GMTI_Slew_Side"] remoteExec ["MM_fnc_drawFoR", _x];
		};

		if ( isNil {_x getVariable "GMTI_Slew_ActionID"}) then {
			[_gh, _x] remoteExec ["MM_fnc_slewSensor", _x];
		};

		if ( isNil {_x getVariable "GMTI_Mode_ActionIDs"} ) then {
			[_gh, _x] remoteExecCall ["MM_fnc_toggleMode", _x];
		};
	} else {	// Removes the Assigned_MTI_Aircraft from players not connected to the respective UAV.
		if ( _x getVariable "Assigned_MTI_Aircraft" isEqualTo _gh ) then {		// This check ensures other players using MTI on different UAVs aren't accidently reset.
			_x setVariable ["Assigned_MTI_Aircraft", nil, true];
			
			[_x, (_x getVariable "GMTI_Slew_ActionID")] remoteExec ["removeAction", _x];	// Removes the sensor slewing scroll action.
			_x setVariable ["GMTI_Slew_ActionID", nil, true];

			for "_i" from 0 to 2 do {	// Removes the "Switch to GRCA", "Switch to RRCA", "Add New GRCA" actions for the former UAV operator.
				[_x, (_x getVariable "GMTI_Mode_ActionIDs" select _i)] remoteExec ["removeAction", _x] 
			};
			_x setVariable ["GMTI_Mode_ActionIDs", nil, true];

			if ( not (isNil {missionNamespace getVariable "GMTI_FoR_On"}) ) then {
				if ( _gh == (missionNamespace getVariable "GMTI_FoR_On" select 0) ) then {		// Only execute the FoR cleanup if the passed aircraft is the one with its FoR toggled on.
					[_gh, _x] remoteExecCall ["MM_fnc_cleanFoR", _x];
				};
			};

			//_gh setVariable ["GMTI_allRecipients", (_gh getVariable "GMTI_allRecipients") deleteAt ((_gh getVariable "GMTI_allRecipients") find _x), true];	// Removes the former UAV pilot from the GMTI_recipient list. If they have a valid recipient device, they will be re-added on the next run of MM_fnc_checkConnected.
		};
	};
} forEach allPlayers;

if ( count _ghPilot < 1 ) exitWith { [false, objnull] };

[true, _ghPilot select 0];