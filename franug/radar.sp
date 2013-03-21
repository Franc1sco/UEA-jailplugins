#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>


new g_iPlayerSpotted = -1;
new g_iBombSpotted = -1;
new g_iPlayerManager = -1;

new bool:g_RadarH[MAXPLAYERS+1] = {false, ...};

public OnPluginStart90()
{
	if ((g_iPlayerSpotted = FindSendPropOffs("CCSPlayerResource", "m_bPlayerSpotted")) == -1)
		SetFailState("Failed to find CCSPlayerResource::m_bPlayerSpotted offset");

	if ((g_iBombSpotted = FindSendPropOffs("CCSPlayerResource", "m_bBombSpotted")) == -1)
		SetFailState("Failed to find CCSPlayerResource::m_bBombSpotted offset");
	
	
}

public OnMapStart90()
{
	g_iPlayerManager = FindEntityByClassname(0, "cs_player_manager");
	
}

public OnEntityThink(entity)
{
	for (new i = 0; i <= 65; i++)
		SetEntData(g_iPlayerManager, g_iPlayerSpotted + i, true, 4, true);
	
	SetEntData(g_iPlayerManager, g_iBombSpotted, true, 4, true);
}

