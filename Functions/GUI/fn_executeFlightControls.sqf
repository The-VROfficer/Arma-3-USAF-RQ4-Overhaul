/*
    Author: Waylen

    Locality: Client

    Description:
        Reads the altitude and loiter-radius textboxes, validates that both
        contain non-negative numbers, and applies the requested flight controls
        to the connected UAV. Altitude is converted from feet MSL to meters ASL
        before being applied with the same value for each flight behavior.

    Parameter(s):
        None.

    Returns:
        Nothing.

    Examples:
        onButtonClick = "[] call MM_fnc_executeFlightControls;";
*/

disableSerialization;

private _uav = getConnectedUAV player;
if (isNull _uav) exitWith {
    hint "Connect to a UAV before executing flight controls.";
};

private _display = findDisplay 1250;
if (isNull _display) exitWith {};

private _altitudeText = ctrlText (_display displayCtrl 1300);
private _loiterText = ctrlText (_display displayCtrl 1301);

private _isNonNegativeNumber = {
    params ["_text"];
    private _characters = toArray _text;
    if (_characters isEqualTo []) exitWith {false};

    private _decimalPoints = 0;
    private _digitCount = 0;
    private _valid = true;
    {
        if (_x isEqualTo 46) then {
            _decimalPoints = _decimalPoints + 1;
            if (_decimalPoints > 1) then {_valid = false;};
        } else {
            if (_x >= 48 && {_x <= 57}) then {
                _digitCount = _digitCount + 1;
            } else {
                _valid = false;
            };
        };
    } forEach _characters;

    _valid && {_digitCount > 0}
};

if !([_altitudeText] call _isNonNegativeNumber) exitWith {
    hint "Enter a valid non-negative number for altitude (ft MSL).";
};
if !([_loiterText] call _isNonNegativeNumber) exitWith {
    hint "Enter a valid non-negative number for loiter radius (m).";
};

private _altitudeFeet = parseNumber _altitudeText;
private _altitudeASL = _altitudeFeet * 0.3048;
private _loiterRadius = parseNumber _loiterText;

// Persist the values on the UAV so the GUI can restore them on its next open.
_uav setVariable ["RQ4Tweak_flightAltitudeASL", _altitudeASL, true];
_uav setVariable ["RQ4Tweak_loiterRadius", _loiterRadius, true];

// flyInHeightASL uses standard, combat, and stealth altitude values.
_uav flyInHeightASL [_altitudeASL, _altitudeASL, _altitudeASL];

private _uavGroup = group driver _uav;
if (isNull _uavGroup) exitWith {
    systemChat "Altitude applied. Loiter settings saved, but the UAV has no group waypoint route to update.";
};

private _loiterWaypoint = [_uavGroup] call MM_fnc_findUpcomingLoiterWaypoint;
if (_loiterWaypoint isEqualTo []) exitWith {
    systemChat "Altitude applied. Loiter settings saved, but no current or upcoming LOITER waypoint exists to update.";
};

// Construct the waypoint handle with the UAV group and the selected waypoint index.
private _waypoint = [_uavGroup, _loiterWaypoint select 1];
_waypoint setWaypointLoiterRadius _loiterRadius;
_waypoint setWaypointLoiterAltitude _altitudeASL;
