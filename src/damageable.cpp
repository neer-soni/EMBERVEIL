#include "damageable.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void Damageable::_bind_methods() {
    ClassDB::bind_method(D_METHOD("hit", "damage", "knockback_direction"),
        &Damageable::hit);
    ClassDB::bind_method(D_METHOD("on_animation_finished", "anim_name"),
        &Damageable::on_animation_finished);

    ClassDB::bind_method(D_METHOD("set_health", "health"), &Damageable::set_health);
    ClassDB::bind_method(D_METHOD("get_health"), &Damageable::get_health);
    ClassDB::bind_method(D_METHOD("set_dead_animation_name", "name"),
        &Damageable::set_dead_animation_name);
    ClassDB::bind_method(D_METHOD("get_dead_animation_name"),
        &Damageable::get_dead_animation_name);

    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "health"),
        "set_health", "get_health");
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "dead_animation_name"),
        "set_dead_animation_name", "get_dead_animation_name");

    // Signals
    ADD_SIGNAL(MethodInfo("on_hit",
        PropertyInfo(Variant::OBJECT, "node"),
        PropertyInfo(Variant::INT,    "damage_taken"),
        PropertyInfo(Variant::VECTOR2,"knockback_direction")));
}

void Damageable::set_health(double p_health) { health = p_health; }
double Damageable::get_health() const { return health; }
void Damageable::set_dead_animation_name(const String &p_name) {
    dead_animation_name = p_name;
}
String Damageable::get_dead_animation_name() const { return dead_animation_name; }

void Damageable::hit(int damage, Vector2 knockback_direction) {
    health -= damage;
    emit_signal("on_hit", get_parent(), damage, knockback_direction);
}

void Damageable::on_animation_finished(const StringName &anim_name) {
    if (anim_name == StringName(dead_animation_name)) {
        if (get_parent()) {
            get_parent()->queue_free();
        }
    }
}
