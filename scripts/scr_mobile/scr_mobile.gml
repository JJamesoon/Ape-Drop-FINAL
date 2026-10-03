//LAYOUT MOBILE (OBJ_MOBILE)==================================
//A CAMERA ENCAIXA O JOGO NA TELA DO CELULAR, SEM FAIXA PRETA:
//	EM PE (NA PARTIDA): MOSTRA SO A ARENA + O PAINEL DO LADO, OCUPANDO A LARGURA TODA. OS BOTOES FICAM EMBAIXO
//	DEITADO (OU NOS MENUS): MOSTRA A ROOM INTEIRA. NA PARTIDA OS BOTOES FICAM NOS LADOS (QUE SAO VAZIOS)
//A GUI USA A MESMA CONTA: (POSIÇAO NA ROOM) * GUI_ESC() CAI NO MESMO LUGAR DA TELA (O DESLOCAMENTO DA CAMERA
//VAI NO DISPLAY_SET_GUI_MAXIMIZE). NO PC COM A JANELA 16:9 TUDO FICA IGUAL AO PROJETO NORMAL
#macro MOB_TESTE_PC			false	//TRUE = O PC RODA COMO CELULAR (JANELA EM PE + BOTOES DE TOQUE) PRA TESTAR O LAYOUT
#macro MOBILE				(MOB_TESTE_PC or os_type == os_android or os_type == os_ios)	//TA RODANDO NO CELULAR?
#macro MOB_RETRATO_W		316		//LARGURA DA ROOM QUE APARECE EM PE (ARENA + PAINEL + UMA MARGEM)
#macro MOB_RETRATO_MEIO_X	401		//MEIO DA ARENA + PAINEL
#macro MOB_RETRATO_Y		28		//TOPO DO QUE APARECE
#macro MOB_JOGO_FIM			388		//ONDE O JOGO TERMINA NA ROOM (DAI PRA BAIXO E A AREA DOS BOTOES)
#macro MOB_JOGO_ESQ			255		//BORDA ESQUERDA E DIREITA DO JOGO (DEITADO, OS BOTOES FICAM FORA DISSO)
#macro MOB_JOGO_DIR			548
#macro MOB_DEBUG			true	//ESCREVE OS TOQUES NO LOG (LOGCAT) PRA TESTAR OS BOTOES. DESLIGAR DEPOIS

global.mob = { cx : 0, cy : 0, cw : 720, ch : 405, esc : 2, ww : 0, wh : 0, retrato : false, botoes : [] };

//NO PC (MOBILE FALSO) ESSAS FUNÇOES DEVOLVEM O MESMO QUE O JOGO USAVA ANTES DO MOBILE EXISTIR
function gui_esc()		{ return MOBILE ? global.mob.esc : display_get_gui_width() / room_width; }	//PIXELS DA TELA POR PIXEL DA ROOM
function gui_meio_x()	{ return MOBILE ? global.mob.cx + global.mob.cw / 2 : room_width / 2; }		//MEIO DA TELA (EM COORDENADA DA ROOM)
function gui_meio_y()																				//EM PE: MEIO DA AREA DO JOGO (OS BOTOES FICAM EMBAIXO)
{
	if(!MOBILE) return room_height / 2;
	return global.mob.retrato ? (global.mob.cy + MOB_JOGO_FIM) / 2 : global.mob.cy + global.mob.ch / 2;
}
function gui_retrato()	{ return global.mob.retrato; }
//A TELA INTEIRA EM COORDENADAS DA GUI [X1, Y1, X2, Y2] (PRA FUNDOS ESCUROS, FLASH, TRANSIÇAO...)
function gui_tela()
{
	if(!MOBILE) return [0, 0, display_get_gui_width(), display_get_gui_height()];
	var _m = global.mob;
	return [_m.cx * _m.esc, _m.cy * _m.esc, _m.cx * _m.esc + _m.ww, _m.cy * _m.esc + _m.wh];
}
//A ROOM DO MENU DE CADA PLATAFORMA
function menu_room()	{ return MOBILE ? rm_menu_mobile : rm_menu; }

//ARRUMA A CAMERA, A APPLICATION_SURFACE, A GUI E OS BOTOES PRO TAMANHO DA JANELA/TELA
function mobile_layout()
{
	var _ww = window_get_width(), _wh = window_get_height();
	if(_ww <= 0 or _wh <= 0) exit; //MINIMIZADA
	var _m = global.mob;
	_m.ww = _ww;
	_m.wh = _wh;
	_m.retrato = room == rm_arcade and _wh > _ww;
	if(_m.retrato)
	{
		_m.cw = MOB_RETRATO_W;
		_m.ch = _m.cw * _wh / _ww;
		_m.cx = MOB_RETRATO_MEIO_X - _m.cw / 2;
		_m.cy = MOB_RETRATO_Y;
	}
	else
	{
		//A ROOM INTEIRA NO MEIO, O QUE SOBRA DA TELA MOSTRA UM POUCO ALEM DA ROOM
		var _esc = min(_ww / room_width, _wh / room_height);
		_m.cw = _ww / _esc;
		_m.ch = _wh / _esc;
		_m.cx = (room_width - _m.cw) / 2;
		_m.cy = (room_height - _m.ch) / 2;
	}
	_m.esc = _ww / _m.cw;

	view_enabled = true;
	view_set_visible(0, true);
	if(view_camera[0] == -1) view_camera[0] = camera_create();
	camera_set_view_size(view_camera[0], _m.cw, _m.ch);
	camera_set_view_pos(view_camera[0], _m.cx, _m.cy);
	view_set_wport(0, _ww);
	view_set_hport(0, _wh);
	surface_resize(application_surface, _ww, _wh);
	display_set_gui_maximize(1, 1, -_m.cx * _m.esc, -_m.cy * _m.esc);
	mobile_botoes_criar();
}

//BOTOES DE TOQUE DA PARTIDA (CADA UM E UMA TECLA VIRTUAL: O PLAYER NAO PRECISA SABER QUE E CELULAR)
function mobile_botoes_criar()
{
	var _m = global.mob;
	for(var i = 0; i < array_length(_m.botoes); i++) virtual_key_delete(_m.botoes[i].vk);
	_m.botoes = [];
	if(!MOBILE) exit;
	if(room == rm_menu_mobile) exit;						//O MENU DO CELULAR E SO TOCAR NA TELA
	if(!modo_arcade()) { mobile_botoes_menu(); exit; }

	var _im = global.imputs;
	var _ww = _m.ww, _wh = _m.wh;
	var _dx, _dy, _ax, _ay, _r, _px, _py, _tx, _ty;
	if(_m.retrato)
	{
		//EMBAIXO DO JOGO: DIRECIONAL NA ESQUERDA, AÇOES NA DIREITA, PAUSE E TELEPORTE NO MEIO
		var _y0 = (MOB_JOGO_FIM - _m.cy) * _m.esc;
		var _h = _wh - _y0;
		_r = min(_ww * .07, _h * .13);
		_dx = _ww * .24;	_dy = _y0 + _h * .5;
		_ax = _ww * .76;	_ay = _dy;
		_px = _ww * .5;		_py = _y0 + _h * .14;
		_tx = _ww * .5;		_ty = _y0 + _h * .86;
	}
	else
	{
		//DEITADO: NOS LADOS VAZIOS DA ROOM
		var _le = max(0, (MOB_JOGO_ESQ - _m.cx) * _m.esc);
		var _ld = max(0, _ww - (MOB_JOGO_DIR - _m.cx) * _m.esc);
		_r = min(_le * .14, _ld * .14, _wh * .085);
		_dx = _le * .5;			_dy = _wh * .64;
		_ax = _ww - _ld * .5;	_ay = _dy;
		_px = _ww - _ld * .5;	_py = _wh * .14;
		_tx = _le * .5;			_ty = _wh * .2;
	}
	var _d = _r * 2.1;
	var _lista = [
		{ x : _dx - _d, y : _dy,      r : _r, tecla : _im.left,     seta : 2,  txt : "",      cor : c_white, img : 0 },
		{ x : _dx + _d, y : _dy,      r : _r, tecla : _im.rigth,    seta : 0,  txt : "",      cor : c_white, img : 1 },
		{ x : _dx,      y : _dy - _d, r : _r, tecla : vk_up,        seta : 1,  txt : "",      cor : c_white, img : 2 },
		{ x : _dx,      y : _dy + _d, r : _r, tecla : _im.down,     seta : 3,  txt : "",      cor : c_white, img : 3 },
		{ x : _ax,      y : _ay + _d, r : _r * 1.15, tecla : _im.jump, seta : -1, txt : "PULO", cor : #8BFF32, img : 4 },
		{ x : _ax + _d, y : _ay,      r : _r, tecla : _im.soco,     seta : -1, txt : "SOCO",  cor : #FF3237, img : 5 },
		{ x : _ax - _d, y : _ay,      r : _r, tecla : _im.giro,     seta : -1, txt : "GIRO",  cor : #FFE600, img : 6 },
		{ x : _ax,      y : _ay - _d, r : _r, tecla : _im.dash,     seta : -1, txt : "DASH",  cor : #31FCFF, img : 7 },
		{ x : _ax + _d * .95, y : _ay - _d * .95, r : _r * .8, tecla : _im.soco_press, seta : -1, txt : "SUPER", cor : #FF8A1A, img : 8 },
		{ x : _px,      y : _py,      r : _r * .6, tecla : vk_escape,  seta : -1, txt : "II",   cor : c_white, img : 9 },
		{ x : _tx,      y : _ty,      r : _r * .75, tecla : _im.acelerar, seta : -1, txt : "TELE", cor : #DE65FF, img : 10 },
		{ x : _tx + _d * 1.2 * (_m.retrato ? 1 : 0), y : _ty + _d * 1.2 * (_m.retrato ? 0 : 1), r : _r * .75, tecla : TEMPO_TECLA, seta : -1, txt : "TEMPO", cor : TEMPO_VERDE, img : 11, tempo : true },
	];
	mobile_botoes_registrar(_lista);
}

//CADA BOTAO VIRA UMA TECLA VIRTUAL (AREA DE TOQUE UM POUCO MAIOR QUE O CIRCULO)
//A TECLA VIRTUAL USA COORDENADA DA GUI, QUE TEM O DESLOCAMENTO DA CAMERA: SOMA ELE IGUAL NO DESENHO
function mobile_botoes_registrar(_lista)
{
	var _m = global.mob;
	var _t = gui_tela();
	for(var i = 0; i < array_length(_lista); i++)
	{
		var _b = _lista[i];
		var _l = _b.r * 2.05;
		_b.vk = virtual_key_add(_t[0] + _b.x - _l / 2, _t[1] + _b.y - _l / 2, _l, _l, _b.tecla);
		array_push(_m.botoes, _b);
	}
	if(MOB_DEBUG)
	{
		show_debug_message("[MOB] layout " + room_get_name(room) + " janela " + string(_m.ww) + "x" + string(_m.wh) + " display " + string(display_get_width()) + "x" + string(display_get_height()) + " botoes " + string(array_length(_m.botoes)));
		for(var i = 0; i < array_length(_m.botoes); i++) show_debug_message("[MOB] botao " + _m.botoes[i].txt + string(_m.botoes[i].seta) + " em " + string(round(_m.botoes[i].x)) + "," + string(round(_m.botoes[i].y)) + " r " + string(round(_m.botoes[i].r)));
	}
}

//BOTOES DOS MENUS (MENU PRINCIPAL, SELEÇAO...): DIRECIONAL + OK + VOLTAR (OS MENUS ACEITAM SETAS, ENTER E ESC)
function mobile_botoes_menu()
{
	var _m = global.mob;
	var _ww = _m.ww, _wh = _m.wh;
	var _dx, _dy, _ax, _ay, _r;
	var _y0 = (room_height - _m.cy) * _m.esc;		//ONDE A ROOM ACABA NA TELA
	var _le = (0 - _m.cx) * _m.esc;					//SOBRA NA ESQUERDA (DEITADO)
	if(_wh - _y0 > _wh * .2)
	{
		//EM PE: EMBAIXO DO MENU
		var _h = _wh - _y0;
		_r = min(_ww * .07, _h * .14);
		_dx = _ww * .26;	_dy = _y0 + _h * .5;
		_ax = _ww * .74;	_ay = _dy;
	}
	else
	{
		//DEITADO: NOS CANTOS DE BAIXO (OU NAS SOBRAS DOS LADOS)
		_r = min(_wh * .07, max(_le * .14, _wh * .05));
		_dx = max(_le * .5, _r * 3.3);		_dy = _wh - _r * 3.3;
		_ax = _ww - max(_le * .5, _r * 3.3);	_ay = _dy;
	}
	var _d = _r * 2.1;
	var _lista = [
		{ x : _dx - _d, y : _dy,      r : _r, tecla : vk_left,   seta : 2,  txt : "",       cor : c_white, img : 0 },
		{ x : _dx + _d, y : _dy,      r : _r, tecla : vk_right,  seta : 0,  txt : "",       cor : c_white, img : 1 },
		{ x : _dx,      y : _dy - _d, r : _r, tecla : vk_up,     seta : 1,  txt : "",       cor : c_white, img : 2 },
		{ x : _dx,      y : _dy + _d, r : _r, tecla : vk_down,   seta : 3,  txt : "",       cor : c_white, img : 3 },
		{ x : _ax + _d * .5, y : _ay + _d * .4, r : _r * 1.2, tecla : vk_enter, seta : -1, txt : "OK", cor : #8BFF32, img : 11 },
		{ x : _ax - _d * .7, y : _ay - _d * .6, r : _r * .85, tecla : vk_escape, seta : -1, txt : "VOLTAR", cor : #FF3237, img : 11 },
	];
	mobile_botoes_registrar(_lista);
}

//DEBUG: ESCREVE NO LOG ONDE TA TOCANDO E QUAIS BOTOES ESTAO APERTADOS
function mobile_debug_toques()
{
	if(!MOB_DEBUG) exit;
	var _txt = "";
	for(var i = 0; i < 5; i++)
	{
		if(device_mouse_check_button(i, mb_left)) _txt += " dedo" + string(i) + "=" + string(round(device_mouse_raw_x(i))) + "," + string(round(device_mouse_raw_y(i)));
	}
	var _b = global.mob.botoes;
	for(var i = 0; i < array_length(_b); i++) if(keyboard_check(_b[i].tecla)) _txt += " [" + _b[i].txt + string(_b[i].seta) + "]";
	if(_txt != "") show_debug_message("[MOB] toque" + _txt);
}

//DESENHA OS BOTOES (DRAW GUI DO OBJ_MOBILE). ACENDE O QUE TA SENDO APERTADO
function mobile_botoes_desenhar()
{
	var _m = global.mob;
	if(array_length(_m.botoes) == 0) exit;
	if(pad_ligado()) exit; //JOGANDO NO CONTROLE: OS BOTOES DE TOQUE SOMEM
	var _t = gui_tela();
	var _ox = _t[0], _oy = _t[1];

	//FUNDO DA AREA DOS BOTOES (EM PE)
	if(_m.retrato)
	{
		var _y0 = (MOB_JOGO_FIM - _m.cy) * _m.esc;
		draw_set_alpha(.55);
		draw_set_color(#0E071B);
		draw_rectangle(_ox, _oy + _y0, _ox + _m.ww, _oy + _m.wh, false);
		draw_set_alpha(1);
		draw_set_color(#424C6E);
		draw_rectangle(_ox, _oy + _y0, _ox + _m.ww, _oy + _y0 + 1, false);
	}

	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	for(var i = 0; i < array_length(_m.botoes); i++)
	{
		var _b = _m.botoes[i];
		var _ap = keyboard_check(_b.tecla);
		var _x = _ox + _b.x, _y = _oy + _b.y;
		var _r = _b.r * (_ap ? .92 : 1);
		var _cor = _b.cor;
		var _apagado = _b.tecla == global.imputs.dash and !tem_poder("dash"); //SEM O PODER, O DASH FICA APAGADO
		//BOTAO DE PARAR O TEMPO: SO APARECE COM A ENERGIA CHEIA (PISCANDO)
		if(variable_struct_exists(_b, "tempo")) { if(global.energia < ENERGIA_MAX or tempo_ativo()) continue; }
		var _es = (_b.r * 2.1) / sprite_get_width(spr_mob_botoes);
		var _afunda = _ap ? _b.r * .08 : 0;
		var _al = _apagado ? .35 : (_ap ? 1 : .85);
		draw_sprite_ext(spr_mob_botoes, _b.img, _x, _y + _afunda, _es, _es, 0, _ap ? #B0B0B0 : c_white, _al);
		//O BOTAO VAZIO GANHA O TEXTO (OK, VOLTAR) OU O RELOGIO DO PARAR O TEMPO
		if(_b.img == 11)
		{
			if(variable_struct_exists(_b, "tempo"))
			{
				var _rr = _b.r * .45;
				draw_set_alpha(.6 + .4 * sin(current_time / 120));
				draw_set_color(TEMPO_VERDE);
				draw_circle(_x, _y + _afunda, _rr, true);
				draw_line_width(_x, _y + _afunda, _x + lengthdir_x(_rr * .8, 90 - current_time / 6), _y + _afunda + lengthdir_y(_rr * .8, 90 - current_time / 6), 2);
				draw_set_alpha(1);
			}
			else
			{
				var _s = _b.r / max(22, string_length(_b.txt) * 6.5);
				draw_text_transformed_color(_x, _y + _afunda, _b.txt, _s, _s, 0, c_white, c_white, c_white, c_white, _al);
			}
		}
		draw_set_alpha(1);
	}
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
