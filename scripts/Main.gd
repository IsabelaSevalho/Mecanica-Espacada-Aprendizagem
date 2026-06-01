# Main.gd
extends Node

func _ready() -> void:
	ir_para_desafio()

func ir_para_desafio() -> void:
	get_tree().change_scene_to_file("res://scenes/Desafio.tscn")
