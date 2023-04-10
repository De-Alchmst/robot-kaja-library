public import support;

public import std.stdio;
public import std.conv : to;

//////////////////
// Kájovo class // and holds error massages
//////////////////

class RobotKaja {
	// variables declared at start //
	ushort[] pos; // x,y
	byte direction;
	ushort[] wallPosition; // limits where he can't go to (one x, one y)
	// ,-1-, //
	// 4 + 2 //
	// '-3-' //

	// variables declared automatically when needed
	string statusMessage;

	// other
	ushort[] returnInfo() => pos~direction;

	// moves foward //
	public bool moveFoward(ushort[][] walls){
		// decide direction
		switch(direction){
			case 1: //up
				// move
				pos[1]--;

				// check for collisions
				if (pos[1] == -1 || checkCollision(pos,walls) >= 0){
					// go back
					pos[1]++;
					// generate error message
					statusMessage = generateErrorMessage("walk into wall", direction);
					// return error status
					return false;
				}
				break;

			case 2:
				// move
				pos[0]++;

				// check for collisions
				if (pos[0] == wallPosition[0] || checkCollision(pos,walls) >= 0){
					// go back
					pos[0]--;
					// generate error message
					statusMessage = generateErrorMessage("walk into wall", direction);
					// return error status
					return false;
				}
				break;

			case 3:
				// move
				pos[1]++;

				// check for collisions
				if (pos[1] == wallPosition[1] || checkCollision(pos,walls) >= 0){
					// go backj
					pos[1]--;
					// generate error message
					statusMessage = generateErrorMessage("walk into wall", direction);
					// return error status
					return false;
				}
				break;

			default:
				// move
				pos[0]--;

				// check for collisions
				if (pos[0] == -1 || checkCollision(pos,walls) >= 0){
					// go back
					pos[0]++;
					// generate error message
					statusMessage = generateErrorMessage("walk into wall", direction);
					// return error status
					return false;
				}
		}

		// if no collision with wall happens
		// return ok status
		return true;
	}

	// Turn Kája left and only left.//
	// Not right. Not Up. Not even into ashes. //
	// Only LEFT //
	public void turnLeft(){
		direction--;
		if (direction == 0)
			direction = 4;
	}

	// Highers number of flags under Kája, if any.//
	public bool placeFlag(ref ushort[][] flags, ushort[] home){
		// if at home, ERROR
		if (home == pos){
			statusMessage = generateErrorMessage("placing flags at home",direction);
			return false;
		}

		// else go through flags
		for (uint i = 0; i < flags.length; i++)
			// if match
			if (flags[i][0] == pos[0] && flags[i][1] == pos[1]){
				// add one
				flags[i][2]++;
				// and stop looping
				return true;
			}

		// if no matches, create a new one
		flags ~= [pos[0],pos[1],1];
		return true;

	}

	// Lowers number of flags under Kája, if any //
	public bool pickUpFlag(ref ushort[][] flags){
		// go through flags
		for (uint i = 0; i < flags.length; i++)
			// if match
			if (flags[i][0] == pos[0] && flags[i][1] == pos[1]){
				// if multiple flags, remove one
				if (flags[i][2] > 1)
					flags[i][2]--;
				// else just delete from list
				else
					if (flags.length-1 == i)
						flags = flags[0..$-1];
					else
						flags = flags[0..i] ~ flags[i+1..$];

				// and stop forlooping
				return true;
			}
	
		// if no match, then return error
		statusMessage = generateErrorMessage("no flags", direction);
		return false;
	}

	// Changes Kájas home //
	public bool changeHome(ushort[][] flags, ref ushort[] home){
		// checks there isn't home alredy
		if (home == pos){
			statusMessage = generateErrorMessage("moved to home",direction);
			return false;
		}
		// go through flags
		for (uint i = 0; i < flags.length; i++)
			// if match
			if (flags[i][0] == pos[0] && flags[i][1] == pos[1]){
				statusMessage = generateErrorMessage("flag in way of home",direction);
				return false;
			}

		// if there isn't anything in way
		home = pos.dup;
		return true;

	}

	// gets place before Kája //
	private ushort[] getDestination(){
		switch (direction){
			case 1:
				return to!(ushort[])([pos[0],pos[1]-1]);
			case 2:
				return to!(ushort[])([pos[0]+1,pos[1]]);
			case 3:
				return to!(ushort[])([pos[0],pos[1]+1]);
			default:
				return to!(ushort[])([pos[0]-1,pos[1]]);
		}
	}

	// builds breakable wall //
	public bool buildAWall(ref ushort[][] breakableWalls, ushort[][] walls, ushort[][] flags, ushort[] home){
		// get destination
		ushort[] destination = getDestination();

		// determin if it is even valid position
		if ( destination[0] == -1 || destination[1] == -1
				|| destination[0] == wallPosition[0] ||  destination[1] == wallPosition[1]){
			statusMessage = generateErrorMessage("build at wall",direction);	
			return false;
		}
		// check for home
		if (home == destination){
			statusMessage = generateErrorMessage("build in home",direction);
			return false;
		}
		// check for walls
		if (checkCollision(destination,walls) != -1){ // it returns -1 of no match
			statusMessage = generateErrorMessage("build at wall",direction);	
			return false;
		}
		// check for flags
		if (checkCollision(destination,flags) != -1){
			statusMessage = generateErrorMessage("build at flag",direction);	
			return false;
		}

		// now that it is sure that place is free, add the wall
		breakableWalls ~= destination;
		return true;
	}

	// breaks breakable wall //
	public bool breakAWall(ref ushort[][] breakableWalls, ushort[][] solidWalls){
		// get destination 
		ushort[] destination = getDestination();

		// determin if it is even valid position
		if ( destination[0] == -1 || destination[1] == -1
				|| destination[0] == wallPosition[0] ||  destination[1] == wallPosition[1]){
			statusMessage = generateErrorMessage("break solid wall",direction);	
			return false;
		}

		// determine if there is solid wall
		// I want it to have special error message
		if (checkCollision(destination,solidWalls) >= 0){
			statusMessage = generateErrorMessage("break solid wall",direction);	
			return false;
		}

		// look for breakable wall
		int wallIndex = checkCollision(destination,breakableWalls);
		// if no found
		if (wallIndex == -1){
			statusMessage = generateErrorMessage("break at nothing",direction);
			return false;
		}
		// if match, get rid of it
		if (wallIndex == breakableWalls.length-1)
			breakableWalls = breakableWalls[0..$-1];
		else
			breakableWalls = breakableWalls[0..wallIndex] ~ breakableWalls[wallIndex+1..$];
		return true;
	}

}

////////////////////////
// Information holder //
////////////////////////

struct InformationHolder{
	ushort[][] solidWalls;
	ushort[][] breakableWalls;
	ushort[][] flags;
	ushort[]   home;

	// all walls combined
	ushort[][] walls() => solidWalls ~ breakableWalls;
}

/////////////
// Scripts //
/////////////

struct Script{
	string[] commands;
	uint commandIndex = 0;
}

struct Statement{
	string type;
	uint origin; // DOKUD and OPAKUJ

	string condition; // DOKUD and KDYŽ
	ubyte loopCount; // OPAKUJ
	uint endsInside; // KDYŽ
}

class Program{
	RobotKaja kaja;
	InformationHolder infoHolder;

	// list of all avilable scripts
	Script[string] scriptList;

	// list of currently running scripts
	Script[] runningScripts; // last one is active

	// list of running statements that need to be ended
	Statement[] statements;

	this(){
		// set variables //
		infoHolder.solidWalls = [];
		infoHolder.breakableWalls = [];
		infoHolder.flags = [];
		infoHolder.home = [];

		kaja = new RobotKaja;
		kaja.pos = [];
		kaja.direction = 0;
	}

	// adding scripts from scriptList to runningScripts //
	void addToRunningScripts(string scriptName){
		// get new struct with copy of commands
		Script addedScript = { commands : scriptList[scriptName].commands.dup };
		// add it
		runningScripts ~= addedScript;
	}

	// going through actions and making them or some shit //
	bool nextAction(){
		// if there is no more scripts
		if (runningScripts.length == 0){
			// return end of script
			kaja.statusMessage = "konec scriptu";
			return false;
		}

		Script scr = runningScripts[$-1];
		bool outcome;
		bool wasThisStatement = false;

		// go þrough all possible commands
		// and execute the right one
		switch (scr.commands[scr.commandIndex]){
			// move foward
			case "KROK":
				outcome = kaja.moveFoward(infoHolder.walls);
				break;
			// turn left and only left (for eternity if in infinite while loop or recursion)
			case "VLEVO_VBOK":
				kaja.turnLeft();
				outcome = true;
				break;

			// place flag
			case "POLOŽ":
				outcome = kaja.placeFlag(infoHolder.flags,infoHolder.home);
				break;
			// pick up flag
			case "ZVEDNI":
				outcome = kaja.pickUpFlag(infoHolder.flags);
				break;

			// change home
			case "PŘESTĚHUJ_SE":
				outcome = kaja.changeHome(infoHolder.flags,infoHolder.home);
				break;

			// build a wall
			case "POSTAV":
				outcome = kaja.buildAWall(
						infoHolder.breakableWalls, infoHolder.walls, infoHolder.flags, infoHolder.home);
				break;
			// break a wall
			case "ZBOŘ":
				outcome = kaja.breakAWall(infoHolder.breakableWalls, infoHolder.solidWalls);
				break;

			// called end
			case "PŘESTAŇ":
				kaja.statusMessage = "povel PŘESTAŇ";
				return false;

			// if it doesent match
			default:
				// look if it isn't statement
				// split into words
				string[] lineParts = scr.commands[scr.commandIndex].split(regex(" "));
				// compare
				wasThisStatement = true;
				switch (lineParts[0]){

					// repeat a numbre of times
					case "OPAKUJ":
						outcome = handleRepeat(lineParts);
						break;

					// end of statement
					case "KONEC":
						outcome = handleEndOfStatement();
						break;

					// if not statement, throw some error
					default:
						kaja.statusMessage = scr.commands[scr.commandIndex] ~ " není srozumitelný příkaz!";
						outcome = false;
				}
		}

		// if all no errors
		if (outcome){
			// move to next command
			// need to influence actual struct, not copy
			runningScripts[$-1].commandIndex++;
			// if it reached end of script
			if (runningScripts[$-1].commandIndex == scr.commands.length)
				// remove it from list
				runningScripts = runningScripts[0..$-1];
			
			// if it was a statement, run one more loop
			if (wasThisStatement)
				outcome = nextAction();
		}

		// if all worked fine
		return outcome;
	}

	// handles OPAKUJ inicialization
	bool handleRepeat(string[] lineParts){
		// test whether parametr is number
		if (!lineParts[1].isNumeric){
			// if not, return error
			kaja.statusMessage = cast(string)lineParts[1] ~ " není validní číslo! Kája je zmaten.";
			return false;
		}

		// if it is, add Statement
		Statement s = {
			type:"OPAKUJ", origin:runningScripts[$-1].commandIndex, loopCount:to!ubyte(lineParts[1])};
		statements ~= s;
		return true;

	}

	bool handleEndOfStatement(){
		// check if there are any statements
		if (statements.length == 0){
			// if there are, throw error
			kaja.statusMessage = "Není tu co ukončit, tak ukončuji program.";
			return false;
		}

		// get what to end
		bool outcome;
		final switch (statements[$-1].type){

			// repeat
			case "OPAKUJ":
				outcome = true;
				// if there is not supposed to be any more repeats
				if (statements[$-1].loopCount == 1){
					// relese it from its suffering
					statements = statements[0..$-1];
				}
				// if there is more to do
				else {
					// just loop back to origin
					runningScripts[$-1].commandIndex = statements[$-1].origin;
					// and check one loop out
					statements[$-1].loopCount--;
				}
				break;
		}

		return outcome;
	}

	// destructor just in case //
	~this(){
		kaja.destroy();
		infoHolder.destroy();
		foreach (Script scr; runningScripts)
			scr.destroy();
		foreach (Script scr; scriptList)
			scr.destroy();
	}
}
