// build with : dmd -c support.d -fPIC
//              dmd -c objects.d -fPIC
//              dmd -c main.d -fPIC
//              dmd -shared main.o objects.o support.o -ofkajaLibD.so

import std.string;
import objects;

import std.conv : to;

import std.stdio;

//////////////////////
// Set up Variables //
//////////////////////

static RobotKaja kaja;
static InformationHolder infoHolder;

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
	bool innitPtr(char* city) { return innit( to!string(fromStringz(city)) ); }
	bool innit(string city){
		// preset some variables
		infoHolder.solidWalls = [];
		infoHolder.breakableWalls = [];
		infoHolder.flags = [];
		infoHolder.home = [];

		kaja = new RobotKaja;
		kaja.pos = [];
		kaja.direction = 0;

		// split map
		string[][] citySplitted = splitCity(city);
		ushort cityWidth = cast(ushort)citySplitted[0].length;

		// set kája.wallPos
		kaja.wallPosition = [cityWidth,cast(ushort)citySplitted.length];

		// fill stuff with data
		for (ushort y = 0; y < citySplitted.length; y++){
			// set error if not all rows are same
			if (citySplitted[y].length != cityWidth){
				kaja.errorMessage =
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
						infoHolder.solidWalls ~= [x,y];
						break;
					// brea kable wall
					case "B":
						infoHolder.breakableWalls ~= [x,y];
						break;
					// home
					case "H":
						infoHolder.home = [x,y];
						break;
					// kája
					case "K1","K2","K3","K4":
						kaja.pos = [x,y];
						kaja.direction = to!byte(citySplitted[y][x][1..2]);
						break;
					// flag
					default:
						// if not number, then it is invalit tile
						if (!isNumeric(citySplitted[y][x])){
							kaja.errorMessage = "Blok mapy "~citySplitted[y][x]~" na pozici X : "~to!string(x)~", Y : "
									~to!string(y)~" není validní. Prosím, zkonzultujte tento problém s vaším architektem.";
							return false;
						}

						// else it is a flag
						infoHolder.flags ~= [x,y,to!ushort(citySplitted[y][x])];
				}
		}
		return true;
	}

	// Load programs //

	// Do one action //

///////////////////////////////////////
// Functions for getting information //
///////////////////////////////////////

	// Get error message //
	char* getErrorMessagePtr(){
		return cast(char*)toStringz(getErrorMessage());
	}
	string getErrorMessage(){
		return kaja.errorMessage;
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
		return kaja.wallPosition;
	}

	// Get Kája //
	int* getKajaIntPtr(){
		return cast(int*)to!(int[])(getKaja());
	}
	ushort[] getKaja(){
		return kaja.returnInfo;
	}

	// Get home //
	int* getHomeIntPtr(){
		return cast(int*)to!(int[])(getHome());
	}
	ushort[] getHome(){
		return infoHolder.home;
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
		return infoHolder.flags;
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
		return infoHolder.solidWalls;
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
		return infoHolder.breakableWalls;
	}

}
