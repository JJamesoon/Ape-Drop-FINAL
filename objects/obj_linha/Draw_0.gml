//LINHA DOS ANDARES: UM FEIXE FINO ENTRE AS DUAS CAPSULAS, COM PULSOS DE ENERGIA CORRENDO.
//QUANDO SOBE DE ANDAR (MODIFICAR_RAIOS AUMENTA A INTENSIDADE) O MESMO FEIXE VIBRA EM ZIGUE-ZAGUE E VAI ACALMANDO
//TREME JUNTO COM A ARENA
var shake_x = global.shake_x;
var shake_y = global.shake_y + global.lerp_y;

//A VIBRAÇAO DE SUBIR DE ANDAR VAI ACALMANDO
intensidade = lerp(intensidade, 0, .05);

//FESTA DE SUBIR DE ANDAR (ATRAS DA REGUA): A TELA ESCURECE UM POUCO E FICA UM RASTRO DOURADO DE ONDE ELA SAIU ATE ONDE TA
var _festa = global.andar_pausa > 0;
var _fa = _festa ? min(1, global.andar_pausa / 20) * min(1, (ANDAR_PAUSA - global.andar_pausa) / 6) : 0; //ENTRA E SAI SUAVE
if(_festa)
{
	var _lx1 = x - 10, _lx2 = x + (instance_exists(minha_area) ? minha_area.sprite_width : 160) + 5;
	draw_set_alpha(.4 * _fa);
	draw_set_color(#0E071B);
	draw_rectangle(-10, -10, room_width + 10, room_height + 10, false);
	gpu_set_blendmode(bm_add);
	draw_set_alpha(.35 * _fa);
	draw_rectangle_color(_lx1 + shake_x, min(y_antigo, y) + shake_y, _lx2 + shake_x, max(y_antigo, y) + shake_y, #FFB21E, #FFB21E, #3A2000, #3A2000, false);
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);
	intensidade = max(intensidade, 10); //O FEIXE FICA VIBRANDO A FESTA TODA
}

//PONTAS DO FEIXE (CAPSULA DA ESQUERDA E DA DIREITA)
var _x1 = x - 10 + shake_x;
var _larg = instance_exists(minha_area) ? minha_area.sprite_width : sprite_get_width(spr_area); //LARGURA DA ARENA (A DO ARCADE E MAIS LARGA)
var _x2 = x + _larg + 5 + shake_x; //(ERA +18: A CAPSULA FICAVA EM CIMA DOS PAINEIS DA HUD)
var _yy = y + shake_y;
var _vib = min(1, intensidade / 12);			//0 CALMO, 1 VIBRANDO FORTE
var _pulso = .8 + .2 * sin(current_time / 250);

//PONTOS DO FEIXE (NO ZIGUE-ZAGUE OS PONTOS DO MEIO SOBEM E DESCEM; AS PONTAS FICAM NAS CAPSULAS)
var _n = 14;
var _px = array_create(_n + 1), _py = array_create(_n + 1);
for(var i = 0; i <= _n; i++)
{
	_px[i] = lerp(_x1, _x2, i / _n);
	_py[i] = _yy + ((i == 0 or i == _n) ? 0 : random_range(-6, 6) * _vib);
}

//BRILHO (MAIS FORTE VIBRANDO) E NUCLEO FINO
for(var i = 0; i < _n; i++)
{
	draw_set_alpha((.16 + .3 * _vib) * _pulso);
	draw_line_width_colour(_px[i], _py[i], _px[i + 1], _py[i + 1], 3 + 2 * _vib, #FFD84A, #FFD84A);
	draw_set_alpha(min(1, .7 * _pulso + .3 * _vib));
	draw_line_width_colour(_px[i], _py[i], _px[i + 1], _py[i + 1], 1, #FFF3B0, #FFF3B0);
}

//PULSOS DE ENERGIA CORRENDO (SO COM O FEIXE CALMO)
if(_vib < .3)
{
	var _larg = _x2 - _x1;
	draw_set_alpha(.9 * (1 - _vib / .3));
	for(var k = 0; k < 3; k++)
	{
		var _p = _x1 + ((current_time / 14 + k * _larg / 3) mod _larg);
		draw_line_width_colour(_p, _yy, min(_p + 8, _x2), _yy, 2, c_white, #FFD84A);
	}
}
draw_set_alpha(1);
draw_set_color(c_white);

//AS DUAS CAPSULAS NAS PONTAS
draw_sprite(spr_laser_cpsula, 0, x - 10 + shake_x, y + shake_y);
draw_sprite(spr_laser_cpsula, 1, _x2, y + shake_y);

//FAISCAS DOURADAS (NA FRENTE DA REGUA)
for(var i = 0; i < array_length(faiscas); i++)
{
	var _c = faiscas[i];
	var _v = _c[4] / 40;
	draw_set_alpha(min(1, _v * 2));
	draw_set_color(merge_color(#FF8A1E, #FFF3B0, _v));
	draw_rectangle(_c[0] - 1 + shake_x, _c[1] - 1 + shake_y, _c[0] + 1 + shake_x, _c[1] + 1 + shake_y, false);
}
draw_set_alpha(1);
draw_set_color(c_white);

//LETREIRO DO ANDAR NO MEIO DA ARENA: ENTRA GRANDE E ASSENTA COM UM PULINHO, BALANÇA E SOME NO FIM.
//EMBAIXO, O NOVO MULTIPLICADOR DE PONTOS
if(_festa and instance_exists(minha_area) and festa_titulo != "")
{
	var _p = 1 - global.andar_pausa / ANDAR_PAUSA;	//0 -> 1
	var _cx = minha_area.x + minha_area.sprite_width / 2 + shake_x;
	var _cy = minha_area.y + minha_area.sprite_height * .38 + shake_y;
	var _e = _p < .12 ? lerp(3.2, 2, _p / .12) : 2 + .12 * sin(_p * 28) * max(0, 1 - _p * 1.5);
	var _ang = sin(_p * 18) * 4 * max(0, 1 - _p * 2);
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _escuro = #3A1E08;
	for(var k = 0; k < 4; k++) draw_text_transformed_color(_cx + lengthdir_x(2, k * 90 + 45), _cy + lengthdir_y(2, k * 90 + 45), festa_titulo, _e, _e, _ang, _escuro, _escuro, _escuro, _escuro, _fa);
	draw_text_transformed_color(_cx, _cy, festa_titulo, _e, _e, _ang, #FFF3B0, #FFF3B0, #FFB21E, #FFB21E, _fa);
	//MULTIPLICADOR (APARECE UM POUQUINHO DEPOIS)
	if(_p > .2)
	{
		var _es = min(1.2, (_p - .2) * 8);
		var _sy = _cy + 22;
		draw_text_transformed_color(_cx + 1, _sy + 1, festa_sub, _es, _es, 0, _escuro, _escuro, _escuro, _escuro, _fa);
		draw_text_transformed_color(_cx, _sy, festa_sub, _es, _es, 0, #31FCFF, #31FCFF, #31FCFF, #31FCFF, _fa);
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
