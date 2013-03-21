/* 
	if (g_RondaEspecial)
	{
		if (g_ZombieClient[attacker])
		{
			new Float:playerloc[3];
			GetClientAbsOrigin(victim, playerloc[3]);
			damage = damage + 999999;
			CS_SwitchTeam(victim, "2");
			CS_RespawnPlayer(victim);
			TeleportEntity(victim, playerloc[3]);
			ConvertirZombie(victim);
		}
		else if (g_ZombieClient[victim])
		{
			if (hitgroup != 1)
			{
				damage = damage * 0;
			}
			else
			{
				damage = damage + 99999;
			}
		}
	}

ConvertirZombie(client)
{
	SetEntityModel(client, "ruta");
	g_ZombieClient[client] = true;
	
	new wepIdx;
	for (new i = 0; i < 6; i++)
	{
		while ((wepIdx = GetPlayerWeaponSlot(client, i)) != -1)
		{
			RemovePlayerItem(client, wepIdx);
		}
	}
	GivePlayerItem(client, "weapon_knife");
	g_ZombieClient[client] = true;
} */

