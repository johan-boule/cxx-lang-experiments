#include <string>
#include <sstream>

module words;

import letters;

namespace words {
	std::string world() {
		using namespace letters;
		std::ostringstream oss;
		oss << w() << o() << r() << l() << d();
		std::string s(oss.str());
		return s;
	}
}
