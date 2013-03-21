
new Handle:Dados_Usos2;
new Handle:Dados_Usados2;


public Action:NadaDeNadaz(Handle:timer, Handle:pack2)
{
   //unpack into
   new client;
   new suerte;


   ResetPack(pack2);
   client = ReadPackCell(pack2);
   suerte = ReadPackCell(pack2);

   if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
   {

     PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! No te ha tocado NADA! sigue probando!", suerte);
     g_Usando[client] = false;
   }
}

public Action:OpcionNumero1z(Handle:timer, Handle:pack2)
{
   //unpack into
   new client;
   new suerte;
   //new antesusados;
   //new Dados_Usos1;
//   new Dados_Usados1;


   ResetPack(pack2);
   client = ReadPackCell(pack2);
   suerte = ReadPackCell(pack2);
   //antesusados = ReadPackCell(pack2);
   //Dados_Usos1 = GetConVarInt(Dados_Usos);
//   Dados_Usados1 = GetConVarInt(Dados_Usados);
   if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
   {

     GivePlayerItem(client, "item_kevlar");

     //PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Le ha tocado algo a alguien! han tocado %i de %i premios.", antesusados, Dados_Usos1);
     g_Usando[client] = false;
     PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado una ARMADURA!", suerte);
   }
}

public Action:OpcionNumero2z(Handle:timer, Handle:pack2)
{
   //unpack into
   new client;
   new suerte;
   //new antesusados;
   //new Dados_Usos1;
//   new Dados_Usados1;


   ResetPack(pack2);
   client = ReadPackCell(pack2);
   suerte = ReadPackCell(pack2);
   //antesusados = ReadPackCell(pack2);
   //Dados_Usos1 = GetConVarInt(Dados_Usos);
//   Dados_Usados1 = GetConVarInt(Dados_Usados);

   if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
   {

     SetEntityHealth(client, 250);

     //PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Le ha tocado algo a alguien! han tocado %i de %i premios.", antesusados, Dados_Usos1);
     g_Usando[client] = false;
     PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! te ha tocado 250 de vida!", suerte);
   }
}

public Action:OpcionNumero3z(Handle:timer, Handle:pack2)
{
   //unpack into
   new client;
   new suerte;
   //new antesusados;
   //new Dados_Usos1;
//   new Dados_Usados1;


   ResetPack(pack2);
   client = ReadPackCell(pack2);
   suerte = ReadPackCell(pack2);
   //antesusados = ReadPackCell(pack2);
   //Dados_Usos1 = GetConVarInt(Dados_Usos);
//   Dados_Usados1 = GetConVarInt(Dados_Usados);

   if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
   {

     SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.3);

     //PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Le ha tocado algo a alguien! han tocado %i de %i premios.", antesusados, Dados_Usos1);
     g_Usando[client] = false;
     PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! ahora corres mas veloz de lo normal!", suerte);
   }
}

public Action:OpcionNumero4z(Handle:timer, Handle:pack2)
{
   //unpack into
   new client;
   new suerte;
   //new antesusados;
   //new Dados_Usos1;
//   new Dados_Usados1;


   ResetPack(pack2);
   client = ReadPackCell(pack2);
   suerte = ReadPackCell(pack2);
   //antesusados = ReadPackCell(pack2);
   //Dados_Usos1 = GetConVarInt(Dados_Usos);
//   Dados_Usados1 = GetConVarInt(Dados_Usados);
   if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
   {
     GivePlayerItem(client, "weapon_flashbang");
     GivePlayerItem(client, "weapon_flashbang");

     //PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Le ha tocado algo a alguien! han tocado %i de %i premios.", antesusados, Dados_Usos1);
     g_Usando[client] = false;
     PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado DOS CEGADORAS!", suerte);
   }
}

public Action:OpcionNumero5z(Handle:timer, Handle:pack2)
{
   //unpack into
   new client;
   new suerte;
   //new antesusados;
   //new Dados_Usos1;
//   new Dados_Usados1;


   ResetPack(pack2);
   client = ReadPackCell(pack2);
   suerte = ReadPackCell(pack2);
   //antesusados = ReadPackCell(pack2);
   //Dados_Usos1 = GetConVarInt(Dados_Usos);
//   Dados_Usados1 = GetConVarInt(Dados_Usados);

   if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
   {
     SetEntityRenderMode(client, RENDER_TRANSCOLOR);
     SetEntityRenderColor(client, 255, 255, 255, 0);

     //PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Le ha tocado algo a alguien! han tocado %i de %i premios.", antesusados, Dados_Usos1);
     g_Usando[client] = false;
     PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado INVISIBILIDAD!", suerte);
   }
}

public Action:OpcionNumero6z(Handle:timer, Handle:pack2)
{
   //unpack into
   new client;
   new suerte;
   //new antesusados;
   //new Dados_Usos1;
//   new Dados_Usados1;


   ResetPack(pack2);
   client = ReadPackCell(pack2);
   suerte = ReadPackCell(pack2);
   //antesusados = ReadPackCell(pack2);
   //Dados_Usos1 = GetConVarInt(Dados_Usos);
//   Dados_Usados1 = GetConVarInt(Dados_Usados);

   if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
   {
     SetEntityModel(client, "models/props/de_train/barrel.mdl");

     //PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Le ha tocado algo a alguien! han tocado %i de %i premios.", antesusados, Dados_Usos1);
     g_Usando[client] = false;
     PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Ahora estas disfradado de BARRIL!!!!!", suerte);
   }
}

public Action:OpcionNumero7z(Handle:timer, Handle:pack2)
{
   //unpack into
   new client;
   new suerte;
   //new antesusados;
   //new Dados_Usos1;
//   new Dados_Usados1;


   ResetPack(pack2);
   client = ReadPackCell(pack2);
   suerte = ReadPackCell(pack2);
   //antesusados = ReadPackCell(pack2);
   //Dados_Usos1 = GetConVarInt(Dados_Usos);
//   Dados_Usados1 = GetConVarInt(Dados_Usados);

   if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
   {
     GivePlayerItem(client, "weapon_m249");

     //PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Le ha tocado algo a alguien! han tocado %i de %i premios.", antesusados, Dados_Usos1);
     g_Usando[client] = false;
     PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado una AMETRALLADORA RAMBO!!!!!", suerte);
   }
}

public Action:OpcionNumero8z(Handle:timer, Handle:pack2)
{
   //unpack into
   new client;
   new suerte;
   //new antesusados;
   //new Dados_Usos1;
//   new Dados_Usados1;


   ResetPack(pack2);
   client = ReadPackCell(pack2);
   suerte = ReadPackCell(pack2);
   //antesusados = ReadPackCell(pack2);
   //Dados_Usos1 = GetConVarInt(Dados_Usos);
//   Dados_Usados1 = GetConVarInt(Dados_Usados);

   if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
   {
     g_Godmode[client] = true;
     SetEntityRenderColor(client, 0, 255, 255, 255);

     //PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Le ha tocado algo a alguien! han tocado %i de %i premios.", antesusados, Dados_Usos1);
     g_Usando[client] = false;
     PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Ahora eres INVULNERABLE durante 20 segundos!", suerte);

     CreateTimer(10.0, OpcionNumero8zb, client);
   }
}

public Action:OpcionNumero8zb(Handle:timer, any:client)
{
 if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
 {
   PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Te quedan 10 segundos de INVULNERABILIDAD!");
   CreateTimer(10.0, OpcionNumero8zc, client);
 }
}

public Action:OpcionNumero8zc(Handle:timer, any:client)
{
 if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
 {
   PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Ya no eres INVULNERABLE!");
   g_Godmode[client] = false;
   SetEntityRenderColor(client, 255, 255, 255, 255);
 }
}

public Action:OpcionNumero9z(Handle:timer, Handle:pack2)
{
   //unpack into
   new client;
   new suerte;
   //new antesusados;
   //new Dados_Usos1;
//   new Dados_Usados1;


   ResetPack(pack2);
   client = ReadPackCell(pack2);
   suerte = ReadPackCell(pack2);
   //antesusados = ReadPackCell(pack2);
   //Dados_Usos1 = GetConVarInt(Dados_Usos);
//   Dados_Usados1 = GetConVarInt(Dados_Usados);

   if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
   {
     SetEntityModel(client, "models/lduke/chicken/chicken2.mdl");

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

     //SetEntityRenderColor(client, 0, 0, 0, 255);
     GivePlayerItem(client, "weapon_knife");

     g_Gallina[client] = true;
     g_cosa[client] = true;
     g_Noweapons[client] = true;

     //PrintToChatAll("\x04[SM_Franug-JailPlugins] \x05Le ha tocado algo a alguien! han tocado %i de %i premios.", antesusados, Dados_Usos1);
     g_Usando[client] = false;
     PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Has sacado un %i! HAS GANADO! Te ha tocado ser GALLINA!!", suerte);
   }
}





