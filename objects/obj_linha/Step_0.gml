
//PAUSA CURTA (HITSTOP): NAO MEXE
if(global.pause_timer) 
{
	exit;
}

//A LINHA DESLIZA ATE A ALTURA DELA (QUANDO O NIVEL SOBE)
y = lerp(y, meu_y, .2);

//FESTA DE SUBIR DE ANDAR (RODA COM O JOGO PARADO): ARPEJO SUBINDO E FAISCAS DOURADAS ESPIRRANDO DA REGUA
if(global.andar_pausa > 0)
{
	var _t = ANDAR_PAUSA - global.andar_pausa;	//FRAMES DESDE QUE SUBIU
	if(_t mod 5 == 0 and festa_nota < 7)
	{
		som_nota(5 + festa_nota * 2, .45);
		festa_nota++;
	}
	if(global.andar_pausa > 20)
	{
		var _larg = instance_exists(minha_area) ? minha_area.sprite_width : 160;
		repeat(4) array_push(faiscas, [x + random(_larg), y, random_range(-1.2, 1.2), -random_range(1, 3.8), irandom_range(22, 40)]);
	}
}
for(var i = array_length(faiscas) - 1; i >= 0; i--)
{
	faiscas[i][0] += faiscas[i][2];
	faiscas[i][1] += faiscas[i][3];
	faiscas[i][3] += .09;
	faiscas[i][4]--;
	if(faiscas[i][4] <= 0) array_delete(faiscas, i, 1);
}
