/*
	Author: Waylen

	Locality: local

	Description: State machine to handle FOR button state and I HAVE A BONAR fuck u man middlefinger
		
	Parameter(s):
		None.

	Returns: Nothing.
		

	Examples:
		[] call MM_fnc_toggleFOR;
*/

private _uav = getConnectedUAV player;
if (isNull _uav) exitWith {};

// turn on FOR case
if ( (_uav getVariable ["RQ4Tweak_forEH_guiMap", []]) isEqualTo [] ) then {

    ctrlSetText [1606, "Field of Regard: On"];
    [_uav, true] spawn MM_fnc_handleFOR;

} else { // turn off FOR case; FOR already off

    ctrlSetText [1606, "Field of Regard: Off"];
    [_uav, false] spawn MM_fnc_handleFOR;

};