//LINHA DOS ANDARES: O PLAYER TEM QUE FECHAR LINHAS ATE ELA PRA SUBIR DE ANDAR
//FICA NA FRENTE DE TUDO
depth = -10000;
intensidade = 0; //INTENCIDADE DO RAIO
tam_raio = 1;	//TAMANHO DOS RAIOS

//ARENA ONDE A LINHA ESTA
minha_area = instance_place(x, y, [obj_area, obj_area_versus]);
todos_andares = [0, 2, 6, 10];	//ALTURA DE CADA ANDAR EM CELULAS (ANDAR 1 = 2 CELULAS, 2 = 6, 3 = 10)
//ALTURA DA LINHA NO ANDAR ATUAL
meu_y = minha_area.y + sprite_get_height(spr_area) - CEL*todos_andares[global.andar];

linhas_atuais = noone;	//QUANTAS LINHAS FORAM FEITAS NESSE ANDAR (PRO EFEITO DE LIMPAR)

//FESTA DE SUBIR DE ANDAR: O JOGO TODO PARA (GLOBAL.ANDAR_PAUSA) ENQUANTO A REGUA VAI PRO LUGAR NOVO
#macro ANDAR_PAUSA		(room_speed * 1.6)	//DURAÇAO DA PAUSA/FESTA
festa_titulo	= "";		//LETREIRO GRANDE NO MEIO DA ARENA ("ANDAR 2!", "LEVEL 3"...)
festa_sub		= "";		//LINHA DE BAIXO (O NOVO MULTIPLICADOR DE PONTOS)
festa_nota		= 0;		//PROXIMA NOTA DO ARPEJO
faiscas			= [];		//FAISCAS DOURADAS SAINDO DA REGUA: [X, Y, VELH, VELV, VIDA]
y_antigo		= y;		//ALTURA DE ONDE A REGUA SAIU (O RASTRO DOURADO VAI DE LA ATE ELA)

//SOBE O ANDAR (1 -> 2 -> 3 -> VOLTA PRO 1) E MOVE A LINHA PRA ALTURA DO ANDAR NOVO. DA ENERGIA E ENCHE O REFLEXO
elevar_nivel = function()
{
	//FESTA: O JOGO PARA, FLASH, TREMIDA E ONDA DE CHOQUE SAINDO DA REGUA (O RESTO E NO STEP E NO DRAW)
	if(modo_arcade()) global.andar_pausa = ANDAR_PAUSA; //(NO VERSUS NAO PARA: SAO DOIS JOGOS AO MESMO TEMPO)
	y_antigo = y;
	festa_nota = 0;
	global.flash_linha = .5;
	shakes(16, 3);
	if(instance_exists(minha_area)) onda_choque(minha_area.x + minha_area.sprite_width / 2, y, 200, 8, 45);
	modificar_raios(25);
	energia_ganhar(ENERGIA_ANDAR);
	with(obj_player) reflexo_energia = 100; //PODER DO REFLEXO ENCHE AO SUBIR DE ANDAR
	switch(global.andar)
	{
		case 1:
			global.andar++;
			break;
		case 2:
			global.andar++;
			global.chegou_andar3 = true; //LIBERA O BLOCO SNIPER
			//COMPLETOU O 2O ANDAR: DAQUI PRA FRENTE AS PEÇAS FICAM MAIS RAPIDAS (SCR_PONTOS, DIFICULDADE)
			contagem_iniciar(global.linguagem == 0 ? "MAIS RÁPIDO" : "FASTER", function() { global.passou_andar2 = true; });
			break;
		case 3:
			//COMPLETOU O 3O ANDAR: SOBE DE LEVEL (MAIS PONTOS E PEÇAS MAIS RAPIDAS)
			global.andar = 1;
			global.level++;
			gorz_falar("level");
			//SO MUDA DE DEGRAU DE DIFICULDADE A CADA 3 LEVEIS (SCR_PONTOS, DIF_NIVEIS): AI AVISA "MAIS RAPIDO". NOS OUTROS LEVEIS NADA MUDA
			if(dificuldade_degrau(global.level) > dificuldade_degrau(global.nivel_vel)) contagem_iniciar(global.linguagem == 0 ? "MAIS RÁPIDO" : "FASTER", function() { global.nivel_vel = global.level; });
			else global.nivel_vel = global.level;
			energia_ganhar(ENERGIA_LEVEL);
			som_tocar(snd_new_level);
			break;
	}
	//LETREIRO: O ANDAR NOVO E O MULTIPLICADOR DE PONTOS DELE (NO LEVEL, O LEVEL NOVO)
	var _pt = global.linguagem == 0 ? "PONTOS x" : "POINTS x";
	if(global.andar == 1)
	{
		festa_titulo = "LEVEL " + string(global.level) + "!";
		festa_sub = _pt + string(global.level);
	}
	else
	{
		festa_titulo = (global.linguagem == 0 ? "ANDAR " : "FLOOR ") + string(global.andar) + "!";
		var _m = pontos_mult_andar();
		festa_sub = _pt + (frac(_m) == 0 ? string(_m) : string_format(_m, 1, 1)); //1.5 (E NAO 1.50)
	}
	var _meu_prox_y = todos_andares[global.andar];
	meu_y = minha_area.y + sprite_get_height(spr_area) - CEL*_meu_prox_y;
	
	//DESTRUINDO TODOS O BLOCOS PRA REINICIAR O LEVEL
	if(alarm[0] == -1) alarm[0] = 5;
	//RESETANDO AS LINHAS
	linhas_atuais = global.linhas_completadas;
	global.linhas_completadas = 0;
}

//RETANGULO DE DEBUG ANTIGO (NAO E MAIS USADO)
draw_rec = false;
rec_x	= noone;
rec_xx	= noone;
rec_y	= noone;
rec_yy	= noone;

//LIMPA A ARENA: CRIA O EFEITO QUE QUEBRA TODOS OS BLOCOS
destruir_blocos = function()
{
	minha_area = instance_place(x, y, [obj_area, obj_area_versus]);
	
	if(place_meeting(x, y, minha_area)) 
	{
		if(place_meeting(x -1, y, obj_parede))
		{
			var _efeito = instance_create_layer(minha_area.x, y+(16*linhas_atuais)/2, "Linha", obj_efeito_animacao);
			_efeito.sprite_index = spr_efeito_destroi_block;
			_efeito.depth = -1000;
			_efeito.image_yscale = linhas_atuais;
			_efeito.destruir_blocos = true;
		}
	}
	
}







