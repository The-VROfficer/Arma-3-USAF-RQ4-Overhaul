class Extended_PreInit_EventHandlers {
    class createSettings {
		init = " call compile preprocessFileLineNumbers 'x\usaf_rq4a_tweak_v2\XEH_preInit.sqf'; ";
    };
};

class Extended_Init_EventHandlers {
    class USAF_RQ4B_B40 {
		class USAF_RQ4B_handlePilot
		{
			serverInit = " [_this select 0, 0.5] spawn MM_fnc_handlePilot; ";
		};
    };
	class USAF_RQ4B_B20 {
		class USAF_RQ4B_setupBACN
		{
			serverInit = " [_this select 0] call MM_fnc_setupBACN; ";
		};
	};
};