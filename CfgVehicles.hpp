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
		editorPreview="USAF_RQ4A\data\UI\preview.jpg";              // TODO: path prefix differs from the model's (\x\rq4a_tweak_v2\...)
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
		model="\x\usaf_rq4a_tweak_v2\Models\RQ4B_GlobalHawk_B40.p3d";  // CHANGED: new model. Prefix matches the folder pboProject packs (\x\usaf_rq4a_tweak_v2); file name must match the CfgModels class in model.cfg
		class TransportItems
		{
		};
		uavCameraDriverPos="PiP0_pos";                               // memory point added (under the nose)
		uavCameraDriverDir="PiP0_dir";
		memoryPointLDust="DustLeft";                                 // memory points added (behind each main wheel)
		memoryPointRDust="DustRight";
		memoryPointDriverOptics="PiP0_pos";
		driverOpticsModel="A3\drones_f\Weapons_F_Gamma\Reticle\UGV_01_Optics_Driver_F.p3d";
		driverForceOptics=1;
		class WingVortices
		{
		};
		// NEW: engine exhaust effect (memory points exhaust1 / exhaust1_dir at the nozzle)
		class Exhausts
		{
			class Exhaust1
			{
				position="exhaust1";
				direction="exhaust1_dir";
				effect="ExhaustsEffectPlane";
			};
		};
		// NEW: spoilers are driven by the "speedBrake" animation source in model.cfg
		airBrake=1;
		airBrakeFrictionCoef=2.5;                                    // tune to taste
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
		maxSpeed=600;
		envelope[] = { 0, 0.15, 0.85, 1.5, 2.3, 2.5, 2.5, 2.5, 2.4, 2.3, 2.1 };   // LRN 1015 Airfoil
		angleOfIndicence = 6 * 3.1415 / 180;	// 6 degrees
		thrustCoef[] = { 0.9, 0.8, 0.9, 1.3, 1.2, 1.2, 1.1, 1, 0.9, 0.2, 0.1, 0, 0 };	// A-164 Wipeout
		flaps=0;
		simulation="airplanex";
		maxOmega=3000;
		dampingRateFullThrottle=0.03;
		dampingRateZeroThrottleClutchEngaged=0.03;
		dampingRateZeroThrottleClutchDisengaged=0.03;
		landingSpeed=195;
		stallSpeed=160;
		stallWarningTreshold=0.2;
		altFullForce=13000;
		altNoForce=18300;
		aileronSensitivity=0.66;
		elevatorCoef[] = { 0.6, 0.9, 0.5, 0.4, 0.35, 0.3, 0.3 };
		elevatorSensitivity=0.8;
		wheelSteeringSensitivity=3;
		gearsUpFrictionCoef = 0.35;
		gearUpTime = 7;
		gearDownTime = 7;
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
			mat[]={};   // CHANGED: removed the Greyhawk (UAV_02) rvmats - they belong to a different UV layout. Add original/damage/destroyed rvmat triplets once the RQ-4B has its own materials.
		};
		hiddenSelections[]=
		{
			"camo1",
			"camo2"
		};
		hiddenSelectionsTextures[]=
		{
			"\x\usaf_rq4a_tweak_v2\Data\rq4_co.paa",
			"\x\usaf_rq4a_tweak_v2\Data\rq4_co.paa"   // camo2: V-tail (same texture sheet by default; point this at a copy with tail art)
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
				position="light_landing_pos";
				direction="light_landing_dir";
				hitpoint="light_landing";
				selection="light_landing";
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
				name="light_nav_l_pos";                              // left (port) wingtip
				color[]={0.80000001,0,0};
				ambient[]={0.079999998,0,0};
				intensity=100;
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
				name="light_nav_r_pos";                              // right (starboard) wingtip
				color[]={0,0.80000001,0};
				ambient[]={0,0.079999998,0};
				intensity=100;
				drawLight=1;
				drawLightSize=0.15000001;
				drawLightCenterSize=0.039999999;
				activeLight=0;
				blinking=0;
				dayLight=0;
				useFlare=0;
			};
			class WhiteSteadyL
			{
				name="light_strobe_l_pos";
				color[]={1,1,1};
				ambient[]={0.1,0.1,0.1};
				intensity=200;                                        // low state: tune to taste
				drawLight=1;
				drawLightSize=0.12;
				drawLightCenterSize=0.03;
				activeLight=0;
				blinking=0;
				dayLight=0;
				useFlare=0;
			};
			class WhiteSteadyR: WhiteSteadyL
			{
				name="light_strobe_r_pos";
			};
			// High-intensity state: on for 1.0 s, then off for 0.5 s (showing the steady low state), repeating
			// every 1.5 s. Both sides use the same pattern, so they flash together.
			class WhiteStrobeL
			{
				name="light_strobe_l_pos";
				color[]={1,1,1};
				ambient[]={0.2,0.2,0.2};
				intensity=400;                                      // high state: tune to taste
				drawLight=1;
				drawLightSize=0.6;
				drawLightCenterSize=0.15;
				activeLight=1;                                       // lights up nearby surfaces during the flash
				blinking=1;
				blinkingPattern[]={0.5,1.5};                         // {seconds high, seconds low}
				blinkingPatternGuarantee=1;
				dayLight=0;                                          // not drawn in daylight
				useFlare=1;
				flareSize=1;
			};
			class WhiteStrobeR: WhiteStrobeL
			{
				name="light_strobe_r_pos";
			};
		};
		driveOnComponent[]=
		{
			"wheel_nose",
			"wheel_main_l",
			"wheel_main_r"
		};
		numberPhysicalWheels=3;
		class Wheels
		{
			class wheel_nose
			{
				boneName="wheel_nose";
				boundary="wheel_nose_bound";
				center="wheel_nose_center";
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
				maxBrakeTorque=900;
				maxCompression=0.05;   // CHANGED: was 0.15 - small travel since the wheels are no longer animated by the damper
				maxDroop=0.05;         // CHANGED: was 0.15
				maxHandBrakeTorque=0;
				MOI=2;
				side="left";
				springDamperRate=56710;   // CHANGED: rescaled with springStrength (same damping ratio as your original)
				springStrength=349950;    // CHANGED: static sag 0.025 m = half of maxCompression 0.05
				sprungMass=891.8;
				steering=1;
				suspForceAppPointOffset="wheel_nose_center";
				suspTravelDirection[]={0,-1,0};
				tireForceAppPointOffset="wheel_nose_center";
				width=0.18;
			};
			class wheel_main_l: wheel_nose
			{
				boneName="wheel_main_l";
				boundary="wheel_main_l_bound";
				center="wheel_main_l_center";
				springDamperRate=83060;   // CHANGED: rescaled with springStrength (same damping ratio as your original)
				springStrength=1155500;   // CHANGED: static sag 0.025 m = half of maxCompression 0.05
				sprungMass=2944.6;
				steering=0;
				side="left";
				suspForceAppPointOffset="wheel_main_l_center";
				tireForceAppPointOffset="wheel_main_l_center";
				width=0.23;
			};
			class wheel_main_r: wheel_main_l
			{
				boneName="wheel_main_r";
				boundary="wheel_main_r_bound";
				center="wheel_main_r_center";
				side="right";
				suspForceAppPointOffset="wheel_main_r_center";
				tireForceAppPointOffset="wheel_main_r_center";
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
			class HitRRudder: HitLCRudder
			{
				name="HitRRudder";
				visual="HitRRudder";
			};
			class HitGear
			{
				armor=2;
				depends="0";
				explosionShielding=2;
				material=-1;
				minimalHit=0.1;
				name="HitGear";
				passThrough=0.3;
				radius=0.3;
				visual="HitGear";
			};
		};
	};
	   class USAF_RQ4B_B20 : USAF_RQ4B_B40
   {
       displayName="RQ-4B Global Hawk (B20)";
       model="\x\usaf_rq4a_tweak_v2\Models\RQ4B_GlobalHawk_BACN.p3d";
       class UserActions {};
   };
};