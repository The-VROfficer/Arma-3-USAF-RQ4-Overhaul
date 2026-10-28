class SensorTemplatePassiveRadar;
class SensorTemplateActiveRadar;
class DefaultVehicleSystemsDisplayManagerLeft
{
	class components;
};
class DefaultVehicleSystemsDisplayManagerRight
{
	class components;
};

class CfgVehicles
{
	class Plane;
	class UAV: Plane
	{
		class NewTurret;
		class ViewPilot;
		class ViewOptics;
		class AnimationSources;
		class Components;
	};
	class USAF_RQ4B_B40: UAV
	{
		author="USAF";
		editorSubcategory="EdSubCat_USAF_Drones";
		editorPreview="USAF_RQ4A\data\UI\preview.jpg";
		displayName="RQ-4B Global Hawk (B40)";
		icon="x\usaf_rq4a_tweak_v2\Icons\rq4_ca.paa";
		picture="\A3\Drones_F\Air_F_Gamma\UAV_02\Data\UI\UAV_02_base_F.paa";
		unitInfoType="RscOptics_AV_airplane_pilot";
		attenuationEffectType="OpenHeliAttenuation";
		_generalMacro="B_UAV_02_F";
		fuelCapacity=1300;
		fuelConsumptionRate=0.398;
		scope=2;
		side=1;
		faction="USAF";
		isUAV = 1;
		crew="B_UAV_AI";
		class Turrets {};
		class Components: Components
		{
			class SensorsManagerComponent
			{
				class Components
				{
					class PassiveRadarSensorComponent: SensorTemplatePassiveRadar
					{
						class AirTarget
						{
							minRange = 32000;
							maxRange = 32000;
							objectDistanceLimitCoef = -1;
							viewDistanceLimitCoef = -1;
						};
						class GroundTarget
						{
							minRange = 32000;
							maxRange = 32000;
							objectDistanceLimitCoef = -1;
							viewDistanceLimitCoef = -1;
						};
					};
					class ActiveRadarSensorComponent: SensorTemplateActiveRadar
					{
						class AirTarget
						{
							minRange = 18000;
							maxRange = 18000;
							objectDistanceLimitCoef = -1;
							viewDistanceLimitCoef = -1;
						};
						class GroundTarget
						{
							minRange = 18000;
							maxRange = 18000;
							objectDistanceLimitCoef = -1;
							viewDistanceLimitCoef = -1;
						};
						angleRangeHorizontal = 360;
						angleRangeVertical = 65;
					};
				};
			};
			class VehicleSystemsDisplayManagerComponentLeft: DefaultVehicleSystemsDisplayManagerLeft
			{
				class components
				{
					class EmptyDisplay
					{
						componentType = "EmptyDisplayComponent";
					};
					class MinimapDisplay
					{
						componentType = "MinimapDisplayComponent";
						resource = "RscCustomInfoMiniMap";
					};
					class SensorDisplay
					{
						componentType = "SensorsDisplayComponent";
						range[] = {16000,8000,4000,32000};
						showTargetTypes = 1+2+4+8+16+32+64+128+256+1024;
						resource = "RscCustomInfoSensors";
					};
				};
			};
			class VehicleSystemsDisplayManagerComponentRight: DefaultVehicleSystemsDisplayManagerRight
			{
				defaultDisplay = "SensorDisplay";
				class components
				{
					class EmptyDisplay
					{
						componentType = "EmptyDisplayComponent";
					};
					class MinimapDisplay
					{
						componentType = "MinimapDisplayComponent";
						resource = "RscCustomInfoMiniMap";
					};
					class SensorDisplay
					{
						componentType = "SensorsDisplayComponent";
						range[] = {16000,8000,4000,32000};
						showTargetTypes = 1+2+4+8+16+32+64+128+256+1024;
						resource = "RscCustomInfoSensors";
					};
				};
			};
		};
		typicalCargo[]=
		{
			"B_UAV_AI"
		};
		accuracy=1;
		soundGetIn[]=
		{
			"",
			0.56234097,
			1
		};
		soundGetOut[]=
		{
			"",
			0.56234097,
			1,
			40
		};
		soundDammage[]=
		{
			"",
			0.56234133,
			1
		};
		soundEngineOnInt[]=
		{
			"A3\Sounds_F_EPC\CAS_01\CAS_01_start_int",
			1,
			1
		};
		soundEngineOnExt[]=
		{
			"A3\Sounds_F_EPC\CAS_01\CAS_01_start_ext",
			1.4125376,
			1,
			500
		};
		soundEngineOffInt[]=
		{
			"A3\Sounds_F_EPC\CAS_01\CAS_01_stop_int",
			1,
			1
		};
		soundEngineOffExt[]=
		{
			"A3\Sounds_F_EPC\CAS_01\CAS_01_stop_ext",
			1.4125376,
			1,
			500
		};
		soundLocked[]=
		{
			"\A3\Sounds_F\weapons\Rockets\locked_1",
			0.1,
			1
		};
		soundIncommingMissile[]=
		{
			"\A3\Sounds_F\weapons\Rockets\locked_3",
			0.1,
			1.5
		};
		soundGearUp[]=
		{
			"A3\Sounds_F_EPC\CAS_01\gear_up",
			0.79432821,
			1,
			150
		};
		soundGearDown[]=
		{
			"A3\Sounds_F_EPC\CAS_01\gear_down",
			0.79432821,
			1,
			150
		};
		soundFlapsUp[]=
		{
			"A3\Sounds_F_EPC\CAS_01\Flaps_Up",
			0.63095737,
			1,
			100
		};
		soundFlapsDown[]=
		{
			"A3\Sounds_F_EPC\CAS_01\Flaps_Down",
			0.63095737,
			1,
			100
		};
		class Sounds
		{
			class EngineLowOut
			{
				sound[]=
				{
					"A3\Sounds_F_EPC\CAS_01\CAS_01_engine_idle_ext",
					1.7782794,
					1,
					2100
				};
				frequency="1.0 min (rpm + 0.5)";
				volume="camPos*2*(rpm factor[0.95, 0])*(rpm factor[0, 0.95])";
			};
			class EngineHighOut
			{
				sound[]=
				{
					"A3\Sounds_F_EPC\CAS_01\CAS_01_engine_ext",
					1.9952624,
					1.2,
					2500
				};
				frequency="1";
				volume="camPos*4*(rpm factor[0.5, 1.1])*(rpm factor[1.1, 0.5])";
			};
			class ForsageOut
			{
				sound[]=
				{
					"A3\Sounds_F_EPC\CAS_01\CAS_01_forsage_ext",
					2.5118864,
					1.2,
					2800
				};
				frequency="1";
				volume="engineOn*camPos*(thrust factor[0.6, 1.0])";
				cone[]={3.1400001,3.9200001,2,0.5};
			};
			class WindNoiseOut
			{
				sound[]=
				{
					"A3\Sounds_F\air\Plane_Fighter_03\noise",
					0.56234133,
					1,
					150
				};
				frequency="(0.1+(1.2*(speed factor[1, 150])))";
				volume="camPos*(speed factor[1, 150])";
			};
			class EngineLowIn
			{
				sound[]=
				{
					"A3\Sounds_F_EPC\CAS_01\CAS_01_engine_idle_int",
					1,
					1
				};
				frequency="1.0 min (rpm + 0.5)";
				volume="(1-camPos)*((rpm factor[0.7, 0.1])*(rpm factor[0.1, 0.7]))";
			};
			class EngineHighIn
			{
				sound[]=
				{
					"A3\Sounds_F_EPC\CAS_01\CAS_01_engine_int",
					1,
					1.2
				};
				frequency="1";
				volume="(1-camPos)*(rpm factor[0.85, 1.0])";
			};
			class ForsageIn
			{
				sound[]=
				{
					"A3\Sounds_F_EPC\CAS_01\CAS_01_forsage_int",
					1,
					1.2
				};
				frequency="1";
				volume="(1-camPos)*(engineOn*(thrust factor[0.6, 1.0]))";
			};
			class WindNoiseIn
			{
				sound[]=
				{
					"A3\Sounds_F\air\Plane_Fighter_03\noise",
					0.50118721,
					1
				};
				frequency="(0.1+(1.2*(speed factor[1, 150])))";
				volume="(1-camPos)*(speed factor[1, 150])";
			};
		};
		formationX=30;
		formationZ=30;
		class Armory
		{
			description="$STR_A3_CfgVehicles_UAV_02_base_Armory0";
		};
		model="\USAF_RQ4A\USAF_RQ4A.p3d";
		class TransportItems
		{
		};
		uavCameraDriverPos="PiP0_pos";
		uavCameraDriverDir="PiP0_dir";
		memoryPointLDust="DustLeft";
		memoryPointRDust="DustRight";
		memoryPointDriverOptics="PiP0_pos";
		driverOpticsModel="A3\drones_f\Weapons_F_Gamma\Reticle\UGV_01_Optics_Driver_F.p3d";
		driverForceOptics=1;
		class WingVortices
		{
		};
		class ViewPilot: ViewPilot
		{
			initFov=1;
			minFov=0.30000001;
			maxFov=1.2;
			initAngleX=0;
			minAngleX=-65;
			maxAngleX=85;
			initAngleY=0;
			minAngleY=-150;
			maxAngleY=150;
		};
		class Viewoptics: ViewOptics
		{
			initAngleX=0;
			minAngleX=0;
			maxAngleX=0;
			initAngleY=0;
			minAngleY=0;
			maxAngleY=0;
			initFov=1;
			minFov=0.30000001;
			maxFov=1.2;
			visionMode[]={"Ti"};
			thermalMode[]={0};
		};
		class AnimationSources: AnimationSources
		{
			class Bombs
			{
				source="user";
				animPeriod=1e-006;
				initPhase=0;
			};
			class AT_missiles
			{
				source="user";
				animPeriod=0.99000001;
				initPhase=1;
			};
			class HitAvionics
			{
				hitpoint="HitAvionics";
				raw=1;
				source="Hit";
			};
			class HitEngine: HitAvionics
			{
				hitpoint="HitEngine";
			};
			class HitEngine2: HitAvionics
			{
				hitpoint="HitEngine2";
			};
			class HitFuel: HitAvionics
			{
				hitpoint="HitFuel";
			};
			class HitFuel2: HitAvionics
			{
				hitpoint="HitFuel2";
			};
			class HitGear: HitAvionics
			{
				hitpoint="HitGear";
			};
			class HitHull: HitAvionics
			{
				hitpoint="HitHull";
			};
			class HitLAileron: HitAvionics
			{
				hitpoint="HitLAileron";
			};
			class HitRAileron: HitAvionics
			{
				hitpoint="HitRAileron";
			};
			class HitLCElevator: HitAvionics
			{
				hitpoint="HitLCElevator";
			};
			class HitRElevator: HitAvionics
			{
				hitpoint="HitRElevator";
			};
			class HitLCRudder: HitAvionics
			{
				hitpoint="HitLCRudder";
			};
			class HitRRudder: HitAvionics
			{
				hitpoint="HitRRudder";
			};
		};
		maxSpeed=588;
		envelope[]={0,0.30000001,1.15,2.2,4.3499999,5.1999998,6,6.5500002,6.6500001,6.8000002,3.5999999,1.8,0};
		landingSpeed=150;
		altFullForce=13000;
		altNoForce=18300;
		aileronSensitivity=1.5;
		elevatorSensitivity=1.5;
		wheelSteeringSensitivity=3;
		rudderInfluence=0.07;
		rudderControlsSensitivitycoef=4;
		rudderCoef[]={0.60000002,1,1,0.89999998,0.80000001,0.69999999,0.60000002};
		killFriendlyExpCoef=0.1;
		driverCompartments="Compartment3";
		cargoCompartments[]=
		{
			"Compartment2"
		};
		class Damage
		{
			tex[]={};
			mat[]=
			{
				"A3\Drones_F\Air_F_Gamma\UAV_02\Data\UAV_02.rvmat",
				"A3\Drones_F\Air_F_Gamma\UAV_02\Data\UAV_02_damage.rvmat",
				"A3\Drones_F\Air_F_Gamma\UAV_02\Data\UAV_02_destruct.rvmat"
			};
		};
		hiddenSelections[]=
		{
			"camo1"
		};
		hiddenSelectionsTextures[]=
		{
			"A3\Drones_F\Air_F_Gamma\UAV_02\Data\UAV_02_CO.paa"
		};
		weapons[]={};
		magazines[]={};
		LockDetectionSystem="1 + 8 + 4";
		incomingMissileDetectionSystem=16;
		DriverCanSee="1 + 2 + 4 + 8 + 16";
		class Reflectors
		{
			class Left
			{
				color[]={7000,7500,10000,1};
				ambient[]={100,100,100,0};
				position="light_1_pos";
				direction="light_1_dir";
				hitpoint="L svetlo";
				selection="L svetlo";
				size=1;
				innerAngle=20;
				outerAngle=60;
				coneFadeCoef=10;
				intensity=50;
				useFlare=1;
				dayLight=0;
				FlareSize=4;
				class Attenuation
				{
					start=1;
					constant=0;
					linear=0;
					quadratic=4;
				};
			};
		};
		class MarkerLights
		{
			class RedStill
			{
				name="cerveny pozicni";
				color[]={0.80000001,0,0};
				ambient[]={0.079999998,0,0};
				intensity=75;
				drawLight=1;
				drawLightSize=0.15000001;
				drawLightCenterSize=0.039999999;
				activeLight=0;
				blinking=0;
				dayLight=0;
				useFlare=0;
			};
			class GreenStill
			{
				name="zeleny pozicni";
				color[]={0,0.80000001,0};
				ambient[]={0,0.079999998,0};
				intensity=75;
				drawLight=1;
				drawLightSize=0.15000001;
				drawLightCenterSize=0.039999999;
				activeLight=0;
				blinking=0;
				dayLight=0;
				useFlare=0;
			};
			class WhiteBlinking
			{
				name="bily pozicni blik";
				color[]={1,1,1,1};
				ambient[]={0.2,0.2,0.2,1};
				intensity=75;
				blinking=1;
				blinkingPattern[]={0.1,0.89999998};
				blinkingPatternGuarantee=0;
				drawLightSize=0.2;
				drawLightCenterSize=0.039999999;
			};
			class WhiteBlinking2
			{
				name="bily pozicni blik2";
				color[]={1,1,1,1};
				ambient[]={0.2,0.2,0.2,1};
				intensity=75;
				blinking=1;
				blinkingPattern[]={0.1,0.89999998};
				blinkingPatternGuarantee=0;
				drawLightSize=0.2;
				drawLightCenterSize=0.039999999;
			};
		};
		driveOnComponent[]=
		{
			"wheel_1",
			"wheel_2",
			"wheel_3"
		};
		numberPhysicalWheels=3;
		class Wheels
		{
			class wheel_1
			{
				boneName="wheel_1";
				boundary="Wheel_1_rim";
				center="Wheel_1_axis";
				dampingRate=0.25;
				dampingRateDamaged=1;
				dampingRateDestroyed=1000;
				frictionVsSlipGraph[]=
				{
					"[0",
					"1]",
					"[0.5",
					"1]",
					"[1",
					"1]"
				};
				latStiffX=25;
				latStiffY=180;
				longitudinalStiffnessPerUnitGravity=5000;
				mass=150;
				maxBrakeTorque=1500;
				maxCompression=0.15000001;
				maxDroop=0.15000001;
				maxHandBrakeTorque=0;
				MOI=2;
				side="left";
				springDamperRate=37000;
				springStrength=149000;
				sprungMass=2500;
				steering=1;
				suspForceAppPointOffset="Wheel_1_axis";
				suspTravelDirection[]={0,-1,0};
				tireForceAppPointOffset="Wheel_1_axis";
				width=0.30000001;
			};
			class wheel_2: wheel_1
			{
				boneName="wheel_2";
				boundary="Wheel_2_rim";
				center="Wheel_2_axis";
				springDamperRate=23883;
				springStrength=95531;
				sprungMass=2134;
				steering=0;
				suspForceAppPointOffset="Wheel_2_axis";
				tireForceAppPointOffset="Wheel_2_axis";
			};
			class wheel_3: wheel_2
			{
				boneName="wheel_2";
				boundary="Wheel_2_rim";
				center="Wheel_2_axis";
				side="right";
				suspForceAppPointOffset="Wheel_2_axis";
				tireForceAppPointOffset="Wheel_2_axis";
			};
		};
		class HitPoints
		{
			class HitAvionics
			{
				armor=3;
				depends="0";
				explosionShielding=1;
				material=-1;
				minimalHit=0.02;
				name="HitAvionics";
				passThrough=0.2;
				radius=0.2;
				visual="HitAvionics";
			};
			class HitEngine
			{
				armor=1.5;
				depends="0";
				explosionShielding=2;
				material=-1;
				minimalHit=0.1;
				name="HitEngine";
				passThrough=0.5;
				radius=0.15000001;
				visual="HitEngine";
			};
			class HitEngine2: HitEngine
			{
				name="HitEngine2";
				visual="HitEngine2";
			};
			class HitFuel
			{
				armor=30;
				depends="0";
				explosionShielding=4;
				material=-1;
				minimalHit=0.1;
				name="HitFuel";
				passThrough=0.5;
				radius=0.25;
				visual="HitFuel";
			};
			class HitFuel2: HitFuel
			{
				name="HitFuel2";
				visual="HitFuel2";
			};
			class HitHull
			{
				armor=30;
				depends="0";
				explosionShielding=5;
				material=-1;
				minimalHit=0.02;
				name="HitHull";
				passThrough=0.5;
				radius=0.5;
				visual="HitHull";
			};
			class HitLAileron
			{
				armor=1.5;
				depends="0";
				explosionShielding=3;
				material=-1;
				minimalHit=0.1;
				name="HitLAileron";
				passThrough=0.1;
				radius=0.18000001;
				visual="HitLAileron";
			};
			class HitRAileron: HitLAileron
			{
				name="HitRAileron";
				visual="HitRAileron";
			};
			class HitLCElevator
			{
				armor=1.5;
				depends="0";
				explosionShielding=3;
				material=-1;
				minimalHit=0.1;
				name="HitLCElevator";
				passThrough=0.1;
				radius=0.2;
				visual="HitLCElevator";
			};
			class HitRElevator: HitLCElevator
			{
				name="HitRElevator";
				visual="HitRElevator";
			};
			class HitLCRudder
			{
				armor=1.5;
				depends="0";
				explosionShielding=3;
				material=-1;
				minimalHit=0.1;
				name="HitLCRudder";
				passThrough=0.1;
				radius=0.25;
				visual="HitLCRudder";
			};
			class HitGlass1
			{
				armor=2;
				material=-1;
				name="glass1";
				visual="glass1";
				passThrough=0;
			};
			class HitGlass2: HitGlass1
			{
				armor=0.5;
			};
		};
		class UserActions
		{
			class SAR_ON
			{
				displayName="<t color='#00ff00'>Activate SAR</t>";
				onlyforplayer=1;
				position="pilot_action";
				radius=8;
				showWindow=1;
				hideOnUse = 1;
				priority=100;
				condition="(remoteControlled player == driver this) && (isEngineOn this)";
				statement="null = [] spawn USAF_PXS_fnc_startSatellite;";
			};
		};
	};
	class USAF_RQ4B_B20 : USAF_RQ4B_B40
	{
		displayName="RQ-4B Global Hawk (B20)";
		class UserActions {};
	};
};
// Add "Add BACN Payload" option to other airframes too
// Fix this later since the statement formatting is wrong and all needs to be on the same line
/* class USAF_MQ9
{
	class ACE_MainActions 
	{
		class addBACNPayload
		{
			displayName = "Add BACN payload";
			condition = " ({(_x call ace_repair_fnc_isRepairVehicle) == true} count ((getPosATLVisual _target) nearEntities 30)) > 0 ";
			exceptions[] = {};
			statement = "
				[_player] spawn { 
					params [""_player""];
					_player playActionNow ""Civil"";
					sleep 2.267;
					_player switchMove [""InBaseMoves_repairVehicleKnl"",0,0.1,false];
				};
				[
					2.267+25,
					[_player, _target],
					{
						[_this select 0 select 1] call MM_fnc_setupBACN;
					},
					{
						[_this select 0 select 0] spawn {
							_this select 0 switchMove ["""", 0, 0.1, false];
							_this select 0 playActionNow ""Stand"";
						};
					},
					""Installing BACN payload""
				] call ace_common_fnc_progressBar;
			";
			icon = "";	//Add a +BACN icon at some point.
		};
		class removeBACNPayload
		{
			displayName = "Remove BACN payload";
			condition = " ({(_x call ace_repair_fnc_isRepairVehicle) == true} count ((getPosATLVisual _target) nearEntities 30)) > 0 ";
			exceptions[] = {};
			statement = "
				[_player] spawn { 
					params [""_player""];
					_player playActionNow ""Civil"";
					sleep 2.267;
					_player switchMove [""InBaseMoves_repairVehicleKnl"",0,0.1,false];
				};
				[
					2.267+25,
					[_player, _target],
					{
						{
							if ( _x getVariable [""RQ4Tweak_connectedToBACN"", []] isEqualTo (_this select 0 select 1) ) then {
								_x setVariable [""RQ4Tweak_connectedToBACN"", nil, true];
								_x setVariable [""RQ4Tweak_bacnConnectionHeld"", nil, true];
								_x setVariable [""RQ4Tweak_playerRadios"", nil, true];
								
								[false] remoteExecCall [""MM_fnc_bacnACREAmplify"", _x, true];

								[""] remoteExec [""hint"", _x];
							};
						} forEach allPlayers;

						[[_this select 0 select 1, 0, _this select 0 select 1 getVariable ""RQ4Tweak_bacnAddActionPath""]] remoteExec [""ace_interact_menu_fnc_removeActionFromObject""];
						[[_this select 0 select 1, 0, _this select 0 select 1 getVariable ""RQ4Tweak_bacnRemoveActionPath""]] remoteExec [""ace_interact_menu_fnc_removeActionFromObject""];
					},
					{
						[_this select 0 select 0] spawn {
							_this select 0 switchMove ["""", 0, 0.1, false];
							_this select 0 playActionNow ""Stand"";
						};
					},
					""Installing BACN payload""
				] call ace_common_fnc_progressBar;
			";
			icon = "";	//Add a +BACN icon at some point.
		};
	};
};
class STmod_airplane_MC130J_half : USAF_MQ9
{};
class STmod_airplane_MC130J_VIV : USAF_MQ9
{};
class STmod_airplane_MC130J_Base : USAF_MQ9
{}; */