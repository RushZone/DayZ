private ["_item","_config","_text","_booleans","_worldspace","_dir","_location","_fire","_tool","_itemPile","_finished"];

_tool = _this;
call gear_ui_init;
closeDialog 0;

if (dayz_actionInProgress) exitWith { localize "str_player_actionslimit" call dayz_rollingMessages; };
dayz_actionInProgress = true;

_item = "ItemLog";
_itemPile = "PartWoodPile";
_config = configFile >> "CfgMagazines" >> _item;
_text = getText (_config >> "displayName");

// item is missing or tools are missing
if (!(_item in magazines player) && !(_itemPile in magazines player)) exitWith {
	localize "str_player_22" call dayz_rollingMessages;
	dayz_actionInProgress = false;
};

_booleans = []; //testonLadder, testSea, testPond, testBuilding, testSlope, testDistance
_worldspace = ["Land_Fire_DZ", player, _booleans] call fn_niceSpot;

// player on ladder or in a vehicle
if (_booleans select 0) exitWith {
	localize "str_player_21" call dayz_rollingMessages;
	dayz_actionInProgress = false;
};

// object would be in the water (pool or sea)
if ((_booleans select 1) OR (_booleans select 2)) exitWith {
	localize "str_player_26" call dayz_rollingMessages;
	dayz_actionInProgress = false;
};

if ((count _worldspace) == 2) then {
	[player,20,true,(getPosATL player)] call player_alertZombies;
	
	_finished = ["Medic",1] call fn_loopAction;
	if (!_finished or (!(_item in magazines player) && !(_itemPile in magazines player))) exitWith {};
	
	if (_item in magazines player) then {
		player removeMagazine _item;
	} else {
		player removeMagazine _itemPile;
	};
	_dir = _worldspace select 0;
	_location = _worldspace select 1;

	// fireplace location may not be in front of player (but in 99% time it should)
	player setDir _dir;
	player setPosATL (getPosATL player);

	// Added Nutrition-Factor for work
	["Working",0,[20,40,15,0]] call dayz_NutritionSystem;

	_fire = createVehicle ["Land_Fire_DZ", [0,0,0], [], 0, "CAN_COLLIDE"];
	_fire setDir _dir;
	_fire setPos _location; // follow terrain slope
	player reveal _fire;
	[_fire,true] call dayz_inflame;
	_fire spawn player_fireMonitor;
	
	/*if (dayz_playerAchievements select 14 < 1) then {
	// Firestarter
		dayz_playerAchievements set [14,1];
		achievement = [14, player, dayz_characterID];
		publicVariableServer "achievement";
	};*/
	localize "str_fireplace_01" call dayz_rollingMessages;
} else {
	localize "str_fireplace_02" call dayz_rollingMessages;
};

dayz_actionInProgress = false;