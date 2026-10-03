//SO DESENHA COM A ARENA E VISIVEL. NO ALERTA MOSTRA SO O AVISO
if(!instance_exists(area) or alpha < .01) exit;
if(estado == "alerta") { desafio_alerta_desenhar(global.linguagem == 0 ? "ENCAIXE!" : "FIT IT!", timer, alpha, area); exit; }
if(estado != "puzzle" or !sprite_exists(spr)) exit;

//ESCALA DA GUI E O MEIO DA ARENA NA GUI
var _e = gui_esc();
var _cx = (area.x + area.sprite_width / 2) * _e;
var _cy = (area.y + area.sprite_height * .55) * _e;
var _a = alpha;

//PEÇA 3D (SPRITE STACKING). VOANDO PRO BURACO: ENCOLHE ATE O TAMANHO DELE E ACHATA
var _px = _cx, _py = _cy;
var _esc = 2.4 * _e * esc_entra * (1 + pop);
var _altura = .75;
if(voo >= 0)
{
	var _v = 1 - power(1 - voo / 14, 3);
	var _m = buraco_meio(alvo);
	_px = lerp(_cx, _m[0] * _e, _v);
	_py = lerp(_cy, _m[1] * _e, _v);
	_esc = lerp(_esc, ENC_BURACO / ENC_CELULA * _e, _v);
	_altura *= 1 - _v;
}
if(erro > 0) _px += random_range(-3, 3) * _e;
var _cor = erro > 0 ? c_red : c_white;
var _bal = voo < 0 ? sin(current_time / 450) * 6 : 0; //BALANÇO LEVE PRA LER COMO 3D (NAO MUDA A POSIÇAO DE VERDADE)
//CADA FATIA DO SPRITE E DESENHADA UM POUCO ACIMA DA OUTRA (REPETE PRA NAO FICAR BURACO ENTRE ELAS)
var _n = sprite_get_number(spr);
var _passo = _esc * _altura;
var _base = _py + _n * _passo * .5;
for(var i = 0; i < _n; i++)
{
	for(var k = 0; k < max(1, ceil(_passo)); k++)
	{
		draw_sprite_ext(spr, i, _px, _base - i * _passo - k, _esc * esc_x, _esc, ang + _bal, _cor, _a * (espera > 0 ? .5 : 1));
	}
}

//CONTROLES E PROGRESSO
draw_set_font(fnt_hud);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var _hy = _cy + 46 * _e;
var _t = 4 * _e;
var _ca = _a * (voo < 0 ? 1 : .4);
seta_desenhar(_cx - 52 * _e, _hy, 2, _t, c_white, _ca);
seta_desenhar(_cx - 38 * _e, _hy, 0, _t, c_white, _ca);
seta_desenhar(_cx, _hy, 1, _t, c_white, _ca);
seta_desenhar(_cx + 46 * _e, _hy, 3, _t, c_white, _ca);
var _nomes = global.linguagem == 0 ? ["GIRAR", "ESPELHAR", "ENCAIXAR"] : ["ROTATE", "MIRROR", "FIT"];
var _xs = [_cx - 45 * _e, _cx, _cx + 46 * _e];
for(var i = 0; i < 3; i++)
{
	draw_text_transformed_color(_xs[i] + _e * .5, _hy + 11 * _e + _e * .5, _nomes[i], _e * .55, _e * .55, 0, #0E071B, #0E071B, #0E071B, #0E071B, _ca);
	draw_text_transformed_color(_xs[i], _hy + 11 * _e, _nomes[i], _e * .55, _e * .55, 0, c_white, c_white, c_white, c_white, _ca);
}
//QUANTAS PEÇAS JA ENCAIXOU / TOTAL
var _txt = string(passo) + "/" + string(pecas_total);
draw_text_transformed_color(_cx + _e, _cy - 34 * _e + _e, _txt, _e, _e, 0, #0E071B, #0E071B, #0E071B, #0E071B, _a);
draw_text_transformed_color(_cx, _cy - 34 * _e, _txt, _e, _e, 0, c_white, c_white, c_white, c_white, _a);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
