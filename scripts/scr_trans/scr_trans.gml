//TRANSIÇAO DE ROOM: FECHA A CORTINA PRETA, TROCA PRA _ROOM E ABRE DE NOVO (OBJ_TRANSISAO)
function scr_trans(_room){
	var _trans = instance_create_depth(0, 0, 0, obj_transisao);
	_trans.prox_room = _room;
}