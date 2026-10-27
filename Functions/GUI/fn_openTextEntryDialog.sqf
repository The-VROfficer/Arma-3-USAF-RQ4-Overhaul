params
[
    ["_onButtonClick",""],
    ["_textPrompt",""]
];

private _suffix = "<t size='1.3'><t align='center' t font='PuristaBold'>";
private _prefix = "   </t>  ";
private _ehPrefix = "private _display = findDisplay 1251;
                     private _textInput = ctrlText (_display displayCtrl 1002);"
private _ehSuffix = "closeDialog 1;";

private _uav = getConnectedUAV player;
if(isNull _uav) exitWith {};

createDialog "RQ4_textEntryDialog";
private _display = findDisplay 1251;

private _textPromptBox = _display displayCtrl 1002;
private _enterButton = _display displayCtrl 1600;

_enterButton ctrlAddEventHandler ["ButtonClicked",(_ehPrefix + _onButtonClick + _ehSuffix)];
_textPromptBox = ctrlSetStructuredText _prefix + _textPrompt + _suffix;
