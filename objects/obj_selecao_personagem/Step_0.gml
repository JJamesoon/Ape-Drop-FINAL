//VERSUS: A SELEÇAO DOS DOIS JOGADORES TEM A LOGICA PROPRIA (SCR_COOP)
if(vs) { versus_sel_step(); exit; }

//ANIMAÇOES: O PERSONAGEM ESCOLHIDO CRESCE, OS OUTROS DIMINUEM
timer += .06;
brilho_t++;

var _total = array_length(global.skins);
for(var i = 0; i < _total; i++)
{
	esc[i] = lerp(esc[i], i == indice ? 1.04 : 1, .2);
	painel_sobe[i] = lerp(painel_sobe[i], i == indice ? (conf >= 0 ? 14 : 6) : 0, .25);
	ativa[i] = lerp(ativa[i], i == indice ? 1 : 0, .15);
}

//QUANDO ALGUEM CONFIRMA, OS OUTROS ESCURECEM E CAEM E O ESCOLHIDO VAI PRO MEIO
out_k = lerp(out_k, conf >= 0 ? 1 : 0, .16);
sel_dx = lerp(sel_dx, (conf >= 0 and conf_longo) ? room_width / 2 - x_personagem(conf_i) : 0, .12);
flash *= .86;

//ANEIS DE ONDA
for(var i = array_length(aneis) - 1; i >= 0; i--)
{
	var _an = aneis[i];
	if(_an.atraso > 0) { _an.atraso--; continue; }
	_an.r += _an.v;
	_an.v *= .95;
	_an.a -= .03;
	if(_an.a <= 0) array_delete(aneis, i, 1);
}

//FAGULHAS
for(var i = array_length(fagulhas) - 1; i >= 0; i--)
{
	var _f = fagulhas[i];
	_f.x += _f.vx;
	_f.y += _f.vy;
	_f.vx *= .97;
	_f.vy += .08;
	_f.life--;
	if(_f.life <= 0) array_delete(fagulhas, i, 1);
}

//FAGULHAS SUBINDO DO PAINEL ESCOLHIDO (ENFEITE)
if(conf < 0 and (brilho_t mod 4) == 0 and global.pers_liberados[indice])
{
	var _cs = selecao_cores(indice);
	array_push(fagulhas, { x : x_personagem(indice) + random_range(-SEL_LARG / 2 + 6, SEL_LARG / 2 - 6), y : SEL_TOPO + SEL_ALT - 4, vx : random_range(-.2, .2), vy : -random_range(.5, 1.3), life : irandom_range(40, 70), dur : 70, cor : choose(_cs[0], _cs[2], c_white), t : choose(1, 2) });
}

//CONFIRMANDO: A ANIMAÇAO MANDA (SEM IMPUT ATE ACABAR)
if(conf >= 0) { selecao_conf_passo(); exit; }

//NAO ACEITA IMPUT DURANTE A TRANSIÇAO
if(instance_exists(obj_transisao)) exit;

//IMPUTS
var _left	= keyboard_check_pressed(ord("A")) or keyboard_check_pressed(vk_left);
var _right	= keyboard_check_pressed(ord("D")) or keyboard_check_pressed(vk_right);
var _enter	= keyboard_check_pressed(vk_space) or keyboard_check_pressed(vk_enter);
var _voltar	= keyboard_check_pressed(vk_escape);

//ESQUERDA/DIREITA TROCA O PERSONAGEM (DA A VOLTA). O NOVO PAINEL DA UM "POP" E SOLTA FAGULHAS
if(_left or _right)
{
	indice = (indice + _right - _left + _total) mod _total;
	som_tocar(snd_menu_select_01, .05);
	esc[indice] = 1.18;
	var _cn = selecao_cores(indice);
	selecao_explodir(x_personagem(indice), SEL_TOPO + SEL_ALT - 6, 10, [_cn[0], _cn[2], c_white]);
	brilho_t = 60;	//O BRILHO COMEÇA A PASSAR NO PAINEL NOVO NA HORA
}

//A TREMIDA DE 'SEM MOEDA' VAI PARANDO
shake_msg = lerp(shake_msg, 0, .15);

//CONFIRMAR: SE JA E LIBERADO, ESCOLHE (COM A ANIMAÇAO) E DEPOIS VAI PRO JOGO (OU PRO PLAYER 2, NO COOP)
if(_enter)
{
	if(global.pers_liberados[indice])
	{
		selecao_confirmar();
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
			var _cb = selecao_cores(indice);
			selecao_explodir(x_personagem(indice), SEL_TOPO + SEL_ALT / 2, 30, [_cb[0], _cb[2], c_white, #FFE66B]);
			selecao_anel(x_personagem(indice), SEL_TOPO + SEL_ALT / 2, #FFE66B, 0);
			flash = .6;
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
