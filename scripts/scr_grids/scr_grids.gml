//GRADE DAS ARENAS==================================
//A ARENA COMEÇA EM UMA POSIÇAO ONDE O CENTRO DAS CELULAS FICA EM:
//	X = MULTIPLO DE 16		Y = MULTIPLO DE 16 + 8
//(ARENA DO ARCADE EM X = 280, Y = 48, 10 COLUNAS). TODO BLOCO PARADO TEM QUE ESTAR EXATAMENTE NESSES PONTOS.

//CENTRO DE CELULA MAIS PERTO
function grid_alinhar_y(_y)
{
	return round((_y - CEL/2) / CEL) * CEL + CEL/2;
}
//COLUNA MAIS PERTO (X MULTIPLO DE 16)
function grid_alinhar_x(_x)
{
	return round(_x / CEL) * CEL;
}

//CENTRO DE CELULA ACIMA (OU O MESMO, SE JA ESTIVER ALINHADO)
//USADO QUANDO UMA PEÇA QUE TAVA DESCENDO PARA NO MEIO DO CAMINHO: A CELULA DE CIMA TA SEMPRE LIVRE
function grid_alinhar_y_cima(_y)
{
	return floor((_y - CEL/2 + .5) / CEL) * CEL + CEL/2;
}

//TEM ALGO SOLIDO NESSA CELULA? (IGNORA AS PEÇAS DO MESMO GRUPO)
//USA UM RETANGULO 1PX MENOR QUE A CELULA, ENTAO NAO ERRA POR CAUSA DE 1PX
function grid_celula_ocupada(_x, _y, _pai = noone)
{
	var _x1 = _x - CEL/2 + 1;
	var _y1 = _y - CEL/2 + 1;
	var _x2 = _x + CEL/2 - 2;
	var _y2 = _y + CEL/2 - 2;

	//PAREDE OU BLOCO PARADO OCUPA
	if(collision_rectangle(_x1, _y1, _x2, _y2, [obj_block, obj_parede], false, true)) return true;

	//PEÇA OCUPA SE NAO FOR DO MESMO GRUPO
	var _lista = ds_list_create();
	var _n = collision_rectangle_list(_x1, _y1, _x2, _y2, obj_peca, false, true, _lista, false);
	var _ocupada = false;
	for(var i = 0; i < _n; i++)
	{
		var _p = _lista[| i];
		if(_pai == noone or _p.pai != _pai)
		{
			_ocupada = true;
			break;
		}
	}
	ds_list_destroy(_lista);
	return _ocupada;
}

//MARCA A CASA DESSE BLOCO COMO OCUPADA NA GRADE (SO SE ELE NAO ESTIVER DESCENDO)
function preencher_grid()
{
	if(andar) exit;

	var _grid = escolhe_grid(true);
	var _area = escolhe_grid(, true);
	if(is_undefined(_grid) or is_undefined(_area)) exit; //FORA DA ARENA

	//COLUNA E LINHA DA GRADE ONDE O BLOCO ESTA
	var _x = (x - _area.x) div CEL;
	var _y = (y - _area.y) div CEL;
	if(_x < 0 or _y < 0 or _x >= ds_grid_width(_grid) or _y >= ds_grid_height(_grid)) exit;

	//CELULA VAZIA
	if(_grid[# _x, _y] == -1) _grid[# _x, _y] = 1;
}

//TIRA O BLOCO DA GRADE (A CASA FICA VAZIA)
function esvaziar_grid()
{
	var _grid = escolhe_grid(true);
	var _area = escolhe_grid(, true);
	if(is_undefined(_grid) or is_undefined(_area)) exit; //FORA DA ARENA

	var _x = (x - _area.x) div CEL;
	var _y = (y - _area.y) div CEL;
	if(_x < 0 or _y < 0 or _x >= ds_grid_width(_grid) or _y >= ds_grid_height(_grid)) exit;

	//CELULA COM VALOR
	if(_grid[# _x, _y] == 1 or _grid[# _x, _y] == 2) _grid[# _x, _y] = -1;
}

//DESCOBRE EM QUAL ARENA O BLOCO ESTA E RETORNA A GRID, A ARENA OU A LINHA DELA
//FORA DE TODAS AS ARENAS RETORNA UNDEFINED (NAO USAR FALSE: O GLOBAL.GRID E O GRID 0, E 0 == FALSE NO GML)
function escolhe_grid(_grid = false, _area = false, _line = false)
{
	var _x = x;
	var _y = y;

	if(instance_exists(obj_area) and position_meeting(_x, _y, obj_area))
	{
		if(_area) return instance_position(_x, _y, obj_area);
		if(_grid) return global.grid;
		if(_line) return obj_linha;
	}
	else if(instance_exists(obj_area_versus) and position_meeting(_x, _y, obj_area_versus))
	{
		if(_area) return instance_position(_x, _y, obj_area_versus);
		if(_grid) return global.grid_2;
		if(_line) return obj_linha_versus;
	}
	else if(instance_exists(obj_area_coop) and position_meeting(_x, _y, obj_area_coop))
	{
		if(_area) return instance_position(_x, _y, obj_area_coop);
		if(_grid) return global.grid_2;
		if(_line) return obj_linha_coop;
	}
	return undefined;
}

//PROFUNDIDADE (QUEM FICA NA FRENTE) DOS BLOCOS E DO PLAYER: QUEM TA MAIS EM CIMA FICA NA FRENTE DE QUEM TA EMBAIXO E,
//NA MESMA LINHA, QUEM TA MAIS PRA DIREITA FICA NA FRENTE.
//TEM QUE SER NUMERO INTEIRO: O GAMEMAKER DESENHA POR CAMADA E A CAMADA E INTEIRA (-71.6 E -71.2 CAIAM NA MESMA E QUEM
//FICAVA NA FRENTE SAIA SORTEADO). CADA COLUNA VALE 1 E CADA LINHA VALE 16, ENTAO AS 10 COLUNAS NUNCA ALCANÇAM A LINHA
//DE CIMA (NAO EMPATA NA DIAGONAL). _Y = O MEIO DA CELULA. FAIXA: NA FRENTE DO CHAO, ATRAS DOS EFEITOS
function profundidade(_x, _y)
{
	return round(_y) - 424 - round(_x / CEL);
}

//CONSERTA A GRADE DA ARENA DO ARCADE/COOP COMPARANDO COM OS BLOCOS PARADOS DE VERDADE (CHAMADO PELO OBJ_AREA DE TEMPOS EM TEMPOS).
//SE ALGUMA CASA FICAR ERRADA (VAZIA COM BLOCO PARADO EM CIMA, OU PRESA EM 2 DEPOIS QUE A LINHA JA FOI LIMPA), A LINHA CHEIA
//NUNCA FECHAVA. SO MEXE QUANDO NAO TEM LINHA SENDO LIMPA. DEVOLVE QUANTAS CASAS CONSERTOU
function grid_reparar(_area)
{
	if(instance_exists(obj_efeito_line)) return 0;
	var _consertos = 0;
	for(var j = 0; j < _area.lins; j++)
	{
		for(var i = 0; i < _area.cols; i++)
		{
			var _cx = _area.x + CEL / 2 + CEL * i, _cy = _area.y + CEL / 2 + CEL * j;
			var _b = collision_point(_cx, _cy, obj_peca, false, true);
			//BLOCO PARADO E ENCAIXADO NA CASA (NAO CAINDO, NAO SENDO EMPURRADO, NAO QUICANDO NA GELATINA, NAO MORRENDO)
			var _parado = _b != noone and _b.estou_parado and !_b.andar and _b.velv == 0 and _b.x == _b.prox_x
				and abs(_b.x - _cx) < .5 and abs(_b.y - _cy) < .5 and _b.destruido_por == noone and !_b.gel_quicando;
			var _v = global.grid[# i, j];
			if(_parado and _v != 1)				{ global.grid[# i, j] = 1; _consertos++; }
			else if(_b == noone and _v == 2)	{ global.grid[# i, j] = -1; _consertos++; }
		}
	}
	return _consertos;
}