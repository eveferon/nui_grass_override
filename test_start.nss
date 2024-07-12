#include "sl_s_grass_inc"

void main()
{
    object oPC = GetPlaceableLastClickedBy();
    MakeGrassTestingWindow(oPC, GetArea(oPC));
}
