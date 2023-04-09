import std.regex : split, regex;
public import std.string : toStringz, fromStringz, strip, StringException, isNumeric;

////////////////////////////////////////////////////////////////////
// checks if any item in array of positions has specific position //
////////////////////////////////////////////////////////////////////
// returns index of said item or -1 if no found
int checkCollision(ushort[] positionToLookFor, ushort[][] stuffToLookIn){
	for (int i = 0; i < stuffToLookIn.length; i++)
		if (stuffToLookIn[i][0] == positionToLookFor[0] && stuffToLookIn[i][1] == positionToLookFor[0])
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

		// if you write error cause wrong
		default:
			return
				"Developer wrote cause of error wrong, so I can't provide any useful information about your demise."
				~ " Please report this incident to your local developer.";
	}
}
