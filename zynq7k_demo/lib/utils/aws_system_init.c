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
#include <stdio.h>
#include "FreeRTOS.h"
#include "aws_system_init.h"
#include "ff.h"
#include "sleep.h"
#include "xil_printf.h"
#include "aws_pkcs11_config.h"

/* Library code. */
extern BaseType_t BUFFERPOOL_Init( void );
extern BaseType_t MQTT_AGENT_Init( void );
extern BaseType_t SOCKETS_Init( void );

#define clientcredentialMQTT_BROKER_ENDPOINT_NAMELEN	255
const char clientcredentialMQTT_BROKER_ENDPOINT[clientcredentialMQTT_BROKER_ENDPOINT_NAMELEN+1];

#define clientcredentialGG_GROUP_NAMELEN	255
const char clientcredentialGG_GROUP[clientcredentialGG_GROUP_NAMELEN+1];

#define rest_NAMELEN	0
char rest[rest_NAMELEN+1];

#define FILE_NAMELEN    (clientcredentialGG_GROUP_NAMELEN + 1 + 32)
const char pkcs11configFILE_NAME_CLIENT_CERTIFICATE[FILE_NAMELEN + 1];
const char pkcs11configFILE_NAME_KEY[FILE_NAMELEN + 1];

#define IOT_THING_NAMELEN (clientcredentialGG_GROUP_NAMELEN	+ 1 + 32)
const char clientcredentialIOT_THING_NAME[IOT_THING_NAMELEN + 1];

#define pkcs11configFILE_NAME_GG_CONFIG "ggconfig.txt"

/*-----------------------------------------------------------*/

/**
 * @brief Reads a file containing broker id and group id from local storage.
 * The two pieces of information are on separate lines
 * Any sequence of non-printable characters is considered a separator
 *
 * @param[in]  pcFileName    The name of the file to be read.
 *
 * @return pdTRUE if data was retrieved successfully from file,
 * pdFALSE otherwise.
 */
static BaseType_t ReadGreenGrassInfo( const char * pcFileName)
{
	FIL fil;
	FRESULT Res;
	uint32_t uFileBytesLeft;
	UINT N;
    uint32_t uLength;
    char* pDst;
    const int CHAR_EOF = -1;
    char c;
    int iChar;
    BaseType_t SkipLeadingNewlines;
    BaseType_t SkipNextRead;
    typedef struct BrokerLine {
        char* pcDst;
        uint32_t uMaxLength;
        char* pcName;
    } BrokerLine;
    BrokerLine pBrokerLines[] = {
        {
            (char*)&clientcredentialMQTT_BROKER_ENDPOINT[0],
            clientcredentialMQTT_BROKER_ENDPOINT_NAMELEN,
            "BrokerEndpoint",
        },
        {
            (char*)&clientcredentialGG_GROUP[0],
            clientcredentialGG_GROUP_NAMELEN,
            "GroupName"
        },
        {
            (char*)&rest[0],
            rest_NAMELEN,
            "TrailingData"
        },
        {
            0,
            0,
            0
        }
    };
    BrokerLine* pBL;

	Res = f_open(&fil, pcFileName, FA_READ);
	if (Res) {
        for(;;) {
            xil_printf("ERROR: Unable to open file '%s' Res %d\r\n", pcFileName, Res);
            sleep(1);
        }
		return pdFALSE;
	}

	uFileBytesLeft = fil.fsize;
    SkipNextRead = pdFALSE;
    rest[0] = 0;

    for(pBL = pBrokerLines; pBL->pcDst; pBL++) {
        /*
         * Each loop parses newline* valid*
         */
        for(
                SkipLeadingNewlines = pdTRUE, pDst = pBL->pcDst, pBL->pcDst[0] = 0, uLength = 0;
                uLength < pBL->uMaxLength;
                ) {
            if(!SkipNextRead) {
                if(uFileBytesLeft >= 1) {
                    uFileBytesLeft--;
                    /* Read should never hit EOF as we don't read more than fil.fsize bytes */
                    Res = f_read(&fil, &c, 1, &N);
                    if((1 != N) || (Res != 0)) {
                        f_close(&fil);
                        for(;;) {
                            xil_printf("ERROR: Read from file %s failed (%d)\r\n", pcFileName, Res);
                            sleep(1);
                        }
                        return pdFALSE;
                    }
                    iChar = (int)c & 0xff;
                } else {
                    iChar = CHAR_EOF;
                }
            }
            SkipNextRead = pdFALSE;

            if(SkipLeadingNewlines) {
                if(CHAR_EOF == iChar) {
                    break;
                } else if(iChar < 32) {
                    /* Keep looking */
                    ;
                } else {
                    SkipLeadingNewlines = pdFALSE;
                    SkipNextRead = pdTRUE;
                }
            } else {
                if((CHAR_EOF == iChar) || (iChar < 32)) {
                    SkipLeadingNewlines = pdTRUE;
                    *pDst = 0;
                    break;
                } else {
                    *pDst++ = iChar;
                    uLength++;
                }
            }
        }
        if(((0 == uLength) && (pBL->uMaxLength > 0)) || (uLength > pBL->uMaxLength)) {
            f_close(&fil);
            for(;;) {
                xil_printf("ERROR: File '%s': '%s' %s: maxlen %u\r\n",
                    pcFileName,
                    pBL->pcName,
                    (0 == uLength) ? "missing" : "too long",
                    pBL->uMaxLength
                    );
                sleep(1);
            }
            return pdFALSE;
        }
        pBL->pcDst[pBL->uMaxLength] = 0;
    }

	f_close(&fil);

    pDst = (char*)pkcs11configFILE_NAME_CLIENT_CERTIFICATE;
    (void)snprintf(pDst, FILE_NAMELEN + 1,
        "%s-node-zynq7k.crt.pem",
        clientcredentialGG_GROUP
        );
    pDst[FILE_NAMELEN] = 0;

    pDst = (char*)pkcs11configFILE_NAME_KEY;
    (void)snprintf(pDst, FILE_NAMELEN + 1,
        "%s-node-zynq7k.key.prv.pem",
        clientcredentialGG_GROUP
        );
    pDst[FILE_NAMELEN] = 0;

    pDst = (char*)clientcredentialIOT_THING_NAME;
    (void)snprintf(pDst, IOT_THING_NAMELEN + 1,
        "%s-node-zynq7k",
        clientcredentialGG_GROUP
        );
    pDst[IOT_THING_NAMELEN] = 0;

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
    	xResult = ReadGreenGrassInfo(pkcs11configFILE_NAME_GG_CONFIG);
    }

    return xResult;
}
