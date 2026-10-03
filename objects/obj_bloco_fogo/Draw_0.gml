//TREME JUNTO COM A ARENA
var _sx = global.shake_x, _sy = global.shake_y + global.lerp_y;

//SENDO ENGOLIDO: O BLOCO DESCE GIRANDO E ENCOLHENDO PRO MEIO DO BURACO (FICANDO ROXO) E AS FAISCAS ROXAS SAO PUXADAS EM ESPIRAL
if(fase == "engolir")
{
	var _p = min(1, timer_fase / FOGO_ENGOLIR);
	var _yy = lerp(y_inicio, y_buraco, _p);
	var _e = 1 - _p * .9;
	gpu_set_blendmode(bm_add);
	draw_set_alpha(.6 * _p);
	draw_circle_color(x + _sx, y_buraco + _sy, 6 + 12 * _p, #9A5CFF, c_black, false);
	draw_set_alpha(1);
	gpu_set_blendmode(bm_normal);
	draw_sprite_ext(spr, img, x + _sx, _yy + _sy, _e, _e, _p * 540, c_white, 1);
	gpu_set_fog(true, #9A5CFF, 0, 1);
	draw_sprite_ext(spr, img, x + _sx, _yy + _sy, _e, _e, _p * 540, c_white, _p * .8);
	gpu_set_fog(false, c_white, 0, 1);
	for(var i = 0; i < 10; i++)
	{
		var _a = i * 36 + _p * 300;
		var _r = 22 * (1 - _p) + 2;
		var _fx = x + lengthdir_x(_r, _a), _fy = y_buraco + lengthdir_y(_r, _a);
		draw_set_alpha(.4 + .6 * _p);
		draw_set_color(i mod 2 ? #B07CFF : #E6D6FF);
		draw_rectangle(_fx - 1 + _sx, _fy - 1 + _sy, _fx + 1 + _sx, _fy + 1 + _sy, false);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
	exit;
}

//PORTAL NO TOPO: ABRE RAPIDO (ANEL ROXO COM O MEIO ESCURO), SOLTA FAISCAS PRA FORA E VAI SUMINDO ATE O BLOCO CAIR
if(aviso > 0)
{
	var _ab = min(1, timer_fase / FOGO_PORTAL);	//0 FECHADO, 1 ABERTO
	var _a = aviso / FOGO_AVISO;				//SOME AOS POUCOS
	var _r = 4 + 16 * _ab;
	gpu_set_blendmode(bm_add);
	draw_set_alpha(.55 * _a);
	draw_circle_color(x + _sx, y + _sy, _r + 8, #9A5CFF, c_black, false);
	draw_set_alpha(1);
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(.7 * _a);
	draw_set_color(#1A0F2E);
	draw_ellipse(x - _r + _sx, y - _r * .55 + _sy, x + _r + _sx, y + _r * .55 + _sy, false);
	draw_set_alpha(_a);
	draw_set_color(#B07CFF);
	draw_ellipse(x - _r + _sx, y - _r * .55 + _sy, x + _r + _sx, y + _r * .55 + _sy, true);
	draw_ellipse(x - _r - 1 + _sx, y - _r * .55 - 1 + _sy, x + _r + 1 + _sx, y + _r * .55 + 1 + _sy, true);
	draw_set_color(#E6D6FF);
	draw_ellipse(x - _r + 1 + _sx, y - _r * .55 + 1 + _sy, x + _r - 1 + _sx, y + _r * .55 - 1 + _sy, true);
	if(_ab < 1)
	{
		for(var i = 0; i < 10; i++)
		{
			var _fa = i * 36;
			var _fr = 6 + 30 * _ab;
			var _fx = x + lengthdir_x(_fr, _fa), _fy = y + lengthdir_y(_fr * .7, _fa);
			draw_set_alpha(1 - _ab);
			draw_set_color(i mod 2 ? #B07CFF : #E6D6FF);
			draw_rectangle(_fx - 1 + _sx, _fy - 1 + _sy, _fx + 1 + _sx, _fy + 1 + _sy, false);
		}
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
}

//AVISO: A COLUNA ONDE ELE VAI CAIR PISCA LARANJA ATE O CHAO
if(aviso > 0 and instance_exists(obj_area))
{
	draw_set_alpha(.18 + .17 * ((aviso div 4) mod 2));
	draw_set_color(#FF5A1A);
	draw_rectangle(x - 7 + _sx, y + _sy, x + 6 + _sx, obj_area.y + obj_area.sprite_height + _sy, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

//BRILHO LARANJA EM VOLTA (SOMANDO LUZ)
gpu_set_blendmode(bm_add);
draw_set_alpha(.45 + .1 * sin(current_time / 60));
draw_circle_color(x + _sx, y + _sy, 16, #FF6A1A, c_black, false);
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);

//FAISCAS (AMARELAS E GRANDES NASCENDO, VERMELHAS E PEQUENAS SUMINDO)
for(var i = 0; i < array_length(chamas); i++)
{
	var _c = chamas[i];
	var _v = _c[4] / 24;
	var _r = 1 + _v * 2.5;
	draw_set_alpha(min(1, _v * 1.6));
	draw_set_color(merge_color(#FF3A1A, #FFE04A, _v));
	draw_rectangle(_c[0] - _r + _sx, _c[1] - _r + _sy, _c[0] + _r + _sx, _c[1] + _r + _sy, false);
}
draw_set_alpha(1);
draw_set_color(c_white);

//O BLOCO, COM UM TOM LARANJA PULSANDO POR CIMA
draw_sprite_ext(spr, img, x + _sx, y + _sy, esc, esc, 0, c_white, 1);
gpu_set_fog(true, #FF6A1A, 0, 1);
draw_sprite_ext(spr, img, x + _sx, y + _sy, esc, esc, 0, c_white, .45 + .2 * sin(current_time / 50));
gpu_set_fog(false, c_white, 0, 1);
