//CRIA A PEÇA SORTEADA E JA SORTEIA A SEGUINTE
if(global.prox_especie == "inimigo" or global.prox_especie == "bomba" or global.prox_especie == "cabecudo")
{
	instance_create_layer(x, y, "Blocos", obj_inimigo, { bomba : global.prox_especie == "bomba", cabecudo : global.prox_especie == "cabecudo" });
	global.debug_bloco = "";
	instance_destroy();
}
else
{
	var _pai = criar_pecas(global.prox_tipo, global.prox_cor, global.prox_fantasmas);
	if(global.prox_gelo) peca_colocar_gelo(_pai.meus_filhos);	//A PEÇA INTEIRA DE GELO
	if(global.prox_especie == "gelatina" or global.prox_especie == "buraco") bloco_virar_sozinho(_pai, global.prox_especie);
	if(global.debug_bloco != "") debug_aplicar(_pai);	//ESCOLHIDA NO MENU DE DEBUG
}
peca_sortear_proxima();
