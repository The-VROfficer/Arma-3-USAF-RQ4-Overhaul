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

private _id = player getVariable ["RQ4Tweak_gcsAction", -1];

switch ( _mode ) do {
    case "ADD": {
        if ( _id < 0 ) then {
            _id = player addAction [
                "<t font='PuristaSemibold'>Open Global Hawk GCS</t>",
                { [] call MM_fnc_openDialog },
                [], 12, false, true, "",
                " _this == (getConnectedUAV _this) getVariable 'RQ4Tweak_pilot' "
            ];
            player setVariable ["RQ4Tweak_gcsAction", _id];
        };

        // If AV + crew belongs to the server, localize it for better performance/responsiveness.
        if ( not local _gh ) then {
            [_gh, clientOwner] remoteExec ["setOwner", 2];
            [group driver _gh, clientOwner] remoteExec ["setGroupOwner", 2];
        };
    };

    case "REMOVE": {
        private _stillConnected = (not isNull _gh) and { _gh isKindOf "USAF_RQ4B_B40" };

        if ( _id >= 0 and not _stillConnected ) then {
            player removeAction _id;
            player setVariable ["RQ4Tweak_gcsAction", nil];
        };
    };
};