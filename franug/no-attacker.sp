
//new const String:CTBOT[] = "Un CT cualquiera";
//new CtBotID;
new const String:TTBOT[] = "www.uea-clan.foroactivo.com";
new TtBotID;

//new CT_ID;
//new T_ID;

//#define TEAM_1    2
//#define TEAM_2    3

public OnPluginStartNOT()
{


        CreateConVar("sm_Esconder-Atacante", "v2.1 by Franc1sco Steam: franug (Made in Spain)", "version del plugin", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

}

public OnMapStartNOT()
{
	CreateTimer(5.0, CreatBots, 0);
}

public Action:CreatBots(Handle:timer){
	//CreateFakeClient(CTBOT);
	CreateFakeClient(TTBOT);
	botSwitch();
}

botSwitch(){
	new mc = GetMaxClients();
	for( new i = 1; i < mc; i++ )
        {
		if( IsClientInGame(i) && IsFakeClient(i))
                {
			decl String:target_name[50];
			GetClientName( i, target_name, sizeof(target_name) );
			if(StrEqual(target_name, TTBOT))
                        {
				TtBotID = i;
 
			}
		}
	}
}


