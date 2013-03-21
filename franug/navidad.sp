#include <ToggleEffects>

new g_Hat[MAXPLAYERS+1] = { 0, ...};
new bool:g_bToggleEffects = false;
new Handle:g_hLookupAttachment = INVALID_HANDLE;

public OnPluginStartNavidad()
{
	HookEvent("player_spawn", PlayerSpawnNavidad);
	HookEvent("player_death", PlayerDeathNavidad);
	HookEvent("player_footstep", PlayerWalkNavidad);
	new Handle:hGameConf = LoadGameConfigFile("hats.gamedata");
	g_bToggleEffects = LibraryExists("ToggleEffects");
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "LookupAttachment");
	g_hLookupAttachment = EndPrepSDKCall();
}

public Action:PlayerSpawnNavidad(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!g_cosa[client])
	{
		CreateHat(client);
	}
	
}

public OnMapStartNavidad()
{
	AddFileToDownloadsTable("materials/models/santahat/furballs.vmt");
	AddFileToDownloadsTable("materials/models/santahat/santahat.vmt");
	AddFileToDownloadsTable("materials/models/santahat/santahat.vtf");
	AddFileToDownloadsTable("models/santahat/santahat.mdl");
	AddFileToDownloadsTable("models/santahat/santahat.phy");
	AddFileToDownloadsTable("models/santahat/santahat.vvd");
	AddFileToDownloadsTable("models/santahat/santahat.sw.vtx");
	AddFileToDownloadsTable("models/santahat/santahat.dx80.vtx");
	AddFileToDownloadsTable("models/santahat/santahat.dx90.vtx");
	PrecacheModel("models/santahat/santahat.mdl");
}

CreateHat(client)
{	
	if(!LookupAttachment(client, "forward"))
		return;
		
	if(GetClientTeam(client) == 1)
		return;

	new Float:or[3];
	new Float:ang[3];
	new Float:fForward[3];
	new Float:fRight[3];
	new Float:fUp[3];
	GetClientAbsOrigin(client,or);
	GetClientAbsAngles(client,ang);
	
	ang[0] += 0.0;
	ang[1] += 0.0;
	ang[2] += 0.0;

	new Float:fOffset[3];
	fOffset[0] = 0.0;
	fOffset[1] = -1.0;
	fOffset[2] = 6.0;

	GetAngleVectors(ang, fForward, fRight, fUp);

	or[0] += fRight[0]*fOffset[0]+fForward[0]*fOffset[1]+fUp[0]*fOffset[2];
	or[1] += fRight[1]*fOffset[0]+fForward[1]*fOffset[1]+fUp[1]*fOffset[2];
	or[2] += fRight[2]*fOffset[0]+fForward[2]*fOffset[1]+fUp[2]*fOffset[2];
	
	new ent = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(ent, "model", "models/santahat/santahat.mdl");
	DispatchKeyValue(ent, "spawnflags", "4");
	SetEntProp(ent, Prop_Data, "m_CollisionGroup", 2);
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	
	DispatchSpawn(ent);	
	AcceptEntityInput(ent, "TurnOn", ent, ent, 0);
	
	g_Hat[client] = ent;
	
	SDKHook(ent, SDKHook_SetTransmit, ShouldHide);
	
	TeleportEntity(ent, or, ang, NULL_VECTOR); 
	
	SetVariantString("!activator");
	AcceptEntityInput(ent, "SetParent", client, ent, 0);
	
	SetVariantString("forward");
	AcceptEntityInput(ent, "SetParentAttachmentMaintainOffset", ent, ent, 0);
}

public Action:PlayerDeathNavidad(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (g_Hat[client] != 0 && IsValidEdict(g_Hat[client]))
	{
		AcceptEntityInput(g_Hat[client], "Kill");
		SDKUnhook(g_Hat[client], SDKHook_SetTransmit, ShouldHide);
		g_Hat[client] = 0;
	}
}

public Action:PlayerWalkNavidad(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (g_cosa[client])
	{
		AcceptEntityInput(g_Hat[client], "Kill");
		SDKUnhook(g_Hat[client], SDKHook_SetTransmit, ShouldHide);
		g_Hat[client] = 0;
	}	
}

public Action:ShouldHide(ent, client)
{
	if(g_bToggleEffects)
		if(!ShowClientEffects(client))
			return Plugin_Handled;
			
	if(ent == g_Hat[client])
		return Plugin_Handled;
			
	if(IsClientInGame(client))
		if(GetEntProp(client, Prop_Send, "m_iObserverMode") == 4 && GetEntPropEnt(client, Prop_Send, "m_hObserverTarget")>=0)
			if(ent == g_Hat[GetEntPropEnt(client, Prop_Send, "m_hObserverTarget")])
				return Plugin_Handled;
	
	return Plugin_Continue;
}

stock LookupAttachment(client, String:point[])
{
    if(g_hLookupAttachment==INVALID_HANDLE) return 0;
    if( client<=0 || !IsClientInGame(client) ) return 0;
    return SDKCall(g_hLookupAttachment, client, point);
}

public OnClientPostAdminCheckNavidad(client)
{
	PrintToChat(client, "La Jail Especial te desea \x03FELIZ NAVIDAD");
	CreateTimer(300.0, MensajeNavidad, client, TIMER_REPEAT);
}

public Action:MensajeNavidad(Handle:timer, any:client)
{
	if (IsClientInGame(client))
	{
		PrintToChat(client, "La Jail Especial te desea \x03FELIZ NAVIDAD");
	}
}