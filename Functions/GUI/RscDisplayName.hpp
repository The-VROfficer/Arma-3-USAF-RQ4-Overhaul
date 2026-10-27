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
  idd = 1250;
  onUnload = "_this call MM_fnc_onDialogUnload";
  class Controls
  {
      class background : RscText
      {
        idc = 1000;
        x = 0.0101562 * safezoneW + safezoneX;
        y = 0.016 * safezoneH + safezoneY;
        w = 0.979687 * safezoneW;
        h = 0.968 * safezoneH;
        colorBackground[] = {0.00, 0.00, 0.00, 0.90};
        colorShadow[] = {0.00, 0.00, 0.00, 0.50};
      };
      class sensorControlsText : RscStructuredText
      {
        idc = 1100;
        x = 0.0204687 * safezoneW + safezoneX;
        y = 0.049 * safezoneH + safezoneY;
        w = 0.242344 * safezoneW;
        h = 0.033 * safezoneH;
        sizeEx = 1.3 * GUI_GRID_H;
        colorText[] = {0.00, 0.00, 0.00, 1.00};
        colorBackground[] = {1.00, 0.68, 0.34, 1.00};
        text = "<t size='1.3'><t align='center' t font='PuristaBold'>Sensor and Flight Controls   </t>  ";
      };
      class displayControlsText : RscStructuredText
      {
        idc = 1101;
        x = 0.29375 * safezoneW + safezoneX;
        y = 0.049 * safezoneH + safezoneY;
        w = 0.232031 * safezoneW;
        h = 0.033 * safezoneH;
        sizeEx = 1.3 * GUI_GRID_H;
        colorText[] = {0.00, 0.00, 0.00, 1.00};
        colorBackground[] = {0.43, 0.51, 0.40, 1.00};
        text = "<t size='1.3'><t align='center' t font='PuristaBold'>Display Controls    </t>  ";
      };
      class dividerBar1 : RscText
      {
        idc = 1020;
        x = 0.273125 * safezoneW + safezoneX;
        y = 0.049 * safezoneH + safezoneY;
        w = 0.0103125 * safezoneW;
        h = 0.902 * safezoneH;
        colorBackground[] = {0.26, 0.26, 0.26, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.50};
      };
      class sensorToggleButton : RscButton
      {
        idc = 1600;
        style = 0x02;
        x = 0.0926562 * safezoneW + safezoneX;
        y = 0.115 * safezoneH + safezoneY;
        w = 0.103125 * safezoneW;
        h = 0.055 * safezoneH;
        colorBackground[] = {1.00, 0.00, 0.00, 1.00};
        text = "Sensor: OFF";
        onButtonClick = "[] call MM_fnc_toggleSensorState; [] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class dummyFocusCatcher : RscButton
      {
        idc = 1699;
        style = 0x02;
        x = 15 * safezoneW + safezoneX;
        y = 15 * safezoneH + safezoneY;
        w = 0.103125 * safezoneW;
        h = 0.055 * safezoneH;
        colorBackground[] = {0.00, 0.00, 0.00, 0.50};
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class slewLeftButton : RscButton
      {
        idc = 1601;
        style = 0x02;
        x = 0.0204687 * safezoneW + safezoneX;
        y = 0.192 * safezoneH + safezoneY;
        w = 0.0979687 * safezoneW;
        h = 0.055 * safezoneH;
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        text = "Slew Left";
        onButtonClick = "[0] call MM_fnc_setSlewSide; [] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class slewRightButton : RscButton
      {
        idc = 1602;
        style = 0x02;
        x = 0.164844 * safezoneW + safezoneX;
        y = 0.192 * safezoneH + safezoneY;
        w = 0.0928125 * safezoneW;
        h = 0.055 * safezoneH;
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        text = "Slew Right";
        onButtonClick = "[1] call MM_fnc_setSlewSide; [] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class mtiModeButton : RscButton
      {
        idc = 1603;
        style = 0x02;
        x = 0.0204687 * safezoneW + safezoneX;
        y = 0.269 * safezoneH + safezoneY;
        w = 0.0979687 * safezoneW;
        h = 0.055 * safezoneH;
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        text = "MTI Mode: RRCA";
        onButtonClick = "[] call MM_fnc_toggleMTIMode; [] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class addGRCAButton : RscButton
      {
        idc = 1604;
        style = 0x02;
        x = 0.164844 * safezoneW + safezoneX;
        y = 0.269 * safezoneH + safezoneY;
        w = 0.0928125 * safezoneW;
        h = 0.055 * safezoneH;
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        text = "Add GRCA";
        onButtonClick = "[getConnectedUAV player] spawn MM_fnc_drawGRCA; [] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class takeSARButton : RscButton
      {
        idc = 1605;
        style = 0x02;
        x = 0.0204687 * safezoneW + safezoneX;
        y = 0.346 * safezoneH + safezoneY;
        w = 0.0979687 * safezoneW;
        h = 0.055 * safezoneH;
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        text = "Take SAR Image";
        onButtonClick = "[] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class toggleFORButton : RscButton
      {
        idc = 1606;
        style = 0x02;
        x = 0.164844 * safezoneW + safezoneX;
        y = 0.346 * safezoneH + safezoneY;
        w = 0.0928125 * safezoneW;
        h = 0.055 * safezoneH;
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        text = "Field of Regard: OFF";
        onButtonClick = "[] call MM_fnc_toggleFOR; [] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class altitudeText : RscStructuredText
      {
        idc = 1102;
        x = 0.02 * safezoneW + safezoneX;
        y = 0.64 * safezoneH + safezoneY;
        w = 0.0979687 * safezoneW;
        h = 0.022 * safezoneH;
        sizeEx = 0.65 * GUI_GRID_H;
        colorBackground[] = {0.60, 0.60, 0.60, 1.00};
        text = "<t size='0.65' t align='center' t font='PuristaBold'>Programmed Altitude (ft/MSL)  </t>  ";
      };
      class loiterText : RscStructuredText
      {
        idc = 1103;
        x = 0.16 * safezoneW + safezoneX;
        y = 0.64 * safezoneH + safezoneY;
        w = 0.0928125 * safezoneW;
        h = 0.022 * safezoneH;
        sizeEx = 0.65 * GUI_GRID_H;
        colorBackground[] = {0.60, 0.60, 0.60, 1.00};
        text = "<t size='0.65'><t align='center' t font='PuristaBold'>Programmed Loiter (m)  </t>  ";
      };
      class altitudeInput : RscEdit
      {
        idc = 1300;
        style = 0x140;
        x = 0.02 * safezoneW + safezoneX;
        y = 0.67 * safezoneH + safezoneY;
        w = 0.0979687 * safezoneW;
        h = 0.055 * safezoneH;
        sizeEx = 0.05;
        colorText[] = {0.90, 0.90, 0.90, 1.00};
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        autocomplete = false;
        colorSelection[] = {0.13, 0.54, 0.21, 1.00};
        canModify = 1;
      };
      class loiterInput : RscEdit
      {
        idc = 1301;
        style = 0x140;
        x = 0.16 * safezoneW + safezoneX;
        y = 0.67 * safezoneH + safezoneY;
        w = 0.0928125 * safezoneW;
        h = 0.055 * safezoneH;
        sizeEx = 0.05;
        colorText[] = {0.90, 0.90, 0.90, 1.00};
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        autocomplete = false;
        colorSelection[] = {0.13, 0.54, 0.21, 1.00};
        canModify = 1;
      };
      class flightControlsExecuteButton : RscButton
      {
        idc = 1607;
        style = 0x02;
        x = 0.11 * safezoneW + safezoneX;
        y = 0.75 * safezoneH + safezoneY;
        w = 0.06 * safezoneW;
        h = 0.03 * safezoneH;
        sizeEx = 1.5 * GUI_GRID_H;
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        text = "EXECUTE";
        onButtonClick = "[] call MM_fnc_executeFlightControls; [] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class mapFrame : RscFrame
      {
        idc = 1800;
        style = 0x40;
        x = 0.54125 * safezoneW + safezoneX;
        y = 0.049 * safezoneH + safezoneY;
        w = 0.438281 * safezoneW;
        h = 0.902 * safezoneH;
      };
      class mapControl : RscMapControl
      {
        idc = 1801;
        x = 0.54125 * safezoneW + safezoneX;
        y = 0.049 * safezoneH + safezoneY;
        w = 0.438281 * safezoneW;
        h = 0.902 * safezoneH;
      };
      class markerColorText : RscStructuredText
      {
        idc = 1104;
        x = 0.3 * safezoneW + safezoneX;
        y = 0.1239 * safezoneH + safezoneY;
        w = 0.09 * safezoneW;
        h = 0.0255 * safezoneH;
        sizeEx = 0.65 * GUI_GRID_H;
        colorBackground[] = {0.60, 0.60, 0.60, 1.00};
        text = "<t size='0.65' t align='center' t font='PuristaBold'>Default Marker Color  </t>  ";
      };
      class markerColorOPFOR : RscText
      {
        idc = 1002;
        x = 0.30 * safezoneW + safezoneX;
        y = 0.16 * safezoneH + safezoneY;
        w = 0.07 * safezoneW;
        h = 0.02 * safezoneH;
        colorBackground[] = {0.50, 0.00, 0.00, 1.00};
        colorShadow[] = {0.00, 0.00, 0.00, 0.50};
      };
      class checkboxOPFOR : RscCheckbox
      {
        idc = 2800;
        x = 0.3768 * safezoneW + safezoneX;
        y = 0.1614 * safezoneH + safezoneY;
        w = 0.01 * safezoneW;
        h = 0.02 * safezoneH;
        onCheckedChanged = "[_this select 0, _this select 1, 'ColorEAST'] call MM_fnc_selectMTIMarkerColor;";
        textureFocusedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureFocusedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        textureHoverChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureHoverUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        texturePressedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        texturePressedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        textureDisabledChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureDisabledUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        colorHover[] = {1.00, 1.00, 1.00, 1.00};
        colorFocused[] = {1.00, 1.00, 1.00, 1.00};
        colorPressed[] = {1.00, 1.00, 1.00, 1.00};
        colorBackgroundHover[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundFocused[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundPressed[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.00};
      };
      class markerColorCIV : RscText
      {
        idc = 1003;
        x = 0.30 * safezoneW + safezoneX;
        y = 0.19 * safezoneH + safezoneY;
        w = 0.07 * safezoneW;
        h = 0.02 * safezoneH;
        colorBackground[] = {0.40, 0.00, 0.50, 1.00};
        colorShadow[] = {0.00, 0.00, 0.00, 0.50};
      };
      class checkboxCIV : RscCheckbox
      {
        idc = 2801;
        x = 0.3768 * safezoneW + safezoneX;
        y = 0.1914 * safezoneH + safezoneY;
        w = 0.01 * safezoneW;
        h = 0.02 * safezoneH;
        onCheckedChanged = "[_this select 0, _this select 1, 'ColorCIV'] call MM_fnc_selectMTIMarkerColor;";
        textureFocusedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureFocusedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        textureHoverChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureHoverUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        texturePressedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        texturePressedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        textureDisabledChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureDisabledUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        colorHover[] = {1.00, 1.00, 1.00, 1.00};
        colorFocused[] = {1.00, 1.00, 1.00, 1.00};
        colorPressed[] = {1.00, 1.00, 1.00, 1.00};
        colorBackgroundHover[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundFocused[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundPressed[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.00};
      };
      class checkboxUNKNOWN : RscCheckbox
      {
        idc = 2802;
        x = 0.3768 * safezoneW + safezoneX;
        y = 0.2214 * safezoneH + safezoneY;
        w = 0.01 * safezoneW;
        h = 0.02 * safezoneH;
        onCheckedChanged = "[_this select 0, _this select 1, 'ColorUNKNOWN'] call MM_fnc_selectMTIMarkerColor;";
        textureFocusedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureFocusedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        textureHoverChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureHoverUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        texturePressedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        texturePressedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        textureDisabledChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureDisabledUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        colorHover[] = {1.00, 1.00, 1.00, 1.00};
        colorFocused[] = {1.00, 1.00, 1.00, 1.00};
        colorPressed[] = {1.00, 1.00, 1.00, 1.00};
        colorBackgroundHover[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundFocused[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundPressed[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.00};
      };
      class markerColorUNKNOWN : RscText
      {
        idc = 1004;
        x = 0.30 * safezoneW + safezoneX;
        y = 0.22 * safezoneH + safezoneY;
        w = 0.07 * safezoneW;
        h = 0.02 * safezoneH;
        colorBackground[] = {0.70, 0.60, 0.00, 1.00};
        colorShadow[] = {0.00, 0.00, 0.00, 0.50};
      };
      class markerColorGUER : RscText
      {
        idc = 1005;
        x = 0.30 * safezoneW + safezoneX;
        y = 0.25 * safezoneH + safezoneY;
        w = 0.07 * safezoneW;
        h = 0.02 * safezoneH;
        colorBackground[] = {0.00, 0.50, 0.00, 1.00};
        colorShadow[] = {0.00, 0.00, 0.00, 0.50};
      };
      class checkboxGUER : RscCheckbox
      {
        idc = 2803;
        x = 0.3768 * safezoneW + safezoneX;
        y = 0.2514 * safezoneH + safezoneY;
        w = 0.01 * safezoneW;
        h = 0.02 * safezoneH;
        onCheckedChanged = "[_this select 0, _this select 1, 'ColorGUER'] call MM_fnc_selectMTIMarkerColor;";
        textureFocusedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureFocusedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        textureHoverChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureHoverUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        texturePressedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        texturePressedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        textureDisabledChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureDisabledUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        colorHover[] = {1.00, 1.00, 1.00, 1.00};
        colorFocused[] = {1.00, 1.00, 1.00, 1.00};
        colorPressed[] = {1.00, 1.00, 1.00, 1.00};
        colorBackgroundHover[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundFocused[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundPressed[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.00};
      };
      class checkboxBLUFOR : RscCheckbox
      {
        idc = 2804;
        x = 0.3768 * safezoneW + safezoneX;
        y = 0.2814 * safezoneH + safezoneY;
        w = 0.01 * safezoneW;
        h = 0.02 * safezoneH;
        onCheckedChanged = "[_this select 0, _this select 1, 'ColorWEST'] call MM_fnc_selectMTIMarkerColor;";
        textureFocusedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureFocusedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        textureHoverChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureHoverUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        texturePressedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        texturePressedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        textureDisabledChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
        textureDisabledUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
        colorHover[] = {1.00, 1.00, 1.00, 1.00};
        colorFocused[] = {1.00, 1.00, 1.00, 1.00};
        colorPressed[] = {1.00, 1.00, 1.00, 1.00};
        colorBackgroundHover[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundFocused[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundPressed[] = {0.00, 0.00, 0.00, 0.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.00};
      };
      class markerColorBLUFOR : RscText
      {
        idc = 1006;
        x = 0.30 * safezoneW + safezoneX;
        y = 0.28 * safezoneH + safezoneY;
        w = 0.07 * safezoneW;
        h = 0.02 * safezoneH;
        colorBackground[] = {0.00, 0.30, 0.60, 1.00};
        colorShadow[] = {0.00, 0.00, 0.00, 0.50};
      };
      class markerRenamingText : RscStructuredText
      {
        idc = 1105;
        x = 0.44 * safezoneW + safezoneX;
        y = 0.1239 * safezoneH + safezoneY;
        w = 0.0928 * safezoneW;
        h = 0.0281 * safezoneH;
        sizeEx = 0.65 * GUI_GRID_H;
        colorBackground[] = {0.60, 0.60, 0.60, 1.00};
        text = "<t size='0.65' t align='center' t font='PuristaBold'>Marker Renaming  </t>  ";
      };
      class markerClickRenameButton : RscButton
      {
        idc = 1608;
        style = 0x02;
        x = 0.44 * safezoneW + safezoneX;
        y = 0.1839 * safezoneH + safezoneY;
        w = 0.0928 * safezoneW;
        h = 0.0407 * safezoneH;
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        text = "via Map Click";
        onButtonClick = "[getConnectedUAV player, false, '', 'TEXT HERE'] spawn MM_fnc_renameMarker; [] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class markerSearchRenameButton : RscButton
      {
        idc = 1609;
        style = 0x02;
        x = 0.44 * safezoneW + safezoneX;
        y = 0.2487 * safezoneH + safezoneY;
        w = 0.0928 * safezoneW;
        h = 0.0407 * safezoneH;
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        text = "via Marker Name";
        onButtonClick = "[] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class allPlayersText : RscStructuredText
      {
        idc = 1106;
        x = 0.30 * safezoneW + safezoneX;
        y = 0.57 * safezoneH + safezoneY;
        w = 0.0928125 * safezoneW;
        h = 0.022 * safezoneH;
        sizeEx = 0.65 * GUI_GRID_H;
        colorBackground[] = {0.60, 0.60, 0.60, 1.00};
        text = "<t size='0.65' t align='center' t font='PuristaBold'>All Players  </t>  ";
      };
      class MTIRecipientsText : RscStructuredText
      {
        idc = 1107;
        x = 0.44 * safezoneW + safezoneX;
        y = 0.57 * safezoneH + safezoneY;
        w = 0.0928125 * safezoneW;
        h = 0.022 * safezoneH;
        sizeEx = 0.65 * GUI_GRID_H;
        colorBackground[] = {0.60, 0.60, 0.60, 1.00};
        text = "<t size='0.65' t align='center' t font='PuristaBold'>MTI Recipients </t>  ";
      };
      class lbAllPlayers : RscListbox
      {
        idc = 1500;
        style = 0x10;
        x = 0.30 * safezoneW + safezoneX;
        y = 0.60 * safezoneH + safezoneY;
        w = 0.0928125 * safezoneW;
        h = 0.352 * safezoneH;
        sizeEx = 0.7 * GUI_GRID_H;
        colorSelect[] = {0.00, 0.00, 0.00, 1.00};
        colorShadow[] = {0.00, 0.00, 0.00, 0.50};
        soundSelect[] = {"\A3\ui_f\data\sound\RscListbox\soundSelect", 0.09, 1};
        colorSelect2[] = {0.00, 0.00, 0.00, 1.00};
        colorSelectBackground[] = {0.95, 0.95, 0.95, 1.00};
        colorSelectBackground2[] = {1.00, 1.00, 1.00, 0.50};
        colorScrollbar[] = {1.00, 0.00, 0.00, 0.00};
        colorPicture[] = {1.00, 1.00, 1.00, 1.00};
        colorPictureSelected[] = {1.00, 1.00, 1.00, 1.00};
        colorPictureDisabled[] = {1.00, 1.00, 1.00, 0.25};
        rowHeight = 0;
        maxHistoryDelay = 1;
        autoScrollSpeed = -1;
        autoScrollDelay = 5;
        autoScrollRewind = 0;
        arrowEmpty = "#(argb,8,8,3)color(1,1,1,1)";
        arrowFull = "#(argb,8,8,3)color(1,1,1,1)";
      };
      class lbRecipients : RscListbox
      {
        idc = 1501;
        style = 0x10;
        x = 0.44 * safezoneW + safezoneX;
        y = 0.60 * safezoneH + safezoneY;
        w = 0.0928125 * safezoneW;
        h = 0.341 * safezoneH;
        sizeEx = 0.7 * GUI_GRID_H;
        colorSelect[] = {0.00, 0.00, 0.00, 1.00};
        colorShadow[] = {0.00, 0.00, 0.00, 0.50};
        soundSelect[] = {"\A3\ui_f\data\sound\RscListbox\soundSelect", 0.09, 1};
        colorSelect2[] = {0.00, 0.00, 0.00, 1.00};
        colorSelectBackground[] = {0.95, 0.95, 0.95, 1.00};
        colorSelectBackground2[] = {1.00, 1.00, 1.00, 0.50};
        colorScrollbar[] = {1.00, 0.00, 0.00, 0.00};
        colorPicture[] = {1.00, 1.00, 1.00, 1.00};
        colorPictureSelected[] = {1.00, 1.00, 1.00, 1.00};
        colorPictureDisabled[] = {1.00, 1.00, 1.00, 0.25};
        rowHeight = 0;
        maxHistoryDelay = 1;
        autoScrollSpeed = -1;
        autoScrollDelay = 5;
        autoScrollRewind = 0;
        arrowEmpty = "#(argb,8,8,3)color(1,1,1,1)";
        arrowFull = "#(argb,8,8,3)color(1,1,1,1)";
      };
      class pushToRecipientsButton : RscButton
      {
        idc = 1610;
        style = 0x02;
        x = 0.40 * safezoneW + safezoneX;
        y = 0.65 * safezoneH + safezoneY;
        w = 0.0360937 * safezoneW;
        h = 0.022 * safezoneH;
        sizeEx = 1.3 * GUI_GRID_H;
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        text = ">";
        onButtonClick = "[] call MM_fnc_pushToRecipients; [] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class pushFromRecipientsButton : RscButton
      {
        idc = 1611;
        style = 0x02;
        x = 0.40 * safezoneW + safezoneX;
        y = 0.71 * safezoneH + safezoneY;
        w = 0.0360937 * safezoneW;
        h = 0.022 * safezoneH;
        sizeEx = 1.3 * GUI_GRID_H;
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        text = "<";
        onButtonClick = "[] call MM_fnc_pushFromRecipients; [] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class clearRecipientsButton : RscButton
      {
        idc = 1612;
        style = 0x02;
        x = 0.40 * safezoneW + safezoneX;
        y = 0.78 * safezoneH + safezoneY;
        w = 0.0360937 * safezoneW;
        h = 0.044 * safezoneH;
        sizeEx = 1 * GUI_GRID_H;
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        text = "Clear ALL";
        onButtonClick = "[] call MM_fnc_clearRecipients; [] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class currentAltitude : RscText
      {
        idc = 1642;
        style = 0x02 + 0x0C;
        x = 0.09 * safezoneW + safezoneX;
        y = 0.55 * safezoneH + safezoneY;
        w = 0.0979687 * safezoneW;
        h = 0.055 * safezoneH;
        sizeEx = 0.05;
        colorText[] = {0.90, 0.90, 0.90, 1.00};
        colorBackground[] = {0.00, 0.00, 0.00, 0.50};
        colorSelection[] = {0.13, 0.54, 0.21, 1.00};
      };
      class currentAltitudeText : RscStructuredText
      {
        idc = 1641;
        x = 0.09 * safezoneW + safezoneX;
        y = 0.52 * safezoneH + safezoneY;
        w = 0.0979687 * safezoneW;
        h = 0.022 * safezoneH;
        sizeEx = 0.65 * GUI_GRID_H;
        colorBackground[] = {0.60, 0.60, 0.60, 1.00};
        text = "<t size='0.65' t align='center' t font='PuristaBold'>Current Altitude (ft/MSL)  </t>  ";
      };
      class dividerBar2 : RscText
      {
        idc = 1021;
        x = 0.02 * safezoneW + safezoneX;
        y = 0.45 * safezoneH + safezoneY;
        w = 0.24 * safezoneW;
        h = 0.02 * safezoneH;
        colorBackground[] = {0.26, 0.26, 0.26, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.50};
      };
      class markerSelectButton : RscButton
      {
        idc = 1620;
        style = 0x02;
        x = 0.30 * safezoneW + safezoneX;
        y = 0.39 * safezoneH + safezoneY;
        w = 0.09 * safezoneW;
        h = 0.04 * safezoneH;
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        text = "Select Marker";
        onButtonClick = "[getConnectedUAV player] spawn MM_fnc_highlightMarker; [] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class updateMarkerButton : RscButton
      {
        idc = 1621;
        style = 0x02;
        x = 0.30 * safezoneW + safezoneX;
        y = 0.45 * safezoneH + safezoneY;
        w = 0.09 * safezoneW;
        h = 0.04 * safezoneH;
        colorBackground[] = {0.85, 0.85, 0.85, 1.00};
        text = "Update Marker";
        onButtonClick = "[] call MM_fnc_focusDialogCatcher;";
        colorFocused[] = {0.00, 0.00, 0.00, 1.00};
        colorBackgroundDisabled[] = {0.00, 0.00, 0.00, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.00};
        colorBorder[] = {0.00, 0.00, 0.00, 1.00};
        borderSize = 0;
      };
      class markerSideText : RscStructuredText
      {
        idc = 1616;
        x = 0.44 * safezoneW + safezoneX;
        y = 0.35 * safezoneH + safezoneY;
        w = 0.0928125 * safezoneW;
        h = 0.022 * safezoneH;
        sizeEx = 0.65 * GUI_GRID_H;
        colorBackground[] = {0.60, 0.60, 0.60, 1.00};
        text = "<t size='0.65' t align='center' t font='PuristaBold'>Marker Side</t>  ";
      };
      class markerTypeText : RscStructuredText
      {
        idc = 1614;
        x = 0.44 * safezoneW + safezoneX;
        y = 0.44 * safezoneH + safezoneY;
        w = 0.0928125 * safezoneW;
        h = 0.022 * safezoneH;
        sizeEx = 0.65 * GUI_GRID_H;
        colorBackground[] = {0.60, 0.60, 0.60, 1.00};
        text = "<t size='0.65' t align='center' t font='PuristaBold'>Marker Type</t>  ";
      };
      class dividerBar4 : RscText
      {
        idc = 1023;
        x = 0.3 * safezoneW + safezoneX;
        y = 0.53 * safezoneH + safezoneY;
        w = 0.2329 * safezoneW;
        h = 0.02 * safezoneH;
        colorBackground[] = {0.26, 0.26, 0.26, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.50};
      };
      class dividerBar3 : RscText
      {
        idc = 1022;
        x = 0.3 * safezoneW + safezoneX;
        y = 0.32 * safezoneH + safezoneY;
        w = 0.2329 * safezoneW;
        h = 0.02 * safezoneH;
        colorBackground[] = {0.26, 0.26, 0.26, 0.50};
        colorShadow[] = {0.00, 0.00, 0.00, 0.50};
      };
      class markerSideCombo : RscCombo
      {
        idc = 1625;
        style = 0x210;
        x = 0.4607 * safezoneW + safezoneX;
        y = 0.38 * safezoneH + safezoneY;
        w = 0.072 * safezoneW;
        h = 0.04 * safezoneH;
        colorSelect[] = {0.00, 0.00, 0.00, 1.00};
        colorActive[] = {1.00, 0.00, 0.00, 1.00};
        soundSelect[] = {"\A3\ui_f\data\sound\RscCombo\soundSelect", 0.1, 1};
        soundExpand[] = {"\A3\ui_f\data\sound\RscCombo\soundExpand", 0.1, 1};
        soundCollapse[] = {"\A3\ui_f\data\sound\RscCombo\soundCollapse", 0.1, 1};
        colorSelectBackground[] = {1.00, 1.00, 1.00, 0.70};
        colorScrollbar[] = {1.00, 0.00, 0.00, 1.00};
        colorPicture[] = {1.00, 1.00, 1.00, 1.00};
        colorPictureSelected[] = {1.00, 1.00, 1.00, 1.00};
        colorPictureDisabled[] = {1.00, 1.00, 1.00, 0.25};
        wholeHeight = 0.45;
        maxHistoryDelay = 1;
        arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_ca.paa";
        arrowFull = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_active_ca.paa";
        class Items
        {
          class BLUFOR
          {
            default = 1;
            picture = "\a3\ui_f\data\Map\Markers\NATO\b_unknown.paa";
          };
          class REDFOR
          {
            picture = "\a3\ui_f\data\Map\Markers\NATO\o_unknown.paa";
          };
          class INDFOR
          {
            picture = "\a3\ui_f\data\Map\Markers\NATO\n_unknown.paa";
          };
        };
      };
      class markerTypeCombo : RscCombo
      {
        idc = 1626;
        style = 0x210;
        x = 0.4607 * safezoneW + safezoneX;
        y = 0.47 * safezoneH + safezoneY;
        w = 0.072 * safezoneW;
        h = 0.04 * safezoneH;
        colorSelect[] = {0.00, 0.00, 0.00, 1.00};
        colorActive[] = {1.00, 0.00, 0.00, 1.00};
        soundSelect[] = {"\A3\ui_f\data\sound\RscCombo\soundSelect", 0.1, 1};
        soundExpand[] = {"\A3\ui_f\data\sound\RscCombo\soundExpand", 0.1, 1};
        soundCollapse[] = {"\A3\ui_f\data\sound\RscCombo\soundCollapse", 0.1, 1};
        colorSelectBackground[] = {1.00, 1.00, 1.00, 0.70};
        colorScrollbar[] = {1.00, 0.00, 0.00, 1.00};
        colorPicture[] = {1.00, 1.00, 1.00, 1.00};
        colorPictureSelected[] = {1.00, 1.00, 1.00, 1.00};
        colorPictureDisabled[] = {1.00, 1.00, 1.00, 0.25};
        wholeHeight = 0.45;
        rowHeight = 0.04;
        maxHistoryDelay = 1;
        arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_ca.paa";
        arrowFull = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_active_ca.paa";
        class Items
        {
          class unknown
          {
            default = 1;
            picture = "\a3\ui_f\data\Map\Markers\NATO\b_unknown.paa";
          };
            class air
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_air.paa";
            };
            class antiair
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_antiair.paa";
            };
            class armor
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_armor.paa";
            };
            class art
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_art.paa";
            };
            class hq
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_hq.paa";
            };
            class inf
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_inf.paa";
            };
            class installation
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_installation.paa";
            };
            class maint
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_maint.paa";
            };
            class mech_inf
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_mech_inf.paa";
            };
            class med
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_med.paa";
            };
            class mortar
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_mortar.paa";
            };
            class motor_inf
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_motor_inf.paa";
            };
            class naval
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_naval.paa";
            };
            class plane
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_plane.paa";
            };
            class recon
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_recon.paa";
            };
            class service
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_service.paa";
            };
            class support
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_support.paa";
            };
            class uav
            {
              picture = "\a3\ui_f\data\Map\Markers\NATO\b_uav.paa";
            };
        };
      };
  };
};