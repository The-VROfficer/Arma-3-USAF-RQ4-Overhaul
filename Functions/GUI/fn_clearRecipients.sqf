/*
    Author: Waylen & Myth

    Locality: Client

    Description:
        Empties the "MTI Recipients" listbox (lbRecipients) and resets
        RQ4Tweak_mtiRecipients on the connected UAV back to an empty array.

    Parameter(s):
        None.

    Returns:
        Nothing.

    Examples:
        onButtonClick = "[] call MM_fnc_clearRecipients;";

    NOTE - setVariable is called with the public/broadcast flag so fn_collectMTI can
    read this wherever it actually runs (e.g. the server).
*/

private _uav = getConnectedUAV player;
if (isNull _uav) exitWith {};

private _display = findDisplay 1250;
if (isNull _display) exitWith {};

private _ctrlRecipients = _display displayCtrl 1501;

for "_i" from 0 to (lbSize _ctrlRecipients) - 1 do {
    _playerObjnetID = _ctrlRecipients lbData _i;

    _playerObj = objectFromNetID _playerObjnetID;
    
    if ( not isNull _playerObj ) then {
        // Turn off ALL targets from all AVs for this player.
        {
            private _gh = _x;
            if ( isNull _gh ) exitWith { continue };

            private _allTrackedTOIs = _gh getVariable ["RQ4Tweak_allTOIMarkers", []];
            {
               [_x, 0] remoteExec ["setMarkerAlphaLocal", _playerObj];
            } forEach _allTrackedTOIs;
        } forEach (missionNamespace getVariable ["RQ4Tweak_allAVs", []]);
    
        // Not working?
        {
            [_x] remoteExec ["deleteMarkerLocal", _playerObj];
        } forEach (allMapMarkers select {"_trackDot_" in _x});
    };
};

missionNamespace setVariable ["RQ4Tweak_mtiRecipients", [], true];
lbClear _ctrlRecipients;