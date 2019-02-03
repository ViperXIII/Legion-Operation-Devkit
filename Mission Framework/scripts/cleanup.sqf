/*

Author: DaVidoSS
name: CleanUp
ver.: 1.3
Description:
Clean up all dead, dropped stuff, ruins, craters around desired point or entire map and remove empty groups. 
You need to define at least one parameter position, marker or object.
To prevent remove some object you need to set an "dnt_remove_me" variable on it using:
this setVariable ["dnt_remove_me",true,false];


Parameter(s):
	0 (Required):
		STRING 	- marker name, or
		ARRAY 	- position in format [x,y,z] or
		OBJECT 	- trigger or any object
	1 (Optional): NUMMBER - Radius for dead stuff search around param 0, if not supplied, 500m will be automatically selected.
	2 (Optional): NUMMBER - Min distance from object to any player. Preventing  player to see disappearing of the object, if not supplied, 300m will be automatically selected.
	3 (Optional): NUMMBER - Vehicle damage above which almost wrecked vehicles without crew will be selected to remove it. If not supplied such vehicles stays in game. Value between 0.1 and 0.9
	4 (Optional): BOOLEAN - Ability to handle with empty groups - true/false. If not supplied false will be selected (disabled)
	5 (Optional): NUMMBER - Sleep time in sec between search if not defined 5 min will be automatically selected.

Returns: Nothing


usage examples:

Example for whole map:

Constantly search entire map with 10min interval.
Objects in player range (100m) will be skipped.
Almost wrecked vehicles without crew stays in game.

if (isServer) then {

	fnc_cleanup = compileFinal preprocessFileLineNumbers "scripts\cleanup.sqf";
	
	null = [
		[worldSize/2,worldSize/2,0],
		worldSize/2,
		100,
		1200
	] spawn fnc_cleanup;
};


Example for marker:

Constantly search entire marker area with 5min interval.
Objects in player range (300m) will be skipped.

if (isServer) then {

	fnc_cleanup = compileFinal preprocessFileLineNumbers "scripts\cleanup.sqf";
	
	null = [
		"marker0",
		((getMarkerSize "marker0") call BIS_fnc_greatestNum)
	] spawn fnc_cleanup;
};

	
Example for object:

Constantly search entire trigger area with 10min interval.
Almost wrecked empty vehicles with damage > 0.8  will be removed.
Objects in player range (500m) will be skipped. 
Empty groups will be removed.

if (isServer) then {

	fnc_cleanup = compileFinal preprocessFileLineNumbers "scripts\cleanup.sqf";
	
	null = [
		_myTrigger,
		((triggerArea _myTrigger) call BIS_fnc_greatestNum),
		500,
		0.8,
		true,
		1200
	] spawn fnc_cleanup;
};


*/

if (!isServer) exitWith {diag_log "** CleanUP: This is no server/host  EXITING!! **"};
scriptName "CleanUp";
params [ ["_anchor", [], [[],"",objNull]], ["_radius", 500, [0]], ["_avoidseeing", 300, [0]], ["_damVeh",nil,[0]], ["_groups", false, [true]], ["_sleep", 600, [0]]];
private _fnc_checkForPlayers = {
	params [["_object", objNull, [objNull, grpNull]],["_area", 0, [0]]];
	private _stdOut = false;
	private _players = allUnits select {isPlayer _x && {!(_x isKindOf "HeadlessClient_F")}};
	if ((typeName _object) isEqualTo "GROUP") exitWith {(_stdOut)};
	private _pos = (getPos _object);
	{if ((_pos distance _x) < _area) exitWith {_stdOut = true}} forEach _players;
	(_stdOut)
};
while {true} do {
	if ((typeName _anchor) == "STRING") then {_anchor = (getMarkerPos _anchor)};
	if ((typeName _anchor) == "OBJECT") then {_anchor = (getPos _anchor)};		
	private _szrot = (allMissionObjects "WeaponHolder")+(allMissionObjects "GroundWeaponHolder")+
	(allMissionObjects "WeaponHolderSimulated")+(allMissionObjects "#crater")+(allDead);
	if !(isNil "_damVeh") then {_szrot = _szrot + (vehicles select { (damage _x > _damVeh || {!canMove _x}) && {(count (crew _x)) isEqualTo 0}})};
	if (_groups) then {_szrot = _szrot + allGroups};
	{if ((typeName _x) isEqualTo "GROUP") then {if ((count (units _x)) isEqualTo 0) then {deleteGroup _x}} else {
	if !([_x, _avoidseeing] call _fnc_checkForPlayers) then {if (isNil {_x getVariable "dnt_remove_me"}) then {
	if ((position _x) inArea [_anchor, _radius, _radius, 360, false, -1]) then {deleteVehicle _x}}}}} forEach _szrot;
	sleep _sleep;
};