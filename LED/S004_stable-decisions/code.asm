; stable-decisions/code.asm
; -------------------------------------------------------------------------
; begin                 : 2012-01-22
; copyright             : Copyright (C) 2012 by Manfred Morgner
; email                 : manfred.morgner@gmx.net
; =========================================================================
;                                                                         |
;   This program is free software; you can redistribute it and/or modify  |
;   it under the terms of the GNU General Public License as published by  |
;   the Free Software Foundation; either version 2 of the License, or     |
;   (at your option) any later version.                                   |
;                                                                         |
;   This program is distributed in the hope that it will be useful,       |
;   but WITHOUT ANY WARRANTY; without even the implied warranty of        |
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
;   GNU General Public License for more details.                          |
;                                                                         |
;   You should have received a copy of the GNU General Public License     |
;   along with this program; if not, write to the                         |
;                                                                         |
;   Free Software Foundation, Inc.,                                       |
;   59 Temple Place Suite 330,                                            |
;   Boston, MA  02111-1307, USA.                                          |
; =========================================================================
;
; This programm will switch on the light on the Arduino LED at Connector 13
; or on your ATmega MC at PORTB Bit 5 (which is the same)
;
; Furhter it will switch the light to the other state if you pull Arduino
; Connector 12 to ground or - respectively - PORTB Bit 4 on your ATmega MC
;
; Which means, we have to manage a state
; -------------------------------------------------------------------------
; Schema description
;
; PB5/ATmega8-Pin19/Arduino-dPin13: LED with 330 Ohm to GND
; PD2/ATmega8-Pin04/Arduino-dPin02: Switch to GND


; TEST: 01.08.2012

.DEVICE atmega8


; ADDRESS TABLE

.org 0x0000
;           ddddddd llllllllllllllllllllllllll             ; ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
            rjmp    start                                  ; register 'start' as Programm Start Point


; MICRO CONTROLLER INITIALISATION SECTION

;llllllllllllllllllllllllll:
start:

;           ddddddd ooooooooooooo rrrrrrrrrrrrrrrrrrrrrrrr ; ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

                                                           ; ATmega-Pin19/Arduino-dPin13 is PORTB/Bit5
            sbi     DDRB,         5                        ; set PORTB/Bit5 to output mode
            cbi     DDRD,         2                        ; set PORTD/Bit2 to input mode
            sbi     PORTD,        2                        ; enable pullup resistor on PORTD/Bit2

            ldi     r16,          1                        ; 'last state' will be 'remembered' as 'high' to begin with

; PROGRAM SECTION

main:
            sbic    PIND,         2                        ; skip next command if Bit2 of PORTD is 0
            rjmp    led_keep                               ; nothings to do, we skip the whole procedure
            tst     r16                                    ; find out if r16 already is NULL
            breq    led_ok                                 ; if so, we already chenged the LED state
            clr     r16                                    ; if not, we finally register that input became 'LOW'
            sbis    PINB,         5                        ; to change the LED state we have to read it
            rjmp    led_on                                 ; it was set to 'on'
            cbi     PORTB,        5                        ; set LED on bit 5 to 'off'
            rjmp    led_ok                                 ; LED handling will end for this squence
led_on:
            sbi     PORTB,        5                        ; set LED on bit 5 to 'on'
            rjmp    led_ok                                 ; LED handling will end for this sequence
led_keep:
            ldi     r16,          1                        ; we are in 'pin high' mode - reset state to 'high'
led_ok:
            rjmp    main                                   ; loop forever by entering 'main' again
