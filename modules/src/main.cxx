#include <iostream>

module main;

import phrases;
import new_line;

int main() {
	std::cout << phrases::hello_world() << new_line::new_line();
}
