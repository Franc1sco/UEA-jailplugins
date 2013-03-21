#include <sourcemod>
#include <sdktools>

#pragma semicolon 1

//Definitions:
#define Speed 200


new bool:g_Spiderman[MAXPLAYERS+1] = {false, ...};

//Prethink:
public OnGameFrame2()
{

	//Declare:
	decl MaxPlayers;

	//Initialize:
	MaxPlayers = GetMaxClients();

	//Loop:
	for(new X = 1; X < MaxPlayers; X++)
	{

		//Connected:
		if(IsClientConnected(X) && IsClientInGame(X))
		{

			//Alive:
			if(IsPlayerAlive(X))
			{

                          if(IsPlayerAlive(X))
			  {
                            
                            if(g_Spiderman[X])
			    {

				//Wall?
				new bool:NearWall = false;

				//Circle:
				for(new AngleRotate = 0; AngleRotate < 360; AngleRotate += 30)
				{

					//Declare:
					decl Handle:TraceRay;
					decl Float:StartOrigin[3], Float:Angles[3];

					//Initialize:
					Angles[0] = 0.0;
					Angles[2] = 0.0;
					Angles[1] = float(AngleRotate);
					GetClientEyePosition(X, StartOrigin);

					//Ray:
					TraceRay = TR_TraceRayEx(StartOrigin, Angles, MASK_SOLID, RayType_Infinite);

					//Collision:
					if(TR_DidHit(TraceRay))
					{

						//Declare:
						decl Float:Distance;
						decl Float:EndOrigin[3];

						//Retrieve:
						TR_GetEndPosition(EndOrigin, TraceRay);

						//Distance:
						Distance = (GetVectorDistance(StartOrigin, EndOrigin));

						//Allowed:
						if(Distance < 50) NearWall = true;

					}

					//Close:
					CloseHandle(TraceRay);

				}

				//Ceiling:
				decl Handle:TraceRay;
				decl Float:StartOrigin[3];
				new Float:Angles[3] =  {270.0, 0.0, 0.0};

				//Initialize:
				GetClientEyePosition(X, StartOrigin);

				//Ray:
				TraceRay = TR_TraceRayEx(StartOrigin, Angles, MASK_SOLID, RayType_Infinite);

				//Collision:
				if(TR_DidHit(TraceRay))
				{
					//Declare:
					decl Float:Distance;
					decl Float:EndOrigin[3];

					//Retrieve:
					TR_GetEndPosition(EndOrigin, TraceRay);

					//Distance:
					Distance = (GetVectorDistance(StartOrigin, EndOrigin));

					//Allowed:
					if(Distance < 50) NearWall = true;
				}

				//Close:
				CloseHandle(TraceRay);

				//Near:
				if(NearWall)
				{ 
					
					//Almost Zero:
					SetEntityGravity(X, Pow(Pow(100.0, 3.0), -1.0));

					//Buttons:
					decl ButtonBitsum;
					ButtonBitsum = GetClientButtons(X);

					//Origin:
					decl Float:ClientOrigin[3];
					GetClientAbsOrigin(X, ClientOrigin);

					//Angles:
					decl Float:ClientEyeAngles[3];
					GetClientEyeAngles(X, ClientEyeAngles);

					//Declare:
					decl Float:VeloX, Float:VeloY, Float:VeloZ;

					//Initialize:
					VeloX = (Speed * Cosine(DegToRad(ClientEyeAngles[1])));
					VeloY = (Speed * Sine(DegToRad(ClientEyeAngles[1])));
					VeloZ = (Speed * Sine(DegToRad(ClientEyeAngles[0])));


					//Jumping:
					if(ButtonBitsum & IN_JUMP)
					{

						//Stop:
						new Float:Velocity[3] = {0.0, 0.0, 0.0};
						TeleportEntity(X, ClientOrigin, NULL_VECTOR, Velocity);
					}

					//Forward:
					if(ButtonBitsum & IN_FORWARD)
					{

						//Forward:
						new Float:Velocity[3];
						Velocity[0] = VeloX;
						Velocity[1] = VeloY;
						Velocity[2] = (VeloZ - (VeloZ * 2));
						TeleportEntity(X, ClientOrigin, NULL_VECTOR, Velocity);
					}

					//Backward:
					else if(ButtonBitsum & IN_BACK)
					{

						//Backward:
						new Float:Velocity[3];
						Velocity[0] = (VeloX - (VeloX * 2));
						Velocity[1] = (VeloY - (VeloY * 2));
						Velocity[2] = VeloZ;
						TeleportEntity(X, ClientOrigin, NULL_VECTOR, Velocity);
					}

					//Null:
					else 
					{

						//Stop:
						new Float:Velocity[3] = {0.0, 0.0, 0.0};
						TeleportEntity(X, ClientOrigin, NULL_VECTOR, Velocity);
					}

				}

				//Default:
				else SetEntityGravity(X, 1.0);	
                          }	
			}

		}

	}

}

public FreezeClient(client)
{
	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntityRenderColor(client, 0, 128, 255, 192);
	CreateTimer(5.0, UnfreezeClient, client);
}

public UnfreezeClient(Handle:timer, any:client)
{
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
		
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}

public OnMapStart14()
{

        AddFileToDownloadsTable("models/player/techknow/spiderman/spiderman.dx80.vtx");
        AddFileToDownloadsTable("models/player/techknow/spiderman/spiderman.dx90.vtx");
        AddFileToDownloadsTable("models/player/techknow/spiderman/spiderman.mdl");
        AddFileToDownloadsTable("models/player/techknow/spiderman/spiderman.phy");
        AddFileToDownloadsTable("models/player/techknow/spiderman/spiderman.sw.vtx");
        AddFileToDownloadsTable("models/player/techknow/spiderman/spiderman.vvd");




        AddFileToDownloadsTable("materials/models/player/techknow/spiderman/red.vmt");
        AddFileToDownloadsTable("materials/models/player/techknow/spiderman/red.vtf");
        AddFileToDownloadsTable("materials/models/player/techknow/spiderman/blue.vmt");
        AddFileToDownloadsTable("materials/models/player/techknow/spiderman/blue.vtf");
        AddFileToDownloadsTable("materials/models/player/techknow/spiderman/black.vmt");
        AddFileToDownloadsTable("materials/models/player/techknow/spiderman/black.vtf");
        AddFileToDownloadsTable("materials/models/player/techknow/spiderman/white.vmt");
        AddFileToDownloadsTable("materials/models/player/techknow/spiderman/white.vtf");
        AddFileToDownloadsTable("materials/models/player/techknow/spiderman/logo.vmt");
        AddFileToDownloadsTable("materials/models/player/techknow/spiderman/logo.vtf");

	PrecacheModel("models/player/techknow/spiderman/spiderman.mdl");

}

public OnPluginStart16()
{
    HookEvent("player_hurt", Event_hurt2);
}


public Action:Event_hurt2(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (attacker == 0)
	{
		return;
	}
	

	if (g_Spiderman[attacker])
	{
          if (GetClientTeam(attacker) != GetClientTeam(client))
          {
             FreezeClient(client);
	  }
        }
}

public OnClientPutInServer2(client)
{
   SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage2);
}


public Action:OnTakeDamage2(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
      if (g_Spiderman[victim])
      {
               damage = damage * 0.3;
               return Plugin_Changed;
      }

      return Plugin_Continue;
}


