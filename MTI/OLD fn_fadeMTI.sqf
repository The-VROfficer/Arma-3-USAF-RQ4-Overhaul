/*
	Author: Myth

	Locality: Local, executed on the aircraft with embedded remoteExecs.

	Description:
		Checks if the (previously "seen") passed target has begun fading from the map due to not being "seen" by an MTI radar. If the object is "unseen" and meets criteria, begin the fading process.

	Parameter(s):
		0: <OBJECT> - The target to be checked.
		1: <MARKER> - The associated TOI marker to be faded, if necessary.
		2: <OBJECT> - The MTI aircraft that spotted the target.

	Returns:
		BOOLEAN - TRUE if the fading has been started, FALSE if fading was unable to be started or is not applicable.

	Examples:
		[enemyTruck, "GMTI_Marker_69", myGlobalHawk] spawn MM_fnc_fadeMTI
*/

params [
	["_target", objNull, [objNull]],
	["_marker", "", [""]],
	["_gh", objNull, [objNull]]
];

if (not (_marker in allMapMarkers)) exitWith {};	// Quits if script is run on a computer where the passed TOI marker does not exist.

if ( (_target getVariable "GMTI_Marker_Info") isEqualTo [] ) exitWith {
	["RQ-4 GMTI ERROR: Object '%1' (marker '%2') cannot perform the MM_fnc_fadeMTI, it has no GMTI marker info.", _target, _marker] call BIS_fnc_error;

	false;
};

_target setVariable ["GMTI_Fading", 1.0, true];

sleep 5;

private _keepLooping = true;
private _opacityCounter = 1.0;
private _startTime = time;

while { _keepLooping } do {

	private _GMTI_Marker_Info = _target getVariable ["GMTI_Marker_Info", []];

	if (_GMTI_Marker_Info isEqualTo []) exitWith {
		_keepLooping = false;
	};

    if ( time - 6 > (_GMTI_Marker_Info select 2) ) then {
        _opacityCounter = (_opacityCounter - (1 / parseNumber MM_RQ4_Fade_Time)) max 0;
        
		_marker setMarkerAlphaLocal _opacityCounter;
		[_marker, _opacityCounter] remoteExec ["setMarkerAlphaLocal", _gh getVariable ["GMTI_allRecipients", objNull], true];	// This may cause some flickering, remove if problematic...
    
        _target setVariable ["GMTI_Fading", _opacityCounter * 100, true];
    } else {
        _keepLooping = false;
    };

    if ( time > _startTime + parseNumber MM_RQ4_TOI_Forget_Time ) then {
        _keepLooping = false;
    };
	
    sleep 1;
};

private _GMTI_Marker_Info = _target getVariable ["GMTI_Marker_Info", []];	// Redefined because it only existed in the while loop until this point.

//hint format ["Target: %1  |  Time: %2", _target, _GMTI_Marker_Info select 2];

if ( (time - 6) >= (_GMTI_Marker_Info select 2) ) then {	// Fading completed as target was not re-spotted.
    _target setVariable ["GMTI_Fading", 0.0, true];
};

// ---- Implementing TOI "forgetting"
_resetCountdown = parseNumber MM_RQ4_TOI_Forget_Time;

while { (_target getVariable "GMTI_Fading" == 0) and _resetCountdown > 0 } do {
    _resetCountdown = _resetCountdown - 1;
    sleep 1;
};

if ( _resetCountdown <= 0 ) then {		// Passed target has completed fadeout and is forgotten.
    _target setVariable ["GMTI_Marker_Info", nil, true];
   
    _target setVariable ["GMTI_Fading", nil, true];
    
	deleteMarkerLocal _marker;
	[_marker] remoteExec ["deleteMarkerLocal", _gh getVariable ["GMTI_allRecipients", objNull], true];

	// Clear out the JIP data for this target so that it doesn't appear for JIP players.
	private _oldJIPData = _gh getVariable "GMTI_JIP_Data";
	private _newJIPData = _oldJIPData deleteAt (_oldJIPData findIf { _x select 0 isEqualTo _marker });

	_gh setVariable ["GMTI_JIP_Data", _newJIPData, true];
};

// ---- Determine if script was successful
if ( isNil {_target getVariable "GMTI_Fading"} ) exitWith { false };

true