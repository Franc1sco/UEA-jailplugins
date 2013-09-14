#define ModelZombie "models/player/slow/aliendrone_v3/slow_alien.mdl"
#define ModelMonstruo "models/player/techknow/ferno/ferno.mdl"
#define ModelSoldado "models/player/slow/trenchcoat/slow.mdl"
#define ModelBicho "models/antlion_guard.mdl"
#define ModelRobot "models/player/techknow/gundam/gundam.mdl"
#define ModelIronman "models/player/techknow/ironman_v3/ironman3.mdl"
#define ModelReina "models/player/avp/alienqueen.mdl"
#define ModelPikachu "models/smashbros/pikachu.mdl"
#define ModelSpiderman "models/player/techknow/spiderman3/spiderman3.mdl"
#define ModelSmith "models/player/pil/smith/smith.mdl"
#define ModelGroudon "models/apocmodels/pokemon/groudon.mdl"
#define ModelPredator "models/player/techknow/predator_v2/predator.mdl"
#define ModelSanta "models/player/slow/santa_claus/slow_fix.mdl"
#define ModelJack "models/player/techknow/jacks/jacks.mdl"
#define ModelGoku "models/player/tap/goku/goku.mdl"
#define ModelTrainer "models/mapeadores/morell/ash/ash.mdl"
#define ModelPene "models/props/slow/joe100/dick/slow.mdl"
#define ModelMedic "models/player/slow/hl2/combine_super_soldier/slow.mdl"
#define ModelBatman "models/player/slow/jamis/mkvsdcu/batman/slow_pub_v2.mdl"


public LoadConVars()
{
	EnableNoBlock = CreateConVar("sm_enablenoblock", "0", "Activar/Desactivar NoBlock en el spawn", _, true, 0.0, true, 1.0);
	//cvType = CreateConVar("sm_avp_dissolve_type", "3");
	//cvDelay = CreateConVar("sm_avp_dissolve_delay","0.1");

	cvarCreditsMax = CreateConVar("sm_premios_credits_max", "500", "Maximo de creditos que se pueden tener(0: No limit)");
	cvarCreditsKill = CreateConVar("sm_premios_credits_kill", "2", "Número de créditos ganados por muerte");

	// CreateConVar("sm_Sistema_De_Creditos", VERSION, "Current version of this plugin", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_UNLOGGED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
	// CreateConVar("sm_Sistema_De_Creditos", VERSION, "Current version of this plugin", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	cvarInterval = CreateConVar("zr_ammo_interval", "5", "Intervalo de recarga de Munición Infinita", _, true, 1.0);

	priAmmoTypeOffset = FindSendPropOffs("CBaseCombatWeapon", "m_iPrimaryAmmoCount");
	secAmmoTypeOffset = FindSendPropOffs("CBaseCombatWeapon", "m_iSecondaryAmmoCount");

	Cvar_Tiempo = CreateConVar("sm_dados_tiempo", "3.0", "Determina cuanto se tarda en ver lo que te toca. Default: 3 segundos");
	Cvar_Miedo = CreateConVar("sm_miedo_tiempo", "2.0", "Determina cuanto se tarda en ver lo que te toca. Default: 3 segundos");

	Dados_Usos = CreateConVar("sm_dados_usos", "6", "Determina cuantas veces se puede usar el comando. Default: 3");
	//Dados_Usos2 = CreateConVar("sm_dados_ctusos", "3", "Determina cuantas veces se puede usar el comando. Default: 3");

	T_Vivos = CreateConVar("sm_ts_max", "1", "Límite de Ts vivos para resucitar");
	CT_Vivos = CreateConVar("sm_cts_max", "1", "Límite de CTs vivos para resucitar");

	Dados_Usados = CreateConVar("sm_dados_usados", "0", "Determina cuantas veces se puede usar el comando.");
	//Dados_Usados2 = CreateConVar("sm_dados_ctusados", "0", "Determina cuantas veces se puede usar el comando.");

	g_Cvar_Delay = CreateConVar("sm_ataque_delay", "4.0", "Intervalo de tiempo en regalos Santa, Pikachu, Groudon", FCVAR_PLUGIN);
	Missile_Predator = CreateConVar("sm_missile_predator", "1.0", "Intervalo de tiempo en misiles del Predator", FCVAR_PLUGIN);
	 
	hPush2 = CreateConVar("bunnyhop_push","1.0", "Salto del Monstruo/Gallina/Predator/Spiderman/Goku");
	hHeight2 = CreateConVar("bunnyhop_height","3.5", "Altura del salto del Monstruo/Gallina/Predator/Spiderman/Goku");

	hPush3 = CreateConVar("bunnyhop_push13","1.0", "Salto del Robot");
	hHeight3 = CreateConVar("bunnyhop_height13","5.0", "Altura del salto del Robot");

	hPush1 = CreateConVar("sm_hpush2","1.0", "Salto del Zombie");
	hHeight1 = CreateConVar("sm_hheight2","3.0", "Altura del salto del Zombie");

	css_avp_damage = CreateConVar("sm_avp_alienqueen_damage", "3000", "Daño hecho por la Reina Alien", FCVAR_PLUGIN);
	css_avp_radius = CreateConVar("sm_avp_alienqueen_radius", "300", "Radio de inicio", FCVAR_PLUGIN);		
	css_avp_pushforce = CreateConVar("sm_avp_alienqueen_pushforce", "3000", "Fuerza del ácido", FCVAR_PLUGIN);

	g_cvJumpBoost = CreateConVar("sm_doublejump_boost", "350.0","The amount of vertical boost to apply to double jumps.");
	g_cvJumpMax = CreateConVar("sm_doublejump_max", "1","The maximum number of re-jumps allowed while already jumping.");
	
	Timer_AwpFreeze = CreateConVar("sm_timer_awpfreeze", "2.0", "Tiempo descongelación de balas AWP");
	
	Dif = CreateConVar("sm_creditsdif", "2", "Valor por el que se divide el precio de los seres especiales");
	
	RondasEspeciales = CreateConVar("sm_rondasespeciales", "1", "Activar o desactivar rondas especiales");
	
	// CVARS PREMIOS
	
	HealthZombie = CreateConVar("sm_health_zombie", "2500", "Vida del ZOMBIE");
	SpeedZombie = CreateConVar("sm_speed_zombie", "1.2", "Velocidad del ZOMBIE");
	CostZombie = CreateConVar("sm_cost_zombie", "12", "Coste del ZOMBIE");

	HealthIronman = CreateConVar("sm_health_ironman", "200", "Vida del IRONMAN");
	SpeedIronman = CreateConVar("sm_speed_ironman", "1.0", "Velocidad del IRONMAN");
	CostIronman = CreateConVar("sm_cost_ironman", "14", "Coste del IRONMAN");	
	
	HealthBicho = CreateConVar("sm_health_soldado", "2500", "Vida del BICHO ÍGNEO");
	SpeedBicho = CreateConVar("sm_speed_soldado", "1.1", "Velocidad del BICHO ÍGNEO");
	CostBicho = CreateConVar("sm_cost_soldado", "14", "Coste del BICHO ÍGNEO");	
	
	HealthSmith = CreateConVar("sm_health_smith", "100", "Vida del SMITH");
	SpeedSmith = CreateConVar("sm_speed_smith", "1.1", "Velocidad del SMITH");
	CostSmith = CreateConVar("sm_cost_smith", "15", "Coste del SMITH");

	HealthSoldado = CreateConVar("sm_health_soldado", "1000", "Vida del SOLDADO CIBERNÉTICO");
	SpeedSoldado = CreateConVar("sm_speed_soldado", "1.0", "Velocidad del SOLDADO CIBERNÉTICO");
	CostSoldado = CreateConVar("sm_cost_soldado", "15", "Coste del SOLDADO CIBERNÉTICO");	

	HealthPikachu = CreateConVar("sm_health_pikachu", "2500", "Vida del PIKACHU");
	SpeedPikachu = CreateConVar("sm_speed_pikachu", "1.0", "Velocidad del PIKACHU");
	CostPikachu = CreateConVar("sm_cost_pikachu", "15", "Coste del PIKACHU");	
	
	HealthSpiderman = CreateConVar("sm_health_spiderman", "200", "Vida del SPIDERMAN");
	SpeedSpiderman = CreateConVar("sm_speed_spiderman", "1.0", "Velocidad del SPIDERMAN");
	CostSpiderman = CreateConVar("sm_cost_spiderman", "16", "Coste del SPIDERMAN");		

	HealthReina = CreateConVar("sm_health_reina", "2500", "Vida de la REINA ALIEN");
	SpeedReina = CreateConVar("sm_speed_reina", "0.9", "Velocidad de la REINA ALIEN");
	CostReina = CreateConVar("sm_cost_reina", "16", "Coste de la REINA ALIEN");	
	
	HealthMonstruo = CreateConVar("sm_health_monstruo", "2500", "Vida del MONSTRUO");
	SpeedMonstruo = CreateConVar("sm_speed_monstruo", "0.8", "Velocidad del MONSTRUO");
	CostMonstruo = CreateConVar("sm_cost_monstruo", "17", "Coste del MONSTRUO");
	
	HealthRobot = CreateConVar("sm_health_soldado", "2500", "Vida del MEGA ROBOT");
	SpeedRobot = CreateConVar("sm_speed_soldado", "0.8", "Velocidad del MEGA ROBOT");
	CostRobot = CreateConVar("sm_cost_soldado", "17", "Coste del MEGA ROBOT");		

	HealthGroudon = CreateConVar("sm_health_groudon", "4000", "Vida del GROUDON");
	SpeedGroudon = CreateConVar("sm_speed_groudon", "1.0", "Velocidad del GROUDON");
	CostGroudon = CreateConVar("sm_cost_groudon", "18", "Coste del GROUDON");		
	
	HealthGoku = CreateConVar("sm_health_goku", "100", "Vida del GOKU");
	SpeedGoku = CreateConVar("sm_speed_goku", "1.0", "Velocidad del GOKU");
	CostGoku = CreateConVar("sm_cost_goku", "18", "Coste del GOKU");

	HealthJack = CreateConVar("sm_health_jack", "200", "Vida del JACK SQUELETON");
	SpeedJack = CreateConVar("sm_speed_jack", "1.0", "Velocidad del JACK SQUELETON");
	CostJack = CreateConVar("sm_cost_jack", "18", "Coste del JACK SQUELETON");	
	
	HealthFantasma = CreateConVar("sm_health_fantasma", "5", "Vida del FANTASMA (Disparos)");
	CostFantasma = CreateConVar("sm_cost_fantasma", "20", "Coste del FANTASMA");

	HealthPredator = CreateConVar("sm_health_predator", "2500", "Vida del PREDATOR");
	SpeedPredator = CreateConVar("sm_speed_predator", "1.2", "Velocidad del PREDATOR");
	CostPredator = CreateConVar("sm_cost_predator", "20", "Coste del PREDATOR");
		
	HealthSanta = CreateConVar("sm_health_santa", "2000", "Vida del SANTA CLAUS");
	SpeedSanta = CreateConVar("sm_speed_santa", "1.0", "Velocidad del SANTA CLAUS");
	CostSanta = CreateConVar("sm_cost_santa", "16", "Coste del SANTA CLAUS");		
	
	HealthTrainer = CreateConVar("sm_health_trainer", "2000", "Vida del ENTRENADOR POKEMON");
	SpeedTrainer = CreateConVar("sm_speed_trainer", "1.0", "Velocidad del ENTRENADOR POKEMON");
	CostTrainer = CreateConVar("sm_cost_trainer", "12", "Coste del ENTRENADOR POKEMON");	

	HealthTrainer = CreateConVar("sm_health_trainer", "2000", "Vida del ENTRENADOR POKEMON");
	SpeedTrainer = CreateConVar("sm_speed_trainer", "1.0", "Velocidad del ENTRENADOR POKEMON");
	CostTrainer = CreateConVar("sm_cost_trainer", "12", "Coste del ENTRENADOR POKEMON");		

	HealthPene = CreateConVar("sm_health_pene", "4000", "Vida del PENE VOLADOR");
	CostPene = CreateConVar("sm_cost_pene", "22", "Coste del PENE VOLADOR");	
	
	HealthMedic = CreateConVar("sm_health_medic", "250", "Vida del MEDICO");
	SpeedMedic = CreateConVar("sm_speed_medic", "1.0", "Velocidad del MEDICO");
	CostMedic = CreateConVar("sm_cost_medic", "14", "Coste del MEDICO");	

	HealthBatman = CreateConVar("sm_health_batman", "250", "Vida del BATMAN");
	SpeedBatman = CreateConVar("sm_speed_batman", "1.3", "Velocidad del BATMAN");
	CostBatman = CreateConVar("sm_cost_batman", "18", "Coste del BATMAN");	
}





