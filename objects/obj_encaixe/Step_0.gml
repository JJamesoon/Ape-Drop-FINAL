//SEM ARENA: ACABA. PAUSADO: ESPERA
if(!instance_exists(area)) { instance_destroy(); exit; }
if(obj_game_control.pausado) exit;
//O PLAYER MORREU (MURO): O GAME OVER ASSUME
if(todos_mortos()) { instance_destroy(); exit; }

//NAO NASCEM PEÇAS NOVAS DURANTE O MODO (OS ALARMES FICAM SEGURADOS)
desafio_segurar(global.quebra_parado);

//A PEÇA VAI ATRAS DA ROTAÇAO E DO ESPELHO (O ESPELHO ACHATA E VIRA)
ang = lerp(ang, rot * 90, .3);
esc_x = lerp(esc_x, esp ? -1 : 1, .3);
//OS "POPS", O ERRO E O FLASH VOLTAM AO NORMAL
pop = lerp(pop, 0, .15);
if(erro > 0) erro--;
if(flash > 0) flash--;

switch(estado)
{
	//ALERTA: AVISO PISCANDO, BIP A CADA SEGUNDO E A LINHA DOS ANDARES VIBRANDO
	case "alerta":
		alpha = lerp(alpha, 1, .1);
		if(timer mod room_speed == 0) som_tocar(Bip_2);
		shakes(2, lerp(.4, 2.5, 1 - timer / QC_ALERTA)); //A GRADE VAI TREMENDO CADA VEZ MAIS
		with(obj_linha) intensidade = max(intensidade, lerp(2, 10, 1 - other.timer / QC_ALERTA));
		timer--;
		//ACABOU A CONTAGEM: TUDO PARA, O MURO ENTRA E VEM A PRIMEIRA PEÇA
		if(timer <= 0)
		{
			estado = "puzzle";
			global.quebra_parado = true;
			muro_alvo = area.y + ENC_INICIO;
			nova_peca();
			shakes(8, 2);
			som_tocar(zap1);
		}
		break;

	case "puzzle":
		//PUZZLE: A PEÇA CRESCE E O MURO VAI DESCENDO
		esc_entra = lerp(esc_entra, 1, .15);
		shakes(2, .5); //O MURO RASPANDO: A GRADE FICA VIBRANDO DE LEVE
		muro_alvo += ENC_VEL;
		muro_y = lerp(muro_y, muro_alvo, .2);

		//A PEÇA TA VOANDO PRO BURACO: EM 14 FRAMES ENCAIXA
		if(voo >= 0)
		{
			voo++;
			if(voo >= 14) encaixou();
		}
		else if(espera > 0) espera--;
		else
		{
			//<- E -> GIRAM, ^ ESPELHA, V TENTA ENCAIXAR
			var _esq = keyboard_check_pressed(vk_left) or keyboard_check_pressed(ord("A")) or keyboard_check_pressed(global.imputs.left);
			var _dir = keyboard_check_pressed(vk_right) or keyboard_check_pressed(ord("D")) or keyboard_check_pressed(global.imputs.rigth);
			var _cima = keyboard_check_pressed(vk_up) or keyboard_check_pressed(ord("W"));
			var _baixo = keyboard_check_pressed(vk_down) or keyboard_check_pressed(ord("S")) or keyboard_check_pressed(global.imputs.down);
			if(_esq or _dir)
			{
				rot += _esq - _dir;
				pop = .25;
				som_tocar(snd_menu_select_03, .05);
			}
			if(_cima)
			{
				esp = !esp;
				pop = .25;
				som_tocar(snd_menu_select_03, .05);
			}
			if(_baixo)
			{
				//A FORMA ATUAL (GIRADA/ESPELHADA) E IGUAL A DO BURACO: VOA PRA LA
				if(enc_forma_chave(enc_forma(base, rot, esp)) == enc_forma_chave(alvo))
				{
					voo = 0;
					som_tocar(snd_roll);
				}
				else
				{
					//ERROU: O MURO DESCE UM POUCO
					erro = 20;
					muro_alvo += ENC_ERRO_DESCE;
					som_tocar(snd_menu_erro_02);
					shakes(6, 2);
				}
			}
		}

		//O MURO QUEBRA OS BLOCOS QUE ENCOSTA (CADA UM TIRA PONTOS)
		var _y = muro_y;
		var _quebrou = false;
		with(obj_peca) if(destruido_por == noone and bbox_top < _y - 2)
		{
			destruido_por = "espinho";
			_quebrou = true;
			instance_destroy();
		}
		//SOM DE QUEBRAR (NO MAXIMO A CADA 6 FRAMES)
		if(_quebrou and som_quebra <= 0)
		{
			audio_play_sound(snd_peca_destroy, 1, false, .6, 0, .8 + random(.3));
			shakes(4, 1);
			som_quebra = 6;
		}
		if(som_quebra > 0) som_quebra--;

		//ENCOSTOU NO PLAYER: LEVA DANO (PONTOS OU CORAÇAO) E O DESAFIO FALHA
		var _tocou = false;
		if(estado == "puzzle") with(obj_player) if(estado != state.morte and bbox_top < _y - 2) { levar_dano(0); _tocou = true; }
		if(_tocou) terminar(false);
		break;

	//FIM: O MURO SOBE, A GUI SOME E O OBJETO SE DESTROI
	case "fim":
		muro_y = lerp(muro_y, muro_alvo, .12);
		timer--;
		if(timer == QC_FIM - 20) global.quebra_parado = false; //O JOGO VOLTA ENQUANTO O MURO SOBE
		alpha = lerp(alpha, timer < 25 ? 0 : 1, .15);
		if(timer <= 0) instance_destroy();
		break;
}
