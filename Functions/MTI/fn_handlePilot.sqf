/*
	Author: Myth

    Locality: Server.

	Description:
		Checks every 0.5s to see if a player has connected/disconnected from the UAV. Adds/removes user actions as appropriate.

	Parameter(s):
		0: <OBJECT> - The AV.
		1: <NUMBER> - The time (in seconds) between checks. Numbers smaller than 1 can have a negative impact on server performace.

	Returns: Nothing.

	Examples:
		[myGlobalHawk] spawn MM_fnc_handlePilot
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_handlePilot";

params [
	["_gh", objNull, [objNull]],
	["_refreshRate", 1, [1]]
];

// DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%1]", _gh];
DEBUG_RPT(_msg, _curFunc);

// ---------------------------------
// Evaluate player connectivity state
// ---------------------------------

while { alive _gh } do {
	private _pilotArr = UAVControl [_gh, "all"];

	// Check if anyone is/was connected. If not, exit. If the previous pilot disconnected from the UAV, clean up their actions.
	private _prevPilot = _gh getVariable "RQ4Tweak_pilot";
	private _grcas = _gh getVariable ["RQ4Tweak_grcas", []];

	if ( count _pilotArr < 1 ) then {
		if ( isNil {_prevPilot} ) then {
			// DEBUG LVL 3
			private _msg = format ["%1: No players have connected to %1 yet. Exiting this iteration.", _gh];
			DEBUG_RPT(_msg, _curFunc);
		} else {
			// Check if RQ4Tweak_pilot var has a pilot in it, this is the most recently disconnected player.
			if ( _prevPilot isEqualTo objNull ) then {
				// DEBUG LVL 3
				private _msg = format ["%1: None connected to %1, no recent disconnected. Exiting this iteration.", _gh];
				DEBUG_RPT(_msg, _curFunc);
			} else {
				// DEBUG LVL 3
				private _msg = format ["%1: None connected to AV %1, %2 recently disconnected, cleaning up their actions and exiting this iteration.", _gh, _prevPilot];
				DEBUG_RPT(_msg, _curFunc);

				// Add code to remove GUI actions HERE
				//

				// Delete all GRCAs and FOR displays, if they exist.
				if ( _grcas isNotEqualTo [] ) then {
					// Check if player is in SP or MP. If SP, DO NOT delete the markers (since client==server), just hide the marker until later.
					if ( hasInterface and isServer ) then {	// This is iffy... would it work on player hosted servers?
						{
							private _boxMarker = _x select 4;
							private _dotMarker = _x select 5;
							
							_boxMarker setMarkerAlphaLocal 0;
							_dotMarker setMarkerAlphaLocal 0;
						} forEach _grcas;
					} else {
						// Add a temp var to the markers that prevents the missionEventHandler in fn_drawGRCA from triggering. This var will be destroyed in aforementioned EH.
						// If this wasn't here, the markers would be deleted on the clientside AND on the server.
						{
							private _boxMarker = _x select 4;
							private _dotMarker = _x select 5;

							private _nameBox = "RQ4Tweak_localDeleteOnly_" + _boxMarker;
							private _nameDot = "RQ4Tweak_localDeleteOnly_" + _dotMarker;
						
							missionNamespace setVariable [_nameBox, true, true];
							missionNamespace setVariable [_nameDot, true, true];

							[_boxMarker] remoteExec ["deleteMarkerLocal", _prevPilot];
							[_dotMarker] remoteExec ["deleteMarkerLocal", _prevPilot];
						} forEach _grcas;
					};
				};

				// Just force turn off the FOR on the client's machine.
				[_gh, false] remoteExec ["MM_fnc_handleFOR", _prevPilot];

				// Define the var as empty so that the rest of the script can see that another player was connected at some point.
				_gh setVariable ["RQ4Tweak_pilot", objNull, true];
			};
		};

		sleep _refreshRate;
		continue;
	};

	private _pilot = _pilotArr select 0;

	// Check if pilot var is empty. If it is, this player is the very first one to connect. Add actions and end this iteration.
	if ( isNil {_prevPilot} ) then {
		_gh setVariable ["RQ4Tweak_pilot", _pilot, true];

		// No need to run the function to add existing GRCAs, there should be none.

		// Add code to add GUI actions HERE
		//

		// DEBUG LVL 3
		private _msg = format ["%1: Player %2 is the first user to connect to %1, adding actions.", _gh, _pilot];
		DEBUG_RPT(_msg, _curFunc);		

		sleep _refreshRate;
		continue;
	};

	// Check if the currently connected pilot is the same as the pilot from the previous check. If so, end this iteration.
	if ( _prevPilot isEqualTo _pilot ) then {
		// DEBUG LVL 3
		private _msg = format ["%1: Player %2 is still connected. Exiting this iteration.", _gh, _pilot];
		DEBUG_RPT(_msg, _curFunc);			
		
		sleep _refreshRate;
		continue;
	};

	// If pilot has made it this far, they are not the first person to connect and/or need actions added to them.
	// DEBUG LVL 3
	private _msg = format ["%1: Player %2 has connected, AV %1 is preowned. Adding actions.", _gh, _pilot];
	DEBUG_RPT(_msg, _curFunc);

	// Add code to render existing GRCAs HERE 
	//

	// Some GRCAs exist, so render them on this new pilots map.
	if ( _grcas isNotEqualTo [] ) then {
		// DEBUG LVL 3
		private _msg = format ["%1: GRCAs exist on AV %1, adding them to player %2's map.", _gh, _pilot];
		DEBUG_RPT(_msg, _curFunc);			
		
		if ( hasInterface and isServer ) then {	// This is iffy... would it work on player hosted servers?
			{
				private _boxMarker = _x select 4;
				private _dotMarker = _x select 5;
				
				_boxMarker setMarkerAlphaLocal 0.3;
				_dotMarker setMarkerAlphaLocal 1;
			} forEach _grcas;
		} else {
			{
				_x params ["_grcaID", "_areaCenterX", "_areaCenterY", "_areaCenterTrue", "_grca", "_bottomRightMarker", "_dotPos"];

				[_grcaID, _areaCenterTrue, _bottomRightMarker, _dotPos] remoteExec ["MM_fnc_readdGRCA", _pilot];
			} forEach _grcas;
		};
	};
	
	// Add code to add GUI actions HERE
	//

	_gh setVariable ["RQ4Tweak_pilot", _pilot, true];

	sleep _refreshRate;
};
