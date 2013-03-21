// DB handle
new Handle:g_hDB = INVALID_HANDLE;


// Here we are creating SQL DB
public InitDB()
{
	// SQL DB
	new String:error[255];
	g_hDB = SQLite_UseDatabase("savecredits", error, sizeof(error));
	
	if (g_hDB == INVALID_HANDLE)
		SetFailState("SQL error: %s", error);
	
	SQL_LockDatabase(g_hDB);
	SQL_FastQuery(g_hDB, "VACUUM");
	SQL_FastQuery(g_hDB, "CREATE TABLE IF NOT EXISTS savescredits_credits (steamid TEXT PRIMARY KEY, credits SMALLINT);");
	SQL_UnlockDatabase(g_hDB);
}


// Admin command that clears all player's scores
public Action:Command_Clear(admin, args)
{
	
	ClearDBQuery();
	
	ReplyToCommand(admin, "Players credits has been reset");
	
	return Plugin_Handled;
}


// Doing clearing stuff
ClearDBQuery()
{
	// Clearing SQL DB
	SQL_LockDatabase(g_hDB);
	SQL_FastQuery(g_hDB, "DELETE FROM savescredits_credits;");
	SQL_UnlockDatabase(g_hDB);
}


InsertScoreInDB(client)
{
	decl String:steamId[30];
	GetClientAuthString(client, steamId, sizeof(steamId));

	new credits = g_iCredits[client];
	

	decl String:query[200];
	Format(query, sizeof(query), "INSERT OR REPLACE INTO savescredits_credits VALUES ('%s', %d);", steamId, credits);
	SQL_TQuery(g_hDB, EmptySQLCallback, query);
}

public EmptySQLCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
		LogError("SQL Error: %s", error);
}

// Syncronize DB with score varibles
public SyncDB()
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client) && IsClientAuthorized(client))
		{
			decl String:steamId[30];
			decl String:query[200];
			
			GetClientAuthString(client, steamId, sizeof(steamId));
			new credits = g_iCredits[client];
			
			Format(query, sizeof(query), "INSERT OR REPLACE INTO savecredits_credits VALUES ('%s', %d);", steamId, credits);
			SQL_FastQuery(g_hDB, query);
		}
	}
}

// Now we need get this information back...
public GetScoreFromDB(client)
{
	
	decl String:steamId[30];
	decl String:query[200];
	
	GetClientAuthString(client, steamId, sizeof(steamId));
	Format(query, sizeof(query), "SELECT * FROM	savescredits_credits WHERE steamId = '%s';", steamId);
	SQL_TQuery(g_hDB, SetPlayerScore, query, client);
}

// ...and set player's score and cash if needed
public SetPlayerScore(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("SQL Error: %s", error);
		return;
	}
	
	if (SQL_GetRowCount(hndl) == 0)
	{
		return;
	}
	
	

	new credits = SQL_FetchInt(hndl,1);

	if (credits != 0)
	{
            g_iCredits[client] = credits;
            LogMessage("%N se le han restaurado sus %i creditos", client, credits);
	}
}