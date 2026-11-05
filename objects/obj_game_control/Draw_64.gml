//VINHETA NAS BORDAS DA TELA (A "LUNETA" DO PROJETO ANTIGO). LEVOU DANO: PISCA EM VERMELHO
if(fundo_xiado != -1)
{
	var _tl = gui_tela();
	draw_sprite_stretched_ext(spr_luneta, 0, _tl[0], _tl[1], _tl[2] - _tl[0], _tl[3] - _tl[1], c_white, FUNDO_LUNETA);
	if(global.fundo_dano > 0)
	{
		gpu_set_fog(true, c_red, 0, 1);
		draw_sprite_stretched_ext(spr_luneta, 0, _tl[0], _tl[1], _tl[2] - _tl[0], _tl[3] - _tl[1], c_white, global.fundo_dano);
		gpu_set_fog(false, c_white, 0, 1);
		global.fundo_dano = max(0, global.fundo_dano - .04);
	}
}

//AS PEÇAS FICARAM MAIS RAPIDAS: VINHETA LARANJA NA BORDA DA TELA QUE VAI SUMINDO (MESMA LUNETA DO DANO, SO QUE LARANJA)
if(global.vel_aviso > 0)
{
	var _tv = gui_tela();
	gpu_set_fog(true, #FF9A3C, 0, 1);
	draw_sprite_stretched_ext(spr_luneta, 0, _tv[0], _tv[1], _tv[2] - _tv[0], _tv[3] - _tv[1], c_white, global.vel_aviso * .8);
	gpu_set_fog(false, c_white, 0, 1);
	global.vel_aviso = max(0, global.vel_aviso - .012);
}

//FLASH BRANCO SUTIL QUANDO FECHA LINHA (VAI SUMINDO SOZINHO)
if(global.flash_linha > 0)
{
	draw_set_alpha(global.flash_linha);
	draw_set_color(c_white);
	var _tl = gui_tela();
	draw_rectangle(_tl[0], _tl[1], _tl[2], _tl[3], false);
	draw_set_alpha(1);
	global.flash_linha = max(0, global.flash_linha - .03);
}

//CONTAGEM DE 3S ANTES DE ACELERAR: TEXTO DO MOTIVO + NUMERO GRANDE QUE DA UM "POP" A CADA SEGUNDO
if(global.contagem > 0 and global.andar_pausa <= 0 and instance_exists(obj_area))
{
	//ESCALA DA GUI E O MEIO DA ARENA NA GUI
	var _e = gui_esc();
	var _cx = (obj_area.x + obj_area.sprite_width / 2) * _e;
	var _cy = (obj_area.y + obj_area.sprite_height * .38) * _e;
	//NUMERO QUE APARECE (3, 2, 1)
	var _num = ceil(global.contagem / room_speed);
	var _frac = (global.contagem mod room_speed) / room_speed; //1 NO COMEÇO DO SEGUNDO, 0 NO FIM
	//O NUMERO NASCE GRANDE E ENCOLHE DURANTE O SEGUNDO
	var _esc = (2.6 + 1.4 * power(_frac, 3)) * _e;
	//3 AMARELO, 2 LARANJA, 1 VERMELHO
	var _cor = _num == 1 ? c_red : (_num == 2 ? c_orange : c_yellow);
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	//TEXTO DO MOTIVO ("MAIS RAPIDO", "FEBRE"...) EM CIMA DO NUMERO
	//(TEXTO COMPRIDO, COMO "ESTA FICANDO MUITO FRIO", ENCOLHE PRA CABER NA LARGURA DA ARENA)
	var _ct = min(1.2, (obj_area.sprite_width - 6) / max(1, string_width(global.contagem_texto))) * _e;
	draw_text_transformed_color(_cx + _e, _cy - 34 * _e + _e, global.contagem_texto, _ct, _ct, 0, #0E071B, #0E071B, #0E071B, #0E071B, 1);
	draw_text_transformed_color(_cx, _cy - 34 * _e, global.contagem_texto, _ct, _ct, 0, c_white, c_white, c_white, c_white, 1);
	//NUMERO COM CONTORNO
	for(var i = 0; i < 4; i++) draw_text_transformed_color(_cx + lengthdir_x(2 * _e, i * 90), _cy + lengthdir_y(2 * _e, i * 90), string(_num), _esc, _esc, 0, #0E071B, #0E071B, #0E071B, #0E071B, 1);
	draw_text_transformed_color(_cx, _cy, string(_num), _esc, _esc, 0, _cor, _cor, _cor, _cor, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

//EFEITO DE AMBIENTE: FRIO (VINHETA AZUL E NEVE)
if(modo_arcade() and !modo_versus()) frio_desenhar();

#region BLOCO NOVO DESCOBERTO
//UMA PLAQUINHA DESCE NO TOPO DA ARENA COM O BLOCO GIRANDO, "NOVO BLOCO DESCOBERTO!" E O NOME. UM DE CADA VEZ
#macro AVISO_BLOCO_DUR	(room_speed * 2.6)
if(array_length(global.avisos_bloco) > 0 and instance_exists(obj_area))
{
	if(global.aviso_bloco_t == 0) audio_play_sound(snd_certo, 1, false, .8, 0, 1.25);
	global.aviso_bloco_t++;
	var _id = global.avisos_bloco[0];
	var _info = bloco_info(_id);
	var _e = gui_esc();
	var _t = global.aviso_bloco_t;
	var _desce = min(1, _t / 12) * min(1, (AVISO_BLOCO_DUR - _t) / 12);	//ENTRA E SAI DESLIZANDO
	var _f = .85;	//AVISO UM POUCO MENOR
	var _w = 74 * _e * _f, _h = 26 * _e * _f;
	var _ent = 1 - power(1 - max(0, _desce), 3);
	//NO PC: NA AREA LIVRE DA ESQUERDA DA ARENA, ENTRANDO PELA ESQUERDA (ABAIXO DO PAINEL DO P2 NO COOP, ACIMA DO COMBO).
	//NO CELULAR NAO SOBRA ESPAÇO DO LADO: DESCE NO TOPO DA ARENA
	var _cx, _y1;
	if(!MOBILE)
	{
		var _cx_fim = (obj_area.x - 24) * _e - _w;
		_cx = lerp(-_w * 1.2, _cx_fim, _ent);
		_y1 = (obj_area.y + 262) * _e;	//BEM EMBAIXO (O COMBO FICA NO MEIO)
	}
	else
	{
		_cx = (obj_area.x + obj_area.sprite_width / 2) * _e;
		_y1 = lerp(-_h - 4 * _e, (obj_area.y + 4) * _e, _ent);
	}
	var _sombra = #0E071B;
	draw_set_color(_sombra);
	draw_rectangle(_cx - _w + 3 * _e, _y1 + 3 * _e, _cx + _w + 3 * _e, _y1 + _h + 3 * _e, false);
	draw_set_color(#1E1A38);
	draw_rectangle(_cx - _w, _y1, _cx + _w, _y1 + _h, false);
	draw_set_color(#FFE66B);
	draw_rectangle(_cx - _w, _y1, _cx + _w, _y1 + _h, true);
	draw_rectangle(_cx - _w + _e, _y1 + _e, _cx + _w - _e, _y1 + _h - _e, true);
	//BRILHO PASSANDO
	var _bx = _cx - _w + (_t * 6 * _e) mod (_w * 3);
	gpu_set_blendmode(bm_add);
	draw_set_alpha(.25);
	draw_set_color(c_white);
	draw_triangle(_bx, _y1, _bx + 10 * _e, _y1, _bx - 6 * _e, _y1 + _h, false);
	draw_set_alpha(1);
	gpu_set_blendmode(bm_normal);
	//O BLOCO (DA UM PULINHO) E OS TEXTOS
	var _pulo = abs(sin(_t / 8)) * 2 * _e;
	bloco_icone_desenhar(_id, _cx - _w + 14 * _e * _f, _y1 + _h / 2 + 2 * _e * _f - _pulo, _e * _f);
	draw_set_font(fnt_hud);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	var _tx = _cx - _w + 28 * _e * _f;
	var _titulo = global.linguagem == 0 ? "NOVO BLOCO DESCOBERTO!" : "NEW BLOCK FOUND!";
	draw_text_transformed_color(_tx + _e * .5, _y1 + 8 * _e * _f + _e * .5, _titulo, _e * .55 * _f, _e * .55 * _f, 0, _sombra, _sombra, _sombra, _sombra, 1);
	draw_text_transformed_color(_tx, _y1 + 8 * _e * _f, _titulo, _e * .55 * _f, _e * .55 * _f, 0, #FFE66B, #FFE66B, #FFB21E, #FFB21E, 1);
	var _nome = is_undefined(_info) ? _id : _info.nome[global.linguagem == 0 ? 0 : 1];
	draw_text_transformed_color(_tx + _e, _y1 + 18 * _e * _f + _e, _nome, _e * .9 * _f, _e * .9 * _f, 0, _sombra, _sombra, _sombra, _sombra, 1);
	draw_text_transformed_color(_tx, _y1 + 18 * _e * _f, _nome, _e * .9 * _f, _e * .9 * _f, 0, c_white, c_white, c_white, c_white, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	if(_t >= AVISO_BLOCO_DUR) { array_delete(global.avisos_bloco, 0, 1); global.aviso_bloco_t = 0; }
}
#endregion

#region PODER DE PARAR O TEMPO
//CLARAO VERDE QUANDO O TEMPO PARA E QUANDO ELE VOLTA
if(global.tempo_flash > 0)
{
	var _tl = gui_tela();
	draw_set_alpha(global.tempo_flash * .7);
	draw_set_color(merge_color(TEMPO_VERDE, c_white, .5));
	draw_rectangle(_tl[0], _tl[1], _tl[2], _tl[3], false);
	draw_set_alpha(1);
	global.tempo_flash = max(0, global.tempo_flash - .035);
}
if(instance_exists(obj_area))
{
	var _e = gui_esc();
	var _cx = (obj_area.x + obj_area.sprite_width / 2) * _e;
	var _sombra = #0E071B;
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _pt = global.linguagem == 0;
	//TEMPO PARADO: POEIRA DE LUZ VERDE SUSPENSA NO AR (QUASE PARADA, SO BALANÇA) POR TODA A ARENA
	if(global.tempo_vis > .05)
	{
		gpu_set_blendmode(bm_add);
		draw_set_color(TEMPO_VERDE);
		for(var k = 0; k < 36; k++)
		{
			var _px = (obj_area.x + ((k * 53) mod obj_area.sprite_width) + sin(current_time / 900 + k) * 4) * _e;
			var _py = (obj_area.y + ((k * 97) mod obj_area.sprite_height) + cos(current_time / 1100 + k * 1.7) * 4) * _e;
			var _pt2 = (1 + (k mod 3)) * _e * .5;
			draw_set_alpha(global.tempo_vis * (.25 + .25 * sin(current_time / 300 + k)));
			draw_rectangle(_px - _pt2, _py - _pt2, _px + _pt2, _py + _pt2, false);
		}
		draw_set_alpha(1);
		gpu_set_blendmode(bm_normal);
	}
	//TEMPO PARADO: TITULO QUE ENTRA GRANDE E UM RELOGIO QUE VAI ESVAZIANDO COM OS SEGUNDOS NO MEIO (BEM TRANSPARENTES PRA NAO ATRAPALHAR)
	if(global.tempo_fase == "parado" and global.tempo_timer > TEMPO_CONTAGEM)
	{
		var _ta = .3;	//TRANSPARENCIA DO TITULO E DO RELOGIO
		var _ent = max(0, 1 - global.tempo_t / 18);
		var _te = _e * (1.3 + 1.6 * _ent * _ent);
		var _ty = (obj_area.y + 34) * _e;
		var _tit = _pt ? "TEMPO PARADO!" : "TIME STOP!";
		for(var k = 0; k < 8; k++) draw_text_transformed_color(_cx + lengthdir_x(2 * _e, k * 45), _ty + lengthdir_y(2 * _e, k * 45), _tit, _te, _te, 0, _sombra, _sombra, _sombra, _sombra, _ta);
		draw_text_transformed_color(_cx, _ty, _tit, _te, _te, sin(global.tempo_t / 20) * 2, c_white, c_white, TEMPO_VERDE, TEMPO_VERDE, _ta);
		//RELOGIO
		var _ry = (obj_area.y + 78) * _e, _rr = 17 * _e;
		var _resta = global.tempo_timer / TEMPO_DURACAO;
		var _fim = global.tempo_timer <= room_speed * 3;
		var _cor = (_fim and (global.tempo_timer div 8) mod 2 == 0) ? #FFE600 : TEMPO_VERDE;
		draw_set_alpha(.75 * _ta);
		draw_set_color(_sombra);
		draw_circle(_cx, _ry, _rr + 4 * _e, false);
		draw_set_alpha(_ta);
		draw_primitive_begin(pr_trianglelist);
		var _seg = 40;
		for(var k = 0; k < _seg * _resta; k++)
		{
			var _a1 = 90 - 360 * k / _seg, _a2 = 90 - 360 * min(k + 1, _seg * _resta) / _seg;
			draw_vertex_colour(_cx, _ry, _cor, .35 * _ta);
			draw_vertex_colour(_cx + lengthdir_x(_rr, _a1), _ry + lengthdir_y(_rr, _a1), _cor, .9 * _ta);
			draw_vertex_colour(_cx + lengthdir_x(_rr, _a2), _ry + lengthdir_y(_rr, _a2), _cor, .9 * _ta);
		}
		draw_primitive_end();
		draw_set_color(c_white);
		for(var k = 0; k < 10; k++) { var _a = 90 - k * 36; draw_line_width(_cx + lengthdir_x(_rr + 1 * _e, _a), _ry + lengthdir_y(_rr + 1 * _e, _a), _cx + lengthdir_x(_rr + 3.5 * _e, _a), _ry + lengthdir_y(_rr + 3.5 * _e, _a), _e); }
		var _ap = 90 - 360 * (1 - _resta);
		draw_line_width(_cx, _ry, _cx + lengthdir_x(_rr * .9, _ap), _ry + lengthdir_y(_rr * .9, _ap), 1.5 * _e);
		var _seg_txt = string(ceil(global.tempo_timer / room_speed));
		var _ne = _e * (1.3 + (_fim ? .25 * abs(sin(global.tempo_t / 6)) : 0));
		for(var k = 0; k < 4; k++) draw_text_transformed_color(_cx + lengthdir_x(_e, k * 90), _ry + lengthdir_y(_e, k * 90), _seg_txt, _ne, _ne, 0, _sombra, _sombra, _sombra, _sombra, _ta);
		draw_text_transformed_color(_cx, _ry, _seg_txt, _ne, _ne, 0, c_white, c_white, c_white, c_white, _ta);
		draw_set_alpha(1);
	}
	//CONTAGEM: 3, 2, 1 GRANDE NO MEIO DA ARENA COM UM ANEL ABRINDO A CADA SEGUNDO
	if(global.tempo_fase == "contagem" or (global.tempo_fase == "parado" and global.tempo_timer <= TEMPO_CONTAGEM))
	{
		var _num = ceil(global.tempo_timer / room_speed);
		var _f = 1 - (global.tempo_timer mod room_speed) / room_speed;	//0 NO COMEÇO DE CADA SEGUNDO
		if(global.tempo_timer mod room_speed == 0) _f = 0;
		var _cy = (obj_area.y + obj_area.sprite_height * .4) * _e;
		var _ne = _e * (4.2 - 1.6 * min(1, _f * 4));
		draw_set_alpha(1 - _f);
		draw_set_color(TEMPO_VERDE);
		for(var k = 0; k < 3; k++) draw_circle(_cx, _cy, (10 + _f * 60) * _e + k, true);
		draw_set_alpha(1);
		for(var k = 0; k < 8; k++) draw_text_transformed_color(_cx + lengthdir_x(3 * _e, k * 45), _cy + lengthdir_y(3 * _e, k * 45), string(_num), _ne, _ne, 0, _sombra, _sombra, _sombra, _sombra, 1);
		draw_text_transformed_color(_cx, _cy, string(_num), _ne, _ne, 0, c_white, c_white, TEMPO_VERDE, TEMPO_VERDE, 1);
		var _ty = _cy - 40 * _e;
		var _tit = _pt ? "O TEMPO VAI VOLTAR!" : "TIME RESUMES IN";
		for(var k = 0; k < 4; k++) draw_text_transformed_color(_cx + lengthdir_x(_e, k * 90), _ty + lengthdir_y(_e, k * 90), _tit, _e, _e, 0, _sombra, _sombra, _sombra, _sombra, 1);
		draw_text_transformed_color(_cx, _ty, _tit, _e, _e, 0, TEMPO_VERDE, TEMPO_VERDE, TEMPO_VERDE, TEMPO_VERDE, 1);
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}
#endregion

//RAIO (PONTOS X2) E BONUS DE MOEDAS: QUANTO TEMPO FALTA, NO TOPO DA ARENA
if(instance_exists(obj_area) and (global.raio > 0 or global.bonus_moedas > 0 or global.dupla_timer > 0) and !tempo_ativo())
{
	var _e = gui_esc();
	var _cx = (obj_area.x + obj_area.sprite_width / 2) * _e;
	var _ty = (obj_area.y + 12) * _e;
	var _avisos = [];
	if(global.raio > 0)			array_push(_avisos, [(global.linguagem == 0 ? "RAIO X2  " : "LIGHTNING X2  ") + string(ceil(global.raio / room_speed)), #31FCFF]);
	if(global.bonus_moedas > 0)	array_push(_avisos, [(global.linguagem == 0 ? "BÔNUS  " : "BONUS  ") + string(ceil(global.bonus_moedas / room_speed)), c_yellow]);
	if(global.dupla_timer > 0)	array_push(_avisos, [(global.linguagem == 0 ? "PEÇAS DUPLAS  " : "DOUBLE PIECES  ") + string(ceil(global.dupla_timer / room_speed)), #FF9A3C]);
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	for(var i = 0; i < array_length(_avisos); i++)
	{
		var _ay = _ty + i * 12 * _e;
		var _c = _avisos[i][1];
		for(var k = 0; k < 4; k++) draw_text_transformed_color(_cx + lengthdir_x(_e, k * 90), _ay + lengthdir_y(_e, k * 90), _avisos[i][0], _e * .8, _e * .8, 0, #0E071B, #0E071B, #0E071B, #0E071B, 1);
		draw_text_transformed_color(_cx, _ay, _avisos[i][0], _e * .8, _e * .8, 0, _c, _c, _c, _c, 1);
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

//MENU DE PODER (COMPLETOU D R O P): 3 CARTAS DE PODER (+ A DO SLOT SE TIVER MOEDAS)
if(alpha_menu > .01 and array_length(poder_opcoes) > 0)
{
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _e = gui_esc();
	var _a = alpha_menu;
	var _n = array_length(poder_opcoes);
	var _en = clamp(global.linguagem, 0, 1);
	
	//FUNDO ESCURO
	draw_set_alpha(_a * .75);
	draw_set_color(c_black);
	var _tl = gui_tela();
	draw_rectangle(_tl[0], _tl[1], _tl[2], _tl[3], false);
	draw_set_alpha(_a);
	
	//TAMANHO DAS CARTAS E DO PAINEL (EM PIXELS DA ROOM)
	var _cw = 88, _ch = 120, _gap = 8;
	var _pw = _n * (_cw + _gap) + 16;
	var _ph = _ch + 58;
	var _px = gui_meio_x() - _pw / 2;
	var _py = gui_meio_y() - _ph / 2;
	var _th = sprite_get_height(spr_caixa_setings);
	//BARRA DE TITULO E JANELA
	draw_sprite_stretched_ext(spr_caixa_setings, 0, _px * _e, _py * _e, _pw * _e, _th * _e, c_white, _a);
	draw_sprite_stretched_ext(spr_menu_janela, 0, _px * _e, (_py + _th) * _e, _pw * _e, (_ph - _th) * _e, c_white, _a);
	
	draw_set_font(fnt_hud);
	draw_set_valign(fa_middle);
	draw_set_halign(fa_left);
	draw_text_transformed_color((_px + 5) * _e, (_py + _th / 2) * _e, _en == 0 ? "ESCOLHA SEU PODER" : "CHOOSE YOUR POWER", _e, _e, 0, c_white, c_white, c_white, c_white, _a);
	
	draw_set_halign(fa_center);
	//UMA CARTA POR PODER (A ESCOLHIDA SOBE UM POUCO E FICA COM A BORDA DA COR DELE)
	for(var i = 0; i < _n; i++)
	{
		var _op = poder_opcoes[i];
		var _sel = i == poder_opcao;
		var _cx = _px + 8 + _gap / 2 + i * (_cw + _gap);
		var _cy = _py + _th + 8 - (_sel ? 3 : 0);
		var _cor = poder_info(_op).cor;
		
		//CARTA
		draw_set_color(_sel ? #2A1846 : #140B24);
		draw_rectangle(_cx * _e, _cy * _e, (_cx + _cw) * _e, (_cy + _ch) * _e, false);
		draw_set_color(_sel ? _cor : #5A4A78);
		for(var b = 0; b < (_sel ? 2 : 1); b++) draw_rectangle((_cx + b) * _e, (_cy + b) * _e, (_cx + _cw - b) * _e, (_cy + _ch - b) * _e, true);
		
		var _mx = (_cx + _cw / 2) * _e;
		//NOME DO PODER
		draw_text_ext_transformed_color(_mx, (_cy + 16) * _e, poder_nome(_op), 12, 96, _e * .85, _e * .85, 0, _cor, _cor, _cor, _cor, _a);
		//ICONE DO PODER (O MESMO DO HUD), NUMA CAIXINHA
		var _ie = 2.5 * _e * (_sel ? 1 + .06 * sin(current_time / 140) : 1);
		var _iy = (_cy + 50) * _e;
		draw_set_color(merge_color(_cor, #0E071B, .75));
		draw_rectangle(_mx - 7.5 * _ie, _iy - 7.5 * _ie, _mx + 7.5 * _ie, _iy + 7.5 * _ie, false);
		draw_set_color(_cor);
		draw_rectangle(_mx - 7.5 * _ie, _iy - 7.5 * _ie, _mx + 7.5 * _ie, _iy + 7.5 * _ie, true);
		poder_icone_desenhar(_op, _mx - 4.5 * _ie, _iy - 4.5 * _ie, _ie, _cor, false, _a);
		//DESCRIÇAO DO PODER
		draw_text_ext_transformed_color(_mx, (_cy + 94) * _e, poder_desc(_op), 12, 104, _e * .72, _e * .72, 0, #C7CFDD, #C7CFDD, #C7CFDD, #C7CFDD, _a);
	}
	
	//DICA DAS TECLAS
	var _dica = tecla_nome(global.imputs.left) + " " + tecla_nome(global.imputs.rigth) + "   " + (_en == 0 ? "ESPAÇO: ESCOLHER" : "SPACE: PICK");
	draw_text_transformed_color(gui_meio_x() * _e, (_py + _ph - 12) * _e, _dica, _e * .7, _e * .7, 0, #C7CFDD, #C7CFDD, #C7CFDD, #C7CFDD, _a);
	
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

#region MENU DE DEBUG DOS BLOCOS
//LISTA EM DUAS COLUNAS. O BLOCO AINDA NAO LIBERADO PELO TEMPO DA PARTIDA APARECE COM O MINUTO DELE
if(menu_debug)
{
	var _e = gui_esc();
	var _a = 1;
	var _cx = gui_meio_x();
	draw_set_alpha(_a * .75);
	draw_set_color(c_black);
	var _tl = gui_tela();
	draw_rectangle(_tl[0], _tl[1], _tl[2], _tl[3], false);
	draw_set_alpha(_a);

	var _lista = debug_lista_blocos();
	var _n = array_length(_lista);
	var _metade = ceil(_n / 2);
	var _lh = 14;
	var _th = sprite_get_height(spr_caixa_setings);
	var _pw = 260;
	var _ph = _th + 12 + _metade * _lh + 18;
	var _px = _cx - _pw / 2;
	var _py = gui_meio_y() - _ph / 2;
	draw_sprite_stretched_ext(spr_caixa_setings, 0, _px * _e, _py * _e, _pw * _e, _th * _e, c_white, _a);
	draw_sprite_stretched_ext(spr_menu_janela, 0, _px * _e, (_py + _th) * _e, _pw * _e, (_ph - _th) * _e, c_white, _a);

	draw_set_font(fnt_hud);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_text_transformed_color((_px + 5) * _e, (_py + _th / 2) * _e, "DEBUG: QUAL BLOCO NASCE?", _e, _e, 0, c_white, c_white, c_white, c_white, _a);

	//MINUTO EM QUE CADA UM E LIBERADO NA PARTIDA NORMAL (SO PRA MOSTRAR)
	var _libera = { Normal : 0, Raio : LIBERA_RAIO, Especial : LIBERA_ESPECIAL, Raivoso : LIBERA_RAIVOSO, Pedra : LIBERA_PEDRA,
		Gelo : LIBERA_GELO, Fujao : LIBERA_FUJAO, Colmeia : LIBERA_COLMEIA, Fantasma : LIBERA_FANTASMA, Inimigo : LIBERA_INIMIGO,
		Cabecudo : LIBERA_CABECUDO, Laser : LIBERA_LASER, LaserLado : LIBERA_LASER, Sniper : LIBERA_SNIPER, Bomba : LIBERA_BOMBA, Lento : LIBERA_LENTO,
		Gelatina : LIBERA_GELATINA, Buraco : LIBERA_BURACO };
	for(var i = 0; i < _n; i++)
	{
		var _col = i div _metade;
		var _lin = i mod _metade;
		var _ix = _px + 14 + _col * (_pw / 2);
		var _iy = _py + _th + 12 + _lin * _lh;
		var _sel = debug_opcao == i;
		if(_sel) draw_sprite_stretched_ext(spr_menu_confg, 0, (_ix - 6) * _e, (_iy - 6) * _e, (_pw / 2 - 16) * _e, 12 * _e, c_white, _a);
		var _c = _sel ? c_white : #92A1B9;
		var _min = _libera[$ _lista[i]];
		var _txt = string_upper(_lista[i]) + (_min > 0 ? "  " + string_format(_min, 1, frac(_min) == 0 ? 0 : 1) + "m" : "");
		draw_text_transformed_color(_ix * _e, _iy * _e, (_sel ? "> " : "") + _txt, _e * .8, _e * .8, 0, _c, _c, _c, _c, _a);
	}
	draw_set_halign(fa_center);
	draw_text_transformed_color(_cx * _e, (_py + _ph - 10) * _e, "SETAS ESCOLHEM - ENTER NASCE - ESC FECHA", _e * .65, _e * .65, 0, c_aqua, c_aqua, c_aqua, c_aqua, _a);
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}
#endregion

//GUIA DA PRIMEIRA LINHA (SCR_PODERES): BRILHO LEVE NA LINHA QUE FICA EM CIMA DO CHAO + SETAS
guia_linha_desenhar();

//TIRA DE COMANDOS NO RODAPE (SCR_PODERES): AS TECLAS PASSAM DEVAGAR, CLARAS ATE O JOGADOR USAR, DEPOIS FICAM COM ALPHA .5
teclas_desenhar();

//GORZ (SCR_PODERES): NO JOGO NORMAL DESENHA AQUI (DEPOIS A TELA DE PAUSA/RESULTADO SAI CEDO). COM PAUSA/RESULTADO ELE DESENHA NO FIM, POR CIMA
if(alpha_pause < .01 and alpha_fim < .01) gorz_desenhar();

//TELA DE PAUSA E DE RESULTADO (GAME OVER)
//TUDO E POSICIONADO EM "PIXELS DA ROOM" E MULTIPLICADO POR _E, PORQUE A GUI E MAIOR QUE A ROOM
if(alpha_pause < .01 and alpha_fim < .01) exit;
//VERSUS: O RESULTADO TEM A TELA PROPRIA (SCR_COOP)
if(modo_versus() and alpha_fim > alpha_pause) { versus_resultado_desenhar(alpha_fim); exit; }

//ESCALA E MEIO DA TELA. _FIM = TA MOSTRANDO O GAME OVER (SENAO E A PAUSA)
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _e = gui_esc();
var _fim = alpha_fim > alpha_pause;
var _a = max(alpha_pause, alpha_fim);
var _cx = gui_meio_x();

//PC: A PAUSA TEM O VISUAL DO MENU PRINCIPAL (SCR_MENU). O CELULAR E O GAME OVER USAM O PAINEL ANTIGO, AQUI EMBAIXO
if(!_fim and !MOBILE)
{
	pausa_menu_desenhar(_a, pause_t, pause_sel, opcao_pause);
	exit;
}

//FUNDO ESCURO
draw_set_alpha(_a * .75);
draw_set_color(c_black);
var _tl = gui_tela();
draw_rectangle(_tl[0], _tl[1], _tl[2], _tl[3], false);
draw_set_alpha(_a);

//TAMANHO DO PAINEL
var _pw = 300;
var _ph = _fim ? 250 : (ver_comandos ? 236 : 248);
var _px = _cx - _pw / 2;
var _py = gui_meio_y() - _ph / 2;
var _th = sprite_get_height(spr_caixa_setings);

draw_sprite_stretched_ext(spr_caixa_setings, 0, _px * _e, _py * _e, _pw * _e, _th * _e, c_white, _a);
draw_sprite_stretched_ext(spr_menu_janela, 0, _px * _e, (_py + _th) * _e, _pw * _e, (_ph - _th) * _e, c_white, _a);

//TITULO NA BARRA
draw_set_font(fnt_hud);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
var _titulo = _fim ? "GAME OVER" : (ver_comandos ? (global.linguagem == 0 ? "COMANDOS" : "CONTROLS") : texto("pausado"));
draw_text_transformed_color((_px + 5) * _e, (_py + _th / 2) * _e, _titulo, _e, _e, 0, c_white, c_white, c_white, c_white, _a);

//PRIMEIRA LINHA DE CONTEUDO
var _y = _py + _th + 16;

if(_fim)
{
	#region RESULTADO
	//FRASE MOTIVACIONAL
	draw_set_halign(fa_center);
	var _frases = texto("frases_fim");
	var _frase = _frases[clamp(frase_fim, 0, array_length(_frases) - 1)];
	draw_text_ext_transformed_color(_cx * _e, _y * _e, _frase, 12, (_pw - 30), _e * .8, _e * .8, 0, #C7CFDD, #C7CFDD, #C7CFDD, #C7CFDD, _a);
	_y += 28;

	//ESTATISTICAS (NOME NA ESQUERDA, VALOR NA DIREITA)
	//TEMPO EM MM:SS
	var _seg = floor(global.tempo_partida);
	var _tempo = string_replace_all(string_format(_seg div 60, 2, 0), " ", "0") + ":" + string_replace_all(string_format(_seg mod 60, 2, 0), " ", "0");
	var _linhas = [
		[texto("pontos"),			string(round(pontos_anim))],
		[texto("recorde"),			string(recorde_atual())],
		["LEVEL",					string(global.level)],
		[texto("tempo_total"),		_tempo],
		[texto("linhas_completas"),	string(global.linhas_total)],
		[texto("blocos_destruidos"),string(global.blocos_destruidos)],
		[texto("moedas_ganhas"),	"+" + string(global.moedas_partida)],
	];
	for(var i = 0; i < array_length(_linhas); i++)
	{
		var _cor = i == 0 ? c_yellow : c_white;
		draw_sprite_stretched_ext(spr_menu_linhas_2, 0, (_px + 12) * _e, (_y - 5) * _e, (_pw - 24) * _e, 11 * _e, c_white, _a * .8);
		draw_set_halign(fa_left);
		draw_text_transformed_color((_px + 18) * _e, _y * _e, _linhas[i][0], _e * .9, _e * .9, 0, c_white, c_white, c_white, c_white, _a);
		draw_set_halign(fa_right);
		draw_text_transformed_color((_px + _pw - 18) * _e, _y * _e, _linhas[i][1], _e * .9, _e * .9, 0, _cor, _cor, _cor, _cor, _a);
		if(i == array_length(_linhas) - 1) draw_sprite_ext(spr_moeda, current_time / 100, (_px + _pw - 18 - string_width(_linhas[i][1]) * .9 - 10) * _e, _y * _e, _e * .7, _e * .7, 0, c_white, _a);
		_y += 17;
	}

	//NOVO RECORDE (PISCANDO)
	draw_set_halign(fa_center);
	if(novo_recorde)
	{
		var _pisca = .6 + .4 * sin(current_time / 120);
		draw_text_transformed_color(_cx * _e, (_y + 2) * _e, texto("novo_recorde"), _e * 1.1, _e * 1.1, 0, c_yellow, c_yellow, c_orange, c_orange, _a * _pisca);
	}
	_y += 20;

	//OPÇOES
	var _opcoes = [texto("recomecar"), texto("voltar_menu")];
	for(var i = 0; i < 2; i++)
	{
		var _sel = opcao_fim == i and timer_menu_fim <= 0;
		var _bw = 150, _bh = 18;
		draw_sprite_stretched_ext(spr_menu_confg, 0, (_cx - _bw / 2) * _e, (_y - _bh / 2) * _e, _bw * _e, _bh * _e, c_white, _a * (_sel ? 1 : .45));
		var _c = _sel ? c_white : #92A1B9;
		draw_text_transformed_color(_cx * _e, _y * _e, (_sel ? "> " : "") + _opcoes[i] + (_sel ? " <" : ""), _e * .9, _e * .9, 0, _c, _c, _c, _c, _a);
		_y += 22;
	}
	#endregion
}
else
{
	#region PAUSA
	draw_set_halign(fa_center);
	if(ver_comandos)
	{
		//COMANDOS: AÇAO NA ESQUERDA, TECLA NO MEIO E BOTAO DO CONTROLE NA DIREITA
		var _pt = global.linguagem == 0;
		var _im = dois_players() ? imputs_layout(COOP_LAYOUT_P1) : global.imputs;
		var _linhas = [
			[_pt ? "AÇÃO" : "ACTION",				_pt ? "TECLADO" : "KEYBOARD",				_pt ? "CONTROLE" : "GAMEPAD"],
			[_pt ? "ANDAR" : "MOVE",				tecla_nome(_im.left) + " / " + tecla_nome(_im.rigth),	_pt ? "ANALÓGICO / D-PAD" : "STICK / D-PAD"],
			[_pt ? "PULO" : "JUMP",					tecla_nome(_im.jump),						"A"],
			[_pt ? "SOCO" : "PUNCH",				tecla_nome(_im.soco),						"X"],
			[_pt ? "SUPER SOCO" : "SUPER PUNCH",	tecla_nome(_im.soco_press),					"RB"],
			[_pt ? "GIRO" : "SPIN",					tecla_nome(_im.giro),						"B"],
			[_pt ? "DASH (PODER)" : "DASH (POWER)",	tecla_nome(_im.dash),						"Y"],
			[_pt ? "TELEPORTAR PEÇA" : "DROP PIECE",	tecla_nome(global.imputs.acelerar),		"LB / RT"],
			[_pt ? "PARAR O TEMPO" : "TIME STOP",	"1",										"LT / SELECT"],
			[_pt ? "PAUSA" : "PAUSE",				"ESC",										"START"],
		];
		var _cx1 = _px + 12, _cx2 = _px + 150, _cx3 = _px + 236;
		for(var i = 0; i < array_length(_linhas); i++)
		{
			var _ly = _y - 4 + i * 17;
			var _cab = i == 0;
			var _c1 = _cab ? #FFE66B : c_white, _c2 = _cab ? #FFE66B : #8BFF32, _c3 = _cab ? #FFE66B : #31FCFF;
			if(!_cab and i mod 2 == 0) { draw_set_alpha(_a * .25); draw_set_color(c_white); draw_rectangle((_px + 6) * _e, (_ly - 7) * _e, (_px + _pw - 6) * _e, (_ly + 7) * _e, false); draw_set_alpha(_a); }
			draw_set_halign(fa_left);
			draw_text_transformed_color(_cx1 * _e, _ly * _e, _linhas[i][0], _e * .7, _e * .7, 0, _c1, _c1, _c1, _c1, _a);
			draw_set_halign(fa_center);
			draw_text_transformed_color(_cx2 * _e, _ly * _e, _linhas[i][1], _e * .7, _e * .7, 0, _c2, _c2, _c2, _c2, _a);
			draw_text_transformed_color(_cx3 * _e, _ly * _e, _linhas[i][2], _e * .7, _e * .7, 0, _c3, _c3, _c3, _c3, _a);
		}
		var _rod = dois_players() ? (_pt ? "P2: SETAS + C X Z V (OU O 2º CONTROLE)" : "P2: ARROWS + C X Z V (OR 2ND GAMEPAD)") : (_pt ? "ESC / B: VOLTAR" : "ESC / B: BACK");
		draw_text_transformed_color(_cx * _e, (_y - 4 + array_length(_linhas) * 17 + 4) * _e, _rod, _e * .6, _e * .6, 0, #C7CFDD, #C7CFDD, #C7CFDD, #C7CFDD, _a);
	}
	var _opcoes = [texto("continuar_jogo"), global.linguagem == 0 ? "COMANDOS" : "CONTROLS", (global.linguagem == 0 ? "TECLAS" : "KEYS") + ": " + (global.mostrar_teclas ? (global.linguagem == 0 ? "SIM" : "ON") : (global.linguagem == 0 ? "NÃO" : "OFF")), (global.linguagem == 0 ? "TESTE DE DIFICULDADE: " : "DIFFICULTY TEST: ") + (global.teste_dif ? (global.linguagem == 0 ? "SIM" : "ON") : (global.linguagem == 0 ? "NÃO" : "OFF")), texto("reiniciar"), texto("voltar_menu")];
	for(var i = 0; i < (ver_comandos ? 0 : 6); i++)
	{
		var _sel = opcao_pause == i;
		var _bw = 160, _bh = 18;
		draw_sprite_stretched_ext(spr_menu_confg, 0, (_cx - _bw / 2) * _e, (_y - _bh / 2) * _e, _bw * _e, _bh * _e, c_white, _a * (_sel ? 1 : .45));
		var _c = _sel ? c_white : #92A1B9;
		//TEXTO LONGO ENCOLHE PRA CABER NA CAIXA
		var _txt_op = (_sel ? "> " : "") + _opcoes[i] + (_sel ? " <" : "");
		var _esc_op = min(.9, (_bw - 12) / max(1, string_width(_txt_op)));
		if(i == 4 and global.teste_dif) _c = _sel ? #FFE66B : #C9A93C;	//LIGADO FICA AMARELO
		draw_text_transformed_color(_cx * _e, _y * _e, _txt_op, _e * _esc_op, _e * _esc_op, 0, _c, _c, _c, _c, _a);
		_y += 24;
	}
	//DICA DO ESPECIAL
	if(!ver_comandos) draw_text_ext_transformed_color(_cx * _e, (_y + 6) * _e, texto("dica_especial"), 12, _pw - 30, _e * .7, _e * .7, 0, c_aqua, c_aqua, c_aqua, c_aqua, _a);
	#endregion
}

//GORZ: A FALA NA TELA (SCR_PODERES). POR CIMA DE TUDO, ATE DA TELA DE RESULTADO
gorz_desenhar();

//VOLTA O PADRAO DE DESENHO
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
