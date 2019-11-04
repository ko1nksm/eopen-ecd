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
