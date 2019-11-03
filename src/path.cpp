#include <windows.h>
#include <wininet.h>
#include <shlwapi.h>
#include "path.h"

namespace ebridge {
	std::wstring UriToPath(std::wstring uri) {
		DWORD length = MAX_PATH;
		WCHAR path[MAX_PATH];
		if (::PathCreateFromUrl(uri.c_str(), path, &length, NULL) != S_OK) {
			return L"";
		}
		return path;
	}

	std::wstring PathToUri(std::wstring uri) {
		DWORD length = INTERNET_MAX_URL_LENGTH;
		WCHAR path[INTERNET_MAX_URL_LENGTH];
		if (::UrlCreateFromPath(uri.c_str(), path, &length, NULL) != S_OK) {
			return L"";
		}
		return path;
	}
}
