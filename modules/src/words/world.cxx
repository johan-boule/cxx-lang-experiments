module;

#include <string>
#include <sstream>

module words;

import letters;
import dummy;

namespace words {
	std::string world() {
		dummy::dummy();
		using namespace letters;
		std::ostringstream oss;
		oss << w() << o() << r() << l() << d();
		std::string s(oss.str());
		return s;
	}
}
