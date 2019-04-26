#include <iostream>

module main;

import phrases;
import foo;

int main() {
	std::cout << phrases::hello_world() << '\n';
}
