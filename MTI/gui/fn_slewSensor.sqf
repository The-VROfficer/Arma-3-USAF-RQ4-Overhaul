/*
	Author: Waylen

    Locality: Server

	Description:		


	Parameter(s):
		0: <BOOLEAN> Left/right input. false = left, true = right.

	Returns:
		Nothing.

	Examples:
		onButtonClick = "[true] spawn slewSensor;";

	NOTE - I foresee having to add some extra param for a specific aircraft
*/

params [
	["_sensorSide", false, [objNull]]
	];

// later me note; make default value for _sensorSide query MM_RQ4_StartSlew var