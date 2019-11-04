#pragma once
#include <iostream>

namespace ebridge {
	class Shell
	{
	public:
		std::wstring GetWorkingDirectory();
		void Open(std::wstring path, std::wstring flags);
		void New(std::wstring path, std::wstring flags);
		void Edit(std::wstring path, std::wstring flags);
	};
}
