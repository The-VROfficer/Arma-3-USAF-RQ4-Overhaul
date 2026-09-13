/*
	Author: Myth

    Locality: Local, executed on the aircraft with remoteExecs embedded.

	Description:
		Finds, qualifies, sorts, displays, and updates target marks on the map. This is where the radar simulation happens.

	Parameter(s):
		0: <OBJECT> - The MTI vehicle.

	Returns:
		Nothing

	Examples:
		[myGlobalHawk] spawn MM_fnc_targetCollection
*/

#include "defines.hpp"

params [
    ["_gh", objNull, [objNull]]
];

if (isNil {missionNamespace getVariable "GMTI_TOI_Counter"}) then {
    missionNamespace setVariable ["GMTI_TOI_Counter", parseNumber MM_RQ4_TOI_Num, true];
};

sleep 1;    // Prevents the game from thinking the UAV isn't alive on mission start.

// ---- Collect Targets
while {alive _gh} do {
    private _slewSide = _gh getVariable ["GMTI_Slew_Side", MM_RQ4_StartSlew];

    // ---- If sensor slewing, wait to run collection until slewing has stopped.
    if ( (_gh getVariable ["GMTI_isSlewing", []]) isEqualTo true ) then {
        waitUntil { sleep 1; (_gh getVariable "GMTI_isSlewing") isNotEqualTo true };
    };
    
    ["Beep"] remoteExec ["playSound"];

    // ---- Prevent aircraft from collecting below threshold altitude.
    if ( getPosATL _gh select 2 <= parseNumber MM_RQ4_Min_Altitude ) then {
        ["Paused: Aircraft too low."] remoteExec ["hint"];
        waitUntil { sleep 1; getPosATL _gh select 2 >= parseNumber MM_RQ4_Min_Altitude };   // This is put in an if statement because if it wasn't the script would be stalled by the waitUntil sleep command.
    };

    // ---- Pauses collect if no one can receive MTI, for optimization.
    if ( count (_gh getVariable ["GMTI_allRecipients", 0]) == 0 ) then {
        ["Paused: No recipients."] remoteExec ["hint"];
        waitUntil { sleep 0.8; count (_gh getVariable ["GMTI_allRecipients", 0]) > 0 };   // Put into an if statement for the same reason as above.
    };

    //[format ["targetCollection: Recipients = %1", _gh getVariable ["GMTI_allRecipients", []]]] remoteExec ["hint"];
    
    // ---- Define TOI recipients.
    private _gmtiRecipients = _gh getVariable ["GMTI_allRecipients", objNull];

    private _targets = nearestObjects [_gh, ["Car", "Helicopter", "Plane", "Ship", "Tank", "Truck", "UAV"], parseNumber MM_RQ4_Ranges_S3_Max, true];

    // ---- Sort targets.
    private _Targets_S1 = [];
    private _Targets_S2 = [];
    private _Targets_S3 = [];

    private _GRCA_Targets_S1 = [];
    private _GRCA_Targets_S2 = [];
    private _GRCA_Targets_S3 = [];

    {
        _GMTI_Marker_Info = _x getVariable ["GMTI_Marker_Info", []];
        _GMTI_Marker = _GMTI_Marker_Info select 0;
        _GMTI_Fading = _x getVariable ["GMTI_Fading", []];

        
        // ---- Clear remaining targets of their "seen" status. This is necessary for MM_fnc_fadeMTI to work right.
        _x setVariable ["GMTI_displayTarget", [false, -1, objNull], true];

        if ( (_gh getVariable "GMTI_Mode" == "GRCA") and isNil {_gh getVariable "GMTI_GRCAs"}) then {    // Using GRCA mode but no GRCAs have been drawn for this aircraft...
            if ( (_GMTI_Marker_Info isNotEqualTo []) and (_GMTI_Fading isEqualTo []) ) then {     // If target has been spotted before and is not already fading, assess using the fade script
                if ( _x getVariable "GMTI_Fading" == 0 ) exitwith {};   // If target has completed fadeout, skip this TOI, otherwise...
                [_x, _GMTI_Marker, _gh] spawn MM_fnc_fadeMTI;  // ...begin fadeout for this TOI
                //[format ["Fading out %1 from GRCA existence check (75)",_x]] remoteExec ["hint"]; sleep 3;
                continue;
            };
        };

        // ---- Disqualify the aircraft, dead, non-human, hidden, or mounted targets
        if ( not (_x == _gh) ) then {
            if ( not alive _x ) exitWith {
                if ( (_GMTI_Marker_Info isNotEqualTo []) and (_GMTI_Fading isEqualTo []) ) then {     // If target has been spotted before and is not already fading, start the fade script
                    if ( _x getVariable "GMTI_Fading" isEqualTo 0 ) exitwith {};   // If target has completed fadeout, skip
                    [_x, _GMTI_Marker, _gh] spawn MM_fnc_fadeMTI;  // ...begin fadeout for this TOI
                    //[format ["Fading out %1 from dead check (85)",_x]] remoteExec ["hint"]; sleep 3;
                    continue;
                };
            };

            if ( _x isKindOf "Animal" ) exitWith {}; 
            if ( isObjectHidden _x ) exitWith {};
            if ( vehicle _x != _x ) exitWith {};

            // ---- Disqualify targets in sensor blindspots
            if (
                ((_gh getRelDir _x) > (LFOVFront) and ((_gh getRelDir _x) < (RFOVFront)))   // Targets in the nose blindspot
                or
                ((_gh getRelDir _x) > (LFOVRear) and ((_gh getRelDir _x) < (RFOVRear)))   // Targets in the tail blindspot
            ) exitWith {
                if ( (_GMTI_Marker_Info isNotEqualTo []) and (_GMTI_Fading isEqualTo []) ) then {     // If target has been spotted before and is not already fading, start the fade script
                    if ( _x getVariable "GMTI_Fading" isEqualTo 0 ) exitwith {};   // If target has completed fadeout, skip this TOI, otherwise...
                    [_x, _GMTI_Marker, _gh] spawn MM_fnc_fadeMTI;  // ...begin fadeout for this TOI
                    //[format ["Fading out %1 from FOV check (108)",_x]] remoteExec ["hint"]; sleep 3;
                    continue;
                };
            };

            // ---- Disqualify based on speed
            if ( not ((speed _x > parseNumber MM_RQ4_Min_Speed) and (speed _x < parseNumber MM_RQ4_Max_Speed)) ) exitWith {
                //hint format ["%1 doesnt meet the speeds", _x];
                if ( (_GMTI_Marker_Info isNotEqualTo []) and (_GMTI_Fading isEqualTo []) ) then {     // If target has been spotted before and is not already fading, start the fade script
                    if ( _x getVariable "GMTI_Fading" isEqualTo 0 ) exitwith {};   // If target has completed fadeout, skip
                    [_x, _GMTI_Marker, _gh] spawn MM_fnc_fadeMTI;  // ...begin fadeout for this TOI
                    //[format ["Fading out %1 from speed check (117)",_x]] remoteExec ["hint"]; sleep 3;
                    continue;
                };
            };

            // ---- Disqualify based on sensor slew side
            if ( not ( ((_gh getRelDir _x) >= (BothFOV select _slewSide select 0)) and ((_gh getRelDir _x) <= (BothFOV select _slewSide select 1)) ) ) exitWith {
                if ( (_GMTI_Marker_Info isNotEqualTo []) and (_GMTI_Fading isEqualTo []) ) then {     // If target has been spotted before and is not already fading, start the fade script
                    if ( _x getVariable "GMTI_Fading" isEqualTo 0 ) exitwith {};   // If target has completed fadeout, skip
                    [_x, _GMTI_Marker, _gh] spawn MM_fnc_fadeMTI;  // ...begin fadeout for this TOI
                    //[format ["Fading out %1 from slew check (128)",_x]] remoteExec ["hint"]; sleep 3;
                    continue;
                };
            }; 

            // Sort qualifying targets into respective range sector
            switch (true) do {
                case (((_gh distance _x) >= parseNumber MM_RQ4_Ranges_S1_Min) and ((_gh distance _x) <= parseNumber MM_RQ4_Ranges_S1_Max)): { _Targets_S1 pushBackUnique _x };
                case (((_gh distance _x) >= parseNumber MM_RQ4_Ranges_S2_Min) and ((_gh distance _x) <= parseNumber MM_RQ4_Ranges_S2_Max)): { _Targets_S2 pushBackUnique _x };
                case (((_gh distance _x) >= parseNumber MM_RQ4_Ranges_S3_Min) and ((_gh distance _x) <= parseNumber MM_RQ4_Ranges_S3_Max)): { _Targets_S3 pushBackUnique _x };
            };

            //[parseText format ["S1 Targets: %1<br/>S2 Targets: %2<br/>S3 Targets: %3", _Targets_S1, _Targets_S2, _Targets_S3]] remoteExec ["hint"];

            if ( _gh getVariable "GMTI_Mode" == "GRCA" ) then {
                {
                    //private _GRCA_Data = _gh getVariable "GMTI_GRCAs";
                    
                    if ( not isNil {_gh getVariable "GMTI_GRCAs"} ) then {  // If no GRCAs have been drawn, exit.
                        for "_i" from 0 to (count (_gh getVariable "GMTI_GRCAs")) - 1 do {
                            if ( _x inArea ((_gh getVariable "GMTI_GRCAs") select _i select 4) ) then {   // If target has been detected but is in a GRCA...
                                // First, classify the target as "seen" so that it won't fadeout by accident.
                                _x setVariable ["GMTI_displayTarget", [true, time, _gh, "for GRCA loop"], true];

                                // Sort the target based on range.
                                switch (true) do {
                                    case ( _x in _Targets_S1 ): { _GRCA_Targets_S1 pushBackUnique _x };
                                    case ( _x in _Targets_S2 ): { _GRCA_Targets_S2 pushBackUnique _x };
                                    case ( _x in _Targets_S3 ): { _GRCA_Targets_S3 pushBackUnique _x };
                                };
                            };
                        };

                        // If the passed target wasn't in ANY of the GRCAs, run checks and fade it out.
                        if ( (_x getVariable "GMTI_displayTarget" select 0) isEqualTo false ) then {
                            if ( not (isNil {_x getVariable "GMTI_Marker_Info"}) and ((_x getVariable ["GMTI_Fading", []]) isEqualTo []) ) then {   // If target has been seen before but has not started fadeout...
                                if ( (_x getVariable ["GMTI_Fading", []]) isEqualTo 0 ) exitwith {};   // Target has completed fadeout, exit.
                                [_x, _GMTI_Marker, _gh] spawn MM_fnc_fadeMTI;  // ...begin fadeout for this TOI
                                //[format ["Fading out %1 from IN GRCA AREA check (152)",_x]] remoteExec ["hint"]; sleep 3;
                                continue;
                            };
                        };
                    };
                } forEach _Targets_S1 + _Targets_S2 + _Targets_S3;
            } else {
                // GRCA mode is disabled but target passed checks, let MM_fnc_fadeMTI know that it shouldn't fade this target out.
                _x setVariable ["GMTI_displayTarget", [true, time, _gh, "GRCA disabled else statement"], true];
            };
        };
    } forEach _targets;

    if ( _gh getVariable "GMTI_Mode" == "GRCA" ) then {
        _Targets_S1 = _GRCA_Targets_S1;
        _Targets_S2 = _GRCA_Targets_S2;
        _Targets_S3 = _GRCA_Targets_S3;
    };

    //hint parseText format ["Qualified Targets are: %1<br/><br/>%2<br/><br/>%3", _Targets_S1, _Targets_S2, _Targets_S3];
    missionNameSpace setVariable ["GMTI_All_Targets",[_Targets_S1, _Targets_S2, _Targets_S3], true];

    // Dice roll, see if distance-sorted targets pass the PoD check, if not, target gets deleted from the detection pool on this pass
    {
        switch (true) do {
            case ( _x in _Targets_S1 ): { if ( random 1.0 >= MM_RQ4_PoD_S1 ) then { _Targets_S1 deleteAt (_Targets_S1 find _x) } };
            case ( _x in _Targets_S2 ): { if ( random 1.0 >= MM_RQ4_PoD_S2 ) then { _Targets_S2 deleteAt (_Targets_S2 find _x) } };
            case ( _x in _Targets_S3 ): { if ( random 1.0 >= MM_RQ4_PoD_S3 ) then { _Targets_S3 deleteAt (_Targets_S3 find _x) } };
        };
    } forEach _Targets_S1 + _Targets_S2 + _Targets_S3;

    private _hourSpotted = floor dayTime;
    private _minuteSpotted = floor ((dayTime - _hourSpotted) * 60);
    if ( _minuteSpotted < 10 ) then {
        _minuteSpotted = format ["0%1", _minuteSpotted]
    };

    // ---- Place markers for targets in Sector 1
    {
        private _GMTI_Sector = 1;
        _GMTI_Marker_Info = _x getVariable ["GMTI_Marker_Info", []];
        _GMTI_Marker = _GMTI_Marker_Info select 0;
        _GMTI_Fading = _x getVariable ["GMTI_Fading", []];

        if ( _GMTI_Marker_Info isEqualTo [] ) then {    // If target does not have an existing GMTI marker...
            private _GH_TOI_Num = (missionNamespace getVariable "GMTI_TOI_Counter") + 1;
            missionNamespace setVariable ["GMTI_TOI_Counter", _GH_TOI_Num, true];

            private _markerName = "GMTI_Marker_" + str _GH_TOI_Num;

            private _GMTI_Marker = createMarkerLocal [_markerName, ((getPos _x) apply {_x * random [1 - parseNumber MM_RQ4_PoD_Error_S1, 1, 1 + parseNumber MM_RQ4_PoD_Error_S1]})];    // Creates marker for the computer simulating the RQ-4
            [[_markerName, ((getPos _x) apply {_x * random [1 - parseNumber MM_RQ4_PoD_Error_S1, 1, 1 + parseNumber MM_RQ4_PoD_Error_S1]})]] remoteExec ["createMarkerLocal", _gmtiRecipients];    // Creates marker for the UAV pilot. If no one is connected, creates targets for no one.
            
            _GMTI_Marker setMarkerTypeLocal "n_unknown";
            [_GMTI_Marker, "n_unknown"] remoteExec ["setMarkerTypeLocal", _gmtiRecipients];

            _GMTI_Marker setMarkerColor "ColorGUER";
            [_GMTI_Marker, "ColorGUER"] remoteExec ["setMarkerColorLocal", _gmtiRecipient];

            private _Target_Number = format ["TOI %1 [S%2-%3:%4L]", _GH_TOI_Num, _GMTI_Sector, _hourSpotted, _minuteSpotted];
            _GMTI_Marker setMarkerTextLocal _Target_Number;
            [_GMTI_Marker, _Target_Number] remoteExec ["setMarkerTextLocal", _gmtiRecipients];

            _GMTI_Marker setMarkerSizeLocal [1 * (sizeOf typeOf _x / 20), 1 * (sizeOf typeOf _x / 20)];     // Scales the marker size depending on the "RCS" (bounding box)
            [_GMTI_Marker, [1 * (sizeOf typeOf _x / 20), 1 * (sizeOf typeOf _x / 20)]] remoteExec ["setMarkerSizeLocal", _gmtiRecipients];

            _x setVariable ["GMTI_Marker_Info", [_GMTI_Marker, _GH_TOI_Num, time, _gh, _x], true];

            [_gh, _x] call MM_fnc_addToJIP;
        } else {    // Target does have an existing GMTI marker...
            _x setVariable ["GMTI_Marker_Info",[_GMTI_Marker, _GMTI_Marker_Info select 1, time, _gh, _x], true];    // Updates the time last seen only

            private _GH_TOI_Num = _GMTI_Marker_Info select 1;

            _GMTI_Marker setMarkerAlphaLocal 1.0;
            [_GMTI_Marker, 1.0] remoteExec ["setMarkerAlphaLocal", _gmtiRecipients];

            _x setVariable ["GMTI_Fading", nil, true];

            private _updatedName = format ["TOI %1 [S%2-%3:%4L]", _GH_TOI_Num, _GMTI_Sector, _hourSpotted, _minuteSpotted];
            _GMTI_Marker setMarkerTextLocal _updatedName;
            [_GMTI_Marker, _updatedName] remoteExec ["setMarkerTextLocal", _gmtiRecipients];

            _GMTI_Marker setMarkerPosLocal ((getPos _x) apply {_x * random [1 - parseNumber MM_RQ4_PoD_Error_S1, 1, 1 + parseNumber MM_RQ4_PoD_Error_S1]}); // Applies the PoD error to each of the elements of the getPos array, making the "dot" more inaccurate and realistic
            [_GMTI_Marker, ((getPos _x) apply {_x * random [1 - parseNumber MM_RQ4_PoD_Error_S1, 1, 1 + parseNumber MM_RQ4_PoD_Error_S1]})] remoteExec ["setMarkerPosLocal", _gmtiRecipients];

            [_gh, _x] call MM_fnc_addToJIP;
        };
    } forEach _Targets_S1;

    // ---- Sector 2
    {
        private _GMTI_Sector = 2;
        _GMTI_Marker_Info = _x getVariable ["GMTI_Marker_Info", []];
        _GMTI_Marker = _GMTI_Marker_Info select 0;
        _GMTI_Fading = _x getVariable ["GMTI_Fading", []];

        if ( _GMTI_Marker_Info isEqualTo [] ) then { // If target does not have an existing GMTI marker...
            private _GH_TOI_Num = (missionNamespace getVariable "GMTI_TOI_Counter") + 1;
            missionNamespace setVariable ["GMTI_TOI_Counter", _GH_TOI_Num, true];

            private _markerName = "GMTI_Marker_" + str _GH_TOI_Num;

            private _GMTI_Marker = createMarkerLocal [_markerName, ((getPos _x) apply {_x * random [1 - parseNumber MM_RQ4_PoD_Error_S2, 1, 1 + parseNumber MM_RQ4_PoD_Error_S2]})];
            [[_markerName, ((getPos _x) apply {_x * random [1 - parseNumber MM_RQ4_PoD_Error_S2, 1, 1 + parseNumber MM_RQ4_PoD_Error_S2]})]] remoteExec ["createMarkerLocal",  _gmtiRecipients];

            _GMTI_Marker setMarkerTypeLocal "n_unknown";
            [_GMTI_Marker, "n_unknown"] remoteExec ["setMarkerTypeLocal", _gmtiRecipients];

            _GMTI_Marker setMarkerColorLocal "ColorGUER";
            [_GMTI_Marker, "ColorGUER"] remoteExec ["setMarkerColorLocal", _gmtiRecipients];

            private _Target_Number = format ["TOI %1 [S%2-%3:%4L]", _GH_TOI_Num, _GMTI_Sector, _hourSpotted, _minuteSpotted];
            _GMTI_Marker setMarkerTextLocal _Target_Number;
            [_GMTI_Marker, _Target_Number] remoteExec ["setMarkerTextLocal", _gmtiRecipients];

            _GMTI_Marker setMarkerSizeLocal [1 * (sizeOf typeOf _x / 20), 1 * (sizeOf typeOf _x / 20)];     // Scales the marker size depending on the "RCS" (bounding box)
            [_GMTI_Marker, [1 * (sizeOf typeOf _x / 20), 1 * (sizeOf typeOf _x / 20)]] remoteExec ["setMarkerSizeLocal", _gmtiRecipients];

            _x setVariable ["GMTI_Marker_Info", [_GMTI_Marker, _GH_TOI_Num, time, _gh, _x], true];

            [_gh, _x] call MM_fnc_addToJIP;
        } else {    // Target does have an existing GMTI marker...
            _x setVariable ["GMTI_Marker_Info",[_GMTI_Marker, _GMTI_Marker_Info select 1, time, _gh, _x], true];    // Updates the time last seen only

            private _GH_TOI_Num = _GMTI_Marker_Info select 1;           

            _GMTI_Marker setMarkerAlphaLocal 1.0;
            [_GMTI_Marker, 1.0] remoteExec ["setMarkerAlphaLocal", _gmtiRecipients];

            _x setVariable ["GMTI_Fading", nil, true];
            
            private _updatedName = format ["TOI %1 [S%2-%3:%4L]", _GH_TOI_Num, _GMTI_Sector, _hourSpotted, _minuteSpotted];
            _GMTI_Marker setMarkerTextLocal _updatedName;
            [_GMTI_Marker, _updatedName] remoteExec ["setMarkerTextLocal", _gmtiRecipients];

            _GMTI_Marker setMarkerPosLocal ((getPos _x) apply {_x * random [1 - parseNumber MM_RQ4_PoD_Error_S2, 1, 1 + parseNumber MM_RQ4_PoD_Error_S2]}); // Applies the PoD error to each of the elements of the getPos array, making the "dot" more inaccurate and realistic
            [_GMTI_Marker, ((getPos _x) apply {_x * random [1 - parseNumber MM_RQ4_PoD_Error_S2, 1, 1 + parseNumber MM_RQ4_PoD_Error_S2]})] remoteExec ["setMarkerPosLocal", _gmtiRecipients];

            [_gh, _x] call MM_fnc_addToJIP;
        };
    } forEach _Targets_S2;

    // ---- Sector 3
    {
        private _GMTI_Sector = 3;
        _GMTI_Marker_Info = _x getVariable ["GMTI_Marker_Info", []];
        _GMTI_Marker = _GMTI_Marker_Info select 0;
        _GMTI_Fading = _x getVariable ["GMTI_Fading", []];

        if ( _GMTI_Marker_Info isEqualTo [] ) then { // If target does not have an existing GMTI marker...
            private _GH_TOI_Num = (missionNamespace getVariable "GMTI_TOI_Counter") + 1;
            missionNamespace setVariable ["GMTI_TOI_Counter", _GH_TOI_Num, true];

            private _markerName = "GMTI_Marker_" + str _GH_TOI_Num;

            private _GMTI_Marker = createMarkerLocal [_markerName, ((getPos _x) apply {_x * random [1 - parseNumber MM_RQ4_PoD_Error_S3, 1, 1 + parseNumber MM_RQ4_PoD_Error_S3]})];
            [[_markerName, ((getPos _x) apply {_x * random [1 - parseNumber MM_RQ4_PoD_Error_S3, 1, 1 + parseNumber MM_RQ4_PoD_Error_S3]})]] remoteExec ["createMarkerLocal", _gmtiRecipients];
            
            _GMTI_Marker setMarkerTypeLocal "n_unknown";
            [_GMTI_Marker, "n_unknown"] remoteExec ["setMarkerTypeLocal", _gmtiRecipients];

            _GMTI_Marker setMarkerColorLocal "ColorGUER";
            [_GMTI_Marker, "ColorGUER"] remoteExec ["setMarkerColorLocal", _gmtiRecipients];

            private _Target_Number = format ["TOI %1 [S%2-%3:%4L]", _GH_TOI_Num, _GMTI_Sector, _hourSpotted, _minuteSpotted];
            _GMTI_Marker setMarkerTextLocal _Target_Number;
            [_GMTI_Marker, _Target_Number] remoteExec ["setMarkerTextLocal", _gmtiRecipients];

            _GMTI_Marker setMarkerSizeLocal [1 * (sizeOf typeOf _x / 20), 1 * (sizeOf typeOf _x / 20)];     // Scales the marker size depending on the "RCS" (bounding box)
            [_GMTI_Marker, [1 * (sizeOf typeOf _x / 20), 1 * (sizeOf typeOf _x / 20)]] remoteExec ["setMarkerSizeLocal", _gmtiRecipients];

            _x setVariable ["GMTI_Marker_Info", [_GMTI_Marker, _GH_TOI_Num, time, _gh, _x], true];

            [_gh, _x] call MM_fnc_addToJIP;
        } else {    // Target does have an existing GMTI marker...
            _x setVariable ["GMTI_Marker_Info",[_GMTI_Marker, _GMTI_Marker_Info select 1, time, _gh, _x], true];    // Updates the time last seen only

            private _GH_TOI_Num = _GMTI_Marker_Info select 1;

            _GMTI_Marker setMarkerAlphaLocal 1.0;
            [_GMTI_Marker, 1.0] remoteExec ["setMarkerAlphaLocal", _gmtiRecipients];

            _x setVariable ["GMTI_Fading", nil, true];

            private _updatedName = format ["TOI %1 [S%2-%3:%4L]", _GH_TOI_Num, _GMTI_Sector, _hourSpotted, _minuteSpotted];
            _GMTI_Marker setMarkerTextLocal _updatedName;
            [_GMTI_Marker, _updatedName] remoteExec ["setMarkerTextLocal", _gmtiRecipients];

            _GMTI_Marker setMarkerPosLocal ((getPos _x) apply {_x * random [1 - parseNumber MM_RQ4_PoD_Error_S3, 1, 1 + parseNumber MM_RQ4_PoD_Error_S3]}); // Applies the PoD error to each of the elements of the getPos array, making the "dot" more inaccurate and realistic
            [_GMTI_Marker, ((getPos _x) apply {_x * random [1 - parseNumber MM_RQ4_PoD_Error_S3, 1, 1 + parseNumber MM_RQ4_PoD_Error_S3]})] remoteExec ["setMarkerPosLocal", _gmtiRecipients];

            [_gh, _x] call MM_fnc_addToJIP;
        };
    } forEach _Targets_S3;

    sleep parseNumber MM_RQ4_Update_Rate;
};

// ---- Executes upon vehicle death of deletion
if (not alive _gh) exitWith {
    {
        private _GMTI_Marker_Info = _x getVariable ["GMTI_Marker_Info", []];
        private _GMTI_Marker = _GMTI_Marker_Info select 0;
        private _GMTI_Fading = _x getVariable ["GMTI_Fading", []];

        if ( (_GMTI_Marker_Info isNotEqualTo []) and (_GMTI_Fading isEqualTo []) ) then {
            if ( (_x getVariable "GMTI_Fading" isEqualTo 1) or (_GMTI_Marker_Info select 3 isNotEqualTo _gh) ) exitwith {};   
            [_x, _GMTI_Marker] remoteExec ["MM_fnc_fadeMTI", 0];
        };
    } forEach nearestObjects [_gh, ["Car", "Helicopter", "Plane", "Ship", "Tank", "Truck", "UAV"], parseNumber MM_RQ4_Ranges_S3_Max, true];
};