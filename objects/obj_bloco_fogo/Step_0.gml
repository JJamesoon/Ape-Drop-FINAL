//PAUSADO: O BLOCO FICA PARADO
if(global.game_pause) exit;
timer_fase++;

//SENDO ENGOLIDO (O DRAW FAZ O GIRO). ACABOU: VAI PRO TOPO DA ARENA, NA COLUNA DO PLAYER, E ABRE O PORTAL
if(fase == "engolir")
{
	if(timer_fase >= FOGO_ENGOLIR)
	{
		var _pl = player_perto(x, y);
		if(instance_exists(obj_area))
		{
			if(_pl != noone) x = clamp(grid_alinhar_x(_pl.x), obj_area.x + CEL / 2, obj_area.x + obj_area.sprite_width - CEL / 2);
			y = obj_area.y + CEL / 2;
		}
		fase = "portal";
		timer_fase = 0;
		esc = 0;
		aviso = FOGO_AVISO;
		audio_play_sound(snd_engolir, 1, false, .7, 0, 1.6); //O "PLOP" DO PORTAL ABRINDO
		shakes(3, 1);
	}
	exit;
}
esc = lerp(esc, 1, .15);

//FAISCAS DO FOGO SUBINDO (CAINDO, ELAS FICAM PRA TRAS E VIRAM UM RASTRO DE FOGO)
repeat(4) array_push(chamas, [x + random_range(-7, 7), y + random_range(-8, 6), random_range(-.35, .35), -random_range(.5, 1.8), irandom_range(10, 24)]);
for(var i = array_length(chamas) - 1; i >= 0; i--)
{
	chamas[i][0] += chamas[i][2];
	chamas[i][1] += chamas[i][3];
	chamas[i][4]--;
	if(chamas[i][4] <= 0) array_delete(chamas, i, 1);
}

//AVISO: FICA PARADO NO TOPO PISCANDO
if(aviso > 0)
{
	aviso--;
	exit;
}

//CAI DIRETO
y += FOGO_VEL;

//QUEBRA TODOS OS BLOCOS NO CAMINHO (NAO DAO PONTOS)
var _lista = ds_list_create();
var _n = instance_place_list(x, y, obj_peca, _lista, false);
var _quebrou = false;
for(var k = 0; k < _n; k++)
{
	with(_lista[| k])
	{
		if(destruido_por == noone)
		{
			destruido_por = "fogo";
			instance_destroy();
			_quebrou = true;
		}
	}
}
ds_list_destroy(_lista);
if(_quebrou)
{
	audio_play_sound(snd_peca_destroy, 1, false, .7, 0, .8 + random(.2));
	shakes(3, 1.5);
}

//INIMIGO NO CAMINHO MORRE TAMBEM
var _ini = instance_place(x, y, obj_inimigo);
if(_ini != noone and _ini.vivo()) _ini.morrer_nocaute(choose(-1, 1), false);

//ACERTOU O PLAYER: DANO
with(obj_player) if(estado != state.morte and place_meeting(x, y, other)) levar_dano(x < other.x ? -1 : 1);

//CHEGOU NO CHAO: EXPLODE E SOME
var _fundo = instance_exists(obj_area) ? obj_area.y + obj_area.sprite_height : room_height;
if(place_meeting(x, y + 1, obj_block) or bbox_top > _fundo)
{
	var _e = instance_create_depth(x, y, -1950, obj_efeito_animacao);
	_e.sprite_index = spr_explosao_bomb;
	_e.image_speed = 1.2;
	_e.image_xscale = 1.5;
	_e.image_yscale = 1.5;
	onda_choque(x, y, 50, 4, 20);
	shakes(8, 2);
	audio_play_sound(snd_explosao, 1, false, .55, 0, 1.2);
	instance_destroy();
}
