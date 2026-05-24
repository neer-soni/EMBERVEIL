#include "hit_state.h"
#include "state_machine.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void HitState::_bind_methods() {
    ClassDB::bind_method(D_METHOD("on_damageable_hit", "node", "damage_amount", "knockback_direction"),
        &HitState::on_damageable_hit);
    ClassDB::bind_method(D_METHOD("on_timer_timeout"),
        &HitState::on_timer_timeout);

    ClassDB::bind_method(D_METHOD("set_damageable", "val"),               &HitState::set_damageable);
    ClassDB::bind_method(D_METHOD("get_damageable"),                       &HitState::get_damageable);
    ClassDB::bind_method(D_METHOD("set_character_state_machine", "val"),  &HitState::set_character_state_machine);
    ClassDB::bind_method(D_METHOD("get_character_state_machine"),          &HitState::get_character_state_machine);
    ClassDB::bind_method(D_METHOD("set_dead_state", "val"),               &HitState::set_dead_state);
    ClassDB::bind_method(D_METHOD("get_dead_state"),                       &HitState::get_dead_state);
    ClassDB::bind_method(D_METHOD("set_return_state", "val"),             &HitState::set_return_state);
    ClassDB::bind_method(D_METHOD("get_return_state"),                     &HitState::get_return_state);

    ClassDB::bind_method(D_METHOD("set_hurt_animation",     "val"), &HitState::set_hurt_animation);
    ClassDB::bind_method(D_METHOD("get_hurt_animation"),            &HitState::get_hurt_animation);
    ClassDB::bind_method(D_METHOD("set_dead_animation_node","val"), &HitState::set_dead_animation_node);
    ClassDB::bind_method(D_METHOD("get_dead_animation_node"),       &HitState::get_dead_animation_node);
    ClassDB::bind_method(D_METHOD("set_knockback_speed",    "val"), &HitState::set_knockback_speed);
    ClassDB::bind_method(D_METHOD("get_knockback_speed"),           &HitState::get_knockback_speed);

    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "damageable",
        PROPERTY_HINT_NODE_TYPE, "Damageable"),
        "set_damageable", "get_damageable");
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "character_state_machine",
        PROPERTY_HINT_NODE_TYPE, "StateMachine"),
        "set_character_state_machine", "get_character_state_machine");
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "dead_state",
        PROPERTY_HINT_NODE_TYPE, "State"),
        "set_dead_state", "get_dead_state");
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "return_state",
        PROPERTY_HINT_NODE_TYPE, "State"),
        "set_return_state", "get_return_state");

    ADD_PROPERTY(PropertyInfo(Variant::STRING, "hurt_animation"),      "set_hurt_animation",      "get_hurt_animation");
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "dead_animation_node"), "set_dead_animation_node", "get_dead_animation_node");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT,  "knockback_speed"),     "set_knockback_speed",     "get_knockback_speed");
}

void HitState::_ready() {
    if (damageable) {
        damageable->connect("on_hit", Callable(this, "on_damageable_hit"));
    }

    // Cast manually instead of templated get_node_or_null
    Node *timer_node = get_node_or_null(NodePath("Timer"));
    Timer *timer = Object::cast_to<Timer>(timer_node);
    if (timer) {
        timer->connect("timeout", Callable(this, "on_timer_timeout"));
    }
}

void HitState::on_enter() {
    if (character_state_machine) {
        _previous_state = character_state_machine->get_current_state();
    }
    if (playback.is_valid()) {
        playback->travel(hurt_animation);
    }

    Node *timer_node = get_node_or_null(NodePath("Timer"));
    Timer *timer = Object::cast_to<Timer>(timer_node);
    if (timer) {
        timer->set_one_shot(true);
        timer->start();
    }
}

void HitState::on_damageable_hit(Node *node, int damage_amount, Vector2 knockback_direction) {
    if (!damageable) return;

    if (damageable->get_health() <= 0) {
        // Zero velocity before going to dead state
        if (character) {
            character->set_velocity(Vector2(0, 0));
        }
        emit_signal("interrupt_state", dead_state);
        if (playback.is_valid()) {
            playback->travel(dead_animation_node);
        }
        return;
    }

    if (character) {
        character->set_velocity(knockback_direction * (real_t)knockback_speed);
    }
    emit_signal("interrupt_state", this);
}

void HitState::on_exit() {
    if (character) {
        character->set_velocity(Vector2(0, 0));
    }
}

void HitState::on_timer_timeout() {
    if (_previous_state != nullptr
        && _previous_state != this
        && _previous_state != dead_state) {
        next_state = _previous_state;
    } else {
        next_state = return_state;
    }
}

// --- Setters / Getters ---
void HitState::set_damageable(Damageable *p)              { damageable = p; }
Damageable *HitState::get_damageable() const              { return damageable; }
void HitState::set_character_state_machine(StateMachine *p){ character_state_machine = p; }
StateMachine *HitState::get_character_state_machine() const{ return character_state_machine; }
void HitState::set_dead_state(State *p)                   { dead_state = p; }
State *HitState::get_dead_state() const                   { return dead_state; }
void HitState::set_return_state(State *p)                 { return_state = p; }
State *HitState::get_return_state() const                 { return return_state; }

void HitState::set_hurt_animation(const String &v)        { hurt_animation = v; }
String HitState::get_hurt_animation() const               { return hurt_animation; }
void HitState::set_dead_animation_node(const String &v)   { dead_animation_node = v; }
String HitState::get_dead_animation_node() const          { return dead_animation_node; }
void HitState::set_knockback_speed(double v)              { knockback_speed = v; }
double HitState::get_knockback_speed() const              { return knockback_speed; }
