#include "test.h"
#include <godot_cpp/core/print_string.hpp>

using namespace godot;

void Test::say_hello()
{
    godot::print_line("Hello from Test class!");
}

