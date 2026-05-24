#include <gdextension_interface.h>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

// Include your classes as you create them
#include "state.h"
#include "state_machine.h"
#include "damageable.h"        // uncomment when ready
#include "zombie_chase_state.h"
#include "zombie_attack_state.h"
#include "hit_state.h"

using namespace godot;

void initialize_gdextension_types(ModuleInitializationLevel p_level)
{
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    // Register in dependency order — base classes first
    ClassDB::register_class<State>();
    ClassDB::register_class<StateMachine>();
    ClassDB::register_class<Damageable>();
    ClassDB::register_class<ZombieChaseState>();
    ClassDB::register_class<ZombieAttackState>();
    ClassDB::register_class<HitState>();
}

void uninitialize_gdextension_types(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}

extern "C"
{
    GDExtensionBool GDE_EXPORT test_plugin_init(
        GDExtensionInterfaceGetProcAddress p_get_proc_address,
        GDExtensionClassLibraryPtr p_library,
        GDExtensionInitialization *r_initialization)
    {
        GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);
        init_obj.register_initializer(initialize_gdextension_types);
        init_obj.register_terminator(uninitialize_gdextension_types);
        init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

        return init_obj.init();
    }
}
