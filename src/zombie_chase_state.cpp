#include "zombie_chase_state.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void ZombieChaseState::_bind_methods() {
	ClassDB::bind_method(D_METHOD("set_walk_state", "state"), &ZombieChaseState::set_walk_state);
	ClassDB::bind_method(D_METHOD("get_walk_state"), &ZombieChaseState::get_walk_state);
	ClassDB::bind_method(D_METHOD("set_attack_state", "state"), &ZombieChaseState::set_attack_state);
	ClassDB::bind_method(D_METHOD("get_attack_state"), &ZombieChaseState::get_attack_state);
	ClassDB::bind_method(D_METHOD("set_player", "player"), &ZombieChaseState::set_player);
	ClassDB::bind_method(D_METHOD("get_player"), &ZombieChaseState::get_player);

	ClassDB::bind_method(D_METHOD("set_chase_speed", "val"), &ZombieChaseState::set_chase_speed);
	ClassDB::bind_method(D_METHOD("get_chase_speed"), &ZombieChaseState::get_chase_speed);
	ClassDB::bind_method(D_METHOD("set_attack_range", "val"), &ZombieChaseState::set_attack_range);
	ClassDB::bind_method(D_METHOD("get_attack_range"), &ZombieChaseState::get_attack_range);
	ClassDB::bind_method(D_METHOD("set_sight_range", "val"), &ZombieChaseState::set_sight_range);
	ClassDB::bind_method(D_METHOD("get_sight_range"), &ZombieChaseState::get_sight_range);
	ClassDB::bind_method(D_METHOD("set_chase_anim_node", "val"), &ZombieChaseState::set_chase_anim_node);
	ClassDB::bind_method(D_METHOD("get_chase_anim_node"), &ZombieChaseState::get_chase_anim_node);

	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "walk_state",
							  PROPERTY_HINT_NODE_TYPE, "State"),
				 "set_walk_state", "get_walk_state");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "attack_state",
							  PROPERTY_HINT_NODE_TYPE, "State"),
				 "set_attack_state", "get_attack_state");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "player",
							  PROPERTY_HINT_NODE_TYPE, "CharacterBody2D"),
				 "set_player", "get_player");

	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "chase_speed"), "set_chase_speed", "get_chase_speed");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "attack_range"), "set_attack_range", "get_attack_range");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "sight_range"), "set_sight_range", "get_sight_range");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "chase_anim_node"), "set_chase_anim_node", "get_chase_anim_node");
}

void ZombieChaseState::on_enter() {
	if (playback.is_valid()) {
		playback->travel(chase_anim_node);
	}
	// clear next_state on enter
	next_state = nullptr;
}

void ZombieChaseState::state_process(double delta) {
	if (!player || !character) {
		if (next_state != walk_state)
			next_state = walk_state;
		return;
	}

	Vector2 player_center = _get_center(player);
	Vector2 zombie_center = _get_center(character);
	Vector2 to_player = player_center - zombie_center;
	double dist = to_player.length();

	if (dist > sight_range) {
		if (next_state != walk_state) {
			character->set_velocity(Vector2(0, character->get_velocity().y));
			next_state = walk_state;
		}
		return;
	}

	if (dist <= attack_range) {
		if (next_state != attack_state)
			next_state = attack_state;
		return;
	}

	next_state = nullptr;

	character->set_velocity(Vector2(
			(real_t)(Math::sign(to_player.x) * chase_speed),
			character->get_velocity().y));
}

Vector2 ZombieChaseState::_get_center(CharacterBody2D *body) const {
	CollisionShape2D *col = Object::cast_to<CollisionShape2D>(
			body->get_node_or_null(NodePath("CollisionShape2D")));
	if (col)
		return col->get_global_position();
	return body->get_global_position();
}

// --- Setters / Getters ---
void ZombieChaseState::set_walk_state(State *p_state) { walk_state = p_state; }
State *ZombieChaseState::get_walk_state() const { return walk_state; }
void ZombieChaseState::set_attack_state(State *p_state) { attack_state = p_state; }
State *ZombieChaseState::get_attack_state() const { return attack_state; }
void ZombieChaseState::set_player(CharacterBody2D *p) { player = p; }
CharacterBody2D *ZombieChaseState::get_player() const { return player; }

void ZombieChaseState::set_chase_speed(double v) { chase_speed = v; }
double ZombieChaseState::get_chase_speed() const { return chase_speed; }
void ZombieChaseState::set_attack_range(double v) { attack_range = v; }
double ZombieChaseState::get_attack_range() const { return attack_range; }
void ZombieChaseState::set_sight_range(double v) { sight_range = v; }
double ZombieChaseState::get_sight_range() const { return sight_range; }
void ZombieChaseState::set_chase_anim_node(const String &v) { chase_anim_node = v; }
String ZombieChaseState::get_chase_anim_node() const { return chase_anim_node; }
