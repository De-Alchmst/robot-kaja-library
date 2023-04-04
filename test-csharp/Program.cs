using Kaja;
using System;

namespace KajaTest;
internal class Program {

	///////////////////
	// set variables //
	///////////////////

	static int[] MapDimensions;

	//////////
	// test //
	//////////
	static void Main(string[] args){
		// innicialize //
		string City = File.ReadAllText(@"../test-scripts/map1.txt");
		Console.Write(City);

		// catch erors //
		if (!RobotKaja.Innit(City)){
			Console.WriteLine(RobotKaja.GetErrorMessage());
			return;
		}
		
		MapDimensions = RobotKaja.GetMapDimensions();
		Console.WriteLine(MapDimensions[0].ToString());
		Console.WriteLine(MapDimensions[1].ToString());

		// test functions
		/* RobotKaja.GetErrorMessage(); */
		/* RobotKaja.GetMapDimensions(); */
		/* RobotKaja.GetKaja(); */
		/* RobotKaja.GetHome(); */
		/* RobotKaja.GetFlags(); */
		/* RobotKaja.GetSolidWalls(); */
		/* RobotKaja.GetBreakableWalls(); */

		/* Console.WriteLine("Functions Loaded Succesfully!!"); */

		// write current state
		/* ShowMap(); */

	}
}
