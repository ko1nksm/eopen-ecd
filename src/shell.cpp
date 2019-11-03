#include <shlwapi.h>
#include <tlhelp32.h>
#include <windows.h>
#include <regex>
#include <fstream>
#include <filesystem>
#include "shell.h"
#include "explorer.h"
#include "path.h"
#include "error.h"
#include "window.h"
#include "env.h"
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
			path = UriToPath(path);
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
				throw win32_error(ERROR_PATH_NOT_FOUND);
			}
		}
		catch (const std::filesystem::filesystem_error & e) {
			const int code = e.code().value();
			switch (code) {
			case ERROR_NOT_SUPPORTED:
				// Provides an opportunity for authentication for CIFS access.
				break;
			default:
				throw win32_error(code);
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
			HWND hwnd = GetMainWindowHandle(process.th32ProcessID);
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

		const HWND mainWindowHandle = GetMainWindowHandle(pid);
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

	void Shell::Open(std::wstring path) {
		Explorer window = GetActiveExplorer();

		if (!window.Exists()) {
			New(path);
			return;
		}

		path = AccessCheck(NormalizePath(path));
		window.Open(path);
		try {
			if (!std::filesystem::is_directory(path)) return;
		}
		catch (...) {} // Ignoring this error will not be a serious problem
		ForegroundWindow(window.GetHWND());
	}

	void Shell::New(std::wstring path) {
		path = AccessCheck(NormalizePath(path));

		SHELLEXECUTEINFO sei = { 0 };
		sei.cbSize = sizeof(SHELLEXECUTEINFO);
		sei.lpVerb = L"open";
		sei.lpFile = path.c_str();
		sei.nShow = SW_SHOWNORMAL;
		sei.fMask = NULL;
		::ShellExecuteEx(&sei);
	}

	void Shell::Edit(std::wstring path)
	{
		std::wstring editor = getenv(L"EOPEN_EDITOR", L"notepad.exe");
		path = AccessCheck(NormalizePath(path));
		SHELLEXECUTEINFO sei = { 0 };
		sei.cbSize = sizeof(SHELLEXECUTEINFO);
		sei.lpVerb = L"open";
		sei.lpFile = editor.c_str();
		sei.lpParameters = path.c_str();
		sei.nShow = SW_SHOWNORMAL;
		sei.fMask = NULL;
		::ShellExecuteEx(&sei);
	}
}
