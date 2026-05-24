#pragma once
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/animation_tree.hpp>
#include <godot_cpp/classes/character_body2d.hpp>
#include "state.h"

namespace godot {

class StateMachine : public Node {
    GDCLASS(StateMachine, Node)

protected:
    static void _bind_methods();

    CharacterBody2D *character = nullptr;
    State *current_state = nullptr;
    AnimationTree *animation_tree = nullptr;

public:
    void _ready() override;
    void _physics_process(double delta) override;
    void _input(const Ref<InputEvent> &p_event) override;

    void switch_states(State *p_new_state);
    bool check_if_can_move() const;
    void on_state_interrupt(State *p_new_state);

    void set_character(CharacterBody2D *p_char);
    CharacterBody2D *get_character() const;
    void set_current_state(State *p_state);
    State *get_current_state() const;
    void set_animation_tree(AnimationTree *p_tree);
    AnimationTree *get_animation_tree() const;
};

} // namespace godot
