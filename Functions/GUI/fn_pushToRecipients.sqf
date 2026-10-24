/*
    Author: Waylen

    Locality: Client

    Description:
        Adds the player currently selected in lbAllPlayers to the connected UAV's
        MTI recipient list and adds a corresponding row to lbRecipients. The row's
        stored player UID identifies the player independently of their display name.

    Parameter(s):
        None.

    Returns:
        Nothing.

    Examples:
        onButtonClick = "[] call MM_fnc_pushToRecipients;";

    NOTE - The function exits without changes if there is no connected UAV, no
    selected player, an invalid UID, or the selected player is already a recipient.
    The updated array is broadcast for other clients and systems. The selected
    player is looked up again from the current online-player list before being added.
*/

private _uav = getConnectedUAV player;
if (isNull _uav) exitWith {};

private _display = findDisplay 1250;
if (isNull _display) exitWith {};

private _ctrlAllPlayers = _display displayCtrl 1500;
private _ctrlRecipients = _display displayCtrl 1501;

private _index = lbCurSel _ctrlAllPlayers;
if (_index < 0) exitWith {};

private _uid = _ctrlAllPlayers lbData _index;
if (_uid isEqualTo "") exitWith {};

private _playerObj = (allPlayers select {(getPlayerUID _x) isEqualTo _uid}) param [0, objNull];
if (isNull _playerObj) exitWith {};

private _recipients = _uav getVariable ["RQ4Tweak_mtiRecipients", []];
if (_playerObj in _recipients) exitWith {};

_recipients pushBack _playerObj;
missionNamespace setVariable ["RQ4Tweak_mtiRecipients", _recipients, true];

private _newIndex = _ctrlRecipients lbAdd (name _playerObj);
_ctrlRecipients lbSetData [_newIndex, getPlayerUID _playerObj];

