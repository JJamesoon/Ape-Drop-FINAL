//ARQUIVO ANTIGO: TUDO AQUI ESTA DESLIGADO (A VERSAO QUE O JOGO USA FICA NO CREATE DO OBJ_PECA)
//FUNCTION VELOCIDADE_H( _CASAS = -1, _SUPER, _POSSO_ANDAR = FALSE)
//{
//	VAR _IRMAOS = IRMAOS();
//	VAR _LIVRE = TRUE;
//	VAR _PARAR = FALSE
	
//	IF(!IRMANDADE)
//	{
//		//CHECA COLISAO 
//		IF(!PLACE_MEETING(X +(CEL/2) * _CASAS, Y, [OBJ_BLOCK, OBJ_PECA, OBJ_PAREDE])) PROX_X = X + CEL * _CASAS;
		
//		ALPHA_FOG = 1;
//		ESC = 1.15;
//		EXIT;
//	}
	
//	FOR(VAR I = 0; I < ARRAY_LENGTH(_IRMAOS); I++)
//	{
//		_IRMAOS[I].VELH = 0;
//		_IRMAOS[I].CASAS = 0;
//	}
	
//	IF(_PARAR) EXIT;
	
//	IF(!_POSSO_ANDAR)
//	{
//		IF(_SUPER)
//		{
//			FOR(VAR I = 0; I < ARRAY_LENGTH(_IRMAOS); I++)
//			{
//				WITH(_IRMAOS[I])
//				{
//					IF(PLACE_MEETING(X + _CASAS, Y, OBJ_PAREDE)) _LIVRE = FALSE;
//					VAR _PECA = INSTANCE_PLACE(X + _CASAS, Y, OBJ_PECA);
//					IF(_PECA)
//					{
//						IF(_PECA.PAI != PAI) _LIVRE = FALSE;
//					}
//				}
//			}
//		}ELSE
//		{
//			IF(PLACE_MEETING(X + _CASAS, Y, OBJ_PAREDE)) _LIVRE = FALSE;
//			VAR _PECA = INSTANCE_PLACE(X + _CASAS, Y, OBJ_PECA);
//			IF(_PECA)
//			{
//				_LIVRE = FALSE;
//			}
//		}
		
//		IF(_LIVRE) VELOCIDADE_H(_CASAS, _SUPER, TRUE);
//		ELSE
//		{
//			IF(_SUPER)
//			{
//				FOR(VAR I = 0; I < ARRAY_LENGTH(_IRMAOS); I++)
//				{
//					_IRMAOS[I].ALPHA_FOG = 1
//					_IRMAOS[I].ESC = 1.15;
				
//				}
//			}ELSE
//			{
//				ALPHA_FOG = 1
//				ESC = 1.15;
//			}
//		}
//	}ELSE
//	{
//		FOR(VAR I = 0; I < ARRAY_LENGTH(_IRMAOS); I++)
//		{
//			WITH(_IRMAOS[I])
//			{
//				IF(_SUPER)
//				{
//					ESVAZIAR_GRID();
//					PROX_X = _IRMAOS[I].X + CEL * _CASAS;
//				}
				
//				ALPHA_FOG = 1
//				ESC = 1.15;
//			}
//		}
//		IF(!_SUPER)
//		{
//			ESVAZIAR_GRID();
//			PROX_X = X + CEL * _CASAS;
//			QUEBRAR_IRMANDADE(PAI.TIMER_MOVE, CRIAR_CHAO);
//		}
//	}
//}

