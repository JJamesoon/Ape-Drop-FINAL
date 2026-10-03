//ANIMAÇOES: O PERSONAGEM ESCOLHIDO CRESCE, OS OUTROS DIMINUEM
timer += .06;

var _total = array_length(global.skins);
for(var i = 0; i < _total; i++)
{
	esc[i] = lerp(esc[i], i == indice ? 1.04 : 1, .2);
	painel_sobe[i] = lerp(painel_sobe[i], i == indice ? 6 : 0, .25);
}

//NAO ACEITA IMPUT DURANTE A TRANSIÇAO
if(instance_exists(obj_transisao)) exit;

//IMPUTS
var _left	= keyboard_check_pressed(ord("A")) or keyboard_check_pressed(vk_left);
var _right	= keyboard_check_pressed(ord("D")) or keyboard_check_pressed(vk_right);
var _enter	= keyboard_check_pressed(vk_space) or keyboard_check_pressed(vk_enter);
var _voltar	= keyboard_check_pressed(vk_escape);

//ESQUERDA/DIREITA TROCA O PERSONAGEM (DA A VOLTA)
if(_left or _right)
{
	indice = (indice + _right - _left + _total) mod _total;
	som_tocar(snd_menu_select_01, .05);
}

//A TREMIDA DE 'SEM MOEDA' VAI PARANDO
shake_msg = lerp(shake_msg, 0, .15);

//CONFIRMAR: SE JA E LIBERADO, ESCOLHE E VAI PRO JOGO
if(_enter)
{
	if(global.pers_liberados[indice])
	{
		som_tocar(snd_menu_confirm_01);
		//COOP: O PLAYER 1 ESCOLHEU, AGORA E A VEZ DO PLAYER 2
		if(global.coop and jogador_escolhendo == 1)
		{
			global.skin_player_1 = indice;
			jogador_escolhendo = 2;
			indice = global.pers_liberados[global.skin_player_2] ? global.skin_player_2 : personagem.macaco;
		}
		else
		{
			if(jogador_escolhendo == 2) global.skin_player_2 = indice;
			else global.skin_player_1 = indice;
			jogo_salvar();
			scr_trans(prox_room);
		}
	}
	else
	{
		//BLOQUEADO: COMPRA SE TIVER MOEDAS
		var _preco = global.skins[indice].preco;
		if(global.moedas >= _preco)
		{
			global.moedas -= _preco;
			global.pers_liberados[indice] = true;
			jogo_salvar();
			som_tocar(snd_new_level);
			efeito_texto(texto("liberado"), x_personagem(indice), room_height/2 - 10, c_yellow, 1.3);
			esc[indice] = 1.2;
		}
		else
		{
			som_tocar(snd_menu_erro_04);
			efeito_texto(texto("sem_moedas"), x_personagem(indice), room_height/2 - 10, c_red, 1);
			shake_msg = 4;
		}
	}
}
//VOLTAR: VAI PRO MENU (CAINDO DIRETO NO MENU PRINCIPAL)
else if(_voltar)
{
	som_tocar(snd_menu_erro_02);
	//COOP: O PLAYER 2 VOLTANDO DEVOLVE A ESCOLHA PRO PLAYER 1
	if(jogador_escolhendo == 2)
	{
		jogador_escolhendo = 1;
		indice = global.skin_player_1;
	}
	else
	{
		global.menu_principal = true;
		scr_trans(menu_room());
	}
}
