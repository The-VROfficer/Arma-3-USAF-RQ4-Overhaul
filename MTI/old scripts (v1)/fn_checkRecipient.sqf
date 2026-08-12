/*
	Author: Myth

	Locality: Local, executed on the aircraft.

	Description:
		Checks who on the server and UAV's team has a valid "recipient device" and allows them to receive MTI TOIs on their map.

	Parameter(s):
		0: <OBJECT> - The MTI vehicle to check the team of.

	Returns:
		0: <ARRAY of OBJECTS> - Array of players with valid recipient devices, these players will see the MTI TOIs on the map.

	Examples:
		[myGlobalHawk] call MM_fnc_checkRecipient
*/

params [
	["_gh", objNull, [objNull]]
];

private _recipients = [];
private _uavTerminals = [];

switch (side _gh) do {	// This check ensures that, if you have a UAV terminal, you're only receiving MTI from YOUR side's RQ-4. Would kinda ruin some PvP situations if it didn't, right?
	case west: { _uavTerminals pushBackUnique "B_UavTerminal" };
	case east: { _uavTerminals pushBackUnique "O_UavTerminal" };
	case resistance: { _uavTerminals pushBackUnique "I_UavTerminal"; _uavTerminal pushBackUnique "I_E_UavTerminal" };
	case civilian: { _uavTerminals pushBackUnique "C_UavTerminal" };
};

{
	if ( alive _x ) then {
		private _player = _x;
		private _items = MM_RQ4_Recipient_Items splitString ",";
		private _items = _items + _uavTerminals;

		_check = if ( (count _items - count _uavTerminals) == 1 ) then {		// Only 1 recipient device is defined in the mod options.
			( alive _player ) and ( side _player isEqualTo side _gh ) and ( (_items select 0) in assignedItems _player )
		} else {	// There are multiple recipient devices, so sort through them to find a match.
			( alive _player ) and ( side _player isEqualTo side _gh ) and ( _items findIf { _x in assignedItems _player } != -1 )
		};

		if ( _check ) then {	// Player has a valid recipient device...
			//if ( _player isNotEqualTo (_gh getVariable ["GMTI_Pilot", objNull]) ) then {	// If player is NOT the UAV pilot... (prevents TOI duplication)
				_player setVariable ["GMTI_Recipient", [true, _gh], true];

				_recipients pushBackUnique _player;
			//};
		} else {	// Player does NOT have valid recipient device...
			_player setVariable ["GMTI_Recipient", nil, true];

			if ( not (_player in (_gh getVariable "GMTI_allRecipients")) ) then {
				private _markersToDelete = [];
				{
					if ( "GMTI_Marker_" in _x ) then {
						_markersToDelete pushBackUnique _x;
					};
				} forEach allMapMarkers;
				
				{	// Instantly hides all GMTI markers since selected player has no means of "receiving" them, as they didn't pass the check above.
					[_x, 0] remoteExec ["setMarkerAlphaLocal", _player];	// You can't REMOVE the markers entirely, otherwise they won't come back again (for that player).
				} forEach _markersToDelete;
			};
		};
	};
} forEach allPlayers;

_recipients;