#include <iostream>
#include "Console.h"
#include "winapi.h"

ebridge::Console::Console(std::wstring title)
{
	if (title.size() > 0) {
		for (auto h : winapi::enum_windows()) {
			std::wstring text = winapi::get_window_text(h);
			if (text.find(title) == std::string::npos) continue;
			handle = h;
			break;
		}
	}
	if (handle == 0) {
		handle = winapi::find_console_window();
	}
	initial_topmost = winapi::is_topmost_window(handle);
}

void ebridge::Console::SetTopMost(bool enabled)
{
	winapi::set_topmost_window(handle, enabled);
}

ebridge::Console::~Console()
{
	winapi::set_topmost_window(handle, initial_topmost);
}
