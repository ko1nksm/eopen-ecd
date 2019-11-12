#pragma once
namespace ebridge {
	class Console
	{
	public:
		Console(std::wstring title);
		void SetTopMost(bool enabled);
		~Console();
	private:
		long handle = 0;
		bool initial_topmost;
	};
};
