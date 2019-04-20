#include <string>

module phrases;

import words;
import punctuations;

namespace phrases {
	std::string hello_world() {
		using namespace words;
		using namespace punctuations;
		return hello() + comma() + space() + world() + exclamation_mark();
	}
}
