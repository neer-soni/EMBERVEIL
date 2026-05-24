#include "state.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void State::_bind_methods() {
    ClassDB::bind_method(D_METHOD("state_process", "delta"), &State::state_process);
    ClassDB::bind_method(D_METHOD("state_input", "event"), &State::state_input);
    ClassDB::bind_method(D_METHOD("on_enter"), &State::on_enter);
    ClassDB::bind_method(D_METHOD("on_exit"), &State::on_exit);
    ClassDB::bind_method(D_METHOD("emit_interrupt", "new_state"), &State::emit_interrupt);

    ClassDB::bind_method(D_METHOD("set_character", "character"), &State::set_character);
    ClassDB::bind_method(D_METHOD("get_character"), &State::get_character);
    ClassDB::bind_method(D_METHOD("set_playback", "playback"), &State::set_playback);
    ClassDB::bind_method(D_METHOD("get_playback"), &State::get_playback);
    ClassDB::bind_method(D_METHOD("set_next_state", "state"), &State::set_next_state);
    ClassDB::bind_method(D_METHOD("get_next_state"), &State::get_next_state);
    ClassDB::bind_method(D_METHOD("set_can_move", "val"), &State::set_can_move);
    ClassDB::bind_method(D_METHOD("get_can_move"), &State::get_can_move);

    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "can_move"), "set_can_move", "get_can_move");

    ADD_SIGNAL(MethodInfo("interrupt_state",
        PropertyInfo(Variant::OBJECT, "new_state", PROPERTY_HINT_NODE_TYPE, "State")));
}

void State::state_process(double delta) {}
void State::state_input(const Ref<InputEvent> &p_event) {}
void State::on_enter() {}
void State::on_exit() {}

void State::emit_interrupt(State *p_new_state) {
    emit_signal("interrupt_state", p_new_state);
}

void State::set_character(CharacterBody2D *p_char) { character = p_char; }
CharacterBody2D *State::get_character() const { return character; }

void State::set_playback(const Ref<AnimationNodeStateMachinePlayback> &p_pb) { playback = p_pb; }
Ref<AnimationNodeStateMachinePlayback> State::get_playback() const { return playback; }

void State::set_next_state(State *p_state) { next_state = p_state; }
State *State::get_next_state() const { return next_state; }

void State::set_can_move(bool p_val) { can_move = p_val; }
bool State::get_can_move() const { return can_move; }
