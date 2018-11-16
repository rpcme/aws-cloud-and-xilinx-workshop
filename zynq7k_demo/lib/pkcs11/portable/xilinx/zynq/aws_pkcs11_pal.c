/*
 * Copyright (C) 2018 Xilinx, Inc.
 * Amazon FreeRTOS PKCS#11 for Xilinx Zynq Microzed V1.0.0
 * Copyright (C) 2018 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * http://aws.amazon.com/freertos
 * http://www.FreeRTOS.org
 */

/**
 * @file aws_pkcs11_pal.c
 * @brief Device specific helpers for PKCS11 Interface.
 */

/* C runtime includes. */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Amazon FreeRTOS Includes. */
#include "aws_pkcs11.h"
#include "aws_pkcs11_config.h"
#include "FreeRTOS.h"
#include "FreeRTOSIPConfig.h"
#include "ff.h"
#include "xil_printf.h"
#include "task.h"


/**
 * @brief Writes a file to local storage.
 *
 * Port-specific file write for crytographic information.
 *
 * @param[in] pcFileName    The name of the file to be written to.
 * @param[in] pucData       Data buffer to be written to file
 * @param[in] pulDataSize   Size (in bytes) of file data.
 *
 * @return pdTRUE if data was saved successfully to file,
 * pdFALSE otherwise.
 */
BaseType_t PKCS11_PAL_SaveFile( char * pcFileName,
                                uint8_t * pucData,
                                uint32_t ulDataSize )
{
	taskENTER_CRITICAL();
	static FIL fil;
	FRESULT Res;
	uint32_t n;

	if ((strncmp(pcFileName, pkcs11configFILE_NAME_CLIENT_CERTIFICATE, strlen(pkcs11configFILE_NAME_CLIENT_CERTIFICATE)) != 0) &&
		(strncmp(pcFileName, pkcs11configFILE_NAME_KEY, strlen(pkcs11configFILE_NAME_KEY)) != 0)) {
		taskEXIT_CRITICAL();
		xil_printf("PKCS11_PAL_SaveFile DEBUG: did not save %s \n\r", pcFileName);
		return pdFALSE;
	}

	Res = f_open(&fil, pcFileName, FA_CREATE_ALWAYS | FA_WRITE);
	if (Res) {
		taskEXIT_CRITICAL();
		xil_printf("PKCS11_PAL_SaveFile ERROR: Unable to open file %s  Res %d\r\n", pcFileName, Res);
		return pdFALSE;
	}

	Res = f_write(&fil, pucData, ulDataSize, &n);
	if ((n < ulDataSize) || (Res != 0)) {
		f_close(&fil);
		taskEXIT_CRITICAL();
		xil_printf("PKCS11_PAL_SaveFile ERROR: Write to file %s failed  Res %d\r\n", pcFileName, Res);
		return pdFALSE;
	}
	f_close(&fil);
	taskEXIT_CRITICAL();

	return pdTRUE;
}

/**
 * @brief Reads a file from local storage.
 *
 * Port-specific file access for crytographic information.
 *
 * @sa PKCS11_ReleaseFileData
 *
 * @param[in] pcFileName    The name of the file to be read.
 * @param[out] ppucData     Pointer to buffer for file data.
 * @param[out] pulDataSize  Size (in bytes) of data located in file.
 *
 * @return pdTRUE if data was retrieved successfully from files,
 * pdFALSE otherwise.
 */
BaseType_t PKCS11_PAL_ReadFile( char * pcFileName,
                                uint8_t ** ppucData,
                                uint32_t * pulDataSize )
{
	taskENTER_CRITICAL();
	static FIL fil;
	FRESULT Res;
	uint32_t n;
	uint8_t *buf;

	if ((strncmp(pcFileName, pkcs11configFILE_NAME_CLIENT_CERTIFICATE, strlen(pkcs11configFILE_NAME_CLIENT_CERTIFICATE)) != 0) &&
		(strncmp(pcFileName, pkcs11configFILE_NAME_KEY, strlen(pkcs11configFILE_NAME_KEY)) != 0)) {
		taskEXIT_CRITICAL();
		xil_printf("PKCS11_PAL_ReadFile DEBUG: did not read %s \n", pcFileName);
		return pdFALSE;
	}

	Res = f_open(&fil, pcFileName, FA_READ);
	if (Res) {
		taskEXIT_CRITICAL();
		xil_printf("PKCS11_PAL_ReadFile ERROR: Unable to open file %s  Res %d\r\n", pcFileName, Res);
		return pdFALSE;
	}

	n = fil.fsize;
	buf = pvPortMalloc(n);
	if (buf == NULL) {
		taskEXIT_CRITICAL();
		xil_printf("PKCS11_PAL_ReadFile ERROR: buf alloc failed \r\n");
		return pdFALSE;
	}

	Res = f_read(&fil, buf, n, pulDataSize);
	if ((*pulDataSize != n) || (Res != 0)) {
		f_close(&fil);
		vPortFree(buf);
		taskEXIT_CRITICAL();
		xil_printf("PKCS11_PAL_ReadFile ERROR: Read from file %s failed  Res %d\r\n", pcFileName, Res);
		return pdFALSE;
	}
	buf[n-1] = 0;
	*ppucData = buf;
	f_close(&fil);
	taskEXIT_CRITICAL();

	return pdTRUE;
}

/**
 * @brief Cleanup after PKCS11_ReadFile().
 *
 * @param[in] pucBuffer The buffer to free.
 * @param[in] ulBufferSize The length of the above buffer.
 */
void PKCS11_PAL_ReleaseFileData( uint8_t * pucBuffer,
                                 uint32_t ulBufferSize )
{
	vPortFree(pucBuffer);
}

/*-----------------------------------------------------------*/

//#if 0

int mbedtls_hardware_poll( void * data,
                           unsigned char * output,
                           size_t len,
                           size_t * olen )
{
	(void) data;

	int copylen = len;
	int size;
	int entropy;

	size = sizeof(entropy);

	while (copylen > 0) {
		entropy = rand( );
		if (entropy == 0) {
			xil_printf("Error RAND is returning 0 at copylen 0x%x \n\r", copylen);
		}

		memcpy(output, &entropy, size);
		output += size;
		copylen -= size;
	}
	*olen = len;

    return 0;
}
//#endif

#if 0

int mbedtls_nv_seed_read_x( unsigned char *buf, size_t buf_len )
{
	static FIL fil;
	FRESULT Res;
	uint32_t *n;
	unsigned char *SeedFname = "seedfile.dat";

	Res = f_open(&fil, SeedFname, FA_READ);
	if (Res) {
		xil_printf("Unable to open file %s  Res %d\r\n", SeedFname, Res);
			return (-1);
	}

	n = fil.fsize;
	Res = f_read(&fil, buf, buf_len, n);
	if ((*n != buf_len) || (Res != 0)) {
		xil_printf("Read from file %s failed  Res %d, req %d read %d \r\n", SeedFname, Res, buf_len, *n);
		f_close(&fil);
		return (-1);
	}
	f_close(&fil);

	//xil_printf("mbedtls_nv_seed_read_x 0x%x, 0x%x \n", buf_len, *(uint32_t *)buf);
	return 0;
}

int mbedtls_nv_seed_write_x( unsigned char *buf, size_t buf_len )
{
	static FIL fil;
	FRESULT Res;
	uint32_t n;
	unsigned char *SeedFname = "seedfile.dat";

	Res = f_open(&fil, SeedFname, FA_CREATE_ALWAYS | FA_WRITE);
	if (Res) {
		xil_printf("Unable to open file %s  Res %d\r\n", SeedFname, Res);
			return (-1);
	}

	Res = f_write(&fil, buf, buf_len, &n);
	if ((n != buf_len) || (Res != 0)) {
		xil_printf("Write to file %s failed  Res %d\r\n", SeedFname, Res);
		f_close(&fil);
			return (-1);
	}
	f_close(&fil);

	//xil_printf("mbedtls_nv_seed_write_x 0x%x, 0x%x \n", buf_len, *(uint32_t *)buf);
	return 0;
}
#endif

int platform_init_fs()
{
	static FATFS fatfs;
	FRESULT Res;
	TCHAR *Path = "0:/";

	/*
	 * Register volume work area, initialize device
	 */
	Res = f_mount(&fatfs, Path, 1);
	if (Res != FR_OK) {
		xil_printf("Failed to mount FAT FS. Formatting... 0x%x \r\n", Res);
		Res = f_mkfs(Path, 0, 0);
		if (Res != FR_OK) {
			xil_printf("Failed to format FAT FS 0x%x \r\n", Res);
			return -1;
		}

		Res = f_mount(&fatfs, Path, 0);
		if (Res != FR_OK) {
			xil_printf("Failed to mount FAT FS after format\r\n");
			return -1;
		}
	}

	xil_printf("File system initialization successful\r\n");
	return 0;
}
