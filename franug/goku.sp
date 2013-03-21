



new g_PlasmaCantidad[MAXPLAYERS+1];

public InitWeapons10()
{

	
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	
	PrecacheSound("weapons/ar2/fire1.wav");
	PrecacheSound("weapons/rpg/rocketfire1.wav");
	PrecacheSound("weapons/explode3.wav");
	PrecacheSound("weapons/physcannon/energy_sing_explosion2.wav");
	PrecacheSound("ambient/explosions/citadel_end_explosion2.wav");
	PrecacheSound("ambient/explosions/citadel_end_explosion1.wav");
	PrecacheSound("ambient/energy/weld1.wav");
	PrecacheSound("weapons/flaregun/fire.wav");
	PrecacheSound("weapons/fx/nearmiss/bulletltor03.wav");
	PrecacheSound("weapons/fx/nearmiss/bulletltor04.wav");
	PrecacheSound("weapons/fx/nearmiss/bulletltor05.wav");
	PrecacheSound("weapons/fx/nearmiss/bulletltor06.wav");
	PrecacheSound("weapons/fx/nearmiss/bulletltor07.wav");
	PrecacheSound("weapons/fx/nearmiss/bulletltor09.wav");
	PrecacheSound("weapons/fx/nearmiss/bulletltor10.wav");
	PrecacheSound("weapons/fx/nearmiss/bulletltor11.wav");
	PrecacheSound("weapons/fx/nearmiss/bulletltor12.wav");
	PrecacheSound("weapons/fx/nearmiss/bulletltor13.wav");
	PrecacheSound("weapons/fx/nearmiss/bulletltor14.wav");
}

stock PlasmaAttack(client)
{
	decl Float:clienteyeangle[3], Float:anglevector[3], Float:clienteyeposition[3], Float:resultposition[3], entity;
	GetClientEyeAngles(client, clienteyeangle);
	GetClientEyePosition(client, clienteyeposition);
	GetAngleVectors(clienteyeangle, anglevector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(anglevector, anglevector);
	//ScaleVector(anglevector, 10.0);
	AddVectors(clienteyeposition, anglevector, resultposition);
	NormalizeVector(anglevector, anglevector);
	ScaleVector(anglevector, 4500.0);

	entity = CreateEntityByName("flashbang_projectile");
	
	SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
	setm_takedamage(entity, DAMAGE_NO);
	DispatchSpawn(entity);
	new Float:vecmax[3] = {4.0, 4.0, 4.0};
	new Float:vecmin[3] = {-4.0, -4.0, -4.0};
	SetEntPropVector(entity, Prop_Send, "m_vecMins", vecmin);
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vecmax);
	SetEntityMoveType(entity, MOVETYPE_FLY);
	SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
	SetEntityModel(entity, "models/weapons/w_missile_launch.mdl");
	TeleportEntity(entity, resultposition, clienteyeangle, anglevector);

	new gascloud = CreateEntityByName("env_rockettrail");
	DispatchKeyValueVector(gascloud,"Origin", resultposition);
	DispatchKeyValueVector(gascloud,"Angles", clienteyeangle);
        new Float:smokecolor[3];
	

        smokecolor[0] = 0.4; 
	smokecolor[1] = 1.0; 
	smokecolor[2] = 1.0;
        
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

        new number = GetRandomInt(1, 11);
        switch (number)
        {
			case 1:
			{
                            EmitSoundToAll("weapons/fx/nearmiss/bulletltor03.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);
			}
			case 2:
			{
                            EmitSoundToAll("weapons/fx/nearmiss/bulletltor04.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);
			}
			case 3:
			{
                            EmitSoundToAll("weapons/fx/nearmiss/bulletltor05.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);
			}
			case 4:
			{
                            EmitSoundToAll("weapons/fx/nearmiss/bulletltor06.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);
			}
			case 5:
			{
                            EmitSoundToAll("weapons/fx/nearmiss/bulletltor07.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);
			}
			case 6:
			{
                            EmitSoundToAll("weapons/fx/nearmiss/bulletltor09.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);
			}
			case 7:
			{
                            EmitSoundToAll("weapons/fx/nearmiss/bulletltor10.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);
			}
			case 8:
			{
                            EmitSoundToAll("weapons/fx/nearmiss/bulletltor11.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);
			}
			case 9:
			{
                            EmitSoundToAll("weapons/fx/nearmiss/bulletltor12.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);
			}
			case 10:
			{
                            EmitSoundToAll("weapons/fx/nearmiss/bulletltor13.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);
			}
			case 11:
			{
                            EmitSoundToAll("weapons/fx/nearmiss/bulletltor14.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, clienteyeposition);
			}
        }

	SDKHook(entity, SDKHook_StartTouch, PlasmaTouchHook);
	SDKHook(entity, SDKHook_OnTakeDamage, PlasmaDamageHook);

	new Handle:datapack = CreateDataPack();
	WritePackCell(datapack, EntIndexToEntRef(entity));
	CreateTimer(0.1, PlasmaSeekThink, datapack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
	setm_takedamage(entity, DAMAGE_YES);

	new Float:angle[3] = {0.0, 0.0, 0.0};

	angle[0] = -6.0;
	angle[1] = GetRandomFloat(-2.0, 2.0);

	makeviewpunch(client, angle);
}

public Action:PlasmaTouchHook(entity, other)
{
	if(other != 0)
	{
		if(other == GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))
			return (Plugin_Continue);
		else if(!IsEntityCollidable(other, true, true, true))
			return (Plugin_Continue);
	}

	PlasmaActive(entity);

	return (Plugin_Continue);
}

public Action:PlasmaDamageHook(entity, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(GetEntProp(entity, Prop_Data, "m_takedamage") == DAMAGE_YES)
		PlasmaActive(entity);

	return (Plugin_Continue);
}



public Action:PlasmaSeekThink(Handle:Timer, Handle:data)
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
					ScaleVector(vecangle, 4500.0);
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

stock PlasmaActive(entity)
{
	SDKUnhook(entity, SDKHook_StartTouch, PlasmaTouchHook);
	SDKUnhook(entity, SDKHook_OnTakeDamage, PlasmaDamageHook);

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


                if(g_Goku2[client])
                {
		      makeexplosion2(IsClientConnectedIngame(client) ? client : 0, -1, entityposition, "", 395);
                } 
                else if(g_Goku[client])
                {
		      makeexplosion2(IsClientConnectedIngame(client) ? client : 0, -1, entityposition, "", 95);
                }

		EmitSoundToAll("weapons/physcannon/energy_sing_explosion2.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, entityposition);
	}
}

