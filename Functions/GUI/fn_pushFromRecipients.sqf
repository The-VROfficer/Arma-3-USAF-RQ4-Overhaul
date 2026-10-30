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
        onButtonClick = "[] spawn MM_fnc_pushFromRecipients;";
*/

private _display = findDisplay 1250;
if (isNull _display) exitWith {};

private _ctrlRecipients = _display displayCtrl 1501;
private _index = lbCurSel _ctrlRecipients;
if (_index < 0) exitWith {};

private _netId = _ctrlRecipients lbData _index;
private _playerObj = objectFromNetId _netId;

// Remove the player from the list of MTI recipients, update the list globally. Prevents additional marker updates from being sent.
_recipients = (missionNamespace getVariable ["RQ4Tweak_mtiRecipients", []]) - [_playerObj];
missionNamespace setVariable ["RQ4Tweak_mtiRecipients", _recipients, true];

if (!isNull _playerObj) then {
    // Turn off ALL targets from all AVs for this player.
    {
        [_playerObj, _x] spawn {
            params ["_playerObj", "_gh"];
            
            // Iterate twice to catch edge case of marker being created at same time as deletion.
            for "_y" from 0 to 1 do {
                if ( isNull _gh ) exitWith { continue };

                // Adds this var to all tracked vehicle OBJECTS.
                {
                    [_x, ["RQ4Tweak_isTOIHidden", true]] remoteExec ["setVariable", _playerObj];
                } forEach (_gh getVariable ["RQ4Tweak_trackedTargets", []]);

                {
                    [_x, 0] remoteExec ["setMarkerAlphaLocal", _playerObj];
                } forEach (_gh getVariable ["RQ4Tweak_allTOIMarkers", []];);
                
                sleep 1;
            };
        };
    } forEach (missionNamespace getVariable ["RQ4Tweak_allAVs", []]);

    // Send this code to the server for execution, since the server sees all TOI and track dot markers. Ingenious, truly spectacular.
    [[_playerObj], {
        params ["_playerObj"];

        {
            [_x] remoteExec ["deleteMarkerLocal", _playerObj];
        } forEach (allMapMarkers select {"_trackDot_" in _x});
    }] remoteExec ["spawn", 2];
};

_ctrlRecipients lbDelete _index;

