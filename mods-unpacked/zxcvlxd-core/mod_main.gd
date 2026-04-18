extends Node

const MOD_DIR := "zxcvlxd-core"
const MOD_LOG_NAME := "zxcvlxd-core:main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

var core_settings:CoreSettings

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	install_script_extensions()
	install_script_hook_files()
	add_translations()
	
	var settings_path = mod_dir_path.path_join("settings/core_settings.tres")
	if FileAccess.file_exists(settings_path):
		core_settings = load(settings_path)
	

func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")

func install_script_hook_files() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")

func add_translations() -> void:
	translations_dir_path = mod_dir_path.path_join("translations")


func _ready() -> void:
	if core_settings:
		get_tree().change_scene_to_file.call_deferred(core_settings.main_scene)
