//A BALA REBATIDA PELO REFLEXO ATRAVESSA ATE O BLOCO QUE ELA ESCOLHEU
if(refletida and instance_exists(alvo)) exit;
//LASER COM BLOCO CHAO COLADO NAS FACES: SENAO A BALA NASCIA DENTRO DO BLOCO E SUMIA NA HORA. ATRAVESSA O PRIMEIRO BLOCO
if(!refletida and point_distance(x, y, origem_x, origem_y) < 34) exit;
instance_destroy();
