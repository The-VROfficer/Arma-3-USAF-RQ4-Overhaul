/*
	Author: Waylen & Myth

	Locality: Local, executed on connected UAV pilot's machine.

	Description:
		Prompts user to click on a given GMTI marker, then prompts a dialog box to give a new name.

	Parameter(s):
		0: <OBJECT> - The MTI vehicle (ideally the RQ-4 Global Hawk).

	Returns:
		BOOLEAN - True if script completed.

	Examples:
		[myGlobalHawk] spawn MM_fnc_renameMarker
*/
params [
	["_gh", objNull, [objNull]]
];

openMap true;

hint parseText "<t color='#ff0000'>Click on a marker to change its name.</t>";

addMissionEventHandler [ 
    "MapSingleClick",
    {
        params ["_units", "_pos"];
	    private _gh = _thisArgs select 0;

	    if ( isNull _gh ) exitWith {};
	    if ( not alive _gh ) exitWith {};

        [_pos] spawn {
            params ["_pos"];
            private _foundMarker = "";
            private _closestDist = 10;

            // determine nearest marker to cursor that contains "GMTI_Marker_" w/in a 10m radius
            {
                if ((_x find "GMTI_Marker_") == 0) then {
                    private _markerPos = getMarkerPos _x;
                    private _dist = sqrt (((_markerPos select 0) - (_pos select 0))^2 + ((_markerPos select 1) - (_pos select 1))^2);
                
                    if (_dist < _closestDist) then {
                        _closestDist = _dist;
                        _foundMarker = _x;
                    };
                };
            } forEach allMapMarkers;

            // break condition if no map marker w/in 10m
            if (_foundMarker isEqualTo "") exitWith
            {
                hint parseText "No GMTI marker found.";
            };

            private _foundMarkerName = (_foundMarker call BIS_fnc_markerParams) select 8;

            // When player clicks on the marker, the selected one should turn yellow to indicate the selection. Once the text is changed and submitted, it should go back to green.
            private _storedColor = (_foundMarker call BIS_fnc_markerParams) select 3;
            _foundMarker setMarkerColorLocal "ColorUNKNOWN";

            // Insert GUI controls HERE later so player can rename the marker
            //
            //
            _inputText = "My newest test marker";
            //
            //
            //
            
            if (_inputText isEqualTo "") exitWith {
                hint "ERROR: No name provided.";
            };

            _foundMarker setMarkerColorLocal _storedColor;

            hint "Marker renamed!";

            _foundMarker setMarkerTextLocal _inputText;
        };

		removeMissionEventHandler ["MapSingleClick", _thisEventHandler];
    }, [_gh]
];

true;