/*
    Author: Waylen

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
if (isNull _uav) exitWith {false};

private _sensorOn = !(_uav getVariable ["RQ4Tweak_sensorOn", false]);
_uav setVariable ["RQ4Tweak_sensorOn", _sensorOn, true];

disableSerialization;
private _display = findDisplay 1250;
if (isNull _display) exitWith {_sensorOn};

private _sensorControl = _display displayCtrl 1600;
private _stateColor = if (_sensorOn) then {[0,1,0,1]} else {[1,0,0,1]};

private _buttonText = if (_sensorOn) then {"Sensor ON"} else {"Sensor OFF"};

_sensorControl ctrlSetText _buttonText;
_sensorControl ctrlSetBackgroundColor _stateColor;
_sensorControl ctrlSetActiveColor _stateColor;

_sensorOn
