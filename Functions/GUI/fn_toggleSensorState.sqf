/*
    Author: Waylen & Myth

    Locality: Client

    Description:
        Toggles the sensor state stored on the UAV connected to the local player.
        Updates RQ4Tweak_sensorOn on the UAV and changes the sensor button's text,
        background color, and active color to reflect the new state.

    Parameter(s):
        None.

    Returns:
        BOOLEAN - The new sensor state, or false if no connected UAV is available.

    Examples:
        onButtonClick = "[] call MM_fnc_toggleSensorStateUI;";

    NOTE - RQ4Tweak_sensorOn is a boolean variable belonging to the aircraft.
    Its public value is broadcast so the MTI collection loop and other systems can
    read the current state. The button display is only changed when display 1250
    is open.
*/

private _uav = getConnectedUAV player;

// Deleted vehicle protection.
if (isNull _uav) exitWith {false};

hintSilent "";

// Query AV's sensor state, if undefined default to false (off).
private _sensorState = _uav getVariable ["RQ4Tweak_sensorOn", false];

if ( _sensorState ) then {
    _uav setVariable ["RQ4Tweak_sensorOn", false, true];
} else {
    _uav setVariable ["RQ4Tweak_sensorOn", true, true];
    [_uav] remoteExec ["MM_fnc_collectMTI"];
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