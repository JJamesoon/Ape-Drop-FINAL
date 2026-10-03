//PAUSADO: A LETRA FICA PARADA
if(global.game_pause) exit;

//ENCOLHE ATE O TAMANHO NORMAL E SOME QUANDO O TEMPO ACABA
esc = lerp(esc, 1, .12);
timer--;
if(timer <= 0) instance_destroy();

var _p = player_perto(x, y); //NO COOP, O MAIS PERTO

//IMA: PUXA A LETRA PRO PLAYER
if(_p != noone and tem_poder("ima") and point_distance(x, y, _p.x, _p.y - 10) < IMA_RAIO)
{
	var _dir = point_direction(x, y, _p.x, _p.y - 10);
	x += lengthdir_x(3, _dir);
	y += lengthdir_y(3, _dir);
}
else if(velv < -.7)
{
	//SAINDO DO BLOCO: SOBE E VAI FREANDO
	y += velv;
	velv += .12;
}
else
{
	//ZIGUE-ZAGUE: ANDA NA DIAGONAL E BATE NAS BORDAS DA ARENA (DO TOPO ATE UM POUCO ACIMA DO CHAO)
	if(abs(velv) < .6) velv = .6 * sign(velv + .01);
	x += velh;
	y += velv;
	if(instance_exists(obj_area))
	{
		var _a = obj_area;
		if(x < _a.x + 10 or x > _a.x + _a.sprite_width - 10) { velh *= -1; x = clamp(x, _a.x + 10, _a.x + _a.sprite_width - 10); }
		if(y < _a.y + 20 or y > _a.y + _a.sprite_height - 24) { velv *= -1; y = clamp(y, _a.y + 20, _a.y + _a.sprite_height - 24); }
	}
}

//PEGOU
if(_p != noone and _p.estado != state.morte and point_distance(x, y, _p.x, _p.y - 10) < 14)
{
	letra_coletar(letra, x, y);
	instance_destroy();
}
