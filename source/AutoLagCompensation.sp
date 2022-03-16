#include <sdktools>
#include <sourcemod>

ConVar g_cvLagCompensation;
ConVar g_LagCompensationOffset;

public Plugin myinfo =
{
	name        = "AutoLagCompensation",
	author      = "Aleafy",
	description = "根据服务器内最大延迟的玩家自动调整延迟补偿上限",
	version     = "1.0",
	url         = "https://github.com/zhuceyezi/CSGO-AutoLagCompensation"
};

public void OnPluginStart()
{
	g_cvLagCompensation     = FindConVar("sv_maxunlag");
	g_LagCompensationOffset = CreateConVar("autocmp_offset_amount", "0.03", "sets the offset amount", 0, true, 0.0, true, 1.0);
	HookEvent("round_start", Event_RoundStart);
	PrintToServer("----------------------------------------------");
	PrintToServer("-[SM] AutoLagCompensation Loaded Successfully.-");
	PrintToServer("----------------------------------------------");
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	float MaxPlayerLatency     = 0.0;
	float CurrentPlayerLatency = 0.0;
	char  PlayerName[64];
	for (int ClientId = 1; ClientId <= 10; ClientId++)
	{
		if (IsClientConnected(ClientId))
		{
			CurrentPlayerLatency = GetClientAvgLatency(ClientId, NetFlow_Both);
			if (CurrentPlayerLatency > MaxPlayerLatency)
			{
				MaxPlayerLatency = CurrentPlayerLatency;
				GetClientName(ClientId, PlayerName, sizeof(PlayerName));
			}
		}
	}
	if (MaxPlayerLatency < 0.2)
	{
		MaxPlayerLatency = 0.2;
		PrintToChatAll("[AutoLagCompensation] 没有高延迟玩家，延迟补偿设置为默认:%f 毫秒", 1000 * (g_cvLagCompensation.FloatValue));
		PrintToServer("[AutoLagCompensation] 没有高延迟玩家，延迟补偿设置为默认:%f 毫秒", 1000 * (g_cvLagCompensation.FloatValue));
		SetConVarFloat(g_cvLagCompensation, 0.2, false, true);
	}
	else {
		SetConVarFloat(g_cvLagCompensation, MaxPlayerLatency + g_LagCompensationOffset.FloatValue, false, true);
		PrintToChatAll("[AutoLagCompensation] 最高延迟玩家： %s", PlayerName);
		PrintToChatAll("[AutoLagCompensation] 延迟补偿设置为:%f 毫秒", 1000 * (g_cvLagCompensation.FloatValue));
		PrintToServer("[AutoLagCompensation] 最高延迟玩家： %s", PlayerName);
		PrintToServer("[AutoLagCompensation] 延迟补偿设置为:%f 毫秒", 1000 * (g_cvLagCompensation.FloatValue));
	}
}