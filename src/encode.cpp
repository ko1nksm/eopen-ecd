#pragma once
#include <windows.h>
#include "encode.h"
#include "error.h"

std::string ebridge::wide2multi(std::wstring const& str, UINT codepage)
{
	LPCSTR ch = "?";
	LPCWCH src = str.data();
	int size = ::WideCharToMultiByte(codepage, 0, src, -1, nullptr, 0, ch, nullptr);
	char* dest = new char[size];
	if (::WideCharToMultiByte(codepage, 0, src, -1, dest, size, ch, nullptr) == 0) {
		throw ebridge::win32_error(::GetLastError());
	}
	std::string ret = dest;
	delete[] dest;
	return ret;
}

std::wstring ebridge::multi2wide(std::string const& str, UINT codepage)
{
	LPCSTR src = str.data();
	int const size = ::MultiByteToWideChar(codepage, 0, src, -1, nullptr, 0);
	wchar_t* dest = new wchar_t[size];
	if (::MultiByteToWideChar(codepage, 0, src, -1, dest, size) == 0) {
		throw ebridge::win32_error(::GetLastError());
	}
	std::wstring ret = dest;
	delete[] dest;
	return ret;
}
