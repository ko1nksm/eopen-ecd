#include <regex>
#include "util.h"

std::wstring util::getenv(std::wstring name, std::wstring default_value)
{
	wchar_t* buf = nullptr;
	std::wstring ret;
	if (_wdupenv_s(&buf, NULL, name.c_str()) != 0) {
		throw std::exception("Failed to access the environment variable.");
	}
	if (!buf) return default_value;
	ret = buf;
	free(buf);
	return ret;
}

std::wstring util::normalize_path_separator(std::wstring path) {
	return std::regex_replace(path, std::wregex(L"/"), L"\\");
}

bool util::exists_flag(std::wstring flags, std::wstring flag)
{
	return (flags.find(flag) != std::string::npos);
}

void util::unicode_mode(bool enabled)
{
	int mode = enabled ? _O_U8TEXT : _O_TEXT;
	(void)_setmode(_fileno(stdout), mode);
	(void)_setmode(_fileno(stderr), mode);
}
