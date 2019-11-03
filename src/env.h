#pragma once
#include <iostream>

namespace ebridge {
	std::wstring getenv(std::wstring name, std::wstring default_value = L"");
}
