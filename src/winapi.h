#pragma once

namespace winapi {
	enum class show
	{
		normal = SW_SHOWNORMAL,
		noactive = SW_SHOWNOACTIVATE,
	};

	class win32_error
	{
	public:
		win32_error(int code);
		std::wstring message();
	private:
		int code;
	};

	void execute(std::wstring exec, std::wstring parameters, show show);

	void set_foreground_window(long handle);
	long get_main_window_handle(const long pid);

	std::string wide2multi(std::wstring const& str, unsigned int codepage);
	std::wstring multi2wide(std::string const& str, unsigned int codepage);

	std::wstring uri2path(std::wstring uri);
	std::wstring path2uri(std::wstring uri);
}
	