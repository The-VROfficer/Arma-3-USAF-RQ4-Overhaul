/*
	Author: Waylen

    Locality: Server

	Description:		


	Parameter(s):
		0: <BOOLEAN> Desired MTI state. False = RRCA, True = GRCA, with RRCA as default. 

	Returns:
		Nothing.

	Examples:
		[true] spawn MM_fnc_toggleMTIMode;

	NOTE - I foresee having to add some extra param for a specific aircraft
*/

params [
    ["_MTIMode", false, [objNull]]
];

// tracked by RQ4Tweak_mtiMode