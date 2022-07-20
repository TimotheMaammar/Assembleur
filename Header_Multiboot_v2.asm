; Canevas de header minimaliste respectant le standard Multiboot2
; À assembler avec le code du kernel
; Tout bootloader gérant le standard Multiboot2 pourra alors démarrer le kernel
; GRUB gère Multiboot et Multiboot2
; En revanche à l'heure actuelle QEMU ne gère que Multiboot

; Compilation :
;   nasm -f elf64 Header_Multiboot_v2.asm -o header.o
; Documentation :
;   https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html


section .header_multiboot2:
; Cette section servira pour l'éditeur de liens

debut:

; ----------------------------------------------------------------------
; TAGS OBLIGATOIRES
; ----------------------------------------------------------------------

    dd 0xe8520d6
    ; Magic number pour le standard Multiboot2
    ; Retrouvable dans la documentation

    dd 0
    ; Code du mode protégé
    ; Au démarrage le processeur est systématiquement dans le mode réel
    ; Mais le mode protégé est plus souple et permet d'adresser beaucoup plus de mémoire

    dd (fin - debut)
    ; Longueur du header calculée proprement

    dd 0x100000000 -  0xe8520d6 - 0 - (fin - debut)
    ; Checksum
    ; La spéficiation Multiboot2 demande une checksum toute simple
    ; Mais ce trick d'ajouter 0x100000000 (2^32) permet d'éviter les valeurs négatives et des erreurs de compilation potentielles


; ----------------------------------------------------------------------
; TAGS FACULTATIFS
; ----------------------------------------------------------------------

;


; ----------------------------------------------------------------------
; TAGS FINAUX OBLIGATOIRES
; ----------------------------------------------------------------------

    dw 0
    dw 0
    dd 8


fin:
