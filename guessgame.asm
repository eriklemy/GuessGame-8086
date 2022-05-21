;               AOC - 2022
; Erick Lemmy dos Santos Oliveira
; Javier Agustin 
 
; GUESS GAME em Assembly 8086 que simule o mecanismo de aproximacao sucessiva para valores entre 00 e 99.
; Dois jogadores intercalam entre os papeis de DESAFIADO e DESAFIANTE.

; O processo deve inicialmente pedir ao DESAFIANTE que digite dois digitos (de 00 a 99), sem exibi-los na tela.
; Este sera o valor secreto a ser procurado;
; A seguir, o programa deve solicitar um palpite ao DESAFIADO. 
; Também são dois digitos, mas devem ser exibidos na tela;

; O programa compara o valor recem entrado com o valor secreto e informa:
; MAIOR: se o valor secreto for maior que o recem digitado. Neste caso, o programa pede mais um palpite para o DESAFIADO (volta ao passo 2);
; MENOR: se o valor secreto for menor que o recem digitado. Neste caso, o programa pede mais um palpite para o DESAFIADO (volta ao passo 2);
; IGUAL: se o valor secreto for igual ao recem digitado. Neste caso, o programa encerra mostrando o número de tentativas necessárias para alcancar a resposta.


;Begin
org  100h
    
    jmp start

; variveis de msgem
    buffer  db 3,?, 3 dup(' ') 
    msg1    db 0Dh, 0Ah, 0Dh, 0Ah, "------------------------ GUESS GAME ------------------------", 0Dh, 0Ah, "$"
    msg2    db 0Dh, 0Ah, "VOCE EH O DESAFIANTE, DIGITE DOIS DIGITOS DE 00 A 99: $"    
    
    msg3    db 0Dh, 0Ah
            db 0Dh, 0Ah, "------------------------------------------------------------", 0Dh, 0Ah
            db 0Dh, 0Ah, "VOCE EH O DESAFIADO: "
            db 0Dh, 0Ah, "ADVINHE OS DIGITOS DO DESAFIANTE, DIGITE DOIS DIGITOS DE 00 A 99: $"
        
    exitMsg db 0Dh, 0Ah, "DESEJA JOGAR NOVAMENTE (S/N): $"
    
    menorMsg  db 0Dh, 0Ah, "O RESULTADO EH MENOR QUE O NUMERO DIGITADO, TENTE NOVAMENTE: $"
    maiorMsg  db 0Dh, 0Ah, "O RESULTADO EH MAIOR QUE O NUMERO DIGITADO, TENTE NOVAMENTE: $"
    
    wonMsg  db 0Dh, 0Ah, 0Dh, 0Ah, "-------------- O VALOR EH IGUAL -> VOCE ACERTOU!! ----------", 0Dh, 0Ah, "$"
    endMsg  db 0Dh, 0Ah, 0Dh, 0Ah, "---------------------- FIM DO PROGRAMA!! ------------------- $"
    
    contMsg db 0Dh, 0Ah, "O NUMERO DE TENTATIVAS NECESSARIAS ATE A RESPOSTA FOI: $"    
    inputErrMsg db 0Dh, 0Ah, "INPUT INVALIDO!!$"
        
                        
start:          
    mov     DX, offset msg1
    mov     AH, 9
    int     21h

    mov     DX, offset msg2
    mov     AH, 9
    int     21h
    call    pega_palpite_oculto
    
    ; confere se o digito da direita esta entre 0 a 9
    cmp     BL, 30h
    jb      inputValueError_1
    cmp     BL, 39h
    ja      inputValueError_1
    
    ; confere se o digito da esquerda esta entre 0 a 9
    cmp     BH, 30h
    jb      inputValueError_1
    cmp     BH, 39h
    ja      inputValueError_1


    ; contador de tentativas (INPUT INVALIDO NAO CONTA)
    mov     CH, 1
    
pega_palpite_msg:    
    mov     DX, offset msg3
    mov     AH, 9                    
    int     21h     

pega_palpite_dnv:
    call    pega_palpite
    
    ; confere se o digito da direita esta entre 0 a 9
    cmp     DL, 30h
    jb      inputValueError_2
    cmp     DL, 39h
    ja      inputValueError_2
    
    ; confere se o digito da esquerda esta entre 0 a 9
    cmp     DH, 30h
    jb      inputValueError_2
    cmp     DH, 39h
    ja      inputValueError_2
    
    cmp     DX, BX  ; se igual ao papalpite oculto (o jogador venceu)
	je      win
	jmp     erro
                       
; input DESAFIANTE - BX:          
pega_palpite_oculto:
    mov     AH, 7
    int     21h 
    mov     BH, AL
    mov     AH, 7
    int     21h
    mov     BL, AL
    ret 
         
; input DESAFIADO - DX
pega_palpite:      
	mov     AH, 1
	int     21h
    mov     DH, AL
    
    mov     AH, 1
    int     21h
    mov     DL, AL	
	ret

; se acertar o valor de input e vencer
win:
    mov     DX, offset wonMsg
    mov     AH, 9
    int     21h
    jmp     imprime_tentativas

; se errar o valor de input
erro:
    inc     CH
    cmp     BX, DX
    ja      maior
    jmp     menor 

; avisa se o numero digita eh um numero maior que o digitado     
maior:
    mov     DX, offset maiorMsg
    mov     AH, 9
    int     21h
    jmp     pega_palpite_dnv

; avisa se o resultado eh um numero menor que o digitado
menor:
    mov     DX, offset menorMsg
    mov     AH, 9
    int     21h
    jmp     pega_palpite_dnv 
    

; mostra quantas tentativas foram necessarias pra vencer
imprime_tentativas:
    mov     DX, offset contMsg
    mov     AH, 9
    int     21h
    
    mov     AH, 2
    add     CH, 48   ; soma 48 para transformar em decimal
    mov     DL, CH
    int     21h
    jmp     exit
        
; termina o programa   
exit:               
    mov     DX, offset exitMsg
    mov     AH, 9
    int     21h     

	mov     AH, 1
	int     21h
	cmp     AL, 'S' ; compara se o input eh igual a S MAISCULO ou nao
    je      start   ; qualquer input != S eh um nao e fecha o jogo 

    mov     DX, offset endMsg
    mov     AH, 9
    int     21h     
    mov     AH, 4Ch
    int     21h

inputValueError_1:
    mov     DX, offset inputErrMsg
    mov     AH, 9
    int     21h     
    jmp     start
 
inputValueError_2:
    mov     DX, offset inputErrMsg
    mov     AH, 9
    int     21h     
    jmp     pega_palpite_msg