#pragma once
#include <iostream>
#import <shdocvw.dll> exclude("OLECMDID", "OLECMDF", "OLECMDEXECOPT", "tagREADYSTATE")

namespace ebridge {
	class Explorer {
	public:
		Explorer();
		Explorer(SHDocVw::IWebBrowser2Ptr window);
		~Explorer();
		bool Exists();
		std::wstring GetPath();
		void Open(std::wstring path);
		HWND GetHWND();

	private:
		SHDocVw::IWebBrowser2Ptr window;
	};
}
