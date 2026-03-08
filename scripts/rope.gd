extends Node3D


@onready var mesh: MeshInstance3D = $MeshInstance3D

func _invert():
	mesh.position.z = 0.5
