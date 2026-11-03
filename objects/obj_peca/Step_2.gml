//END STEP DA PEÇA: AQUI ELA SE MOVE DE VERDADE E PARA QUANDO BATE.
//PAUSADO OU NO HITSTOP: NAO MEXE
if(global.pause_timer) exit;
if(pausa_em(x)) exit;

//O QUE PARA UMA PEÇA
var _obj = [obj_block, obj_peca, obj_mask_fa];

if(irmandade)
{
	//O GRUPO SE MOVE TODO JUNTO E SO O PAI MEXE NELE.
	//ANTES CADA BLOCO SE MOVIA NO PROPRIO END STEP: SE UM ANDASSE ANTES DO OUTRO PERCEBER A COLISAO,
	//O GRUPO SE SEPARAVA 0.7PX E A PEÇA FICAVA TORTA.
	if(!sou_pai) exit;
	if(pai == noone) exit;

	var _irmaos = irmaos();
	if(velv > 0)
	{
		//ALGUM BLOCO DO GRUPO VAI BATER?
		var _dist = max(1, velv);
		var _bater = false;
		for(var i = 0; i < array_length(_irmaos) and !_bater; i++)
		{
			with(_irmaos[i])
			{
				if(place_meeting(x, y + _dist, obj_block)) _bater = true;
				else
				{
					var _lista = ds_list_create();
					var _n = instance_place_list(x, y + _dist, obj_peca, _lista, false);
					for(var j = 0; j < _n; j++)
					{
						if(_lista[| j].pai != pai)
						{
							_bater = true;
							break;
						}
					}
					ds_list_destroy(_lista);
				}
			}
		}

		if(_bater)
		{
			controlando_velocidade(0, false);

			//ENCAIXA NA CELULA MAIS PERTO (SE ESTIVER OCUPADA, NA DE CIMA)
			var _alvo = grid_alinhar_y(y) - y;
			for(var i = 0; i < array_length(_irmaos); i++)
			{
				if(grid_celula_ocupada(_irmaos[i].x, _irmaos[i].y + _alvo, pai))
				{
					_alvo = grid_alinhar_y_cima(y) - y;
					break;
				}
			}
			for(var i = 0; i < array_length(_irmaos); i++)
			{
				//ATRIBUI O VALOR EXATO (SOMAR DEIXAVA ERRO DE PONTO FLUTUANTE, TIPO 264.00000000000006)
				_irmaos[i].y = grid_alinhar_y(_irmaos[i].y + _alvo);
				_irmaos[i].prox_y = _irmaos[i].y + CEL;
			}
		}
	}

	//MOVENDO O GRUPO: TODOS ANDAM EXATAMENTE O MESMO QUE O PAI
	var _dy = velv;
	for(var i = 0; i < array_length(_irmaos); i++)
	{
		_irmaos[i].x += _irmaos[i].velh;
		_irmaos[i].y += _dy;
	}
	
	//PEÇA CAINDO EM CIMA DO PLAYER: EMPURRA ELE PRA BAIXO (OU ESMAGA SE ELE TIVER PRENSADO)
	for(var i = 0; i < array_length(_irmaos); i++)
	{
		with(_irmaos[i]) empurrar_player();
	}
}
//BLOCO SOZINHO: MOVE E ENCOSTA PIXEL POR PIXEL (IGUAL AO PLAYER)
else
{
	var _velh = sign(velh);
	var _velv = sign(velv);

	//BATEU NA HORIZONTAL
	if(place_meeting(x + velh, y, _obj))
	{
		while (!place_meeting(x + _velh, y, _obj))
		{
			x += _velh;
		}
		velh = 0;
	}

	//BATEU NA VERTICAL
	if(place_meeting(x, y + velv, _obj))
	{
		while (!place_meeting(x, y + _velv, _obj))
		{
			y += _velv;
		}
		velv = 0;

		//PAROU ENCOSTADO: GARANTE QUE FICOU NA GRADE
		var _alvo = grid_alinhar_y(y);
		if(!grid_celula_ocupada(x, _alvo, pai)) y = _alvo;
		else y = grid_alinhar_y_cima(y);
		prox_y = y + CEL;
		
		//E PARA DE VERDADE (ANTES CONTINUAVA "ANDAR" E TENTAVA DESCER TODO FRAME: NUNCA VIRAVA PARADO,
		//NAO ENTRAVA NA GRADE E O BLOCO DE CIMA FICAVA ESPERANDO ELE PRA SEMPRE, NO AR)
		andar = false;
		timer_move = meu_timer;
	}

	//MOVE DE VERDADE
	x += velh;
	y += velv;
	
	//PEÇA CAINDO EM CIMA DO PLAYER: EMPURRA ELE PRA BAIXO (OU ESMAGA SE ELE TIVER PRENSADO)
	empurrar_player();
}
