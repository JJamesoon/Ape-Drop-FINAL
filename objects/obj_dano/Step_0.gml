//SOCO DO PLAYER: EMPURRA O BLOCO QUE ACERTAR
//O BLOCO FANTASMA NAO E AFETADO PELO SOCO (SO O GIRO QUEBRA ELE)

//INIMIGO: O SOCO MATA
var _inimigo = instance_place(x, y, obj_inimigo);
if(_inimigo != noone and _inimigo.vivo())
{
	som_tocar(snd_hit, .1);
	soco_efeito(_inimigo.x, _inimigo.y);
	_inimigo.morrer_nocaute(sign(image_xscale), true);
	instance_destroy();
	exit;
}

//SOCO ESPIRITUAL: ACERTA O INIMIGO ATE 3 CASAS PRA FRENTE, MESMO COM BLOCO NO MEIO
if(espiritual)
{
	var _longe = collision_line(x, y, x + sign(image_xscale) * CEL * 3, y, obj_inimigo, false, true);
	if(_longe != noone and _longe.vivo())
	{
		som_tocar(snd_hit, .1);
		_longe.morrer_nocaute(sign(image_xscale), true);
	}
}

//PROCURA O PRIMEIRO BLOCO QUE O SOCO ACERTOU (O FANTASMA SO CONTA NO SOCO ESPIRITUAL)
var _peca = noone;
var _lista = ds_list_create();
var _n = instance_place_list(x, y, obj_peca, _lista, false);
for(var k = 0; k < _n; k++)
{
	if(!_lista[| k].sou_fantasma or espiritual)
	{
		_peca = _lista[| k];
		break;
	}
}
ds_list_destroy(_lista);

if(_peca)
{
	//SOM DE PANCADA SO QUANDO ACERTA UM BLOCO DE VERDADE
	som_tocar(snd_hit, .1);
	soco_efeito(_peca.x - sign(image_xscale) * 8, _peca.y);

	//SOCO ESPIRITUAL: TIRA A LETRA DE DENTRO DO BLOCO E DESARMA O BLOCO SENSOR
	if(espiritual)
	{
		if(_peca.letra >= 0)
		{
			letra_criar(_peca.x, _peca.y, _peca.letra, true);
			_peca.letra = -1;
		}
		if(_peca.sou_sensor)
		{
			_peca.sou_sensor = false;
			_peca.sou_normal = true;
			_peca.sensor_timer = -1;
			_peca.alpha_fog = 1;
		}
	}

	//SOCO FRACO (FALHOU): O BLOCO SO PISCA E INCHA
	if(soco_fail)
	{
		_peca.alpha_fog = 1;
		_peca.esc = 1.2;
	}
	else _peca.velocidade_h(sign(image_xscale), super); //A HITBOX E ESTICADA (SOCO_ALCANCE): SO O LADO IMPORTA

	//O SOCO SO ACERTA UMA VEZ
	instance_destroy();
}
