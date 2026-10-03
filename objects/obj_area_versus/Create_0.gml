//ARENA DO MODO VERSUS (ARENA DO PLAYER 2) (CODIGO ANTIGO, QUASE IGUAL A ARENA DO ARCADE). A GRADE FICA NA GLOBAL.GRID_2
//DEPTH = 999;
//CRIANDO A BORDA
//VAR _MINHA_LINHA = INSTANCE_PLACE(X, Y, OBJ_LINHA);
//IF(_MINHA_LINHA) _MINHA_LINHA.X = X - CEL/2;

//TREMIDA DA TELA (SHAKES)
shake_intensity = 0;
shake_duration = 0;

minha_borda = instance_create_depth(x, y, -1000, obj_borda);
minha_borda.sprite_index = spr_borda;


cel = CEL;
//QUANTAS COLUNAS E LINHAS CABEM NA ARENA
cols = sprite_width div cel;
lins = sprite_height div cel;

//AQUI CONTROLO SE VOUQUERER QUE OS BLOCOS SSOMEM NA HUD
somar_blocos_hud = false;
//CAIXINHAS DO PLACAR DE BLOCOS POR COR (ENUM BLOCOS_CAIXA)
blocos_cx = [
				[0, 0, 0, 0, 0],
				[],
				[],
				[1, 1, 1, 1, 1],
				[0, 0, 0, 0, 0]
			];

//GRADE DA ARENA (-1 VAZIA, 1 OCUPADA, 2 LINHA SENDO DESTRUIDA)
global.grid_2 = ds_grid_create(cols, lins);
ds_grid_clear(global.grid_2, -1);

//POSIÇAO ORIGINAL (A TREMIDA MEXE NA ARENA)
pos_x = x;
pos_y = x;
meu_x = x;
meu_y = y;

//LIDANDO COM O PECA INST===========
peca_inst = noone;
//LIDANDO COM O PECA INST===========

//CRIANDO BLOCO
//ALARM[0] = ROOM_SPEED;

//FUNÇOES===========================
//EFEITO DE LINHA COMPLETA: _LINE = A LINHA DO ANDAR (UM EFEITO SO), SENAO UM EFEITO POR LINHA
efeito_line = function(_linha, _cont = 1, _line = false)
{
	//SHOW_MESSAGE("")
	//ESSE EFEITO FUNCIONA, POREM É UM EFEITO MAIS SIMPLES =============
		//_LINHA += 1;
	    //VAR _X_EFEITO = X + SPRITE_WIDTH/2;
	    //VAR _Y_EFEITO = (Y) + CEL * _LINHA;
		//_Y_EFEITO -= (CEL * _CONT) / 2;
	    //// CRIA A INSTÂNCIA NA LAYER DESEJADA (SUBSTITUA "LAYERNOME" PELO NOME REAL)
	    //VAR _EFEITO = INSTANCE_CREATE_LAYER(_X_EFEITO, _Y_EFEITO, "BLOCOS", OBJ_EFEITO_LINE);
	    //_EFEITO.ALT = CEL * _CONT;
	//ESSE EFEITO FUNCIONA, POREM É UM EFEITO MAIS SIMPLES =============
	
	//NOVO EFEITO INSPIRADO NO GUNNY ASSEND
		_linha += 1;
	    var _x_efeito = x + sprite_width/2;
	    var _y_efeito = (y) + CEL * _linha;
		_y_efeito -= (CEL * _cont) / 2;
		
	    // CRIA A INSTÂNCIA NA LAYER DESEJADA (SUBSTITUA "LAYERNOME" PELO NOME REAL)
	  if(_line)
	  {
		 var _efeito = instance_create_layer(_x_efeito, _y_efeito, "Blocos", obj_efeito_line);
	     _efeito.alt = CEL * _cont;
		 _efeito.qtd = _cont;
	     _efeito.meu_y = y + CEL*(_linha-1);
	     _efeito.minha_area = obj_area_versus;
		 _efeito.minha_linha = obj_linha_versus;
		 
	  }else
	  {
		for(var i = 0; i <  _cont; i++)
		{
			var _efeito = instance_create_layer(_x_efeito, _y_efeito, "Blocos", obj_efeito_line);
		    _efeito.alt = CEL * _cont;
		    _efeito.meu_y = (y + CEL*(_linha-1) - CEL*i);
			_efeito.line = false;
			_efeito.minha_area = obj_area_versus;
			_efeito.minha_linha = obj_linha_versus;
		}
	  }
	//NOVO EFEITO INSPIRADO NO GUNNY ASSEND
}


//CRIA A PROXIMA PEÇA NUMA COLUNA ALEATORIA (SE O TOPO ESTIVER LIVRE)
criar_bloco = function()
{
	var _tipo = irandom(tipo_peca.total-1);
	var _x = (x + cel/2) + (16*irandom(cols-1));
	var _y = (y + cel/2) - cel*2;
	
	var _area_de_criacao = collision_rectangle(x, y + cel, x + sprite_width, (y + cel) - cel*3, [obj_peca, obj_cria_peca], 0, 1);
	
	if(!_area_de_criacao) 
	{
		//VAR _CRIADOR = INSTANCE_CREATE_LAYER(_X, _Y, LAYER, OBJ_CRIA_PECA);
		//_CRIADOR.TIPO = _TIPO;
		 //_X = (X + CEL/2) + (16*5);
		var _criador = instance_create_layer(_x, _y, "Linha", obj_cria_peca);
	}
}

//MARCA A LINHA COMO SENDO DESTRUIDA NA GRADE (O OBJ_EFEITO_LINE QUE QUEBRA OS BLOCOS)
destroy_linha = function(_linha, _cont, _criar_line = false, _line = false)
{
	
	if(_criar_line)efeito_line(_linha, _cont, _line);
	
	for(var i = 0; i < cols; i++)
	{
		var _x = (x + CEL/2) + CEL*i;
		var _y = (y + CEL/2) + CEL*_linha;
		
		var _peca = collision_point(_x, _y, obj_peca, 0, 1);
		
		//ESSE ALARM TEM QUE LIGADO JUNTO COM A VELOCIDADE DA ANIMAÇAO LA NO OBJ_EFEITO_LINE PRA FICAR LEGAL
		//E O PROPRIO EFEITO LINE QUE DESTROI OS BLOCOS
		//IF(_PECA) IF(_PECA.ALARM[0] == -1) _PECA.ALARM[0] = 18 * (LINS - _LINHA);
		global.grid_2[# i, _linha] = 2;
		
		//IF(_PECA) INSTANCE_DESTROY(_PECA);
		//INSTANCE_CREATE_LAYER(_X, _Y, LAYER, OBJ_BLOCK);
	}
}

//PLACAR DE BLOCOS: SOMA UM NA CAIXINHA DA COR E DA UM "POP"
contagem_blocos = function(_tipo)
{
	//PEGANDO O BLOCOS
	blocos_cx[blocos_caixa.qtd][_tipo] ++;
	blocos_cx[blocos_caixa.esc][_tipo] = 1.25;
	blocos_cx[blocos_caixa.alpha][_tipo] = 1;
}




