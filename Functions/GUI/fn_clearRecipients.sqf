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

// Remove all recipients globally to stop marker updates.
missionNamespace setVariable ["RQ4Tweak_mtiRecipients", [], true];

for "_i" from 0 to (lbSize _ctrlRecipients) - 1 do {
    _playerObjnetID = _ctrlRecipients lbData _i;

    _playerObj = objectFromNetID _playerObjnetID;
    
    if ( not isNull _playerObj ) then {
        // Turn off ALL targets from all AVs for this player.
        {
            [_playerObj, _x] spawn {
                // Iterate twice to catch edge case of marker being created at same time as deletion.
                for "_y" from 0 to 1 do {
                    params ["_playerObj", "_gh"];

                    if ( isNull _gh ) exitWith { continue };

                    // Adds this var to all tracked vehicle OBJECTS.
                    {
                        [_x, ["RQ4Tweak_isTOIHidden", true]] remoteExec ["setVariable", _playerObj];
                    } forEach (_gh getVariable ["RQ4Tweak_trackedTargets", []]);

                    // Performs this on all TOI MARKERS.
                    {
                        [_x, 0] remoteExec ["setMarkerAlphaLocal", _playerObj];
                    } forEach (_gh getVariable ["RQ4Tweak_allTOIMarkers", []]);
                    
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
};

lbClear _ctrlRecipients;