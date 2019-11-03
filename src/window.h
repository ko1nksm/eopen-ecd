#pragma once
#include <windows.h>

namespace ebridge {
	HWND GetMainWindowHandle(const DWORD pid);
	void ForegroundWindow(HWND hwnd);
}
