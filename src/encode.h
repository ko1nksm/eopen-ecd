#pragma once
#include <iostream>

namespace ebridge {
	std::string wide2multi(std::wstring const& str, UINT codepage);
	std::wstring multi2wide(std::string const& str, UINT codepage);
}
