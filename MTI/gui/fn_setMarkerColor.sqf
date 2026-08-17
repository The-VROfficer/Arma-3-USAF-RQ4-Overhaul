/*
	Author: Waylen

    Locality: Server

	Description:		


	Parameter(s):
		0: <ARRAY> Color of marker in RGB format (will almost definitely change).

	Returns:
		Nothing.

	Examples:
		onButtonClick = "[255,255,0] spawn MM_fnc_setMarkerColor;";

	NOTE - I foresee having to add some extra param for a specific aircraft

    todo - make currently set loiter variable
*/

params [
	["_color", [0,255,0], [],[3]]
	];