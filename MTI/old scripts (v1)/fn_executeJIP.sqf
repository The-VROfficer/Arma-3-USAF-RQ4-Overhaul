/*
	Author: Myth

	Locality: Local, executed on the JIP player's computer.

	Description:
		Takes data configured in MM_fnc_addToJIP and adds all current GMTI markers to players who have JIP'd.

	Parameter(s):
		0: <OBJECT> - The MTI aircraft that detected/is detecting the targets.
		1: <OBJECT> - The player that just JIP'd.

	Returns:
		0: <BOOLEAN> - Completion flag.

	Examples:
		[] call MM_fnc_executeJIP
*/

params [
	["_gh", objNull, [objNull]],
	["_jipPlayer", objNull, [objNull]]
];

if (didJIP) then {
	hint "GMTI Debug: You are JIP!";

	private _GMTI_JIP_Data = _gh getVariable ["GMTI_JIP_Data", []];
	if ( _JIP_Data isEqualTo [] ) exitWith {};

	for "_i" from 0 to ( count _GMTI_JIP_Data ) - 1 do {
		_GMTI_JIP_Data select _i params ["_GMTI_Marker", "_GH_TOI_Num", "_timeSpotted", "_spottingAircraft", "_target"];

		// ---- Initial marker creation and configuration.
		private _markerName = "GMTI_Marker_" + str _GH_TOI_Num;
		private _GMTI_Marker = createMarkerLocal [_markerName, ((getPos _target) apply {_x * random [1 - parseNumber MM_RQ4_PoD_Error_S2, 1, 1 + parseNumber MM_RQ4_PoD_Error_S2]})];

		_GMTI_Marker setMarkerTypeLocal "n_unknown";

		_GMTI_Marker setMarkerColorLocal "ColorGUER";

		private _Target_Number = format ["TOI %1", _GH_TOI_Num];	// Data such as sector number and time spotted were cut to optimize array size in GMTI_JIP_Data. They will be added once MM_fnc_targetCollection runs again.
		_GMTI_Marker setMarkerTextLocal _Target_Number;

		_GMTI_Marker setMarkerSizeLocal [1 * (sizeOf typeOf _target / 20), 1 * (sizeOf typeOf _target / 20)];

		// ---- Place the marker in its most up-to-date position + fade amount.
		private _currentFade = _target getVariable ["GMTI_Fading", 100];
		_GMTI_Marker setMarkerAlphaLocal _currentFade;
	};

	_jipPlayer setVariable ["GMTI_JIP_Complete", true, true];

	true;
} else {
	hint "GMTI Debug: You are NOT JIP.";

	_jipPlayer setVariable ["GMTI_JIP_Complete", false, true];	// False in this case meaning the player did not JIP.

	false;
};