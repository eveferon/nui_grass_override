#include "nw_inc_nui_insp"
#include "sl_s_grass_inc"

void main()
{
    // Let the inspector handle what it wants.
    HandleWindowInspectorEvent();

    // The rest of this file is for the demo panels.
    object oPC = NuiGetEventPlayer();
    int nWindow = NuiGetEventWindow();
    string sEvent = NuiGetEventType();
    string sElem = NuiGetEventElement();
    int nIdx = NuiGetEventArrayIndex();
    string sWndId = NuiGetWindowId(oPC, nWindow);

    if(sWndId == "sl_nui_grass_test")
    {
        object oArea = GetArea(oPC);
        if (sEvent == "watch")
        {
            if(sElem == "grass_density")
            {
                float fDensitySlider = JsonGetFloat(NuiGetBind(oPC, nWindow, "grass_density"));
                NuiSetBind(oPC, nWindow, "grass_density_value", JsonString(FloatToString(fDensitySlider, 2, 1)));

                ApplyGrassOverride(oPC, nWindow);
            }
            else if(sElem == "grass_height")
            {
                float fHeightSlider = JsonGetFloat(NuiGetBind(oPC, nWindow, "grass_height"));
                NuiSetBind(oPC, nWindow, "grass_height_value", JsonString(FloatToString(fHeightSlider, 2, 1)));

                ApplyGrassOverride(oPC, nWindow);
            }
            else if(sElem == "texture_selector")
            {
                ApplyGrassOverride(oPC, nWindow);
            }
            else if(sElem == "material_selector")
            {
                RestoreAndSaveMaterialSelection(oArea, oPC, JsonGetInt(NuiGetBind(oPC, nWindow, "material_selector")), nWindow);
            }
            else if(sElem == "grass_ambient_color")
            {

                json jColor = NuiGetBind(oPC, nWindow, "grass_ambient_color");
                vector vAmbient = GetColorVectorFromJson(jColor);
                ApplyGrassOverride(oPC, nWindow);
            }
            else if(sElem == "grass_diffuse_color")
            {
                json jColor = NuiGetBind(oPC, nWindow, "grass_diffuse_color");
                vector vDiffuse = GetColorVectorFromJson(jColor);
                ApplyGrassOverride(oPC, nWindow);
            }
        }
        else if (sEvent == "click")
        {
            if(sElem == "bt_grass")
            {
                NuiSetBind(oPC, nWindow, "material_selector", JsonInt(3));
            }
            else if(sElem == "bt_dirt")
            {
                NuiSetBind(oPC, nWindow, "material_selector", JsonInt(1));
            }
            else if(sElem == "bt_leaves")
            {
                NuiSetBind(oPC, nWindow, "material_selector", JsonInt(14));
            }
            else if(sElem == "bt_snow")
            {
                NuiSetBind(oPC, nWindow, "material_selector", JsonInt(19));
            }
            else if(sElem == "bt_sands")
            {
                NuiSetBind(oPC, nWindow, "material_selector", JsonInt(20));
            }
            else if(sElem == "bt_stone")
            {
                NuiSetBind(oPC, nWindow, "material_selector", JsonInt(4));
            }
            else if(sElem == "bt_apply")
            {
                ApplyGrassOverride(oPC, nWindow);
            }
            else if(sElem == "bt_clean")
            {
                CleanAllOverrides(oPC);
            }
            else if(sElem == "btleft")
            {
                int nTexture = JsonGetInt(NuiGetBind(oPC, nWindow, "texture_selector"));
                if(GetTextureExist(--nTexture))
                {
                    NuiSetBind(oPC, nWindow, "texture_selector", JsonInt(nTexture));
                    ApplyGrassOverride(oPC, nWindow);
                }
                else
                    FloatingTextStringOnCreature("Go other direction when switching", oPC, FALSE);

            }
            else if(sElem == "btright")
            {
                int nTexture = JsonGetInt(NuiGetBind(oPC, nWindow, "texture_selector"));
                if(GetTextureExist(++nTexture))
                {
                    NuiSetBind(oPC, nWindow, "texture_selector", JsonInt(nTexture));
                    ApplyGrassOverride(oPC, nWindow);
                }
                else
                    FloatingTextStringOnCreature("Go other direction when switching", oPC, FALSE);
            }
        }
    }
}

