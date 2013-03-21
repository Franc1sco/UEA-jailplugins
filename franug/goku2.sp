new Float:g_pos[3];


AttachTargetParticle(client)
{
    new strIParticle = CreateEntityByName("info_particle_system");
    
    new String:strName[128];
    if (IsValidEdict(strIParticle))
    {
        new Float:strflPos[3];

        GetEntPropVector(client, Prop_Send, "m_vecOrigin", strflPos);

        EmitSoundToAll("franug/aura.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, strflPos);
        
        Format(strName, sizeof(strName), "target%i", client);
        DispatchKeyValue(client, "targetname", strName);
        
        DispatchKeyValue(strIParticle, "targetname", "CSSParticle");
        DispatchKeyValue(strIParticle, "parentname", strName);
        DispatchKeyValue(strIParticle, "effect_name", "aura");
        DispatchSpawn(strIParticle);
        TeleportEntity(strIParticle, strflPos, NULL_VECTOR, NULL_VECTOR);

        SetVariantString(strName);
        AcceptEntityInput(strIParticle, "SetParent", strIParticle, strIParticle, 0);
        SetVariantString("ValveBiped.Bip01_L_Hand");
        AcceptEntityInput(strIParticle, "SetParentAttachment", strIParticle, strIParticle, 0);
        ActivateEntity(strIParticle);
        AcceptEntityInput(strIParticle, "start");
    }
}  


public Action:Tele(client)
{

	
	if( !SetTeleportEndPoint(client))
	{
		return;
	}
	

	PerformTeleport(client,g_pos);
	
		
}

SetTeleportEndPoint(client)
{
	decl Float:vAngles[3];
	decl Float:vOrigin[3];
	decl Float:vBuffer[3];
	decl Float:vStart[3];
	decl Float:Distance;
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
    //get endpoint for teleport
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
    	
	if(TR_DidHit(trace))
	{   	 
   	 	TR_GetEndPosition(vStart, trace);
		GetVectorDistance(vOrigin, vStart, false);
		Distance = -35.0;
   	 	GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		g_pos[0] = vStart[0] + (vBuffer[0]*Distance);
		g_pos[1] = vStart[1] + (vBuffer[1]*Distance);
		g_pos[2] = vStart[2] + (vBuffer[2]*Distance);
	}
	else
	{
		PrintToChat(client, "[SM] %s", "Could not teleport player");
		CloseHandle(trace);
		return false;
	}
	
	CloseHandle(trace);
	return true;
}

public bool:TraceEntityFilterPlayerXD(entity, contentsMask)
{
	return entity > GetMaxClients() || !entity;
} 

PerformTeleport(client, Float:pos[3])
{
	decl Float:partpos[3];
	
	GetClientEyePosition(client, partpos);
	partpos[2]-=20.0;	
	
	
	TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
	pos[2]+=40.0;

        EmitSoundToAll("franug/teleport.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);

	
}