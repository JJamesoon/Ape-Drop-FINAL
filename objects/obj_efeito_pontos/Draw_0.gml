draw_set_font(fnt_hud);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

//COR DA SOMBRA DOS TEXTOS
var _sombra = #0E071B;

switch(modo)
{
	//NUMERO DA LINHA NO CENTRO DA TELA (GRANDE, COM CONTORNO)
	case "coletor":
		var _e = 2 * esc * esc_pop;
		//CONTORNO: O TEXTO ESCURO 2PX PRA CADA LADO
		for(var i = 0; i < 4; i++)
		{
			draw_text_transformed_color(x + lengthdir_x(2, i * 90), y + lengthdir_y(2, i * 90), mensagem, _e, _e, 0, _sombra, _sombra, _sombra, _sombra, alpha);
		}
		draw_text_transformed_color(x, y, mensagem, _e, _e, 0, c_yellow, c_yellow, c_orange, c_orange, alpha);
		break;

	//BLOCO DA IRMANDADE: O "10" (COM UM PULINHO QUANDO APARECE) E DEPOIS VOANDO PRO CENTRO
	case "coletar":
		var _e = .9 * (1 + .3 * max(0, 1 - timer_voo / 8));
		draw_text_transformed_color(x + 1, y + 1, mensagem, _e, _e, 0, _sombra, _sombra, _sombra, _sombra, 1);
		draw_text_transformed_color(x, y, mensagem, _e, _e, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
		break;
	
	//MORTE DA IRMANDADE: ANEL BRANCO (CONTORNO DE 2PX)
	case "anel":
		var _m = 8 * esc * esc_anel;
		draw_set_alpha(alpha);
		draw_rectangle_color(x - _m, y - _m, x + _m, y + _m, c_white, c_white, c_white, c_white, true);
		draw_rectangle_color(x - _m + 1, y - _m + 1, x + _m - 1, y + _m - 1, c_white, c_white, c_white, c_white, true);
		draw_set_alpha(1);
		break;
	
	//TELEPORTE: A PEÇA CHEGOU NO CHAO. CLARAO QUE ABRE PROS LADOS, ANEL E FAÍSCAS PULANDO (O RASTRO E O SPR_EFEITO_TELEPORTE)
	case "tele":
		var _ti = timer_voo;
		var _azul = #6B9AC4, _menta = #90E8C0;
		var _ab = 6 + _ti * 2.5;
		gpu_set_blendmode(bm_add);
		draw_set_alpha(max(0, 1 - _ti / 10));
		draw_rectangle_colour(x - _ab, y_chao - 2, x + _ab, y_chao, _menta, _menta, c_white, c_white, false);
		draw_set_alpha(max(0, .6 - _ti / 14));
		draw_ellipse_colour(x - _ab * .8, y_chao - 4 - _ti * .3, x + _ab * .8, y_chao + 2, _menta, _azul, true);
		draw_set_color(_menta);
		for(var k = 0; k < 6; k++)
		{
			var _ang = 35 + k * 22;
			var _vel = 1.4 + (k mod 3) * .45;
			var _fx = x + lengthdir_x(_vel, _ang) * _ti;
			var _fy = y_chao - 1 + lengthdir_y(_vel, _ang) * _ti + .1 * _ti * _ti;
			draw_set_alpha(max(0, 1 - _ti / 16));
			draw_rectangle(_fx, _fy, _fx + 1, _fy + 1, false);
		}
		draw_set_alpha(1);
		draw_set_color(c_white);
		gpu_set_blendmode(bm_normal);
		break;

	//POEIRA
	case "poeira":
		draw_set_alpha(alpha);
		draw_set_color(#E8DCC8);
		draw_circle(x, y, esc, false);
		draw_set_alpha(1);
		draw_set_color(c_white);
		break;
	
	//MORTE DA IRMANDADE: MINI-BLOCO DA COR DO BLOCO
	case "estilhaco":
		draw_sprite_ext(spr_peca, frame, x, y, esc, esc, ang, c_white, alpha);
		break;

	//MODO TEXTO (E O RESTO): TEXTO COM SOMBRA
	default:
		draw_text_transformed_color(x + 1, y + 1, mensagem, esc, esc, 0, _sombra, _sombra, _sombra, _sombra, alpha);
		draw_text_transformed_color(x, y, mensagem, esc, esc, 0, cor, cor, cor, cor, alpha);
		break;
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
