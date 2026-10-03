//SO DESENHA COM A ARENA E VISIVEL. NO ALERTA MOSTRA SO O AVISO
if(!instance_exists(area) or alpha < .01) exit;
var _gw = display_get_gui_width(), _gh = display_get_gui_height();
//ESCALA DA GUI E O MEIO DA ARENA NA GUI
var _e = gui_esc();
var _cx = (area.x + area.sprite_width / 2) * _e;
var _cy = (area.y + area.sprite_height * .4) * _e;
var _a = alpha;

//PULSO PRA SETA ATUAL
var _pulso = .5 + .5 * sin(current_time / 120);
if(estado == "alerta") { desafio_alerta_desenhar(global.linguagem == 0 ? "QUEBRA-CABEÇA!" : "PUZZLE!", timer, _a, area); exit; }

//CUBO MAGICO (SPRITE STACKING: CADA FATIA 1PX ACIMA DA OUTRA, TODAS GIRANDO JUNTAS)
if(sprite_exists(cubo_spr))
{
	var _esc = (2 + .5 * cubo_pop) * cubo_esc * _e;
	var _n = sprite_get_number(cubo_spr);
	var _passo = _esc * .75; //AS FATIAS UM POUCO MAIS JUNTAS: O CUBO NAO FICA ALTO DEMAIS
	var _base = _cy + _n * _passo * .5;
	for(var i = 0; i < _n; i++)
	{
		for(var k = 0; k < ceil(_passo); k++)
		{
			draw_sprite_ext(cubo_spr, i, _cx, _base - i * _passo - k, _esc, _esc, cubo_ang, c_white, _a);
		}
	}
}

//SETAS DA SEQUENCIA (AS CERTAS FICAM ACESAS)
if(estado == "puzzle" and array_length(seq) > 0)
{
	var _n = array_length(seq);
	//ESPAÇO ENTRE AS SETAS, ALTURA DELAS, ONDE COMEÇA E TAMANHO
	var _esp = 20 * _e;
	var _sy = _cy + 52 * _e;
	var _x0 = _cx - (_n - 1) * _esp / 2;
	var _t = 6 * _e;

	//FUNDO ESCURO ARREDONDADO ATRAS DAS SETAS
	draw_set_alpha(_a * .6);
	draw_set_color(#0E071B);
	draw_roundrect_ext(_x0 - _esp * .7, _sy - _esp * .7, _x0 + (_n - 1) * _esp + _esp * .7, _sy + _esp * .7, 8 * _e, 8 * _e, false);
	draw_set_alpha(1);

	for(var i = 0; i < _n; i++)
	{
		//VERDE = JA FEITA, BRANCA = A PROXIMA, CINZA = AS QUE FALTAM (VERMELHA E TREMENDO QUANDO ERRA)
		var _feita = i < seq_pos;
		var _cor = _feita ? #8BFF32 : (i == seq_pos ? c_white : #8A84A8);
		var _ox = 0;
		if(seq_erro > 0) { _cor = c_red; _ox = random_range(-2, 2) * _e; }
		var _tt = _t * (1 + .6 * seq_pop[i]) * (i == seq_pos and seq_erro <= 0 ? 1 + .1 * _pulso : 1);
		seta_desenhar(_x0 + i * _esp + _ox, _sy, seq[i], _tt, _cor, _a * (seq_espera > 0 ? .4 : 1));
	}

	//ETAPAS DO CUBO
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _txt = string(passo) + "/" + string(passos_total);
	draw_text_transformed_color(_cx + _e, _sy + 22 * _e + _e, _txt, _e, _e, 0, #0E071B, #0E071B, #0E071B, #0E071B, _a);
	draw_text_transformed_color(_cx, _sy + 22 * _e, _txt, _e, _e, 0, c_white, c_white, c_white, c_white, _a);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
