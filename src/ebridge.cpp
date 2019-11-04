#include <comdef.h>
#include <fcntl.h>
#include <io.h>
#include <windows.h>
#include <winerror.h>
#include <iostream>
#include <string>
#include <filesystem>
#include "shell.h"
#include "error.h"
#include "encode.h"
#include "version.h"

using namespace ebridge;

void setmode(int mode) {
	(void)_setmode(_fileno(stdout), mode);
	(void)_setmode(_fileno(stderr), mode);
}

int do_usage(std::wstring prog) {
	std::wcout << L"Usage: " + std::filesystem::path(prog).stem().wstring();
	std::wcout << " <open | new | edit | pwd | chcp | version> [<parameter>...]";
	std::wcout << std::endl;
	return 0;
}

int do_open(std::wstring path, std::wstring flags) {
	Shell shell;
	shell.Open(path, flags);
	return 0;
}

int do_new(std::wstring path, std::wstring flags) {
	Shell shell;
	shell.New(path, flags);
	return 0;
}

int do_edit(std::wstring path, std::wstring flags) {
	Shell shell;
	shell.Edit(path, flags);
	return 0;
}

int do_pwd(std::wstring codepage) {
	Shell shell;
	std::wstring dir = shell.GetWorkingDirectory();
	if (dir.empty()) return 0;

	if (codepage.empty()) {
		std::wcout << dir;
		return 0;
	}

	UINT cp;
	try {
		cp = std::stoi(codepage);
	}
	catch (...) {
		// Expected codepage is "auto" for auto detection.
		// But any invalid codepage treat same as "auto".
		cp = ::GetConsoleOutputCP();
	}

	// Replace to "?" from invalid character in the specified codepage. 
	setmode(_O_TEXT);
	std::cout << wide2multi(dir, cp);
	return 0;
}

int do_chcp(std::wstring codepage) {
	int cp = 0;

	try {
		cp = std::stoi(codepage);
	}
	catch (...) {
		throw ebridge::win32_error(ERROR_INVALID_PARAMETER);
	}

	UINT current_cp = ::GetConsoleOutputCP();
	if (cp != 0 && cp != current_cp) {
		if (::SetConsoleOutputCP(cp) == 0) {
			throw ebridge::win32_error(GetLastError());
		}
	}
	std::wcout << current_cp;
	return 0;
}

int do_version() {
	std::wcout << VERSION << std::endl;
	return 0;
}

int process(int argc, wchar_t* argv[]) {
	if (argc == 1) {
		return do_usage(argv[0]);
	}


	try {
		if (wcscmp(argv[1], L"open") == 0) {
			std::wstring path = (argc > 2) ? argv[2] : L".";
			std::wstring flags = (argc > 3) ? argv[3] : L"";
			return do_open(path, flags);
		}

		if (wcscmp(argv[1], L"new") == 0) {
			std::wstring path = (argc > 2) ? argv[2] : L".";
			std::wstring flags = (argc > 3) ? argv[3] : L"";
			return do_new(path, flags);
		}

		if (wcscmp(argv[1], L"edit") == 0) {
			std::wstring path = (argc > 2) ? argv[2] : L".";
			std::wstring flags = (argc > 3) ? argv[3] : L"";
			return do_edit(path, flags);
		}

		if (wcscmp(argv[1], L"pwd") == 0) {
			std::wstring codepage = (argc > 2) ? argv[2] : L"";
			return do_pwd(codepage);
		}

		if (wcscmp(argv[1], L"chcp") == 0) {
			std::wstring codepage = (argc > 2) ? argv[2] : L"0";
			return do_chcp(codepage);
		}

		if (wcscmp(argv[1], L"version") == 0) {
			return do_version();
			return 0;
		}

		throw ebridge::win32_error(ERROR_INVALID_FUNCTION);
	}
	catch (ebridge::win32_error & e) {
		std::wcerr << e.message() << std::endl;
	}
	catch (ebridge::silent_error) {
		// do not display anything
	}
	catch (const _com_error & e) {
		std::wcerr << e.ErrorMessage() << std::endl;
	}
	catch (std::runtime_error & e) {
		UINT cp = ::GetConsoleOutputCP();
		std::wcerr << multi2wide(e.what(), cp) << std::endl;
	}
	catch (std::exception & e) {
		std::wcerr << L"An unexpected exception occurred: ";
		UINT cp = ::GetConsoleOutputCP();
		std::wcerr << multi2wide(e.what(), cp) << std::endl;
	}
	catch (...) {
		std::wcerr << L"An unexpected error occurred" << std::endl;
	}

	return 1;
}

int wmain(int argc, wchar_t* argv[]) {
	(void)::CoInitialize(NULL);
	setmode(_O_U8TEXT);
	int ret = process(argc, argv);
	::CoUninitialize();
	return ret;
}
