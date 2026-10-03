//BLOCO DE UMA PEÇA (TETRIS). UMA PEÇA = VARIOS OBJ_PECA: UM E O PAI, OS OUTROS SAO OS FILHOS (A 'IRMANDADE').
//ENQUANTO ESTAO JUNTOS ELES CAEM E ANDAM COMO UMA PEÇA SO. A IRMANDADE QUEBRA QUANDO A PEÇA E EMPURRADA OU FECHA LINHA
//IMAGE_ALPHA = .2
//VARIAVEIS DE INICIALIZAÇAO

//IMPEDINDO DE SER CRIADO DENTRO DFE OUTRAS PEÇAS
var _peca = instance_place(x, y, obj_peca)
if(_peca) instance_destroy(_peca);

escorregar_player = 0; //TEMPO QUE TEM PRA ESCORREGAR O PLAYERE NO TELEPORTE



sou_pai = false;	//ESSE BLOCO E O PAI DA PEÇA?
meus_filhos = noone;	//APENAS A PEÇA PAI TEM ESSA INFORMAÇAO
pai = noone;	//BLOCO PAI DA PEÇA (QUEM MANDA NA QUEDA)
inicializando = 10;	//FRAMES ATE COMEÇAR A COLIDIR (ACABOU DE NASCER)
irmandade = true;	//AINDA ESTA PRESO AOS IRMAOS (PEÇA INTEIRA)?
tipo = noone;	//FORMATO DA PEÇA (T, L, O...)

dano = noone;	//ESTADO DE DANO (ANTIGO)
minha_sombra = noone;	//SOMBRA (NAO USADA)
destruido_por = noone;	//QUEM DESTRUIU: "LINHA", "PLAYER", "SENSOR"... (PRA DAR OS PONTOS)
pontos_mult = 1; //MULTIPLICADOR DE PONTOS QUANDO O PLAYER QUEBRA (QUIQUE DO GIRO NO AR)
pode_especial = false;	//FAZ PARTE DE UM GRUPO QUE O ESPECIAL PODE DESTRUIR AGORA
meu_coletor = noone;	//QUADRO DE PONTOS ONDE ESSE BLOCO RESERVOU LUGAR (IRMANDADE)
morte_irmandade = false; //MORRE COM O EFEITO DA IRMANDADE (EXPLODE EM MINI-BLOCOS)
espera_pontos = 0; //FRAMES A MAIS QUE O "10" DA IRMANDADE ESPERA ANTES DE VOAR (UM DE CADA VEZ) //QUADRO DE PONTOS ONDE ESSE BLOCO RESERVOU LUGAR (IRMANDADE) //FAZ PARTE DE UM GRUPO QUE O ESPECIAL PODE DESTRUIR AGORA (MARCADO PELO ESPECIAL_MARCAR) //"LINHA" OU "PLAYER": QUEM DESTRUIU (PRA DAR OS PONTOS)

//CONTROLANDO O (INSTANCQUEBRAR_IRMANDADEIAR PECA)============
anim_brilho = 0;	//BRILHO DA PEÇA ATUAL (A QUE TELEPORTA)

//CONTROLANDO O (INSTANCIAR PECA)============

//EFEITOS DE MORTE, SE DEVE OU NAO CRIAR
criar_chao = false;	//QUANDO ESSE BLOCO QUEBRA NUMA LINHA, VIRA CHAO SOLIDO?
criar_chao_combo = false; //AQUI ELE CRIA O CHAO QUANDO E UM COMBO TIPO 5 INHAS JUNTOS
efeito_morte = true;	//MOSTRA EFEITO QUANDO MORRE

//VARIAVEIS DE GAMEFELL OU AUXILIO DE GAMEFELL============


coloracao = noone;	//COR DO BLOCO (FRAME DA SPR_PECA)
estou_parado = false;	//JA ASSENTOU (NAO ESTA MAIS CAINDO)
shake = 0;	//TREMIDA DO BLOCO
cair = false;
timer = 0;	//TEMPO GERAL (ANIMAÇOES)
esc = 1;	//ESCALA (INCHA QUANDO ACERTADO)
alpha_fog = 0;	//BRILHO BRANCO
anim_efeito_irmandade = false; //AO DESFAZER IRMANDADDE ISSO CONTROLA ANIMAÇAO
timer_efeito_irmandade = 0;	//TEMPO DA ANIMAÇAO DE QUEBRAR A IRMANDADE

//EFEITO DE BLOCO AO ENCAIXAR
animar_efeito_encaixe = false;	//TOCANDO A ANIMAÇAO DE ENCAIXAR?
timer_anim_efeito = 0;	//TEMPO DA ANIMAÇAO DE ENCAIXAR
//VARIAVEIS DE GAMEFELL OU AUXILIO DE GAMEFELL============

//VARIAVEIS DE MOVIMENTOA
prox_y = y + CEL;	//PROXIMA CASA PRA ONDE ELE ESTA DESCENDO
prox_x = x;	//PROXIMA COLUNA (QUANDO E EMPURRADO)
velh = 0;
velv = 0;
casas = 0;	//CASAS QUE AINDA VAI ANDAR PRO LADO
vel  = .8; //VELOCIDADE DA DESCIDA DE UMA CASA PRA OUTRA (ERA .7, ANTES 1)
#macro SENSOR_AVISO	24	//FRAMES QUE O BLOCO SENSOR TREME DEPOIS DE SE REVELAR, ANTES DE SE LANÇAR
vel_raivoso = 1.2; //A PEÇA RAIVOSA CAI DIRETO, SEM PARAR (ERA 2, DEPOIS 1.4. NAO DIVIDE OS 16PX: ELA SO ENCAIXA NA GRADE QUANDO PARA)
andar = false;	//TRUE ENQUANTO ESTA DESCENDO DE UMA CASA PRA OUTRA
meu_timer = peca_tempo_queda(); //FICA MAIS RAPIDO A CADA LEVEL E A CADA ANDAR
timer_move = meu_timer;	//CONTAGEM ATE DESCER A PROXIMA CASA

//VARIAVEIS DE TIPO DE BLOCOS FANTASMA, RAIVOSO, SOLIDO, LASER------------
	mask_fantasma = noone;	//MASCARA DO FANTASMA (ANTIGO)

	sou_normal		= true;	//BLOCO NORMAL (PODE SER SORTEADO PRA VIRAR ESPECIAL)
	sou_fantasma	= false;	//SO O GIRO QUEBRA, O PLAYER ATRAVESSA
	sou_solido		= false;	//CHAO SOLIDO (VIROU CHAO NUMA LINHA)
	sou_raivoso		= false;	//CAI DIRETO SEM PARAR
	sou_laser		= false;	//ATIRA LASER NO PLAYER
	laser_lado		= false;	//LASER LATERAL: ATIRA RETO PRO LADO MAIS ABERTO DA ARENA (QUEBRA O PRIMEIRO BLOCO OU DA DANO)
	sou_especial	= false; //AO SER DEESTRUIDO DA ALGO BOM OU RUIM PRO PLAYER
	sou_sensor		= false; //BLOCO SNIPER (SENSOR): PARECE NORMAL, SE LANÇA QUANDO O PLAYER PASSA NA LINHA DELE
	sou_raio		= false; //BLOCO RAIO: DESTRUIDO, CAI UM RAIO, OS OBJETOS FICAM AZUL AQUA E OS PONTOS DOBRAM
	sou_fujao		= false; //BLOCO FUJAO: TEM MOEDA DENTRO E FOGE DO PLAYER QUANDO ELE CHEGA PERTO
	sou_pedra		= false; //BLOCO DE PEDRA (SOLIDO): O PLAYER PRECISA BATER DUAS VEZES PRA QUEBRAR
	vida_pedra		= 2;	 //GOLPES QUE AINDA AGUENTA (1 = RACHADO)
	pedra_imune		= 0;	 //FRAMES SEM LEVAR GOLPE DEPOIS DE RACHAR
	cor_original	= -1;	 //A PEDRA NAO TEM COR: GUARDA A COR DA PEÇA PRA VOLTAR SE DEIXAR DE SER PEDRA
	sou_gelo		= false; //BLOCO DE GELO (A PEÇA INTEIRA): O PLAYER ESCORREGA EM CIMA DELE
	sou_colmeia		= false; //COLMEIA: PARADA, SOLTA ABELHAS QUE VAO NO BLOCO MAIS PERTO E SE DESTROEM COM ELE
	colmeia_timer	= 0;	 //FRAMES ATE A PROXIMA ABELHA
	sou_lento		= false; //LENTO: DESTRUIDO SEM SER PELO PLAYER (LINHA, LASER...), JOGA O FEITIÇO DE LENTIDAO NO PLAYER
	sou_gelatina	= false; //GELATINA: TRAMPOLIM DO PLAYER. O BLOCO QUE CAI EM CIMA DELA FICA QUICANDO ATE TER OUTRO EM CIMA DELE
	gel_balanco		= 0;	 //GELATINA BALANÇANDO (1 LOGO DEPOIS DE QUICAR UMA PEÇA)
	gel_quicando	= false; //ESSE BLOCO TA QUICANDO NA GELATINA (SOZINHO, FORA DA PEÇA E DA GRADE)
	gel_vel			= 0;	 //VELOCIDADE VERTICAL DO QUIQUE (NEGATIVO = SUBINDO)
	sou_buraco		= false; //BURACO: ENGOLE O BLOCO QUE CAI EM CIMA E ELE VOLTA PEGANDO FOGO EM CIMA DO PLAYER
	buraco_espera	= 0;	 //FRAMES ATE PODER ENGOLIR DE NOVO (RECARREGANDO: O REDEMOINHO FICA ESCURO)
	buraco_giro		= 0;	 //FRAME DO REDEMOINHO (GIRA MAIS DEVAGAR ENQUANTO RECARREGA)
	ult_spr			= spr_peca; //SPRITE E FRAME DESENHADOS POR ULTIMO (O BLOCO EM CHAMAS DO BURACO USA A CARA DELE)
	ult_img			= 0;
	fujao_acordado	= false; //TA FUGINDO (O PLAYER CHEGOU PERTO)? COM O PLAYER LONGE VOLTA A FICAR PARADO
	fujao_espera	= 0;	 //FRAMES ATE A PROXIMA CASA
	fujao_encurralado = false; //AS 4 CASAS EM VOLTA FECHADAS (FICA TREMENDO)
	fujao_controle	= false; //ACORDADO E ANDANDO SOZINHO PELA GRADE (SEM CAIR)
	fujao_alvo_x	= x;	 //CASA PRA ONDE ELE TA INDO
	fujao_alvo_y	= y;
	fujao_ant_x		= x;	 //CASA DE ONDE ELE VEIO (PRA NAO FICAR INDO E VOLTANDO)
	fujao_ant_y		= y;
	sensor_timer	= -1;	 //CONTAGEM DEPOIS DE SE REVELAR (-1 = AINDA ESCONDIDO)
	premio_especial	= -1;	 //O QUE O BLOCO ESPECIAL GUARDA (SORTEADO QUANDO ELE VIRA ESPECIAL, A VISAO ESPIRITUAL MOSTRA)
	letra			= -1;	 //LETRA D/R/O/P GUARDADA DENTRO DO BLOCO (SAI QUANDO ELE QUEBRA)
	letra_timer		= 0;	 //QUANTO TEMPO A LETRA AINDA FICA NO BLOCO
	//VOLTA O BLOCO PRA NORMAL (TIRA TODOS OS TIPOS)
	restar_variaveis_blocos = function()
	{
		sou_normal		= true; 
		sou_fantasma	= false;
		sou_solido		= false;
		sou_raivoso		= false;
		sou_laser		= false;
		laser_lado		= false;
		sou_especial	= false;
		sou_sensor		= false;
		sou_raio		= false;
		sou_fujao		= false;
		if(sou_pedra or sou_gelo or sou_colmeia or sou_gelatina or sou_buraco) coloracao = cor_original; //VOLTA A COR DA PEÇA
		sou_pedra		= false;
		sou_gelo		= false;
		sou_colmeia		= false;
		sou_lento		= false;
		sou_gelatina	= false;
		sou_buraco		= false;
	}
	//NO PROXIMO FRAME SORTEIA SE VIRA UM TIPO ESPECIAL (ALARM 1)
	alarm[1] = 1;
//VARIAVEIS DE TIPO DE BLOCOS FANTASMA, RAIVOSO, SOLIDO------------


//FUNÇOES DA PEÇA. AS QUE MEXEM NA PEÇA INTEIRA PASSAM POR TODOS OS IRMAOS
//FUNÇOES ================================
//IRMAOS = FUNCTION()
//{
//	RETURN PAI.MEUS_FILHOS;
//}

//LISTA DOS BLOCOS DA PEÇA QUE AINDA EXISTEM (SEM PAI = ELE E SOZINHO)
irmaos = function()
{
    if (!instance_exists(pai))
    {
        pai = id;
        irmandade = false;
        if (!is_array(meus_filhos)) meus_filhos = [id];
    }

    var _lista = pai.meus_filhos;
    var _vivos = [];
    for (var i = 0; i < array_length(_lista); i++)
        if (instance_exists(_lista[i])) array_push(_vivos, _lista[i]);

    pai.meus_filhos = _vivos;   // LIMPA A LISTA DE VEZ
    return _vivos;
}

//EMPURRA A PEÇA _CASAS PRO LADO (SOCO). SUPER: A PEÇA INTEIRA ANDA. NORMAL: SO ESSE BLOCO ANDA E A IRMANDADE QUEBRA.
//_POSSO_ANDAR = JA CONFERIU QUE TEM ESPAÇO
velocidade_h = function(_casas = -1, _super = false, _posso_andar = false)
{
	//PEÇA RAIVOSA CAINDO NAO PODE SER EMPURRADA: ELA DESCE SEM PARAR E, EMPURRADA NO MEIO DA QUEDA,
	//ENTRAVA DENTRO DA PEÇA DO LADO. SO PISCA PRA MOSTRAR QUE NAO DEU
	if(sou_raivoso)
	{
		var _todos = irmandade ? irmaos() : [id];
		for(var i = 0; i < array_length(_todos); i++)
		{
			_todos[i].alpha_fog = 1;
			_todos[i].esc = 1.15;
		}
		return;
	}
	
	//SE A PEÇA TA DESCENDO, TAMBEM CONFERE A CASA DE BAIXO NA COLUNA DE DESTINO (SENAO ELA ENTRA NA DE BAIXO)
	var _descendo = (irmandade and instance_exists(pai)) ? pai.andar : andar;
	var _extra_y = _descendo ? CEL : 0;
	
    //BLOCO SOZINHO: ANDA SE A CASA DO LADO ESTIVER LIVRE
    if (!irmandade)
    {
        // CHECA COLISÃO
        if (!place_meeting(x + (CEL/2) * _casas, y, [obj_block, obj_peca, obj_parede]) and !place_meeting(x + (CEL/2) * _casas, y + _extra_y, [obj_block, obj_peca, obj_parede]))
        {
            prox_x = x + CEL * _casas;
			esvaziar_grid();
        }
        alpha_fog = 1;
        esc = 1.15;
        return;
    }

    //PEÇA INTEIRA: ZERA O MOVIMENTO DE TODOS OS IRMAOS
    var _irmaos = irmaos();

    for (var i = 0; i < array_length(_irmaos); i++)
    {
        _irmaos[i].velh = 0;
        _irmaos[i].casas = 0;
    }

    //TEM ESPAÇO: ANDA (SUPER = TODOS JUNTOS, NORMAL = SO ESSE BLOCO E A IRMANDADE QUEBRA)
    if (_posso_andar)
    {
        for (var i = 0; i < array_length(_irmaos); i++)
        {
            with (_irmaos[i])
            {
                if (_super)
                {
                    esvaziar_grid();
                    prox_x = x + CEL * _casas;
                }
                alpha_fog = 1;
                esc = 1.15;
            }
        }

        if (!_super)
        {
            esvaziar_grid();
            prox_x = x + CEL * _casas;
            quebrar_irmandade(pai.timer_move, criar_chao);
        }

        return;
    }

    // AINDA NÃO SABEMOS SE PODE ANDAR: CHECAR ESPAÇO LIVRE
    var _livre = true;

    //SUPER: CONFERE O ESPAÇO DE TODOS OS BLOCOS DA PEÇA (IGNORA OS PROPRIOS IRMAOS)
    if (_super)
    {
        for (var i = 0; i < array_length(_irmaos); i++)
        {
            with (_irmaos[i])
            {
                if (place_meeting(x + CEL * _casas, y, obj_parede)) _livre = false;
                if (place_meeting(x + CEL * _casas, y + _extra_y, obj_block)) _livre = false;

                var _peca = instance_place(x + CEL * _casas, y, [obj_peca, obj_mask_fa]);
                if (_peca && _peca.pai != pai) _livre = false;
                _peca = instance_place(x + CEL * _casas, y + _extra_y, [obj_peca, obj_mask_fa]);
                if (_peca && _peca.pai != pai) _livre = false;
            }
        }
    }
    else
    {
        //NORMAL: CONFERE SO A CASA DESSE BLOCO
        if (place_meeting(x + CEL * _casas, y, obj_parede)) _livre = false;
        if (place_meeting(x + CEL * _casas, y + _extra_y, [obj_block, obj_peca, obj_mask_fa])) _livre = false;

        var _peca = instance_place(x + CEL * _casas, y, [obj_peca, obj_mask_fa]);
        if (_peca) _livre = false;
    }

    if (_livre)
    {
        velocidade_h(_casas, _super, true);
		
    }
    //SEM ESPAÇO: SO PISCA PRA MOSTRAR QUE NAO DEU
    else if (_super)
    {
        for (var i = 0; i < array_length(_irmaos); i++)
        {
            _irmaos[i].alpha_fog = 1;
            _irmaos[i].esc = 1.15;
        }
    }
    else
    {
        alpha_fog = 1;
        esc = 1.15;
    }
}

//ACERTADO: A PEÇA (OU O BLOCO) PISCA E INCHA
sofri_dano = function(_super = false)
{
	if(irmandade)
	{
		var _irmaos = irmaos();
		for(var i = 0; i < array_length(_irmaos); i++)
		{
			_irmaos[i].alpha_fog = 1;
			_irmaos[i].esc = 1.15;
		}
	}else 
	{
		alpha_fog = 1
		esc = 1.15;
	}
}

//TEM ALGUMA COISA _PX ABAIXO? (PEÇA INTEIRA: QUALQUER BLOCO DELA ENCOSTANDO EM ALGO QUE NAO SEJA IRMAO)
check_colisao = function(_px = 1)
{
	if(inicializando > 0) exit;
	if(irmandade)
	{
		var _irmaos = irmaos();
		for(var i = 0; i < array_length(_irmaos); i++)
		{
			with(_irmaos[i])
			{
				var _peca = instance_place(x, y + _px, [obj_peca, obj_mask_fa]);
				if(place_meeting(x, y + _px, obj_block)) 
				{
					return true;
				}
				else if(_peca)
				{
					if(pai != _peca.pai) 
					{
						return true;
					}
				}
			}
		}
		return false;
	}
	else 
	{
		//(O BLOCO FANTASMA COLIDE NORMAL COM AS PEÇAS; SO O PLAYER PASSA POR DENTRO DELE)
		var _peca = instance_place(x, y + _px, [obj_peca, obj_mask_fa]);
		var _block = place_meeting(x, y + _px, obj_block)
		
		if(_block) 
		{
			return true;
		}
		else if(_peca)
		{
			return true;   // <-- BASTA EXISTIR FISICAMENTE ALI, NÃO IMPORTA A FLAG
		}
	}
	return false; // TAMBÉM ESTAVA FALTANDO UM RETURN EXPLÍCITO NESSE RAMO, CUIDADO
}

//BLOCO FUJAO: DA PRA IR PRA ESSA CASA? (SEM BLOCO, PEÇA, PAREDE, CHAO OU PLAYER, SEM PEÇA CAINDO EM CIMA DELA,
//DENTRO DA ARENA E FORA DAS 2 LINHAS DE CIMA, ONDE AS PEÇAS NASCEM)
fujao_livre = function(_nx, _ny)
{
	if(place_meeting(_nx, _ny, [obj_block, obj_peca, obj_mask_fa])) return false;
	if(place_meeting(_nx, _ny, obj_player)) return false;
	if(instance_exists(obj_area))
	{
		if(_nx < obj_area.x or _nx > obj_area.x + obj_area.sprite_width) return false;
		if(_ny < obj_area.y + CEL * 2) return false;
	}
	//PEÇA CAINDO LOGO ACIMA DA CASA (IA ENTRAR NELA JUNTO)
	var _lista = ds_list_create();
	var _n = instance_place_list(_nx, _ny - CEL / 2, obj_peca, _lista, false);
	var _livre = true;
	for(var k = 0; k < _n; k++) if(!_lista[| k].estou_parado and !_lista[| k].fujao_controle) { _livre = false; break; }
	ds_list_destroy(_lista);
	return _livre;
}

//LIGA/DESLIGA O FANTASMA EM TODOS OS BLOCOS DA PEÇA
geral_fantasma = function(_fan)
{
	var _irmaos = irmaos();
	for(var i = 0; i < array_length(_irmaos); i++)
	{
		_irmaos[i].sou_fantasma = _fan;
	}
}

//ARRUMA O Y DE CADA BLOCO NA GRADE E MARCA A PROXIMA CASA (A RAIVOSA PULA 2)
ajustando_posicao = function()
{
	var _irmaos = irmaos();
	for(var i = 0; i < array_length(_irmaos); i++)
	{
		// SNAP: FORÇA O Y PRO GRID ANTES DE CALCULAR O PRÓXIMO
		//(A RAIVOSA NAO: ELA NAO PARA ENTRE AS CASAS E O SNAP PUXARIA ELA PRA TRAS. ELA ENCAIXA QUANDO BATE)
		var _y = ((_irmaos[i].y div CEL) * CEL) + 8;
		if(!sou_raivoso) _irmaos[i].y = _y;
		
		var _mult = sou_raivoso == true ? 2 : 1;
		_irmaos[i].prox_y = _y + CEL * _mult;
	}
}

//TIRA TODOS OS BLOCOS DA PEÇA DA GRADE (SCR_GRIDS)
esvaziar_grid_irmaos = function()
{
	var _irmaos = irmaos();
	for(var i = 0; i < array_length(_irmaos); i++)
	{
		with(_irmaos[i])
		{
			esvaziar_grid();
		}
	}
}

//REINICIA A CONTAGEM DA QUEDA E MARCA A PEÇA NA GRADE
ajustando_tempo_e_grid = function()
{
	if(irmandade)
	{
		var _irmaos = irmaos();
		for(var i = 0; i < array_length(_irmaos); i++)
		{
			with(_irmaos[i])
			{
				timer_move = meu_timer;
				preencher_grid();
			}
		}
	}else 
	{
		timer_move = meu_timer;
		preencher_grid();
		
	}
}

//MARCA SE A PEÇA ESTA PARADA OU CAINDO
avisando_que_estao_parado = function(_parado)
{
	if(irmandade)
	{
		var _irmaos = irmaos();
		for(var i = 0; i < array_length(_irmaos); i++)
		{
			_irmaos[i].estou_parado = _parado;
		}
	}else estou_parado = _parado;
}

//PASSA A TREMIDA PRA TODOS OS BLOCOS DA PEÇA
gamefeel_shake = function()
{
	if(irmandade)
	{
		var _irmaos = irmaos();
		for(var i = 0; i < array_length(_irmaos); i++)
		{
			_irmaos[i].shake = shake;
		}
	}else shake = shake;
}

//MUDA A VELOCIDADE DE QUEDA DE TODOS (E PARA A DESCIDA SE _ANDAR FOR FALSE)
controlando_velocidade = function(_vel, _andar = true)
{
	var _irmaos = irmaos();
	for(var i = 0; i < array_length(_irmaos); i++)
	{
		_irmaos[i].velv = _vel;
		if(!_andar)
		{
			pai.andar = false;
		}
	}
}
//VERSAO ANTIGA DO GERAL_PARADO (DESLIGADA)
/*
GERAL_PARADO = FUNCTION(_PARADO, _QUEBRAR = FALSE)
{
	VAR _IRMAOS = IRMAOS();
	
	SHAKES();
	
	FOR(VAR I = 0; I < ARRAY_LENGTH(_IRMAOS); I++)
	{
		
		
		_IRMAOS[I].ESTOU_PARADO = _PARADO;
		_IRMAOS[I].SOU_RAIVOSO	= FALSE;
		
		IF(_PARADO) _IRMAOS[I].ANIMAR_EFEITO_ENCAIXE = TRUE; //FEITO ATIVADO 
	}
}
*/

//A PEÇA ASSENTOU (OU VOLTOU A CAIR): TREME, TOCA O SOM DE ENCAIXAR E MARCA TODOS OS BLOCOS
geral_parado = function(_parado, _quebrar = false)
{
	var _irmaos = irmaos();
	shakes();
	if(_parado) som_tocar(snd_peca_encaixar, .1);
	
	for(var i = 0; i < array_length(_irmaos); i++)
	{
		with(_irmaos[i])
		{
			if(estou_parado && (!irmandade || sou_pai))
			{
				corrigir_alinhamento_grid();
			}
			
			estou_parado = _parado;
			sou_raivoso	= false;
			
			if(_parado) animar_efeito_encaixe = true; //FEITO ATIVADO 
		}
	}
}


//SEPARA OS BLOCOS DA PEÇA: CADA UM VIRA UMA PEÇA SOZINHA (SOU_LINHA = QUEBROU POR CAUSA DE UMA LINHA, SEM EFEITO)
quebrar_irmandade = function(_timer, sou_linha)
{
	var _irmaos = irmaos();
	var _andar = pai.andar;
	//PEÇA RAIVOSA: ELA CAI SEM PARAR (FORA DA GRADE) E O PROX_Y DELA FICA PRA TRAS. SEPARADA NO MEIO DA QUEDA,
	//CADA BLOCO PRECISA RECOMEÇAR A QUEDA NORMAL DA CASA ONDE ESTA (ANTES ELES FICAVAM COM A VELOCIDADE DA RAIVOSA
	//E O PROX_Y VELHO: ESCORREGAVAM, VOLTAVAM PRA CASA ERRADA E UM BLOCO ENTRAVA DENTRO DO OUTRO)
	var _raivosa = false;
	for(var i = 0; i < array_length(_irmaos); i++) if(_irmaos[i].sou_raivoso) _raivosa = true;
	for(var i = 0; i < array_length(_irmaos); i++)
	{
		with(_irmaos[i])
		{
			timer_move = _timer;
			irmandade = false;
			andar = _andar;
			pai = _irmaos[i].id;
if(_raivosa)
			{
				velv = 0;
				andar = true;
				prox_y = ceil((y - CEL / 2) / CEL) * CEL + CEL / 2; //PROXIMA CASA DA GRADE (OU A ATUAL, SE JA TA NELA)
				sou_raivoso = false;
			}
			
			
			if(!sou_linha) 
			{
				esc = 1.1;
				sou_raivoso = false;
				//_IRMAOS[I].ALPHA_FOG = 1;//SO PODE DAR ESSSE EFEITO SE NAO FOR UMA LINHAS SENDO DESTRIDA
				anim_efeito_irmandade = true;
			}
			
		}
		
		
	}
}


//VERIFICADOR PERIÓDICO DE ALINHAMENTO DE GRID
timer_verificacao_grid = 0;	//TEMPO ATE A PROXIMA CONFERIDA DA GRADE
//BLOCO PARADO FORA DA GRADE (DESALINHADO): PUXA ELE PRA CASA CERTA SE NAO FOR BATER EM NADA
corrigir_alinhamento_grid = function()
{
	var _grupo = irmandade ? irmaos() : [id];
	
	for(var i = 0; i < array_length(_grupo); i++)
	{
		var _inst = _grupo[i];
		
		if(!instance_exists(_inst)) continue;
		
		// SÓ CORRIGE QUEM ESTÁ REALMENTE PARADO E ASSENTADO
		if(!_inst.estou_parado) continue;
		if(_inst.andar) continue;
		
		var _off = ((_inst.y - 8) mod CEL + CEL) mod CEL;	//QUANTOS PIXELS ELE ESTA FORA DA GRADE
		
		if(_off != 0)
		{
			//VAI PRA CASA MAIS PERTO (CIMA OU BAIXO)
			var _correcao = (_off <= CEL / 2) ? -_off : (CEL - _off);
			var _novo_y = _inst.y + _correcao;
			
			// GUARD: SÓ APLICA SE NÃO COLIDIR COM BLOCO OU PEÇA DE OUTRO PAI
			var _seguro = !place_meeting(_inst.x, _novo_y, obj_block);
			
			if(_seguro)
			{
				var _lista = ds_list_create();
				var _n = instance_place_list(_inst.x, _novo_y, obj_peca, _lista, false);
				for(var k = 0; k < _n; k++)
				{
					if(_lista[| k].pai != _inst.pai)
					{
						_seguro = false;
						break;
					}
				}
				ds_list_destroy(_lista);
			}
			
			if(_seguro)
			{
				show_debug_message($"[GRID FIX] {_inst} (obj:{object_get_name(_inst.object_index)}) corrigido {_correcao}px (y={_inst.y} -> {_novo_y})");
				_inst.y = _novo_y;
				_inst.prox_y = _inst.y + CEL;
			}
			else
			{
				show_debug_message($"[GRID FIX] {_inst} desalinhado {_off}px mas correção bloqueada por colisão");
			}
		}
	}
}

//AO FAZER UMA LINHA E O BLOCO TIVER NA IRMANDADE ELE DEESSTROI GERAL E DA POTNOS EXTRAS
//VAZIA (ANTIGO)
combo_irmandade = function()
{
}

//PEÇA CAINDO EM CIMA DO PLAYER:
//	SE TEM ESPAÇO EMBAIXO DELE, O PLAYER E EMPURRADO PRA BAIXO JUNTO COM A PEÇA (SEM DANO: NAO TA ESMAGANDO)
//	SE NAO DA PRA DESCER (PRENSADO CONTRA O CHAO OU OUTRO BLOCO), E ESMAGADO: PERDE UMA VIDA (ESMAGADO DO PLAYER)
//(ANTES QUALQUER PEÇA CAINDO QUE ENCOSTASSE NA CABEÇA MATAVA, ATE COM O PLAYER NO AR)
empurrar_player = function()
{
	if(velv <= 0 or sou_fantasma or !instance_exists(obj_player)) exit;
	var _pl = instance_place(x, y, obj_player);
	if(_pl == noone or _pl.estado == state.morte) exit;
	if(_pl.y <= y) exit; //O PLAYER TA EM CIMA DO BLOCO, NAO EMBAIXO
	
	var _meu_pai = pai;	//BLOCO DO PLAYER (OS IRMAOS NAO CONTAM COMO OBSTACULO)
	var _falta = bbox_bottom + 1 - _pl.bbox_top; //QUANTO O PLAYER PRECISA DESCER PRA SAIR DE BAIXO DO BLOCO
	var _vel = velv;	//VELOCIDADE DA PEÇA
	with(_pl)
	{
		//DESCE O PLAYER PIXEL POR PIXEL ATE SAIR DE BAIXO DO BLOCO (OU BATER EM ALGO)
		var _desceu = 0;
		while(_desceu < _falta)
		{
			//TEM CHAO OU BLOCO LOGO EMBAIXO DOS PES? (IGNORA A PROPRIA PEÇA QUE TA EMPURRANDO E O FANTASMA,
			//QUE O PLAYER ATRAVESSA. USA A MASCARA DO PLAYER 1PX ABAIXO. OBS: COLLISION_RECTANGLE COM ALTURA ZERO
			//NAO DETECTA NADA, E OS *_LIST NAO ACEITAM LISTA DE OBJETOS, POR ISSO OBJ_BLOCK E OBJ_PECA SEPARADOS)
			var _bloqueado = place_meeting(x, y + 1, obj_block);
			if(!_bloqueado)
			{
				var _lista = ds_list_create();
				var _n = instance_place_list(x, y + 1, obj_peca, _lista, false);
				for(var k = 0; k < _n; k++)
				{
					if(_lista[| k].pai != _meu_pai and !_lista[| k].sou_fantasma)
					{
						_bloqueado = true;
						break;
					}
				}
				ds_list_destroy(_lista);
			}
			if(_bloqueado) break;
			y += 1;
			_desceu++;
		}
		
		if(_desceu < _falta) esmagado(other.id);	//PRENSADO: NAO DEU PRA DESCER (PERDE UMA VIDA)
		else velv = max(velv, _vel, .5);	//ACOMPANHA O BLOCO (NAO CONSEGUE SUBIR ATRAVES DELE)
	}
}

//A PEÇA ESTA ASSENTANDO: TEM GELATINA PARADA EMBAIXO? O BLOCO QUE ENCOSTOU NELA (SE NAO TIVER NADA EM CIMA DELE)
//SAI DA PEÇA E FICA QUICANDO (GEL_QUICANDO, NO STEP) ATE TER OUTRO BLOCO EM CIMA. RETORNA TRUE SE ALGUM BLOCO QUICOU
gel_quicar = function()
{
	if(sou_gelatina) return false;
	var _grupo = irmandade ? irmaos() : [id];
	var _quicam = [];
	for(var k = 0; k < array_length(_grupo); k++)
	{
		with(_grupo[k]) if(gel_embaixo() != noone and !gel_tem_cima() and !place_meeting(x, y - 1, obj_player)) array_push(_quicam, id);
	}
	if(array_length(_quicam) == 0) return false;
	//A PEÇA SE SEPARA: QUEM ENCOSTOU NA GELATINA QUICA, O RESTO CAI SOZINHO
	if(irmandade and instance_exists(pai)) quebrar_irmandade(pai.timer_move, false);
	fila_remover(id);
	for(var k = 0; k < array_length(_quicam); k++) with(_quicam[k]) gel_impulso();
	return true;
}

//GELATINA PARADA LOGO EMBAIXO DESSE BLOCO (OU NOONE)
gel_embaixo = function()
{
	var _r = noone;
	var _lista = ds_list_create();
	var _n = instance_place_list(x, y + 1, obj_peca, _lista, false);
	for(var j = 0; j < _n; j++)
	{
		var _g = _lista[| j];
		if(_g.sou_gelatina and _g.id != id and _g.estou_parado and _g.destruido_por == noone) _r = _g;
	}
	ds_list_destroy(_lista);
	return _r;
}

//TEM BLOCO EM CIMA DESSE, SEGURANDO ELE? (ATE GEL_PESO CASAS ACIMA: UM BLOCO CAINDO LOGO ACIMA TAMBEM SEGURA)
gel_tem_cima = function()
{
	var _x1 = bbox_left + 2, _x2 = bbox_right - 3, _y1 = bbox_top - CEL * GEL_PESO, _y2 = bbox_top - 1;
	return collision_rectangle(_x1, _y1, _x2, _y2, [obj_block, obj_peca], false, true) != noone;
}

//TEM ALGO NO CAMINHO DO QUIQUE? _DY > 0: OLHA SO EMBAIXO DO BLOCO. _DY < 0: SO EM CIMA (E O PLAYER TAMBEM BLOQUEIA)
//(SO OLHA A FAIXA DO MOVIMENTO: UM BLOCO QUE JA TA ENCOSTADO DO OUTRO LADO NAO ATRAPALHA)
gel_bate = function(_dy, _player = false)
{
	var _x1 = bbox_left + 2, _x2 = bbox_right - 3;
	var _y1 = _dy > 0 ? bbox_bottom : bbox_top + _dy;
	var _y2 = _dy > 0 ? bbox_bottom + _dy : bbox_top - 1;
	var _objs = _player ? [obj_block, obj_peca, obj_player] : [obj_block, obj_peca];
	return collision_rectangle(_x1, _y1, _x2, _y2, _objs, false, true) != noone;
}

//COMEÇA (OU CONTINUA) A QUICAR: SAI DA GRADE E DA FILA E GANHA O IMPULSO PRA CIMA. A GELATINA BALANÇA
gel_impulso = function()
{
	esvaziar_grid();
	fila_remover(id);
	gel_quicando = true;
	gel_vel = -GEL_IMPULSO;
	estou_parado = false;
	andar = false;
	velv = 0;
	sou_raivoso = false;
	esc = 1.15;
	var _g = gel_embaixo();
	if(_g != noone) with(_g) { gel_balanco = 1; esc = 1.15; }
	audio_play_sound(snd_boing, 1, false, .55, 0, .95 + random(.15));
}

//BURACO ENGOLINDO UM BLOCO: ELE SAI DA PEÇA (A IRMANDADE QUEBRA) E VIRA O OBJ_BLOCO_FOGO (COM A MESMA CARA DELE),
//QUE FAZ O RESTO: GIRA E ENCOLHE PRA DENTRO DO BURACO, SAI DE UM PORTAL NO TOPO DA ARENA (NA COLUNA DO PLAYER) E CAI PEGANDO FOGO
buraco_engolir = function(_b)
{
	with(_b) if(irmandade and instance_exists(pai)) quebrar_irmandade(pai.timer_move, false);
	instance_create_depth(_b.x, _b.y, -1500, obj_bloco_fogo, { spr : _b.ult_spr, img : _b.ult_img, fase : "engolir", y_buraco : y });
	with(_b)
	{
		destruido_por = "buraco";
		efeito_morte = false;
		instance_destroy();
	}
	//O BURACO "ENGOLE": INCHA, SOM E UMA ONDINHA
	buraco_espera = BURACO_ESPERA;
	esc = 1.3;
	alpha_fog = .6;
	onda_choque(x, y, 30, 3, 14);
	audio_play_sound(snd_engolir, 1, false, .9);
	shakes(4, 1);
}
