# Occult Box API 0.1.0 — Include Surface

This generated inventory distinguishes the explicitly named API candidate from
shared support headers and family-internal implementation headers. Visibility in
source does not by itself create a stability promise.

## Compatibility classes

- **Named API candidate:** `MIXSR_API_LoopSafe.fxh`. Three families carry
  byte-identical copies. Its declarations are documented below, but 0.1.0-draft
  does not yet guarantee long-term source compatibility.
- **Shared/support surface:** reusable `miXSR_shared_*` and adapter headers.
  They are callable source, but their declarations may move while the draft is
  being reconciled.
- **Family-internal surface:** effect implementation and domain headers. Consumers
  should include the family effect or documented umbrella header instead of
  depending on these declarations directly.

## Named API candidate

All three copies currently have SHA-256
`9667081ABC26667A20C5619B6B201AAD90E73A0DF1842EB761DCFA6531FDDC0D`.

| Signature | Source-supported behavior |
|---|---|
| `float MIXSR_FloatModNoWarn(float a, float b)` | Float modulo with an absolute denominator floor of `1e-6`. |
| `float2 MIXSR_Float2ModNoWarn(float2 a, float2 b)` | Component-wise float2 modulo with denominator floors. |
| `float3 MIXSR_Float3ModNoWarn(float3 a, float3 b)` | Component-wise float3 modulo with denominator floors. |
| `int MIXSR_IntModNoWarn(int a, int b)` | Nonnegative integer-like modulo computed through floats; clamps `a` to nonnegative and `b` to at least one. |
| `uint MIXSR_UIntModNoWarn(uint a, uint b)` | Unsigned integer-like modulo computed through floats; clamps `b` to at least one. |
| `float MIXSR_SafePowNonNegative(float baseValue, float exponentValue)` | Applies `pow` after clamping the base to nonnegative. |
| `float3 MIXSR_RM_LoopMissColor(float2 uv)` | Produces a fixed dark/red 24-cell grid diagnostic for loop-miss display. |

### Current copies

- [`black_wand/header/MIXSR_API_LoopSafe.fxh`](../../black_wand/header/MIXSR_API_LoopSafe.fxh)
- [`book_of_death/header/MIXSR_API_LoopSafe.fxh`](../../book_of_death/header/MIXSR_API_LoopSafe.fxh)
- [`legacy_lenses/header/MIXSR_API_LoopSafe.fxh`](../../legacy_lenses/header/MIXSR_API_LoopSafe.fxh)

## Header inventory

| Header | Class | Macros | Structs | Functions | Resources | Direct local includers | SHA-256 |
|---|---|---:|---:|---:|---:|---:|---|
| [`black_wand/header/black_wand_Complex_Helper_AA.fxh`](../../black_wand/header/black_wand_Complex_Helper_AA.fxh) | family-internal surface | 1 | 0 | 5 | 0 | 1 | `3ED7D66211D3889809E878A6BF676EC1BA9C4BCB96DF186D7254BC6A7A7627FE` |
| [`black_wand/header/black_wand_Complex_Helper_All.fxh`](../../black_wand/header/black_wand_Complex_Helper_All.fxh) | family-internal surface | 1 | 0 | 0 | 0 | 2 | `F4D28A5C56B0F1B30046FAA970AA6397EBF35A327146945CB1A95FA9DF79177B` |
| [`black_wand/header/black_wand_Complex_Helper_AO.fxh`](../../black_wand/header/black_wand_Complex_Helper_AO.fxh) | family-internal surface | 1 | 0 | 6 | 0 | 1 | `2A2FBB26C3A6DE2F452B67535AC9BCE8C7294DFBF14A94270EA1C01B3821C9CA` |
| [`black_wand/header/black_wand_Complex_Helper_Detail.fxh`](../../black_wand/header/black_wand_Complex_Helper_Detail.fxh) | family-internal surface | 1 | 0 | 4 | 0 | 1 | `FFF489B6273FCBF14059EC8AA493577F55C97427B544150A6F7FF064E40E09E4` |
| [`black_wand/header/black_wand_Complex_Helper_SSR.fxh`](../../black_wand/header/black_wand_Complex_Helper_SSR.fxh) | family-internal surface | 1 | 0 | 7 | 0 | 1 | `DAB924D695EE6C1F7D0AEEE3610E5798DD15DA4F913AB2FF252F469BB7F0587F` |
| [`black_wand/header/black_wand_Complex_Helper_Tone.fxh`](../../black_wand/header/black_wand_Complex_Helper_Tone.fxh) | family-internal surface | 1 | 0 | 3 | 0 | 1 | `51464F525CA64FEC36880AAAC3154F01981863CEDD7165E3008E7042FE0D8036` |
| [`black_wand/header/black_wand_Debug_Colorize_Server.fxh`](../../black_wand/header/black_wand_Debug_Colorize_Server.fxh) | family-internal surface | 1 | 0 | 4 | 0 | 0 | `90ED0078449B023D6E2EAA8877FD1FBBC6A65C37945B014F1318D0C60D4A353D` |
| [`black_wand/header/black_wand_Depth_Adapter.fxh`](../../black_wand/header/black_wand_Depth_Adapter.fxh) | shared/support surface | 4 | 0 | 9 | 0 | 2 | `824525F24170547E562AA47B857C6B8A762F345BA645F28B956D61F0C471E3C0` |
| [`black_wand/header/black_wand_DO_All.fxh`](../../black_wand/header/black_wand_DO_All.fxh) | family-internal surface | 1 | 0 | 0 | 0 | 0 | `3C2AB168773C248C03F4109C628D6F9F3603A8DE94A85D7B76E42C570E4DE09B` |
| [`black_wand/header/black_wand_DO_Display.fxh`](../../black_wand/header/black_wand_DO_Display.fxh) | family-internal surface | 1 | 0 | 7 | 0 | 1 | `5CBD9A53803C4C160FD5401A47B1543DBB6A71731812EAECB3EE8E79D5EE3457` |
| [`black_wand/header/black_wand_DO_LumaFallback.fxh`](../../black_wand/header/black_wand_DO_LumaFallback.fxh) | family-internal surface | 1 | 0 | 18 | 0 | 1 | `312D31200E97765BA09977050B0E2AA094644D18017FD483802838D7A4CBBDE6` |
| [`black_wand/header/black_wand_DO_Normal.fxh`](../../black_wand/header/black_wand_DO_Normal.fxh) | family-internal surface | 1 | 0 | 3 | 0 | 1 | `D0D493353ABB13B92FE48B25812BDFE6DFD29F834488368278D82CE8CE6CD12F` |
| [`black_wand/header/black_wand_DO_OfficialDetail.fxh`](../../black_wand/header/black_wand_DO_OfficialDetail.fxh) | family-internal surface | 1 | 0 | 11 | 0 | 1 | `81DA9601E728DA4C4EE071B204CA0681289E5DA2884FA5986187CACE50EC91A2` |
| [`black_wand/header/black_wand_DO_Oracle.fxh`](../../black_wand/header/black_wand_DO_Oracle.fxh) | family-internal surface | 1 | 0 | 7 | 0 | 1 | `FF2ADC25EC31DDAD7E69ED95E5E29BC3D51D02750865E789354CC1C83C5F390E` |
| [`black_wand/header/black_wand_DO_RMProbe.fxh`](../../black_wand/header/black_wand_DO_RMProbe.fxh) | family-internal surface | 1 | 0 | 4 | 0 | 1 | `32AF9C7FE6AE280DB21205031E3F8765682645DC6F062774790C9074E19CFFAE` |
| [`black_wand/header/black_wand_DO_Safe.fxh`](../../black_wand/header/black_wand_DO_Safe.fxh) | family-internal surface | 1 | 0 | 9 | 0 | 1 | `2C40DF883F26C9368E7E739259CB4EFECA1F2716BE320BEDC81B098DCA110739` |
| [`black_wand/header/black_wand_Gate_Server.fxh`](../../black_wand/header/black_wand_Gate_Server.fxh) | family-internal surface | 8 | 0 | 6 | 0 | 2 | `B667D6BC744AA1C91956139F48AD19B215F6D3EB218D3C2D0632EDFFEF64DF1B` |
| [`black_wand/header/black_wand_Hatch_Adapter.fxh`](../../black_wand/header/black_wand_Hatch_Adapter.fxh) | shared/support surface | 23 | 0 | 5 | 0 | 1 | `B94614355CE5B131124581C09DDBB83D65DD2F4FC3FCB3D408BB37752FD8CF6F` |
| [`black_wand/header/black_wand_Helper_All.fxh`](../../black_wand/header/black_wand_Helper_All.fxh) | family-internal surface | 1 | 0 | 0 | 0 | 5 | `37185AEA017C6E1A19232E58F00C01EAE12DA372F7BFD08252284342C7655F2D` |
| [`black_wand/header/black_wand_Helper_FirstTap.fxh`](../../black_wand/header/black_wand_Helper_FirstTap.fxh) | family-internal surface | 1 | 0 | 5 | 0 | 3 | `2E3036E027C27F90B2425BCB55839A9E40CD4ADF5587CF3B14241B81F88E7451` |
| [`black_wand/header/black_wand_Helper_OneStepEffect.fxh`](../../black_wand/header/black_wand_Helper_OneStepEffect.fxh) | family-internal surface | 1 | 0 | 3 | 0 | 1 | `4244B1920532D3C01C63711DE4735AEC85916B5ABBC5F495D29FA1D260105ADC` |
| [`black_wand/header/black_wand_Helper_Output.fxh`](../../black_wand/header/black_wand_Helper_Output.fxh) | family-internal surface | 1 | 0 | 8 | 0 | 2 | `7F0CB8D324883A1CEFC6DEFBC8B9EB8D403B39ED7DBB2A4A40A45A71291AA47A` |
| [`black_wand/header/black_wand_Helper_RoleMasks.fxh`](../../black_wand/header/black_wand_Helper_RoleMasks.fxh) | family-internal surface | 1 | 0 | 4 | 0 | 1 | `74AA7F6FFC6D57EFE1C944940E255F49F1E1BA48CAD9B8E525C81AB0219B6B36` |
| [`black_wand/header/black_wand_Lens_Adapter.fxh`](../../black_wand/header/black_wand_Lens_Adapter.fxh) | shared/support surface | 32 | 0 | 12 | 0 | 3 | `626607CC597C3090411EE4581B1C19C3C44AAAB05E594905618CAB34E7A43F0F` |
| [`black_wand/header/black_wand_Mask_Adapter.fxh`](../../black_wand/header/black_wand_Mask_Adapter.fxh) | shared/support surface | 38 | 0 | 13 | 0 | 1 | `923F9F896595807A020D217EE427502D1391B5C7B31219AB3B65AB2CD7E3310B` |
| [`black_wand/header/black_wand_Pattern_Adapter.fxh`](../../black_wand/header/black_wand_Pattern_Adapter.fxh) | shared/support surface | 1 | 0 | 5 | 0 | 0 | `D1E6129DA97F02E17C9E875D79E1A9F64DCF546D11D4017D830C38783E9B3DC3` |
| [`black_wand/header/black_wand_Primitive_All.fxh`](../../black_wand/header/black_wand_Primitive_All.fxh) | family-internal surface | 1 | 0 | 0 | 0 | 4 | `975D1A2EB886628BBB672E84BEF809B8147C6831D910522C702CFFCA0744E7D9` |
| [`black_wand/header/black_wand_Primitive_Color.fxh`](../../black_wand/header/black_wand_Primitive_Color.fxh) | family-internal surface | 1 | 0 | 6 | 0 | 2 | `4493B546031A4292D96CCE155D17FD7913887CD0279382A0D03B6E29EC591ACF` |
| [`black_wand/header/black_wand_Primitive_Depth.fxh`](../../black_wand/header/black_wand_Primitive_Depth.fxh) | family-internal surface | 3 | 0 | 6 | 0 | 2 | `A37542BC5A70E83329C8C2F9702F4E7BAE1A78F9F9EAE64A3C6FB3416C39EBAA` |
| [`black_wand/header/black_wand_Primitive_Gate.fxh`](../../black_wand/header/black_wand_Primitive_Gate.fxh) | family-internal surface | 1 | 0 | 3 | 0 | 2 | `3E247A841674B04DC0011F30D422CB145ED41DBAA771A3ACC4F3FD636C09233E` |
| [`black_wand/header/black_wand_Primitive_Hatch.fxh`](../../black_wand/header/black_wand_Primitive_Hatch.fxh) | family-internal surface | 1 | 0 | 4 | 0 | 2 | `3449CF8F73F329586A42B7E570693D82D037BF2EC03CEA88B7297932CBBF2958` |
| [`black_wand/header/black_wand_Primitive_Lens.fxh`](../../black_wand/header/black_wand_Primitive_Lens.fxh) | family-internal surface | 1 | 0 | 4 | 0 | 2 | `159ABAA245586859D08D88E9263B4508C60D1EB2C23DF48E5D61E8820A0CB74D` |
| [`black_wand/header/black_wand_Primitive_Mask.fxh`](../../black_wand/header/black_wand_Primitive_Mask.fxh) | family-internal surface | 1 | 0 | 6 | 0 | 2 | `BE86F897063AAA07A917B21BBE2DFF5F08DA5421F517955333E5F53317D3BFE6` |
| [`black_wand/header/black_wand_Primitive_Reduce.fxh`](../../black_wand/header/black_wand_Primitive_Reduce.fxh) | family-internal surface | 1 | 0 | 4 | 0 | 2 | `357F7E2F1F318FC7084B9049CCBFC594CA8112D2C04A26A5DF1288D1B39CB095` |
| [`black_wand/header/black_wand_Primitive_Safe.fxh`](../../black_wand/header/black_wand_Primitive_Safe.fxh) | family-internal surface | 2 | 0 | 10 | 0 | 6 | `CB1EC59C936B6201ED39D115E672B18CA334499307282FEC5624E0DA1009F418` |
| [`black_wand/header/black_wand_Primitive_Source.fxh`](../../black_wand/header/black_wand_Primitive_Source.fxh) | family-internal surface | 1 | 0 | 4 | 0 | 1 | `E4A4CB03637CCDB0724814E263BE89C880C81F24366E38FCBBC1E3D3F45F3A57` |
| [`black_wand/header/black_wand_Primitive_Weight.fxh`](../../black_wand/header/black_wand_Primitive_Weight.fxh) | family-internal surface | 1 | 0 | 2 | 0 | 2 | `9CC9F087E58D350A64387608DB3C8A850DD35635027BCAF844A70DFD04AD86C7` |
| [`black_wand/header/black_wand_Procedural_All.fxh`](../../black_wand/header/black_wand_Procedural_All.fxh) | family-internal surface | 1 | 0 | 0 | 0 | 1 | `4E0CE8D3172332B6ACA183BA18A8465E9EFE097DD42BC816FC798595AB3F1A89` |
| [`black_wand/header/black_wand_Procedural_Color.fxh`](../../black_wand/header/black_wand_Procedural_Color.fxh) | family-internal surface | 1 | 0 | 16 | 0 | 9 | `C095F6408E09D6ACF124ED18B1773F52D7D3182358D0609A413F91C282AD6713` |
| [`black_wand/header/black_wand_Procedural_ComplexGlue.fxh`](../../black_wand/header/black_wand_Procedural_ComplexGlue.fxh) | family-internal surface | 1 | 0 | 10 | 0 | 1 | `4E8631DEFF4805333E3DE8E78447FA7DA759739491F529A0C0BF248FE6F2F682` |
| [`black_wand/header/black_wand_Procedural_ComposeGlue.fxh`](../../black_wand/header/black_wand_Procedural_ComposeGlue.fxh) | family-internal surface | 1 | 0 | 6 | 0 | 1 | `61759F5B0D11622E6472C85A147010AF9E9C3A28E7040FE92A88E6B7B959C090` |
| [`black_wand/header/black_wand_Procedural_DebugGlue.fxh`](../../black_wand/header/black_wand_Procedural_DebugGlue.fxh) | family-internal surface | 1 | 0 | 7 | 0 | 1 | `C2E7DC47598359E53DFB43F2D14729187938ED8D6A250C724CC6BEE8C85B4E83` |
| [`black_wand/header/black_wand_Procedural_DepthGlue.fxh`](../../black_wand/header/black_wand_Procedural_DepthGlue.fxh) | family-internal surface | 1 | 0 | 8 | 0 | 1 | `721D40DFAE852FA8A3634A15E92B0241421AC8591A3370B513E8F6BB47185CCD` |
| [`black_wand/header/black_wand_Procedural_GateGlue.fxh`](../../black_wand/header/black_wand_Procedural_GateGlue.fxh) | family-internal surface | 1 | 0 | 5 | 0 | 1 | `83F7A8294D304954B1F09ED687A2D4A908E216A52CCC50A72229253983353CC7` |
| [`black_wand/header/black_wand_Procedural_HatchGlue.fxh`](../../black_wand/header/black_wand_Procedural_HatchGlue.fxh) | family-internal surface | 1 | 0 | 7 | 0 | 1 | `6C27CB448C851B3E3D7B33A02D22F091E9C7AD26F27FBED5DFD4F5DC4B670EA8` |
| [`black_wand/header/black_wand_Procedural_LensGlue.fxh`](../../black_wand/header/black_wand_Procedural_LensGlue.fxh) | family-internal surface | 1 | 0 | 8 | 0 | 1 | `11614E38F6F282EB1D002CD1B1460ED326C89138E1A8F5A7C677A9CF451B9F71` |
| [`black_wand/header/black_wand_Procedural_MaskGlue.fxh`](../../black_wand/header/black_wand_Procedural_MaskGlue.fxh) | family-internal surface | 1 | 0 | 11 | 0 | 1 | `325F79DAC46BBEFC7ADB03ED07AD4B5CBF97AB3BD8CC8CEECC652ED5310CBDC7` |
| [`black_wand/header/black_wand_Procedural_Noise.fxh`](../../black_wand/header/black_wand_Procedural_Noise.fxh) | family-internal surface | 1 | 0 | 8 | 0 | 1 | `58BD232E1808CFE69E41C8BF1FE8AC76CCE55A4E90FB00D170A5827593031468` |
| [`black_wand/header/black_wand_Procedural_OutputGlue.fxh`](../../black_wand/header/black_wand_Procedural_OutputGlue.fxh) | family-internal surface | 1 | 0 | 7 | 0 | 2 | `A2D4F929CB658182E49BCB31892F67378A697EF8266CB42948A97E142039F727` |
| [`black_wand/header/black_wand_Procedural_Pattern.fxh`](../../black_wand/header/black_wand_Procedural_Pattern.fxh) | family-internal surface | 1 | 0 | 12 | 0 | 2 | `E408DF0EE17190C300C0C3BD9D698221096406F2CB955B80E5BE488B14B1108D` |
| [`black_wand/header/black_wand_Procedural_ReduceGlue.fxh`](../../black_wand/header/black_wand_Procedural_ReduceGlue.fxh) | family-internal surface | 1 | 0 | 8 | 0 | 1 | `F71F3C5AF55556ACB5F7567A7D8ABF4D76C6B381EB8B584A8FD959E972D0A587` |
| [`black_wand/header/black_wand_Procedural_SafeMath.fxh`](../../black_wand/header/black_wand_Procedural_SafeMath.fxh) | family-internal surface | 1 | 0 | 22 | 0 | 8 | `90B161CAF55450A7F4F8F22AE6FDE5F2D166A8B4B7EABE419904F813FE927D10` |
| [`black_wand/header/black_wand_Procedural_Source.fxh`](../../black_wand/header/black_wand_Procedural_Source.fxh) | family-internal surface | 1 | 0 | 8 | 0 | 2 | `76C75C2E908CB0E6FB6E5AB7FC113F0D192DD0652E939323AC4EFC5F11DCB96D` |
| [`black_wand/header/black_wand_Procedural_UV.fxh`](../../black_wand/header/black_wand_Procedural_UV.fxh) | family-internal surface | 1 | 0 | 20 | 0 | 3 | `7B94F482CED59901BE5915B8E3A078D9CA421B95B3D4CC222BD86B8BECDDB8A3` |
| [`black_wand/header/black_wand_Procedural_WeightGlue.fxh`](../../black_wand/header/black_wand_Procedural_WeightGlue.fxh) | family-internal surface | 1 | 0 | 5 | 0 | 1 | `A11DEEA4A78F0B5C0C3856E5CF26274DC3FA9010CD2B6C128710D06FCC048487` |
| [`black_wand/header/black_wand_Reduce_Server.fxh`](../../black_wand/header/black_wand_Reduce_Server.fxh) | family-internal surface | 6 | 0 | 7 | 0 | 2 | `70DA5C2BC2B5E0A27C34A0A8875CC2719DCEBC775D1F3D9F310049D11C7B0B58` |
| [`black_wand/header/black_wand_RM_All.fxh`](../../black_wand/header/black_wand_RM_All.fxh) | family-internal surface | 1 | 0 | 0 | 0 | 1 | `5BAD1F53E4CC64BABD2333B49CCB36662EF15E042836A3BCBF878732C34B5FF6` |
| [`black_wand/header/black_wand_RM_Debug.fxh`](../../black_wand/header/black_wand_RM_Debug.fxh) | family-internal surface | 1 | 0 | 5 | 0 | 1 | `9735BA1A6B2D6BE79BD355B1C84BE59C5F1B6252D734F84F4C9502505592F9E9` |
| [`black_wand/header/black_wand_RM_Lighting.fxh`](../../black_wand/header/black_wand_RM_Lighting.fxh) | family-internal surface | 1 | 0 | 5 | 0 | 1 | `D655D6A732EE9D3CB0050334EC5B10C4FB30151023BDD68192AB756D2673D79A` |
| [`black_wand/header/black_wand_RM_March.fxh`](../../black_wand/header/black_wand_RM_March.fxh) | family-internal surface | 1 | 0 | 4 | 0 | 1 | `A9183994EA256BF86B72D405F8BA3031287662B15AF354BAD8917FCD1445B351` |
| [`black_wand/header/black_wand_RM_Normal.fxh`](../../black_wand/header/black_wand_RM_Normal.fxh) | family-internal surface | 1 | 0 | 3 | 0 | 1 | `C214652C4881AA8981BF1A7493C6C0E35E2F3FF0F90AAF3544E3282E23F5ED72` |
| [`black_wand/header/black_wand_RM_Ops.fxh`](../../black_wand/header/black_wand_RM_Ops.fxh) | family-internal surface | 1 | 0 | 12 | 0 | 1 | `F7C75265BA13D60042E44AB657B829706DE2E352BD9DED0253C5B6698CD5D65F` |
| [`black_wand/header/black_wand_RM_Ray.fxh`](../../black_wand/header/black_wand_RM_Ray.fxh) | family-internal surface | 1 | 0 | 3 | 0 | 1 | `1B576BAFDF5E576D2A10EB53BB78AAE45BA3E1107D3C542462C6957AC1DA0B15` |
| [`black_wand/header/black_wand_RM_Safe.fxh`](../../black_wand/header/black_wand_RM_Safe.fxh) | family-internal surface | 1 | 0 | 14 | 0 | 1 | `3B5D01955C06FECAA3EFB5752D93AB47D29339DDACE1CDFF98AAA2C12D9DE21C` |
| [`black_wand/header/black_wand_RM_Scene.fxh`](../../black_wand/header/black_wand_RM_Scene.fxh) | family-internal surface | 9 | 0 | 2 | 0 | 1 | `AB37B021896422EE8E10888308313F5300C0B47623AED55E34398C2514F329CF` |
| [`black_wand/header/black_wand_RM_SDF_Basic.fxh`](../../black_wand/header/black_wand_RM_SDF_Basic.fxh) | family-internal surface | 1 | 0 | 9 | 0 | 1 | `035A46EE6CA5725E62C0823928CD2ACFA5E0B38048C67870432E83B7275FA17B` |
| [`black_wand/header/black_wand_RM_Types.fxh`](../../black_wand/header/black_wand_RM_Types.fxh) | family-internal surface | 8 | 3 | 2 | 0 | 1 | `36F19CAF41AE8BDC089DF32D9AE1E9C107CB8F0D59DED744BCE64C693866429A` |
| [`black_wand/header/black_wand_Sampler_Server.fxh`](../../black_wand/header/black_wand_Sampler_Server.fxh) | family-internal surface | 1 | 1 | 1 | 0 | 0 | `6C4BD1E2C4AB9E99E7DBC14539E766DB1D12D06225C82BE469BF19D13BDE9C66` |
| [`black_wand/header/black_wand_Weight_Server.fxh`](../../black_wand/header/black_wand_Weight_Server.fxh) | family-internal surface | 6 | 0 | 4 | 0 | 2 | `66547B04D7B0C14BA4ED00E66CC691DA1800EFF5DCB5A394B5D277BFCE5409FD` |
| [`black_wand/header/BlackWand_Common.fxh`](../../black_wand/header/BlackWand_Common.fxh) | family-internal surface | 4 | 0 | 18 | 0 | 11 | `84F6678140B2F33E72EE7C0BF7D21B666C5C84166DD5045D7145D8684D3714CD` |
| [`black_wand/header/BlackWand_Extended_Common.fxh`](../../black_wand/header/BlackWand_Extended_Common.fxh) | family-internal surface | 1 | 0 | 15 | 0 | 11 | `3F046DE1815575DBD039207574D378B95042F1D8DDFF3033A245E7B270685800` |
| [`black_wand/header/hexing_eye.fxh`](../../black_wand/header/hexing_eye.fxh) | family-internal surface | 40 | 0 | 64 | 0 | 1 | `E0EF127B3EE75B912540D1A3783E1255B02EEC9F8CD7DBD20045FDC2C7724A81` |
| [`black_wand/header/kaleidoscope.fxh`](../../black_wand/header/kaleidoscope.fxh) | family-internal surface | 38 | 0 | 47 | 0 | 1 | `310D59A9587E22A9E82FC7B651CFCCAB68414F49767C9F1CF9D6E7F89AB4AEDB` |
| [`black_wand/header/looking_glass.fxh`](../../black_wand/header/looking_glass.fxh) | family-internal surface | 31 | 0 | 37 | 2 | 1 | `6B152A666828D247F651A480F4F26A083E18620FD76BA4600A05206E3B7A7F97` |
| [`black_wand/header/MIXSR_API_LoopSafe.fxh`](../../black_wand/header/MIXSR_API_LoopSafe.fxh) | named API candidate | 1 | 0 | 7 | 0 | 1 | `9667081ABC26667A20C5619B6B201AAD90E73A0DF1842EB761DCFA6531FDDC0D` |
| [`black_wand/header/miXSR_shared_core.fxh`](../../black_wand/header/miXSR_shared_core.fxh) | shared/support surface | 1 | 0 | 8 | 0 | 7 | `BF077C1B2FF187FC157689448919D634A9AFE8C2BD3C74F9C9DFAE782E549205` |
| [`black_wand/header/miXSR_shared_depth.fxh`](../../black_wand/header/miXSR_shared_depth.fxh) | shared/support surface | 1 | 0 | 5 | 0 | 3 | `79A0EA19549C202E217AD7F2450DDCF47888D91E0B8ACE14D6738907524A2819` |
| [`black_wand/header/miXSR_shared_fibonacci.fxh`](../../black_wand/header/miXSR_shared_fibonacci.fxh) | shared/support surface | 2 | 0 | 6 | 0 | 3 | `F0660EA90C8A4907B058504A33D016AF64814B4D5195E678BEDDD3C97373E789` |
| [`black_wand/header/miXSR_shared_lens55.fxh`](../../black_wand/header/miXSR_shared_lens55.fxh) | shared/support surface | 1 | 0 | 4 | 0 | 1 | `B6297728820ACE4A4B32C24252BA95DADFB01D5686D92F669E2B96D87A9FEA4D` |
| [`black_wand/header/miXSR_shared_pattern.fxh`](../../black_wand/header/miXSR_shared_pattern.fxh) | shared/support surface | 1 | 0 | 2 | 0 | 3 | `488009283E180772826AEEA88A71FAAAD7EBA18191E0B7F61EDAACA5D1B83F43` |
| [`book_of_death/header/BlueSmoke.fxh`](../../book_of_death/header/BlueSmoke.fxh) | family-internal surface | 19 | 0 | 35 | 0 | 1 | `6B1D08EC5CFBA963C726873A610CA154C347DEBCC0B59DB612DBC4C129D2736A` |
| [`book_of_death/header/CrookedTongue.fxh`](../../book_of_death/header/CrookedTongue.fxh) | family-internal surface | 8 | 0 | 20 | 0 | 1 | `3056FE99D00EF8BB7CB71879E5E13C9A296F41EC23C31CD0547ADCAD017752B9` |
| [`book_of_death/header/CrystalMass.fxh`](../../book_of_death/header/CrystalMass.fxh) | family-internal surface | 14 | 0 | 26 | 0 | 1 | `103F1D171B35651FDB3960DD36286ED80708AA3CD67838BE590059C1D515E66A` |
| [`book_of_death/header/DeathGaze.fxh`](../../book_of_death/header/DeathGaze.fxh) | family-internal surface | 19 | 0 | 35 | 0 | 1 | `5B988D94032AD648703A410D958168068A35F39D6B65E2EDCEF73B4ADC3DEB92` |
| [`book_of_death/header/FoolsGold.fxh`](../../book_of_death/header/FoolsGold.fxh) | family-internal surface | 19 | 0 | 38 | 0 | 1 | `BE77DC1B3867458F2A37D65543363D3BF62025E286827D45DC4B8CDE01650D2C` |
| [`book_of_death/header/GoldenHour.fxh`](../../book_of_death/header/GoldenHour.fxh) | family-internal surface | 23 | 0 | 44 | 0 | 1 | `20D0FD085556A5A82BC0CD858A604EA4308923F1243E31A2124042777E798585` |
| [`book_of_death/header/MIXSR_API_LoopSafe.fxh`](../../book_of_death/header/MIXSR_API_LoopSafe.fxh) | named API candidate | 1 | 0 | 7 | 0 | 8 | `9667081ABC26667A20C5619B6B201AAD90E73A0DF1842EB761DCFA6531FDDC0D` |
| [`book_of_death/header/ObsidianMirror.fxh`](../../book_of_death/header/ObsidianMirror.fxh) | family-internal surface | 11 | 0 | 30 | 0 | 1 | `870733A8380108F91AF8BA398281CA17ADE3F4CB7366F9B3202AFEF48DBCDC13` |
| [`book_of_death/header/PottingClay.fxh`](../../book_of_death/header/PottingClay.fxh) | family-internal surface | 19 | 0 | 34 | 0 | 1 | `DB0CB095694BD22F8B656357CFE9BEE6458B08595D4834B0CE226AB31A97B485` |
| [`book_of_death/header/shared_core.fxh`](../../book_of_death/header/shared_core.fxh) | family-internal surface | 1 | 0 | 8 | 0 | 11 | `8EEFA29B6398C8AD562CAB0400A97D165E650315610FDA1629A5700859989AE9` |
| [`book_of_death/header/shared_depth.fxh`](../../book_of_death/header/shared_depth.fxh) | family-internal surface | 1 | 0 | 5 | 0 | 8 | `7B84EA9A2D87A4F86EB47466DA11B7714EA43B7540341850BFD3EB8E8708AAD3` |
| [`book_of_death/header/shared_fibonacci.fxh`](../../book_of_death/header/shared_fibonacci.fxh) | family-internal surface | 1 | 0 | 4 | 0 | 7 | `C913D174B447934CCF64F49874488A3075138CA58406BADB6B021923A5C5F807` |
| [`book_of_death/header/shared_lens55.fxh`](../../book_of_death/header/shared_lens55.fxh) | family-internal surface | 1 | 0 | 4 | 0 | 8 | `5AB89171D098C1AF1370273C5D4BEF4532BC52D92D9F08D24849798CE0B2109B` |
| [`book_of_death/header/SpiritWorld.fxh`](../../book_of_death/header/SpiritWorld.fxh) | family-internal surface | 12 | 0 | 37 | 0 | 1 | `36789E2E363B4B26E90AA01AD3EBBC135B01B1FFBD0AC7F3081C9C7FBC149B6D` |
| [`depth_oracle/header/black_wand_Depth_Adapter.fxh`](../../depth_oracle/header/black_wand_Depth_Adapter.fxh) | shared/support surface | 4 | 0 | 9 | 0 | 0 | `824525F24170547E562AA47B857C6B8A762F345BA645F28B956D61F0C471E3C0` |
| [`depth_oracle/header/black_wand_DO_All.fxh`](../../depth_oracle/header/black_wand_DO_All.fxh) | family-internal surface | 1 | 0 | 0 | 0 | 1 | `3C2AB168773C248C03F4109C628D6F9F3603A8DE94A85D7B76E42C570E4DE09B` |
| [`depth_oracle/header/black_wand_DO_Display.fxh`](../../depth_oracle/header/black_wand_DO_Display.fxh) | family-internal surface | 1 | 0 | 7 | 0 | 1 | `5CBD9A53803C4C160FD5401A47B1543DBB6A71731812EAECB3EE8E79D5EE3457` |
| [`depth_oracle/header/black_wand_DO_LumaFallback.fxh`](../../depth_oracle/header/black_wand_DO_LumaFallback.fxh) | family-internal surface | 1 | 0 | 18 | 0 | 1 | `312D31200E97765BA09977050B0E2AA094644D18017FD483802838D7A4CBBDE6` |
| [`depth_oracle/header/black_wand_DO_Normal.fxh`](../../depth_oracle/header/black_wand_DO_Normal.fxh) | family-internal surface | 1 | 0 | 3 | 0 | 1 | `D0D493353ABB13B92FE48B25812BDFE6DFD29F834488368278D82CE8CE6CD12F` |
| [`depth_oracle/header/black_wand_DO_OfficialDetail.fxh`](../../depth_oracle/header/black_wand_DO_OfficialDetail.fxh) | family-internal surface | 1 | 0 | 11 | 0 | 1 | `81DA9601E728DA4C4EE071B204CA0681289E5DA2884FA5986187CACE50EC91A2` |
| [`depth_oracle/header/black_wand_DO_Oracle.fxh`](../../depth_oracle/header/black_wand_DO_Oracle.fxh) | family-internal surface | 1 | 0 | 7 | 0 | 1 | `FF2ADC25EC31DDAD7E69ED95E5E29BC3D51D02750865E789354CC1C83C5F390E` |
| [`depth_oracle/header/black_wand_DO_RMProbe.fxh`](../../depth_oracle/header/black_wand_DO_RMProbe.fxh) | family-internal surface | 1 | 0 | 4 | 0 | 1 | `32AF9C7FE6AE280DB21205031E3F8765682645DC6F062774790C9074E19CFFAE` |
| [`depth_oracle/header/black_wand_DO_Safe.fxh`](../../depth_oracle/header/black_wand_DO_Safe.fxh) | family-internal surface | 1 | 0 | 9 | 0 | 1 | `2C40DF883F26C9368E7E739259CB4EFECA1F2716BE320BEDC81B098DCA110739` |
| [`depth_oracle/header/black_wand_RM_All.fxh`](../../depth_oracle/header/black_wand_RM_All.fxh) | family-internal surface | 1 | 0 | 0 | 0 | 0 | `5BAD1F53E4CC64BABD2333B49CCB36662EF15E042836A3BCBF878732C34B5FF6` |
| [`depth_oracle/header/black_wand_RM_Debug.fxh`](../../depth_oracle/header/black_wand_RM_Debug.fxh) | family-internal surface | 1 | 0 | 5 | 0 | 1 | `9735BA1A6B2D6BE79BD355B1C84BE59C5F1B6252D734F84F4C9502505592F9E9` |
| [`depth_oracle/header/black_wand_RM_Lighting.fxh`](../../depth_oracle/header/black_wand_RM_Lighting.fxh) | family-internal surface | 1 | 0 | 5 | 0 | 1 | `D655D6A732EE9D3CB0050334EC5B10C4FB30151023BDD68192AB756D2673D79A` |
| [`depth_oracle/header/black_wand_RM_March.fxh`](../../depth_oracle/header/black_wand_RM_March.fxh) | family-internal surface | 1 | 0 | 4 | 0 | 1 | `A9183994EA256BF86B72D405F8BA3031287662B15AF354BAD8917FCD1445B351` |
| [`depth_oracle/header/black_wand_RM_Normal.fxh`](../../depth_oracle/header/black_wand_RM_Normal.fxh) | family-internal surface | 1 | 0 | 3 | 0 | 1 | `C214652C4881AA8981BF1A7493C6C0E35E2F3FF0F90AAF3544E3282E23F5ED72` |
| [`depth_oracle/header/black_wand_RM_Ops.fxh`](../../depth_oracle/header/black_wand_RM_Ops.fxh) | family-internal surface | 1 | 0 | 12 | 0 | 1 | `F7C75265BA13D60042E44AB657B829706DE2E352BD9DED0253C5B6698CD5D65F` |
| [`depth_oracle/header/black_wand_RM_Ray.fxh`](../../depth_oracle/header/black_wand_RM_Ray.fxh) | family-internal surface | 1 | 0 | 3 | 0 | 1 | `1B576BAFDF5E576D2A10EB53BB78AAE45BA3E1107D3C542462C6957AC1DA0B15` |
| [`depth_oracle/header/black_wand_RM_Safe.fxh`](../../depth_oracle/header/black_wand_RM_Safe.fxh) | family-internal surface | 1 | 0 | 14 | 0 | 1 | `3B5D01955C06FECAA3EFB5752D93AB47D29339DDACE1CDFF98AAA2C12D9DE21C` |
| [`depth_oracle/header/black_wand_RM_Scene.fxh`](../../depth_oracle/header/black_wand_RM_Scene.fxh) | family-internal surface | 9 | 0 | 2 | 0 | 1 | `AB37B021896422EE8E10888308313F5300C0B47623AED55E34398C2514F329CF` |
| [`depth_oracle/header/black_wand_RM_SDF_Basic.fxh`](../../depth_oracle/header/black_wand_RM_SDF_Basic.fxh) | family-internal surface | 1 | 0 | 9 | 0 | 1 | `035A46EE6CA5725E62C0823928CD2ACFA5E0B38048C67870432E83B7275FA17B` |
| [`depth_oracle/header/black_wand_RM_Types.fxh`](../../depth_oracle/header/black_wand_RM_Types.fxh) | family-internal surface | 8 | 3 | 2 | 0 | 1 | `36F19CAF41AE8BDC089DF32D9AE1E9C107CB8F0D59DED744BCE64C693866429A` |
| [`depth_oracle/header/miXSR_shared_core.fxh`](../../depth_oracle/header/miXSR_shared_core.fxh) | shared/support surface | 1 | 0 | 8 | 0 | 1 | `BF077C1B2FF187FC157689448919D634A9AFE8C2BD3C74F9C9DFAE782E549205` |
| [`depth_oracle/header/miXSR_shared_depth.fxh`](../../depth_oracle/header/miXSR_shared_depth.fxh) | shared/support surface | 1 | 0 | 5 | 0 | 1 | `79A0EA19549C202E217AD7F2450DDCF47888D91E0B8ACE14D6738907524A2819` |
| [`golden_weave/header/GoldenWeave_Primitives.fxh`](../../golden_weave/header/GoldenWeave_Primitives.fxh) | family-internal surface | 7 | 2 | 25 | 0 | 1 | `2B548BD42B950C5337F8C1275FF3B62E47B5151B8A97636ED83364BF6665E6BA` |
| [`legacy_lenses/header/hexing_eye.fxh`](../../legacy_lenses/header/hexing_eye.fxh) | family-internal surface | 39 | 0 | 63 | 0 | 1 | `6E487F52A718ADA453869F4E0D3FDE48F8BEA7931F6418606A71DF9057325682` |
| [`legacy_lenses/header/kaleidoscope.fxh`](../../legacy_lenses/header/kaleidoscope.fxh) | family-internal surface | 38 | 0 | 47 | 0 | 1 | `310D59A9587E22A9E82FC7B651CFCCAB68414F49767C9F1CF9D6E7F89AB4AEDB` |
| [`legacy_lenses/header/looking_glass.fxh`](../../legacy_lenses/header/looking_glass.fxh) | family-internal surface | 30 | 0 | 34 | 2 | 1 | `776003ABC49277070AA8B2923B0B4A703D1773EBF2FE29887CA541826304567E` |
| [`legacy_lenses/header/MIXSR_API_LoopSafe.fxh`](../../legacy_lenses/header/MIXSR_API_LoopSafe.fxh) | named API candidate | 1 | 0 | 7 | 0 | 3 | `9667081ABC26667A20C5619B6B201AAD90E73A0DF1842EB761DCFA6531FDDC0D` |
| [`legacy_lenses/header/miXSR_shared_core.fxh`](../../legacy_lenses/header/miXSR_shared_core.fxh) | shared/support surface | 1 | 0 | 8 | 0 | 6 | `BF077C1B2FF187FC157689448919D634A9AFE8C2BD3C74F9C9DFAE782E549205` |
| [`legacy_lenses/header/miXSR_shared_depth.fxh`](../../legacy_lenses/header/miXSR_shared_depth.fxh) | shared/support surface | 1 | 0 | 5 | 0 | 2 | `79A0EA19549C202E217AD7F2450DDCF47888D91E0B8ACE14D6738907524A2819` |
| [`legacy_lenses/header/miXSR_shared_fibonacci.fxh`](../../legacy_lenses/header/miXSR_shared_fibonacci.fxh) | shared/support surface | 2 | 0 | 5 | 0 | 3 | `9275EC57624D64A7FBB758AB866DDA2BB340B38F2251D647C8CD9CED568E23E3` |
| [`legacy_lenses/header/miXSR_shared_lens55.fxh`](../../legacy_lenses/header/miXSR_shared_lens55.fxh) | shared/support surface | 1 | 0 | 4 | 0 | 1 | `B6297728820ACE4A4B32C24252BA95DADFB01D5686D92F669E2B96D87A9FEA4D` |
| [`legacy_lenses/header/miXSR_shared_pattern.fxh`](../../legacy_lenses/header/miXSR_shared_pattern.fxh) | shared/support surface | 1 | 0 | 2 | 0 | 2 | `488009283E180772826AEEA88A71FAAAD7EBA18191E0B7F61EDAACA5D1B83F43` |

## Declaration lookup

`SYMBOLS.json` carries the complete extracted macro, struct/field, function,
resource, uniform, technique, include-edge, source-line, byte-size, and SHA-256
inventory. Use it for exact lookup rather than treating this classification
table as a semantic specification for internal helpers.

## Validation boundary

Static extraction and hash equality establish only the present declaration
surface. They do not establish consumer compilation, numerical equivalence on
all backends, runtime safety, performance, or a future compatibility guarantee.
