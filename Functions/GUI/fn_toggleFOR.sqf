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
if(_uav getVariable ["RQ4Tweak_forEH",[]] isEqualTo []) exitWith {

    ctrlSetText [1606, "Turn FOR Off"];
    [_uav,true] spawn MM_fnc_handleFOR;

}
// turn off FOR case; FOR already off
else {

    ctrlSetText [1606, "Turn FOR On"];
    [_uav,false] spawn MM_fnc_handleFOR;

};

