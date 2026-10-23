/*
    Author: Waylen

    Locality: Client

    Description:
        Finds the first LOITER waypoint on the connected aircraft group's
        current or upcoming route. Completed waypoints are skipped so flight
        controls can read or update the next assigned loiter without changing
        the route.

    Parameter(s):
        0: GROUP - Aircraft group whose waypoint route should be searched.

    Returns:
        ARRAY - Waypoint in [group, index] format, or an empty array if no current
        or upcoming LOITER waypoint exists.

    Examples:
        private _loiterWaypoint = [_uavGroup] call MM_fnc_findUpcomingLoiterWaypoint;

    NOTE - This function does not create waypoints or change their type. It only
    returns an existing LOITER waypoint whose index is not before the active one.
*/

params ["_group"];

if (isNull _group) exitWith {[]};

private _waypointList = waypoints _group;
if (_waypointList isEqualTo []) exitWith {[]};

private _currentWaypointIndex = currentWaypoint _group;
private _upcomingLoiterWaypoints = _waypointList select {
    ((_x select 1) >= _currentWaypointIndex) && {(waypointType _x) isEqualTo "LOITER"}
};

_upcomingLoiterWaypoints param [0, []]
