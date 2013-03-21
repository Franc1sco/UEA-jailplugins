#define SOUND_FREEZE_EXPLODE	"ui/freeze_cam.wav"

#define FreezeColor	{75,75,255,255}

new g_Terremotos[MAXPLAYERS+1] = 0;


public OnMapStartPo() 
{
	
	PrecacheSound(SOUND_FREEZE_EXPLODE);
}

public Action:CheckClientOrgG(any:Client) 
{

    if (IsValidClient(Client) && GetClientTeam(Client) != 1 && IsPlayerAlive(Client))
    {


            decl Float:MedicOriginG[3],Float:TargetOriginG[3], Float:DistanceG;
            GetClientAbsOrigin(Client, MedicOriginG);
            for (new X = 1; X <= MaxClients; X++)
            {
                if(X != Client && IsValidClient(X) && GetClientTeam(X) != 1 && IsPlayerAlive(X) && GetClientTeam(Client) != GetClientTeam(X)) 
                {
                    GetClientAbsOrigin(X, TargetOriginG);
                    DistanceG = GetVectorDistance(TargetOriginG,MedicOriginG);
                    if(DistanceG <= 500.0)
                    { 
                        DealDamage(X,50,Client,DMG_SLASH," ");
                        Shake(X, AMP_SHAKEG, DUR_SHAKEG);
                    }
                }
            }
            EmitSoundToAll("ambient/explosions/exp4.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, MedicOriginG);
            if(g_Groudon[Client])
            {
                   CreateTimer(GetConVarFloat(g_Cvar_Delay), DarTerremoto, Client);
            }
            //new Float:iVecg[ 3 ];
            //GetClientAbsOrigin( Client, Float:MedicOriginG );

	    //TE_SetupExplosion( MedicOriginG, g_ExplosionSprite, 5.0, 1, 0, 50, 40, iNormal );
	    //TE_SendToAll();

	    TE_SetupSmoke( MedicOriginG, g_SmokeSprite, 10.0, 3 );
	    TE_SendToAll();

            g_Terremotos[Client] -= 1;
    }
    return Plugin_Continue;
}  


public SDKHook_Touch_Callback(ent1, ent2)
{

    if (!IsValidEntity(ent1))
        return;



    new attacker = GetEntPropEnt(ent1, Prop_Send, "m_hOwnerEntity");



    if (IsValidClient(ent2) && IsValidClient(attacker))
    {
      if(GetClientTeam(attacker) != GetClientTeam(ent2))
      {
           if(g_Groudon[ent2] || g_Pikachu[ent2])
           {
                DealDamage(ent2,99999,attacker,DMG_SLASH," ");
                g_iCredits[attacker] += 5;
                PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Han capturado a un POKEMON! El capturador gana 5 creditos de premio");
                RemoveEdict(ent1);


                new Float:playerEyesg[3]; 
                GetClientEyePosition(ent2, playerEyesg);

	        TE_SetupBeamRingPoint(playerEyesg, 10.0, 600.0, g_LightningSpriter, g_HaloSprite13, 1, 10, 1.0, 5.0, 1.0, FreezeColor, 0, 0);
	        TE_SendToAll();
	        LightCreate(playerEyesg);
           }
      }
    }
} 

LightCreate(Float:Pos[3])   
{  
	new iEntity = CreateEntityByName("light_dynamic");
	DispatchKeyValue(iEntity, "inner_cone", "0");
	DispatchKeyValue(iEntity, "cone", "80");
	DispatchKeyValue(iEntity, "brightness", "1");
	DispatchKeyValueFloat(iEntity, "spotlight_radius", 150.0);
	DispatchKeyValue(iEntity, "pitch", "90");
	DispatchKeyValue(iEntity, "style", "1");

	DispatchKeyValue(iEntity, "_light", "75 75 255 255");
	DispatchKeyValueFloat(iEntity, "distance", 600.0);
	EmitSoundToAll(SOUND_FREEZE_EXPLODE, iEntity, SNDCHAN_WEAPON);
	CreateTimer(1.0, Deletepo, iEntity, TIMER_FLAG_NO_MAPCHANGE);

	DispatchSpawn(iEntity);
	TeleportEntity(iEntity, Pos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(iEntity, "TurnOn");
}

public Action:Deletepo(Handle:timer, any:entity)
{
	if(IsValidEdict(entity))
		AcceptEntityInput(entity, "kill");
}

public Action:DarTerremoto(Handle:timer, any:client)
{
 if (IsClientInGame(client) && g_Groudon[client])
 {
   	g_Terremotos[client] += 1;
 }
}
