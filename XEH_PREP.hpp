class Extended_PreInit_EventHandlers {
    class createSettings {
		init = " call compile preprocessFileLineNumbers 'x\usaf_rq4a_tweak_v2\XEH_preInit.sqf' ";
    };
};

class Extended_InitPost_EventHandlers {
    class USAF_RQ4B_B40 {
		class USAF_RQ4B_slewSide
		{
			serverInit = "";
		};
    };
	class USAF_RQ4B_B20 {
		class USAF_RQ4B_setupBACN
		{
			serverInit = "[_this select 0] call MM_fnc_setupBACN ";
		};
	};
};