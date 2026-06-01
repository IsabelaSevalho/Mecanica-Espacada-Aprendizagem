# GameManager.gd
extends Node

# Banco de questões — adicione quantas quiser
var questoes := [
	{
		"id": 1,
		"enunciado": "Uma camisa custa R$80,00. Há 25% de desconto. Quanto você paga?",
		"resposta": 60.0,
		"nivel": 1
	},
	{
		"id": 2,
		"enunciado": "Um produto de R$200,00 tem 10% de aumento. Qual o novo preço?",
		"resposta": 220.0,
		"nivel": 1
	},
	{
		"id": 3,
		"enunciado": "Um tênis custa R$150,00. Desconto de 20% e depois mais 5%. Valor final?",
		"resposta": 114.0,
		"nivel": 2
	},
	{
		"id": 4,
		"enunciado": "Se 30% de um valor é R$90,00, qual é o valor total?",
		"resposta": 300.0,
		"nivel": 2
	},
]

# Fila de repetição espaçada: {id_questao: tentativas_até_reaparecer}
var fila_espacada := {}

# Histórico de tentativas
var historico := []  # Array de dicts: {questao_id, resposta_dada, correto, tentativa_num}

var tentativa_atual := 0
var questao_atual := {}
var nivel_atual := 1
var ultimo_resultado := {}

func proxima_questao() -> Dictionary:
	tentativa_atual += 1
	
	# Verifica se alguma questão da fila deve reaparecer
	for qid in fila_espacada.keys():
		fila_espacada[qid] -= 1
		if fila_espacada[qid] <= 0:
			fila_espacada.erase(qid)
			# Retorna essa questão para revisão
			for q in questoes:
				if q["id"] == qid:
					questao_atual = q
					return questao_atual
	
	# Filtra questões do nível atual que não estão na fila
	var disponiveis := questoes.filter(func(q):
		return q["nivel"] <= nivel_atual and not fila_espacada.has(q["id"])
	)
	
	if disponiveis.is_empty():
		disponiveis = questoes  # fallback: usa todas
	
	disponiveis.shuffle()
	questao_atual = disponiveis[0]
	return questao_atual

func registrar_resposta(resposta_dada: float, correto: bool) -> void:
	historico.append({
		"questao_id": questao_atual["id"],
		"enunciado": questao_atual["enunciado"],
		"resposta_dada": resposta_dada,
		"resposta_correta": questao_atual["resposta"],
		"correto": correto,
		"tentativa": tentativa_atual
	})
	
	# Se errou, agenda para reaparecer em 3 questões
	if not correto:
		fila_espacada[questao_atual["id"]] = 3
	
	# Sobe de nível a cada 5 acertos consecutivos no nível atual
	var acertos_nivel := historico.filter(func(h):
		return h["correto"] and _questao_de_nivel(h["questao_id"]) == nivel_atual
	).size()
	
	if acertos_nivel >= 5 and nivel_atual < 2:
		nivel_atual += 1

func _questao_de_nivel(qid: int) -> int:
	for q in questoes:
		if q["id"] == qid:
			return q["nivel"]
	return 1
