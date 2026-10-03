

//OBJETO DE TESTE ANTIGO: MOSTRA EM QUAL LINHA DA GRADE ELE ESTA E VAI DESCENDO DEVAGAR
var _x = (x + CEL/2) + (cols-1);
var _y = (y + CEL/2) - CEL*2;

draw_text(x, y, _y div CEL)

//PAUSA CURTA (HITSTOP): NAO DESCE
if(global.pause_timer ) exit;
y+= .5;

