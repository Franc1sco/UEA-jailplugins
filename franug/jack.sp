

public Action:CheckClientOrg(Handle:Timer, any:Client) 
{

    if (IsValidClient(Client) && GetClientTeam(Client) != 1 && IsPlayerAlive(Client))
    {

        if(g_Jack[Client])
        {
            decl Float:MedicOrigin[3],Float:TargetOrigin[3], Float:Distance;
            GetClientAbsOrigin(Client, MedicOrigin);
            for (new X = 1; X <= MaxClients; X++)
            {
                if(X != Client && IsValidClient(X) && GetClientTeam(X) != 1 && IsPlayerAlive(X) && GetClientTeam(Client) != GetClientTeam(X)) 
                {
                    GetClientAbsOrigin(X, TargetOrigin);
                    Distance = GetVectorDistance(TargetOrigin,MedicOrigin);
                    if(Distance <= 500.0)
                        Miedo(X);
                }
            }
        }
    }
    return Plugin_Continue;
}  


public Miedo(client) 
{ 
                CongelarCliente(client);

               	new miedo = GetRandomInt(1, 5);
		switch (miedo)
		{
			case 1:
			{
			   new Float:pos[3];
			   GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
			   EmitSoundToAll("franug/scream_01.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
			case 2:
			{
			   new Float:pos[3];
			   GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
			   EmitSoundToAll("franug/scream_02.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
			case 3:
			{
			   new Float:pos[3];
			   GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
			   EmitSoundToAll("franug/scream_03.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
			case 4:
			{
			   new Float:pos[3];
			   GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
			   EmitSoundToAll("franug/scream_04.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
			case 5:
			{
			   new Float:pos[3];
			   GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
			   EmitSoundToAll("franug/scream_05.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
                }
}