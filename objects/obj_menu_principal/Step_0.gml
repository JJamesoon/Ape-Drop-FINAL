teste_menu(); //TESTE AUTOMATICO (SO COM TESTE_MENU LIGADO)

//ANIMAÇAO DO TITULO E ESPERA DA TELA DE TITULO
timer_title += .06;
if(timer_inicio > 0) timer_inicio--;

//NAO ACEITA IMPUT DURANTE A TRANSIÇAO
if(instance_exists(obj_transisao)) exit;

//IMPUTS
var _left		= keyboard_check_pressed(ord("A")) or keyboard_check_pressed(vk_left);
var _right		= keyboard_check_pressed(ord("D")) or keyboard_check_pressed(vk_right);
var _up			= keyboard_check_pressed(ord("W")) or keyboard_check_pressed(vk_up);
var _down		= keyboard_check_pressed(ord("S")) or keyboard_check_pressed(vk_down);
var _left_hold	= keyboard_check(ord("A")) or keyboard_check(vk_left);
var _right_hold	= keyboard_check(ord("D")) or keyboard_check(vk_right);
var _enter		= keyboard_check_pressed(vk_space) or keyboard_check_pressed(vk_enter);
var _voltar		= keyboard_check_pressed(vk_escape) or keyboard_check_pressed(vk_backspace);

//ANIMAÇOES QUE VOLTAM SOZINHAS
for(var i = 0; i < array_length(shake_msg); i++)
{
	shake_msg[i]	 = lerp(shake_msg[i], 0, .1);
	alpha_fog_msg[i] = lerp(alpha_fog_msg[i], 0, .08);
}
if(mostrar_msg > 0)
{
	mostrar_msg--;
	alpha_msg = lerp(alpha_msg, 1, .1);
}
else alpha_msg = lerp(alpha_msg, 0, .1);

alpha_conf = lerp(alpha_conf, estado == menu.config ? 1 : 0, .2);
alpha_ranks = lerp(alpha_ranks, estado == menu.ranks ? 1 : 0, .2);
alpha_blocos = lerp(alpha_blocos, estado == menu.blocos ? 1 : 0, .2);

switch(estado)
{
	#region INICIO
	//TITULO: O LOGO DESCE, O "APERTE ESPAÇO" PISCA E OS PERSONAGENS CORREM. ENTER VAI PRO MENU
	case menu.inicio:
		esc_fundo_lerp = .5;
		y_title			= lerp(y_title, 90, .2);
		alpha_bg_blocos = lerp(alpha_bg_blocos, 0, .2);
		alpha_title		= lerp(alpha_title, 1, .2);
		_alpha			= sin(timer_title * 1.7) + .75;

		for(var i = 0; i < array_length(players); i++) mover_player(players[i]);

		if(_enter and timer_inicio <= 0)
		{
			som_tocar(snd_menu_select_03);
			estado = menu.principal;
		}
		break;
	#endregion

	#region PRINCIPAL
	//MENU PRINCIPAL: O LOGO SOBE E APARECEM OS BOTOES
	case menu.principal:
		esc_fundo_lerp = .6;
		y_title			= lerp(y_title, -100, .15);
		alpha_bg_blocos = lerp(alpha_bg_blocos, 1, .2);
		alpha_title		= lerp(alpha_title, 0, .3);
		_alpha			= lerp(_alpha, 0, .3);

		var _total = sprite_get_number(spr_menu);

		//MUDANDO ENTRE CONFIG (-1), MEIO (0) E CREDITOS (1)
		var _h_antes = indice_h;
		indice_h = clamp(indice_h + _right - _left, -1, 1);
		if(indice_h != _h_antes) som_tocar(snd_menu_select_02);

		//SUBINDO E DESCENDO NOS BOTOES DO MEIO (DA A VOLTA)
		if(indice_h == 0 and (_up xor _down))
		{
			indice = (indice + _down - _up + _total) mod _total;
			som_tocar(snd_menu_select_03);
		}

		if(_voltar)
		{
			som_tocar(snd_menu_erro_02);
			estado = menu.inicio;
			timer_inicio = 10;
		}
		else if(_enter)
		{
			if(indice_h == -1)
			{
				som_tocar(snd_menu_select_01);
				estado = menu.config;
				conf_sub = noone;
				conf_indice = 0;
				conf_resetar_anim();
			}
			else if(indice_h == 1)
			{
				som_tocar(snd_menu_select_01);
				estado = menu.creditos;
				creditos_y = room_height + 15;
				alpha_img_creditos = 0;
			}
			else
			{
				switch(indice)
				{
					case menu_pri.arcade:
						som_tocar(snd_menu_select_01);
						global.coop = false;
						scr_trans(rm_selecao);
						break;
					case menu_pri.versus:
						som_tocar(snd_menu_select_01);
						estado = menu.versus;
						indice_versus = 0;
						break;
					case menu_pri.tutorial:	//TABELA DOS BLOCOS (O QUE CADA UM FAZ)
						som_tocar(snd_menu_select_01);
						estado = menu.blocos;
						blocos_sel = 0;
						break;
					case menu_pri.ranks:	//RECORDES DESSE COMPUTADOR (O RANKING ONLINE DO JOGO ANTIGO NAO FOI TRAZIDO)
						som_tocar(snd_menu_select_01);
						estado = menu.ranks;
						break;
					case menu_pri.steam:
						url_open("https://store.steampowered.com/app/3495060/");
						som_tocar(snd_certo);
						shake_msg[indice] = 4;
						break;
					case menu_pri.sair:
						jogo_salvar();
						game_end();
						break;
				}
			}
		}

		//ANIMANDO OS BOTOES
		for(var i = 0; i < _total; i++)
		{
			var _sel = (indice == i and indice_h == 0);
			array_y_menu[i] = lerp(array_y_menu[i], _sel ? -2 : 0, .2);
			array_alpha[i]	= lerp(array_alpha[i], _sel ? 1 : .5, .2);
		}
		array_x_menu_h[0]  = lerp(array_x_menu_h[0], indice_h == -1 ? -2 : 0, .2);
		array_alpha_hor[0] = lerp(array_alpha_hor[0], indice_h == -1 ? 1 : .5, .2);
		array_x_menu_h[1]  = lerp(array_x_menu_h[1], indice_h == 1 ? 2 : 0, .2);
		array_alpha_hor[1] = lerp(array_alpha_hor[1], indice_h == 1 ? 1 : .5, .2);
		break;
	#endregion

	#region VERSUS / COOP
	//ESCOLHA ENTRE VERSUS E COOP
	case menu.versus:
		if(_up xor _down)
		{
			indice_versus = !indice_versus;
			som_tocar(snd_menu_select_03);
		}
		for(var i = 0; i < 2; i++) y_versus[i] = lerp(y_versus[i], indice_versus == i ? -2 : 0, .2);

		if(_voltar)
		{
			som_tocar(snd_menu_erro_02);
			estado = menu.principal;
		}
		else if(_enter)
		{
			som_tocar(snd_menu_select_01);
			//COOP: O ARCADE COM DOIS JOGADORES (OS DOIS ESCOLHEM O PERSONAGEM ANTES)
			global.coop = indice_versus == 1;
			scr_trans(global.coop ? rm_selecao : rm_versus);
		}
		break;
	#endregion

	#region CONFIG
	//CONFIGURAÇOES: LISTA PRINCIPAL E OS SUBMENUS (AUDIO, CONTROLES, JOGO)
	case menu.config:
		var _linhas = conf_linhas();
		var _qtd = array_length(_linhas);

		//NOS CONTROLES SO A LINHA DO LAYOUT E SELECIONAVEL
		if(conf_sub != menu_conf.controles and (_up xor _down))
		{
			conf_indice = (conf_indice + _down - _up + _qtd) mod _qtd;
			som_tocar(snd_menu_select_03);
		}

		switch(conf_sub)
		{
			case noone:
				if(conf_indice == menu_conf.idioma)
				{
					if(_enter or _left or _right)
					{
						global.linguagem = !global.linguagem;
						som_tocar(snd_menu_select_02);
					}
				}
				else if(_enter)
				{
					som_tocar(snd_menu_select_01);
					conf_sub = conf_indice;
					conf_indice = 0;
					conf_resetar_anim();
				}
				break;

			case menu_conf.audio:
				//APERTAR MUDA 10%, SEGURAR VAI MUDANDO SOZINHO
				var _mudar = _right - _left;
				if(_right_hold xor _left_hold) timer_press++;
				else timer_press = 0;
				if(timer_press > 30)
				{
					timer_press = 24;
					_mudar = _right_hold - _left_hold;
				}
				if(_mudar != 0)
				{
					if(conf_indice == 0) global.musica	  = clamp(global.musica + _mudar * .1, 0, 1);
					else				 global.som_geral = clamp(global.som_geral + _mudar * .1, 0, 1);
					som_tocar(snd_menu_select_02);
				}
				break;

			case menu_conf.controles:
				conf_indice = 0;
				if(_left xor _right)
				{
					var _qtd_layouts = array_length(global.layouts_imputs);
					trocar_comandos((global.meus_imputs + _right - _left + _qtd_layouts) mod _qtd_layouts);
					som_tocar(snd_menu_select_02);
				}
				break;

			//JOGO: TELA CHEIA E TREMOR LIGA/DESLIGA
			case menu_conf.jogo:
				if(_enter)
				{
					if(conf_indice == 0)
					{
						global.full_screen = !global.full_screen;
						window_set_fullscreen(global.full_screen);
					}
					else global.shake = !global.shake;
					som_tocar(snd_menu_select_01);
				}
				break;
		}

		if(_voltar)
		{
			som_tocar(snd_menu_erro_02);
			jogo_salvar();
			if(conf_sub == noone)
			{
				estado = menu.principal;
			}
			else
			{
				conf_indice = conf_sub; //VOLTA COM A OPÇAO QUE TAVA ABERTA SELECIONADA
				conf_sub = noone;
				conf_resetar_anim();
			}
		}

		//ANIMANDO AS LINHAS
		_qtd = array_length(conf_linhas());
		if(array_length(conf_x) != _qtd) conf_resetar_anim();
		for(var i = 0; i < _qtd; i++)
		{
			var _sel = (i == conf_indice);
			conf_x[i]	  = lerp(conf_x[i], _sel ? 8 : 0, .24 - i * .01);
			conf_alpha[i] = lerp(conf_alpha[i], _sel ? 1 : .35, .2);
		}
		break;
	#endregion

	#region RANKS
	//RECORDES: QUALQUER TECLA DE VOLTAR OU CONFIRMAR VOLTA PRO MENU
	case menu.ranks:
		if(_voltar or _enter)
		{
			som_tocar(snd_menu_erro_02);
			estado = menu.principal;
		}
		break;
	#endregion

	#region TABELA DOS BLOCOS
	//SETAS ANDAM NA GRADE (6 POR LINHA), ESC/ENTER VOLTA
	case menu.blocos:
		var _nb = array_length(blocos_catalogo());
		var _antes = blocos_sel;
		if(_left)	blocos_sel = (blocos_sel - 1 + _nb) mod _nb;
		if(_right)	blocos_sel = (blocos_sel + 1) mod _nb;
		if(_up)		blocos_sel = (blocos_sel - 6 + _nb) mod _nb;
		if(_down)	blocos_sel = (blocos_sel + 6) mod _nb;
		if(blocos_sel != _antes) som_tocar(snd_menu_select_03);
		if(_voltar or _enter)
		{
			som_tocar(snd_menu_erro_02);
			estado = menu.principal;
		}
		break;
	#endregion

	#region CREDITOS
	//CREDITOS: O TEXTO VAI SUBINDO. QUALQUER TECLA VOLTA
	case menu.creditos:
		creditos_y -= .28;
		if(_voltar or _enter)
		{
			som_tocar(snd_menu_erro_02);
			estado = menu.principal;
		}
		break;
	#endregion
}

//ZOOM DO FUNDO E BALANÇO DO TITULO
esc_fundo = lerp(esc_fundo, esc_fundo_lerp, .1);
angle_title = sin(timer_title) * 1.8;
