#include <regex>
#include "explorer.h"
#include "util.h"
#include "winapi.h"
#import "SHELL32.dll" rename("ShellExecute", "_ShellExecute")

namespace ebridge {
	Explorer::Explorer() : Explorer(nullptr) {}

	Explorer::Explorer(const SHDocVw::IWebBrowser2Ptr window) : window(window) {}

	Explorer::~Explorer() {}

	bool Explorer::Exists()
	{
		return (bool)window;
	}

	std::wstring Explorer::GetPath()
	{
		BSTR url;
		window->get_LocationURL(&url);
		return winapi::uri2path(url);
	}

	void Explorer::Open(std::wstring path)
	{
		try {
			if (path.length() > 0) {
				window->Navigate(path.c_str());
			}
		}
		catch (const _com_error & e) {
			if (e.Error() == HRESULT_FROM_WIN32(ERROR_CANCELLED)) {
				throw util::silent_error();
			}
			throw e;
		}

	}

	void Explorer::Close()
	{
		try {
			window->Quit();
		}
		catch (const _com_error & e) {
			if (e.Error() == HRESULT_FROM_WIN32(ERROR_CANCELLED)) {
				throw util::silent_error();
			}
			throw e;
		}

	}

	std::vector<std::wstring> Explorer::SelectedItems()
	{
		auto view = (Shell32::IShellFolderViewDual2Ptr)window->GetDocument();
		auto items = view->SelectedItems();
		std::vector<std::wstring> ret;
		for (long i = 0; i < items->GetCount(); i++) {
			Shell32::FolderItem2Ptr item(items->Item(i));
			std::wstring path = (BSTR)item->GetPath();
			ret.push_back(path);
		}
		return ret;
	}

	long Explorer::GetHandle()
	{
		HWND hwnd;
		window->get_HWND((long *)&hwnd);
		return HandleToLong(hwnd);
	}
}
