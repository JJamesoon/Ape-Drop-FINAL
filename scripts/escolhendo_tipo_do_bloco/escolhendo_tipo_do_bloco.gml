// OS RECURSOS DE SCRIPT MUDARAM PARA A V2.3.0; VEJA
// HTTPS://HELP.YOYOGAMES.COM/HC/EN-US/ARTICLES/360005277377 PARA OBTER MAIS INFORMAÇÕES
//SORTEIA SE ESSE BLOCO VIRA UM TIPO ESPECIAL (CHAMADO PELO ALARM 1 DA PEÇA COM UM TIPO SORTEADO).
//CADA TIPO SO APARECE DEPOIS DO SEU TEMPO DE PARTIDA (BLOCO_LIBERADO E OS LIBERA_ NO SCR_PONTOS)
function escolhendo_tipo_do_bloco(_tipo)
{
	
	// "FANTASMA", "LASER", "RAIVOSO"
	//PRIMEIRO ELE VAI ESCOLHER OQUE SUPOSTAMENTE ELE PODED SSER, DPS DEPENDENDO DO QUE ELE QUER ER
	//VAI TER UMA CHANCE DE SER OU NAO SER
	var _chance;	
	switch(_tipo)
	{
		//FANTASMA: DESLIGADO AQUI (CHANCE 0). HOJE O FANTASMA VEM PELO SORTEIO DA PEÇA (PECA_COLOCAR_FANTASMAS)
		case "Fantasma":
		
			_chance = 0;
			if(random(100) <= _chance)
			{
				sou_normal = false //NAO É MAIS UM SIMPLES BLOCO
				sou_fantasma = true;
				
				//MASCARA ANTIGA (DESLIGADA)
				////MASK_FANTASMA = INSTANCE_CREATE_LAYER(X, Y, "BLOCOS", OBJ_MASK_FA);
				////MASK_FANTASMA.PAI = PAI;
				////MASK_FANTASMA.MEU_BLOCO = ID;
			}
			
			break;
		//ESPECIAL: 11% DE CHANCE (ERA 6), NO MAXIMO UM NA ARENA
		case "Especial":
			_chance = 11;
			if(!bloco_liberado(LIBERA_ESPECIAL)) break;

			if(random(100) <= _chance and global.bloco_especial == noone) 
			{
				sou_normal = false //NAO É MAIS UM SIMPLES BLOCO
				sou_especial = true;
				premio_especial = especial_sortear(); //JA SABE O QUE GUARDA (A VISAO ESPIRITUAL MOSTRA)
				global.bloco_especial = id;
			}
			
			break;
		//LASER: NO MAXIMO LASER_MAX NA ARENA
		case "Laser":
			if(!bloco_liberado(LIBERA_LASER)) break;
			_chance = chance_perigo() * 3; //SOBE A CADA LEVEL (SCR_PONTOS). O TRIPLO DOS OUTROS: O SORTEIO E POR BLOCO E ELE QUASE NAO APARECIA
			var _lasers = 0;
			with(obj_peca) if(sou_laser) _lasers++;
			if(_lasers >= LASER_MAX) break; //MAIS QUE ISSO FICA ROUBADO
			
			if(random(100) <= _chance) 
			{
				sou_normal = false //NAO É MAIS UM SIMPLES BLOCO
				sou_laser	= true;
				laser_lado	= random(100) < LASER_LADO_CHANCE; //PARTE DOS LASERS E A VARIANTE LATERAL
			}
			
			break;
		case "Sensor": //BLOCO SNIPER (SE JOGA NO PLAYER QUANDO ELE PASSA NA LINHA DELE)
			if(!bloco_liberado(LIBERA_SNIPER)) break;
			_chance = chance_perigo() + SNIPER_EXTRA; //SOBE A CADA LEVEL (SCR_PONTOS)
			if(random(100) <= _chance)
			{
				sou_normal = false; //PARECE UM BLOCO NORMAL, MAS NAO E
				sou_sensor = true;
			}
			break;
		//RAIO: AO SER DESTRUIDO CAI UM RAIO, OS OBJETOS FICAM AZUL AQUA E OS PONTOS DOBRAM (SCR_PONTOS, RAIO_ATIVAR).
		//NO MAXIMO UM NA ARENA E NAO APARECE COM O RAIO JA LIGADO
		case "Raio":
			if(!bloco_liberado(LIBERA_RAIO) or global.raio > 0) break;
			var _raios = 0;
			with(obj_peca) if(sou_raio) _raios++;
			if(_raios > 0) break;
			if(random(100) <= RAIO_CHANCE)
			{
				sou_normal = false; //NAO É MAIS UM SIMPLES BLOCO
				sou_raio = true;
			}
			break;
		//FUJAO: TEM MOEDA DENTRO E FOGE PELA GRADE QUANDO O PLAYER CHEGA PERTO (STEP DA PEÇA). NO MAXIMO UM NA ARENA
		case "Fujao":
			if(!bloco_liberado(LIBERA_FUJAO)) break;
			var _fujoes = 0;
			with(obj_peca) if(sou_fujao) _fujoes++;
			if(_fujoes > 0) break;
			if(random(100) <= FUJAO_CHANCE)
			{
				sou_normal = false; //NAO É MAIS UM SIMPLES BLOCO
				sou_fujao = true;
			}
			break;
		//PEDRA (SOLIDO): PRECISA DE DOIS GOLPES DO PLAYER PRA QUEBRAR. NAO TEM COR (NAO ENTRA NO ESPECIAL)
		case "Pedra":
			if(bloco_liberado(LIBERA_PEDRA) and random(100) <= PEDRA_CHANCE)
			{
				sou_normal = false; //NAO É MAIS UM SIMPLES BLOCO
				sou_pedra = true;
				vida_pedra = 2;
				cor_original = coloracao;
				coloracao = -1;
			}
			break;
		//RAIVOSA: A PEÇA INTEIRA VIRA RAIVOSA (CAI DIRETO SEM PARAR)
		//COLMEIA: PARADA, SOLTA ABELHAS QUE DESTROEM OS BLOCOS (STEP DA PEÇA). NAO TEM COR. NO MAXIMO UMA NA ARENA
		case "Colmeia":
			if(!bloco_liberado(LIBERA_COLMEIA) or blocos_contar("sou_colmeia") > 0) break;
			if(random(100) <= COLMEIA_CHANCE)
			{
				sou_normal = false; //NAO É MAIS UM SIMPLES BLOCO
				sou_colmeia = true;
				colmeia_timer = COLMEIA_PRIMEIRA;
				cor_original = coloracao;
				coloracao = -1;
			}
			break;
		//LENTO: DESTRUIDO, JOGA O FEITIÇO DE LENTIDAO NO PLAYER (DESTROY DA PEÇA). CONTINUA COM A COR. NO MAXIMO UM NA ARENA
		case "Lento":
			if(!bloco_liberado(LIBERA_LENTO) or blocos_contar("sou_lento") > 0) break;
			if(random(100) <= LENTO_CHANCE)
			{
				sou_normal = false; //NAO É MAIS UM SIMPLES BLOCO
				sou_lento = true;
			}
			break;
		case "Raivoso":
			if(!bloco_liberado(LIBERA_RAIVOSO)) break;
			_chance = chance_perigo(); //SOBE A CADA LEVEL (SCR_PONTOS)
			
			if(random(100) <= _chance)
			{
				var _irmaos = pai.meus_filhos;
				
				for(var i = 0; i < array_length(_irmaos); i++)
				{
					_irmaos[i].restar_variaveis_blocos();//RESETANDO GARANTO QUE TODOS VAO SERE O MSM
					_irmaos[i].cair_direto	= true;
					_irmaos[i].sou_raivoso	= true;
					_irmaos[i].sou_normal	= false //NAO É MAIS UM SIMPLES BLOCO
				}
			}
			
			break;
	}
}