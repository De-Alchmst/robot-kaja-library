using System;
using System.Runtime.InteropServices;

namespace Kaja;

public class RobotKaja
{
///////////////////////////
// Load extern functions //
///////////////////////////
[DllImport("../lib-d/kajaLibD.so")]
static extern bool innitPtr(IntPtr city);
[DllImport("../lib-d/kajaLibD.so")]
static extern IntPtr getErrorMessagePtr();
[DllImport("../lib-d/kajaLibD.so")]
static extern IntPtr getMapDimensionsInt();
[DllImport("../lib-d/kajaLibD.so")]
static extern ushort[] getKaja();
[DllImport("../lib-d/kajaLibD.so")]
static extern ushort[] getHome();
[DllImport("../lib-d/kajaLibD.so")]
static extern ushort[][] getFlags();
[DllImport("../lib-d/kajaLibD.so")]
static extern ushort[][] getSolidWalls();
[DllImport("../lib-d/kajaLibD.so")]
static extern ushort[][] getBreakableWalls();

///////////////////////////////
// Functions for interaction //
///////////////////////////////

	// Innit / Restart //
	static public bool Innit(string city){
		return innitPtr(Marshal.StringToHGlobalAnsi(city)); // convert string to char*
	}

	// Load programs //

	// Do one action //

///////////////////////////////////////
// Functions for getting impormation //
///////////////////////////////////////

	// Get error message //
	static public string GetErrorMessage(){
		return Marshal.PtrToStringUTF8(getErrorMessagePtr()); // convert to string
	}

	// get map dimensions
	static public int[] GetMapDimensions(){
		int[] Output = new int[2];
		IntPtr ToConvert = getMapDimensionsInt();

		Marshal.Copy(ToConvert,	Output,0,2);
		return Output;
	}

	// Get Kája //
	static public ushort[] GetKaja(){
		return getKaja();
	}

	// Get home //
	static public ushort[] GetHome(){
		return getHome();
	}

	// Get flags //
	static public ushort[][] GetFlags(){
		return getFlags();
	}

	// Get solid walls //
	static public ushort[][] GetSolidWalls(){
		return getSolidWalls();
	}

	// Get breakable walls //
	static public ushort[][] GetBreakableWalls(){
		return getBreakableWalls();
	}

}
