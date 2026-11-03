//SEM ARENA: ACABA. PAUSADO: ESPERA
if(!instance_exists(area)) { instance_destroy(); exit; }
if(obj_game_control.pausado) exit;
//O PLAYER MORREU (ESPINHOS): O GAME OVER ASSUME
if(todos_mortos()) { instance_destroy(); exit; }

//NAO NASCEM PEÇAS NOVAS DURANTE O MODO (OS ALARMES FICAM SEGURADOS)
desafio_segurar(global.quebra_parado);

//O CUBO GIRA SEMPRE DEVAGAR + O GIRO EXTRA DE CADA ETAPA (QUE VAI DIMINUINDO)
cubo_ang += .6;
var _g = cubo_giro * .12;
cubo_ang += _g;
cubo_giro -= _g;
//OS "POPS" E O TEMPO DO ERRO VOLTAM AO NORMAL
cubo_pop = lerp(cubo_pop, 0, .15);
for(var i = 0; i < array_length(seq_pop); i++) seq_pop[i] = lerp(seq_pop[i], 0, .2);
if(seq_erro > 0) seq_erro--;

switch(estado)
{
	//ALERTA: AVISO PISCANDO, BIP A CADA SEGUNDO E A LINHA DOS ANDARES VIBRANDO
	case "alerta":
		alpha = lerp(alpha, 1, .1);
		if(timer mod room_speed == 0) som_tocar(Bip_2);
		shakes(2, lerp(.4, 2.5, 1 - timer / QC_ALERTA)); //A GRADE VAI TREMENDO CADA VEZ MAIS
		with(obj_linha) intensidade = max(intensidade, lerp(2, 10, 1 - other.timer / QC_ALERTA));
		timer--;
		//ACABOU A CONTAGEM: TUDO PARA E COMEÇA A PRIMEIRA SEQUENCIA
		if(timer <= 0)
		{
			estado = "puzzle";
			global.quebra_parado = true;
			nova_sequencia();
			shakes(8, 2);
			som_tocar(zap1);
		}
		break;

	//PUZZLE: O CUBO CRESCE E OS ESPINHOS VAO DESCENDO
	case "puzzle":
		cubo_esc = lerp(cubo_esc, 1, .15);
		shakes(2, .5); //OS ESPINHOS RASPANDO: A GRADE FICA VIBRANDO DE LEVE
		espinho_alvo += QC_ESPINHO_VEL;
		espinho_y = lerp(espinho_y, espinho_alvo, .2);

		//SETAS
		if(seq_espera > 0) seq_espera--;
		else
		{
			//QUAL SETA FOI APERTADA (-1 = NENHUMA)
			var _dir = -1;
			if(keyboard_check_pressed(vk_right) or keyboard_check_pressed(ord("D")) or keyboard_check_pressed(global.imputs.rigth)) _dir = 0;
			if(keyboard_check_pressed(vk_up) or keyboard_check_pressed(ord("W"))) _dir = 1;
			if(keyboard_check_pressed(vk_left) or keyboard_check_pressed(ord("A")) or keyboard_check_pressed(global.imputs.left)) _dir = 2;
			if(keyboard_check_pressed(vk_down) or keyboard_check_pressed(ord("S")) or keyboard_check_pressed(global.imputs.down)) _dir = 3;
			if(_dir != -1)
			{
				//ACERTOU A SETA: ACENDE E VAI PRA PROXIMA
				if(_dir == seq[seq_pos])
				{
					seq_pop[seq_pos] = 1;
					seq_pos++;
					som_nota(4 + seq_pos, .6); //CADA SETA CERTA E A NOTA SEGUINTE
					if(seq_pos >= array_length(seq))
					{
						//ETAPA DO CUBO COMPLETA: OS ESPINHOS SOBEM 16PX
						passo++;
						qc_cubo_resolver(cubo, passos_total - passo + 1);
						cubo_refazer();
						cubo_giro += 90;
						cubo_pop = 1;
						espinho_alvo = max(area.y - 2, espinho_alvo - CEL);
						som_tocar(snd_pegar_moeda);
						//ERA A ULTIMA ETAPA: VENCEU. SENAO, PAUSINHA E SEQUENCIA NOVA
						if(passo >= passos_total) terminar(true);
						else
						{
							seq_espera = 15;
							nova_sequencia();
						}
					}
				}
				else
				{
					//ERROU: RECOMEÇA A SEQUENCIA E OS ESPINHOS DESCEM UM POUCO
					seq_pos = 0;
					seq_erro = 20;
					espinho_alvo += QC_ERRO_DESCE;
					som_tocar(snd_menu_erro_02);
					shakes(6, 2);
				}
			}
		}

		//OS ESPINHOS QUEBRAM OS BLOCOS QUE ENCOSTAM
		var _y = espinho_y;
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

		//OS ESPINHOS ENCOSTARAM NO PLAYER: LEVA DANO (PONTOS OU CORAÇAO) E O DESAFIO FALHA
		var _tocou = false;
		with(obj_player) if(estado != state.morte and bbox_top < _y - 2) { levar_dano(0); _tocou = true; }
		if(_tocou) terminar(false);
		break;

	//FIM: OS ESPINHOS SOBEM, A GUI SOME E O OBJETO SE DESTROI
	case "fim":
		espinho_y = lerp(espinho_y, espinho_alvo, .12);
		timer--;
		if(timer == QC_FIM - 20) global.quebra_parado = false; //O JOGO VOLTA ENQUANTO OS ESPINHOS SOBEM
		alpha = lerp(alpha, timer < 25 ? 0 : 1, .15);
		if(timer <= 0) instance_destroy();
		break;
}
