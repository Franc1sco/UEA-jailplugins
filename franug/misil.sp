

/* 
	------------------------------------------------------------------------------------------
	STOCKLIB-FUNCTIONS
	------------------------------------------------------------------------------------------
*/
// settings for m_takedamage
#define	DAMAGE_NO				0
#define DAMAGE_EVENTS_ONLY		1		// Call damage functions, but don't modify health
#define	DAMAGE_YES				2
#define	DAMAGE_AIM				3

#define FFADE_IN 	0x0001        // Just here so we don't pass 0 into the function
#define FFADE_OUT	0x0002        // Fade out (not in)
#define FFADE_MODULATE	0x0004        // Modulate (don't blend)
#define FFADE_STAYOUT	0x0008        // ignores the duration, stays faded out until new ScreenFade message received
#define FFADE_PURGE	0x0010        // Purges all other fades, replacing them with this one

new MisilCantidad[MAXPLAYERS+1] = 0;



public InitWeapons()
{

	
	
	PrecacheSound("weapons/rpg/rocketfire1.wav");//
	PrecacheSound("weapons/explode3.wav");//

	PrecacheModel("models/weapons/w_missile_launch.mdl");
}


stock RocketAttack(client)
{
	decl Float:clienteyeangle[3], Float:anglevector[3], Float:clienteyeposition[3], Float:resultposition[3], entity;
	GetClientEyeAngles(client, clienteyeangle);
	GetClientEyePosition(client, clienteyeposition);
	GetAngleVectors(clienteyeangle, anglevector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(anglevector, anglevector);
	//ScaleVector(anglevector, 10.0);
	AddVectors(clienteyeposition, anglevector, resultposition);
	NormalizeVector(anglevector, anglevector);
	ScaleVector(anglevector, 500.0);

	entity = CreateEntityByName("hegrenade_projectile");
	SetEntityMoveType(entity, MOVETYPE_FLY);


	SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
	setm_takedamage(entity, DAMAGE_NO);
	DispatchSpawn(entity);
	new Float:vecmax[3] = {4.0, 4.0, 4.0};
	new Float:vecmin[3] = {-4.0, -4.0, -4.0};
	SetEntPropVector(entity, Prop_Send, "m_vecMins", vecmin);
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vecmax);
	
	SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
	SetEntityModel(entity, "models/weapons/w_missile_launch.mdl");

	new NadeTeam = GetEntProp(client, Prop_Send, "m_iTeamNum");

	switch (NadeTeam)
	{
		case 2:
		{
			SetEntityRenderColor(entity, 255, 0, 0, 255);
		}
		case 3:
		{
			SetEntityRenderColor(entity, 0, 0, 255, 255);
		}
	}

	TeleportEntity(entity, resultposition, clienteyeangle, anglevector);

	new gascloud = CreateEntityByName("env_rockettrail");
	DispatchKeyValueVector(gascloud,"Origin", resultposition);
	DispatchKeyValueVector(gascloud,"Angles", clienteyeangle);
	new Float:smokecolor[3] = {1.0, 1.0, 1.0};
	SetEntPropVector(gascloud, Prop_Send, "m_StartColor", smokecolor);
	SetEntPropFloat(gascloud, Prop_Send, "m_Opacity", 0.5);
	SetEntPropFloat(gascloud, Prop_Send, "m_SpawnRate", 100.0);
	SetEntPropFloat(gascloud, Prop_Send, "m_ParticleLifetime", 0.5);
	SetEntPropFloat(gascloud, Prop_Send, "m_StartSize", 5.0);
	SetEntPropFloat(gascloud, Prop_Send, "m_EndSize", 30.0);
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

	EmitSoundToAll("weapons/rpg/rocketfire1.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);
	SDKHook(entity, SDKHook_StartTouch, RocketTouchHook);
	SDKHook(entity, SDKHook_OnTakeDamage, RocketDamageHook);
	
	new Handle:datapack = CreateDataPack();
	WritePackCell(datapack, EntIndexToEntRef(entity));
	CreateTimer(0.1, RocketSeekThink, datapack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
	setm_takedamage(entity, DAMAGE_YES);
 
	new Float:angle[3] = {0.0, 0.0, 0.0};

	angle[0] = -6.0;
	angle[1] = GetRandomFloat(-2.0, 2.0);

	makeviewpunch(client, angle);

}

public Action:RocketTouchHook(entity, other)
{
	if(other != 0)
	{
		if(other == GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))
			return (Plugin_Continue);
		else if(!IsEntityCollidable(other, true, true, true))
			return (Plugin_Continue);
	}

	RocketActive(entity);

	return (Plugin_Continue);
}

public Action:RocketDamageHook(entity, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(GetEntProp(entity, Prop_Data, "m_takedamage") == DAMAGE_YES)
		RocketActive(entity);

	return (Plugin_Continue);
}

public Action:RocketSeekThink(Handle:Timer, Handle:data)
{
	decl entity, client;
	ResetPack(data);
	entity = ReadPackCell(data);
	entity = EntRefToEntIndex(entity);

	if(entity != -1)
	{
		client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

		if(IsClientConnectedIngame(client))
		{
			if(IsPlayerAlive(client))
			{
				decl Float:cleyepos[3], Float:cleyeangle[3], Float:resultposition[3], Float:rocketposition[3], Float:vecangle[3], Float:angle[3];

				GetClientEyePosition(client, cleyepos);
				GetClientEyeAngles(client, cleyeangle);

				new Handle:traceresulthandle = INVALID_HANDLE;

				traceresulthandle = TR_TraceRayFilterEx(cleyepos, cleyeangle, MASK_SOLID, RayType_Infinite, tracerayfilterrocket, client);

				if(TR_DidHit(traceresulthandle) == true)
				{
					TR_GetEndPosition(resultposition, traceresulthandle);
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", rocketposition);

					MakeVectorFromPoints(rocketposition, resultposition, vecangle);
					NormalizeVector(vecangle, vecangle);
					GetVectorAngles(vecangle, angle);
					ScaleVector(vecangle, 500.0);
					TeleportEntity(entity, NULL_VECTOR, angle, vecangle);
				}

				CloseHandle(traceresulthandle);
			}
		}
		return (Plugin_Continue);
	}
	else
		return (Plugin_Stop);
}

stock RocketActive(entity)
{
	SDKUnhook(entity, SDKHook_StartTouch, RocketTouchHook);
	SDKUnhook(entity, SDKHook_OnTakeDamage, RocketDamageHook);

	if(GetEntProp(entity, Prop_Data, "m_takedamage") == DAMAGE_YES)
	{
		setm_takedamage(entity, DAMAGE_NO);
		decl Float:entityposition[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityposition);
		new client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

		new gasentity = GetEntPropEnt(entity, Prop_Send, "m_hEffectEntity");
		AcceptEntityInput(gasentity, "kill");
		AcceptEntityInput(entity, "Kill");
		entityposition[2] = entityposition[2] + 15.0;

		makeexplosion(IsClientConnectedIngame(client) ? client : 0, -1, entityposition, "", 200);

		EmitSoundToAll("weapons/explode3.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, entityposition);
	}
}

