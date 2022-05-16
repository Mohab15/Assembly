.MODEL SMALL
.STACK 64
;----------------------------------------------------
.DATA
ELEMENTS    DB '0123456789abcdefABCDEF?'                             
CARDNUMBER  DB  5,?,5 DUP (?)
PASSWORD    DB  5,?,5 DUP (?)
                  
IDs_1       DW 0AAAAH,0BBBBH,0CCCCH,0DDDDH,0EEEEH,0FFFFH,1111H,2222H,3333H,4444H   
IDs_2       DW 5555H,6666H,7777H,8888H,9999H,1000H,2100H,3000H,4000H,5000H
PWs_1       DW 1111H,2222H,3333H,4444H,5555H,6666H,000AH,000BH,000CH,000DH
PWs_2       DW 000EH,000FH,0001H,0002H,0003H,000AH,000BH,000CH,000DH,000EH

SPACER      DB 00H
LINE        DB '----------------------------------------------------','$'
HEADER      DB 'ATM - machine','$'
UNDERLINE   DB '---------------','$'
CHOICE1     DB 'Enter your CardNumber and PASSWORD, Both are 4 hexadecimal digits','$'
ID_INPUT    DB 'Enter your Card Number : ','$'
PW_INPUT    DB 'Enter your password    : ','$' 
ID_ERROR0   DB 'Invalid Card Number (Not enough didgits)','$'
ID_ERROR1   DB 'INVALID,Your Card-Number must contain number (0~9) and letters (A~F)','$'
ID_ERROR2   DB 'Your Card-number is wrong, Please try again!!','$'            
SUCCESS     DB 'Access granted !! (1)','$' 
FAILURE     DB 'Access denied  !! (0)','$'
;----------------------------------------------------
.CODE
MAIN        PROC  FAR
            MOV   AX,@DATA                ;move offset of data segment into $AX
            MOV   DS,AX
            MOV   ES,AX                   ;Make both DS and ES overlapping to be able to point on two different data
            MOV   DH,00H
            CALL  CLEAR                   ;Clear the screen (tzabat el output window To avoid overlapping later)
            MOV   BP,OFFSET SPACER        ;Move the offset of SPACER into BP to set the cursor easily 
;-------            
START:      CALL  NEWLINE
            MOV   DI,OFFSET IDs_1         ;Point to the begging of the Card numbers and password
            MOV   SI,OFFSET IDS_1
            CALL  SETNEWLINE              ;Start a new Line
            CALL  BASE                    ;Display the base messages of the ATM machine
            CALL  PUTNUMBER               ;Take the card number from user (4 digits HEXA)
            CALL  CHECKCOUNT              ;Check that the card number is 4 digits not less
            CALL  HEXACHECK               ;Check that the card number applies the hexadecimal system 
            MOV   SI,OFFSET CARDNUMBER+2  ;Pointer
            CALL  SAVENUMBER              ;Put card number into AX
            CALL  CHECKCARDNO             ;Check the card number into database
            CALL  SETNEWLINE              ;start a new line
            CALL  PUTPASS                 ;take password as input
            MOV   SI,OFFSET PASSWORD+2    ;Pointer
            CALL  SAVENUMBER              ;Put The password into AX
            CALL  CHECKPASS               ;check the Password relevant to the successful ID entered
            CALL  SETNEWLINE              ;start a new line
            CALL  GRANTED                 ;if successful login entry , display successful entrance message
        
;-------
COUNTERROR: CALL  CNTERRORMSG             ;ERROR HANDLING
HEXAERROR:  CALL  HEXAERORMSG             ;ERROR HANDLING            
WRONGNUMBER:CALL  WRONGNOMSG              ;ERROR HANDLING
WRONGPASS:  CALL  DENIED                  ;ERROR HANDLING

MAIN        ENDP            
;----------------------------------------------------
CLEAR       PROC  
            MOV   AX,0600H              ;Clear lines to scroll
            MOV   BH,07H                ;Background color
            MOV   CX,0000H              ;upper and loweer rows number
            MOV   DL,79                 ;right column number
            MOV   DH,24                 ;lower row number
            INT   10H
            RET
CLEAR       ENDP 
;----------------------------------------------------
SETNEWLINE  PROC
            MOV   AH,02H                ;Set cursor position
            MOV   BH,00H                ;Page number
            MOV   DL,00H                ;Column #
            MOV   DH,DS:[BP]            ;row #
            INT   10H
            ADD   DS:[BP],1
            RET
SETNEWLINE  ENDP
;----------------------------------------------------
NEWLINE     PROC
            CALL  SETNEWLINE
            MOV   AH,09H                ;display string
            MOV   DX,OFFSET LINE        ;display the message which has it's offset address in DX
            INT   21H
            RET
NEWLINE     ENDP
;---------------------------------------------------- 
BASE        PROC
            MOV   AH,09H
            MOV   DX,OFFSET HEADER
            INT   21H
            CALL  SETNEWLINE
            MOV   AH,09H
            MOV   DX,OFFSET UNDERLINE
            INT   21H
            CALL  SETNEWLINE
            MOV   AH,09H
            MOV   DX,OFFSET CHOICE1
            INT   21H
            CALL  SETNEWLINE
            MOV   AH,09H
            MOV   DX,OFFSET ID_INPUT
            INT   21H            
            RET
BASE        ENDP 
;----------------------------------------------------
PUTNUMBER   PROC
            MOV   AH,0AH                 ;Buffered keyboard input
            MOV   DX,OFFSET CARDNUMBER
            INT   21H
            RET
PUTNUMBER   ENDP
;---------------------------------------------------- 
CHECKCOUNT  PROC
            LEA   SI,CARDNUMBER+1
            CMP   [SI],04H
            JNZ   COUNTERROR
            RET
CHECKCOUNT  ENDP
;----------------------------------------------------
HEXACHECK   PROC
            MOV   AH,04H
            LEA   SI,CARDNUMBER+2
 LOOPING:   LEA   DI,ELEMENTS
            MOV   CX,23
            MOV   AL,[SI]
            REPNZ SCASB
            CMP   CX,0000
            JZ    DONE
            INC   SI
            DEC   AH
            JNZ   LOOPING
            RET
 DONE:      JMP   HEXAERROR
HEXACHECK   ENDP
;----------------------------------------------------
PUTPASS     PROC
            MOV   AH,09H
            MOV   DX,OFFSET PW_INPUT
            INT   21H
            MOV   AH,0AH
            MOV   DX,OFFSET PASSWORD
            INT   21H           
            RET
PUTPASS     ENDP
;----------------------------------------------------
CNTERRORMSG PROC
            CALL  SETNEWLINE
            MOV   AH,09H
            MOV   DX,OFFSET ID_ERROR0
            INT   21H
            CALL  NEWLINE
            JMP   START
            RET
CNTERRORMSG ENDP           
;---------------------------------------------------- 
HEXAERORMSG PROC
            CALL  SETNEWLINE
            MOV   AH,09H
            MOV   DX,OFFSET ID_ERROR1
            INT   21H
            CALL  NEWLINE
            JMP   START
            RET
HEXAERORMSG ENDP
;----------------------------------------------------
WRONGNOMSG  PROC
            CALL  SETNEWLINE
            MOV   AH,09H
            MOV   DX,OFFSET ID_ERROR2
            INT   21H
            CALL  NEWLINE
            JMP   START
            RET
WRONGNOMSG  ENDP
;----------------------------------------------------
GRANTED     PROC
            MOV   AH,09H
            MOV   DX,OFFSET SUCCESS
            INT   21H
            CALL  NEWLINE
            JMP   START
            RET
GRANTED     ENDP
;----------------------------------------------------
DENIED      PROC
            CALL  SETNEWLINE
            MOV   AH,09H
            MOV   DX,OFFSET FAILURE
            INT   21H
            CALL  NEWLINE
            JMP   START
DENIED      ENDP
;----------------------------------------------------
SAVENUMBER  PROC
            MOV   CX,04H
LOOPING2:   CMP   [SI],39H
            JZ    ZERO
            JB    ZERO         
            JA    DIGIT    
 ZERO:      SUB   [SI],30H
            JMP   DONE2         
 DIGIT:     CMP   [SI],70
            JZ    CAPITAL
            JB    CAPITAL
            JA    SMALL
 CAPITAL:   SUB   [SI],55
            JMP   DONE2 
 SMALL:     SUB   [SI],87
            JMP   DONE2       
 DONE2:     INC   SI 
            DEC   CX   
            JNZ   LOOPING2       
            SUB   SI,4
            MOV   AH,[SI]
            MOV   AL,[SI+2]
            MOV   BH,[SI+1]
            MOV   BL,[SI+3]
            SHL   AX,4
            OR    AX,BX
            RET
SAVENUMBER  ENDP
;----------------------------------------------------
CHECKCARDNO PROC
            MOV   CX,21
            LEA   DI,IDS_1
            CLD
            REPNE SCASW
            CMP   CX,0000H
            JZ    WRONGNUMBER
            RET
CHECKCARDNO ENDP
;----------------------------------------------------
CHECKPASS   PROC
            MOV   BX,AX
            ADD   DI,38
            CMP   BX,[DI]
            JNZ   WRONGPASS            
            RET
CHECKPASS   ENDP
;----------------------------------------------------               