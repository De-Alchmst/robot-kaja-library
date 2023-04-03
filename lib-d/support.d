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
extern(C) string[][] splitCity(string city){
	// get LF line ends
	// using strip to get rid of extra whitespace

	// get chunks separated by \r\n
	string[] chunks = strip(city).split(regex("\r\n"));
	string LFstring = strip(chunks[0]);

	// put them back together but with \n only
	for (ushort i = 1; i < chunks.length; i++) // start from 1 to ignore first chunk alredy assigned
		LFstring ~= "\n"~strip(chunks[i]);

	// return split by \n and , char
	string[][] rows = [];
	chunks = LFstring.split(regex("\n"));

	for (ushort i = 0; i < chunks.length; i++)
		rows ~= chunks[i].split(regex(","));

	return rows;
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
					break;
				case 2:
					return "Procházení zdmi ještě nebylo implementováno";
					break;
				case 3:
					return "Hleď, nechť Kája vrazil do zdi.";
					break;
				default:
					return "Navedl jsi Káju do zdi. Ty vrahu!";
			}
			break;

		// if you write error cause wrong
		default:
			return
				"Developer wrote cause of error wrong, so I can't provide any useful information about your demise."
				~ " Please report this incident to your local developer.";
	}
}
