; Affichage du contenu d'un fichier d'1 Go au maximum
; Le choix de la taille est arbitraire et il n'y a aucune sécurité

; Compilation et exécution :
;     nasm -f elf Exemple_Fichier.asm -o Exemple_Fichier.o
;     ld -m elf_i386 Exemple_Fichier.o -o Exemple_Fichier.exe
;     ./Exemple_Fichier.exe


; Les fonctions fournies par le kernel sont aussi retrouvables dans unistd_32.h :
;     "cat /usr/include/x86_64-linux-gnu/asm/unistd_32.h | grep open"
;     => "#define __NR_open 5" => Le code correspondant à "open" sera 5
; On peut retrouver le détail de ces fonctions dans le manuel ("man 2 open")
; Mais il faut parfois les installer ("sudo apt install manpages-dev")



global _start
; Permet de rendre le symbole '_start' visible pour ld
; Évite un warning au moment de l'édition de liens


section .bss ; Section contenant les variables non-initialisées

   descripteur resb 4 ; Pour stocker le futur descripteur de fichier
   buffer resb 1024*1024*1024 ; Allocation de 1 Go pour recueillir le contenu du fichier
   longueur_buffer equ 1024*1024*1024 ; Constante


section .data ; Section contenant les variables initialisées

   message: db "Contenu du fichier : ", 0xa
   longueur: equ ($ - message)
   fichier: db "test.txt", 0


section .text ; Section contenant les instructions

   _start: ; Point d'entrée pour ld

   ;---------------------------
   ; AFFICHAGE
   ;---------------------------

   mov eax, 4 ; ssize_t write(int fd, const void *buf, size_t count)
   mov ebx, 1 ; fd = STDOUT
   mov ecx, message ; buf = Texte défini plus haut
   mov edx, longueur ; count = Longueur du texte
   int 0x80 ; Interruption


   ;---------------------------
   ; OUVERTURE
   ;---------------------------

   mov eax,5 ; int open(const char *pathname, int flags)
   mov ebx,fichier ; Nom du fichier
   mov ecx,0 ; Read-Only
   int 0x80 ; Interruption

   mov [descripteur],eax ; Stockage du descripteur pour après

   ;---------------------------
   ; LECTURE
   ;---------------------------

   mov eax,3 ; ssize_t read(int fd, void *buf, size_t count)
   mov ebx,[descripteur] ; fd = Notre fichier
   mov ecx,buffer ; buf = Notre buffer
   mov edx,longueur_buffer ; count = Longueur du buffer
   int 0x80 ; Interruption


   ;---------------------------
   ; AFFICHAGE
   ;---------------------------

   mov edx,eax ; On place le nombre d'octets lus dans EDX

   mov eax,4 ; ssize_t write(int fd, const void *buf, size_t count)
   mov ebx,1 ; Descripteur correspondant au terminal
   mov ecx,buffer ; On lit depuis le buffer
   int 0x80 ; Interruption


   ;---------------------------
   ; FERMETURE
   ;---------------------------

   mov eax,6 ; int close(int fd)
   mov ebx,[descripteur] ; Notre descripteur
   int 0x80 ; Interruption


   ;---------------------------
   ; SORTIE
   ;---------------------------
   mov al, 1 ; noreturn void _exit(int status)
   mov ebx, 0 ; Code de retour
   int 0x80 ; Interruption
