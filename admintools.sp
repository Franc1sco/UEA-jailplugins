#include <sourcemod>
#include <sdktools>
#include <basecomm>
#include <cstrike>
#include <capitan>
#include <morecolors>
#include <smlib>

#pragma semicolon 1


public Plugin:myinfo =
{
	name = "Admin Tools",
	author = "Xilver266 Steam: donchopo",
	description = "Chat de admins y admin tags para el Clan UEA",
	version = "1.2",
	url = "www.servers-cfg.foroactivo.com"
};

public OnPluginStart()
{
	RegConsoleCmd("say", HookSay);
	HookEvent("player_spawn", PlayerSpawn);
}

public Action:HookSay(client, args)
{
	if(client == 0 || !IsClientInGame(client))
		return Plugin_Continue;
		

	decl String:SayText[512];
	GetCmdArgString(SayText,sizeof(SayText));
	
	StripQuotes(SayText);
	
	if(SayText[0] == '@' || SayText[0] == '/' || SayText[0] == '!' || !SayText[0])
		return Plugin_Continue;
	

	new String:temp[32];
	new AdminId:AdmId = GetUserAdmin(client);
	new count = GetAdminGroupCount(AdmId);
	for (new s = 0; s <= count; s++)
	{
		if (GetAdminGroup(AdmId, s, temp, sizeof(temp)))
		{
			if (Capitan_Obtener() != client)
			{
				if (StrEqual("Lider", temp))
				{
					PrintToChatAll("\x07ff6600[ADMIN] \x07%06X%N:\x07ffffff %s", CGetTeamColor(client), client, SayText);	
					return Plugin_Handled;
				}
				else if (StrEqual("SuperAdmin UEA", temp))
				{
					PrintToChatAll("\x07cf0000[ADMIN] \x07%06X%N:\x07ffffff %s", CGetTeamColor(client), client, SayText);	
					return Plugin_Handled;
				}			
				else if (StrEqual("Admin CEO", temp))
				{
					PrintToChatAll("\x070090ff[ADMIN] \x07%06X%N:\x07ffffff %s", CGetTeamColor(client), client, SayText);
					return Plugin_Handled;
				}
				else if (StrEqual("Admin UEA", temp))
				{
					PrintToChatAll("\x0725A312[ADMIN] \x07%06X%N:\x07ffffff %s", CGetTeamColor(client), client, SayText);
					return Plugin_Handled;
				}
			}
		}
	}	
	return Plugin_Continue;
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	PonerTag(client);
}

public OnClientPostAdminCheck(client) 
{
	if (Client_IsValid(client) && IsClientInGame(client))
	{
		PonerTag(client);
	}
} 

PonerTag(client)
{
	new String:temp[32];
	new AdminId:AdmId = GetUserAdmin(client);
	new count = GetAdminGroupCount(AdmId);
	for (new s = 0; s <= count; s++)
	{
		if (GetAdminGroup(AdmId, s, temp, sizeof(temp)))
		{
			if (StrEqual("Admin UEA", temp))
			{
				// new String:buffer[32];
				// new String:clantag[32] = "UEA| ";
				// Format(buffer, sizeof(buffer), "%s", clantag);
				CS_SetClientClanTag(client, "UEA |");
			}
			else if (StrEqual("Admin CEO", temp))
			{
				CS_SetClientClanTag(client, "CEO |");
			}
			else if (StrEqual("SuperAdmin UEA", temp))
			{
				CS_SetClientClanTag(client, "UEA |");
			}
			else if (StrEqual("Lider", temp))
			{
				CS_SetClientClanTag(client, "UEA |");
			}			
		}
	}
} 