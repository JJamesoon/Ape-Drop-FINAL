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