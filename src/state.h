#pragma once
// Try these instead

#include <godot_cpp/classes/animation_node_state_machine_playback.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/classes/character_body2d.hpp>
#include <godot_cpp/classes/animation_node_state_machine_playback.hpp>
#include <godot_cpp/variant/string_name.hpp>

namespace godot {

class State : public Node {
    GDCLASS(State, Node)

protected:
    static void _bind_methods();

    CharacterBody2D *character = nullptr;
    Ref<AnimationNodeStateMachinePlayback> playback;
    State *next_state = nullptr;
    bool can_move = true;

public:
    virtual void state_process(double delta);
    virtual void state_input(const Ref<InputEvent> &p_event);
    virtual void on_enter();
    virtual void on_exit();

    void emit_interrupt(State *p_new_state);

    // Setters/getters for GDScript bridge
    void set_character(CharacterBody2D *p_char);
    CharacterBody2D *get_character() const;

    void set_playback(const Ref<AnimationNodeStateMachinePlayback> &p_pb);
    Ref<AnimationNodeStateMachinePlayback> get_playback() const;

    void set_next_state(State *p_state);
    State *get_next_state() const;

    void set_can_move(bool p_val);
    bool get_can_move() const;
};

} // namespace godot
