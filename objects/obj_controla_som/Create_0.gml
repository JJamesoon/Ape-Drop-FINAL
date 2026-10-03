//CONTROLA A MUSICA E O VOLUME. E PERSISTENTE: EXISTE SO UM NO JOGO TODO
//E CRIADO PELO SOM_INICIAR_CONTROLE() (NAO PRECISA COLOCAR NA ROOM)
if(instance_number(obj_controla_som) > 1)
{
	instance_destroy();
	exit;
}

//CARREGANDO O SAVE UMA VEZ, QUANDO O JOGO ABRE
jogo_carregar();

//ACELERAÇAO DA MUSICA NO ARCADE (PITCH: 1 = NORMAL)
#macro MUSICA_POR_MINUTO	.02		//A CADA MINUTO DE PARTIDA...
#macro MUSICA_TEMPO_MAX		.1		//...ATE ESSE MAXIMO
#macro MUSICA_PILHA			.15		//PILHA NO TOPO
#macro MUSICA_PILHA_INICIO	.4		//COMEÇA A ACELERAR QUANDO A PILHA PASSA DE 40% DA ARENA
#macro MUSICA_FEBRE			.08
#macro MUSICA_MAX			1.3

musica_atual	= noone;	//ASSET DA MUSICA
musica_id		= noone;	//SOM TOCANDO AGORA
pitch_musica	= 1;	//VELOCIDADE ATUAL DA MUSICA (MUDA SUAVE)

//QUAL MUSICA TOCA EM CADA ROOM
musica_da_room = function()
{
	switch(room)
	{
		case rm_menu:
		case rm_menu_mobile:
		case rm_selecao:
			return snd_musica_retro_1;
		case rm_arcade:
			return snd_musica_retro_2;
		case rm_versus:
		case rm_coop:
			return snd_musica_game;
	}
	return musica_atual; //ROOM SEM MUSICA DEFINIDA: CONTINUA A QUE TA TOCANDO
}

//TOCA UMA MUSICA EM LOOP (TROCA A QUE TAVA TOCANDO)
tocar_musica = function(_musica)
{
	//JA TA TOCANDO ESSA MUSICA, NAO REINICIA
	if(_musica == musica_atual and audio_is_playing(musica_id)) exit;

	if(musica_id != noone) audio_stop_sound(musica_id);
	musica_atual = _musica;
	musica_id = noone;

	if(_musica == noone) exit;

	musica_id = audio_play_sound(_musica, 10, true, 0);
	audio_sound_gain(musica_id, global.musica, 1000); //FADE IN DE 1 SEGUNDO
	volume_aplicado = global.musica;
}

//VOLUME QUE JA FOI APLICADO NA MUSICA (O STEP VE SE MUDOU)
volume_aplicado = global.musica;

//COMEÇA A MUSICA DA ROOM ATUAL
tocar_musica(musica_da_room());
