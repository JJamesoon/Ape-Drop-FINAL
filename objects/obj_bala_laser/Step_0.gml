//PAUSADO: A BALA FICA PARADA
if(pausa_em(x)) exit;

//ACELERA SUAVE ATE A VELOCIDADE
velh = lerp(velh, vel, .2);
velv = lerp(velv, vel, .2);

//PODER DO REFLEXO: QUANDO A BALA VAI ACERTAR, O PLAYER DA UM MORTAL E REBATE ELA.
//A BALA REBATIDA ESCOLHE UM BLOCO PRA QUEBRAR: REFLEXO_VOLTA % DE CHANCE DE SER O PROPRIO LASER QUE ATIROU
var _p = player_perto(x, y); //NO COOP, QUEM TA MAIS PERTO DA BALA
if(!refletida and _p != noone)
{
	if(_p.estado != state.morte and tem_poder("reflexo", _p.jogador) and _p.reflexo_energia >= REFLEXO_CUSTO and point_distance(x, y, _p.x, _p.y - 10) < 24)
	{
		_p.reflexo_energia -= REFLEXO_CUSTO;
		_p.esquivar();
		refletida = true;
		if(random(100) < REFLEXO_VOLTA and instance_exists(pai)) alvo = pai;
		else
		{
			var _blocos = [];
			with(obj_peca) if(id != other.pai and destruido_por == noone and y > 40) array_push(_blocos, id);
			if(array_length(_blocos) > 0) alvo = _blocos[irandom(array_length(_blocos) - 1)];
			else if(instance_exists(pai)) alvo = pai;
		}
		if(!instance_exists(alvo)) image_angle += 180;
		vel = 7;
		velh = 7;
		velv = 7;
	}
}

//REBATIDA: VAI ATRAS DO BLOCO ESCOLHIDO (ELE PODE ESTAR CAINDO)
if(refletida and instance_exists(alvo)) image_angle = point_direction(x, y, alvo.x, alvo.y);

//ANDA NA DIREÇAO DO ANGULO
x += lengthdir_x(velh, image_angle);
y += lengthdir_y(velv, image_angle);

//ACERTOU O BLOCO ESCOLHIDO: QUEBRA ELE (CONTA COMO SE O PLAYER TIVESSE QUEBRADO)
if(refletida and instance_exists(alvo) and place_meeting(x, y, alvo))
{
	with(alvo)
	{
		destruido_por = "player";
		instance_destroy();
	}
	var _anel = instance_create_depth(x, y, -1900, obj_efeito_pontos);
	_anel.modo = "anel";
	_anel.timer = 14;
	instance_destroy();
	exit;
}

//LASER LATERAL: O PRIMEIRO BLOCO QUE ENCOSTAR QUEBRA (E A BALA SOME)
if(lateral and !refletida)
{
	var _b = noone;
	with(obj_peca) if(id != other.pai and destruido_por == noone and !sou_fantasma and place_meeting(x, y, other.id)) { _b = id; break; }
	if(_b != noone)
	{
		with(_b) { destruido_por = "laser"; instance_destroy(); }
		var _anel = instance_create_depth(x, y, -1900, obj_efeito_pontos);
		_anel.modo = "anel";
		_anel.timer = 12;
		shakes(4, 1);
		instance_destroy();
		exit;
	}
}

//SAIU DA TELA
if(x < -20 or x > room_width + 20 or y < -20 or y > room_height + 20) instance_destroy();
