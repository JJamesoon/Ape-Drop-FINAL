//FILA DE PEÇAS PRA TELEPORTAR==================================
//GLOBAL.PECA_INST		= PEÇA ATUAL (A QUE BRILHA E TELEPORTA NO ESPAÇO)
//GLOBAL.PROX_PECA_INT	= FILA COM AS PROXIMAS
//ANTES ESSA LOGICA ESTAVA COPIADA EM 4 LUGARES, CADA UMA UM POUCO DIFERENTE

//TIRA DA FILA AS PEÇAS QUE NAO EXISTEM MAIS
function fila_limpar()
{
	var _nova = [];
	for(var i = 0; i < array_length(global.prox_peca_int); i++)
	{
		var _p = global.prox_peca_int[i];
		if(instance_exists(_p) and _p != global.peca_inst) array_push(_nova, _p);
	}
	global.prox_peca_int = _nova;
}

//A PRIMEIRA DA FILA VIRA A PEÇA ATUAL
function fila_avancar()
{
	fila_limpar();
	if(array_length(global.prox_peca_int) > 0)
	{
		global.peca_inst = global.prox_peca_int[0];
		array_delete(global.prox_peca_int, 0, 1);
	}
	else global.peca_inst = noone;
}

//TIRA UMA PEÇA DA FILA (SE FOR A ATUAL, A PROXIMA ASSUME)
function fila_remover(_peca)
{
	//VERSUS: CADA ZONA TEM A SUA FILA
	if(room == rm_versus) { var _z = versus_zona_x(_peca.x); if(_z >= 0) fila_remover_zona(obj_area.zonas[_z], _peca); exit; }
	if(_peca == global.peca_inst)
	{
		fila_avancar();
		exit;
	}
	for(var i = array_length(global.prox_peca_int) - 1; i >= 0; i--)
	{
		if(global.prox_peca_int[i] == _peca) array_delete(global.prox_peca_int, i, 1);
	}
}

//COLOCA UMA PEÇA NOVA NA FILA (SE NAO TIVER ATUAL, ELA JA VIRA A ATUAL)
function fila_adicionar(_peca)
{
	//VERSUS: CADA ZONA TEM A SUA FILA
	if(room == rm_versus) { var _z = versus_zona_x(_peca.x); if(_z >= 0) fila_adicionar_zona(obj_area.zonas[_z], _peca); exit; }
	if(!instance_exists(global.peca_inst)) global.peca_inst = _peca;
	else array_push(global.prox_peca_int, _peca);
}

//TELEPORTA A PEÇA ATUAL E PASSA PRA PROXIMA (TECLA DE ACELERAR)
//TELEPORTA NA HORA: ANTES ERA NO FRAME SEGUINTE E, SE A PEÇA PARASSE NESSE MEIO TEMPO,
//A FILA JA TINHA ANDADO E QUEM TELEPORTAVA ERA A PROXIMA
function teleporte_acionar()
{
	fila_limpar();
	if(!instance_exists(global.peca_inst)) exit;
	
	with(global.peca_inst) teleportar_peca();
	fila_avancar();
	som_tocar(snd_acelerar_peca, .05);
	global.lerp_y = 5;
}
