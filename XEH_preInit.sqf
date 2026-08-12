private _modName = "USAF RQ-4 Tweak";

[
	"MM_RQ4_RangesSimple",
	"CHECKBOX",
	["Standardized radar ranges (RECOMMENDED)","ENABLING THIS SETTING OVERWRITES ALL RANGE INPUTS! Sets all radar ranges to the most balanced ranges,
	making the RQ-4 extremely useful but not TOO overpowered.
	S1: 1000 - 2900 m, S2: 3000 - 5999 m, S3: 6000 - 12000 m"],
	[_modName, "Radar Ranges"],
	true,
	1,
	{},
	true
] call CBA_fnc_addSetting;

[
	"MM_RQ4_Ranges_S1_Min",
	"EDITBOX",
	"Sector 1 low-end range [meters]",
	[_modName, "Radar Ranges"],
	"1000",
	1,
	{},
	true
] call CBA_fnc_addSetting;

[
	"MM_RQ4_Ranges_S1_Max",
	"EDITBOX",
	"Sector 1 high-end range [meters]",
	[_modName, "Radar Ranges"],
	"2999",
	1,
	{},
	true
] call CBA_fnc_addSetting;

[
	"MM_RQ4_Ranges_S2_Min",
	"EDITBOX",
	"Sector 2 low-end range [meters]",
	[_modName, "Radar Ranges"],
	"3000",
	1,
	{},
	true
] call CBA_fnc_addSetting;

[
	"MM_RQ4_Ranges_S2_Max",
	"EDITBOX",
	"Sector 2 high-end range [meters]",
	[_modName, "Radar Ranges"],
	"5999",
	1,
	{},
	true
] call CBA_fnc_addSetting;

[
	"MM_RQ4_Ranges_S3_Min",
	"EDITBOX",
	"Sector 3 low-end range [meters]",
	[_modName, "Radar Ranges"],
	"6000",
	1,
	{},
	true
] call CBA_fnc_addSetting;

[
	"MM_RQ4_Ranges_S3_Max",
	"EDITBOX",
	"Sector 3 high-end range [meters]",
	[_modName, "Radar Ranges"],
	"12000",
	1,
	{},
	true
] call CBA_fnc_addSetting;

// ---- Radar control
[
	"MM_RQ4_SlewTime",
	"SLIDER",
	["Radar slew time [seconds]","Sets the amount of time it takes for the radar to switch from one side of the aircraft
	to the other. During the transition to the new side, the radar will continue to collect on its current side."],
	[_modName, "Radar Control"],
	[0, 60, 10, 0, false],
	1,
	{},
	true
] call CBA_fnc_addSetting;

[
	"MM_RQ4_StartSlew",
	"LIST",
	["Radar start slew","Determines the default side the radar will be looking when a new aircraft is spawned in."],
	[_modName, "Radar Control"],
	[[1,0], ["Left", "Right"], 0],
	1,
	{},
	true
] call CBA_fnc_addSetting;

// ---- Radar performance
[
	"MM_RQ4_DetectInfantry",
	"CHECKBOX",
	["Detect infatry","Makes the RQ-4 overpowered as hell and will absolutely clutter your map on bigger,
	missions. Not recommended, but it's your jet."],
	[_modName, "Radar Performance"],
	false,
	1,
	{},
	false
] call CBA_fnc_addSetting;

[
	"MM_RQ4_Min_Altitude",
	"EDITBOX",
	["Minimum collection altitude [m]","If the aircraft is below this altitude, MTI cannot be collected."],
	[_modName, "Radar Performance"],
	"4000",
	1,
	{},
	true
] call CBA_fnc_addSetting;

[
	"MM_RQ4_Min_Speed",
	"EDITBOX",
	"Target minimum speed for detection [km/h]",
	[_modName, "Radar Performance"],
	"10",
	1,
	{},
	false
] call CBA_fnc_addSetting;

[
	"MM_RQ4_Max_Speed",
	"EDITBOX",
	"Target maximum speed for detection [km/h]",
	[_modName, "Radar Performance"],
	"200",
	1,
	{},
	false
] call CBA_fnc_addSetting;

[
	"MM_RQ4_Update_Rate",
	"EDITBOX",
	"Radar update rate [seconds]",
	[_modName, "Radar Performance"],
	"5",
	1,
	{},
	false
] call CBA_fnc_addSetting;

[
	"MM_RQ4_PoD_S1",
	"SLIDER",
	["Sector 1 coefficient of probability of detect","This value controls the chance a target that is spotted by the radar is actually 'disseminated' 
	and displayed on the map. Higher value = better chance of detect."],
	[_modName, "Radar Performance"],
	[0.01, 1.00, 0.90, 2, false],
	1,
	{},
	false
] call CBA_fnc_addSetting;

[
	"MM_RQ4_PoD_Error_S1",
	"EDITBOX",
	["Sector 1 coefficient of PoD error", "(Recommend you DON'T touch this) A small correction factor that adds some randomness into the placement of TOI markers. 
	Lower numbers = map marks will be closer to TOIs actual position."],
	[_modName, "Radar Performance"],
	["0.001"],
	1,
	{},
	false
] call CBA_fnc_addSetting;

[
	"MM_RQ4_PoD_S2",
	"SLIDER",
	["Sector 2 coefficient of probability of detect",""],
	[_modName, "Radar Performance"],
	[0.01, 1.00, 0.75, 2, false],
	1,
	{},
	false
] call CBA_fnc_addSetting;

[
	"MM_RQ4_PoD_Error_S2",
	"EDITBOX",
	["Sector 2 coefficient of PoD error", ""],
	[_modName, "Radar Performance"],
	["0.005"],
	1,
	{},
	false
] call CBA_fnc_addSetting;

[
	"MM_RQ4_PoD_S3",
	"SLIDER",
	["Sector 3 coefficient of probability of detect",""],
	[_modName, "Radar Performance"],
	[0.01, 1.00, 0.50, 2, false],
	1,
	{},
	false
] call CBA_fnc_addSetting;

[
	"MM_RQ4_PoD_Error_S3",
	"EDITBOX",
	["Sector 3 coefficient of PoD error", ""],
	[_modName, "Radar Performance"],
	["0.015"],
	1,
	{},
	false
] call CBA_fnc_addSetting;

// ---- Psuedo-DGS settings
[
	"MM_RQ4_Recipient_Items",
	"EDITBOX",
	["Item(s) Needed to Receive TOIs", "Classnames of the items the player must have to receive MTI TOIs from the aircraft, separated by comma.
	The player connected to the UAV does NOT need this item to see the TOIs."],
	[_modName, "Psuedo-DGS"],
	"ItemGPS",
	1,
	{},
	true
] call CBA_fnc_addSetting;

[
	"MM_RQ4_Fade_Time",
	"EDITBOX",
	["Time to fade out unseen TOIs [seconds]", "Time it takes for a TOI to completely fade off the map. Fading begins the moment a target goes 
	unseen by the radar and ends if the target is relocated."],
	[_modName, "Psuedo-DGS"],
	"20",
	1,
	{},
	false
] call CBA_fnc_addSetting;

[
	"MM_RQ4_TOI_Forget_Time",
	"EDITBOX",
	["Time TOI must be unseen to be forgotten [seconds]", "When DGS 'forgets' a TOI, the target will be assigned a new TOI number when it is reacquired. 
	The 'forget' countdown begins after the target fades off the map."],
	[_modName, "Psuedo-DGS"],
	"20",
	0,
	{},
	true
] call CBA_fnc_addSetting;

[
	"MM_RQ4_TOI_Num",
	"EDITBOX",
	"Starting number for TOI marker naming",
	[_modName, "Psuedo-DGS"],
	"000",
	1,
	{},
	true
] call CBA_fnc_addSetting;