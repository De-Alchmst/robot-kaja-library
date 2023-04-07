public import support;

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
	string errorMessage;

	// other
	ushort[] returnInfo() => pos~direction;

	// moves foward //
	public bool moveFoward(ushort[][] walls){
		static int collisionIndex;
		
		// decide direction
		switch(direction){
			case 1: //up
				// move
				pos[1]--;

				// check for collisions
				collisionIndex = checkCollision(pos,walls);
				if (pos[1] == 0 || collisionIndex >= 0){
					// go back
					pos[1]++;
					// generate error message
					errorMessage = generateErrorMessage("walk into wall", direction);
					// return error status
					return false;
				}
				break;

			case 2:
				// move
				pos[0]++;

				// check for collisions
				collisionIndex = checkCollision(pos,walls);
				if (pos[0] == wallPosition[0] || collisionIndex >= 0){
					// go back
					pos[0]--;
					// generate error message
					errorMessage = generateErrorMessage("walk into wall", direction);
					// return error status
					return false;
				}
				break;

			case 3:
				// move
				pos[1]++;

				// check for collisions
				collisionIndex = checkCollision(pos,walls);
				if (pos[1] == wallPosition[1] || collisionIndex >= 0){
					// go back
					pos[1]--;
					// generate error message
					errorMessage = generateErrorMessage("walk into wall", direction);
					// return error status
					return false;
				}
				break;

			default:
				// move
				pos[0]--;

				// check for collisions
				collisionIndex = checkCollision(pos,walls);
				if (pos[0] == 0 || collisionIndex >= 0){
					// go back
					pos[0]++;
					// generate error message
					errorMessage = generateErrorMessage("walk into wall", direction);
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
	uint currentCommandIndex = 0;
}

class Program{
	RobotKaja kaja;
	InformationHolder infoHolder;

	// list of all avilable scripts
	Script[string] scriptList;

	// list of currently running scripts
	Script[] runningScripts;

	this(){
		// set variables
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

}
