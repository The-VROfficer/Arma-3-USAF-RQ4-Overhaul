/*
	Author: Waylen & Myth

	Locality: Local, executed on the AV pilot's machine

	Description:
		Prompts user to click on a given GMTI marker, then highlights and displays detailed info about that marker. Marker is deselected once player clicks off or closes map.

	Parameter(s):
		0: <OBJECT> - The MTI vehicle (ideally the RQ-4 Global Hawk).

	Returns:
		BOOLEAN - True if script completed.

	Examples:
		[myGlobalHawk] spawn MM_fnc_highlightMarker
*/

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_highlightMarker";

params [
	["_gh", objNull, [objNull]]
];

hint "Click on a marker to highlight it.";

addMissionEventHandler [ 
    "MapSingleClick",
    {
        params ["_units", "_pos"];
	    private _gh = _thisArgs select 0;

	    if ( isNull _gh ) exitWith {};
	    if ( not alive _gh ) exitWith {};

        [_pos, _gh] spawn {
            params ["_pos", "_gh"];
            private _foundMarker = "";
            private _closestDist = 50;

            // determine nearest marker to cursor that contains "TOI_" w/in a 50m radius
            {
                if ((_x find "TOI_") == 0) then {
                    private _markerPos = getMarkerPos _x;
                    private _dist = sqrt (((_markerPos select 0) - (_pos select 0))^2 + ((_markerPos select 1) - (_pos select 1))^2);
                
                    if (_dist < _closestDist) then {
                        _closestDist = _dist;
                        _foundMarker = _x;
                    };
                };
            } forEach allMapMarkers;

            // break condition if no map marker w/in 50m
            if (_foundMarker isEqualTo "") exitWith
            {
                hint parseText "<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />No TOI marker found.";
            };

            private _foundMarkerName = (_foundMarker call BIS_fnc_markerParams) select 8;

            private _storedColor = (_foundMarker call BIS_fnc_markerParams) select 3;
            
            _foundMarker setMarkerColorLocal "ColorYELLOW";

            // Create a LOCAL var that is attached to the marker, this var will determine if the game should continue displaying the data box or not.
            missionNamespace setVariable ["RQ4Tweak_markerSelected", [true, _foundMarker]];

            // ---------------------------------
            // Create hint box containing TOI data
            // ---------------------------------

            [_foundMarker, _gh] spawn {
                params ["_foundMarker", "_gh"];

                while { (missionNamespace getVariable ["RQ4Tweak_markerSelected", [false]]) select 0 } do {
                    private _seriesID = (_foundMarker splitString "_") select 1;

                    // Find which object this _foundMarker belongs too. Filtered list to improve efficiency.
                    private _entities = entities [["Car", "Helicopter", "Plane", "Ship", "Tank", "Truck", "UAV", "Man"], [], false, true];
                    
                    private _markerOwner = _entities select (_entities findIf {
                        // Returns the number after "TOI_" in the passed object's marker name
                        (((_x getVariable "RQ4Tweak_mtiMarkerParams") select 0 select 0) splitString "_") select 1 isEqualTo _seriesID;
                    });
                    
                    // Add marker deletion protection.
                    if ( (_markerOwner getVariable ["RQ4Tweak_mtiSector", []]) isEqualTo []) exitWith {
                        // DEBUG LVL 3
                        private _msg = format ["%1: Attempted to pull selected marker sector params, but %2's mtiSector param is missing!", _gh, _markerOwner];
                        ERROR_RPT(_msg, _curFunc);

                        hintSilent "";
                    };
                    if ( (_markerOwner getVariable ["RQ4Tweak_lastSeen", []]) isEqualTo []) exitWith {
                        // DEBUG LVL 3
                        private _msg = format ["%1: Attempted to pull spottedBy params, but %2's lastSeen param is missing!", _gh, _markerOwner];
                        ERROR_RPT(_msg, _curFunc);

                        hintSilent "";
                    };

                    // Add the marker owner to the markerSelected var.
                    private _data = missionNamespace getVariable "RQ4Tweak_markerSelected";
                    _data set [2, _markerOwner];
                    missionNamespace setVariable ["RQ4Tweak_markerSelected", _data, true];

                    // AV that spotted this target.
                    private _spottedBy = (_markerOwner getVariable "RQ4Tweak_lastSeen") select 2;
                    
                    // Pull the range sector for this target.
                    private _rangeSector = _markerOwner getVariable "RQ4Tweak_mtiSector";
                    private _sectors = [[MM_RQ4_Ranges_S1_Min, MM_RQ4_Ranges_S1_Max], [MM_RQ4_Ranges_S2_Min, MM_RQ4_Ranges_S2_Max], [MM_RQ4_Ranges_S3_Min, MM_RQ4_Ranges_S3_Max]] select (_rangeSector - 1);

                    // Get sland range.
                    private _slantRange = _spottedBy distance _markerOwner;

                    // Get target's altitude.
                    private _alt = ((getPosATLVisual _markerOwner) select 2) toFixed 1;

                    // RCS here is kind of a made up number lol, this is the same calculation from fn_createMTIMarker so at least it's consistent.
                    private _rcs = sizeOf (typeOf _markerOwner);

                    private _text = "<t align='center' font='PuristaBold'>MTI Analysis</t><br /><br /><t align='left'>Spotted by:            %1<br />Range Sector:       %2 (%3-%4m)<br />Slant Range:          %5m<br />Altitude:                  %6m<br />RCS:                         %7m^2<br /><br />";

                    hintSilent parseText format [_text, group _spottedBy, _rangeSector, _sectors select 0, _sectors select 1, _slantRange, _alt, _rcs];

                    //sleep parseNumber MM_RQ4_Update_Rate;
                    sleep 1;
                };
            };

            // ---------------------------------
            // Create additional EH to deselect click
            // ---------------------------------

            // If player changes the marker via fn_updateMarker, this EH gets deleted in there.
            private _deselectClickEH = addMissionEventHandler [
                "MapSingleClick",
                {
                    _thisArgs params ["_foundMarker", "_storedColor"];

                    // If mtiParams has not changed (user has not changed marker color via fn_updateMarker), then reset the marker color to its original.
                    if ( _storedColor isEqualTo ((((missionNamespace getVariable "RQ4Tweak_markerSelected") select 2) getVariable "RQ4Tweak_mtiMarkerParams") select 3) ) then {
                        _foundMarker setMarkerColorLocal _storedColor;
                    };

                    missionNamespace setVariable ["RQ4Tweak_markerSelected", nil];
                    hintSilent "";

                    removeMissionEventHandler ["MapSingleClick", _thisEventHandler];
                },
                [_foundMarker, _storedColor]
            ];

            private _data = missionNamespace getVariable "RQ4Tweak_markerSelected";
            _data set [3, _deselectClickEH];
            missionNamespace setVariable ["RQ4Tweak_markerSelected", _data];

            // ---------------------------------
            // Create custom EH that resets marker and stops data box execution if map is closed before deselect.
            // ---------------------------------

            [_foundMarker, _storedColor, _deselectClickEH] spawn {
                params ["_foundMarker", "_storedColor", "_deselectClickEH"];

                waitUntil { sleep 1; str (findDisplay 1250) isEqualTo "No Display" };

                _foundMarker setMarkerColorLocal _storedColor;

                removeMissionEventHandler ["MapSingleClick", _deselectClickEH];

                missionNamespace setVariable ["RQ4Tweak_markerSelected", nil];

                hintSilent "";
            };
        };

		removeMissionEventHandler ["MapSingleClick", _thisEventHandler];
    },
    [_gh]
];

true;