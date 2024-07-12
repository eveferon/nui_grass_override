# NUI Grass Override Tool

This is a NUI grass override tool for working with [SetAreaGrassOverride](https://lexicon.nwn.wiki/index.php/SetAreaGrassOverride).

It allows you to quickly test the grass override on your areas to select the ones that work best for your area and even persist it using a simple system provided in the module.

![Example](https://github.com/user-attachments/assets/e2c33bc1-f7af-46ca-9947-d70ead2fd101)

For demonstration purposes, there is a small video: [https://youtu.be/bp5tiHp-c0k](https://youtu.be/bp5tiHp-c0k).

Feel free to test and contribute. There are certainly some issues and areas for improvement, but it is more than enough to get started.

If you have issues using it, go to the [NWN Developers Discord](https://discord.gg/zHMubRfR) and PM Siala.

## Adaptation Guide

The most important thing is to customize the list of all grass textures that you have. This customization is done in `sl_s_grass_inc`:

<img width="671" alt="image" src="https://github.com/user-attachments/assets/77bab968-738a-489b-9652-9bbea58b0bcb">

You need to know your textures or search for them in your haks.

Here is an example list I used on Siala for testing (9 different grass textures from different tilesets; you will likely have some of them as well):

```cpp
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
            jResult = JsonArrayInsert(jResult, JsonString("ps_wwgrass"));
            jResult = JsonArrayInsert(jResult, JsonString("dark green thick grass"));
            break;
        case 4:
            jResult = JsonArrayInsert(jResult, JsonString("ttz_grass"));
            jResult = JsonArrayInsert(jResult, JsonString("light green thin grass"));
            break;
        case 5:
            jResult = JsonArrayInsert(jResult, JsonString("dls01_3dgrass01"));
            jResult = JsonArrayInsert(jResult, JsonString("bright summer grass"));
            break;
        case 6:
            jResult = JsonArrayInsert(jResult, JsonString("ttw01_grass01"));
            jResult = JsonArrayInsert(jResult, JsonString("grass with flowers"));
            break;
        case 7:
            jResult = JsonArrayInsert(jResult, JsonString("twl01_grass01"));
            jResult = JsonArrayInsert(jResult, JsonString("grayish grass"));
            break;
        case 8:
            jResult = JsonArrayInsert(jResult, JsonString("tfm01_grass3d"));
            jResult = JsonArrayInsert(jResult, JsonString("grass with big pink flowers"));
            break;
        case 9:
            jResult = JsonArrayInsert(jResult, JsonString("wheat"));
            jResult = JsonArrayInsert(jResult, JsonString("wheat grass"));
            break;
        default:
            jResult = JsonArrayInsert(jResult, JsonString("unknown"));
            jResult = JsonArrayInsert(jResult, JsonString("unknown"));
            break;
    }

    return jResult;
}
```


## Some Technical Notes

### Overview

This tool is designed to allow users to test and apply different grass textures in their areas using the NUI (Neverwinter Nights User Interface). The core functionalities include selecting textures, applying them to specific materials, and encoding/decoding grass override parameters for persistence.

### Key Functions

1. **GetTextureAndLabelByNumber**: This function returns the texture model name and its corresponding label based on the provided number. It utilizes a `switch` statement to map numbers to specific textures and labels.

2. **GetTextureExist**: This function checks if a given texture number corresponds to a valid texture by ensuring the texture name is not empty or "unknown".

3. **CleanAllOverrides**: This function iterates through all material types and removes grass overrides for the specified player character's area.

4. **SendCDFloatingMessage**: Sends a floating text message to the player character, ensuring messages are not spammed by implementing a cooldown.

5. **GetJsonColorFromVector** and **GetColorVectorFromJson**: These functions convert between JSON color objects and vector representations of colors.

6. **EncodeGrassOverrideParameters**: Encodes grass override parameters (texture, density, height, ambient color, diffuse color) into a single string for storage.

7. **ApplyGrassOverride**: Applies the grass override to the area based on the selected or specified texture, material, density, height, and colors.

8. **RunGrassOverrideFromEncodedString**: Decodes an encoded string of grass override parameters and applies them to the area.

9. **RestoreAndSaveMaterialSelection**: Restores saved grass override settings for a specified material in an area and applies them using the encoded parameters.

10. **PopulateGrassTextureList**: Generates a JSON array of grass textures available for selection in the NUI.

11. **PopulateMaterialsList**: Generates a JSON array of materials available for selection in the NUI.

12. **MakeGrassTestingWindow**: Creates the NUI window for testing and applying grass overrides, including all UI elements such as text inputs, sliders, and buttons.

13. **RestoreGrasOverrideInSingleArea** and **RestoreAllGrassOverrides**: Functions to restore grass overrides for single or all areas based on stored parameters.

### Example Usage

- To apply a grass override, a player would use the NUI window to select a texture, material, and adjust density and height sliders.
- The settings are encoded into a string and stored as a local variable on the area.
- On module load or area transition, the grass overrides can be restored using the encoded parameters.

This tool is highly customizable and designed to work seamlessly with the existing Neverwinter Nights engine and custom modules.

