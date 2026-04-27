class_name User extends Resource

@export var name:String = "user"
@export var password:String = ""

@export var data:Dictionary[String, Variant] = {}

@export var rights:Array[StringName] 

var peer_id:int = -1

const DATA_DIR = "user://users/"
