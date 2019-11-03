#pragma once
#include <iostream>

namespace ebridge {
	class Shell
	{
	public:
		std::wstring GetWorkingDirectory();
		void Open(std::wstring path);
		void New(std::wstring path);
		void Edit(std::wstring path);
	};
}
