#include "state_machine.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void StateMachine::_bind_methods() {
    ClassDB::bind_method(D_METHOD("switch_states", "new_state"), &StateMachine::switch_states);
    ClassDB::bind_method(D_METHOD("check_if_can_move"), &StateMachine::check_if_can_move);
    ClassDB::bind_method(D_METHOD("on_state_interrupt", "new_state"), &StateMachine::on_state_interrupt);

    ClassDB::bind_method(D_METHOD("set_character", "character"), &StateMachine::set_character);
    ClassDB::bind_method(D_METHOD("get_character"), &StateMachine::get_character);
    ClassDB::bind_method(D_METHOD("set_current_state", "state"), &StateMachine::set_current_state);
    ClassDB::bind_method(D_METHOD("get_current_state"), &StateMachine::get_current_state);
    ClassDB::bind_method(D_METHOD("set_animation_tree", "tree"), &StateMachine::set_animation_tree);
    ClassDB::bind_method(D_METHOD("get_animation_tree"), &StateMachine::get_animation_tree);

    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "character",
        PROPERTY_HINT_NODE_TYPE, "CharacterBody2D"),
        "set_character", "get_character");
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "current_state",
        PROPERTY_HINT_NODE_TYPE, "State"),
        "set_current_state", "get_current_state");
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "animation_tree",
        PROPERTY_HINT_NODE_TYPE, "AnimationTree"),
        "set_animation_tree", "get_animation_tree");
}

void StateMachine::_ready() {
    TypedArray<Node> children = get_children();
    for (int i = 0; i < children.size(); i++) {
        Node *child_node = Object::cast_to<Node>(children[i]);
        State *s = Object::cast_to<State>(child_node);

        if (!s) {
            UtilityFunctions::push_warning(
                "Child is not a State: " + String(child_node->get_name())
            );
            continue;
        }

        s->set_character(character);

        if (animation_tree) {
            Ref<AnimationNodeStateMachinePlayback> pb =
                animation_tree->get("parameters/playback");
            s->set_playback(pb);
        }

        s->connect("interrupt_state", Callable(this, "on_state_interrupt"));
    }

    if (!current_state && get_child_count() > 0) {
        current_state = Object::cast_to<State>(get_child(0));
    }

    // Enter the initial state
    if (current_state) {
        current_state->on_enter();
    }
}

void StateMachine::_physics_process(double delta) {
    if (!current_state) return;

    State *next = current_state->get_next_state();
    if (next != nullptr && next != current_state) {
        switch_states(next);
    }

    current_state->state_process(delta);
}

void StateMachine::_input(const Ref<InputEvent> &p_event) {
    if (current_state) current_state->state_input(p_event);
}

void StateMachine::switch_states(State *p_new_state) {
    if (!p_new_state) return;
    if (current_state) {
        current_state->on_exit();
        current_state->set_next_state(nullptr);
    }
    current_state = p_new_state;
    current_state->on_enter();
}

bool StateMachine::check_if_can_move() const {
    if (!current_state) return false;
    return current_state->get_can_move();
}

void StateMachine::on_state_interrupt(State *p_new_state) {
    if (p_new_state) switch_states(p_new_state);
}

void StateMachine::set_character(CharacterBody2D *p_char)  { character = p_char; }
CharacterBody2D *StateMachine::get_character() const       { return character; }
void StateMachine::set_current_state(State *p_state)       { current_state = p_state; }
State *StateMachine::get_current_state() const             { return current_state; }
void StateMachine::set_animation_tree(AnimationTree *p_tree){ animation_tree = p_tree; }
AnimationTree *StateMachine::get_animation_tree() const    { return animation_tree; }
