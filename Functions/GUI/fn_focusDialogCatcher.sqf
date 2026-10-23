/*
    Author: Waylen

    Locality: Client

    Description:
        Moves keyboard focus to the dedicated focus-catcher control in the RQ4
        sensor-control dialog after a button is clicked. This prevents the
        previously clicked button from continuing to flash.

    Parameter(s):
        None.

    Returns:
        Nothing.

    Examples:
        onButtonClick = "[] call MM_fnc_focusDialogCatcher;";

    NOTE - The focus-catcher control is idc 1699 in display 1250. Call this
    function after any button-specific action so the focus change happens last.
*/

disableSerialization;

private _display = findDisplay 1250;
if (isNull _display) exitWith {};

private _focusCatcher = _display displayCtrl 1699;
if (isNull _focusCatcher) exitWith {};

ctrlSetFocus _focusCatcher;
