#pragma once
#include "state.h"
#include <godot_cpp/classes/area2d.hpp>
#include <godot_cpp/classes/character_body2d.hpp>

namespace godot {

class ZombieAttackState : public State {
	GDCLASS(ZombieAttackState, State)

protected:
	static void _bind_methods();

	State *chase_state = nullptr;
	Area2D *hitbox = nullptr;
	CharacterBody2D *player = nullptr;

	double attack_range = 80.0;
	String return_anim_node = "run";
	String attack_anim_1 = "Attack1";
	String attack_anim_2 = "Attack2";
	String attack_anim_3 = "Attack3";

	String _current_attack = "";

	double attack_cooldown = 2.0; // seconds between attacks
	double _cooldown_timer = 0.0;
	bool _on_cooldown = false;

public:
	void on_enter() override;
	void on_exit() override;
	void on_animation_finished(const StringName &anim_name);

	void set_attack_cooldown(double p_val);
	void set_chase_state(State *p_state);
	State *get_chase_state() const;
	void set_hitbox(Area2D *p_hitbox);
	Area2D *get_hitbox() const;
	void set_player(CharacterBody2D *p_player);
	CharacterBody2D *get_player() const;

	void set_attack_range(double p_val);
	double get_attack_range() const;
	void set_return_anim_node(const String &p_val);
	String get_return_anim_node() const;
	void set_attack_anim_1(const String &p_val);
	String get_attack_anim_1() const;
	void set_attack_anim_2(const String &p_val);
	String get_attack_anim_2() const;
	void set_attack_anim_3(const String &p_val);
	String get_attack_anim_3() const;
	double get_attack_cooldown() const;
	void state_process(double delta) override; // ADD THIS
};

} // namespace godot
