// build with : dmd

import std.string;
import objects;

import std.conv : to;

//////////////////////
// Set up Variables //
//////////////////////

static Robotkaja kaja;
static InformationHolder infoHolder;


extern(C) export {
///////////////////////////////
// Functions for interaction //
///////////////////////////////

	// Innit / Restart //
	void InnitPtr(char* city) { Innit( to!string(fromStringz(city)) ); }
	void Innit(string city){
		// preset some variables
		infoHolder.solidWalls = [];
		infoHolder.breakableWalls = [];
		infoHolder.flags = [];
		infoHolder.home = [];

		kaja.pos = [];
		kaja.direction = 0;

		// split map
		string[][] citySplitted = splitCity(city);
		ushort cityWidth = cast(ushort)citySplitted[0].length;

		// set kája.wallPos
		kaja.wallPosition = [cityWidth,cast(ushort)citySplitted.length];

		// fill stuff with data
		for (ushort y = 0; y < citySplitted.length; y++){
			// throw exception if not all rows are same
			if (citySplitted[y].length != cityWidth)
				throw new StringException(
						"Mapa nemá konzistentní šířku. Prosím, zkonzultujte tento problém s vaším architektem.");

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
						kaja.direction = to!byte(citySplitted[y][x][1]);
						break;
					// flag
					default:
						// if not number, then it is invalit tile
						if (!isNumeric(citySplitted[y][x]))
							throw new StringException("Blok mapy "~citySplitted[y][x]~" na pozici X : "~to!string(x)~", Y : "
									~to!string(y)~" není validní. Prosím, zkonzultujte tento problém s vaším architektem.");

						// else it is a flag
						infoHolder.flags ~= [x,y,to!ushort(citySplitted[y][x])];
				}
		}

	}

	// Load programs //

	// Do one action //

///////////////////////////////////////
// Functions for getting information //
///////////////////////////////////////

	// Get error message //

	// Get Kája //

	// Get home //

	// Get flags //

	// Get solid walls //

	// Get breakable walls //

}
