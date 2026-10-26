/*
    Author: Waylen

    Locality: Client

    Description:
        Opens the RQ4 sensor-control dialog, fills its player and MTI-recipient
        listboxes, and loads the connected UAV's current sensor, MTI mode,
        field-of-regard, slew-side, marker-color, assigned-altitude, and loiter
        radius state into the controls. Starts the player-list refresh loop while
        the dialog remains open.

    Parameter(s):
        None.

    Returns:
        Nothing.

    Examples:
        player addAction ["Open GUI", {[] call MM_fnc_openDialog;}];

    NOTE - The player and recipient listbox rows store player UIDs as their data,
    so duplicate display names can still be identified. Aircraft settings are read
    from the connected UAV. The function exits without opening the dialog if the
    player is not connected to a UAV. The altitude target is stored in meters ASL
    and displayed in feet MSL; the current or next LOITER waypoint radius is read
    when available, with the UAV's stored radius used as a fallback.
*/

disableSerialization;

private _uav = getConnectedUAV player;
if (isNull _uav) exitWith {};

if !(createDialog "RQ4dialog") exitWith {};

private _display = findDisplay 1250;
if (isNull _display) exitWith {};

private _ctrlAllPlayers = _display displayCtrl 1500;
private _ctrlRecipients = _display displayCtrl 1501;
lbClear _ctrlAllPlayers;
lbClear _ctrlRecipients;

// Store player UIDs in listbox data so recipient changes can identify units
// without relying on display names being unique.
{
    private _newIndex = _ctrlAllPlayers lbAdd (name _x);
    _ctrlAllPlayers lbSetData [_newIndex, getPlayerUID _x];
} forEach allPlayers;

// Recipient membership is stored on the connected UAV in this prototype.
{
    if (!isNull _x) then {
        private _newIndex = _ctrlRecipients lbAdd (name _x);
        _ctrlRecipients lbSetData [_newIndex, getPlayerUID _x];
    };
} forEach (_uav getVariable ["RQ4Tweak_mtiRecipients", []]);

// Load the visible sensor state from the aircraft instead of the dialog defaults.
private _sensorOn = _uav getVariable ["RQ4Tweak_sensorOn", false];
private _sensorControl = _display displayCtrl 1600;
_sensorControl ctrlSetText (if (_sensorOn) then {"Sensor: ON"} else {"Sensor: OFF"});
_sensorControl ctrlSetBackgroundColor (if (_sensorOn) then {[0,1,0,1]} else {[1,0,0,1]});
_sensorControl ctrlSetActiveColor (if (_sensorOn) then {[0,1,0,1]} else {[1,0,0,1]});

private _mtiMode = _uav getVariable ["RQ4Tweak_mtiMode", "RRCA"];
(_display displayCtrl 1603) ctrlSetText format ["MTI Mode: %1", _mtiMode];

private _forEH = _uav getVariable ["RQ4Tweak_forEH_guiMap", []];
// Check to see if GUI FOR got deleted on GUI close (it usually does). If it did, re-render it.
if ( _forEH isNotEqualTo [] ) then {
    if ( _forEH select 0 == 0 ) then {
        [_uav, true, true] spawn MM_fnc_handleFOR;
    };
};

private _forOn = !(_forEH isEqualTo []);
(_display displayCtrl 1606) ctrlSetText (if (_forOn) then {"Field of Regard: ON"} else {"Field of Regard: OFF"});

// Altitude is stored in the aircraft in meters ASL and displayed in feet MSL.
private _altitudeInput = _display displayCtrl 1300;
private _altitudeASL = _uav getVariable ["RQ4Tweak_flightAltitudeASL", -1];
if (_altitudeASL >= 0) then {
    _altitudeInput ctrlSetText str (round (_altitudeASL / 0.3048));
};

// Prefer the next configured LOITER waypoint's radius, falling back to its
// aircraft-stored value if there is no upcoming LOITER waypoint.
private _loiterInput = _display displayCtrl 1301;
private _loiterWaypoint = [group driver _uav] call MM_fnc_findUpcomingLoiterWaypoint;
private _loiterRadius = _uav getVariable ["RQ4Tweak_loiterRadius", -1];
if !(_loiterWaypoint isEqualTo []) then {
    _loiterRadius = waypointLoiterRadius _loiterWaypoint;
    _uav setVariable ["RQ4Tweak_loiterRadius", _loiterRadius, true];
};
if (_loiterRadius >= 0) then {
    _loiterInput ctrlSetText str _loiterRadius;
};

// Continuously update the "Current Altitude" box as long as the GUI is open.
[_uav] spawn {
    params ["_uav"];

    while { findDisplay 1250 } do {
        (findDisplay 1250 displayCtrl 1642) ctrlSetText (format ["%1", (getPosASLVisual _uav select 2) toFixed 0]);
        sleep 2;
    };
};

// Highlight the aircraft's current sensor side.
private _slewSide = _uav getVariable ["RQ4Tweak_slewSide", MM_RQ4_StartSlew];
private _slewLeftButton = _display displayCtrl 1601;
private _slewRightButton = _display displayCtrl 1602;
_slewLeftButton ctrlSetBackgroundColor [0.851,0.851,0.851,1];
_slewRightButton ctrlSetBackgroundColor [0.851,0.851,0.851,1];
private _currentSlewButton = if (_slewSide == 1) then {_slewRightButton} else {_slewLeftButton};
_currentSlewButton ctrlSetBackgroundColor [0,1,0,1];
private _slewSideName = if (_slewSide == 1) then {"Right"} else {"Left"};
_slewLeftButton ctrlSetTooltip format ["Current sensor side: %1", _slewSideName];
_slewRightButton ctrlSetTooltip format ["Current sensor side: %1", _slewSideName];

// Read the stored marker color. Values use the color suffix from the checkbox
// name, while older BIKI aliases and RGBA values remain recognized for the UI.
private _markerColor = _uav getVariable ["RQ4Tweak_mtiMarkerColor", "ColorGUER"];
private _markerColorControl = _display displayCtrl 1104;
_markerColorControl ctrlSetTooltip format ["Current Color: %1", _markerColor];

private _markerColorOptions = [
    ["ColorEAST", ["ColorEAST"], 2800, [0.5,0,0,1]],
    ["ColorCIV", ["ColorCIV"], 2801, [0.4,0,0.5,1]],
    ["ColorUNKNOWN", ["ColorUNKNOWN"], 2802, [0.7,0.6,0,1]],
    ["ColorGUER", ["ColorGUER"], 2803, [0,0.5,0,1]],
    ["ColorWEST", ["ColorWEST"], 2804, [0,0.3,0.6,1]]
];
{
    private _colorName = _x select 0;
    private _aliases = _x select 1;
    private _control = _display displayCtrl (_x select 2);
    private _rgba = _x select 3;
    private _isCurrentColor = (_markerColor isEqualTo _colorName) || {_markerColor in (_aliases + [_rgba])};
    if (_isCurrentColor && {!(_markerColor isEqualTo _colorName)}) then {
        _uav setVariable ["RQ4Tweak_mtiMarkerColor", _colorName, true];
    };
    _control cbSetChecked _isCurrentColor;
} forEach _markerColorOptions;

// Keep both player lists synchronized while the dialog remains open.
[] spawn MM_fnc_refreshPlayerLists;

