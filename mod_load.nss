#include "sl_s_grass_inc"

void main()
{
    SetEventScript(GetModule(), EVENT_SCRIPT_MODULE_ON_NUI_EVENT, "sl_s_nui_events");
    RestoreAllGrassOverrides();
}
