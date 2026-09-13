/*
	Author: Myth

	Locality: Local, executed on the UAV pilot's computer.

	Description:
		Adds the action to slew the radar left/right and reprograms the affected scripts.

	Parameter(s):
		0: <OBJECT> - The MTI UAV.
		1: <OBJECT> - The player connected to the UAV via the UAV terminal.

	Returns:
		Nothing

	Examples:
		[myGlobalHawk, myPilot] spawn MM_fnc_slewSide
*/

params [
	["_gh", objNull, [objNull]],
	["_ghPilot", objNull, [objNull]]
];

if ( not local _ghPilot ) exitWith {};	// Forces local execution.

_ghPilot setVariable ["GMTI_Slew_ActionID", -1];

[_gh, _ghPilot] spawn {
    params ["_gh", "_ghPilot"];

    while { alive _ghPilot } do {

		if ( _ghPilot getVariable "GMTI_Slew_ActionID" == -1 ) then {		// If no action exists, create one.
			private _slewSide = if (_gh getVariable "GMTI_Slew_Side" == 0) then {	// 0 inidicates the sensor is slewed right currently.
				[0, "Slew Sensor Left"]	
			} else {	// 1 inidicates the sensor is slewed left currently.
				[1, "Slew Sensor Right"]	
			};

			_actionID = _ghPilot addAction [
				_slewSide select 1,
				{
					params ["_target", "_caller", "_actionId"];
					private _gh = _this select 3 select 0;
					private _slewSide = _this select 3 select 1;

					private _newSlew = if ( (_slewSide select 0) == 0 ) then {
						1 	// Slew left
					} else {
						0	// Slew right
					};

					_gh setVariable ["GMTI_Slew_Side", _newSlew, true];


					[_newSlew] spawn {
						params ["_newSlew"];

						private _newSlewText = if ( _newSlew == 0 ) then { "RIGHT" } else { "LEFT" };

						for "_i" from 0 to (round MM_RQ4_SlewTime) do {
							hintSilent parseText format ["- SENSOR SLEWING %1 -<br />Time Remaining: %2 second(s)", _newSlewText, round MM_RQ4_SlewTime - _i];
							sleep 1;
						};

						hintSilent "";
					};

					_gh setVariable ["GMTI_isSlewing", true, true];
					sleep round MM_RQ4_SlewTime;
					_gh setVariable ["GMTI_isSlewing", false, true];

					if ( not isNil {missionNamespace getVariable "GMTI_FoR_On"} ) then {
						if ( _gh == (missionNamespace getVariable "GMTI_FoR_On" select 0) ) then {		// Only execute the FoR cleanup if the passed aircraft is the one with it's FoR toggled on.
							[_gh, _target] call MM_fnc_cleanFoR;

							if ( getConnectedUAV _target == _gh ) then {	// Catches an edgecase where player disconnects from UAV while it's slewing.
								_target setVariable ["Assigned_MTI_Aircraft", _gh, true];	// Enables MM_fnc_drawFoR to function properly when its called.
							};

							[_gh, _target, _newSlew] spawn MM_fnc_drawFoR;
							[format ["Called fn_drawFor with param %1", _newSlew]] remoteExec ["hint"];
						};
					};

					// Remove old action
					_target removeAction (_target getVariable "GMTI_Slew_ActionID");
					_target setVariable ["GMTI_Slew_ActionID", -1];

				},
				[_gh, _slewSide],
				99,
				true,
				true,
				"",
				"getConnectedUAV _target getVariable 'GMTI_isSlewing' isNotEqualTo true"	// Change this to be when the player is in the turret too
			];

			_ghPilot setVariable ["GMTI_Slew_ActionID", _actionID, true];
		};

        sleep 0.5;
    };
};