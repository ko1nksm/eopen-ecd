#include "window.h"

namespace ebridge {
	HWND GetMainWindowHandle(const DWORD pid) {
		HWND hwnd = ::GetTopWindow(NULL);

		do {
			if (::GetWindowLongPtr(hwnd, GWLP_HWNDPARENT) != 0) continue;
			if (!IsWindowVisible(hwnd)) continue;

			DWORD getPID;
			::GetWindowThreadProcessId(hwnd, &getPID);

			if (pid == getPID) return hwnd;
		} while ((hwnd = ::GetNextWindow(hwnd, GW_HWNDNEXT)) != NULL);

		return NULL;
	}

	void ForegroundWindow(HWND hwnd)
	{
		::ShowWindow(hwnd, SW_RESTORE);
		::SetForegroundWindow(hwnd);
		::SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
		::SetWindowPos(hwnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW | SWP_NOMOVE | SWP_NOSIZE);
	}
}
