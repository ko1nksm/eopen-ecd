#pragma once
#include <iostream>

namespace ebridge {
	class Shell
	{
	public:
		std::wstring GetWorkingDirectory();
		void Open(std::wstring path, bool background = false);
		void New(std::wstring path, bool background = false);
		void Edit(std::wstring path, bool background = false);
		void Search(std::wstring query, std::wstring location, std::vector<std::wstring> crumbs, bool background = false);
		void WebSearch(std::wstring keywords, bool background = false);
		void Close();
		std::vector<std::wstring> SelectedItems();
	private:
		std::wstring NormalizePath(std::wstring path);
	};
}
