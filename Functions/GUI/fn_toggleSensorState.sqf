/*
    Author: Waylen & Myth

    Locality: Local, AV pilot client

    Description:
        Toggles the sensor state stored on the UAV connected to the local player.
        Updates RQ4Tweak_sensorOn on the UAV and changes the sensor button's text,
        background color, and active color to reflect the new state.

    Parameter(s):
        0: <BOOLEAN> - (Optional) If true, Turns the "Sensor" button to OFF. It's a workaround added for MM_fnc_collectMTI checks. If false or nil, does nothing.

    Returns: Nothing.

    Examples:
        onButtonClick = "[] call MM_fnc_toggleSensorStateUI;";
*/

params [
    ["_doSensorOff", false, [false]]
];

private _uav = getConnectedUAV player;

// Deleted vehicle protection.
if (isNull _uav) exitWith {false};

// Workaround for fn_collectMTI. UI commands can't be remoteExec'd, so just call this fnc and perform the sensor button shutoff here!
if ( _doSensorOff ) exitWith {
    (findDisplay 1250 displayCtrl 1600) ctrlSetBackgroundColor [1,0,0,1];
    (findDisplay 1250 displayCtrl 1600) ctrlSetActiveColor [1,0,0,1];
    (findDisplay 1250 displayCtrl 1600) ctrlSetText "Sensor: OFF";
};

hintSilent "";

// Query AV's sensor state, if undefined default to false (off).
private _sensorState = _uav getVariable ["RQ4Tweak_sensorOn", false];

if ( _sensorState ) then {
    _uav setVariable ["RQ4Tweak_sensorOn", false, true];
} else {
    _uav setVariable ["RQ4Tweak_sensorOn", true, true];
    [_uav] remoteExec ["MM_fnc_collectMTI", 2];
};

disableSerialization;
private _display = findDisplay 1250;

private _sensorControl = _display displayCtrl 1600;
private _stateColor = if ( _sensorState ) then {
    [1,0,0,1]   // Make button red.
} else {
    [0,1,0,1]   // Make button green.
};

private _buttonText = if ( _sensorState ) then {
    "Sensor: OFF"
} else {
    "Sensor: ON"
};

_sensorControl ctrlSetText _buttonText;
_sensorControl ctrlSetBackgroundColor _stateColor;
_sensorControl ctrlSetActiveColor _stateColor;