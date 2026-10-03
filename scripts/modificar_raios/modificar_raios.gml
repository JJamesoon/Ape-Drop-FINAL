// OS RECURSOS DE SCRIPT MUDARAM PARA A V2.3.0; VEJA
// HTTPS://HELP.YOYOGAMES.COM/HC/EN-US/ARTICLES/360005277377 PARA OBTER MAIS INFORMAÇÕES
//MUDA A FORÇA DOS RAIOS QUE SAEM DA LINHA (EFEITO QUANDO O NIVEL SOBE)
function modificar_raios(_power = 18, _obj_linha = obj_linha)
{
	with(_obj_linha)
	{
		intensidade = _power;
		tam_raio = 5; 
	}
}