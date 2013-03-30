
new g_Regalos[MAXPLAYERS+1] = 0;


new gSmoke1;
new gHaloS;
new gGlow1;
new gLaser1;

public DrawIonBeam(Float:startPosition[3])
{
	decl Float:position[3];
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] = startPosition[2] + 1500.0;	

	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, {0, 150, 255, 255}, 3 );
	TE_SendToAll();
	position[2] -= 1490.0;
	TE_SetupSmoke(startPosition, gSmoke1, 10.0, 2);
	TE_SendToAll();
	TE_SetupGlowSprite(startPosition, gGlow1, 1.0, 1.0, 255);
	TE_SendToAll();
}

stock env_shake(Float:Origin[3], Float:Amplitude, Float:Radius, Float:Duration, Float:Frequency)
{
	decl Ent;

	//Initialize:
	Ent = CreateEntityByName("env_shake");
		
	//Spawn:
	if(DispatchSpawn(Ent))
	{
		//Properties:
		DispatchKeyValueFloat(Ent, "amplitude", Amplitude);
		DispatchKeyValueFloat(Ent, "radius", Radius);
		DispatchKeyValueFloat(Ent, "duration", Duration);
		DispatchKeyValueFloat(Ent, "frequency", Frequency);

		SetVariantString("spawnflags 8");
		AcceptEntityInput(Ent,"AddOutput");

		//Input:
		AcceptEntityInput(Ent, "StartShake", 0);
		
		//Send:
		TeleportEntity(Ent, Origin, NULL_VECTOR, NULL_VECTOR);

		//Delete:
		RemoveEntity(Ent, 30.0);
	}
}


stock RemoveEntity(entity, Float:time = 0.0)
{
	if (time == 0.0)
	{
		if(IsValidEntity(entity))
		{
			new String:edictname[32];
			GetEdictClassname(entity, edictname, 32);

			if (StrEqual(edictname, "player"))
				KickClient(entity); // HaHa =D
			else
				AcceptEntityInput(entity, "kill");
		}
	}
	else
	{
		CreateTimer(time, RemoveEntityTimer, entity, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:RemoveEntityTimer(Handle:Timer, any:entity)
{
	if(IsValidEntity(entity))
		AcceptEntityInput(entity, "kill"); // RemoveEdict(entity);
	
	return (Plugin_Stop);
}

stock MineAttack(client)
{
	decl Float:cleyepos[3], Float:cleyeangle[3];
	
	GetClientEyePosition(client, cleyepos);
	GetClientEyeAngles(client, cleyeangle);

	new entity;
	entity = CreateEntityByName("hegrenade_projectile");

	
	SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
	DispatchSpawn(entity);
	
	setm_takedamage(entity, DAMAGE_YES);
	
	SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
	SetEntityModel(entity, "models/items/cs_gift.mdl");
	TeleportEntity(entity, cleyepos, cleyeangle, cleyeangle);

	SetEntProp(entity, Prop_Data, "m_iHealth", 1);
	
	CreateTimer(3.0, StartMine, entity, TIMER_FLAG_NO_MAPCHANGE);
	
	SDKHook(entity, SDKHook_StartTouch, MineTouchHook);				
	SDKHook(entity, SDKHook_OnTakeDamage, MineDamageHook);
}

public Action:StartMine(Handle:Timer, any:entity)
{
	MineActive(entity);
}

public Action:MineTouchHook(entity, other)
{
	decl Float:entityposition[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityposition);	
	
	new laserent = CreateEntityByName("point_tesla");
	DispatchKeyValue(laserent, "m_flRadius", "100.0");
	DispatchKeyValue(laserent, "m_SoundName", "DoSpark");
	DispatchKeyValue(laserent, "beamcount_min", "42");
	DispatchKeyValue(laserent, "beamcount_max", "62");
	DispatchKeyValue(laserent, "texture", "sprites/physbeam.vmt");
	DispatchKeyValue(laserent, "m_Color", "255 255 255");
	DispatchKeyValue(laserent, "thick_min", "10.0");
	DispatchKeyValue(laserent, "thick_max", "11.0");
	DispatchKeyValue(laserent, "lifetime_min", "0.3");
	DispatchKeyValue(laserent, "lifetime_max", "0.3");
	DispatchKeyValue(laserent, "interval_min", "0.1");
	DispatchKeyValue(laserent, "interval_max", "0.2");
	DispatchSpawn(laserent);
	
	TeleportEntity(laserent, entityposition, NULL_VECTOR, NULL_VECTOR);
	
	AcceptEntityInput(laserent, "TurnOn");  
	AcceptEntityInput(laserent, "DoSpark");    
		
	if(other != 0)
	{
		if(other == GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))
			return (Plugin_Continue);
		else if(!IsEntityCollidable(other, true, true, true))
			return (Plugin_Continue);
			
		MineActive(entity);
	}

	return (Plugin_Continue);
}

public Action:MineDamageHook(entity, &attacker, &inflictor, &Float:damage, &damagetype)
{
	MineActive(entity);
	
	return (Plugin_Handled);
}

stock MineActive(entity)
{
	SDKUnhook(entity, SDKHook_StartTouch, MineTouchHook);
	SDKUnhook(entity, SDKHook_OnTakeDamage, MineDamageHook);

	if(IsValidEntity(entity) && IsValidEdict(entity))
	{ 
		setm_takedamage(entity, DAMAGE_NO);
		decl Float:entityposition[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityposition);
		new client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

		AcceptEntityInput(entity, "Kill");
		
		DrawIonBeam(entityposition);
		TE_SetupBeamRingPoint(entityposition, 0.0, 500.0, gGlow1, gHaloS, 0, 0, 0.5, 10.0, 2.0, {255, 255, 255, 255}, 0, 0);
		TE_SendToAll();
		TE_SetupBeamRingPoint(entityposition, 0.0, 500.0, gGlow1, gHaloS, 0, 0, 0.7, 10.0, 2.0, {255, 255, 255, 255}, 0, 0);
		TE_SendToAll();
		TE_SetupBeamRingPoint(entityposition, 0.0, 500.0, gGlow1, gHaloS, 0, 0, 0.9, 10.0, 2.0, {255, 255, 255, 255}, 0, 0);
		TE_SendToAll();
		TE_SetupBeamRingPoint(entityposition, 0.0, 500.0, gGlow1, gHaloS, 0, 0, 1.4, 10.0, 2.0, {255, 255, 255, 255}, 0, 0);
		TE_SendToAll();

		// Light
		new ent = CreateEntityByName("light_dynamic");

		DispatchKeyValue(ent, "_light", "120 120 255 255");
		DispatchKeyValue(ent, "brightness", "5");
		DispatchKeyValueFloat(ent, "spotlight_radius", 500.0);
		DispatchKeyValueFloat(ent, "distance", 500.0);
		DispatchKeyValue(ent, "style", "6");
		
		// SetEntityMoveType(ent, MOVETYPE_NOCLIP); 
		DispatchSpawn(ent);
		AcceptEntityInput(ent, "TurnOn");
		
		TeleportEntity(ent, entityposition, NULL_VECTOR, NULL_VECTOR);
		
		RemoveEntity(ent, 1.0);
		
		entityposition[2] += 15.0;
		makeexplosion(IsClientConnectedIngame(client) ? client : 0, -1, entityposition, "", 300);
		
		env_shake(entityposition, 120.0, 1000.0, 3.0, 250.0);
		
		EmitSoundToAll("weapons/physcannon/energy_disintegrate4.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, entityposition);
		

		// Knockback
		new Float:vReturn[3], Float:vClientPosition[3], Float:dist;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i))
			{	
				GetClientEyePosition(i, vClientPosition);

				dist = GetVectorDistance(vClientPosition, entityposition, false);
				if (dist < 1000.0)
				{
					MakeVectorFromPoints(entityposition, vClientPosition, vReturn);
					NormalizeVector(vReturn, vReturn);
					ScaleVector(vReturn, -5000.0);

					TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, vReturn);
				}
			}
		}
	}
}

public Action:DarRegalos(Handle:timer, any:client)
{
 if (IsClientInGame(client) && g_Santa[client])
 {
   	g_Regalos[client] += 1;
 }
}
