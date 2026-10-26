/*
	Author: Myth

	Description: Enables the usage of RPT debugging tools without the need for CBA script_component bullshit. Writes to server/host's RPT file only.
*/

// Type #define DEBUG_ENABLED' below to enable/disable RPT debug messages in ALL functions!
#define DEBUG_ENABLED

#ifdef DEBUG_ENABLED
    #define DEBUG_RPT(MSG,CURFUNC)\
        [MSG, CURFUNC, [false, true, false]] call CBA_fnc_debug;

    #define ERROR_RPT(MSG,CURFUNC)\
        ["ERROR: " + MSG, CURFUNC, [false, true, false]] call CBA_fnc_debug;

#else
    #define DEBUG_RPT(MSG,CURFUNC) ""
    #define ERROR_RPT(MSG,CURFUNC) ""
#endif
