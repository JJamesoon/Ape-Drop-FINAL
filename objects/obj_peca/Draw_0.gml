//ESCOLHE A SPRITE/FRAME CONFORME O TIPO DO BLOCO
var  _minha_spr = sprite_index;
var _alpha = 1;
if(sou_fantasma)
{
	//BLOCO FANTASMA: SEMITRANSPARENTE (O PLAYER PASSA POR DENTRO DELE)
	sprite_index = spr_peca;
	_minha_spr = spr_peca;
	image_index = 6;
	_alpha = .55 + .1 * sin(current_time / 300);
}else if(sou_especial)
{
	//ESPECIAL: FRAME 7
	image_index = 7;
}else if(sou_pedra)
{
	//PEDRA: SPRITE PROPRIA (FRAME 0 INTEIRA, 1 RACHADA)
	_minha_spr = spr_bloco_pedra;
}else if(sou_gelo)
{
	//GELO, COLMEIA, GELATINA E BURACO: SPRITE PROPRIA (SEM COR). A GELATINA E MEIO TRANSPARENTE
	_minha_spr = spr_bloco_gelo;
}else if(sou_colmeia)
{
	_minha_spr = spr_bloco_colmeia;
}else if(sou_gelatina)
{
	_minha_spr = spr_bloco_gelatina;
	_alpha = .85;
}else if(sou_buraco)
{
	_minha_spr = spr_bloco_buraco;
}else if(sou_sensor)
{
	//SNIPER: SPRITE PROPRIA. PARADO ELE FICA "OLHANDO" (SPR_BLOCO_SNIPER_IDLE). REVELADO (O PLAYER PASSOU NA LINHA DELE) TOCA
	//SPR_BLOCO_SNIPER_TIRO: A SETA VAI CRESCENDO DURANTE A CONTAGEM (SENSOR_AVISO) ATE ELE SE LANÇAR
	_minha_spr = sensor_timer < 0 ? spr_bloco_sniper_idle : spr_bloco_sniper_tiro;
}else if(sou_laser)
{
	//O LASER USA A SPRITE PROPRIA (O STEP TROCA PRA ELA E ANIMA).
	//ANTES CAIA NO ELSE DE BAIXO: VOLTAVA PRA SPR_PECA TODO FRAME, FICAVA TRAVADO NO FRAME 0 (VERDE) E NUNCA ATIRAVA
	_minha_spr = spr_peca_laser;
}else
{
	//NORMAL: A COR VEM DO FRAME (STEP)
	sprite_index = spr_peca;
	_minha_spr = spr_peca;
}

//BLOCO RAIO: ELE E SEMPRE O BLOCO AZUL. COM O RAIO LIGADO, TODOS OS BLOCOS COLORIDOS VIRAM O AZUL
//(O FANTASMA, O RAIVOSO, O ESPECIAL E O LASER FICAM COM A CARA DELES)
var _img = image_index;
if(_minha_spr == spr_peca and image_index < 5 and (sou_raio or raio_azul())) _img = cores.c_aqua;
if(sou_pedra) _img = vida_pedra >= 2 ? 0 : 1;
if(sou_gelo or sou_colmeia or sou_gelatina) _img = 0;
if(sou_sensor)
{
	//PARADO: 10 QUADROS POR SEGUNDO. REVELADO: O QUADRO DO TIRO ACOMPANHA A CONTAGEM (OS 7 PRIMEIROS; O 8O, ESCURO, FICA DE FORA)
	if(sensor_timer < 0) _img = floor(current_time / 100) mod sprite_get_number(spr_bloco_sniper_idle);
	else _img = clamp(floor((1 - sensor_timer / SENSOR_AVISO) * 7), 0, 6);
}
//O REDEMOINHO GIRANDO. RECARREGANDO (DEPOIS DE ENGOLIR) ELE GIRA DEVAGAR E VAI ACELERANDO ATE FICAR PRONTO
var _blend = image_blend;
if(sou_buraco)
{
	var _carga = buraco_espera > 0 ? 1 - buraco_espera / BURACO_ESPERA : 1;	//0 ACABOU DE ENGOLIR, 1 PRONTO
	if(!global.game_pause) buraco_giro += .03 + .12 * _carga;
	_img = buraco_giro;
	//RECARREGANDO: PERDE O BRILHO (FICA ESCURO E ACINZENTADO) E VAI VOLTANDO AOS POUCOS
	if(buraco_espera > 0) _blend = merge_color(#45404F, c_white, _carga * _carga);
}
ult_spr = _minha_spr;
ult_img = _img;

//TREME JUNTO COM A ARENA (NO VERSUS, A DA DIREITA USA A TREMIDA DO PLAYER 2) + A TREMIDA PROPRIA DO BLOCO
var shake_x, shake_y;
if(modo_arcade() or x < room_width/2)
{
	shake_x = global.shake_x;
	shake_y = global.shake_y + global.lerp_y;
}
else 
{
	shake_x = global.shake_x_2;
	shake_y = global.shake_y_2 + global.lerp_y_2;
}
shake_x += shake;

//BLOCO FUJAO ACORDADO: BALANÇA DE LEVE (ENCURRALADO: TREME UM POUCO MAIS)
if(sou_fujao and fujao_acordado) shake_x += fujao_encurralado ? choose(-.5, .5) : sin(current_time / 70) * .3;

//COLMEIA: TREME UM POUQUINHO ANTES DE SAIR UMA ABELHA
if(sou_colmeia and estou_parado and !andar and colmeia_timer < room_speed * .6) shake_x += sin(current_time / 25) * .6;

//GELATINA: BALANÇA SEMPRE UM POUQUINHO (BEM MAIS LOGO DEPOIS DE QUICAR UMA PEÇA)
var _ex = esc, _ey = esc;
if(sou_gelatina)
{
	var _bal = (.04 + .18 * gel_balanco) * sin(current_time / 45);
	_ex = esc * (1 + _bal);
	_ey = esc * (1 - _bal);
	gel_balanco = lerp(gel_balanco, 0, .04);
}

//NOS PRIMEIROS FRAMES DE VIDA NAO DESENHA (EVITA PISCAR NO LUGAR ERRADO)
if(inicializando > 0) 
{
	inicializando--;
	exit;
}

//DEBUG ANTIGO DESLIGADO
//IF(!IRMANDADE)DRAW_TEXT(X, Y + 16, TIMER_MOVE);

//GAMEFELL ==================
	
	//CORES ANTIGAS DO BRILHO (HOJE O BRILHO E SEMPRE BRANCO)
	//CORE
	var _cor = [
    #39FF14, // VERDE NEON
    #FFE600, // AMARELO VIVO
    #D92BFF, // ROXO/MAGENTA
    #00E5FF, // CIANO ELÉTRICO
    #FF3030,  // VERMELHO VIVO
    #FF3030,  // VERMELHO VIVO
    #A17BDA  // VERMELHO VIVO
];
_cor = c_white;
	
	//BRILHO POR CIMA DO BLOCO:
	//	BRANCO PISCANDO RAPIDO = VAI QUEBRAR PELA IRMANDADE (DEPOIS EXPLODE EM MINI-BLOCOS)
	//	AZUL PULSANDO DEVAGAR = DA PRA DESTRUIR ESSE GRUPO COM O ESPECIAL (TEM ENERGIA E 5+ DA MESMA COR)
	var _fog_cor = c_white;
	var _fog_alpha = alpha_fog;
	if(destruido_por == "irmandade")
	{
		_fog_cor = c_white;
		_fog_alpha = max(alpha_fog, .45 + .45 * sin(current_time / 35));
	}
	else if(pode_especial and energia_valor(x) >= 1 and alpha_fog < .3)
	{
		_fog_cor = #31FCFF;
		_fog_alpha = .3 + .25 * sin(current_time / 140);
	}
	//SENSOR REVELADO: LINHA VERMELHA NO TRAJETO (ATE A PAREDE DO LADO DO PLAYER), PISCA VERMELHO E TREME
	if(sensor_timer >= 0)
	{
		var _pp = player_perto(x, y);
		if(_pp != noone and instance_exists(obj_area))
		{
			var _lado = _pp.x < x ? -1 : 1;
			var _fim = _lado < 0 ? obj_area.x : obj_area.x + obj_area.sprite_width;
			draw_set_alpha(.35 + .35 * ((sensor_timer div 3) mod 2));
			draw_set_color(c_red);
			draw_rectangle(min(x, _fim), y - 2, max(x, _fim), y + 1, false);
			draw_set_alpha(1);
			draw_set_color(c_white);
		}
		_fog_cor = c_white;
		_fog_alpha = (sensor_timer div 3) mod 2 ? .35 : 0;	//(A ARTE JA E VERMELHA: SO UM CLARAO BRANCO PISCANDO)
		shake_x += choose(-1, 1);
	}
	
	//O BLOCO E O BRILHO POR CIMA
	draw_sprite_ext(_minha_spr, _img, x + shake_x, y + shake_y, _ex, _ey, 0, _blend, _alpha);
	gpu_set_fog(true, _fog_cor, 0, 1);
	draw_sprite_ext(_minha_spr, _img, x + shake_x, y + shake_y, _ex, _ey, 0, _cor, _fog_alpha);
	gpu_set_fog(false, c_white, 0, 1);
	
	//TEMPO PARADO, DICA: ESSE BLOCO COMPLETA UMA LINHA QUANDO CAIR (BORDA BRILHANDO)
	if((global.tempo_fase == "parado" or global.tempo_fase == "contagem") and array_contains(global.tempo_dicas, id))
	{
		var _dp = .55 + .45 * sin(current_time / 110), _bx = x + shake_x, _by = y + shake_y;
		gpu_set_blendmode(bm_add);
		draw_set_color(#FFE600);
		for(var k = 0; k < 3; k++)
		{
			draw_set_alpha(_dp * (.5 - k * .15));
			draw_rectangle(_bx - 8 - k, _by - 8 - k, _bx + 7 + k, _by + 7 + k, true);
		}
		gpu_set_blendmode(bm_normal);
		draw_set_alpha(.5 + .5 * _dp);
		draw_set_color(c_white);
		draw_rectangle(_bx - 8, _by - 8, _bx + 7, _by + 7, true);
		draw_set_alpha(1);
	}
	
	//PLAYER SEGURANDO BAIXO EM CIMA DA PEÇA: BRILHO E LINHAS DE VELOCIDADE SUBINDO
	if(global.peca_acelerada_timer > 0 and (pai == global.peca_acelerada or id == global.peca_acelerada))
	{
		gpu_set_fog(true, c_white, 0, 1);
		draw_sprite_ext(_minha_spr, _img, x + shake_x, y + shake_y, esc, esc, 0, c_white, .25);
		gpu_set_fog(false, c_white, 0, 1);
		draw_set_alpha(.5);
		draw_set_color(c_white);
		var _t = current_time / 40;
		for(var k = 0; k < 2; k++)
		{
			var _lx = x + shake_x - 5 + k * 10;
			var _ly = y + shake_y - 10 - ((_t + k * 7) mod 14);
			draw_line(_lx, _ly, _lx, _ly - 6);
		}
		draw_set_alpha(1);
	}
	
	//BLOCO RAIO: O RAIO NO MEIO DO BLOCO (ANIMADO, COM UM BRILHO AQUA PULSANDO)
	if(sou_raio)
	{
		var _rf = current_time / 90;
		gpu_set_fog(true, #31FCFF, 0, 1);
		draw_sprite_ext(spr_bloco_eletrico, _rf, x + shake_x, y + shake_y, esc * 1.3, esc * 1.3, 0, c_white, .35 + .25 * sin(current_time / 120));
		gpu_set_fog(false, c_white, 0, 1);
		draw_sprite_ext(spr_bloco_eletrico, _rf, x + shake_x, y + shake_y, esc, esc, 0, c_white, 1);
	}
	
	//LASER LATERAL: SETINHA LARANJA APONTANDO PRO LADO DO TIRO
	if(sou_laser and laser_lado)
	{
		var _meio = instance_exists(obj_area) ? obj_area.x + obj_area.sprite_width / 2 : room_width / 2;
		var _lado = x > _meio ? -1 : 1;
		var _ax = x + shake_x + _lado * (5 + sin(current_time / 100)), _ay = y + shake_y;
		draw_set_color(#0E071B);
		draw_triangle(_ax, _ay - 4, _ax, _ay + 4, _ax + _lado * 5, _ay, false);
		draw_set_color(#FF9A3C);
		draw_triangle(_ax, _ay - 3, _ax, _ay + 3, _ax + _lado * 4, _ay, false);
		draw_set_color(c_white);
	}

	//BLOCO LENTO: A ESPIRAL DO FEITIÇO GIRANDO NO MEIO DO BLOCO (COM UM BRILHO ROXO)
	if(sou_lento)
	{
		gpu_set_fog(true, #B07CFF, 0, 1);
		draw_sprite_ext(spr_icone_lento, 0, x + shake_x, y + shake_y, esc * 1.15, esc * 1.15, -current_time / 6, c_white, .35 + .2 * sin(current_time / 140));
		gpu_set_fog(false, c_white, 0, 1);
		draw_sprite_ext(spr_icone_lento, 0, x + shake_x, y + shake_y, esc * .85, esc * .85, -current_time / 6, c_white, 1);
	}

	//BLOCO FUJAO: A MOEDA DENTRO DELE (PULSANDO PRA CHAMAR ATENÇAO)
	if(sou_fujao)
	{
		var _me = (.6 + .06 * sin(current_time / 150)) * esc;
		draw_sprite_ext(spr_moeda, current_time / 100, x + shake_x, y + shake_y, _me, _me, 0, c_white, 1);
	}

	//MODO BONUS: MOEDA EM CIMA DE TODOS OS BLOCOS (PISCA NO FINAL)
	if(global.bonus_moedas > 0 and !(global.bonus_moedas < room_speed * 2 and (global.bonus_moedas div 5) mod 2 == 0))
	{
		draw_sprite_ext(spr_moeda, current_time / 100 + x * .05, x + shake_x, y + shake_y, .7 * esc, .7 * esc, 0, c_white, 1);
	}
	
	//LETRA GUARDADA NO BLOCO (FICHINHA DOURADA NO MEIO)
	if(letra >= 0 and !(letra_timer < room_speed * 3 and (letra_timer div 5) mod 2 == 0))
	{
		var _ly = y + shake_y + sin(current_time / 200);
		draw_set_alpha(.3 + .25 * sin(current_time / 90));
		draw_set_color(c_yellow);
		draw_circle(x + shake_x, _ly, 9, false);
		draw_set_alpha(1);
		draw_set_color(#3A1E08);
		draw_circle(x + shake_x, _ly, 6, false);
		draw_set_color(#FFB21E);
		draw_circle(x + shake_x, _ly, 5, false);
		draw_set_font(fnt_hud);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text_transformed_color(x + shake_x, _ly, global.letras_nomes[letra], .7, .7, 0, #8A2E00, #8A2E00, #8A2E00, #8A2E00, 1);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
	}
	
	//VISAO ESPIRITUAL: MOSTRA O SENSOR (OLHO) E O QUE O BLOCO ESPECIAL GUARDA
	if(tem_poder("visao"))
	{
		//(O SNIPER JA TEM A CARA DELE O TEMPO TODO: A VISAO ESPIRITUAL NAO PRECISA MARCAR O OLHO)
		if(sou_especial and premio_especial >= 0)
		{
			var _nomes = global.linguagem == 0 ? ["PONTOS", "DEVAGAR", "+1 VIDA", "RÁPIDO", "CUBO", "BÔNUS"] : ["POINTS", "SLOW", "+1 LIFE", "FAST", "CUBE", "BONUS"];
			draw_set_font(fnt_hud);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text_transformed_color(x + shake_x, y + shake_y - 14, _nomes[premio_especial], .6, .6, 0, #FF7AE0, #FF7AE0, #FF7AE0, #FF7AE0, 1);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
		}
	}
	
	//PEÇA ATUAL DA FILA (A QUE TELEPORTA): BRILHO EM VOLTA
	//CHECANDD SE O NOSSO PAI E O INST_PECA
	if(room == rm_versus ? versus_peca_atual(pai) : pai == global.peca_inst)
	{
		//NO COOP O BRILHO TEM A COR DE QUEM TEM A VEZ DO TELEPORTE. NO SOLO E BRANCO
		var _cor_brilho = (global.coop and room != rm_versus and !MOBILE) ? coop_vez_cor() : c_white;
		draw_sprite_ext(spr_efeito_brilho, get_timer()/50000, x + shake_x, y + shake_y, 1, 1, 0, _cor_brilho, 1);
	}	//(A ARTE NOVA DO BRILHO TEM O RISCO 3PX MAIS PRA DIREITA NO QUADRO: O -3 CENTRA NA FACE DO BLOCO)
	//ANIMAÇAO DE QUEBRAR A IRMANDADE
	if(anim_efeito_irmandade)
	{
		timer_efeito_irmandade += .55;
		draw_sprite_ext(spr_efeito_bloco_irmandade, timer_efeito_irmandade, x + shake_x, y + shake_y, 1, 1, 0, c_white, 1);
		if(timer_efeito_irmandade > sprite_get_number(spr_efeito_bloco_irmandade)-1)
		{
			timer_efeito_irmandade = 0;
			anim_efeito_irmandade = false;
		}
	}
	
	//EFEITO DE ENCAIXE
	if(animar_efeito_encaixe)
	{
		timer_anim_efeito += .4;
		draw_sprite(spr_efeito_bloco, timer_anim_efeito, x + shake_x, y + shake_y);
		if(timer_anim_efeito > (sprite_get_number(spr_efeito_bloco)-1))
		{
			animar_efeito_encaixe = false;
			timer_anim_efeito = 0;
		}
	}
//GAMEFELL ==================

//INCHAÇO E BRILHO VOLTAM AO NORMAL
esc			= lerp(esc, 1, .2);
alpha_fog	= lerp(alpha_fog, 0, .2);

//DEBUG
var __y = y-8;
var _meu_y = __y - obj_area.y mod CEL;
//DRAW_TEXT(X, Y,  STRING(_MEU_Y) + "-" + STRING((__Y - OBJ_AREA.Y) DIV CEL));
			
//DEBUG: BARRA DO TEMPO ATE A PROXIMA DESCIDA
if(DEBUG)
{
	var _temp = (timer_move / meu_timer) * 100;
	draw_healthbar(x-4, y + 6, x+4, y - 6, _temp, c_black, c_red, c_green, 2, 1, 1);
}
//DEBUG ANTIGO DESLIGADO
//IF(KEYBOARD_CHECK(VK_SPACE))
//{
	
//}

////DRAW_TEXT(X + 20, Y - 8, Y)
////DRAW_TEXT(X + 100, Y - 8, PROX_Y)

//IF(SOU_PAI)DRAW_TEXT(X - 5, Y - 10, 0)
