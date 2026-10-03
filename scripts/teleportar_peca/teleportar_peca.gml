//TELEPORTA A PEÇA DIRETO PRA BAIXO (CHAMADO NO PAI DA PEÇA)
//
//COMO FUNCIONAVA ANTES (E POR QUE BUGAVA 1PX):
//	DESCIA DE 1 EM 1 PIXEL, PARAVA COM 8PX DE SOBRA E ARREDONDAVA CADA BLOCO SOZINHO.
//	SE A PEÇA DE BAIXO ESTIVESSE NO MEIO DA QUEDA, O ARREDONDAMENTO JOGAVA A PEÇA 1PX PRA DENTRO DELA.
//	E DEPOIS DO TELEPORTE A PEÇA CONTINUAVA COM A VELOCIDADE DA QUEDA QUE ESTAVA FAZENDO.
//
//COMO FUNCIONA AGORA:
//	1. ALINHA A PEÇA NA GRADE (ELA PODE ESTAR NO MEIO DE UMA QUEDA OU DE UM EMPURRAO)
//	2. DESCE CELULA POR CELULA, CHECANDO A CELULA INTEIRA DE CADA BLOCO (COM 1PX DE MARGEM)
//	3. COLOCA O GRUPO TODO JUNTO NA ULTIMA CELULA LIVRE, EXATAMENTE NA GRADE, E ZERA O MOVIMENTO
function teleportar_peca()
{
	//TODOS OS BLOCOS DA PEÇA E O PAI DELA
	var _irmaos = irmaos();
	if(array_length(_irmaos) == 0) exit;
	var _pai = pai;

	#region 1. ALINHANDO NA GRADE
	for(var i = 0; i < array_length(_irmaos); i++)
	{
		with(_irmaos[i])
		{
			esvaziar_grid();
			x = grid_alinhar_x(prox_x);	//SE TAVA SENDO EMPURRADA, TERMINA O EMPURRAO
			prox_x = x;
			y = grid_alinhar_y_cima(y);	//SE TAVA DESCENDO, VOLTA PRA CELULA DE ONDE SAIU (ELA TA LIVRE)
		}
	}
	#endregion

	#region 2. PROCURANDO ATE ONDE DA PRA DESCER
	var _queda = 0;
	var _max = 40; //SEGURANÇA: NUNCA DESCE MAIS QUE ISSO
	repeat(_max)
	{
		var _prox = _queda + CEL;
		var _livre = true;
		for(var i = 0; i < array_length(_irmaos); i++)
		{
			if(grid_celula_ocupada(_irmaos[i].x, _irmaos[i].y + _prox, _pai))
			{
				_livre = false;
				break;
			}
		}
		if(!_livre) break;
		_queda = _prox;
	}
	#endregion

	#region 3. COLOCANDO NA POSIÇAO FINAL
	var _area = escolhe_grid(, true);
	if(is_undefined(_area)) _area = instance_exists(obj_area) ? obj_area.id : noone;

	var _colunas = {}; //TOPO DE CADA COLUNA DA PEÇA ANTES DE CAIR (UM RASTRO SO POR COLUNA)
	var _fundos = {};  //Y DO BLOCO MAIS BAIXO DE CADA COLUNA (DEPOIS DE CAIR)
	for(var i = 0; i < array_length(_irmaos); i++)
	{
		with(_irmaos[i])
		{
			var _chave = string(x);
			if(!variable_struct_exists(_colunas, _chave) or y < _colunas[$ _chave]) _colunas[$ _chave] = y;
			inicializando = 0; //APARECE NA HORA (PEÇA RECEM CRIADA FICAVA INVISIVEL E SO O RASTRO APARECIA)
			y += _queda;
			if(!variable_struct_exists(_fundos, _chave) or y > _fundos[$ _chave]) _fundos[$ _chave] = y;
			prox_y = y + CEL;
			velv = 0;
			velh = 0;
			andar = false;
			timer_move = meu_timer;
			escorregar_player = 5; //SE CAIR EM CIMA DO PLAYER, ELE ESCORREGA PRA CIMA
		}
	}

	//RASTRO DO TELEPORTE: UM POR COLUNA, DO TOPO DA COLUNA ANTES ATE O TOPO DELA DEPOIS (NAO COBRE OS BLOCOS)
	//(ANTES CADA BLOCO SOLTAVA O SEU, COMEÇANDO NO MEIO DO BLOCO: NA PEÇA EM PE FICAVAM UNS EM CIMA DOS OUTROS)
	var _xs = variable_struct_get_names(_colunas);
	if(_queda > 0)
	{
		for(var i = 0; i < array_length(_xs); i++)
		{
			var _topo = _colunas[$ _xs[i]] - CEL/2;
			var _efeito = instance_create_depth(real(_xs[i]), _topo, _pai.depth - 100, obj_efeito_animacao);
			_efeito.sprite_index = spr_efeito_teleporte;
			_efeito.image_yscale = _queda / sprite_get_height(spr_efeito_teleporte);
		}
	}
	//EFEITO A MAIS: NO CHAO ONDE CADA COLUNA CAIU, UM CLARAO QUE ABRE PROS LADOS E FAÍSCAS (MODO "TELE" DO OBJ_EFEITO_PONTOS)
	for(var i = 0; i < array_length(_xs); i++)
	{
		var _impacto = instance_create_depth(real(_xs[i]), _fundos[$ _xs[i]] + CEL / 2, -1800, obj_efeito_pontos);
		_impacto.modo = "tele";
		_impacto.y_chao = _impacto.y;
	}
	#endregion

	//CRIANDO A PROXIMA PEÇA LOGO EM SEGUIDA
	if(_area != noone) _area.alarm[0] = 1;
}
