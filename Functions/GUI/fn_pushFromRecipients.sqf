/*
    Author: Waylen

    Locality: Client

    Description:
        Removes the currently selected player from the connected UAV's MTI
        recipient list and removes that row from the dialog's lbRecipients listbox.
        The selected row is identified by its stored player UID, so display names
        do not need to be unique.

    Parameter(s):
        None.

    Returns:
        Nothing.

    Examples:
        onButtonClick = "[] call MM_fnc_pushFromRecipients;";

    NOTE - If there is no connected UAV or no selected recipient row, the function
    exits without changing the aircraft variable. The updated array is broadcast
    to the systems that consume the list. If the selected UID is no longer found
    in the stored recipient array, its visible row is still removed from the UI.
*/

private _uav = getConnectedUAV player;
if (isNull _uav) exitWith {};

private _display = findDisplay 1250;
if (isNull _display) exitWith {};

private _ctrlRecipients = _display displayCtrl 1501;
private _index = lbCurSel _ctrlRecipients;
if (_index < 0) exitWith {};

private _uid = _ctrlRecipients lbData _index;
private _recipients = _uav getVariable ["RQ4Tweak_mtiRecipients", []];
private _playerObj = (_recipients select {(getPlayerUID _x) isEqualTo _uid}) param [0, objNull];

if (!isNull _playerObj) then {
    _recipients = _recipients - [_playerObj];
    _uav setVariable ["RQ4Tweak_mtiRecipients", _recipients, true];
};

_ctrlRecipients lbDelete _index;

