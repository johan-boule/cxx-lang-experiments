module;

#include <string>
#include <sstream>

module words;

import letters;
import dummy;

namespace words {
	std::string hello() {
		dummy::dummy();
		using namespace letters;
		std::ostringstream oss;
		oss << h() << e() << l() << l() << o();
		std::string s(oss.str());
		return s;
	}
}
