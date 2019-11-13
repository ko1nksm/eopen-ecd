#pragma once
#include <iostream>

namespace util {
	class silent_error {};

	std::wstring getenv(std::wstring name, std::wstring default_value = L"");
	std::wstring normalize_path_separator(std::wstring path);
	std::wstring to_mixed_path(std::wstring path);
	bool exists_flag(std::wstring flags, std::wstring flag);
	void unicode_mode(bool);
}
