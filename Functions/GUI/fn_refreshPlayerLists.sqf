/*
    Author: Waylen

    Locality: Client

    Description:
        Keeps lbAllPlayers and lbRecipients synchronized while the sensor-control
        dialog is open. New and departing players are reflected in lbAllPlayers;
        recipients who leave are removed from the connected UAV's recipient array
        and the visible recipient list. Current selection is preserved by UID when
        either list must be rebuilt.

    Parameter(s):
        None.

    Returns:
        Nothing.

    Examples:
        [] spawn MM_fnc_refreshPlayerLists;

    NOTE - This function suspends between refreshes, so call it with spawn. The
    loop exits when the dialog closes. Recipient changes are broadcast, and the
    recipient array is stored on the connected UAV. If there is no connected UAV,
    the recipient list is cleared from the dialog on its next refresh. Listbox
    selection is restored by UID after a list rebuild when the player is still
    present in that list.
*/

disableSerialization;

private _display = findDisplay 1250;
if (isNull _display) exitWith {};

private _ctrlAllPlayers = _display displayCtrl 1500;
private _ctrlRecipients = _display displayCtrl 1501;

while {!isNull _display} do {
    uiSleep 1;
    if (isNull _display) exitWith {};

    private _onlinePlayers = allPlayers;
    private _playerRows = [];
    private _playerKeys = [];
    {
        private _uid = getPlayerUID _x;
        private _playerName = name _x;
        _playerRows pushBack [_uid, _playerName];
        _playerKeys pushBack format ["%1|%2", _uid, _playerName];
    } forEach _onlinePlayers;
    _playerKeys sort true;

    private _visiblePlayerKeys = [];
    for "_index" from 0 to ((lbSize _ctrlAllPlayers) - 1) do {
        _visiblePlayerKeys pushBack format [
            "%1|%2",
            _ctrlAllPlayers lbData _index,
            _ctrlAllPlayers lbText _index
        ];
    };
    _visiblePlayerKeys sort true;

    if !(_visiblePlayerKeys isEqualTo _playerKeys) then {
        private _selectedUID = "";
        private _selectedIndex = lbCurSel _ctrlAllPlayers;
        if (_selectedIndex >= 0) then {
            _selectedUID = _ctrlAllPlayers lbData _selectedIndex;
        };

        lbClear _ctrlAllPlayers;
        {
            private _row = _x;
            private _newIndex = _ctrlAllPlayers lbAdd (_row select 1);
            _ctrlAllPlayers lbSetData [_newIndex, _row select 0];
        } forEach _playerRows;

        private _restoredIndex = lbSize _ctrlAllPlayers;
        for "_index" from 0 to ((lbSize _ctrlAllPlayers) - 1) do {
            if ((_ctrlAllPlayers lbData _index) isEqualTo _selectedUID) exitWith {
                _restoredIndex = _index;
            };
        };
        if (_restoredIndex < (lbSize _ctrlAllPlayers)) then {
            _ctrlAllPlayers lbSetCurSel _restoredIndex;
        };
    };

    private _uav = getConnectedUAV player;
    private _recipients = [];
    if (!isNull _uav) then {
        private _storedRecipients = _uav getVariable ["RQ4Tweak_mtiRecipients", []];
        {
            if (!isNull _x && {_x in _onlinePlayers}) then {
                _recipients pushBackUnique _x;
            };
        } forEach _storedRecipients;

        if !(_recipients isEqualTo _storedRecipients) then {
            _uav setVariable ["RQ4Tweak_mtiRecipients", _recipients, true];
        };
    };

    private _recipientRows = _recipients apply {
        [getPlayerUID _x, name _x]
    };
    private _recipientKeys = _recipientRows apply {
        format ["%1|%2", _x select 0, _x select 1]
    };
    _recipientKeys sort true;

    private _visibleRecipientKeys = [];
    for "_index" from 0 to ((lbSize _ctrlRecipients) - 1) do {
        _visibleRecipientKeys pushBack format [
            "%1|%2",
            _ctrlRecipients lbData _index,
            _ctrlRecipients lbText _index
        ];
    };
    _visibleRecipientKeys sort true;

    if !(_visibleRecipientKeys isEqualTo _recipientKeys) then {
        private _selectedUID = "";
        private _selectedIndex = lbCurSel _ctrlRecipients;
        if (_selectedIndex >= 0) then {
            _selectedUID = _ctrlRecipients lbData _selectedIndex;
        };

        lbClear _ctrlRecipients;
        {
            private _row = _x;
            private _newIndex = _ctrlRecipients lbAdd (_row select 1);
            _ctrlRecipients lbSetData [_newIndex, _row select 0];
        } forEach _recipientRows;

        private _restoredIndex = lbSize _ctrlRecipients;
        for "_index" from 0 to ((lbSize _ctrlRecipients) - 1) do {
            if ((_ctrlRecipients lbData _index) isEqualTo _selectedUID) exitWith {
                _restoredIndex = _index;
            };
        };
        if (_restoredIndex < (lbSize _ctrlRecipients)) then {
            _ctrlRecipients lbSetCurSel _restoredIndex;
        };
    };
};
