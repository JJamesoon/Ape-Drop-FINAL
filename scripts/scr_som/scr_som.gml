//SONS DO JOGO==================================

//TOCA UM EFEITO SONORO. _VARIAR_PITCH DEIXA O SOM UM POUCO DIFERENTE A CADA VEZ (EX: .1)
function som_tocar(_som, _variar_pitch = 0, _prioridade = 1)
{
	var _pitch = 1 + random_range(-_variar_pitch, _variar_pitch);
	return audio_play_sound(_som, _prioridade, false, 1, 0, _pitch);
}

//NOTAS MUSICAIS==================================
//A MUSICA DO ARCADE E EM DO MAIOR. OS SONS QUE VEM EM SEQUENCIA (MOEDAS, LETRAS, QUIQUE DO GIRO, ESPECIAL, SETAS DO
//CUBO) TOCAM NOTAS DA ESCALA PENTATONICA DE DO (DO RE MI SOL LA): SEMPRE COMBINAM COM A MUSICA E VAO SUBINDO
//A CADA ACERTO SEGUIDO. O SND_NOTA E UM "PLIM" EM DO; O PITCH VIRA AS OUTRAS NOTAS
#macro MOEDA_SEQ_TEMPO		900		//MS: PEGOU OUTRA MOEDA ANTES DISSO, A NOTA SOBE (SENAO VOLTA PRA PRIMEIRA)
global.moeda_seq = 0;		//MOEDAS PEGAS EM SEQUENCIA
global.moeda_ultima = 0;	//QUANDO PEGOU A ULTIMA (CURRENT_TIME)

//TOCA A NOTA _GRAU DA ESCALA (0 = DO, 1 = RE, 2 = MI, 3 = SOL, 4 = LA, 5 = DO DE CIMA, 6 = RE DE CIMA...)
function som_nota(_grau, _volume = .6)
{
	var _escala = [0, 2, 4, 7, 9];
	_grau = max(0, _grau);
	var _semitons = _escala[_grau mod 5] + 12 * (_grau div 5);
	return audio_play_sound(snd_nota, 1, false, _volume, 0, power(2, _semitons / 12));
}

//MOEDA PEGA: O "PLIM" DA MOEDA E UMA NOTA QUE SOBE A CADA MOEDA PEGA EM SEQUENCIA (IGUAL UMA ESCALINHA)
function som_moeda()
{
	if(current_time - global.moeda_ultima < MOEDA_SEQ_TEMPO) global.moeda_seq++;
	else global.moeda_seq = 0;
	global.moeda_ultima = current_time;
	audio_play_sound(snd_pegar_moeda, 1, false, .6);
	som_nota(5 + min(global.moeda_seq, 9), .5);
}

//SOM DE FECHAR LINHA, FICA MAIS AGUDO QUANTO MAIOR O COMBO
function som_linha(_combo = 1)
{
	var _sons = [snd_fechar_linha_1, snd_fechar_linha_2, snd_fechar_linha_3, snd_fechar_linha_4, snd_fechar_linha_5, snd_fechar_linha_6,
				 snd_fechar_linha_7, snd_fechar_linha_8, snd_fechar_linha_9, snd_fechar_linha_10, snd_fechar_linha_11, snd_fechar_linha_12,
				 snd_fechar_linha_13, snd_fechar_linha_14, snd_fechar_linha_15, snd_fechar_linha_16, snd_fechar_linha_17, snd_fechar_linha_18];

	var _i = clamp(_combo - 1, 0, array_length(_sons) - 1);
	som_tocar(_sons[_i]);
}

//GARANTE QUE O CONTROLADOR DE SOM EXISTE (CHAMAR NO CREATE DOS CONTROLADORES DE CADA ROOM)
function som_iniciar_controle()
{
	if(!instance_exists(obj_controla_som)) instance_create_depth(0, 0, 0, obj_controla_som);
}
