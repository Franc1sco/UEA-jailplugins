/* 2.8.0
* AWPs congeladoras azules e independientes
* Médico solo CTs
* Código más ordenado
* Ser Amado quita menos vida y muere si lo tocas.
* Arreglado un bug que no te dejaba tirar los dados
* Arreglado un bug con el que podías resucitar siendo espectador
* Arreglado un bug que no permitía hacer daño
*/

/* 2.8.1
* Arreglados errores con clientes que no estaban en el juego
* Añadido el poder disfrazarse de CT
* Funciones Convertir en algunos dados
* Cambiado el modelo del Ser Amado a Sakura
* Nuevo premio: Ganzua
*/

/* 2.8.2
* Arreglados errores con clientes que no estaban en el juego
* Cambiado el modelo de disfraz de CT
* Quitado el sistema de backup de creditos
* Corregidos errores con las ganzúas que devolvía puertas inválidas
* Arreglados errores con clientes inválidos
* Arreglado un crash al disfrazarse
* Arreglado un error con las AWP Congeladoras
* Corregidos errores al obtener la mitad del coste de los premios
* Arreglos en el Santa Claus
* Modelo y Sonidos de Batman
* El médico tiene munición extra
*/

/* 2.8.3
* Quitado el comando !darme
* Aumentado el daño de la Reina  Alien
* Smith solo para Admins CT
* Bicho ígneo solo para Admins T
* Los admins reciben 2 créditos más al matar y al finalizar la ronda
*/

/* ATAJOS
* Buscar: COMANDOS
* Buscar: Final COMANDOS
* Buscar: FUNCIONES
* Buscar: Final FUNCIONES
* Buscar: TRANSFORMACIONES
* Buscar: Final TRANSFORMACIONES
* Buscar: EVENTOS
* Buscar: Final EVENTOS
* Buscar: DADOS
* Buscar: Final DADOS
* Buscar: PREMIOS
* Buscar: Final PREMIOS
*/

/* ==================== INCLUDES ==================== */

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdktools_sound>
#include <cstrike>
#include <lastrequest>
#include <colors>
#include <sdkhooks>
#include <cssthrowingknives>
#include <smlib>

/* ==================== DEFINES ==================== */

#define VERSION "2.8.3"

#define AMP_SHAKE        50.0
#define DUR_SHAKE        1.0

#define AMP_SHAKEG        80.0
#define DUR_SHAKEG        1.0

// damage types
#define DMG_GENERIC										0
#define DMG_CRUSH										(1 << 0)
#define DMG_BULLET										(1 << 1)
#define DMG_SLASH										(1 << 2)
#define DMG_BURN										(1 << 3)
#define DMG_VEHICLE										(1 << 4)
#define DMG_FALL										(1 << 5)
#define DMG_BLAST										(1 << 6)
#define DMG_CLUB										(1 << 7)
#define DMG_SHOCK										(1 << 8)
#define DMG_SONIC										(1 << 9)
#define DMG_ENERGYBEAM									(1 << 10)
#define DMG_PREVENT_PHYSICS_FORCE						(1 << 11)
#define DMG_NEVERGIB									(1 << 12)
#define DMG_ALWAYSGIB									(1 << 13)
#define DMG_DROWN										(1 << 14)
#define DMG_TIMEBASED									(DMG_PARALYZE | DMG_NERVEGAS | DMG_POISON | DMG_RADIATION | DMG_DROWNRECOVER | DMG_ACID | DMG_SLOWBURN)
#define DMG_PARALYZE									(1 << 15)
#define DMG_NERVEGAS									(1 << 16)
#define DMG_POISON										(1 << 17)
#define DMG_RADIATION									(1 << 18)
#define DMG_DROWNRECOVER								(1 << 19)
#define DMG_ACID										(1 << 20)
#define DMG_SLOWBURN									(1 << 21)
#define DMG_REMOVENORAGDOLL								(1 << 22)
#define DMG_PHYSGUN										(1 << 23)
#define DMG_PLASMA										(1 << 24)
#define DMG_AIRBOAT										(1 << 25)
#define DMG_DISSOLVE									(1 << 26)
#define DMG_BLAST_SURFACE								(1 << 27)
#define DMG_DIRECT										(1 << 28)
#define DMG_BUCKSHOT									(1 << 29)

#define Speed 200

//#define MESS "\x04[SM_Franug-JailPlugins] \x05"

#define EXPLODE_SOUND	"ambient/explosions/explode_8.wav"
#define SOUND_FREEZE		"physics/glass/glass_impact_bullet4.wav"

// junto duchas
#define sitio1 {2021.1, 2007.3, 65.0 }
#define sitio2 {1075.0, 2788.0, 171.0}
#define sitio3 {368.5, 2920.1, 626.5}
#define sitio4 {1075.0, 2500.0, 171.0}


// basket
#define sitio5 {2240.0, 2153.0, 171.0}
#define sitio6 {2240.0, 1900.0, 171.0}

// piscina
#define sitio7 {1040.0, 2880.0, 171.0}
#define sitio8 {1040.0, 2400.0, 171.0}
#define sitio9 {-481.0, 3390.0, 171.0}
#define sitio10 {-510.0, 1950.0, 171.0}

// cocina
#define sitio11 {-1125.0, -1870.0, 171.0}
#define sitio12 {-1360.0, -1870.0, 171.0}

// futbol
#define sitio13 {-3550.0, -2220.0, 710.0}
#define sitio14 {-1951.0, -2220.0, 710.0}
#define sitio15 {-3550.0, 160.0, 710.0}
#define sitio16 {-1990.0, 160.0, 710.0}

// ======================================================================
//	HANDLES
// ======================================================================

new Handle:g_hRegenTimer[MAXPLAYERS+1];
new Handle:g_Cvar_Delay = INVALID_HANDLE;
new Handle:hGetWeaponPosition = INVALID_HANDLE;
new Handle:cvarCreditsMax = INVALID_HANDLE;
new Handle:cvarCreditsKill = INVALID_HANDLE;
new Handle:Missile_Predator = INVALID_HANDLE;
new Handle:css_avp_damage;
new Handle:css_avp_radius;
new Handle:css_avp_pushforce;
new Handle:cvarInterval;
new Handle:AmmoTimer;
new Handle:Cvar_Tiempo;
new Handle:Cvar_Miedo;
new Handle:Dados_Usos;
new Handle:Dados_Usados;
new Handle:T_Vivos;
new Handle:CT_Vivos;
new Handle:hPush1;
new Handle:hHeight1;
new Handle:hPush2;
new Handle:hHeight2;
new Handle:hPush3;
new Handle:hHeight3;
new Handle:g_hTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
//new Handle:cvType = INVALID_HANDLE;
//new Handle:cvDelay = INVALID_HANDLE;
new Handle:g_cvJumpBoost;
new Handle:g_cvJumpMax;
new Handle:Timer_AwpFreeze;
new Handle:Dif;
new Handle:RondasEspeciales;

// Zombie
new Handle:HealthZombie;
new Handle:SpeedZombie;
new Handle:CostZombie;

// Monstruo
new Handle:HealthMonstruo;
new Handle:SpeedMonstruo;
new Handle:CostMonstruo;

// Soldado
new Handle:HealthSoldado;
new Handle:SpeedSoldado;
new Handle:CostSoldado;

// Bicho
new Handle:HealthBicho;
new Handle:SpeedBicho;
new Handle:CostBicho;

// Robot
new Handle:HealthRobot;
new Handle:SpeedRobot;
new Handle:CostRobot;

// Ironman
new Handle:HealthIronman;
new Handle:SpeedIronman;
new Handle:CostIronman;

// Reina
new Handle:HealthReina;
new Handle:SpeedReina;
new Handle:CostReina;

// Pikachu
new Handle:HealthPikachu;
new Handle:SpeedPikachu;
new Handle:CostPikachu;

// Spiderman
new Handle:HealthSpiderman;
new Handle:SpeedSpiderman;
new Handle:CostSpiderman;

// Smith
new Handle:HealthSmith;
new Handle:SpeedSmith;
new Handle:CostSmith;

// Goku
new Handle:HealthGoku;
new Handle:SpeedGoku;
new Handle:CostGoku;

// Groudon
new Handle:HealthGroudon;
new Handle:SpeedGroudon;
new Handle:CostGroudon;

// Fantasma
new Handle:CostFantasma;
new Handle:HealthFantasma;

// Predator
new Handle:HealthPredator;
new Handle:SpeedPredator;
new Handle:CostPredator;

// Santa
new Handle:HealthSanta;
new Handle:SpeedSanta;
new Handle:CostSanta;

// Jack
new Handle:HealthJack;
new Handle:SpeedJack;
new Handle:CostJack;

// Entrenador
new Handle:HealthTrainer;
new Handle:SpeedTrainer;
new Handle:CostTrainer;

// Pene
new Handle:HealthPene;
new Handle:CostPene;

// Medico
new Handle:HealthMedic;
new Handle:SpeedMedic;
new Handle:CostMedic;

// Amado
// new Handle:HealthAmado;
// new Handle:SpeedAmado;
// new Handle:CostAmado;

// Batman
new Handle:HealthBatman;
new Handle:SpeedBatman;
new Handle:CostBatman;

// ======================================================================
//	BOOL
// ======================================================================

new bool:g_Explosiva[MAXPLAYERS+1] = {false, ...};
new bool:g_Golpeado[MAXPLAYERS+1] = {false, ...};
new bool:g_Batman[MAXPLAYERS+1] = {false, ...};
new bool:g_Amor[MAXPLAYERS+1] = {false, ...};
new bool:g_Zombie[MAXPLAYERS+1] = {false, ...};
new bool:g_Monster[MAXPLAYERS+1] = {false, ...};
new bool:g_Ironman[MAXPLAYERS+1] = {false, ...};
new bool:g_Robot[MAXPLAYERS+1] = {false, ...};
new bool:g_Bicho[MAXPLAYERS+1] = {false, ...};
new bool:g_Soldado[MAXPLAYERS+1] = {false, ...};
new bool:g_Spiderman[MAXPLAYERS+1] = {false, ...};
new bool:g_Goku[MAXPLAYERS+1] = {false, ...};
new bool:g_Paloma[MAXPLAYERS+1] = {false, ...};
new bool:g_Gallina[MAXPLAYERS+1] = {false, ...};
new bool:g_Smith[MAXPLAYERS+1] = {false, ...};
new bool:g_Jack[MAXPLAYERS+1] = {false, ...};
new bool:g_Groudon[MAXPLAYERS+1] = {false, ...};
new bool:g_Fantasma[MAXPLAYERS+1] = {false, ...};
new bool:g_Pikachu[MAXPLAYERS+1] = {false, ...};
new bool:g_Medic[MAXPLAYERS+1] = {false, ...};
new bool:g_Predator[MAXPLAYERS+1] = {false, ...};
new bool:g_Santa[MAXPLAYERS+1] = {false, ...};
new bool:g_Reina[MAXPLAYERS+1] = {false, ...};
new bool:g_NoMuerto[MAXPLAYERS+1] = {false, ...};
new bool:g_Trepando[MAXPLAYERS+1] = {false, ...};
new bool:g_Goku2[MAXPLAYERS+1] = {false, ...};
new bool:g_Saltador[MAXPLAYERS+1] = {false, ...};
new bool:g_Noweapons[MAXPLAYERS+1] = {false, ...};
new bool:g_Godmode[MAXPLAYERS+1] = {false, ...};
new bool:g_Usando[MAXPLAYERS+1] = {false, ...};
new bool:g_AmmoInfi[MAXPLAYERS+1] = {false, ...};
new bool:g_Franug[MAXPLAYERS+1] = {false, ...};
new bool:g_cosa[MAXPLAYERS+1] = {false, ...};
new bool:AwpFreeze[2048] = false;
new bool:Ganzua[2048] = false;
new bool:g_RapidFire[MAXPLAYERS+1] = {false, ...};
new bool:conectado[MAXPLAYERS+1] = {false, ...};
new bool:Fin_Ronda = false;
new bool:g_RondaEspecial = false; // Para dados y premios
new bool:g_Trainer[MAXPLAYERS+1] = {false, ...};
new bool:g_Pene[MAXPLAYERS+1] = {false, ...};
new bool:g_Cloak[MAXPLAYERS+1] = {false, ...};
new g_Attachments[MAXPLAYERS + 1] = { 0, ...};
new bool:g_ZResucitar[MAXPLAYERS + 1] = {false, ...};

// ======================================================================
//	INT / STRING / FLOAT
// ======================================================================

new Float:g_flBoost = 250.0;
new Float:iNormal[ 3 ] = { 0.0, 0.0, 1.0 };
new Float:g_fClientLastScale[MAXPLAYERS+1] = {1.0, ... };
new Float:g_fClientCurrentScale[MAXPLAYERS+1] = {1.0, ... };
new Float:g_fClientLastHeadScale[MAXPLAYERS+1] = {1.0, ... };
new Float:g_fClientCurrentHeadScale[MAXPLAYERS+1] = {1.0, ... };
new g_fLastButtons[MAXPLAYERS+1];
new g_fLastFlags[MAXPLAYERS+1];
new g_iJumps[MAXPLAYERS+1];
new g_iJumpMax;
new String:Arma_Damage_si[30];
new String:Arma_Enuso[30];
new String:Logfile[PLATFORM_MAX_PATH];
new m_iFOV;
new g_iCredits[MAXPLAYERS+1] = 0;
new g_iMedicHeal[MAXPLAYERS+1] = 0;
new g_Golpes[MAXPLAYERS+1] = 0;
new activeOffset = -1;
new clip1Offset = -1;
new clip2Offset = -1;
new PrimaryAmmoOff = -1;
new secAmmoTypeOffset = -1;
new priAmmoTypeOffset = -1;
new String:g_MapName[128];
new String: weaponIDG[30];
new VelocityOffset_0;
new VelocityOffset_1;
new BaseVelocityOffset;
new iEnt;
new String:doorlist[][] = {
	
	"func_door",
	"func_rotating",
	"func_door_rotating",
	"func_movelinear",
	"prop_door",
	"prop_door_rotating",
	"func_tracktrain",
	"func_elevator",
	"\0"
};

new g_BeamSprite;
new g_HaloSprite;
new g_ExplosionSprite;
new g_SmokeSprite;
new g_LightningSpriter;

new redColor[4]		= {255, 75, 75, 255};
// new orangeColor[4]	= {255, 128, 0, 255};
// new greenColor[4]	= {75, 255, 75, 255};
new blueColor[4]	= {75, 75, 255, 255};
// new whiteColor[4]	= {255, 255, 255, 255};
// new greyColor[4]	= {128, 128, 128, 255};

public Plugin:myinfo =
{
	name = "SM Franug Jail Plugins",
	author = "Franc1sco steam: franug and Xilver steam: donchopo",
	description = "Modo jail especial creado por franug",
	version = VERSION,
	url = "http://servers-cfg.foroactivo.com/"
};

/* ==================== INCLUDES FRANUG ==================== */

#include "franug/bomb.sp"
#include "franug/fuego.sp"
#include "franug/misil.sp"
#include "franug/goku.sp"
#include "franug/jack.sp"
#include "franug/groudon.sp"
#include "franug/rayos.sp"
#include "franug/laser.sp"
#include "franug/regalos.sp"
#include "franug/cvars.sp"
#include "franug/ar.sp"
#include "franug/objetivos.sp"
#include "franug/stock.sp"
// #include "franug/navidad.sp"
#include "franug/amor.sp"

public OnPluginStart()
{
	LoadConVars();
	LoadTranslations("common.phrases");
	BuildPath(Path_SM, Logfile, sizeof(Logfile), "logs/dados.log");
	
	/* ==================== HOOKEVENTS ==================== */
	
	HookEvent("player_spawn", PlayerSpawn, EventHookMode_Pre);
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
	HookEvent("player_hurt", Event_hurt);
	HookEvent("player_jump", PlayerJump);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("weapon_fire", EventWeaponFire);
	HookEvent("player_footstep", PlayerFootstep);
	HookEvent("bullet_impact", BulletImpact);
	
	/* ==================== COMANDOS ==================== */

	RegConsoleCmd("sm_premios", DOMenu);
	RegConsoleCmd("sm_disfraces", DODMH);
	RegConsoleCmd("sm_creditos", VerCreditos);
	RegConsoleCmd("sm_resucitar", Resucitar);
	RegConsoleCmd("sm_zresucitar", ZResucitar);
	RegConsoleCmd("sm_medic", Curarse);
	RegConsoleCmd("sm_enfer", Curarse);
	RegConsoleCmd("sm_doctor", Curarse);
	RegConsoleCmd("drop", Utilidad);
	RegConsoleCmd("sm_bomb", Bumb);
	RegConsoleCmd("sm_detonar", Bumb);	
	RegConsoleCmd("sm_models", Skin);	
	RegConsoleCmd("sm_vercreditos", VerCreditosClient);
	RegConsoleCmd("sm_dar", Dar);
	RegConsoleCmd("sm_gopen", Ganzua_Open);
	RegAdminCmd("sm_normal", Command_Normalizar, ADMFLAG_GENERIC);
	RegAdminCmd("sm_setcredits", FijarCreditos, ADMFLAG_ROOT);
	//RegAdminCmd("sm_resetdb", Command_Clear, ADMFLAG_ROOT);
	//RegAdminCmd("sm_darme", Darme, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_zombie", Zombie, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_amor", Amor, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_predator", Predator, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_groudon", Groudon, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_pikachu", Pikachu, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_monster", Monstruo, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_robot", Robot, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_soldado", Soldado, ADMFLAG_SLAY);	
	RegAdminCmd("sm_pajaro", Paloma, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_ironman", Ironman, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_gallina", Gallina, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_saltador", Saltador, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_goku", Goku, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_soldado", Soldado, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_bomba", Bomba, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_trainer", Trainer, ADMFLAG_CUSTOM2);
	RegAdminCmd("sm_pene", penisc, ADMFLAG_CUSTOM2);	
	RegAdminCmd("sm_ammoinfi", MunicionInfinita, ADMFLAG_CUSTOM2);
	RegConsoleCmd("sm_dados", Lanzar);	
	
	CreateConVar("sm_Franug-JailPlugins", VERSION, "plugin info", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	/* ==================== OFFSETS ==================== */
	
	VelocityOffset_0=FindSendPropOffs("CBasePlayer","m_vecVelocity[0]");
	
	if (VelocityOffset_0==-1)
		SetFailState("[BunnyHop] Error: Failed to find Velocity[0] offset, aborting");
	
	VelocityOffset_1=FindSendPropOffs("CBasePlayer","m_vecVelocity[1]");
	
	if (VelocityOffset_1==-1)
		SetFailState("[BunnyHop] Error: Failed to find Velocity[1] offset, aborting");
	
	BaseVelocityOffset=FindSendPropOffs("CBasePlayer","m_vecBaseVelocity");
	
	if (BaseVelocityOffset==-1)
		SetFailState("[BunnyHop] Error: Failed to find the BaseVelocity offset, aborting");
	
	activeOffset = FindSendPropOffs("CAI_BaseNPC", "m_hActiveWeapon");
	
	clip1Offset = FindSendPropOffs("CBaseCombatWeapon", "m_iClip1");
	clip2Offset = FindSendPropOffs("CBaseCombatWeapon", "m_iClip2");	
	
	PrimaryAmmoOff = FindSendPropOffs("CBaseCombatWeapon", "m_iPrimaryAmmoCount");
	
	g_flBoost = GetConVarFloat(g_cvJumpBoost);
	g_iJumpMax = GetConVarInt(g_cvJumpMax);	
	
	HookConVarChange(g_cvJumpBoost, convar_ChangeBoost);
	HookConVarChange(g_cvJumpMax, convar_ChangeMax);
	
	m_iFOV = FindSendPropOffs("CBasePlayer","m_iFOV");
	
	/* ==================== GAMEDATA ==================== */
	
	new Handle:hGameConf = LoadGameConfigFile("jailplugins.gamedata");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "Weapon_ShootPosition");
	PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByValue);
	hGetWeaponPosition = EndPrepSDKCall();	
	
	/* ==================== ONPLUGINSTART  ==================== */
	
	//OnPluginStart2();
	OnPluginStart13();
	OnPluginStart20();
	//OnPluginStart30();
	OnPluginStart40();
	OnPluginStartpre();
	//OnPluginStartNavidad();
	InicioAR();	
	// Creating DB...
	//InitDB();

	//AutoExecConfig(true, "sm_jailespecial_renew");
	
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_TraceAttack, HookTraceAttack);
	SDKHook(client, SDKHook_Touch, Tocada);
}

public OnMapStart()
{
	g_BeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_HaloSprite = PrecacheModel("materials/sprites/glow01.vmt");
	gHaloS = PrecacheModel("materials/sprites/halo01.vmt");
	gGlow1 = PrecacheModel("sprites/blueglow2.vmt", true);
	gSmoke1 = PrecacheModel("materials/effects/fire_cloud1.vmt");
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");	
	PrecacheSound( EXPLODE_SOUND );
	g_ExplosionSprite = PrecacheModel( "sprites/blueglow2.vmt" );
	g_SmokeSprite = PrecacheModel( "sprites/steam1.vmt" );	
	g_LightningSpriter = PrecacheModel("sprites/lgtning.vmt");
	g_HaloSprite13 = PrecacheModel("materials/sprites/halo01.vmt");	
	

	
	if (AmmoTimer != INVALID_HANDLE) {
		KillTimer(AmmoTimer);
	}
	new Float:interval = GetConVarFloat(cvarInterval);
	AmmoTimer = CreateTimer(interval, ResetAmmo, _, TIMER_REPEAT);
	GetCurrentMap(g_MapName, sizeof(g_MapName));
	
	//OnMapStart2();
	OnMapStart13();
	OnMapStart20();
	InitWeapons();
	InitWeapons10();
	//OnMapStart14();
	OnMapStartR();
	OnMapStartPo();
	OnMapStartpre();
	//OnMapStartNavidad();
	
	PrecacheModel("models/items/cs_gift.mdl");
	
	AddFileToDownloadsTable("materials/models/player/slow/santa_claus/slow_santa.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/santa_claus/slow_santa.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/santa_claus/slow_santa_bump.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/santa_claus/slow_santa_cloth.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/santa_claus/slow_santa_cloth.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/santa_claus/slow_santa_detail.vtf");
	AddFileToDownloadsTable("models/player/slow/santa_claus/slow_fix.dx80.vtx");
	AddFileToDownloadsTable("models/player/slow/santa_claus/slow_fix.dx90.vtx");
	AddFileToDownloadsTable("models/player/slow/santa_claus/slow_fix.mdl");
	AddFileToDownloadsTable("models/player/slow/santa_claus/slow_fix.phy");
	AddFileToDownloadsTable("models/player/slow/santa_claus/slow_fix.sw.vtx");
	AddFileToDownloadsTable("models/player/slow/santa_claus/slow_fix.vvd");
	PrecacheModel("models/player/slow/santa_claus/slow_fix.mdl");
	

	
	PrecacheModel("models/props_interiors/furniture_chair03a.mdl");
	AddFileToDownloadsTable("sound/misc/horror/the_horror2.wav");
	PrecacheSound("misc/horror/the_horror2.wav");

	AddFileToDownloadsTable("sound/UEA/anarquista/volador.wav");
	PrecacheSound("UEA/anarquista/volador.wav");
	
	//AddFileToDownloadsTable("sound/lduke/chicken/chicken.wav");
	//PrecacheSound("lduke/chicken/chicken.wav");
	
	AddFileToDownloadsTable("sound/lduke/chicken/chicken.wav");
	PrecacheSound("lduke/chicken/chicken.wav");
	
	AddFileToDownloadsTable("sound/franug/i_am_ironman.mp3");
	PrecacheSound("franug/i_am_ironman.mp3");
	
	AddFileToDownloadsTable("sound/franug/teleport.wav");
	PrecacheSound("franug/teleport.wav");
	
	/*
	AddFileToDownloadsTable("sound/franug/aura.wav");
	PrecacheSound("franug/aura.wav");
*/
	
	AddFileToDownloadsTable("sound/crosshair/alarm.wav");
	PrecacheSound("crosshair/alarm.wav");
	
	AddFileToDownloadsTable("sound/medicsound/medic.wav");
	PrecacheSound("medicsound/medic.wav");
	
	AddFileToDownloadsTable("materials/models/lduke/chicken/chicken2.vmt");
	AddFileToDownloadsTable("materials/models/lduke/chicken/chicken2.vtf");
	AddFileToDownloadsTable("models/lduke/chicken/chicken2.dx80.vtx");
	AddFileToDownloadsTable("models/lduke/chicken/chicken2.dx90.vtx");
	AddFileToDownloadsTable("models/lduke/chicken/chicken2.mdl");
	AddFileToDownloadsTable("models/lduke/chicken/chicken2.phy");
	AddFileToDownloadsTable("models/lduke/chicken/chicken2.sw.vtx");
	AddFileToDownloadsTable("models/lduke/chicken/chicken2.vvd");
	PrecacheModel("models/lduke/chicken/chicken2.mdl");

	AddFileToDownloadsTable("models/player/techknow/ironman_v3/ironman3.dx80.vtx");
	AddFileToDownloadsTable("models/player/techknow/ironman_v3/ironman3.dx90.vtx");
	AddFileToDownloadsTable("models/player/techknow/ironman_v3/ironman3.mdl");
	AddFileToDownloadsTable("models/player/techknow/ironman_v3/ironman3.phy");
	AddFileToDownloadsTable("models/player/techknow/ironman_v3/ironman3.sw.vtx");
	AddFileToDownloadsTable("models/player/techknow/ironman_v3/ironman3.vvd");
	
	AddFileToDownloadsTable("materials/models/player/techknow/ironman_v3/body.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/ironman_v3/body.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/ironman_v3/body_n.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/ironman_v3/flame.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/ironman_v3/flame.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/ironman_v3/head.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/ironman_v3/head.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/ironman_v3/head_n.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/ironman_v3/sphere.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/ironman_v3/sphere.vtf");
	PrecacheModel("models/player/techknow/ironman_v3/ironman3.mdl");
	
	AddFileToDownloadsTable("materials/models/player/slow/trenchcoat/slow_body.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/trenchcoat/slow_body.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/trenchcoat/slow_head.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/trenchcoat/slow_holster.vmt");
	AddFileToDownloadsTable("models/player/slow/trenchcoat/slow.dx80.vtx");
	AddFileToDownloadsTable("models/player/slow/trenchcoat/slow.dx90.vtx");
	AddFileToDownloadsTable("models/player/slow/trenchcoat/slow.mdl");
	AddFileToDownloadsTable("models/player/slow/trenchcoat/slow.phy");
	AddFileToDownloadsTable("models/player/slow/trenchcoat/slow.sw.vtx");
	AddFileToDownloadsTable("models/player/slow/trenchcoat/slow.vvd");

	AddFileToDownloadsTable("models/mapeadores/morell/ash/ash.mdl");
	AddFileToDownloadsTable("models/mapeadores/morell/ash/ash.dx80.vtx");
	AddFileToDownloadsTable("models/mapeadores/morell/ash/ash.dx90.vtx");
	AddFileToDownloadsTable("models/mapeadores/morell/ash/ash.phy");
	AddFileToDownloadsTable("models/mapeadores/morell/ash/ash.sw.vtx");
	AddFileToDownloadsTable("models/mapeadores/morell/ash/ash.vvd");
	AddFileToDownloadsTable("models/mapeadores/morell/ash/ash.xbox.vtx");

	AddFileToDownloadsTable("materials/mapeadores/morell/ash/Ash_Body.vmt");
	AddFileToDownloadsTable("materials/mapeadores/morell/ash/Ash_Body.vtf");
	AddFileToDownloadsTable("materials/mapeadores/morell/ash/Ash_Eye.vmt");
	AddFileToDownloadsTable("materials/mapeadores/morell/ash/Ash_Eye.vtf");
	PrecacheModel("models/mapeadores/morell/ash/ash.mdl");

	PrecacheModel("models/props/slow/joe100/dick/slow.mdl");

	AddFileToDownloadsTable("sound/franug/invencible.mp3");
	PrecacheSound("franug/invencible.mp3");

	AddFileToDownloadsTable("sound/franug/amor.mp3");
	PrecacheSound("franug/amor.mp3");

	AddFileToDownloadsTable("sound/franug/amor_logrado.mp3");
	PrecacheSound("franug/amor_logrado.mp3");

	PrecacheModel("models/mapeadores/morell/sakura/sakura.mdl");
	
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/drone_arms.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/drone_arms.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/drone_arms_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/drone_head.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/drone_head.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/drone_head_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/drone_legs.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/drone_legs.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/drone_legs_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/drone_torso.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/drone_torso.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/drone_torso_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/slow_alien_blood.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/slow_alien_blood.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/slow_alien_gebiss.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/slow_alien_gebiss.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/slow_alien_gebiss_bump.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/slow_alien_schwanz.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/aliendrone_v3/slow_alien_schwanz.vtf");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien.dx80.vtx");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien.dx90.vtx");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien.mdl");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien.phy");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien.sw.vtx");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien.vvd");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien.xbox.vtx");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien_head.dx80.vtx");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien_head.dx90.vtx");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien_head.mdl");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien_head.phy");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien_head.sw.vtx");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien_head.vvd");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien_head.xbox.vtx");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien_hs.dx80.vtx");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien_hs.dx90.vtx");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien_hs.mdl");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien_hs.phy");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien_hs.sw.vtx");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien_hs.vvd");
	AddFileToDownloadsTable("models/player/slow/aliendrone_v3/slow_alien_hs.xbox.vtx");
	
	PrecacheModel("models/player/slow/aliendrone_v3/slow_alien.mdl");
	PrecacheModel("models/player/slow/aliendrone_v3/slow_alien_head.mdl");
	PrecacheModel("models/player/slow/aliendrone_v3/slow_alien_hs.mdl");	
	
	AddFileToDownloadsTable("materials/models/player/techknow/ferno/ferno.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/ferno/ferno.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/ferno/ferno_n.vtf");
	AddFileToDownloadsTable("models/player/techknow/ferno/ferno.dx80.vtx");
	AddFileToDownloadsTable("models/player/techknow/ferno/ferno.dx90.vtx");
	AddFileToDownloadsTable("models/player/techknow/ferno/ferno.mdl");
	AddFileToDownloadsTable("models/player/techknow/ferno/ferno.phy");
	AddFileToDownloadsTable("models/player/techknow/ferno/ferno.sw.vtx");
	AddFileToDownloadsTable("models/player/techknow/ferno/ferno.vvd");
	PrecacheModel("models/player/techknow/ferno/ferno.mdl");
	
	AddFileToDownloadsTable("materials/models/player/avp/alienqueen/torso.vmt");
	AddFileToDownloadsTable("materials/models/player/avp/alienqueen/torso.vtf");
	AddFileToDownloadsTable("materials/models/player/avp/alienqueen/torso_n.vtf");
	AddFileToDownloadsTable("materials/models/player/avp/alienqueen/legs.vtf");
	AddFileToDownloadsTable("materials/models/player/avp/alienqueen/legs.vmt");
	AddFileToDownloadsTable("materials/models/player/avp/alienqueen/legs_n.vtf");
	AddFileToDownloadsTable("materials/models/player/avp/alienqueen/head.vmt");
	AddFileToDownloadsTable("materials/models/player/avp/alienqueen/head.vtf");
	AddFileToDownloadsTable("materials/models/player/avp/alienqueen/head_n.vtf");
	AddFileToDownloadsTable("models/player/avp/alienqueen.dx80.vtx");
	AddFileToDownloadsTable("models/player/avp/alienqueen.dx90.vtx");
	AddFileToDownloadsTable("models/player/avp/alienqueen.mdl");
	AddFileToDownloadsTable("models/player/avp/alienqueen.phy");
	AddFileToDownloadsTable("models/player/avp/alienqueen.sw.vtx");
	AddFileToDownloadsTable("models/player/avp/alienqueen.vvd");
	PrecacheModel("models/player/avp/alienqueen.mdl");
	
	AddFileToDownloadsTable("sound/franug/susto3.wav");
	PrecacheSound("franug/susto3.wav");
	
	AddFileToDownloadsTable("materials/models/player/pil/smith/smithbody.vmt");
	AddFileToDownloadsTable("materials/models/player/pil/smith/smithbody.vtf");
	AddFileToDownloadsTable("materials/models/player/pil/smith/smithbody-normal.vtf");
	AddFileToDownloadsTable("materials/models/player/pil/smith/smithhead.vmt");
	AddFileToDownloadsTable("materials/models/player/pil/smith/smithhead.vtf");
	AddFileToDownloadsTable("materials/models/player/pil/smith/smithhead-normal.vtf");
	AddFileToDownloadsTable("materials/models/player/pil/smith/smithshades.vmt");
	AddFileToDownloadsTable("materials/models/player/pil/smith/smithshoe.vmt");
	AddFileToDownloadsTable("materials/models/player/pil/smith/smithshoe.vtf");
	AddFileToDownloadsTable("materials/models/player/pil/smith/smithshoe-normal.vtf");
	AddFileToDownloadsTable("materials/models/player/pil/smith/soria-env.vtf");
	AddFileToDownloadsTable("materials/models/player/pil/smith/urbantemp.vmt");
	AddFileToDownloadsTable("materials/models/player/pil/smith/urbantemp.vtf");
	AddFileToDownloadsTable("models/player/pil/smith/smith.dx80.vtx");
	AddFileToDownloadsTable("models/player/pil/smith/smith.dx90.vtx");
	AddFileToDownloadsTable("models/player/pil/smith/smith.mdl");
	AddFileToDownloadsTable("models/player/pil/smith/smith.phy");
	AddFileToDownloadsTable("models/player/pil/smith/smith.sw.vtx");
	AddFileToDownloadsTable("models/player/pil/smith/smith.vvd");
	PrecacheModel("models/player/pil/smith/smith.mdl");
	
	AddFileToDownloadsTable("sound/queen/spawn/spot_1.wav");
	PrecacheSound("queen/spawn/spot_1.wav");
	
	AddFileToDownloadsTable("sound/franug/pikachu.wav");
	PrecacheSound("franug/pikachu.wav");
	
	AddFileToDownloadsTable("materials/models/smashbros/Pikachu/Pikachu_eyes.vmt");
	AddFileToDownloadsTable("materials/models/smashbros/Pikachu/Pikachu_eyes.vtf");
	AddFileToDownloadsTable("materials/models/smashbros/Pikachu/Pikachu_main.vmt");
	AddFileToDownloadsTable("materials/models/smashbros/Pikachu/Pikachu_main.vtf");
	AddFileToDownloadsTable("models/smashbros/pikachu.dx80.vtx");
	AddFileToDownloadsTable("models/smashbros/pikachu.dx90.vtx");
	AddFileToDownloadsTable("models/smashbros/pikachu.mdl");
	AddFileToDownloadsTable("models/smashbros/pikachu.phy");
	AddFileToDownloadsTable("models/smashbros/pikachu.sw.vtx");
	AddFileToDownloadsTable("models/smashbros/pikachu.vvd");
	PrecacheModel("models/smashbros/pikachu.mdl");
	
	AddFileToDownloadsTable("sound/UEA/pignoise55/dragon_ball.mp3");
	PrecacheSound("UEA/pignoise55/dragon_ball.mp3");
	
	PrecacheSound("ambient/explosions/explode_2.wav");
	
	PrecacheSound("ambient/creatures/town_scared_sob2.wav");
	
	PrecacheSound("ambient/explosions/exp4.wav");
	
	
	PrecacheModel("models/props/de_train/barrel.mdl");
	
	PrecacheModel("models/pigeon.mdl");
	
	PrecacheSound("npc/zombie/zombie_pain1.wav");
	PrecacheSound("npc/zombie/zombie_pain2.wav");
	PrecacheSound("npc/zombie/zombie_pain3.wav");
	PrecacheSound("npc/zombie/zombie_pain4.wav");
	PrecacheSound("npc/zombie/zombie_pain5.wav");
	PrecacheSound("npc/zombie/zombie_pain6.wav");
	
	PrecacheSound("npc/zombie/zombie_alert1.wav");
	
	PrecacheModel("models/crow.mdl");
	PrecacheModel("particle/fire.vmt");
	
	PrecacheSound("npc/combine_gunship/gunship_pain.wav");
	PrecacheModel("models/player/slow/trenchcoat/slow.mdl");
	
	AddFileToDownloadsTable("materials/models/player/techknow/gundam/flame.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/gundam/flame.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/gundam/gundam.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/gundam/gundam.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/gundam/gundam_n.vtf");
	
	AddFileToDownloadsTable("models/player/techknow/gundam/gundam.dx80.vtx");
	AddFileToDownloadsTable("models/player/techknow/gundam/gundam.dx90.vtx");
	AddFileToDownloadsTable("models/player/techknow/gundam/gundam.mdl");
	AddFileToDownloadsTable("models/player/techknow/gundam/gundam.phy");
	AddFileToDownloadsTable("models/player/techknow/gundam/gundam.sw.vtx");
	AddFileToDownloadsTable("models/player/techknow/gundam/gundam.vvd");
	
	PrecacheModel("models/player/techknow/gundam/gundam.mdl");
	
	AddFileToDownloadsTable("materials/models/player/techknow/spiderman3/body.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/spiderman3/body.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/spiderman3/body_n.vtf");
	
	AddFileToDownloadsTable("models/player/techknow/spiderman3/spiderman3.dx80.vtx");
	AddFileToDownloadsTable("models/player/techknow/spiderman3/spiderman3.dx90.vtx");
	AddFileToDownloadsTable("models/player/techknow/spiderman3/spiderman3.mdl");
	AddFileToDownloadsTable("models/player/techknow/spiderman3/spiderman3.phy");
	AddFileToDownloadsTable("models/player/techknow/spiderman3/spiderman3.sw.vtx");
	AddFileToDownloadsTable("models/player/techknow/spiderman3/spiderman3.vvd");
	

	
	AddFileToDownloadsTable("materials/models/player/techknow/jacks/body.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/jacks/body.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/jacks/body_n.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/jacks/head.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/jacks/head.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/jacks/head_n.vtf");
	
	AddFileToDownloadsTable("models/player/techknow/jacks/jacks.dx80.vtx");
	AddFileToDownloadsTable("models/player/techknow/jacks/jacks.dx90.vtx");
	AddFileToDownloadsTable("models/player/techknow/jacks/jacks.mdl");
	AddFileToDownloadsTable("models/player/techknow/jacks/jacks.phy");
	AddFileToDownloadsTable("models/player/techknow/jacks/jacks.sw.vtx");
	AddFileToDownloadsTable("models/player/techknow/jacks/jacks.vvd");
	PrecacheModel("models/player/techknow/jacks/jacks.mdl");
	
	AddFileToDownloadsTable("materials/models/apocmodels/pokemon/Groudon.vmt");
	AddFileToDownloadsTable("materials/models/apocmodels/pokemon/Groudon.vtf");
	AddFileToDownloadsTable("materials/models/apocmodels/pokemon/GroudonEye1.vmt");
	AddFileToDownloadsTable("materials/models/apocmodels/pokemon/GroudonEye1.vtf");
	AddFileToDownloadsTable("materials/models/apocmodels/pokemon/GroudonEye2.vmt");
	AddFileToDownloadsTable("materials/models/apocmodels/pokemon/GroudonEye2.vtf");
	AddFileToDownloadsTable("materials/models/apocmodels/pokemon/GroudonEye3.vmt");
	AddFileToDownloadsTable("materials/models/apocmodels/pokemon/GroudonEye3.vtf");
	AddFileToDownloadsTable("materials/models/apocmodels/pokemon/GroudonEye4.vmt");
	AddFileToDownloadsTable("materials/models/apocmodels/pokemon/GroudonEye4.vtf");
	AddFileToDownloadsTable("models/apocmodels/pokemon/groudon.mdl");
	AddFileToDownloadsTable("models/apocmodels/pokemon/groudon.dx80.vtx");
	AddFileToDownloadsTable("models/apocmodels/pokemon/groudon.dx90.vtx");
	AddFileToDownloadsTable("models/apocmodels/pokemon/groudon.phy");
	AddFileToDownloadsTable("models/apocmodels/pokemon/groudon.sw.vtx");
	AddFileToDownloadsTable("models/apocmodels/pokemon/groudon.vvd");
	PrecacheModel("models/apocmodels/pokemon/groudon.mdl");
	
	AddFileToDownloadsTable("sound/franug/scream_01.wav");
	PrecacheSound("franug/scream_01.wav");
	AddFileToDownloadsTable("sound/franug/scream_02.wav");
	PrecacheSound("franug/scream_02.wav");
	AddFileToDownloadsTable("sound/franug/scream_03.wav");
	PrecacheSound("franug/scream_03.wav");
	AddFileToDownloadsTable("sound/franug/scream_04.wav");
	PrecacheSound("franug/scream_04.wav");
	AddFileToDownloadsTable("sound/franug/scream_05.wav");
	PrecacheSound("franug/scream_05.wav");
	
	AddFileToDownloadsTable("sound/franug/santa.mp3");
	PrecacheSound("franug/santa.mp3");
	
	PrecacheSound("weapons/fx/rics/ric1.wav");
	PrecacheSound("weapons/fx/rics/ric2.wav");
	PrecacheSound("weapons/fx/rics/ric3.wav");
	PrecacheSound("weapons/fx/rics/ric4.wav");
	PrecacheSound("weapons/fx/rics/ric5.wav");
	
	PrecacheModel("models/player/techknow/spiderman3/spiderman3.mdl");	
	
	AddFileToDownloadsTable("materials/models/player/tap/goku/goku.vmt");
	AddFileToDownloadsTable("materials/models/player/tap/goku/goku.vtf");
	AddFileToDownloadsTable("materials/models/player/tap/goku/goku_n.vtf");
	
	AddFileToDownloadsTable("models/player/tap/goku/goku.dx80.vtx");
	AddFileToDownloadsTable("models/player/tap/goku/goku.dx90.vtx");
	AddFileToDownloadsTable("models/player/tap/goku/goku.mdl");
	AddFileToDownloadsTable("models/player/tap/goku/goku.phy");
	AddFileToDownloadsTable("models/player/tap/goku/goku.sw.vtx");
	AddFileToDownloadsTable("models/player/tap/goku/goku.vvd");
	
	AddFileToDownloadsTable("materials/models/player/techknow/meatman/body.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/meatman/body.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/meatman/body_n.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/meatman/pants.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/meatman/pants.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/meatman/pants_n.vtf");
	
	AddFileToDownloadsTable("models/player/techknow/meatman/meatman.dx80.vtx");
	AddFileToDownloadsTable("models/player/techknow/meatman/meatman.dx90.vtx");
	AddFileToDownloadsTable("models/player/techknow/meatman/meatman.mdl");
	AddFileToDownloadsTable("models/player/techknow/meatman/meatman.phy");
	AddFileToDownloadsTable("models/player/techknow/meatman/meatman.sw.vtx");
	AddFileToDownloadsTable("models/player/techknow/meatman/meatman.vvd");
	
	PrecacheModel("models/player/techknow/meatman/meatman.mdl");
	
	PrecacheModel("models/player/tap/goku/goku.mdl");
	
	PrecacheSound("npc/dog/dog_angry1.wav");
	PrecacheSound("npc/dog/dog_footstep_run1.wav");
	PrecacheSound("npc/dog/dog_footstep_run2.wav");
	PrecacheSound("npc/dog/dog_footstep_run3.wav");
	PrecacheSound("npc/dog/dog_footstep_run4.wav");
	PrecacheSound("npc/dog/dog_footstep_run5.wav");
	PrecacheSound("npc/dog/dog_footstep_run8.wav");
	
	PrecacheSound("npc/antlion_guard/antlion_guard_die2.wav");
	PrecacheModel("models/antlion_guard.mdl");
	PrecacheSound("music/stingers/HL1_stinger_song28.mp3");
	
	PrecacheSound("player/suit_sprint.wav");
	
	AddFileToDownloadsTable("sound/franug/franug_matrix.mp3");
	PrecacheSound("franug/franug_matrix.mp3");	
	
	AddFileToDownloadsTable("models/player/slow/hl2/combine_super_soldier/slow.dx80.vtx");
	AddFileToDownloadsTable("models/player/slow/hl2/combine_super_soldier/slow.dx90.vtx");
	AddFileToDownloadsTable("models/player/slow/hl2/combine_super_soldier/slow.mdl");
	AddFileToDownloadsTable("models/player/slow/hl2/combine_super_soldier/slow.phy");
	AddFileToDownloadsTable("models/player/slow/hl2/combine_super_soldier/slow.sw.vtx");
	AddFileToDownloadsTable("models/player/slow/hl2/combine_super_soldier/slow.vvd");
	PrecacheModel("models/player/slow/hl2/combine_super_soldier/slow.mdl");
	PrecacheModel("models/player/UEA/urban_admin/ct_urban.mdl");	
	PrecacheModel("models/player/UEA/ct_admin/ct_gign.mdl");

	AddFileToDownloadsTable("materials/models/player/slow/jamis/mkvsdcu/batman/slow_batman.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/jamis/mkvsdcu/batman/slow_batman.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/jamis/mkvsdcu/batman/slow_batman_belt.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/jamis/mkvsdcu/batman/slow_batman_blades.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/jamis/mkvsdcu/batman/slow_batman_bump.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/jamis/mkvsdcu/batman/slow_batman_exp.vtf");
	AddFileToDownloadsTable("materials/models/player/slow/jamis/mkvsdcu/batman/slow_batman_eyes.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/jamis/mkvsdcu/batman/slow_batman_latex.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/jamis/mkvsdcu/batman/slow_batman_pockets.vmt");
	AddFileToDownloadsTable("materials/models/player/slow/jamis/mkvsdcu/batman/slow_batman_skin.vmt");
	AddFileToDownloadsTable("models/player/slow/jamis/mkvsdcu/batman/slow_pub_v2.dx80.vtx");
	AddFileToDownloadsTable("models/player/slow/jamis/mkvsdcu/batman/slow_pub_v2.dx90.vtx");
	AddFileToDownloadsTable("models/player/slow/jamis/mkvsdcu/batman/slow_pub_v2.mdl");
	AddFileToDownloadsTable("models/player/slow/jamis/mkvsdcu/batman/slow_pub_v2.phy");
	AddFileToDownloadsTable("models/player/slow/jamis/mkvsdcu/batman/slow_pub_v2.sw.vtx");
	AddFileToDownloadsTable("models/player/slow/jamis/mkvsdcu/batman/slow_pub_v2.sw.vtx");
	AddFileToDownloadsTable("models/player/slow/jamis/mkvsdcu/batman/slow_pub_v2.vvd");
	AddFileToDownloadsTable("sound/UEA/batman.mp3");
	PrecacheSound("UEA/batman.mp3");
	PrecacheModel("models/player/slow/jamis/mkvsdcu/batman/slow_pub_v2.mdl");
}

//--------------------------------------------------------------//
// ######################### COMANDOS ######################### //
//--------------------------------------------------------------//

public Action:Ganzua_Open(client, args)
{
	new WeaponIndex = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	if (WeaponIndex < 0) return Plugin_Continue;
	if(IsValidEntity(WeaponIndex) && Ganzua[WeaponIndex])
	{
		UsoGanzua(client);
	}
	return Plugin_Handled;
}
public Action:VerCreditosClient(client, args)
{
	if (args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_vercreditos <#userid|nombre>");
		return Plugin_Handled;
	}
	
	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 
	
	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 
	
	if ((TargetCount = ProcessTargetString(strTarget, 0, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 
	
	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient)) 
		{ 
			//g_iCredits[iClient] = amount;
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05%N Creditos: %i", iClient, g_iCredits[iClient]);
			//PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Puesto %i creditos en el jugador %N", amount, iClient);
		} 
	}   
	
	
	return Plugin_Continue;
}

public Action:Skin(client, args)
{
	if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
	{
		if (g_cosa[client])
		{
			
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05El jugador\x03 %N \x05ha sido asesinado por intentar cambiarse de skin teniendo un premio", client);
			
			ForcePlayerSuicide(client);
			
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action:FijarCreditos(client, args)
{
	if (args < 2) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_setcredits <#userid|nombre> [cantidad]");
		return Plugin_Handled;
	}
	
	decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	new amount = StringToInt(arg2);
	//new target;
	
	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 
	
	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 
	
	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 
	
	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient)) 
		{ 
			g_iCredits[iClient] = amount;
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Puesto %i creditos en el jugador %N", amount, iClient);
		} 
	}
	
	return Plugin_Continue;
}  

public Action:Darme(client, args)
{
	decl String:arg1[10];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	new amount = StringToInt(arg1);
	
	g_iCredits[client] += amount;
	PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Te has dado %i creditos", amount);
	
	return Plugin_Continue;
} 

public Action:VerCreditos(client, args)
{
	PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos actuales son: %i", g_iCredits[client]);
}

public Action:DOMenu(client,args)
{
	if (!g_RondaEspecial)
	{
		DID(client);
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i", g_iCredits[client]);
	}
	else
	{
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar premios en este momento");
	}
}

public Action:Resucitar(client,args)
{
	if (!g_RondaEspecial)
	{
		if (!Fin_Ronda)
		{
			
			new count = 0; 
			//count = 0; 
			
			new count2 = 0; 
			//count2 = 0;
			
			for(new i = 1; i <= MaxClients; i++) 
			{ 
				if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i)) 
				{ 
					count++; 
				} 
			} 
			
			for(new i = 1; i <= MaxClients; i++) 
			{ 
				if (IsClientInGame(i) && GetClientTeam(i) == 3 && IsPlayerAlive(i)) 
				{ 
					count2++; 
				} 
			} 
			
			if (count > GetConVarInt(T_Vivos))
			{ 
				if (count2 > GetConVarInt(CT_Vivos))
				{ 
					if (!IsPlayerAlive(client) && GetClientTeam(client) != 1)
					{
						if (g_iCredits[client] >= 4)
						{
							
							CS_RespawnPlayer(client);
							
							g_iCredits[client] -= 4;
							
							CPrintToChatAllEx(client, "{default}[SM_Franug-JailPlugins] {olive}El jugador{teamcolor} %N {olive}ha resucitado!", client);
							PrintCenterTextAll("El jugador %N ha resucitado!", client);
							
							if (GetClientTeam(client) == 3)
							{
								if (strcmp(g_MapName, "ba_jail_electric_vip") == 0)
								{
									Teleportar(client);
								} 	
							}							
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos para resucitar! Necesitas 4)", g_iCredits[client]);
						}							
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar MUERTO para usarlo!");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No se puede resucitar cuando solo quedan %i CTs vivos!", GetConVarInt(CT_Vivos));
				}
			}
			else
			{
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No se puede resucitar cuando solo quedan %i Ts vivos!", GetConVarInt(T_Vivos));
			}
		}
		else
		{
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No se puede resucitar cuando esta acabada la ronda!");
		}
	}
	else
	{
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes resucitar en una ronda especial!");
	}
}

public Action:ZResucitar(client,args)
{
	if (!Fin_Ronda)
	{
		
		new count = 0; 
		//count = 0; 
		
		new count2 = 0; 
		//count2 = 0;
		
		for(new i = 1; i <= MaxClients; i++) 
		{ 
			if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i)) 
			{ 
				count++; 
			} 
		} 
		
		for(new i = 1; i <= MaxClients; i++) 
		{ 
			if (IsClientInGame(i) && GetClientTeam(i) == 3 && IsPlayerAlive(i)) 
			{ 
				count2++; 
			} 
		} 
		
		if (count > GetConVarInt(T_Vivos))
		{ 
			if (count2 > GetConVarInt(CT_Vivos))
			{ 
				if (GetClientTeam(client) != 1 && !IsPlayerAlive(client))
				{
					if (!g_ZResucitar[client])
					{
						if (g_iCredits[client] >= 2)
						{
							g_ZResucitar[client] = true;
							CS_RespawnPlayer(client);
							
							CreateTimer(3.0, CrearNoMuerto, client);
							ConvertirNoMuerto(client);
							
							g_iCredits[client] -= 2;
							
							decl String:nombre[32];
							GetClientName(client, nombre, sizeof(nombre));
							
							PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05El jugador\x03 %s \x05ha vuelto a la vida como NO MUERTO!", nombre);
							PrintCenterTextAll("El jugador %s ha vuelto a la vida como NO MUERTO!", nombre);
							
							if (GetClientTeam(client) == 3)
							{
								if (strcmp(g_MapName, "ba_jail_electric_vip") == 0)
								{
									Teleportar(client);
								} 
							}
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos para resucitar! Necesitas 2)", g_iCredits[client]);
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Solo puedes usar el comando \x01!zresucitar \x05una vez por ronda!");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar MUERTO para usarlo!");
				}
			}
			else
			{
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No se puede resucitar cuando solo quedan %i CTs vivos!", GetConVarInt(CT_Vivos));
			}
		}
		else
		{
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No se puede resucitar cuando solo quedan %i Ts vivos!", GetConVarInt(T_Vivos));
		}
	}
	else
	{
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No se puede resucitar cuando esta acabada la ronda!");
	}
}

public Action:Curarse(client,args)
{
	if (IsPlayerAlive(client) && GetClientTeam(client) != 1)
	{
		if (g_iCredits[client] >= 1)
		{
			if (g_cosa[client])
			{
				
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes curarte siendo un ser especial!");
				return;
			}
			
			SetEntityHealth(client, 100);
			
			g_iCredits[client] -= 1;
			
			EmitSoundToClient(client,"medicsound/medic.wav");
			
			
			decl String:nombre[32];
			GetClientName(client, nombre, sizeof(nombre));
			
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05El jugador\x03 %s \x05se ha curado!", nombre);
			
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Te has aplicado cirugia. Tus creditos: %i (-1)", g_iCredits[client]);
		}
		else
		{
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos para resucitar! Necesitas 1)", g_iCredits[client]);
		}
	}
	else
	{
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Pero si estas muerto... so bobo !! xDD");
	}
}

public Action:penisc(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_pene <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			ConvertirPene(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05convertido en pene el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Command_Normalizar(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_normal <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			Normalizar(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Normalizado el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Utilidad(client, args)
{
	if(g_Medic[client])
	{
		PrintHintText(client, "No puedes tirar tus armas siendo medico");
		return Plugin_Handled;
	}
	else if(g_Paloma[client] || g_Pene[client])
	{
		new MoveType:movetype = GetEntityMoveType(client); 
		if (movetype != MOVETYPE_FLY)
		{
			SetEntityMoveType(client, MOVETYPE_FLY);
			PrintToChat(client,"\x04[SM_Franug-JailPlugins] \x05Vuelo Activado");
		}
		else
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
			PrintToChat(client,"\x04[SM_Franug-JailPlugins] \x05Vuelo Desactivado");
		}
	}	
	else if(g_Spiderman[client])
	{ 
		if (g_Trepando[client])
		{
			g_Trepando[client] = false;
			PrintToChat(client,"\x04[SM_Franug-JailPlugins] \x05Modo trepar Desactivado");
			SetEntityGravity(client, 1.0);
		}
		else
		{
			g_Trepando[client] = true;
			PrintToChat(client,"\x04[SM_Franug-JailPlugins] \x05Modo trepar Activado");
		}
	}
	new WeaponIndex = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	if (WeaponIndex < 0) return Plugin_Continue;
	if(IsValidEntity(WeaponIndex) && Ganzua[WeaponIndex])
	{
		UsoGanzua(client);
	}
	
	return Plugin_Continue;
}

public Action:MunicionInfinita(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_ammoinfi <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			g_AmmoInfi[iClient] = true;
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05MUNICION INFINITA para el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Paloma(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_paloma <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			ConvertirPajaro(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en PALOMA el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Monstruo(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_monstruo <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			ConvertirMonstruo(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en MONSTRUO el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Zombie(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_zombie <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			ConvertirZombie(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en ZOMBIE el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Ironman(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_ironman <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			ConvertirIronman(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en IRONMAN el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Gallina(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_ironman <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			ConvertirGallina(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en GALLINA el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Saltador(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_saltador <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			g_Saltador[iClient] = true;
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en SALTADOR el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Bomba(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_bomba <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			g_Bomba[iClient] = true;
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en KAMIKAZE EXPLOSIVO el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Pikachu(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_pikachu <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			ConvertirPikachu(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en PIKACHU el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Groudon(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_groudon <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			ConvertirGroudon(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en GROUDON el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Predator(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_predator <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			ConvertirPredator(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en Predator el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Amor(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_amor <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			ConvertirAmada(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en SER AMADO el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Goku(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_goku <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			ConvertirGoku(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en GOKU el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Robot(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_robot <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			ConvertirRobot(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en MEGA ROBOT el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Soldado(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_soldado <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			ConvertirSoldado(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en SOLDADO el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}  

public Action:Trainer(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_trainer <#userid|nombre>");
		return Plugin_Handled;
	}

	//decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	//GetCmdArg(2, arg2, sizeof(arg2));

	//new amount = StringToInt(arg2);
	//new target;

	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 

	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 

	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) 
		{ 
			ConvertirTrainer(iClient);
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Convertido en ENTRENADOR POKEMON el jugador %N", iClient);
		} 
	}

	return Plugin_Continue;
}   

public Action:Dar(client, args)
{	
	if (args < 2) // Not enough parameters
	{
		ReplyToCommand(client, "[SM] Utiliza: sm_dar <#userid|nombre> [cantidad]");
		return Plugin_Handled;
	}
	
	decl String:arg[30], String:arg2[10];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	new amount = StringToInt(arg2);
	
	if (amount > g_iCredits[client])
	{
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tu no tienes tantos creditos!");
		return Plugin_Handled; // Target not found...
	}
	
	if (amount <= 0)
	{
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes dar menos de 0 creditos!");
		return Plugin_Handled; // Target not found...
	}
	
	
	new target;
	
	if ((target = FindTarget(client, arg, false, false)) == -1)
	{
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Objetivo no encontrado");
		return Plugin_Handled; // Target not found...
	}
	
	//    SetEntProp(target, Prop_Data, "m_iDeaths", amount);
	g_iCredits[target] += amount;
	g_iCredits[client] -= amount;
	
	PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Entregados %i creditos al jugador %N", amount, target);
	PrintToChat(target, "\x04[SM_Franug-JailPlugins] \x05Te ha Entregado %i creditos el jugador %N", amount, client);
	
	return Plugin_Continue;
} 

// Final COMANDOS
//--------------------------------------------------------------//
// ##################### TRANSFORMACIONES ##################### //
//--------------------------------------------------------------//
ConvertirBatman(client)
{
	// Features
	EmitSoundToAll("UEA/batman.mp3");
	SetEntityHealth(client, GetConVarInt(HealthBatman));
	SetEntityModel(client, ModelBatman);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedBatman));
	g_Batman[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	SetClientThrowingKnives(client, 10);
	
	// Team
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntityRenderColor(client, 0, 0, 255, 255);
	}
	
	// Common
	GivePlayerItem(client, "weapon_knife");
	g_cosa[client] = true;	
}
ConvertirGanzua(client)
{
	
	new index = GetPlayerWeaponSlot(client, 2);
	// If the index is not -1 - Client has a Knife
	if(index != -1)
	{
		RemovePlayerItem(client, index);
		RemoveEdict(index);
	}
	new ent = GivePlayerItem(client, "weapon_knife");
	Ganzua[ent] = true;
	SetEntityRenderMode(ent, RENDER_NORMAL);
	SetEntityRenderColor(ent, 244, 227, 41, 255);
}

ConvertirAwpFreeze(client)
{
	new index = GetPlayerWeaponSlot(client, 0);
	// If the index is not -1 - Client has a Primary weapon 
	if(index != -1)
	{
		CS_DropWeapon(client, index, false, true);
	}
	new ent = GivePlayerItem(client, "weapon_awp");
	AwpFreeze[ent] = true;
	SetEntityRenderMode(ent, RENDER_NORMAL);
	SetEntityRenderColor(ent, 0, 0, 255, 255);
	
	new zomg = GetEntDataEnt2(client, ent);
	if (PrimaryAmmoOff != -1 && zomg != -1)
	SetEntData(zomg, PrimaryAmmoOff, 100);
	
	new String:tName[128];
	Format(tName, sizeof(tName), "lighttarget%i", ent);
	DispatchKeyValue(ent, "targetname", tName);
	
	new String:light_name[128];
	Format(light_name, sizeof(light_name), "light%i", ent);
	
	new luz = CreateEntityByName("light_dynamic");
	
	DispatchKeyValue(luz,"targetname", light_name);
	DispatchKeyValue(luz, "parentname", tName);
	DispatchKeyValue(luz, "inner_cone", "0");
	DispatchKeyValue(luz, "classname", "luzent");
	DispatchKeyValue(luz, "cone", "100");
	DispatchKeyValue(luz, "brightness", "1");
	DispatchKeyValueFloat(luz, "spotlight_radius", 300.0);
	
	DispatchKeyValue(luz, "pitch", "200");
	DispatchKeyValue(luz, "style", "5");
	DispatchKeyValue(luz, "_light", "0 0 255 255");
	DispatchKeyValueFloat(luz, "distance", 300.0);
	DispatchSpawn(luz);
	new Float:ClientsPos[3];
	GetClientAbsOrigin(client, ClientsPos);
	TeleportEntity(luz, ClientsPos, NULL_VECTOR, NULL_VECTOR);
	SetVariantString(tName);
	AcceptEntityInput(luz, "SetParent");
	SetEntPropEnt(ent, Prop_Send, "m_hEffectEntity", luz);
	AcceptEntityInput(luz, "TurnOn");
}

ConvertirPajaro(client)
{
	// Features
	SetEntityMoveType(client, MOVETYPE_FLY);
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, 255, 255, 255, 255);
	g_Paloma[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	
	// Team
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntityModel(client, "models/pigeon.mdl");
	}
	else
	{
		SetEntityModel(client, "models/crow.mdl");
	}
	
	// Common
	GivePlayerItem(client, "weapon_knife");
	HideWeapons(client);
	g_cosa[client] = true;	
}

ConvertirGallina(client)
{
	// Features
	SetEntityModel(client, "models/lduke/chicken/chicken2.mdl");
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, 255, 255, 255, 255);
	g_Gallina[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	
	// Team
	if (GetClientTeam(client) == CS_TEAM_T)
	{
		SetEntityRenderColor(client, 0, 0, 0, 255);
	}
	
	// Common
	GivePlayerItem(client, "weapon_knife");
	HideWeapons(client);
	g_cosa[client] = true;
}

ConvertirTrainer(client)
{
	// Features
	SetEntityModel(client, ModelTrainer);
	SetEntityHealth(client, GetConVarInt(HealthTrainer));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedTrainer));
	EmitSoundToAll("franug/invencible.mp3");
	g_Trainer[client] = true;
	RemoveWeapons(client);
	
	// Team
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntityRenderColor(client, 0, 0, 255, 255);
	}
	
	// Common
	GivePlayerItem(client, "weapon_hegrenade");
	g_cosa[client] = true;
}

ConvertirZombie(client)
{
	// Features
	SetEntityModel(client, ModelZombie);
	SetEntityHealth(client, GetConVarInt(HealthZombie));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedZombie));
	EmitSoundToAll("misc/horror/the_horror2.wav");
	Alien_Vision(client);
	Shake(client, AMP_SHAKE, DUR_SHAKE);
	g_Zombie[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	
	// Team
	
	// Common
	GivePlayerItem(client, "weapon_knife");
	HideWeapons(client);
	g_cosa[client] = true;
}

ConvertirMonstruo(client)
{
	// Features
	SetEntityModel(client, ModelMonstruo);
	SetEntityHealth(client, GetConVarInt(HealthMonstruo));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedMonstruo));
	EmitSoundToAll("crosshair/alarm.wav");
	g_Monster[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	if (g_Bomba[client])
	{
		PrintToChat(client, "Los MONSTRUOS no pueden ser KAMIKAZES EXPLOSIVOS. Has perdido tu capacidad explosiva.");
		g_Bomba[client] = false;
	}	
	if (GetClientThrowingKnives(client) > 0)
	{
		PrintToChat(client, "Los MONSTRUOS no pueden tener CUCHILLOS ARROJADIZOS. Has perdido tus cuchillos.");
		SetClientThrowingKnives(client, 0);
	}
	
	// Team
	
	// Common
	GivePlayerItem(client, "weapon_knife");
	HideWeapons(client);
	g_cosa[client] = true;
	
	// Effects
	new Float:iVec[3];
	GetClientAbsOrigin(client, iVec);
	
	TE_SetupSparks(iVec, iVec, 50, 50);
	TE_SendToAll();
	
	TE_SetupGlowSprite(iVec, g_HaloSprite, 2.0, 50.0, 50);
	TE_SendToAll();
	
	TE_SetupBeamRingPoint(iVec, 10.0, 375.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 10.0, 0.5, redColor, 10, 0);
	TE_SendToAll();
	
	TE_SetupExplosion( iVec, g_ExplosionSprite, 5.0, 1, 0, 50, 40, iNormal );
	TE_SendToAll();
	
	TE_SetupSmoke( iVec, g_SmokeSprite, 10.0, 3 );
	TE_SendToAll();		
}

ConvertirSoldado(client)
{
	// Features
	SetEntityModel(client, ModelSoldado);
	SetEntityHealth(client, GetConVarInt(HealthSoldado));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedSoldado));
	EmitSoundToAll("npc/combine_gunship/gunship_pain.wav");
	g_Soldado[client] = true;
	g_AmmoInfi[client] = true;
	RemoveWeapons(client);
	
	// Team
	
	// Common
	GivePlayerItem(client, "weapon_mp5navy");
	GivePlayerItem(client, "weapon_deagle");
	GivePlayerItem(client, "weapon_knife");
	g_cosa[client] = true;
}

ConvertirBicho(client)
{
	// Features
	SetEntityModel(client, ModelBicho);
	SetEntityHealth(client, GetConVarInt(HealthBicho));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedBicho));
	EmitSoundToAll("npc/antlion_guard/antlion_guard_die2.wav");
	g_Bicho[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	flameAmount[client] += 1;
	
	// Team
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntityRenderColor(client, 0, 0, 255, 255);
	}	
	// Common
	GivePlayerItem(client, "weapon_knife");
	HideWeapons(client);
	g_cosa[client] = true;
}

ConvertirMedic(client)
{
	// Features
	SetEntityModel(client, ModelMedic);
	SetEntityHealth(client, GetConVarInt(HealthMedic));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedMedic));
	EmitSoundToAll("medicsound/medic.wav");
	g_Medic[client] = true;
	RemoveWeapons(client);
	
	// Team
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntityRenderColor(client, 0, 0, 255, 255);
	}	
	// Common
	GivePlayerItem(client, "weapon_mp5navy");
	GivePlayerItem(client, "weapon_fiveseven");
	GivePlayerItem(client, "weapon_knife");
	
	new zomg = GetEntDataEnt2(client, activeOffset);
	if (PrimaryAmmoOff != -1 && zomg != -1)
	SetEntData(zomg, PrimaryAmmoOff, 1000);
	g_cosa[client] = true;
}

ConvertirRobot(client)
{
	// Features
	SetEntityModel(client, ModelRobot);
	SetEntityHealth(client, GetConVarInt(HealthRobot));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedRobot));
	EmitSoundToAll("npc/dog/dog_angry1.wav");
	g_Robot[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	if (g_Bomba[client])
	{
		PrintToChat(client, "Los MEGA ROBOTS no pueden ser KAMIKAZES EXPLOSIVOS. Has perdido tu capacidad explosiva.");
		g_Bomba[client] = false;
	}
	if (GetClientThrowingKnives(client) > 0)
	{
		PrintToChat(client, "Los MEGA ROBOTS no pueden tener CUCHILLOS ARROJADIZOS. Has perdido tus cuchillos.");
		SetClientThrowingKnives(client, 0);
	}	
	
	// Team
	
	// Common
	GivePlayerItem(client, "weapon_knife");
	HideWeapons(client);
	g_cosa[client] = true;
	
	// Effects
	new Float:iVec[3];
	GetClientAbsOrigin(client, iVec);
	
	TE_SetupSparks(iVec, iVec, 50, 50);
	TE_SendToAll();
	
	TE_SetupGlowSprite(iVec, g_HaloSprite, 2.0, 50.0, 50);
	TE_SendToAll();
	
	TE_SetupBeamRingPoint(iVec, 10.0, 375.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 10.0, 0.5, blueColor, 10, 0);
	TE_SendToAll();
	
	TE_SetupExplosion( iVec, g_ExplosionSprite, 5.0, 1, 0, 50, 40, iNormal );
	TE_SendToAll();
	
	TE_SetupSmoke( iVec, g_SmokeSprite, 10.0, 3 );
	TE_SendToAll();		
}

ConvertirIronman(client)
{
	// Features
	SetEntityModel(client, ModelIronman);
	SetEntityHealth(client, GetConVarInt(HealthIronman));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedIronman));
	EmitSoundToAll("franug/i_am_ironman.mp3");
	g_Ironman[client] = true;

	// Team
	
	// Common
	g_cosa[client] = true;
	
	// Effects
	new Float:iVec[3];
	GetClientAbsOrigin(client, iVec);
	
	TE_SetupSparks(iVec, iVec, 10, 10);
	TE_SendToAll();
	
	TE_SetupGlowSprite(iVec, g_HaloSprite, 0.6, 1.5, 50);
	TE_SendToAll();
	
	TE_SetupBeamRingPoint(iVec, 10.0, 375.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 10.0, 0.5, blueColor, 10, 0);
	TE_SendToAll();
	
	TE_SetupExplosion(iVec, g_ExplosionSprite, 5.0, 1, 0, 50, 40, iNormal );
	TE_SendToAll();
	
	TE_SetupSmoke(iVec, g_SmokeSprite, 10.0, 3 );
	TE_SendToAll();		
}

ConvertirReina(client)
{
	// Features
	SetEntityModel(client, ModelReina);
	SetEntityHealth(client, GetConVarInt(HealthReina));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedReina));
	EmitSoundToAll("queen/spawn/spot_1.wav");
	g_Reina[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	
	// Team
	
	// Common
	GivePlayerItem(client, "weapon_knife");
	HideWeapons(client);
	g_cosa[client] = true;
}

ConvertirPikachu(client)
{
	// Features
	SetEntityModel(client, ModelPikachu);
	SetEntityHealth(client, GetConVarInt(HealthPikachu));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedPikachu));
	EmitSoundToAll("franug/pikachu.wav");
	g_Pikachu[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	g_Rayos[client] += 1;
	
	// Team
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntityRenderColor(client, 0, 0, 255, 255);
	}	
	// Common
	GivePlayerItem(client, "weapon_knife");
	HideWeapons(client);
	g_cosa[client] = true;
}

ConvertirSpiderman(client)
{
	// Features
	SetEntityModel(client, ModelSpiderman);
	SetEntityHealth(client, GetConVarInt(HealthSpiderman));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedSpiderman));
	EmitSoundToAll("music/stingers/HL1_stinger_song28.mp3");
	g_Spiderman[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	SetClientThrowingKnives(client, 99999);
	
	// Team

	// Common
	GivePlayerItem(client, "weapon_knife");
	HideWeapons(client);
	g_cosa[client] = true;
}

ConvertirSmith(client)
{
	// Features
	SetEntityModel(client, ModelSmith);
	SetEntityHealth(client, GetConVarInt(HealthSmith));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedSmith));
	EmitSoundToAll("franug/franug_matrix.mp3");
	g_Smith[client] = true;
	g_AmmoInfi[client] = true;	
	RemoveWeapons(client);
	
	// Team

	// Common
	GivePlayerItem(client, "weapon_knife");
	GivePlayerItem(client, "weapon_deagle");
	g_Noweapons[client] = true;
	g_cosa[client] = true;
}

ConvertirGoku(client)
{
	// Features
	SetEntityModel(client, ModelGoku);
	SetEntityHealth(client, GetConVarInt(HealthGoku));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedGoku));
	EmitSoundToAll("UEA/pignoise55/dragon_ball.mp3");
	g_Goku[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	g_PlasmaCantidad[client] += 999999;
	
	// Team
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntityRenderColor(client, 0, 0, 255, 255);
	}
	// Common
	GivePlayerItem(client, "weapon_knife");
	HideWeapons(client);
	g_cosa[client] = true;
}

ConvertirGroudon(client)
{
	// Features
	SetEntityModel(client, ModelGroudon);
	SetEntityHealth(client, GetConVarInt(HealthGroudon));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedGroudon));
	EmitSoundToAll("ambient/explosions/explode_2.wav");
	g_Groudon[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	g_Terremotos[client] += 1;	
	
	// Team
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntityRenderColor(client, 0, 0, 255, 255);
	}
	// Common
	GivePlayerItem(client, "weapon_knife");
	HideWeapons(client);
	g_cosa[client] = true;
}

ConvertirAmada(client)
{
	// Features
	SetEntityModel(client, "models/mapeadores/morell/sakura/sakura.mdl");
	SetEntityHealth(client, 100);
	EmitSoundToAll("franug/amor.mp3");
	g_Amor[client] = true;

	// Team
	if (GetClientTeam(client) == CS_TEAM_T)
	{
		SetEntityRenderColor(client, 255, 153, 204, 255);
	}
	g_cosa[client] = true;
}

ConvertirFantasma(client)
{
	// Features
	g_Golpes[client] = 0;
	EmitSoundToAll("franug/susto3.wav");
	SetEntityMoveType(client, MOVETYPE_NOCLIP);
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, 255, 255, 255, 128);	
	g_Fantasma[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	
	// Team

	// Common
	GivePlayerItem(client, "weapon_knife");
	g_cosa[client] = true;
}

ConvertirPredator(client)
{
	// Features
	SetEntityModel(client, ModelPredator);
	SetEntityHealth(client, GetConVarInt(HealthPredator));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedPredator));
	EmitSoundToAll("predator/imhere.mp3");
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, 100, 100, 100, 100);	
	g_Predator[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	g_Lasers[client] += 1;
	
	// Team

	// Common
	GivePlayerItem(client, "weapon_knife");
	HideWeapons(client);
	g_cosa[client] = true;
}

ConvertirSanta(client)
{
	// Features
	SetEntityModel(client, ModelSanta);
	SetEntityHealth(client, GetConVarInt(HealthSanta));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedSanta));	
	EmitSoundToAll("franug/santa.mp3");
	g_Santa[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);
	g_Regalos[client] += 1;						
	
	// Team
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntityRenderColor(client, 0, 0, 255, 255);
	}
	
	// Common
	GivePlayerItem(client, "weapon_knife");
	g_cosa[client] = true;
}

ConvertirJack(client)
{
	// Features
	if (g_hTimer[client] == INVALID_HANDLE)
	{
		g_hTimer[client] = CreateTimer(GetConVarFloat(Cvar_Miedo), CheckClientOrg, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}	
	SetEntityModel(client, ModelJack);
	SetEntityHealth(client, GetConVarInt(HealthJack));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(SpeedJack));	
	EmitSoundToAll("ambient/creatures/town_scared_sob2.wav");
	g_Jack[client] = true;
	
	// Team
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntityRenderColor(client, 0, 0, 255, 255);
	}
	
	// Common
	g_cosa[client] = true;
}

ConvertirPene(client)
{
	// Features
	SetEntityHealth(client, GetConVarInt(HealthPene));	
	EmitSoundToAll("UEA/anarquista/volador.wav");
	SetEntityMoveType(client, MOVETYPE_FLY);
	g_Pene[client] = true;
	g_Noweapons[client] = true;
	RemoveWeapons(client);	
	if (g_Bomba[client])
	{
		PrintToChat(client, "Los PENES VOLADORES no pueden ser KAMIKAZES EXPLOSIVOS. Has perdido tu capacidad explosiva.");
		g_Bomba[client] = false;
	}
	if (GetClientThrowingKnives(client) > 0)
	{
		PrintToChat(client, "Los PENES VOLADORES no pueden tener CUCHILLOS ARROJADIZOS. Has perdido tus cuchillos.");
		SetClientThrowingKnives(client, 0);
	}	
	
	new ent = CreateEntityByName("prop_dynamic_override");
	
	new String:targetname[16];
	Format(targetname, sizeof(targetname), "attachment%i", client);
	DispatchKeyValue(ent, "targetname", targetname);
	DispatchKeyValue(ent, "model", ModelPene);
	DispatchKeyValue(ent, "spawnflags", "256");
	DispatchKeyValue(ent, "solid", "0");
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	DispatchSpawn(ent);	
	AcceptEntityInput(ent, "TurnOn", ent, ent, 0);
	
	new Float:ppos[3];
	
	GetClientEyePosition(client, ppos);

	ppos[0]+=10.0;
	ppos[2]-=30.0;
	
	new Float:aang[3];
	
	GetClientAbsAngles(client, aang);
	
	if(aang[1] > 0)
	{
		ppos[0]+=FloatSub(10.0, FloatMul(FloatDiv(10.0, 90.0), aang[1]));
		ppos[1]+=FloatSub(10.0, FloatMul(FloatDiv(10.0, 90.0), FloatAbs(FloatSub(aang[1], 90.0))));
	}
	else
	{
		ppos[0]+=FloatSub(10.0, FloatMul(FloatDiv(10.0, 90.0), FloatAbs(aang[1])));
		ppos[1]-=FloatSub(10.0, FloatMul(FloatDiv(10.0, 90.0), FloatAbs(FloatSub(FloatAbs(aang[1]), 90.0))));
	}
	
	aang[0]=0.0;
	aang[1]+=180.0;
	aang[2]=0.0;
	
	TeleportEntity(ent, ppos, aang, NULL_VECTOR);
	
	g_Attachments[client] = ent;	
	
	// Team
	
	// Common
	GivePlayerItem(client, "weapon_knife");
	HideWeapons(client);
	g_cosa[client] = true;
}

ConvertirNoMuerto(client)
{
	// Features
	g_NoMuerto[client] = true;
	g_Noweapons[client] = true;
	SetEntityHealth(client, 200);
	EmitSoundToAll("npc/zombie/zombie_alert1.wav");
	GivePlayerItem(client, "weapon_knife");
	Alien_Vision(client);
	Shake(client, AMP_SHAKE, DUR_SHAKE);
	RemoveWeapons(client);
	
	// Team
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntityRenderColor(client, 0, 0, 255, 255);
	}
	
	// Common
	g_cosa[client] = true;
	HideWeapons(client);
}

// Final TRANSFORMACIONES
//--------------------------------------------------------------//
// ##################### TIMERS / FUNCIONES ##################### //
//--------------------------------------------------------------//
UsoGanzua(client)
{
	decl Ent;
	decl String:ClassName[255];
	decl Float:ClientOrigin[3],Float:TargetOrigin[3], Float:Distance;
	GetClientAbsOrigin(client, ClientOrigin);	
	
	Ent = GetClientAimTarget(client, false);
	GetEdictClassname(Ent, ClassName, 255);
	
	if (!IsValidEdict(Ent))
		return;
	
	for (new i=0;i<sizeof(doorlist);i++)
	{
		if(StrEqual(ClassName, doorlist[i]))
		{
			Entity_GetAbsOrigin(Ent, TargetOrigin);
			Distance = GetVectorDistance(ClientOrigin, TargetOrigin);
			if (Distance <= 75.0)
			{
				AcceptEntityInput(Ent, "Open", client);
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has abierto la puerta!");
			}
			else
			{
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Estas demasiado lejos de la puerta.");
			}
		}
	}
}
public Action:DelayWeapon(Handle:Timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_Trainer[client])
	{
		new wepIdx;

		// strip all weapons
		for (new s = 0; s < 4; s++)
		{
			if ((wepIdx = GetPlayerWeaponSlot(client, s)) != -1)
			{
				RemovePlayerItem(client, wepIdx);
				RemoveEdict(wepIdx);
			}
		}
		GivePlayerItem(client, "weapon_hegrenade");
	}
}

public Action:SuperMonsterTimer(Handle:timer, any:client)
{
	
	PrintToChatAll("\x04RONDA ESPECIAL!!");
	PrintToChatAll("\x04IRONMAN \x01VS \x04MONSTRUO!!");	
	if (IsClientInGame(client) && Client_IsValid(client))
	{
		if (GetClientTeam(client) == CS_TEAM_CT)
		{
			ConvertirIronman(client);
			g_AmmoInfi[client] = true;
		}
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			ConvertirMonstruo(client);
		}
	}	
	BorrarPuertas();
}

public Action:TrainerVsGroudonTimer(Handle:timer, any:client)
{
	PrintToChatAll("\x04RONDA ESPECIAL!!");
	PrintToChatAll("\x04ENTRENADOR POKEMON \x01VS \x04GROUDON!!");				
	if (IsClientInGame(client) && Client_IsValid(client))
	{
		if (GetClientTeam(client) == CS_TEAM_CT)
		{
			ConvertirTrainer(client);
		}
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			ConvertirGroudon(client);
		}		
	}	
	BorrarPuertas();
}

public Action:Regenerate(Handle:timer, any:client)
{
	if (Client_IsValid(client) && IsClientInGame(client))
	{
		if (g_Medic[client])
		{
			new ClientHealth = GetClientHealth(client);

			if(ClientHealth < 250)
			{
				new Regenerated = ClientHealth + 10;
				SetEntityHealth(client, Regenerated);
			}
			else
			{
				SetEntityHealth(client, 250);
				g_hRegenTimer[client] = INVALID_HANDLE;
				KillTimer(timer);
			}
		}
	}
}
public Action:LimpiarGolpeado(Handle:timer, any:client)
{
	if (g_Golpeado[client])
	{
		g_Golpeado[client] = false;
	}
}
public Action:AwpDescongelar(Handle:timer, any:client)
{
	if(IsClientInGame(client))
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}

public Action:RemoveParticle(Handle:timer, any:particle)
{
	if (IsValidEdict(particle))
	{
		AcceptEntityInput(particle, "Kill");
		RemoveEdict(particle);
	}
}

public Action:DeletePushForce(Handle:timer, any:ent)
{
	if (IsValidEntity(ent))
	{
		decl String:classname[64];
		GetEdictClassname(ent, classname, sizeof(classname));
		if (StrEqual(classname, "point_push", false))
		{
			AcceptEntityInput(ent, "Disable");
			AcceptEntityInput(ent, "Kill"); 
			RemoveEdict(ent);
		}
	}
}

public Action:DeletePointHurt(Handle:timer, any:ent)
{
	if (IsValidEntity(ent))
	{
		decl String:classname[64];
		GetEdictClassname(ent, classname, sizeof(classname));
		if (StrEqual(classname, "point_hurt", false))
		{
			AcceptEntityInput(ent, "Kill"); 
			RemoveEdict(ent);
		}
	}
}

public Action:MensajesMuerte(Handle:timer, any:client)
{
	if (IsClientInGame(client))
	{
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has muerto, escribe \x03!resucitar \x05(4 creditos) o \x03!zresucitar \x05para revivir como no muerto (2 creditos)");
	}
}

public Action:MensajesSpawn(Handle:timer, any:client)
{
	if (IsClientInGame(client))
	{
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Mata jugadores para conseguir creditos");
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Escribe \x03!premios \x05para gastar tus creditos en premios");
	}
}

public Action:CrearNoMuerto(Handle:timer, any:client)
{
	SetEntityModel(client, "models/player/techknow/meatman/meatman.mdl");
}

public Action:ResetAmmo(Handle:timer)
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientConnected(client) && !IsFakeClient(client) && IsClientInGame(client) && IsPlayerAlive(client) && (g_AmmoInfi[client]))
		{
			Client_ResetAmmo(client);
		}
	}
}

public Client_ResetAmmo(client)
{
	new zomg = GetEntDataEnt2(client, activeOffset);
	if (clip1Offset != -1 && zomg != -1)
	SetEntData(zomg, clip1Offset, 200, 4, true);
	if (clip2Offset != -1 && zomg != -1)
	SetEntData(zomg, clip2Offset, 200, 4, true);
	if (priAmmoTypeOffset != -1 && zomg != -1)
	SetEntData(zomg, priAmmoTypeOffset, 200, 4, true);
	if (secAmmoTypeOffset != -1 && zomg != -1)
	SetEntData(zomg, secAmmoTypeOffset, 200, 4, true);
}

SaltoIronman(client)
{
	if (!IsClientInGame(client)) return;
	if (!IsPlayerAlive(client)) return;
	
	new Float:velocity[3];
	new Float:velocity0;
	new Float:velocity1;
	
	velocity0 = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	velocity1 = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	
	velocity[0] = (7.0 * velocity0) * (1.0 / 4.1);
	velocity[1] = (7.0 * velocity1) * (1.0 / 4.1);
	velocity[2] = 0.0;
	
	SetEntPropVector(client, Prop_Send, "m_vecBaseVelocity", velocity);
}

SaltoRobot(client)
{
	new Float:finalvec[3];
	finalvec[0]=GetEntDataFloat(client,VelocityOffset_0)*GetConVarFloat(hPush3)/2.0;
	finalvec[1]=GetEntDataFloat(client,VelocityOffset_1)*GetConVarFloat(hPush3)/2.0;
	finalvec[2]=GetConVarFloat(hHeight3)*50.0;
	SetEntDataVector(client,BaseVelocityOffset,finalvec,true);
	
	new Float:pos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	
	new number = GetRandomInt(1, 6);
	
	switch (number)
	{
	case 1:
		{
			EmitSoundToAll("npc/dog/dog_footstep_run1.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
		}
	case 2:
		{
			EmitSoundToAll("npc/dog/dog_footstep_run2.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
		}
	case 3:
		{
			EmitSoundToAll("npc/dog/dog_footstep_run3.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
		}
	case 4:
		{
			EmitSoundToAll("npc/dog/dog_footstep_run4.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
		}
	case 5:
		{
			EmitSoundToAll("npc/dog/dog_footstep_run5.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
		}
	case 6:
		{
			EmitSoundToAll("npc/dog/dog_footstep_run8.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
		}
	}
}

SaltoGallina(client)
{
	new Float:finalvec[3];
	finalvec[0]=GetEntDataFloat(client,VelocityOffset_0)*GetConVarFloat(hPush2)/2.0;
	finalvec[1]=GetEntDataFloat(client,VelocityOffset_1)*GetConVarFloat(hPush2)/2.0;
	finalvec[2]=GetConVarFloat(hHeight2)*50.0;
	SetEntDataVector(client,BaseVelocityOffset,finalvec,true);
	
	new Float:pos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	EmitSoundToAll("lduke/chicken/chicken.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
}

SaltoNormal(client)
{
	new Float:finalvec[3];
	finalvec[0]=GetEntDataFloat(client,VelocityOffset_0)*GetConVarFloat(hPush2)/2.0;
	finalvec[1]=GetEntDataFloat(client,VelocityOffset_1)*GetConVarFloat(hPush2)/2.0;
	finalvec[2]=GetConVarFloat(hHeight2)*50.0;
	SetEntDataVector(client,BaseVelocityOffset,finalvec,true);
	
	//new Float:pos[3];
	//GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	//EmitSoundToAll("lduke/chicken/chicken.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
}

SaltoZombie(client)
{
	new Float:finalvec[3];
	finalvec[0]=GetEntDataFloat(client,VelocityOffset_0)*GetConVarFloat(hPush1)/2.0;
	finalvec[1]=GetEntDataFloat(client,VelocityOffset_1)*GetConVarFloat(hPush1)/2.0;
	finalvec[2]=GetConVarFloat(hHeight1)*50.0;
	SetEntDataVector(client,BaseVelocityOffset,finalvec,true);
}

public Action:TraceHitPlayer(any:client)
{
	new Float:vAngles[3], Float:vOrigin[3], Float:AnglesVec[3], Float:EndPoint[3], Float:pos[3];
	
	new Float:Distance = 600.0;
	GetClientEyeAngles(client,vAngles);
	GetClientEyePosition(client,vOrigin);
	GetAngleVectors(vAngles, AnglesVec, NULL_VECTOR, NULL_VECTOR);
	
	EndPoint[0] = vOrigin[0] + (AnglesVec[0]*Distance);
	EndPoint[1] = vOrigin[1] + (AnglesVec[1]*Distance);
	EndPoint[2] = vOrigin[2] + (AnglesVec[2]*Distance);
	
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, EndPoint, MASK_SHOT, RayType_EndPoint, TraceEntityFilterPlayer, client);
	
	if (TR_DidHit(trace))
	{
		new TargetHit = TR_GetEntityIndex(trace);
		
		if ((TargetHit > 0) && (TargetHit <= GetMaxClients()))
		{
			new String:name[64];
			GetClientName(TargetHit, name, sizeof(name));
			
			if (GetClientTeam(TargetHit) != GetClientTeam(client))
			{		
				GetEntityAbsOrigin2(TargetHit,EndPoint);
				
				new Float:damage=GetConVarFloat(css_avp_damage);
				new Float:radius=GetConVarFloat(css_avp_radius);
				new Float:pushforce=GetConVarFloat(css_avp_pushforce);
				
				new pointHurt = CreateEntityByName("point_hurt");   
				
				DispatchKeyValueFloat(pointHurt, "Damage", damage);        
				DispatchKeyValueFloat(pointHurt, "DamageRadius", radius);     
				DispatchKeyValue(pointHurt, "DamageDelay", "0.0");   
				DispatchSpawn(pointHurt);
				TeleportEntity(pointHurt, EndPoint, NULL_VECTOR, NULL_VECTOR);  
				AcceptEntityInput(pointHurt, "Hurt", -1);    
				CreateTimer(0.1, DeletePointHurt, pointHurt); 
				
				
				new push = CreateEntityByName("point_push");         
				DispatchKeyValueFloat (push, "magnitude", pushforce);                     
				DispatchKeyValueFloat (push, "radius", radius*1.0);                     
				SetVariantString("spawnflags 24");                     
				AcceptEntityInput(push, "AddOutput");
				DispatchSpawn(push);   
				TeleportEntity(push, EndPoint, NULL_VECTOR, NULL_VECTOR);  
				AcceptEntityInput(push, "Enable", -1, -1);
				CreateTimer(0.5, DeletePushForce, push);
			}
		}
	}
	
	TR_GetEndPosition(pos, trace);
	//draw your beam
	
	CloseHandle(trace);
}

stock SpitEffect(const any:client)
{	
	if (IsPlayerAlive(client))
	{								
		new Float:vAngles[3];
		new Float:vOrigin[3];
		
		
		GetClientEyePosition(client, vOrigin);
		GetClientEyeAngles(client, vAngles);
		
		new particle = CreateEntityByName("env_smokestack");
		if (IsValidEdict(particle))
		{
			decl String:Name[32]; 
			Format(Name, sizeof(Name), "laser_%i", particle);
			DispatchKeyValue(particle, "targetname", Name);
			DispatchKeyValue(particle, "parentname", Name);
			DispatchKeyValueFloat(particle, "BaseSpread", 1.0);
			DispatchKeyValueFloat(particle, "StartSize", 1.0);
			DispatchKeyValueFloat(particle, "EndSize", 10.0);
			DispatchKeyValueFloat(particle, "Twist", 0.0);
			DispatchKeyValue(particle, "Name", Name);
			DispatchKeyValue(particle, "SmokeMaterial", "particle/fire.vmt");
			DispatchKeyValue(particle, "RenderColor", "0 255 80");
			DispatchKeyValue(particle, "SpreadSpeed", "30");
			DispatchKeyValue(particle, "RenderAmt", "50");
			DispatchKeyValue(particle, "JetLength", "400");
			DispatchKeyValue(particle, "Speed", "350");
			DispatchKeyValue(particle, "Rate", "500");
			DispatchSpawn(particle);
			TeleportEntity(particle, vOrigin, vAngles, NULL_VECTOR);
			
			SetVariantString("!activator");
			AcceptEntityInput(particle, "SetParent", client, particle, 0);
			SetVariantString("head");
			AcceptEntityInput(particle, "SetParentAttachment", client, client, 0);
			AcceptEntityInput(particle, "TurnOn");
			CreateTimer(2.0, RemoveParticle, particle);
			
			TraceHitPlayer(client);
		}
	}
}

public bool:TraceEntityFilterPlayer(entity, contentsMask, any:data)
{
	return data != entity;
}

GetEntityAbsOrigin2(TargetHit,Float:EndPoint[3]) 
{
	decl Float:mins[3], Float:maxs[3];
	
	GetEntPropVector(TargetHit,Prop_Send,"m_vecOrigin",EndPoint);
	GetEntPropVector(TargetHit,Prop_Send,"m_vecMins",mins);
	GetEntPropVector(TargetHit,Prop_Send,"m_vecMaxs",maxs);
	
	EndPoint[0] += (mins[0] + maxs[0]) * 0.5;
	EndPoint[1] += (mins[1] + maxs[1]) * 0.5;
	EndPoint[2] += (mins[2] + maxs[2]) * 0.5;
}

Spiderman(X)
{
	//Wall?
	new bool:NearWall = false;
	
	//Circle:
	for(new AngleRotate = 0; AngleRotate < 360; AngleRotate += 30)
	{
		
		//Declare:
		decl Handle:TraceRay;
		decl Float:StartOrigin[3], Float:Angles[3];
		
		//Initialize:
		Angles[0] = 0.0;
		Angles[2] = 0.0;
		Angles[1] = float(AngleRotate);
		GetClientEyePosition(X, StartOrigin);
		
		//Ray:
		TraceRay = TR_TraceRayEx(StartOrigin, Angles, MASK_SOLID, RayType_Infinite);
		
		//Collision:
		if (TR_DidHit(TraceRay))
		{
			
			//Declare:
			decl Float:Distance;
			decl Float:EndOrigin[3];
			
			//Retrieve:
			TR_GetEndPosition(EndOrigin, TraceRay);
			
			//Distance:
			Distance = (GetVectorDistance(StartOrigin, EndOrigin));
			
			//Allowed:
			if (Distance < 50) NearWall = true;
			
		}
		
		//Close:
		CloseHandle(TraceRay);
		
	}
	
	//Ceiling:
	decl Handle:TraceRay;
	decl Float:StartOrigin[3];
	new Float:Angles[3] =  {270.0, 0.0, 0.0};
	
	//Initialize:
	GetClientEyePosition(X, StartOrigin);
	
	//Ray:
	TraceRay = TR_TraceRayEx(StartOrigin, Angles, MASK_SOLID, RayType_Infinite);
	
	//Collision:
	if (TR_DidHit(TraceRay))
	{
		//Declare:
		decl Float:Distance;
		decl Float:EndOrigin[3];
		
		//Retrieve:
		TR_GetEndPosition(EndOrigin, TraceRay);
		
		//Distance:
		Distance = (GetVectorDistance(StartOrigin, EndOrigin));
		
		//Allowed:
		if (Distance < 50) NearWall = true;
	}
	
	//Close:
	CloseHandle(TraceRay);
	
	//Near:
	if (NearWall)
	{ 
		
		//Almost Zero:
		SetEntityGravity(X, Pow(Pow(100.0, 3.0), -1.0));
		
		//Buttons:
		decl ButtonBitsum;
		ButtonBitsum = GetClientButtons(X);
		
		//Origin:
		decl Float:ClientOrigin[3];
		GetClientAbsOrigin(X, ClientOrigin);
		
		//Angles:
		decl Float:ClientEyeAngles[3];
		GetClientEyeAngles(X, ClientEyeAngles);
		
		//Declare:
		decl Float:VeloX, Float:VeloY, Float:VeloZ;
		
		//Initialize:
		VeloX = (Speed * Cosine(DegToRad(ClientEyeAngles[1])));
		VeloY = (Speed * Sine(DegToRad(ClientEyeAngles[1])));
		VeloZ = (Speed * Sine(DegToRad(ClientEyeAngles[0])));
		
		
		//Jumping:
		if (ButtonBitsum & IN_JUMP)
		{
			
			//Stop:
			new Float:Velocity[3] = {0.0, 0.0, 0.0};
			TeleportEntity(X, ClientOrigin, NULL_VECTOR, Velocity);
		}
		
		//Forward:
		if (ButtonBitsum & IN_FORWARD)
		{
			
			//Forward:
			new Float:Velocity[3];
			Velocity[0] = VeloX;
			Velocity[1] = VeloY;
			Velocity[2] = (VeloZ - (VeloZ * 2));
			TeleportEntity(X, ClientOrigin, NULL_VECTOR, Velocity);
		}
		
		//Backward:
		else if (ButtonBitsum & IN_BACK)
		{
			
			//Backward:
			new Float:Velocity[3];
			Velocity[0] = (VeloX - (VeloX * 2));
			Velocity[1] = (VeloY - (VeloY * 2));
			Velocity[2] = VeloZ;
			TeleportEntity(X, ClientOrigin, NULL_VECTOR, Velocity);
		}
		
		//Null:
		else 
		{
			
			//Stop:
			new Float:Velocity[3] = {0.0, 0.0, 0.0};
			TeleportEntity(X, ClientOrigin, NULL_VECTOR, Velocity);
		}
		
	}
	
	//Default:
	else SetEntityGravity(X, 1.0);	
	
}

FastFire(client) 
{ 
	new ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
	if(IsValidEntity(ActiveWeapon)) 
	{ 
		if (ActiveWeapon != -1) 
		{ 
			if (g_RapidFire[client]) 
			{ 
				SetEntPropFloat(ActiveWeapon, Prop_Send, "m_flNextPrimaryAttack", 0.50); 
				SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime()); 
				SetEntProp(client, Prop_Send, "m_iShotsFired", 0); 
				
				new Float:NoRecoil[3] = {0.0, 0.0, 0.0}; 
				SetEntPropVector(client, Prop_Send, "m_vecPunchAngle", NoRecoil); 
			} 
			else if (g_Batman[client]) 
			{ 
				SetEntPropFloat(ActiveWeapon, Prop_Send, "m_flNextPrimaryAttack", 0.80); 
				SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime()); 
				SetEntProp(client, Prop_Send, "m_iShotsFired", 0); 
				
				new Float:NoRecoil[3] = {0.0, 0.0, 0.0}; 
				SetEntPropVector(client, Prop_Send, "m_vecPunchAngle", NoRecoil); 
			}
		} 
	} 
}

stock DoubleJump(const any:client) {
	new fCurFlags	= GetEntityFlags(client);		// current flags
	new fCurButtons	= GetClientButtons(client);		// current buttons
	
	if (g_fLastFlags[client] & FL_ONGROUND) {		// was grounded last frame
		if (
				!(fCurFlags & FL_ONGROUND) &&			// becomes airbirne this frame
				!(g_fLastButtons[client] & IN_JUMP) &&	// was not jumping last frame
				fCurButtons & IN_JUMP					// started jumping this frame
				) {
			OriginalJump(client);					// process jump from the ground
		}
	} else if (										// was airborne last frame
			fCurFlags & FL_ONGROUND						// becomes grounded this frame
			) {
		Landed(client);								// process landing on the ground
	} else if (										// remains airborne this frame
			!(g_fLastButtons[client] & IN_JUMP) &&		// was not jumping last frame
			fCurButtons & IN_JUMP						// started jumping this frame
			) {
		ReJump(client);								// process attempt to double-jump
	}
	
	g_fLastFlags[client]	= fCurFlags;				// update flag state for next frame
	g_fLastButtons[client]	= fCurButtons;			// update button state for next frame
}

stock OriginalJump(const any:client) {
	g_iJumps[client]++;	// increment jump count
}

stock Landed(const any:client) {
	g_iJumps[client] = 0;	// reset jumps count
}

stock ReJump(const any:client) {
	if ( 1 <= g_iJumps[client] <= g_iJumpMax) {						// has jumped at least once but hasn't exceeded max re-jumps
		g_iJumps[client]++;											// increment jump count
		decl Float:vVel[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);	// get current speeds
		
		vVel[2] = g_flBoost;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);		// boost player
	}
}

public convar_ChangeBoost(Handle:convar, const String:oldVal[], const String:newVal[]) {
	g_flBoost = StringToFloat(newVal);
}

public convar_ChangeMax(Handle:convar, const String:oldVal[], const String:newVal[]) {
	g_iJumpMax = StringToInt(newVal);
}

Teleportar(client)
{
	
	new teleportn = GetRandomInt(1, 16);
	
	PrintToChat(client, "Teleportado a: %i", teleportn);
	
	switch (teleportn)
	{
	case 1:
		{
			new Float:site1[3] = sitio1;
			TeleportEntity(client, site1, NULL_VECTOR, NULL_VECTOR); 
		}
	case 2:
		{    
			new Float:site2[3] = sitio2;
			TeleportEntity(client, site2, NULL_VECTOR, NULL_VECTOR); 
		}
	case 3:
		{
			new Float:site3[3] = sitio3;
			TeleportEntity(client, site3, NULL_VECTOR, NULL_VECTOR); 
		}
	case 4:
		{    
			new Float:site4[3] = sitio4;
			TeleportEntity(client, site4, NULL_VECTOR, NULL_VECTOR); 
		}
	case 5:
		{
			new Float:site5[3] = sitio5;
			TeleportEntity(client, site5, NULL_VECTOR, NULL_VECTOR); 
		}
	case 6:
		{    
			new Float:site6[3] = sitio6;
			TeleportEntity(client, site6, NULL_VECTOR, NULL_VECTOR); 
		}
	case 7:
		{
			new Float:site7[3] = sitio7;
			TeleportEntity(client, site7, NULL_VECTOR, NULL_VECTOR); 
		}
	case 8:
		{    
			new Float:site8[3] = sitio8;
			TeleportEntity(client, site8, NULL_VECTOR, NULL_VECTOR); 
		}
	case 9:
		{
			new Float:site9[3] = sitio9;
			TeleportEntity(client, site9, NULL_VECTOR, NULL_VECTOR); 
		}
	case 10:
		{    
			new Float:site10[3] = sitio10;
			TeleportEntity(client, site10, NULL_VECTOR, NULL_VECTOR); 
		}
	case 11:
		{
			new Float:site11[3] = sitio11;
			TeleportEntity(client, site11, NULL_VECTOR, NULL_VECTOR); 
		}
	case 12:
		{    
			new Float:site12[3] = sitio12;
			TeleportEntity(client, site12, NULL_VECTOR, NULL_VECTOR); 
		}
	case 13:
		{
			new Float:site13[3] = sitio13;
			TeleportEntity(client, site13, NULL_VECTOR, NULL_VECTOR); 
		}
	case 14:
		{    
			new Float:site14[3] = sitio14;
			TeleportEntity(client, site14, NULL_VECTOR, NULL_VECTOR); 
		}
	case 15:
		{
			new Float:site15[3] = sitio15;
			TeleportEntity(client, site15, NULL_VECTOR, NULL_VECTOR); 
		}
	case 16:
		{    
			new Float:site16[3] = sitio16;
			TeleportEntity(client, site16, NULL_VECTOR, NULL_VECTOR); 
		}
	}
}

stock Alien_Vision(const any:client)
{
	new Handle:message = StartMessageOne("Fade", client, 1);
	
	if (IsClientInGame(client) && IsClientConnected(client) && IsPlayerAlive(client))
	{
		//FFADE_IN            0x0001        // Just here so we don't pass 0 into the function
		//FFADE_OUT           0x0002        // Fade out (not in)
		//FFADE_MODULATE      0x0004        // Modulate (don't blend)
		//FFADE_STAYOUT       0x0008        // ignores the duration, stays faded out until new ScreenFade message received
		//FFADE_PURGE         0x0010        // Purges all other fades, replacing them with this one
		
		
		SetEntData(client, m_iFOV, 120, 4, true);
		BfWriteShort(message, 585);
		BfWriteShort(message, 585);
		BfWriteShort(message, (0x0008)); //Fade out
		BfWriteByte(message, 200); //fade red
		BfWriteByte(message, 0); //fade green
		BfWriteByte(message, 0); //fade blue
		BfWriteByte(message, 30); //fade alpha
		EndMessage();
	}
}

stock Normal_Vision(const any:client)
{
	new Handle:message = StartMessageOne("Fade", client, 1);
	
	if (IsClientInGame(client) && IsClientConnected(client))
	{
		//FFADE_IN            0x0001        // Just here so we don't pass 0 into the function
		//FFADE_OUT           0x0002        // Fade out (not in)
		//FFADE_MODULATE      0x0004        // Modulate (don't blend)
		//FFADE_STAYOUT       0x0008        // ignores the duration, stays faded out until new ScreenFade message received
		//FFADE_PURGE         0x0010        // Purges all other fades, replacing them with this one
		
		
		SetEntData(client, m_iFOV, 90, 4, true);
		BfWriteShort(message, 585);
		BfWriteShort(message, 585);
		BfWriteShort(message, (0x0008)); //Fade out
		BfWriteByte(message, 0); //fade red
		BfWriteByte(message, 0); //fade green
		BfWriteByte(message, 0); //fade blue
		BfWriteByte(message, 0); //fade alpha
		EndMessage();
	}
}

BorrarPuertas()
{
	for(new i=0;i<sizeof(doorlist);++i)
	{
		while((iEnt = FindEntityByClassname(iEnt, doorlist[i])) != -1)
		{
			AcceptEntityInput(iEnt, "Disable");
			AcceptEntityInput(iEnt, "Kill"); 
			RemoveEdict(iEnt);		
		}
	}
}

// -- FINAL FUNCIONES
//--------------------------------------------------------------//
// ##################### EVENTOS / FORWARDS ##################### //
//--------------------------------------------------------------//
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
    if (buttons & IN_USE) 
	{
		if (Client_IsValid(client) && IsPlayerAlive(client))
		{
			if (g_Batman[client])
			{
				new target_index = GetClientAimTarget(client, true);
				new target = GetClientOfUserId(target_index);
				decl Float:ClientOrigin[3],Float:TargetOrigin[3], Float:Distance;
				
				if (IsPlayerAlive(target))
				{
					GetClientAbsOrigin(client, ClientOrigin);	
					GetClientAbsOrigin(target, TargetOrigin);	

					Distance = GetVectorDistance(ClientOrigin, TargetOrigin);
					
					if (Distance <= 100.0)
					{
						if (g_Golpeado[client])
						{
							new randslap = GetRandomInt(10, 500);
							SlapPlayer(target, randslap, true);
							g_Golpeado[client] = true;
							CreateTimer(0.5, LimpiarGolpeado, client);
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes golpear todavia!.");
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05El objetivo esta demasiado lejos.");
					}				
				}
			}
		}
    }
}
public Action:PlayerFootstep(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (g_cosa[client])
	{
		if (g_Zombie[client])
		{
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);
		}
		if (g_NoMuerto[client])
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255);
			}
			else if (GetClientTeam(client) == CS_TEAM_CT)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 0, 0, 255, 255);
			}			
		}	
		if (g_Santa[client])
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255);
			}
			else if (GetClientTeam(client) == CS_TEAM_CT)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 0, 0, 255, 255);
			}	
		}
		if (g_Monster[client])
		{
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);
		}
		if (g_Robot[client])
		{
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);
		}
		if (g_Ironman[client])
		{
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);
		}
		if (g_Paloma[client])
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 0, 0, 0, 255);
			}
			else if (GetClientTeam(client) == CS_TEAM_CT)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255);
			}
		}
		if (g_Fantasma[client])
		{
			SetEntityRenderMode(client, RENDER_TRANSCOLOR);
			SetEntityRenderColor(client, 255, 255, 255, 128);
		}
		if (g_Gallina[client])
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 0, 0, 0, 255);
			}
			else if (GetClientTeam(client) == CS_TEAM_CT)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255);
			}
		}
		if (g_Godmode[client])
		{
			SetEntityRenderColor(client, 0, 255, 255, 255);
			SetEntityRenderMode(client, RENDER_NORMAL);
		}
		if (g_Bicho[client])
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255);
			}
			else if (GetClientTeam(client) == CS_TEAM_CT)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 0, 0, 255, 255);
			}
		}
		if (g_Soldado[client])
		{
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);
		}	
		if (g_Smith[client])
		{
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);
		}
		if (g_Jack[client])
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255);
			}
			else if (GetClientTeam(client) == CS_TEAM_CT)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 0, 0, 255, 255);
			} 
		}
		if (g_Groudon[client])
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255);
			}
			else if (GetClientTeam(client) == CS_TEAM_CT)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 0, 0, 255, 255);
			} 
		}
		if (g_Pikachu[client])
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255);
			}
			else if (GetClientTeam(client) == CS_TEAM_CT)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 0, 0, 255, 255);
			} 
		}
		if (g_NoMuerto[client])
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255);
			}
			else if (GetClientTeam(client) == CS_TEAM_CT)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 0, 0, 255, 255);
			} 
		}		
		if (g_Spiderman[client])
		{
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);	
		}
		if (g_Goku[client])
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255);
			}
			else if (GetClientTeam(client) == CS_TEAM_CT)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 0, 0, 255, 255);
			}
		}
		
		if (g_Predator[client])
		{
			SetEntityRenderMode(client, RENDER_TRANSCOLOR);
			SetEntityRenderColor(client, 100, 100, 100, 100);	
		}
		if (g_Pene[client])
		{
			SetEntityRenderMode(client, RENDER_TRANSCOLOR);
			SetEntityRenderColor(client, 255, 255, 255, 0);
			
			new wepIdx;
			
			// strip all weapons
			for (new s = 0; s < 5; s++)
			{
				if ((wepIdx = GetPlayerWeaponSlot(client, s)) != -1)
				{
					SetEntityRenderMode(wepIdx, RENDER_TRANSCOLOR);
					SetEntityRenderColor(wepIdx, 255, 255, 255, 0);
				}
			}
		}
		if (g_Trainer[client])
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255);
			}
			else if (GetClientTeam(client) == CS_TEAM_CT)
			{
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 0, 0, 255, 255);
			}
		}
		if (g_Reina[client])
		{
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);
		}
		ResizePlayer(client, 1.0);
		/*if (GetClientTeam(client) == CS_TEAM_CT)
		{
			if (JC_GetCaptain() == client)
			{
				SetEntityRenderColor(client, 255, 150, 0, 255);
			}
		}*/
	}
	return Plugin_Continue;
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	// Ser Amado
	if (g_Amor[victim])
	{
		if (Client_IsValid(attacker) && GetClientTeam(attacker) != GetClientTeam(victim))
		{
			if(damagetype == DMG_POISON) return Plugin_Continue;
			else PrintHintText(attacker, "El amor no se le vence con armas!");
		}
		return Plugin_Handled;
	}
	
	// Ataques del Megarobot, Monstruo y Pene
	if (Client_IsValid(attacker))
	{		
		if (g_Robot[attacker] || g_Monster[attacker] || g_Pene[attacker])
		{
			if (GetClientTeam(attacker) != GetClientTeam(victim))
			{
				new Float:iVec[ 3 ];
				GetClientAbsOrigin( victim, Float:iVec );
				
				TE_SetupExplosion( iVec, g_ExplosionSprite, 5.0, 1, 0, 50, 40, iNormal );
				TE_SendToAll();
				
				TE_SetupSmoke( iVec, g_SmokeSprite, 10.0, 3 );
				TE_SendToAll();
				
				EmitAmbientSound( EXPLODE_SOUND, iVec, victim, SNDLEVEL_NORMAL );
				
				damage = (damage + 10000);
				if (g_Fantasma[victim])
				{
					ForcePlayerSuicide(victim);
				}
				return Plugin_Changed;
			}
		}
	}
	
	// Mostrar la vida de los Seres Especiales
	if (g_cosa[victim])
	{
		new ShowHealthCosa = GetClientHealth(victim);
		PrintHintText(victim, "%i HP", ShowHealthCosa);	
	}

	// Godmode
	if (g_Godmode[victim])
	{
		damage = 0.0;
		return Plugin_Changed;
	}
	
	// Vida del Fantasma
	else if (g_Fantasma[victim])
	{
		if (Client_IsValid(attacker) && GetClientTeam(attacker) != GetClientTeam(victim))
		{
			g_Golpes[victim] += 1;
			
			if (g_Golpes[victim] >= GetConVarInt(HealthFantasma))
			{
				ForcePlayerSuicide(victim);
			}
		}
	}
	
	// Esquivar balas de Smith, Jack y Spiderman
	else if (g_Smith[victim] || g_Jack[victim] || g_Spiderman[victim])
	{
		if (Client_IsValid(attacker))
		{
			new smith_d = GetRandomInt(1, 10);
			switch (smith_d)
			{
			case 1:
				{
					damage = damage * 0.6;
					return Plugin_Changed;
				}
			case 2:
				{
					damage = damage * 0.6;
					return Plugin_Changed;
				}
			case 3:
				{
					damage = damage * 0.6;
					return Plugin_Changed;
				}
			case 4:
				{
					new Float:pos[3];
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
					EmitSoundToAll("player/suit_sprint.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
					
					return Plugin_Handled;
				}
			case 5:
				{
					new Float:pos[3];
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
					EmitSoundToAll("player/suit_sprint.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
					
					return Plugin_Handled;
				}
			case 6:
				{
					new Float:pos[3];
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
					EmitSoundToAll("player/suit_sprint.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
					
					return Plugin_Handled;
				}
			case 7:
				{
					new Float:pos[3];
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
					EmitSoundToAll("player/suit_sprint.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
					
					return Plugin_Handled;
				}
			case 8:
				{
					new Float:pos[3];
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
					EmitSoundToAll("player/suit_sprint.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
					
					return Plugin_Handled;
				}
			case 9:
				{
					new Float:pos[3];
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
					EmitSoundToAll("player/suit_sprint.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
					
					return Plugin_Handled;
				}
			case 10:
				{
					new Float:pos[3];
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
					EmitSoundToAll("player/suit_sprint.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
					
					return Plugin_Handled;
				}
			}
		}
	}
	
	// Sonidos al dañar a Goku o Ironman
	else if (g_Ironman[victim] || g_Goku[victim])
	{
		new number999 = GetRandomInt(1, 5);
		switch (number999)
		{
		case 1:
			{
				new Float:pos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
				EmitSoundToAll("weapons/fx/rics/ric1.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
		case 2:
			{
				new Float:pos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
				EmitSoundToAll("weapons/fx/rics/ric2.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
		case 3:
			{
				new Float:pos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
				EmitSoundToAll("weapons/fx/rics/ric3.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
		case 4:
			{
				new Float:pos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
				EmitSoundToAll("weapons/fx/rics/ric4.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
		case 5:
			{
				new Float:pos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
				EmitSoundToAll("weapons/fx/rics/ric5.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
		}
		
		// Reducir el daño que recibe Goku y Ironman
		if (g_Goku[victim])
		{
			damage = damage * 0.1;
			return Plugin_Changed;
		}
		else
		{
			
			damage = damage * 0.2;
			return Plugin_Changed;
		}
	}
	
	// Reducir el daño que recibe Batman
	else if (g_Batman[victim])
	{
		damage = damage * 0.2;
		PrintToChatAll("Reduccion de daño");
		return Plugin_Changed;
	}
	
	// Sonidos al dañar al zombie
	else if (g_Zombie[victim])
	{
		new number = GetRandomInt(1, 6);
		switch (number)
		{
		case 1:
			{
				new Float:pos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
				EmitSoundToAll("npc/zombie/zombie_pain1.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
		case 2:
			{
				new Float:pos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
				EmitSoundToAll("npc/zombie/zombie_pain2.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
		case 3:
			{
				new Float:pos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
				EmitSoundToAll("npc/zombie/zombie_pain3.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
		case 4:
			{
				new Float:pos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
				EmitSoundToAll("npc/zombie/zombie_pain4.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
		case 5:
			{
				new Float:pos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
				EmitSoundToAll("npc/zombie/zombie_pain5.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
		case 6:
			{
				new Float:pos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
				EmitSoundToAll("npc/zombie/zombie_pain6.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
		}
	}
	
	if(!Client_IsValid(attacker))
	return Plugin_Continue;
	
	// Evitar otras armas congeladoras

	new WeaponIndex = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	
	new String:g_Weapon[32];
	GetClientWeapon(attacker, g_Weapon, sizeof(g_Weapon));
	
	if (WeaponIndex < 0) return Plugin_Continue;
	if (IsValidEntity(WeaponIndex) && AwpFreeze[WeaponIndex]) 
	{
		// Evitar otras armas congeladoras
		if (StrEqual(g_Weapon, "weapon_awp"))
		{
			SetEntityMoveType(victim, MOVETYPE_NONE);
			SetEntityRenderColor(victim, 0, 128, 255, 192);
			new Float:vec[3];
			GetClientEyePosition(victim, vec);
			EmitAmbientSound(SOUND_FREEZE, vec, victim, SNDLEVEL_RAIDSIREN);
			CreateTimer(GetConVarFloat(Timer_AwpFreeze), AwpDescongelar, victim);
		}
		else
		{
			new wepIdx = GetPlayerWeaponSlot(attacker, 0);
			RemovePlayerItem(attacker, wepIdx);
			RemoveEdict(wepIdx);
			ConvertirAwpFreeze(attacker);
		}
	}	
	return Plugin_Continue;
}

public Action:PlayerJump(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// Saltos de los Seres Especiales
	if (g_Robot[client]) SaltoRobot(client);
	else if (g_Ironman[client]) SaltoIronman(client);
	else if (g_Gallina[client]) SaltoGallina(client);
	else if (g_Spiderman[client]) SaltoNormal(client);
	else if (g_Monster[client]) SaltoNormal(client);
	else if (g_Predator[client]) SaltoNormal(client);
	else if (g_Goku[client]) SaltoNormal(client);
	else if (g_Zombie[client]) SaltoZombie(client);
	else if (g_Batman[client]) SaltoNormal(client);
}

public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	CreateTimer(2.0, MensajesMuerte, client);
	SetClientThrowingKnives(client, 0);

	// Borrar el Pene del mapa
	if(g_Pene[client])
	{
		if(g_Attachments[client] != 0 && IsValidEdict(g_Attachments[client]))
		{
			RemoveEdict(g_Attachments[client]);
			g_Attachments[client]=0;
		}
	}
	
	// No hay atacante
	if (!attacker)
		return;
	
	// El atacante es la víctima
	if (attacker == client)
		return;
	
	// Obtener la mitad de los créditos de un Ser Especial al matarlo
	if (g_cosa[client])
	{
		if (g_Medic[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new AmorDif = GetConVarInt(CostMedic) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(AmorDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", AmorDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}	
		if (g_Amor[client])
		{
			new Float:pos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
			EmitSoundToAll("franug/amor_logrado.mp3", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);

			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new AmorDif = 20 / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(AmorDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", AmorDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}
		if (g_Zombie[client])
		{
			Normal_Vision(client);
			
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new ZombieDif = GetConVarInt(CostZombie) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(ZombieDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", ZombieDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}
		if (g_Monster[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new MonstruoDif = GetConVarInt(CostMonstruo) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(MonstruoDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", MonstruoDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}
		if (g_Ironman[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new IronmanDif = GetConVarInt(CostIronman) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(IronmanDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", IronmanDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}	
		if (g_Robot[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new RobotDif = GetConVarInt(CostRobot) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(RobotDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", RobotDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}		
		if (g_Bicho[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new BichoDif = GetConVarInt(CostBicho) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(BichoDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", BichoDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}	
		if (g_Soldado[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new SoldadoDif = GetConVarInt(CostSoldado) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(SoldadoDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", SoldadoDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}	
		if (g_Spiderman[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new SpidermanDif = GetConVarInt(CostSpiderman) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(SpidermanDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", SpidermanDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}	
		if (g_Goku[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new GokuDif = GetConVarInt(CostGoku) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(GokuDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", GokuDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}	
		if (g_Paloma[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new PalomaDif = 5 / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(PalomaDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", PalomaDif);
			}
			else
			{
			g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
			PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}		
		if (g_Gallina[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
			new GallinaDif = 5 / GetConVarInt(Dif);
			g_iCredits[attacker] += RoundToCeil(float(GallinaDif));
			PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", GallinaDif);
			}
			else
			{
			g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
			PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}	
		}
		if (g_Smith[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new SmithDif = GetConVarInt(CostSmith) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(SmithDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", SmithDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}		
		if (g_Jack[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new JackDif = GetConVarInt(CostJack) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(JackDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", JackDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}	
		if (g_Groudon[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new GroudonDif = GetConVarInt(CostGroudon) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(GroudonDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", GroudonDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}		
		if (g_Fantasma[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new FantasmaDif = GetConVarInt(CostFantasma) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(FantasmaDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", FantasmaDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}	
		if (g_Pikachu[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new PikachuDif = GetConVarInt(CostPikachu) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(PikachuDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", PikachuDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}		
		if (g_Predator[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new PredatorDif = GetConVarInt(CostPredator) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(PredatorDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", PredatorDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}			
		if (g_Reina[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new ReinaDif = GetConVarInt(CostReina) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(ReinaDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", ReinaDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}					
		if (g_Santa[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new SantaDif = GetConVarInt(CostSanta) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(SantaDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", SantaDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}
		if (g_Pene[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new PeneDif = GetConVarInt(CostPene) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(PeneDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", PeneDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}
		if (g_Trainer[client])
		{
			if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
			{
				new TrainerDif = GetConVarInt(CostTrainer) / GetConVarInt(Dif);
				g_iCredits[attacker] += RoundToCeil(float(TrainerDif));
				PrintToChat(attacker, "\x04[Franug-JailPlugins] \x05Has ganado \x04%i \x05creditos", TrainerDif);
			}
			else
			{
				g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
				PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);			
			}
		}		
	}
	else
	{
		g_iCredits[attacker] += GetConVarInt(cvarCreditsKill);
		if (Client_IsAdmin(attacker))
		{
			PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Gracias por abonar tu cuota. Recibes 2 creditos mas");
			g_iCredits[attacker] += 2;
		}
		
		if (g_iCredits[attacker] < GetConVarInt(cvarCreditsMax))
		{
			PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (+%d)", g_iCredits[attacker], GetConVarInt(cvarCreditsKill));
		}
		else
		{
			g_iCredits[attacker] = GetConVarInt(cvarCreditsMax);
			PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (Maximo permitido)", g_iCredits[attacker]);
		}				
	}
	
	if (GetClientTeam(attacker) != 2)
		return;
	
	if (g_Muertes[attacker] > 0)
	{
		
		if (N_Mision == 7)
		{
			g_Muertes[attacker] -= 1;
			
			if (g_Muertes[attacker] == 0)
			{
				PrintToChat(attacker, "\x04[SM_Franug-JailObjetivos] \x01Enhorabuena! has cumplido tu mision! ganas %i creditos!", GetConVarInt(Premio_C));
				g_iCredits[attacker] += GetConVarInt(Premio_C);
				g_Muertes[attacker] = -2;
			}
			else
			{
				PrintToChat(attacker, "\x04[SM_Franug-JailObjetivos] \x01Tienes que matar a \x03%i \x01guardias mas!", g_Muertes[attacker]);
			}
			
		}
		else
		{
			//GetEventString(event,"weapon",weaponIDF,29);
			
			//GetEventInt(event, "weapon")
			GetEventString(event,"weapon",Arma_Damage_si,29);
			
			
			
			if (StrEqual(Arma_Damage_si, Arma_Enuso))
			{
				g_Muertes[attacker] -= 1;
				
				if (g_Muertes[attacker] == 0)
				{
					PrintToChat(attacker, "\x04[SM_Franug-JailObjetivos] \x01Enhorabuena! has cumplido tu mision! ganas %i creditos!", GetConVarInt(Premio_C));
					g_iCredits[attacker] += GetConVarInt(Premio_C);
					g_Muertes[attacker] = -2;
				}
				else
				{
					PrintToChat(attacker, "\x04[SM_Franug-JailObjetivos] \x01Tienes que matar a \x03%i \x01guardias mas con ese arma!", g_Muertes[attacker]);
				}
			}
		}
	}	
}

public Action:Event_hurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if (attacker == 0)
	{
		return;
	}
	
	
	if (g_Bomba[client])
	{
		if (GetClientTeam(attacker) != GetClientTeam(client))
		{
			new Vidaa = GetClientHealth(client);
			new Damage_Recibido = GetEventInt(event, "dmg_health");
			
			if (Vidaa <= Damage_Recibido)
			{
				Detonate(client);
				//PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05El guardia\x03 %N \x05ha hecho estallar al KAMIKAZE EXPLOSIVO!", attacker);
			}
		}
	}
	
	
	
	//else if (g_Spiderman[attacker])
	//{
	//  if (GetClientTeam(attacker) != GetClientTeam(client))
	//  {
	//     FreezeClient(client);
	//  }
	//}
	
	if (g_Groudon[attacker])
	{
		if (GetClientTeam(attacker) != GetClientTeam(client))
		{
			
			GetEventString(event,"weapon",weaponIDG,29);
			
			if (StrEqual(weaponIDG, "knife"))
			{
				new Float:iVec[ 3 ];
				GetClientAbsOrigin(client, Float:iVec);
				
				TE_SetupExplosion(iVec, g_ExplosionSprite, 5.0, 1, 0, 50, 40, iNormal);
				TE_SendToAll();
				
				TE_SetupSmoke(iVec, g_SmokeSprite, 10.0, 3 );
				TE_SendToAll();
				
				EmitAmbientSound( EXPLODE_SOUND, iVec, client, SNDLEVEL_NORMAL );
				
				//DealDamage(client,9999,attacker,DMG_GENERIC,"knife");
				DealDamage(client,9999,attacker,DMG_SLASH," ");
			}
		}
	}
	
	else if (g_Spiderman[attacker])
	{
		if (GetClientTeam(attacker) != GetClientTeam(client))
		{
			CongelarCliente(client);
		}
	}
	else if (g_Bicho[attacker])
	{
		if (GetClientTeam(attacker) != GetClientTeam(client))
		{
			IgniteEntity(client, 5.0);
		}
	}
	else if (g_Goku[attacker])
	{
		if (GetClientTeam(attacker) != GetClientTeam(client))
		{
			Shake(client, AMP_SHAKE, DUR_SHAKE);
		}
	}
	if(g_hRegenTimer[client] == INVALID_HANDLE)
	{
		g_hRegenTimer[client] = CreateTimer(1.0, Regenerate, client, TIMER_REPEAT);
	}
}

public Action:OnWeaponCanUse(client, weapon)
{
	if (g_Noweapons[client])
	{
		// block switching to weapon other than knife
		decl String:sClassname[32];
		GetEdictClassname(weapon, sClassname, sizeof(sClassname));
		if (!StrEqual(sClassname, "weapon_knife"))
		return Plugin_Handled;
	}
	else if(g_Trainer[client])
	{
		decl String:sClassname[32];
		GetEdictClassname(weapon, sClassname, sizeof(sClassname));
		if (!StrEqual(sClassname, "weapon_hegrenade"))
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	ServerCommand("sm_dados_usados 0");
	ServerCommand("sm_dados_ctusados 0");
	//ServerCommand("sm_robots_numero 0");

	g_RondaEspecial = false;
	Fin_Ronda = false;

	new maxent = GetMaxEntities();
	for (new i=GetMaxClients();i<maxent;i++)
	{
		if ( IsValidEdict(i) && IsValidEntity(i) )
		{
			if(AwpFreeze[i])
			{
				AwpFreeze[i]=false;
			}
			if(Ganzua[i])
			{
				Ganzua[i]=false;
			}			
		}
	}	
	
	new indexent = -1;
	while((indexent = FindEntityByClassname(indexent, "luzent")) != -1)
	{
		AcceptEntityInput(indexent, "Disable");
		AcceptEntityInput(indexent, "Kill"); 
		RemoveEdict(indexent);		
	}		
	
	new misionn = GetRandomInt(1, 11);
	
	for (new i = 1; i < GetMaxClients(); i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2)
		{
			
			g_ZResucitar[i] = false;
			PrintToChat(i, "\x04[SM_Franug-JailObjetivos] \x01Asignando una mision...");
			
			
			switch (misionn)
			{
			case 1:
				{
					CreateTimer(3.0, Mision1, i);
				}
			case 2:
				{
					CreateTimer(3.0, Mision2, i);
				}
			case 3:
				{
					CreateTimer(3.0, Mision3, i);
				}
			case 4:
				{
					CreateTimer(3.0, Mision4, i);
				}
			case 5:
				{
					CreateTimer(3.0, Mision5, i);
				}
			case 6:
				{
					CreateTimer(3.0, Mision6, i);
				}
			case 7:
				{
					CreateTimer(3.0, Mision7, i);
				}
			case 8:
				{
					CreateTimer(3.0, Mision8, i);
				}
			case 9:
				{
					CreateTimer(3.0, Mision9, i);
				}
			case 10:
				{
					CreateTimer(3.0, Mision10, i);
				}
			case 11:
				{
					CreateTimer(3.0, Mision11, i);
				}
			}
		}
	}
	if (GetConVarBool(RondasEspeciales))
	{
		
		new randomespecial = GetRandomInt(1, 20);
		switch (randomespecial)
		{
		case 1:
			{
				CreateTimer(3.0, SuperMonsterTimer, client);
				g_RondaEspecial = true;
			}
		case 2:
			{
				CreateTimer(3.0, TrainerVsGroudonTimer, client);
				g_RondaEspecial = true;
			}
		}	
	}
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

		
	if(GetClientTeam(client) == 2 || GetClientTeam(client) == 3)
		CreateTimer(1.0, MensajesSpawn, client);

	Normalizar(client);
}

public Action:Event_RoundEnd(Handle: event , const String: name[] , bool: dontBroadcast)
{
	for (new i = 1; i < GetMaxClients(); i++)
	{
		if (IsClientInGame(i) && Client_IsValid(i) &&  GetClientTeam(i) != 1)
		{
			g_iCredits[i] += 2;
			if (Client_IsAdmin(i))
			{
				PrintToChat(i, "\x04[SM_Franug-JailPlugins] \x05Gracias por abonar tu couta. Recibes 2 creditos mas");
				g_iCredits[i] += 2;
			}
			
		}
	}
	Fin_Ronda = true;
	PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Cada final de ronda, todos los que estan en un equipo reciben 2 creditos gratis");
}

public OnClientPostAdminCheck(client)
{
	if (!client || IsFakeClient(client))
	return;
	
	//OnClientPostAdminCheckNavidad(client);
	g_iCredits[client] = 0;
	conectado[client] = true;
	
}

public OnGameFrame() 
{
	for (new i = 1; i <= MaxClients; i++) 
	{
		if (IsClientInGame(i) && IsClientConnected(i) && GetClientTeam(i) > 1 && IsPlayerAlive(i)) 
		{
			if (g_Saltador[i])
			{
				DoubleJump(i);
			}
			if (GetConVarBool(g_CvarEnable) && g_Predator[i])
			{
				CreateBeam(i);
			}
			if(IsValidEdict(g_Attachments[i]))
			{
				new Float:ppos[3];
				
				GetClientEyePosition(i, ppos);

				ppos[2]-=30.0;
				
				new Float:aang[3];
				
				GetClientEyeAngles(i, aang);
				
				if(aang[1] > 0)
				{
					ppos[0]+=FloatSub(10.0, FloatMul(FloatDiv(10.0, 90.0), aang[1]));
					ppos[1]+=FloatSub(10.0, FloatMul(FloatDiv(10.0, 90.0), FloatAbs(FloatSub(aang[1], 90.0))));
				}
				else
				{
					ppos[0]+=FloatSub(10.0, FloatMul(FloatDiv(10.0, 90.0), FloatAbs(aang[1])));
					ppos[1]-=FloatSub(10.0, FloatMul(FloatDiv(10.0, 90.0), FloatAbs(FloatSub(FloatAbs(aang[1]), 90.0))));
				}
				
				
				aang[0]=0.0;
				aang[1]+=180.0;
				aang[2]=0.0;
				
				
				TeleportEntity(g_Attachments[i], ppos, aang, NULL_VECTOR);
			}
			if (g_RapidFire[i])
			{
				FastFire(i);
			}
			if (g_Spiderman[i] && g_Trepando[i])
			{
				Spiderman(i); 
			}
			new button = GetClientButtons(i);
			
			if (g_Cloak[i])
			{
				if (button & IN_FORWARD || button & IN_BACK || button & IN_MOVERIGHT || button & IN_MOVELEFT)
				{
					SetEntityRenderMode(i, RENDER_TRANSCOLOR);
					SetEntityRenderColor(i, 255, 255, 255, 50);
					
					new wepIdx;
					
					// strip all weapons
					for (new s = 0; s < 5; s++)
					{
						if ((wepIdx = GetPlayerWeaponSlot(i, s)) != -1)
						{
							SetEntityRenderMode(wepIdx, RENDER_NORMAL);
							SetEntityRenderColor(wepIdx, 255, 255, 255, 255);
						}
					}				
				}
				else
				{
					SetEntityRenderMode(i, RENDER_TRANSCOLOR);
					SetEntityRenderColor(i, 255, 255, 255, 0);
					
					new wepIdx;
					
					// strip all weapons
					for (new s = 0; s < 5; s++)
					{
						if ((wepIdx = GetPlayerWeaponSlot(i, s)) != -1)
						{
							SetEntityRenderMode(wepIdx, RENDER_TRANSCOLOR);
							SetEntityRenderColor(wepIdx, 255, 255, 255, 0);
						}
					}				
				}
			}
		}
	}
}

public Action:EventWeaponFire(Handle:event,const String:name[],bool:dontBroadcast) 
{       
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	static String:sWeapon[32];
	GetEventString(event, "weapon", sWeapon, sizeof(sWeapon));
	if (!IsFakeClient(client))
	{
		if (g_Cloak[client])
		{
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			
			new wepIdx;
			
			// strip all weapons
			for (new s = 0; s < 5; s++)
			{
				if ((wepIdx = GetPlayerWeaponSlot(client, s)) != -1)
				{
					SetEntityRenderMode(wepIdx, RENDER_NORMAL);
					SetEntityRenderColor(wepIdx, 255, 255, 255, 255);
				}
			}		
		}
		if (StrEqual(sWeapon, "knife"))
		{
			
			if (MisilCantidad[client] > 0)
			{
				RocketAttack(client);
				
				MisilCantidad[client] -= 1;
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Numero de Misiles: %i", MisilCantidad[client]);
			}
			else if (g_Lasers[client] > 0)
			{
				
				SentryShootProjectile(client);
				
				g_Lasers[client] -= 1;
				
				if (g_Predator[client])
				{                
					CreateTimer(GetConVarFloat(Missile_Predator), DarLaser, client);
				}
				
				//CreateBeam2(client);
			}
			else if (g_Regalos[client] > 0)
			{
				
				MineAttack(client);	
				g_Regalos[client] -= 1;
				
				if (g_Santa[client])
				{
					new Float:pos[3];
					GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
					EmitSoundToAll("franug/santa.mp3", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);                
					CreateTimer(GetConVarFloat(g_Cvar_Delay), DarRegalos, client);
				}
				
				//CreateBeam2(client);
			}
			else if (g_Terremotos[client] > 0)
			{
				CheckClientOrgG(client);
			}
			else if (g_Rayos[client] > 0)
			{
				CheckClientOrgRayo(client);
			}
			else if (g_PlasmaCantidad[client] > 0)
			{
				PlasmaAttack(client);
				
				g_PlasmaCantidad[client] -= 1;
				//PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Numero de Ondas de Energia: %i", g_PlasmaCantidad[client]);
			}
			else if (flameAmount[client] > 0)
			{
				Flame(client);
			}
			else if (g_Reina[client])
			{
				SpitEffect(client);
			}
		}
		else if(StrEqual(sWeapon, "hegrenade") && g_Trainer[client])
		{
			CreateTimer(2.0, DelayWeapon, client);
		}			
	}
}

public OnClientDisconnect(client)
{
	if (!conectado[client])
	return;
	
	if (!client || IsFakeClient(client))
	return;
	
	if (g_hTimer[client] != INVALID_HANDLE && CloseHandle(g_hTimer[client]))
	{
		//CloseHandle(g_hTimer[client]);
		g_hTimer[client] = INVALID_HANDLE;
	} 
	
	//InsertScoreInDB(client);
	
	conectado[client] = false;
}

public OnEntityCreated(entity, const String:classname[])
{
	if (StrEqual(classname, "hegrenade_projectile"))
	{
		SDKHook(entity, SDKHook_StartTouch, SDKHook_Touch_Callback);
		
		if (N_Mision == 4)
		{
			CreateTimer(0.01, InitGrenade, entity, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action:HookTraceAttack(victim, &attacker, &inflictor, &Float:damage, &damagetype, &ammotype, hitbox, HitGroup)
{
	if (Client_IsValid(attacker) && Client_IsValid(victim))
	{
		new String:g_Weapon[32];
		GetClientWeapon(attacker, g_Weapon, sizeof(g_Weapon));

		if (g_Medic[attacker])
		{
			if (GetClientTeam(victim) == CS_TEAM_CT && GetClientTeam(attacker) == CS_TEAM_CT)
			{
				if (!g_cosa[victim])
				{
					if (GetClientHealth(victim) == 250)
					return;
					
					if (GetClientHealth(victim) < 250)
					{					
						new VictimHealth = GetClientHealth(victim);
						new aVictimHealth = VictimHealth + 30;
						SetEntityHealth(victim, aVictimHealth);
						g_iMedicHeal[attacker] += 1;
						PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Has curado al jugador %N. Sanaciones: %d/10", victim, g_iMedicHeal[attacker]);
						if (g_iMedicHeal[attacker] >= 10)
						{
							g_iCredits[attacker] += 2;
							g_iMedicHeal[attacker] = 0;
							PrintToChat(attacker, "\x04[SM_Franug-JailPlugins] \x05Has ganado 2 creditos por hacer 10 sanaciones");
						}
					}						
					if (GetClientHealth(victim) > 250)
					{
						SetEntityHealth(victim, 250);
					}			
				}
			}
		}
	}
}

public BulletImpact(Handle:event,const String:name[],bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));	
	if (Client_IsValid(attacker) && IsClientInGame(attacker))
	{
		if (g_Medic[attacker])
		{
			new Float:bulletOrigin[3];
			SDKCall(hGetWeaponPosition, attacker, bulletOrigin);

			new Float:bulletDestination[3];
			bulletDestination[0] = GetEventFloat(event, "x");
			bulletDestination[1] = GetEventFloat(event, "y");
			bulletDestination[2] = GetEventFloat(event, "z");

			// The following code moves the beam a little bit further away from the player
			new Float:distance = GetVectorDistance(bulletOrigin, bulletDestination);
			//PrintToChatAll("vector distance: %f", distance);

			// calculate the percentage between 0.4 and the actual distance
			new Float:percentage = 0.4 / (distance/100);
			//PrintToChatAll( "percentage (0.4): %f", percentage );

			// we add the difference between origin and destination times the percentage to calculate the new origin
			new Float:newBulletOrigin[3];
			newBulletOrigin[0] = bulletOrigin[0] + ((bulletDestination[0] - bulletOrigin[0]) * percentage);
			newBulletOrigin[1] = bulletOrigin[1] + ((bulletDestination[1] - bulletOrigin[1]) * percentage) - 0.08;
			newBulletOrigin[2] = bulletOrigin[2] + ((bulletDestination[2] - bulletOrigin[2]) * percentage);

			new color[4];
			color[0] = 0;
			color[1] = 255;
			color[2] = 0;
			color[3] = 150;
			new Float:life = 0.3;
			new Float:width = 3.0;

			/*
			start				Start position of the beam
			end					End position of the beam
			ModelIndex	Precached model index
			HaloIndex		Precached model index
			StartFrame	Initital frame to render
			FrameRate		Beam frame rate
			Life				Time duration of the beam
			Width				Initial beam width
			EndWidth		Final beam width
			FadeLength	Beam fade time duration
			Amplitude		Beam amplitude
			color				Color array (r, g, b, a)
			Speed				Speed of the beam
			*/
			
			TE_SetupBeamPoints(newBulletOrigin, bulletDestination, gLaser1, 0, 0, 0, life, width, width, 1, 0.0, color, 0);
			TE_SendToAll();
		}
		else if(g_Explosiva[attacker])
		{
			new Float:iVec[3];
			GetClientAbsOrigin(victim, Float:iVec );
			
			TE_SetupExplosion(iVec, g_ExplosionSprite, 5.0, 1, 0, 50, 40, iNormal );
			TE_SendToAll();		
		}
	}
}

public OnStartLR(PrisonerIndex, GuardIndex)
{
	Normalizar(PrisonerIndex);
	Normalizar(GuardIndex);
	PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Se han normalizado a los jugadores");
}

// Final EVENTOS / FORWARD
//--------------------------------------------------------------//
// ##################### PREMIOS ##################### //
//--------------------------------------------------------------//

public Action:DID(clientId) 
{
	new Handle:menu = CreateMenu(DIDMenuHandler);
	SetMenuTitle(menu, "Tienda de premios. Tus creditos: %i", g_iCredits[clientId]);
	AddMenuItem(menu, "m_iInfo", "Ver informacion del plugin");
	AddMenuItem(menu, "m_iCuchillo", "Comprar Cuchillo - 1 Credito");
	AddMenuItem(menu, "m_iCegadora", "Comprar CEGADORA - 1 Creditos");
	AddMenuItem(menu, "m_iLanzallamas", "Comprar municion de LANZALLAMAS - 2 Creditos");
	AddMenuItem(menu, "m_iArrojadizo", "Comprar CUCHILLO ARROJADIZO - 2 Creditos");
	AddMenuItem(menu, "m_iGranada", "Comprar GRANADA - 2 Creditos");
	AddMenuItem(menu, "m_iUSP", "Comprar pistola USP - 3 Creditos");
	AddMenuItem(menu, "m_iGanzua", "Comprar una GANZUA - 4 Creditos");
	AddMenuItem(menu, "m_i200HP", "Tener 200 hp de vida - 4 Creditos");
	AddMenuItem(menu, "m_iSaltador", "Tener DOBLE SALTO - 4 Creditos");
	AddMenuItem(menu, "m_iPajaro", "Convertirse en PAJARO - 5 Creditos");
	AddMenuItem(menu, "m_iGallina", "Convertirse en GALLINA - 5 Creditos");
	AddMenuItem(menu, "m_iVelocidad", "Mas velocidad - 5 Creditos");
	AddMenuItem(menu, "m_iInfiAmmo", "Municion Infinita - 6 Creditos");
	AddMenuItem(menu, "m_iKamikaze", "Convertirse en KAMIKAZE EXPLOSIVO (Solo T) - 7 Creditos");
	AddMenuItem(menu, "m_iMisil", "Comprar MISIL - 7 Creditos");
	AddMenuItem(menu, "m_iRambo", "Comprar metralleta RAMBO - 7 Creditos");
	AddMenuItem(menu, "m_iInvulnerable", "INVULNERABLE 20 segundos - 7 Creditos");
	AddMenuItem(menu, "m_iExplosiva", "Comprar MUNICION EXPLOSIVA  - 8 Creditos");
	AddMenuItem(menu, "m_iDisfraces", "Disfrazarse  - 8 Creditos");
	AddMenuItem(menu, "m_iAWP", "Comprar AWP - 8 Creditos");
	AddMenuItem(menu, "m_iSmall", "Hacerse DIMINUTO - 9 Creditos");
	// AddMenuItem(menu, "m_iMina", "Comprar MINA LASER - 9 Creditos");
	AddMenuItem(menu, "m_iInvisible", "Ser invisible - 10 Creditos");
	AddMenuItem(menu, "m_iAwpFreeze", "AWP Congeladora - 10 Creditos");
	AddMenuItem(menu, "m_iFuegoRapido", "Fuego Rapido - 12 Creditos");
	AddMenuItem(menu, "m_iCloak", "Camuflaje - 12 Creditos");
	AddMenuItem(menu, "m_iTrainer", "Convertirse en ENTRENADOR POKEMON - 12 Creditos");	
	AddMenuItem(menu, "m_iZombie", "Convertirse en ZOMBIE (Solo T) - 12 Creditos");
	AddMenuItem(menu, "m_iIronman", "Convertirse en IRONMAN (Solo CT) - 14 Creditos");	
	if (Client_IsAdmin(client))
	{
		AddMenuItem(menu, "m_iBicho", "Convertirse en BICHO IGNEO (Solo ADMINS T) - 14 Creditos");
	}
	AddMenuItem(menu, "m_iMedic", "Convertirse en MEDICO (Solo CT) - 14 Creditos");	
	if (Client_IsAdmin(client))
	{
		AddMenuItem(menu, "m_iSmith", "Convertirse en AGENTE SMITH (Solo ADMINS CT) - 15 Creditos");	
	}
	AddMenuItem(menu, "m_iSoldado", "Convertirse en SOLDADO CIBERNETICO (solo CT) - 15 Creditos");
	AddMenuItem(menu, "m_iPikachu", "Convertirse en POKEMON PIKACHU - 15 Creditos");	
	AddMenuItem(menu, "m_iSpiderman", "Convertirse en SPIDERMAN (Solo CT) - 16 Creditos");	
	AddMenuItem(menu, "m_iReina", "Convertirse en REINA ALIEN (Solo T) - 16 Creditos");
	// AddMenuItem(menu, "m_iSanta", "Convertirse en SANTA CLAUS - 16 Creditos");	
	AddMenuItem(menu, "m_iMonstruo", "Convertirse en MONSTRUO (Solo T) - 17 Creditos");
	AddMenuItem(menu, "m_iRobot", "Convertirse en MEGA ROBOT (Solo CT) - 17 Creditos");
	AddMenuItem(menu, "m_iGroudon", "Convertirse en POKEMON GROUDON - 18 Creditos");	
	AddMenuItem(menu, "m_iGoku", "Convertirse en GOKU - 18 Creditos");
	AddMenuItem(menu, "m_iJack", "Convertirse en JACK ESQUELETON - 18 Creditos");
	//AddMenuItem(menu, "m_iBatman", "Convertirse en BATMAN - 18 Creditos");		
	AddMenuItem(menu, "m_iFantasma", "Convertirse en FANTASMA - 20 Creditos");
	AddMenuItem(menu, "m_iPredator", "Convertirse en PREDATOR - 20 Creditos");
	AddMenuItem(menu, "m_iAmada", "Convertirse en SER AMADO - 20 Creditos");
	AddMenuItem(menu, "m_iPene", "Convertirse en PENE VOLADOR - 22 Creditos");
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, clientId, MENU_TIME_FOREVER);
	
	
	return Plugin_Handled;
}

public DIDMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		new String:info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if ( strcmp(info,"m_iInfo") == 0 ) 
		{
			{
				DID(client);
				PrintToChat(client,"\x04[SM_Franug-JailPlugins] \x05Mata jugadores para conseguir creditos, por cada muerte se te da\x03 1 \x05credito.");
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Plugin version:\x03 %s \x05creado para SourceMod \x05(privado, si quieres este plugin tendras que negociarlo con Steam: \x03franug\x05)", VERSION);
			}
			
		}
		
		else if ( strcmp(info,"m_iCuchillo") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 1)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						
						
						GivePlayerItem(client, "weapon_knife");
						
						g_iCredits[client] -= 1;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has comprado un cuchillo! Tus creditos: %i (-1)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
					
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 1)", g_iCredits[client]);
				}
			}
			
		}
		
		else if ( strcmp(info,"m_iCegadora") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 1)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						GivePlayerItem(client, "weapon_flashbang");
						
						g_iCredits[client] -= 1;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has comprado una cegadora! Tus creditos: %i (-1)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
					
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 1)", g_iCredits[client]);
				}
			}
			
		}
		
		else if ( strcmp(info,"m_iLanzallamas") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 2)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						flameAmount[client] += 1;
						
						g_iCredits[client] -= 2;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has comprado una municion para LANZALLAMAS! Se usa apretando boton derecho del raton.  Tus creditos: %i (-2)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
					
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 2)", g_iCredits[client]);
				}
			}
			
		}
		
		else if ( strcmp(info,"m_iArrojadizo") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 2)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						

						new nuevo = GetClientThrowingKnives(client);
						++nuevo;
						SetClientThrowingKnives(client, nuevo);
						
						g_iCredits[client] -= 2;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has comprado un cuchillo arrojadizo! Tus creditos: %i (-2)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
					
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 2)", g_iCredits[client]);
				}
			}
			
		}
		
		else if ( strcmp(info,"m_iGranada") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 2)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						GivePlayerItem(client, "weapon_hegrenade");
						
						g_iCredits[client] -= 2;
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has comprado un granada! Tus creditos: %i (-2)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
					
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 2)", g_iCredits[client]);
				}
			}
			
		}
		
		else if ( strcmp(info,"m_iUSP") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 3)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						GivePlayerItem(client, "weapon_usp");
						
						g_iCredits[client] -= 3;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has comprado una pistola USP! Tus creditos: %i (-3)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
					
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 3)", g_iCredits[client]);
				}
			}
			
		}
		else if ( strcmp(info,"m_iGanzua") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 4)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						ConvertirGanzua(client);
						g_iCredits[client] -= 4;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has comprado una GANZUA para abrir puertas! Tus creditos: %i (-4)", g_iCredits[client]);
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes una GANZUA, escribe \x04!gopen para abrir una puerta");
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
					
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 4)", g_iCredits[client]);
				}
			}
			
		}		
		else if ( strcmp(info,"m_i200HP") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 4)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						SetEntityHealth(client, 200);
						
						g_iCredits[client] -= 4;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora tienes 200 de vida! Tus creditos: %i (-4)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 4)", g_iCredits[client]);
				}
			}
			
		}
		
		else if ( strcmp(info,"m_iSaltador") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 4)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						
						g_Saltador[client] = true;
						
						g_iCredits[client] -= 4;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora tienes DOBLE SALTO y puedes saltar en el aire! Tus creditos: %i (-4)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 4)", g_iCredits[client]);
				}
			}
			
		}
		
		else if ( strcmp(info,"m_iPajaro") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 5)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						ConvertirPajaro(client);
						
						g_iCredits[client] -= 5;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres una PAJARO y puedes volar! Tus creditos: %i (-5)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 5)", g_iCredits[client]);
				}
			}
			
		}
		
		else if ( strcmp(info,"m_iGallina") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 5)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						ConvertirGallina(client);
						g_iCredits[client] -= 5;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres una GALLINA y puedes brincar! Tus creditos: %i (-5)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 5)", g_iCredits[client]);
				}
			}
			
		}
		
		else if ( strcmp(info,"m_iVelocidad") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 5)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.3);
						
						g_iCredits[client] -= 5;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora tienes mas velocidad! Tus creditos: %i (-5)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 5)", g_iCredits[client]);
				}
			}
			
		}
		
		else if ( strcmp(info,"m_iInfiAmmo") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 6)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						g_AmmoInfi[client] = true;
						
						g_iCredits[client] -= 6;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora tienes municion infinita! Tus creditos: %i (-6)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 6)", g_iCredits[client]);
				}
			}
			
		}
		
		else if ( strcmp(info,"m_iKamikaze") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 7)
				{
					
					if (GetClientTeam(client) == CS_TEAM_T)
					{
						if (IsPlayerAlive(client))
						{
							if (g_cosa[client])
							{
								
								PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
								return;
							}
							
							
							//SetEntityRenderColor(client, 255, 30, 10, 255);
							
							g_Bomba[client] = true;
							
							g_iCredits[client] -= 7;
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres una KAMIKAZE EXPLOSIVO! escribe !detonar para estallar! Tus creditos: %i (-7)", g_iCredits[client]);
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que ser T para poder usar esto");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 7)", g_iCredits[client]);
				}
			}
			
		}
		
		else if ( strcmp(info,"m_iMisil") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 7)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						MisilCantidad[client] += 1;
						
						g_iCredits[client] -= 7;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has comprado un MISIL! Tus creditos: %i (-7)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
					
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 7)", g_iCredits[client]);
				}
			}
			
		}
		
		
		else if ( strcmp(info,"m_iRambo") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 7)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						GivePlayerItem(client, "weapon_m249");
						
						g_iCredits[client] -= 7;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora tienes una RAMBO! Tus creditos: %i (-7)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 7)", g_iCredits[client]);
				}
			}
			
		}
		
		else if ( strcmp(info,"m_iInvulnerable") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 7)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						g_Godmode[client] = true;
						SetEntityRenderColor(client, 0, 255, 255, 255);
						CreateTimer(10.0, OpcionNumero16b, client);
						
						g_iCredits[client] -= 7;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres INVULNERABLE durante 20 segundos! Tus creditos: %i (-7)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 7)", g_iCredits[client]);
				}
			}
			
		}
		else if ( strcmp(info,"m_iInvulnerable") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 8)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						g_Explosiva[client] = true;
						g_iCredits[client] -= 8;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora tienes MUNICION EXPLOSIVA! Tus creditos: %i (-8)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 8)", g_iCredits[client]);
				}
			}
			
		}		
		else if ( strcmp(info,"m_iDisfraces") == 0 ) 
		{
			{
				DMH(client);
				/* 				
				DID(client);
				if (g_iCredits[client] >= 8)
				{
				if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
				{
				if (g_cosa[client])
				{
				
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
				return;
				}
				
				SetEntityModel(client, "models/props/de_train/barrel.mdl");
				
				g_iCredits[client] -= 8;
				
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un Barril! Tus creditos: %i (-8)", g_iCredits[client]);
				}
				else
				{
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
				}
				}
				else
				{
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 8)", g_iCredits[client]);
				} 
				*/
			}
			
		}
		
		else if ( strcmp(info,"m_iAWP") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 8)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						GivePlayerItem(client, "weapon_awp");
						
						g_iCredits[client] -= 8;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora tienes una AWP! Tus creditos: %i (-8)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 8)", g_iCredits[client]);
				}
			}
			
		}
		else if ( strcmp(info,"m_iSmall") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 9)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						
						ResizePlayer(client, 0.3);
						SetEntityRenderMode(client, RENDER_NORMAL);
						SetEntityRenderColor(client, 255, 255, 255, 255);
						
						
						g_iCredits[client] -= 9;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres DIMINUTO. Tus creditos: %i (-9)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 9)", g_iCredits[client]);
				}
			}	
		}
		// else if ( strcmp(info,"m_iMina") == 0 ) 
		// {
		// {
		// DID(client);
		// if (g_iCredits[client] >= 9)
		// {
		// if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
		// {
		// if (g_cosa[client])
		// {
		
		// PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
		// return;
		// }
		
		// AddClientLasermines(client, 1, false);
		
		// g_iCredits[client] -= 9;
		
		// PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has comprado una MINA LASER. Escribe !lm para ponerla. Tus creditos: %i (-9)", g_iCredits[client]);
		// }
		// else
		// {
		// PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
		// }
		// }
		// else
		// {
		// PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 9)", g_iCredits[client]);
		// }
		// }	
		// }		
		else if ( strcmp(info,"m_iInvisible") == 0 ) 
		{
			{
				DID(client);
				if (g_iCredits[client] >= 10)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						SetEntityRenderMode(client, RENDER_TRANSCOLOR);
						SetEntityRenderColor(client, 255, 255, 255, 0);
						
						g_iCredits[client] -= 10;
						
						//g_cosa[client] = true;
						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres invisible! Tus creditos: %i (-10)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 10)", g_iCredits[client]);
				}
			}
			
		}
		
		else if ( strcmp(info,"m_iAwpFreeze") == 0 ) 
		{
			
			{ 
				DID(client);
				if (g_iCredits[client] >= 10)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						ConvertirAwpFreeze(client);
						g_iCredits[client] -= 10;
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora tienes una AWP CONGELADORA! Tus creditos: %i (-10)", g_iCredits[client]);

					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 10)", g_iCredits[client]);
				}
			}
			
		}

		else if ( strcmp(info,"m_iTrainer") == 0 ) 
		{
			DID(client);
			if (g_iCredits[client] >= GetConVarInt(CostTrainer))
			{
				if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
				{
					if (g_cosa[client])
					{

						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
						return;
					}
					
					g_iCredits[client] -= GetConVarInt(CostTrainer);
					ConvertirTrainer(client);

					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres entrenador pokemon! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostTrainer));

					PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha aparecido un ENTRENADOR POKEMON!");
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
				}
			}
			else
			{
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostTrainer));
			}
			
			
		}		
		
		else if ( strcmp(info,"m_iFuegoRapido") == 0 ) 
		{
			
			{ 
				DID(client);
				if (g_iCredits[client] >= 12)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}			
						g_RapidFire[client] = true;
						g_iCredits[client] -= 12;
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora tienes FUEGO RAPIDO! Tus creditos: %i (-12)", g_iCredits[client]);						
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 12)", g_iCredits[client]);
				}
			}
			
		}			
		else if ( strcmp(info,"m_iCloak") == 0 ) 
		{
			
			{ 
				DID(client);
				if (g_iCredits[client] >= 12)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}	
						g_Cloak[client] = true;
						g_iCredits[client] -= 12;
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora tienes CAMUFLAJE! Solo seras visible cuando te muevas. Tus creditos: %i (-12)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 12)", g_iCredits[client]);
				}
			}
			
		}		
		else if ( strcmp(info,"m_iZombie") == 0 ) 
		{
			
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostZombie))
				{
					if (GetClientTeam(client) == CS_TEAM_T)
					{
						if (IsPlayerAlive(client))
						{
							if (g_cosa[client])
							{
								
								PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
								return;
							}
							ConvertirZombie(client);
							g_iCredits[client] -= GetConVarInt(CostZombie);							
							PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha aparecido un ZOMBIE en la jail! MATARLO! para los zombies no existe el FreeKill");							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un ZOMBIE!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostZombie));
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que ser T para poder usar esto");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostZombie));
				}
				
			}
			
		}
		
		else if ( strcmp(info,"m_iMonstruo") == 0 ) 
		{
			
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostMonstruo))
				{
					if (GetClientTeam(client) == CS_TEAM_T)
					{
						if (IsPlayerAlive(client))
						{
							if (g_cosa[client])
							{
								
								PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
								return;
							}							
							ConvertirMonstruo(client);
							g_iCredits[client] -= GetConVarInt(CostMonstruo);
							PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05HHa aparecido un MONSTRUO en la jail! MATARLO! para los monstruos no existe el FreeKill");
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un MONSTRUO!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostMonstruo));
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que ser T para poder usar esto");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostMonstruo));
				}
				
			}
			
		}
		
		else if ( strcmp(info,"m_iSoldado") == 0 ) 
		{
			
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostSoldado))
				{
					if (GetClientTeam(client) == CS_TEAM_CT)
					{
						if (IsPlayerAlive(client))
						{
							
							if (g_cosa[client])
							{
								
								PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
								return;
							}
							ConvertirSoldado(client);						
							g_iCredits[client] -= GetConVarInt(CostSoldado);
							PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha venido un SOLDADO CIBERNETICO!!!");	
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un SOLDADO CIBERNETICO!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostSoldado));
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que ser CT para poder usar esto");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostSoldado));
				}
				
			}
			
		}
		
		else if ( strcmp(info,"m_iBicho") == 0 ) 
		{
			
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostBicho))
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (GetClientTeam(client) == CS_TEAM_T)
						{
							if (g_cosa[client])
							{
								
								PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
								return;
							}
							ConvertirBicho(client);
							g_iCredits[client] -= GetConVarInt(CostBicho);
							PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha aparecido un BICHO IGNEO!!!");
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un BICHO IGNEO!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostBicho));
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que ser T para poder usar esto");
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostBicho));
				}
				
			}
			
		}

		else if (strcmp(info,"m_iMedic") == 0) 
		{
			
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostMedic))
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						if (GetClientTeam(client) == CS_TEAM_CT)
						{
							if (g_cosa[client])
							{
								
								PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
								return;
							}
							ConvertirMedic(client);
							g_iCredits[client] -= GetConVarInt(CostMedic);
							PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha aparecido un MEDICO!!!");
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un MEDICO!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostMedic));
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que ser CT para poder usar esto");
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostMedic));
				}
				
			}
			
		}		
		
		else if ( strcmp(info,"m_iRobot") == 0 ) 
		{
			
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostRobot))
				{
					if (GetClientTeam(client) == CS_TEAM_CT)
					{
						if (IsPlayerAlive(client))
						{
							if (g_cosa[client])
							{
								
								PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
								return;
							}
							ConvertirRobot(client);
							g_iCredits[client] -= GetConVarInt(CostRobot);
							PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha venido un MEGA ROBOT!!!");
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un MEGA ROBOT!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostRobot));
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que ser CT para poder usar esto");
					}
					
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostRobot));
				}
				
			}
			
		}
		
		
		else if ( strcmp(info,"m_iIronman") == 0 ) 
		{
			
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostIronman))
				{
					if (GetClientTeam(client) == CS_TEAM_CT)
					{
						if (IsPlayerAlive(client))
						{
							
							if (g_cosa[client])
							{
								
								PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
								return;
							}
							ConvertirIronman(client);
							g_iCredits[client] -= GetConVarInt(CostIronman);
							PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha venido un IRONMAN!!!");
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un IRONMAN!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostIronman));
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que ser CT para poder usar esto");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostIronman));
				}
				
			}
			
		}
		
		else if ( strcmp(info,"m_iReina") == 0 ) 
		{
			
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostReina))
				{
					if (GetClientTeam(client) == CS_TEAM_T)
					{
						if (IsPlayerAlive(client))
						{
							if (g_cosa[client])
							{
								
								PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
								return;
							}
							ConvertirReina(client);
							g_iCredits[client] -= GetConVarInt(CostReina);
							PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha aparecido una REINA ALIEN en la jail! MATARLO! para ellos no existe el FreeKill");
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres unA REINA ALIEN!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostReina));
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que ser T para poder usar esto");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostReina));
				}
				
			}
			
		}
		
		else if ( strcmp(info,"m_iPikachu") == 0 ) 
		{
			
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostPikachu))
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						ConvertirPikachu(client);
						g_iCredits[client] -= GetConVarInt(CostPikachu);
						PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha venido el POKEMON PIKACHU!");
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres el POKEMON PIKACHU!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostPikachu));
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostPikachu));
				}
				
			}
			
		}
		
		else if ( strcmp(info,"m_iSpiderman") == 0 ) 
		{		
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostSpiderman))
				{
					if (GetClientTeam(client) == CS_TEAM_CT)
					{
						if (IsPlayerAlive(client))
						{
							if (g_cosa[client])
							{
								
								PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
								return;
							}
							ConvertirSpiderman(client);
							g_iCredits[client] -= GetConVarInt(CostSpiderman);
							PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha venido un SPIDERMAN!!!");
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un SPIDERMAN!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostSpiderman));
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que ser CT para poder usar esto");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostSpiderman));
				}				
			}			
		}		
		else if ( strcmp(info,"m_iSmith") == 0 ) 
		{			
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostSmith))
				{
					if (GetClientTeam(client) == CS_TEAM_CT)
					{
						if (IsPlayerAlive(client))
						{
							if (g_cosa[client])
							{
								
								PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
								return;
							}
							ConvertirSmith(client);																		
							g_iCredits[client] -= GetConVarInt(CostSmith);
							PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha venido un AGENTE SMITH!!!");
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un AGENTE SMITH!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostSmith));
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que ser CT para poder usar esto");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostSmith));
				}				
			}			
		}
		
		else if ( strcmp(info,"m_iGoku") == 0 ) 
		{			
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostGoku))
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{		
						if (g_cosa[client])
						{				
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						ConvertirGoku(client);
						g_iCredits[client] -= GetConVarInt(CostGoku);
						PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha venido un GOKU!!!");
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un GOKU!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostGoku));
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostGoku));
				}				
			}			
		}	
		else if ( strcmp(info,"m_iGroudon") == 0 ) 
		{			
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostGroudon))
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{					
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						ConvertirGroudon(client);																	
						g_iCredits[client] -= GetConVarInt(CostGroudon);
						PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha venido el POKEMON GROUDON!");
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres el POKEMON GROUDON!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostGroudon));
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostGroudon));
				}				
			}			
		}
		
		else if ( strcmp(info,"m_iFantasma") == 0 ) 
		{
			
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostFantasma))
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						ConvertirFantasma(client);											
						g_iCredits[client] -= GetConVarInt(CostFantasma);
						PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha aparecido un FANTASMA!");
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un FANTASMA!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostFantasma));
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostFantasma));
				}
				
			}
			
		}
		
		else if ( strcmp(info,"m_iPredator") == 0 ) 
		{		
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostPredator))
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{
						
						if (g_cosa[client])
						{
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						ConvertirPredator(client);
						g_iCredits[client] -= GetConVarInt(CostPredator);					
						PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha aparecido un PREDATOR!");
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un PREDATOR!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostPredator));
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostPredator));
				}	
			}	
		}	
		else if (strcmp(info,"m_iSanta") == 0 ) 
		{			
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostSanta))
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{					
						if (g_cosa[client])
						{						
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}
						ConvertirSanta(client);
						g_iCredits[client] -= GetConVarInt(CostSanta);
						PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha venido SANTA CLAUS!!!");
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres SANTA CLAUS!! Puedes repartir regalos! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostSanta));
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostSanta));
				}				
			}			
		}				
		else if ( strcmp(info,"m_iJack") == 0 ) 
		{		
			{ 
				DID(client);
				if (g_iCredits[client] >= GetConVarInt(CostJack))
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{					
						if (g_cosa[client])
						{						
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
							return;
						}					
						ConvertirJack(client);
						g_iCredits[client] -= GetConVarInt(CostJack);
						PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha venido Jack Skellington!!!");
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un Jack Skellington!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostJack));
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostJack));
				}			
			}		
		}

		else if ( strcmp(info,"m_iAmada") == 0 ) 
		{
			
			

			if (g_iCredits[client] >= 20)
			{
				if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
				{

					if (g_cosa[client])
					{

						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
						return;
					}
					ConvertirAmada(client);
					g_iCredits[client] -= 20;
					PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha Un Ser Amado!!!");
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un SER AMADO!! Tus creditos: %i (-%i)", g_iCredits[client], 20);
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
				}
			}
			else
			{
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %i)", g_iCredits[client], 20);
			}
			DID(client);
			
			
			
		}

		else if ( strcmp(info,"m_iPene") == 0 ) 
		{
			
			
			if (g_iCredits[client] >= GetConVarInt(CostPene))
			{
				if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
				{

					if (g_cosa[client])
					{

						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
						return;
					}
					ConvertirPene(client);
					g_iCredits[client] -= GetConVarInt(CostPene);
					PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha venido un PENE VOLADOR!!!");
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un PENE VOLADOR!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostPene));
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
				}
			}
			else
			{
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostPene));
			}
			DID(client);
			
			
			
		}
		else if ( strcmp(info,"m_iBatman") == 0 ) 
		{
			
			
			if (g_iCredits[client] >= GetConVarInt(CostBatman))
			{
				if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
				{

					if (g_cosa[client])
					{

						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes comprar siendo un ser especial!");
						return;
					}
					ConvertirBatman(client);
					g_iCredits[client] -= GetConVarInt(CostBatman);
					PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha venido BATMAN!!!");
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ahora eres un BATMAN!! Tus creditos: %i (-%d)", g_iCredits[client], GetConVarInt(CostBatman));
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
				}
			}
			else
			{
				PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas %d)", g_iCredits[client], GetConVarInt(CostBatman));
			}
			DID(client);
		}		
		
	}
	else if (action == MenuAction_Cancel) 
	{ 
		PrintToServer("Client %d's menu was cancelled.  Reason: %d", client, itemNum); 
	} 

	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:DODMH(client, args)
{
	DMH(client);
	PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i", g_iCredits[client]);
}

public Action:DMH(clientId) 
{
	new Handle:menu = CreateMenu(DisguiseMH);
	SetMenuTitle(menu, "Tienda de disfraces. Tus creditos: %i", g_iCredits[clientId]);
	AddMenuItem(menu, "m_iSilla", "Disfrazarse de SILLA");
	AddMenuItem(menu, "m_iBarril", "Disfrazarse de BARRIL");
	AddMenuItem(menu, "m_iCT", "Disfrazarse de CT");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, clientId, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public DisguiseMH(Handle:menu, MenuAction:action, client, itemNum) 
{
	if (action == MenuAction_Select) 
	{
		new String:info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if ( strcmp(info,"m_iSilla") == 0 ) 
		{
			{
				DMH(client);
				if (g_iCredits[client] >= 8)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{						
						SetEntityModel(client, "models/props_interiors/furniture_chair03a.mdl");						
						g_iCredits[client] -= 8;						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Te has disfrazado de SILLA! Tus creditos: %i (-8)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
					
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 8)", g_iCredits[client]);
				}			
			}
		}
		
		else if ( strcmp(info,"m_iBarril") == 0 ) 
		{
			{
				DMH(client);
				if (g_iCredits[client] >= 8)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{						
						SetEntityModel(client, "models/props/de_train/barrel.mdl");						
						g_iCredits[client] -= 8;						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Te has disfrazado de BARRIL! Tus creditos: %i (-8)", g_iCredits[client]);
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
					
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 8)", g_iCredits[client]);
				}			
			}
		}
		else if ( strcmp(info,"m_iCT") == 0 ) 
		{
			{
				DMH(client);
				if (g_iCredits[client] >= 8)
				{
					if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
					{											
						g_iCredits[client] -= 8;						
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Te has disfrazado de CT! Tus creditos: %i (-8)", g_iCredits[client]);
						PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05CUIDADO, HAY UN PRISIONERO CAMUFLADO DE GUARDIA!!");
						
						new rand = GetRandomInt(1, 2);
						switch (rand)
						{
							case 1:
								{
									SetEntityModel(client, "models/player/UEA/urban_admin/ct_urban.mdl");	
								}
							case 2:
								{
									SetEntityModel(client, "models/player/UEA/ct_admin/ct_gign.mdl");
								}
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder comprar premios");
					}
					
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tus creditos: %i (No tienes suficiente Creditos! Necesitas 8)", g_iCredits[client]);
				}			
			}
		}		
	}
	
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}	

// Final PREMIOS
//--------------------------------------------------------------//
// ##################### DADOS ##################### //
//--------------------------------------------------------------//

public Action:Lanzar(client, args)
{
	if (!g_RondaEspecial)
	{
		if (IsPlayerAlive(client))
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				if (GetConVarInt(Dados_Usados) < GetConVarInt(Dados_Usos))
				{
					if (!g_Usando[client])
					{
						if (!g_cosa[client])
						{
							g_Usando[client] = true;
							new suerte = GetRandomInt(1, 60);
							
							LogToFile(Logfile, "tocado suerte numero %i", suerte);
							
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tirando los dados...");
							
							new Handle:pack;
							
							switch (suerte)
							{
							case 1:
								{
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 2:
								{
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero1, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 3:
								{
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero2, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 4:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero3, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 5:
								{
									
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 6:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero4, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 7:
								{
									
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 8:
								{
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 9:
								{
									
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 10:
								{
									
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 11:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero5, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 12:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero6, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 13:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero7, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 14:
								{
									
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 15:
								{
									
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 16:
								{
									
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 17:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero8, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 18:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero9, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 19:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero10, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 20:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero11, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 21:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero5, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 22:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero12, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 23:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero5, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 24:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero13, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 25:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero14, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 26:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero11, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 27:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero12, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 28:
								{
									
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 29:
								{
									
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 30:
								{
									
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 31:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero12, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 32:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero15, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 33:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero16, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 34:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero17, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 35:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero18, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 36:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero18, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 37:
								{
									
									
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 38:
								{
									
									
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 39:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero19, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 40:
								{
									
									
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNada, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
								}
							case 41:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero20, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 42:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero20, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 43:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero13, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 44:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero13, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 45:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero13, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 46:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero2, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 47:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero2, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 48:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero3, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 49:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero21, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 50:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero21, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 51:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero18, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 52:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero2, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 53:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero1, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 54:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero2, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 55:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero2, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 56:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero8, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 57:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero8, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 58:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero8, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 59:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero8, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							case 60:
								{
									
									
									new antesusados = (GetConVarInt(Dados_Usados) + 1);
									ServerCommand("sm_dados_usados %i", GetConVarInt(Dados_Usados) + 1);
									CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero8, pack);
									WritePackCell(pack, client);
									WritePackCell(pack, suerte);
									WritePackCell(pack, antesusados);
								}
							}
						}
						else
						{
							PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes tirar los dados siendo un SER ESPECIAL!!");
						}
					}
					else
					{
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que esperar a que salga algo en los dados para volver a tirar.");
					}
					
				}
				else
				{
					PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ya han tocado todos los premios! prueba suerte a la siguiente ronda.");
				}
			}
			/* 		else
			{
			if (GetClientTeam(client) == 3)
			{
			if (GetConVarInt(Dados_Usados2) < GetConVarInt(Dados_Usos2))
			{
			if (!g_Usando[client])
			{
			g_Usando[client] = true;
			new suerte2 = GetRandomInt(1, 10);
			
			
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tirando los dados...");
			
			new Handle:pack2;
			
			switch (suerte2)
			{
			case 1:
			{
			CreateDataTimer(GetConVarFloat(Cvar_Tiempo), NadaDeNadaz, pack2);
			WritePackCell(pack2, client);
			WritePackCell(pack2, suerte2);
			}
			case 2:
			{
			
			//new antesusados = (GetConVarInt(Dados_Usados2) + 1);
			ServerCommand("sm_dados_ctusados %i", GetConVarInt(Dados_Usados2) + 1);
			CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero1z, pack2);
			WritePackCell(pack2, client);
			WritePackCell(pack2, suerte2);
			//WritePackCell(pack2, antesusados);
			}
			case 3:
			{
			
			//new antesusados = (GetConVarInt(Dados_Usados2) + 1);
			ServerCommand("sm_dados_ctusados %i", GetConVarInt(Dados_Usados2) + 1);
			CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero2z, pack2);
			WritePackCell(pack2, client);
			WritePackCell(pack2, suerte2);
			//WritePackCell(pack2, antesusados);
			}
			case 4:
			{
			
			//new antesusados = (GetConVarInt(Dados_Usados2) + 1);
			ServerCommand("sm_dados_ctusados %i", GetConVarInt(Dados_Usados2) + 1);
			CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero3z, pack2);
			WritePackCell(pack2, client);
			WritePackCell(pack2, suerte2);
			//WritePackCell(pack2, antesusados);
			}
			case 5:
			{
			
			//new antesusados = (GetConVarInt(Dados_Usados2) + 1);
			ServerCommand("sm_dados_ctusados %i", GetConVarInt(Dados_Usados2) + 1);
			CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero4z, pack2);
			WritePackCell(pack2, client);
			WritePackCell(pack2, suerte2);
			//WritePackCell(pack2, antesusados);
			}
			case 6:
			{
			
			//new antesusados = (GetConVarInt(Dados_Usados2) + 1);
			ServerCommand("sm_dados_ctusados %i", GetConVarInt(Dados_Usados2) + 1);
			CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero5z, pack2);
			WritePackCell(pack2, client);
			WritePackCell(pack2, suerte2);
			//WritePackCell(pack2, antesusados);
			}
			case 7:
			{
			
			//new antesusados = (GetConVarInt(Dados_Usados2) + 1);
			ServerCommand("sm_dados_ctusados %i", GetConVarInt(Dados_Usados2) + 1);
			CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero6z, pack2);
			WritePackCell(pack2, client);
			WritePackCell(pack2, suerte2);
			//WritePackCell(pack2, antesusados);
			}
			case 8:
			{
			
			//new antesusados = (GetConVarInt(Dados_Usados2) + 1);
			ServerCommand("sm_dados_ctusados %i", GetConVarInt(Dados_Usados2) + 1);
			CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero7z, pack2);
			WritePackCell(pack2, client);
			WritePackCell(pack2, suerte2);
			//WritePackCell(pack2, antesusados);
			}
			case 9:
			{
			
			//new antesusados = (GetConVarInt(Dados_Usados2) + 1);
			ServerCommand("sm_dados_ctusados %i", GetConVarInt(Dados_Usados2) + 1);
			CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero8z, pack2);
			WritePackCell(pack2, client);
			WritePackCell(pack2, suerte2);
			//WritePackCell(pack2, antesusados);
			}
			case 10:
			{
			
			//new antesusados = (GetConVarInt(Dados_Usados2) + 1);
			ServerCommand("sm_dados_ctusados %i", GetConVarInt(Dados_Usados2) + 1);
			CreateDataTimer(GetConVarFloat(Cvar_Tiempo), OpcionNumero9z, pack2);
			WritePackCell(pack2, client);
			WritePackCell(pack2, suerte2);
			//WritePackCell(pack2, antesusados);
			}
			}
			}
			else
			{
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que esperar a que salga algo en los dados para volver a tirar.");
			}
			}
			else
			{
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ya han tocado todos los premios! prueba suerte a la siguiente ronda.");
			}
			}
			else
			{
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Los ESPECTADORES no pueden tirar los dados!");
			}
			} */
		}
		else
		{
			PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Tienes que estar vivo para poder usar este comando!");
		}
	}
	else
	{
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05No puedes lanzar los dados en este momento");
	}
}

public Action:NadaDeNada(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! No te ha tocado NADA! sigue probando!", suerte);
		g_Usando[client] = false;
	}
}

public Action:OpcionNumero1(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		
		GivePlayerItem(client, "weapon_deagle");
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado una DEAGLE!", suerte);
	}
}

public Action:OpcionNumero2(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		
		GivePlayerItem(client, "item_kevlar");
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado una ARMADURA!", suerte);
	}
}

public Action:OpcionNumero3(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		
		SetEntityHealth(client, 1);
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS PERDIDO! ahora solo tienes 1 HP de vida!", suerte);
	}
}

public Action:OpcionNumero4(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		
		GivePlayerItem(client, "weapon_scout");
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado una SCOUT!", suerte);
	}
}

public Action:OpcionNumero5(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		
		SetEntityHealth(client, 250);
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! te ha tocado 250 de vida!", suerte);
	}
}

public Action:OpcionNumero6(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.7);
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS PERDIDO! ahora corres mas lento de lo normal!", suerte);
	}
}

public Action:OpcionNumero7(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.3);
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! ahora corres mas veloz de lo normal!", suerte);
	}
}

public Action:OpcionNumero8(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		GivePlayerItem(client, "weapon_hegrenade");
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado una GRANADA!", suerte);
	}
}

public Action:OpcionNumero9(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		GivePlayerItem(client, "weapon_m3");
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado una ESCOPETA!", suerte);
	}
}

public Action:OpcionNumero10(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		GivePlayerItem(client, "weapon_flashbang");
		GivePlayerItem(client, "weapon_flashbang");
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te han tocado DOS CEGADORAS!", suerte);
	}
}

public Action:OpcionNumero11(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 255, 255, 255, 0);
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		g_cosa[client] = true;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado INVISIBILIDAD!", suerte);
	}
}

public Action:OpcionNumero12(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		SetEntityModel(client, "models/props/de_train/barrel.mdl");
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Ahora estas disfradado de BARRIL!!!!!", suerte);
	}
}

public Action:OpcionNumero13(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		GivePlayerItem(client, "weapon_usp");
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado una PISTOLA USP!", suerte);
	}
}

public Action:OpcionNumero14(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		GivePlayerItem(client, "weapon_m249");
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado una AMETRALLADORA RAMBO!!!!!", suerte);
	}
}

public Action:OpcionNumero15(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		SetEntityMoveType(client, MOVETYPE_NONE);
		SetEntityRenderColor(client, 0, 0, 255, 255);
		new Float:vec[3];
		GetClientEyePosition(client, vec);
		EmitAmbientSound(SOUND_FREEZE, vec, client, SNDLEVEL_RAIDSIREN);
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS PERDIDO! Ahora Estas congelado 30 segundos!", suerte);
		
		CreateTimer(15.0, OpcionNumero15b, client);
	}
}

public Action:OpcionNumero15b(Handle:timer, any:client)
{
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Te quedan 15 segundos de CONGELACION!");
		CreateTimer(15.0, OpcionNumero15c, client);
	}
}

public Action:OpcionNumero15c(Handle:timer, any:client)
{
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ya no estas CONGELADO!");
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}

public Action:OpcionNumero16(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		g_Godmode[client] = true;
		SetEntityRenderColor(client, 0, 255, 255, 255);
		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Ahora eres INVULNERABLE durante 20 segundos!", suerte);
		
		CreateTimer(10.0, OpcionNumero16b, client);
	}
}

public Action:OpcionNumero16b(Handle:timer, any:client)
{
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Te quedan 10 segundos de INVULNERABILIDAD!");
		CreateTimer(10.0, OpcionNumero16c, client);
	}
}

public Action:OpcionNumero16c(Handle:timer, any:client)
{
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ya no eres INVULNERABLE!");
		g_Godmode[client] = false;
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}

public Action:OpcionNumero17(Handle:timer, Handle:pack)
{
	
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		ConvertirZombie(client);
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha aparecido un ZOMBIE en la jail! MATARLO! para los zombies no existe el FreeKill");
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Ahora eres un ZOMBIE!! Mata a unos cuantos CT", suerte);
	}
}

public Action:OpcionNumero18(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		RemoveWeapons(client);		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS PERDIDO! Ahora estas DESARMADO!", suerte);
	}
}

public Action:OpcionNumero19(Handle:timer, Handle:pack)
{
	
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
		
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		ConvertirMonstruo(client);		
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ha aparecido un MONSTRUO en la jail! MATARLO! para los monstruos no existe el FreeKill");
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Ahora eres un MOSNTRUO!! Mata a unos cuantos CT, los matas de un solo zarpazo", suerte);
	}
}

public Action:OpcionNumero20(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		ConvertirPajaro(client);
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado ser PAJARO!! ahora puedes volar :D", suerte);
	}
}

public Action:OpcionNumero21(Handle:timer, Handle:pack)
{
	//unpack into
	new client;
	new suerte;
	new antesusados;
	new Dados_Usos1;
	//   new Dados_Usados1;
	
	
	ResetPack(pack);
	client = ReadPackCell(pack);
	suerte = ReadPackCell(pack);
	antesusados = ReadPackCell(pack);
	Dados_Usos1 = GetConVarInt(Dados_Usos);
	//   Dados_Usados1 = GetConVarInt(Dados_Usados);
	
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		ConvertirGallina(client);
		if (antesusados == Dados_Usos1)
		{
			PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Ya han tocado los %i dados de los Terros!", Dados_Usos1);
		}
		g_Usando[client] = false;
		PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado ser GALLINA!!", suerte);
	}
}

// Final DADOS