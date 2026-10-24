/*
    Author: Waylen

    Locality: Client

    Description:
        Sets the radar sensor's slew side on the UAV connected to the local
        player, then updates the open sensor-control dialog to show which side
        is active. The selected button is highlighted green; the other button
        is reset to its neutral background color.

    Parameter(s):
        0: NUMBER - Slew side to select. Use 0 for Left or 1 for Right.

    Returns:
        Nothing.

    Examples:
        onButtonClick = "[0] spawn MM_fnc_setSlewSide;"; // Select Left
        onButtonClick = "[1] spawn MM_fnc_setSlewSide;"; // Select Right

    NOTE - RQ4Tweak_slewSide belongs to the UAV. Its 0=Left, 1=Right mapping is
    documented in the production project's List of new variables.txt. The selected
    side is broadcast with the aircraft state. The UAV variable is updated even if
    the dialog cannot be found; only visual feedback depends on the dialog being
    open. Invalid values and players without a connected UAV are ignored.
*/

params ["_slewSide"];

private _uav = getConnectedUAV player;
if (isNull _uav) exitWith {};

hintSilent "";

// Add slewing in progress protection
if ( _uav getVariable ["RQ4Tweak_isSlewing", []] isNotEqualTo [] ) exitWith {
    hintSilent parseText format ["<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />Sensor is slewing.</t>"];
};

if ((_uav getVariable ["RQ4Tweak_slewSide", MM_RQ4_StartSlew]) isEqualTo _slewSide) exitWith {
    private _side = if ( _slewSide isEqualTo 0 ) then {
        "RIGHT"
    } else {
        "LEFT"
    };

    hintSilent parseText format ["<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />Sensor already slewed %1.", _side];
};

[_uav,player] spawn MM_fnc_slewSensor;

disableSerialization;
private _display = findDisplay 1250;
if (isNull _display) exitWith {};

private _slewLeftButton = _display displayCtrl 1601;
private _slewRightButton = _display displayCtrl 1602;
_slewLeftButton ctrlSetBackgroundColor [0.851,0.851,0.851,1];
_slewRightButton ctrlSetBackgroundColor [0.851,0.851,0.851,1];

private _currentSlewButton = if (_slewSide == 1) then {_slewRightButton} else {_slewLeftButton};
_currentSlewButton ctrlSetBackgroundColor [0,1,0,1];

private _slewSideName = if (_slewSide == 1) then {"Right"} else {"Left"};
_slewLeftButton ctrlSetTooltip format ["Current sensor side: %1", _slewSideName];
_slewRightButton ctrlSetTooltip format ["Current sensor side: %1", _slewSideName];
