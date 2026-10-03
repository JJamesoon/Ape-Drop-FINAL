//TESTE AUTOMATICO - SO EXISTE COM A MACRO TESTE_AUTO LIGADA (SCRIPT GLOBAIS)
//TESTA: SORTEIO DO FANTASMA/INIMIGO, PEÇAS COM BLOCOS FANTASMA, INIMIGO PRESO VIRANDO BLOCO E O RETRATO DO HUD
//O RESULTADO SAI NO OUTPUT (LINHAS COM [TESTE]) E OS PRINTS VAO PRA %LOCALAPPDATA%\APEDROP_FINAL
timer = 0;
show_debug_message("[TESTE] inicio");

//ESTADO DO TESTE (CADA ETAPA USA ALGUMAS DESSAS VARIAVEIS PRA GUARDAR O QUE VIU)
marca = 0;			//FRAME DE REFERENCIA DE CADA ETAPA
etapa = "sorteio";
inimigo = noone;
pontos_antes = 0;
viradas = 0;
dir_antes = 0;
viu_preso = false;
peca_t = noone;
peca_o = noone;
x_antes = 0;
passou = 0;

//CRIA UMA PEÇA DE TESTE: TIPO, COLUNA DA ARENA, COR, ESPECIE E QUANTOS BLOCOS FANTASMA
criar = function(_tipo, _col, _cor = cores.c_green, _especie = "normal", _fantasmas = 0)
{
	global.prox_tipo = _tipo;
	global.prox_cor = _cor;
	global.prox_especie = _especie;
	global.prox_fantasmas = _fantasmas;
	instance_create_layer(288 + 16 * _col, 24, "Linha", obj_cria_peca);
}

//ESCREVE NO OUTPUT COM [TESTE] NA FRENTE
log = function(_s)
{
	show_debug_message("[TESTE] " + _s);
}

//PLAYER LONGE (NAO ATRAPALHA)
player_longe = function()
{
	with(obj_player) { x = -200; y = 100; velh = 0; velv = 0; estado = state.idle; imune = 0; }
}

//PLAYER EM PE NO CHAO NA POSIÇAO X
player_em = function(_x)
{
	with(obj_player) { x = _x; y = 352; velh = 0; velv = 0; estado = state.idle; imune = 0; }
}

//BLOCOS DE UMA PEÇA (PELO PAI)
blocos_de = function(_pai)
{
	var _r = [];
	with(obj_peca) if(pai == _pai) array_push(_r, id);
	return _r;
}

//RESUMO DOS BLOCOS: QUANTOS FANTASMAS, SE ESTAO GRUDADOS, CORES
resumo = function(_blocos)
{
	var _f = [], _cores = "";
	for(var i = 0; i < array_length(_blocos); i++)
	{
		if(_blocos[i].sou_fantasma) array_push(_f, _blocos[i]);
		_cores += string(_blocos[i].coloracao) + " ";
	}
	//CADA FANTASMA TEM QUE TER OUTRO FANTASMA GRUDADO (SE TIVER MAIS DE 1)
	var _grudados = true;
	if(array_length(_f) > 1)
	{
		for(var i = 0; i < array_length(_f); i++)
		{
			var _tem = false;
			for(var j = 0; j < array_length(_f); j++)
			{
				if(i != j and abs(_f[i].x - _f[j].x) + abs(_f[i].y - _f[j].y) == CEL) _tem = true;
			}
			if(!_tem) _grudados = false;
		}
	}
	var _alarmes = true;
	for(var i = 0; i < array_length(_blocos); i++) if(_blocos[i].alarm[1] > 0) _alarmes = false;
	return "blocos=" + string(array_length(_blocos)) + " fantasmas=" + string(array_length(_f)) + " grudados=" + string(_grudados) + " cores=[" + _cores + "] sem sorteio de laser/raivosa=" + string(_alarmes);
}
