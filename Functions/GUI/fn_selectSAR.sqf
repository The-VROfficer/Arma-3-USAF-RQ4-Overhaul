/*
	Author: Myth

    Locality: Local, executed on the pilot's computer.

	Description:
		Prompts the user to select an area they want to take a SAR of. Passes those map coords to fn_doSAR.

	Parameter(s):
		None.

	Returns:
		None.

	Examples:
		onButtonClick = "[] spawn MM_fnc_selectSAR;";
*/

#include "..\gh_defines.hpp"

private _gh = getConnectedUAV player;

private _sarRunning = missionNamespace getVariable ["RQ4Tweak_sarRunning", []];
if ( _sarRunning isNotEqualTo [] ) exitWith {
	if ( _sarRunning == "RUNNING" ) then {
		systemChat "COMMAND REJECTED - A SAR is being taken.";
	} else {
		hintSilent parseText "<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />The Radar Image Processor is resetting.";
		sleep 5;
		hintSilent "";
	};
};

if ( (isNull _gh) or not (alive _gh) ) exitWith {};

if ( not (_gh getVariable ["RQ4Tweak_sensorOn", false]) ) exitWith {
	hintSilent parseText "<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />The sensor is off.";
	sleep 5;
	hintSilent "";
};

hintSilent parseText "Left click to select the SAR location.<br /><br />Push ESC to cancel.";

private _sarMapClickEH = addMissionEventHandler ["MapSingleClick", {
	params ["_units", "_pos", "_alt", "_shift"];

	private _gh = getConnectedUAV player;
	private _slewSide = _gh getVariable ["RQ4Tweak_slewSide", 0];
	if ( 
		not ( 
			( (_gh getRelDir _pos) >= (BothFOV select _slewSide select 0) )
			and
			( (_gh getRelDir _pos) <= (BothFOV select _slewSide select 1) )
		)
	 ) exitWith {
		[] spawn {
			hintSilent parseText "<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />The selected target is out of the field of regard.";
			sleep 5;
			hintSilent "";
		};

		(findDisplay 1250) displayRemoveEventHandler ["KeyDown", missionNamespace getVariable "RQ4Tweak_escPressEH"];
		removeMissionEventHandler ["MapSingleClick", _thisEventHandler];

		missionNamespace setVariable ["RQ4Tweak_sarMapClickEH", nil];
		missionNamespace setVariable ["RQ4Tweak_escPressEH", nil];
	};

	if ( (_gh distance _pos) > (parseNumber MM_RQ4_Ranges_S3_Max) ) exitWith {
		[] spawn {
			hintSilent parseText "<t font='PuristaBold'>COMMAND REJECTED</t><br /><br />The selected target is out of range.";
			sleep 5;
			hintSilent "";
		};

		(findDisplay 1250) displayRemoveEventHandler ["KeyDown", missionNamespace getVariable "RQ4Tweak_escPressEH"];
		removeMissionEventHandler ["MapSingleClick", _thisEventHandler];

		missionNamespace setVariable ["RQ4Tweak_sarMapClickEH", nil];
		missionNamespace setVariable ["RQ4Tweak_escPressEH", nil];
	};

	private _randName = "sarArea_" + str (floor random 10000);
	private _sarArea = createMarkerLocal [_randName, [0, 0, 0]];
	_sarArea setMarkerPosLocal _pos;
	_sarArea setMarkerShapeLocal "RECTANGLE";
	_sarArea setMarkerSizeLocal [200, 200]; 
	_sarArea setMarkerAlphaLocal 0;

	[_sarArea, _gh, 0.2] spawn MM_fnc_doSAR;

	removeMissionEventHandler ["MapSingleClick", _thisEventHandler];
	(findDisplay 1250) displayRemoveEventHandler ["KeyDown", missionNamespace getVariable "RQ4Tweak_escPressEH"];

	missionNamespace setVariable ["RQ4Tweak_sarMapClickEH", nil];
	missionNamespace setVariable ["RQ4Tweak_escPressEH", nil];
}];

missionNamespace setVariable ["RQ4Tweak_sarMapClickEH", _sarMapClickEH];

// Create the backout action.
private _escPressEH = (findDisplay 1250) displayAddEventHandler ["KeyDown", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];
	if ( _key != 1 or _shift or _ctrl or _alt ) exitWith { false };   // 1 = ESC key

	private _sarMapClickEH = missionNamespace getVariable "RQ4Tweak_sarMapClickEH";

	removeMissionEventHandler ["MapSingleClick", missionNamespace getVariable "RQ4Tweak_sarMapClickEH"];
	(findDisplay 1250) displayRemoveEventHandler ["KeyDown", _thisEventHandler];
	missionNamespace setVariable ["RQ4Tweak_sarMapClickEH", nil];
	missionNamespace setVariable ["RQ4Tweak_escPressEH", nil];

	hintSilent "";

	true
}];

// Needed to delete the escPressEH in sarMapClickEH.
missionNamespace setVariable ["RQ4Tweak_escPressEH", _escPressEH];