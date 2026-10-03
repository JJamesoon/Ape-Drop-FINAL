
//PAUSA CURTA (HITSTOP): NAO MEXE
if(global.pause_timer) 
{
	exit;
}

//A LINHA DESLIZA ATE A ALTURA DELA (QUANDO O NIVEL SOBE)
y = lerp(y, meu_y, .2);
