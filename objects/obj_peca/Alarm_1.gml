//SORTEIA UM TIPO ESPECIAL PRA PEÇA NORMAL. CADA TIPO SO APARECE DEPOIS DO SEU TEMPO DE PARTIDA (BLOCO_LIBERADO):
//O CHOOSE CONTINUA COM OS 4 (O TIPO QUE AINDA NAO FOI LIBERADO SO NAO ACONTECE), ENTAO A CHANCE DE CADA UM NAO MUDA
if(!sou_normal) exit;
//O SENSOR SO EXISTE NO ARCADE (ELE PROCURA O OBJ_PLAYER)
if(modo_arcade()) escolhendo_tipo_do_bloco(choose("Raivoso", "Especial", "Laser", "Sensor"));
else escolhendo_tipo_do_bloco(choose("Raivoso", "Especial", "Laser"));
//RAIO, FUJAO, PEDRA, COLMEIA E LENTO TEM O SORTEIO DELES (SE ENTRASSEM NO CHOOSE, OS OUTROS TIPOS APARECERIAM MENOS).
//SO NO ARCADE, E PARA NO PRIMEIRO QUE SAIR
if(modo_arcade())
{
	var _proprios = ["Raio", "Fujao", "Pedra", "Colmeia", "Lento"];
	for(var i = 0; i < array_length(_proprios) and sou_normal; i++) escolhendo_tipo_do_bloco(_proprios[i]);
}
