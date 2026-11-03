#include "db_camera.h"
#include "db_wire.h"
#include "db_log.h"
#include "xil_printf.h"
#include "ov5640/ov5640_init.h"
int db_camera_init_pair(void)
{
    unsigned c;
    for(c=0;c<2;++c) {
        if(ov5640_init((u8)c,DB_WIDTH,DB_HEIGHT,DB_CAMERA_HTS,DB_CAMERA_VTS)) {
            xil_printf("ERROR CAMERA init camera=%u\r\n",c);return 0;
        }
    }
    xil_printf("CAMERA timing_hts=%u timing_vts=%u geometry=1280x720 baseline_register_sequence\r\n",DB_CAMERA_HTS,DB_CAMERA_VTS);
    return 1;
}
