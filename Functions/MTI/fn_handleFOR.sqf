/*
	Author: Myth

	Locality: The drone pilot's computer only.

	Description: Handles creation and deletion of a display control event handler which renders the Field of Regard (FOR) on the drone pilot's map.
		

	Parameter(s):
		0: <OBJECT> - The AV to have its FOR handled.
		1: <BOOLEAN> - Create or delete the FOR. True = display it, False = delete it.
		2: <BOOLEAN> - If true, only draws the FOR on the GUI's map and skips the main map.

	Returns: Nothing.
		

	Examples:
		[myGlobalHawk, true] spawn MM_fnc_handleFOR
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#include "..\debug_defines.hpp"
#include "color_defines.hpp"
private _curFunc = "MM_fnc_handleFOR";

params [
	["_gh", objNull, [objNull]],
	["_create", true, [true]],
	["_guiMapOnly", false, [false]]
];

// DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1, %2]", _gh, _create];
DEBUG_RPT(_msg, _curFunc);

// ---------------------------------
// Create protection in case the wrong intent was passed, given the AV's current vars.
// ---------------------------------

private _forEH_guiMap = _gh getVariable ["RQ4Tweak_forEH_guiMap", []];

// Attempted to create FOR, but it's already rendered.
if ( _create and (_forEH_guiMap isNotEqualTo []) and not _guiMapOnly) exitWith {
	// DEBUG LVL 2
	private _msg = format ["%1: Abnormal exit, attempted to draw FOR, but FOR already exists for %1!", _gh];
	ERROR_RPT(_msg, _curFunc);
};

// Attempted to delete FOR, but it doesn't exist.
if ( not _create and (_forEH_guiMap isEqualTo []) ) exitWith {
	// DEBUG LVL 2
	private _msg = format ["%1: Abnormal exit, attempted to delete FOR, but no FOR exists for %1!", _gh];
	ERROR_RPT(_msg, _curFunc);
};

// ---------------------------------
// Evaluate passed params, create/delete the FOR on the map
// ---------------------------------

disableSerialization;

if ( _create ) then {
	private _slewSide = _gh getVariable ["RQ4Tweak_slewSide", 0];
	// Convert color name to RGBA via parseText, which makes it into a macro that is compatible with color_defines.hpp
	private _color = _gh getVariable ["RQ4Tweak_mtiMarkerColor", "ColorWEST"];

	_color = switch ( _color ) do {
		case "ColorUNKNOWN": { ColorUNKNOWN };
		case "ColorGUER": { ColorGUER };
		case "ColorEAST": { ColorEAST };
		case "ColorCIV": { ColorCIV };
		case "ColorWEST": { ColorWEST };
		default { ColorWEST };
	};

	//private _str = format ["[_this select 0, %1, %2, %3, _thisEventHandler] call MM_fnc_drawFOR", _gh, _slewSide, _color];
	private _str = format ["
		private _pos = getPosASLVisual %1;
		private _dist = sqrt((parseNumber MM_RQ4_Ranges_S3_Max)^2) - sqrt((_pos select 2)^2);
		_pos set [2,0];

		private _dir = if (%2 == 0) then {
			(getDir %1) - 90;
		} else {
			(getDir %1) + 90;
		};

		private _vertices = [-45,45]; 

		private _points = [];
		for ""_i"" from -45 to 45 step (45/6) do { 
		_points pushBack _i; 
		};

		_vertices insert [1, _points]; 
		_points = nil; 

		_vertices = [_pos] + (_vertices apply { 
			private _verticePos = _pos getPos [_dist, _dir + _x]; 
			_verticePos set [2 ,0]; 
			_verticePos;
		});

		_control = _this select 0;

		_control drawPolygon [_vertices, %3];
	", _gh, _slewSide, _color];

	// Draw FOR lines on GUI map.
	_forEH_guiMap = (findDisplay 1250 displayCtrl 1801) ctrlAddEventHandler ["Draw", _str];
	_gh setVariable ["RQ4Tweak_forEH_guiMap", [_forEH_guiMap, findDisplay 1250 displayCtrl 1801], true];
	
	if ( not _guiMapOnly ) then {
		// Draw FOR lines on main map.
		_forEH_mainMap = (findDisplay 12 displayCtrl 51) ctrlAddEventHandler ["Draw", _str];
		_gh setVariable ["RQ4Tweak_forEH_mainMap", [_forEH_mainMap, findDisplay 12 displayCtrl 51], true];
	};
	
	// DEBUG LVL 3
	private _msg = format ["%1: Complete, FOR is drawn.", _gh];
	DEBUG_RPT(_msg, _curFunc);

	// Completion flag to show a new FOR was rendered.
	true;
} else {
	(_gh getVariable "RQ4Tweak_forEH_guiMap") params ["_forEH", "_mapCtrl"];

	_mapCtrl ctrlRemoveEventHandler ["Draw", _forEH];

	_gh setVariable ["RQ4Tweak_forEH_guiMap", nil, true];

	// Run the same thing again but modified for main map FOR lines.

	(_gh getVariable "RQ4Tweak_forEH_mainMap") params ["_forEH", "_mapCtrl"];

	_mapCtrl ctrlRemoveEventHandler ["Draw", _forEH];

	_gh setVariable ["RQ4Tweak_forEH_mainMap", nil, true];

	// DEBUG LVL 3
	private _msg = format ["%1: Complete, FOR is deleted.", _gh];
	DEBUG_RPT(_msg, _curFunc);

	// Completion flag to show a existing FOR was deleted.
	false;
};