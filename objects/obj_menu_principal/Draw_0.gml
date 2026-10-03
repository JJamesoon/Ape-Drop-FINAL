//DESENHO DO MENU DO PC
var _centro_x = room_width/2;
var _centro_y = room_height/2;
var _sombra = #0E071B;

//FUNDO (COM ZOOM CONFORME A TELA)
draw_sprite_ext(spr_menu_fundo, 0, _centro_x, _centro_y, esc_fundo, esc_fundo, 0, c_white, 1);

#region TELA DE TITULO: PERSONAGENS CORRENDO NA BORDA
if(estado == menu.inicio)
{
	var _frame = get_timer() / 100000;
	for(var i = 0; i < array_length(players); i++)
	{
		var p = players[i];
		draw_sprite_ext(skin_sprite(p.skin, red_corrida2), _frame, p.x, p.y, -1, 1, p.angle, c_white, 1);
	}
}
#endregion

#region MENU PRINCIPAL
if(estado == menu.principal)
{
	//BOTOES DO MEIO UM EMBAIXO DO OUTRO (O SELECIONADO SOBE UM POUCO E FICA ACESO)
	var _marg = 3;
	for(var i = 0; i < sprite_get_number(spr_menu); i++)
	{
		var _y = 200 + (_marg + sprite_get_height(spr_menu)) * i + array_y_menu[i];
		var _x = _centro_x + random_range(-shake_msg[i], shake_msg[i]);

		draw_sprite_ext(spr_menu, i, _x, _y, 1, 1, 0, c_white, array_alpha[i]);

		//BRILHO VERMELHO DO MODO INDISPONIVEL
		gpu_set_fog(true, c_red, 0, 1);
		draw_sprite_ext(spr_menu, i, _x, _y, 1, 1, 0, c_white, alpha_fog_msg[i]);
		gpu_set_fog(false, c_white, 0, 1);
	}

	//CONFIG (ESQUERDA) E CREDITOS (DIREITA)
	draw_sprite_ext(spr_menu_conf, 0, _centro_x - sprite_get_width(spr_menu) + 10 + array_x_menu_h[0], room_height*.54, 1, 1, 0, c_white, array_alpha_hor[0]);
	draw_sprite_ext(spr_menu_conf, 2, _centro_x + sprite_get_width(spr_menu) - 10 + array_x_menu_h[1], room_height*.54, 1, 1, 0, c_white, array_alpha_hor[1]);
}
#endregion

var _esc = .4;
//BLOCOS DE DECORAÇAO EM CIMA (APARECEM NO MENU PRINCIPAL)
draw_sprite_ext(spr_menu_blocos, 0, 0, 0, _esc, _esc, 0, c_white, alpha_bg_blocos);

//TITULO
draw_sprite_ext(spr_bg_ape, 0, _centro_x + 1, y_title + 1, 1.4, 1.4, angle_title, _sombra, alpha_title);
draw_sprite_ext(spr_bg_ape, 0, _centro_x, y_title, 1.4, 1.4, angle_title, c_white, alpha_title);

//"FEITO POR" EMBAIXO E O "APERTE ESPAÇO" PISCANDO
draw_sprite_ext(spr_bg_made_in, 0, _centro_x + 1, room_height - 8 + 1, 1, 1, 0, _sombra, alpha_title);
draw_sprite_ext(spr_bg_made_in, 0, _centro_x, room_height - 8, 1, 1, 0, c_white, alpha_title);

draw_sprite_ext(spr_bg_press, 0, _centro_x + 1, room_height - 115 + 1, 1, 1, 0, _sombra, _alpha);
draw_sprite_ext(spr_bg_press, 0, _centro_x, room_height - 115, 1, 1, 0, c_white, _alpha);

draw_set_font(fnt_hud);

#region VERSAO (TELA DE TITULO)
if(estado == menu.inicio)
{
	draw_set_halign(fa_left);
	draw_set_valign(fa_bottom);
	draw_text_color(5, room_height - 3, "V1.0.0", #C7CFDD, #C7CFDD, #C7CFDD, #C7CFDD, alpha_title);
}
#endregion

#region VERSUS / COOP
if(estado == menu.versus)
{
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _opcoes = [texto("versus"), texto("coop")];
	var _w = 130, _h = 24;
	for(var i = 0; i < 2; i++)
	{
		var _sel = (indice_versus == i);
		var _y = 215 + 32 * i + y_versus[i];
		var _a = _sel ? 1 : .5;
		draw_sprite_stretched_ext(spr_menu_confg, 0, _centro_x - _w/2, _y - _h/2, _w, _h, c_white, _a);
		draw_text_color(_centro_x, _y, _opcoes[i], c_white, c_white, c_white, c_white, _a);
	}
}
#endregion

#region CONFIGURAÇOES
if(alpha_conf > .01)
{
	//LINHAS DA TELA DE CONFIGURAÇAO ATUAL E O TITULO DO PAINEL
	var _linhas = conf_linhas();
	var _qtd = array_length(_linhas);
	var _px = 20;					//X DO PAINEL
	var _pw = 280;					//LARGURA DO PAINEL
	var _th = sprite_get_height(spr_caixa_setings);
	var _titulo = texto("title_confg");
	switch(conf_sub)
	{
		case menu_conf.audio:		_titulo = texto("audio");	break;
		case menu_conf.controles:	_titulo = texto("control");	break;
		case menu_conf.jogo:		_titulo = texto("op_game");	break;
	}

	draw_set_alpha(alpha_conf);
	//BARRA DE TITULO E JANELA
	draw_sprite_stretched(spr_caixa_setings, 0, _px, 25, _pw, _th);
	draw_sprite_stretched(spr_menu_janela, 0, _px, 25 + _th, _pw, 30 + 25 * _qtd);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text_color(_px + 4, 26, _titulo, c_white, c_white, c_white, c_white, alpha_conf);

	for(var i = 0; i < min(_qtd, array_length(conf_x)); i++)
	{
		var _y = 25 + _th + 12 + 25 * i;
		var _x = _px + 10 + conf_x[i];
		var _a = conf_alpha[i] * alpha_conf;

		//LINHAS DE FUNDO DE CADA OPÇAO
		var _max = ceil(max(75, string_width(_linhas[i]) + 20));
		draw_sprite_stretched(spr_menu_linhas_2, 0, _px + 1, _y + 2, _max, 11);
		draw_sprite(spr_menu_linhas_1, 0, _px + 1 + _max, _y + 2);
		draw_sprite_stretched(spr_menu_linhas_3, 0, _px + 1 + _max + sprite_get_width(spr_menu_linhas_1), _y + 2, _pw - _max - 2 - sprite_get_width(spr_menu_linhas_1), 11);

		draw_text_color(_x, _y, _linhas[i], c_white, c_white, c_white, c_white, _a);

		//VALOR DE CADA OPÇAO (LADO DIREITO)
		var _vx = _px + _pw - 50;
		var _vy = _y + 7;
		draw_set_halign(fa_center);
		switch(conf_sub)
		{
			case noone:
				if(i == menu_conf.idioma) draw_text_color(_vx, _y, texto("idioma_nome"), c_white, c_white, c_white, c_white, _a);
				break;
			case menu_conf.audio:
				var _vol = i == 0 ? global.musica : global.som_geral;
				draw_sprite_ext(spr_menu_som, 0, _vx, _vy, 1, 1, 0, c_white, _a);
				draw_sprite_ext(spr_menu_som, 1, _vx - 37 + _vol * 40, _vy, 1, 1, 0, c_white, _a);
				break;
			case menu_conf.controles:
				var _t = global.imputs;
				var _valor = "";
				switch(i)
				{
					case 0: _valor = "< 0" + string(global.meus_imputs + 1) + " >";				break;
					case 1: _valor = tecla_nome(_t.left) + " / " + tecla_nome(_t.rigth);	break;
					case 2: _valor = tecla_nome(_t.jump);		break;
					case 3: _valor = tecla_nome(_t.soco);		break;
					case 4: _valor = tecla_nome(_t.soco_press);	break;
					case 5: _valor = tecla_nome(_t.giro);		break;
					case 6: _valor = tecla_nome(_t.acelerar);	break;
					case 7: _valor = tecla_nome(_t.dash);		break;
					case 8: _valor = tecla_nome(_t.down) + " + " + tecla_nome(_t.soco); break;
				}
				//NOS CONTROLES AS TECLAS FICAM SEMPRE VISIVEIS
				draw_text_color(_vx, _y, _valor, c_white, c_white, c_white, c_white, alpha_conf);
				break;
			case menu_conf.jogo:
				var _ligado = i == 0 ? global.full_screen : global.shake;
				draw_sprite_ext(spr_menu_certo, _ligado, _vx, _vy, .5, .5, 0, c_white, _a);
				break;
		}
		draw_set_halign(fa_left);
	}
	draw_set_alpha(1);
}
#endregion

#region RANKS
//MESMO PAINEL DAS CONFIGURAÇOES: BARRA DE TITULO, JANELA E UMA LINHA POR RECORDE (VALOR NA DIREITA)
if(alpha_ranks > .01)
{
	var _px = 20, _pw = 280;
	var _th = sprite_get_height(spr_caixa_setings);
	var _seg = floor(global.tempo_de_jogo);
	var _tempo = string(_seg div 3600) + "H " + string_replace_all(string_format((_seg div 60) mod 60, 2, 0), " ", "0") + "M";
	var _itens = [
		[global.linguagem == 0 ? "RECORDE ARCADE" : "ARCADE RECORD", string(global.record_1)],
		[global.linguagem == 0 ? "RECORDE COOP" : "COOP RECORD", string(global.record_coop)],
		[global.linguagem == 0 ? "MOEDAS" : "COINS", string(global.moedas)],
		[global.linguagem == 0 ? "TEMPO JOGADO" : "TIME PLAYED", _tempo],
	];
	var _qtd = array_length(_itens);
	draw_set_alpha(alpha_ranks);
	draw_sprite_stretched(spr_caixa_setings, 0, _px, 25, _pw, _th);
	draw_sprite_stretched(spr_menu_janela, 0, _px, 25 + _th, _pw, 30 + 25 * _qtd);
	draw_set_font(fnt_hud);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text_color(_px + 4, 26, "RANKS", c_white, c_white, c_white, c_white, alpha_ranks);
	for(var i = 0; i < _qtd; i++)
	{
		var _y = 25 + _th + 12 + 25 * i;
		var _max = ceil(max(75, string_width(_itens[i][0]) + 20));
		draw_sprite_stretched(spr_menu_linhas_2, 0, _px + 1, _y + 2, _max, 11);
		draw_sprite(spr_menu_linhas_1, 0, _px + 1 + _max, _y + 2);
		draw_sprite_stretched(spr_menu_linhas_3, 0, _px + 1 + _max + sprite_get_width(spr_menu_linhas_1), _y + 2, _pw - _max - 2 - sprite_get_width(spr_menu_linhas_1), 11);
		draw_set_halign(fa_left);
		draw_text_color(_px + 10, _y, _itens[i][0], c_white, c_white, c_white, c_white, alpha_ranks);
		draw_set_halign(fa_center);
		draw_text_color(_px + _pw - 50, _y, _itens[i][1], c_yellow, c_yellow, c_yellow, c_yellow, alpha_ranks);
	}
	draw_set_halign(fa_left);
	draw_set_alpha(1);
}
#endregion

#region TABELA DOS BLOCOS
//MESMO ESTILO DOS OUTROS PAINEIS: BARRA DE TITULO E JANELA. NA ESQUERDA A GRADE COM TODOS OS BLOCOS (OS QUE AINDA NAO
//APARECERAM FICAM SO A SOMBRA COM "?"), NA DIREITA O SELECIONADO GRANDE COM O NOME, QUANDO APARECE E O QUE FAZ
if(alpha_blocos > .01)
{
	var _a = alpha_blocos;
	var _cat = blocos_catalogo();
	var _nb = array_length(_cat);
	var _vistos = 0;
	for(var i = 0; i < _nb; i++) if(bloco_visto(_cat[i].id)) _vistos++;
	var _pt = global.linguagem == 0;
	draw_set_alpha(_a * .7);
	draw_set_color(c_black);
	draw_rectangle(0, 0, room_width, room_height, false);
	draw_set_alpha(_a);
	var _px = 60, _pw = 600, _py = 40, _ph = 290;
	var _th = sprite_get_height(spr_caixa_setings);
	draw_sprite_stretched_ext(spr_caixa_setings, 0, _px, _py, _pw, _th, c_white, _a);
	draw_sprite_stretched_ext(spr_menu_janela, 0, _px, _py + _th, _pw, _ph - _th, c_white, _a);
	draw_set_font(fnt_hud);
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
	draw_text_color(_px + 4, _py + 1, _pt ? "BLOCOS" : "BLOCKS", c_white, c_white, c_white, c_white, _a);
	draw_set_halign(fa_right);
	var _cont = string(_vistos) + "/" + string(_nb) + (_pt ? " DESCOBERTOS" : " FOUND");
	draw_text_color(_px + _pw - 6, _py + 1, _cont, c_yellow, c_yellow, c_yellow, c_yellow, _a);
	//GRADE (6 POR LINHA)
	var _gx = _px + 22, _gy = _py + _th + 22, _ce = 44;
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	for(var i = 0; i < _nb; i++)
	{
		var _cx = _gx + (i mod 6) * _ce + _ce / 2, _cy = _gy + (i div 6) * _ce + _ce / 2;
		var _sel = i == blocos_sel;
		var _visto = bloco_visto(_cat[i].id);
		draw_set_color(_sel ? #3A3460 : #1A1932);
		draw_rectangle(_cx - 19, _cy - 19, _cx + 19, _cy + 19, false);
		draw_set_color(_sel ? c_yellow : #424C6E);
		draw_rectangle(_cx - 19, _cy - 19, _cx + 19, _cy + 19, true);
		if(_sel) draw_rectangle(_cx - 18, _cy - 18, _cx + 18, _cy + 18, true);
		var _ie = _sel ? 1.6 + .1 * sin(current_time / 150) : 1.4;
		bloco_icone_desenhar(_cat[i].id, _cx, _cy + 1, _ie, !_visto, _a);
		if(!_visto) draw_text_transformed_color(_cx, _cy, "?", 1.2, 1.2, 0, #7A86A8, #7A86A8, #7A86A8, #7A86A8, _a);
	}
	//DETALHE DO SELECIONADO
	var _dx = _px + 22 + 6 * _ce + 18, _dw = _px + _pw - 16 - _dx;
	var _s = _cat[blocos_sel];
	var _visto = bloco_visto(_s.id);
	var _dcx = _dx + _dw / 2;
	draw_set_color(#1A1932);
	draw_rectangle(_dx, _gy - 4, _dx + _dw, _py + _ph - 14, false);
	draw_set_color(#424C6E);
	draw_rectangle(_dx, _gy - 4, _dx + _dw, _py + _ph - 14, true);
	bloco_icone_desenhar(_s.id, _dcx, _gy + 40, 3, !_visto, _a);
	if(!_visto) draw_text_transformed_color(_dcx, _gy + 38, "?", 2.5, 2.5, 0, #7A86A8, #7A86A8, #7A86A8, #7A86A8, _a);
	var _nome = _visto ? _s.nome[_pt ? 0 : 1] : "???";
	draw_text_transformed_color(_dcx + 1, _gy + 91, _nome, 1.2, 1.2, 0, #0E071B, #0E071B, #0E071B, #0E071B, _a);
	draw_text_transformed_color(_dcx, _gy + 90, _nome, 1.2, 1.2, 0, c_white, c_white, c_white, c_white, _a);
	var _quando = _s.min <= 0 ? (_pt ? "DESDE O COMEÇO" : "FROM THE START") : ((_pt ? "APARECE COM " : "SHOWS UP AT ") + string_format(_s.min, 1, frac(_s.min) == 0 ? 0 : 1) + " MIN");
	draw_text_transformed_color(_dcx, _gy + 110, _visto ? (_pt ? "DESBLOQUEADO" : "UNLOCKED") : (_pt ? "AINDA NÃO DESCOBERTO" : "NOT FOUND YET"), .7, .7, 0, _visto ? #8BFF32 : #92A1B9, _visto ? #8BFF32 : #92A1B9, _visto ? #8BFF32 : #92A1B9, _visto ? #8BFF32 : #92A1B9, _a);
	draw_text_transformed_color(_dcx, _gy + 124, _quando, .65, .65, 0, #C7CFDD, #C7CFDD, #C7CFDD, #C7CFDD, _a);
	var _desc = _visto ? _s.desc[_pt ? 0 : 1] : (_pt ? "JOGUE O ARCADE ATÉ ESSE BLOCO APARECER PRA DESCOBRIR O QUE ELE FAZ." : "PLAY ARCADE UNTIL THIS BLOCK SHOWS UP TO FIND OUT WHAT IT DOES.");
	draw_set_valign(fa_top);
	draw_text_ext_transformed_color(_dcx, _gy + 140, _desc, 14, (_dw - 16) / .7, .7, .7, 0, c_white, c_white, c_white, c_white, _a);
	//DICA
	draw_set_valign(fa_middle);
	draw_text_transformed_color(_px + _pw / 2, _py + _ph + 12, _pt ? "SETAS ESCOLHEM    ESC VOLTA" : "ARROWS CHOOSE    ESC BACK", .7, .7, 0, c_white, c_white, c_white, c_white, _a * .8);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
	draw_set_color(c_white);
}
#endregion

#region CREDITOS
if(estado == menu.creditos)
{
	draw_set_alpha(.75);
	draw_set_color(c_black);
	draw_rectangle(0, 0, room_width, room_height, false);
	draw_set_alpha(1);

	draw_set_font(fnt_creditos);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);

	//ALTURA DE CADA LINHA E ONDE O TEXTO ACABA
	var _cred = texto("creditos");
	var _alt = string_height("H") + 2;
	var _fim = -_alt * array_length(_cred);

	//QUANDO ACABA O TEXTO PARA DE SUBIR E MOSTRA A IMAGEM
	if(creditos_y < _fim)
	{
		creditos_y = _fim;
		alpha_img_creditos = lerp(alpha_img_creditos, 1, .1);
		draw_sprite_ext(spr_img_creditos, 0, _centro_x, _centro_y, .25, .25, 0, c_white, alpha_img_creditos);
	}

	for(var i = 0; i < array_length(_cred); i++)
	{
		var _y = creditos_y + _alt * i;
		draw_text_color(_centro_x + 1, _y + 2, _cred[i], #593080, #593080, #593080, #593080, 1);
		draw_text_color(_centro_x, _y, _cred[i], c_white, c_white, c_white, c_white, 1);
	}
}
#endregion

#region MENSAGEM "MODO INDISPONIVEL"
if(alpha_msg > .01)
{
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _txt = texto("indisponivel");
	var _w = string_width(_txt) + 16;
	var _h = string_height("H") + 8;
	draw_sprite_stretched_ext(spr_menu_confg, 0, _centro_x - _w/2, room_height - 50 - _h/2, _w, _h, c_white, alpha_msg);
	draw_text_color(_centro_x, room_height - 50, _txt, #92A1B9, #92A1B9, #92A1B9, #92A1B9, alpha_msg);
}
#endregion

#region DICAS DE TECLA (CANTO DE BAIXO)
if(estado != menu.inicio and estado != menu.creditos)
{
	draw_set_font(fnt_hud);
	draw_set_halign(fa_right);
	draw_set_valign(fa_middle);
	var _dicas = [texto("continar"), texto("voltar"), texto("selecionar")];
	for(var i = 0; i < 3; i++)
	{
		var _x = room_width - 34;
		var _y = room_height - 62 + 22 * i;
		draw_text_color(_x + 1, _y + 1, _dicas[i], c_black, c_black, c_black, c_black, 1);
		draw_text_color(_x, _y, _dicas[i], c_white, c_white, c_white, c_white, 1);
		draw_sprite_ext(spr_controles_gui, i, _x + 16, _y, .5, .5, 0, c_white, .8);
	}
}
#endregion

#region FRASE PASSANDO NO TOPO
draw_set_font(fnt_creditos);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var _frase = texto("Frase_play_test");
var _passo = string_width(_frase) + 60; //TAMANHO DA FRASE + ESPAÇO ATE A PROXIMA
frase_x -= .5;
if(frase_x < -_passo) frase_x += _passo;
//REPETE A FRASE ATE COBRIR A TELA (FUNCIONA MESMO TROCANDO DE IDIOMA)
for(var _x = frase_x; _x < room_width; _x += _passo)
{
	draw_text_color(_x + 1, 1, _frase, c_purple, c_purple, c_purple, c_purple, 1);
	draw_text_color(_x, 0, _frase, c_white, c_white, c_white, c_white, 1);
}
#endregion

//VOLTA O PADRAO DE DESENHO
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
