#ifndef DB_CONFIG_H
#define DB_CONFIG_H
#include "db_wire.h"
#include "db_calibration.h"
/* Change the session on a new acquisition run and rebuild both applications.
 * No automatic session switching from untrusted/delayed data packets. */
#ifndef DB_SESSION_ID
#define DB_SESSION_ID 0x20261009U
#endif
#define DB_UDP_PORT 5001U
#define DB_TIMEOUT_US 150000U
/* Bring-up measured round-trip is 240--403 ms. A button measurement
 * additionally requires a capture sent after the button request. */
#define DB_FRESH_US 500000U
/* Initial static-target bring-up window, not a hardware exposure-sync claim. */
#define DB_MAX_SKEW_US 15000U
#define DB_MAX_DISTANCE_MM 3000U
#define DB_CAPTURE_BASE 0x01000000U
#define DB_CAPTURE_RIGHT_BASE 0x02000000U
#define DB_RESULT_BASE 0x03000000U
#define DB_RAW_TX_BASE 0x04000000U
#define DB_NETWORK_RX_BASE 0x05000000U
#define DB_WORKER_OUTPUT_BASE 0x06000000U
#define DB_MASK_BASE 0x07000000U
#define DB_MAP_BASE 0x08000000U
#endif
