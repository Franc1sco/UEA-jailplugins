public Tocada(tocada, tocador)
{
    if (IsValidClient(tocada) && IsValidClient(tocador))
    {
		if(GetClientTeam(tocada) != GetClientTeam(tocador))
		{
		    if(g_Amor[tocada])
		    {
				if (g_Pene[tocador]) 
				{
					DealDamage(tocada,169,tocador,DMG_POISON," ");
				}
				else 
				{
					DealDamage(tocada,1,tocador,DMG_POISON," ");
				}
				PrintHintText(tocada, "El jugador %N te ha dado amor", tocador);
				PrintHintText(tocador, "Has dado amor a %N", tocada);
		    }
		}
    }
} 