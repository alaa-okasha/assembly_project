.MODEL SMALL

.DATA
menu DB '1. Encrypt File', 0Dh, 0Ah, '2. Decrypt File', 0Dh, 0Ah, '3. Exit', 0Dh, 0Ah, 'Enter your choice: $'
keyPrompt DB 0Dh, 0Ah, 'Enter 8-byte XOR key: $'
errorMsg DB 'Error occurred. Program terminating.', 0Dh, 0Ah, '$'

encryptFilename DB 'input.txt', 0
outputFilename DB 'output.txt', 0
key DB 8 DUP(0)
buffer DB 512 DUP(0)
bytesRead DW 0
inputHandle DW 0
outputHandle DW 0
choice DB 0

.CODE
MAIN:
    MOV AX, @DATA
    MOV DS, AX

MENU_LOOP:  

    
    MOV AH, 02h
    MOV DL, 0Dh  
    INT 21h
    MOV DL, 0Ah  
    INT 21h
    
    
    
    LEA DX, menu
    MOV AH, 09h
    INT 21h

    
    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    MOV choice, AL

    
    CMP choice, 1
    JE ENCRYPT_FILE
    CMP choice, 2
    JE DECRYPT_FILE
    CMP choice, 3
    JE EXIT_PROGRAM

    
    JMP MENU_LOOP

ENCRYPT_FILE PROC
    CALL GET_XOR_KEY
    CALL OPEN_ENCRYPT_FILES
    CALL PROCESS_ENCRYPTION
    CALL CLOSE_FILES
    JMP MENU_LOOP
ENCRYPT_FILE ENDP

DECRYPT_FILE PROC
    CALL GET_XOR_KEY
    CALL OPEN_DECRYPT_FILE
    CALL TRUNCATE_OUTPUT_FILE
    CALL PROCESS_ENCRYPTION
    CALL CLOSE_FILES
    JMP MENU_LOOP
DECRYPT_FILE ENDP

GET_XOR_KEY PROC
    
    LEA DX, keyPrompt
    MOV AH, 09h
    INT 21h
    MOV CX, 8
    LEA DI, key
READ_KEY_LOOP:
    MOV AH, 01h
    INT 21h
    MOV [DI], AL
    INC DI
    LOOP READ_KEY_LOOP
    RET
GET_XOR_KEY ENDP

OPEN_ENCRYPT_FILES PROC
    
    MOV AH, 3Dh
    LEA DX, encryptFilename
    MOV AL, 0
    INT 21h
    JC ERROR
    MOV inputHandle, AX

    
    MOV AH, 3Ch
    LEA DX, outputFilename
    MOV CX, 0
    INT 21h
    JC ERROR
    MOV outputHandle, AX
    RET
OPEN_ENCRYPT_FILES ENDP

OPEN_DECRYPT_FILE PROC
    
    MOV AH, 3Dh
    LEA DX, outputFilename
    MOV AL, 0
    INT 21h
    JC ERROR
    MOV inputHandle, AX

    
    MOV AH, 3Ch
    LEA DX, outputFilename
    MOV CX, 0
    INT 21h
    JC ERROR
    MOV outputHandle, AX
    RET
OPEN_DECRYPT_FILE ENDP

TRUNCATE_OUTPUT_FILE PROC
    
    MOV AH, 40h
    MOV BX, outputHandle
    MOV CX, 0 
    LEA DX, buffer
    INT 21h
    RET
TRUNCATE_OUTPUT_FILE ENDP

PROCESS_ENCRYPTION PROC
READ_LOOP:
    
    MOV AH, 3Fh
    MOV BX, inputHandle
    LEA DX, buffer
    MOV CX, 512
    INT 21h
    JC DONE
    MOV bytesRead, AX
    CMP bytesRead, 0
    JE DONE

    
    MOV SI, OFFSET buffer
    MOV CX, bytesRead
    XOR DI, DI
XOR_LOOP:
    MOV AL, [SI]
    XOR AL, [key + DI]
    MOV [SI], AL
    INC SI
    INC DI
    CMP DI, 8
    JNE SKIP_RESET
    XOR DI, DI
SKIP_RESET:
    LOOP XOR_LOOP

    
    MOV AH, 40h
    MOV BX, outputHandle
    LEA DX, buffer
    MOV CX, bytesRead
    INT 21h
    JC ERROR

    JMP READ_LOOP

DONE:
    RET
PROCESS_ENCRYPTION ENDP

CLOSE_FILES PROC
    
    MOV AH, 3Eh
    MOV BX, inputHandle
    INT 21h

    
    MOV AH, 3Eh
    MOV BX, outputHandle
    INT 21h
    RET
CLOSE_FILES ENDP

EXIT_PROGRAM:
    MOV AX, 4C00h
    INT 21h

ERROR:
    LEA DX, errorMsg
    MOV AH, 09h
    INT 21h
    MOV AX, 4C01h
    INT 21h


END MAIN
