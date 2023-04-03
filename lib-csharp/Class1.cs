using System;
using System.Runtime.InteropServicec;

namespace Kaja;

///////////////////////////
// Load extern functions //
///////////////////////////
[DllImport("../lib-d/kajaLibD.so")]
static extern void innitPtr(IntPtr city);
[DllImport("../lib-d/kajaLibD.so")]
static extern IntPtr getErrorMessagePtr();
[DllImport("../lib-d/kajaLibD.so")]
static extern ushort[] getMapDimensions();
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

//////////////////////
// Cover them in C# //
//////////////////////
public class Class1
{
///////////////////////////////
// Functions for interaction //
///////////////////////////////

	// Innit / Restart //
	static public void Innit(string city){
		InnitPtr(Marshal.StringToHGlobalAnsi(city)); // convert string to char*
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
	static public ushort[] GetMapDimensions(){
		return getMapDimensions();
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
