/*
	Author: Myth

	Locality: Local, executed on a player's machine.

	Description:
		Returns the UAV the player is connected to and "attaches" that object name to the player via setVariable.

	Parameter(s):
		None

	Returns:
		0: <BOOLEAN> - Completion flag.

	Examples:
		[] call MM_fnc_checkConnectedPlayer
*/

player setVariable ["GMTI_connectedUAV", getConnectedUAV player, true];

if ( (player getVariable ["GMTI_ConnectedUAV", objNull]) isEqualTo objNull ) then {
	player setVariable ["GMTI_connectedUAV", nil, true];
};

true;