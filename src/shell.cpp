#include <regex>
#include <fstream>
#include <filesystem>
#include "Shell.h"
#include "Explorer.h"
#include "util.h"
#include "winapi.h"
#import "SHELL32.dll" rename("ShellExecute", "_ShellExecute")

namespace ebridge {
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
			return util::normalize_path_separator(path);
		}

		// URI (expept file:)
		if (std::regex_match(path, std::wregex(L"[a-zA-Z0-9.+-]+:.*"))) {
			return path;
		}

		// UNC Path
		if (std::regex_match(path, std::wregex(LR"([\\/][\\/].*)"))) {
			return util::normalize_path_separator(path);
		}

		std::wstring cwd = std::filesystem::current_path();

		// Absolute Path without drive letter
		if (std::regex_match(path, std::wregex(LR"([\\/].*)"))) {
			cwd.resize(cwd.find(L"\\")); // To append drive letter if exists
			return util::normalize_path_separator(cwd + path);
		}

		// Relative path
		if (cwd.back() == L'\\') cwd.pop_back();
		return util::normalize_path_separator(cwd + L"\\" + path);
	}

	void AccessCheck(std::wstring path) {
		// UNC that Host name only
		if (std::regex_match(path, std::wregex(LR"([\\/][\\/][^\\]+(|\\))"))) {
			return;
		}

		// URI (does not start with a drive letter)
		if (!std::regex_match(path, std::wregex(L"[a-zA-Z]:.*"))) {
			return;
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
	}

	Explorer GetActiveExplorer() {
		long mainWindowHandle = 0;
		auto entries = winapi::get_process_entries(L"explorer.exe");
		for (auto entry : entries) {
			if (entry.window_text_length > 0) {
				mainWindowHandle = entry.window_handle;
			}
		}
		if (mainWindowHandle == 0) return Explorer();

		SHDocVw::IShellWindowsPtr shellWindows;
		shellWindows.CreateInstance(__uuidof(SHDocVw::ShellWindows));
		const long count = shellWindows->GetCount();
		for (long i = 0; i < count; i++) {
			SHDocVw::IWebBrowser2Ptr browser(shellWindows->Item(i));
			Explorer window(browser);
			if (!window.Exists()) continue;
			if (window.GetHandle() != mainWindowHandle) continue;
			return window;
		}

		return Explorer();
	}

	std::wstring Shell::GetWorkingDirectory() {
		auto window = GetActiveExplorer();
		if (!window.Exists()) {
			throw std::runtime_error(
				"Explorer is not running. "
				"(Is \"Launch folder windows in a separete process\" enabled?)");
		}
		return window.GetPath();
	}

	void Shell::Open(std::wstring path, bool background) {
		auto window = GetActiveExplorer();

		if (!window.Exists()) {
			New(path, background);
			return;
		}

		AccessCheck(NormalizePath(path));
		window.Open(path);
		if (background) return;
		try {
			if (!std::filesystem::is_directory(path)) return;
		}
		catch (...) {} // Ignoring this error will not be a serious problem
		winapi::bring_window_to_top(window.GetHandle());
	}

	void Shell::New(std::wstring path, bool background) {
		AccessCheck(NormalizePath(path));
		auto show = background ? winapi::show::noactive : winapi::show::normal;
		winapi::execute(L"explorer.exe", path, show);
	}

	void Shell::Edit(std::wstring path, bool background)
	{
		std::wstring editor = util::getenv(L"EOPEN_EDITOR", L"notepad.exe");
		AccessCheck(NormalizePath(path));
		auto show = background ? winapi::show::noactive : winapi::show::normal;
		winapi::execute(editor, path, show);
	}
}
