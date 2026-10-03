//GRADE: A CADA 15 FRAMES CONFERE COM OS BLOCOS PARADOS (SE UMA CASA FICAR ERRADA, A LINHA CHEIA NAO FECHAVA)
if(!global.game_pause and (current_time div 250) != grade_conferida)
{
	grade_conferida = current_time div 250;
	var _c = grid_reparar(id);
	if(_c > 0 and TESTE_AUTO) show_debug_message("[TESTE] GRADE CONSERTADA: " + string(_c) + " casas");
}

//PEÇAS DUPLAS: A SEGUNDA PEÇA DO PAR NASCE NUMA COLUNA ONDE ELA CABE (A MESMA BUSCA DA ONDA DE PEÇAS)
if(!global.game_pause and dupla_espera > 0)
{
	dupla_espera--;
	if(dupla_espera == 0 and !criar_peca_onda())
	{
		dupla_tentativas++;
		if(dupla_tentativas < 20) dupla_espera = 5;
	}
}

//BEGIN STEP: TREMIDA DA TELA. CADA FRAME ELA FICA MAIS FRACA ATE ACABAR
if (shake_duration > 0) {
    shake_duration--;
    
	shake_intensity *= .9;
	
    global.shake_x = random_range(-shake_intensity, shake_intensity);
    global.shake_y = random_range(-shake_intensity, shake_intensity);
//SEM TREMIDA: TUDO PARADO
} else {
    global.shake_x = 0;
    global.shake_y = 0;
}