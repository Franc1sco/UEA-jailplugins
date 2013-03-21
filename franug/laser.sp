


new Handle:g_CvarEnable = INVALID_HANDLE;

new g_spritepre;


new Handle:g_CvarRed2 = INVALID_HANDLE;
new Handle:g_CvarBlue2 = INVALID_HANDLE;
new Handle:g_CvarGreen2 = INVALID_HANDLE;

new Handle:g_CvarTrans2 = INVALID_HANDLE;

new Handle:g_CvarRed = INVALID_HANDLE;
new Handle:g_CvarBlue = INVALID_HANDLE;
new Handle:g_CvarGreen = INVALID_HANDLE;

new Handle:g_CvarTrans = INVALID_HANDLE;
new Handle:g_CvarLife = INVALID_HANDLE;
new Handle:g_CvarWidth = INVALID_HANDLE;



new g_Lasers[MAXPLAYERS+1] = 0;

public OnMapStartpre()
{
	g_spritepre = PrecacheModel("materials/sprites/laser.vmt");
        PrecacheSound("weapons/physcannon/energy_disintegrate4.wav");
        PrecacheSound("weapons/physcannon/energy_disintegrate5.wav");

	AddFileToDownloadsTable("materials/models/player/techknow/predator/chest.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/predator/chest.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/predator/chest_n.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/predator/crop.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/predator/crop.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/predator/crop_n.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/predator/head.vmt");
	AddFileToDownloadsTable("materials/models/player/techknow/predator/head.vtf");
	AddFileToDownloadsTable("materials/models/player/techknow/predator/head_n.vtf");
	AddFileToDownloadsTable("models/player/techknow/predator_v2/predator.dx80.vtx");
	AddFileToDownloadsTable("models/player/techknow/predator_v2/predator.dx90.vtx");
	AddFileToDownloadsTable("models/player/techknow/predator_v2/predator.mdl");
	AddFileToDownloadsTable("models/player/techknow/predator_v2/predator.phy");
	AddFileToDownloadsTable("models/player/techknow/predator_v2/predator.sw.vtx");
	AddFileToDownloadsTable("models/player/techknow/predator_v2/predator.vvd");

	AddFileToDownloadsTable("sound/predator/imhere.mp3");
	PrecacheSound("predator/imhere.mp3");

	PrecacheModel("models/player/techknow/predator_v2/predator.mdl");

}

public OnPluginStartpre()
{
	g_CvarEnable = CreateConVar("sm_laser_aim_on", "1", "1 turns the plugin on 0 is off");

	g_CvarRed = CreateConVar("sm_laser_aim_red", "200", "Amount OF Red In The Beam");
	g_CvarGreen = CreateConVar("sm_laser_aim_green", "0", "Amount Of Green In The Beam");
	g_CvarBlue = CreateConVar("sm_laser_aim_blue", "0", "Amount OF Blue In The Beams");
	g_CvarTrans = CreateConVar("sm_laser_aim_alpha", "200", "Amount OF Transparency In Beam");

	g_CvarRed2 = CreateConVar("sm_laser_aim_red2", "0", "Amount OF Red In The Beam");
	g_CvarGreen2 = CreateConVar("sm_laser_aim_green2", "0", "Amount Of Green In The Beam");
	g_CvarBlue2 = CreateConVar("sm_laser_aim_blue2", "200", "Amount OF Blue In The Beams");
	g_CvarTrans2 = CreateConVar("sm_laser_aim_alpha2", "200", "Amount OF Transparency In Beam");
	
	g_CvarLife = CreateConVar("sm_laser_aim_life", "0.1", "Life of the Beam");


	g_CvarWidth = CreateConVar("sm_laser_aim_width", "0.4", "Width of the Beam");







	//m_iFOV = FindSendPropOffs("CBasePlayer","m_iFOV");
}

public Action:CreateBeam(any:client)
{
	new Float:f_playerViewOrigin[3];
	GetClientAbsOrigin(client, f_playerViewOrigin);
	if(GetClientButtons(client) & IN_DUCK)
		f_playerViewOrigin[2] += 40;
	else
		f_playerViewOrigin[2] += 60;

	new Float:f_playerViewDestination[3];		
	GetPlayerEye(client, f_playerViewDestination);

	new Float:distance = GetVectorDistance( f_playerViewOrigin, f_playerViewDestination );

	new Float:percentage = 0.4 / ( distance / 100 );

	new Float:f_newPlayerViewOrigin[3];
	f_newPlayerViewOrigin[0] = f_playerViewOrigin[0] + ( ( f_playerViewDestination[0] - f_playerViewOrigin[0] ) * percentage );
	f_newPlayerViewOrigin[1] = f_playerViewOrigin[1] + ( ( f_playerViewDestination[1] - f_playerViewOrigin[1] ) * percentage ) - 0.08;
	f_newPlayerViewOrigin[2] = f_playerViewOrigin[2] + ( ( f_playerViewDestination[2] - f_playerViewOrigin[2] ) * percentage );


        new color[4];
        if(GetClientTeam(client) == 2)
        {
	   color[0] = GetConVarInt( g_CvarRed ); 
	   color[1] = GetConVarInt( g_CvarGreen );
	   color[2] = GetConVarInt( g_CvarBlue );
	   color[3] = GetConVarInt( g_CvarTrans );
        }
        else
        {
	   color[0] = GetConVarInt( g_CvarRed2 ); 
	   color[1] = GetConVarInt( g_CvarGreen2 );
	   color[2] = GetConVarInt( g_CvarBlue2 );
	   color[3] = GetConVarInt( g_CvarTrans2 );
        }
	
	new Float:life;
	life = GetConVarFloat( g_CvarLife );

	new Float:width;
	width = GetConVarFloat( g_CvarWidth );

	
	TE_SetupBeamPoints( f_newPlayerViewOrigin, f_playerViewDestination, g_spritepre, 0, 0, 0, life, width, 0.0, 1, 0.0, color, 0 );
	TE_SendToAll();
	
	
	return Plugin_Continue;
}



bool:GetPlayerEye(client, Float:pos[3])
{
	new Float:vAngles[3], Float:vOrigin[3];
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayerpre);
	
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(pos, trace);
		CloseHandle(trace);
		return true;
	}
	CloseHandle(trace);
	return false;
}

public bool:TraceEntityFilterPlayerpre(entity, contentsMask)
{
    return entity > GetMaxClients();
}


stock SentryShootProjectile(client)
{
	decl Float:clienteyeangle[3], Float:anglevector[3], Float:clienteyeposition[3], Float:resultposition[3], entity;
	GetClientEyeAngles(client, clienteyeangle);
	GetClientEyePosition(client, clienteyeposition);
	GetAngleVectors(clienteyeangle, anglevector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(anglevector, anglevector);
	ScaleVector(anglevector, 100.0);
	AddVectors(clienteyeposition, anglevector, resultposition);
	NormalizeVector(anglevector, anglevector);
	ScaleVector(anglevector, 2500.0);


	//if (game == CSS)
	entity = CreateEntityByName("hegrenade_projectile");
	//else if (game == TF)
	//	entity = CreateEntityByName("tf_projectile_pipe");
		
	//setm_takedamage(entity, DAMAGE_NO);

        SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
	setm_takedamage(entity, DAMAGE_YES);
	//SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
	DispatchSpawn(entity);
	/*
	new Float:vecmax[3] = {4.0, 4.0, 4.0};
	new Float:vecmin[3] = {-4.0, -4.0, -4.0};
	SetEntPropVector(entity, Prop_Send, "m_vecMins", vecmin);
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vecmax);
	*/
	SetEntityMoveType(entity, MOVETYPE_FLY);
	SetEntityModel(entity, "models/weapons/w_missile_launch.mdl");
	
	TeleportEntity(entity, resultposition, clienteyeangle, anglevector);

	new gascloud = CreateEntityByName("env_rockettrail");
	DispatchKeyValueVector(gascloud,"Origin", resultposition);
	DispatchKeyValueVector(gascloud,"Angles", clienteyeangle);
	new Float:smokecolor[3] = {0.0, 0.0, 0.0};
	SetEntPropVector(gascloud, Prop_Send, "m_StartColor", smokecolor);
	SetEntPropFloat(gascloud, Prop_Send, "m_Opacity", 0.2);
	SetEntPropFloat(gascloud, Prop_Send, "m_SpawnRate", 10.0);
	SetEntPropFloat(gascloud, Prop_Send, "m_ParticleLifetime", 0.1);
	SetEntPropFloat(gascloud, Prop_Send, "m_StartSize", 1.0);
	SetEntPropFloat(gascloud, Prop_Send, "m_EndSize", 3.0);
	SetEntPropFloat(gascloud, Prop_Send, "m_SpawnRadius", 0.0);
	SetEntPropFloat(gascloud, Prop_Send, "m_MinSpeed", 0.0);
	SetEntPropFloat(gascloud, Prop_Send, "m_MaxSpeed", 10.0);
	SetEntPropFloat(gascloud, Prop_Send, "m_flFlareScale", 1.0);
	DispatchSpawn(gascloud);
	decl String:steamid[64];
	GetClientAuthString(client, steamid, 64);
	Format(steamid, 64, "%s%f", steamid, GetGameTime());
	DispatchKeyValue(entity, "targetname", steamid);
	SetVariantString(steamid);
	AcceptEntityInput(gascloud, "SetParent");
	SetEntPropEnt(entity, Prop_Send, "m_hEffectEntity", gascloud);

	//EmitSoundToAll("weapons/ar2/fire1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
        EmitSoundToAll("weapons/fx/nearmiss/bulletltor03.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);

        new number = GetRandomInt(1, 2);
        switch (number)
        {
			case 1:
			{
                            EmitSoundToAll("weapons/physcannon/energy_disintegrate4.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);
			}
			case 2:
			{
                            EmitSoundToAll("weapons/physcannon/energy_disintegrate5.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);
			}
        }
	SDKHook(entity, SDKHook_StartTouch, SentryProjectileTouchHook);
	SDKHook(entity, SDKHook_OnTakeDamage, SentryProjectileDamageHook);

	setm_takedamage(entity, DAMAGE_YES);

}

public Action:SentryProjectileTouchHook(entity, other)
{
	SentryProjectileActive(entity, other);

	return (Plugin_Continue);
}

public Action:SentryProjectileDamageHook(entity, &attacker, &inflictor, &Float:damage, &damagetype)
{
	SentryProjectileActive(entity, 0);

	return (Plugin_Continue);
}

stock SentryProjectileActive(entity, other)
{
	SDKUnhook(entity, SDKHook_StartTouch, SentryProjectileTouchHook);
	SDKUnhook(entity, SDKHook_OnTakeDamage, SentryProjectileDamageHook);

	decl Float:entityposition[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityposition);

        new client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

	//EmitAmbientSound( EXPLODE_SOUND, entityposition, entity, SNDLEVEL_NORMAL );

        EmitSoundToAll( EXPLODE_SOUND, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, entityposition);

	AcceptEntityInput(entity, "Kill");
	//entityposition[2] = entityposition[2] + 15.0;



	//MakeDamage(client, other, 200, DMG_BULLET, 500.0, entityposition);
        makeexplosion2(IsClientConnectedIngame(client) ? client : 0, -1, entityposition, "", 200);
	// makeexplosion(0, -1, entityposition, "", 25);


	//TE_SetupExplosion( entityposition, g_ExplosionSprite, 5.0, 1, 0, 50, 40, iNormal );
	//TE_SendToAll();
			
	//TE_SetupSmoke( entityposition, g_SmokeSprite, 10.0, 3 );
	//TE_SendToAll();
	


}


public Action:DarLaser(Handle:timer, any:client)
{
 if (IsClientInGame(client) && g_Predator[client])
 {
   	g_Lasers[client] += 1;
 }
}