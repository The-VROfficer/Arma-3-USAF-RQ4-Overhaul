/*
	Author: Seb (from Seb's Briefing Table [https://steamcommunity.com/sharedfiles/filedetails/?id=2422853226]), modified by Myth.

    Locality: Local, executed on the pilot's computer.

	Description:
		Performs the calculation, rendering, and disposal and cleanup of the SAR image.

	Parameter(s):
		0: <MARKER> - The square, 200x200m marker passed by fn_selectSAR. This marker defines the dimensions of the SAR.
        1: <OBJECT> - The AV taking the SAR.
        2: <NUMBER> - (optional, default 0.2) The threshold of visibility. Anything tile of terrain below this value will be "dropped".

	Returns:
		None.

	Examples:
		["mySARArea", myGH, 0.42] spawn MM_fnc_doSAR
*/

scopeName "RQ4_doSAR";  // Named so the kill switch can breakOut of the nested loops.

params [
    "_marker",
    "_av",
    ["_visThreshold", 0.2]
];

if !(hasInterface) exitWith {};

// Kill switch: armed only if the GUI (IDD 1250) is open when we start. If the user closes it mid-render, the process is aborted.
private _killSwitchArmed = not isNull (findDisplay 1250);

private _table = createVehicleLocal ["Land_VR_Shape_01_cube_1m_F", [0, 0, 5000]];
private _backing = createVehicleLocal ["Land_VR_Block_03_F", [0, 0, 5000]];
private _light = createVehicleLocal ["Reflector_Cone_01_wide_white_F", [0, 0, 5005]];
missionNamespace setVariable ["RQ4Tweak_table_base", [_table, _backing, _light]];

_backing setObjectTexture [0, "#(rgb,8,8,3)color(0,0,0,1)"];
_backing setObjectTexture [1, "#(rgb,8,8,3)color(0,0,0,1)"];
_backing attachTo [_table, [0, 0, -2.475]];

_light setPosASL ((getPosASLVisual _table) vectorAdd [0, 0, 5]);
_light setVectorDirAndUp [[0, 0, -1], [0, 1, 0]];   // pointing straight down

private _display = findDisplay 1250;
if (isNull _display) exitWith {};
private _terrainResolution = round (sliderPosition (_display displayCtrl 1630));

private _scaleMultiplier = 2;
private _useTerrainHeight = true;

missionNamespace setVariable ["RQ4Tweak_sarRunning", "RUNNING"];

if (isNil "_table" || {
    isNull _table || {
        _marker == "" || {
            private _temp = createMarkerLocal [_marker, [0,0,0]]; 
            deleteMarkerLocal _temp; 
            _temp != "" //a duplicate marker should fail; otherwise this marker didn't exist at all
        }
    }
}) exitWith {};

// Returns true if the ray is blocked by terrain or by anything that is NOT a tree/rock-type map object.
private _fnc_radarBlocked = {
    params ["_from", "_to", "_ign1", "_ign2"];

    // Hills and ground block the view outright.
    if ( terrainIntersectASL [_from, _to] ) exitWith { true };

    // Otherwise look at every object the ray passes through.
    private _hits = lineIntersectsSurfaces [_from, _to, _ign1, _ign2, true, -1, "VIEW", "NONE"];
    private _blocking = _hits select {
        private _obj = _x select 2;
        isNull _obj || { typeOf _obj != "" }   // keep terrain hits and classed objects; drop classless map objects
    };

    count _blocking > 0
};

_table enableSimulation false;
private _tableObjects = [];

private _bbr = 2 boundingBoxReal _table;
private _p1 = _bbr#0;
private _p2 = _bbr#1;
private _tableWidth = abs ((_p2#0) - (_p1#0));
private _tableLength = abs ((_p2#1) - (_p1#1));
private _tableHeight = abs ((_p2#2) - (_p1#2));

private _markerDir = markerDir _marker;
private _markerPos = getMarkerPos _marker;
private _markerSize = getMarkerSize _marker;
private _maxSize = _markerSize#0 max _markerSize#1; // longest edge of marker
_marker setMarkerSize [_maxSize, _maxSize]; // Marker must be square

private _tableDir = getDir _table;
private _tableSize = ((_tableWidth min _tableLength) / 2) * _scaleMultiplier * 0.9;    // Gets shortest edge of table. Why do I have to divide by 2???????????????
private _scale = _tableSize/_maxSize; // fit longest edge of marker on table

private _squareDist = sqrt (2*_maxSize*_maxSize);
private _objects = (nearestTerrainObjects [_markerPos, [],  _squareDist, false, true]) inAreaArray _marker; // Terrian objects
_objects append ((_markerPos nearObjects ["Static", _squareDist]) inAreaArray _marker); // Will pick up custom placed objects, but contains duplicates from above

_objects append ((_markerPos nearObjects ["LandVehicle", _squareDist]) inAreaArray _marker);
_objects append ((_markerPos nearObjects ["Air", _squareDist]) inAreaArray _marker);
_objects append ((_markerPos nearObjects ["Ship", _squareDist]) inAreaArray _marker);

private _uniqueObjects = [];
private _seenObjects = createHashMap;
{
    private _key = str _x;

    if (isNil {_seenObjects get _key}) then {
        _seenObjects set [_key, true];
        _uniqueObjects pushBack _x;
    };
} forEach _objects;
_objects = _uniqueObjects;

private _dummy = "Land_HelipadEmpty_F" createVehicleLocal _markerPos;
_markerPos set [2, (0 max getTerrainHeightASL _markerPos) + 1];
_dummy enableSimulation false;
_dummy setPosASL _markerPos;
_dummy setDir _markerDir;

// Radar shadow setup. Place the sensor along the real AV->scene bearing, capped at a ray length checkVisibility can reasonably handle.
private _sensorPos = [];
if ( not isNull _av ) then {
    private _toAV = (getPosASL _av) vectorDiff _markerPos;   // _markerPos is already ASL (see line 74)
    private _maxRay = 4000;                                    // metres; tune this
    _sensorPos = _markerPos vectorAdd ((vectorNormalized _toAV) vectorMultiply ((vectorMagnitude _toAV) min _maxRay));
};

// Kill switch helpers.
private _fnc_killRequested = { (_killSwitchArmed and { isNull (findDisplay 1250) }) or not ((getConnectedUAV player) getVariable ["RQ4Tweak_sensorOn", false]) };   // If user closes the GUI or the AV's sensor turns off, stop script.

// Deletes everything this run created and resets state so a new SAR can be started. Must be called from a scheduled context (it sleeps).
private _fnc_abortSAR = {
    hintSilent "";

    // Delete the cubes and scaled objects in batches so the client does not freeze.
    {
        deleteVehicle _x;
        if ( (_forEachIndex + 1) % 250 == 0 ) then { sleep 0.01 };
    } forEach _tableObjects;
    _tableObjects resize 0;

    // Helper objects.
    deleteVehicle _dummy;
    detach _backing;
    deleteVehicle _backing;
    deleteVehicle _table;
    deleteMarkerLocal _marker;

    // Reset state.
    missionNamespace setVariable ["RQ4Tweak_sarRunning", nil];
    missionNamespace setVariable ["RQ4Tweak_table_base", nil];
};

private _zOffset = if (_useTerrainHeight) then {
    private _minHeight = 100000;
    {
        _minHeight = _minHeight min (getPosASL _x)#2;
    } forEach _objects;
    (getPosASL _dummy#2) - _minHeight
} else {
    0
};
private _vectorDiff = [0, 0, _tableHeight/2 + (_zOffset * _scale) + 0.05]; // neatly fit all the stuff on the top of the table

hintSilent parseText "<t font='PuristaBold'>SAR Progress</t><br /><br />Initializing.";

// Config counter.
private _objIter = 0;
private _totalIters = count _objects;
{
    if ( call _fnc_killRequested ) then {
        call _fnc_abortSAR;
        breakOut "RQ4_doSAR";
    };
    private _model = (getModelInfo _x)#1;
    if (_model != "" && !(isObjectHidden _x) && {(((boundingBoxReal  _x)#2) * _scale * getObjectScale _x ) > 0.005}) then {

        private _visible = true;

        if (_sensorPos isNotEqualTo []) then {
            private _target = (getPosASL _x) vectorAdd [0, 0, 1];
            private _vis = [_av, "VIEW", _x] checkVisibility [_sensorPos, _target];

            if (_vis < _visThreshold) then {
                _visible = not (
                    [_sensorPos, _target, _av, _x] call _fnc_radarBlocked
                );
            };
        };

        if (_visible) then {
            isNil {
                private _relCentre = _dummy worldToModel (ASLtoAGL getPosWorld _x);
                private _relVectDir = _dummy vectorWorldToModel (vectorDir _x);
                private _relVectUp = _dummy vectorWorldToModel (vectorUp _x);
                private _tableObj = if ( _x isKindOf "AllVehicles" ) then {
                    createSimpleObject [typeOf _x, [0, 0, 0], true];	// Syntax 2, class name, has texturing.
                } else {
                    createSimpleObject [_model, [0, 0, 0], true];	// Syntax 1, .p3d, no texturing.
                };
                private _scaledPos = _relCentre vectorMultiply _scale;
                private _newPos = if (_useTerrainHeight) then {(_table modelToWorldWorld (_scaledPos vectorAdd _vectorDiff))}
                else
                {_table modelToWorldWorld (_scaledPos vectorAdd _vectorDiff)}; 
                _tableObj setPosWorld _newPos;
                _tableObj setVectorDirAndUp [_table vectorModelToWorld _relVectDir, _table vectorModelToWorld _relVectUp];
                if ( _x isKindOf "AllVehicles" ) then {
                    for "_i" from 0 to 10 do {
                        _tableObj setObjectTexture [_i, "#(rgb,8,8,3)color(0.9,0,0.75,1)"];
                    };
                };
                _tableObj setObjectScale _scale * getObjectScale _x;
                _tableObjects pushBack _tableObj;
            };
        };
    };

    // Iterate counter.
    _objIter = _objIter + 1;
    private _pctDone = (round ((_objIter / _totalIters) * 100)) min 100;
    hintSilent parseText format ["<t font='PuristaBold'>SAR Progress</t><br /><br />Scanning - %1%% Complete.", _pctDone];
} forEach _objects;


private _step = 2/_terrainResolution;
private _dirAndUp = [vectorDir _table, vectorUp _table];

// Add progress tracker.
private _totalCells = (_terrainResolution + 1) ^ 2;
private _cellsDone = 0;
private _lastPct = -1;

for "_xIndex" from 0 to _terrainResolution do {
    private _posX = -1 + (_xIndex * _step);

    for "_yIndex" from 0 to _terrainResolution do {
        private _posY = -1 + (_yIndex * _step);

        if ( call _fnc_killRequested ) then {
            call _fnc_abortSAR;
            breakOut "RQ4_doSAR";
        };

        isNil {
            private _tablePos = [_posX * _tableSize, _posY * _tableSize, 0];
            private _worldPos = (_dummy modelToWorld (_tablePos vectorMultiply 1/_scale)); // divide by scale to scale back up

            private _visible = true;
            if ( _sensorPos isNotEqualTo [] ) then {
                private _groundASL = [_worldPos#0, _worldPos#1, ((getTerrainHeightASL _worldPos) max 0) + 1];
                private _vis = [_av, "VIEW", objNull] checkVisibility [_sensorPos, _groundASL];

                if ( _vis < _visThreshold ) then {
                    _visible = not ([_sensorPos, _groundASL, _av, objNull] call _fnc_radarBlocked);
                };
            };
            if ( not _visible ) exitWith {};   // radar shadow: skip this cubee

            private _road = roadAt (_worldPos select [0,2]);
            private _texture = if (!isNull _road) then {getRoadInfo _road select 3} else {surfaceTexture _worldPos};
            private _normal = vectorUp _table;
            private _cubeSize = _step * _tableSize;
            
            private _averageStep = _step / 2;
            // Sample four corners of the cube.
            {
                _normal = _normal vectorAdd (surfaceNormal (_worldPos vectorAdd _x));
            } forEach [
                [-_averageStep, -_averageStep],
                [-_averageStep,  _averageStep],
                [ _averageStep, -_averageStep],
                [ _averageStep,  _averageStep]
            ];
            _normal = [_normal, _tableDir - _markerDir, 2] call BIS_fnc_rotateVector3D;
            private _cos = abs (vectorUp _table vectorCos _normal);
            private _dynamicSize = 1.1 / _cos;
            _cubeSize = _cubeSize * _dynamicSize;
            _tablePos set [2, -(_worldPos#2 * _scale + _cubeSize/(2*_cos) + 0.5)];

            private _groundObject = createSimpleObject ["Land_VR_Shape_01_cube_1m_F", [0,0,0], true];
            _groundObject enableSimulation false;
            _groundObject setPosASL (_table modelToWorldWorld (_tablePos vectorAdd _vectorDiff));
            _groundObject setVectorDirAndUp _dirAndUp;
            _groundObject setVectorUp _normal;
            for "_selection" from 0 to 6 do {
                _groundObject setObjectMaterial [_selection, "\a3\data_f\default.rvmat"];
                _groundObject setObjectTexture [_selection, _texture];
            };
            _groundObject setObjectScale _cubeSize;
            _tableObjects pushBack _groundObject;
        };

        _cellsDone = _cellsDone + 1;
        private _pct = (round ((_cellsDone / _totalCells) * 100)) min 100;
        if ( _pct != _lastPct ) then {
            _lastPct = _pct;
            hintSilent parseText format ["<t font='PuristaBold'>SAR Progress</t><br /><br />Rendering - %1%% Complete.", _pct];
        };
    };
};

_table setVariable ["RQ4Tweak_table_tableObjects", _tableObjects];
deleteVehicle _dummy;


if ( call _fnc_killRequested ) then {
    call _fnc_abortSAR;
    breakOut "RQ4_doSAR";
};

/////////////////////////////////////
// Create camera and camera effects
/////////////////////////////////////

private _targetASL = _table modelToWorldWorld _vectorDiff;

private _camHeight = 2;
private _camBack   = 0.25;

private _camASL = _targetASL vectorAdd [
    (sin (_tableDir + 180)) * _camBack,
    (cos (_tableDir + 180)) * _camBack,
    _camHeight
];

if ( (str findDisplay 1250) != "No display" ) then {
    missionNamespace setVariable ["RQ4Tweak_displayWasOpen", true];
};

private _sarCam = "camera" camCreate (ASLToAGL _camASL);
_sarCam cameraEffect ["INTERNAL", "BACK"];
_sarCam camSetPos (ASLToAGL _camASL);
_sarCam camSetTarget (ASLToAGL _targetASL);
_sarCam camSetFocus [-1, -1];
_sarCam camSetFov 0.4;
_sarCam camCommit 0;
missionNamespace setVariable ["RQ4Tweak_sarCamera", _sarCam];

showCinemaBorder false;
enableEnvironment false;
closeDialog 2;

private _fnc_createPP = {
    params ["_name", "_priority"];
    private _handle = -1;
    while { _handle = ppEffectCreate [_name, _priority]; _handle < 0 } do { _priority = _priority + 1; };
    _handle
};

RQ4Tweak_sarCC = ["ColorCorrections", 1500] call _fnc_createPP;
RQ4Tweak_sarBlur = ["DynamicBlur", 400] call _fnc_createPP;
RQ4Tweak_sarGrain = ["FilmGrain", 2000] call _fnc_createPP;

RQ4Tweak_sarCC ppEffectEnable true; 
RQ4Tweak_sarCC ppEffectAdjust [1.0, 1.0, 0, [0,0,0,0], [1,1,1,0], [0.4, -0.5, 0.7, 0]];
RQ4Tweak_sarCC ppEffectCommit 0;
RQ4Tweak_sarCC ppEffectForceInNVG true;
 
RQ4Tweak_sarBlur ppEffectEnable true;
RQ4Tweak_sarBlur ppEffectAdjust [0.15];
RQ4Tweak_sarBlur ppEffectCommit 0;
RQ4Tweak_sarBlur ppEffectForceInNVG true;

RQ4Tweak_sarGrain ppEffectEnable true;
RQ4Tweak_sarGrain ppEffectAdjust [0.5, 0.8, 1.5, 2, 1];
RQ4Tweak_sarGrain ppEffectCommit 0;  
RQ4Tweak_sarGrain ppEffectForceInNVG true;

/////////////////////////////////////
// Create event handler to exit SAR camera
/////////////////////////////////////

deleteMarkerLocal _marker;

private _RQ4Tweak_sarKeyEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];

    if ( _key != 45 or _shift or _ctrl or _alt ) exitWith { false };   // 45 = X key

    _display displayRemoveEventHandler ["KeyDown", _thisEventHandler];
    _RQ4Tweak_sarKeyEH = nil;

	_sarCam = missionNamespace getVariable ["RQ4Tweak_sarCamera", []];
    if ( _sarCam isNotEqualTo [] ) then {
        _sarCam cameraEffect ["terminate", "back"];
        camDestroy _sarCam;
    };
    missionNamespace setVariable ["RQ4Tweak_sarCamera", nil];

    // If display was open before the SAR was rendered, reopen it.
    if ( missionNamespace getVariable ["RQ4Tweak_displayWasOpen", false] ) then {
        missionNamespace setVariable ["RQ4Tweak_displayWasOpen", nil];
        [] call MM_fnc_openDialog;
    };

    // Turn the SAR post-processing off again.
    { _x ppEffectEnable false; ppEffectDestroy _x; } forEach [RQ4Tweak_sarCC, RQ4Tweak_sarBlur, RQ4Tweak_sarGrain];

	// Clear and delete the diorama. Stagger deletion so it doesn't freeze client's computer.
	missionNamespace setVariable ["RQ4Tweak_sarRunning", "CLEANUP"];

	[] spawn {
        private _table = (missionNamespace getVariable "RQ4Tweak_table_base") select 0;
        private _tableObjects = _table getVariable ["RQ4Tweak_table_tableObjects", []];

        private _count = count _tableObjects;
        private _firstBatch = round (_count * 0.25);

        sleep 1.5;

        // Delete first batch.
        for "_i" from 0 to (_firstBatch - 1) do {
            deleteVehicle (_tableObjects select _i);

            if ((_i + 1) % 250 == 0) then {
                sleep 0.01;
            };
        };

        // Delete remaining objects.
        for "_i" from _firstBatch to (_count - 1) do {
            deleteVehicle (_tableObjects select _i);

            if ((_i - _firstBatch + 1) % 250 == 0) then {
                sleep 0.01;
            };
        };

        _table setVariable ["RQ4Tweak_table_tableObjects", nil];
        missionNamespace setVariable ["RQ4Tweak_sarRunning", nil];
    };

    // Delete the display table things.
    {
        detach _x;
        deleteVehicle _x;
    } forEach (missionNamespace getVariable "RQ4Tweak_table_base");

    enableEnvironment true;

    hintSilent "";

    true
}];