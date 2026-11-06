//EFEITO DE LINHA COMPLETA: ANIMAÇAO NA LINHA E, NO MEIO DELA, QUEBRA OS BLOCOS, DA OS PONTOS E VE SE SOBE DE ANDAR.
//CRIADO PELO LIMPAR_LINHAS DA ARENA (UM POR LINHA)
depth = -1000
alt = 16;	//ALTURA DO EFEITO
qtd = 1;	//QUANTAS LINHAS ESSE EFEITO CUIDA
meu_y = noone;	//Y DA LINHA
timer = 0;	//TEMPO DA ANIMAÇAO
alpha_rec = 1;	//TRANSPARENCIA DO RETANGULO (ANTIGO)

timer_array = [];	//TEMPO DA ANIMAÇAO DE CADA LINHA
y_array = [];	//Y DE CADA LINHA
line = true;	//E A LINHA DO ANDAR? (ANTIGO)
minha_area = noone;	//ARENA DA LINHA
minha_linha = noone;	//LINHA DOS ANDARES DESSA ARENA
zx = noone;	//VERSUS: X ONDE COMEÇA A ZONA DESSA LINHA (NOONE = A ARENA INTEIRA)
zc = noone;	//VERSUS: COLUNAS DA ZONA
zona = -1;	//VERSUS: QUAL ZONA (0 OU 1)
regua_y = noone;	//VERSUS: Y DA LINHA DOS ANDARES DESSA ZONA (NO ARCADE A LINHA E O OBJ_LINHA, MINHA_LINHA)

somar = true;	//SOMA NO ANDAR (ANTIGO)
combo = 0;	//QUANTAS LINHAS FECHARAM JUNTO

criar_chao_combo = false;	//OS BLOCOS DESSA LINHA VIRAM CHAO (A LINHA CONTA PRO ANDAR)
subir_andar = false; //LINHA DE COR UNICA: SOBE DE ANDAR NO FIM DA ANIMACAO
chao_y = noone;	//Y (TOPO) DA LINHA QUE VIROU CHAO. NO FIM DO EFEITO, QUALQUER CASA DELA SEM CHAO GANHA UM (EVITA BURACO NO CHAO)

//Y DA LINHA DOS ANDARES: A DA ZONA (VERSUS) OU A DO ARCADE. INFINITY = NAO TEM (NADA VIRA CHAO)
regua_atual = function()
{
	if(regua_y != noone) return regua_y;
	return minha_linha != noone ? floor(minha_linha.y) : infinity;
}

//QUEBRA OS BLOCOS DA LINHA EM _Y (O NOME E ANTIGO: ELA NAO CRIA BLOCO)
criar_bloco = function(_y)
{
	var _area =  minha_area;
	var _zx = zx == noone ? _area.x : zx;	//ONDE COMEÇA A ZONA (OU A ARENA)
	var _zc = zc == noone ? _area.cols : zc;	//QUANTAS COLUNAS
	var _peca = collision_point(_zx + CEL/2, _y, obj_peca, 0, 1);
	if(!_peca) exit;
	
	//PEGANDO OS BLOCOS DA LINHA ANTES DE DESTRUIR QUALQUER UM
	//(QUANDO O PRIMEIRO BLOCO DE UMA PEÇA MORRE ELE DESFAZ O GRUPO, AI OS OUTROS PERDERIAM O BONUS DE GRUPO)
	var _blocos = [];
	var _agrupado = [];
	var _cores = [];
	//PASSA POR TODAS AS COLUNAS DA LINHA
	for(var i = 0; i < _zc; i++)
	{
		var _x = (_zx + CEL/2) + CEL*i;
		var _p = collision_point(_x, _y + 8, obj_peca, 0, 1);
		if(_p and _p.destruido_por == noone)
		{
			array_push(_blocos, _p);
			array_push(_agrupado, _p.irmandade);
			array_push(_cores, _p.coloracao);
		}
	}
	
	//ESSA FUNÇAO RODA TODO FRAME ENQUANTO O EFEITO TA ATIVO: SE OS BLOCOS JA FORAM MARCADOS, NAO FAZ NADA
	if(array_length(_blocos) == 0) exit;
	//ESSA LINHA VIRA CHAO (MESMA REGRA DO _P.CRIAR_CHAO MAIS ABAIXO): GUARDA PRA CONFERIR O CHAO NO FIM
	if(criar_chao_combo and regua_atual() != infinity and _y >= regua_atual()) chao_y = _y;
	
	//IRMANDADE: TODA PEÇA QUE AINDA TAVA INTEIRA NA LINHA E DESTRUIDA POR COMPLETO
	//(OS BLOCOS DELA QUE ESTAO FORA DA LINHA TAMBEM MORREM). CADA BLOCO DELA MOSTRA +PONTOS_IRMANDADE
	var _irmaos_fora = [];
	for(var i = 0; i < array_length(_blocos); i++)
	{
		if(!_agrupado[i]) continue;
		//TODOS OS BLOCOS DA PEÇA (MESMO OS DE FORA DA LINHA)
		var _lista = _blocos[i].irmaos();
		
		for(var k = 0; k < array_length(_lista); k++)
		{
			var _ir = _lista[k];
			if(!instance_exists(_ir)) continue;
			if(array_contains(_blocos, _ir) or array_contains(_irmaos_fora, _ir)) continue;
			
			//SE ESSE BLOCO TA EM OUTRA LINHA QUE TAMBEM VAI SER LIMPA (GRID = 2), A LINHA DELE CUIDA
			var _gx = (_ir.x - _area.x) div CEL; //(NO VERSUS A GRADE E A DA ARENA INTEIRA: COLUNA ABSOLUTA)
			var _gy = (_ir.y - _area.y) div CEL;
			if(_gx >= 0 and _gy >= 0 and _gx < _area.cols and _gy < _area.lins and global.grid[# _gx, _gy] == 2) continue;
			
			array_push(_irmaos_fora, _ir);
		}
	}
	
	//LINHA: PONTOS FIXOS NO NUMERO DO CENTRO DA TELA
	var _quadro = noone;
	if(zona >= 0)
	{
		//VERSUS: OS PONTOS DA LINHA SAO DE QUEM FECHOU E A ENERGIA DO ESPECIAL TAMBEM
		pontos_somar(PONTOS_LINHA, _zx + _zc * CEL / 2, _y - 6);
		versus_energia_ganhar(zona, VS_ENERGIA_LINHA);
	}
	else
	{
		_quadro = coletor_linha();
		global.linhas_total++;
		energia_ganhar(ENERGIA_LINHA);
	}
	
	//LINHA DE UMA COR SO (SO CONTA ABAIXO DA REGUA): BONUS E SOBE DIRETO PRO PROXIMO ANDAR
	var _uma_cor = minha_linha != noone and array_length(_cores) == _area.cols and _y >= floor(minha_linha.y) and _cores[0] != -1; //O FANTASMA NAO TEM COR
	for(var i = 1; i < array_length(_cores) and _uma_cor; i++)
	{
		if(_cores[i] != _cores[0]) _uma_cor = false;
	}
	if(_uma_cor)
	{
		coletor_uma_cor(_quadro);
		efeito_texto(texto("cor_unica") + "!", _area.x + _area.sprite_width/2, _y - 20, c_orange, 1.3);
		som_tocar(snd_new_level);
		energia_ganhar(ENERGIA_UMA_COR);
		//SO SOBE NO FIM DA ANIMACAO: SE SUBISSE AGORA, O CHAO SERIA APAGADO ENQUANTO OS BLOCOS DESSA LINHA
		//AINDA ESTAO VIRANDO CHAO (UNS SUMIAM, OUTROS FICAVAM E O CHAO FICAVA COM BURACO)
		subir_andar = true;
	}
	
	//DESTRUINDO A LINHA: OS BLOCOS FICAM BRANCOS E SOMEM DO CENTRO PRAS PONTAS (1 FRAME POR COLUNA, TIPO TETRIS)
	//OS BLOCOS DA IRMANDADE (DENTRO E FORA DA LINHA) QUEBRAM JUNTO, NO MESMO FRAME DA COLUNA DELES.
	//O EFEITO DE MORTE E O "10" SAEM NO DESTROY DE CADA BLOCO
	var _meio = (_zc - 1) / 2;
	var _n_irm = 0;
	for(var i = 0; i < array_length(_blocos); i++)
	{
		var _p = _blocos[i];
		if(!instance_exists(_p)) continue;
		if(criar_chao_combo and regua_atual() != infinity) if(_y >= regua_atual()) _p.criar_chao = true;
		_p.efeito_morte = false;
		_p.destruido_por = "linha";
		_p.alpha_fog = 1;
		_p.esc = 1.2;
		_p.alarm[3] = 1 + floor(abs(((_p.x - _zx) div CEL) - _meio)); //O ALARM 3 DA PEÇA SO DA INSTANCE_DESTROY()
		
		if(_agrupado[i])
		{
			_p.morte_irmandade = true;
			_p.meu_coletor = _quadro;	//RESERVA LUGAR NO NUMERO DO CENTRO (ELE ESPERA ESSE 10)
			if(_quadro != noone) _quadro.esperando++;
			_p.espera_pontos = _n_irm * 3;
			_n_irm++;
		}
	}
	
	//BLOCOS DA IRMANDADE QUE ESTAO FORA DA LINHA: MORREM JUNTO
	for(var i = 0; i < array_length(_irmaos_fora); i++)
	{
		var _ir = _irmaos_fora[i];
		if(!instance_exists(_ir) or _ir.destruido_por != noone) continue;
		_ir.destruido_por = "irmandade";
		_ir.morte_irmandade = true;
		_ir.meu_coletor = _quadro;
		if(_quadro != noone) _quadro.esperando++;
		_ir.espera_pontos = _n_irm * 3;
		_n_irm++;
		_ir.alpha_fog = 1;
		_ir.esc = 1.2;
		_ir.timer_move = 99999;	//NAO CAI NESSES POUCOS FRAMES
		_ir.alarm[3] = 1 + floor(abs(((_ir.x - _zx) div CEL) - _meio));
	}
}

