#pragma once
#include <iostream>

namespace util {
	class silent_error {};

	std::wstring getenv(std::wstring name, std::wstring default_value = L"");
}
