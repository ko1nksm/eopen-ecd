#include "Console.h"
#include <iostream>
#include "winapi.h"

ebridge::Console::Console()
{
	handle = winapi::find_console_window();
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
