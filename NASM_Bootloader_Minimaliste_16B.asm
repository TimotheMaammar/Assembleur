; Compilation :
;   nasm NASM_Bootloader_Minimaliste_16B.asm -f bin -o bootloader.bin
; Exécution :
;   qemu-system-x86_64 bootloader.bin


;------------------------------------------------------------------------------------------------------
; DÉBUT OBLIGATOIRE
;------------------------------------------------------------------------------------------------------

[bits 16]
; On reste dans le mode protégé donc il n'y aura pas de passage en mode 32-bits pour notre cas

[org 0x7c00]
; Ligne obligatoire et à copier/coller pour tout bootloader
; 'org' = 'Origin' = Moyen de spécifier une origine fixe pour les éventuelles futures références relatives
; Le BIOS va forcément à cette adresse au démarrage donc c'est un "magic number" arbitraire à connaître


;------------------------------------------------------------------------------------------------------
; AFFICHAGE DE TEXTE
;------------------------------------------------------------------------------------------------------

mov si, texte ; Nécessaire pour la fonction 'lodsb'
call prints

mov si, texte2
call prints

jmp $
; Boucle infinie sur la ligne courante
; Cette technique sert à ne pas tenter d'exécuter la suite par précaution
; On peut retirer cette ligne si on a un vrai bootloader complet qui sort proprement


;------------------------------------------------------------------------------------------------------
; DÉCLARATIONS
;------------------------------------------------------------------------------------------------------

printc:
; Fonction affichant un caractère grâce à une interruption
; On met le code de la fonction à appeler dans le registre AH
; Voir : https://en.wikipedia.org/wiki/INT_10H
    mov ah, 0x0e ; 0x0e = "Teletype output"
    int 0x10 ; 0x10 = Code de l'interruption
    ret

prints:
; Fonction affichant toute une chaîne de caractères
; On boucle et on utilise printc autant de fois qu'il le faut
; La fonction 'lodsb' transfère des données du registre SI vers le registre AL puis incrémente ou décrémente le registre SI
; Voir : https://c9x.me/x86/html/file_module_x86_id_160.html
; Dès que le registre AL passe à 0 on saute sur la sortie
    .boucle:
        lodsb
        test al, al ; Moyen plus optimisé que 'cmp' et 'or' pour tester si un registre est à 0
        je .fin ; On saute seulement si AL = 0
        call printc
        jmp .boucle
    .fin:
        ret

texte db 'Bienvenue !', 0xd, 0xa, 0xa, 0
texte2 db 'Pas encore de kernel pour le moment, revenez plus tard !', 0
; Variables contenant le texte à afficher
; 0xd = Carriage Return
; 0xa = Line Feed
; Voir la table ASCII si besoin


;------------------------------------------------------------------------------------------------------
; FIN OBLIGATOIRE
;------------------------------------------------------------------------------------------------------

times (510-($-$$)) db 0
; Padding final pour que le boot sector fasse 512 octets
; On complète avec des 0 jusqu'à la fin du boot sector
; 510 et pas 512 parce qu'il faut déduire les deux octets finaux
; $ = Début de la ligne en cours
; $$ = Début de la section en cours
; $ - $$ = [Ligne] - [Section] = Point actuel par rapport au début de la section

db 0x55, 0xaa
; Deux octets de fin obligatoires
; Le boot sector doit forcément se terminer par "\x55\xaa"

