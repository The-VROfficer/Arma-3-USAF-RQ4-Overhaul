params
[
    ["_onButtonClick",""],
    ["_textPrompt",""]
];
private _eh = format ["
                    private _display = findDisplay 1251;
                    private _textInput = ctrlText (_display displayCtrl 1002);
                    uiNamespace setVariable [""%1"",_textInput];
                    closeDialog 1;",
_onButtonClick];

private _uav = getConnectedUAV player;
if(isNull _uav) exitWith {};

createDialog "RQ4_textEntryDialog";
private _display = findDisplay 1251;

private _textPromptBox = _display displayCtrl 1602;
private _enterButton = _display displayCtrl 1600;

_enterButton ctrlAddEventHandler ["ButtonClicked",_eh];
_textPromptBox ctrlSetStructuredText (parseText format ["<t size='1.3' t align='center' t font='PuristaBold'>%1   </t>  ",_textPrompt]);
