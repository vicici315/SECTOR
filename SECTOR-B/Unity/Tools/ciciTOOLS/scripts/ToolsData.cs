using UnityEngine;
using System.Collections.Generic;

public class ToolsData : ScriptableObject
{
    public string[,] MatTexsList = { };
    public List<GameObject> AllConfirms = new List<GameObject>();
    public List<GameObject> Confirm;
    public string[,] FontSize = { {"Error","35" },{ "Best in class", "35" },{ "Bing Bam Boum", "39"}, { "CHERI", "34" }, { "CHERL", "31" }, { "DJB Get Digital", "35" }, { "mexcellent 3d", "35" }, { "Urban", "36" }, { "Games", "36" }, { "KGPrimaryLinedNOSPACE", "40" }, { "SEGA", "28" }, { "space age", "25" }, { "Viyola", "29" }, { "Fontgothic", "40" }, { "Road_Rage", "28" },{ "Deep Shadow", "22"}, { "SQUAREKI", "23" }, { "budmo jigglish", "32" }, { "CROOTH", "27" }, { "moon_get-Heavy", "23" }, { "The Rambler", "33" }, { "Sanchez", "43" }, { "Kaoly Demo-Regular", "24" }, { "Dark power", "42" }, { "Stars Fighters", "16" }, { "Carneys Gallery Script", "14" }, { "2020 Outline Fortune Kei", "30" }, { "THORN", "39" }, { "Barringtone", "30" } };
    public Material SliterMatA;
    public Material SliterMatB;
    public Material SliderApply;
    public GameObject ABobj;
    public GameObject MCamera;
    public string PP = "";
    public string Ver = "1.7";
}
