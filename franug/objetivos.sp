



#define PLUGIN_VERSION "v1.1 by Franc1sco Steam: franug (Made in Spain)"



new g_Muertes[MAXPLAYERS+1];


//new Handle:Arma_Usada;
new Handle:Premio_C;

new N_Mision;

//new String: weaponIDF[30];

public OnPluginStart40()
{
	CreateConVar("sm_Franug-MisionesDeJail", PLUGIN_VERSION, "version del plugin", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

        //Arma_Usada = CreateConVar("sm_armao", "0", "Determita que arma se usa para los objetivos");
        Premio_C = CreateConVar("sm_premioc", "10", "Determita cuantos creditos se ganan al acabar objetivo");
}








public Action:Mision1(Handle:timer, any:client)
{


   if (IsClientInGame(client) && GetClientTeam(client) == 2)
   {


     new Handle:ScoreReportPanal=CreatePanel();

     DrawPanelItem(ScoreReportPanal, "Tienes que matar a 3 CTs con pistola USP");


     SendPanelToClient(ScoreReportPanal, client, Handler_MyPanel, 15);

     CloseHandle(ScoreReportPanal);

     g_Muertes[client] = 3;

     N_Mision = 1;


     Arma_Enuso = "usp";

   }
}

public Action:Mision2(Handle:timer, any:client)
{


   if (IsClientInGame(client) && GetClientTeam(client) == 2)
   {


     new Handle:ScoreReportPanal=CreatePanel();

     DrawPanelItem(ScoreReportPanal, "Tienes que matar a 3 CTs con AWP");


     SendPanelToClient(ScoreReportPanal, client, Handler_MyPanel, 15);

     CloseHandle(ScoreReportPanal);

     g_Muertes[client] = 3;


     Arma_Enuso = "awp";

     N_Mision = 2;

   }
}

public Action:Mision3(Handle:timer, any:client)
{


   if (IsClientInGame(client) && GetClientTeam(client) == 2)
   {


     new Handle:ScoreReportPanal=CreatePanel();

     DrawPanelItem(ScoreReportPanal, "Tienes que matar a 3 CTs con cuchillo");


     SendPanelToClient(ScoreReportPanal, client, Handler_MyPanel, 15);

     CloseHandle(ScoreReportPanal);

     g_Muertes[client] = 3;


     Arma_Enuso = "knife";

     N_Mision = 3;

   }
}

public Action:Mision4(Handle:timer, any:client)
{


   if (IsClientInGame(client) && GetClientTeam(client) == 2)
   {


     new Handle:ScoreReportPanal=CreatePanel();

     DrawPanelItem(ScoreReportPanal, "Tienes que matar a 2 CTs con una sola Granada");



     SendPanelToClient(ScoreReportPanal, client, Handler_MyPanel, 15);

     CloseHandle(ScoreReportPanal);

     g_Muertes[client] = 2;


     Arma_Enuso = "hegrenade";

     N_Mision = 4;

   }
}

public Action:Mision5(Handle:timer, any:client)
{


   if (IsClientInGame(client) && GetClientTeam(client) == 2)
   {


     new Handle:ScoreReportPanal=CreatePanel();

     DrawPanelItem(ScoreReportPanal, "Tienes que matar a 3 CTs con granadas");



     SendPanelToClient(ScoreReportPanal, client, Handler_MyPanel, 15);

     CloseHandle(ScoreReportPanal);

     g_Muertes[client] = 3;


     Arma_Enuso = "hegrenade";

     N_Mision = 5;

   }
}

public Action:Mision6(Handle:timer, any:client)
{


   if (IsClientInGame(client) && GetClientTeam(client) == 2)
   {


     new Handle:ScoreReportPanal=CreatePanel();

     DrawPanelItem(ScoreReportPanal, "Tienes que matar a 2 CTs con scout");



     SendPanelToClient(ScoreReportPanal, client, Handler_MyPanel, 15);

     CloseHandle(ScoreReportPanal);

     g_Muertes[client] = 2;


     Arma_Enuso = "scout";

     N_Mision = 6;

   }
}

public Action:Mision7(Handle:timer, any:client)
{


   if (IsClientInGame(client) && GetClientTeam(client) == 2)
   {


     new Handle:ScoreReportPanal=CreatePanel();

     DrawPanelItem(ScoreReportPanal, "Tienes que matar a 4 CTs con cualquier arma");



     SendPanelToClient(ScoreReportPanal, client, Handler_MyPanel, 15);

     CloseHandle(ScoreReportPanal);

     g_Muertes[client] = 4;


     Arma_Enuso = "scout";

     N_Mision = 7;

   }
}

public Action:Mision8(Handle:timer, any:client)
{


   if (IsClientInGame(client) && GetClientTeam(client) == 2)
   {


     new Handle:ScoreReportPanal=CreatePanel();

     DrawPanelItem(ScoreReportPanal, "Tienes que matar a 1 CT con cegadora");


     SendPanelToClient(ScoreReportPanal, client, Handler_MyPanel, 15);

     CloseHandle(ScoreReportPanal);

     g_Muertes[client] = 1;


     Arma_Enuso = "flashbang";

     N_Mision = 8;

   }
}

public Action:Mision9(Handle:timer, any:client)
{


   if (IsClientInGame(client) && GetClientTeam(client) == 2)
   {


     new Handle:ScoreReportPanal=CreatePanel();

     DrawPanelItem(ScoreReportPanal, "Tienes que matar a 2 CTs con pistola p228 , pistola de aviso de CT");


     SendPanelToClient(ScoreReportPanal, client, Handler_MyPanel, 15);

     CloseHandle(ScoreReportPanal);

     g_Muertes[client] = 3;


     Arma_Enuso = "p228";

     N_Mision = 8;

   }
}

public Action:Mision10(Handle:timer, any:client)
{


   if (IsClientInGame(client) && GetClientTeam(client) == 2)
   {


     new Handle:ScoreReportPanal=CreatePanel();

     DrawPanelItem(ScoreReportPanal, "Tienes que matar a 3 CTs con cualquier arma");



     SendPanelToClient(ScoreReportPanal, client, Handler_MyPanel, 15);

     CloseHandle(ScoreReportPanal);

     g_Muertes[client] = 3;


     Arma_Enuso = "scout";

     N_Mision = 7;

   }
}

public Action:Mision11(Handle:timer, any:client)
{


   if (IsClientInGame(client) && GetClientTeam(client) == 2)
   {


     new Handle:ScoreReportPanal=CreatePanel();

     DrawPanelItem(ScoreReportPanal, "Tienes que matar a 1 CT con cegadora");


     SendPanelToClient(ScoreReportPanal, client, Handler_MyPanel, 15);

     CloseHandle(ScoreReportPanal);

     g_Muertes[client] = 1;


     Arma_Enuso = "flashbang";

     N_Mision = 11;

   }
}

public Handler_MyPanel(Handle:menu, MenuAction:action, param1, param2)
{
} 

public Action:InitGrenade(Handle:timer, any:grenade)
{
    if (!IsValidEntity(grenade))
        return;
        
        
    new client = GetEntPropEnt(grenade, Prop_Send, "m_hOwnerEntity");
    
    if (!IsValidClient(client))
        return;

    if(g_Muertes[client] > 0)
    {
      g_Muertes[client] = 2;
    }
        
}






