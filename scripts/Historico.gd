extends Control

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)
	
	var titulo := Label.new()
	titulo.text = "Histórico de Tentativas"
	vbox.add_child(titulo)
	
	for entrada in GameManager.historico:
		var label := Label.new()
		var icone := "✅" if entrada["correto"] else "❌"
		label.text = "%s S%d [%s] R$%.2f (correto: R$%.2f)" % [
			icone,
			entrada["sessao"],
			entrada["metodo"],
			entrada["resposta_dada"],
			entrada["resposta_correta"]
		]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(label)
	
	var btn_voltar := Button.new()
	btn_voltar.text = "VOLTAR"
	btn_voltar.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Desafio.tscn"))
	vbox.add_child(btn_voltar)
