

#define SOUND_THUNDER "ambient/explosions/explode_9.wav"


new g_SmokeSpriter;

new g_Rayos[MAXPLAYERS+1] = 0;


public OnMapStartR()
{
	PrecacheSound(SOUND_THUNDER, true);
	g_SmokeSpriter = PrecacheModel("sprites/steam1.vmt");
}

public Action:CheckClientOrgRayo(Client) 
{

    if (IsValidClient(Client) && GetClientTeam(Client) != 1 && IsPlayerAlive(Client))
    {


            decl Float:MedicOriginr[3],Float:TargetOriginr[3], Float:Distancer;
            GetClientAbsOrigin(Client, MedicOriginr);
            for (new X = 1; X <= MaxClients; X++)
            {
                if(X != Client && IsValidClient(X) && GetClientTeam(X) != 1 && IsPlayerAlive(X) && GetClientTeam(Client) != GetClientTeam(X)) 
                {
                    GetClientAbsOrigin(X, TargetOriginr);
                    Distancer = GetVectorDistance(TargetOriginr,MedicOriginr);
                    if(Distancer <= 500.0)
                        Rayo(Client, X);
                }
            }
            g_Rayos[Client] -= 1;

            if(g_Pikachu[Client])
            {
                CreateTimer(GetConVarFloat(g_Cvar_Delay), DarRayo, Client);
            }
            RayoMe(Client);
    }
    return Plugin_Continue;
}  

Rayo(client, target)
{
	
	// define where the lightning strike ends
	new Float:clientpos[3];
	GetClientAbsOrigin(target, clientpos);
	clientpos[2] += 26; // increase y-axis by 26 to strike at player's chest instead of the ground
	
	// get random numbers for the x and y starting positions
	new randomx = GetRandomInt(-500, 500);
	new randomy = GetRandomInt(-500, 500);
	
	// define where the lightning strike starts
	new Float:startpos[3];
	startpos[0] = clientpos[0] + randomx;
	startpos[1] = clientpos[1] + randomy;
	startpos[2] = clientpos[2] + 800;
	
	// define the color of the strike
	new color[4] = {255, 255, 0, 255};
	
	// define the direction of the sparks
	new Float:dir[3] = {0.0, 0.0, 0.0};
	
	TE_SetupBeamPoints(startpos, clientpos, g_LightningSpriter, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, color, 3);
	TE_SendToAll();
	
	TE_SetupSparks(clientpos, dir, 5000, 1000);
	TE_SendToAll();
	
	TE_SetupEnergySplash(clientpos, dir, false);
	TE_SendToAll();
	
	TE_SetupSmoke(clientpos, g_SmokeSpriter, 5.0, 10);
	TE_SendToAll();
	
	EmitAmbientSound(SOUND_THUNDER, startpos, client, SNDLEVEL_RAIDSIREN);
	
	DealDamage(target,50,client,DMG_SLASH," ");
}


RayoMe(target)
{
	
	// define where the lightning strike ends
	new Float:clientpos[3];
	GetClientAbsOrigin(target, clientpos);
	clientpos[2] += 26; // increase y-axis by 26 to strike at player's chest instead of the ground
	
	// get random numbers for the x and y starting positions
	new randomx = GetRandomInt(-500, 500);
	new randomy = GetRandomInt(-500, 500);
	
	// define where the lightning strike starts
	new Float:startpos[3];
	startpos[0] = clientpos[0] + randomx;
	startpos[1] = clientpos[1] + randomy;
	startpos[2] = clientpos[2] + 800;
	
	// define the color of the strike
	new color[4] = {255, 255, 0, 255};
	
	// define the direction of the sparks
	new Float:dir[3] = {0.0, 0.0, 0.0};
	
	TE_SetupBeamPoints(startpos, clientpos, g_LightningSpriter, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, color, 3);
	TE_SendToAll();
	
	TE_SetupSparks(clientpos, dir, 5000, 1000);
	TE_SendToAll();
	
	TE_SetupEnergySplash(clientpos, dir, false);
	TE_SendToAll();
	
	TE_SetupSmoke(clientpos, g_SmokeSpriter, 5.0, 10);
	TE_SendToAll();
	
	EmitAmbientSound(SOUND_THUNDER, startpos, target, SNDLEVEL_RAIDSIREN);
        //EmitSoundToAll(SOUND_THUNDER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startpos);
        
}

public Action:DarRayo(Handle:timer, any:client)
{
 if (IsClientInGame(client) && g_Pikachu[client])
 {
   	g_Rayos[client] += 1;
 }
}
