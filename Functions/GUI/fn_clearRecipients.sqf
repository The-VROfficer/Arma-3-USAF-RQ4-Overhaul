/*
    Author: Waylen

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

missionNamespace setVariable ["RQ4Tweak_mtiRecipients", [], true];
lbClear _ctrlRecipients;
