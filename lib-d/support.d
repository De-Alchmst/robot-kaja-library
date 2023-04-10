public import std.regex : split, regex;
public import std.string : toStringz, fromStringz, strip, StringException, isNumeric;

////////////////////////////////////////////////////////////////////
// checks if any item in array of positions has specific position //
////////////////////////////////////////////////////////////////////
// returns index of said item or -1 if no found
int checkCollision(ushort[] positionToLookFor, ushort[][] stuffToLookIn){
	for (int i = 0; i < stuffToLookIn.length; i++)
		// not stuffToLookIn[i] == positionToLookFor, so it can work with falgs and stuff
		if (stuffToLookIn[i][0] == positionToLookFor[0] && stuffToLookIn[i][1] == positionToLookFor[1])
			return i;

	return -1;
}

////////////////////////////////////////////
// splits city into lines for map loading //
////////////////////////////////////////////
string[][] splitCity(string city){
	// get LF line ends
	// using strip to get rid of extra whitespace

	// get chunks separated by \r\n
	string[] chunks = strip(city).split(regex("\r\n"));
	string LFstring = chunks[0];

	// put them back together but with \n only
	for (ushort i = 1; i < chunks.length; i++) // start from 1 to ignore first chunk alredy assigned
		LFstring ~= "\n"~chunks[i];

	// return split by \n and , char
	string[][] rows = [];
	chunks = LFstring.split(regex("\n"));

	for (ushort i = 0; i < chunks.length; i++)
		rows ~= strip(chunks[i]).split(regex(","));

	return rows;
}

///////////////////////////////////////////////////////
// splits sctipr by lines and gets rid of whitespace //
///////////////////////////////////////////////////////
string[] splitScript(string newScript){
	string[] splitedScript;

	// split by \r\n
	string[] chunks = strip(newScript).split(regex("\r\n"));
	string LFstring = chunks[0];

	// put them back together but with \n only
	for (uint i = 1; i < chunks.length; i++) // start from 1 to ignore first chunk alredy assigned
		LFstring ~= "\n"~chunks[i];

	// split by \n
	string[] rows = LFstring.split(regex("\n"));

	for (uint i = 0; i < rows.length; i++){
		string row  = strip(rows[i]);
		if (row != "")
			splitedScript ~= row;
	}

	// return
	return splitedScript;

}

///////////////////////////////////////////////////
// generates some error message based on context // and direction of Kája for some extra diversity
///////////////////////////////////////////////////
string generateErrorMessage(string cause, byte directionOfKaja){
	switch(cause){
		// collision with walls
		case "walk into wall":
			switch (directionOfKaja){
				case 1:
					return "Kája vešel do zdi... a to není dobře.";
				case 2:
					return "Procházení zdmi ještě nebylo implementováno.";
				case 3:
					return "Hleď, nechť Kája vrazil do zdi.";
				default:
					return "Navedl jsi Káju do zdi. Ty vrahu!";
			}
			break;

		// lack of flags
		case "no flags":
			switch (directionOfKaja){
				case 1:
					return "Ať kája hledá jak chce, žádné značky tu nejsou.";
				case 2:
					return "Na zemi žádný bordel není, a to je kupodivu špatně.";
				case 3:
					return "Kde nic není, ani Smrt nebere.";
				default:
					return "Kája se pokusil sebrat vzduch. Nepovedlo se.";
			}
			break;

		// trying to place flag at home
		case "placing flags at home":
			switch (directionOfKaja){
				case 1:
					return "Dělání bordelu v domě je vyloženě zakázáno!";
				case 2:
					return "Kája vložil značku do ledničky. Teď z toho má depresi.";
				case 3:
					return "V položení značky na podlahu Kájovi brání kvetoucí kaktus. Jaká to škoda.";
				default:
					return "Kája znečisťuje jen ulice, né svůj pokoj. Buď jako Kája a ukliď si pokoj.";
			}
			break;

		// moved home to place where it alredy is
		case "moved to home":
			switch (directionOfKaja){
				case 1:
					return "Když si Kája uvědomil zbytečnost této akce, tak dostal infarkt.";
				case 2:
					return "Kája se pokusil prodat dům sám sobě, ale selhal.";
				case 3:
					return "Toto je vskutku zapeklitá situace, kterou však nepovoluji.";
				default:
					return "Dům se zde již nachízí, takže ukončuji program. Vrať se až implementuješ KDYŽ.";
			}
			break;

		// moved to place with flag
		case "flag in way of home":
			switch (directionOfKaja){
				case 1:
					return "ve výstavbě domu překáží nějaká skládka.";
				case 2:
					return "Na Káju je tu až moc velký binec.";
				case 3:
					return "Výhružně stojící značka odmítá prodat svůj pozemek.";
				default:
					return "Zdá se, že je obtížné vykreslovat jak značky, tak domy na stejném místě.";
			}
			break;

		// attempt to build wall at other wall or out of bounds
		case "build at wall":
			switch (directionOfKaja){
				case 1:
					return "Zdi bohužel mohou dosahovat pouze omezené výšky.";
				case 2:
					return "Vypadá to, že se zde již jedna zeď nachází. Běž si stavět jinam!";
				case 3:
					return "Kája se pokusil nacpat dvě zdi do sebe. Nějak se mu přitom podařilo stvořit černou díru a zničit svět.";
				default:
					return "Hleď! Nechť zeď tu již stojí.";
			}
			break;

		// attempt to build wall at flag
		case "build at flag":
			switch (directionOfKaja){
				case 1:
					return "Kája se pokusil postavit zeď na značce, ale nepovedlo se mu to.";
				case 2:
					return "Bohužel se kvůli přílišnému bordelu na zemi nepodařilo Kájovi získat stavební povolení.";
				case 3:
					return "Ač by zeď na značce dozajista vypadala esteticky, tato verze Kájy tuto možnost nepodporuje.";
				default:
					return "Práce v nečistém prostředí je zakázána!";
			}
			break;

		// attempt to build in home
		case "build in home":
			switch (directionOfKaja){
				case 1:
					return "Zdá se, že tento dům již obsahuje dostatek zdí.";
				case 2:
					return "Kája postavil zeď v domě. Teď se nemá jak dostat ven.";
				case 3:
					return "Kája zazdil ledničku. Teď má hlad.";
				default:
					return "Zeď je sice moc hezká věc, ale do garsonky se zrovna nehodí.";
			}
			break;

		// try breaking unbreakable wall
		case "break solid wall":
			switch (directionOfKaja){
				case 1:
					return "Kája se pokusil zničit zeď, ale byla na jeho paličku až moc kvalitní. Teď nemá jak paličku, tak sebevědomí.";
				case 2:
					return "Kája se pokusil zničit zeď, ale zeď zničila jeho.";
				case 3:
					return "Kája chytře rozpoznal, že tato zeď není k ničení vhodná.";
				default:
					return "Kája nasprejoval na zeď urážlivé grafiti. Byl zabit twiterovým sniperem.";
			}
			break;

		// try breaking nothing
		case "break at nothing":
			switch (directionOfKaja){
				case 1:
					return "Ať Kája hledá jak chce, zeď se zde nenachází.";
				case 2:
					return "Kája zmaten absencí zdi usíná.";
				case 3:
					return "Kája vyhloubil díru. Teď se z ní nemůže dostat.";
				default:
					return "Kája se pokusil zbořit zeď, ale namísto toho zbořil stabilitu tohoto programu.";
			}
			break;

		// if you write error cause wrong
		default:
			return
				"Zdá se, že vývojář špatně napsal příčinu selhání, takže nemohu poskytnout žádné užitečné informace"
				~ " oledně zkázy vašeho programu. Prosím nahlašte tento překlep vašemu lokálnímu poskytovately Kájy.";
	}
}
