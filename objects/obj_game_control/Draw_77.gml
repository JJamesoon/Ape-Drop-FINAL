//POST DRAW: DESENHA A TELA DO JOGO COM O SHADER DA ONDA DE CHOQUE
//(O DESENHO AUTOMATICO DA APPLICATION_SURFACE FICA DESLIGADO NESSA ROOM: VER CREATE E ROOM END)
//ONDE A TELA DO JOGO FICA NA JANELA
var _pos = application_get_position();
var _w = _pos[2] - _pos[0];
var _h = _pos[3] - _pos[1];

//AVANÇA AS ONDAS E TIRA AS QUE ACABARAM
for(var i = array_length(global.ondas_choque) - 1; i >= 0; i--)
{
	global.ondas_choque[i].t++;
	if(global.ondas_choque[i].t >= global.ondas_choque[i].dur) array_delete(global.ondas_choque, i, 1);
}

//AVANÇA O CALOR DOS LASERS E TIRA O QUE ACABOU
for(var i = array_length(global.calor) - 1; i >= 0; i--)
{
	global.calor[i].t++;
	if(global.calor[i].t >= global.calor[i].dur) array_delete(global.calor, i, 1);
}

//BLOCO RAIO: OS OBJETOS VAO FICANDO AQUA (NOS ULTIMOS 2S PISCA AVISANDO QUE VAI ACABAR). QUEM PINTA E O AQUA_INICIO
var _alvo = 0;
if(global.raio > 0) _alvo = (global.raio < room_speed * 2 and (global.raio div 8) mod 2 == 0) ? .4 : 1;
global.raio_mix = lerp(global.raio_mix, _alvo, .15);
if(global.raio_mix < .01) global.raio_mix = 0;

//TEMPO PARADO: A TELA VAI FICANDO VERDE (E VOLTA DEPOIS DA QUEDA)
global.tempo_vis = lerp(global.tempo_vis, (global.tempo_fase == "parado" or global.tempo_fase == "contagem") ? 1 : 0, .08);
if(global.tempo_vis < .01) global.tempo_vis = 0;

//SEM ONDA, SEM CALOR E SEM TEMPO PARADO: DESENHA A TELA NORMAL
var _n = array_length(global.ondas_choque);
var _nc = array_length(global.calor);
if(_n == 0 and _nc == 0 and global.tempo_vis <= 0)
{
	draw_surface_stretched(application_surface, _pos[0], _pos[1], _w, _h);
	exit;
}

//COM ONDA: MANDA PRO SHADER O CENTRO (0-1 NA TELA), O RAIO E A FORÇA DE CADA UMA (ATE 4)
var _sw = surface_get_width(application_surface);
var _sh = surface_get_height(application_surface);
var _esc = _sw / global.mob.cw;
var _dados = array_create(16, 0);
for(var i = 0; i < _n; i++)
{
	var _o = global.ondas_choque[i];
	var _p = _o.t / _o.dur;
	_dados[i * 4]		= (_o.x - global.mob.cx) / global.mob.cw;
	_dados[i * 4 + 1]	= (_o.y - global.mob.cy) / global.mob.ch;
	_dados[i * 4 + 2]	= _o.raio * (1 - power(1 - _p, 3)) * _esc;	//CRESCE RAPIDO E VAI FREANDO
	_dados[i * 4 + 3]	= _o.forca * (1 - _p) * _esc;				//E VAI ENFRAQUECENDO
}
//CALOR: RETANGULO DE CADA LASER (0-1 NA TELA) E A FAIXA QUE DESCE (VAI ENFRAQUECENDO NO FIM)
var _calor = array_create(12, 0);
var _info = array_create(12, 0);
var _chao = instance_exists(obj_area) ? obj_area.y + obj_area.sprite_height : global.mob.cy + global.mob.ch;
for(var i = 0; i < _nc; i++)
{
	var _c = global.calor[i];
	_calor[i * 4]		= (_c.x1 - global.mob.cx) / global.mob.cw;
	_calor[i * 4 + 1]	= 0;
	_calor[i * 4 + 2]	= (_c.x2 - global.mob.cx) / global.mob.cw;
	_calor[i * 4 + 3]	= (_chao - global.mob.cy) / global.mob.ch;
	_info[i * 4]		= frac(_c.t / CALOR_PASSADA);
	_info[i * 4 + 1]	= CALOR_FORCA * sqrt(1 - _c.t / _c.dur) * _esc;
	_info[i * 4 + 2]	= _c.t;
	_info[i * 4 + 3]	= CALOR_FAIXA * _esc;
}
//DESENHA A TELA PASSANDO PELO SHADER
shader_set(sh_onda_choque);
shader_set_uniform_f(u_onda_tela, _sw, _sh);
shader_set_uniform_f_array(u_onda_dados, _dados);
shader_set_uniform_f(u_onda_largura, ONDA_CHOQUE_LARGURA * _esc);
shader_set_uniform_f_array(u_calor, _calor);
shader_set_uniform_f_array(u_calor_info, _info);
//TEMPO PARADO: O ANEL DO RELOGIO SAI DE ONDE O TEMPO PAROU, UM A CADA ~1.3S
var _raio_anel = (global.tempo_t * 6) mod 480;
shader_set_uniform_f(u_parado, global.tempo_vis);
shader_set_uniform_f(u_parado_info, (global.tempo_cx - global.mob.cx) / global.mob.cw, (global.tempo_cy - global.mob.cy) / global.mob.ch, _raio_anel * _esc, 10 * _esc);
draw_surface_stretched(application_surface, _pos[0], _pos[1], _w, _h);
shader_reset();

//TEMPO PARADO: O PLAYER CONTINUA COLORIDO (DESENHADO DE NOVO POR CIMA DA TELA VERDE) COM UMA AURA CLARA EM VOLTA
if(global.tempo_vis > .02)
{
	var _ej = _w / global.mob.cw;
	with(obj_player) if(estado != state.morte)
	{
		var _sx = _pos[0] + (x - global.mob.cx) * _ej, _sy = _pos[1] + (y - global.mob.cy) * _ej;
		var _pulso = 1.1 + .05 * sin(current_time / 90);
		gpu_set_fog(true, #C8FFDC, 0, 1);
		draw_sprite_ext(sprite_index, image_index, _sx, _sy, esc_x * _ej * _pulso, esc_y * _ej * _pulso, 0, c_white, .35 * global.tempo_vis);
		gpu_set_fog(false, c_white, 0, 1);
		draw_sprite_ext(sprite_index, image_index, _sx, _sy, esc_x * _ej, esc_y * _ej, 0, c_white, global.tempo_vis);
	}
}
