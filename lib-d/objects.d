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

	string condition; // DOKUD
	ubyte loopCount; // OPAKUJ
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
		bool recurse = false;
		bool addLineToRunningScripts = false;

		// go þrough all possible commands
		// and execute the right one
		string line = scr.commands[scr.commandIndex];
		switch (line){
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
				// anything here is not something, to show to the player so go right to the next loop
				recurse = true;

				// looks if it isn't another script
				if ((line in scriptList) !is null){
					// if it is, add it
					addLineToRunningScripts = true;
					outcome = true;
					break;
				}

				// look if it isn't statement
				// split into words
				string[] lineParts = line.split(regex(" "));
				// compare
				switch (lineParts[0]){

					// repeat a numbre of times
					case "OPAKUJ":
						outcome = handleRepeat(lineParts);
						break;

					// repeat until condition
					case "DOKUD":
						outcome = handleUntil(lineParts);
						break;

					// do if condition
					case "KDYŽ":
						outcome = handleIf(lineParts);
						break;

					// possible else after KDYŽ
					case "JINAK":
						outcome = handleElse();
						break;

					// end of statement
					case "KONEC":
						outcome = handleEndOfStatement();
						break;

					// if not statement, throw some error
					default:
						kaja.statusMessage = line ~ " není srozumitelný příkaz!";
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
			
			// if set to add new script
			if (addLineToRunningScripts)
				addToRunningScripts(line);
			// if it was a statement, run one more loop
			if (recurse)
				outcome = nextAction();
		}

		// if all worked fine
		return outcome;
	}

	// handles JINAK inicialization //
	bool handleElse(){
		// if previous statement is KDYŽ
		if (statements[$-1].type == "KDYŽ"){
			// change it to JINAK
			return skipBlockOfCode("JINAK");
		}
		// else if it is something else
		// return error
		kaja.statusMessage = "Tohle JINAK vypadá, jakoby sem nepatřilo.";
		return false;
	}

	// handles KDYŽ inicialization //
	bool handleIf(string[] lineParts){
		// test for corret ammount of parts
		if (lineParts.length != 2){
			kaja.statusMessage = "KDYŽ nedostalo správný počet parametrů.";
			return false;
		}

		// test for validity of condition
		if (!validateCondition(lineParts[1]))
			return false;

		// if valid and true, then add statement
		if (handleCondition(lineParts[1])){
			Statement s = {type:"KDYŽ"};
			statements ~= s;
			return true;

		// else skip entire block
		} else {
			return skipBlockOfCode("KDYŽ");
		}
	}

	// handles DOKUD inicialization //
	bool handleUntil(string[] lineParts){
		// test for corret ammount of parts
		if (lineParts.length != 2){
			kaja.statusMessage = "DOKUD nedostalo správný počet parametrů.";
			return false;
		}

		// test for validity of condition
		if (!validateCondition(lineParts[1]))
			return false;

		// if valid and true, then add statement
		if (handleCondition(lineParts[1])){
			Statement s = {type:"DOKUD", condition:lineParts[1], origin:runningScripts[$-1].commandIndex};
			statements ~= s;
			return true;

		// else skip entire block
		} else {
			return skipBlockOfCode("DOKUD");
		}

	}

	// handles OPAKUJ inicialization //
	bool handleRepeat(string[] lineParts){
		// test for corret ammount of parts
		if (lineParts.length != 2){
			kaja.statusMessage = "OPAKUJ nedostalo správný počet parametrů.";
			return false;
		}
			
		// test whether parametr is number
		if (!lineParts[1].isNumeric){
			// if not, return error
			kaja.statusMessage = cast(string)lineParts[1] ~ " není validní číslo! Kája je zmaten.";
			return false;
		}

		ubyte loopCount = to!ubyte(lineParts[1]);
		// test number of loops
		if (loopCount <= 0){
			kaja.statusMessage = "Počet průběhů v OPAKUJ musí být větší než 0!";
			return false;
		}

		// if it is, add Statement
		Statement s = {type:"OPAKUJ", origin:runningScripts[$-1].commandIndex, loopCount:loopCount};
		statements ~= s;
		return true;

	}

	// handles KONEC and JINAK
	bool handleEndOfStatement(){
		// check if there are any statements
		if (statements.length == 0){
			// if there are, throw error
			kaja.statusMessage = "Není tu co ukončit, tak ukončuji program.";
			return false;
		}

		// get what to end
		final switch (statements[$-1].type){

			// repeat
			case "OPAKUJ":
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

			// until
			case "DOKUD":
				// if condition is still true
				if (handleCondition(statements[$-1].condition))
					// loop back to origin
					runningScripts[$-1].commandIndex = statements[$-1].origin;

				// if it is false
				else
					// don't repeat and get rid of it
					statements = statements[0..$-1];

				break;

			// if
			case "KDYŽ", "JINAK":
				// relese it
				statements = statements[0..$-1];
				break;
		}

		return true;
	}

	// validates condition //
	bool validateCondition(string condition){
		static string[] validConditions = ["ZEĎ","ZNAČKA","SEVER","DOMOV","KVALITA"];

		// get rid of potentional '!'
		if (condition[0] == '!' && condition.length > 1)
			condition = condition[1..$];

		// test for validity
		foreach (string x; validConditions)
			if (condition == x)
				return true;
		// if no match
		kaja.statusMessage = condition ~ " není validní podmínkou.";
		return false;
	}
	
	// returns boolean of condition //
	bool handleCondition(string condition){
		bool outcome;
		// note potentional negaiton
		bool negated = false;
		if (condition[0] == '!' && condition.length > 1){
			condition = condition[1..$];
			negated = true;
		}

		// get value of condition
		final switch (condition){
			// is there wall before Kája
			case "ZEĎ":
				if (checkCollision(kaja.getDestination(),infoHolder.walls) == -1)
					outcome = false;
				else
					outcome = true;
				break;

			// is there flag under Kája
			case "ZNAČKA":
				if (checkCollision(kaja.pos,infoHolder.flags) == -1)
					outcome = false;
				else
					outcome = true;
				break;

			// is Kája rotated ta North
			case "SEVER":
				if (kaja.direction == 1)
					outcome = true;
				else
					outcome = false;
				break;

			// is Kája home
			case "DOMOV":
				if (kaja.pos == infoHolder.home)
					outcome = true;
				else
					outcome = false;
				break;

			case "KVALITA":
				if (checkCollision(kaja.getDestination(),infoHolder.solidWalls) == -1)
					outcome = false;
				else
					outcome = true;
		}

		// return
		if (negated)
			return !outcome;
		else
			return outcome; 
	}

	// skips block of code
	bool skipBlockOfCode(string cause){
		static string[] validStatements = ["KDYŽ","DOKUD","OPAKUJ"];
		// whether to stop at JINAK
		ubyte innerLoops = 0;
		// go through code
		while (true){
			// add index
			runningScripts[$-1].commandIndex++;
			// if too far
			if (runningScripts[$-1].commandIndex == runningScripts[$-1].commands.length){
				// throw error
				kaja.statusMessage = "Vypadá to, že tu jaksi chybí KONEC.";
				return false;
			}
			// get line
			string line = runningScripts[$-1].commands[runningScripts[$-1].commandIndex];
			// split into words
			string[] lineParts = line.split(regex(" "));

			// look what it is
			// if statement
			bool isStatement = false;
			foreach (string s; validStatements)
				if (lineParts[0] == s){
					isStatement = true;
					break;
				}
			if (isStatement)
				// add innre loop that needs to be completed
				innerLoops++;

			// if KONEC
			else if (line == "KONEC")
				// if some inner loop
				if (innerLoops != 0)
					// end it
					innerLoops--;
				// else end self
				else
					break;

			// if JINAK
			else if (line == "JINAK")
				// if in KDYŽ and no inner loops
				if (innerLoops == 0 && cause == "KDYŽ"){
					// add JINAK statement
					Statement s= {type:"JINAK"};
					statements ~= s;
					break;
				}

			
		}
		return true;
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
