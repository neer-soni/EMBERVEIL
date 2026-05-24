#pragma once
#include "state.h"
#include <godot_cpp/classes/character_body2d.hpp>
#include <godot_cpp/classes/collision_shape2d.hpp>

namespace godot {

class ZombieChaseState : public State {
    GDCLASS(ZombieChaseState, State)

protected:
    static void _bind_methods();

    State *walk_state   = nullptr;
    State *attack_state = nullptr;
    CharacterBody2D *player = nullptr;

    double chase_speed  = 120.0;
    double attack_range = 100.0;
    double sight_range  = 1500.0;
    String chase_anim_node = "run";

    Vector2 _get_center(CharacterBody2D *body) const;

public:
    void on_enter() override;
    void state_process(double delta) override;

    void set_walk_state(State *p_state);
    State *get_walk_state() const;
    void set_attack_state(State *p_state);
    State *get_attack_state() const;
    void set_player(CharacterBody2D *p_player);
    CharacterBody2D *get_player() const;

    void set_chase_speed(double p_val);
    double get_chase_speed() const;
    void set_attack_range(double p_val);
    double get_attack_range() const;
    void set_sight_range(double p_val);
    double get_sight_range() const;
    void set_chase_anim_node(const String &p_val);
    String get_chase_anim_node() const;
};

} // namespace godot
