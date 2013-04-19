public Action:CongelarCliente(client)
{
	SetEntityMoveType(client, MOVETYPE_NONE);
	//SetEntityRenderColor(client, 0, 128, 255, 192);

	CreateTimer(4.5, DescongelarCliente, client);
}

public IsValidClient( client ) 
{ 
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
}

stock DealDamage(nClientVictim, nDamage, nClientAttacker = 0, nDamageType = DMG_GENERIC, String:sWeapon[] = "")
// ----------------------------------------------------------------------------
{
	// taken from: http://forums.alliedmods.net/showthread.php?t=111684
	// thanks to the authors!
	if(	nClientVictim > 0 &&
			IsValidEdict(nClientVictim) &&
			IsClientInGame(nClientVictim) &&
			IsPlayerAlive(nClientVictim) &&
			nDamage > 0)
	{
		new EntityPointHurt = CreateEntityByName("point_hurt");
		if(EntityPointHurt != 0)
		{
			new String:sDamage[16];
			IntToString(nDamage, sDamage, sizeof(sDamage));

			new String:sDamageType[32];
			IntToString(nDamageType, sDamageType, sizeof(sDamageType));

			DispatchKeyValue(nClientVictim,			"targetname",		"war3_hurtme");
			DispatchKeyValue(EntityPointHurt,		"DamageTarget",	"war3_hurtme");
			DispatchKeyValue(EntityPointHurt,		"Damage",				sDamage);
			DispatchKeyValue(EntityPointHurt,		"DamageType",		sDamageType);
			if(!StrEqual(sWeapon, ""))
				DispatchKeyValue(EntityPointHurt,	"classname",		sWeapon);
			DispatchSpawn(EntityPointHurt);
			AcceptEntityInput(EntityPointHurt,	"Hurt",					(nClientAttacker != 0) ? nClientAttacker : -1);
			DispatchKeyValue(EntityPointHurt,		"classname",		"point_hurt");
			DispatchKeyValue(nClientVictim,			"targetname",		"war3_donthurtme");

			RemoveEdict(EntityPointHurt);
		}
	}
}

stock Shake(client, Float:flAmplitude, Float:flDuration)
{
    new Handle:hBf=StartMessageOne("Shake", client);
    if(hBf!=INVALID_HANDLE)
    
    BfWriteByte(hBf,  0);
    BfWriteFloat(hBf, flAmplitude);
    BfWriteFloat(hBf, 1.0);
    BfWriteFloat(hBf, flDuration);
    EndMessage();
}

public Action:DescongelarCliente(Handle:timer, any:client)
{
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
		
		//SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}

// Santa Claus
stock bool:makeexplosion(attacker = 0, inflictor = -1, const Float:attackposition[3], const String:weaponname[] = "", magnitude = 800, radiusoverride = 0, Float:damageforce = 0.0, flags = 0){
	
	new explosion = CreateEntityByName("env_explosion");


	
	if(explosion != -1)
	{
		DispatchKeyValueVector(explosion, "Origin", attackposition);
		
		decl String:intbuffer[64];
		IntToString(magnitude, intbuffer, 64);
		DispatchKeyValue(explosion,"iMagnitude", intbuffer);
		if(radiusoverride > 0)
		{
			IntToString(radiusoverride, intbuffer, 64);
			DispatchKeyValue(explosion,"iRadiusOverride", intbuffer);
		}
		
		if(damageforce > 0.0)
			DispatchKeyValueFloat(explosion,"DamageForce", damageforce);

		if(flags != 0)
		{
			IntToString(flags, intbuffer, 64);
			DispatchKeyValue(explosion,"spawnflags", intbuffer);
		}

		if(!StrEqual(weaponname, "", false))
			DispatchKeyValue(explosion,"classname", weaponname);

		DispatchSpawn(explosion);
		if(IsClientConnectedIngame(attacker))
                {
			SetEntPropEnt(explosion, Prop_Send, "m_hOwnerEntity", attacker);
		        new clientTeam = GetEntProp(attacker, Prop_Send, "m_iTeamNum");
                        SetEntProp(explosion, Prop_Send, "m_iTeamNum", clientTeam);
                }

		if(inflictor != -1)
			SetEntPropEnt(explosion, Prop_Data, "m_hInflictor", inflictor);

			
		AcceptEntityInput(explosion, "Explode");
		AcceptEntityInput(explosion, "Kill");
		
		return (true);
	}
	else
		return (false);
}

stock bool:IsClientConnectedIngame(client)
{
	if(client > 0 && client <= MaxClients)
		if(IsClientInGame(client))
			return (true);

	return (false);
}

stock setm_takedamage(entity, type)
{
	SetEntProp(entity, Prop_Data, "m_takedamage", type);
}

stock makeviewpunch(client, Float:angle[3])
{
	decl Float:oldangle[3];
	
	GetEntPropVector(client, Prop_Send, "m_vecPunchAngle", oldangle);
	
	oldangle[0] = oldangle[0] + angle[0];
	oldangle[1] = oldangle[1] + angle[1];
	oldangle[2] = oldangle[2] + angle[2];
	
	SetEntPropVector(client, Prop_Send, "m_vecPunchAngle", oldangle);
	SetEntPropVector(client, Prop_Send, "m_vecPunchAngleVel", angle);
}




public bool:tracerayfilterrocket(entity, mask, any:data)
{
	if(entity != data && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != data)
		return (true);
	else
		return (false);
}

stock bool:IsEntityCollidable(entity, bool:includeplayer = true, bool:includehostage = true, bool:includeprojectile = true)
{
	decl String:classname[64];
	GetEdictClassname(entity, classname, 64);
	
	if((StrEqual(classname, "player", false) && includeplayer) || (StrEqual(classname, "hostage_entity", false) && includehostage)
		|| StrContains(classname, "physics", false) != -1 || StrContains(classname, "prop", false) != -1
		|| StrContains(classname, "door", false)  != -1 || StrContains(classname, "weapon", false)  != -1
		|| StrContains(classname, "break", false)  != -1 || ((StrContains(classname, "projectile", false)  != -1) && includeprojectile)
		|| StrContains(classname, "brush", false)  != -1 || StrContains(classname, "button", false)  != -1
		|| StrContains(classname, "physbox", false)  != -1 || StrContains(classname, "plat", false)  != -1
		|| StrEqual(classname, "func_conveyor", false) || StrEqual(classname, "func_fish_pool", false)
		|| StrEqual(classname, "func_guntarget", false) || StrEqual(classname, "func_lod", false)
		|| StrEqual(classname, "func_monitor", false) || StrEqual(classname, "func_movelinear", false)
		|| StrEqual(classname, "func_reflective_glass", false) || StrEqual(classname, "func_rotating", false)
		|| StrEqual(classname, "func_tanktrain", false) || StrEqual(classname, "func_trackautochange", false)
		|| StrEqual(classname, "func_trackchange", false) || StrEqual(classname, "func_tracktrain", false)
		|| StrEqual(classname, "func_train", false) || StrEqual(classname, "func_traincontrols", false)
		|| StrEqual(classname, "func_vehicleclip", false) || StrEqual(classname, "func_traincontrols", false)
		|| StrEqual(classname, "func_water", false) || StrEqual(classname, "func_water_analog", false))
	{
		return (true);
	}
	
	return (false);
}

stock bool:makeexplosion2(attacker = 0, inflictor = -1, const Float:attackposition[3], const String:weaponname[] = "", magnitude = 800, radiusoverride = 0, Float:damageforce = 0.0, flags = 0){
	
	new explosion = CreateEntityByName("env_explosion");
	
	if(explosion != -1)
	{
		DispatchKeyValueVector(explosion, "Origin", attackposition);
		
		decl String:intbuffer[64];
		IntToString(magnitude, intbuffer, 64);
		DispatchKeyValue(explosion,"iMagnitude", intbuffer);
		if(radiusoverride > 0)
		{
			IntToString(radiusoverride, intbuffer, 64);
			DispatchKeyValue(explosion,"iRadiusOverride", intbuffer);
		}
		
		if(damageforce > 0.0)
			DispatchKeyValueFloat(explosion,"DamageForce", damageforce);

		if(flags != 0)
		{
			IntToString(flags, intbuffer, 64);
			DispatchKeyValue(explosion,"spawnflags", intbuffer);
		}

		if(!StrEqual(weaponname, "", false))
			DispatchKeyValue(explosion,"classname", weaponname);

		DispatchSpawn(explosion);
		if(IsClientConnectedIngame(attacker))
                {
			SetEntPropEnt(explosion, Prop_Send, "m_hOwnerEntity", attacker);
		        new clientTeam = GetEntProp(attacker, Prop_Send, "m_iTeamNum");
                        SetEntProp(explosion, Prop_Send, "m_iTeamNum", clientTeam);
                }

		if(inflictor != -1)
			SetEntPropEnt(explosion, Prop_Data, "m_hInflictor", inflictor);

			
		AcceptEntityInput(explosion, "Explode");
		AcceptEntityInput(explosion, "Kill");
		
		return (true);
	}
	else
		return (false);
}

stock ResizePlayer(const client, const Float:fScale = 0.0)
{
	if (client == 0)
	{
		ReplyToCommand(client, "\x05[SM]\x01 %t", "Unable to target");
		return;
	}

	if (fScale == 0.0)
	{
		if (g_fClientCurrentScale[client] != g_fClientLastScale[client])
		{
			SetEntPropFloat(client, Prop_Send, "m_flModelScale", g_fClientLastScale[client]);
			//SetEntPropFloat(client, Prop_Send, "m_flStepSize", 18.0 * g_fClientLastScale[client]);
			g_fClientCurrentScale[client] = g_fClientLastScale[client];
		}
		else
		{
			SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.0);
			//SetEntPropFloat(client, Prop_Send, "m_flStepSize", 18.0);
			g_fClientCurrentScale[client] = 1.0;
		}
	}
	else
	{
		if (fScale != 1.0)
		{
			g_fClientLastScale[client] = fScale;
		}
		SetEntPropFloat(client, Prop_Send, "m_flModelScale", fScale);
		//SetEntPropFloat(client, Prop_Send, "m_flStepSize", 18.0 * fScale);
		g_fClientCurrentScale[client] = fScale;
	}
}

stock ResizePlayerHead(const client, const Float:fScale = 0.0)
{
	if (client == 0)
	{
		ReplyToCommand(client, "\x05[SM]\x01 %t", "Unable to target");
		return;
	}

	if (fScale == 0.0)
	{
		if (g_fClientCurrentHeadScale[client] != g_fClientLastHeadScale[client])
		{
			//SetEntPropFloat(client, Prop_Send, "m_flHeadScale", g_fClientLastHeadScale[client]);
			g_fClientCurrentHeadScale[client] = g_fClientLastHeadScale[client];
		}
		else
		{
			//SetEntPropFloat(client, Prop_Send, "m_flHeadScale", 1.0);
			g_fClientCurrentHeadScale[client] = 1.0;
		}
	}
	else
	{
		if (fScale != 1.0)
		{
			g_fClientLastHeadScale[client] = fScale;
		}
		//SetEntPropFloat(client, Prop_Send, "m_flHeadScale", fScale);
		g_fClientCurrentHeadScale[client] = fScale;
	}
}

stock Normalizar(client)
{
	if (g_Zombie[client])
	{
		g_Zombie[client] = false;
	}
	if (g_Batman[client])
	{
		g_Batman[client] = false;
	}
	if (g_NoMuerto[client])
	{
		g_NoMuerto[client] = false;
	}
	if (g_Medic[client])
	{
		g_Medic[client] = false;
	}
	if (g_cosa[client])
	{
		g_cosa[client] = false;
	}
	if (g_Santa[client])
	{
		g_Santa[client] = false;
	}
	if (g_Monster[client])
	{
		g_Monster[client] = false;
	}
	if (g_Amor[client])
	{
		g_Amor[client] = false;
	}
	if (g_Robot[client])
	{
		g_Robot[client] = false;
	}
	if (g_Ironman[client])
	{
		g_Ironman[client] = false;
	}
	if (g_Paloma[client])
	{
		g_Paloma[client] = false;
		SetEntityMoveType(client, MOVETYPE_WALK);
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			SetEntityModel(client, "models/player/techknow/prison/leet_p.mdl");
		}
		if (GetClientTeam(client) == CS_TEAM_CT)
		{
			SetEntityModel(client, "models/player/elis/po/police.mdl");
		}		
	}
	if (g_Fantasma[client])
	{
		g_Fantasma[client] = false;
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);
		SetEntityMoveType(client, MOVETYPE_WALK);
	}
	if (g_Gallina[client])
	{
		g_Gallina[client] = false;
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			SetEntityModel(client, "models/player/techknow/prison/leet_p.mdl");
		}
		if (GetClientTeam(client) == CS_TEAM_CT)
		{
			SetEntityModel(client, "models/player/elis/po/police.mdl");
		}		
	}
	if (g_Godmode[client])
	{
		g_Godmode[client] = false;
	}
	if (g_AmmoInfi[client])
	{
		g_AmmoInfi[client] = false;
	}
	if (g_Noweapons[client])
	{
		g_Noweapons[client] = false;
	}
	if (g_Bicho[client])
	{
		g_Bicho[client] = false;
	}
	if (g_Soldado[client])
	{
		g_Soldado[client] = false;
	}
	if (g_Saltador[client])
	{
		g_Saltador[client] = false;
	}
	if (g_Cloak[client])
	{
		g_Cloak[client] = false;
	}		
	if (g_RapidFire[client])
	{
		g_RapidFire[client] = false;
	}	
	if (g_Explosiva[client])
	{
		g_Explosiva[client] = false;
	}	
	if (g_Bomba[client])
	{
		g_Bomba[client] = false;
	}
	if (g_Smith[client])
	{
		g_Smith[client] = false;
	}
	if (g_Jack[client])
	{
		g_Jack[client] = false;
		if (g_hTimer[client] != INVALID_HANDLE)
		{
			CloseHandle(g_hTimer[client]);
			g_hTimer[client] = INVALID_HANDLE;
		} 
	}
	if (g_Groudon[client])
	{
		g_Groudon[client] = false;
	}
	if (g_Pikachu[client])
	{
		g_Pikachu[client] = false;
	}
	if (g_Spiderman[client])
	{
		g_Spiderman[client] = false;
		//CloseHandle(TraceRay);
		SetEntityGravity(client, 1.0);
		
	}
	if (g_Goku[client])
	{
		g_Goku[client] = false;
		
	}
	
	if (g_Predator[client])
	{
		
		g_Predator[client] = false;
		
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);
		
		for(new i = 0; i < 4; i++)
		{
			new weapon = GetPlayerWeaponSlot(client, i);
			if (weapon != -1)
			{
				SetEntityRenderMode(weapon,  RENDER_NORMAL);
				SetEntityRenderColor(weapon, 255, 255, 255, 255);
			}
		}
		
	}
	if (g_Pene[client])
	{
		g_Pene[client] = false;
		if(g_Attachments[client] != 0 && IsValidEdict(g_Attachments[client]))
		{
			RemoveEdict(g_Attachments[client]);
			g_Attachments[client]=0;
		}
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
	if (g_Trainer[client])
	{
		g_Trainer[client] = false;

	}
	if (g_Reina[client])
	{
		g_Reina[client] = false;

	}	

	MisilCantidad[client] = 0;
	g_PlasmaCantidad[client] = 0;
	g_Rayos[client] = 0;
	g_Lasers[client] = 0;
	g_Terremotos[client] = 0;
	g_Regalos[client] = 0;
	flameAmount[client] = 0;
	SetClientThrowingKnives(client, 0);	
	ResizePlayer(client, 1.0);
	g_Usando[client] = false;
}

stock RemoveWeapons(client)
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
}

stock HideWeapons(client)
{
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