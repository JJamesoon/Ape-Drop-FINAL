//MURO DO ENCAIXE (SCR_QUEBRA_CABECA):
//	ALERTA: CONTAGEM DE 3 COM A GRADE TREMENDO
//	PUZZLE: TUDO PARA. UM MURO DESCE DO TOPO QUEBRANDO OS BLOCOS, COM UM BURACO NO FORMATO DE UMA PEÇA.
//			NO MEIO DA TELA A PEÇA 3D (SPRITE STACKING): <- E -> GIRAM, ^ ESPELHA, V ENCAIXA.
//			ENCAIXOU CERTO: A PEÇA VOA PRO BURACO, O MURO SOBE 16PX E VEM OUTRA. ERROU: O MURO DESCE UM POUCO.
//			O MURO ENCOSTOU NO PLAYER: MORRE
//	FIM:	TODAS AS PEÇAS ENCAIXADAS (BONUS) OU FALHOU. O MURO SOBE E O JOGO CONTINUA
estado = "alerta";	//ESTADO ATUAL E TEMPO QUE FALTA NELE
timer = QC_ALERTA;
area = instance_find(obj_area, 0);	//ARENA DO ARCADE
global.quebra_parado = false;	//TRUE TRAVA PEÇAS E PLAYER (SO NO PUZZLE)
alpha = 0;	//TRANSPARENCIA DA GUI DO DESAFIO

pecas_total = desafio_tamanho(ENC_PECAS_MAX);	//QUANTAS PEÇAS PRA ENCAIXAR (2-3 NO PRIMEIRO, VAI SUBINDO)
global.desafios_feitos++;
passo = 0;	//PEÇAS JA ENCAIXADAS
muro_y = area.y - 2;	//PONTA DOS ESPINHOS DEBAIXO DO MURO
muro_alvo = muro_y;	//ALTURA QUE O MURO ESTA INDO
som_quebra = 0;	//TEMPO ENTRE UM SOM DE QUEBRAR E OUTRO

//PEÇA DO JOGADOR
base = [];	//CASAS DA PEÇA (GLOBAL.ENC_PECAS)
cor = c_white;	//COR DA PEÇA
spr = -1;	//SPRITE 3D GERADA DA PEÇA
rot = 0;			//VEZES QUE GIROU 90 GRAUS PRA ESQUERDA
esp = false;		//ESPELHADA
ang = 0;			//DESENHO: VAI ATRAS DO ROT E DO ESP
esc_x = 1;	//ESCALA X (O ESPELHO VAI DE 1 A -1)
esc_entra = 0;		//A PEÇA NOVA ENTRA CRESCENDO
pop = 0;	//"POP" QUANDO GIRA/ESPELHA
erro = 0;			//ENCAIXOU ERRADO: FICA VERMELHA E TREME
voo = -1;			//>= 0: A PEÇA TA VOANDO PRO BURACO
espera = 0;	//PAUSINHA ANTES DA PROXIMA PEÇA
alvo = [];			//FORMA DO BURACO
flash = 0;			//BURACO PREENCHIDO PISCANDO DEPOIS DO ENCAIXE
flash_forma = [];	//FORMA DO BURACO QUE PISCA
flash_cor = c_white;	//COR DO BURACO QUE PISCA

//SORTEIA UMA PEÇA NOVA E A FORMA DO BURACO
nova_peca = function()
{
	base = global.enc_pecas[irandom(array_length(global.enc_pecas) - 1)];
	cor = global.enc_cores[irandom(array_length(global.enc_cores) - 1)];
	if(sprite_exists(spr)) sprite_delete(spr);
	spr = enc_peca_sprite(base, cor);
	rot = 0;
	esp = false;
	ang = 0;
	esc_x = 1;
	esc_entra = 0;
	//BURACO: A PEÇA EM OUTRA POSIÇAO (DIFERENTE DE COMO ELA COMEÇA)
	var _ini = enc_forma_chave(enc_forma(base, 0, false));
	repeat(30)
	{
		alvo = enc_forma(base, irandom(3), irandom(1));
		if(enc_forma_chave(alvo) != _ini) break;
	}
}

//TAMANHO DE UMA FORMA EM CASAS [LARGURA, ALTURA]
forma_tam = function(_f)
{
	var _w = 0, _h = 0;
	for(var i = 0; i < array_length(_f); i++) { _w = max(_w, _f[i][0] + 1); _h = max(_h, _f[i][1] + 1); }
	return [_w, _h];
}

//MEIO DO BURACO NO MURO (COORDENADAS DA ROOM), LOGO ACIMA DOS ESPINHOS
buraco_meio = function(_f)
{
	var _t = forma_tam(_f);
	return [area.x + area.sprite_width / 2, muro_y - 14 - _t[1] * ENC_BURACO / 2];
}

//A PEÇA CHEGOU NO BURACO
encaixou = function()
{
	passo++;
	voo = -1;
	flash = 25;
	flash_forma = alvo;
	flash_cor = cor;
	som_tocar(snd_pegar_moeda);
	audio_play_sound(snd_hit2, 1, false, 1, 0, .8);
	shakes(6, 2);
	muro_alvo = max(area.y + ENC_INICIO, muro_alvo - CEL);
	//ERA A ULTIMA: VENCEU. SENAO, PAUSINHA E PEÇA NOVA
	if(passo >= pecas_total) terminar(true);
	else
	{
		espera = 15;
		nova_peca();
	}
}

//TERMINA: O MURO SOBE E O JOGO VOLTA
terminar = function(_venceu)
{
	estado = "fim";
	timer = QC_FIM;
	muro_alvo = area.y - 2;
	var _cx = area.x + area.sprite_width / 2, _cy = area.y + area.sprite_height * .4;
	//VENCEU: BONUS (VEZES O LEVEL), TEXTO, SOM E ONDA DE CHOQUE
	if(_venceu)
	{
		pontos_somar(ENC_BONUS * global.level, _cx, _cy + 30, c_yellow, 1.3);
		desafio_premio_letra(_cx, _cy + 6);
		efeito_texto(global.linguagem == 0 ? "TUDO ENCAIXADO!" : "ALL FITTED!", _cx, _cy + 10, c_yellow, 1.4);
		som_tocar(snd_new_level);
		onda_choque(_cx, _cy, 140, 6, 36);
		shakes(10, 3);
	}
	//FALHOU: SO O AVISO
	else
	{
		efeito_texto(global.linguagem == 0 ? "FALHOU!" : "FAILED!", _cx, _cy + 10, c_red, 1.4);
		som_tocar(snd_menu_erro_04);
		shakes(12, 3);
	}
}
