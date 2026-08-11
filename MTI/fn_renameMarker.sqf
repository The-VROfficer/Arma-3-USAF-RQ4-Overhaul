/*
	Author: Waylen

	Locality: Local, executed on player

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

hint parseText "<t color='#ff0000'>Click on a marker to change it's name.</t>";

addMissionEventHandler [ 
    "MapSingleClick",
    {
        params ["_units", "_pos"];
	    private _gh = _thisArgs select 0;

	    if (isNull _gh) exitWith { hintSilent "" };
	    if (not alive _gh) exitWith { hintSilent "" };

        [_pos] spawn 
        {
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

            // get new marker name from user
            private _inputText = ["Marker name:", "", _foundMarkerName] call BIS_fnc_inputBox;
            
            if (_inputText isEqualTo "") exitWith {
                systemChat "No name provided.";
            };

            _foundMarker setMarkerTextLocal _inputText;
        };
		removeMissionEventHandler ["MapSingleClick", _thisEventHandler];
    }, [_gh]
];

true;