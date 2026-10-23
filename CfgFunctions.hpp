class CfgFunctions
{
    class MM
    {
        tag = "MM";
        class BACN
        {
            file = "\x\usaf_rq4a_tweak_v2\Functions\BACN";

            class addActionToPlayer {};
            class bacnACREAmplify {};
            class bacnConnectAction {};
            class checkBACNLOS {};
            class checkCommSysType {};
            class setupBACN {};
        };
        class MTI
        {
			file = "\x\usaf_rq4a_tweak_v2\Functions\MTI";

			class applyPoD {};
            class collectMTI {};
            class clientMarkerUpdate {};
            class clientTrackDotUpdate {};
			class createMTIMarker {};
            //class drawFOR {};
            class drawGRCA {};
			class fadeMarker {};
            class genericFilter {};
            class handleFOR {};
            class handleMTIMarker {};
            class handlePilot {};
            class radarScan {};
            class highlightMarker {};
            class slewSensor {};
            class updateMTIMarker {};
        };
		class GUI
		{
			file = "\x\usaf_rq4a_tweak_v2\Functions\GUI";
			class clearRecipients {};
			class executeFlightControls {};
			class focusDialogCatcher {};
			class findUpcomingLoiterWaypoint {};
			class onDialogUnload {};
			class openDialog {};
			class pushFromRecipients {};
			class pushToRecipients {};
			class refreshPlayerLists {};
			class selectMTIMarkerColor {};
			class setSlewSide {};
			class toggleSensorState {};
		};
    };
};