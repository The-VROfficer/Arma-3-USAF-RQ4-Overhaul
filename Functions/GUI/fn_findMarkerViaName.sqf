private _uav = getConnectedUAV player;
if(isNull _uav) exitWith {};

[ // query user for marker they're searching for
    "uiNamespace setVariable ['RQ4Tweak_marker',_textInput];",
    "Enter a marker ID"
] spawn MM_fnc_openTextEntryDialog;

waitUntil { // wait til they close dialog or input
    sleep 0.5; 
    !(isNil localNamespace getVariable ["RQ4Tweak_marker"]) || !dialog
};
// break condition in case they close dialog with ESC
if (isNil localNamespace getVariable ["RQ4Tweak_marker"]) exitWith {};

[ // query for new marker name
    "localNamespace setVariable ['RQ4Tweak_markerName',_textInput];",
    "Enter a new marker name"
] spawn MM_fnc_openTextEntryDialog;

waitUntil { // wait til dialog closed or input
    sleep 0.5; 
    !(isNil localNamespace getVariable ["RQ4Tweak_markerName"]) || !dialog
};
// break condition in case they close dialog with ESC
if (isNil localNamespace getVariable ["RQ4Tweak_markerName"]) exitWith {};

private _marker = localNamespace getVariable ["RQ4Tweak_marker"];
private _markerName = localNamespace getVariable ["RQ4Tweak_markerName"];

[
    _uav,
    true,
    _marker,
    _markerName
] spawn MM_fnc_renameMarker; // call new marker name func

//cleanup vars
localNamespace setVariable ["RQ4Tweak_marker", nil];
localNamespace setVariable ["RQ4Tweak_markerName", nil];

