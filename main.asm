;====================================================================
; Processor: ATtiny13
; 4.8 MHz
;====================================================================

.equ RelayPin	 = PORTB0
.equ RelayDDR	 = DDB0
.equ ErrorLedPin = PORTB1
.equ ErrorLedDDR = DDB1
.equ ActLedPin	 = PORTB2
.equ ActLedDDR	 = DDB2

.equ SENS	 = 510	; 0-1023

.cseg
.org 0x00

      rjmp Setup	; Reset Handler
      reti		; IRQ0 Handler
      reti		; PCINT0 Handler
      reti		; Timer0 Overflow Handler
      reti		; EEPROM Ready Handler
      reti		; Analog Comparator Handler
      reti		; Timer0 CompareA Handler
      reti		; Timer0 CompareB Handler
      reti		; Watchdog Interrupt Handler
      rjmp ADC_VECT	; ADC Conversion Handler

ErrorLedOn:
      sbi	PORTB,	ErrorLedPin
      ret
      
ErrorLedOff:
      cbi	PORTB,	ErrorLedPin
      ret
      
ActLedOn:
      sbi	PORTB,	ActLedPin	
      ret
      
ActLedOff:
      cbi	PORTB,	ActLedPin	
      ret
      
ActLedToggle:
      in 	r16,	PORTB
      ldi	r17,	(1<<ActLedPin)
      eor	r16,	r17
      out	PORTB,	r16
      
RelayOn:
      sbi	PORTB,	RelayPin	
      ret
      
RelayOff:
      cbi	PORTB,	RelayPin	
      ret
      
ADC_VECT:
      rcall 	ActLedToggle
      
      in	r16,	ADCL
      in	r17,	ADCH
      ldi	r18,	LOW(SENS)
      ldi	r19,	HIGH(SENS)
      ; if (ADC>=SENC) Panic()
      cp	r16,	r18
      cpc	r17,	r19
      brge	Panic
      reti
    
Panic:
      cli
      rcall	RelayOff
      rcall 	ErrorLedOn
      rcall	ActLedOff
      sleep	; power-down wait reset
  
Setup:
      ldi	r16,	(1<<ErrorLedDDR) | (1<<ActLedDDR) | (1<<RelayDDR)
      out	DDRB,	r16
      rcall	ActLedOn
      rcall	RelayOn
      
      ldi	r16,	(1<<MUX1) | (1<<MUX0) ; adc pb3 pin
      out	ADMUX,	r16
      
      ldi	r16,	(1<<ADEN) | (1<<ADSC) | (1<<ADATE) | (1<<ADIF) | (1<<ADIE) | (1<<ADPS2) | (1<<ADPS1) | (1<<ADPS0)
      out	ADCSRA,	r16
      
      ldi	r16,	(1<<SE) | (1<<SM1) ; sleep enable | power-down
      out	MCUCR,	r16
      
      ;	timer0
      ldi	r16,	(1<<CS02)|(1<<CS00)
      out	TCCR0B,	r16
      ldi	r16,	(1<<TOIE0)
      out	TIMSK0,	r16
      ldi	r16,	(1<<ADTS2)
      out	ADCSRB,	r16
       
      sei
      
Loop:
      rjmp	Loop

;====================================================================
