GRLIB_side_friendly = WEST;																						// Friendly side.

// GRLIB_side_enemy = EAST;																						// Enemy side.
// GRLIB_side_resistance = RESISTANCE;																				// Resistance side.
// GRLIB_side_civilian = CIVILIAN;																					// Civilian side.
// GRLIB_respawn_marker = "respawn";																				// Respawn marker name.
GRLIB_color_friendly = "ColorBLUFOR";																			// Friendly sector marker color.
GRLIB_color_enemy = "ColorOPFOR";																				// Enemy sector marker color.
// GRLIB_color_enemy_bright = "ColorRED";																			// Enemy sector marker color (activated).


show_platoon = true;
show_nametags = true;
nametags_distance = 32;
show_teammates = true;

F_getUnitPositionId = {
	params [ "_unit" ];
	private ["_vvn", "_str"];
	_vvn = vehicleVarName _unit;
	_unit setVehicleVarName "";
	_str = str _unit;
	_unit setVehicleVarName _vvn;
	parseNumber (_str select [(_str find ":") + 1])
};

F_getCommander = {
	private [ "_commanderobj" ];
	_commanderobj = objNull;
	if (!isNil "commandant") then {
		{ if ( _x == commandant ) exitWith { _commanderobj = _x }; } foreach allPlayers;
	};
	_commanderobj
};

waituntil {!isnull (finddisplay 46)};

[] spawn {
	_LoadMenuButtons = {
		_display = _this;
		_KP_TextRank = _display displayctrl 758032;
		_NewButtonsX = ((ctrlPosition _KP_TextRank) select 0) + ((ctrlPosition _KP_TextRank) select 2);
		_KP_GroupList = _display displayctrl 758038;
		_NewButtonsY = (ctrlPosition _KP_GroupList) select 1;
		_NewButtonsW = (ctrlPosition _KP_GroupList select 2)/2;
		_NewButtonsH = (ctrlPosition _KP_GroupList select 3)/4;
		
		_TagButton = _display ctrlCreate['RSCButton', 3001];
		_TagButton ctrlSetPosition [
			_NewButtonsX,
			_NewButtonsY,
			_NewButtonsW,
			_NewButtonsH
		];
		_TagButton ctrlSetText (if (show_nametags) then {"Hide Tags"} else {"Show Tags"});
		_TagButton ctrlCommit 0;
		_TagButton ctrlSetBackgroundColor [0.02,0,0.03,0.6];
		_TagButton ctrlSetEventHandler ['ButtonClick',"
			show_nametags = !show_nametags;
			(_this select 0) ctrlSetText (if (show_nametags) then {'Hide Tags'} else {'Show Tags'});
		"];
		_PlatoonButton = _display ctrlCreate['RSCButton', 3002];
		_PlatoonButton ctrlSetPosition [
			_NewButtonsX,
			_NewButtonsY + _NewButtonsH,
			_NewButtonsW,
			_NewButtonsH
		];
		_PlatoonButton ctrlSetText (if (show_platoon) then {"Hide Platoon"} else {"Show Platoon"});
		_PlatoonButton ctrlCommit 0;
		_PlatoonButton ctrlSetBackgroundColor [0.02,0,0.03,0.6];
		_PlatoonButton ctrlSetEventHandler ['ButtonClick',"
			show_platoon = !show_platoon;
			(_this select 0) ctrlSetText (if (show_platoon) then {'Hide Platoon'} else {'Show Platoon'});
		"];
		_MarkerButton = _display ctrlCreate['RSCButton', 3003];
		_MarkerButton ctrlSetPosition [
			_NewButtonsX,
			_NewButtonsY + _NewButtonsH * 2,
			_NewButtonsW,
			_NewButtonsH
		];
		_MarkerButton ctrlSetText (if (show_teammates) then {"Hide Markers"} else {"Show Markers"});
		_MarkerButton ctrlCommit 0;
		_MarkerButton ctrlSetBackgroundColor [0.02,0,0.03,0.6];
		_MarkerButton ctrlSetEventHandler ['ButtonClick',"
			show_teammates = !show_teammates;
			(_this select 0) ctrlSetText (if (show_teammates) then {'Hide Markers'} else {'Show Markers'});
		"];
	};

	_run1 = diag_ticktime;
	_run5 = diag_ticktime;
	_DialogOpened = false;
	while { true } do {
		if (diag_ticktime - _run1 >= 0) then {
			if ( local group player ) then {
				{
					if ( _x getVariable ["GRLIB_squad_color", "MAIN"] != assignedTeam _x ) then {
						_x setVariable ["GRLIB_squad_color", assignedTeam _x, true ];
					};
				} foreach (units group player);
			};
			_run1 = diag_ticktime + 1;
		};
		if (diag_ticktime - _run5 >= 0) then {
			_scanned_units = [ allUnits, { ( alive _x ) && ( side group _x == GRLIB_side_friendly ) } ] call BIS_fnc_conditionalSelect;
			_scanned_units = [ _scanned_units, { (_x == leader group player ) || (_x distance player < nametags_distance) } ] call BIS_fnc_conditionalSelect;
			_scanned_units = [ _scanned_units, { (_x != player) && (( vehicle player ) != ( vehicle _x )) } ] call BIS_fnc_conditionalSelect;
			GRLIB_nametag_units = [] + _scanned_units;

			_scanned_groups = [ allGroups, { ( side _x == side player ) && ( isplayer (leader _x) ) } ] call BIS_fnc_conditionalSelect;
			_scanned_groups = [ _scanned_groups, { ( count units _x > 1 ) || ( count units _x == 1 && leader _x != player ) } ] call BIS_fnc_conditionalSelect;
			GRLIB_overlay_groups = [] + _scanned_groups;
			_run5 = diag_ticktime + 5;
		};
		_display = (finddisplay 75803);
		if (_DialogOpened) then {
			if (isnull _display) then {
				_DialogOpened = false;
			};
		}
		else {
			if (!isnull _display) then {
				_display call _LoadMenuButtons;
				_DialogOpened = true;
			};
		};
		sleep 0.2;
	};
};

[] execvm "ignatz\GREUH_playermarkers.sqf";
[] execvm "ignatz\GREUH_platoonoverlay.sqf";
