/*
	Author: Myth

    Locality: Local, executed on the UAV pilot's computer.

	Description:
		Consistently draws the Field of Regard on the map for whoever is in control of UAV via the UAV terminal.

	Parameter(s):
		0: <OBJECT> - The MTI vehicle to have the lines rendered on (ideally an RQ-4 Global Hawk).
        1: <OBJECT> - The player connected to the UAV.
        2: <NUMBER> - 0: Sensor is slewed right, 1: Sensor is slewed left.

	Returns:
		BOOLEAN - Completion flag.

	Examples:
		[myGlobalHawk, player, 1] spawn MM_fnc_drawFoR
*/
#include "defines.hpp"

params [
    ["_gh", objNull, [objNull]],
    ["_ghPilot", objNull, [objNull]],
    ["_slewSide", 0, [0]]
];

if ( not isNil {_ghPilot getVariable "GMTI_FoR_Action"}) exitWith {};	// This check prevents duplicate addActions from being created. 

_ghPilot setVariable ["GMTI_FoR_Action", true, true];       // Temp variable assignment to keep fnc_checkConnected from constantly recreating the action, gets overwritten later.

_ghPilot addAction [
    "Toggle Field of Regard",
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        private _gh = _arguments select 0;
        private _slewSide = _arguments select 1;

        _caller setVariable ["GMTI_FoR_Action", _actionID, true];

        if ( not (isNil {MTI_Aircraft}) and (isNil {missionNamespace getVariable "GMTI_FoR_On" select 0}) ) exitWith {
            hint parseText "ERROR: Cannot display field of regard.<br />Field of regard is being displayed on another aircraft.";
        };

        if (isNil {missionNamespace getVariable "GMTI_FoR_On"}) then {    // FoR lines are OFF
            // The following code block was made out of necessity, because drawLine doesn't let you use anything other than GLOBAL variables.
            // The point of this block is to assign THIS SPECIFIC aircraft (passed as "_gh" here) a global variable,
            // that being "MTI_Aircraft". Due to the nature of global variables and to prevent accidental overwriting,
            // only one aircraft can have their FoR displayed at a time. Fuck drawLine, for real. -Myth

            MTI_Aircraft = _gh;
            missionNamespace setVariable ["GMTI_FoR_On", [MTI_Aircraft], true];

            if ( _slewSide == 0 ) then {    // Sensor slewed right
                MTI_Aircraft_LimTop = RFOVFront;
                MTI_Aircraft_LimBottom = RFOVRear;
            } else {    // Sensor slewed left
                MTI_Aircraft_LimTop = LFOVFront;
                MTI_Aircraft_LimBottom = LFOVRear;
            };
            
            for "_i" from 1 to 2 do {
                if (_i == 1) then {
                    _topLine = (findDisplay 12 displayCtrl 51) ctrlAddEventHandler [
                        "Draw",
                        {
                            _this select 0 drawLine [   // drawLine does NOT accept local variables. Passed variables must be GLOBAL.
                                MTI_Aircraft,
                                MTI_Aircraft getRelPos [parseNumber MM_RQ4_Ranges_S3_Max, MTI_Aircraft_LimTop],
                                [0, 0, 1, 1]
                            ];
                        }
                    ];

                    missionNamespace setVariable ["GMTI_FoR_On",[missionNamespace getVariable "GMTI_FoR_On" select 0, _topLine], true];
                } else {
                    _bottomLine = (findDisplay 12 displayCtrl 51) ctrlAddEventHandler [
                        "Draw",
                        {
                            _this select 0 drawLine [
                                MTI_Aircraft,
                                MTI_Aircraft getRelPos [parseNumber MM_RQ4_Ranges_S3_Max, MTI_Aircraft_LimBottom],
                                [0, 0, 1, 1]
                            ];
                        }
                    ];

                    missionNamespace setVariable ["GMTI_FoR_On",[missionNamespace getVariable "GMTI_FoR_On" select 0, missionNamespace getVariable "GMTI_FoR_On" select 1, _bottomLine], true];
                };
            };

        } else {    // FoR lines are already ON, so turn them off (delete them)
            (findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler ["Draw", missionNamespace getVariable "GMTI_FoR_On" select 1];
            (findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler ["Draw", missionNamespace getVariable "GMTI_FoR_On" select 2];

            missionNamespace setVariable ["GMTI_FoR_On", nil, true];

            MTI_Aircraft = nil;
            MTI_Aircraft_LimTop = nil;
            MTI_Aircraft_LimBottom = nil;
        };
    },
    [_gh, _slewSide],
    50,
    false,
    true,
    "",
    "( getConnectedUAV _target == (_target getVariable 'Assigned_MTI_Aircraft') ) and ( (getConnectedUAV _target) getVariable 'GMTI_isSlewing' isNotEqualTo true )"
];

true;