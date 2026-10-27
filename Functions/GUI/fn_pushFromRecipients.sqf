/*
    Author: Waylen & Myth

    Locality: Client

    Description:
        Removes the currently selected player from the connected UAV's MTI
        recipient list and removes that row from the dialog's lbRecipients listbox.

    Parameter(s):
        None.

    Returns:
        Nothing.

    Examples:
        onButtonClick = "[] call MM_fnc_pushFromRecipients;";
*/

private _display = findDisplay 1250;
if (isNull _display) exitWith {};

private _ctrlRecipients = _display displayCtrl 1501;
private _index = lbCurSel _ctrlRecipients;
if (_index < 0) exitWith {};

private _netId = _ctrlRecipients lbData _index;
private _playerObj = objectFromNetId _netId;

if (!isNull _playerObj) then {
    // Turn off ALL targets from all AVs for this player.
    {
        private _gh = _x;
        if ( isNull _gh ) then { continue };

        private _allTrackedTOIs = _gh getVariable ["RQ4Tweak_allTOIMarkers", []];
        {
            [_x, 0] remoteExec ["setMarkerAlphaLocal", _playerObj];
        } forEach _allTrackedTOIs;
    } forEach (missionNamespace getVariable ["RQ4Tweak_allAVs", []]);

    {
        [_x] remoteExec ["deleteMarkerLocal", _playerObj];
    } forEach (allMapMarkers select {"_trackDot_" in _x});

    // Remove the player from the list of MTI recipients, update the list globally.
    _recipients = (missionNamespace getVariable ["RQ4Tweak_mtiRecipients", []]) - [_playerObj];
    missionNamespace setVariable ["RQ4Tweak_mtiRecipients", _recipients, true];
};

_ctrlRecipients lbDelete _index;

