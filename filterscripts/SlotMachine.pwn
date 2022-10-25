#include <a_samp>
#include <zcmd>
#include <dof2>
#include <streamer>

#define SlotMachineFolder "SlotMachines/SlotMachine%i.ini"
#define MAX_SLOTMACHINE 100
#define DIALOG_SLOTMACHINE 20000
#define MINIMUM_BET 5000

enum TLucky {TDName[16]}
new PLucky[][TLucky] = {"ld_slot:r_69", "ld_slot:grapes", "ld_slot:cherry", "ld_slot:bell", "ld_slot:bar2_o", "ld_slot:bar1_o"};
enum InfoSlotMachine {SmObject, DiceIcon, Text3D:TextoSm, bool:Occupied, Jackpot};
new DataSlotMachine[MAX_SLOTMACHINE][InfoSlotMachine];
new PlayerText:TDLucky[5], bool:Playing[MAX_PLAYERS], RandLucky[3][MAX_PLAYERS]; 
new Spin[MAX_PLAYERS], TimerSpin[MAX_PLAYERS], Prize[MAX_PLAYERS], SmID[MAX_PLAYERS], EditingSM[MAX_PLAYERS];

public OnGameModeInit() return LoadSlotMachines();
public OnPlayerConnect(playerid)
{
	TDLucky[0] = CreatePlayerTextDraw(playerid, 331.000000, 130.000000, "_");
	PlayerTextDrawAlignment(playerid, TDLucky[0], 2), PlayerTextDrawFont(playerid, TDLucky[0], 1); 
	PlayerTextDrawLetterSize(playerid, TDLucky[0], 0.500000, 6.000000), PlayerTextDrawUseBox(playerid, TDLucky[0], 1); 
	PlayerTextDrawBoxColor(playerid, TDLucky[0], 255), PlayerTextDrawTextSize(playerid, TDLucky[0], 18.000000, -175.000000);

	TDLucky[1] = CreatePlayerTextDraw(playerid, 247.000000, 130.000000, "ld_slot:grapes");
	PlayerTextDrawFont(playerid, TDLucky[1], 4), PlayerTextDrawLetterSize(playerid, TDLucky[1], 0.500000, 1.000000);
	PlayerTextDrawUseBox(playerid, TDLucky[1], 1), PlayerTextDrawTextSize(playerid, TDLucky[1], 57.000000, 73.000000);

	TDLucky[2] = CreatePlayerTextDraw(playerid, 302.000000, 130.000000, "ld_slot:cherry");
	PlayerTextDrawFont(playerid, TDLucky[2], 4), PlayerTextDrawLetterSize(playerid, TDLucky[2], 0.500000, 1.000000);
	PlayerTextDrawUseBox(playerid, TDLucky[2], 1), PlayerTextDrawTextSize(playerid, TDLucky[2], 57.000000, 73.000000);

	TDLucky[3] = CreatePlayerTextDraw(playerid, 357.000000, 130.000000, "ld_slot:bell");
	PlayerTextDrawFont(playerid, TDLucky[3], 4), PlayerTextDrawLetterSize(playerid, TDLucky[3], 0.500000, 1.000000);
	PlayerTextDrawUseBox(playerid, TDLucky[3], 1), PlayerTextDrawTextSize(playerid, TDLucky[3], 57.000000, 73.000000);

	TDLucky[4] = CreatePlayerTextDraw(playerid, 263.000000, 107.000000, "CACA-NIQUEL");
	PlayerTextDrawFont(playerid, TDLucky[4], 3), PlayerTextDrawLetterSize(playerid, TDLucky[4], 0.700000, 2.000000);
	PlayerTextDrawSetOutline(playerid, TDLucky[4], 1);
	return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	new String[128], Float:PozX, Float:PozY, Float:PozZ;
	if(newkeys == KEY_YES)
	{
		if(EditingSM[playerid] == 2)
		{
			GetPlayerPos(playerid, PozX, PozY, PozZ), DOF2_SetFloat(GetSlotMachine(SmID[playerid]), "PozX", PozX), DOF2_SetFloat(GetSlotMachine(SmID[playerid]), "PozY", PozY), DOF2_SetFloat(GetSlotMachine(SmID[playerid]), "PozZ", PozZ), DOF2_SaveFile();
		    DestroyDynamic3DTextLabel(DataSlotMachine[SmID[playerid]][TextoSm]), DataSlotMachine[SmID[playerid]][TextoSm] = CreateDynamic3DTextLabel("{FF0033}Caça-níquel\n{FFFFFF}Aperte F para jogar", -1, PozX, PozY, PozZ, 100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0, -1, 10.0);
		    format(String, sizeof(String), "{FF0033}Localização do Caça-níquel: {FFFFFF}%i {FF0033}setada com sucesso.", SmID[playerid]), SendClientMessage(playerid, -1, String), EditingSM[playerid] = 0;
		}
	}
	if(newkeys == KEY_SECONDARY_ATTACK)
	{
		for(new i; i < MAX_SLOTMACHINE; i++)
		{
			if(!DOF2_FileExists(GetSlotMachine(i))) continue;
		    if(IsPlayerInRangeOfPoint(playerid, 1.0, DOF2_GetFloat(GetSlotMachine(i), "PozX"), DOF2_GetFloat(GetSlotMachine(i), "PozY"), DOF2_GetFloat(GetSlotMachine(i), "PozZ")) && EditingSM[playerid] == 0 && Playing[playerid] == false)
		    {
		      	if(DataSlotMachine[i][Occupied] == true) return SendClientMessage(playerid, -1, "{FF0000}[Cassino] Este Caça-níquel está ocupado no momento!");
		      	else
	  			{
				  	ShowPlayerDialog(playerid, DIALOG_SLOTMACHINE, DIALOG_STYLE_INPUT, "{FF0000}#{FF0033}Cassino - Caça-níquel","{87CEFA}Digite o valor que deseja apostar\n\nAposta mínima: {228B22}R${FFFFFF}5000","Inserir","Sair"), Playing[playerid] = true, DataSlotMachine[SmID[playerid] = i][Occupied] = true;
					break;
				}
			}
		}
	}
	return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_SLOTMACHINE)
	{
		new String[64];
	    if(!response) return Playing[playerid] = false, DataSlotMachine[SmID[playerid]][Occupied] = false;
	    Prize[playerid] = strval(inputtext);
	    if(Prize[playerid] < 5000) return format(String, sizeof(String), "{FF0000}[Cassino] A aposta mínima e de R$%d.", MINIMUM_BET), SendClientMessage(playerid, -1, String), Playing[playerid] = false, DataSlotMachine[SmID[playerid]][Occupied] = false;
	    if(GetPlayerMoney(playerid) < Prize[playerid]) return SendClientMessage(playerid, -1, "{FF0000}[Cassino] Você não possui a quantia apostada."), Playing[playerid] = false, DataSlotMachine[SmID[playerid]][Occupied] = false;
		DataSlotMachine[SmID[playerid]][Jackpot] = DOF2_GetInt(GetSlotMachine(SmID[playerid]), "Jackpot"), GivePlayerMoney(playerid, -Prize[playerid]), SetTimerEx("SpinSlotMachine", 1000, false, "i", playerid), ApplyAnimation(playerid, "CASINO", "Slot_in", 4.1, 0, 0, 0, 1, 1, 1);
	}
	return 1;
}
public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	if(EditingSM[playerid] == 1) 
	{
		if(response == EDIT_RESPONSE_FINAL)
		{
			SendClientMessage(playerid, -1, "{FF0033}Posicione-se em frente ao {FFFFFF}Caça-níquel {FF0033}e aperte {FFFFFF}Y."), DOF2_SaveFile(), EditingSM[playerid] = 2;
	        DOF2_SetFloat(GetSlotMachine(SmID[playerid]), "PozXX", fX), DOF2_SetFloat(GetSlotMachine(SmID[playerid]), "PozYY", fY), DOF2_SetFloat(GetSlotMachine(SmID[playerid]), "PozZZ", fZ);
			DOF2_SetFloat(GetSlotMachine(SmID[playerid]), "RotXX", fRotX), DOF2_SetFloat(GetSlotMachine(SmID[playerid]), "RotYY", fRotY), DOF2_SetFloat(GetSlotMachine(SmID[playerid]), "RotZZ", fRotZ);
		}
		if(response == EDIT_RESPONSE_CANCEL) return EditingSM[playerid] = 0;
	}
	return 1;
}
CMD:criarcn(playerid)
{
	new String[256], Float:PozX, Float:PozY, Float:PozZ;
	if(EditingSM[playerid] != 0) return SendClientMessage(playerid, -1, "{FF0000}[Cassino] Você está editando um objeto.");
	if(Playing[playerid] == true) return SendClientMessage(playerid, -1, "{FF0000}[Cassino] Você não pode criar um Caça-níquel enquanto você está jogando.");
	for(new i; i < MAX_SLOTMACHINE; i++)
	{
		if(DOF2_FileExists(GetSlotMachine(i))) continue;
		DOF2_CreateFile(GetSlotMachine(i)), DOF2_SetInt(GetSlotMachine(i), "SmID", i), DOF2_SetInt(GetSlotMachine(i), "Jackpot", 0), DOF2_SetFloat(GetSlotMachine(i), "PozX", PozX), DOF2_SetFloat(GetSlotMachine(i), "PozY", PozY), DOF2_SetFloat(GetSlotMachine(i), "PozZ", PozZ), DOF2_SaveFile();
		GetPlayerPos(playerid, PozX, PozY, PozZ), format(String, sizeof(String), "{FF0033}Caça-níquel ID: {FFFFFF}%i {FF0033}criado, Segure {FFFFFF}ESPAÇO {FF0033}caso queira mudar o ângulo de visão!", i), SendClientMessage(playerid, -1, String);
		DataSlotMachine[i][SmObject] = CreateObject(2325, PozX+1, PozY+1, PozZ, 0.0, 0.0, 0.0), SmID[playerid] = i, EditingSM[playerid] = 1, EditObject(playerid, DataSlotMachine[i][SmObject]);
		break;	
	}	
	return 1;
}
CMD:delcn(playerid)
{
    new String[128];
    if(EditingSM[playerid] != 0) return SendClientMessage(playerid, -1, "{FF0000}[Cassino] Você está editando um objeto.");
    if(Playing[playerid] == true) return SendClientMessage(playerid, -1, "{FF0000}[Cassino] Você não pode deletar um Caça-níquel enquanto você está jogando.");
 	for(new i; i < MAX_SLOTMACHINE; i++)
    {
    	if(!DOF2_FileExists(GetSlotMachine(i))) continue;
    	if(IsPlayerInRangeOfPoint(playerid, 1.0, DOF2_GetFloat(GetSlotMachine(i), "PozX"), DOF2_GetFloat(GetSlotMachine(i), "PozY"), DOF2_GetFloat(GetSlotMachine(i), "PozZ")))
    	{
	   		if(DataSlotMachine[i][Occupied] == true) return SendClientMessage(playerid, -1, "{FF0000}[Cassino] Você não pode deletar um Caça-níquel enquanto alguém está jogando.");
		    GivePlayerMoney(playerid, DOF2_GetInt(GetSlotMachine(i), "Jackpot")), DOF2_RemoveFile(GetSlotMachine(i)), DestroyDynamic3DTextLabel(DataSlotMachine[i][TextoSm]), DestroyObject(DataSlotMachine[i][SmObject]), format(String, sizeof(String), "{FF0033}Você deletou o Caça-níquel de ID: {FFFFFF}%d{FF0033}.", i), SendClientMessage(playerid, -1 , String);
			break;
		}
	}
	return 1;
}
CMD:editcn(playerid)
{
    new String[256];
    if(EditingSM[playerid] != 0) return SendClientMessage(playerid, -1, "{FF0000}[Cassino] Você ja está editando um objeto.");
    if(Playing[playerid] == true) return SendClientMessage(playerid, -1, "{FF0000}[Cassino] Você não pode editar um Caça-níquel enquanto você está jogando.");
	for(new i; i < MAX_SLOTMACHINE; i++)
    {
		if(!DOF2_FileExists(GetSlotMachine(i))) continue;
    	if(IsPlayerInRangeOfPoint(playerid, 1.0, DOF2_GetFloat(GetSlotMachine(i), "PozX"), DOF2_GetFloat(GetSlotMachine(i), "PozY"), DOF2_GetFloat(GetSlotMachine(i), "PozZ")))
    	{
	   		if(DataSlotMachine[i][Occupied] == true) return SendClientMessage(playerid, -1, "{FF0000}[Cassino] Você não pode editar um Caça-níquel enquanto alguém está jogando.");
	  	    SmID[playerid] = i, EditingSM[playerid] = 1, format(String, sizeof(String), "{FF0033}Você esta editando o caça-níquel {FF0033}Segure {FFFFFF}ESPAÇO {FF0033}caso queira mudar o ângulo de visão!", SmID[playerid]), SendClientMessage(playerid, -1 , String);
  			EditObject(playerid, DataSlotMachine[i][SmObject]);
			break;
		}
	}
	return 1;
}
CMD:infocn(playerid)
{
    new String[256];
    if(EditingSM[playerid] != 0) return SendClientMessage(playerid, -1, "{FF0000}[Cassino] Você está editando um objeto.");
    if(Playing[playerid] == true) return SendClientMessage(playerid, -1, "{FF0000}[Cassino] Você não pode ver informações de um Caça-níquel enquanto você está jogando.");
	for(new i; i < MAX_SLOTMACHINE; i++)
    {
    	if(!DOF2_FileExists(GetSlotMachine(i))) continue;
    	if(IsPlayerInRangeOfPoint(playerid, 1.0, DOF2_GetFloat(GetSlotMachine(i), "PozX"), DOF2_GetFloat(GetSlotMachine(i), "PozY"), DOF2_GetFloat(GetSlotMachine(i), "PozZ")))
    	{
	    	format(String, sizeof(String), "{FF0033}Este é o caça-níquel {FFFFFF}%d{FF0033} e possui o valor de {228B22}R${FFFFFF}%i {FF0033}em seu {FFFFFF}JACKPOT{FF0033}.", i, DOF2_GetInt(GetSlotMachine(i), "Jackpot")), SendClientMessage(playerid, -1 , String);
			break;
		}
	}
	return 1;
}
forward StopAnim(playerid); public StopAnim(playerid)
{
	new Float:X, Float:Y, Float:Z;
	ClearAnimations(playerid), GetPlayerPos(playerid, X, Y, Z), SetPlayerPos(playerid, X, Y, Z+1), DataSlotMachine[SmID[playerid]][Occupied] = false, SmID[playerid] = -1;
	return 1;
}
forward SpinSlotMachine(playerid); public SpinSlotMachine(playerid)
{
	Spin[playerid]++;
	if(Spin[playerid] == 1)
	{
		for(new i; i < 5; i++) {PlayerTextDrawShow(playerid, TDLucky[i]);}
		TimerSpin[playerid] = SetTimerEx("SpinSlotMachine", 50, true, "i", playerid), ApplyAnimation(playerid, "CASINO", "Slot_wait", 4.1, 0, 0, 0, 1, 1, 1), PlayerPlaySound(playerid, 4201, 0.0, 0.0, 0.0);
	}
	if(Spin[playerid] < 38) return PlayerTextDrawSetString(playerid, TDLucky[1], PLucky[random(6)][TDName]), PlayerTextDrawSetString(playerid, TDLucky[2], PLucky[random(6)][TDName]), PlayerTextDrawSetString(playerid, TDLucky[3], PLucky[random(6)][TDName]);
	if(Spin[playerid] == 39) return PlayerPlaySound(playerid, 4202, 0.0, 0.0, 0.0), PlayerTextDrawSetString(playerid, TDLucky[1], PLucky[RandLucky[0][playerid] = random(6)][TDName]), PlayerTextDrawSetString(playerid, TDLucky[2], PLucky[random(6)][TDName]), PlayerTextDrawSetString(playerid, TDLucky[3], PLucky[random(6)][TDName]);
	if(Spin[playerid] < 69) return PlayerTextDrawSetString(playerid, TDLucky[2], PLucky[random(6)][TDName]), PlayerTextDrawSetString(playerid, TDLucky[3], PLucky[random(6)][TDName]);
	if(Spin[playerid] == 69) return PlayerPlaySound(playerid, 4202, 0.0, 0.0, 0.0), PlayerTextDrawSetString(playerid, TDLucky[2], PLucky[RandLucky[1][playerid] = random(6)][TDName]), PlayerTextDrawSetString(playerid, TDLucky[3], PLucky[random(6)][TDName]);
	if(Spin[playerid] < 99) return PlayerTextDrawSetString(playerid, TDLucky[3], PLucky[random(6)][TDName]);
	if(Spin[playerid] == 99) return PlayerPlaySound(playerid, 4202, 0.0, 0.0, 0.0), PlayerTextDrawSetString(playerid, TDLucky[3], PLucky[RandLucky[2][playerid] = random(6)][TDName]);
    if(Spin[playerid] == 100) return RewardPrize(playerid);
	if(Spin[playerid] == 130)
	{
		for(new i; i < 5; i++) {PlayerTextDrawHide(playerid, TDLucky[i]);}
		Spin[playerid] = 0, RandLucky[0][playerid] = 0, RandLucky[1][playerid] = 0, RandLucky[2][playerid] = 0, Playing[playerid] = false, Prize[playerid] = 0, KillTimer(TimerSpin[playerid]);
	}
	return 0;
}
RewardPrize(playerid)
{
	new String[128];
	if(RandLucky[0][playerid] == 0)
	{
	    if(RandLucky[0][playerid] == RandLucky[1][playerid] && RandLucky[1][playerid] == RandLucky[2][playerid]) 
	   	{
	   		new PrizeJackpot[MAX_PLAYERS];
	   		PrizeJackpot[playerid] = DataSlotMachine[SmID[playerid]][Jackpot]+Prize[playerid]*10, GameTextForPlayer(playerid, "~p~JACKPOT", 1400, 6), format(String, sizeof(String), "{A020F0}[Cassino] Parabéns você conseguiu um {FFFFFF}JACKPOT {A020F0}e recebeu a quantia de {228B22}R${FFFFFF}%i{A020F0}.", PrizeJackpot[playerid]), SendClientMessage(playerid, -1, String);
		   	GivePlayerMoney(playerid, PrizeJackpot[playerid]), DOF2_SetInt(GetSlotMachine(SmID[playerid]), "Jackpot", DataSlotMachine[SmID[playerid]][Jackpot] = 0), DOF2_SaveFile(), ApplyAnimation(playerid, "CASINO", "Slot_win_out", 4.1, 0, 0, 0, 1, 1, 1), PlayerPlaySound(playerid, 5461, 0.0, 0.0, 0.0), SetTimerEx("StopAnim", 7000, false, "i", playerid);
		}
		if(RandLucky[0][playerid] != RandLucky[1][playerid] || RandLucky[1][playerid] != RandLucky[2][playerid]) return GameTextForPlayer(playerid, "~r~Voce PERDEU", 1400, 6), ApplyAnimation(playerid, "CASINO", "Slot_lose_out", 4.1, 0, 0, 0, 1, 1, 1), PlayerPlaySound(playerid, 4203, 0.0, 0.0, 0.0), DOF2_SetInt(GetSlotMachine(SmID[playerid]), "Jackpot", DataSlotMachine[SmID[playerid]][Jackpot]+Prize[playerid]), DOF2_SaveFile(), SetTimerEx("StopAnim", 4000, false, "i", playerid);
	}
	if(RandLucky[0][playerid] == 4)
	{
	    if(RandLucky[0][playerid] == RandLucky[1][playerid] && RandLucky[1][playerid] == RandLucky[2][playerid]) return GameTextForPlayer(playerid, "~y~8X APOSTA", 1400, 6), format(String, sizeof(String), "{FFD700}[Cassino] Parabéns você recebeu a quantia de {228B22}R${FFFFFF}%i{FFD700}.", Prize[playerid]*8), SendClientMessage(playerid, -1, String), GivePlayerMoney(playerid, Prize[playerid]*8),
		ApplyAnimation(playerid, "CASINO", "manwind", 4.1, 0, 0, 0, 1, 1, 1), PlayerPlaySound(playerid, 5448, 0.0, 0.0, 0.0), SetTimerEx("StopAnim", 2000, false, "i", playerid);
		if(RandLucky[0][playerid] != RandLucky[1][playerid] || RandLucky[1][playerid] != RandLucky[2][playerid]) return GameTextForPlayer(playerid, "~r~Voce PERDEU", 1400, 6), ApplyAnimation(playerid, "CASINO", "Roulette_lose", 4.1, 0, 0, 0, 1, 1, 1), PlayerPlaySound(playerid, 4203, 0.0, 0.0, 0.0), DOF2_SetInt(GetSlotMachine(SmID[playerid]), "Jackpot", DataSlotMachine[SmID[playerid]][Jackpot]+Prize[playerid]), DOF2_SaveFile(), SetTimerEx("StopAnim", 2000, false, "i", playerid);
	}
	if(RandLucky[0][playerid] == 5)
	{
	    if(RandLucky[0][playerid] == RandLucky[1][playerid] && RandLucky[1][playerid] == RandLucky[2][playerid]) return GameTextForPlayer(playerid, "~b~6X APOSTA", 1400, 6), format(String, sizeof(String), "{436EEE}[Cassino] Parabéns você recebeu a quantia de {228B22}R${FFFFFF}%i{436EEE}.", Prize[playerid]*6), SendClientMessage(playerid, -1, String), GivePlayerMoney(playerid, Prize[playerid]*6),
		ApplyAnimation(playerid, "CASINO", "manwind", 4.1, 0, 0, 0, 1, 1, 1), PlayerPlaySound(playerid, 5448, 0.0, 0.0, 0.0), SetTimerEx("StopAnim", 2000, false, "i", playerid);
		if(RandLucky[0][playerid] != RandLucky[1][playerid] || RandLucky[1][playerid] != RandLucky[2][playerid]) return GameTextForPlayer(playerid, "~r~Voce PERDEU", 1400, 6), ApplyAnimation(playerid, "CASINO", "Roulette_lose", 4.1, 0, 0, 0, 1, 1, 1), PlayerPlaySound(playerid, 4203, 0.0, 0.0, 0.0), DOF2_SetInt(GetSlotMachine(SmID[playerid]), "Jackpot", DataSlotMachine[SmID[playerid]][Jackpot]+Prize[playerid]), DOF2_SaveFile(), SetTimerEx("StopAnim", 2000, false, "i", playerid);
	}
	if(RandLucky[0][playerid] == 1 || RandLucky[0][playerid] == 2 || RandLucky[0][playerid] == 3)
	{
	    if(RandLucky[0][playerid] == RandLucky[1][playerid] && RandLucky[1][playerid] == RandLucky[2][playerid]) return GameTextForPlayer(playerid, "~g~3X APOSTA", 1400, 6), format(String, sizeof(String), "{32CD32}[Cassino] Parabéns você recebeu a quantia de {228B22}R${FFFFFF}%i{32CD32}.", Prize[playerid]*3), SendClientMessage(playerid, -1, String), GivePlayerMoney(playerid, Prize[playerid]*3),
		ApplyAnimation(playerid, "CASINO", "manwinb", 4.1, 0, 0, 0, 1, 1, 1), PlayerPlaySound(playerid, 5448, 0.0, 0.0, 0.0), SetTimerEx("StopAnim", 2000, false, "i", playerid);
		if(RandLucky[0][playerid] != RandLucky[1][playerid] || RandLucky[1][playerid] != RandLucky[2][playerid]) return GameTextForPlayer(playerid, "~r~Voce PERDEU", 1400, 6), ApplyAnimation(playerid, "CASINO", "Roulette_lose", 4.1, 0, 0, 0, 1, 1, 1), PlayerPlaySound(playerid, 4203, 0.0, 0.0, 0.0), DOF2_SetInt(GetSlotMachine(SmID[playerid]), "Jackpot", DataSlotMachine[SmID[playerid]][Jackpot]+Prize[playerid]), DOF2_SaveFile(), SetTimerEx("StopAnim", 2000, false, "i", playerid);
	}
	return 1;
}
LoadSlotMachines()
{
	for(new i; i < MAX_SLOTMACHINE; i++)
	{
	    if(!DOF2_FileExists(GetSlotMachine(i))) continue;
		DataSlotMachine[i][DiceIcon] = CreateDynamicMapIcon(DOF2_GetFloat(GetSlotMachine(i), "PozX"), DOF2_GetFloat(GetSlotMachine(i), "PozY"), DOF2_GetFloat(GetSlotMachine(i), "PozZ"), 25, 0, 0, 0, -1, 50.0), DataSlotMachine[i][TextoSm] = CreateDynamic3DTextLabel("{FF0033}Caça-níquel\n{FFFFFF}Aperte F para jogar", -1, DOF2_GetFloat(GetSlotMachine(i), "PozX"), DOF2_GetFloat(GetSlotMachine(i), "PozY"), DOF2_GetFloat(GetSlotMachine(i), "PozZ"), 100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0, -1, 10.0);
		DataSlotMachine[i][SmObject] = CreateObject(2325, DOF2_GetFloat(GetSlotMachine(i), "PozXX"), DOF2_GetFloat(GetSlotMachine(i), "PozYY"), DOF2_GetFloat(GetSlotMachine(i), "PozZZ"), DOF2_GetFloat(GetSlotMachine(i), "RotXX"), DOF2_GetFloat(GetSlotMachine(i), "RotYY"), DOF2_GetFloat(GetSlotMachine(i), "RotZZ")), DataSlotMachine[i][Jackpot] = DOF2_GetInt(GetSlotMachine(i), "Jackpot");
	}
	return 1;
}
GetSlotMachine(ID)
{
    new File[38];
    format(File, sizeof(File), SlotMachineFolder, ID);
    return File;
} 	
