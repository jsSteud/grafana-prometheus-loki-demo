from typing import Union
from fastapi import FastAPI

import logging
import logging.handlers
import socket

SYSLOG_SERVER = 'loki'
SYSLOG_PORT = 3100

# Entfernen oder kommentieren Sie die vorherige BasicConfig-Zeile aus
# logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Erstellen Sie einen SysLogHandler für das Senden der Logs
syslog_handler = logging.handlers.SysLogHandler(address=(SYSLOG_SERVER, SYSLOG_PORT), facility=logging.handlers.SysLogHandler.LOG_USER)
formatter = logging.Formatter('%(name)s: %(levelname)s %(message)s')
syslog_handler.setFormatter(formatter)

logger.addHandler(syslog_handler)

app = FastAPI()


@app.get("/v1/status/201", status_code=201)
def read_root():
    logger.info("Anfrage an /status/201 erhalten")
    return {}

@app.get("/v1/status/404", status_code=404)
def read_root():
    logger.info("Anfrage an /status/404 erhalten")
    return {}

@app.get("/v1/status/418", status_code=418)
def read_root():
    logger.info("I'm a teapot!")
    return {}


