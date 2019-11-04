#include <shlwapi.h>
#include <tlhelp32.h>
#include <windows.h>
#include <regex>
#include <fstream>
#include <filesystem>
#include "Shell.h"
#include "Explorer.h"
#include "util.h"
#include "winapi.h"
#import "SHELL32.dll" rename("ShellExecute", "_ShellExecute")

namespace ebridge {
	std::wstring SlashToBackslash(std::wstring path) {
		return std::regex_replace(path, std::wregex(L"/"), L"\\");
	}

	// This function returns only,
	//  * URI (expept file:) [e.g. http://example.com]
	//    * file: schema is converted to an absolute path
	//  * Absolute path   [e.g. c:\example]
	//  * UNC path        [e.g. \\wsl$\ubuntu]
	std::wstring NormalizePath(std::wstring path) {
		// URI (file:)
		if (std::regex_match(path, std::wregex(L"file:.*"))) {
			path = winapi::uri2path(path);
		}

		// Absolute Path with a drive letter
		if (std::regex_match(path, std::wregex(L"[a-zA-Z]:.*"))) {
			return SlashToBackslash(path);
		}

		// URI (expept file:)
		if (std::regex_match(path, std::wregex(L"[a-zA-Z0-9.+-]+:.*"))) {
			return path;
		}

		// UNC Path
		if (std::regex_match(path, std::wregex(LR"([\\/][\\/].*)"))) {
			return SlashToBackslash(path);
		}

		std::wstring cwd = std::filesystem::current_path();

		// Absolute Path without drive letter
		if (std::regex_match(path, std::wregex(LR"([\\/].*)"))) {
			cwd.resize(cwd.find(L"\\")); // To append drive letter if exists
			return SlashToBackslash(cwd + path);
		}

		// Relative path
		if (cwd.back() == L'\\') cwd.pop_back();
		return SlashToBackslash(cwd + L"\\" + path);
	}

	std::wstring AccessCheck(std::wstring path) {
		// UNC that Host name only
		if (std::regex_match(path, std::wregex(LR"([\\/][\\/][^\\]+(|\\))"))) {
			return path;
		}

		// URI (does not start with a drive letter)
		if (!std::regex_match(path, std::wregex(L"[a-zA-Z]:.*"))) {
			return path;
		}

		// Absolute path or UNC with path
		try {
			if (!std::filesystem::exists(path)) {
				throw winapi::win32_error(ERROR_PATH_NOT_FOUND);
			}
		}
		catch (const std::filesystem::filesystem_error & e) {
			const int code = e.code().value();
			switch (code) {
			case ERROR_NOT_SUPPORTED:
				// Provides an opportunity for authentication for CIFS access.
				break;
			default:
				throw winapi::win32_error(code);
			}
		}
		return path;
	}

	DWORD GetActiveExplorerPID() {
		HANDLE handle = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS | TH32CS_SNAPMODULE, 0);
		if (!handle) return 0;

		PROCESSENTRY32 process = { sizeof(PROCESSENTRY32) };
		::Process32First(handle, &process);

		do {
			if (wcscmp(process.szExeFile, L"explorer.exe") != 0) continue;
			HWND hwnd = (HWND)LongToHandle(winapi::get_main_window_handle(process.th32ProcessID));
			if (::GetWindowTextLength(hwnd) > 0) {
				CloseHandle(handle);
				return process.th32ProcessID;
			}
		} while (::Process32Next(handle, &process));

		::CloseHandle(handle);
		return 0;
	}

	Explorer GetActiveExplorer() {
		SHDocVw::IShellWindowsPtr shellWindows;
		shellWindows.CreateInstance(__uuidof(SHDocVw::ShellWindows));

		const DWORD pid = GetActiveExplorerPID();
		if (pid == 0) return Explorer();

		HWND mainWindowHandle = (HWND)LongToHandle(winapi::get_main_window_handle(pid));
		if (mainWindowHandle == NULL) return Explorer();

		const long count = shellWindows->GetCount();

		for (long i = 0; i < count; i++) {
			SHDocVw::IWebBrowser2Ptr browser(shellWindows->Item(i));
			Explorer window(browser);
			if (!window.Exists()) continue;
			if (window.GetHWND() != mainWindowHandle) continue;
			return window;
		}

		return Explorer();
	}

	std::wstring Shell::GetWorkingDirectory() {
		Explorer window = GetActiveExplorer();
		if (!window.Exists()) {
			throw std::runtime_error(
				"Explorer is not running. "
				"(Is \"Launch folder windows in a separete process\" enabled?)");
		}
		return window.GetPath();
	}

	void Shell::Open(std::wstring path, std::wstring flags) {
		Explorer window = GetActiveExplorer();

		if (!window.Exists()) {
			New(path, flags);
			return;
		}

		path = AccessCheck(NormalizePath(path));
		window.Open(path);
		if (flags.find(L"b") != std::string::npos) return;
		try {
			if (!std::filesystem::is_directory(path)) return;
		}
		catch (...) {} // Ignoring this error will not be a serious problem
		winapi::set_foreground_window(HandleToLong(window.GetHWND()));
	}

	void Shell::New(std::wstring path, std::wstring flags) {
		path = AccessCheck(NormalizePath(path));
		if (flags.find(L"b") == std::string::npos) {
			winapi::execute(L"explorer.exe", path, winapi::show::normal);
		}
		else {
			winapi::execute(L"explorer.exe", path, winapi::show::noactive);
		}
	}

	void Shell::Edit(std::wstring path, std::wstring flags)
	{
		std::wstring editor = util::getenv(L"EOPEN_EDITOR", L"notepad.exe");
		path = AccessCheck(NormalizePath(path));
		if (flags.find(L"b") == std::string::npos) {
			winapi::execute(editor, path, winapi::show::normal);
		}
		else {
			winapi::execute(editor, path, winapi::show::noactive);
		}
	}
}
