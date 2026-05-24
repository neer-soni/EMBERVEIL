#pragma once
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/string_name.hpp>

namespace godot {

class Damageable : public Node {
    GDCLASS(Damageable, Node)

protected:
    static void _bind_methods();

    double health = 100.0;
    String dead_animation_name = "dead";

public:
    void hit(int damage, Vector2 knockback_direction);

    void set_health(double p_health);
    double get_health() const;
    void set_dead_animation_name(const String &p_name);
    String get_dead_animation_name() const;

    void on_animation_finished(const StringName &anim_name);
};

} // namespace godot
