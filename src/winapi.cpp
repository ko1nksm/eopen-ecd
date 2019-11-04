#include <iostream>
#include <windows.h>
#include <wininet.h>
#include <shlwapi.h>
#include "winapi.h"

namespace winapi {
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

	void execute(std::wstring exec, std::wstring parameters, show show) {
		SHELLEXECUTEINFO sei = { 0 };
		sei.cbSize = sizeof(SHELLEXECUTEINFO);
		sei.lpVerb = L"open";
		sei.lpFile = exec.c_str();
		sei.lpParameters = parameters.c_str();
		sei.nShow = (int)show;
		sei.fMask = NULL;
		::ShellExecuteEx(&sei);
	}

	void set_foreground_window(long handle)
	{
		HWND hwnd = (HWND)LongToHandle(handle);
		::ShowWindow(hwnd, SW_RESTORE);
		::SetForegroundWindow(hwnd);
		::SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
		::SetWindowPos(hwnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW | SWP_NOMOVE | SWP_NOSIZE);
	}

	long get_main_window_handle(const long pid) {
		HWND hwnd = ::GetTopWindow(NULL);

		do {
			if (::GetWindowLongPtr(hwnd, GWLP_HWNDPARENT) != 0) continue;
			if (!IsWindowVisible(hwnd)) continue;

			DWORD getPID;
			::GetWindowThreadProcessId(hwnd, &getPID);

			if (pid == getPID) return HandleToLong(hwnd);
		} while ((hwnd = ::GetNextWindow(hwnd, GW_HWNDNEXT)) != NULL);

		return NULL;
	}


	std::string wide2multi(std::wstring const& str, unsigned int codepage)
	{
		LPCSTR ch = "?";
		LPCWCH src = str.data();
		int size = ::WideCharToMultiByte(codepage, 0, src, -1, nullptr, 0, ch, nullptr);
		char* dest = new char[size];
		if (::WideCharToMultiByte(codepage, 0, src, -1, dest, size, ch, nullptr) == 0) {
			throw win32_error(::GetLastError());
		}
		std::string ret = dest;
		delete[] dest;
		return ret;
	}

	std::wstring multi2wide(std::string const& str, unsigned int codepage)
	{
		LPCSTR src = str.data();
		int const size = ::MultiByteToWideChar(codepage, 0, src, -1, nullptr, 0);
		wchar_t* dest = new wchar_t[size];
		if (::MultiByteToWideChar(codepage, 0, src, -1, dest, size) == 0) {
			throw win32_error(::GetLastError());
		}
		std::wstring ret = dest;
		delete[] dest;
		return ret;
	}

	std::wstring uri2path(std::wstring uri) {
		DWORD length = MAX_PATH;
		WCHAR path[MAX_PATH];
		if (::PathCreateFromUrl(uri.c_str(), path, &length, NULL) != S_OK) {
			return L"";
		}
		return path;
	}

	std::wstring path2uri(std::wstring uri) {
		DWORD length = INTERNET_MAX_URL_LENGTH;
		WCHAR path[INTERNET_MAX_URL_LENGTH];
		if (::UrlCreateFromPath(uri.c_str(), path, &length, NULL) != S_OK) {
			return L"";
		}
		return path;
	}
}
