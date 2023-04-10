// build with : dmd -c support.d -fPIC
//              dmd -c objects.d -fPIC
//              dmd -c main.d -fPIC
//              dmd -shared main.o objects.o support.o -ofkajaLibD.so

import objects;

//////////////////////
// Set up Variables //
//////////////////////

static Program program;

// for getting stuff to c#
static int[][] storedFlags;
static ushort flagIndex;

static int[][] storedSolidWalls;
static ushort solidWallIndex;

static int[][] storedBreakableWalls;
static ushort breakableWallIndex;

extern(C) export {
///////////////////////////////
// Functions for interaction //
///////////////////////////////

	// Innit / Restart //
	bool innitPtr(char* city, char* mainScript)
		{ return innit( to!string(fromStringz(city)), to!string(fromStringz(mainScript)) ); }
	bool innit(string city, string mainScript){
		// reset program
		program = new Program;

		// split map
		string[][] citySplitted = splitCity(city);
		ushort cityWidth = cast(ushort)citySplitted[0].length;

		// set kája.wallPos
		program.kaja.wallPosition = [cityWidth,cast(ushort)citySplitted.length];

		// fill stuff with data
		for (ushort y = 0; y < citySplitted.length; y++){
			// set error if not all rows are same
			if (citySplitted[y].length != cityWidth){
				program.kaja.statusMessage =
					"Mapa nemá konzistentní šířku. Prosím, zkonzultujte tento problém s vaším architektem.";
				return false;
			}

			for (ushort x = 0; x < cityWidth; x++)
				// determine what does said char mean
				switch (citySplitted[y][x]){
					// empty
					case " ":
						// do nothing
						break;
					// solid wall
					case "W":
						program.infoHolder.solidWalls ~= [x,y];
						break;
					// brea kable wall
					case "B":
						program.infoHolder.breakableWalls ~= [x,y];
						break;
					// home
					case "H":
						program.infoHolder.home = [x,y];
						break;
					// kája
					case "K1","K2","K3","K4":
						program.kaja.pos = [x,y];
						program.kaja.direction = to!byte(citySplitted[y][x][1..2]);
						break;
					// flag
					default:
						// if not number, then it is invalit tile
						if (!isNumeric(citySplitted[y][x])){
							program.kaja.statusMessage = "Blok mapy "~citySplitted[y][x]~" na pozici X : "~to!string(x)~", Y : "
									~to!string(y)~" není validní. Prosím, zkonzultujte tento problém s vaším architektem.";
							return false;
						}

						// else it is a flag
						program.infoHolder.flags ~= [x,y,to!ushort(citySplitted[y][x])];
				}
		}

		// load main script
		if (loadScript(mainScript)){
			// add to running scripts
			string[] splitedScript = splitScript(mainScript); // get all lines again

			// add the script ro runningScripts
			program.addToRunningScripts(splitedScript[0]);
		}
		// else return error
		else return false;

		return true;
	}

	// Load programs //
	bool loadScriptPtr(char* newScript)
		{ return loadScript( to!string(fromStringz(newScript)) ); }
	bool loadScript(string newScript){
		string[] splitedScript = splitScript(newScript);

		// test if for errors
		if (splitedScript.length == 0){
			program.kaja.statusMessage = "script is empty";
			return false;
		}
		// here will be something to check if commands are valid
		// at some point

		// add to list 
		Script x = {commands : splitedScript[1..$]};
		program.scriptList[splitedScript[0]] = x;
		return true;
	}

	// Do one action //
	bool doSomething(){
		return program.nextAction();
	}

///////////////////////////////////////
// Functions for getting information //
///////////////////////////////////////

	// Get error message //
	char* getStatusMessagePtr(){
		return cast(char*)toStringz(getStatusMessage());
	}
	string getStatusMessage(){
		return program.kaja.statusMessage;
	}

	// get map dimensions //
	int* getMapDimensionsIntPtr(){
		// get ushort[]
		// transform into int[] because weird c# stuff with ushorts
		// cast to pointer because weird c++ stuff
		// return
		return cast(int*)to!(int[])(getMapDimensions());
	}
	ushort[] getMapDimensions(){
		return program.kaja.wallPosition;
	}

	// Get Kája //
	int* getKajaIntPtr(){
		return cast(int*)to!(int[])(getKaja());
	}
	ushort[] getKaja(){
		return program.kaja.returnInfo;
	}

	// Get home //
	int* getHomeIntPtr(){
		return cast(int*)to!(int[])(getHome());
	}
	ushort[] getHome(){
		return program.infoHolder.home;
	}

	// Get flags //
	// innicialize new set of flags for c#
	void getFlagsLength(int* lengthOfArray){
		storedFlags = to!(int[][])(getFlags());
		flagIndex = 0;
		*lengthOfArray = cast(int)storedFlags.length;
	}
	// get flag for c#
	int* getNextFlagIntPtr(){
		flagIndex++;
		return cast(int*)(storedFlags[flagIndex-1]);
	}

	ushort[][] getFlags(){
		return program.infoHolder.flags;
	}

	// Get solid walls //
	void getSolidWallsLength(int* lengthOfArray){
		storedSolidWalls = to!(int[][])(getSolidWalls());
		solidWallIndex = 0;
		*lengthOfArray = cast(int)storedSolidWalls.length;
	}
	int* getNextSolidWallIntPtr(){
		solidWallIndex++;
		return cast(int*)(storedSolidWalls[solidWallIndex-1]);
	}

	ushort[][] getSolidWalls(){
		return program.infoHolder.solidWalls;
	}

	// Get breakable walls //
	void getBreakableWallsLength(int* lengthOfArray){
		storedBreakableWalls = to!(int[][])(getBreakableWalls());
		breakableWallIndex = 0;
		*lengthOfArray = cast(int)storedBreakableWalls.length;
	}
	int* getNextBreakableWallIntPtr(){
		breakableWallIndex++;
		return cast(int*)(storedBreakableWalls[breakableWallIndex-1]);
	}

	ushort[][] getBreakableWalls(){
		return program.infoHolder.breakableWalls;
	}

}
