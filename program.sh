#!/bin/bash

#openocd -f stm32vldiscovery-busblaster.cfg -c init -c targets -c "halt" -c "flash write_image erase main.elf" -c "verify_image main.elf" -c "reset run" -c shutdown

openocd -f board/stm32vldiscovery.cfg -c init -c targets -c "halt" -c "flash write_image erase main.elf" -c "verify_image main.elf" -c "reset run" -c shutdown
