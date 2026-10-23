
/*
    Author: Waylen

    Locality: Client

    Description:
        Runs when the sensor-control dialog closes. Removes the mission-level
        PlayerConnected event handler, if one was registered elsewhere, and clears
        its stored handler ID. The player-list refresh itself runs in a polling loop.

    Parameter(s):
        0: DISPLAY - The display being closed, supplied by the dialog onUnload event.
        1: NUMBER - The dialog exit code, supplied by the dialog onUnload event.

    Returns:
        Nothing.

    Examples:
        onUnload = "_this call MM_fnc_onDialogUnload;";

    NOTE - The handler ID is stored in RQ4_playerConnectedEH. The nil check allows
    the dialog to close safely when no PlayerConnected handler was registered.
*/

params ["_display", "_exitCode"];

if (!isNil "RQ4_playerConnectedEH") then {
    removeMissionEventHandler ["PlayerConnected", RQ4_playerConnectedEH];
    RQ4_playerConnectedEH = nil;
};
