using static Kaja.RobotKaja;
using System;
using System.Threading;

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
		string MainScript = File.ReadAllText(@"../test-scripts/test-basics.txt");
		string Vpravo = File.ReadAllText(@"../test-scripts/vpravo.txt");
		Console.Write(City);

		// catch erors //
		if (!Innit(City, MainScript)){
			Console.WriteLine(GetStatusMessage());
			return;
		}

		// load another script
		LoadScript(Vpravo);
		
		MapDimensions = GetMapDimensions();

		// run until end of script
		// write current state
		do {
			Console.WriteLine();
			ShowMap();
			// sleep for a while
			Thread.Sleep(200);
		} while (DoSomething());
		// write why exit
		Console.WriteLine(GetStatusMessage());

	}

	static void ShowMap(){
		string[][] ToShow = new string[MapDimensions[1]][];

		// innitial nothing
		for (ushort y = 0; y < MapDimensions[1]; y++){
			string[] newPart = new string[MapDimensions[0]];
			for (ushort x = 0; x < MapDimensions[0]; x++)
				newPart[x] = "..";
			ToShow[y] = newPart;
		}

		// flags
		foreach (int[] flag in GetFlags()){
			// add only two digits or FL
			string FlagString = flag[2].ToString();

			if (FlagString.Length == 2)
				ToShow[flag[1]][flag[0]] = "\x1b[35m"+FlagString+"\x1b[37m";
			else if (FlagString.Length == 1)
				ToShow[flag[1]][flag[0]] = "\x1b[35m0"+FlagString+"\x1b[37m";
			else
				ToShow[flag[1]][flag[0]] = "\x1b[35m~~\x1b[37m";
		}

		// walls
		foreach (int[] wall in GetSolidWalls())
			ToShow[wall[1]][wall[0]] = "\x1b[31m██\x1b[37m";
		foreach (int[] wall in GetBreakableWalls())
			ToShow[wall[1]][wall[0]] = "\x1b[33m▒▒\x1b[37m";

		// home
		int[] Home = GetHome();
		if (Home.Length == 2)
			ToShow[Home[1]][Home[0]] = "\x1b[32m╠╣\x1b[37m";

		// kaja
		int[] Kaja = GetKaja();
		switch (Kaja[2]){
			case 1:
				ToShow[Kaja[1]][Kaja[0]] = "\x1b[36m/\\\x1b[37m";
				break;
			case 2:
				ToShow[Kaja[1]][Kaja[0]] = "\x1b[36m=>\x1b[37m";
				break;
			case 3:
				ToShow[Kaja[1]][Kaja[0]] = "\x1b[36m\\/\x1b[37m";
				break;
			default:
				ToShow[Kaja[1]][Kaja[0]] = "\x1b[36m<=\x1b[37m";
				break;
		}

		// draw
		string ActualDraw = "";
		for (ushort i = 0; i < ToShow.Length; i++){
			for (ushort j = 0; j < ToShow[0].Length; j++)
				ActualDraw += ToShow[i][j];
			ActualDraw += "\n";
		}

		Console.Write(ActualDraw);

	}


}
