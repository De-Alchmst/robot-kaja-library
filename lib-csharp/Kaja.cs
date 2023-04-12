using System;
using System.Runtime.InteropServices;

namespace Kaja;

public class RobotKaja
{
///////////////////////////
// Load extern functions //
///////////////////////////
[DllImport("../lib-d/kajaLibD.so")]
static extern bool innitPtr(IntPtr city, IntPtr mainScript);
[DllImport("../lib-d/kajaLibD.so")]
static extern bool loadScriptPtr(IntPtr mainScript);
[DllImport("../lib-d/kajaLibD.so")]
static extern bool doSomething();
[DllImport("../lib-d/kajaLibD.so")]
static extern IntPtr getStatusMessagePtr();
[DllImport("../lib-d/kajaLibD.so")]
static extern IntPtr getMapDimensionsIntPtr();
[DllImport("../lib-d/kajaLibD.so")]
static extern IntPtr getKajaIntPtr();
[DllImport("../lib-d/kajaLibD.so")]
static extern IntPtr getHomeIntPtr();
[DllImport("../lib-d/kajaLibD.so")]
static extern void getFlagsLength(out int lengthOfArray);
[DllImport("../lib-d/kajaLibD.so")]
static extern IntPtr getNextFlagIntPtr();
[DllImport("../lib-d/kajaLibD.so")]
static extern void getSolidWallsLength(out int lengthOfArray);
[DllImport("../lib-d/kajaLibD.so")]
static extern IntPtr getNextSolidWallIntPtr();
[DllImport("../lib-d/kajaLibD.so")]
static extern void getBreakableWallsLength(out int lengthOfArray);
[DllImport("../lib-d/kajaLibD.so")]
static extern IntPtr getNextBreakableWallIntPtr();
[DllImport("../lib-d/kajaLibD.so")]
static extern void changeSolidWall(ushort x, ushort y);
[DllImport("../lib-d/kajaLibD.so")]
static extern void changeBreakableWall(ushort x, ushort y);
[DllImport("../lib-d/kajaLibD.so")]
static extern void relocateHome(ushort x, ushort y);
[DllImport("../lib-d/kajaLibD.so")]
static extern void addFlag(ushort x, ushort y);
[DllImport("../lib-d/kajaLibD.so")]
static extern void substractFlag(ushort x, ushort y);

///////////////////////////////
// Functions for interaction //
///////////////////////////////

	// Innit / Restart //
	static public bool Innit(string city, string MainScript){
		return innitPtr(Marshal.StringToHGlobalAnsi(city), Marshal.StringToHGlobalAnsi(MainScript));// convert string to char*
	}

	// Load programs //
	static public bool LoadScript(string NewScript){
		return loadScriptPtr(Marshal.StringToHGlobalAnsi(NewScript));
	}

	// Do one action //
	static public bool DoSomething(){
		return doSomething();
	}

///////////////////////////////////////
// Functions for getting impormation //
///////////////////////////////////////

	// Get error message //
	static public string GetStatusMessage(){
		return Marshal.PtrToStringUTF8(getStatusMessagePtr()); // convert to string
	}

	// get map dimensions
	static public int[] GetMapDimensions(){
		int[] Output = new int[2];
		IntPtr ToConvert = getMapDimensionsIntPtr();

		Marshal.Copy(ToConvert,	Output,0,2);
		return Output;
	}

	// Get Kája //
	static public int[] GetKaja(){
		int[] Output = new int[3];
		IntPtr ToConvert = getKajaIntPtr();

		Marshal.Copy(ToConvert,	Output,0,3);
		return Output;
	}

	// Get home //
	static public int[] GetHome(){
		int[] Output = new int[2];
		IntPtr ToConvert = getHomeIntPtr();

		Marshal.Copy(ToConvert,	Output,0,2);
		return Output;
	}

	// Get flags //
	static public int[][] GetFlags(){
		// get ptr and length
		int LengthOfArray;
		getFlagsLength(out LengthOfArray);

		// output
		int[][] Output = new int[LengthOfArray][];

		// get all flags
		for (int i = 0; i < LengthOfArray; i++){
			int[] x = new int[3];
			Marshal.Copy(getNextFlagIntPtr(),x,0,3);
			Output[i] = x;
		}

		return Output;
	}

	// Get solid walls //
	static public int[][] GetSolidWalls(){
		// get ptr and length
		int LengthOfArray;
		getSolidWallsLength(out LengthOfArray);

		// output
		int[][] Output = new int[LengthOfArray][];

		// get all flags
		for (int i = 0; i < LengthOfArray; i++){
			int[] x = new int[3];
			Marshal.Copy(getNextSolidWallIntPtr(),x,0,3);
			Output[i] = x;
		}

		return Output;
	}

	// Get breakable walls //
	static public int[][] GetBreakableWalls(){
		// get ptr and length
		int LengthOfArray;
		getBreakableWallsLength(out LengthOfArray);

		// output
		int[][] Output = new int[LengthOfArray][];

		// get all flags
		for (int i = 0; i < LengthOfArray; i++){
			int[] x = new int[3];
			Marshal.Copy(getNextBreakableWallIntPtr(),x,0,3);
			Output[i] = x;
		}

		return Output;
	}

	// places or breaks solid wall //
	static public void ChangeSolidWall(int x, int y){
		changeSolidWall((ushort)x,(ushort)y);
	}

	// places or breaks breakable wall //
	public static void ChangeBreakableWall(int x, int y){
		changeBreakableWall((ushort)x,(ushort)y);
	}

	// relocates home //
	public static void RelocateHome(int x, int y){
		relocateHome((ushort)x,(ushort)y);
	}

	// adds a flag //
	public static void AddFlag(int x, int y){
		addFlag((ushort)x,(ushort)y);
	}

	// substracts flag //
	public static void SubstractFlag(int x, int y){
		substractFlag((ushort)x,(ushort)y);
	}

}
