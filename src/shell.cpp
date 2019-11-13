#include <regex>
#include <fstream>
#include <filesystem>
#include "Shell.h"
#include "Explorer.h"
#include "util.h"
#include "winapi.h"
#import "SHELL32.dll" rename("ShellExecute", "_ShellExecute")

namespace ebridge {
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
				throw winapi::win32_error_path_not_found();
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
			Explorer explorer(browser);
			if (!explorer.Exists()) continue;
			if (explorer.GetHandle() != mainWindowHandle) continue;
			return explorer;
		}

		return Explorer();
	}

	std::wstring Shell::GetWorkingDirectory() {
		auto explorer = GetActiveExplorer();
		if (!explorer.Exists()) {
			throw std::runtime_error(
				"Explorer is not running. "
				"(Is \"Launch folder windows in a separete process\" enabled?)");
		}
		return explorer.GetPath();
	}

	void Shell::Open(std::wstring path, bool background) {
		auto explorer = GetActiveExplorer();

		if (!explorer.Exists()) {
			New(path, background);
			return;
		}

		path = AccessCheck(NormalizePath(path));
		if (path.size() > 0 && explorer.GetPath() != path) {
			explorer.Open(path);
		}

		try {
			if (path.length() > 0 && !std::filesystem::is_directory(path)) {
				return;
			}
		}
		catch (...) {} // Ignoring this error will not be a serious problem
		if (background) {
			winapi::show_window(explorer.GetHandle());
		}
		else {
			winapi::active_window(explorer.GetHandle());
		}
	}

	void Shell::New(std::wstring path, bool background) {
		if (path.empty()) {
			path = util::getenv(L"EOPEN_LAUNCH_TO", L"");
		}
		if (path.empty()) {
			// It also open same path if path is empty, but steal the focus on Windows 10.
			std::wstring key = LR"(Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced)";
			std::wstring name = L"LaunchTo";
			long launch_to = winapi::get_registry_value(key, name, 0);
			switch(launch_to) {
			case 1: // This PC
				path = L"shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}";
				break;
			case 2: // Quick access
				path = L"shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}";
				break;
			case 3: // Downloads folder (undocumented)
				path = L"shell:::{374DE290-123F-4565-9164-39C4925E467B}";
				break;
			}
		}

		path = AccessCheck(NormalizePath(path));
		auto show = background ? winapi::show::noactive : winapi::show::normal;
		winapi::execute(L"explorer.exe", path, show);
	}

	void Shell::Edit(std::wstring path, bool background)
	{
		std::wstring editor = util::getenv(L"EOPEN_EDITOR", L"notepad.exe");
		path = AccessCheck(NormalizePath(path));
		auto show = background ? winapi::show::noactive : winapi::show::normal;
		winapi::execute(editor, path, show);
	}

	void Shell::Close() {
		auto explorer = GetActiveExplorer();

		if (explorer.Exists()) {
			explorer.Close();
		}
	}

	void Shell::SelectedItems(bool mixed) {
		auto explorer = GetActiveExplorer();

		explorer.SelectedItems(mixed);
	}

	// This function returns only,
	//  * URI (expept file:) [e.g. http://example.com]
	//    * file: schema is converted to an absolute path
	//  * Absolute path   [e.g. c:\example]
	//  * UNC path        [e.g. \\wsl$\ubuntu]
	std::wstring Shell::NormalizePath(std::wstring path) {
		if (path.empty()) {
			return path;
		}

		// URI (file:)
		if (std::regex_match(path, std::wregex(L"file:.*"))) {
			path = winapi::uri2path(path);
		}

		// Explorer Location
		if (std::regex_match(path, std::wregex(LR"(:|:[\\/].*)"))) {
			std::wstring wd = GetWorkingDirectory();
			if (path.size() > 1) {
				wd = std::regex_replace(wd, std::wregex(LR"(\\$)"), L"");
			}
			return wd + util::normalize_path_separator(path.substr(1));
		}

		// Shell special folder (shell: shorthand)
		if (std::regex_match(path, std::wregex(LR"(:.*)"))) {
			return L"shell" + path;
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
}
