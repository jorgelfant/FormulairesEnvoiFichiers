package com.sdzee.servlets;

import java.io.*;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

public class Upload extends HttpServlet {

    public static final String VUE = "/WEB-INF/upload.jsp";
    //----------------------------------------------------------
    public static final String CHAMP_DESCRIPTION = "description";
    public static final String CHAMP_FICHIER = "fichier";
    //----------------------------------------------------------
    public static final String CHEMIN = "chemin";
    public static final int TAILLE_TAMPON = 10240; // 10 ko

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        /* Affichage de la page d'envoi de fichiers */
        this.getServletContext().getRequestDispatcher(VUE).forward(request, response);
    }

    //------------------------------------------------------------------------------------------------------------------
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Lecture du paramètre 'chemin' passé à la servlet via la déclaration dans le web.xml
        String chemin = this.getServletConfig().getInitParameter(CHEMIN);
        // --------------------------------------------------------------
        // Récupération du contenu du champ de description
        String description = request.getParameter(CHAMP_DESCRIPTION);
        request.setAttribute(CHAMP_DESCRIPTION, description);
        // --------------------------------------------------------------
        //Les données reçues sont multipart, on doit donc utiliser la méthode getPart() pour traiter le champ d'envoi de fichiers.
        Part part = request.getPart(CHAMP_FICHIER);
        // --------------------------------------------------------------
        // Il faut déterminer s'il s'agit d'un champ classique ou d'un champ de type fichier : on délègue cette opération
        // à la méthode utilitaire getNomFichier().
        String nomFichier = getNomFichier(part);
        // --------------------------------------------------------------
        // Si la méthode a renvoyé quelque chose, il s'agit donc d'un champ de type fichier (input type="file").
        if (nomFichier != null && !nomFichier.isEmpty()) {
            String nomChamp = part.getName();
            // Antibug pour Internet Explorer, qui transmet pour une raison mystique le chemin du fichier local à la machine du client...
            //
            // Ex : C:/dossier/sous-dossier/fichier.ext
            //
            // On doit donc faire en sorte de ne sélectionner que le nom et l'extension du fichier, et de se débarrasser du superflu.
            nomFichier = nomFichier.substring(nomFichier.lastIndexOf('/') + 1).substring(nomFichier.lastIndexOf('\\') + 1);
            // --------------------------------------------------------------
            // Écriture du fichier sur le disque
            ecrireFichier(part, nomFichier, chemin);
            // --------------------------------------------------------------
            request.setAttribute(nomChamp, nomFichier);
        }
        this.getServletContext().getRequestDispatcher(VUE).forward(request, response);
    }

    //------------------------------------------------------------------------------------------------------------------
    // Méthode utilitaire qui a pour unique but d'analyser l'en-tête "content-disposition", et de vérifier si le
    // paramètre "filename"  y est présent. Si oui, alors le champ traité est de type File et la méthode retourne
    // son nom, sinon il s'agit d'un champ de formulaire classique et la méthode retourne null.
    //------------------------------------------------------------------------------------------------------------------
    private static String getNomFichier(Part part) {
        // Boucle sur chacun des paramètres de l'en-tête "content-disposition".
        for (String contentDisposition : part.getHeader("content-disposition").split(";")) {
            // Recherche de l'éventuelle présence du paramètre "filename".
            if (contentDisposition.trim().startsWith("filename")) {
                // Si "filename" est présent, alors renvoi de sa valeur, c'est-à-dire du nom de fichier sans guillemets.
                return contentDisposition.substring(contentDisposition.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        // Et pour terminer, si rien n'a été trouvé...
        return null;
    }

    //------------------------------------------------------------------------------------------------------------------
    // Méthode utilitaire qui a pour but d'écrire le fichier passé en paramètre sur le disque, dans le répertoire
    // donné et avec le nom donné.
    //------------------------------------------------------------------------------------------------------------------
    private void ecrireFichier(Part part, String nomFichier, String chemin) throws IOException {
        // Prépare les flux.
        BufferedInputStream entree = null;
        BufferedOutputStream sortie = null;
        // BufferedInputStream no es abstracta, es una clase concreta, por tanto puedes crear instancias de esta clase.
        // Su método read devuelve un byte de a cada vez pero mantiene un buffer donde va acumulando los bytes internamente.
        // Así la función read(), lee byte a byte de forma que se puede hacer algun tipo de bucle.

        // int read(byte[] b, int off, int len)
        // b, buffer sobre el que dejaremos los bytes resultado de la lectura.
        // off, indica la posición del buffer en la cual se almacenarán los bytes leídos.
        // len, número de bytes a leer.

        try {
            // Ouvre les flux.
            entree = new BufferedInputStream(part.getInputStream(), TAILLE_TAMPON);
            sortie = new BufferedOutputStream(new FileOutputStream(new File(chemin + nomFichier)), TAILLE_TAMPON);

            // Lit le fichier reçu et écrit son contenu dans un fichier sur le disque.
            byte[] tampon = new byte[TAILLE_TAMPON];
            int longueur;
            //entree a le doc et entree.read(tampon)    >0 ou !=-1
            while ((longueur=entree.read(tampon)) > 0) {//Returns: the next byte of data, or -1 if the end of the stream is reached.
                sortie.write(tampon, 0, longueur);//Writes len bytes from the specified byte array starting at offset off to this buffered output stream.
            }
        } finally {//Dans tous les cas tu vas essayer de fermer la sortie et l'entree
            try {
                sortie.close();
            } catch (IOException ignore) {
            }
            try {
                entree.close();
            } catch (IOException ignore) {
            }
        }
    }
}
/* EJEMPLO PARECIDO A      private void ecrireFichier(Part part, String nomFichier, String chemin) throws IOException {
   QUE ENCONTRE EN INTERNET, la particularidad es a notar en el try catch de los inuts outputs

class MostrarArchivo {
    public static void main(String[] args) {
          int i;
          //fin es inicalizado como nulo
          FileInputStream fin=null;
         //Primero asegúrese de que haya especificado un archivo
         if (args.length!=1){
             System.out.println("Uso: MostrarArchivo.");
             return;
         }
        //El siguiente código abre un archivo,
        // lee caracteres hasta que se encuentra el EOF,
        // y luego cierra el archivo a través de un bloque finally.
        // EOF es un concepto para determinar el final de un archivo
         try {
             fin=new FileInputStream(args[0]);
             do {
                 i=fin.read();
                 if (i !=-1) System.out.print((char)i);
             }while (i!=-1); //Cuando i es igual a -1, se ha alcanzado el final del archivo
         }catch (FileNotFoundException exc){
             System.out.println("Archivo no encontrado");
         }catch (IOException exc){
             System.out.println("Ha ocurrido un error de E/S");
         }finally {
             //Cerrar archivo en todos los casos
             try{
                 //Cierra fin sólo si no es nulo
                 if (fin!=null) fin.close();
             }catch (IOException exc){
                 System.out.println("Error al cerrar archivo.");
             }
         }
    }
}
*/