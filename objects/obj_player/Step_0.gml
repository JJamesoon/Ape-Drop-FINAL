//MORTE: PARA UM POUCO, PULA E CAI PRA FORA DA TELA (SEM COLISAO)
//RODA ANTES DO PAUSE PORQUE O JOGO PAUSA ENQUANTO O PLAYER MORRE
if(estado == state.morte)
{
	//SPRITE DE DANO, CONTA O TEMPO E DEPOIS DE 25 FRAMES COMEÇA A CAIR
	nova_spr(spr_player_dano);
	image_speed = .4;
	timer_morte++;
	if(timer_morte > 25)
	{
		velv += GRAVID;
		y += velv;
	}
	//COOP: COM O PARCEIRO VIVO, VOLTA DEPOIS DE UM TEMPO
	if(global.coop and !global.game_pause and !todos_mortos())
	{
		reviver--;
		if(reviver <= 0) reviver_agora();
	}
	exit;
}

//PAUSADO (MENU, DESAFIO, HITSTOP): O PLAYER NAO FAZ NADA
if(global.game_pause and !tempo_player_livre()) exit; //NO TEMPO PARADO SO O PLAYER ANDA

//(O PLAYER PASSA POR DENTRO DO BLOCO FANTASMA: AS COLISOES DELE USAM SOLIDO/SOLIDO_INST/PECA_SOLIDA DO CREATE)
//O QUE TEM EMBAIXO DO PE: QUALQUER COISA SOLIDA E A PEÇA (SE FOR UMA)
var _block = solido_inst(x, y + 1);
var _peca = peca_solida(x, y + 1);
var _bloco_fantasma = false;
if(_peca) if(_peca.sou_fantasma) _bloco_fantasma = true;
//EM CIMA DE UM BLOCO DE GELO: ESCORREGA (O MOVER E AS FREADAS USAM POUCO ATRITO)
no_gelo = _peca != noone and _peca.sou_gelo;

//GELATINA: TRAMPOLIM. PISOU EM CIMA, E JOGADO PRA CIMA (SEGURANDO O PULO, MAIS ALTO). NO GIRO ELA QUEBRA NORMAL
if(velv >= 0) pulo_trampolim = false;
//(SO SE A GELATINA TIVER EMBAIXO DOS PES: SE ELA TA CAINDO POR CIMA DO PLAYER, ELA EMPURRA ELE PRA BAIXO COMO UM BLOCO NORMAL)
//(NO TEMPO PARADO A GELATINA FICA CONGELADA: E SO UM BLOCO, NAO QUICA NEM EMPURRA)
if(_peca != noone and _peca.sou_gelatina and _peca.bbox_top >= y - 3 and velv >= 0 and estado != state.giro and estado != state.dash and !tempo_ativo())
{
	velv = -vel_jump * (keyboard_check(imp.jump_press) ? GEL_TRAMPOLIM_FORTE : GEL_TRAMPOLIM);
	estado = state.jump;
	girar_jump = true;
	pulo_trampolim = true;
	esc_x = .7 * image_xscale;
	esc_y = 1.4;
	with(_peca) { gel_balanco = 1; esc = 1.2; }
	audio_play_sound(snd_boing, 1, false, .9, 0, 1.2 + random(.1));
	_block = noone; //JA SAIU DO CHAO (O RESTO DO STEP NAO PODE ACHAR QUE TA PISANDO)
	_peca = noone;
}
//GELATINA DO LADO: ENCOSTOU NA LATERAL, E JOGADO UM POUCO PRO OUTRO LADO (COM UM PULINHO)
if(estado != state.giro and !tempo_ativo())
{
	var _gel_lado = 0, _gel = noone;
	var _gd = peca_solida(x + 1, y - 3);
	var _ge = peca_solida(x - 1, y - 3);
	//(SO SE ELA TIVER DO LADO DE VERDADE: SE JA TA ENCOSTANDO NO PLAYER SEM ELE ANDAR, E PORQUE TA POR CIMA DELE)
	if(_gd != noone and _gd.sou_gelatina and !place_meeting(x, y - 3, _gd)) { _gel_lado = 1; _gel = _gd; }
	else if(_ge != noone and _ge.sou_gelatina and !place_meeting(x, y - 3, _ge)) { _gel_lado = -1; _gel = _ge; }
	if(_gel_lado != 0)
	{
		velh = -_gel_lado * GEL_EMPURRAO;
		velv = min(velv, -.8);
		estado = state.jump;
		timer_mover = 6;	//UNS FRAMES SEM CONTROLE (SENAO SEGURANDO PRO LADO ELE VOLTAVA NA HORA)
		pulo_trampolim = true;
		esc_x = 1.25 * image_xscale;
		esc_y = .8;
		with(_gel) { gel_balanco = 1; esc = 1.15; }
		audio_play_sound(snd_boing, 1, false, .6, 0, 1.4 + random(.1));
		_block = noone;
		_peca = noone;
	}
}

//COOP: CAIU NA CABEÇA DO PARCEIRO -> QUICA, E ELE LEVA SO O EFEITO DO DANO (NAO PERDE VIDA)
if(pisca_dano > 0) pisca_dano--;
if(global.coop and velv > 0 and estado != state.giro)
{
	var _par = instance_place(x, y + velv + 1, obj_player);
	if(_par != noone and _par.estado != state.morte and _par.estado != state.dano and bbox_bottom <= _par.bbox_top + 2 + velv)
	{
		y = _par.bbox_top - (bbox_bottom - y) - 1;
		quicar();
		_par.efeito_dano(_par.x < x ? -1 : 1);
	}
}

//IMPUTS**********************
//TODAS COMEÇAM DESLIGADAS E DEPOIS LEEM AS TECLAS DO LAYOUT ESCOLHIDO
var _left, _right, _up, _down, _soco_press, _soco, _jump, _jump_press, _jump_giro, _jump_giro_press, _dash;
_left			= false;
_right			= false;
_up				= false;
_down			= false;
_soco_press		= false;
_soco			= false;
_dash			= false;

_jump			= false;
_jump_press		= false;
_jump_giro		= false;
_jump_giro_press= false;

_left			= keyboard_check(imp.left);
_right			= keyboard_check(imp.rigth);
_down			= keyboard_check(imp.down);
_soco_press		= keyboard_check_pressed(imp.soco_press);
_soco			= keyboard_check_pressed(imp.soco);

_jump			= keyboard_check_pressed(imp.jump);
_jump_press		= keyboard_check(imp.jump_press);
_jump_giro		= keyboard_check_pressed(imp.giro);
_jump_giro_press= keyboard_check(imp.giro_press);
_dash			= keyboard_check_pressed(imp.dash);

//VIRA PRO LADO QUE TA APERTANDO (MENOS NO MEIO DE UM SOCO)
if(_left xor _right and estado != state.soco and estado != state.super_soco) 
{
	if(estado != state.dano) image_xscale = sign(_right - _left);
	esc_x = image_xscale;
}

//COLISORES***************
var _obj_colisao = [obj_block, obj_peca];

//TIMERS
if(timer_mover > 0) timer_mover--;	//TEMPO DO WALL JUMP
if(timer_jump > 0) timer_jump--;	//COYOTE JUMP (PULAR LOGO DEPOIS DE SAIR DA BEIRADA)
if(imune > 0) imune--;	//INVENCIVEL DEPOIS DE LEVAR DANO
if(lento > 0) lento--;	//FEITIÇO DO BLOCO LENTO
if(rapido > 0) rapido--;	//VELOCIDADE DE QUEM QUEBROU O BLOCO LENTO
if(escudo_bloqueio > 0) escudo_bloqueio--;	//EFEITO DO ESCUDO BLOQUEANDO
//GIRO DE FOGO: O TEMPO PRA EMENDAR O PROXIMO GIRO SO CORRE QUANDO NAO TA GIRANDO. ACABOU: O FOGO APAGA
if(estado != state.giro and giro_janela > 0)
{
	giro_janela--;
	if(giro_janela <= 0) giro_seq = 0;
}
if(recarga_dash > 0) recarga_dash--;	//RECARGA DO DASH

//DASH: FUNCIONA NO CHAO E NO AR, COM UM TEMPO DE RECARGA
var _pode_dash = estado == state.idle or estado == state.idle_mudar_lado or estado == state.in_run or estado == state.run or estado == state.run_stop or estado == state.jump;
if(_dash and recarga_dash <= 0 and _pode_dash)
{
	//DIREÇAO NORMAL DO DASH: PRA FRENTE
	if(_left xor _right) image_xscale = sign(_right - _left);
	dash_dx = image_xscale;
	dash_dy = 0;
	//PODER DO DASH: VAI PRA DIREÇAO DAS TECLAS (8 DIREÇOES, IGUAL CELESTE). A TECLA DE PULO E O "CIMA"
	if(tem_poder("dash"))
	{
		var _dx = _right - _left;
		//(NO COOP SO A TECLA DE PULO DE CADA UM: AS SETAS E O W SAO DOS DOIS JOGADORES)
		var _cima = keyboard_check(imp.jump) or (!global.coop and (keyboard_check(vk_up) or keyboard_check(ord("W"))));
		var _dy = (_down or (!global.coop and keyboard_check(vk_down))) - _cima;
		if(_dx != 0 or _dy != 0)
		{
			var _l = point_distance(0, 0, _dx, _dy);
			dash_dx = _dx / _l;
			dash_dy = _dy / _l;
		}
	}
	//COMEÇA O DASH: SEM GRAVIDADE E COM UM BRILHO
	estado = state.dash;
	timer_dash = DASH_TEMPO;
	recarga_dash = DASH_RECARGA;
	velv = 0;
	alpha_fog = .6;
}

//GAMEFEEL: POEIRA QUANDO SAI DO CHAO PULANDO E QUANDO CAI FORTE
if(_block and !chao_antes and velv_antes > 2.5) { poeira(x, y, 5); esc_x = 1.3 * image_xscale; esc_y = .75; }
if(!_block and chao_antes and velv < 0) poeira(x, y, 3);
chao_antes = _block != noone;
velv_antes = velv;

//PISOU NO CHAO (FORA DO GIRO): ZERA O QUIQUE EM CADEIA E O PULO DUPLO DAS ASAS
if(_block and velv >= 0 and estado != state.giro) quique_seq = 0;
if(_block and velv >= 0) pulo_duplo_usado = false;

//PODERES: A ENERGIA DO REFLEXO E O ESCUDO RECUPERAM COM O TEMPO
if(tem_poder("reflexo")) reflexo_energia = min(100, reflexo_energia + REFLEXO_REGEN);
if(tem_poder("escudo"))
{
	escudo_vida = min(100, escudo_vida + ESCUDO_REGEN);
	if(escudo_quebrado and escudo_vida >= 100) escudo_quebrado = false;
}
if(mortal > 0) mortal--;	//TEMPO DO MORTAL DO REFLEXO

//ESPECIAL: BAIXO + SOCO EM CIMA DE UM BLOCO (DESTROI OS BLOCOS DA MESMA COR CONECTADOS)
var _no_chao = estado == state.idle or estado == state.idle_mudar_lado or estado == state.in_run or estado == state.run or estado == state.run_stop;
if(_down and _soco and _no_chao and _peca and !_peca.andar)
{
	especial_usar(_peca);
	_soco = false; //NAO SOCA NORMAL JUNTO
	esc_y = .7;
	esc_x = 1.3 * image_xscale;
}

//BAIXO + GIRO EM CIMA DE UMA PEÇA: JA QUEBRA O BLOCO DE BAIXO (SEM PRECISAR PULAR PRO GIRO NO AR)
if(estado != state.giro) giro_baixo = false;
if(_down and _jump_giro and _no_chao and _peca)
{
	onda_choque(_peca.x, _peca.y, 32, 3, 16);
	bloco_golpe(_peca);
	_peca = noone; //NAO EXISTE MAIS (O RESTO DO STEP NAO PODE USAR)
	_block = solido_inst(x, y + 1);
	audio_play_sound(snd_hit2, 1, false);
	estado = state.giro;
	giro_ar = false;
	giro_baixo = true; //ESSE GIRO NAO QUEBRA OS BLOCOS DO LADO
	image_index = 0;
	esc_y = .7;
	esc_x = 1.3 * image_xscale;
	_jump_giro = false;
}

//EM CIMA DE UMA PEÇA QUE AINDA TA CAINDO, SEGURANDO BAIXO: ELA DESCE DIRETO COM O PLAYER (SEM A PAUSA ENTRE AS CASAS)
if(_down and instance_exists(_peca) and !_peca.estou_parado)
{
	var _pai_peca = instance_exists(_peca.pai) ? _peca.pai : _peca;
	_pai_peca.timer_move = 0;
	//MOSTRA QUE TA ACELERANDO: A PEÇA BRILHA COM LINHAS DE VELOCIDADE E O PLAYER AGACHA
	if(global.peca_acelerada != _pai_peca or global.peca_acelerada_timer <= 0) som_tocar(snd_acelerar_peca, .05);
	global.peca_acelerada = _pai_peca;
	global.peca_acelerada_timer = 3;
	esc_y = lerp(esc_y, .82, .3);
}

//PULO VARIAVEL: SOLTOU O BOTAO DE PULO SUBINDO, CORTA O PULO
if(!_jump_press and velv < 0 and !_block and estado != state.dash and !pulo_trampolim) //NO DASH PRA CIMA E NO TRAMPOLIM NAO CORTA
{
	velv = max(velv, -vel_jump /2.3)
}

//MAQUINA DE ESTADOS DO PLAYER: CADA ESTADO CUIDA DA ANIMAÇAO, DO MOVIMENTO E DE PRA ONDE PODE IR
switch(estado)
{
	#region DASH
		case state.dash:
			//CORRENDO RAPIDO NA DIREÇAO DO DASH ATE O TEMPO ACABAR
			nova_spr(spr_player_dash_run);
			image_speed = .9;
			velh = DASH_VEL * dash_dx;
			velv = DASH_VEL * dash_dy; //NO AR ELE NAO CAI DURANTE O DASH (SO O PODER DO DASH VAI PRA CIMA/BAIXO)
			esc_x = 1.3 * image_xscale;
			esc_y = .8;
			timer_dash--;
			//ACABOU: SAI COM A VELOCIDADE DE CORRIDA (OU CAINDO SE TIVER NO AR)
			if(timer_dash <= 0)
			{
				velh = vel_run * dash_dx;
				velv = dash_dy * 2;
				if(!_block) estado = state.jump;
				else estado = _left xor _right ? state.run : state.idle;
			}
		break;
	#endregion
	#region DANO
		case state.dano:
			//EMPURRADO PRA TRAS, CAINDO E FREANDO
			nova_spr(spr_player_dano);
			image_speed = .4;
			scr_gravid();
			velh = lerp(velh, 0, .08);
			timer_dano++;
			//SAI QUANDO A ANIMAÇAO ACABA E ELE TA NO CHAO.
			//SEGURANÇA: DEPOIS DE 1 SEGUNDO SAI DE QUALQUER JEITO (NUNCA MAIS FICA PRESO NO DANO)
			if((ultima_spr() and _block and velv >= 0) or timer_dano > room_speed)
			{
				timer_dano = 0;
				estado = _block ? state.idle : state.jump;
			}
		break;
	#endregion
	#region MUDAR LADO
		case state.idle_mudar_lado:
		
			//ANIMAÇAO DE VIRAR PRO OUTRO LADO. SE APERTAR PRA ANDAR NO MEIO DELA, JA SAI CORRENDO
			image_speed = .5;
			velh = lerp(velh, 0, no_gelo ? GELO_ATRITO : .2); //NO GELO ESCORREGA
			nova_spr(spr_player_idle_virando);
			
			if(image_index > 1)
			{
				if(_left xor _right) 
				{
					image_xscale *= -1;
					esc_x = image_xscale;
					estado = state.in_run;
					velh = (vel_run + .2) * _right - _left;
				}
			}
			
			if(ultima_spr())
			{
				image_xscale *= -1;
				esc_x = image_xscale;
				estado = state.idle;
			}
		
		break;
	#endregion
	#region IDLE
		case state.idle:
		
			//PARADO: FREIA E ESPERA UMA TECLA
			nova_spr(red_idle2);
			velh = lerp(velh, 0, no_gelo ? GELO_ATRITO : .2); //NO GELO ESCORREGA
			
			//MOVENDO	
			if(_left xor _right) 
			{
				
				//COM PAREDE/BLOCO NA FRENTE JA VAI PRO RUN (PRA EMPURRAR), SENAO COMEÇA A CORRER
				if(solido(x + image_xscale, y)) estado = state.run;
				else
				{
					estado = state.in_run;
					if(!no_gelo) velh = (vel_run+.1) * _right - _left; //NO GELO SAI DEVAGAR (O IN_RUN ACELERA)
				}
				
			}
			
			//JUMP
			if(_jump)
			{
				velv = 0;
				velv -= vel_jump;
				estado = state.jump;
				girar_jump = true;
			}
			
			//SOCO
			if(_soco)
			{
				estado = state.soco;
			}
			//SUPER SOCO
			if(_soco_press)
			{
				estado = state.super_soco;
			}
			
			//CAIR
			if(!_block)
			{
				estado = state.jump;
				timer_jump = coyote_timer;	//COYOTE: AINDA DA PRA PULAR UNS FRAMES DEPOIS DE SAIR DA BEIRADA
			}
			
			//GIRO
			if(_jump_giro)
			{
				velh += image_xscale*2;
				estado = state.giro;
			}
			
		break;
	#endregion
	#region IN RUN
		case state.in_run:
			
			//COMEÇANDO A CORRER: ACELERA ATE A VELOCIDADE DE CORRIDA E DEPOIS VAI PRO RUN
			image_speed = .7;
			nova_spr(spr_player_dash_run);
			
			velh = lerp(velh, vel_run*image_xscale, no_gelo ? GELO_ATRITO : .1);
			if(ultima_spr()) estado = state.run;
			
			//CASO TENHA Q EMPURRAR PEÇA
			var _colisor = solido_linha(x, y - sprite_height/2, x + 10 * image_xscale, y - sprite_height/2);
			if(solido(x + image_xscale, y) and _colisor)
			{
				estado = state.run;
			}
			
			//JUMP
			if(_jump)
			{
				velv = 0;
				velv -= vel_jump;
				estado = state.jump;
				girar_jump = true;
			}
			
			// SOCO
			if(_soco)
			{
				estado = state.soco;
			}
			
			//SUPER SOCO
			if(_soco_press)
			{
				estado = state.super_soco;
			}
			
			//CAIR
			if(!_block)
			{
				estado = state.jump;
				timer_jump = coyote_timer;
			}
			
			//GIRO
			if(_jump_giro)
			{
				velh += image_xscale*1.5;
				estado = state.giro;
			}
 	break;
	#endregion
	#region RUN
		case state.run:
			
			//CORRENDO: ANDA E, SE TIVER UMA PEÇA NA FRENTE NA ALTURA DO PEITO, EMPURRA
			image_speed = .55;
			
			mover(vel_run);
			var _spr = red_corrida2;
			
			//GARANTINDO QUE BATE DE PEITO
			//EMPURRANDO NBLOCOS
			var _colisor = solido_linha(x, y - sprite_height/2, x + 10 * image_xscale, y - sprite_height/2);
			if(solido(x + image_xscale, y) and _colisor)
			{
				//TEM UMA PEÇA (NAO PAREDE) NA FRENTE
				var _fantasma = peca_solida(x + image_xscale, y);
				if(_fantasma)
				{
					_spr = spr_player_push;
				
					var _peca = peca_solida(x + _right - _left, y);
					var _livre = false;
				
					//A PEÇA SO ANDA SE TIVER ESPAÇO DO OUTRO LADO E NAO FOR DA IRMANDADE
					with(_peca)
					{
						if(!place_meeting(x + _right - _left, y, [obj_peca, obj_block]) and !irmandade)
						{
							_livre = true;
						}
					}
					//EMPURRANDO UM TEMPO (25 FRAMES): DA O EMPURRAO (ESTADO PUSH)
					if(_livre)
					{
						_spr = spr_player_push_run;
						timer_push++;
						if(timer_push >= 25)
						{
							estado = state.push;
							timer_push = 0;
						}
					}
				}
			}
			nova_spr(_spr);
			
			//PARANDO
			if(_left and _right or !_left and !_right) 
			{
				//SOLTOU AS TECLAS CORRENDO NORMAL: DERRAPA (RUN_STOP)
				if(_spr == spr_player_run)
				{
					estado = state.run_stop;
					velh = vel_run * image_xscale;
				}
				else estado = state.idle;
			}
			
			//JUMP
			if(_jump)
			{
				velv = 0;
				velv -= vel_jump;
				estado = state.jump;
				girar_jump = true;
			}
			
			//SOCO
			if(_soco)
			{
				estado = state.soco;
			}
			//SUPER SOCO
			if(_soco_press)
			{
				estado = state.super_soco;
			}
			
			//CAIR
			if(!_block)
			{
				estado = state.jump;
				timer_jump = coyote_timer;
			}
			
			//GIRO
			if(_jump_giro)
			{
				velh += image_xscale*vel_giro;
				estado = state.giro;
			}
			
		break;
	#endregion
	#region STOP RUN
		case state.run_stop:
		
			//DERRAPANDO: FREIA ATE PARAR
			nova_spr(spr_player_stop_run);
			velh = lerp(velh, 0, no_gelo ? GELO_ATRITO : .16);
			if(ultima_spr()) estado = state.idle;
			
			//MOVENDO	
			if(_left xor _right) 
			{
				var _lado = _right - _left;
				estado = state.in_run;
				if(!no_gelo) velh = (vel_run + .2) * _lado;
			}
			
			//JUMP
			if(_jump)
			{
				velv = 0;
				velv -= vel_jump;
				estado = state.jump;
				girar_jump = true;
			}
			
			//CAIR
			if(!_block)
			{
				estado = state.jump;
				timer_jump = coyote_timer;
			}
			
			//SOCO
			if(_soco)
			{
				estado = state.soco;
			}
			
			//SUPER SOCO
			if(_soco_press)
			{
				estado = state.super_soco;
			}
				
		break;
	#endregion
	#region JUMP
		case state.jump:
		
			//NO AR: CONTROLA PRO LADO (DEPOIS DO WALL JUMP ESPERA UM POUCO)
			if(timer_mover == 0) mover(vel_run, .2)
			
			var _pulou_agora = false;

			//COYOTE JUMP
			if(timer_jump > 0 and _jump)
			{
				velv = 0;
				velv -= vel_jump;
				estado = state.jump;
				girar_jump = true;	
				timer_jump = 0;
				_pulou_agora = true;
			}
			
			image_speed = .6;
			//TEM PAREDE DO LADO QUE TA APERTANDO?
			var _dir = _right - _left != 0 ? _right - _left : image_xscale;
			var _wall = solido_inst(x + _dir*2, y);
			
			//AGARRADO NA PAREDE: ESCORREGA DEVAGAR. PULAR AQUI E O WALL JUMP (PULA PRO LADO CONTRARIO)
			var _na_parede = _wall and velv > .2 and (_left xor _right);
			//PAREDE DE GELO: ELE SE AGARRA MAS ESCORREGA RAPIDO, E O WALL JUMP E SO UM PULINHO (NAO DA PRA ESCALAR)
			var _parede_gelo = _wall != noone and _wall.object_index == obj_peca and _wall.sou_gelo; //(A PAREDE DA ARENA NAO E BLOCO)
			if(_na_parede)
			{
				image_xscale = _dir;
				velv = lerp(velv, _parede_gelo ? GELO_PAREDE_VEL : .3, .2);
				nova_spr(spr_player_wall);
				if (_jump) 
				{
				    timer_mover = 10;
					velv = 0;
				    velv = _parede_gelo ? -GELO_PAREDE_PULO : -(vel_jump);
				    velh = image_xscale * -1;
					
					
				}
			}
			else
			{
				//NO AR NORMAL: GRAVIDADE E A SPRITE DE SUBINDO / GIRINHO / CAINDO
				scr_gravid();
				if(velv < -1.9)
				{
					nova_spr(spr_player_jump);
				}else 
				{
					//CONTROLA SE ELE DA AQUELE GIRINHO LEGAL NO PULO
					if(girar_jump)
					{
						if(ultima_spr())nova_spr(sprite_index == skin_sprite(skin, spr_player_jump) ? spr_player_jump_giro : spr_player_fall);
					}else
					{
						nova_spr(spr_player_fall);
						ultima_spr();
					}	
				}
			}
			//ASAS: SEGUNDO PULO NO AR
			if(_jump and !_pulou_agora and !_na_parede and !pulo_duplo_usado and tem_poder("asas"))
			{
				velv = -vel_jump;
				pulo_duplo_usado = true;
				girar_jump = true;
				esc_x = .8 * image_xscale;
				esc_y = 1.3;
				var _anel = instance_create_depth(x, y, depth + 1, obj_efeito_pontos);
				_anel.modo = "anel";
				_anel.timer = 12;
				som_tocar(snd_jump, .1);
				_pulou_agora = true;
			}
			
			//IDLE
			//CAIU NO CHAO: VOLTA A CORRER OU FICA PARADO
			if(_block and !_pulou_agora)
			{
			    girar_jump = false;
			    estado = _left xor _right ? state.run : state.idle;
			}
			
			//CODIGO ANTIGO DESLIGADO
			//IF(_BLOCK AND !_BLOCK.SOU_FANTASMA AND !_PULOU_AGORA)
			//{
			//	GIRAR_JUMP = FALSE;
			//	ESTADO = _LEFT XOR _RIGHT ? STATE.RUN : STATE.IDLE;
			//}
			
			//SOCO
			if(_soco)
			{
				estado = state.soco;
			}
			
			//SUPER SOCO
			if(_soco_press)
			{
				estado = state.super_soco;
			}
			
			//GIRAR
			if(_jump_giro)
			{
				giro_ar = true;
				estado = state.giro;
			}
			
		break;
	#endregion
	#region SOCO
		case state.soco:
			
			//CODIGO ANTIGO DESLIGADO (O SOCO FALHAVA NA IRMANDADE)
			//VAR _PECA = INSTANCE_PLACE(X + IMAGE_XSCALE*10, Y, OBJ_PECA);
			//IF(_PECA)
			//{
			//	IF(_PECA.IRMANDADE) SOCO_FAIL = TRUE;
			//}
			image_speed = .6;
			nova_spr(soco_fail == true ? spr_player_soco_fail : spr_player_soco)
			
			//SEGURANDO A DIREÇAO ELE ANDA BEM DEVAGAR DURANTE O SOCO (PRA ALCANÇAR O BLOCO QUE ACABOU DE EMPURRAR)
			velh = lerp(velh, (_right - _left) * vel_run * SOCO_ANDAR, .15);
			velv = lerp(velv, 0, .18);
			
			//NO FRAME 2 DO SOCO CRIA A AREA DE DANO NA FRENTE (ESTICADA PELO SOCO_ALCANCE)
			if(image_index >= 2 and !dano)
			{
				dano = instance_create_layer(x + (8 + 2 * SOCO_ALCANCE) * image_xscale, y - 10, "Player", obj_dano);
				dano.image_xscale = image_xscale * SOCO_ALCANCE;
				dano.espiritual = tem_poder("espiritual");
				
				if(soco_fail)
				{
					dano.soco_fail = true;
					alpha_fog = 1;
				}
			}
			
			//ACABOU A ANIMAÇAO: VOLTA PRO NORMAL
			if(ultima_spr()) 
			{
				if(!_block) estado = state.jump;
				else estado = state.idle;
				dano = noone;
				soco_fail = false;
			}
			break;
	#endregion
	#region SUPER SOCO
		case state.super_soco:
			nova_spr(spr_player_super_soco);
			image_speed = .6
			
			//SEGURANDO A DIREÇAO ELE ANDA BEM DEVAGAR DURANTE O SOCO
			velh = lerp(velh, (_right - _left) * vel_run * SOCO_ANDAR, .15);
			velv = lerp(velv, 0, .18);
			
			//IGUAL AO SOCO, MAS A AREA DE DANO E DE SUPER SOCO
			if(image_index >= 2 and !dano)
			{
				dano = instance_create_layer(x + (8 + 2 * SOCO_ALCANCE) * image_xscale, y - 10, "Player", obj_dano);
				dano.image_xscale = image_xscale * SOCO_ALCANCE;
				dano.espiritual = tem_poder("espiritual");
				dano.super = true;
			}
			
			if(ultima_spr()) 
			{
				if(!_block) estado = state.jump;
				else estado = state.idle;
				dano = noone;
			}
			break;
	#endregion
	#region CLIMB
		case state.climb:
			//SUBINDO NUM BLOCO (ESTADO ANTIGO): ESPERA O PULO, TOCA A ANIMAÇAO E PASSA PRA CIMA
			image_speed = .6;
			if(!subir_climb) 
			{
				if(_jump) subir_climb = true;
				image_index = 0;
			}
			
			nova_spr(spr_player_climb);
			if(ultima_spr())
			{
				subir_climb = false;
				x += 6*image_xscale;
				
				if(_left xor _right)
				{
					var _lado = _right - _left;
					nova_spr(spr_player_dash_run);
					estado = state.in_run;
					velh = (vel_run + .2) * _lado;
				}
				else estado = state.idle;
				
			}
			
			break;
	#endregion
	#region GIRO
		case state.giro:
			
			//GIRO: ATACA GIRANDO. NO CHAO QUEBRA O BLOCO DO LADO, NO AR DESCE RAPIDO E QUEBRA O DE BAIXO
			image_speed = .9;
			
			mover(vel_giro, .2);
			
			//JUMP
			if(_jump and _block)
			{
				velv = 0;
				velv -= vel_jump;
				estado = state.jump;
				girar_jump = true;
			}
			
			//GIRO NO AR: CAI RAPIDO (GRAVIDADE DOBRADA)
			if(giro_ar)
			{
				if(nova_spr(spr_player_giro_1))
				{
					esc_x = .8 * image_xscale;
					esc_y = 1.4;
				}
				
					mover(vel_run);
					if(velv <= 2) velv = 2;
					scr_gravid(2);
					
					
					//CODIGO ANTIGO DESLIGADO
					//IF (IMAGE_INDEX >= IMAGE_NUMBER-1)
					//{
					//    IMAGE_INDEX = 2;
					//}
					
					//CAIU EM CIMA DE UMA PEÇA: QUEBRA ELA E QUICA PRA CIMA
					//PECA
					var _peca = instance_place(x, y +1, [obj_peca, obj_mask_fa]);
					if(_peca)
					{
						//QUIQUE EM CADEIA: CADA BLOCO QUEBRADO SEM PISAR NO CHAO MULTIPLICA OS PONTOS
						quique_seq++;
						if(_peca.object_index == obj_peca) _peca.pontos_mult = quique_seq;
						if(quique_seq >= 2) efeito_texto("x" + string(quique_seq), x, y - 26, c_orange, 1 + .12 * min(quique_seq, 6));
						onda_choque(_peca.x, _peca.y, 32, 3, 16);
						audio_play_sound(snd_hit2, 1, false, 1, 0, 1 + min(quique_seq, 10) * .08);
						if(quique_seq >= 2) som_nota(3 + min(quique_seq, 10), .5); //QUIQUE SEGUIDO: NOTA SUBINDO
						if(_peca.object_index == obj_peca) bloco_golpe(_peca); //A PEDRA SO RACHA NO PRIMEIRO (MAS QUICA IGUAL)
						else instance_destroy(_peca);
						velv = 0;
						velv -=  _jump_press ? vel_jump * GIRO_QUIQUE_FORTE : vel_jump; //SEGURANDO O PULO QUICA MAIS ALTO
						estado = state.jump;
						giro_ar = false;
						
					}
					
					//CAIU NO CHAO SEM PEÇA: PARA DE GIRAR
					//CHAO
					if(place_meeting(x, y+1, obj_block)) 
					{
						giro_ar = false;
						estado = _left xor  _right ? state.run : state.run_stop;
					}
					
					
				
			}
			else
			{
				//GIRO NO CHAO
				scr_gravid(2);
				nova_spr(spr_player_giro);
				
				//QUBRANDO PECAS AO LADO (O GIRO DO BAIXO + GIRO SO QUEBRA O DE BAIXO)
				var _peca = giro_baixo ? noone : instance_place(x + image_xscale*2, y, obj_peca);
				if(_peca)
				{
					onda_choque(_peca.x, _peca.y, 32, 3, 16);
					bloco_golpe(_peca);
				}
				
				//ACABOU A ANIMAÇAO: VOLTA A CORRER OU DERRAPA
				if(ultima_spr() or ultima_spr() and _block)
				{
					estado = _left xor  _right ? state.run : state.run_stop;
				}
			}
			
		break;
	#endregion
	#region PUSH
		case state.push:
		
			//EMPURRAO: NO FRAME 1 CRIA A AREA DE DANO QUE EMPURRA A PEÇA DA FRENTE
			nova_spr(spr_player_empurra);
			var _peca = instance_place(x + image_xscale, y, obj_peca);
			if(image_index >= 1 and !dano)
			{
				dano = instance_create_layer(x + (8 + 2 * SOCO_ALCANCE) * image_xscale, y - sprite_height/2, "Player", obj_dano);
				dano.image_xscale = image_xscale * SOCO_ALCANCE;
				dano.espiritual = tem_poder("espiritual");
			}
			
			if(ultima_spr())
			{
				dano = noone;
				estado = state.idle;
			}
		
		break;
	#endregion
}

//FEITIÇO DO BLOCO LENTO: A ANIMAÇAO TAMBEM FICA LENTA (O MOVIMENTO FICA LENTO NO END STEP E NA GRAVIDADE)
if(lento > 0) image_speed *= LENTO_MULT;
else if(rapido > 0) image_speed *= RAPIDO_MULT;
