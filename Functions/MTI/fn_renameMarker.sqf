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
    ["_searchID", "", [""]],
    ["_newName", "", [""]]
];

// DEBUG LVL 3
private _msg = format ["%1: Started - Params [%1, %2, %3, %4].", _gh, _nameSearch, _searchID, _newName];
DEBUG_RPT(_msg, _curFunc);

// ---------------------------------
// See if marker exists based on passed search method.
// ---------------------------------

_foundMarker = if ( _nameSearch ) then {
    // Perform quick search to locate the marker. If no such marker exists, display error for user and log it.
    // This allMapMarkers search is LOCAL, so other "hidden" markers from other AVs and other sources will be protected.
    if ( (allMapMarkers findIf { _searchID in ((_x call bis_fnc_markerParams) select 8) }) == -1 ) exitWith {
        hint parseText format ["<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />No TOI markers contain ID [%1].", _searchID];
    };

    // Check for duplicates and exit if any are found. Not efficient, but necessary.
    if ( ({ _searchID in ((_x call bis_fnc_markerParams) select 8) } count allMapMarkers) > 1 ) exitWith {
        hint parseText format ["<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />Too many markers containing [%1].", _searchID];
    };

    _foundMarkerStr = allMapMarkers select (allMapMarkers findIf { _searchID in ((_x call bis_fnc_markerParams) select 8) });

    // DEBUG LVL 3
    private _msg = format ["%1: Found marker via name is - %2", _gh, _foundMarkerStr];
    DEBUG_RPT(_msg, _curFunc);

    _foundMarkerStr
} else {
    _foundMarkerStr = "";
    
    hint "Click on a marker to rename it.";

    addMissionEventHandler [ 
        "MapSingleClick",
        {
            params ["_units", "_pos"];
            private _gh = _thisArgs select 0;
            private _foundMarkerStr = _thisArgs select 1;

            if ( isNull _gh ) exitWith {};
            if ( not alive _gh ) exitWith {};

            [_pos, _gh] spawn {
                params ["_pos", "_gh"];
                private _closestDist = 50;
                private _foundMarkerStr = "";

                // determine nearest marker to cursor that contains "TOI_" w/in a 50m radius
                {
                    if ((_x find "TOI_") == 0) then {
                        private _markerPos = getMarkerPos _x;
                        private _dist = sqrt (((_markerPos select 0) - (_pos select 0))^2 + ((_markerPos select 1) - (_pos select 1))^2);
                    
                        if (_dist < _closestDist) then {
                            _closestDist = _dist;
                            _foundMarkerStr = _x;
                        };
                    };
                } forEach allMapMarkers;

                // break condition if no map marker w/in 50m
                if (_foundMarkerStr isEqualTo "") exitWith {
                    missionNamespace setVariable ["RQ4Tweak_foundMarker", -1];
                };

                missionNamespace setVariable ["RQ4Tweak_foundMarker", _foundMarkerStr];
            };

            removeMissionEventHandler ["MapSingleClick", _thisEventHandler];
        },
        [_gh, _foundMarkerStr]
    ];

    waitUntil { sleep 1; (missionNamespace getVariable ["RQ4Tweak_foundMarker", false]) isNotEqualTo false };

    // If nothing was found via click, exit.
    if ( (missionNamespace getVariable "RQ4Tweak_foundMarker") isEqualTo -1 ) exitWith {
        hint parseText "<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />No TOI marker found.";
    };

    // DEBUG LVL 3
    private _msg = format ["%1: Found marker via click is - %2", _gh, missionNamespace getVariable "RQ4Tweak_foundMarker"];
    DEBUG_RPT(_msg, _curFunc);

    missionNamespace getVariable "RQ4Tweak_foundMarker"
};

// Make sure to destroy the temp var made to support the click selection thing. Otherwise causes "ghost clicks".
missionNamespace setVariable ["RQ4Tweak_foundMarker", nil];

// ---------------------------------
// Invalid selection handling
// ---------------------------------

// Add invalid selection protection.
if ( isNil { _foundMarker } ) exitWith {
    hint parseText "<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />Invalid marker selected.";

    // DEBUG LVL 3
    private _msg = format ["%1: Marker %2 is invalid! Exiting.", _gh, _foundMarker];
    ERROR_RPT(_msg, _curFunc);
};

if ( not ("TOI_" in (_foundMarker call BIS_fnc_markerParams select 0 select 0)) ) exitWith {
    hint parseText "<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />Invalid marker selected.";

    // DEBUG LVL 3
    private _msg = format ["%1: Marker %2 is invalid! Exiting.", _gh, _foundMarker];
    ERROR_RPT(_msg, _curFunc);
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