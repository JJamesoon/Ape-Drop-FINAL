//A ROOM E EM PE (405X720). A CAMERA PODE MOSTRAR UM POUCO ALEM DELA, ENTAO O FUNDO COBRE A CAMERA INTEIRA
var _m = global.mob;
var _cx = room_width / 2;
var _sombra = #0E071B;

//FUNDO (O MESMO DO MENU DO PC, AMPLIADO PRA COBRIR A TELA EM PE)
var _esc = max(_m.cw / sprite_get_width(spr_menu_fundo), _m.ch / sprite_get_height(spr_menu_fundo));
var _fy = _m.cy + _m.ch / 2 - (sprite_get_height(spr_menu_fundo) / 2 - sprite_get_yoffset(spr_menu_fundo)) * _esc;
draw_sprite_ext(spr_menu_fundo, 0, _m.cx + _m.cw / 2, _fy, _esc, _esc, 0, c_white, 1);

//TITULO BALANÇANDO
var _ang = sin(timer) * 1.8;
draw_sprite_ext(spr_bg_ape, 0, _cx + 1, y_titulo + 1, 1.5, 1.5, _ang, _sombra, 1);
draw_sprite_ext(spr_bg_ape, 0, _cx, y_titulo, 1.5, 1.5, _ang, c_white, 1);

//PERSONAGEM ESCOLHIDO PARADO NO MEIO
var _spr = skin_sprite(global.skin_player_1, spr_player_idle);
draw_sprite_ext(_spr, get_timer() / 120000, _cx, room_height * .56, 4, 4, 0, c_white, 1);

//TEXTOS CENTRALIZADOS
draw_set_font(fnt_hud);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

//RECORDE
var _rec = texto("recorde") + ": " + string(global.record_1);
draw_text_transformed_color(_cx + 1, room_height * .36 + 1, _rec, 1.3, 1.3, 0, _sombra, _sombra, _sombra, _sombra, 1);
draw_text_transformed_color(_cx, room_height * .36, _rec, 1.3, 1.3, 0, #FFE600, #FFE600, #FFE600, #FFE600, 1);

//"TOQUE PRA JOGAR" PISCANDO
var _a = clamp(sin(timer * 1.7) + .75, 0, 1);
var _txt = texto("toque_jogar");
draw_text_transformed_color(_cx + 1, room_height * .76 + 1, _txt, 1.8, 1.8, 0, _sombra, _sombra, _sombra, _sombra, _a);
draw_text_transformed_color(_cx, room_height * .76, _txt, 1.8, 1.8, 0, c_white, c_white, c_white, c_white, _a);

//FEITO POR (EMBAIXO) E VERSAO
draw_sprite_ext(spr_bg_made_in, 0, _cx + 1, room_height - 14 + 1, 1.2, 1.2, 0, _sombra, 1);
draw_sprite_ext(spr_bg_made_in, 0, _cx, room_height - 14, 1.2, 1.2, 0, c_white, 1);
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
draw_text_color(5, room_height - 3, "V1.0.0", #C7CFDD, #C7CFDD, #C7CFDD, #C7CFDD, 1);

//VOLTA O PADRAO DE DESENHO
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
