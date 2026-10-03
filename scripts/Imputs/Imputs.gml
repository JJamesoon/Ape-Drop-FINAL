//LAYOUTS DE CONTROLE (ESCOLHIDOS EM CONFIGURAÇOES > CONTROLES)
//ORDEM DE CADA LAYOUT: SOCO, SOCO_PRESS, JUMP, GIRO, ACELERAR, LEFT, RIGTH, DOWN, DASH
global.layouts_imputs = [
	//01 - J, K, W, L, ESPAÇO, A, D, S, M
	[ord("J"), ord("K"), ord("W"), ord("L"), vk_space, ord("A"), ord("D"), ord("S"), ord("M")],
	//02 - C, X, CIMA, Z, ESPAÇO, SETAS, V
	[ord("C"), ord("X"), vk_up, ord("Z"), vk_space, vk_left, vk_right, vk_down, ord("V")],
	//03 - D, S, I, A, SHIFT, J, L, K, F
	[ord("D"), ord("S"), ord("I"), ord("A"), vk_shift, ord("J"), ord("L"), ord("K"), ord("F")],
];

global.meus_imputs = 0; //LAYOUT ATUAL (O SAVE PODE TROCAR)

//APLICA UM LAYOUT: MONTA A GLOBAL.IMPUTS COM AS TECLAS DE CADA AÇAO
function trocar_comandos(_layout)
{
	global.meus_imputs = clamp(_layout, 0, array_length(global.layouts_imputs) - 1);
	global.imputs = imputs_layout(global.meus_imputs);
}

//MONTA AS TECLAS DE CADA AÇAO DE UM LAYOUT (STRUCT COM SOCO, JUMP, LEFT...)
function imputs_layout(_layout)
{
	var _i = global.layouts_imputs[_layout];
	return {
		soco			: _i[0],
		soco_press		: _i[1],
		jump			: _i[2],
		giro			: _i[3],
		acelerar		: _i[4],
		left			: _i[5],
		rigth			: _i[6],
		down			: _i[7],
		dash			: _i[8],
		jump_press		: _i[2],	//AS VERSOES _PRESS USAM A MESMA TECLA
		giro_press		: _i[3],
	}
}
//CARREGA O LAYOUT PADRAO
trocar_comandos(global.meus_imputs);

//COOP: CADA JOGADOR TEM UM LAYOUT FIXO NO MESMO TECLADO (P1 = 01: WASD + J K L M, P2 = 02: SETAS + C X Z V).
//FORA DO COOP O PLAYER USA O LAYOUT ESCOLHIDO NAS CONFIGURAÇOES
#macro COOP_LAYOUT_P1	0
#macro COOP_LAYOUT_P2	1
function imputs_jogador(_n)
{
	if(!global.coop) return global.imputs;
	return imputs_layout(_n == 2 ? COOP_LAYOUT_P2 : COOP_LAYOUT_P1);
}

//NOME DA TECLA PRA MOSTRAR NA TELA
function tecla_nome(_tecla)
{
	switch(_tecla)
	{
		case vk_space:	return global.linguagem == 0 ? "ESPAÇO" : "SPACE";
		case vk_shift:	return "SHIFT";
		case vk_enter:	return "ENTER";
		case vk_up:		return global.linguagem == 0 ? "CIMA" : "UP";
		case vk_down:	return global.linguagem == 0 ? "BAIXO" : "DOWN";
		case vk_left:	return global.linguagem == 0 ? "ESQ" : "LEFT";
		case vk_right:	return global.linguagem == 0 ? "DIR" : "RIGHT";
	}
	return chr(_tecla);
}

//LETRAS E NUMEROS: O PROPRIO CARACTERE

//==================== CONTROLE (GAMEPAD / JOYSTICK) ====================
//O JOGO TODO LE O TECLADO. O CONTROLE SO "APERTA" E "SOLTA" AS TECLAS CERTAS (KEYBOARD_KEY_PRESS/RELEASE), ENTAO TUDO QUE FUNCIONA
//NO TECLADO FUNCIONA NO CONTROLE SEM MEXER NO RESTO DO CODIGO. NA PARTIDA: AS TECLAS DO PLAYER (NO COOP, O 2O CONTROLE E O P2).
//NOS MENUS, NA PAUSA, NO MENU DE PODER E NO GAME OVER: SETAS, ENTER E ESC. RODA NO STEP DO OBJ_CONTROLA_SOM (PERSISTENTE)
//	ANALOGICO / D-PAD = ANDAR	A = PULO	X = SOCO	B = GIRO	Y = DASH	RB = SUPER SOCO
//	LB OU RT = TELEPORTE DA PEÇA	LT OU SELECT = PARAR O TEMPO	START = PAUSA
#macro PAD_ZONA		.45		//O QUANTO O ANALOGICO TEM QUE INCLINAR PRA CONTAR
global.pad_teclas = {};		//TECLAS QUE O CONTROLE TA SEGURANDO AGORA (PRA SOLTAR QUANDO ELE SOLTAR)

//OS CONTROLES LIGADOS (NA ORDEM DOS SLOTS: O PRIMEIRO E O P1)
function pads_ligados()
{
	var _r = [];
	for(var i = 0; i < gamepad_get_device_count(); i++) if(gamepad_is_connected(i)) array_push(_r, i);
	return _r;
}

//TEM ALGUM CONTROLE LIGADO?
function pad_ligado()
{
	return array_length(pads_ligados()) > 0;
}

//OS 4 LADOS DO CONTROLE (D-PAD OU ANALOGICO ESQUERDO)
function pad_lados(_p)
{
	var _h = gamepad_axis_value(_p, gp_axislh), _v = gamepad_axis_value(_p, gp_axislv);
	return {
		esq : gamepad_button_check(_p, gp_padl) or _h < -PAD_ZONA,
		dir : gamepad_button_check(_p, gp_padr) or _h > PAD_ZONA,
		cima : gamepad_button_check(_p, gp_padu) or _v < -PAD_ZONA,
		baixo : gamepad_button_check(_p, gp_padd) or _v > PAD_ZONA,
	};
}

//ESTA NUMA PARTIDA COM O JOGO RODANDO (SENAO O CONTROLE MEXE NOS MENUS)?
function pad_na_partida()
{
	if(!modo_arcade() and room != rm_versus) return false;
	if(!instance_exists(obj_game_control)) return true;
	with(obj_game_control) if(pausado or menu_poder or fim_jogo or menu_debug) return false;
	return true;
}

//RODA TODO FRAME: MONTA AS TECLAS QUE CADA CONTROLE QUER SEGURAR E APERTA/SOLTA SO O QUE MUDOU
function gamepad_atualizar()
{
	var _quer = {};
	var _pads = pads_ligados();
	var _partida = pad_na_partida();
	var _marca = function(_q, _tecla, _on) { if(_on) _q[$ string(_tecla)] = true; };
	for(var n = 0; n < min(2, array_length(_pads)); n++)
	{
		var _p = _pads[n];
		var _l = pad_lados(_p);
		if(_partida)
		{
			//NA PARTIDA: O 1O CONTROLE E O P1 E O 2O E O P2 (SO NO COOP)
			if(n == 1 and !global.coop) break;
			var _im = imputs_jogador(n + 1);
			_marca(_quer, _im.left, _l.esq);
			_marca(_quer, _im.rigth, _l.dir);
			_marca(_quer, _im.down, _l.baixo);
			_marca(_quer, _im.jump, gamepad_button_check(_p, gp_face1));
			_marca(_quer, _im.giro, gamepad_button_check(_p, gp_face2));
			_marca(_quer, _im.soco, gamepad_button_check(_p, gp_face3));
			_marca(_quer, _im.dash, gamepad_button_check(_p, gp_face4));
			_marca(_quer, _im.soco_press, gamepad_button_check(_p, gp_shoulderr));
			_marca(_quer, global.imputs.acelerar, gamepad_button_check(_p, gp_shoulderl) or gamepad_button_check(_p, gp_shoulderrb));
			_marca(_quer, TEMPO_TECLA, gamepad_button_check(_p, gp_shoulderlb) or gamepad_button_check(_p, gp_select));
			_marca(_quer, vk_escape, gamepad_button_check(_p, gp_start));
		}
		else
		{
			//MENUS (E PAUSA, PODERES, GAME OVER): SETAS, A CONFIRMA, B VOLTA. NA PAUSA O START FECHA, NOS MENUS ELE CONFIRMA
			_marca(_quer, vk_left, _l.esq);
			_marca(_quer, vk_right, _l.dir);
			_marca(_quer, vk_up, _l.cima);
			_marca(_quer, vk_down, _l.baixo);
			_marca(_quer, vk_enter, gamepad_button_check(_p, gp_face1));
			_marca(_quer, vk_escape, gamepad_button_check(_p, gp_face2));
			var _na_pausa = modo_arcade() and instance_exists(obj_game_control) and obj_game_control.pausado;
			_marca(_quer, _na_pausa ? vk_escape : vk_enter, gamepad_button_check(_p, gp_start));
		}
	}
	//SOLTA O QUE O CONTROLE PAROU DE SEGURAR E APERTA O QUE ELE COMEÇOU A SEGURAR
	var _antes = variable_struct_get_names(global.pad_teclas);
	for(var i = 0; i < array_length(_antes); i++) if(!variable_struct_exists(_quer, _antes[i])) { keyboard_key_release(real(_antes[i])); variable_struct_remove(global.pad_teclas, _antes[i]); }
	var _agora = variable_struct_get_names(_quer);
	for(var i = 0; i < array_length(_agora); i++) if(!variable_struct_exists(global.pad_teclas, _agora[i])) { keyboard_key_press(real(_agora[i])); global.pad_teclas[$ _agora[i]] = true; }
}