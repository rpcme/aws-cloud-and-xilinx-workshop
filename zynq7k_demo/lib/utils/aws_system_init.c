/*
 * Amazon FreeRTOS System Initialization
 * Copyright (C) 2017 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
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
#include "FreeRTOS.h"
#include "aws_system_init.h"
#include "ff.h"
#include "xil_printf.h"
#include "aws_pkcs11_config.h"

/* Library code. */
extern BaseType_t BUFFERPOOL_Init( void );
extern BaseType_t MQTT_AGENT_Init( void );
extern BaseType_t SOCKETS_Init( void );

#define clientcredentialMQTT_BROKER_ENDPOINT_NAMELEN	127
const char clientcredentialMQTT_BROKER_ENDPOINT[clientcredentialMQTT_BROKER_ENDPOINT_NAMELEN+1];

/*-----------------------------------------------------------*/

/**
 * @brief Reads a file containing broker id from local storage.
 *
 * @param[in]  pcFileName    The name of the file to be read.
 * @param[out] pucData     Buffer for file data.
 * @param[out] ulDataSize  Size (in bytes) of data located in file and buffer size
 *
 * @return pdTRUE if data was retrieved successfully from file,
 * pdFALSE otherwise.
 */
BaseType_t ReadBrokerId( const char * pcFileName,
                                uint8_t * pucData,
                                uint32_t ulDataSize )
{
	FIL fil;
	FRESULT Res;
	uint32_t n;
	UINT N;

	Res = f_open(&fil, pcFileName, FA_READ);
	if (Res) {
		xil_printf("ReadBrokerId ERROR: Unable to open file %s  Res %d\r\n", pcFileName, Res);
		return pdFALSE;
	}

	n = fil.fsize;
	if(n >= ulDataSize) {
		f_close(&fil);
		xil_printf("ReadBrokerId ERROR: File %s Size 0x%08x max 0x%08x\r\n", pcFileName, n, ulDataSize );
		return pdFALSE;
	}

	Res = f_read(&fil, pucData, n, &N);
	if ((n != N) || (Res != 0)) {
		f_close(&fil);
		xil_printf("ReadBrokerId ERROR: Read from file %s failed: Res %d\r\n", pcFileName, Res);
		return pdFALSE;
	}

	f_close(&fil);

	pucData[n] = 0;
	for(uint32_t i = 0; i < n; i++) {
		if(pucData[i] < 32) {
			pucData[i] = 0;
			break;
		}
	}

	return pdTRUE;
}

/*-----------------------------------------------------------*/

/**
 * @brief Initializes Amazon FreeRTOS libraries.
 */
BaseType_t SYSTEM_Init()
{
    BaseType_t xResult = pdPASS;

    xResult = BUFFERPOOL_Init();

    if( xResult == pdPASS )
    {
        xResult = MQTT_AGENT_Init();
    }

    if( xResult == pdPASS )
    {
        xResult = SOCKETS_Init();
    }

    if(xResult == pdPASS )
    {
    	xResult = ReadBrokerId( pkcs11configFILE_NAME_BROKER_ID,
						(uint8_t*)clientcredentialMQTT_BROKER_ENDPOINT,
						clientcredentialMQTT_BROKER_ENDPOINT_NAMELEN );
    }

    return xResult;
}
