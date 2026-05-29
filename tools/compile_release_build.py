import os
import sys
import subprocess

# Go up one level from tools/ to reach the project root (where SConstruct lives)
script_dir   = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(script_dir)


def read_dont_touch():
    """Read plugin name and godot version from dont_touch.txt."""
    try:
        with open(os.path.join(project_root, "dont_touch.txt"), "r") as file:
            lines = file.readlines()
            if len(lines) < 2:
                raise ValueError("dont_touch.txt does not have at least two lines")
            return lines[0].strip(), lines[1].strip()
    except (FileNotFoundError, IOError, ValueError):
        print("dont_touch.txt is missing or corrupted.")
        sys.exit(1)


def main():
    plugin_name, godot_version = read_dont_touch()

    print(f"Building RELEASE build for plugin: {plugin_name}")
    print(f"Targeting Godot version: {godot_version}")
    print("Target: template_release\n")
    print("This may take a while...\n")

    # Mirror the same scons call as compile_debug_build.py
    # but with target=template_release instead of template_debug
    result = subprocess.run(
        [
            "scons",
            "platform=windows",
            "target=template_release",
            "arch=x86_64",
        ],
        cwd=project_root,   # run from the folder that contains SConstruct
    )

    if result.returncode == 0:
        print("\n✓ Release build compiled successfully!")
        print("You can now export your Godot project.")
    else:
        print("\n✗ Release build failed. Check the output above for errors.")

    input("\nPress Enter to continue...")


if __name__ == "__main__":
    main()
