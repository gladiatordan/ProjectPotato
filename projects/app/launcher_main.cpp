#include <iostream>
#include <Windows.h>

// Define the function signature of our DLL's entry point
typedef int(__stdcall* RunModuleFunc)(int, char**);

int main(int argc, char** argv) {
    std::cout << "ProjectPotato Launcher starting..." << std::endl;

    // Load the 64-bit DLL we built in the other CMake project
    HMODULE hDll = LoadLibraryA("ProjectPotatoDLL.dll");

    if (!hDll) {
        std::cerr << "[ERROR] Failed to load ProjectPotatoDLL.dll. Code: " << GetLastError() << std::endl;
        std::cin.get(); // Pause so you can read the error before the console closes
        return 1;
    }

    std::cout << "DLL Loaded successfully. Finding RunModule..." << std::endl;

    // Locate the RunModule function inside the DLL
    RunModuleFunc RunModule = (RunModuleFunc)GetProcAddress(hDll, "RunModule");

    if (!RunModule) {
        std::cerr << "[ERROR] Failed to find RunModule in DLL. Code: " << GetLastError() << std::endl;
        FreeLibrary(hDll);
        std::cin.get();
        return 1;
    }

    // Execute the GUI
    int result = RunModule(argc, argv);

    // Cleanup when Qt exits
    FreeLibrary(hDll);
    return result;
}