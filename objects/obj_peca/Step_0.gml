//PAUSADO: A PEÇA FICA PARADA
//NO TEMPO PARADO O BLOCO NAO CAI, MAS O PLAYER AINDA EMPURRA ELE PRO LADO
if(global.game_pause)
{
	if(tempo_player_livre() and prox_x != x)
	{
		x = lerp(x, prox_x, .4);
		if(abs(x - prox_x) < .1) x = prox_x;
	}
	exit;
}

//PEDRA: TEMPINHO SEM LEVAR GOLPE DEPOIS DE RACHAR
if(pedra_imune > 0) pedra_imune--;

var _block = false;	//NAO USADO

//CHAO (BLOCO PARADO) E PEÇA LOGO EMBAIXO
var _chao = place_meeting(x, y + 1, obj_block);
var _peca = instance_place(x, y + 1, [obj_peca, obj_mask_fa]);

//FANTASMA ANTIGO: OLHAVA PELA MASCARA DELE
if(sou_fantasma)
{
	with(mask_fantasma)
	{
		_chao = place_meeting(x, y + 1, obj_block);
		_peca = instance_place(x, y + 1, [obj_peca, obj_mask_fa]);
	}
}

//TEM ALGO EMBAIXO? (CONTANDO A PEÇA INTEIRA SE AINDA FOR IRMANDADE)
var _colidindo = check_colisao();

//LETRA GUARDADA NO BLOCO SOME SE O PLAYER NAO PEGAR A TEMPO
if(letra >= 0)
{
	letra_timer--;
	if(letra_timer <= 0) letra = -1;
}

//BLOCO SENSOR: PARADO, QUANDO O PLAYER PASSA NA LINHA DELE (A QUALQUER DISTANCIA) ELE SE REVELA, TREME
//E SE LANÇA PRA FRENTE (OBJ_SENSOR_VOANDO)
//(DEPOIS DE REVELADO ELE SEMPRE SE LANÇA: ANTES, SE O BLOCO DEIXASSE DE ESTAR "PARADO" NO MEIO DA CONTAGEM
//- UM BLOCO DO LADO MEXENDO NO GRUPO, POR EXEMPLO - A CONTAGEM TRAVAVA E ELE FICAVA TREMENDO PRA SEMPRE)
if(sou_sensor and destruido_por == noone and player_perto(x, y) != noone)
{
	//PLAYER VIVO NA MESMA LINHA DO BLOCO (SENAO, O MAIS PERTO)
	var _pl = noone;
	with(obj_player) if(estado != state.morte and bbox_bottom > other.bbox_top and bbox_top < other.bbox_bottom) _pl = id;
	if(_pl == noone) _pl = player_perto(x, y);
	//AINDA ESCONDIDO: O PLAYER ENTROU NA MESMA LINHA E O BLOCO TA PARADO -> REVELA E COMEÇA A CONTAGEM
	if(sensor_timer < 0)
	{
		if(estou_parado and !andar and _pl.estado != state.morte and _pl.bbox_bottom > bbox_top and _pl.bbox_top < bbox_bottom)
		{
			sensor_timer = SENSOR_AVISO;
			som_tocar(snd_menu_erro_03);
		}
	}
	else
	{
		//REVELADO: CONTAGEM ACABOU, VIRA O SENSOR VOANDO NA DIREÇAO DO PLAYER E ESSE BLOCO SOME
		sensor_timer--;
		if(sensor_timer <= 0)
		{
			var _s = instance_create_depth(x, y, depth, obj_sensor_voando);
			_s.dir = _pl.x < x ? -1 : 1;
			_s.frame = image_index;
			destruido_por = "sensor";
			efeito_morte = false;
			instance_destroy();
			exit;
		}
	}
}

//BLOCO FUJAO: TEM MOEDA DENTRO. QUANDO O PLAYER CHEGA PERTO ELE ACORDA, QUEBRA A PEÇA (SE TAVA NUMA) E FOGE
//PELA GRADE UMA CASA POR VEZ, PRA CIMA, BAIXO OU PROS LADOS (ACORDADO ELE NAO CAI: E UM BLOCO ESPERTO).
//SO FICA ENCURRALADO SE AS 4 CASAS EM VOLTA TIVEREM BLOCO, PAREDE, CHAO OU O PLAYER.
//COM O PLAYER LONGE, VOLTA A SER UM BLOCO NORMAL (E CAI SE TIVER NO AR)
if(sou_fujao and destruido_por == noone)
{
	var _pl = player_perto(x, y);
	var _d = _pl == noone ? infinity : point_distance(x, y, _pl.x, _pl.y - 10);
	if(!fujao_acordado and _d < FUJAO_PERTO)
	{
		fujao_acordado = true;
		fujao_espera = 8;
		esc = 1.25; //SUSTO
	}
	else if(fujao_acordado and _d > FUJAO_LONGE) fujao_acordado = false;

	//ACORDOU: ASSUME O CONTROLE QUANDO ESTIVER NUMA CASA DA GRADE (NAO NO MEIO DE UMA QUEDA OU DE UM EMPURRAO).
	//NUMA PEÇA, SO DEPOIS DELA ASSENTAR. A PEÇA ATUAL DO TELEPORTE SO FOGE DEPOIS DE ASSENTAR (AI SAI DA FILA)
	if(fujao_acordado and !fujao_controle and !andar and x == prox_x and (estou_parado or (pai != global.peca_inst and id != global.peca_inst))
	and !(irmandade and (!estou_parado or (instance_exists(pai) and pai.andar))))
	{
		if(irmandade) quebrar_irmandade(timer_move, false); //A PEÇA INTEIRA SE SEPARA
		fila_remover(id);
		esvaziar_grid();
		fujao_controle = true;
		estou_parado = false;
		velh = 0;
		velv = 0;
		y = grid_alinhar_y(y);
		fujao_alvo_x = x;
		fujao_alvo_y = y;
		fujao_ant_x = x;
		fujao_ant_y = y;
	}

	if(fujao_controle)
	{
		//DESLIZA ATE A CASA ESCOLHIDA
		velh = 0;
		velv = 0;
		x += clamp(fujao_alvo_x - x, -FUJAO_VEL, FUJAO_VEL);
		y += clamp(fujao_alvo_y - y, -FUJAO_VEL, FUJAO_VEL);
		prox_x = x;
		prox_y = y + CEL;

		if(x == fujao_alvo_x and y == fujao_alvo_y)
		{
			if(fujao_espera > 0) fujao_espera--;
			//PLAYER LONGE: SOLTA O CONTROLE E VOLTA A SER UM BLOCO NORMAL (A QUEDA E A GRADE FICAM COM O RESTO DO STEP)
			else if(!fujao_acordado)
			{
				fujao_controle = false;
				fujao_encurralado = false;
				andar = false;
				cair = true;
				timer_move = meu_timer;
			}
			else
			{
				//ESCOLHE, ENTRE AS CASAS LIVRES EM VOLTA, A QUE FICA MAIS LONGE DO PLAYER (PREFERE OS LADOS).
				//SO VOLTA PRA CASA DE ONDE VEIO SE NAO TIVER OUTRA (SENAO FICAVA INDO E VOLTANDO)
				var _dx = [CEL, -CEL, 0, 0];
				var _dy = [0, 0, -CEL, CEL];
				var _melhor = -1, _melhor_d = -infinity, _volta = -1;
				for(var k = 0; k < 4; k++)
				{
					var _nx = x + _dx[k], _ny = y + _dy[k];
					if(!fujao_livre(_nx, _ny)) continue;
					if(_nx == fujao_ant_x and _ny == fujao_ant_y) { _volta = k; continue; }
					var _nd = _pl == noone ? 0 : point_distance(_nx, _ny, _pl.x, _pl.y - 10);
					if(_dy[k] == 0) _nd += 8; //PREFERE FUGIR PROS LADOS
					if(_nd > _melhor_d) { _melhor_d = _nd; _melhor = k; }
				}
				if(_melhor < 0) _melhor = _volta;

				if(_melhor < 0) fujao_encurralado = true; //AS 4 CASAS FECHADAS: TREME DE MEDO
				else
				{
					fujao_ant_x = x;
					fujao_ant_y = y;
					fujao_alvo_x = x + _dx[_melhor];
					fujao_alvo_y = y + _dy[_melhor];
					fujao_espera = FUJAO_PASSO;
					fujao_encurralado = false;
					esc = 1.1;
				}
			}
		}
		//NO CONTROLE O RESTO DO STEP (QUEDA, GRADE, EMPURRAR O PLAYER) NAO RODA
		exit;
	}
}

//BLOCO QUICANDO NA GELATINA: SOBE E CAI COMO UMA BOLA (SEM PARAR NAS CASAS). BATEU NA GELATINA DE NOVO: QUICA OUTRA
//VEZ, A NAO SER QUE TENHA UM BLOCO EM CIMA DELE (AI PARA E ASSENTA). COM O PLAYER EM CIMA ELE ESPERA. CAIU EM OUTRA COISA: VOLTA AO NORMAL
if(gel_quicando)
{
	gel_vel = min(gel_vel + GEL_GRAVIDADE, 4);
	var _v = gel_vel;
	if(_v < 0)
	{
		//SUBINDO: PARA SE FOR BATER EM ALGO OU NO TOPO DA ARENA (E COMEÇA A CAIR)
		if((instance_exists(obj_area) and bbox_top + _v < obj_area.y) or gel_bate(_v, true)) gel_vel = 0;
		else y += _v;
	}
	else if(gel_bate(_v))
	{
		//CAINDO: ENCOSTA NO QUE TIVER EMBAIXO
		while(!gel_bate(1)) y += 1;
		y = grid_alinhar_y(y);
		if(gel_embaixo() != noone and !gel_tem_cima())
		{
			if(!place_meeting(x, y - 1, obj_player)) gel_impulso();
			else gel_vel = 0;
		}
		else
		{
			//PAROU DE QUICAR: VOLTA A SER UM BLOCO NORMAL (O RESTO DO STEP ASSENTA ELE NO PROXIMO FRAME)
			gel_quicando = false;
			gel_vel = 0;
			prox_y = y + CEL;
			timer_move = 0;
		}
	}
	else
	{
		//CAINDO NO AR. EM CIMA DO PLAYER: EMPURRA OU ESMAGA (IGUAL A PEÇA)
		y += _v;
		velv = _v;
		empurrar_player();
		velv = 0;
	}
	prox_x = x;
	exit;
}

//COLMEIA: PARADA, SOLTA UMA ABELHA DE TEMPOS EM TEMPOS (NO MAXIMO ABELHA_MAX VOANDO). CAINDO, A CONTAGEM RECOMEÇA
if(sou_colmeia and destruido_por == noone)
{
	if(estou_parado and !andar)
	{
		colmeia_timer--;
		if(colmeia_timer <= 0)
		{
			colmeia_timer = COLMEIA_TEMPO;
			var _voando = 0;
			with(obj_abelha) if(dono == other.id) _voando++;
			if(_voando < ABELHA_MAX)
			{
				for(var k = 0; k < min(ABELHA_POR_VEZ, ABELHA_MAX - _voando); k++) instance_create_depth(x - 3 + 6 * k, y - 4, -1600, obj_abelha, { dono : id });
				esc = 1.2;
				audio_play_sound(snd_zumbido, 1, false, .7, 0, .9 + random(.2));
			}
		}
	}
	else colmeia_timer = COLMEIA_PRIMEIRA;
}

//BURACO: PARADO, ENGOLE O BLOCO QUE CAIR EM CIMA DELE. DEPOIS DE ENGOLIR RECARREGA BURACO_ESPERA (O BLOCO QUE
//CAIR EM CIMA NESSE TEMPO FICA ESPERANDO E E ENGOLIDO QUANDO ELE FICAR PRONTO). PRONTO DE NOVO: PISCA
if(sou_buraco and destruido_por == noone)
{
	if(buraco_espera > 0)
	{
		buraco_espera--;
		if(buraco_espera == 0)
		{
			alpha_fog = .8;
			esc = 1.2;
			audio_play_sound(snd_engolir, 1, false, .35, 0, 2);
		}
	}
	else if(estou_parado and !andar)
	{
		var _lista = ds_list_create();
		var _n = instance_place_list(x, y - 1, obj_peca, _lista, false);
		var _cima = noone;
		for(var k = 0; k < _n; k++)
		{
			var _b = _lista[| k];
			if(_b != id and _b.destruido_por == noone and _b.bbox_bottom <= bbox_top + 1 and !_b.fujao_controle and !_b.gel_quicando) _cima = _b;
		}
		ds_list_destroy(_lista);
		if(_cima != noone) buraco_engolir(_cima);
	}
}

#region CONTROLANDO OS TIPOS DE BLOCOS
	
	//CADA TIPO TEM SEU FRAME NA SPR_PECA (RAIVOSO 5, FANTASMA 6)
	if(sou_raivoso)		image_index = 5;
	
	else if(sou_fantasma)	image_index = 6;
	else if(sou_laser)	
	{
		
		//LASER: ANIMAÇAO DE CARREGAR E, NO FRAME 6, ATIRA NA DIREÇAO DO PLAYER
		image_speed = .4;
		nova_spr(spr_peca_laser);
		//SE ELE OFR LASER VAMOS ATIRAR
		if(ultima_spr() and alarm[2] == -1) alarm[2] = room_speed * 3; //ESPERA ENTRE OS TIROS (ERA 2S)
		var _alvo = player_perto(x, y); //NO COOP ATIRA NO MAIS PERTO
		//LASER LATERAL: TIRO RETO PRO LADO MAIS ABERTO (NA METADE DIREITA DA ARENA ATIRA PRA ESQUERDA E VICE-VERSA)
		if(laser_lado and image_index >= 6 and !dano)
		{
			var _meio = instance_exists(obj_area) ? obj_area.x + obj_area.sprite_width / 2 : room_width / 2;
			dano = instance_create_depth(x, y, depth - 50, obj_bala_laser);
			dano.image_angle = x > _meio ? 180 : 0;
			dano.pai = id;
			dano.lateral = true;
			onda_choque(x, y, 26, 2, 14);
			som_tocar(snd_tiro_laser, .1);
		}
		if(!laser_lado and image_index >= 6 and !dano and _alvo != noone)
		{
			var _dir = point_direction(x, y, _alvo.x, _alvo.y);
			dano = instance_create_depth(x, y+2, depth-50, obj_bala_laser);
			dano.image_angle = _dir;
			dano.pai = id;
			onda_choque(x, y + 2, 26, 2, 14); //ONDA BEM LEVE NO DISPARO
			som_tocar(snd_tiro_laser, .1);
			//CODIGO ANTIGO DESLIGADO (ATIRAVA PROS DOIS LADOS)
			//FOR(VAR I = 0; I < 2; I++)
			//{
			//	DANO = INSTANCE_CREATE_DEPTH((X - 3) + 6*I, Y+2, DEPTH-50, OBJ_BALA_LASER);
			//	DANO.IMAGE_XSCALE = I == 0 ? -1 : 1;
			//	DANO.VELH = 2.5 * (I == 0 ? -1 : 1);
			//	DANO.PAI = ID;
			//}
		}
	}
	else
	{
		//ARRUMANDO A COR/INDEX
		switch(coloracao)
		{
			case cores.c_green	: image_index = 0; break;
			case cores.c_yellow	: image_index = 1; break;
			case cores.c_purple	: image_index = 2; break;
			case cores.c_aqua	: image_index = 3; break;
			case cores.c_red	: image_index = 4; break;
		}
	}
	//SOLIDO NAO TEM FRAME PROPRIO AQUI
	//IF(SOU_SOLIDO) 
	
#endregion

//PAI CONTROLANDO TUDO E TODOS POIS AINDA SOMOS IRMAOS
if(prox_x != x)
{
	//DESLIZA ATE A COLUNA NOVA (FOI EMPURRADA)
	x = lerp(x, prox_x, .4)
	//CHEGOU: FICA EXATAMENTE NA GRADE (ANTES SO ENCAIXAVA SE TIVESSE ALGO EMBAIXO E FICAVA 0.1PX TORTO)
	if(abs(x - prox_x) < .1) x = prox_x;
	//CHEGOU E TEM ALGO EMBAIXO: MARCA NA GRADE
	if(x == prox_x and collision_line(x, y, x, y + 10, [obj_block,obj_peca], 0, 1)) 
	{
		//EMPURRADO PRA CIMA DE UMA GELATINA: QUICA (IGUAL AO BLOCO QUE CAI NELA)
		if(gel_quicar()) exit;
		var _p = instance_place(x, y + 1, [obj_peca, obj_mask_fa]);
		
		if(irmandade)
		{
			ajustando_tempo_e_grid();
		}
		else
		{
			if(_p)
			{
				if(!_p.andar) preencher_grid();
			}
			else preencher_grid();
		}
	}
}
		
//PEÇA INTEIRA (IRMANDADE): SO O PAI CUIDA DA QUEDA DE TODO MUNDO
if(irmandade)
{
	if(sou_pai) 
	{
		if(andar)//EM MOVIMENTO
		{
			controlando_velocidade(sou_raivoso ? vel_raivoso : vel);
			//CHEGOU NA PROXIMA CASA: PARA E ESPERA O TEMPO DA QUEDA
			if (round(y) >= prox_y)
			{
				//A RAIVOSA NAO PARA ENTRE AS CASAS (CONTINUA DESCENDO DURANTE A ESPERA), ENTAO O PROX_Y DELA FICA
				//PRA TRAS: ANTES O PAI VOLTAVA PRA ELE (ATE 64PX PRA CIMA) E OS IRMAOS SEGUIAM SEM ELE
				if(!sou_raivoso)
				{
					controlando_velocidade(0);
					y = prox_y;
				}
				ajustando_posicao();
				andar = false;
				timer_move = meu_timer;
			} 
		}
		
		else //PARADO
		{
			//SE AINDA NAO PAREI DE VERDADE
			if(!estou_parado)
			{
				//NAO TEM NADA EMBAIXO: ESPERA O TEMPO E DESCE MAIS UMA CASA
				if(!_colidindo)
				{
					//GAMEFEEL - SHAKE =================
					if(cair)
					{
						timer ++;
						shake = .4 * cos(timer/1.5);
						if(timer > 12) 
						{
							cair = false
							timer = 0;
						}
					}else shake = lerp(shake, 0, .2);
					gamefeel_shake(); //PASSANDO O SSHAKE PROS IRMAOSS
					//GAMEFEEL - SHAKE =================
					
					//PEÇA RAIVOSA NAO PODE SER TELEPORTADA: SAI DA FILA
					if(sou_raivoso) fila_remover(id);
					
					timer_move -= peca_velocidade_tempo(); //MAIS DEVAGAR/RAPIDO COM O BLOCO ESPECIAL
					if(timer_move <= 0) 
					{
						andar = true;
					}
				}else
				//BATEU EM ALGO: A PEÇA ASSENTOU
				{
					//GELATINA EMBAIXO: A PEÇA QUICA PRA CIMA EM VEZ DE ASSENTAR
					if(gel_quicar()) exit;
					geral_parado(true, sou_raivoso);
					ajustando_tempo_e_grid();
					
					//PAROU: NAO DA MAIS PRA TELEPORTAR, SAI DA FILA
					fila_remover(id);
				}
			}else
			{
				//JA TAVA PARADA E O QUE TINHA EMBAIXO SUMIU: VOLTA A CAIR
				if(!_colidindo)
				{
					geral_parado(false);
					cair = true;
					esvaziar_grid_irmaos();
				}
			}
		}
	}
	//(A COLISAO DE VERDADE FICA NO END STEP)
	//COLISAO
}
//BLOCO SOZINHO (SEM IRMANDADE): MESMA LOGICA, SO PRA ELE
else
{
	if(andar)//EM MOVIMENTO
	{
		velv = sou_raivoso ? vel_raivoso : vel;
		
		//CHEGOU NA PROXIMA CASA: PARA E ESPERA O TEMPO DA QUEDA
		if (y >= prox_y-.1)
		{
			//DEBUG ANTIGO DESLIGADO
			//SHOW_MESSAGE(PROX_Y)
			//SHOW_MESSAGE(Y)
			y = prox_y;        // <-- ADICIONAR: FORÇA O SNAP EXATO
			//INSTANCE_DESTROY()
			velv = 0;
			prox_y += CEL;
			andar = false;
			timer_move = meu_timer;
		} 
		
	}
	else //PARADO
	{
		if(!estou_parado)
		{
			if(!_colidindo)
			{
				//GAMEFEEL - SHAKE =================
				if(cair)
				{
					timer ++;
					shake = .4 * cos(timer/1.5);
					if(timer > 12) 
					{
						cair = false
						timer = 0;
					}
				}else shake = lerp(shake, 0, .2);
				//GAMEFEEL - SHAKE =================
				
				//SO ESPERA O BLOCO DE BAIXO SE ELE AINDA TA CAINDO (ANTES ESPERAVA QUALQUER BLOCO A 2PX:
				//SE O DE BAIXO TRAVASSE OU TIVESSE 1PX DE FOLGA, ESSE FICAVA PARADO NO AR PRA SEMPRE)
				var _tes = instance_place(x, y + 2, [obj_peca, obj_mask_fa]);
				var _esperar = false;
				if(_tes)
				{
					var _tes_pai = instance_exists(_tes.pai) ? _tes.pai : _tes;
					_esperar = _tes_pai.andar or _tes.velv > 0;
				}
				if(!_esperar) timer_move -= peca_velocidade_tempo();
				
				
				if(timer_move <= 0) 
				{
					
					andar = true;
				}
			//BATEU EM ALGO: ASSENTOU
			}else
			{
				//GELATINA EMBAIXO: O BLOCO QUICA PRA CIMA EM VEZ DE ASSENTAR
				if(gel_quicar()) exit;
				avisando_que_estao_parado(true);
				ajustando_tempo_e_grid();
			}
		}
		//JA TAVA PARADO E O QUE TINHA EMBAIXO SUMIU: VOLTA A CAIR
		else
		{
			if(!_colidindo)
			{
				avisando_que_estao_parado(false)
				cair = true;
				esvaziar_grid();
			}
		}
	}
}

//A CADA 5 FRAMES, CHECA E CORRIGE DESALINHAMENTO DE GRID
if(estou_parado) 
{
	var _col = instance_place(x, y +1, obj_peca);	//NAO USADO
	
	//A CONTAGEM ESTA DESLIGADA: A CORREÇAO SO ACONTECE QUANDO A PEÇA PARA (GERAL_PARADO)
	//TIMER_VERIFICACAO_GRID++;
	
}
else timer_verificacao_grid = 0; // RESETA SE VOLTAR A SE MOVER, EVITA CORRIGIR LOGO NO FRAME SEGUINTE

if(timer_verificacao_grid >= 5)
{
	timer_verificacao_grid = 0;
	
	if(estou_parado && (!irmandade || sou_pai))
	{
		corrigir_alinhamento_grid();
	}
}

//COISAS DO PLAYER (O FANTASMA NAO MEXE NO PLAYER, ELE ATRAVESSA)
if(!sou_fantasma)
{
	//LOGO DEPOIS DO TELEPORTE: SE A PEÇA CAIU EM CIMA DO PLAYER, EMPURRA ELE PRA CIMA ATE SAIR
	if(escorregar_player > 0)
	{
		escorregar_player--;
		var _player = instance_place(x, y, obj_player);
		while(_player)
		{
			_player.y--;
			_player = instance_place(x, y, obj_player);
		}
	}

	//PLAYER EM CIMA DA PEÇA DESCE JUNTO COM ELA
	//(ANTES CHECAVA Y+1, QUE E EMBAIXO: A PEÇA EMPURRAVA O PLAYER PRA DENTRO DO CHAO EM VEZ DE ESMAGAR)
	//SO MEXE NO PLAYER SE ELE NAO ESTIVER SUBINDO (VELV >= 0).
	//ANTES SO IGNORAVA O ESTADO DE PULO: NO EMPURRAO DO DANO (QUE SOBE SEM SER PULO) A PEÇA PUXAVA
	//O PLAYER DE VOLTA TODO FRAME, O VELV FICAVA NEGATIVO PRA SEMPRE E ELE TRAVAVA NO ESTADO DE DANO
	var _player = instance_place(x, y - 1, obj_player);
	if(_player and _player.velv >= 0 and _player.y <= bbox_top + 1) _player.y += velv;

	//PLAYER UM POUCO ACIMA DA PEÇA (E NAO PULANDO): GRUDA ELE NO TOPO DELA
	_player = instance_place(x, y-5, obj_player);
	if(_player and _player.estado != state.jump and _player.velv >= 0) _player.y = bbox_top; 
}

