/*
	Author: Myth

    Locality:
		Local, the connected UAV pilot's machine.

	Description:
		Handles the creation/deletion of the pseudo-UAV terminal (and its actions) within the custom GUI.

	Parameter(s):
		Nothing.

	Returns:
		Nothing

	Examples:
		[] spawn MM_fnc_handlePsuedoTerminal
*/

#include "..\color_defines.hpp"

disableSerialization;

private _display = findDisplay 1250;
if (isNull _display) exitWith {};

private _map = _display displayCtrl 1801;

/////////////////////////////////////
// Prune completed waypoints from the connected UAV's queue
/////////////////////////////////////

private _pruneQueue = {
	private _gh = getConnectedUAV player;
	if (isNull _gh) exitWith {};

	private _queue = _gh getVariable ["RQ4Tweak_waypointQueue", []];
	if (_queue isEqualTo []) exitWith {};

	private _grp = group driver _gh;
	if (isNull _grp) exitWith {};

	private _current = currentWaypoint _grp;

	// A route with a Cycle waypoint repeats, so completed waypoints stay in the queue.
	private _hasCycle = (_queue findIf { (_x param [2, "MOVE"]) == "CYCLE" }) != -1;
	private _remaining = if (_hasCycle) then { +_queue } else { _queue select { (_x select 0) >= _current } };

	if (_remaining isNotEqualTo []) then {
		private _wps = waypoints _grp;
		private _lastIdx = (_remaining select ((count _remaining) - 1)) select 0;

		// Something was appended after our last queued waypoint.
		private _hasForeignWP = (count _wps) > (_lastIdx + 1);

		// A queued waypoint is missing, or has been moved/replaced (5 m tolerance).
		private _hasMismatch = (_remaining findIf {
			_x params ["_idx", "_pos"];
			(_idx >= (count _wps)) or {((waypointPosition [_grp, _idx]) distance2D _pos) > 5}
		}) != -1;

		if (_hasForeignWP or _hasMismatch) then { _remaining = []; };
	};

	// Only broadcast when something actually changed, to keep network traffic down.
	if (_remaining isNotEqualTo _queue) then {
		_gh setVariable ["RQ4Tweak_waypointQueue", _remaining, true];
	};
};

call _pruneQueue;

/////////////////////////////////////
// Ctrl tracking 
/////////////////////////////////////

_display displayAddEventHandler ["KeyDown", {
	params ["_disp", "_key"];
	if (_key in [29, 157]) then { _disp setVariable ["RQ4Tweak_ctrlHeld", true]; };
	false
}];

_display displayAddEventHandler ["KeyUp", {
	params ["_disp", "_key"];
	if (_key in [29, 157]) then { _disp setVariable ["RQ4Tweak_ctrlHeld", false]; };
	false
}];

/////////////////////////////////////
// Draw EH 
/////////////////////////////////////

_map ctrlAddEventHandler ["Draw", {
	params ["_ctrl"];
	private _uav = getConnectedUAV player;
	if (isNull _uav) exitWith {};

	private _queue = _uav getVariable ["RQ4Tweak_waypointQueue", []];
	if (_queue isEqualTo []) exitWith {};

	private _color = switch ( _uav getVariable ["RQ4Tweak_mtiMarkerColor", "ColorWEST"] ) do {
		case "ColorUNKNOWN": { ColorUNKNOWN };
		case "ColorEAST": { ColorEAST };
		case "ColorCIV": { ColorCIV };
		case "ColorGUER": { ColorGUER };
		case "ColorWEST": { ColorWEST };
		default { ColorWEST };
	};

	private _from = _uav;
	{
		_x params ["", "_to", ["_type", "MOVE"]];

		_ctrl drawArrow [_from, _to, _color];

		if (_type in ["CYCLE", "LAND"]) then {
			_ctrl drawIcon ["#(rgb,1,1,1)color(0,0,0,0)", _color, _to, 0, 0, 0, _type, 2, 0.05, "RobotoCondensed", "right"];
		};

		_from = _to;
	} forEach _queue;
}];

/////////////////////////////////////
// Right-click a queued waypoint
/////////////////////////////////////

_map ctrlAddEventHandler ["MouseButtonUp", {
	params ["_mapCtrl", "_button", "_xPos", "_yPos"];

	private _disp = ctrlParent _mapCtrl;

	// A release inside an open menu belongs to the menu (it is selecting an item); leave it alone.
	private _oldMenu = _disp getVariable ["RQ4Tweak_wpMenu", controlNull];
	private _menuPos = if (isNull _oldMenu) then { [0, 0, 0, 0] } else { ctrlPosition _oldMenu };
	private _inMenu = (not isNull _oldMenu)
		and {_xPos >= (_menuPos select 0)}
		and {_xPos <= ((_menuPos select 0) + (_menuPos select 2))}
		and {_yPos >= (_menuPos select 1)}
		and {_yPos <= ((_menuPos select 1) + (_menuPos select 3))};

	if (_inMenu) exitWith {};

	// Any other click closes a menu that is already open.
	if (not isNull _oldMenu) then { ctrlDelete _oldMenu; };

	// Only the right mouse button opens a menu.
	if (_button != 1) exitWith {};

	private _uav = getConnectedUAV player;
	if (isNull _uav) exitWith {};

	private _queue = _uav getVariable ["RQ4Tweak_waypointQueue", []];
	if (_queue isEqualTo []) exitWith {};

	// Find the queued waypoint nearest the cursor. The hit radius is 0.02 UI units, converted to metres at the map's current zoom.
	private _clickWorld = _mapCtrl ctrlMapScreenToWorld [_xPos, _yPos];
	private _hitMeters = _clickWorld distance2D (_mapCtrl ctrlMapScreenToWorld [_xPos + 0.02, _yPos]);

	private _hitIdx = -1;
	private _bestDist = _hitMeters;
	{
		private _d = _clickWorld distance2D (_x select 1);
		if (_d < _bestDist) then {
			_bestDist = _d;
			_hitIdx = _x select 0;
		};
	} forEach _queue;

	if (_hitIdx < 0) exitWith {};

	// [label, action] - edit this list to change the menu entries.
	private _options = [
		["Move", "MOVE"],
		["Loiter (CW)", "LOITER_CW"],
		["Loiter (CCW)", "LOITER_CCW"],
		["Cycle", "CYCLE"],
		["Land", "LAND"],
		["Delete Waypoint", "DELETE"]
	];

	[_disp, _xPos, _yPos, _hitIdx, _options] spawn {
		disableSerialization;   // this script holds a display, so it must not be serialized
		params ["_disp", "_xPos", "_yPos", "_hitIdx", "_options"];

		uiSleep 0.05;
		if (isNull _disp) exitWith {};

		// Replace any menu left over from a quick second right-click.
		private _oldMenu = _disp getVariable ["RQ4Tweak_wpMenu", controlNull];
		if (not isNull _oldMenu) then { ctrlDelete _oldMenu; };

		private _menuW = 0.28 * 0.6;
		private _menuH = (count _options) * 0.04 + 0.01;

		// Open at the cursor, but keep the whole menu on screen.
		private _menuX = _xPos min (safeZoneX + safeZoneW - _menuW);
		private _menuY = _yPos min (safeZoneY + safeZoneH - _menuH);

		private _menu = _disp ctrlCreate ["RscListBox", -1];
		_menu ctrlSetPosition [_menuX, _menuY, _menuW, _menuH];
		_menu ctrlSetBackgroundColor [0, 0, 0, 0.85];
		_menu ctrlSetFontHeight 0.035;
		_menu ctrlCommit 0;

		{ _menu lbAdd (_x select 0); } forEach _options;

		ctrlSetFocus _menu;
		_menu lbSetCurSel (-1);   // nothing pre-selected, so clicking any row, including the first, is a real change

		_menu setVariable ["RQ4Tweak_wpIdx", _hitIdx];
		_menu setVariable ["RQ4Tweak_wpOptions", _options];
		_disp setVariable ["RQ4Tweak_wpMenu", _menu];

		_menu ctrlAddEventHandler ["LBSelChanged", {
			params ["_menuCtrl", "_sel"];

			if (_sel < 0) exitWith {};

			private _wpIdx = _menuCtrl getVariable ["RQ4Tweak_wpIdx", -1];
			private _option = (_menuCtrl getVariable ["RQ4Tweak_wpOptions", []]) param [_sel, []];

			private _uav = getConnectedUAV player;
			private _grp = if (isNull _uav) then { grpNull } else { group driver _uav };

			if ( (_option isNotEqualTo []) and {_wpIdx >= 0} and {not isNull _grp} ) then {
				private _action = _option select 1;
				private _wp = [_grp, _wpIdx];
				private _queue = +(_uav getVariable ["RQ4Tweak_waypointQueue", []]);

				if (_action == "DELETE") then {
					deleteWaypoint _wp;

					// Drop the entry, then shift the index of every later waypoint down by one.
					_queue = _queue select { (_x select 0) != _wpIdx };
					_queue = _queue apply {
						if ((_x select 0) > _wpIdx) then {
							private _entry = +_x;
							_entry set [0, (_x select 0) - 1];
							_entry
						} else { _x }
					};
				} else {
					// [engine waypoint type, loiter type, type kept in the queue, statement run on arrival]
					private _cfg = switch (_action) do {
						case "MOVE":       { ["MOVE",   "CIRCLE",   "MOVE",   ""] };
						case "LOITER_CW":  { ["LOITER", "CIRCLE",   "LOITER", ""] };
						case "LOITER_CCW": { ["LOITER", "CIRCLE_L", "LOITER", ""] };
						case "CYCLE":      { ["CYCLE",  "CIRCLE",   "CYCLE",  ""] };
						case "LAND":       { ["MOVE",   "CIRCLE",   "LAND",   "(vehicle this) land 'LAND'"] };
						default { [] };
					};

					if (_cfg isNotEqualTo []) then {
						_cfg params ["_engineType", "_loiterType", "_queueType", "_statement"];
						private _loiterRadius = 300;

						_wp setWaypointType _engineType;
						_wp setWaypointStatements ["true", _statement];   // also clears an old Land statement

						if (_engineType == "LOITER") then {
							_wp setWaypointLoiterType _loiterType;
							_wp setWaypointLoiterRadius _loiterRadius;
						};

						private _i = _queue findIf { (_x select 0) == _wpIdx };
						if (_i != -1) then {
							_queue set [_i, [_wpIdx, (_queue select _i) select 1, _queueType, _loiterType, _loiterRadius]];
						};
					};
				};

				// Broadcast so every client draws the updated plan.
				_uav setVariable ["RQ4Tweak_waypointQueue", _queue, true];
			};

			// Hide right away so it vanishes even if the delete below were to fail, then delete on the next step.
			_menuCtrl ctrlShow false;
			[_menuCtrl] spawn {
				disableSerialization;
				params ["_m"];
				if (not isNull _m) then { ctrlDelete _m; };
			};
		}];
	};
}];

/////////////////////////////////////
// Waypoint click EH
/////////////////////////////////////

private _wptClickEH = addMissionEventHandler ["MapSingleClick", {
	params ["_units", "_pos", "_altKey", "_shift"];

	private _display = findDisplay 1250;
	private _gh = getConnectedUAV player;

	if ( (isNull _display) or {isNull _gh} ) exitWith {};

	// Shift = replace everything, Ctrl = add to the queue. Shift wins if both are held.
	private _ctrlHeld = _display getVariable ["RQ4Tweak_ctrlHeld", false];
	if ( not (_shift or _ctrlHeld) ) exitWith {};

	private _grp = group driver _gh;
	if (isNull _grp) exitWith {};

	private _flightAlt = _gh getVariable ["RQ4Tweak_flightAltitudeASL", 4000];
	private _queue = _gh getVariable ["RQ4Tweak_waypointQueue", []];

	private _append = (not _shift) and {_queue isNotEqualTo []};

	if (not _append) then {
		for "_i" from ((count waypoints _grp) - 1) to 0 step -1 do {
			deleteWaypoint [_grp, _i];
		};
		_queue = [];
	};

	private _goToWP = _grp addWaypoint [_pos, -1];
	_goToWP setWaypointType "MOVE";

	// Only a replacing click takes over as the active waypoint; queued ones wait their turn.
	if (not _append) then { _grp setCurrentWaypoint _goToWP; };

	_gh flyInHeightASL [_flightAlt, _flightAlt, _flightAlt];

	// Store the waypoint's index (not its group handle) so the shared data stays simple.
	_queue pushBack [_goToWP select 1, _pos, "MOVE", "CIRCLE", 300];

	// Broadcast (and JIP-sync) so every client, and any future pilot, sees the same flight plan.
	_gh setVariable ["RQ4Tweak_waypointQueue", _queue, true];
}];

/////////////////////////////////////
// Keep the queue pruned until the GUI is closed
/////////////////////////////////////

while { not isNull (findDisplay 1250) } do {
	call _pruneQueue;
	sleep 0.25;
};

/////////////////////////////////////
// Cleanup the EHs once the GUI is closed
/////////////////////////////////////

removeMissionEventHandler ["MapSingleClick", _wptClickEH];