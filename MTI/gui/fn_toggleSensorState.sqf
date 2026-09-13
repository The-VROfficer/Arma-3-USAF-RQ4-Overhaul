/*
	Author: Waylen

    Locality: Server

	Description:		

	Toggle button handler for sensor ON/OFF button; calls external functions and tracks itself.

	Parameter(s):
		0: <BOOLEAN> on/off state for the sensor currently. false = off, true = on.

	Returns:
		Current sensor state, 0 = off, 1 = on.

	Examples:
		onButtonClick = "[RQ4Tweak_sensorOn] spawn MM_fnc_toggleSensorState;";

	NOTE - I foresee having to add some extra param to specify an aircraft
*/

params [
	["_sensorState", false, []]
	];

// DEBUG LVL 3
LOG(format ["MM_fnc_toggleSensorState, %1: Running - Params: %2", _gh, _sensorState]);

if(_sensorState) exitWith
	{
		RQ4Tweak_sensorOn = true;
		_control ctrlSetActiveColor [0,1,0,1];
		_control ctrlSetStructuredText parseText "<t size='0.5'>&#160;</t><br/><t size='1' align='center'>Sensor ON&#160;&#160;</t>";
	};	
else exitWith
	{
		RQ4Tweak_sensorOn = false;
		_control ctrlSetActiveColor [1,0,0,1];
		_control ctrlSetStructuredText parseText "<t size='0.5'>&#160;</t><br/><t size='1' align='center'>Sensor OFF&#160;&#160;</t>";
	};

// this shit DEFINITELY does not work right now lmao