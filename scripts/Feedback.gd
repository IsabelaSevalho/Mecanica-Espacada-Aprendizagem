# Feedback.gd
extends Control

@onready var label_resultado := $VBoxContainer/LabelResultado
@onready var label_detalhe := $VBoxContainer/LabelDetalhe
@onready var btn_proxima := $VBoxContainer/BtnProxima
@onready var btn_historico := $VBoxContainer/BtnHistorico

func _ready() -> void:
	var r := GameManager.ultimo_resultado
	
	if r["correto"]:
		label_resultado.text = "✅ Correto! Muito bem!"
		label_detalhe.text = "Resposta: R$ %.2f" % r["resposta_correta"]
	else:
		label_resultado.text = "❌ Não foi dessa vez."
		label_detalhe.text = (
            "Você respondeu: R$ %.2f\nResposta correta: R$ %.2f\n\nDica: converta o %% para decimal e multiplique." 
			% [r["resposta_dada"], r["resposta_correta"]]
		)
	
	btn_proxima.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Desafio.tscn"))
	btn_historico.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Historico.tscn"))
