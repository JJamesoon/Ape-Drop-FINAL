//SONS DO PLAYER (TOCA QUANDO ENTRA EM UM ESTADO NOVO)
if(estado != estado_som)
{
	switch(estado)
	{
		case state.jump:		if(velv < 0) som_tocar(snd_jump, .1); break;
		case state.giro:		som_tocar(snd_Giro, .1); giro_contar(); break; //CONTA OS GIROS SEGUIDOS (GIRO DE FOGO)
		case state.dash:		som_tocar(snd_roll, .1);	break;
		case state.dano:		som_tocar(hurt3);			break;
		case state.morte:		som_tocar(snd_player_morte);break;
	}
	estado_som = estado;
}

//DIREÇAO DO MOVIMENTO (-1, 0 OU 1) PRA ENCOSTAR PIXEL POR PIXEL
//MORTO: SEM COLISAO, O CORPO CAI PRA FORA DA TELA (NO COOP O JOGO NAO PAUSA QUANDO UM MORRE, E A COLISAO
//PRENDIA O CORPO ATRAVESSANDO O CHAO NUM LOOP INFINITO)
if(estado == state.morte) exit;

var _velh = sign(velh);
var _velv = sign(velv);
if(global.game_pause and !tempo_player_livre()) exit; //NO TEMPO PARADO SO O PLAYER ANDA

//FEITIÇO DO BLOCO LENTO: ANDA SO UMA PARTE DA VELOCIDADE POR FRAME (A GRAVIDADE TAMBEM FICA MAIS FRACA NO
//SCR_GRAVID, ENTAO O PULO TEM A MESMA ALTURA, SO QUE EM CAMERA LENTA)
var _f = lento > 0 ? LENTO_MULT : (rapido > 0 ? RAPIDO_MULT : 1);	//(RAPIDO: QUEBROU O BLOCO LENTO)
var _mh = velh * _f;
var _mv = velv * _f;

//COLISAO COM BLOCOS E PEÇAS (MENOS O FANTASMA E A GELATINA, O PLAYER PASSA POR DENTRO DELES)
//BATEU NA HORIZONTAL: ANDA ATE ENCOSTAR E PARA
if (solido(x + _mh, y))
{
    while (!solido(x + _velh, y))
    {
        x += _velh;
    }
	 velh = 0;
	 _mh = 0;
}

//BATEU NA VERTICAL (CHAO OU TETO): ANDA ATE ENCOSTAR E PARA
if (solido(x, y + _mv))
{
    while (!solido(x, y + _velv))
    {
        y += _velv;
    }
	
	//PODER DA CABEÇADA: PULANDO, BATEU A CABEÇA NUM BLOCO POR BAIXO -> QUEBRA ELE (COMO NO MARIO).
	//INIMIGO EM CIMA DO BLOCO MORRE JUNTO
	if(velv < 0 and tem_poder("cabeca"))
	{
		var _cima = peca_solida(x, y - 1);
		if(_cima != noone)
		{
			var _ini = collision_rectangle(_cima.bbox_left, _cima.bbox_top - 20, _cima.bbox_right, _cima.bbox_top, obj_inimigo, false, true);
			if(_ini != noone and _ini.vivo()) _ini.morrer_nocaute(sign(_ini.x - x + .1), true);
			bloco_golpe(_cima);
			audio_play_sound(snd_hit2, 1, false, 1, 0, .9);
			onda_choque(x, bbox_top, 30, 3, 16);
			shakes(4, 1);
			esc_x = 1.2 * image_xscale;
			esc_y = .8;
		}
	}
		velv = 0;
		_mv = 0;
}

//MOVE DE VERDADE
x += _mh;
y += _mv;