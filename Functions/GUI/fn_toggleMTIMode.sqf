/*
	Author: Myth

    Locality: Local, Pilot's computer.

	Description:
		Handles the flip flopping of the MTI Mode button on the GUI. Also changes the MTI mode on the AV.

	Parameter(s):
		None.

	Returns:
		Nothing.

	Examples:
		onButtonClick = "[] call MM_fnc_toggleMTIMode;"
*/

private _gh = getConnectedUAV player;
private _currentMode = _gh getVariable ["RQ4Tweak_mtiMode", "RRCA"];

if ( _currentMode isEqualTo "RRCA" ) then {
    (findDisplay 1250 displayCtrl 1603) ctrlSetText "MTI Mode: GRCA";

	_gh setVariable ["RQ4Tweak_mtiMode", "GRCA", true];
} else {
	(findDisplay 1250 displayCtrl 1603) ctrlSetText "MTI Mode: RRCA";

	_gh setVariable ["RQ4Tweak_mtiMode", "RRCA", true];
};