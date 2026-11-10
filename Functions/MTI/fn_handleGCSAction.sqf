/*
	Author:
		Myth

	Locality:
		Local, the AV pilot's computer.

	Description:
		Handles the adding and removing of the "Open Global Hawk GCS" action on the local client. Prevents duplicate actions.

	Parameter(s):
		0: <STRING> - "ADD" adds the action, "REMOVE" removes it.

	Returns:
		Nothing.
		
	Examples:
		["ADD"] call MM_fnc_handleGCSAction
*/

// ---------------------------------
// Script Start and Setup
// ---------------------------------

#include "..\debug_defines.hpp"
private _curFunc = "MM_fnc_handleGCSAction";

params [
	["_mode", "ADD", [""]]
];

private _gh = getConnectedUAV player;

// DEBUG LVL 3
private _msg = format ["%1: Started - Params: [%2]", _gh, _mode];
DEBUG_RPT(_msg, _curFunc);

// ---------------------------------
// Handle the adding/removing of the action
// ---------------------------------

if ( not hasInterface ) exitWith {
	// DEBUG LVL 2
	private _msg = format ["%1: Passed player is not a player. Exiting.", getConnectedUAV player, _mode];
	ERROR_RPT(_msg, _curFunc);
};

// Removes EVERY "Open Global Hawk GCS" action on the player. Guarantees there is never more than one.
private _fnc_sweep = {
	{
		if ( ((player actionParams _x) select 0) find "Open Global Hawk GCS" >= 0 ) then {
			player removeAction _x;
		};
	} forEach (actionIDs player);

	player setVariable ["RQ4Tweak_gcsAction", nil];
};

switch ( _mode ) do {
    case "ADD": {
        // Clear any existing copies (including strays added by other code), then add exactly one.
        call _fnc_sweep;

        private _id = player addAction [
            "<t font='PuristaSemibold'>Open Global Hawk GCS</t>",
            { [] call MM_fnc_openDialog },
            [], 12, false, true, "",
            " _this == (getConnectedUAV _this) getVariable 'RQ4Tweak_pilot' "
        ];
        player setVariable ["RQ4Tweak_gcsAction", _id];

        // If AV + crew belongs to the server, localize it for better performance/responsiveness.
        if ( not isNull _gh and { not local _gh } ) then {
            [_gh, clientOwner] remoteExec ["setOwner", 2];
            [group driver _gh, clientOwner] remoteExec ["setGroupOwner", 2];
        };
    };

    case "REMOVE": {
        // Exact class match: a B20 must not count as "still connected to a Hawk".
        private _stillConnected = (typeOf _gh) isEqualTo "USAF_RQ4B_B40";

        if ( not _stillConnected ) then {
            call _fnc_sweep;
        };
    };
};
