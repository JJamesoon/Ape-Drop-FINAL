//CONTROLE (GAMEPAD): VIRA AS TECLAS DO JOGO (IMPUTS)
gamepad_atualizar();

//VOLUME GERAL DE TODOS OS SONS
audio_master_gain(global.som_geral);

//VOLUME DA MUSICA MUDOU NAS CONFIGURAÇOES
if(global.musica != volume_aplicado and musica_id != noone)
{
	audio_sound_gain(musica_id, global.musica, 0);
	volume_aplicado = global.musica;
}

//MUSICA MAIS GRAVE ENQUANTO O JOGO TA PAUSADO.
//NO ARCADE ELA ACELERA: UM POUCO A CADA MINUTO DE PARTIDA, CONFORME A PILHA DE BLOCOS SOBE (MAIS PERTO DO TOPO,
//MAIS RAPIDA) E NA FEBRE
var _pitch = 1;
if(global.game_pause and !(variable_global_exists("congelar") and global.congelar > 0)) _pitch = .7; //O HITSTOP NAO MEXE NA MUSICA
else if(modo_arcade() and variable_global_exists("altura_pilha"))
{
	_pitch += min(MUSICA_TEMPO_MAX, MUSICA_POR_MINUTO * global.tempo_partida / 60);
	_pitch += MUSICA_PILHA * clamp((global.altura_pilha - MUSICA_PILHA_INICIO) / (1 - MUSICA_PILHA_INICIO), 0, 1);
	if(global.febre > 0) _pitch += MUSICA_FEBRE;
	_pitch = min(_pitch, MUSICA_MAX);
}
//A MUDANÇA DE VELOCIDADE E SUAVE
pitch_musica = lerp(pitch_musica, _pitch, .05);
if(musica_id != noone) audio_sound_pitch(musica_id, pitch_musica);

global.tempo_de_jogo += delta_time / 1000000; //EM SEGUNDOS
