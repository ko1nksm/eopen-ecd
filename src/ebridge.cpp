#include <array>  
#include <iostream>
#include <string>
#include <filesystem>
#include <comdef.h>
#include "Console.h"
#include "Shell.h"
#include "util.h"
#include "version.h"
#include "winapi.h"

using namespace ebridge;

int do_usage(std::wstring prog) {
	std::wcout << L"Usage: " + std::filesystem::path(prog).stem().wstring();
	std::wcout << " <open | new | edit | close | pwd | chcp | env | version> [<parameter>...]";
	std::wcout << std::endl;
	return 0;
}

int do_open(std::vector<std::wstring> params) {
	std::wstring path = params.size() >= 1 ? params[0] : L"";
	std::wstring flags = params.size() >= 2 ? params[1] : L"";
	std::wstring title = params.size() >= 3 ? params[2] : L"";

	Console console(title);
	console.SetTopMost(true);
	Shell shell;
	bool background = util::exists_flag(flags, L"b");
	shell.Open(path, background);
	return 0;
}

int do_new(std::vector<std::wstring> params) {
	Shell shell;
	std::wstring path = params.size() >= 1 ? params[0] : L"";
	std::wstring flags = params.size() >= 2 ? params[1] : L"";
	bool background = util::exists_flag(flags, L"b");
	shell.New(path, background);
	return 0;
}

int do_edit(std::vector<std::wstring> params) {
	Shell shell;
	std::wstring path = params.size() >= 1 ? params[0] : L"";
	std::wstring flags = params.size() >= 2 ? params[1] : L"";
	bool background = util::exists_flag(flags, L"b");
	shell.Edit(path, background);
	return 0;
}

int do_close(std::vector<std::wstring> params) {
	Shell shell;
	shell.Close();
	return 0;
}

int do_list_selected_items(std::vector<std::wstring> params) {
	Shell shell;
	std::wstring flags = params.size() >= 1 ? params[0] : L"";
	bool mixed = util::exists_flag(flags, L"m");
	shell.SelectedItems(mixed);
	return 0;
}

int do_pwd(std::vector<std::wstring> params) {
	Shell shell;
	std::wstring codepage = params.size() >= 1 ? params[0] : L"";
	std::wstring dir = shell.GetWorkingDirectory();
	if (dir.empty()) return 0;

	if (codepage.empty()) {
		std::wcout << dir;
		return 0;
	}

	unsigned int cp;
	try {
		cp = std::stoi(codepage);
	}
	catch (...) {
		// Expected codepage is "auto" for auto detection.
		// But any invalid codepage treat same as "auto".
		cp = winapi::get_console_output_codepage();
	}

	// Replace to "?" from invalid character in the specified codepage. 
	util::unicode_mode(false);
	std::cout << winapi::wide2multi(dir, cp);
	return 0;
}

int do_chcp(std::vector<std::wstring> params) {
	std::wstring codepage = params.size() >= 1 ? params[0] : L"0";
	int cp = 0;

	try {
		cp = std::stoi(codepage);
	}
	catch (...) {
		throw winapi::win32_error_invalid_parameter();
	}

	unsigned int previous_cp = winapi::set_console_output_codepage(cp);
	std::wcout << previous_cp;
	return 0;
}

int do_env(std::vector<std::wstring> params) {
	std::wstring name = params.size() >= 1 ? params[0] : L"";
	std::wcout << util::getenv(name);
	return 0;
}

int do_version() {
	std::wcout << VERSION << std::endl;
	return 0;
}

int process(int argc, wchar_t* argv[]) {
	try {
		if (argc == 1) {
			return do_usage(argv[0]);
		}

		std::wstring func = argv[1];
		std::vector<std::wstring> params;
		for (int i = 2; i < argc; i++) {
			params.push_back(argv[i]);
		}

		if (func == L"open")    return do_open(params);
		if (func == L"new")     return do_new(params);
		if (func == L"edit")    return do_edit(params);
		if (func == L"close")   return do_close(params);
		if (func == L"lsi")     return do_list_selected_items(params);
		if (func == L"pwd")     return do_pwd(params);
		if (func == L"chcp")    return do_chcp(params);
		if (func == L"env")     return do_env(params);
		if (func == L"version") return do_version();
		throw winapi::win32_error_invalid_function();
	}
	catch (winapi::win32_error & e) {
		std::wcerr << e.message() << std::endl;
	}
	catch (util::silent_error) {
		// do not display anything
	}
	catch (const _com_error & e) {
		std::wcerr << e.ErrorMessage() << std::endl;
	}
	catch (std::runtime_error & e) {
		unsigned int cp = winapi::get_console_output_codepage();
		std::wcerr << winapi::multi2wide(e.what(), cp) << std::endl;
	}
	catch (std::exception & e) {
		std::wcerr << L"An unexpected exception occurred: ";
		unsigned int cp = winapi::get_console_output_codepage();
		std::wcerr << winapi::multi2wide(e.what(), cp) << std::endl;
	}
	catch (...) {
		std::wcerr << L"An unexpected error occurred" << std::endl;
	}

	return 1;
}

int wmain(int argc, wchar_t* argv[]) {
	(void)::CoInitialize(NULL);
	util::unicode_mode(true);
	int ret = process(argc, argv);
	::CoUninitialize();
	return ret;
}
