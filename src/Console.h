#pragma once
namespace ebridge {
	class Console
	{
	public:
		Console();
		void SetTopMost(bool enabled);
		~Console();
	private:
		long handle;
		bool initial_topmost;
	};
};

