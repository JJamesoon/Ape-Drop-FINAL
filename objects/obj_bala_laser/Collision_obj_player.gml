//ACERTOU O PLAYER: EMPURRA ELE PRO LADO CONTRARIO DA BALA (BALA REBATIDA PELO REFLEXO NAO MACHUCA)
if(refletida) exit;
if(pausa_em(x) or player_e_fantasma(other)) exit; //(O FANTASMA DO VERSUS NAO LEVA TIRO) //TIRO PARADO NO AR (TEMPO PARADO): NAO MACHUCA
other.levar_dano(sign(other.x - x));
instance_destroy();
