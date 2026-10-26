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

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_drawGRCA";

params [
	["_gh", objNull, [objNull]]
];

// DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1]", _gh];
DEBUG_RPT(_msg, _curFunc);

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

			private _grcaData = _gh getVariable ["RQ4Tweak_grcas", []];

			// ---- Figure out next markers' IDs
			private _nextID = if ( _grcaData isEqualTo [] ) then {		// If no GRCA has ever been drawn...
				1
			} else {		// GRCAs have been drawn before.
				selectMax (_grcaData apply {_x select 0}) + 1;
			};

			// Add this AV's netID to the GRCA ID to prevent issues w/ overlapping mark names shinnanigans.
			private _ghId = (netId _gh) regexReplace [":", "_"];
			_Marker1_ID = format ["GRCA_%1_0_%2", _nextID, _ghID];

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
					private _grcaData = _thisArgs select 3;
					private _ghID = _thisArgs select 4;

					if (isNull _gh) exitWith { hintSilent "" };
					if (not alive _gh) exitWith { hintSilent "" };

					[_pos, _gh, _topLeftMarker, _nextID, _grcaData, _ghID] spawn {
						params ["_pos", "_gh", "_topLeftMarker", "_nextID", "_grcaData", "_ghID"];

						_Marker2_ID = format ["_USER_DEFINED GRCA_%1_1_%2", _nextID, _ghID];

						_bottomRightMarker = createMarkerLocal [_Marker2_ID, _pos];
						_bottomRightMarker setMarkerTypeLocal "mil_dot";
						_bottomRightMarker setMarkerTextLocal "BOTTOM RIGHT";

						private _areaCenterX = round ( (getMarkerPos _bottomRightMarker select 0) - (getMarkerPos _topLeftMarker select 0) ) / 2;
						private _areaCenterY = round ( (getMarkerPos _topLeftMarker select 1) - (getMarkerPos _bottomRightMarker select 1) ) / 2;

						private _areaCenterTrue = [(getMarkerPos _topLeftMarker select 0) + _areaCenterX, (getMarkerPos _bottomRightMarker select 1) + _areaCenterY];

						_grcaID = format ["GRCA_BOX_%1_%2", _nextID, _ghID];

						deleteMarkerLocal _topLeftMarker;
						_bottomRightMarker setMarkerTextLocal format ["GRCA %1", (_grcaID splitString "_") select 2];
						
						// ---- Duplicate marker preventer
						if (!isNil {markerShape _grcaID}) then {
							deleteMarkerLocal _grcaID;
						};

						_grca = createMarkerLocal [_grcaID, _areaCenterTrue];
						[[_grcaID, _areaCenterTrue]] remoteExec ["createMarkerLocal", 2];	// GRCA_BOX needs to be created ON THE SERVER too, otherwise "target in GRCA" checks will fail in MM_fnc_targetCollection.

						_grca setMarkerShapeLocal "RECTANGLE";
						[_grca, "RECTANGLE"] remoteExec ["setMarkerShapeLocal", 2];

						_grca setMarkerSizeLocal [_areaCenterX, _areaCenterY];
						[_grca, [_areaCenterX, _areaCenterY]] remoteExec ["setMarkerSizeLocal", 2];

						_grca setMarkerColorLocal "#(0, 0, 1, 1)";
						_grca setMarkerAlphaLocal 0.3;

						// If GRCA has never been drawn, push back this GRCA as the first bit of data in the var, otherwise add it to the existing var data.
						if ( _grcaData isEqualTo [] ) then {
							_gh setVariable ["RQ4Tweak_grcas", [[1, _areaCenterX, _areaCenterY, _areaCenterTrue, _grca, _bottomRightMarker, getMarkerPos _bottomRightMarker]], true];
						} else {
							_gh setVariable ["RQ4Tweak_grcas", _grcaData + [[_nextID, _areaCenterX, _areaCenterY, _areaCenterTrue, _grca, _bottomRightMarker, getMarkerPos _bottomRightMarker]], true];
						};
					};

					hintSilent "";

					removeMissionEventHandler ["MapSingleClick", _thisEventHandler];
				},
				[_gh, _topLeftMarker, _nextID, _grcaData, _ghID]
			];
		};
		removeMissionEventHandler ["MapSingleClick", _thisEventHandler];
	}, [_gh]
];


// Add a mission eventhandler that handles checks if ANY marker that was just deleted was a GRCA marker. If it was, handle it approriately. This only needs to be defined once.
if (isNil {missionNamespace getVariable "RQ4Tweak_grcaDeleteEH"}) then {
    private _eh = addMissionEventHandler ["MarkerDeleted", {

        params ["_marker", "_local", "_deleter"];
        private _gh = _thisArgs select 0;

		// DEBUG LVL 3
		private _msg = format ["%1: GRCA deletion EH started - Params: [%1, %2, %3, %4]", _gh, _marker, _local, _deleter];
		DEBUG_RPT(_msg, "fn_drawGRCA (EH)");

		private _grcaData = _gh getVariable ["RQ4Tweak_grcas", []];

        if (("_USER_DEFINED" in _marker) and ("GRCA" in _marker)) then {

			if ( missionNamespace getVariable ("RQ4Tweak_localDeleteOnly_" + _marker) isEqualTo true ) exitWith {
				// DEBUG LVL 3
				private _msg = format ["%1: Exiting GRCA deletion EH, commanded local delete only.", _gh];
				DEBUG_RPT(_msg, "fn_drawGRCA (EH)");

				// This var, defined in fn_handlePilot, should be one-time use only, so destroy it when not in use.
				missionNamespace setVariable ["RQ4Tweak_localDeleteOnly_" + _marker, nil, true];
			};

            private _index = parseNumber ((_marker splitString "_") select 2);
            private _foundIndex = _grcaData findIf { (_x select 0) == _index };

            if (_foundIndex != -1) then {

                private _grcaDelete = (_grcaData select _foundIndex) select 4;

                deleteMarkerLocal _grcaDelete;
				[_grcaDelete] remoteExec ["deleteMarkerLocal", 2];		// This makes it so that it is also deleted on the server.

                _grcaData deleteAt _foundIndex;
                _gh setVariable ["RQ4Tweak_grcas", _grcaData];

				// If RQ4Tweak_grcas var is empty, destroy the var.
                if (count _grcaData == 0) then {
                    _gh setVariable ["RQ4Tweak_grcas", nil, true];
                };
            };

			// DEBUG LVL 3
			private _msg = format ["%1: GRCA deletion EH complete, %2 is deleted from server and clients.", _gh, _marker];
			DEBUG_RPT(_msg, "fn_drawGRCA (EH)");
        } else {
			// DEBUG LVL 3
			private _msg = format ["%1: Exiting GRCA deletion EH, marker %2 does not match criteria.", _gh, _marker];
			DEBUG_RPT(_msg, "fn_drawGRCA (EH)");
		};
    }, [_gh]];

    missionNamespace setVariable ["RQ4Tweak_grcaDeleteEH", _eh, true];
};

true;