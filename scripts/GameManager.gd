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
		"exercicios": []
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
		"intencao": "completar",
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
			"enunciado": "Calcule passo a passo: 30% de R$50,00",
			"etapas": [
				{"texto": "Passo 1 — Transforme a porcentagem em decimal:\n30 ÷ 100 =", "resposta": 0.30},
				{"texto": "Passo 2 — Multiplique pelo valor total:\n0,30 × 50 = R$", "resposta": 15.0},
			],
			"resposta": 15.0
		},
		{
			"id": "A_C2",
			"enunciado": "Calcule passo a passo: 20% de R$80,00",
			"etapas": [
				{"texto": "Passo 1 — Transforme a porcentagem em decimal:\n20 ÷ 100 =", "resposta": 0.20},
				{"texto": "Passo 2 — Multiplique pelo valor total:\n0,20 × 80 = R$", "resposta": 16.0},
			],
			"resposta": 16.0
		},
		{
			"id": "A_C3",
			"enunciado": "Um produto custa R$200. O preço aumentou 15%. Qual o novo preço?",
			"etapas": [
				{"texto": "Passo 1 — Transforme em decimal:\n15 ÷ 100 =", "resposta": 0.15},
				{"texto": "Passo 2 — Calcule o aumento:\n0,15 × 200 = R$", "resposta": 30.0},
				{"texto": "Passo final — Some ao valor original:\n200 + 30 = R$", "resposta": 230.0},
			],
			"resposta": 230.0
		},
		{
			"id": "A_C4",
			"enunciado": "Uma loja deu 40% de desconto em um item de R$150. Qual o valor do desconto?",
			"etapas": [
				{"texto": "Passo 1 — Transforme em decimal:\n40 ÷ 100 =", "resposta": 0.40},
				{"texto": "Passo 2 — Multiplique pelo valor total:\n0,40 × 150 = R$", "resposta": 60.0},
			],
			"resposta": 60.0
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
			"enunciado": "Calcule passo a passo: 40% de R$60,00",
			"etapas": [
				{"texto": "Passo 1 — Calcule 10% do valor:\n10% de 60 = R$", "resposta": 6.0},
				{"texto": "Passo 2 — Some 4 vezes (40% = 4 × 10%):\n6 + 6 + 6 + 6 = R$", "resposta": 24.0},
			],
			"resposta": 24.0
		},
		{
			"id": "B_C2",
			"enunciado": "Calcule passo a passo: 30% de R$90,00",
			"etapas": [
				{"texto": "Passo 1 — Calcule 10% do valor:\n10% de 90 = R$", "resposta": 9.0},
				{"texto": "Passo 2 — Some 3 vezes (30% = 3 × 10%):\n9 + 9 + 9 = R$", "resposta": 27.0},
			],
			"resposta": 27.0
		},
		{
			"id": "B_C3",
			"enunciado": "Um celular custa R$500. O preço subiu 20%. Qual o valor do aumento?",
			"etapas": [
				{"texto": "Passo 1 — Calcule 10% do valor:\n10% de 500 = R$", "resposta": 50.0},
				{"texto": "Passo 2 — Some 2 vezes (20% = 10% + 10%):\n50 + 50 = R$", "resposta": 100.0},
			],
			"resposta": 100.0
		},
		{
			"id": "B_C4",
			"enunciado": "Uma jaqueta de R$200 está com 35% de desconto. Qual o desconto em reais?",
			"etapas": [
				{"texto": "Passo 1 — Calcule 10% do valor:\n10% de 200 = R$", "resposta": 20.0},
				{"texto": "Passo 2 — Some 3 vezes (30%):\n20 + 20 + 20 = R$", "resposta": 60.0},
				{"texto": "Passo 3 — Calcule 5% (metade de 10%):\n5% de 200 = R$", "resposta": 10.0},
				{"texto": "Passo final — Some 30% + 5%:\n60 + 10 = R$", "resposta": 70.0},
			],
			"resposta": 70.0
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
var sessao_atual_id: int  = 1
var exercicio_atual  := {}
var metodo_atual: String  = "A"
var historico        := []
var erros_agendados  := []
var data_inicio: String   = ""
var ultimo_resultado := {}

const SAVE_PATH := "user://save.json"

# ══════════════════════════════════════════
# CICLO DE VIDA
# ══════════════════════════════════════════

func _ready() -> void:
	carregar_estado()

# ══════════════════════════════════════════
# SAVE / LOAD
# ══════════════════════════════════════════

func salvar_estado() -> void:
	var dados := {
		"sessao_atual_id": sessao_atual_id,
		"metodo_atual":    metodo_atual,
		"data_inicio":     data_inicio,
		"historico":       historico,
		"erros_agendados": erros_agendados,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(dados, "\t"))
		f.close()

func carregar_estado() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not f:
		return
	var resultado: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if resultado == null or not resultado is Dictionary:
		return
	sessao_atual_id  = resultado.get("sessao_atual_id",  1)
	metodo_atual     = resultado.get("metodo_atual",     "A")
	data_inicio      = resultado.get("data_inicio",      "")
	historico        = resultado.get("historico",        [])
	erros_agendados  = resultado.get("erros_agendados",  [])

func resetar_jogo() -> void:
	sessao_atual_id  = 1
	metodo_atual     = "A"
	data_inicio      = ""
	historico        = []
	erros_agendados  = []
	ultimo_resultado = {}
	# Apaga o arquivo de save
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

# ══════════════════════════════════════════
# FUNÇÕES PRINCIPAIS
# ══════════════════════════════════════════

func iniciar_jogo() -> void:
	# Só define data_inicio na primeira vez
	if data_inicio == "":
		data_inicio = Time.get_date_string_from_system()
		salvar_estado()

func sessao_disponivel(id: int) -> bool:
	if modo_demonstracao:
		return true
	if data_inicio == "":
		return id == 1
	var sessao: Dictionary = sessoes[id - 1]
	var hoje   := Time.get_date_string_from_system()
	var dias   := _calcular_dias(data_inicio, hoje)
	return dias >= int(sessao["dia"])

# Retorna quantos dias faltam para a sessão ficar disponível (0 = disponível)
func dias_restantes(id: int) -> int:
	if modo_demonstracao or data_inicio == "":
		return 0
	var sessao: Dictionary = sessoes[id - 1]
	var hoje   := Time.get_date_string_from_system()
	var dias   := _calcular_dias(data_inicio, hoje)
	var faltam := int(sessao["dia"]) - dias
	return max(0, faltam)

func get_sessao_atual() -> Dictionary:
	return sessoes[sessao_atual_id - 1]

func proxima_sessao_disponivel() -> int:
	for s in sessoes:
		if sessao_disponivel(s["id"]) and s["id"] >= sessao_atual_id:
			return s["id"]
	return sessao_atual_id

func get_exercicio(metodo: String, intencao: String) -> Dictionary:
	var banco := exercicios_A if metodo == "A" else exercicios_B

	for erro in erros_agendados:
		if erro["sessao_alvo"] == sessao_atual_id and erro["metodo"] == metodo:
			erros_agendados.erase(erro)
			var ex: Dictionary = erro["exercicio"]
			if intencao == "completar" and not ex.has("etapas"):
				break
			return ex

	if not banco.has(intencao):
		return {}

	var lista: Array = banco[intencao].duplicate()
	lista.shuffle()
	return lista[0]

func registrar_resposta(exercicio: Dictionary, resposta_dada: float, correto: bool, usou_dica: bool) -> void:
	historico.append({
		"sessao":           sessao_atual_id,
		"exercicio_id":     exercicio.get("id", ""),
		"enunciado":        exercicio.get("enunciado", ""),
		"metodo":           metodo_atual,
		"resposta_dada":    resposta_dada,
		"resposta_correta": exercicio.get("resposta", 0.0),
		"correto":          correto,
		"usou_dica":        usou_dica,
	})

	if not correto:
		var proxima := sessao_atual_id + 1
		if proxima <= 6:
			erros_agendados.append({
				"exercicio":   exercicio,
				"metodo":      metodo_atual,
				"sessao_alvo": proxima
			})

	if not modo_demonstracao:
		salvar_estado()

func alternar_metodo() -> void:
	metodo_atual = "B" if metodo_atual == "A" else "A"

func avancar_sessao() -> void:
	sessao_atual_id += 1
	if not modo_demonstracao:
		salvar_estado()

# ══════════════════════════════════════════
# UTILITÁRIOS
# ══════════════════════════════════════════

func _calcular_dias(data_ini: String, data_fim: String) -> int:
	var ini := Time.get_unix_time_from_datetime_string(data_ini + "T00:00:00")
	var fim := Time.get_unix_time_from_datetime_string(data_fim + "T00:00:00")
	return int((fim - ini) / 86400.0)
