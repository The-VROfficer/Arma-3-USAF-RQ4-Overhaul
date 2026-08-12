/*
	Author: Myth

	Locality: Local, executed on the UAV pilot's computer.

	Description:
		Prompts user to click twice on the map and renders a rectangle based on the clicks, used for filtering targets geographically (GRCA).

	Parameter(s):
		0: <OBJECT> - The MTI vehicle (ideally the RQ-4 Global Hawk).

	Returns:
		BOOLEAN - True if script completed.

	Examples:
		[myGlobalHawk] spawn MM_fnc_drawGRCA
*/

params [
	["_gh", objNull, [objNull]]
];

openMap true;

hint parseText "Click to place the <t color='#ff0000'>TOP LEFT</t> of the GRCA.";

addMissionEventHandler [
	"MapSingleClick",
	{
		params ["_units", "_pos"];
		private _gh = _thisArgs select 0;

		if (isNull _gh) exitWith { hintSilent "" };
		if (not alive _gh) exitWith { hintSilent "" };

		[_pos, _gh] spawn {
			params ["_pos", "_gh"];

			private _GRCA_Data = _gh getVariable ["GMTI_GRCAs", []];

			// ---- Figure out next markers' IDs
			private _nextID = if ( _GRCA_Data isEqualTo [] ) then {		// If no GRCA has ever been drawn...
				1
			} else {		// GRCAs have been drawn before.
				selectMax (_GRCA_Data apply {_x select 0}) + 1;
			};

			_Marker1_ID = format ["GRCA_%1_0", _nextID];

			_topLeftMarker = createMarkerLocal [_Marker1_ID, _pos];
			_topLeftMarker setMarkerTypeLocal "mil_dot";
			_topLeftMarker setMarkerTextLocal "TOP LEFT";

			sleep 0.5;

			hint parseText "Click to place the <t color='#2bff00'>BOTTOM RIGHT</t> of the GRCA.";

			addMissionEventHandler [
				"MapSingleClick",
				{
					params ["_units", "_pos"];
					
					private _gh = _thisArgs select 0;
					private _topLeftMarker = _thisArgs select 1;
					private _nextID = _thisArgs select 2;
					private _GRCA_Data = _thisArgs select 3;

					if (isNull _gh) exitWith { hintSilent "" };
					if (not alive _gh) exitWith { hintSilent "" };

					[_pos, _gh, _topLeftMarker, _nextID, _GRCA_Data] spawn {
						params ["_pos", "_gh", "_topLeftMarker", "_nextID", "_GRCA_Data"];

						_Marker2_ID = format ["_USER_DEFINED GRCA_%1_1", _nextID];

						_bottomRightMarker = createMarkerLocal [_Marker2_ID, _pos];
						_bottomRightMarker setMarkerTypeLocal "mil_dot";
						_bottomRightMarker setMarkerTextLocal "BOTTOM RIGHT";

						private _areaCenterX = round ( (getMarkerPos _bottomRightMarker select 0) - (getMarkerPos _topLeftMarker select 0) ) / 2;
						private _areaCenterY = round ( (getMarkerPos _topLeftMarker select 1) - (getMarkerPos _bottomRightMarker select 1) ) / 2;

						private _areaCenterTrue = [(getMarkerPos _topLeftMarker select 0) + _areaCenterX, (getMarkerPos _bottomRightMarker select 1) + _areaCenterY];

						_GRCA_ID = format ["GRCA_BOX_%1", _nextID];

						deleteMarkerLocal _topLeftMarker;
						_bottomRightMarker setMarkerTextLocal format ["GRCA %1", (_GRCA_ID splitString "_") select 2];
						
						// ---- Duplicate marker preventer
						if (!isNil {markerShape _GRCA_ID}) then {
							deleteMarkerLocal _GRCA_ID;
						};

						_GRCA = createMarkerLocal [_GRCA_ID, _areaCenterTrue];
						[[_GRCA_ID, _areaCenterTrue]] remoteExec ["createMarkerLocal", 2];	// GRCA_BOX needs to be created ON THE SERVER too, otherwise "target in GRCA" checks will fail in MM_fnc_targetCollection.

						_GRCA setMarkerShapeLocal "RECTANGLE";
						[_GRCA, "RECTANGLE"] remoteExec ["setMarkerShapeLocal", 2];

						_GRCA setMarkerSizeLocal [_areaCenterX, _areaCenterY];
						[_GRCA, [_areaCenterX, _areaCenterY]] remoteExec ["setMarkerSizeLocal", 2];

						_GRCA setMarkerColorLocal "#(0, 0, 1, 1)";
						_GRCA setMarkerAlphaLocal 0.3;

						if ( _GRCA_Data isEqualTo [] ) then {		// If no GRCA has ever been drawn...
							_gh setVariable ["GMTI_GRCAs", [[1, _areaCenterX, _areaCenterY, _areaCenterTrue, _GRCA, _bottomRightMarker]], true];
						} else {		// GRCAs have been drawn before.
							_gh setVariable ["GMTI_GRCAs", _GRCA_Data + [[_nextID, _areaCenterX, _areaCenterY, _areaCenterTrue, _GRCA, _bottomRightMarker]]];
						};
					};

					hintSilent "";

					removeMissionEventHandler ["MapSingleClick", _thisEventHandler];
				}, [_gh, _topLeftMarker, _nextID, _GRCA_Data]
			];
		};
		removeMissionEventHandler ["MapSingleClick", _thisEventHandler];
	}, [_gh]
];

if (isNil {missionNamespace getVariable "GRCA_DeleteEH"}) then {

    private _eh = addMissionEventHandler ["MarkerDeleted", {

        params ["_marker", "_local", "_deleter"];
        
		private _gh = _thisArgs select 0;
		private _GRCA_Data = _gh getVariable ["GMTI_GRCAs", []];

        if (("_USER_DEFINED" in _marker) and ("GRCA" in _marker)) then {

            private _index = parseNumber ((_marker splitString "_") select 2);
            private _foundIndex = _GRCA_Data findIf { (_x select 0) == _index };

            if (_foundIndex != -1) then {

                private _GRCA_Delete = (_GRCA_Data select _foundIndex) select 4;

                deleteMarkerLocal _GRCA_Delete;
				[_GRCA_Delete] remoteExec ["deleteMarkerLocal", 2];		// This makes it so that it is also deleted on the server.

                _GRCA_Data deleteAt _foundIndex;
                _gh setVariable ["GMTI_GRCAs", _GRCA_Data];

                if (count _GRCA_Data == 0) then {
                    _gh setVariable ["GMTI_GRCAs", nil, true];
                };
            };
        };

    }, [_gh]];

    missionNamespace setVariable ["GRCA_DeleteEH", _eh, true];
};

true;