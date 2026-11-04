//ARENA DO ARCADE: CRIA A BORDA, GUARDA A GRADE (GLOBAL.GRID) E CRIA AS PEÇAS
//DEPTH = 999;
//ESSE OBJETO E A GRADE DO ARCADE E TAMBEM O "MOTOR" QUE OS OUTROS MODOS HERDAM (OBJ_AREA_COOP E OBJ_AREA_VERSUS SAO FILHOS DELE):
//CADA FILHO AJEITA O QUE E SO DELE (TAMANHO DA ARENA, JOGADORES, ZONAS) E CHAMA EVENT_INHERITED() PRA USAR O RESTO DAQUI.
//OS FILHOS TROCAM DUAS FUNÇOES DESTE OBJETO: DESENHAR_FUNDO (O FUNDO DA ARENA) E DETECTAR_LINHAS (QUANDO UMA LINHA FECHA)
//CRIANDO A BORDA

//ENCAIXA A LINHA DOS ANDARES NA ARENA
var _minha_linha = instance_place(x, y, obj_linha);
if(_minha_linha) _minha_linha.x = x - CEL/2;

//A BORDA E O HUD DO ARCADE E DO COOP. O VERSUS NAO USA (O HUD DELE E DESENHADO PELO PROPRIO OBJ_AREA_VERSUS): O FILHO DESLIGA USA_BORDA ANTES
if(!variable_instance_exists(id, "usa_borda")) usa_borda = true;
minha_borda = noone;
if(usa_borda)
{
	minha_borda = instance_create_depth(x, y, -1000, obj_borda);
	minha_borda.sprite_index = modo_arcade() ? spr_borda : spr_borda_vesus;
	minha_borda.dx_hud = sprite_width - sprite_get_width(spr_area);	//ARENA MAIS LARGA (COOP): O PAINEL VAI PRA DIREITA
}

timer_combo = 0; //TEMPO DE .5 SEG PRA ENTRAR MAIS UMA LINHA PA GERA UM COPMBO

//FUNDO DA ARENA (CHAMADO NO DRAW): O PRETO MEIO TRANSPARENTE POR CIMA DA PAREDE DE AZULEJOS E A BORDA DE TRAS. O VERSUS TROCA POR OUTRO
desenhar_fundo = function(_sx, _sy)
{
	//DENTRO DA ARENA: UM PRETO MEIO TRANSPARENTE POR CIMA DA PAREDE DE AZULEJOS (IGUAL AO PROJETO ANTIGO), PROS BLOCOS APARECEREM
	if(modo_arcade())
	{
		draw_set_alpha(FUNDO_ARENA);
		draw_set_color(c_black);
		draw_rectangle(x + _sx, y + _sy, x + sprite_width - 1 + _sx, y + sprite_height - 1 + _sy, false);
		draw_set_alpha(1);
		draw_set_color(c_white);
	}
	//FUNDO DA ARENA
	if(modo_arcade()) borda_desenhar(spr_borda, 0, x + _sx, y + _sy, sprite_width - sprite_get_width(spr_area));
	else draw_sprite(spr_borda_vesus, 0, x + _sx, y + _sy);
}

//DETECTANDO LINHAS COMPLETAS (CHAMADO NO DRAW): TODAS AS CELULAS DA LINHA COM 1 NA GRID. A LIMPEZA (EFEITO, PONTOS, CHAO E CONTAGEM
//DO ANDAR) FICA NO LIMPAR_LINHAS(). O VERSUS TROCA POR OUTRO (UMA DETECÇAO POR ZONA)
detectar_linhas = function()
{
	var _linhas = [];
	for(var j = 0; j < lins; j++)
	{
		var _completa = true;
		for(var i = 0; i < cols; i++)
		{
			if(global.grid[# i, j] != 1)
			{
				_completa = false;
				break;
			}
		}
		if(_completa) array_push(_linhas, j);
	}
	if(timer_reset == 0 and array_length(_linhas) > 0) limpar_linhas(_linhas);
}

cel = CEL;	//TAMANHO DA CELULA
cols = sprite_width div cel;	//QUANTAS COLUNAS CABEM NA ARENA
lins = sprite_height div cel;	//QUANTAS LINHAS CABEM NA ARENA

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

//VARIAVEIS ANTIGAS DAS SETAS (HOJE O QUEBRA-CABEÇA FICA NO OBJ_QUEBRA_CABECA)
//VARIAVEIS DAS CETAS 
alpha_geral = []; //CADA UM TEM UM ALPHA
alpha_cetas = []; //CADA UM TEM UM ALPHA
array_cetas = [];
array_shake = 0;
alpha_fog = [];
alpha_fog_error = [];
qtd_cetas = noone; //ENTRE 3 - 5
round_ceta = 1;
acertos = 0;
//VARIAVEIS DAS CETAS 

//ESPINHOS DAS LATERAIS (ANTIGO)
pos_espinhos_x = [x - 6, x + 6];
pos_espinhos_y = [y, y];
prox_espinhos_x = [x, x];
fechando = false;

//GRADE DA ARENA: CADA CASA GUARDA -1 (VAZIA), O BLOCO QUE TA LA OU 2 (LINHA SENDO DESTRUIDA). VER SCR_GRIDS
global.grid = ds_grid_create(cols, lins);
ds_grid_clear(global.grid, -1);

//POSIÇAO ORIGINAL (A TREMIDA MEXE NA ARENA)
pos_x = x;
pos_y = x;
meu_x = x;
meu_y = y;

timer_reset = 0;	//NAO USADO
grade_conferida = 0;	//ULTIMA VEZ QUE A GRADE FOI CONFERIDA COM OS BLOCOS (GRID_REPARAR)
dupla_espera = 0;		//PEÇAS DUPLAS: FRAMES ATE A SEGUNDA PEÇA DO PAR
dupla_tentativas = 0;	//SE O TOPO TA OCUPADO, TENTA DE NOVO (ATE DESISTIR)
topo_cheio_vezes = 0; //QUANTAS TENTATIVAS SEGUIDAS DE CRIAR PEÇA COM A ARENA CHEIA
lado_ultimo = 0;	//PAREDE ONDE A ULTIMA PEÇA NASCEU ENCOSTADA (-1 ESQUERDA, 1 DIREITA, 0 = NASCEU LONGE DAS PAREDES)

//TREMIDA DA TELA (SHAKES)
shake_intensity = 0;
shake_duration = 0;

//LIDANDO COM O PECA INST===========
peca_inst = noone;	//NAO USADO (A FILA FICA NO SCR_FILA)
//LIDANDO COM O PECA INST===========

//CRIANDO BLOCO
alarm[0] = room_speed; //PRIMEIRA PEÇA (DEPOIS O ALARM SE REPETE SOZINHO)

//FUNÇOES===========================


//ONDE A PROXIMA PEÇA PODE NASCER: TODAS AS COLUNAS DO PAI ONDE ELA CABE INTEIRA NA ARENA, EM ORDEM SORTEADA COM PESO.
//ENCOSTADA NUMA PAREDE TEM MENOS CHANCE (PECA_LATERAL_PESO) E, SE A ULTIMA JA NASCEU ENCOSTADA NA MESMA PAREDE,
//MUITO MENOS (PECA_LATERAL_REPETE): PODE ACONTECER, MAS NAO VARIAS VEZES SEGUIDAS.
//(ANTES SORTEAVA A COLUNA E EMPURRAVA A PEÇA PRA DENTRO QUANDO ELA FICAVA PRA FORA: AS COLUNAS DE FORA "CAIAM"
//NA BEIRADA, E A PEÇA ENCOSTADA NA PAREDE SAIA ATE 3X MAIS QUE AS OUTRAS POSIÇOES)
//RETORNA UM ARRAY DE { COL, LADO } (A PRIMEIRA E A SORTEADA, AS OUTRAS SAO AS OPÇOES SEGUINTES)
colunas_sorteadas = function(_tipo)
{
	//CASAS QUE A PEÇA OCUPA PROS LADOS EM VOLTA DO PAI
	var _f = peca_formato(_tipo);
	var _minx = 0, _maxx = 0;
	for(var i = 0; i < array_length(_f[0]); i++)
	{
		_minx = min(_minx, _f[0][i]);
		_maxx = max(_maxx, _f[0][i]);
	}
	var _lista = [];
	for(var c = -_minx; c <= cols - 1 - _maxx; c++)
	{
		var _lado = 0;
		if(c + _minx == 0) _lado = -1;
		else if(c + _maxx == cols - 1) _lado = 1;
		var _peso = 1;
		if(_lado != 0) _peso = _lado == lado_ultimo ? PECA_LATERAL_REPETE : PECA_LATERAL_PESO;
		//SORTEIO COM PESO: CADA OPÇAO GANHA UMA NOTA ALEATORIA (MAIOR PESO = NOTA MAIOR, EM MEDIA) E A LISTA E
		//ORDENADA PELA NOTA. A CHANCE DE CADA UMA SER A PRIMEIRA E PROPORCIONAL AO PESO
		array_push(_lista, { col : c, lado : _lado, nota : power(random(1), 1 / _peso) });
	}
	array_sort(_lista, function(_a, _b) { return sign(_b.nota - _a.nota); });
	return _lista;
}

//CRIA A PROXIMA PEÇA NUMA COLUNA SORTEADA (SE O TOPO ESTIVER LIVRE)
criar_bloco = function()
{
	//ARENA CHEIA: TEM BLOCO PARADO NA PRIMEIRA LINHA DA ARENA -> GAME OVER
	var _topo = y + CEL;
	var _x1 = x, _x2 = x + sprite_width;
	var _cheia = false;
	with(obj_peca) if(estou_parado and !andar and y < _topo and x > _x1 and x < _x2) _cheia = true;
	//PRECISA CONTINUAR CHEIA NA TENTATIVA SEGUINTE (~2S): UMA PEÇA ENCOSTADA EM OUTRA QUE AINDA TA CAINDO
	//FICA "PARADA" POR UM INSTANTE, E ISSO NAO PODE DAR GAME OVER
	if(_cheia)
	{
		topo_cheio_vezes++;
		if(topo_cheio_vezes >= 2 and IMORTAL) { with(obj_peca) instance_destroy(); topo_cheio_vezes = 0; } //MODO DE TESTE: SO LIMPA
		else if(topo_cheio_vezes >= 2) with(obj_player) morrer();
		exit;
	}
	topo_cheio_vezes = 0;
	
	//ABERTURA: AS PRIMEIRAS PEÇAS SAO SEMPRE AS MESMAS, NA COLUNA CERTA (CRIAR_PECAS)
	var _abertura = abertura_ativa();
	if(_abertura)
	{
		var _ab = global.abertura_pecas[global.abertura_i];
		global.prox_tipo = _ab[0];
		global.prox_cor = _ab[1];
		global.prox_especie = "normal";
		global.prox_fantasmas = 0;
		global.prox_gelo = false;
		global.debug_bloco = "";
	}
	//COLUNA SORTEADA (MENOS CHANCE ENCOSTADA NA PAREDE), DUAS CASAS ACIMA DA ARENA
	var _escolha = _abertura ? { col : global.abertura_pecas[global.abertura_i][2], lado : 0 } : colunas_sorteadas(global.prox_tipo)[0];
	var _x = (x + cel/2) + cel * _escolha.col;
	var _y = (y + cel/2) - cel*2;
	
	//TEM ALGO NA AREA ONDE A PEÇA NASCE? ENTAO ESPERA A PROXIMA VEZ
	var _area_de_criacao = collision_rectangle(x, y + cel, x + sprite_width, (y + cel) - cel*3, [obj_peca, obj_cria_peca, obj_inimigo], 0, 1); //O INIMIGO TREME UM POUCO ONDE NASCEU
	
	if(!_area_de_criacao) 
	{
		//CODIGO ANTIGO DESLIGADO
		//VAR _CRIADOR = INSTANCE_CREATE_LAYER(_X, _Y, LAYER, OBJ_CRIA_PECA);
		//_CRIADOR.TIPO = _TIPO;
		 //_X = (X + CEL/2) + (16*5);
		var _criador = instance_create_layer(_x, _y, "Linha", obj_cria_peca);
		lado_ultimo = _escolha.lado;
		if(_abertura) { global.abertura_i++; global.abertura_marca = true; }
	}
}
//PEÇA DA ONDA: NASCE NUMA COLUNA ONDE ELA CABE, SEM ESPERAR A AREA DE CRIAÇAO TODA ESVAZIAR
//(AS PEÇAS DA ONDA CAEM LADO A LADO). RETORNA FALSE SE NAO ACHOU LUGAR (TENTA DE NOVO NO FRAME SEGUINTE)
criar_peca_onda = function()
{
	//CASAS QUE A PROXIMA PEÇA OCUPA EM VOLTA DO PAI
	var _f = peca_formato(global.prox_tipo);
	var _minx = 0, _maxx = 0, _miny = 0, _maxy = 0;
	for(var i = 0; i < array_length(_f[0]); i++)
	{
		_minx = min(_minx, _f[0][i]);
		_maxx = max(_maxx, _f[0][i]);
		_miny = min(_miny, _f[1][i]);
		_maxy = max(_maxy, _f[1][i]);
	}
	var _y = (y + cel/2) - cel * 2;
	var _y_pai = global.prox_tipo == tipo_peca.I1 ? _y + cel : _y; //A I EM PE NASCE UMA CASA MAIS BAIXO (CRIAR_PECAS)
	var _y1 = _y_pai + cel * _miny - cel/2 + 1;
	var _y2 = _y_pai + cel * (_maxy + 1) + cel/2 - 1; //UMA CASA DE FOLGA EMBAIXO
	
	//TENTA AS COLUNAS ONDE ELA CABE, NA ORDEM SORTEADA (MENOS CHANCE ENCOSTADA NA PAREDE, VER COLUNAS_SORTEADAS)
	var _opcoes = colunas_sorteadas(global.prox_tipo);
	for(var i = 0; i < array_length(_opcoes); i++)
	{
		var _col = _opcoes[i].col;
		var _x = (x + cel/2) + cel * _col;
		var _x1 = _x + cel * _minx - cel/2 + 1;
		var _x2 = _x + cel * _maxx + cel/2 - 1;
		if(!collision_rectangle(_x1, _y1, _x2, _y2, [obj_peca, obj_cria_peca, obj_inimigo], 0, 1))
		{
			instance_create_layer(_x, _y, "Linha", obj_cria_peca);
			lado_ultimo = _opcoes[i].lado;
			return true;
		}
	}
	return false;
}

//ANTIGO: CRIAVA UMA PEÇA FANTASMA NO MEIO DA ARENA
criar_bloco_fantasma = function()
{
	var _tipo = tipo_peca.F;
	var _x = (x + (cel/2) + (cel/2 * 6)) + (16*irandom(3));
	var _y = (y + cel/2) - cel*2;
	
	var _area_de_criacao = collision_rectangle(x, y + cel, x + sprite_width, (y + cel) - cel*3, [obj_peca, obj_cria_peca, obj_inimigo], 0, 1); //O INIMIGO TREME UM POUCO ONDE NASCEU
	
	if(!_area_de_criacao) 
	{
		//VAR _CRIADOR = INSTANCE_CREATE_LAYER(_X, _Y, LAYER, OBJ_CRIA_PECA);
		//_CRIADOR.TIPO = _TIPO;
		 //_X = (X + CEL/2) + (16*5);
		var _criador = instance_create_layer(_x, _y, "Linha", obj_cria_peca);
	}
}


//LIMPA AS LINHAS COMPLETAS (UMA OU VARIAS DE UMA VEZ, MESMO QUE NAO ESTEJAM COLADAS)
//CADA LINHA GANHA O SEU OBJ_EFEITO_LINE, QUE DESTROI OS BLOCOS, DA OS PONTOS E VIRA CHAO SE PRECISAR.
//LINHA NA REGUA OU ABAIXO DELA CONTA PRO ANDAR (E VIRA CHAO) SE O CHAO SOBE ATE ELA, IGUAL ANTES.
//ANTES: SE A META DO ANDAR JA TINHA SIDO ATINGIDA, OU SE VARIAS LINHAS PASSAVAM DA META, ALGUMAS LINHAS
//FICAVAM MARCADAS NA GRID (2 = SENDO DESTRUIDA) SEM EFEITO NENHUM E NUNCA MAIS FECHAVAM
limpar_linhas = function(_linhas)
{
	habil_aprender("linha"); //ENSINO NATURAL: JA SABE FECHAR LINHA
	var _n = array_length(_linhas);
	var _regua = instance_exists(obj_linha) ? instance_nearest(x + sprite_width/2, y, obj_linha) : noone;
	var _regua_y = _regua != noone ? floor(_regua.y) : infinity;
	
	//ALGUMA DELAS TA NA ALTURA DO CHAO ATUAL? (O CHAO SOBE A CADA LINHA QUE CONTA NO ANDAR)
	var _no_chao = false;
	for(var k = 0; k < _n; k++)
	{
		if(lins - global.linhas_completadas == _linhas[k] + 1) _no_chao = true;
	}
	
	//MARCANDO NA GRID (2 = SENDO DESTRUIDA, PRA NAO DETECTAR DE NOVO)
	for(var k = 0; k < _n; k++)
	{
		for(var i = 0; i < cols; i++) global.grid[# i, _linhas[k]] = 2;
	}
	
	//COMBO E SOM (UMA VEZ SO, MESMO COM VARIAS LINHAS)
	var _y_texto = (y + CEL/2) + CEL * _linhas[_n - 1];
	combo_linha(_n, x + sprite_width/2, _y_texto);
	global.qc_ritmo += _n; //QUEBRA-CABEÇA: JOGADOR INDO BEM
	som_linha(_n + global.combo_seq - 1); //MAIS AGUDO QUANTO MAIOR O COMBO
	
	//GAMEFEEL: ONDA DE CHOQUE SAINDO DA LINHA (MAIOR COM MAIS LINHAS) E UM HITSTOP CURTINHO
	onda_choque(x + sprite_width/2, _y_texto, 70 + 25 * _n, 4 + _n, 30);
	hitstop(1 + _n);
	
	//UM EFEITO POR LINHA
	for(var k = 0; k < _n; k++)
	{
		var _row = _linhas[k];
		var _e = instance_create_layer(x + sprite_width/2, (y + CEL/2) + CEL * _row, "Blocos", obj_efeito_line);
		_e.alt = CEL;
		_e.meu_y = y + CEL * _row;
		_e.line = false;
		_e.minha_area = id;
		_e.minha_linha = _regua != noone ? _regua : obj_linha;
		_e.somar = true;
		_e.combo = _n;
		_e.criar_chao_combo = _no_chao;
		
		//CONTA PRO ANDAR (NA REGUA OU ABAIXO, COM O CHAO SUBINDO ATE ELA)
		if(_no_chao and floor(y + CEL * _row) >= _regua_y) global.linhas_completadas++;
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

