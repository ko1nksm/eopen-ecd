#pragma once
#include <iostream>

namespace ebridge {
	class silent_error {};

	class win32_error
	{
	public:
		win32_error(int code);
		std::wstring message();
	private:
		int code;
	};
}
