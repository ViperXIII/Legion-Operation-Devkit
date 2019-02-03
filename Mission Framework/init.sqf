// Whole map clean script.
if (isServer) then {

	fnc_cleanup = compileFinal preprocessFileLineNumbers "scripts\cleanup.sqf";
	
	null = [
		[worldSize/2,worldSize/2,0],
		worldSize/2,
		100,
		1200
	] spawn fnc_cleanup;
};

// live feed 
// null = [[monitor1,monitor2,monitor3,monitor4],["s1","s2","s3","s4","s5","s6","s7","s8","s9","s10","z1","z2","z3","z4","z5","z6","z7","z8","z9","z10","r1","r2","r3","r4","r5","t1","t2","t3","a1","a2","a3","a4","o1","o2","o3","o4",
// "o5","o6","o7","o8","h1","h2","h3","h4","h5","h6","h7","h8","h9","h10"]] execVM "LFC\Feedinit.sqf";

// player menu
if (hasinterface) then {
	[] execvm "Ignatz\Ignatz_Playerinit.sqf";	
};

//rpt server and player readout
[] spawn {
    _Checkintervall = 30;
    if (isserver) then {
        "FPS_Report" addpublicvariableeventhandler {
            _input = _this select 1;
            diag_log format ["FPS-Check | %1: %2 | LocalUnits: %3 |", _input select 0, _input select 1, _input select 2];
        };
        while {true} do {
            uisleep _Checkintervall;
            diag_log format ["FPS-Checker: ServerFPS: %1 | AllUnits: %2 | LocalUnits: %3 | Players: %4", round diag_fps, {!isplayer _x} count allunits, {local _x} count allUnits, count allplayers];
        };
    }
    else {
        while {true} do {
            uisleep _Checkintervall;
            FPS_Report = [name player, round diag_fps, {local _x} count allUnits];
            publicvariableserver "FPS_Report";
        };    
    };
};