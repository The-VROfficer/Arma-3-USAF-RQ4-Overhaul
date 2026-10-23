class RscText;
class RscButton;
class RscCombo;
class RscEdit;
class RscMapControl;
class RscStructuredText;
class RscFrame;
class RscCheckbox;
class RscListbox;

class textEntryDialog
{
	idd = 1251;
	class textEntryBackground: RscText
	{
		idc = 1000;
		x = 6.5 * GUI_GRID_W + GUI_GRID_X;
		y = 9 * GUI_GRID_H + GUI_GRID_Y;
		w = 23 * GUI_GRID_W;
		h = 3 * GUI_GRID_H;
		colorBackground[] = {0,0,0,1};
	};
	class textEntryPlaceholder: RscEdit
	{
		idc = 1002;
		x = 7 * GUI_GRID_W + GUI_GRID_X;
		y = 9.5 * GUI_GRID_H + GUI_GRID_Y;
		w = 16 * GUI_GRID_W;
		h = 2 * GUI_GRID_H;
		colorBackground[] = {1,1,1,0.7};
	};
	class textEntryEnter: RscButton
	{
		idc = 1600;
		text = "Enter"; //--- ToDo: Localize;
		x = 23.5 * GUI_GRID_W + GUI_GRID_X;
		y = 9.5 * GUI_GRID_H + GUI_GRID_Y;
		w = 5.5 * GUI_GRID_W;
		h = 2 * GUI_GRID_H;
		colorBackground[] = {1,1,1,0.7};
	};
};


class RQ4dialog
{
	idd=1250;
	onUnload = "_this call MM_fnc_onDialogUnload;";
	class controls
	{
		class background: RscText
		{
			idc = 1000;
			x = 0.0101562 * safezoneW + safezoneX;
			y = 0.016 * safezoneH + safezoneY;
			w = 0.979687 * safezoneW;
			h = 0.968 * safezoneH;
			colorBackground[] = {0,0,0,0.9};
		};
		class sensorControlsText: RscStructuredText
		{
			idc = 1100;
			text = "<t size='1.3'><t align='center' t font='PuristaBold'>Sensor and Flight Controls   </t>  "; //--- ToDo: Localize;
			x = 0.0204687 * safezoneW + safezoneX;
			y = 0.049 * safezoneH + safezoneY;
			w = 0.242344 * safezoneW;
			h = 0.033 * safezoneH;
			colorText[] = {0,0,0,1};
			colorBackground[] = {1,0.675,0.341,1};
			sizeEx = 1.3 * GUI_GRID_H;
		};
		class displayControlsText: RscStructuredText
		{
			idc = 1101;
			text = "<t size='1.3'><t align='center' t font='PuristaBold'>Display Controls    </t>  "; //--- ToDo: Localize;
			x = 0.29375 * safezoneW + safezoneX;
			y = 0.049 * safezoneH + safezoneY;
			w = 0.232031 * safezoneW;
			h = 0.033 * safezoneH;
			colorText[] = {0,0,0,1};
			colorBackground[] = {0.431,0.51,0.396,1};
			sizeEx = 1.3 * GUI_GRID_H;
		};
		class dividerBar: RscText
		{
			idc = 1001;
			x = 0.273125 * safezoneW + safezoneX;
			y = 0.049 * safezoneH + safezoneY;
			w = 0.0103125 * safezoneW;
			h = 0.902 * safezoneH;
			colorBackground[] = {0.263,0.263,0.263,0.5};
		};
		class sensorToggleButton: RscButton
		{
			idc = 1600;
			text = "Sensor OFF"; //--- ToDo: Localize;
			onButtonClick = "[] call MM_fnc_toggleSensorStateUI; [] call MM_fnc_focusDialogCatcher;";
			x = 0.0926562 * safezoneW + safezoneX;
			y = 0.115 * safezoneH + safezoneY;
			w = 0.103125 * safezoneW;
			h = 0.055 * safezoneH;
			colorBackground[] = {1,0,0,1};
			period = 0;
			periodFocus = 0;
		};
		class dummyFocusCatcher: RscButton
		{
			idc = 1699;
			text = ""; //--- ToDo: Localize;
			x = 15 * safezoneW + safezoneX;
			y = 15 * safezoneH + safezoneY;
			w = 0.103125 * safezoneW;
			h = 0.055 * safezoneH;
			colorBackground[] = {0,0,0,0};
			period = 0;
			periodFocus = 0;
		};
		class slewLeftButton: RscButton
		{
			idc = 1601;
			text = "Slew Left"; //--- ToDo: Localize;
			onButtonClick = "[0] call MM_fnc_setSlewSide; [] call MM_fnc_focusDialogCatcher;";
			x = 0.0204687 * safezoneW + safezoneX;
			y = 0.192 * safezoneH + safezoneY;
			w = 0.0979687 * safezoneW;
			h = 0.055 * safezoneH;
			colorBackground[] = {0.851,0.851,0.851,1};
		};
		class slewRightButton: RscButton
		{
			idc = 1602;
			text = "Slew Right"; //--- ToDo: Localize;
			onButtonClick = "[1] call MM_fnc_setSlewSide; [] call MM_fnc_focusDialogCatcher;";
			x = 0.164844 * safezoneW + safezoneX;
			y = 0.192 * safezoneH + safezoneY;
			w = 0.0928125 * safezoneW;
			h = 0.055 * safezoneH;
			colorBackground[] = {0.851,0.851,0.851,1};
		};
		class mtiModeButton: RscButton
		{
			idc = 1603;
			text = "MTI Mode: RRCA"; //--- ToDo: Localize;
			onButtonClick = "[] call MM_fnc_focusDialogCatcher;";
			x = 0.0204687 * safezoneW + safezoneX;
			y = 0.269 * safezoneH + safezoneY;
			w = 0.0979687 * safezoneW;
			h = 0.055 * safezoneH;
			colorBackground[] = {0.851,0.851,0.851,1};
		};
		class addGRCAButton: RscButton
		{
			idc = 1604;
			text = "Add GRCA"; //--- ToDo: Localize;
			onButtonClick = "[getConnectedUAV player] spawn MM_fnc_drawGRCA; [] call MM_fnc_focusDialogCatcher;";
			x = 0.164844 * safezoneW + safezoneX;
			y = 0.269 * safezoneH + safezoneY;
			w = 0.0928125 * safezoneW;
			h = 0.055 * safezoneH;
			colorText[] = {0.6,0.6,0.6,1};
			colorBackground[] = {0.851,0.851,0.851,1};
		};
		class takeSARButton: RscButton
		{
			idc = 1605;
			text = "Take SAR Image"; //--- ToDo: Localize;
			onButtonClick = "[] spawn USAF_PXS_fnc_startSatellite; [] call MM_fnc_focusDialogCatcher;";
			x = 0.0204687 * safezoneW + safezoneX;
			y = 0.346 * safezoneH + safezoneY;
			w = 0.0979687 * safezoneW;
			h = 0.055 * safezoneH;
			colorBackground[] = {0.851,0.851,0.851,1};
		};
		class toggleFORButton: RscButton
		{
			idc = 1606;
			text = "Turn FOR On"; //--- ToDo: Localize;
			onButtonClick = "[] call MM_fnc_focusDialogCatcher;";
			x = 0.164844 * safezoneW + safezoneX;
			y = 0.346 * safezoneH + safezoneY;
			w = 0.0928125 * safezoneW;
			h = 0.055 * safezoneH;
			colorBackground[] = {0.851,0.851,0.851,1};
		};
		class altitudeText: RscStructuredText
		{
			idc = 1102;
			text = "<t size='0.65' t align='center' t font='PuristaBold'>Programmed Altitude (ft/MSL)  </t>  "; //--- ToDo: Localize;
			x = 0.0204687 * safezoneW + safezoneX;
			y = 0.467 * safezoneH + safezoneY;
			w = 0.0979687 * safezoneW;
			h = 0.022 * safezoneH;
			colorBackground[] = {0.6,0.6,0.6,1};
			sizeEx = 0.65 * GUI_GRID_H;
		};
		class loiterText: RscStructuredText
		{
			idc = 1103;
			text = "<t size='0.65'><t align='center' t font='PuristaBold'>Programmed Loiter (m)  </t>  "; //--- ToDo: Localize;
			x = 0.164844 * safezoneW + safezoneX;
			y = 0.467 * safezoneH + safezoneY;
			w = 0.0928125 * safezoneW;
			h = 0.022 * safezoneH;
			colorBackground[] = {0.6,0.6,0.6,1};
			sizeEx = 0.65 * GUI_GRID_H;
		};
		class altitudeInput: RscEdit
		{
			idc = 1300;
			text = ""; //--- ToDo: Localize;
			x = 0.0204687 * safezoneW + safezoneX;
			y = 0.5 * safezoneH + safezoneY;
			w = 0.0979687 * safezoneW;
			h = 0.055 * safezoneH;
			colorBackground[] = {0.851,0.851,0.851,1};
			colorText[] = {0.9,0.9,0.9,1};
			sizeEx = 0.65 * GUI_GRID_H;
		};
		class loiterInput: RscEdit
		{
			idc = 1301;
			text = ""; //--- ToDo: Localize;
			x = 0.164844 * safezoneW + safezoneX;
			y = 0.5 * safezoneH + safezoneY;
			w = 0.0928125 * safezoneW;
			h = 0.055 * safezoneH;
			colorBackground[] = {0.851,0.851,0.851,1};
			colorText[] = {0.9,0.9,0.9,1};
			sizeEx = 0.65 * GUI_GRID_H;
		};
		class flightControlsExecuteButton: RscButton
		{
			idc = 1607;
			text = "EXECUTE"; //--- ToDo: Localize;
			onButtonClick = "[] call MM_fnc_executeFlightControls; [] call MM_fnc_focusDialogCatcher;";
			x = 0.0978125 * safezoneW + safezoneX;
			y = 0.61 * safezoneH + safezoneY;
			w = 0.0825 * safezoneW;
			h = 0.055 * safezoneH;
			colorBackground[] = {0.851,0.851,0.851,1};
			sizeEx = 1.5 * GUI_GRID_H;
		};
		class mapFrame: RscFrame
		{
			idc = 1800;
			x = 0.54125 * safezoneW + safezoneX;
			y = 0.049 * safezoneH + safezoneY;
			w = 0.438281 * safezoneW;
			h = 0.902 * safezoneH;
		};
		class mapControl: RscMapControl
		{
			idc = 1801;
			x = 0.54125 * safezoneW + safezoneX;
			y = 0.049 * safezoneH + safezoneY;
			w = 0.438281 * safezoneW;
			h = 0.902 * safezoneH;
		};
		class markerColorText: RscStructuredText
		{
			idc = 1104;
			text = "<t size='0.65' t align='center' t font='PuristaBold'>Default Marker Color  </t>  "; //--- ToDo: Localize;
			x = 0.29375 * safezoneW + safezoneX;
			y = 0.126 * safezoneH + safezoneY;
			w = 0.0928125 * safezoneW;
			h = 0.022 * safezoneH;
			colorBackground[] = {0.6,0.6,0.6,1};
			sizeEx = 0.65 * GUI_GRID_H;
		};
		class markerColorOPFOR: RscText
		{
			idc = 1002;
			x = 0.29375 * safezoneW + safezoneX;
			y = 0.159 * safezoneH + safezoneY;
			w = 0.0567187 * safezoneW;
			h = 0.011 * safezoneH;
			colorBackground[] = {0.5,0,0,1};
		};
		class checkboxOPFOR: RscCheckbox
		{
			idc = 2800;
			// Integration note: this mission registers MM_fnc_selectMTIMarkerColor via CfgFunctions.
			// Add it under MM/GUI in the mod config and point that category at MTI\gui.
			// CfgFunctions does not require spawn; use spawn only if this handler later needs suspension.
			onCheckedChanged = "[_this select 0, _this select 1, 'colorOPFOR'] call MM_fnc_selectMTIMarkerColor;";
			x = 0.355625 * safezoneW + safezoneX;
			y = 0.159 * safezoneH + safezoneY;
			w = 0.00515625 * safezoneW;
			h = 0.011 * safezoneH;
		};
		class markerColorCIV: RscText
		{
			idc = 1003;
			x = 0.29375 * safezoneW + safezoneX;
			y = 0.181 * safezoneH + safezoneY;
			w = 0.0567187 * safezoneW;
			h = 0.011 * safezoneH;
			colorBackground[] = {0.4,0,0.5,1};
		};
		class checkboxCIV: RscCheckbox
		{
			idc = 2801;
			onCheckedChanged = "[_this select 0, _this select 1, 'colorCIV'] call MM_fnc_selectMTIMarkerColor;";
			x = 0.355625 * safezoneW + safezoneX;
			y = 0.181 * safezoneH + safezoneY;
			w = 0.00515625 * safezoneW;
			h = 0.011 * safezoneH;
		};
		class checkboxUNKNOWN: RscCheckbox
		{
			idc = 2802;
			onCheckedChanged = "[_this select 0, _this select 1, 'colorUNKNOWN'] call MM_fnc_selectMTIMarkerColor;";
			x = 0.355625 * safezoneW + safezoneX;
			y = 0.203 * safezoneH + safezoneY;
			w = 0.00515625 * safezoneW;
			h = 0.011 * safezoneH;
		};
		class markerColorUNKNOWN: RscText
		{
			idc = 1004;
			x = 0.29375 * safezoneW + safezoneX;
			y = 0.203 * safezoneH + safezoneY;
			w = 0.0567187 * safezoneW;
			h = 0.011 * safezoneH;
			colorBackground[] = {0.7,0.6,0,1};
		};
		class markerColorGUER: RscText
		{
			idc = 1005;
			x = 0.29375 * safezoneW + safezoneX;
			y = 0.225 * safezoneH + safezoneY;
			w = 0.0567187 * safezoneW;
			h = 0.011 * safezoneH;
			colorBackground[] = {0,0.5,0,1};
		};
		class checkboxGUER: RscCheckbox
		{
			idc = 2803;
			onCheckedChanged = "[_this select 0, _this select 1, 'colorGUER'] call MM_fnc_selectMTIMarkerColor;";
			x = 0.355625 * safezoneW + safezoneX;
			y = 0.225 * safezoneH + safezoneY;
			w = 0.00515625 * safezoneW;
			h = 0.011 * safezoneH;
		};
		class checkboxBLUFOR: RscCheckbox
		{
			idc = 2804;
			onCheckedChanged = "[_this select 0, _this select 1, 'colorBLUFOR'] call MM_fnc_selectMTIMarkerColor;";
			x = 0.355625 * safezoneW + safezoneX;
			y = 0.247 * safezoneH + safezoneY;
			w = 0.00515625 * safezoneW;
			h = 0.011 * safezoneH;
		};
		class markerColorBLUFOR: RscText
		{
			idc = 1006;
			x = 0.29375 * safezoneW + safezoneX;
			y = 0.247 * safezoneH + safezoneY;
			w = 0.0567187 * safezoneW;
			h = 0.011 * safezoneH;
			colorBackground[] = {0,0.3,0.6,1};
		};
		class markerRenamingText: RscStructuredText
		{
			idc = 1105;
			text = "<t size='0.65' t align='center' t font='PuristaBold'>Marker Renaming  </t>  "; //--- ToDo: Localize;
			x = 0.432969 * safezoneW + safezoneX;
			y = 0.126 * safezoneH + safezoneY;
			w = 0.0928125 * safezoneW;
			h = 0.022 * safezoneH;
			colorBackground[] = {0.6,0.6,0.6,1};
			sizeEx = 0.65 * GUI_GRID_H;
		};
		class markerClickRenameButton: RscButton
		{
			idc = 1608;
			text = "via Map Click"; //--- ToDo: Localize;
			onButtonClick = "[] call MM_fnc_focusDialogCatcher;";
			x = 0.432969 * safezoneW + safezoneX;
			y = 0.17 * safezoneH + safezoneY;
			w = 0.0928125 * safezoneW;
			h = 0.044 * safezoneH;
			colorBackground[] = {0.851,0.851,0.851,1};
		};
		class markerSearchRenameButton: RscButton
		{
			idc = 1609;
			text = "via Marker Name"; //--- ToDo: Localize;
			onButtonClick = "[] call MM_fnc_focusDialogCatcher;";
			x = 0.432969 * safezoneW + safezoneX;
			y = 0.236 * safezoneH + safezoneY;
			w = 0.0928125 * safezoneW;
			h = 0.044 * safezoneH;
			colorBackground[] = {0.851,0.851,0.851,1};
		};
		class allPlayersText: RscStructuredText
		{
			idc = 1106;
			text = "<t size='0.65' t align='center' t font='PuristaBold'>All Players  </t>  "; //--- ToDo: Localize;
			x = 0.29375 * safezoneW + safezoneX;
			y = 0.324 * safezoneH + safezoneY;
			w = 0.0928125 * safezoneW;
			h = 0.022 * safezoneH;
			colorBackground[] = {0.6,0.6,0.6,1};
			sizeEx = 0.65 * GUI_GRID_H;
		};
		class MTIRecipientsText: RscStructuredText
		{
			idc = 1107;
			text = "<t size='0.65' t align='center' t font='PuristaBold'>MTI Recipients </t>  "; //--- ToDo: Localize;
			x = 0.432969 * safezoneW + safezoneX;
			y = 0.324 * safezoneH + safezoneY;
			w = 0.0928125 * safezoneW;
			h = 0.022 * safezoneH;
			colorBackground[] = {0.6,0.6,0.6,1};
			sizeEx = 0.65 * GUI_GRID_H;
		};
		class lbAllPlayers: RscListbox
		{
			idc = 1500;
			x = 0.29375 * safezoneW + safezoneX;
			y = 0.368 * safezoneH + safezoneY;
			w = 0.0928125 * safezoneW;
			h = 0.352 * safezoneH;
			sizeEx = 0.7 * GUI_GRID_H;
		};
		class lbRecipients: RscListbox
		{
			idc = 1501;
			x = 0.432969 * safezoneW + safezoneX;
			y = 0.368 * safezoneH + safezoneY;
			w = 0.0928125 * safezoneW;
			h = 0.341 * safezoneH;
			sizeEx = 0.7 * GUI_GRID_H;
		};
		class pushToRecipientsButton: RscButton
		{
			idc = 1610;
			text = ">"; //--- ToDo: Localize;
			onButtonClick = "[] call MM_fnc_pushToRecipients; [] call MM_fnc_focusDialogCatcher;";
			x = 0.391719 * safezoneW + safezoneX;
			y = 0.423 * safezoneH + safezoneY;
			w = 0.0360937 * safezoneW;
			h = 0.022 * safezoneH;
			colorBackground[] = {0.851,0.851,0.851,1};
			sizeEx = 1.3 * GUI_GRID_H;
		};
		class pushFromRecipientsButton: RscButton
		{
			idc = 1611;
			text = "<"; //--- ToDo: Localize;
			onButtonClick = "[] call MM_fnc_pushFromRecipients; [] call MM_fnc_focusDialogCatcher;";
			x = 0.391719 * safezoneW + safezoneX;
			y = 0.478 * safezoneH + safezoneY;
			w = 0.0360937 * safezoneW;
			h = 0.022 * safezoneH;
			colorBackground[] = {0.851,0.851,0.851,1};
			sizeEx = 1.3 * GUI_GRID_H;
		};
		class clearRecipientsButton: RscButton
		{
			idc = 1612;
			text = "Clear ALL"; //--- ToDo: Localize;
			onButtonClick = "[] call MM_fnc_clearRecipients; [] call MM_fnc_focusDialogCatcher;";
			x = 0.391719 * safezoneW + safezoneX;
			y = 0.555 * safezoneH + safezoneY;
			w = 0.0360937 * safezoneW;
			h = 0.044 * safezoneH;
			colorBackground[] = {0.851,0.851,0.851,1};
			sizeEx = 1 * GUI_GRID_H;
		};
	};
};
