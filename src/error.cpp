#include <windows.h>
#include "error.h"

namespace ebridge {
	win32_error::win32_error(int code) : code(code) {};

	std::wstring win32_error::message()
	{
		LPWSTR buffer;
		::FormatMessage(
			FORMAT_MESSAGE_ALLOCATE_BUFFER
			| FORMAT_MESSAGE_FROM_SYSTEM
			| FORMAT_MESSAGE_IGNORE_INSERTS
			| FORMAT_MESSAGE_MAX_WIDTH_MASK,
			NULL, code, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
			(LPWSTR)&buffer, 0, NULL);
		std::wstring ret = buffer;
		::LocalFree(buffer);
		return ret;
	}
}
