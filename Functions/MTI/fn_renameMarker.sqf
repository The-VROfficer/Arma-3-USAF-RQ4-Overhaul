/*
	Author: Myth

	Locality: Local, the AV pilot's PC.

	Description:
		Performs a search of TOI markers based on passed params to find a match, then renames the marker based on passed params.

	Parameter(s):
		0: <OBJECT> - The MTI vehicle (ideally the RQ-4 Global Hawk).
        1: <BOOLEAN> - Name-based or Click-based search. True for name-based, false for click-based.
        2: <STRING> - If name-based, the TOI marker name to search for.
        3: <STRING> - The new name of the marker.

	Returns:
		Nothing.

	Examples:
		[myGlobalHawk, true, "TOI 0-1", "myAwesomeMTI"] spawn MM_fnc_renameMarker;
        [myGlobalHawk, false, "", "myAwesomeMTI"] spawn MM_fnc_renameMarker;
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_renameMarker";

params [
	["_gh", objNull, [objNull]],
    ["_nameSearch", true, [true]],
    ["_searchID", "", [""]]
];

// DEBUG LVL 3
private _msg = format ["%1: Started - Params [%1, %2, %3, %4].", _gh, _nameSearch, _searchID];
DEBUG_RPT(_msg, _curFunc);

//cleanup vars
uiNamespace setVariable ["RQ4Tweak_markerName", nil];

// ---------------------------------
// See if marker exists based on passed search method.
// ---------------------------------

_foundMarker = if ( _nameSearch ) then {
    // Perform quick search to locate the marker. If no such marker exists, display error for user and log it.
    // This allMapMarkers search is LOCAL, so other "hidden" markers from other AVs and other sources will be protected.
    if ( (allMapMarkers findIf { _searchID in ((_x call bis_fnc_markerParams) select 8) }) == -1 ) exitWith {
        hint parseText format ["<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />No TOI markers contain ID [%1].", _searchID];

        sleep 5;
        hintSilent "";

        -1
    };

    // Check for duplicates and exit if any are found. Not efficient, but necessary.
    if ( ({ _searchID in ((_x call bis_fnc_markerParams) select 8) } count allMapMarkers) > 1 ) exitWith {
        hint parseText format ["<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />Too many markers containing [%1].", _searchID];

        sleep 5;
        hintSilent "";

        -1
    };

    _foundMarkerStr = allMapMarkers select (allMapMarkers findIf { _searchID in ((_x call bis_fnc_markerParams) select 8) });

    // DEBUG LVL 3
    private _msg = format ["%1: Found marker via name is - %2", _gh, _foundMarkerStr];
    DEBUG_RPT(_msg, _curFunc);

    _foundMarkerStr
} else {
    private _markerSelected = missionNamespace getVariable ["RQ4Tweak_markerSelected", []];

    if ( _markerSelected isEqualTo [] ) then {
        hint parseText "<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />No marker is currently selected.";
        
        -1
    } else {
        _markerSelected select 1
    };
};

// Destroy that temp var or else you get "ghost clicks".
missionNamespace setVariable ["RQ4Tweak_foundMarker", nil];

if ( _foundMarker isEqualTo -1 ) exitWith {};

[ // query for new marker name
    "RQ4Tweak_markerName",
    "Enter a new marker name"
] spawn MM_fnc_openTextEntryDialog;

waitUntil { // wait til they close dialog or input
    sleep 0.5; 
    !(uiNamespace isNil "RQ4Tweak_markerName") || {isNull (findDisplay 1251)}
};

//evaluate if they actually entered a value or closed it
if (uiNamespace isNil "RQ4Tweak_markerName" || {uiNamespace getVariable "RQ4Tweak_markerName" isEqualTo ""}) exitWith 
{
    hintSilent parseText "<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />No marker name entered.";
};

private _newName = uiNamespace getVariable "RQ4Tweak_markerName";

// ---------------------------------
// Invalid selection handling
// ---------------------------------

// Add invalid selection protection.
if ( isNil { _foundMarker } ) exitWith {
    hintSilent parseText "<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />Invalid marker selected.";

    // DEBUG LVL 3
    private _msg = format ["%1: Marker %2 is invalid! Exiting.", _gh, _foundMarker];
    ERROR_RPT(_msg, _curFunc);

    sleep 5;
    hintSilent "";
};

if ( not ("TOI_" in (_foundMarker call BIS_fnc_markerParams select 0 select 0))) exitWith {
    hintSilent parseText "<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />Invalid marker selected.";

    // DEBUG LVL 3
    private _msg = format ["%1: Marker %2 is invalid! Exiting.", _gh, _foundMarker];
    ERROR_RPT(_msg, _curFunc);

    sleep 5;
    hintSilent "";
};

// ---------------------------------
// Perform marker renaming
// ---------------------------------

private _seriesID = (_foundMarker splitString "_") select 1;

// Find which object this _foundMarker belongs too. Filtered list to improve efficiency.
private _entities = entities [["Car", "Helicopter", "Plane", "Ship", "Tank", "Truck", "UAV", "Man"], [], false, true];

private _markerOwner = _entities select (_entities findIf {
    // Returns the number after "TOI_" in the passed object's marker name
    (((_x getVariable "RQ4Tweak_mtiMarkerParams") select 0 select 0) splitString "_") select 1 isEqualTo _seriesID;
});

// DEBUG LVL 3
private _msg = format ["%1: Marker owner is %2.", _gh, _markerOwner];
DEBUG_RPT(_msg, _curFunc);

private _currentTimeName = (((_foundMarker call bis_fnc_markerParams) select 8) splitString "[") select 1; // Returns just the lastSeen timeblock.

// DEBUG LVL 3
private _msg = format ["%1: Raw timeblock is - %2", _gh, _currentTimeName];
DEBUG_RPT(_msg, _curFunc);

private _newCombinedName = _newName + " [" + _currentTimeName;

_foundMarker setMarkerTextLocal _newCombinedName;
[_foundMarker, _newCombinedName] remoteExec ["setMarkerTextLocal", missionNamespace getVariable ["RQ4Tweak_mtiReceipients", objNull], true];
[_foundMarker, _newCombinedName] remoteExec ["setMarkerTextLocal", 2, true];

// Update the mtiMarkerParams var on the object the TOI marker belongs to. This will prevent the server from undoing the renaming.
private _markerData = _markerOwner getVariable "RQ4Tweak_mtiMarkerParams";
_markerData set [8, _newCombinedName];
_markerOwner setVariable ["RQ4Tweak_mtiMarkerParams", _markerData, true];

hintSilent "";

true;