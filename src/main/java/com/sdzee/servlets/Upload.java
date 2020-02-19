package com.sdzee.servlets;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.sdzee.beans.Fichier;
import com.sdzee.forms.UploadForm;

public class Upload extends HttpServlet {
    public static final String CHEMIN = "chemin";

    public static final String ATT_FICHIER = "fichier";
    public static final String ATT_FORM = "form";

    public static final String VUE = "/WEB-INF/upload.jsp";
    //------------------------------------------------------------------------------------------------------------------
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        /* Affichage de la page d'upload */
        this.getServletContext().getRequestDispatcher(VUE).forward(request, response);
    }
    //------------------------------------------------------------------------------------------------------------------
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // Lecture du paramètre 'chemin' passé à la servlet via la déclaration dans le web.xml
        String chemin = this.getServletConfig().getInitParameter(CHEMIN);

        // Préparation de l'objet formulaire
        UploadForm form = new UploadForm();

        // Traitement de la requête et récupération du bean en résultant
        Fichier fichier = form.enregistrerFichier(request, chemin);

        // Stockage du formulaire et du bean dans l'objet request
        request.setAttribute(ATT_FORM, form);
        request.setAttribute(ATT_FICHIER, fichier);

        this.getServletContext().getRequestDispatcher(VUE).forward(request, response);
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