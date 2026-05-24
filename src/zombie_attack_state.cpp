#include "zombie_attack_state.h"
#include <cstdlib> // for rand()
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void ZombieAttackState::_bind_methods() {
	ClassDB::bind_method(D_METHOD("on_animation_finished", "anim_name"),
						 &ZombieAttackState::on_animation_finished);

	ClassDB::bind_method(D_METHOD("set_chase_state", "state"), &ZombieAttackState::set_chase_state);
	ClassDB::bind_method(D_METHOD("get_chase_state"), &ZombieAttackState::get_chase_state);
	ClassDB::bind_method(D_METHOD("set_hitbox", "hitbox"), &ZombieAttackState::set_hitbox);
	ClassDB::bind_method(D_METHOD("get_hitbox"), &ZombieAttackState::get_hitbox);
	ClassDB::bind_method(D_METHOD("set_player", "player"), &ZombieAttackState::set_player);
	ClassDB::bind_method(D_METHOD("get_player"), &ZombieAttackState::get_player);

	ClassDB::bind_method(D_METHOD("set_attack_range", "val"), &ZombieAttackState::set_attack_range);
	ClassDB::bind_method(D_METHOD("get_attack_range"), &ZombieAttackState::get_attack_range);
	ClassDB::bind_method(D_METHOD("set_return_anim_node", "val"), &ZombieAttackState::set_return_anim_node);
	ClassDB::bind_method(D_METHOD("get_return_anim_node"), &ZombieAttackState::get_return_anim_node);
	ClassDB::bind_method(D_METHOD("set_attack_anim_1", "val"), &ZombieAttackState::set_attack_anim_1);
	ClassDB::bind_method(D_METHOD("get_attack_anim_1"), &ZombieAttackState::get_attack_anim_1);
	ClassDB::bind_method(D_METHOD("set_attack_anim_2", "val"), &ZombieAttackState::set_attack_anim_2);
	ClassDB::bind_method(D_METHOD("get_attack_anim_2"), &ZombieAttackState::get_attack_anim_2);
	ClassDB::bind_method(D_METHOD("set_attack_anim_3", "val"), &ZombieAttackState::set_attack_anim_3);
	ClassDB::bind_method(D_METHOD("get_attack_anim_3"), &ZombieAttackState::get_attack_anim_3);
	ClassDB::bind_method(D_METHOD("set_attack_cooldown", "val"), &ZombieAttackState::set_attack_cooldown);
	ClassDB::bind_method(D_METHOD("get_attack_cooldown"), &ZombieAttackState::get_attack_cooldown);

	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "attack_cooldown"),
				 "set_attack_cooldown", "get_attack_cooldown");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "chase_state",
							  PROPERTY_HINT_NODE_TYPE, "State"),
				 "set_chase_state", "get_chase_state");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "hitbox",
							  PROPERTY_HINT_NODE_TYPE, "Area2D"),
				 "set_hitbox", "get_hitbox");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "player",
							  PROPERTY_HINT_NODE_TYPE, "CharacterBody2D"),
				 "set_player", "get_player");

	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "attack_range"), "set_attack_range", "get_attack_range");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "return_anim_node"), "set_return_anim_node", "get_return_anim_node");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "attack_anim_1"), "set_attack_anim_1", "get_attack_anim_1");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "attack_anim_2"), "set_attack_anim_2", "get_attack_anim_2");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "attack_anim_3"), "set_attack_anim_3", "get_attack_anim_3");
}

// Fix on_enter() — replace Math::rand() % 3
void ZombieAttackState::on_enter() {
    if (_on_cooldown) {
        next_state = chase_state;
        return;
    }
    if (character) {
        character->set_velocity(Vector2(0.0, character->get_velocity().y));
    }

    Array attacks;
    attacks.append(attack_anim_1);
    attacks.append(attack_anim_2);
    attacks.append(attack_anim_3);
    _current_attack = attacks[rand() % 3];

    if (playback.is_valid()) {
        playback->travel(_current_attack);
    }

    // Re-add this — yokai has NO animation tracks for monitoring
    if (hitbox) {
        hitbox->call_deferred("set_monitoring", true);
    }
}

void ZombieAttackState::state_process(double delta) {
	if (_on_cooldown) {
		_cooldown_timer -= delta;
		if (_cooldown_timer <= 0.0) {
			_cooldown_timer = 0.0;
			_on_cooldown = false;
		}
	}
}

void ZombieAttackState::on_animation_finished(const StringName &anim_name) {
	if (anim_name == StringName(_current_attack)) {
		if (hitbox) {
			hitbox->set_monitoring(false);
		}
		// Start cooldown before returning to chase
		_on_cooldown = true;
		_cooldown_timer = attack_cooldown;

		next_state = chase_state;

		if (playback.is_valid()) {
			playback->travel(return_anim_node);
		}
	}
}

// Fix on_exit() — replace Vector2::ZERO
void ZombieAttackState::on_exit() {
    if (character) {
        character->set_velocity(Vector2(0, 0));
    }
    if (hitbox) {
        hitbox->call_deferred("set_monitoring",  false);
        // DO NOT set monitorable here — causes the physics lock error
    }
}
// --- Setters / Getters ---
void ZombieAttackState::set_chase_state(State *p_state) { chase_state = p_state; }
State *ZombieAttackState::get_chase_state() const { return chase_state; }
void ZombieAttackState::set_hitbox(Area2D *p_hitbox) { hitbox = p_hitbox; }
Area2D *ZombieAttackState::get_hitbox() const { return hitbox; }
void ZombieAttackState::set_player(CharacterBody2D *p) { player = p; }
CharacterBody2D *ZombieAttackState::get_player() const { return player; }

void ZombieAttackState::set_attack_range(double v) { attack_range = v; }
double ZombieAttackState::get_attack_range() const { return attack_range; }
void ZombieAttackState::set_return_anim_node(const String &v) { return_anim_node = v; }
String ZombieAttackState::get_return_anim_node() const { return return_anim_node; }
void ZombieAttackState::set_attack_anim_1(const String &v) { attack_anim_1 = v; }
String ZombieAttackState::get_attack_anim_1() const { return attack_anim_1; }
void ZombieAttackState::set_attack_anim_2(const String &v) { attack_anim_2 = v; }
String ZombieAttackState::get_attack_anim_2() const { return attack_anim_2; }
void ZombieAttackState::set_attack_anim_3(const String &v) { attack_anim_3 = v; }
String ZombieAttackState::get_attack_anim_3() const { return attack_anim_3; }
void ZombieAttackState::set_attack_cooldown(double v) { attack_cooldown = v; }
double ZombieAttackState::get_attack_cooldown() const { return attack_cooldown; }