//FUNDO PRETO (DA ROOM) E A LOGO DA VEZ, APARECENDO E SUMINDO
var _cx = room_width / 2, _cy = room_height / 2;
var _d = fases[fase];
var _a = clamp(min(timer / INTRO_FADE, (_d - timer) / INTRO_FADE), 0, 1);
//ENTRADA COM UM "POP" (PASSA UM POUCO DO TAMANHO E VOLTA)
var _p = clamp(timer / 24, 0, 1);
var _pop = 1 + 2.2 * power(_p - 1, 3) + 1.2 * power(_p - 1, 2);
draw_set_font(fnt_hud);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

switch(fase)
{
	//LOGO DO JOGO
	case 0:
		var _e = .5 * (.6 + .4 * _pop);
		draw_sprite_ext(spr_intro_ape_drop_1, 0, _cx, _cy + sin(current_time / 400) * 2, _e, _e, 0, c_white, _a);
		break;

	//GAMEMAKER
	case 1:
		draw_text_transformed_color(_cx, _cy - 52, global.linguagem == 0 ? "FEITO COM" : "MADE WITH", 1, 1, 0, #C7CFDD, #C7CFDD, #C7CFDD, #C7CFDD, _a);
		draw_sprite_ext(spr_intro_gm, 0, _cx, _cy + 8, .42 * (.8 + .2 * _pop), .42 * (.8 + .2 * _pop), 0, c_white, _a);
		break;

	//CANARY TEAM
	case 2:
		draw_text_transformed_color(_cx, _cy - 120, global.linguagem == 0 ? "UM JOGO DESENVOLVIDO POR" : "A GAME DEVELOPED BY", 1, 1, 0, #C7CFDD, #C7CFDD, #C7CFDD, #C7CFDD, _a);
		draw_sprite_ext(spr_intro_cnry, 0, _cx, _cy - 4, .36 * (.8 + .2 * _pop), .36 * (.8 + .2 * _pop), 0, c_white, _a);
		draw_text_transformed_color(_cx, _cy + 112, "CANARY TEAM", 1.8, 1.8, 0, c_white, c_white, c_white, c_white, _a);
		break;
}

//DICA PRA PULAR
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
var _dica = global.linguagem == 0 ? "ESPAÇO: PULAR" : "SPACE: SKIP";
draw_text_transformed_color(room_width - 8, room_height - 6, _dica, .6, .6, 0, #657392, #657392, #657392, #657392, .8);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
