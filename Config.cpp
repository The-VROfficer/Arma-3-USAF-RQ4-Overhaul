class CfgPatches
{
	class usaf_rq4a_tweak_v2
	{
		author="Myth, Waylen, and the USAF Mod Team";
		authorUrl="https://gitlab.com/usaf-a3/usaf-mod";
		units[]=
		{
			"USAF_RQ4B_B40",
			"USAF_RQ4B_B20"
		};
		weapons[]={};
		requiredVersion=2.0;
		requiredAddons[]=
		{
			"usaf_main",
			"usaf_rq4a",
			"cba_xeh"
		};
	};
};

#include "XEH_PREP.hpp"
#include "CfgFunctions.hpp"
#include "CfgVehicles.hpp"
#include "CfgSounds.hpp"
#include "CfgRemoteExec.hpp"
#include "\a3\ui_f\hpp\defineCommonGrids.inc"
#include "Functions\GUI\RscGlobalHawkGUI.hpp"