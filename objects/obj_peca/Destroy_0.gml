//SAINDO DA FILA DO TELEPORTE (SE A PEÇA TAVA NELA)
if(instance_exists(pai)) fila_remover(pai);
fila_remover(id);

//VAI EM TODOS OS MEUS IRMAOS E DESFAZ A IRMANDADE SE TIVER
if(irmandade and instance_exists(pai))
{
	quebrar_irmandade(pai.timer_move, criar_chao);
}
esvaziar_grid();

//PONTOS: BLOCO QUEBRADO PELO PLAYER (OS DAS LINHAS SAO SOMADOS NO OBJ_EFEITO_LINE, UM TEXTO POR LINHA)
//(PONTOS_MULT: NO GIRO NO AR, CADA QUIQUE SEGUIDO SEM PISAR NO CHAO MULTIPLICA)
if(destruido_por == "player") pontos_somar((sou_fantasma ? PONTOS_FANTASMA : PONTOS_BLOCO_PLAYER) * global.level * pontos_mult, x, y - 8, c_yellow, .8);

//GIRO DE FOGO: QUEBRADO POR UM PLAYER GIRANDO EM FOGO, VALE GIRO_FOGO_PONTOS A MAIS
if(destruido_por == "player")
{
	var _fogo = false;
	with(obj_player) if(estado == state.giro and em_fogo()) _fogo = true;
	if(_fogo) pontos_somar(GIRO_FOGO_PONTOS, x, y - 20, c_orange, .6);
}

//ESPINHOS DO QUEBRA-CABEÇA E EXPLOSAO DA BOMBA: O BLOCO QUEBRADO TIRA PONTOS EM VEZ DE DAR (CASTIGO)
var _castigo = destruido_por == "espinho" or destruido_por == "bomba";
if(_castigo) pontos_tirar(PONTOS_BLOCO_PLAYER * global.level, x, y - 8);

//ARMADILHAS DOS BLOCOS NOVOS (ABELHA, BURACO, BLOCO EM CHAMAS E CABEÇADA DO CABEÇUDO): O BLOCO SO SOME (SEM PONTOS E SEM PREMIO)
var _armadilha = destruido_por == "abelha" or destruido_por == "buraco" or destruido_por == "fogo" or destruido_por == "cabecudo";
var _sem_premio = _castigo or _armadilha;

//ESPECIAL: PONTOS E MOEDA POR BLOCO
if(destruido_por == "especial") especial_bloco_destruido(x, y);

//IRMANDADE: BLOCO DE UMA PEÇA INTEIRA DESTRUIDA NA LINHA (DENTRO OU FORA DELA)
//O "10" SAI AQUI, NA HORA QUE O BLOCO EXPLODE, E VOA PRO NUMERO DO CENTRO
if(morte_irmandade)
{
	pontos_irmandade(x, y, espera_pontos, meu_coletor, true);
	audio_play_sound(snd_peca_destroy, 1, false, .8, 0, 1 + random(.3));
}
else if(instance_exists(meu_coletor))
{
	//TINHA RESERVADO LUGAR NO QUADRO MAS MORREU DE OUTRO JEITO: LIBERA A RESERVA
	meu_coletor.esperando = max(0, meu_coletor.esperando - 1);
}

//ESTATISTICA DA TELA DE RESULTADO
if(destruido_por != noone) global.blocos_destruidos++;

//LETRA GUARDADA NO BLOCO: SAI PULANDO
if(letra >= 0 and modo_arcade()) letra_criar(x, y, letra, true);

//BLOCO RAIO: CAI UM RAIO NELE, OS OBJETOS FICAM AZUL AQUA E OS PONTOS DOBRAM
//(OS ESPINHOS E A BOMBA NAO CONTAM: ELES SAO CASTIGO, NAO O JOGADOR QUEBRANDO)
if(sou_raio and destruido_por != noone and !_sem_premio) raio_ativar(x, y);

//BLOCO FUJAO: SOLTA AS MOEDAS QUE TINHA DENTRO
if(sou_fujao and destruido_por != noone and !_sem_premio) moeda_criar(x, y, FUJAO_MOEDAS);

//BLOCO LENTO: QUEBRADO PELO PLAYER (GIRO, ESPECIAL...) NAO ACONTECE NADA. DESTRUIDO DE OUTRO JEITO (LINHA, LASER, BOMBA...),
//JOGA O FEITIÇO DE LENTIDAO NO PLAYER (A ABELHA E O BURACO TAMBEM NAO CONTAM)
if(sou_lento and destruido_por != noone and destruido_por != "player" and destruido_por != "especial" and !_armadilha) lento_lancar(x, y);
if(sou_lento and destruido_por == "player") rapido_lancar(x, y); //O PLAYER QUEBROU: GANHA VELOCIDADE

//MODO BONUS (BLOCO ESPECIAL): TODO BLOCO DESTRUIDO SOLTA UMA MOEDA
if(global.bonus_moedas > 0 and destruido_por != noone and !_sem_premio and modo_arcade()) moeda_criar(x, y, 1);

//BLOCO ESPECIAL: ALGO BOM OU RUIM PRO PLAYER
if(sou_especial and destruido_por != noone and !_armadilha)
{
	especial_ativar(x, y, premio_especial);
	if(global.bloco_especial == id) global.bloco_especial = noone;
}
else if(global.bloco_especial == id) global.bloco_especial = noone;

//CRIANDO O EFEITO DE MORTE==================================
	var _cor = noone;
	//COR DO EFEITO CONFORME A COR DO BLOCO
	switch(coloracao)
	{
		case cores.c_green	: _cor = #8BFF32; break;
		case cores.c_yellow	: _cor = #FFFF00; break;
		case cores.c_purple	: _cor = #DE65FF; break;
		case cores.c_aqua	: _cor = #31FCFF; break;
		case cores.c_red	: _cor = #FF3237; break;
	}
	//O FANTASMA NAO TEM COR: MINI-BLOCOS DO PROPRIO FANTASMA (FRAME 6) E MORTE CINZA CLARO
	var _frame = coloracao;
	if(sou_fantasma)
	{
		_cor = #C9C9D6;
		_frame = 6;
	}
	//PEDRA: LASCAS CINZA
	else if(sou_pedra)
	{
		_cor = #8E90A3;
		_frame = 6;
	}
	//GELO, COLMEIA, GELATINA E BURACO: MINI-BLOCOS E MORTE DA COR DELES
	else if(sou_gelo)		{ _cor = #A6E6FF; _frame = cores.c_aqua; }
	else if(sou_colmeia)	{ _cor = #F2A93B; _frame = cores.c_yellow; }
	else if(sou_gelatina)	{ _cor = #6EE05A; _frame = cores.c_green; }
	else if(sou_buraco)		{ _cor = #5A3290; _frame = cores.c_purple; }
	//BLOCO RAIO (OU COM O RAIO LIGADO): O BLOCO E AZUL, ENTAO A MORTE TAMBEM
	else if(sou_raio or raio_azul())
	{
		_cor = #31FCFF;
		_frame = cores.c_aqua;
	}

	//BLOCO DA IRMANDADE: MORTE DIFERENTE (ANEL BRANCO + MINI-BLOCOS DA COR DELE)
	if(morte_irmandade or destruido_por == "irmandade")
	{
		efeito_morte_irmandade(x, y, _frame);
	}
	//BLOCO DA LINHA: SOLTA UNS MINI-BLOCOS DA COR DELE (SATISFAÇAO DE FECHAR LINHA)
	else if(destruido_por == "linha")
	{
		efeito_morte_linha(x, y, _frame);
	}
	//QUALQUER OUTRA MORTE: A PEÇA VOA PRA FORA DA ARENA (OBJ_PECA_MORTE)
	else if(efeito_morte)
	{
		var _peca_stack = instance_create_layer(x, y, "Linha", obj_peca_morte);
		_peca_stack.image_blend = _cor;
		_peca_stack.tipo = coloracao;
	}

	//BLOCO QUE VIRA CHAO SOLIDO QUANDO QUEBRA NUMA LINHA
	if(criar_chao or criar_chao_combo) instance_create_layer(x, y, "Blocos", obj_block);
//CRIANDO O EFEITO DE MORTE==================================
