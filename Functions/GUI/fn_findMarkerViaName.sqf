private _uav = getConnectedUAV player;
if(isNull _uav) exitWith {};

//cleanup vars
uiNamespace setVariable ["RQ4Tweak_marker", nil];
uiNamespace setVariable ["RQ4Tweak_markerName", nil];

[ // query user for marker they're searching for
    "RQ4Tweak_marker",
    "Enter a marker ID"
] spawn MM_fnc_openTextEntryDialog;

waitUntil { // wait til they close dialog or input
    sleep 0.5; 
    !(uiNamespace isNil "RQ4Tweak_marker") || {isNull (findDisplay 1251)}
};
// break condition in case they close dialog with ESC
if (uiNamespace isNil "RQ4Tweak_marker" || {uiNamespace getVariable "RQ4Tweak_marker" isEqualTo ""}) exitWith 
{
    hintSilent parseText "<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />No marker name entered.";
};

private _marker = uiNamespace getVariable "RQ4Tweak_marker";

[
    _uav,
    true,
    _marker
] spawn MM_fnc_renameMarker; // call new marker name func
