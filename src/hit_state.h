#pragma once
#include "state.h"
#include "damageable.h"
#include <godot_cpp/classes/character_body2d.hpp>
#include <godot_cpp/classes/timer.hpp>

namespace godot {

class StateMachine;

class HitState : public State {
    GDCLASS(HitState, State)

protected:
    static void _bind_methods();

    Damageable  *damageable           = nullptr;
    StateMachine *character_state_machine = nullptr;
    State       *dead_state           = nullptr;
    State       *return_state         = nullptr;
    State       *_previous_state      = nullptr;

    String hurt_animation     = "hurt";
    String dead_animation_node = "dead";
    double knockback_speed    = 400.0;

public:
    void _ready() override;
    void on_enter() override;
    void on_exit() override;

    void on_damageable_hit(Node *node, int damage_amount, Vector2 knockback_direction);
    void on_timer_timeout();

    void set_damageable(Damageable *p_val);
    Damageable *get_damageable() const;
    void set_character_state_machine(StateMachine *p_val);
    StateMachine *get_character_state_machine() const;
    void set_dead_state(State *p_val);
    State *get_dead_state() const;
    void set_return_state(State *p_val);
    State *get_return_state() const;

    void set_hurt_animation(const String &p_val);
    String get_hurt_animation() const;
    void set_dead_animation_node(const String &p_val);
    String get_dead_animation_node() const;
    void set_knockback_speed(double p_val);
    double get_knockback_speed() const;
};

} // namespace godot
