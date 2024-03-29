waitUntil {time > 1};
waitUntil {!isNil "GRLIB_all_fobs"};
waitUntil {!isNil "save_is_loaded"};
waitUntil {save_is_loaded};

if (count GRLIB_all_fobs == 0) then {

    if (GRLIB_build_first_fob) then {
        _potentialplaces = [];
        {
            _nextsector = _x;
            _acceptsector = true;
            {
                if (((markerPos _nextsector) distance (markerPos _x)) < 800) then {
                    _acceptsector = false;
                };
            } foreach sectors_allSectors;

            if (_acceptsector) then {
                _potentialplaces pushBack _nextsector;
            };
        } foreach sectors_opfor;

        _spawnplace = selectRandom _potentialplaces;
        [markerPos _spawnplace, true] remoteExec ["build_fob_remote_call",2];
    } else {
        private _fobbox = objNull;

        while {count GRLIB_all_fobs == 0} do {
            _barge = KP_liberation_boat1_classname createVehicle (getposATL barge);
            _barge setDir getdIR barge;
            _barge setposATL (getposATL barge);
            _fobbox = ([FOB_box_typename, FOB_truck_typename] select KP_liberation_fob_vehicle) createVehicle (getposATL base_boxspawn);
            _fobbox setdir getDir base_boxspawn;
            _fobbox setposATL (getposATL base_boxspawn);
            _barge setVehicleCargo _fobbox;

            clearWeaponCargoGlobal _fobbox;
            clearMagazineCargoGlobal _fobbox;
            clearBackpackCargoGlobal _fobbox;
            clearItemCargoGlobal _fobbox;

            if (!KP_liberation_fob_vehicle) then {
                _fobbox call F_setFobMass;
                // Add ViV actions to FOB Box
                [_fobBox] remoteExecCall ["F_setLoadableViV", 0, _fobBox];
            };

            sleep 3;

            waitUntil {
                sleep 1;
                _bardist = _barge distance barge;
                !(alive _fobbox) || !(alive _barge) || !(_bardist < 120) || ((count GRLIB_all_fobs) > 0) || (((getPosASL _fobbox) select 2) < 0)
            };
            sleep 15;
        };
        deleteVehicle _fobbox;
        deleteVehicle _barge;
    };

    waitUntil {sleep 5; (count GRLIB_all_fobs) > 0};

    private _crateArray = [];

    uiSleep 10;

    for [{_i = 0;}, {_i < 6}, {_i = _i + 1;}] do {
        private _crate = createVehicle [
            (KP_liberation_crates select (_i % 3)),
            [((GRLIB_all_fobs select 0) select 0), ((GRLIB_all_fobs select 0) select 1), 150],
            [],
            80,
            "FLY"
        ];
        clearWeaponCargoGlobal _crate;
        clearMagazineCargoGlobal _crate;
        clearItemCargoGlobal _crate;
        clearBackpackCargoGlobal _crate;
        _crate setVariable ["KP_liberation_crate_value", 100, true];
        [_crate, 500] remoteExec ["F_setMass",_crate];
        [objNull, _crate] call BIS_fnc_curatorObjectEdited;
        if(KP_liberation_ace) then {[_crate, true, [0, 1.5, 0], 0] remoteExec ["ace_dragging_fnc_setCarryable"];};
        _crateArray pushBack _crate;
    };
    uiSleep 25;
    {
        private _smoke = "SmokeShellGreen" createVehicle (getPos _x);
        _smoke attachTo [_x];
    } forEach _crateArray;
};
