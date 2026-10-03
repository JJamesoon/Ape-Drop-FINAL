//PAUSADO: TUDO PARA
if(global.game_pause) exit;

//PROXIMO LASER: MIRA NA COLUNA ONDE UM PLAYER VIVO ESTA AGORA (NO COOP, UM DOS DOIS)
if(criados < qtd)
{
	espera--;
	if(espera <= 0)
	{
		criados++;
		espera = LASER_ESPACO;
		var _vivos = [];
		with(obj_player) if(estado != state.morte) array_push(_vivos, id);
		if(array_length(_vivos) > 0 and instance_exists(obj_area))
		{
			var _p = _vivos[irandom(array_length(_vivos) - 1)];
			var _a = obj_area;
			var _col = clamp((_p.x - _a.x) div CEL, 0, _a.cols - 1);
			array_push(lasers, { x : _a.x + CEL / 2 + CEL * _col, t : 0 });
			audio_play_sound(snd_laser_carga, 1, false, .6);
		}
	}
}

//CADA LASER: AVISO -> DISPARO (LIGADO POR LASER_ATIVO) -> SOME
for(var i = array_length(lasers) - 1; i >= 0; i--)
{
	var _l = lasers[i];
	_l.t++;
	if(_l.t == LASER_AVISO)
	{
		//DISPAROU: SOM, TREMIDA E ONDA DE CHOQUE NO CHAO
		audio_play_sound(snd_tiro_laser, 1, false, 1, 0, .7);
		som_tocar(zap1, .1);
		shakes(8, 2);
		if(instance_exists(obj_area)) onda_choque(_l.x, obj_area.y + obj_area.sprite_height, 40, 4, 18);
		calor_laser(_l.x - LASER_LARGURA / 2 - 5, _l.x + LASER_LARGURA / 2 + 5, LASER_ATIVO + 12); //AR QUENTE EM VOLTA DO FEIXE
	}
	if(_l.t >= LASER_AVISO) laser_queimar(_l.x);
	if(_l.t >= LASER_AVISO + LASER_ATIVO) array_delete(lasers, i, 1);
}

//ACABOU A ONDA
if(criados >= qtd and array_length(lasers) == 0) instance_destroy();
