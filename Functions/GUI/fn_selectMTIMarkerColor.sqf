/*
    Author: Waylen

    Locality: Client

    Description:
        Stores the selected marker-color suffix in RQ4Tweak_mtiMarkerColor on the
        connected UAV and enforces a single checked color in the sensor-control
        dialog. If the currently selected color is clicked off, it is checked again.

    Parameter(s):
        0: CONTROL - Checkbox that raised the onCheckedChanged event.
        1: NUMBER - Checked state supplied by the event; 0 is unchecked, 1 is checked.
        2: STRING - Marker-color suffix matching the checkbox name, such as "colorOPFOR".

    Returns:
        Nothing.

    Examples:
        onCheckedChanged = "[_this select 0, _this select 1, 'colorOPFOR'] call MM_fnc_selectMTIMarkerColor;";

    NOTE - The marker-color setting is stored on the connected UAV and broadcast
    to other clients and systems. During a deliberate color change, the new value
    is stored before other checkboxes are unchecked so their events do not restore
    the old selection. If no UAV is connected, the GUI still updates locally.
*/

disableSerialization;
params ["_control", "_checked", "_colorName"];

private _uav = getConnectedUAV player;

// Keep the currently stored choice checked if the user clicks it off.
if (_checked == 0) exitWith {
    if (!isNull _uav && {(_uav getVariable ["RQ4Tweak_mtiMarkerColor", "colorGUER"]) isEqualTo _colorName}) then {
        _control cbSetChecked true;
    };
};

// Update the variable before unchecking other controls so their unchecked
// events can distinguish a deliberate selection change from an uncheck click.
if (!isNull _uav) then {
    _uav setVariable ["RQ4Tweak_mtiMarkerColor", _colorName, true];
};

private _display = findDisplay 1250;
if (isNull _display) exitWith {};

private _colorOptions = [
    ["ColorEAST", 2800],
    ["ColorCIV", 2801],
    ["ColorUNKNOWN", 2802],
    ["ColorGUER", 2803],
    ["ColorWEST", 2804]
];
{
    private _checkbox = _display displayCtrl (_x select 1);
    _checkbox cbSetChecked ((_x select 0) isEqualTo _colorName);
} forEach _colorOptions;
