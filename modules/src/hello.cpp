#include <string>

module hello;

import words;

std::string say_hello() {
	using namespace words;
	return hello() + std::string(", ") + world();
}
