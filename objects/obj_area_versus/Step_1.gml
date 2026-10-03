//BEGIN STEP DO VERSUS: TREMIDA DA TELA DO PLAYER 2. CADA FRAME ELA FICA MAIS FRACA ATE ACABAR
if (shake_duration > 0) {
    shake_duration--;
    
	shake_intensity *= .9;
	
    global.shake_x_2 = random_range(-shake_intensity, shake_intensity);
    global.shake_y_2 = random_range(-shake_intensity, shake_intensity);
//SEM TREMIDA: TUDO PARADO
} else {
    global.shake_x_2 = 0;
    global.shake_y_2 = 0;
}




