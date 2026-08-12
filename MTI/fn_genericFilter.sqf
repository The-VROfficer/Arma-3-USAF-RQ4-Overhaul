/*
	Author: Myth

    Locality: Server.

	Description:
		Filters out dead, animals, model-hidden, mounted, LOS-blocked, too fast/slow, and out of FoR limits targets. Returns filtered list to MM_fnc_radarScan.

	Parameter(s):
		0: <OBJECT> - The AV that is performing the scan.
		1: <ARRAY> - The objects to be filtered, passed by MM_fnc_radarScan.

	Returns:
		Array of arrays - The objects that qualify to become MTI targets.

	Examples:
		[myGlobalHawk, [car_1, myPlane, mrAnderson]] spawn MM_fnc_genericFilter
*/















// Disqualify targets in sensor blindspots (nose and tail)
if (
	((_gh getRelDir _x) > (LFOVFront) and ((_gh getRelDir _x) < (RFOVFront)))   // Targets in the nose blindspot
	or
	((_gh getRelDir _x) > (LFOVRear) and ((_gh getRelDir _x) < (RFOVRear)))   // Targets in the tail blindspot
) then {

};