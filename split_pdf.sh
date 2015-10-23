#!/bin/bash
# Nome: split_cedolini.sh
# Descrizione: Questo script prende il file, pdf, generato da CSSPaghe con i cedolini e lo separa in singoli file
# pdf da n pagine rinominandoli tipo anno_mese_nomeUtente ( es. 2015_novembre_lucacanali ).

# Se si è passato un file ed è valido
if [[ -f $1 && $# == 1 ]]; then
   
   # Variabili
   filename=`basename $1 | cut -d'.' -f1` # Nome file senza percorso reale
   name=`pdftk $1 dump_data | sed -n "/^BookmarkTitle/p" | awk '{print tolower($2) tolower($3)}'` # estrae i titoli dei Bookmark 
   page=`pdftk $1 dump_data | sed -n "/^BookmarkPageNumber/p" | awk '{print $2}'` # Estrae la lista del numero di pagina di partenza del bookmak
   max_page=`pdftk $1 dump_data | sed -n "/^NumberOfPages/p" | awk '{print $2}'` # Estrae il numero totale di pagine
   array_page=(`echo $page | tr " " "\n"`) # Crea l'arrai con in numeri di pagina di partenza del Bookmark
   array_name=(`echo $name | tr " " "\n"`) # Crea l'array con i titoli dei bookmark
   
   # Si prende il file pdf e si splitta nelle numero di giuste pagine e si rinomina
   for i in ${!array_page[@]}; do
      
      # Variabili di appoggio
      x=$i
      p=${array_page[$((++x))]}
      da=${array_page[$i]}
      a=$((p-=1))
      
      # Se si è raggiunto l'ultimo elemento dell'array_page si abbina alla variabile a le pagine massime
      if (( $a <= 0 )); then
         a=$max_page
      fi
      
      # Controlla che ci sia la directory temporanea
      if [ ! -d './tmp' ]; then
         mkdir ./tmp
      fi
      
      # Split del pdf per ogni bookmark e per il numero di pagine adatte
      pdftk $1 cat $da-$a output ./tmp/$filename"_"${array_name[$i]}".pdf"
   done
else
   
   # In caso non si sia inserito il file come parametro o se si inserisce un file inesistente lo script si arresta
   echo "Controllare il corretto utilizzo dell'applicazione."
   echo "Usage: "$0" FILE.pdf"
   exit $?
fi