This is a NUI grass override tool for working with https://lexicon.nwn.wiki/index.php/SetAreaGrassOverride.

It allows you to quickly test the grass override on your areas to select the ones that work best for your area and even persist it using a simple system I provided in the module.

![Example](https://github.com/user-attachments/assets/e2c33bc1-f7af-46ca-9947-d70ead2fd101)

For demonstration purposes, there is a small video https://youtu.be/bp5tiHp-c0k 

Feel free to test and contribute. There are certainly some issues and areas for improvement but is more than enough to get started.

If you have issues using it, go to NWN Developers Discord (https://discord.gg/zHMubRfR) and PM Siala

Adaptation guide:
The most important thing is to customize the list of all grass textures that you have. This customization is done in sl_s_grass_inc:
<img width="671" alt="image" src="https://github.com/user-attachments/assets/77bab968-738a-489b-9652-9bbea58b0bcb">

You need to know your textures or search for them in your haks. 

Here is an example list I used on Siala for testing (9 different grass textures from different tilesets, you will likely have some of them as well)
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

