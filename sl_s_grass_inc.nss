#include "nw_inc_nui_insp"
#include "nw_inc_nui"

// Written for Siala PW, https://siala.online
// Author: Friedrich Chasin
// Community contributions: <>



// ATTENTION: The only place to customize based on textures your module has
// Simply add/remove texture model names (first entry) and how you want them to be called
// (second entry) for each texture you have. These entries will be the ones to choose from

// Change the constant as well. If you have 10 textures, make it 10
const int TEXTURE_COUNT = 3;

json GetTextureAndLabelByNumber(int nNumber)
{
    json jResult = JsonArray();

    switch (nNumber)
    {
        case 1:
            jResult = JsonArrayInsert(jResult, JsonString("trs02_grassrim01"));
            jResult = JsonArrayInsert(jResult, JsonString("winter grass"));
            break;
        case 2:
            jResult = JsonArrayInsert(jResult, JsonString("trm02_grass3d"));
            jResult = JsonArrayInsert(jResult, JsonString("summer nice grass"));
            break;
        case 3:
            jResult = JsonArrayInsert(jResult, JsonString("ttz_grass"));
            jResult = JsonArrayInsert(jResult, JsonString("light green thin grass"));
            break;
        default:
            jResult = JsonArrayInsert(jResult, JsonString("unknown"));
            jResult = JsonArrayInsert(jResult, JsonString("unknown"));
            break;
    }

    return jResult;
}

int GetTextureExist(int nNumber)
{
    json jTextureAndLabel = GetTextureAndLabelByNumber(nNumber);
    string sTexture = JsonGetString(JsonArrayGet(jTextureAndLabel, 0));

    // Check if the texture is not an empty string or "unknown"
    if (sTexture != "" && sTexture != "unknown")
    {
        return TRUE;
    }
    return FALSE;
}

void CleanAllOverrides(object oPC)
{
    object oArea = GetArea(oPC);
    int nMaterial;

    // Iterate through all material types and remove grass overrides
    for (nMaterial = 0; nMaterial <= 30; nMaterial++)
    {
        SetAreaGrassOverride(oArea, nMaterial, " ", 0.0, 0.0, [1.0, 1.0, 1.0], [1.0, 1.0, 1.0]);
    }
}

void SendCDFloatingMessage(object oPC, string sMessage)
{
    if(!GetLocalInt(oPC, "MessageCD"))
    {
        SetLocalInt(oPC, "MessageCD", 1);
        DelayCommand(1.0, SetLocalInt(oPC, "MessageCD", 0));
        FloatingTextStringOnCreature(sMessage, oPC);
    }
}

json GetJsonColorFromVector(vector vColor)
{
    // Extract RGB values from the vector
    float fRed = vColor.x;
    float fGreen = vColor.y;
    float fBlue = vColor.z;

    // Convert the RGB values from the range 0.0 - 1.0 to 0 - 255
    int nRed = FloatToInt(fRed * 255.0);
    int nGreen = FloatToInt(fGreen * 255.0);
    int nBlue = FloatToInt(fBlue * 255.0);

    // Create and return the JSON color object
    json jColor = JsonObject();
    JsonObjectSetInplace(jColor, "r", JsonInt(nRed));
    JsonObjectSetInplace(jColor, "g", JsonInt(nGreen));
    JsonObjectSetInplace(jColor, "b", JsonInt(nBlue));
    JsonObjectSetInplace(jColor, "a", JsonInt(255)); // Always assuming full opacity, extend if you wish

    return jColor;
}

vector GetColorVectorFromJson(json jColor)
{
    // Extract RGB values from the JSON color
    int nRed = JsonGetInt(JsonObjectGet(jColor, "r"));
    int nGreen = JsonGetInt(JsonObjectGet(jColor, "g"));
    int nBlue = JsonGetInt(JsonObjectGet(jColor, "b"));

    // Convert the RGB values to the range 0.0 - 1.0
    float fRed = nRed / 255.0;
    float fGreen = nGreen / 255.0;
    float fBlue = nBlue / 255.0;

    // Create and return the vector
    return Vector(fRed, fGreen, fBlue);
}

// Function to encode the grass override parameters into a string
string EncodeGrassOverrideParameters(string sTexture, float fDensity, float fHeight, vector vAmbientColor, vector vDiffuseColor)
{
    // Convert the vector components to strings
    string sAmbientColor = FloatToString(vAmbientColor.x, 1, 2) + "," + FloatToString(vAmbientColor.y, 1, 2) + "," + FloatToString(vAmbientColor.z, 1, 2);
    string sDiffuseColor = FloatToString(vDiffuseColor.x, 1, 2) + "," + FloatToString(vDiffuseColor.y, 1, 2) + "," + FloatToString(vDiffuseColor.z, 1, 2);

    // Combine all parameters into a single string
    return sTexture + "|" + FloatToString(fDensity, 3, 1) + "|" + FloatToString(fHeight, 3, 1) + "|" + sAmbientColor + "|" + sDiffuseColor;
}

// Use fDensitySlider and fHeightSlider to override, use -1.0 for default value if overriding just one value
void ApplyGrassOverride(object oPC, int nWindow, int nForce = FALSE)
{
    if(GetLocalInt(oPC, "FirstGrassOverrideExecution") && !nForce)
    {
        return;
    }
    object oArea = GetArea(oPC);
    string sTexture;
    string sExplicitTexture = JsonGetString(NuiGetBind(oPC, nWindow, "grass_texture_string_value"));
    int nTexture;
    if(sExplicitTexture != "")
    {
        sTexture = sExplicitTexture;
        SendCDFloatingMessage(oPC, "You used specific texture (" + sExplicitTexture + "). Remove if you want to use dropdown)");
    }
    else
    {
        nTexture = JsonGetInt(NuiGetBind(oPC, nWindow, "texture_selector"));
        sTexture = JsonGetString(JsonArrayGet(GetTextureAndLabelByNumber(nTexture), 0)) ;
    }

    int nMaterial = JsonGetInt(NuiGetBind(oPC, nWindow, "material_selector"));
    float fDensitySlider = JsonGetFloat(NuiGetBind(oPC, nWindow, "grass_density"));
    float fHeightSlider = JsonGetFloat(NuiGetBind(oPC, nWindow, "grass_height"));

    json jAmbientColor = NuiGetBind(oPC, nWindow, "grass_ambient_color");
    json jDiffuseColor = NuiGetBind(oPC, nWindow, "grass_diffuse_color");

    vector vAmbientColor = GetColorVectorFromJson(jAmbientColor);
    vector vDiffuseColor = GetColorVectorFromJson(jDiffuseColor);

    string sEncodedOverrideParameters = EncodeGrassOverrideParameters(sTexture, fDensitySlider, fHeightSlider, vAmbientColor, vDiffuseColor);
    SetLocalString(oArea, "GrassOverride" + IntToString(nMaterial), sEncodedOverrideParameters);
    string sLogMessage = "Saved for " + IntToString(nMaterial) + ": " + sEncodedOverrideParameters;
    SendMessageToAllDMs(sLogMessage);
    SendMessageToPC(oPC, sLogMessage);
    SendMessageToPC(oPC, "For PW, you can add local var on area GrassOverride" + IntToString(nMaterial) + " string value, where value is the encoded string above. On module load iterate through all areas and restore");
    SetAreaGrassOverride(GetArea(oPC), nMaterial, sTexture, fDensitySlider, fHeightSlider, vAmbientColor, vDiffuseColor);
}

int GetListNumberFromGrassTexture(string sTexture)
{
    int i = 1;
    json jResult = GetTextureAndLabelByNumber(i);
    string sCurrentTexture = JsonGetString(JsonArrayGet(jResult, 0));
    while (sCurrentTexture != "unknown" && sCurrentTexture != "")
    {
        jResult = GetTextureAndLabelByNumber(i);
        sCurrentTexture = JsonGetString(JsonArrayGet(jResult, 0));

        if (sCurrentTexture == sTexture)
            return i;
        i++;
    }

    return -1; // Return -1 if the texture is not found
}

void RunGrassOverrideFromEncodedString(object oArea, object oPC, int nMaterialId, string sEncodedString, int nWindowID)
{
    // Prevent from many changes while restoring NUI
    SetLocalInt(oPC, "FirstGrassOverrideExecution", 1);
    DelayCommand(1.0, SetLocalInt(oPC, "FirstGrassOverrideExecution", 0));

    // Initialize variables
    string sTexture;
    float fDensity;
    float fHeight;
    vector vAmbientColor;
    vector vDiffuseColor;

    // Find positions of delimiters
    int pos1 = FindSubString(sEncodedString, "|", 0);
    int pos2 = FindSubString(sEncodedString, "|", pos1 + 1);
    int pos3 = FindSubString(sEncodedString, "|", pos2 + 1);
    int pos4 = FindSubString(sEncodedString, "|", pos3 + 1);

    // Extract components from the encoded string
    if (pos1 != -1 && pos2 != -1 && pos3 != -1 && pos4 != -1)
    {
        // Extract texture
        sTexture = GetSubString(sEncodedString, 0, pos1);

        // Extract density
        string sDensity = GetSubString(sEncodedString, pos1 + 1, pos2 - pos1 - 1);
        fDensity = StringToFloat(sDensity);

        // Extract height
        string sHeight = GetSubString(sEncodedString, pos2 + 1, pos3 - pos2 - 1);
        fHeight = StringToFloat(sHeight);

        // Extract ambient color
        string sAmbientColor = GetSubString(sEncodedString, pos3 + 1, pos4 - pos3 - 1);
        int posA1 = FindSubString(sAmbientColor, ",", 0);
        int posA2 = FindSubString(sAmbientColor, ",", posA1 + 1);
        float fRed = StringToFloat(GetSubString(sAmbientColor, 0, posA1));
        float fGreen = StringToFloat(GetSubString(sAmbientColor, posA1 + 1, posA2 - posA1 - 1));
        float fBlue = StringToFloat(GetSubString(sAmbientColor, posA2 + 1, GetStringLength(sAmbientColor) - posA2 - 1));
        vAmbientColor = Vector(fRed, fGreen, fBlue);

        // Extract diffuse color
        string sDiffuseColor = GetSubString(sEncodedString, pos4 + 1, GetStringLength(sEncodedString) - pos4 - 1);
        int posD1 = FindSubString(sDiffuseColor, ",", 0);
        int posD2 = FindSubString(sDiffuseColor, ",", posD1 + 1);
        fRed = StringToFloat(GetSubString(sDiffuseColor, 0, posD1));
        fGreen = StringToFloat(GetSubString(sDiffuseColor, posD1 + 1, posD2 - posD1 - 1));
        fBlue = StringToFloat(GetSubString(sDiffuseColor, posD2 + 1, GetStringLength(sDiffuseColor) - posD2 - 1));
        vDiffuseColor = Vector(fRed, fGreen, fBlue);

        // Restore NUI values
        if(nWindowID != -1)
        {
            // Set texture
            int nTextureNumber = GetListNumberFromGrassTexture(sTexture);
            if(nTextureNumber >= 0)
                NuiSetBind(oPC, nWindowID, "texture_selector", JsonInt(nTextureNumber));
            else
                NuiSetBind(oPC, nWindowID, "grass_texture_string_value", JsonString(sTexture));

            // Set density slider into default
            NuiSetBind(oPC, nWindowID, "grass_density", JsonFloat(fDensity));

            // Set height slider into default
            NuiSetBind(oPC, nWindowID, "grass_height", JsonFloat(fHeight));

            // Set default slider label values
            NuiSetBind(oPC, nWindowID, "grass_density_value", JsonString(FloatToString(JsonGetFloat(NuiGetBind(oPC, nWindowID, "grass_density")), 2, 1))); //
            NuiSetBind(oPC, nWindowID, "grass_height_value", JsonString(FloatToString(JsonGetFloat(NuiGetBind(oPC, nWindowID, "grass_height")), 2, 1))); //

            // Set default color values
            NuiSetBind(oPC, nWindowID, "grass_ambient_color", GetJsonColorFromVector((vAmbientColor)));
            NuiSetBind(oPC, nWindowID, "grass_diffuse_color", GetJsonColorFromVector((vDiffuseColor)));
        }
        else
            SetAreaGrassOverride(oArea, nMaterialId, sTexture, fDensity, fHeight, vAmbientColor, vDiffuseColor);
    }
    else
    {
        // Handle error: invalid encoded string format
        // You can log the error or notify the user here
    }
}

void RestoreAndSaveMaterialSelection(object oArea, object oPC, int nMaterial, int nWindowID)
{
                                                                                SendMessageToPC(oPC, "nWindowID " + IntToString(nWindowID));
    SetLocalInt(oPC, "SelectedMaterial", nMaterial);
    string sEncodedOverrideParameters = GetLocalString(oArea, "GrassOverride" + IntToString(nMaterial));
    string sLogMessage = "Restoring for " + IntToString(nMaterial) + ": " + sEncodedOverrideParameters;
    SendMessageToAllDMs(sLogMessage);                                           SendMessageToPC(oPC, sLogMessage);

    if(sEncodedOverrideParameters != "")
    {
        RunGrassOverrideFromEncodedString(oArea, oPC, nMaterial, sEncodedOverrideParameters, nWindowID);
        if(nWindowID == -1)
            ApplyGrassOverride(oPC, nWindowID, TRUE);
    }
}

json PopulateGrassTextureList()
{
    json jGrassTextures = JsonArray();
    int i;
    for (i = 1; i <= TEXTURE_COUNT; i++)
    {
        json jTextureAndLabel = GetTextureAndLabelByNumber(i);
        string sLabel = JsonGetString(JsonArrayGet(jTextureAndLabel, 1));
        jGrassTextures = JsonArrayInsert(jGrassTextures, NuiComboEntry(sLabel, i));
    }

    return jGrassTextures;
}

json PopulateMaterialsList()
{
    json jMaterialNames = JsonArray();
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Dirt", 1));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Obscuring", 2));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Grass", 3));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Stone", 4));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Wood", 5));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Water", 6));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Nonwalk", 7));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Transparent", 8));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Carpet", 9));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Metal", 10));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Puddles", 11));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Swamp", 12));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Mud", 13));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Leaves", 14));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Lava", 15));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Bottomless Pit", 16));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("DeepWater", 17));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Door", 18));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Snow", 19));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Sand", 20));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Barebones", 21));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("StoneBridge", 22));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Template 23", 23));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Template 24", 24));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Template 25", 25));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Template 26", 26));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Template 27", 27));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Template 28", 28));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Template 29", 29));
    jMaterialNames = JsonArrayInsert(jMaterialNames, NuiComboEntry("Trigger", 30));

    return jMaterialNames;
}

float GetCenterHeightPointForWindow(object oPC, float fWindowHeight)
{
    return IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_HEIGHT)) / 2 - fWindowHeight / 2;
}

float GetUpCenterPointForWindow(object oPC, float fWindowWidth)
{
    return IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_WIDTH)) / 2 - fWindowWidth / 2;
}

int MakeGrassTestingWindow(object oPC, object oArea)
{
    json jCol = JsonArray();
    json jRow;

    // Texture name
    {
        // Input field
        json jInputField = NuiTextEdit(JsonString("Enter texture name"), NuiBind("grass_texture_string_value"), 32, FALSE);
        jRow = JsonArrayInsert(JsonArray(), jInputField);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }

    // Texture selector
    {
        jRow = JsonArray();
        json jGrassTextures = PopulateGrassTextureList();
        jRow = JsonArrayInsert(jRow, NuiWidth(NuiCombo(jGrassTextures, NuiBind("texture_selector")), 350.0));
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }

    // Mext and prev buttons
    {
        // Left button
        json jLeftButton = NuiId(NuiButton(JsonString("<")), "btleft");
        jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
        jRow = JsonArrayInsert(jRow, NuiHeight(NuiWidth(jLeftButton, 30.0), 30.0));

        // Empty button
        json jEmptyButton = NuiVisible(NuiId(NuiButton(JsonString("")), "btempty"), JsonBool(0));
        jRow = JsonArrayInsert(jRow, NuiHeight(NuiWidth(jEmptyButton, 30.0), 30.0));

        // Right button
        json jRightButton = NuiId(NuiButton(JsonString(">")), "btright");
        jRow = JsonArrayInsert(jRow, NuiHeight(NuiWidth(jRightButton, 30.0), 30.0));
        jRow = JsonArrayInsert(jRow, NuiSpacer());

        // Finish the row
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }

    // Material selector
    {
        jRow = JsonArray();
        json jMaterials = PopulateMaterialsList();
        jRow = JsonArrayInsert(jRow, NuiWidth(NuiCombo(jMaterials, NuiBind("material_selector")), 350.0));
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }

    // First row with Grass, Dirt, Leaves buttons
    {
        json jGrassButton = NuiEnabled(NuiId(NuiButton(JsonString("Grass (3)")), "bt_grass"), NuiBind("enable_grass"));
        json jDirtButton = NuiEnabled(NuiId(NuiButton(JsonString("Dirt (1)")), "bt_dirt"), NuiBind("enable_dirt"));
        json jLeavesButton = NuiEnabled(NuiId(NuiButton(JsonString("Leaves (14)")), "bt_leaves"), NuiBind("enable_leaves"));

        json jRow1 = JsonArrayInsert(JsonArray(), NuiSpacer());
        jRow1 = JsonArrayInsert(jRow1, NuiHeight(NuiWidth(jGrassButton, 95.0), 30.0));
        jRow1 = JsonArrayInsert(jRow1, NuiSpacer());
        jRow1 = JsonArrayInsert(jRow1, NuiHeight(NuiWidth(jDirtButton, 95.0), 30.0));
        jRow1 = JsonArrayInsert(jRow1, NuiSpacer());
        jRow1 = JsonArrayInsert(jRow1, NuiHeight(NuiWidth(jLeavesButton, 95.0), 30.0));
        jRow1 = JsonArrayInsert(jRow1, NuiSpacer());

        jCol = JsonArrayInsert(jCol, NuiRow(jRow1));
    }

    // Second row with Snow, Sand, Stone buttons
    {
        json jSnowButton = NuiEnabled(NuiId(NuiButton(JsonString("Snow (19)")), "bt_snow"), NuiBind("enable_snow"));
        json jSandsButton = NuiEnabled(NuiId(NuiButton(JsonString("Sand (20)")), "bt_sands"), NuiBind("enable_sands"));
        json jStoneButton = NuiEnabled(NuiId(NuiButton(JsonString("Stone (4)")), "bt_stone"), NuiBind("enable_stone"));

        json jRow2 = JsonArrayInsert(JsonArray(), NuiSpacer());
        jRow2 = JsonArrayInsert(jRow2, NuiHeight(NuiWidth(jSnowButton, 95.0), 30.0));
        jRow2 = JsonArrayInsert(jRow2, NuiSpacer());
        jRow2 = JsonArrayInsert(jRow2, NuiHeight(NuiWidth(jSandsButton, 95.0), 30.0));
        jRow2 = JsonArrayInsert(jRow2, NuiSpacer());
        jRow2 = JsonArrayInsert(jRow2, NuiHeight(NuiWidth(jStoneButton, 95.0), 30.0));
        jRow2 = JsonArrayInsert(jRow2, NuiSpacer());

        jCol = JsonArrayInsert(jCol, NuiRow(jRow2));
    }

    // Density slider label row
    {
        jRow = JsonArray();

        json sLabel = NuiLabel(JsonString("Density (0.0 - 50.0): "), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_BOTTOM));
        jRow = JsonArrayInsert(jRow, sLabel);

        sLabel = NuiLabel(NuiBind("grass_density_value"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_BOTTOM));
        jRow = JsonArrayInsert(jRow, sLabel);

        // Finish the row
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }

    // Density slider row
    {
        // Define row
        jRow = JsonArray();

        // Slider
        json jSlider = NuiSliderFloat(NuiBind("grass_density"), JsonFloat(0.0), JsonFloat(50.0), JsonFloat(0.1));
             jSlider = NuiEnabled(jSlider, NuiBind("grass_density_enabled"));
             jSlider = NuiWidth(jSlider, 350.0f);
             jSlider = NuiTooltip(jSlider, NuiBind("grass_density_tooltip"));
        jRow = JsonArrayInsert(jRow, jSlider);

        // Finish the row
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }

    // Height slider label row
    {
        jRow = JsonArray();

        json sLabel = NuiLabel(JsonString("Height (0.0 - 5.0)"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_BOTTOM));
        jRow = JsonArrayInsert(jRow, sLabel);

        sLabel = NuiLabel(NuiBind("grass_height_value"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_BOTTOM));
        jRow = JsonArrayInsert(jRow, sLabel);

        // Finish the row
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }

    // Height slider row
    {
        // Define row
        jRow = JsonArray();

        // Slider
        json jSlider = NuiSliderFloat(NuiBind("grass_height"), JsonFloat(0.0), JsonFloat(5.0), JsonFloat(0.1));
             jSlider = NuiEnabled(jSlider, NuiBind("grass_height_enabled"));
             jSlider = NuiWidth(jSlider, 350.0f);
             jSlider = NuiTooltip(jSlider, NuiBind("grass_height_tooltip"));
        jRow = JsonArrayInsert(jRow, jSlider);

        // Finish the row
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }

    // Color labels
    {
        jRow = JsonArray();

        jRow = JsonArrayInsert(jRow, NuiSpacer());

        json sLabel = NuiLabel(JsonString("Ambient"), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_BOTTOM));
        jRow = JsonArrayInsert(jRow, sLabel);

        jRow = JsonArrayInsert(jRow, NuiSpacer());

        sLabel = NuiLabel(JsonString("Diffuse"), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_BOTTOM));
        jRow = JsonArrayInsert(jRow, sLabel);

        jRow = JsonArrayInsert(jRow, NuiSpacer());

        // Finish the row
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }

    {
        // Define row
        jRow = JsonArray();

        jRow = JsonArrayInsert(jRow, NuiSpacer());

        json jColorPicker = NuiColorPicker(NuiBind("grass_ambient_color"));
        jColorPicker = NuiHeight(jColorPicker, 80.0);
        jColorPicker = NuiWidth(jColorPicker, 150.0);

        // Add row
        jRow = JsonArrayInsert(jRow, jColorPicker);

        // Space
        jRow = JsonArrayInsert(jRow, NuiSpacer());

        jColorPicker = NuiColorPicker(NuiBind("grass_diffuse_color"));
        jColorPicker = NuiHeight(jColorPicker, 80.0);
        jColorPicker = NuiWidth(jColorPicker, 150.0);

        // Add row
        jRow = JsonArrayInsert(jRow, jColorPicker);

        // Space
        jRow = JsonArrayInsert(jRow, NuiSpacer());

        // Add column
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }


    // Apply and Clean Buttons
    {
        json jApplyButton = NuiId(NuiButton(JsonString("Apply")), "bt_apply");
        jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
        jRow = JsonArrayInsert(jRow, NuiHeight(NuiWidth(jApplyButton, 100.0), 30.0));

        // Add space
        jRow = JsonArrayInsert(jRow, NuiSpacer());

        json jCleanButton = NuiId(NuiButton(JsonString("Clean all")), "bt_clean");
        jRow = JsonArrayInsert(jRow, NuiHeight(NuiWidth(jCleanButton, 100.0), 30.0));

        // Add space
        jRow = JsonArrayInsert(jRow, NuiSpacer());

        // Finish the row
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }

    // Prepare window label
    string sWindowLabel = "Grass override for: " + GetName(oArea);

    // Window definition
    json jWindow = NuiWindow(
        NuiCol(jCol),
        JsonString(sWindowLabel),// Window label
        NuiRect(GetUpCenterPointForWindow(oPC, 370.0) + 500.0, GetCenterHeightPointForWindow(oPC, 420.0), 370.0, 620.0/*420.0*/), // Window position and size
        JsonBool(FALSE),                    // resizable
        NuiBind("grass_test_collapsed"),     // collapsable
        JsonBool(TRUE),                     // closable
        JsonBool(TRUE),                    // transparent
        JsonBool(TRUE));                    // border

    // Window creation
    int nWindowID = NuiCreate(oPC, jWindow, "sl_nui_grass_test");

    SetLocalInt(oPC, "FirstGrassOverrideExecution", 1);
    DelayCommand(1.0, SetLocalInt(oPC, "FirstGrassOverrideExecution", 0));

    // Enable sliders
    NuiSetBind(oPC, nWindowID, "grass_density_enabled", JsonBool(1));
    NuiSetBind(oPC, nWindowID, "grass_height_enabled", JsonBool(1));

    // Set default material to grass
    NuiSetBind(oPC, nWindowID, "material_selector", JsonInt(3));

    // Set materials buttons and list defaults
    NuiSetBind(oPC, nWindowID, "enable_grass", JsonBool(1));
    NuiSetBind(oPC, nWindowID, "enable_dirt", JsonBool(1));
    NuiSetBind(oPC, nWindowID, "enable_leaves", JsonBool(1));
    NuiSetBind(oPC, nWindowID, "enable_snow", JsonBool(1));
    NuiSetBind(oPC, nWindowID, "enable_sands", JsonBool(1));
    NuiSetBind(oPC, nWindowID, "enable_stone", JsonBool(1));
    SetLocalInt(oPC, "SelectedMaterial", 3);

    // Disable collapse
    NuiSetBind(oPC, nWindowID, "grass_test_collapsed", JsonBool(0));

    // Set density slider into default
    NuiSetBind(oPC, nWindowID, "grass_density", JsonFloat(20.0));

    // Set height slider into default
    NuiSetBind(oPC, nWindowID, "grass_height", JsonFloat(0.6));

    // Set default slider label values
    NuiSetBind(oPC, nWindowID, "grass_density_value", JsonString(FloatToString(JsonGetFloat(NuiGetBind(oPC, nWindowID, "grass_density")), 2, 1))); //
    NuiSetBind(oPC, nWindowID, "grass_height_value", JsonString(FloatToString(JsonGetFloat(NuiGetBind(oPC, nWindowID, "grass_height")), 2, 1))); //

    // Set default color values
    NuiSetBind(oPC, nWindowID, "grass_ambient_color", NuiColor(255, 255, 255, 255));
    NuiSetBind(oPC, nWindowID, "grass_diffuse_color", NuiColor(255, 255, 255, 255));

    // Set tooltips
    NuiSetBind(oPC, nWindowID, "grass_density_tooltip", JsonString("How dense the grass will be"));
    NuiSetBind(oPC, nWindowID, "grass_height_tooltip", JsonString("How high the grass will be"));

    // Set watch events on the sliders
    NuiSetBindWatch(oPC, nWindowID, "grass_density", TRUE);
    NuiSetBindWatch(oPC, nWindowID, "grass_height", TRUE);
    NuiSetBindWatch(oPC, nWindowID, "texture_selector", TRUE);
    NuiSetBindWatch(oPC, nWindowID, "material_selector", TRUE);
    NuiSetBindWatch(oPC, nWindowID, "grass_ambient_color", TRUE);
    NuiSetBindWatch(oPC, nWindowID, "grass_diffuse_color", TRUE);

    // Restore saved override
    RestoreAndSaveMaterialSelection(oArea, oPC, JsonGetInt(NuiGetBind(oPC, nWindowID, "material_selector")), nWindowID);

    return nWindowID;
}

void RestoreGrasOverrideInSingleArea(object oArea)
{
    int i;
    string sEncodedString;
    for(i = 1; i <= 30; i++)
    {
        // We do not have oPC here, but no problem, system handles it :)
        RestoreAndSaveMaterialSelection(oArea, OBJECT_INVALID, i, -1);
    }
}

void RestoreAllGrassOverrides()
{
    object oArea = GetFirstArea();
    while(GetIsObjectValid(oArea))
    {
        RestoreGrasOverrideInSingleArea(oArea);
        oArea = GetNextArea();
    }
}
