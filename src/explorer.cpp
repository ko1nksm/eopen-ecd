#include "explorer.h"
#include "path.h"
#include "error.h"

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
		return UriToPath(url);
	}

	void Explorer::Open(std::wstring path)
	{
		try {
			window->Navigate(path.c_str());
		}
		catch (const _com_error & e) {
			if (e.Error() == HRESULT_FROM_WIN32(ERROR_CANCELLED)) {
				throw silent_error();
			}
			throw e;
		}

	}

	HWND Explorer::GetHWND()
	{
		HWND hwnd;
		window->get_HWND((long*)&hwnd);
		return hwnd;
	}
}
