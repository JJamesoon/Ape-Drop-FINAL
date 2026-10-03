//GIRA, CAI COM GRAVIDADE E VAI PERDENDO A VELOCIDADE PRO LADO
ang += vel*5;
velv += .2;
velh = lerp(velh, 0, .08);

//JA CAIU O SUFICIENTE E O PLACAR DE BLOCOS TA LIGADO: VOA ATE A CAIXINHA DO TIPO DELA NO HUD
if((timer <= 0 or y > obj_area.y + sprite_get_height(spr_area)*.9) and velv > 3 and obj_area.somar_blocos_hud)
{
	x = lerp(x, obj_area.blocos_cx[blocos_caixa.pos_x][tipo], .065);
	y = lerp(y, obj_area.blocos_cx[blocos_caixa.pos_y][tipo] + 20, .065);
	var _dist = point_distance(x, y,  obj_area.blocos_cx[blocos_caixa.pos_x][tipo],  obj_area.blocos_cx[blocos_caixa.pos_y][tipo]);
	//CHEGOU PERTO: VAI SUMINDO
	if(_dist < 20) 
	{
		image_alpha -= .02
		if(image_alpha <= 0) instance_destroy();
	}
} 
//SENAO SO CONTINUA CAINDO
else 
{
	x += velh;
	y += velv;
	timer--;
}

//SEMPRE VAI APAGANDO UM POUCO
image_alpha -= .02;

//DESENHA CADA FRAME DO SPRITE UM POUCO DESLOCADO (DA UM VOLUME DE BLOCO 3D)
for(var i = 0; i < image_number; i++)
{
	draw_sprite_ext(sprite_index, i,x - i, y + i, 1, 1, ang, image_blend, image_alpha)
}


