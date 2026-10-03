//MODO QUEBRA-CABEÇA (SCR_QUEBRA_CABECA):
//	ALERTA: CONTAGEM DE 5 (O JOGO AINDA RODA, MAS NAO NASCEM PEÇAS NOVAS)
//	PUZZLE: TUDO PARA (PEÇAS E PLAYER). ESPINHOS DESCEM DEVAGAR QUEBRANDO OS BLOCOS. O JOGADOR APERTA AS SETAS
//			DA SEQUENCIA (3 A 5). CADA SEQUENCIA CERTA = 1 ETAPA DO CUBO MAGICO E OS ESPINHOS SOBEM 16PX.
//			ERROU: A SEQUENCIA RECOMEÇA E OS ESPINHOS DESCEM UM POUCO. OS ESPINHOS ENCOSTARAM NO PLAYER: MORRE
//	FIM:	CUBO COMPLETO (BONUS) OU FALHOU. OS ESPINHOS VOLTAM PRA CIMA E O JOGO CONTINUA
estado = "alerta";	//ESTADO ATUAL E TEMPO QUE FALTA NELE
timer = QC_ALERTA;
area = instance_find(obj_area, 0);	//ARENA DO ARCADE
global.quebra_parado = false;	//TRUE TRAVA PEÇAS E PLAYER (SO NO PUZZLE)

passos_total = desafio_tamanho(QC_PASSOS_MAX);	//QUANTAS SEQUENCIAS PRA COMPLETAR O CUBO (2-3 NO PRIMEIRO, VAI SUBINDO)
global.desafios_feitos++;
passo = 0;	//ETAPAS JA FEITAS
seq = [];	//SETAS DA SEQUENCIA ATUAL (0 DIR, 1 CIMA, 2 ESQ, 3 BAIXO)
seq_pos = 0;	//PROXIMA SETA A APERTAR
seq_espera = 0;	//PAUSINHA ENTRE UMA SEQUENCIA E OUTRA
seq_erro = 0;	//AS SETAS FICAM VERMELHAS E TREMEM
seq_pop = [];	//"POP" DE CADA SETA QUANDO ACERTA

espinho_y = area.y - 2;	//PONTA DOS ESPINHOS
espinho_alvo = espinho_y;	//ALTURA QUE OS ESPINHOS ESTAO INDO
som_quebra = 0;	//TEMPO ENTRE UM SOM DE QUEBRAR E OUTRO

//CUBO MAGICO (SPRITE STACKING)
cubo = qc_cubo_novo();	//CORES DAS FACES DO CUBO
cubo_spr = -1;	//SPRITE GERADA DO CUBO (SPRITE STACKING)
cubo_ang = 30;	//ANGULO DO CUBO
cubo_giro = 0;		//GIRO EXTRA QUANDO COMPLETA UMA ETAPA
cubo_esc = 0;		//ENTRA CRESCENDO
cubo_pop = 0;
alpha = 0;	//TRANSPARENCIA DA GUI DO DESAFIO

//SORTEIA UMA SEQUENCIA NOVA DE 3 A 5 SETAS
nova_sequencia = function()
{
	seq = [];
	seq_pop = [];
	var _n = irandom_range(QC_SETAS_MIN, QC_SETAS_MAX);
	for(var i = 0; i < _n; i++)
	{
		array_push(seq, irandom(3));
		array_push(seq_pop, 0);
	}
	seq_pos = 0;
}

//REFAZ A SPRITE DO CUBO (DEPOIS DE CADA ETAPA ELE FICA MAIS ARRUMADO)
cubo_refazer = function()
{
	if(sprite_exists(cubo_spr)) sprite_delete(cubo_spr);
	cubo_spr = qc_cubo_sprite(cubo);
}
cubo_refazer();

//TERMINA: OS ESPINHOS SOBEM E O JOGO VOLTA
terminar = function(_venceu)
{
	estado = "fim";
	timer = QC_FIM;
	espinho_alvo = area.y - 2;
	var _cx = area.x + area.sprite_width / 2, _cy = area.y + area.sprite_height * .4;
	//VENCEU: BONUS (VEZES O LEVEL), TEXTO, SOM E ONDA DE CHOQUE
	if(_venceu)
	{
		pontos_somar(QC_BONUS * global.level, _cx, _cy + 30, c_yellow, 1.3);
		desafio_premio_letra(_cx, _cy + 6);
		efeito_texto(global.linguagem == 0 ? "CUBO COMPLETO!" : "CUBE SOLVED!", _cx, _cy + 10, c_yellow, 1.4);
		som_tocar(snd_new_level);
		onda_choque(_cx, _cy, 140, 6, 36);
		shakes(10, 3);
		cubo_giro += 360;
	}
	//FALHOU: SO O AVISO
	else
	{
		efeito_texto(global.linguagem == 0 ? "FALHOU!" : "FAILED!", _cx, _cy + 10, c_red, 1.4);
		som_tocar(snd_menu_erro_04);
		shakes(12, 3);
	}
}
