extends Node

# ══════════════════════════════════════════
# MODOS
# ══════════════════════════════════════════
var modo_demonstracao: bool = false  # true = ignora datas, libera tudo

# ══════════════════════════════════════════
# SESSÕES
# ══════════════════════════════════════════
var sessoes := [
	{
		"id": 1,
		"dia": 0,
		"intencao": "observar",
		"notificacao": "Bem-vindo! Hoje você vai conhecer dois jeitos de calcular porcentagem.",
		"lembrete": "",
		"exercicios": []  # sessão 1 só observa, sem exercícios
	},
	{
		"id": 2,
		"dia": 1,
		"intencao": "completar",
		"notificacao": "Lembra dos dois métodos? Agora complete os passos!",
		"lembrete": "resumo_s1",
		"exercicios": ["A", "B"]
	},
	{
		"id": 3,
		"dia": 3,
		"intencao": "apoio",
		"notificacao": "Hoje você resolve sozinho — mas pode pedir uma dica!",
		"lembrete": "resumo_s1_s2",
		"exercicios": ["A", "B"]
	},
	{
		"id": 4,
		"dia": 6,
		"intencao": "sem_apoio",
		"notificacao": "Desafio do dia: sem dicas desta vez. Você consegue!",
		"lembrete": "",
		"exercicios": ["A", "B"]
	},
	{
		"id": 5,
		"dia": 10,
		"intencao": "transferir",
		"notificacao": "Hoje o desafio é em um contexto diferente!",
		"lembrete": "",
		"exercicios": ["A", "B"]
	},
	{
		"id": 6,
		"dia": 15,
		"intencao": "autonomia",
		"notificacao": "Última sessão! Use o método que preferir.",
		"lembrete": "",
		"exercicios": ["A", "B"]
	},
]

# ══════════════════════════════════════════
# BANCO DE EXERCÍCIOS
# ══════════════════════════════════════════
var exercicios_A := {
	"completar": [
		{
			"id": "A_C1",
			"enunciado": "Complete: 30% de R$50 → 30÷100 = ___ → ___×50 = R$___",
			"passos": [0.30, 15.0],
			"resposta": 15.0
		},
		{
			"id": "A_C2",
			"enunciado": "Complete: 20% de R$80 → 20÷100 = ___ → ___×80 = R$___",
			"passos": [0.20, 16.0],
			"resposta": 16.0
		},
	],
	"apoio": [
		{
			"id": "A_A1",
			"enunciado": "Uma camiseta custa R$60. Com 25% de desconto, quanto você paga?",
			"resposta": 45.0,
			"dica": "Passo 1: divida 25 por 100. Passo 2: multiplique pelo preço."
		},
		{
			"id": "A_A2",
			"enunciado": "Um tênis custa R$120. Com 10% de desconto, qual o valor do desconto?",
			"resposta": 12.0,
			"dica": "Passo 1: divida 10 por 100. Passo 2: multiplique pelo preço."
		},
	],
	"sem_apoio": [
		{
			"id": "A_S1",
			"enunciado": "Um produto custa R$200. O preço aumentou 15%. Qual o novo preço?",
			"resposta": 230.0,
			"dica": ""
		},
		{
			"id": "A_S2",
			"enunciado": "Uma loja deu 40% de desconto em um item de R$150. Qual o valor do desconto?",
			"resposta": 60.0,
			"dica": ""
		},
	],
	"transferir": [
		{
			"id": "A_T1",
			"enunciado": "Você acertou 80% de 25 questões. Quantas questões você acertou?",
			"resposta": 20.0,
			"dica": ""
		},
	],
	"autonomia": [
		{
			"id": "A_AU1",
			"enunciado": "Em uma turma de 40 alunos, 35% faltaram. Quantos alunos faltaram?",
			"resposta": 14.0,
			"dica": ""
		},
	],
}

var exercicios_B := {
	"completar": [
		{
			"id": "B_C1",
			"enunciado": "Complete: 40% de R$60 → 10%=___ → ___+___+___+___ = R$___",
			"passos": [6.0, 24.0],
			"resposta": 24.0
		},
		{
			"id": "B_C2",
			"enunciado": "Complete: 30% de R$90 → 10%=___ → ___+___+___ = R$___",
			"passos": [9.0, 27.0],
			"resposta": 27.0
		},
	],
	"apoio": [
		{
			"id": "B_A1",
			"enunciado": "Um livro custa R$80. Com 25% de desconto, qual o valor do desconto?",
			"resposta": 20.0,
			"dica": "Dica: 25% = 10% + 10% + 5%. Calcule cada parte e some."
		},
		{
			"id": "B_A2",
			"enunciado": "Uma mochila custa R$100. Com 15% de desconto, quanto você economiza?",
			"resposta": 15.0,
			"dica": "Dica: 15% = 10% + 5%. Calcule cada parte e some."
		},
	],
	"sem_apoio": [
		{
			"id": "B_S1",
			"enunciado": "Um celular custa R$500. O preço subiu 20%. Qual o valor do aumento?",
			"resposta": 100.0,
			"dica": ""
		},
		{
			"id": "B_S2",
			"enunciado": "Uma jaqueta de R$200 está com 35% de desconto. Qual o desconto em reais?",
			"resposta": 70.0,
			"dica": ""
		},
	],
	"transferir": [
		{
			"id": "B_T1",
			"enunciado": "Uma receita usa 15% de 200g de açúcar. Quantos gramas de açúcar são usados?",
			"resposta": 30.0,
			"dica": ""
		},
	],
	"autonomia": [
		{
			"id": "B_AU1",
			"enunciado": "Um time ganhou 60% dos 30 jogos que disputou. Quantos jogos o time ganhou?",
			"resposta": 18.0,
			"dica": ""
		},
	],
}

# ══════════════════════════════════════════
# ESTADO DO JOGO
# ══════════════════════════════════════════
var sessao_atual_id: int = 1
var exercicio_atual := {}
var metodo_atual: String = "A"  # alterna A e B
var historico := []
var erros_agendados := []  # [{exercicio, sessao_alvo}]
var data_inicio: String = ""  # formato "YYYY-MM-DD"
var ultimo_resultado := {}

# ══════════════════════════════════════════
# FUNÇÕES PRINCIPAIS
# ══════════════════════════════════════════

func iniciar_jogo() -> void:
	if data_inicio == "":
		data_inicio = Time.get_date_string_from_system()

func sessao_disponivel(id: int) -> bool:
	if modo_demonstracao:
		return true
	var sessao = sessoes[id - 1]
	var hoje := Time.get_date_string_from_system()
	var dias_passados := _calcular_dias(data_inicio, hoje)
	return dias_passados >= sessao["dia"]

func get_sessao_atual() -> Dictionary:
	return sessoes[sessao_atual_id - 1]

func proxima_sessao_disponivel() -> int:
	for s in sessoes:
		if sessao_disponivel(s["id"]) and s["id"] >= sessao_atual_id:
			return s["id"]
	return sessao_atual_id

func get_exercicio(metodo: String, intencao: String) -> Dictionary:
	var banco = exercicios_A if metodo == "A" else exercicios_B
	if not banco.has(intencao):
		return {}
	
	# Verifica se tem erros agendados para essa sessão
	for erro in erros_agendados:
		if erro["sessao_alvo"] == sessao_atual_id and erro["metodo"] == metodo:
			erros_agendados.erase(erro)
			return erro["exercicio"]
	
	var lista: Array = banco[intencao]
	lista.shuffle()
	return lista[0]

func registrar_resposta(exercicio: Dictionary, resposta_dada: float, correto: bool, usou_dica: bool) -> void:
	historico.append({
		"sessao": sessao_atual_id,
		"exercicio_id": exercicio.get("id", ""),
		"metodo": metodo_atual,
		"resposta_dada": resposta_dada,
		"resposta_correta": exercicio.get("resposta", 0.0),
		"correto": correto,
		"usou_dica": usou_dica
	})
	
	# Agenda revisão se errou
	if not correto:
		var proxima := sessao_atual_id + 1
		if proxima <= 6:
			erros_agendados.append({
				"exercicio": exercicio,
				"metodo": metodo_atual,
				"sessao_alvo": proxima
			})

func alternar_metodo() -> void:
	metodo_atual = "B" if metodo_atual == "A" else "A"

func _calcular_dias(data_ini: String, data_fim: String) -> int:
	# Formato esperado: "YYYY-MM-DD"
	var ini := Time.get_unix_time_from_datetime_string(data_ini + "T00:00:00")
	var fim := Time.get_unix_time_from_datetime_string(data_fim + "T00:00:00")
	return int((fim - ini) / 86400.0)
