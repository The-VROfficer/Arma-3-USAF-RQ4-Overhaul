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
            class drawGRCA {};
            class fadeMarkerLocal {};
            class genericFilter {};
            class handleFadeMarker {};
            class handleFOR {};
            class handleMTIMarker {};
            class handlePilot {};
            class highlightMarker {};
            class radarScan {};
            class readdGRCA {};
            class renameMarker {};
            class slewSensor {};
            class updateMTIMarker {};
        };
		class GUI
		{
			file = "\x\usaf_rq4a_tweak_v2\Functions\GUI";
			class clearRecipients {};
			class executeFlightControls {};
            class findMarkerViaName {};
            class findUpcomingLoiterWaypoint {};
			class focusDialogCatcher {};
			class onDialogUnload {};
			class openDialog {};
            class openTextEntryDialog {};
			class pushFromRecipients {};
			class pushToRecipients {};
			class refreshPlayerLists {};
			class selectMTIMarkerColor {};
			class setSlewSide {};
            class toggleFOR {};
            class toggleMTIMode {};
            class toggleSensorState {};
            class updateMarker {};
		};
    };
};