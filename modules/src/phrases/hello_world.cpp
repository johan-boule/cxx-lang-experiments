#include <string>

module phrases;

import words;

namespace phrases {
	std::string hello_world() {
		using namespace words;
		return hello() + std::string(", ") + world();
	}
}
