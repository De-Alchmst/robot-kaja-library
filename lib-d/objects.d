public import support;

//////////////////
// Kájovo class // and holds error massages
//////////////////

class Robotkaja {
	// variables declared at start //
	ushort[] pos; // x,y
	byte direction;
	ushort[] wallPosition; // limits where he can't go to (one x, one y)
	// ,-1-, //
	// 4 + 2 //
	// '-3-' //

	// variables declared automatically when needed
	string errorMessage;

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
					errorMessage = getErrorMessage("walk into wall", direction);
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
					errorMessage = getErrorMessage("walk into wall", direction);
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
					errorMessage = getErrorMessage("walk into wall", direction);
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
					errorMessage = getErrorMessage("walk into wall", direction);
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
	public bool turnLeft(){
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
