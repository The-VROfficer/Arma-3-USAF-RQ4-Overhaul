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

// Query AV's sensor state, if undefined default to false (off).
private _sensorState = _uav getVariable ["RQ4Tweak_sensorOn", false];

// Do the toggle.
private _newSensorState = not _sensorState;

disableSerialization;
private _display = findDisplay 1250;
// purpose?
if (isNull _display) exitWith {_newSensorState};

private _sensorControl = _display displayCtrl 1600;
private _stateColor = if ( _newSensorState isEqualTo true ) then {
    [0,1,0,1]   // Make button green.
} else {
    [1,0,0,1]   // Make button red.
};

private _buttonText = if ( _newSensorState isEqualTo true ) then {
    "Sensor ON"
} else {
    "Sensor OFF"
};

_sensorControl ctrlSetText _buttonText;
_sensorControl ctrlSetBackgroundColor _stateColor;
_sensorControl ctrlSetActiveColor _stateColor;

_sensorOn;